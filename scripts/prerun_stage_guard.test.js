"use strict";
/**
 * prerun_stage_guard 单测 —— 验行为，不验源码字符串。
 *
 * 覆盖 codex 要求的 7 条 + 我补的 3 条边界：
 *   1. snapshot promise 永不 resolve → 超时、不派发 payload
 *   2. enrich   promise 永不 resolve → 超时、不派发 payload
 *   3. 正常完成 → ok=true、timedOut=false、原返回值透传
 *   4. 两个阶段各自独立上限（60s / 120s）
 *   5. 超时后 cancel/drain 成功 → drainSettled=true、recoveryRequired=false
 *   6. 超时后 drain 失败       → drainSettled=false、recoveryRequired=true
 *   7. payload 在任何失败路径都不得被派发（payloadDispatched 恒 false）
 *   + 同步抛出、rejection、unhandled rejection 不外泄、/status 摘要字段齐备
 *
 * 纯 Node，零外部依赖，可 `node prerun_stage_guard.test.js` 直接跑。
 */
const assert = require("node:assert");
const G = require("./prerun_stage_guard.js");

let pass = 0;
const failures = [];

async function t(name, fn) {
  try {
    await fn();
    pass++;
    console.log("  PASS " + name);
  } catch (err) {
    failures.push(name + " — " + ((err && err.message) || String(err)));
    console.log("  FAIL " + name + "  — " + ((err && err.message) || String(err)));
  }
}

const never = () => new Promise(() => {});          // 永不 resolve
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

(async function main() {
  console.log("=== prerun_stage_guard 单测 ===\n");

  console.log("[1] snapshot 永不 resolve");
  await t("1.1 超时且 ok=false", async () => {
    const r = await G.guardStage(G.STAGE_SNAPSHOT, never, { timeoutMs: 60, drainMs: 30 });
    assert.strictEqual(r.ok, false);
    assert.strictEqual(r.timedOut, true);
    assert.strictEqual(r.stage, "snapshot");
  });
  await t("1.2 state.timedOut / timeoutMs 记录正确", async () => {
    const r = await G.guardStage(G.STAGE_SNAPSHOT, never, { timeoutMs: 60, drainMs: 30 });
    assert.strictEqual(r.state.timedOut, true);
    assert.strictEqual(r.state.timeoutMs, 60);
    assert.ok(r.state.elapsedMs >= 55, "elapsedMs=" + r.state.elapsedMs);
  });
  await t("1.3 payloadDispatched 恒 false", async () => {
    const r = await G.guardStage(G.STAGE_SNAPSHOT, never, { timeoutMs: 60, drainMs: 30 });
    assert.strictEqual(r.state.payloadDispatched, false);
  });

  console.log("\n[2] enrich 永不 resolve");
  await t("2.1 超时且 stage=enrich", async () => {
    const r = await G.guardStage(G.STAGE_ENRICH, never, { timeoutMs: 60, drainMs: 30 });
    assert.strictEqual(r.ok, false);
    assert.strictEqual(r.timedOut, true);
    assert.strictEqual(r.stage, "enrich");
  });
  await t("2.2 超时码是 PRE_RUN_ENRICH_TIMEOUT（与 snapshot 区分）", async () => {
    const r = await G.guardStage(G.STAGE_ENRICH, never, { timeoutMs: 60, drainMs: 30 });
    const body = G.timeoutResponse(r.stage, r.state);
    assert.strictEqual(body.error, "PRE_RUN_ENRICH_TIMEOUT");
    const b2 = G.timeoutResponse("snapshot", r.state);
    assert.strictEqual(b2.error, "PRE_RUN_SNAPSHOT_TIMEOUT");
  });

  console.log("\n[3] 正常完成");
  await t("3.1 ok=true、timedOut=false、值透传", async () => {
    const r = await G.guardStage(G.STAGE_SNAPSHOT,
      async () => ({ rc: 0, logPath: "/tmp/a.log" }), { timeoutMs: 5000 });
    assert.strictEqual(r.ok, true);
    assert.strictEqual(r.timedOut, false);
    assert.strictEqual(r.value.rc, 0);
    assert.strictEqual(r.value.logPath, "/tmp/a.log");
  });
  await t("3.2 正常完成不触发 cancel", async () => {
    let cancelled = false;
    await G.guardStage(G.STAGE_SNAPSHOT, async () => "done",
      { timeoutMs: 5000, cancelRun: () => { cancelled = true; return true; } });
    assert.strictEqual(cancelled, false);
  });
  await t("3.3 正常完成 state.completedAt 有值、recoveryRequired=false", async () => {
    const r = await G.guardStage(G.STAGE_SNAPSHOT, async () => 1, { timeoutMs: 5000 });
    assert.ok(r.state.completedAt);
    assert.strictEqual(r.state.recoveryRequired, false);
  });

  console.log("\n[4] 两阶段默认上限独立");
  await t("4.1 默认值 60s / 120s（codex 指定）", () => {
    assert.strictEqual(G.SNAPSHOT_TIMEOUT_MS, 60000);
    assert.strictEqual(G.ENRICH_TIMEOUT_MS, 120000);
  });
  await t("4.2 未传 timeoutMs 时按阶段取默认", async () => {
    // 用立即完成的 work，只检查 state.timeoutMs 取到的默认值
    const s = await G.guardStage(G.STAGE_SNAPSHOT, async () => 1, {});
    const e = await G.guardStage(G.STAGE_ENRICH, async () => 1, {});
    assert.strictEqual(s.state.timeoutMs, 60000);
    assert.strictEqual(e.state.timeoutMs, 120000);
  });

  console.log("\n[5] 超时后 cancel/drain 成功");
  await t("5.1 drain 成功 → drainSettled=true、recoveryRequired=false", async () => {
    let resolveWork;
    const work = () => new Promise((res) => { resolveWork = res; });
    const p = G.guardStage(G.STAGE_SNAPSHOT, work, {
      timeoutMs: 50, drainMs: 500,
      cancelRun: () => { setTimeout(() => resolveWork("late"), 20); return true; },
    });
    const r = await p;
    assert.strictEqual(r.timedOut, true);
    assert.strictEqual(r.state.cancelAttempted, true);
    assert.strictEqual(r.state.cancelOk, true);
    assert.strictEqual(r.state.drainSettled, true, "drainSettled=" + r.state.drainSettled);
    assert.strictEqual(r.state.recoveryRequired, false);
  });
  await t("5.2 cancelRun 抛错 → cancelOk=false 但流程继续", async () => {
    const r = await G.guardStage(G.STAGE_SNAPSHOT, never, {
      timeoutMs: 50, drainMs: 40,
      cancelRun: () => { throw new Error("cancel boom"); },
    });
    assert.strictEqual(r.state.cancelAttempted, true);
    assert.strictEqual(r.state.cancelOk, false);
    assert.strictEqual(r.timedOut, true);
  });

  console.log("\n[6] 超时后 drain 失败");
  await t("6.1 drain 不落定 → drainSettled=false、recoveryRequired=true", async () => {
    const r = await G.guardStage(G.STAGE_SNAPSHOT, never,
      { timeoutMs: 50, drainMs: 40 });
    assert.strictEqual(r.state.drainSettled, false);
    assert.strictEqual(r.state.recoveryRequired, true);
  });
  await t("6.2 recovery(drain 失败) → 503 + recoveryRequired（codex 阻塞7）", async () => {
    const r = await G.guardStage(G.STAGE_ENRICH, never,
      { timeoutMs: 50, drainMs: 40 });
    const body = G.timeoutResponse(r.stage, r.state);
    assert.strictEqual(body.recoveryRequired, true);
    assert.strictEqual(body.drainSettled, false);
    assert.strictEqual(body.status, 503, "drain 无法收敛=桥需 reopen，应 503 而非 504");
    assert.strictEqual(r.status, 503, "顶层 status 也应 503");
  });
  await t("6.3 干净超时(cancel+drain 成功) → 504（与 503 分野）", async () => {
    let resolveWork;
    const r = await G.guardStage(G.STAGE_SNAPSHOT,
      () => new Promise((res) => { resolveWork = res; }), {
        timeoutMs: 40, cancelDeadlineMs: 500, drainMs: 500,
        cancelRun: () => { setTimeout(() => resolveWork("late"), 15); return true; },
      });
    assert.strictEqual(r.timedOut, true);
    assert.strictEqual(r.state.recoveryRequired, false, "干净收敛不需恢复");
    assert.strictEqual(G.timeoutResponse(r.stage, r.state).status, 504, "干净超时应 504");
  });
  await t("6.4 readiness promise 超时仍排空 underlying transport", async () => {
    let resolveTransport;
    const transport = new Promise((resolve) => { resolveTransport = resolve; });
    const r = await G.guardStage(G.STAGE_SNAPSHOT, () => new Promise(() => {}), {
      timeoutMs: 35, drainMs: 300,
      meta: { runId: "stage-readiness", transportRunId: "transport-readiness" },
      drainPromise: () => transport,
      cancelRun: () => { setTimeout(() => resolveTransport("transport-settled"), 15); return true; },
      transportProbe: () => ({ runId: "transport-readiness", transportAck: true }),
    });
    assert.strictEqual(r.ok, false);
    assert.strictEqual(r.state.transportPromiseAttached, true);
    assert.strictEqual(r.state.transportSettled, true);
    assert.strictEqual(r.state.recoveryRequired, false);
    const body = G.timeoutResponse(r.stage, r.state);
    assert.strictEqual(body.payloadDispatched, false);
    assert.strictEqual(body.transportRunId, "transport-readiness");
    assert.strictEqual(body.transportAck, true);
  });
  await t("6.5 underlying transport 不收敛 → recovery-required", async () => {
    const r = await G.guardStage(G.STAGE_ENRICH, () => new Promise(() => {}), {
      timeoutMs: 35, drainMs: 35,
      meta: { runId: "stage-stuck", transportRunId: "transport-stuck" },
      drainPromise: () => new Promise(() => {}),
      transportProbe: () => ({ runId: "transport-stuck", transportAck: true }),
    });
    assert.strictEqual(r.state.transportPromiseAttached, true);
    assert.strictEqual(r.state.transportSettled, false);
    assert.strictEqual(r.state.recoveryRequired, true);
    assert.strictEqual(G.timeoutResponse(r.stage, r.state).status, 503);
  });

  console.log("\n[7] payload 在任何失败路径都不派发");
  await t("7.1 超时路径 payloadDispatched=false", async () => {
    const r = await G.guardStage(G.STAGE_SNAPSHOT, never, { timeoutMs: 50, drainMs: 30 });
    assert.strictEqual(G.timeoutResponse(r.stage, r.state).payloadDispatched, false);
  });
  await t("7.2 同步抛出路径 ok=false（调用方须放弃派发）", async () => {
    const r = await G.guardStage(G.STAGE_SNAPSHOT, () => { throw new Error("sync boom"); },
      { timeoutMs: 5000 });
    assert.strictEqual(r.ok, false);
    assert.strictEqual(r.timedOut, false);
    assert.ok(/sync boom/.test(r.state.error), "error=" + r.state.error);
  });
  await t("7.3 异步 reject 路径 ok=false", async () => {
    const r = await G.guardStage(G.STAGE_ENRICH,
      async () => { throw new Error("async boom"); }, { timeoutMs: 5000 });
    assert.strictEqual(r.ok, false);
    assert.strictEqual(r.timedOut, false);
    assert.ok(/async boom/.test(r.state.error));
  });
  await t("7.4 调用方按 ok 决定派发的契约可用", async () => {
    let dispatched = false;
    const r = await G.guardStage(G.STAGE_SNAPSHOT, never, { timeoutMs: 50, drainMs: 30 });
    if (r.ok) dispatched = true;          // 产品接线层的判据形态
    assert.strictEqual(dispatched, false);
  });

  console.log("\n[8] 边界：超时后原 promise 的 rejection 不得外泄");
  await t("8.1 超时后原 promise reject 不产生 unhandled rejection", async () => {
    const seen = [];
    const onUnhandled = (e) => seen.push(e);
    process.on("unhandledRejection", onUnhandled);
    let rejectWork;
    const r = await G.guardStage(G.STAGE_SNAPSHOT,
      () => new Promise((_, rej) => { rejectWork = rej; }),
      { timeoutMs: 40, drainMs: 30 });
    rejectWork(new Error("late reject"));
    await sleep(80);
    process.removeListener("unhandledRejection", onUnhandled);
    assert.strictEqual(r.timedOut, true);
    assert.strictEqual(seen.length, 0, "捕到 " + seen.length + " 个 unhandledRejection");
  });

  console.log("\n[9] /status 摘要");
  await t("9.1 publicStageSummary 字段齐备", async () => {
    const r = await G.guardStage(G.STAGE_ENRICH, never, {
      timeoutMs: 50, drainMs: 30,
      meta: { runId: "run_X", sourceMode: "visible-bridge", snapshotPath: "/tmp/s.dta" },
    });
    const s = G.publicStageSummary(r.state);
    for (const f of ["preRunStage", "stageStartedAt", "snapshotPath", "runId",
                     "sourceMode", "timedOut", "timeoutMs", "elapsedMs",
                     "cancelAttempted", "cancelOk", "drainSettled",
                     "recoveryRequired", "payloadDispatched", "completedAt"]) {
      assert.ok(f in s, "缺字段 " + f);
    }
    assert.strictEqual(s.preRunStage, "enrich");
    assert.strictEqual(s.runId, "run_X");
    assert.strictEqual(s.sourceMode, "visible-bridge");
    assert.strictEqual(s.snapshotPath, "/tmp/s.dta");
    assert.strictEqual(s.timedOut, true);
    assert.strictEqual(s.payloadDispatched, false);
  });
  await t("9.2 无状态时返回 null", () => {
    assert.strictEqual(G.publicStageSummary(null), null);
  });
  await t("9.3 meta 透传进 504 体（runId/sourceMode/snapshotPath）", async () => {
    const r = await G.guardStage(G.STAGE_SNAPSHOT, never, {
      timeoutMs: 40, drainMs: 20,
      meta: { runId: "run_Y", sourceMode: "human-file", snapshotPath: "/tmp/y.dta" },
    });
    const b = G.timeoutResponse(r.stage, r.state);
    assert.strictEqual(b.runId, "run_Y");
    assert.strictEqual(b.sourceMode, "human-file");
    assert.strictEqual(b.snapshotPath, "/tmp/y.dta");
  });

  console.log("\n[10] codex 复核补测：v4 三处修复 + 6 类核心场景");

  await t("10.1 cancel 永不返回 → CANCEL_TIMED_OUT，且仍进入 drain", async () => {
    const r = await G.guardStage(G.STAGE_SNAPSHOT, never, {
      timeoutMs: 40, cancelDeadlineMs: 40, drainMs: 40,
      cancelRun: () => new Promise(() => {}),   // cancel 自己永不 resolve
    });
    assert.strictEqual(r.state.cancelAttempted, true);
    assert.strictEqual(r.state.cancelTimedOut, true, "cancelTimedOut 应为 true");
    // cancel 超时后仍应走到 drain（drainSettled 被赋值，非 null）
    assert.notStrictEqual(r.state.drainSettled, null, "drain 未开始");
    // 最终 result 反映最严重态
    assert.ok([G.RESULT.CANCEL_TIMED_OUT, G.RESULT.DRAIN_FAILED].includes(r.result),
              "result=" + r.result);
  });

  await t("10.2 cancel deadline 后进入 drain（不永久挂）", async () => {
    const t0 = Date.now();
    await G.guardStage(G.STAGE_SNAPSHOT, never, {
      timeoutMs: 30, cancelDeadlineMs: 40, drainMs: 40,
      cancelRun: () => new Promise(() => {}),
    });
    const el = Date.now() - t0;
    // timeout(30) + cancelDeadline(40) + drain(40) ≈ 110ms，给足余量但必须有界
    assert.ok(el < 2000, "总耗时 " + el + "ms，疑似永久挂");
  });

  await t("10.3 drain 永不返回 → DRAIN_FAILED + recoveryRequired", async () => {
    const r = await G.guardStage(G.STAGE_SNAPSHOT, never,
      { timeoutMs: 30, drainMs: 40 });   // 无 cancel，work 永不 resolve → drain 也不落定
    assert.strictEqual(r.state.drainSettled, false);
    assert.strictEqual(r.state.recoveryRequired, true);
    assert.strictEqual(r.result, G.RESULT.DRAIN_FAILED, "result=" + r.result);
  });

  await t("10.4 三种失败用不同错误码（超时/rejection/同步异常）", async () => {
    const to = await G.guardStage(G.STAGE_SNAPSHOT, never, { timeoutMs: 30, drainMs: 20 });
    const rj = await G.guardStage(G.STAGE_SNAPSHOT,
      async () => { throw new Error("x"); }, { timeoutMs: 5000 });
    const sy = await G.guardStage(G.STAGE_SNAPSHOT,
      () => { throw new Error("y"); }, { timeoutMs: 5000 });
    assert.strictEqual(to.result, G.RESULT.DRAIN_FAILED, "timeout→" + to.result);
    assert.strictEqual(rj.result, G.RESULT.REJECTED, "reject→" + rj.result);
    assert.strictEqual(sy.result, G.RESULT.SYNC_THREW, "sync→" + sy.result);
    // 三者互不相同
    assert.strictEqual(new Set([to.result, rj.result, sy.result]).size, 3);
  });

  await t("10.5 rejection 不被误报成 TIMEOUT（codex 指控2）", async () => {
    const r = await G.guardStage(G.STAGE_ENRICH,
      async () => { throw new Error("boom"); }, { timeoutMs: 5000 });
    assert.strictEqual(r.timedOut, false);
    assert.notStrictEqual(r.result, G.RESULT.TIMED_OUT);
    assert.notStrictEqual(r.result, G.RESULT.DRAIN_FAILED);
    assert.strictEqual(r.result, G.RESULT.REJECTED);
  });

  await t("10.6 payload 派发后 markPayloadDispatched 置 true（codex 指控3）", async () => {
    const r = await G.guardStage(G.STAGE_SNAPSHOT, async () => "ok", { timeoutMs: 5000 });
    assert.strictEqual(r.ok, true);
    // 正常完成后 payloadDispatched 初始仍 false（尚未派发）
    assert.strictEqual(G.publicStageSummary(r.state).payloadDispatched, false);
    // 接线层显式标记后才 true
    G.markPayloadDispatched(r.state);
    assert.strictEqual(G.publicStageSummary(r.state).payloadDispatched, true);
  });

  await t("10.7 完成态 result=COMPLETED", async () => {
    const r = await G.guardStage(G.STAGE_ENRICH, async () => 1, { timeoutMs: 5000 });
    assert.strictEqual(r.result, G.RESULT.COMPLETED);
  });

  await t("10.8 cancel 成功 → drain 落定 → 不需 recovery", async () => {
    let resolveWork;
    const r = await G.guardStage(G.STAGE_SNAPSHOT,
      () => new Promise((res) => { resolveWork = res; }), {
        timeoutMs: 40, cancelDeadlineMs: 500, drainMs: 500,
        cancelRun: () => { setTimeout(() => resolveWork("late"), 15); return true; },
      });
    assert.strictEqual(r.state.cancelOk, true);
    assert.strictEqual(r.state.cancelTimedOut, false);
    assert.strictEqual(r.state.drainSettled, true);
    assert.strictEqual(r.state.recoveryRequired, false);
    // cancel 成功让 drain 落定：result 应为 TIMED_OUT（原始超时因，非 drain 失败）
    assert.strictEqual(r.result, G.RESULT.TIMED_OUT, "result=" + r.result);
  });

  console.log("\n[11] C3 适配层增强（codex 阻塞6/7）");
  await t("11.1 接收 cancelRun 三级原语（不再混作 softStop）", async () => {
    let runArg = null, resolveWork;
    const r = await G.guardStage(G.STAGE_SNAPSHOT,
      () => new Promise((res) => { resolveWork = res; }), {
        timeoutMs: 40, cancelDeadlineMs: 500, drainMs: 500,
        meta: { runId: "run_T" },
        cancelRun: (rid) => { runArg = rid; setTimeout(() => resolveWork("x"), 10); return true; },
      });
    assert.strictEqual(runArg, "run_T", "cancelRun 未收到精确 runId");
    assert.strictEqual(r.state.cancelOk, true);
  });
  await t("11.2 顶层透传两维：cause/settlement/outcome/cancelHitLevel", async () => {
    const r = await G.guardStage(G.STAGE_SNAPSHOT, never, {
      timeoutMs: 40, cancelDeadlineMs: 30, drainMs: 30, meta: { runId: "r" },
      cancelRun: () => false, cancelAll: () => false,
    });
    assert.ok("cause" in r && "settlement" in r && "outcome" in r,
              "顶层缺两维字段");
    assert.strictEqual(r.recoveryRequired, true);
    assert.ok(Array.isArray(r.cancelLevels), "cancelLevels 应透传为数组");
  });
  await t("11.3 同步异常/rejection → 500（httpStatusFor 分野）", async () => {
    const sy = await G.guardStage(G.STAGE_SNAPSHOT, () => { throw new Error("s"); },
      { timeoutMs: 5000 });
    const rj = await G.guardStage(G.STAGE_ENRICH, async () => { throw new Error("r"); },
      { timeoutMs: 5000 });
    assert.strictEqual(G.httpStatusFor(sy.state), 500, "同步异常应 500");
    assert.strictEqual(G.httpStatusFor(rj.state), 500, "rejection 应 500");
    assert.strictEqual(sy.status, 500);
    assert.strictEqual(rj.status, 500);
  });
  await t("11.4 failureResponse 与 timeoutResponse 同源裁 status", async () => {
    const r = await G.guardStage(G.STAGE_SNAPSHOT, never, { timeoutMs: 40, drainMs: 30 });
    assert.strictEqual(G.failureResponse(r.stage, r.state).status,
                       G.timeoutResponse(r.stage, r.state).status, "两者 status 必须一致");
  });
  await t("11.5 publicStageSummary 含两维审计字段", async () => {
    const r = await G.guardStage(G.STAGE_ENRICH, never, {
      timeoutMs: 40, drainMs: 30, meta: { runId: "r" },
    });
    const s = G.publicStageSummary(r.state);
    for (const f of ["cause", "settlement", "outcome", "cancelHitLevel",
                     "cancelConfirmed", "httpStatus"]) {
      assert.ok(f in s, "publicStageSummary 缺字段 " + f);
    }
  });

  console.log("\n[12] C4.1 修正 + 两处 overclaim 回归钉");
  await t("12.1 rejection 的 reasonCode 是 EXEC_REJECTED，绝非 *_TIMEOUT（#7 overclaim）", async () => {
    const r = await G.guardStage(G.STAGE_SNAPSHOT,
      async () => { throw new Error("boom"); }, { timeoutMs: 5000 });
    const b = G.timeoutResponse(r.stage, r.state);
    assert.strictEqual(b.error, "EXEC_REJECTED", "rejection 不该谎报超时码，实为 " + b.error);
    assert.strictEqual(b.reasonCode, "EXEC_REJECTED");
    assert.ok(!/TIMEOUT/.test(b.error), "error 仍含 TIMEOUT");
    assert.strictEqual(b.status, 500);
  });
  await t("12.2 同步异常 reasonCode=EXEC_SYNC_THREW（#7）", async () => {
    const r = await G.guardStage(G.STAGE_ENRICH, () => { throw new Error("s"); },
      { timeoutMs: 5000 });
    const b = G.timeoutResponse(r.stage, r.state);
    assert.strictEqual(b.error, "EXEC_SYNC_THREW");
    assert.ok(!/TIMEOUT/.test(b.reasonCode));
  });
  await t("12.3 真超时仍用阶段 *_TIMEOUT 码（不误伤正路）", async () => {
    const r = await G.guardStage(G.STAGE_ENRICH, never, { timeoutMs: 40, drainMs: 30 });
    const b = G.timeoutResponse(r.stage, r.state);
    assert.strictEqual(b.error, "PRE_RUN_ENRICH_TIMEOUT", "真超时应保留阶段码");
  });
  await t("12.4 timeoutResponse 与 publicStageSummary 都含 cancelLevels（#8 overclaim）", async () => {
    const r = await G.guardStage(G.STAGE_SNAPSHOT, never, {
      timeoutMs: 40, cancelDeadlineMs: 30, drainMs: 30, meta: { runId: "r" },
      cancelRun: () => false, cancelAll: () => false,
    });
    const body = G.timeoutResponse(r.stage, r.state);
    const summ = G.publicStageSummary(r.state);
    assert.ok("cancelLevels" in body && Array.isArray(body.cancelLevels),
              "timeoutResponse 缺 cancelLevels 数组");
    assert.ok("cancelLevels" in summ && Array.isArray(summ.cancelLevels),
              "publicStageSummary 缺 cancelLevels 数组");
    assert.ok(body.cancelLevels.length >= 1, "cancelLevels 应记录尝试过的级");
  });

  require("./test_prerun_response_wiring_rc734.js");

  console.log("\n" + "=".repeat(58));
  console.log("  PASS=" + pass + "  FAIL=" + failures.length);
  if (failures.length) {
    failures.forEach((f) => console.log("   - " + f));
    process.exit(1);
  }
})();
