"use strict";
/**
 * js_scope_scan 单测 —— 含 codex 点名的三类反证：
 *   ① 超长死分支（不能因长度被截断 → 4000 字节窗口正是死在这）
 *   ② 嵌套 try/catch（consequent 非 block、且跨 catch/finally）
 *   ③ 紧邻的活跃调用（死分支结束后的调用**不得**被误判为死）
 * 另覆盖 minified 常见坑：字符串/模板/注释/正则里的假括号。
 */
const assert = require("node:assert");
const S = require("./js_scope_scan.js");

let pass = 0; const fails = [];
function t(name, fn) {
  try { fn(); pass++; console.log("  PASS " + name); }
  catch (e) { fails.push(name + " — " + ((e && e.message) || e));
              console.log("  FAIL " + name + "  — " + ((e && e.message) || e)); }
}
const dead = (src) => S.findConstFalseBranches(src);
const isDead = (src, needle) => S.inAnyRange(dead(src), src.indexOf(needle));

(function main() {
  console.log("=== js_scope_scan 单测（替代 4000 字节窗口）===\n");

  console.log("[A] 基本形态");
  t("A.1 block consequent：内部调用判死", () => {
    const s = 'a();if(false&&x){DEADCALL()}LIVECALL();';
    assert.strictEqual(isDead(s, "DEADCALL"), true);
    assert.strictEqual(isDead(s, "LIVECALL"), false);
  });
  t("A.2 if(false) 无 && 也识别", () => {
    const s = 'if(false){DEADCALL()}LIVECALL();';
    assert.strictEqual(isDead(s, "DEADCALL"), true);
    assert.strictEqual(isDead(s, "LIVECALL"), false);
  });
  t("A.3 !1 形式（minifier 常产）", () => {
    const s = 'if(!1&&y){DEADCALL()}LIVECALL();';
    assert.strictEqual(isDead(s, "DEADCALL"), true);
    assert.strictEqual(isDead(s, "LIVECALL"), false);
  });
  t("A.4 真分支不得判死", () => {
    const s = 'if(true&&x){LIVECALL()}';
    assert.strictEqual(dead(s).length, 0);
    assert.strictEqual(isDead(s, "LIVECALL"), false);
  });

  console.log("\n[B] codex 反证①：超长死分支（长度不得影响判定）");
  t("B.1 死分支体 > 20000 字节，末尾调用仍判死", () => {
    const filler = "var _x=1;".repeat(3000);           // ~27KB
    const s = 'if(false&&a){' + filler + 'DEADCALL()}LIVECALL();';
    assert.ok(s.indexOf("DEADCALL") > 20000, "样本没到 20KB");
    assert.strictEqual(isDead(s, "DEADCALL"), true, "超长死分支末尾被漏判（窗口式缺陷）");
    assert.strictEqual(isDead(s, "LIVECALL"), false);
  });
  t("B.2 4000 字节窗口在此样本上会**误判**（证明旧法确有缺陷）", () => {
    const filler = "var _x=1;".repeat(3000);
    const s = 'if(false&&a){' + filler + 'DEADCALL()}LIVECALL();';
    const at = s.indexOf("if(false&&");
    const windowEnd = at + 4000;                        // 旧启发式
    const deadPos = s.indexOf("DEADCALL");
    assert.ok(deadPos >= windowEnd, "旧窗口本应覆盖不到该位置");
    assert.strictEqual(isDead(s, "DEADCALL"), true, "新扫描器必须仍判死");
  });

  console.log("\n[C] codex 反证②：嵌套 try/catch + 非 block consequent");
  t("C.1 consequent 是 try 语句（无外层大括号）", () => {
    const s = 'if(false&&a)try{DEADCALL()}catch(e){DEADCATCH()}LIVECALL();';
    assert.strictEqual(isDead(s, "DEADCALL"), true);
    assert.strictEqual(isDead(s, "DEADCATCH"), true, "catch 块也属死分支");
    assert.strictEqual(isDead(s, "LIVECALL"), false, "紧随其后的调用是活的");
  });
  t("C.2 try/catch/finally 三段都算死", () => {
    const s = 'if(false&&a)try{D1()}catch(e){D2()}finally{D3()}LIVECALL();';
    ["D1", "D2", "D3"].forEach((k) =>
      assert.strictEqual(isDead(s, k), true, k + " 应判死"));
    assert.strictEqual(isDead(s, "LIVECALL"), false);
  });
  t("C.3 深层嵌套 {{{}}} 不错位", () => {
    const s = 'if(false&&a){if(b){while(c){DEADCALL()}}}LIVECALL();';
    assert.strictEqual(isDead(s, "DEADCALL"), true);
    assert.strictEqual(isDead(s, "LIVECALL"), false);
  });

  console.log("\n[D] codex 反证③：紧邻活跃调用不被误伤");
  t("D.1 死分支后紧贴活跃调用（无分隔）", () => {
    const s = 'if(false&&a){D()}LIVE1();LIVE2();';
    assert.strictEqual(isDead(s, "LIVE1"), false);
    assert.strictEqual(isDead(s, "LIVE2"), false);
  });
  t("D.2 两个死分支之间夹一个活跃调用", () => {
    const s = 'if(false&&a){D1()}MIDLIVE();if(false&&b){D2()}TAILLIVE();';
    assert.strictEqual(isDead(s, "D1"), true);
    assert.strictEqual(isDead(s, "D2"), true);
    assert.strictEqual(isDead(s, "MIDLIVE"), false, "夹在中间的活跃调用被误判");
    assert.strictEqual(isDead(s, "TAILLIVE"), false);
  });
  t("D.3 死分支内嵌 else 活支：else 内**不**属死分支", () => {
    const s = 'if(false&&a){D()}else{ELSELIVE()}TAIL();';
    assert.strictEqual(isDead(s, "D"), true);
    assert.strictEqual(isDead(s, "ELSELIVE"), false, "else 分支是可达的");
  });

  console.log("\n[E] minified 词法坑：字符串/模板/注释/正则里的假括号");
  t("E.1 字符串里的 } 不提前收尾", () => {
    const s = 'if(false&&a){var q=\"}\";DEADCALL()}LIVECALL();';
    assert.strictEqual(isDead(s, "DEADCALL"), true, "被字符串里的 } 提前收尾");
    assert.strictEqual(isDead(s, "LIVECALL"), false);
  });
  t("E.2 模板串（含 ${} 嵌套）不错位", () => {
    const s = 'if(false&&a){var q=`x${ {k:1} }y`;DEADCALL()}LIVECALL();';
    assert.strictEqual(isDead(s, "DEADCALL"), true);
    assert.strictEqual(isDead(s, "LIVECALL"), false);
  });
  t("E.3 注释里的括号不影响", () => {
    const s = 'if(false&&a){/* } } } */DEADCALL()}LIVECALL();';
    assert.strictEqual(isDead(s, "DEADCALL"), true);
    assert.strictEqual(isDead(s, "LIVECALL"), false);
  });
  t("E.4 正则字面量里的 } / 引号不影响", () => {
    const s = 'if(false&&a){var re=/[}\'\"]/g;DEADCALL()}LIVECALL();';
    assert.strictEqual(isDead(s, "DEADCALL"), true);
    assert.strictEqual(isDead(s, "LIVECALL"), false);
  });
  t("E.5 除法不被误当正则（不吞掉后续代码）", () => {
    const s = 'var n=(a)/2;if(false&&b){D()}LIVECALL();';
    assert.strictEqual(isDead(s, "D"), true);
    assert.strictEqual(isDead(s, "LIVECALL"), false);
  });

  console.log("\n[F] 真实 dist 上的行为（回归锚定）");
  t("F.1 dist 里 #14 的 codex_humanfile_state_ 判死，且活跃 guard 全不判死", () => {
    const fs = require("node:fs"), path = require("node:path");
    const d = fs.readFileSync(path.join(__dirname, "..", "dist", "extension.js"), "utf8");
    const ranges = dead(d);
    assert.ok(ranges.length >= 1, "dist 里应至少有一个常量假分支");
    const mi = d.indexOf("codex_humanfile_state_");
    assert.ok(mi > 0, "找不到 #14 标识串");
    assert.strictEqual(S.inAnyRange(ranges, mi), true, "#14 应判死（不可达）");
    // 活跃 guard 一个都不能落在死分支里
    const re = /guardStage\("(?:snapshot|enrich)"/g;
    let m, live = 0;
    while ((m = re.exec(d)) !== null) {
      assert.strictEqual(S.inAnyRange(ranges, m.index), false,
        "guard 注入落在死分支内（假接线）@" + m.index);
      live++;
    }
    assert.strictEqual(live, 4, "活跃 guard 应 4 处，实为 " + live);
  });

  console.log("\n" + "=".repeat(58));
  console.log("  PASS=" + pass + "  FAIL=" + fails.length);
  if (fails.length) { fails.forEach((f) => console.log("   - " + f)); process.exit(1); }
})();
