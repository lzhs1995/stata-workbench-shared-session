"use strict";
/**
 * test_checkpoint_scope_rc715.js —— StopCheckpoint 作用域闸门 · 对抗性测试
 *
 * 设计原则（任务包硬要求）：只数字符串的测试不算测试。
 *   每条用例都必须证明「闸门在该失败时真的失败」或「在该通过时真的通过」，
 *   且判据来自真 AST 作用域解析，而非文本出现次数。
 *
 * 覆盖的失败模式：
 *   A/A2  越界消费点（rc.7.14 确切形态 + 块粒度形态）
 *   B     导出缺失
 *   C     导出重复 / 非唯一
 *   D     合规形态必须通过（防止闸门恒假）
 *   E/E2  require 锚点重复 / 缺失 → 必须抛错（fail closed）
 *   F     幂等重放（逐字节）
 *   G     真 dist 全绿 + 声明确为 let（证明块粒度判据真的被用到）
 *   H     逆变换重建 rc.7.14 形态 → 必须以确切 2 处越界失败
 *   I     同一闸门对两种形态判决必须相反（防止闸门恒真/恒假）
 */
const assert = require("assert");
const fs = require("fs");
const path = require("path");
const acorn = require("acorn");
const SCOPE = require("./checkpoint_scope_gate.js");
const RC715 = require("./checkpoint_global_export_rc715.js");

const DIST = path.join(__dirname, "..", "dist", "extension.js");
const REQ = 'require("./stop_checkpoint_core.js")';

let pass = 0;
function t(name, fn) {
  fn();
  pass++;
  console.log("  ok  " + name);
}

// ---- A. rc.7.14 确切失败形态：声明在一个函数内、消费点在另一个函数 ----
t("A: 声明在 activate() 内、消费点在外层函数 → 必须判死并点名越界", () => {
  const src =
    "function activate(){let __codexStopCheckpoint=" + REQ + ";" +
    "return __codexStopCheckpoint.publicSummary(null)}\n" +
    "async function humanFile(){return await __codexStopCheckpoint.enrich({})}";
  const r = SCOPE.report(src);
  assert.strictEqual(r.ok, false, "rc.7.14 形态必须失败");
  assert.strictEqual(r.counts.outOfScope, 1, "外层消费点必须计越界");
  assert.ok(
    r.problems.some((p) => /越界裸引用 __codexStopCheckpoint/.test(p)),
    "必须点名越界裸引用"
  );
});

// ---- A2. 块粒度：同函数但**块外** —— 函数粒度判据会漏掉这个 ----
t("A2: let 在块内、消费点在同函数块外 → 仍必须判死（函数粒度会漏判）", () => {
  const src =
    "function activate(){{let __codexStopCheckpoint=" + REQ + ";}" +
    "return __codexStopCheckpoint.cleanup(null)}";
  const r = SCOPE.report(src);
  assert.strictEqual(r.counts.outOfScope, 1, "块作用域外引用必须判死");
  // 反证：若按函数粒度建作用域，该引用会被误判为可解析
  assert.strictEqual(r.ok, false);
});

// ---- A3. 对照：块内消费点必须判为可解析（证明 A2 不是恒判越界） ----
t("A3: let 在块内、消费点在同块内 → 不得计越界（防止判据恒判死）", () => {
  const src =
    "function activate(){{let __codexStopCheckpoint=" + REQ + ";" +
    "__codexStopCheckpoint.cleanup(null)}}";
  const r = SCOPE.report(src);
  assert.strictEqual(r.counts.outOfScope, 0, "块内引用不得计越界");
  assert.strictEqual(r.counts.bareViolations, 1, "但仍违反统一全局形态");
});

// ---- B. 缺导出 ----
t("B: 无 globalThis 导出但已用全局形态 → 必须判死（undefined 与 ReferenceError 同样致命）", () => {
  const src =
    "function activate(){let __codexStopCheckpoint=" + REQ + ";return 1}\n" +
    "function x(){return globalThis.__codexStopCheckpointRef.cleanup(null)}";
  const r = SCOPE.report(src);
  assert.strictEqual(r.ok, false);
  assert.ok(
    r.problems.some((p) => /全局导出缺失：__codexStopCheckpointRef/.test(p)),
    "必须报导出缺失"
  );
  assert.ok(
    r.problems.some((p) => /引用了未成功导出的全局绑定/.test(p)),
    "必须报引用未导出绑定"
  );
});

// ---- C. 导出重复 / 非唯一 ----
t("C: 重复导出 → 必须判死（无法判定最终绑定）", () => {
  const src =
    "function activate(){let __codexStopCheckpoint=(globalThis.__codexStopCheckpointRef=" +
    REQ + ");globalThis.__codexStopCheckpointRef=" + REQ + ";return 1}";
  const r = SCOPE.report(src);
  assert.strictEqual(r.ok, false);
  assert.ok(
    r.problems.some((p) => /全局导出重复：__codexStopCheckpointRef 出现 2 次/.test(p)),
    "必须报导出重复"
  );
});

t("C2: 只读不赋值不算导出（读取不得冒充导出）", () => {
  const src =
    "function activate(){let __codexStopCheckpoint=" + REQ + ";" +
    "return globalThis.__codexStopCheckpointRef}";
  const r = SCOPE.report(src);
  assert.ok(r.problems.some((p) => /全局导出缺失/.test(p)), "读取不得被计为导出");
});

// ---- D. 合规形态必须通过（防止闸门恒假） ----
t("D: 全局导出 + 全部消费点走全局形态 → 通过", () => {
  const src =
    "function activate(){let __codexStopCheckpoint=(globalThis.__codexStopCheckpointRef=" +
    REQ + ");return 1}\n" +
    "function x(){return globalThis.__codexStopCheckpointRef.cleanup(null)}\n" +
    "async function y(){return await globalThis.__codexStopCheckpointRef.enrich({})}";
  const r = SCOPE.report(src);
  assert.strictEqual(r.ok, true, JSON.stringify(r.problems));
  assert.strictEqual(r.counts.bareViolations, 0);
  assert.strictEqual(r.counts.outOfScope, 0);
});

// ---- E. 锚点重复 / 缺失 → 必须抛错（fail closed，绝不静默跳过） ----
t("E: require 锚点重复 → injectExport 抛错", () => {
  const dup = RC715.requireFrom(RC715.SPEC);
  assert.throws(
    () => RC715.injectExport("var a=" + dup + ";var b=" + dup + ";"),
    /rc\.7\.15 require anchor .* must be unique, found 2/
  );
});

t("E2: require 锚点缺失 → injectExport 抛错", () => {
  assert.throws(
    () => RC715.injectExport("var nothing=1;"),
    /rc\.7\.15 require anchor .* must be unique, found 0/
  );
});

t("E3: 导出非唯一时 rewriteBareRefs 抛错（不得在歧义全局上继续改写）", () => {
  const src =
    "function activate(){let __codexStopCheckpoint=" + REQ + ";return 1}";
  assert.throws(
    () => RC715.rewriteBareRefs(src),
    /rc\.7\.15 global export .* must appear exactly once, found 0/
  );
});

// ---- F. 幂等重放（逐字节） ----
t("F: 对已改写文本再跑 apply 不改字节", () => {
  const src = fs.readFileSync(DIST, "utf8");
  const once = RC715.apply(src);
  const twice = RC715.apply(once.text);
  assert.strictEqual(twice.text, once.text, "apply 非幂等（字节发生变化）");
  assert.strictEqual(twice.report.exportAction, "already");
  assert.strictEqual(twice.report.rewritten, 0, "第二遍不应还有可改写的裸消费点");
});

// ---- G. 真 dist 必须全绿 + 声明确为 let ----
t("G: 真 dist 通过闸门，导出恰好一次，声明为 let", () => {
  const r = SCOPE.report(fs.readFileSync(DIST, "utf8"));
  assert.strictEqual(r.ok, true, JSON.stringify(r.problems.slice(0, 6)));
  assert.strictEqual(r.counts.outOfScope, 0);
  assert.strictEqual(r.counts.bareViolations, 0);
  assert.ok(
    /__codexStopCheckpoint:let/.test(r.counts.declKind),
    "声明应为 let（块粒度判据必须真的被用到）：" + r.counts.declKind
  );
  for (const e of r.counts.exports) {
    assert.strictEqual(e.exportCount, 1, e.global + " 导出次数应为 1");
  }
});

/**
 * 逆变换：把最终 dist 折回 rc.7.14 形态。
 * 判据不依赖一次性夹具文件 —— 用确定性逆变换保证「闸门能判死历史缺陷」这条性质
 * 随 dist 演进一起被持续验证。
 */
function recreateRc714(text) {
  const from =
    "__codexStopCheckpoint=(globalThis.__codexStopCheckpointRef=require(globalThis.__codexStopCheckpointPath=";
  const n = text.split(from).length - 1;
  if (n !== 1) throw new Error("重建失败：导出折叠锚点出现 " + n + " 次（应为 1）");
  return text
    .replace(from, "__codexStopCheckpoint=(require(")
    .split("globalThis.__codexStopCheckpointRef")
    .join("__codexStopCheckpoint");
}

// ---- H. 逆变换重建 rc.7.14 形态 → 必须以确切 7 处越界失败 ----
// rc.7.16 新增 human-file pre-dispatch cleanup 消费点；折回词法形态后它与
// enrich / normal cleanup 一样越界；rc.7.19 又增加两条发布前清理消费点，
// rc.7.20 新增一次 Stop 所有权决策消费。rc.7.21 的 readiness 仲裁位于
// activate() 的词法作用域内，所以增加全局引用总数但不增加历史越界数。
// rc.7.30 的 Stop transportSummary 消费点位于外层 Stop 函数，再增加一处。
t("H: 重建的 rc.7.14 形态必须失败，越界数恰为 7，且零导出", () => {
  const rebuilt = recreateRc714(fs.readFileSync(DIST, "utf8"));
  // 先证明重建产物仍是合法 JS（否则失败可能只是语法坏了，不是判据生效）
  acorn.parse(rebuilt, {
    ecmaVersion: "latest",
    sourceType: "script",
    allowReturnOutsideFunction: true,
  });
  const r = SCOPE.report(rebuilt);
  assert.strictEqual(r.ok, false, "rc.7.14 形态必须失败");
  assert.strictEqual(r.counts.outOfScope, 7,
    "越界数应为 7（既有三处 + 两条 rc.7.19 清理 + rc.7.20 所有权决策 + rc.7.30 transportSummary）");
  for (const e of r.counts.exports) {
    assert.strictEqual(e.exportCount, 0, "rc.7.14 形态应零导出");
  }
});

// ---- I. 闸门不得恒真/恒假 ----
t("I: 同一闸门对最终 dist 与 rc.7.14 形态判决必须相反", () => {
  const src = fs.readFileSync(DIST, "utf8");
  const a = SCOPE.report(src).ok;
  const b = SCOPE.report(recreateRc714(src)).ok;
  assert.notStrictEqual(a, b, "判决相同说明闸门恒真或恒假");
  assert.strictEqual(a, true);
  assert.strictEqual(b, false);
});

// ---- J. 打包期闸门（guard_scope_gate）必须并入 checkpoint 判据 ----
t("J: guard_scope_gate 对 rc.7.14 形态必须失败（打包门真的会拦住）", () => {
  const GUARD = require("./guard_scope_gate.js");
  const src = fs.readFileSync(DIST, "utf8");
  const good = GUARD.gateReport(src);
  assert.strictEqual(good.ok, true, JSON.stringify(good.problems.slice(0, 6)));
  assert.strictEqual(good.counts.checkpoint.outOfScope, 0);

  const bad = GUARD.gateReport(recreateRc714(src));
  assert.strictEqual(bad.ok, false, "打包门必须拦住 rc.7.14 形态");
  assert.strictEqual(bad.counts.checkpoint.outOfScope, 7);
  // guard 侧计数必须**不受影响**（证明 rc.7.15 判据没污染 15/15 契约）
  assert.strictEqual(bad.counts.scopeResolvable, 15, "guard 侧仍应 15");
  assert.strictEqual(bad.counts.unresolvable, 0, "guard 侧仍应 0 不可解析");
  assert.ok(
    bad.problems.every((p) => /^\[checkpoint\]/.test(p)),
    "rc.7.14 形态下的问题应全部来自 checkpoint 维：" + bad.problems.slice(0, 3).join(" | ")
  );
});

module.exports = { recreateRc714 };

if (require.main === module) {
  console.log("CHECKPOINT_SCOPE_RC715_TESTS  " + pass + "/" + pass + " passed");
}
