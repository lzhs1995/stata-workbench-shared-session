"use strict";
/**
 * ast_reachability_gate 单测 —— 权威可达性判据
 *
 * 重点：把自制词法扫描器**被击穿的三个样本**钉为回归（AST 必须判死），
 * 以及 guard 归属必须靠 AST 祖先链（不是字节窗口）。
 */
const assert = require("node:assert");
const A = require("./ast_reachability_gate.js");
const OLD = require("./js_scope_scan.js");

let pass = 0; const fails = [];
function t(name, fn) {
  try { fn(); pass++; console.log("  PASS " + name); }
  catch (e) { fails.push(name + " — " + ((e && e.message) || e));
              console.log("  FAIL " + name + "  — " + ((e && e.message) || e)); }
}
const dead = (src, needle) => { const r = A.analyze(src); return r.inDead(src.indexOf(needle)); };

(function main() {
  console.log("=== AST 可达性门禁单测 ===\n");

  console.log("[A] 旧扫描器被击穿的样本：AST 必须判死（回归钉）");
  const BREAKERS = [
    ["return /}/", 'if(false&&a){function f(){return /}/.test(x)}DEAD()}LIVE();'],
    ["typeof /}/", 'if(false&&a){var t=typeof /}/;DEAD()}LIVE();'],
    ["case /}/",   'if(false&&a){switch(k){case 1:var r=/}/;break}DEAD()}LIVE();'],
  ];
  BREAKERS.forEach(([tag, src], i) => {
    t(`A.${i + 1} ${tag} → DEAD 判死、LIVE 不误判`, () => {
      assert.strictEqual(dead(src, "DEAD()"), true, "AST 未判死（与旧扫描器同样被击穿）");
      assert.strictEqual(dead(src, "LIVE()"), false, "紧邻活跃调用被误判");
    });
  });
  t("A.4 前两个样本确实曾击穿旧扫描器（证明本门禁有存在意义）", () => {
    const broken = BREAKERS.slice(0, 2).filter(([, src]) =>
      !OLD.inAnyRange(OLD.findConstFalseBranches(src), src.indexOf("DEAD()")));
    assert.strictEqual(broken.length, 2, "旧扫描器竟没被击穿，样本失效需复核");
  });

  console.log("\n[B] 恒假形态覆盖");
  [["if(false)", 'if(false){DEAD()}LIVE();'],
   ["if(!1)", 'if(!1){DEAD()}LIVE();'],
   ["if(!!0)", 'if(!!0){DEAD()}LIVE();'],
   ["if(0)", 'if(0){DEAD()}LIVE();'],
   ["if(false&&x)", 'if(false&&x){DEAD()}LIVE();'],
   ["单语句 consequent", 'if(false&&a)DEAD();LIVE();'],
   ["非 block try", 'if(false&&a)try{DEAD()}catch(e){DEAD2()}LIVE();'],
  ].forEach(([tag, src], i) => {
    t(`B.${i + 1} ${tag}`, () => {
      assert.strictEqual(dead(src, "DEAD"), true);
      assert.strictEqual(dead(src, "LIVE"), false);
    });
  });
  t("B.8 真分支不判死；else 分支可达", () => {
    assert.strictEqual(dead('if(true&&x){LIVE()}', "LIVE"), false);
    const s = 'if(false&&a){DEAD()}else{ELSELIVE()}';
    assert.strictEqual(dead(s, "DEAD"), true);
    assert.strictEqual(dead(s, "ELSELIVE"), false, "else 分支是可达的");
  });

  console.log("\n[C] guard 归属靠祖先链，不靠字节距离");
  t("C.1 在 guard 的 arguments 子树内 → guarded", () => {
    const r = A.analyze('async function h(){await g.guardStage("snapshot",()=>zg.runSelection(a,b))}');
    assert.strictEqual(r.callsites.length, 1);
    assert.strictEqual(r.callsites[0].guarded, true);
    assert.strictEqual(r.callsites[0].guardKind, "guardStage");
  });
  t("C.2 guardProgress 同样识别", () => {
    const r = A.analyze('async function h(){await G.guardProgress(()=>zg.runSelection(x),{state:s})}');
    assert.strictEqual(r.callsites[0].guarded, true);
    assert.strictEqual(r.callsites[0].guardKind, "guardProgress");
  });
  t("C.3 仅**紧邻**guard 但不在其 arguments 内 → 不算 guarded（旧窗口法会误算）", () => {
    const r = A.analyze('async function h(){await g.guardStage("snapshot",()=>f());zg.runSelection(bare)}');
    assert.strictEqual(r.callsites.length, 1);
    assert.strictEqual(r.callsites[0].guarded, false, "字节上紧邻就被算 guarded = 假覆盖");
  });
  t("C.4 祖先链上有非 guard 调用（onStarted）不得污染 guardKind", () => {
    const r = A.analyze(
      'async function h(){await G.guardProgress(()=>zg.runSelection(c,{onStarted:()=>rec(1)}),{s:1})}');
    assert.strictEqual(r.callsites[0].guarded, true);
    assert.strictEqual(r.callsites[0].guardKind, "guardProgress",
      "遍历祖先链时若一遇到可命名调用就停，会错标成 onStarted");
  });

  console.log("\n[D] 调用点识别精确");
  t("D.1 只认 zg.runSelection，不认同名属性/其它对象", () => {
    const r = A.analyze('other.runSelection(a);zg.runFile(b);zg.runSelection(c);');
    assert.strictEqual(r.callsites.length, 1);
  });
  t("D.2 computed 形式 zg[\"runSelection\"] 保守不认（避免假计数）", () => {
    const r = A.analyze('zg["runSelection"](a);');
    assert.strictEqual(r.callsites.length, 0);
  });

  console.log("\n[E] 真 dist 锚定");
  t("E.1 dist：17 调用点 / 15 可达 / 2 不可达(#8+#12) / 15 全 guard、0 裸", () => {
    const fs = require("node:fs"), path = require("node:path");
    const src = fs.readFileSync(path.join(__dirname, "..", "dist", "extension.js"), "utf8");
    const r = A.analyze(src);
    const live = r.callsites.filter((c) => c.reachable);
    assert.strictEqual(r.callsites.length, 17, "调用点总数变了，需复核 manifest");
    assert.strictEqual(live.length, 15, "可达数应 15（#8 preflight 与 #12 state 均在死分支）");
    assert.strictEqual(live.filter((c) => c.guarded).length, 15, "15 个可达点必须全 guard");
    assert.strictEqual(live.filter((c) => !c.guarded).length, 0, "不得有裸调用");
    // 死分支内不得有 guard 注入（假接线检测）
    r.callsites.filter((c) => !c.reachable).forEach((c) => {
      assert.strictEqual(c.guarded, false, "不可达调用点竟被注了 guard = 假接线 @" + c.start);
    });
  });
  t("E.2 transport guardKind 分布：guardStage 2 + guardProgress 1 + guardWrap 12", () => {
    const fs = require("node:fs"), path = require("node:path");
    const src = fs.readFileSync(path.join(__dirname, "..", "dist", "extension.js"), "utf8");
    const k = {};
    A.analyze(src).callsites.filter((c) => c.guarded)
      .forEach((c) => { k[c.guardKind] = (k[c.guardKind] || 0) + 1; });
    assert.deepStrictEqual(k, { guardWrap: 12, guardStage: 2, guardProgress: 1 },
      "分布不符（onStarted 之类被误标会在此暴露）：" + JSON.stringify(k));
  });

  console.log("\n" + "=".repeat(58));
  console.log("  PASS=" + pass + "  FAIL=" + fails.length);
  if (fails.length) { fails.forEach((f) => console.log("   - " + f)); process.exit(1); }
})();
