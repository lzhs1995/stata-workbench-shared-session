"use strict";
/**
 * test_replay_rc713.js —— 从原始基线**跨目录树**确定性重放门禁
 *
 * 为什么要这个门禁（血的教训，必须留着）：
 *   我第一次跑重放时报了 IDEMPOTENT_OK，那是**假的**。补丁在临时树里因
 *   `Cannot find module 'acorn'` 直接崩了、一个字节都没写，两遍都停在基线 sha，
 *   我却把「基线==基线」当成了「重放一致」——而且 `tail -3` 把栈吞了所以没看见。
 *   所以本文件里：
 *     · 临时树必须 symlink node_modules（否则 acorn 缺失）；
 *     · 子进程退出码必须为 0，stderr 必须无 "Cannot find module"；
 *     · 产物 sha 必须**不等于**输入基线 sha（证明真写了东西）；
 *     · 两棵独立树的产物必须逐字节相同。
 *   少任何一条，"重放通过" 就可能又是自己骗自己。
 *
 * 另外导出 makeReplayTree/runPatchInTree 供 test_guard_wiring_rc713.js 复用，
 * 用来取「打完核心补丁、还没接线」的中间态文本（core 锚点只在那份文本里成形）。
 */
const assert = require("node:assert");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const crypto = require("node:crypto");
const { spawnSync } = require("node:child_process");

const REPO = path.join(__dirname, "..");
const BASELINE = path.join(REPO, "tests", "fixtures", "extension.js.95aa8079");
const BASELINE_SHA16 = "95aa8079aa18dcab";
const sha256 = (buf) => crypto.createHash("sha256").update(buf).digest("hex");

let pass = 0; const fails = [];
function t(name, fn) {
  try { fn(); pass++; console.log("  PASS " + name); }
  catch (e) { fails.push(name + " — " + ((e && e.message) || e));
              console.log("  FAIL " + name + "  — " + ((e && e.message) || e)); }
}

/**
 * 造一棵可独立跑补丁的临时树。
 *
 * ⚠️ scripts/* 必须**实体拷贝**，不能 symlink：Node 的 __dirname 会解析穿透
 * symlink，于是补丁里的 path.join(__dirname,"..","dist","extension.js") 会指回
 * **真仓库**的 dist —— 我第一版就是这样把真 dist 当成临时树改了（幸亏 apply
 * 幂等，sha 未变）。node_modules 仍可 symlink：它只参与模块解析，不参与 __dirname。
 *
 * @param {{captureIntermediate?:string}} opts captureIntermediate 给出路径时，
 *        用一个「记录入参再转交真模块」的替身覆盖 guard_wiring_rc713.js，
 *        从而把接线前的中间态原文落盘。
 */
function makeReplayTree(opts) {
  const o = opts || {};
  const root = fs.realpathSync(fs.mkdtempSync(path.join(os.tmpdir(), "rc713-replay-")));
  fs.mkdirSync(path.join(root, "scripts"));
  fs.mkdirSync(path.join(root, "dist"));
  for (const ent of fs.readdirSync(path.join(REPO, "scripts"), { withFileTypes: true })) {
    if (!ent.isFile()) continue; // 子目录（如 scripts/mac）补丁不用，跳过
    if (o.captureIntermediate && ent.name === "guard_wiring_rc713.js") continue;
    fs.copyFileSync(path.join(REPO, "scripts", ent.name), path.join(root, "scripts", ent.name));
  }
  fs.symlinkSync(path.join(REPO, "node_modules"), path.join(root, "node_modules"));
  fs.copyFileSync(BASELINE, path.join(root, "dist", "extension.js"));
  if (o.captureIntermediate) {
    const real = JSON.stringify(path.join(REPO, "scripts", "guard_wiring_rc713.js"));
    const outFile = JSON.stringify(o.captureIntermediate);
    fs.writeFileSync(path.join(root, "scripts", "guard_wiring_rc713.js"),
      '"use strict";\n' +
      "// 测试替身：先把接线前的中间态写盘，再原样转交真模块（不改变行为）\n" +
      "const __real = require(" + real + ");\n" +
      "module.exports = Object.assign({}, __real, {\n" +
      "  apply(text) { require(\"fs\").writeFileSync(" + outFile + ", text, \"utf8\"); return __real.apply(text); },\n" +
      "});\n", "utf8");
  }
  return root;
}

/**
 * 在临时树里跑真补丁；返回 {status, stdout, stderr, distPath, sha, bytes}。
 *
 * P2-1（审计意见）：旧版把「真仓库 dist 未被动过」的断言放在 execFileSync **成功之后**，
 * 于是「子进程先改了真 dist、再非零退出」这条路径会先抛异常、根本走不到作用域检查 ——
 * 恰恰是最危险的那条路没人看。现在改成：
 *   1. 子进程退出状态/stdout/stderr 一律**捕获成结果**，不靠异常来传递；
 *   2. 真 dist 的 sha 校验放在 finally 等价路径里，**先校验作用域，再决定接受还是重抛**；
 *   3. 成功路径也要查 stderr（旧版只在失败时看，报告却声称查了 stdout/stderr）。
 *
 * @param {string} root 临时树根
 * @param {{allowFailure?:boolean}} opts allowFailure=true 时非零退出不抛，交调用方断言
 *        （给"缺依赖必须被发现且真 dist 不变"的负例用）
 */
function runPatchInTree(root, opts) {
  const o = opts || {};
  // realDistPath 可注入：仅为让"越界检测本身有效"可被证明（A.6 用临时decoy），
  // 默认仍是真仓库 dist。审计明令不得故意改真 dist 来测这条。
  const realDist = o.realDistPath || path.join(REPO, "dist", "extension.js");
  const script = o.scriptPath || path.join(root, "scripts", "apply_rc7_shared_execution_patch.js");
  const realShaBefore = fs.existsSync(realDist) ? sha256(fs.readFileSync(realDist)) : null;

  // 不用 execFileSync 的「抛异常」当控制流：spawnSync 把状态/输出一并给回来。
  const cp = spawnSync(process.execPath, [script],
    { cwd: root, encoding: "utf8", stdio: ["ignore", "pipe", "pipe"] });

  const stdout = cp.stdout || "";
  const stderr = cp.stderr || "";
  // status 为 null 表示被信号杀死或压根没起来；spawnError 单独留痕
  const status = cp.status;
  const spawnError = cp.error ? String((cp.error && cp.error.message) || cp.error) : null;

  // —— 作用域检查：无论子进程成败，都必须先跑 ——
  // 放在这里（而不是成功分支里）就是 P2-1 的要点：失败也可能已经把真 dist 改了。
  let scopeViolation = null;
  if (realShaBefore) {
    const realShaAfter = sha256(fs.readFileSync(realDist));
    if (realShaAfter !== realShaBefore) {
      scopeViolation = "临时树重放改动了**真仓库 dist**（__dirname 穿透 symlink 的坑复发）：" +
        realShaBefore.slice(0, 16) + " → " + realShaAfter.slice(0, 16);
    }
  }
  // 作用域违规优先于一切：即使子进程非零退出，也要先把越界喊出来。
  if (scopeViolation) throw new Error(scopeViolation);

  const failed = status !== 0 || spawnError !== null;
  if (failed && !o.allowFailure) {
    throw new Error("补丁在临时树中失败（这正是第一次假 PASS 的成因）：status=" + status +
      (spawnError ? " spawnError=" + spawnError : "") +
      " stderr=" + stderr.slice(0, 600));
  }
  // 成功路径也查 stderr：缺模块/未捕获异常有时只落在 stderr。
  if (!failed && /Cannot find module|MODULE_NOT_FOUND|UnhandledPromiseRejection|ERR_[A-Z_]+/.test(stderr)) {
    throw new Error("子进程退出码 0 但 stderr 有致命征兆（不得当成功）：" + stderr.slice(0, 600));
  }

  const distPath = path.join(root, "dist", "extension.js");
  const exists = fs.existsSync(distPath);
  const buf = exists ? fs.readFileSync(distPath) : Buffer.alloc(0);
  return {
    status, spawnError, stdout, stderr, distPath,
    sha: exists ? sha256(buf) : null,
    bytes: buf.length,
    realDistShaBefore: realShaBefore,
    realDistUnchanged: true, // 走到这里即已断言过
  };
}

function main() {
  console.log("=== rc.7.13 跨目录树确定性重放门禁 ===\n");
  const FIN = require("./finalize_bundle_identity.js");
  const AST = require("./ast_reachability_gate.js");
  const guardWiring = require("./guard_wiring_rc713.js");

  t("0.1 基线存在且 sha 前16位为 " + BASELINE_SHA16, () => {
    assert.ok(fs.existsSync(BASELINE), "基线缺失：" + BASELINE);
    const s = sha256(fs.readFileSync(BASELINE));
    assert.strictEqual(s.slice(0, 16), BASELINE_SHA16, "基线 sha 变了：" + s.slice(0, 16));
  });
  t("0.2 基线是**未接线**原文（19 裸调用 / 0 wrapper）", () => {
    const src = fs.readFileSync(BASELINE, "utf8");
    assert.strictEqual(guardWiring.countOccurrences(src, guardWiring.CALL_HEAD), 19, "基线调用点数不是 19");
    assert.strictEqual(guardWiring.countOccurrences(src, guardWiring.WRAP_HEAD), 0, "基线竟已含 wrapper，不是干净基线");
  });

  console.log("\n[A] 两棵独立临时树各自重放");
  const trees = [];
  const results = [];
  t("A.1 两棵树均成功产出（退出码 0、无缺模块、产物 ≠ 基线）", () => {
    const baseSha = sha256(fs.readFileSync(BASELINE));
    for (let i = 0; i < 2; i++) {
      const root = makeReplayTree({});
      trees.push(root);
      const r = runPatchInTree(root);
      results.push(r);
      assert.ok(!/Cannot find module/.test(r.stdout), "stdout 出现缺模块（第一次假 PASS 的病征）");
      assert.notStrictEqual(r.sha, baseSha, "产物与基线同 sha = 补丁根本没写盘（假重放）");
      assert.ok(r.bytes > 5000000, "产物过小：" + r.bytes);
    }
  });
  t("A.2 两棵树产物逐字节相同（确定性）", () => {
    assert.strictEqual(results[0].sha, results[1].sha,
      "重放不确定：" + results[0].sha.slice(0, 16) + " vs " + results[1].sha.slice(0, 16));
  });
  t("A.3 重放日志确认真接线了 12 处（wrapped=12，非 verified）", () => {
    assert.ok(/RC713_GUARD_WIRING\s+wrapped=12\s+verifiedWrapped=0\s+migratedWrapped=0\s+verifiedCore=3\s+retired=2\s+total=17/.test(results[0].stdout),
      "接线日志不符：" + (results[0].stdout.match(/RC713_GUARD_WIRING.*/) || ["(无)"])[0]);
  });
  t("A.4 分歧检测**本身有效**：任意一字节不同必须被同一判据判为不一致", () => {
    // 没有这条，A.2 的「两棵树相同」有可能只是判据太钝而不是真的确定性。
    const a = fs.readFileSync(results[0].distPath);
    const at = a.indexOf(Buffer.from("timeoutMs:30000", "utf8"));
    assert.ok(at > 0, "样本失效：产物里找不到 timeoutMs:30000");
    const b = Buffer.from(a); // 拷一份只改一个字节
    b[at + "timeoutMs:3000".length] = "1".charCodeAt(0); // 30000 → 30001
    assert.notStrictEqual(sha256(b), sha256(a), "改一个字节 sha 竟不变（判据无效）");
    // 用与 A.2 完全相同的判据复核：它必须拒绝这一对
    assert.throws(() => assert.strictEqual(sha256(b), sha256(a)), /AssertionError|Expected/,
      "A.2 用的判据对单字节分歧无感 —— 那条 PASS 就没有意义");
  });

  t("A.5 【P2-1 负例】缺依赖 → 子进程非零退出**必被发现**，且真仓库 dist 不变", () => {
    // 复刻第一次假 PASS 的现场：临时树不铺 node_modules，acorn 解析不到。
    // 两件事都要证：(a) 失败被识别为失败（不再吞栈冒充成功）；
    //              (b) 失败路径上真仓库 dist 依然逐字节不变 —— 旧版这条断言在
    //                  execFileSync 之后，非零退出会先抛，压根跑不到。
    // 注意：绝不故意去改真 dist 来"测"这条（审计明令），只观察真实失败路径。
    const realDist = path.join(REPO, "dist", "extension.js");
    const before = sha256(fs.readFileSync(realDist));

    const root = fs.realpathSync(fs.mkdtempSync(path.join(os.tmpdir(), "rc713-nodeps-")));
    trees.push(root);
    fs.mkdirSync(path.join(root, "scripts"));
    fs.mkdirSync(path.join(root, "dist"));
    for (const ent of fs.readdirSync(path.join(REPO, "scripts"), { withFileTypes: true })) {
      if (!ent.isFile()) continue;
      fs.copyFileSync(path.join(REPO, "scripts", ent.name), path.join(root, "scripts", ent.name));
    }
    fs.copyFileSync(BASELINE, path.join(root, "dist", "extension.js")); // 故意不建 node_modules

    // allowFailure：让结果回到手里，才能逐项断言，而不是被异常带走
    const r = runPatchInTree(root, { allowFailure: true });
    assert.notStrictEqual(r.status, 0, "缺 acorn 竟然退出码 0 —— 失败没被识别（假 PASS 复发）");
    assert.ok(/Cannot find module|MODULE_NOT_FOUND/.test(r.stderr + r.stdout),
      "没看到缺模块证据，负例样本失效：status=" + r.status + " stderr=" + r.stderr.slice(0, 200));
    // (b) 作用域：真 dist 必须没被这次失败的重放动过
    assert.strictEqual(sha256(fs.readFileSync(realDist)), before,
      "失败路径上真仓库 dist 被改动了");
    // 临时树的 dist 应仍是基线原文（补丁没写成任何东西）
    assert.strictEqual(r.sha, sha256(fs.readFileSync(BASELINE)),
      "补丁崩溃却改了临时树 dist，状态不一致");

    // 并且默认模式（allowFailure 省略）必须把这次失败**抛出来**：
    // 这条正是"第一次假 PASS"不可能再悄悄发生的保证。
    assert.throws(() => runPatchInTree(root), /补丁在临时树中失败/,
      "默认模式没有对失败抛错 —— 又会被当成功");
  });

  t("A.6 【P2-1 判据自证】子进程「先改越界文件、再非零退出」必须报越界，而非只报失败", () => {
    // A.5 证明了失败会被发现；但"失败时作用域检查也跑了"还需要单独证明 ——
    // 否则那句断言可能只是从没被触发过。这里用一个 decoy 充当"受保护文件"
    // （绝不动真 dist），让子进程改它并非零退出，看守卫是否喊越界。
    const root = fs.realpathSync(fs.mkdtempSync(path.join(os.tmpdir(), "rc713-scope-")));
    trees.push(root);
    fs.mkdirSync(path.join(root, "scripts"));
    const decoy = path.join(root, "decoy-protected.bin");
    fs.writeFileSync(decoy, "ORIGINAL-PROTECTED-CONTENT", "utf8");
    const evil = path.join(root, "scripts", "mutate_then_fail.js");
    fs.writeFileSync(evil,
      'require("fs").writeFileSync(' + JSON.stringify(decoy) + ', "MUTATED", "utf8");\n' +
      'process.exit(3);\n', "utf8");

    // 越界必须**优先于**失败被报出来（这正是旧版做不到的：非零退出先抛，检查跑不到）
    assert.throws(
      () => runPatchInTree(root, { realDistPath: decoy, scriptPath: evil, allowFailure: true }),
      /改动了\*\*真仓库 dist\*\*|改动了/,
      "子进程改了受保护文件却没被判越界 —— 作用域断言在失败路径上是死的"
    );
    // 反证：同样非零退出但不碰受保护文件时，不应误报越界
    const clean = path.join(root, "scripts", "just_fail.js");
    fs.writeFileSync(clean, "process.exit(4);\n", "utf8");
    fs.writeFileSync(decoy, "ORIGINAL-PROTECTED-CONTENT", "utf8"); // 复位
    const r2 = runPatchInTree(root, { realDistPath: decoy, scriptPath: clean, allowFailure: true });
    assert.strictEqual(r2.status, 4, "干净失败的退出码没拿到");
    assert.strictEqual(fs.readFileSync(decoy, "utf8"), "ORIGINAL-PROTECTED-CONTENT",
      "受保护文件被无关进程改了？");
  });

  console.log("\n[B] 重放产物的覆盖率与指纹（与真 dist 对齐）");
  const REAL_DIST = path.join(REPO, "dist", "extension.js");
  t("B.1 重放产物 15/15 已守卫、0 裸活跃调用、退役点保持裸态", () => {
    const src = fs.readFileSync(results[0].distPath, "utf8");
    const r = AST.analyze(src);
    assert.strictEqual(r.callsites.length, 17, "调用点总数不是 17");
    const live = r.callsites.filter((c) => c.reachable);
    const dead = r.callsites.filter((c) => !c.reachable);
    assert.strictEqual(live.length, 15, "可达点不是 15");
    assert.strictEqual(dead.length, 2, "退役点不是 2");
    assert.strictEqual(live.filter((c) => !c.guarded).length, 0, "仍有裸活跃调用");
    assert.strictEqual(dead.filter((c) => c.guarded).length, 0, "退役点被注 guard = 假接线");
  });
  t("B.2 重放产物 guardKind 分布 = {guardWrap:12, guardStage:2, guardProgress:1}", () => {
    const src = fs.readFileSync(results[0].distPath, "utf8");
    const k = {};
    AST.analyze(src).callsites.filter((c) => c.guarded)
      .forEach((c) => { k[c.guardKind] = (k[c.guardKind] || 0) + 1; });
    assert.deepStrictEqual(k, { guardWrap: 12, guardStage: 2, guardProgress: 1 }, "分布不符：" + JSON.stringify(k));
  });
  t("B.3 重放产物落地前是 UNFINALIZED（槽位仍为 64 个 0）", () => {
    const src = fs.readFileSync(results[0].distPath, "utf8");
    const slot = FIN.locateSlot(src);
    assert.strictEqual(slot.value, FIN.ZERO_SLOT,
      "重放产物槽位竟已被写值——finalize 不该发生在补丁里");
  });
  t("B.4 两棵树 finalize 后指纹相同，且等于真 dist 的 guardBuildFingerprint", () => {
    const f0 = FIN.fingerprintOf(fs.readFileSync(results[0].distPath, "utf8"));
    const f1 = FIN.fingerprintOf(fs.readFileSync(results[1].distPath, "utf8"));
    assert.strictEqual(f0, f1, "两棵树指纹不同");
    const realSrc = fs.readFileSync(REAL_DIST, "utf8");
    assert.strictEqual(f0, FIN.fingerprintOf(realSrc),
      "重放指纹 " + f0.slice(0, 16) + " ≠ 真 dist " + FIN.fingerprintOf(realSrc).slice(0, 16));
  });
  t("B.5 重放 finalize 后与真 dist 逐字节相同（DIST_EQUALS_REPLAY）", () => {
    const finalized = FIN.finalize(fs.readFileSync(results[0].distPath, "utf8"));
    const text = typeof finalized === "string" ? finalized : finalized.text;
    assert.strictEqual(sha256(Buffer.from(text, "utf8")), sha256(fs.readFileSync(REAL_DIST)),
      "真 dist 不等于基线重放产物 —— dist 里有非重放来源的字节（须查明再打包）");
  });

  // 清理临时树（只删自己在 os.tmpdir() 里造的 rc713-replay-* 目录）
  for (const root of trees) { try { fs.rmSync(root, { recursive: true, force: true }); } catch { /* 清理失败不影响判定 */ } }

  console.log("\n" + "=".repeat(58));
  console.log("  PASS=" + pass + "  FAIL=" + fails.length);
  if (fails.length) { fails.forEach((f) => console.log("   - " + f)); process.exit(1); }
  console.log("  REPLAY_DETERMINISTIC_OK");
}

if (require.main === module) main();

module.exports = { makeReplayTree, runPatchInTree, BASELINE, BASELINE_SHA16, sha256 };
