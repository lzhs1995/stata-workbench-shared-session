"use strict";
/**
 * test_guard_scope_gate.js —— 作用域闸门的对抗性测试
 *
 * 为什么要「对抗性」而不是只跑一遍真 bundle：
 *   一个只会对当前 dist 说 OK 的闸门，和没有闸门等价。必须证明它
 *   **在该失败的时候真的失败**，且失败原因分类正确。rc.7.13 的教训是
 *   17/17 全绿掩盖了 10 处 ReferenceError——闸门自己也可能这样骗人。
 *
 * 五类必测（对应任务包）：
 *   A. rc.7.13 的**确切失败形态**：词法 let 在 activate() 内，引用在外
 *   B. 合法捕获该绑定的**嵌套后代**（在声明作用域内层 → 必须判可解析）
 *   C. **兄弟 / 外层**函数（不在声明作用域祖先链上 → 必须判死）
 *   D. 显式全局引用，**有导出**与**无导出**两种（后者必须判死）
 *   E. 混合直连 guardStage / guardProgress / 包装器 policy 引用
 *
 * 另加：把最终 dist 逆变换**重建**成 rc.7.13 形态，验证重建体与真 rc.7.13
 *      夹具给出**同一组 10 个序号**——证明闸门的判据不依赖某个一次性 /tmp 产物。
 */
const assert = require("assert");
const fs = require("fs");
const path = require("path");
const SCOPE = require("./guard_scope_gate.js");

let pass = 0;
function t(name, fn) {
  fn();
  pass++;
  console.log("  ok  " + name);
}

/** 合成夹具骨架：调用点必须是 zg.runSelection(...) 才被可达性核心识别 */
function fixture(body) {
  return "var zg={runSelection:function(){return Promise.resolve(1)}};\n" + body + "\n";
}

const DECL =
  'let __codexExecGuard=require("./execution_guard.js"),' +
  '__codexPreRunGuard=require("./prerun_stage_guard.js");';

// ---------------------------------------------------------------- A
t("A: rc.7.13 确切失败形态——声明在 activate() 内，调用点在外，判不可解析", () => {
  const src = fixture(
    "function activate(){" + DECL + "\n" +
      "  return __codexGuardWrap(()=>zg.runSelection(1),__codexExecGuard.POLICY.PROGRESS);\n" +
      "}\n" +
      "function elsewhere(){\n" +
      "  return __codexGuardWrap(()=>zg.runSelection(2),__codexExecGuard.POLICY.PROGRESS);\n" +
      "}"
  );
  const r = SCOPE.gateReport(src, { expectCounts: false });
  assert.strictEqual(r.rows.length, 2, "两个调用点");
  assert.strictEqual(r.rows[0].scopeResolvable, true, "activate 内可解析");
  assert.strictEqual(r.rows[1].scopeResolvable, false, "activate 外必须判死");
  assert.strictEqual(r.rows[1].guardRefs.unresolvable, 1);
  assert.ok(
    r.problems.some((p) => /越界裸引用 __codexExecGuard/.test(p)),
    "必须点名越界裸引用"
  );
});

// ---------------------------------------------------------------- B
t("B: 嵌套后代合法捕获该绑定——多层嵌套 + 箭头函数都判可解析", () => {
  const src = fixture(
    "function activate(){" + DECL + "\n" +
      "  function mid(){\n" +
      "    const inner=()=>function deepest(){\n" +
      "      return __codexGuardWrap(()=>zg.runSelection(1),__codexExecGuard.POLICY.RECOVERY);\n" +
      "    };\n" +
      "    return inner;\n" +
      "  }\n" +
      "  return mid;\n" +
      "}"
  );
  const r = SCOPE.gateReport(src, { expectCounts: false });
  assert.strictEqual(r.rows.length, 1);
  assert.strictEqual(r.rows[0].scopeResolvable, true, "三层嵌套后代仍在声明作用域内");
  assert.strictEqual(r.rows[0].guardRefs.unresolvable, 0);
  // 但它仍不是统一全局形态 → 必须以「未统一」计违规，不能放过
  assert.ok(
    r.problems.some((p) => /虽词法可解析，但未使用统一全局形态/.test(p)),
    "词法可解析 ≠ 合规；必须要求统一形态"
  );
});

// ---------------------------------------------------------------- C
t("C: 兄弟函数与外层作用域不得解析——即使名字完全相同", () => {
  const src = fixture(
    "function outer(){\n" +
      "  return __codexGuardWrap(()=>zg.runSelection(0),__codexPreRunGuard.POLICY.ABSOLUTE);\n" +
      "}\n" +
      "function activate(){" + DECL + " return 1; }\n" +
      "function sibling(){\n" +
      "  return __codexGuardWrap(()=>zg.runSelection(1),__codexPreRunGuard.POLICY.ABSOLUTE);\n" +
      "}"
  );
  const r = SCOPE.gateReport(src, { expectCounts: false });
  assert.strictEqual(r.rows.length, 2);
  assert.deepStrictEqual(
    r.rows.map((x) => x.scopeResolvable),
    [false, false],
    "外层与兄弟都必须判死"
  );
});

// ---------------------------------------------------------------- D
t("D1: 显式全局引用 + 恰好一次导出 → 可解析", () => {
  const src = fixture(
    "function activate(){" +
      'let __codexExecGuard=(globalThis.__codexExecGuardRef=require("./execution_guard.js"));' +
      'let __codexPreRunGuard=(globalThis.__codexPreRunGuardRef=require("./prerun_stage_guard.js"));' +
      " return 1; }\n" +
      "function elsewhere(){\n" +
      "  return __codexGuardWrap(()=>zg.runSelection(1),globalThis.__codexExecGuardRef.POLICY.PROGRESS);\n" +
      "}"
  );
  const r = SCOPE.gateReport(src, { expectCounts: false });
  assert.strictEqual(r.rows[0].scopeResolvable, true, "显式全局 + 有导出 = 可解析");
  assert.strictEqual(r.rows[0].guardRefs.global, 1);
  assert.ok(!r.problems.some((p) => /未成功导出/.test(p)));
});

t("D2: 显式全局引用但**无导出** → 必须判死（拿到 undefined 和 ReferenceError 一样致命）", () => {
  const src = fixture(
    "function activate(){" + DECL + " return 1; }\n" +
      "function elsewhere(){\n" +
      "  return __codexGuardWrap(()=>zg.runSelection(1),globalThis.__codexExecGuardRef.POLICY.PROGRESS);\n" +
      "}"
  );
  const r = SCOPE.gateReport(src, { expectCounts: false });
  assert.strictEqual(r.rows[0].scopeResolvable, false, "全局绑定没导出 = 不可解析");
  assert.ok(
    r.problems.some((p) => /全局导出缺失：__codexExecGuardRef/.test(p)),
    "必须报导出缺失"
  );
  assert.ok(
    r.problems.some((p) => /引用了未成功导出的全局绑定/.test(p)),
    "必须报「引用未导出绑定」"
  );
});

t("D3: 全局绑定**重复导出** → 必须判死（无法判定最终绑定）", () => {
  const src = fixture(
    "function activate(){" +
      'let __codexExecGuard=(globalThis.__codexExecGuardRef=require("./execution_guard.js"));' +
      'globalThis.__codexExecGuardRef=require("./other_guard.js");' +
      " return 1; }"
  );
  const r = SCOPE.gateReport(src, { expectCounts: false });
  assert.ok(
    r.problems.some((p) => /全局导出重复：__codexExecGuardRef 出现 2 次/.test(p)),
    "重复导出必须报错"
  );
});

t("D4: 只**读取** globalThis.<Ref> 不算导出", () => {
  const src = fixture(
    "function activate(){" + DECL + "\n" +
      "  var probe=globalThis.__codexExecGuardRef;\n" +
      " return probe; }"
  );
  const m = SCOPE.analyze(src);
  assert.strictEqual((m.exports.get("__codexExecGuardRef") || []).length, 0, "读取不是导出");
});

// ---------------------------------------------------------------- E
t("E: 混合 guardStage / guardProgress / 包装器三种 policy 引用形态都被解析", () => {
  const src = fixture(
    "function activate(){" +
      'let __codexExecGuard=(globalThis.__codexExecGuardRef=require("./execution_guard.js"));' +
      'let __codexPreRunGuard=(globalThis.__codexPreRunGuardRef=require("./prerun_stage_guard.js"));' +
      " return 1; }\n" +
      "async function a(){\n" +
      '  return await globalThis.__codexPreRunGuardRef.guardStage("snapshot",()=>zg.runSelection(1),{timeoutMs:60000});\n' +
      "}\n" +
      "async function b(){\n" +
      "  return await globalThis.__codexExecGuardRef.guardProgress(()=>zg.runSelection(2),{});\n" +
      "}\n" +
      "async function c(){\n" +
      "  return __codexGuardWrap(()=>zg.runSelection(3),globalThis.__codexExecGuardRef.POLICY.SHORT_INTERNAL);\n" +
      "}"
  );
  const r = SCOPE.gateReport(src, { expectCounts: false });
  assert.strictEqual(r.rows.length, 3);
  assert.deepStrictEqual(r.rows.map((x) => x.scopeResolvable), [true, true, true]);
  assert.deepStrictEqual(
    r.rows.map((x) => x.guardKind),
    ["guardStage", "guardProgress", "guardWrap"],
    "三种 guard 形态都要被正确归类"
  );
  assert.strictEqual(r.counts.unresolvable, 0);
});

t("E2: guard 引用出现在**工作体内部**不算该调用点的 guard 引用（避免误判可解析）", () => {
  // guard 调用用全局形态（合规），但工作体里另有一个越界裸引用：
  // 该裸引用必须被全量裸引用检查抓到，而不是被算成本调用点的 guard 引用。
  const src = fixture(
    "function activate(){" +
      'let __codexExecGuard=(globalThis.__codexExecGuardRef=require("./execution_guard.js"));' +
      'let __codexPreRunGuard=(globalThis.__codexPreRunGuardRef=require("./prerun_stage_guard.js"));' +
      " return 1; }\n" +
      "function elsewhere(){\n" +
      "  return __codexGuardWrap(()=>{__codexExecGuard.note();return zg.runSelection(1)}," +
      "globalThis.__codexExecGuardRef.POLICY.PROGRESS);\n" +
      "}"
  );
  const r = SCOPE.gateReport(src, { expectCounts: false });
  assert.strictEqual(r.rows[0].scopeResolvable, true, "guard 引用本身合规");
  assert.strictEqual(r.rows[0].guardRefs.bare, 0, "工作体内的引用不计入 guard 引用");
  assert.ok(
    r.problems.some((p) => /越界裸引用 __codexExecGuard/.test(p)),
    "但全量裸引用检查必须仍然抓到它——闸门不能只看 guard 调用头"
  );
  assert.strictEqual(r.ok, false);
});

// ---------------------------------------------------------------- 白名单
t("F: 白名单只认声明点与包装器闭包，且包装器越界时白名单失效", () => {
  const good = fixture(
    "function activate(){" +
      'let __codexExecGuard=(globalThis.__codexExecGuardRef=require("./execution_guard.js"));' +
      'let __codexPreRunGuard=(globalThis.__codexPreRunGuardRef=require("./prerun_stage_guard.js"));' +
      "globalThis.__codexGuardWrap=function(fn,p){let __EG=__codexExecGuard;return __EG.run(fn,p)};" +
      " return 1; }"
  );
  const rg = SCOPE.gateReport(good, { expectCounts: false });
  assert.ok(!rg.problems.some((p) => /裸引用/.test(p)), "声明点 + 作用域内包装器闭包都应放过");

  // 包装器装到声明作用域**外**：其闭包引用不可解析，白名单必须失效
  const bad = fixture(
    "function activate(){" + DECL + " return 1; }\n" +
      "globalThis.__codexGuardWrap=function(fn,p){let __EG=__codexExecGuard;return __EG.run(fn,p)};"
  );
  const rb = SCOPE.gateReport(bad, { expectCounts: false });
  assert.ok(
    rb.problems.some((p) => /越界裸引用 __codexExecGuard/.test(p)),
    "越界的包装器闭包不能靠白名单蒙过去"
  );
});

// ------------------------------------------------- 重建 rc.7.13 夹具并对照
/**
 * 把最终 rc.7.14 dist **逆变换**回 rc.7.13 形态：
 *   1. 折叠 require 链上的显式全局导出（→ 零导出）
 *   2. globalThis.<X>Ref → 裸 <X>（→ 全部裸引用，含 10 处越界）
 * 这样夹具是从我们自己掌握的字节**确定性重建**的，不依赖任何一次性产物。
 */
function recreateRc713(text) {
  let out = text;
  const collapse = [
    ["__codexPreRunGuard=(globalThis.__codexPreRunGuardRef=require(globalThis.__codexPreRunGuardPath=",
     "__codexPreRunGuard=(require("],
    ["__codexExecGuard=(globalThis.__codexExecGuardRef=require(globalThis.__codexExecGuardPath=",
     "__codexExecGuard=(require("],
  ];
  for (const [from, to] of collapse) {
    const n = out.split(from).length - 1;
    if (n !== 1) throw new Error("重建失败：导出折叠锚点出现 " + n + " 次（应为 1）: " + from.slice(0, 40));
    out = out.replace(from, to);
  }
  for (const [lex, glob] of Object.entries(SCOPE.GUARDS)) {
    out = out.split("globalThis." + glob).join(lex);
  }
  return out;
}

const EXPECTED_DEAD_ORDINALS = [7, 9, 10, 11, 13, 14, 15, 16, 17];
const LEGACY_RC713_DEAD_ORDINALS = [8, 10, 11, 12, 13, 15, 16, 17, 18, 19];
const DIST = path.join(__dirname, "..", "dist", "extension.js");

t("G: 最终 dist 通过硬计数闸门（total 17 / retired 2 / 15-15-15 / unresolvable 0 / policy 15/15）", () => {
  const r = SCOPE.gateReport(fs.readFileSync(DIST, "utf8"));
  if (!r.ok) console.error(r.problems.slice(0, 10).join("\n"));
  assert.strictEqual(r.ok, true, "最终 dist 必须全绿");
  assert.strictEqual(r.counts.totalCallsites, 17);
  assert.strictEqual(r.counts.retired, 2);
  assert.strictEqual(r.counts.reachable, 15);
  assert.strictEqual(r.counts.guarded, 15);
  assert.strictEqual(r.counts.scopeResolvable, 15);
  assert.strictEqual(r.counts.unresolvable, 0);
  assert.strictEqual(r.counts.policyMatched, 15);
  assert.strictEqual(r.counts.bareViolations, 0, "最终 dist 不得有任何非白名单裸引用");
  for (const e of r.counts.exports) assert.strictEqual(e.exportCount, 1, e.global + " 必须恰好导出一次");
});

t("H: 从 rc.7.19 逆变换的 rc.7.13 绑定形态必须以确切的 9 个序号失败", () => {
  const rebuilt = recreateRc713(fs.readFileSync(DIST, "utf8"));
  require("acorn").parse(rebuilt, { ecmaVersion: "latest", sourceType: "script", allowReturnOutsideFunction: true });
  const r = SCOPE.gateReport(rebuilt);
  assert.strictEqual(r.ok, false, "rc.7.13 形态必须失败");
  const dead = r.rows.filter((x) => !x.retired && x.scopeResolvable === false).map((x) => x.ord);
  assert.deepStrictEqual(dead, EXPECTED_DEAD_ORDINALS, "失败序号必须精确匹配当前 17-callsite 拓扑");
  assert.strictEqual(r.counts.scopeResolvable, 6);
  assert.strictEqual(r.counts.unresolvable, 9);
  for (const e of r.counts.exports) assert.strictEqual(e.exportCount, 0, "rc.7.13 形态零导出");
});

t("I: 真 rc.7.13 历史夹具（若在场）仍给出原始 19-callsite 的 10 个序号", () => {
  const real = process.env.RC713_FIXTURE || path.join(__dirname, "..", "tests", "fixtures", "extension.js.rc713-54e645da");
  if (!fs.existsSync(real)) {
    console.log("      (skip: 真 rc.7.13 夹具不在场 " + real + "；重建体断言已覆盖判据)");
    return;
  }
  const r = SCOPE.gateReport(fs.readFileSync(real, "utf8"));
  const dead = r.rows.filter((x) => !x.retired && x.scopeResolvable === false).map((x) => x.ord);
  assert.deepStrictEqual(dead, LEGACY_RC713_DEAD_ORDINALS);
  assert.strictEqual(r.counts.unresolvable, 10);
});

t("J: 闸门对最终 dist 与 rc.7.13 形态的判决必须相反（防止闸门恒真/恒假）", () => {
  const finalR = SCOPE.gateReport(fs.readFileSync(DIST, "utf8"));
  const rc713R = SCOPE.gateReport(recreateRc713(fs.readFileSync(DIST, "utf8")));
  assert.notStrictEqual(finalR.ok, rc713R.ok, "同一闸门必须能区分两者");
  assert.strictEqual(finalR.ok, true);
  assert.strictEqual(rc713R.ok, false);
});

module.exports = { recreateRc713, EXPECTED_DEAD_ORDINALS };

if (require.main === module) {
  console.log("GUARD_SCOPE_GATE_TESTS  " + pass + "/" + pass + " passed");
}
