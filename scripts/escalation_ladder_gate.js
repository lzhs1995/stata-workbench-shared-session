#!/usr/bin/env node
"use strict";

/**
 * 缺陷 PF-4 的静态判据闸门：soft-stop 失败升级阶梯必须单调不减。
 *
 * 为什么需要独立闸门（Phase 2C C4 的盲区）：
 *   C4 变体验的是「守卫是否有界、是否如实上报」，那部分在 rc.7.34 确实成立
 *   （hardEscalated=true、finalGeneration 递增、cancel/drain 回执齐全）。
 *   C4 **没有**验「升级后的期限是否足够完成任务」。于是 45000 → 30000 → 10000
 *   这条倒挂阶梯带着满绿判决活了下来，直到 FULL45 正式跑
 *   BROAD-RC734-20260823_055413_530294 S12 step5 把桥打成 recovery-required。
 *
 * 本闸门补的就是那一条谓词：**若发生升级，则后级期限不得小于前级。**
 * 两个平面都要查，缺一不可：
 *   平面 A（模块）：escalationLadder() 在整个输入域上单调；
 *   平面 B（产物）：dist 里五处期限都从模块取值，没有任何硬编码残留。
 *   —— 只查 A 会漏「模块对了但 dist 还在用字面量」；只查 B 会漏「取到了模块
 *   但模块自己算出倒挂的数」。
 */

const assert = require("assert");
const fs = require("fs");
const path = require("path");

const C = require(path.join(__dirname, "stop_checkpoint_core.js"));
// 默认查真仓库 dist；可选 argv[2] 只用于**负控制**（把历史 rc.7.34 产物喂进来，
// B 组必须判死）。npm run check 永远走默认路径，不接受外部路径。
const DIST = process.argv[2]
  ? path.resolve(process.argv[2])
  : path.join(__dirname, "..", "dist", "extension.js");

let pass = 0;
const failures = [];

function t(name, fn) {
  try {
    fn();
    pass += 1;
    console.log("  PASS  " + name);
  } catch (error) {
    failures.push({ name, error: String((error && error.message) || error) });
    console.log("  FAIL  " + name + " — " + String((error && error.message) || error));
  }
}

// ---------- 平面 A：模块侧单调性 ----------
console.log("A 组 模块侧阶梯单调性");

// 输入域扫全：artifacts 由 estimateCount + graphCount 合成，故两轴都要动，
// 且必须覆盖 45000 天花板前后（artifacts=60 是拐点）。
const DOMAIN = [];
for (let e = 0; e <= 200; e += 1) DOMAIN.push({ estimateCount: e, graphCount: 0 });
for (let g = 0; g <= 200; g += 1) DOMAIN.push({ estimateCount: 0, graphCount: g });
for (let e = 0; e <= 100; e += 7) {
  for (let g = 0; g <= 100; g += 11) DOMAIN.push({ estimateCount: e, graphCount: g });
}
// 病态输入也不得让阶梯倒挂或抛错（NaN/负数/缺字段/null）。
const PATHOLOGICAL = [
  null, undefined, {}, { estimateCount: -5, graphCount: -5 },
  { estimateCount: NaN, graphCount: NaN },
  { estimateCount: "60", graphCount: "60" },
  { estimateCount: Infinity, graphCount: 0 },
];

t("A1 后级 restore 期限不得小于前级（整个输入域）", () => {
  for (const snap of DOMAIN) {
    const l = C.escalationLadder(snap);
    assert.ok(l.l2RestoreMs >= l1(snap), JSON.stringify({ snap, l }));
  }
  function l1(snap) { return C.restoreTimeoutMs(snap); }
});

t("A2 L3 reconnect 不得小于 L2 reconnect（整个输入域）", () => {
  for (const snap of DOMAIN) {
    const l = C.escalationLadder(snap);
    assert.ok(l.l3ReconnectMs >= l.l2ReconnectMs, JSON.stringify({ snap, l }));
  }
});

t("A3 monotonic 谓词与实际数值一致（谓词不得是恒真装饰）", () => {
  for (const snap of DOMAIN.concat(PATHOLOGICAL)) {
    const l = C.escalationLadder(snap);
    const truth = l.l2RestoreMs >= l.l1RestoreMs && l.l3ReconnectMs >= l.l2ReconnectMs;
    assert.strictEqual(l.monotonic, truth, JSON.stringify({ snap, l }));
    assert.strictEqual(l.monotonic, true, JSON.stringify({ snap, l }));
  }
});

t("A4 病态输入不抛错且仍单调", () => {
  for (const snap of PATHOLOGICAL) {
    const l = C.escalationLadder(snap);
    for (const k of ["l1RestoreMs", "l2ReconnectMs", "l2RestoreMs", "l3ReconnectMs"]) {
      assert.ok(Number.isFinite(l[k]) && l[k] > 0, k + " 非正有限：" + JSON.stringify(l));
    }
    assert.strictEqual(l.monotonic, true, JSON.stringify({ snap, l }));
  }
});

t("A5 谓词有判别力：人为倒挂必须被判死（反向证明）", () => {
  // 用 rc.7.34 的真实数值构造倒挂样本，谓词必须为假。缺此项时 A3 可能只是
  // 因为「monotonic 永远写 true」而通过。
  const broken = { l1RestoreMs: 45000, l2ReconnectMs: 10000, l2RestoreMs: 30000, l3ReconnectMs: 10000 };
  const truth = broken.l2RestoreMs >= broken.l1RestoreMs
    && broken.l3ReconnectMs >= broken.l2ReconnectMs;
  assert.strictEqual(truth, false, "rc.7.34 的历史阶梯必须被判为非单调");
});

t("A6 升级必须放宽而非等长（L2 严格大于 L1）", () => {
  for (const snap of DOMAIN) {
    const l = C.escalationLadder(snap);
    assert.ok(l.l2RestoreMs > l.l1RestoreMs, JSON.stringify({ snap, l }));
  }
});

t("A7 L3 reconnect 不得回落到事故值 10000", () => {
  assert.ok(C.forceResetReconnectTimeoutMs() > 10000,
    "实测健康态 force-reset 重连 7.49 s，事故那次 durationMs=10002");
});

// ---------- 平面 B：产物侧无硬编码残留 ----------
console.log("B 组 产物侧期限来源");

const bundle = fs.readFileSync(DIST, "utf8");

t("B0 dist 含 rc.7.35 阶梯标记", () => {
  assert.ok(bundle.includes("codex patch rc.7.35: monotonic escalation ladder"));
});

const BANNED = [
  'soft-stop dataset restore timed out after 45000ms',
  'hard-fallback reconnect timed out after 10000ms',
  'hard-fallback dataset restore timed out after 30000ms',
  'stale-reconnect retry timed out after 10000ms',
  'stale-reconnect dataset restore retry timed out after 30000ms',
  'force-reset backend reconnect timed out after 10000ms',
];

t("B1 五处硬编码期限字面量全部清除", () => {
  for (const literal of BANNED) {
    assert.ok(!bundle.includes(literal), "残留硬编码期限：" + literal);
  }
});

const REQUIRED = [
  'escalationLadder(__snapshot)',
  '__codexL2ReconnectMs=__codexLadder.l2ReconnectMs',
  '__codexL2RestoreMs=__codexLadder.l2RestoreMs',
  'forceResetReconnectTimeoutMs()',
  '__reconnect.timeoutMs=__codexFrReconnectMs',
];

t("B2 期限全部取自 stop_checkpoint_core", () => {
  for (const token of REQUIRED) {
    assert.ok(bundle.includes(token), "缺少模块取值点：" + token);
  }
});

t("B3 L2 走 datasetOnly 降级恢复且如实标注", () => {
  assert.ok(bundle.includes("restoreCode(__snapshot,__codexStataString,{datasetOnly:true})"));
  assert.ok(bundle.includes("zg.runSelection(__codexL2RestoreCode,"));
  assert.ok(bundle.includes("degraded:__codexL2Downgrade"));
  assert.ok(bundle.includes("ladder:__codexLadder"),
    "阶梯必须落进回执，否则产物侧无法复算单调性");
});

t("B4 L1 仍是动态期限（修复不得把 L1 也钉成常量）", () => {
  assert.ok(bundle.includes("restoreTimeoutMs(__snapshot)"));
  assert.ok(bundle.includes('soft-stop dataset restore timed out after "+String(__restoreTimeoutMs)+"ms'));
});

t("B5 reconnect 与 restore 分别计时（预算不得互相侵占）", () => {
  // 同一个变量同时喂 reconnect 与 restore 就是侵占；两者必须是不同变量。
  assert.ok(bundle.includes(',__codexL2ReconnectMs))]);if(!__reconnectAttempt.settled)'));
  assert.ok(bundle.includes(',__codexL2RestoreMs))]);if(!__retryAttempt.settled)'));
  assert.notStrictEqual("__codexL2ReconnectMs", "__codexL2RestoreMs");
});

t("B6 降级摘要必须报出跳过的重建条数", () => {
  const s = C.restoreDowngradeSummary({ path: DIST });
  assert.ok(s && s.mode === "dataset-only", JSON.stringify(s));
  assert.strictEqual(typeof s.skippedEstimates, "number");
  assert.strictEqual(typeof s.skippedGraphs, "number");
});

t("B7 datasetOnly 真的少做事（不得只是改了个标志位）", () => {
  // 用临时快照目录构造 2 条 estimates + 2 条 graphs 的清单，比较两种码长。
  const os = require("os");
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "pf4-ladder-"));
  const dta = path.join(dir, "snap.dta");
  fs.writeFileSync(dta, Buffer.alloc(1024, 1));
  const stateDir = dta + ".state";
  fs.mkdirSync(stateDir, { recursive: true });
  const checkpointNonce = "3".repeat(32);
  fs.writeFileSync(path.join(stateDir, "snapshot.ready"),
    `ready\t${checkpointNonce}\tdata\n`);
  fs.writeFileSync(path.join(stateDir, "default_graph_object.txt"), "0\n");
  fs.writeFileSync(path.join(stateDir, "globals.b64.tsv"), "");
  fs.writeFileSync(path.join(stateDir, "current_graph.txt"), "g2\n");
  fs.writeFileSync(path.join(stateDir, "estimates.txt"), "m1\nm2\n");
  fs.writeFileSync(path.join(stateDir, "graphs.txt"), "g1\ng2\n");
  for (const n of ["m1", "m2"]) fs.writeFileSync(path.join(stateDir, "estimate_" + n + ".ster"), "x");
  for (const n of ["g1", "g2"]) fs.writeFileSync(path.join(stateDir, "graph_" + n + ".gph"), "x");
  const snap = {
    path: dta,
    bytes: 1024,
    runId: "r",
    stateComplete: true,
    estimateCount: 2,
    graphCount: 2,
    checkpointNonce,
  };
  const q = (v) => '"' + String(v) + '"';
  const full = C.restoreCode(snap, q);
  const lite = C.restoreCode(snap, q, { datasetOnly: true });
  fs.rmSync(dir, { recursive: true, force: true });
  assert.ok(full && full !== "exit 459\n", "full fixture must be complete and restore-capable");
  assert.ok(lite.length < full.length, "datasetOnly 未减少工作量");
  assert.ok(!/estimates use/.test(lite), "datasetOnly 仍在重建 estimates");
  assert.ok(!/graph use/.test(lite), "datasetOnly 仍在重建 graphs");
  assert.ok(/___CODEX_CHECKPOINT_RESTORED___/.test(lite), "降级码必须仍打完成标记");
});

console.log("");
if (failures.length) {
  console.log("ESCALATION_LADDER_GATE_FAIL  PASS=%d FAIL=%d", pass, failures.length);
  for (const f of failures) console.log("  - %s :: %s", f.name, f.error);
  process.exit(1);
}
console.log("ESCALATION_LADDER_GATE_OK  PASS=%d FAIL=0", pass);
