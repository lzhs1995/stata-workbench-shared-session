"use strict";
/**
 * test_callsite_reachability_gate.js —— 调用点**可达性**静态门禁（codex C5-3）
 *
 * 为什么需要它：我曾报「ABSOLUTE 5/5 全守卫」，但 #14 位于 dist 的
 *   …stateSnapshotPath:null;if(false&&__codexPreparedHumanFileRun&&(…))try{…}
 * 永久死分支内 —— 运行时永不可达。**静态「裸调用归零」不能证明运行时覆盖**，
 * 而我把字符串计数当成了覆盖率。本门禁把「可达性」变成可失败的机器判据：
 *
 *   A. 死分支内**不得**出现 guard 注入（出现即红 —— 假接线）
 *   B. 活跃可达点必须全部被 guard 包裹（当前 4 个）
 *   C. retired 名单与活跃分母**分离**：#14 的死分支必须仍为 false；
 *      若有人重新启用它（if(false 消失）而未接线 → 红（防悄悄多出一个未守卫点）
 *
 * 纯静态、零依赖、不需要桥。`node scripts/test_callsite_reachability_gate.js`
 */
const assert = require("node:assert");
const fs = require("node:fs");
const path = require("node:path");
const SCOPE = require("./js_scope_scan.js");

const DIST = path.join(__dirname, "..", "dist", "extension.js");
const d = fs.readFileSync(DIST, "utf8");

// 活跃（可达）ABSOLUTE 调用点：manifest v4 的 #5/#6/#10/#11（#14 已 RETIRED）
const EXPECTED_ACTIVE_GUARDS = 6;   // 2 snapshot + 2 enrich stages + wrapper + terminal progress
const EXPECTED_CONTROL_GUARDS = 5;  // excludes the shared wrapper implementation itself

// retired 名单：{ 标识串, 死分支特征 }
const RETIRED = [
  {
    id: 14,
    name: "human-file final state snapshot",
    marker: 'codex_humanfile_state_',
    // 该调用被 if(false&&…) 包住；特征取「if(false&&」+ 同一段内出现 marker
    deadBranchProbe: 'if(false&&__codexPreparedHumanFileRun',
  },
];

let pass = 0; const failures = [];
function t(name, fn) {
  try { fn(); pass++; console.log("  PASS " + name); }
  catch (e) { failures.push(name + " — " + ((e && e.message) || e));
              console.log("  FAIL " + name + "  — " + ((e && e.message) || e)); }
}

/**
 * C5.1-3：死分支判定改用**括号配平作用域扫描**（js_scope_scan），
 * 取代原 4000 字节固定窗口 —— codex 指出后者会因代码长度/相邻调用变化误分类，
 * 且 js_scope_scan.test.js 的 B.2 已用样本证明旧法确实误判。
 */
function deadBranchRanges(src) {
  return SCOPE.findConstFalseBranches(src);
}

const DEAD = deadBranchRanges(d);
const inDead = (pos) => SCOPE.inAnyRange(DEAD, pos);

(function main() {
  console.log("=== 调用点可达性门禁（死分支 / 活跃分母 / retired 分离）===\n");

  console.log("[A] 死分支内不得出现 guard 注入（假接线检测）");
  t("A.1 dist 中每个 guardStage 注入都在可达代码里", () => {
    const positions = [];
    const re = /guardStage\("(?:snapshot|enrich)"|guardProgress\(/g;
    let m; while ((m = re.exec(d)) !== null) positions.push(m.index);
    const bad = positions.filter((p) => inDead(p));
    assert.strictEqual(bad.length, 0,
      `有 ${bad.length} 处 guard 注入落在 if(false&&…) 死分支内（假接线），offsets=${bad}`);
  });
  t("A.2 门禁自身能失败（对合成的死分支样本必须报红）", () => {
    // 反证：构造一段「死分支内含 guardStage」的样本，断言检测逻辑会命中
    const fake = 'x;if(false&&__codexPreparedHumanFileRun&&(a||b))try{await __g.guardStage("snapshot",()=>1)}catch{}LIVE();';
    const ranges = deadBranchRanges(fake);
    const gi = fake.indexOf('guardStage("snapshot"');
    assert.strictEqual(SCOPE.inAnyRange(ranges, gi), true,
      "检测逻辑对已知死分支样本没报红 → 门禁形同虚设");
    // 同时确认紧邻的活跃调用**不**被误判（旧窗口法会误伤）
    assert.strictEqual(SCOPE.inAnyRange(ranges, fake.indexOf("LIVE()")), false,
      "紧邻活跃调用被误判为死");
  });

  console.log("\n[B] 活跃可达点计数 = 分母");
  t(`B.1 可达 guard 恰为 ${EXPECTED_ACTIVE_GUARDS} 处（#14 已退役，不计入）`, () => {
    const positions = [];
    const re = /guardStage\("(?:snapshot|enrich)"|guardProgress\(/g;
    let m; while ((m = re.exec(d)) !== null) positions.push(m.index);
    const live = positions.filter((p) => !inDead(p));
    assert.strictEqual(live.length, EXPECTED_ACTIVE_GUARDS,
      `活跃 guard 应 ${EXPECTED_ACTIVE_GUARDS} 处，实为 ${live.length}`);
  });
  t("B.2 每个活跃 pre-run/terminal guard 都带三级取消原语与 supersedeLookup", () => {
    const re = /guardStage\("(?:snapshot|enrich)"|__codexTermGuard=await globalThis\.__codexExecGuardRef\.guardProgress\(/g;
    let m, checked = 0;
    while ((m = re.exec(d)) !== null) {
      if (inDead(m.index)) continue;
      const open = d.indexOf("(", m.index);
      const seg = d.slice(m.index, SCOPE.scanBalanced(d, open, "parens").end);
      assert.ok(seg.includes("__codexGuardTransport.cancelRun"),
                `活跃 guard @${m.index} 缺 cancelRun`);
      assert.ok(seg.includes("supersedeLookup"),
                `活跃 guard @${m.index} 缺 supersedeLookup`);
      checked++;
    }
    assert.strictEqual(checked, EXPECTED_CONTROL_GUARDS);
  });
  t("B.3 pre-run 快照路径无裸 await zg.runSelection 残留（可达部分）", () => {
    const bare = [];
    const re = /(?<!\)=>)await zg\.runSelection\(__snapshotCode/g;
    let m; while ((m = re.exec(d)) !== null) if (!inDead(m.index)) bare.push(m.index);
    assert.strictEqual(bare.length, 0, `可达裸调用残留 ${bare.length} 处：${bare}`);
  });

  console.log("\n[C] retired 名单与活跃分母分离（防悄悄复活）");
  RETIRED.forEach((r) => {
    t(`C.${r.id} #${r.id} ${r.name} 仍在死分支内且未接线`, () => {
      const mi = d.indexOf(r.marker);
      assert.ok(mi > 0, `找不到 retired 标识串 ${r.marker}（dist 结构变了，需复核 manifest）`);
      // 死分支特征必须仍存在 —— 若有人删掉 if(false 让它复活，这里先红
      assert.ok(d.includes(r.deadBranchProbe),
        `#${r.id} 的死分支特征消失（可能被重新启用）→ 必须先接线并从 retired 名单移除`);
      assert.strictEqual(inDead(mi), true,
        `#${r.id} 已不在死分支内 → 它现在可达但未守卫，属未覆盖调用点`);
      // 且不得有针对它的 guard 注入（那是假接线）
      assert.strictEqual(d.includes("human-file-final-state"), false,
        `#${r.id} 存在 guard 注入但它不可达 —— 假接线`);
    });
  });

  console.log("\n" + "=".repeat(58));
  console.log("  PASS=" + pass + "  FAIL=" + failures.length);
  if (failures.length) { failures.forEach((f) => console.log("   - " + f)); process.exit(1); }
})();
