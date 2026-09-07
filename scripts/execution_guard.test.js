"use strict";
/**
 * execution_guard 单测 —— codex 要求的通用 guard 场景，零真桥（cancel 原语全 mock）。
 *
 * 覆盖：
 *   PROGRESS 正常增长 / pre-log 120/300 超时 / 首日志后长任务继续
 *   精确 taskId 取消 / fallback 取消 / 两级都超时
 *   cancel 迟到回调被 generation 拒绝
 *   RECOVERY 保留 snapshot 且不递归 softStop
 *   SHORT_INTERNAL 超时后无后台漏跑（drain）
 *   cause/settlement 两维不互相覆盖；OUTCOME 归属正确
 */
const assert = require("node:assert");
const G = require("./execution_guard.js");

let pass = 0; const fails = [];
async function t(name, fn) {
  try { await fn(); pass++; console.log("  PASS " + name); }
  catch (e) { fails.push(name + " — " + ((e && e.message) || e));
              console.log("  FAIL " + name + "  — " + ((e && e.message) || e)); }
}
const never = () => new Promise(() => {});
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

(async function main() {
  console.log("=== execution_guard 单测（零真桥）===\n");

  console.log("[A] ABSOLUTE / SHORT_INTERNAL 固定上限");
  await t("A.1 正常完成 → cause=COMPLETED settlement=NOT_NEEDED ok", async () => {
    const r = await G.guardFixed(G.POLICY.ABSOLUTE, async () => "v", { timeoutMs: 2000 });
    assert.strictEqual(r.ok, true);
    assert.strictEqual(r.cause, G.CAUSE.COMPLETED);
    assert.strictEqual(r.settlement, G.SETTLEMENT.NOT_NEEDED);
    assert.strictEqual(r.value, "v");
    assert.strictEqual(r.outcome.belongsTo, "ok");
  });
  await t("A.2 同步异常 → SYNC_THREW，不当超时", async () => {
    const r = await G.guardFixed(G.POLICY.ABSOLUTE, () => { throw new Error("s"); },
                                 { timeoutMs: 2000 });
    assert.strictEqual(r.cause, G.CAUSE.SYNC_THREW);
    assert.strictEqual(r.outcome.code, "EXEC_SYNC_THREW");
    assert.strictEqual(r.outcome.belongsTo, "BAD");
  });
  await t("A.3 rejection → REJECTED，不当超时", async () => {
    const r = await G.guardFixed(G.POLICY.ABSOLUTE, async () => { throw new Error("r"); },
                                 { timeoutMs: 2000 });
    assert.strictEqual(r.cause, G.CAUSE.REJECTED);
    assert.strictEqual(r.outcome.code, "EXEC_REJECTED");
  });

  console.log("\n[B] 两级取消：精确 → fallback → 都超时");
  await t("B.1 精确 cancelRun 成功 → CANCELLED，未用 fallback", async () => {
    let workRes; const work = () => new Promise((res) => { workRes = res; });
    let cancelledRunId = null;
    const r = await G.guardFixed(G.POLICY.ABSOLUTE, work, {
      timeoutMs: 40, cancelDeadlineMs: 500, drainDeadlineMs: 500,
      meta: { runId: "run_X" },
      // 归一化契约：cancelRun 须返回 true 才算确认（对齐真实 zg.cancelRun 的 boolean）
      cancelRun: (rid) => { cancelledRunId = rid; setTimeout(() => workRes("late"), 10); return true; },
      cancelAll: () => { throw new Error("不该调 fallback"); },
    });
    assert.strictEqual(cancelledRunId, "run_X", "cancelRun 未收到精确 runId");
    assert.strictEqual(r.state.cancelPrecise, true);
    assert.strictEqual(r.state.cancelHitLevel, "cancelRun");
    assert.strictEqual(r.state.cancelFallback, null, "不该用 fallback");
    assert.strictEqual(r.settlement, G.SETTLEMENT.CANCELLED);
    assert.strictEqual(r.state.recoveryRequired, false);
  });
  await t("B.2 精确失败 → fallback cancelAll 成功 → CANCELLED", async () => {
    let workRes; const work = () => new Promise((res) => { workRes = res; });
    const r = await G.guardFixed(G.POLICY.ABSOLUTE, work, {
      timeoutMs: 40, cancelDeadlineMs: 200, drainDeadlineMs: 500,
      meta: { runId: "run_Y" },
      cancelRun: () => false,                              // 精确取消未确认（真实语义）
      cancelAll: () => { setTimeout(() => workRes("late"), 10); return true; },
    });
    assert.strictEqual(r.state.cancelPrecise, false);
    assert.strictEqual(r.state.cancelFallback, true);
    assert.strictEqual(r.state.cancelHitLevel, "cancelAll");
    assert.strictEqual(r.settlement, G.SETTLEMENT.CANCELLED);
  });
  await t("B.3 两级都超时 → CANCEL_TIMEOUT + recoveryRequired", async () => {
    const r = await G.guardFixed(G.POLICY.ABSOLUTE, never, {
      timeoutMs: 30, cancelDeadlineMs: 40, drainDeadlineMs: 40,
      meta: { runId: "run_Z" },
      cancelRun: () => new Promise(() => {}),
      cancelAll: () => new Promise(() => {}),
    });
    assert.strictEqual(r.state.cancelTimedOut, true);
    assert.strictEqual(r.settlement, G.SETTLEMENT.CANCEL_TIMEOUT);
    assert.strictEqual(r.outcome.code, "EXEC_CANCEL_TIMEOUT");
    assert.strictEqual(r.outcome.belongsTo, "HARNESS_BLOCKING");
    assert.strictEqual(r.state.recoveryRequired, true);
  });
  await t("B.4 无取消原语 + work 不 settle → DRAIN_FAILED", async () => {
    const r = await G.guardFixed(G.POLICY.SHORT_INTERNAL, never,
                                 { timeoutMs: 30, drainDeadlineMs: 40 });
    assert.strictEqual(r.settlement, G.SETTLEMENT.DRAIN_FAILED);
    assert.strictEqual(r.outcome.code, "EXEC_DRAIN_FAILED");
    assert.strictEqual(r.state.recoveryRequired, true);
  });

  console.log("\n[C] SHORT_INTERNAL 超时后无后台漏跑");
  await t("C.1 超时触发取消，drain 确认 settle", async () => {
    let workRes; const work = () => new Promise((res) => { workRes = res; });
    const r = await G.guardFixed(G.POLICY.SHORT_INTERNAL, work, {
      timeoutMs: 30, cancelDeadlineMs: 300, drainDeadlineMs: 300,
      meta: { runId: "r" }, cancelRun: () => { setTimeout(() => workRes("x"), 10); return true; },
    });
    assert.strictEqual(r.state.cancelAttempted, true);
    assert.strictEqual(r.settlement, G.SETTLEMENT.CANCELLED);  // 无漏跑
  });

  console.log("\n[D] PROGRESS 进展感知");
  await t("D.1 正常完成（有日志增长）→ COMPLETED", async () => {
    let bytes = 0;
    const r = await G.guardProgress(async () => { await sleep(60); return "ok"; }, {
      preLogMs: 5000, idleMs: 5000, pollMs: 15,
      probe: () => ({ logPath: "/l", logBytes: (bytes += 100) }),
    });
    assert.strictEqual(r.ok, true);
    assert.strictEqual(r.cause, G.CAUSE.COMPLETED);
    assert.ok(r.state.firstLogAt != null, "未记 firstLogAt");
  });
  await t("D.2 pre-log stall（始终无 logPath）→ PROGRESS_STALL", async () => {
    const r = await G.guardProgress(never, {
      preLogMs: 40, idleMs: 5000, pollMs: 15, drainDeadlineMs: 40,
      probe: () => ({}),   // 从不出日志
    });
    assert.strictEqual(r.cause, G.CAUSE.PROGRESS_STALL);
    assert.strictEqual(r.outcome.code, "EXEC_PRELOG_STALL");
    assert.strictEqual(r.state.firstLogAt, null);
  });
  await t("D.3 首日志出现后长任务继续（不被 preLog 杀）", async () => {
    // preLogMs 很短(40ms)，但 60ms 时已出首日志 → 之后应按 idle 窗口，不因总时长被杀
    let out = false;
    setTimeout(() => { out = true; }, 30);
    const r = await G.guardProgress(async () => { await sleep(200); return "done"; }, {
      preLogMs: 40, idleMs: 5000, pollMs: 15,
      probe: () => out ? ({ logPath: "/l", logBytes: Date.now() % 100000 }) : ({}),
    });
    assert.strictEqual(r.ok, true, "首日志后不该被 preLog 杀，cause=" + r.cause);
  });
  await t("D.4 首日志后空闲超 idle → PROGRESS_STALL", async () => {
    let firstDone = false;
    setTimeout(() => { firstDone = true; }, 20);
    const r = await G.guardProgress(never, {
      preLogMs: 5000, idleMs: 60, pollMs: 15, cancelDeadlineMs: 40, drainDeadlineMs: 40,
      // 出一次日志后再不增长
      probe: () => firstDone ? ({ logPath: "/l", logBytes: 500 }) : ({}),
    });
    assert.strictEqual(r.cause, G.CAUSE.PROGRESS_STALL);
    assert.ok(r.state.firstLogAt != null);
  });
  await t("D.5 结构性长任务用 300s 门限（默认短 120s）", () => {
    assert.strictEqual(G.DEFAULT_PRELOG_SHORT_MS, 120000);
    assert.strictEqual(G.DEFAULT_PRELOG_LONG_MS, 300000);
  });

  console.log("\n[E] RECOVERY：保留 snapshot，不递归 softStop");
  await t("E.1 超时 → 保留 snapshot + STOP_RESTORE_TIMEOUT", async () => {
    let softStopCalled = false;
    const r = await G.guardFixed(G.POLICY.RECOVERY, never, {
      timeoutMs: 30, cancelDeadlineMs: 40, drainDeadlineMs: 40,
      meta: { runId: "r", snapshotPath: "/snap.dta" },
      cancelRun: () => new Promise(() => {}),
      cancelAll: () => new Promise(() => {}),
      // 故意提供 softStop 以证明 guard 不会去调它
      softStop: () => { softStopCalled = true; },
    });
    assert.strictEqual(r.state.snapshotPreserved, true, "未保留 snapshot");
    assert.strictEqual(softStopCalled, false, "guard 不该递归调 softStop");
    assert.strictEqual(r.outcome.code, "STOP_RESTORE_TIMEOUT");
    assert.strictEqual(r.outcome.belongsTo, "HARNESS_BLOCKING");
  });
  await t("E.2 RECOVERY 正常完成不保留 snapshot 标记（无需恢复）", async () => {
    const r = await G.guardFixed(G.POLICY.RECOVERY, async () => "ok", { timeoutMs: 2000 });
    assert.strictEqual(r.ok, true);
    assert.strictEqual(r.state.snapshotPreserved, null);
  });

  console.log("\n[F] cause/settlement 两维不互相覆盖");
  await t("F.1 超时但 cancel 成功 → cause=TIMED_OUT + settlement=CANCELLED（两维独立）", async () => {
    let workRes; const r = await G.guardFixed(G.POLICY.ABSOLUTE,
      () => new Promise((res) => { workRes = res; }), {
        timeoutMs: 30, cancelDeadlineMs: 300, drainDeadlineMs: 300, meta: { runId: "r" },
        cancelRun: () => { setTimeout(() => workRes("x"), 10); return true; },
      });
    assert.strictEqual(r.cause, G.CAUSE.TIMED_OUT);
    assert.strictEqual(r.settlement, G.SETTLEMENT.CANCELLED);
    // 单一 result 无法表达的信息，两维都在
  });
  await t("F.2 markPayloadDispatched 前后 payloadDispatched 翻转", async () => {
    const r = await G.guardFixed(G.POLICY.ABSOLUTE, async () => 1, { timeoutMs: 2000 });
    assert.strictEqual(G.publicSummary(r.state).payloadDispatched, false);
    G.markPayloadDispatched(r.state);
    assert.strictEqual(G.publicSummary(r.state).payloadDispatched, true);
  });

  console.log("\n[G] codex C2 阻塞项补测");
  await t("G.1 cancelTask 远端终态 + cancelRun 互补执行（C5-2：非 fallback）", async () => {
    let workRes; const hits = [];
    const r = await G.guardFixed(G.POLICY.ABSOLUTE,
      () => new Promise((res) => { workRes = res; }), {
        timeoutMs: 30, cancelDeadlineMs: 300, drainDeadlineMs: 300,
        meta: { runId: "run_A", taskId: "task_A" },
        // 远端终态（Task.status=cancelled 语义 → terminal:true）
        cancelTask: (tid) => { hits.push(["task", tid]);
                               return { confirmed: true, terminal: true }; },
        // 互补动作：即便远端已终止，也必须调 cancelRun 释放本地 token/Promise
        cancelRun: (rid) => { hits.push(["run", rid]);
                              setTimeout(() => workRes("x"), 8); return true; },
        cancelAll: () => { throw new Error("远端终态不该走 cancelAll"); },
      });
    assert.deepStrictEqual(hits[0], ["task", "task_A"], "未先调 cancelTask");
    assert.deepStrictEqual(hits[1], ["run", "run_A"], "远端终态后仍须互补调 cancelRun");
    assert.strictEqual(r.state.remoteTerminal, true);
    assert.strictEqual(r.state.cancelHitLevel, "cancelTask");
    assert.strictEqual(r.state.cancelFallback, null, "不该用 cancelAll");
  });
  await t("G.2 cancelRun 返回 false 不算成功，继续 fallback（阻塞3）", async () => {
    let workRes;
    const r = await G.guardFixed(G.POLICY.ABSOLUTE,
      () => new Promise((res) => { workRes = res; }), {
        timeoutMs: 30, cancelDeadlineMs: 300, drainDeadlineMs: 300, meta: { runId: "r" },
        cancelRun: () => false,   // 真实 zg.cancelRun 无源时返 false
        cancelAll: () => { setTimeout(() => workRes("x"), 8); return true; },
      });
    assert.strictEqual(r.state.cancelPrecise, false, "false 不该记成功");
    assert.strictEqual(r.state.cancelHitLevel, "cancelAll");
  });
  await t("G.3 normalizeCancelReceipt 五种输入", () => {
    const N = G.normalizeCancelReceipt;
    assert.strictEqual(N(true).confirmed, true);
    assert.strictEqual(N(false).confirmed, false);
    assert.strictEqual(N(undefined).confirmed, false);
    assert.strictEqual(N({ ok: false }).confirmed, false);
    assert.strictEqual(N({ confirmed: true, terminal: true }).confirmed, true);
    assert.strictEqual(N({ confirmed: true, terminal: false }).confirmed, false, "非终态不算");
  });
  await t("G.4 isCurrent：旧 generation 迟到不得改新 run（阻塞1）", () => {
    const st = G.createState(G.POLICY.PROGRESS, { runId: "r1", generation: 5 });
    assert.strictEqual(G.isCurrent(st, { runId: "r1", generation: 5 }), true);
    assert.strictEqual(G.isCurrent(st, { runId: "r1", generation: 6 }), false, "generation 变了应判非当前");
    assert.strictEqual(G.isCurrent(st, { runId: "r2", generation: 5 }), false, "runId 变了应判非当前");
    assert.strictEqual(G.isCurrent(st, null), true, "无属主判据向后兼容");
  });
  await t("G.5 PROGRESS 迟到：属主已换 → SUPERSEDED（阻塞3，非无进展）", async () => {
    let gen = 7;
    const r = await G.guardProgress(never, {
      preLogMs: 5000, idleMs: 5000, pollMs: 15, cancelDeadlineMs: 40, drainDeadlineMs: 40,
      meta: { runId: "r", generation: 7 },
      ownerRef: () => ({ runId: "r", generation: gen }),
      probe: () => { gen = 8; return {}; },   // 第一次 probe 后属主换代
    });
    assert.strictEqual(r.cause, G.CAUSE.SUPERSEDED, "属主换代应判 SUPERSEDED");
    assert.strictEqual(r.state.stallReason, G.STALL.OWNER_LOST);
  });
  await t("G.6 短/长任务 idle 默认不同（阻塞4）", () => {
    assert.strictEqual(G.DEFAULT_IDLE_SHORT_MS, 60000);
    assert.strictEqual(G.DEFAULT_IDLE_LONG_MS, 1800000);
    assert.notStrictEqual(G.DEFAULT_IDLE_SHORT_MS, G.DEFAULT_IDLE_LONG_MS);
  });
  await t("G.7 probe run-ownership：别的 run 的日志不算进展（阻塞4）", async () => {
    // 日志一直"增长"但 logRunId 是别的 run → 应判 pre-log stall（本 run 无真进展）
    let b = 0;
    const r = await G.guardProgress(never, {
      preLogMs: 60, idleMs: 5000, pollMs: 15, cancelDeadlineMs: 40, drainDeadlineMs: 40,
      meta: { runId: "mine" },
      probe: () => ({ logPath: "/other", logBytes: (b += 100), logRunId: "other_run" }),
    });
    assert.strictEqual(r.cause, G.CAUSE.PROGRESS_STALL, "别的 run 的增长不该续命");
    assert.ok(r.state.probeRunMismatch > 0, "未记 probeRunMismatch");
    assert.strictEqual(r.state.firstLogAt, null, "别的 run 的日志不该记 firstLog");
  });
  await t("G.8 hard budget 触顶即停，伪日志不能无限续命（阻塞4）", async () => {
    let b = 0;
    const r = await G.guardProgress(never, {
      preLogMs: 5000, idleMs: 5000, pollMs: 15, hardBudgetMs: 80,
      cancelDeadlineMs: 40, drainDeadlineMs: 40, meta: { runId: "r" },
      probe: () => ({ logPath: "/l", logBytes: (b += 100), logRunId: "r" }),  // 持续伪增长
    });
    assert.strictEqual(r.state.hardBudgetHit, true, "hard budget 未触发");
    assert.strictEqual(r.cause, G.CAUSE.PROGRESS_STALL);
  });
  await t("G.9 hard budget 默认关闭：不设则不触顶", async () => {
    let b = 0, done = false;
    setTimeout(() => { done = true; }, 40);
    const r = await G.guardProgress(async () => { await sleep(90); return "ok"; }, {
      preLogMs: 5000, idleMs: 5000, pollMs: 15, meta: { runId: "r" },
      probe: () => done ? ({ logPath: "/l", logBytes: (b += 100), logRunId: "r" }) : ({}),
    });
    assert.strictEqual(r.ok, true, "无 hardBudget 不该被杀");
    assert.strictEqual(r.state.hardBudgetHit, false);
  });

  console.log("\n[H] C4 内核修正补测（codex 7 项）");
  await t("H.1 对象回执缺 terminal → 不算确认（阻塞1：ack≠terminal）", () => {
    const N = G.normalizeCancelReceipt;
    assert.strictEqual(N({ ok: true }).confirmed, false, "{ok:true} 无 terminal 不该算确认");
    assert.strictEqual(N({ confirmed: true }).confirmed, false, "缺 terminal 不算");
    assert.strictEqual(N({ ok: true, terminal: true }).confirmed, true, "显式 terminal:true 才算");
    assert.strictEqual(N({ ok: true, terminal: false }).confirmed, false);
  });
  await t("H.2 取消尝试但无一级确认 + work 自行 settle → DRAINED（非 CANCELLED，阻塞2）", async () => {
    let workRes; const work = () => new Promise((res) => { workRes = res; });
    const r = await G.guardFixed(G.POLICY.ABSOLUTE, work, {
      timeoutMs: 30, cancelDeadlineMs: 300, drainDeadlineMs: 300, meta: { runId: "r" },
      // 两级都「未确认」，但 work 稍后自行 settle
      cancelRun: () => { setTimeout(() => workRes("late"), 10); return false; },
      cancelAll: () => false,
    });
    assert.strictEqual(r.state.cancelConfirmed, false, "无一级确认");
    assert.strictEqual(r.settlement, G.SETTLEMENT.DRAINED, "未确认自行 settle 应记 DRAINED");
    assert.notStrictEqual(r.settlement, G.SETTLEMENT.CANCELLED);
  });
  await t("H.3 未声明的 SUPERSEDED 收尾禁 cancelAll，且计 BAD（阻塞3+C4.1#5）", async () => {
    let gen = 1, cancelAllCalled = false, cancelRunTarget = null;
    let workRes; const work = () => new Promise((res) => { workRes = res; });
    const r = await G.guardProgress(work, {
      preLogMs: 5000, idleMs: 5000, pollMs: 10, cancelDeadlineMs: 200, drainDeadlineMs: 200,
      meta: { runId: "old", generation: 1 },   // 未声明 expectedSupersede
      ownerRef: () => ({ runId: "old", generation: gen }),
      probe: () => { gen = 2; return {}; },   // 属主换代 → SUPERSEDED
      cancelRun: (rid) => { cancelRunTarget = rid; setTimeout(() => workRes("x"), 8); return true; },
      cancelAll: () => { cancelAllCalled = true; return true; },
    });
    assert.strictEqual(r.cause, G.CAUSE.SUPERSEDED);
    assert.strictEqual(cancelAllCalled, false, "SUPERSEDED 绝不能调 cancelAll");
    assert.strictEqual(cancelRunTarget, "old", "只精确取消旧 run");
    assert.strictEqual(r.settlement, G.SETTLEMENT.CANCELLED);
    assert.strictEqual(r.outcome.belongsTo, "BAD", "未声明的换代是缺陷，不能记 ok");
    assert.strictEqual(r.outcome.code, "EXEC_SUPERSEDED_UNEXPECTED");
  });
  await t("H.3b 有控制面证据的换代 → EXCLUDED（非 PASS 非缺陷，D0a）", async () => {
    let gen = 1;
    let workRes; const work = () => new Promise((res) => { workRes = res; });
    const r = await G.guardProgress(work, {
      preLogMs: 5000, idleMs: 5000, pollMs: 10, cancelDeadlineMs: 200, drainDeadlineMs: 200,
      meta: { runId: "old", generation: 1 },
      ownerRef: () => ({ runId: "old", generation: gen }),
      probe: () => { gen = 2; return {}; },
      // 控制面登记：Stop 发起的换代，runId/from/to/kind 全匹配
      supersedeLookup: () => ({ runId: "old", fromGeneration: 1, toGeneration: 2,
                               kind: G.SUPERSEDE_KINDS.SOFT_STOP, token: "tk1",
                               at: new Date().toISOString() }),      cancelRun: () => { setTimeout(() => workRes("x"), 8); return true; },
      cancelAll: () => { throw new Error("不该调"); },
    });
    assert.strictEqual(r.cause, G.CAUSE.SUPERSEDED);
    assert.strictEqual(r.outcome.belongsTo, "EXCLUDED", "有据的换代应排除计分");
    assert.strictEqual(r.outcome.code, "EXEC_SUPERSEDED_EXPECTED");
    assert.strictEqual(r.exclusionReason, "EXPECTED_SUPERSEDE", "须给出排除原因");
    assert.strictEqual(r.state.supersedeExpected, true);
    assert.strictEqual(r.state.supersedeEvidence.kind, "soft-stop");
    assert.strictEqual(r.state.supersedeEvidence.token, "tk1");
  });
  await t("H.4 SUPERSEDED 但旧 transport 卡住 → HARNESS_BLOCKING（不掩盖）", async () => {
    let gen = 1;
    const r = await G.guardProgress(never, {
      preLogMs: 5000, idleMs: 5000, pollMs: 10, cancelDeadlineMs: 30, drainDeadlineMs: 30,
      meta: { runId: "old", generation: 1 },
      ownerRef: () => ({ runId: "old", generation: gen }),
      probe: () => { gen = 2; return {}; },
      cancelRun: () => false, cancelAll: () => { throw new Error("不该调"); },  // 精确取消未确认
    });
    assert.strictEqual(r.cause, G.CAUSE.SUPERSEDED);
    assert.strictEqual(r.settlement, G.SETTLEMENT.DRAIN_FAILED);
    assert.strictEqual(r.outcome.belongsTo, "HARNESS_BLOCKING", "旧 transport 卡住须升级");
  });
  // H.5 —— PLACEHOLDER_H
  await t("H.5 probe 动态捕获 taskId → cancelTask 可达（阻塞4）", async () => {
    let firstLog = false, cancelTaskArg = null;
    setTimeout(() => { firstLog = true; }, 12);
    const r = await G.guardProgress(never, {
      preLogMs: 5000, idleMs: 45, pollMs: 8, cancelDeadlineMs: 200, drainDeadlineMs: 60,
      meta: { runId: "r" },   // 注意：meta 不带 taskId，只能靠 probe 动态给
      probe: () => firstLog ? ({ logPath: "/l", logBytes: 100, logRunId: "r", taskId: "task_live" })
                            : ({}),
      cancelTask: (tid) => { cancelTaskArg = tid; return true; },
      cancelRun: () => { throw new Error("不该退到 cancelRun"); },
    });
    assert.strictEqual(r.state.taskId, "task_live", "未从 probe 动态捕获 taskId");
    assert.strictEqual(cancelTaskArg, "task_live", "cancelTask 未收到动态 taskId");
    assert.strictEqual(r.state.cancelHitLevel, "cancelTask");
  });
  await t("H.6 四类 stallReason 分别落盘（阻塞5）", async () => {
    // PRE_LOG
    const preLog = await G.guardProgress(never, {
      preLogMs: 30, idleMs: 5000, pollMs: 8, cancelDeadlineMs: 30, drainDeadlineMs: 30,
      meta: { runId: "r" }, probe: () => ({}),
    });
    assert.strictEqual(preLog.state.stallReason, G.STALL.PRE_LOG);
    // IDLE
    let seen = false; setTimeout(() => { seen = true; }, 12);
    const idle = await G.guardProgress(never, {
      preLogMs: 5000, idleMs: 30, pollMs: 8, cancelDeadlineMs: 30, drainDeadlineMs: 30,
      meta: { runId: "r" },
      probe: () => seen ? ({ logPath: "/l", logBytes: 100, logRunId: "r" }) : ({}),
    });
    assert.strictEqual(idle.state.stallReason, G.STALL.IDLE);
    // HARD_BUDGET
    let b = 0;
    const hard = await G.guardProgress(never, {
      preLogMs: 5000, idleMs: 5000, pollMs: 8, hardBudgetMs: 40,
      cancelDeadlineMs: 30, drainDeadlineMs: 30, meta: { runId: "r" },
      probe: () => ({ logPath: "/l", logBytes: (b += 100), logRunId: "r" }),
    });
    assert.strictEqual(hard.state.stallReason, G.STALL.HARD_BUDGET);
    // OWNER_LOST 已由 H.3 覆盖，这里断言四者互不相同
    assert.strictEqual(new Set([G.STALL.PRE_LOG, G.STALL.IDLE, G.STALL.HARD_BUDGET, G.STALL.OWNER_LOST]).size, 4);
  });
  await t("H.7 publicSummary 透传两维 + stallReason + cancelLevels（阻塞6/7）", async () => {
    const r = await G.guardFixed(G.POLICY.SHORT_INTERNAL, never, {
      timeoutMs: 20, cancelDeadlineMs: 20, drainDeadlineMs: 20, meta: { runId: "r" },
      cancelRun: () => false, cancelAll: () => false,
    });
    const s = G.publicSummary(r.state);
    for (const f of ["cause", "settlement", "stallReason", "cancelConfirmed",
                     "cancelLevels", "cancelHitLevel"]) {
      assert.ok(f in s, "publicSummary 缺字段 " + f);
    }
    assert.ok(Array.isArray(s.cancelLevels), "cancelLevels 应为数组");
  });
  console.log("\n[I] C4.1 修正 + 两处 overclaim 回归钉");
  await t("I.1 probe 缺身份(无 runId/logRunId) → 丢弃，不注入 taskId 不续命（#1）", async () => {
    let firstDone = false;
    setTimeout(() => { firstDone = true; }, 12);
    const r = await G.guardProgress(never, {
      preLogMs: 40, idleMs: 5000, pollMs: 8, cancelDeadlineMs: 30, drainDeadlineMs: 30,
      meta: { runId: "r" },   // state 有身份，但 probe 不给
      // 出「日志 + taskId」却无 runId/logRunId → 不可信，不得注入 taskId、不得记 firstLog
      probe: () => firstDone ? ({ logPath: "/l", logBytes: 100, taskId: "ghost" }) : ({}),
      cancelTask: () => { throw new Error("缺身份不该捕获 taskId 进而调 cancelTask"); },
    });
    assert.strictEqual(r.state.taskId, null, "缺身份不得注入 taskId");
    assert.strictEqual(r.state.firstLogAt, null, "缺身份的日志不得记 firstLog");
    assert.ok(r.state.probeUnidentified > 0, "未记 probeUnidentified");
    assert.strictEqual(r.state.stallReason, G.STALL.PRE_LOG);
  });
  await t("I.2 probe 用 pr.runId(非 logRunId) 也能匹配当前 run（#1）", async () => {
    let firstDone = false, cancelTaskArg = null;
    setTimeout(() => { firstDone = true; }, 10);
    const r = await G.guardProgress(never, {
      preLogMs: 5000, idleMs: 40, pollMs: 8, cancelDeadlineMs: 200, drainDeadlineMs: 60,
      meta: { runId: "r" },
      probe: () => firstDone ? ({ logPath: "/l", logBytes: 100, runId: "r", taskId: "t9" }) : ({}),
      cancelTask: (tid) => { cancelTaskArg = tid; return true; },
    });
    assert.strictEqual(cancelTaskArg, "t9", "pr.runId 匹配时应捕获 taskId 并可 cancelTask");
  });
  await t("I.3 cancel 超时但 work 在 drain 窗口自行收敛 → DRAINED，不误报 503（#3）", async () => {
    let workRes; const work = () => new Promise((res) => { workRes = res; });
    // work 30ms 后自行 settle；cancel 永不返回（会 cancelTimedOut）；drain 窗口 300ms 足够
    setTimeout(() => { if (workRes) workRes("selfdone"); }, 30);
    const r = await G.guardFixed(G.POLICY.ABSOLUTE, work, {
      timeoutMs: 10, cancelDeadlineMs: 15, drainDeadlineMs: 300, meta: { runId: "r" },
      cancelRun: () => new Promise(() => {}),   // 取消永不返回
      cancelAll: () => new Promise(() => {}),
    });
    assert.strictEqual(r.state.cancelTimedOut, true, "cancelTimedOut 作审计应保留 true");
    assert.strictEqual(r.settlement, G.SETTLEMENT.DRAINED, "work 收敛应记 DRAINED");
    assert.strictEqual(r.state.recoveryRequired, false, "transport 已释放，不需恢复(不 503)");
  });
  await t("I.4 cancelFallback 仅在真调 cancelAll 后置位；缺函数记 skipped（#4/#2）", async () => {
    const r = await G.guardFixed(G.POLICY.ABSOLUTE, never, {
      timeoutMs: 20, cancelDeadlineMs: 20, drainDeadlineMs: 20, meta: { runId: "r" },
      cancelRun: () => false,   // 精确未确认；无 cancelAll 原语
    });
    assert.strictEqual(r.state.cancelFallback, null, "没 cancelAll 不该报用过 fallback");
    const lv = r.state.cancelLevels.find((l) => l.level === "cancelAll");
    assert.ok(lv && lv.skipped === true, "cancelAll 缺失应记 skipped 进 cancelLevels");
  });
  await t("I.5 缺 cancelTask 原语 → level① 记 skipped，不静默丢（#2）", async () => {
    const r = await G.guardFixed(G.POLICY.ABSOLUTE, never, {
      timeoutMs: 20, cancelDeadlineMs: 20, drainDeadlineMs: 20,
      meta: { runId: "r", taskId: "T" },   // 有 taskId 但不提供 cancelTask 函数
      cancelRun: () => false, cancelAll: () => false,
    });
    const lv = r.state.cancelLevels.find((l) => l.level === "cancelTask");
    assert.ok(lv && lv.skipped === true, "cancelTask 缺原语应记 skipped");
  });
  console.log("\n[J] D0a 换代证据（禁伪造/禁预设）+ EXCLUDED 计分");
  // 复用的换代场景工厂：只换 supersedeLookup，其余固定
  // C5-4：证据现在强制 token + at（时效），故工厂给 lookup 结果补齐这两项，
  // 让每条测试只隔离它想验的那个拒因（缺 token / 过期 有独立测试 J.11-J.13）。
  const withReq = (rec) => (rec == null ? rec : Object.assign(
    { token: "tk_" + Math.random().toString(36).slice(2), at: new Date().toISOString() }, rec));
  const supersedeCase = async (lookup, extra) => {
    let gen = 1;
    let workRes; const work = () => new Promise((res) => { workRes = res; });
    return await G.guardProgress(work, Object.assign({
      preLogMs: 5000, idleMs: 5000, pollMs: 10, cancelDeadlineMs: 200, drainDeadlineMs: 200,
      meta: { runId: "old", generation: 1 },
      ownerRef: () => ({ runId: "old", generation: gen }),
      probe: () => { gen = 2; return {}; },
      supersedeLookup: (q) => withReq(lookup(q)),
      cancelRun: () => { setTimeout(() => workRes("x"), 8); return true; },
      cancelAll: () => { throw new Error("SUPERSEDED 不该调 cancelAll"); },
    }, extra || {}));
  };
  await t("J.1 伪造布尔预期不得排除（禁 run-start 预设）", async () => {
    // 调用方传 meta.expectedSupersede:true 但**无**控制面证据 → 必须仍记 BAD
    let gen = 1;
    let workRes; const work = () => new Promise((res) => { workRes = res; });
    const r = await G.guardProgress(work, {
      preLogMs: 5000, idleMs: 5000, pollMs: 10, cancelDeadlineMs: 200, drainDeadlineMs: 200,
      meta: { runId: "old", generation: 1, expectedSupersede: true },   // 伪造
      ownerRef: () => ({ runId: "old", generation: gen }),
      probe: () => { gen = 2; return {}; },
      cancelRun: () => { setTimeout(() => workRes("x"), 8); return true; },
    });
    assert.strictEqual(r.outcome.belongsTo, "BAD", "布尔预设不得换来排除");
    assert.strictEqual(r.state.supersedeExpected, false);
    assert.strictEqual(r.state.supersedePresetIgnored, true, "应记录预设被忽略");
    assert.strictEqual(r.state.supersedeRejectReason, "NO_LOOKUP");
    assert.strictEqual(r.exclusionReason, null, "BAD 不该带 exclusionReason");
  });
  await t("J.2 generation 不匹配不得排除", async () => {
    const r = await supersedeCase(() => ({ runId: "old", fromGeneration: 99,
      toGeneration: 2, kind: G.SUPERSEDE_KINDS.SOFT_STOP }));
    assert.strictEqual(r.outcome.belongsTo, "BAD");
    assert.strictEqual(r.state.supersedeRejectReason, "FROM_GENERATION_MISMATCH");
  });
  await t("J.3 toGeneration 与新属主不符不得排除", async () => {
    const r = await supersedeCase(() => ({ runId: "old", fromGeneration: 1,
      toGeneration: 77, kind: G.SUPERSEDE_KINDS.FORCE_RESET }));
    assert.strictEqual(r.outcome.belongsTo, "BAD");
    assert.strictEqual(r.state.supersedeRejectReason, "TO_GENERATION_MISMATCH");
  });
  await t("J.4 runId 不匹配不得排除（别的 run 的 Stop 不算）", async () => {
    const r = await supersedeCase(() => ({ runId: "someone_else", fromGeneration: 1,
      toGeneration: 2, kind: G.SUPERSEDE_KINDS.SOFT_STOP }));
    assert.strictEqual(r.outcome.belongsTo, "BAD");
    assert.strictEqual(r.state.supersedeRejectReason, "RUNID_MISMATCH");
  });
  await t("J.5 原因不在白名单不得排除（只认 Stop/force-reset）", async () => {
    const r = await supersedeCase(() => ({ runId: "old", fromGeneration: 1,
      toGeneration: 2, kind: "random-relaunch" }));
    assert.strictEqual(r.outcome.belongsTo, "BAD");
    assert.strictEqual(r.state.supersedeRejectReason, "KIND_NOT_ALLOWED");
  });
  await t("J.6 查不到记录 / lookup 抛错都不得排除", async () => {
    const none = await supersedeCase(() => null);
    assert.strictEqual(none.outcome.belongsTo, "BAD");
    assert.strictEqual(none.state.supersedeRejectReason, "NO_RECORD");
    const threw = await supersedeCase(() => { throw new Error("boom"); });
    assert.strictEqual(threw.outcome.belongsTo, "BAD");
    assert.strictEqual(threw.state.supersedeRejectReason, "LOOKUP_THREW");
  });
  await t("J.7 force-reset 证据齐全 → EXCLUDED", async () => {
    const r = await supersedeCase(() => ({ runId: "old", fromGeneration: 1,
      toGeneration: 2, kind: G.SUPERSEDE_KINDS.FORCE_RESET, token: "tk2" }));
    assert.strictEqual(r.outcome.belongsTo, "EXCLUDED");
    assert.strictEqual(r.exclusionReason, "EXPECTED_SUPERSEDE");
  });
  await t("J.8 有据但旧 transport 不收敛 → 仍 HARNESS_BLOCKING（证据不能掩盖卡死）", async () => {
    let gen = 1;
    const r = await G.guardProgress(never, {
      preLogMs: 5000, idleMs: 5000, pollMs: 10, cancelDeadlineMs: 25, drainDeadlineMs: 25,
      meta: { runId: "old", generation: 1 },
      ownerRef: () => ({ runId: "old", generation: gen }),
      probe: () => { gen = 2; return {}; },
      supersedeLookup: () => ({ runId: "old", fromGeneration: 1, toGeneration: 2,
                               kind: G.SUPERSEDE_KINDS.SOFT_STOP,
                               token: "tk_j8", at: new Date().toISOString() }),
      cancelRun: () => false,
    });
    assert.strictEqual(r.state.supersedeExpected, true, "证据应仍被核实");
    assert.strictEqual(r.outcome.belongsTo, "HARNESS_BLOCKING", "不收敛不得因有据而排除");
    assert.strictEqual(r.exclusionReason, null);
  });
  await t("J.9 EXCLUDED ≠ 既有 harness 的 EXPECTED_ABORT token（避免同名混淆）", () => {
    assert.strictEqual(G.OUTCOME.SUPERSEDED_EXPECTED.belongsTo, "EXCLUDED");
    assert.notStrictEqual(G.OUTCOME.SUPERSEDED_EXPECTED.belongsTo, "EXPECTED_ABORT");
    assert.strictEqual(G.OUTCOME.SUPERSEDED_EXPECTED.exclusionReason, "EXPECTED_SUPERSEDE");
    assert.deepStrictEqual(G.ALLOWED_SUPERSEDE_KINDS, ["soft-stop", "force-reset"]);
  });
  await t("J.10 身份不符的 taskId 不得用于取消（映射错误防线，D0a）", async () => {
    // probe 报的 logRunId 是别的 run，却带 taskId → 既不得记进展也不得注入 taskId
    let called = null;
    const r = await G.guardProgress(never, {
      preLogMs: 40, idleMs: 5000, pollMs: 8, cancelDeadlineMs: 30, drainDeadlineMs: 30,
      meta: { runId: "mine" },
      probe: () => ({ logPath: "/other", logBytes: 500, logRunId: "other", taskId: "T_other" }),
      cancelTask: (tid) => { called = tid; return true; },
      cancelRun: () => false,
    });
    assert.strictEqual(r.state.taskId, null, "身份不符不得注入 taskId");
    assert.strictEqual(called, null, "绝不能用别的 run 的 taskId 取消");
    assert.ok(r.state.probeRunMismatch > 0);
  });
  console.log("\n[K] C5 修正：Task.status 终态 / 互补取消 / 证据收紧");
  const mkTaskCase = async (taskStatusReceipt, opts) => {
    const hits = [];
    let workRes; const work = () => new Promise((res) => { workRes = res; });
    const r = await G.guardFixed(G.POLICY.ABSOLUTE, work, Object.assign({
      timeoutMs: 25, cancelDeadlineMs: 300, drainDeadlineMs: 300,
      meta: { runId: "R", taskId: "T" },
      cancelTask: () => { hits.push("task"); return taskStatusReceipt; },
      cancelRun: () => { hits.push("run"); setTimeout(() => workRes("x"), 6); return true; },
      cancelAll: () => { hits.push("all"); return true; },
    }, opts || {}));
    return { r, hits };
  };
  // dist 侧把 Task.status 映射成 {confirmed,terminal}；这里按映射结果覆盖 5 种 status
  await t("K.1 Task.status=completed/failed/cancelled → 远端终态，不走 cancelAll", async () => {
    for (const st of ["completed", "failed", "cancelled"]) {
      const { r, hits } = await mkTaskCase({ confirmed: true, terminal: true, taskStatus: st });
      assert.strictEqual(r.state.remoteTerminal, true, st + " 应判终态");
      assert.ok(hits.includes("run"), st + " 仍须互补调 cancelRun");
      assert.ok(!hits.includes("all"), st + " 不该走 cancelAll");
    }
  });
  await t("K.2 Task.status=working/input_required → 非终态（受理≠终止）", async () => {
    for (const st of ["working", "input_required"]) {
      const { r } = await mkTaskCase({ confirmed: false, terminal: false, taskStatus: st });
      assert.strictEqual(r.state.remoteTerminal, false, st + " 不该判终态");
    }
  });
  await t("K.3 远端非终态 + 本地精确成功 → 仍不走 cancelAll", async () => {
    const { r, hits } = await mkTaskCase({ confirmed: false, terminal: false, taskStatus: "working" });
    assert.strictEqual(r.state.cancelPrecise, true);
    assert.ok(!hits.includes("all"), "本地精确成功后不该兜底全量取消");
    assert.strictEqual(r.state.cancelFallback, null);
  });
  await t("K.4 远端非终态 + 本地精确失败 → 才允许 cancelAll", async () => {
    let workRes; const hits = [];
    const r = await G.guardFixed(G.POLICY.ABSOLUTE,
      () => new Promise((res) => { workRes = res; }), {
        timeoutMs: 25, cancelDeadlineMs: 300, drainDeadlineMs: 300,
        meta: { runId: "R", taskId: "T" },
        cancelTask: () => ({ confirmed: false, terminal: false, taskStatus: "working" }),
        cancelRun: () => { hits.push("run"); return false; },      // 本地精确失败
        cancelAll: () => { hits.push("all"); setTimeout(() => workRes("x"), 6); return true; },
      });
    assert.deepStrictEqual(hits, ["run", "all"], "应在精确失败后才兜底");
    assert.strictEqual(r.state.cancelFallback, true);
    assert.strictEqual(r.state.cancelHitLevel, "cancelAll");
  });
  await t("K.5 SUPERSEDED 即便远端非终态+精确失败也禁 cancelAll", async () => {
    let gen = 1;
    const r = await G.guardProgress(never, {
      preLogMs: 5000, idleMs: 5000, pollMs: 10, cancelDeadlineMs: 30, drainDeadlineMs: 30,
      meta: { runId: "old", generation: 1, taskId: "T" },
      ownerRef: () => ({ runId: "old", generation: gen }),
      probe: () => { gen = 2; return {}; },
      cancelTask: () => ({ confirmed: false, terminal: false, taskStatus: "working" }),
      cancelRun: () => false,
      cancelAll: () => { throw new Error("SUPERSEDED 绝不能兜底全量取消"); },
    });
    assert.strictEqual(r.cause, G.CAUSE.SUPERSEDED);
    assert.strictEqual(r.state.cancelFallback, null);
  });
  await t("K.6 证据缺 token → 拒（TOKEN_MISSING）", async () => {
    const r = await supersedeCase(() => ({ runId: "old", fromGeneration: 1, toGeneration: 2,
      kind: G.SUPERSEDE_KINDS.SOFT_STOP, token: null, at: new Date().toISOString() }));
    assert.strictEqual(r.outcome.belongsTo, "BAD");
    assert.strictEqual(r.state.supersedeRejectReason, "TOKEN_MISSING");
  });
  await t("K.7 新 gen 可见但证据缺 toGeneration → 拒（不再放过）", async () => {
    const r = await supersedeCase(() => ({ runId: "old", fromGeneration: 1,
      kind: G.SUPERSEDE_KINDS.SOFT_STOP }));   // 无 toGeneration
    assert.strictEqual(r.outcome.belongsTo, "BAD");
    assert.strictEqual(r.state.supersedeRejectReason, "TO_GENERATION_MISSING");
  });
  await t("K.8 证据超 5 分钟 → 拒（EVIDENCE_EXPIRED）", async () => {
    const r = await supersedeCase(() => ({ runId: "old", fromGeneration: 1, toGeneration: 2,
      kind: G.SUPERSEDE_KINDS.SOFT_STOP, token: "old_tk",
      at: new Date(Date.now() - 6 * 60 * 1000).toISOString() }));
    assert.strictEqual(r.outcome.belongsTo, "BAD");
    assert.strictEqual(r.state.supersedeRejectReason, "EVIDENCE_EXPIRED");
  });
  await t("K.9 证据缺时间戳 → 拒（TIMESTAMP_MISSING）", () => {
    const st = G.createState(G.POLICY.PROGRESS, { runId: "r", generation: 4 });
    const ok = G.verifySupersedeEvidence(st, { runId: "r", generation: 5 },
      { supersedeLookup: () => ({ runId: "r", fromGeneration: 4, toGeneration: 5,
                                  kind: "soft-stop", token: "t" }) });   // 无 at
    assert.strictEqual(ok, false);
    assert.strictEqual(st.supersedeRejectReason, "TIMESTAMP_MISSING");
  });
  await t("K.10 token 一次性：同一证据第二次使用即拒（复用=BAD）", () => {
    const rec = { runId: "r", fromGeneration: 4, toGeneration: 5, kind: "soft-stop",
                  token: "one_shot", at: new Date().toISOString(), consumedAt: null };
    const s1 = G.createState(G.POLICY.PROGRESS, { runId: "r", generation: 4 });
    assert.strictEqual(G.verifySupersedeEvidence(s1, { runId: "r", generation: 5 },
      { supersedeLookup: () => rec }), true, "首次应通过：" + s1.supersedeRejectReason);
    assert.ok(rec.consumedAt, "首次通过后应标记 consumedAt");
    const s2 = G.createState(G.POLICY.PROGRESS, { runId: "r", generation: 4 });
    assert.strictEqual(G.verifySupersedeEvidence(s2, { runId: "r", generation: 5 },
      { supersedeLookup: () => rec }), false, "复用不该通过");
    assert.strictEqual(s2.supersedeRejectReason, "TOKEN_ALREADY_CONSUMED");
  });
  await t("K.11 consumeSupersedeToken 注入时由调用方消费（不就地改记录）", () => {
    const rec = { runId: "r", fromGeneration: 4, toGeneration: 5, kind: "force-reset",
                  token: "tk", at: new Date().toISOString(), consumedAt: null };
    const consumed = [];
    const st = G.createState(G.POLICY.PROGRESS, { runId: "r", generation: 4 });
    assert.strictEqual(G.verifySupersedeEvidence(st, { runId: "r", generation: 5 },
      { supersedeLookup: () => rec,
        consumeSupersedeToken: (tk, at) => consumed.push([tk, at]) }), true);
    assert.strictEqual(consumed.length, 1);
    assert.strictEqual(consumed[0][0], "tk");
    assert.strictEqual(rec.consumedAt, null, "有消费器时不该就地改记录");
    assert.ok(st.supersedeEvidence.consumedAt, "state 里仍应留 consumedAt 审计");
  });
  await t("K.12 时效上限常量为 5 分钟", () => {
    assert.strictEqual(G.SUPERSEDE_EVIDENCE_MAX_AGE_MS, 300000);
  });
  await t("K.13 消费器抛错 → TOKEN_CONSUME_FAILED，不得判 EXCLUDED（C5.1 fail-closed）", () => {
    const rec = { runId: "r", fromGeneration: 4, toGeneration: 5, kind: "soft-stop",
                  token: "tk", at: new Date().toISOString(), consumedAt: null };
    const st = G.createState(G.POLICY.PROGRESS, { runId: "r", generation: 4 });
    const ok = G.verifySupersedeEvidence(st, { runId: "r", generation: 5 },
      { supersedeLookup: () => rec,
        consumeSupersedeToken: () => { throw new Error("consume boom"); } });
    assert.strictEqual(ok, false, "消费失败仍判通过 = fail-open，必须拒");
    assert.strictEqual(st.supersedeRejectReason, "TOKEN_CONSUME_FAILED");
    assert.ok(/consume boom/.test(st.supersedeConsumeError || ""), "应记消费错误");
  });
  await t("K.14 就地标记失败（冻结记录）→ TOKEN_CONSUME_FAILED", () => {
    const frozen = Object.freeze({ runId: "r", fromGeneration: 4, toGeneration: 5,
      kind: "soft-stop", token: "tk", at: new Date().toISOString(), consumedAt: null });
    const st = G.createState(G.POLICY.PROGRESS, { runId: "r", generation: 4 });
    assert.strictEqual(G.verifySupersedeEvidence(st, { runId: "r", generation: 5 },
      { supersedeLookup: () => frozen }), false, "标记未生效却判通过 = 无法防复用");
    assert.strictEqual(st.supersedeRejectReason, "TOKEN_CONSUME_FAILED");
  });
  console.log("\n" + "=".repeat(58));
  console.log("  PASS=" + pass + "  FAIL=" + fails.length);
  if (fails.length) { fails.forEach((f) => console.log("   - " + f)); process.exit(1); }
})();
