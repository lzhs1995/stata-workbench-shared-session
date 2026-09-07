"use strict";
/**
 * test_guard_module_identity_rc714.js —— 运行时 guard 模块身份（只读）的可执行测试
 *
 * 补的是哪个洞：
 *   dist 在运行时 require 两个**外部**脚本 scripts/execution_guard.js 与
 *   scripts/prerun_stage_guard.js，真正决定超时/截止时间的逻辑在它们里面。
 *   但 bundle 身份（dist/extension.js 的 SHA + guardBuildFingerprint）**不覆盖**它们：
 *   把 execution_guard.js 的 60000 改成 1，dist SHA 一字节不变、bundle identity 仍报 OK。
 *   → 于是 /status 增加只读的 guard 模块摘要，且**必须 fail-closed**：
 *     模块缺失/不可读 → guardModuleIdentityState 明确非 OK，绝不静默当健康。
 *
 * 与 wedge 测试同样的原则：从 dist 现抽生成片段真执行，而不是 grep。
 */
const assert = require("assert");
const fs = require("fs");
const os = require("os");
const path = require("path");
const crypto = require("crypto");

const DIST = path.join(__dirname, "..", "dist", "extension.js");
const SRC = fs.readFileSync(DIST, "utf8");

let pass = 0;
function t(name, fn) { fn(); pass++; console.log("  ok  " + name); }

// --------------------------------------------------------------- 抽片段
function cutBetween(from, to) {
  const a = SRC.indexOf(from);
  assert.ok(a >= 0, "找不到起点 " + from.slice(0, 50));
  const b = SRC.indexOf(to, a + from.length);
  assert.ok(b >= 0, "找不到终点 " + to.slice(0, 50));
  return SRC.slice(a, b + to.length);
}

const COMPUTE = cutBetween("globalThis.__codexComputeGuardModuleIdentity=function(){", "return R};");
const STATUS_FN = cutBetween("globalThis.__codexGuardModuleIdentityStatus=function(){", "guardModules:I.guardModules||{}}};");

/** 在受控 globalThis 上装载抽出的两个函数并返回它
 *
 *  必须同时注入 require：生产里 dist 是 CJS 模块，`require` 是模块局部变量；
 *  new Function 的函数体跑在全局作用域里没有它。不注入的话片段会
 *  fail-closed 成 MODULE_UNREADABLE（这本身说明兜底是对的，但测不到正常路径）。
 */
function loadInto(g) {
  new Function("globalThis", "require", COMPUTE + STATUS_FN)(g, require);
  return g;
}

function sha256File(p) {
  return crypto.createHash("sha256").update(fs.readFileSync(p)).digest("hex");
}

// --------------------------------------------------------------- 测试
t("M0: 生成片段在 dist 中各恰好一次，且 /status 挂载点带 fail-closed 兜底", () => {
  assert.strictEqual(SRC.split("globalThis.__codexComputeGuardModuleIdentity=function(){").length - 1, 1);
  assert.strictEqual(SRC.split("globalThis.__codexGuardModuleIdentityStatus=function(){").length - 1, 1);
  assert.strictEqual(SRC.split("/* codex-guard-module-identity-v1 */").length - 1, 1, "幂等标记只应一次");
  // /status 展开：必须与 bundle 身份展开**一一对应**地挂在同一个状态对象构造点上
  const bundleSpreads = [...SRC.matchAll(/\.\.\.\(globalThis\.__codexBundleIdentityStatus\?/g)];
  const spreads = [...SRC.matchAll(/\.\.\.\(globalThis\.__codexGuardModuleIdentityStatus\?/g)];
  assert.strictEqual(spreads.length, bundleSpreads.length,
    "guard 模块身份必须挂在 bundle 身份出现的每一处（bundle " + bundleSpreads.length +
      " 处 vs guard " + spreads.length + " 处）");
  assert.strictEqual(spreads.length, 1, "当前 bundle 只有一个状态对象构造点");
  assert.ok(spreads[0].index > bundleSpreads[0].index, "guard 身份应紧随 bundle 身份之后展开");
  for (const m of spreads) {
    const seg = SRC.slice(m.index, m.index + 340);
    assert.ok(/guardModuleIdentityState:"IDENTITY_UNREADABLE"/.test(seg),
      "缺 fail-closed 兜底：helper 缺失时必须明确报不可读，不能展开成空对象");
    assert.ok(/guardModuleCombinedSha256:null/.test(seg), "兜底必须把摘要显式置 null");
  }
});

t("M1: 真实仓库路径 → state=OK，两模块摘要与独立计算一致", () => {
  const execPath = path.join(__dirname, "execution_guard.js");
  const prePath = path.join(__dirname, "prerun_stage_guard.js");
  const g = loadInto({ __codexExecGuardPath: execPath, __codexPreRunGuardPath: prePath });
  const r = g.__codexComputeGuardModuleIdentity();
  assert.strictEqual(r.guardModuleIdentityState, "OK", r.guardModuleIdentityError || "");
  assert.strictEqual(r.guardModuleIdentityError, null);
  assert.strictEqual(r.guardModules.executionGuard.sha256, sha256File(execPath), "executionGuard 摘要必须等于真文件 SHA256");
  assert.strictEqual(r.guardModules.preRunStageGuard.sha256, sha256File(prePath), "preRunStageGuard 摘要必须等于真文件 SHA256");
  assert.strictEqual(r.guardModules.executionGuard.bytes, fs.statSync(execPath).size);
  assert.strictEqual(r.guardModules.preRunStageGuard.bytes, fs.statSync(prePath).size);
  // 组合摘要 = sha256("name=sha\nname=sha")，顺序为 executionGuard 先
  const expect = crypto.createHash("sha256").update(Buffer.from(
    "executionGuard=" + sha256File(execPath) + "\npreRunStageGuard=" + sha256File(prePath), "utf8")).digest("hex");
  assert.strictEqual(r.guardModuleCombinedSha256, expect, "组合摘要算法必须可独立复算");
  assert.strictEqual(r.guardModuleCombinedSha256.length, 64);
});

t("M2: 这正是 bundle 身份漏掉的那一维——改模块字节，组合摘要必须变", () => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "rc714-modid-"));
  const execPath = path.join(dir, "execution_guard.js");
  const prePath = path.join(dir, "prerun_stage_guard.js");
  fs.copyFileSync(path.join(__dirname, "execution_guard.js"), execPath);
  fs.copyFileSync(path.join(__dirname, "prerun_stage_guard.js"), prePath);

  const g1 = loadInto({ __codexExecGuardPath: execPath, __codexPreRunGuardPath: prePath });
  const before = g1.__codexComputeGuardModuleIdentity();
  assert.strictEqual(before.guardModuleIdentityState, "OK");

  // 模拟「悄悄把 60000 截止时间改成 1」这类致命篡改
  const distShaBefore = sha256File(DIST);
  fs.appendFileSync(execPath, "\n/* tampered deadline */\n");
  const g2 = loadInto({ __codexExecGuardPath: execPath, __codexPreRunGuardPath: prePath });
  const after = g2.__codexComputeGuardModuleIdentity();

  assert.strictEqual(after.guardModuleIdentityState, "OK", "篡改后文件仍可读，状态仍是 OK");
  assert.notStrictEqual(after.guardModuleCombinedSha256, before.guardModuleCombinedSha256,
    "组合摘要必须变——否则这一维毫无意义");
  assert.notStrictEqual(after.guardModules.executionGuard.sha256, before.guardModules.executionGuard.sha256);
  assert.strictEqual(after.guardModules.preRunStageGuard.sha256, before.guardModules.preRunStageGuard.sha256,
    "未被改的模块摘要必须稳定（能定位到具体是哪个模块变了）");
  assert.strictEqual(sha256File(DIST), distShaBefore,
    "对照：dist SHA 完全不变——这就是 bundle 身份的盲区");

  fs.rmSync(dir, { recursive: true, force: true });
});

t("M3: 模块不可读 → fail-closed（MODULE_UNREADABLE + 点名哪个模块 + 摘要为 null）", () => {
  const g = loadInto({
    __codexExecGuardPath: path.join(os.tmpdir(), "definitely-absent-execution-guard-" + Date.now() + ".js"),
    __codexPreRunGuardPath: path.join(__dirname, "prerun_stage_guard.js"),
  });
  const r = g.__codexComputeGuardModuleIdentity();
  assert.strictEqual(r.guardModuleIdentityState, "MODULE_UNREADABLE", "缺文件绝不能报 OK");
  assert.strictEqual(r.guardModuleCombinedSha256, null, "不可读时组合摘要必须为 null");
  assert.ok(/executionGuard:/.test(r.guardModuleIdentityError), r.guardModuleIdentityError);
  assert.ok(r.guardModules.executionGuard.error, "必须记下具体错误");
  assert.strictEqual(r.guardModules.executionGuard.sha256, null);
  // 另一个仍应正常读出，便于定位
  assert.strictEqual(r.guardModules.preRunStageGuard.sha256, sha256File(path.join(__dirname, "prerun_stage_guard.js")));
});

t("M4: 路径从未被捕获（undefined）→ 同样 fail-closed 并说明原因", () => {
  const g = loadInto({});
  const r = g.__codexComputeGuardModuleIdentity();
  assert.strictEqual(r.guardModuleIdentityState, "MODULE_UNREADABLE");
  assert.strictEqual(r.guardModuleCombinedSha256, null);
  assert.ok(/never captured at require time/.test(r.guardModuleIdentityError), r.guardModuleIdentityError);
  for (const nm of ["executionGuard", "preRunStageGuard"]) {
    assert.ok(r.guardModules[nm].error, nm + " 必须报错");
    assert.strictEqual(r.guardModules[nm].path, null);
  }
});

t("M5: 两个模块都不可读时，错误信息必须都点名（不能只报第一个）", () => {
  const g = loadInto({
    __codexExecGuardPath: path.join(os.tmpdir(), "absent-a-" + Date.now() + ".js"),
    __codexPreRunGuardPath: path.join(os.tmpdir(), "absent-b-" + Date.now() + ".js"),
  });
  const r = g.__codexComputeGuardModuleIdentity();
  assert.strictEqual(r.guardModuleIdentityState, "MODULE_UNREADABLE");
  assert.ok(/executionGuard:/.test(r.guardModuleIdentityError));
  assert.ok(/preRunStageGuard:/.test(r.guardModuleIdentityError));
});

t("M6: status 包装器缓存结果、只读、且字段齐全", () => {
  const execPath = path.join(__dirname, "execution_guard.js");
  const prePath = path.join(__dirname, "prerun_stage_guard.js");
  const g = loadInto({ __codexExecGuardPath: execPath, __codexPreRunGuardPath: prePath });

  let computes = 0;
  const real = g.__codexComputeGuardModuleIdentity;
  g.__codexComputeGuardModuleIdentity = function () { computes++; return real.call(this); };

  const s1 = g.__codexGuardModuleIdentityStatus();
  const s2 = g.__codexGuardModuleIdentityStatus();
  assert.strictEqual(computes, 1, "应缓存：第二次不得重算（/status 是热路径，不能每次读盘）");
  assert.deepStrictEqual(Object.keys(s1).sort(),
    ["guardModuleCombinedSha256", "guardModuleIdentityError", "guardModuleIdentityState", "guardModules"]);
  assert.strictEqual(s1.guardModuleIdentityState, "OK");
  assert.strictEqual(s1.guardModuleCombinedSha256, s2.guardModuleCombinedSha256);

  // 只读：改返回对象不得影响下一次
  s1.guardModuleIdentityState = "TAMPERED";
  assert.strictEqual(g.__codexGuardModuleIdentityStatus().guardModuleIdentityState, "OK",
    "返回值被改不得污染内部状态");
});

t("M7: compute 不写任何文件、不改 guard 行为（纯只读）", () => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "rc714-ro-"));
  const execPath = path.join(dir, "execution_guard.js");
  const prePath = path.join(dir, "prerun_stage_guard.js");
  fs.copyFileSync(path.join(__dirname, "execution_guard.js"), execPath);
  fs.copyFileSync(path.join(__dirname, "prerun_stage_guard.js"), prePath);
  const before = fs.readdirSync(dir).sort();
  const mtimes = before.map((f) => fs.statSync(path.join(dir, f)).mtimeMs);

  const g = loadInto({ __codexExecGuardPath: execPath, __codexPreRunGuardPath: prePath });
  g.__codexComputeGuardModuleIdentity();
  g.__codexGuardModuleIdentityStatus();

  assert.deepStrictEqual(fs.readdirSync(dir).sort(), before, "不得新建/删除文件");
  assert.deepStrictEqual(before.map((f) => fs.statSync(path.join(dir, f)).mtimeMs), mtimes, "不得改动 mtime");
  // 抽出的片段里不得出现任何写操作
  for (const bad of ["writeFileSync", "appendFileSync", "unlinkSync", "rmSync", "mkdirSync"]) {
    assert.ok(!COMPUTE.includes(bad), "compute 片段不得含 " + bad);
    assert.ok(!STATUS_FN.includes(bad), "status 片段不得含 " + bad);
  }
  fs.rmSync(dir, { recursive: true, force: true });
});

t("M8: dist 确实在运行时捕获了两个 require 路径（否则 M4 的失败态就是生产常态）", () => {
  for (const g of ["__codexExecGuardPath", "__codexPreRunGuardPath"]) {
    const assigns = [...SRC.matchAll(new RegExp("globalThis\\." + g + "=", "g"))];
    assert.strictEqual(assigns.length, 1, g + " 必须恰好在 require 处捕获一次，实际 " + assigns.length);
    // 捕获点必须就在对应 require( 里，而不是事后重新推导路径
    const seg = SRC.slice(assigns[0].index - 60, assigns[0].index + 200);
    assert.ok(/require\(globalThis\.__codex(Exec|PreRun)GuardPath=/.test(seg),
      g + " 必须是 require(globalThis.X=<path>) 形态，保证摘要的是真正被加载的那个文件；实际: " + seg.slice(0, 120));
  }
  assert.ok(SRC.includes('"execution_guard.js"'));
  assert.ok(SRC.includes('"prerun_stage_guard.js"'));
});

console.log("GUARD_MODULE_IDENTITY_TESTS  " + pass + "/9 passed");
if (pass !== 9) process.exit(1);
