"use strict";
/**
 * prerun_stage_guard.js —— pre-run 阶段有界守卫（R1-128 修复）
 *
 * 缺陷背景（R1-128，MAJOR，落盘证据见测试工作区 post_regression/R1-128_ROOT_CAUSE.md）：
 *   visible-agent 与 human-file 两条路径在派发 payload 之前会做两件事：
 *     ① dataset snapshot：capture preserve / capture quietly save <run>.dta / capture restore
 *     ② checkpoint enrich：写 globals/estimates/graphs 到 <run>.dta.state/
 *   两者都是 `await zg.runSelection(...)`，**都没有超时**。任一不 resolve 时：
 *     桥停在 busy=true + postRunBusy=true + trueReady=false + phase=acquired，
 *     logPath 恒 null、rc 恒 null，Stata worker CPU 约 0.014 秒/秒（判挂线 0.05），
 *     实测持续 600-1200 秒不自解，此后任何派发都拿 'bridge busy' 并在约 600s 后
 *     返回 500 且 extRunOps 全零（从未进扩展）。唯一恢复途径是 reopen。
 *   实测停住深度**不唯一**：有的 .dta 已写完（save 成功后卡住），有的 .dta 未落地。
 *   故必须按阶段分别设限，而不是只在某一个 await 上加超时。
 *
 * 为什么不能靠主 watchdog：
 *   __codexBridgeWatchdog 对象在 pre-run 之前创建，但真正启动监视的 .guard()
 *   在两个 pre-run await **之后**才调用（全文仅 1 次，包裹 payload promise）。
 *   即 pre-run 阶段根本没有运行中的 watchdog，与 longRun 判定和 4 小时阈值均无关。
 *
 * 本模块职责（纯 Node，无 vscode / 无外部依赖，可单测）：
 *   · guardStage()        有界执行一个 pre-run 阶段；超时后有界 cancel/drain
 *   · timeoutResponse()   生成 504 响应体（含 payloadDispatched:false）
 *   · publicStageSummary() 供 /status 暴露阶段状态
 *
 * 红线：超时后**绝不**继续派发 payload —— 原 runSelection promise 可能仍占用
 *       transport，直接派发会双占。必须先 drain；drain 失败则进入
 *       recovery-required，而不是保持永久 busy。
 */

const SNAPSHOT_TIMEOUT_MS = 60000;   // dataset snapshot 上限：正常 1-3s
const CANCEL_DEADLINE_MS = 15000;    // opts.cancel() 自身的有界上限（v4 新增）
const ENRICH_TIMEOUT_MS = 120000;    // checkpoint enrich 上限：估计/图多时较慢
const DRAIN_TIMEOUT_MS = 15000;      // 超时后等待原 promise 落定的上限

const STAGE_SNAPSHOT = "snapshot";
const STAGE_ENRICH = "enrich";

// C3：本模块现为 execution_guard 的 ABSOLUTE 适配层。cancel/drain 的实现
// 统一收敛到 execution_guard，本文件不再重复维护那套逻辑（下方 guardStage 委托）。
const EG = require("./execution_guard.js");

// v4 结果枚举（codex 要求：同步异常/普通 rejection/超时用不同码，不能全当 TIMEOUT）
const RESULT = {
  COMPLETED: "COMPLETED",
  SYNC_THREW: "SYNC_THREW",
  REJECTED: "REJECTED",
  TIMED_OUT: "TIMED_OUT",
  CANCEL_TIMED_OUT: "CANCEL_TIMED_OUT",
  DRAIN_FAILED: "DRAIN_FAILED",
};

const TIMEOUT_CODE = {
  [STAGE_SNAPSHOT]: "PRE_RUN_SNAPSHOT_TIMEOUT",
  [STAGE_ENRICH]: "PRE_RUN_ENRICH_TIMEOUT",
};

function defaultTimeoutFor(stage) {
  return stage === STAGE_ENRICH ? ENRICH_TIMEOUT_MS : SNAPSHOT_TIMEOUT_MS;
}

function nowIso() {
  return new Date().toISOString();
}

/** 新建阶段状态对象。挂在 globalThis 上供 /status 读取。 */
function createStageState(stage, meta) {
  meta = meta || {};
  return {
    preRunStage: stage,
    stageStartedAt: nowIso(),
    stageStartedMs: Date.now(),
    snapshotPath: meta.snapshotPath || null,
    runId: meta.runId || null,
    sourceMode: meta.sourceMode || null,
    transportRunId: meta.transportRunId || null,
    transportTaskId: meta.transportTaskId || null,
    transportAck: false,
    transportSettled: null,
    transportSettlementAt: null,
    transportLogPath: null,
    transportLogBytes: null,
    transportPromiseAttached: false,
    timedOut: false,
    result: null,            // v4: RESULT.* —— 供接线层区分超时/rejection/同步异常
    timeoutMs: null,
    elapsedMs: null,
    cancelAttempted: false,
    cancelOk: null,
    cancelTimedOut: false,   // v4: opts.cancel() 自身超过 CANCEL_DEADLINE_MS
    drainSettled: null,
    drainMs: null,
    recoveryRequired: false,
    payloadDispatched: false,
    error: null,
    completedAt: null,
  };
}

function mergeTransportEvidence(state, probe) {
  if (!state || !probe || typeof probe !== "object") return state;
  if (probe.runId != null) state.transportRunId = String(probe.runId);
  if (probe.taskId != null) state.transportTaskId = String(probe.taskId);
  if (probe.transportAck != null) state.transportAck = !!probe.transportAck;
  if (probe.logPath != null) state.transportLogPath = String(probe.logPath);
  if (probe.logBytes != null && Number.isFinite(Number(probe.logBytes))) {
    state.transportLogBytes = Number(probe.logBytes);
  }
  if (probe.settled === true || probe.transportSettled === true) {
    state.transportSettled = true;
    state.transportSettlementAt = state.transportSettlementAt || nowIso();
  }
  return state;
}

/**
 * 有界执行一个 pre-run 阶段。
 *
 * @param {string} stage           "snapshot" | "enrich"
 * @param {Function} work          () => Promise —— 被守卫的原始调用
 * @param {object} opts
 *   opts.timeoutMs   覆盖默认上限
 *   opts.state       复用外部状态对象（否则新建）
 *   opts.meta        {runId, sourceMode, snapshotPath}
 *   opts.cancelTask/opts.cancelRun/opts.cancelAll  三级有界取消原语（可选，逐级降级）
 *     ⚠️ cancelTask 直接收 taskId（协议 tasks/cancel，服务端中止）；
 *        **不要**先把 taskId 映射成 runId 再调 cancelRun —— 那会降级最强的一级。
 *   opts.supersedeLookup  换代证据查询器（检测时查控制面，见 execution_guard D0a）
 *   opts.drainMs     drain 上限
 *   opts.log         (msg) => void
 * @returns {Promise<{ok, timedOut, stage, state, value?, error?}>}
 *   ok=true 时 value 是原调用返回值；ok=false 时调用方**必须**放弃派发 payload。
 */
async function guardStage(stage, work, opts) {
  opts = opts || {};
  const timeoutMs = Number.isFinite(opts.timeoutMs)
    ? opts.timeoutMs
    : defaultTimeoutFor(stage);
  const state = opts.state || createStageState(stage, opts.meta);
  state.preRunStage = stage;
  state.timeoutMs = timeoutMs;
  if (opts.meta) {
    if (opts.meta.runId != null) state.runId = opts.meta.runId;
    if (opts.meta.sourceMode != null) state.sourceMode = opts.meta.sourceMode;
    if (opts.meta.snapshotPath != null) state.snapshotPath = opts.meta.snapshotPath;
    if (opts.meta.transportRunId != null) state.transportRunId = opts.meta.transportRunId;
  }

  // C3：委托给通用 execution_guard 的 ABSOLUTE policy，删除本模块曾经重复的
  // cancel/drain 实现（codex 要求）。EG 内部有更完整的三级取消 + generation +
  // 归一化回执；这里做双向映射，保持 v4 对外形状（result/timedOut/state.*）不变，
  // 使已接线的 dist 5 处与 30 条既有单测继续可用。
  const egState = EG.createState(EG.POLICY.ABSOLUTE, {
    runId: state.runId, sourceMode: state.sourceMode,
    snapshotPath: state.snapshotPath,
    transportRunId: state.transportRunId,
  });
  const transportProbe = typeof opts.transportProbe === "function"
    ? opts.transportProbe : null;
  const refreshTransport = () => {
    if (!transportProbe) return;
    try { mergeTransportEvidence(state, transportProbe() || {}); } catch {}
  };
  refreshTransport();
  const eg = await EG.guardFixed(EG.POLICY.ABSOLUTE, work, {
    timeoutMs: timeoutMs, state: egState,
    cancelDeadlineMs: opts.cancelDeadlineMs, drainDeadlineMs: opts.drainMs,
    log: opts.log,
    // C4.1#6：D 接线统一传三级 transport 原语；删除旧 opts.cancel 兼容别名，
    // 取消与会话恢复彻底分离，杜绝 softStop 混淆。
    cancelTask: typeof opts.cancelTask === "function" ? opts.cancelTask : undefined,
    cancelRun: typeof opts.cancelRun === "function" ? opts.cancelRun : undefined,
    cancelAll: typeof opts.cancelAll === "function" ? opts.cancelAll : undefined,
    // D0a：换代证据查询器透传（ABSOLUTE 路径当前不判换代，但保持接口一致，
    // 便于 D 接线统一注入，且未来若给 ABSOLUTE 加属主校验无需再改签名）。
    supersedeLookup: typeof opts.supersedeLookup === "function"
      ? opts.supersedeLookup : undefined,
    // Atomic checkpoints expose a readiness promise before the original
    // runSelection transport settles. Drain the latter on timeout.
    drainPromise: opts.drainPromise,
  });
  refreshTransport();

  // EG 两维 → v4 单维 result 映射
  var result;
  if (eg.cause === EG.CAUSE.COMPLETED) result = RESULT.COMPLETED;
  else if (eg.cause === EG.CAUSE.SYNC_THREW) result = RESULT.SYNC_THREW;
  else if (eg.cause === EG.CAUSE.REJECTED) result = RESULT.REJECTED;
  else if (eg.settlement === EG.SETTLEMENT.CANCEL_TIMEOUT) result = RESULT.CANCEL_TIMED_OUT;
  else if (eg.settlement === EG.SETTLEMENT.DRAIN_FAILED) result = RESULT.DRAIN_FAILED;
  else result = RESULT.TIMED_OUT;

  // 回填 v4 state 字段（既有测试与 dist 的 timeoutResponse 依赖这些）
  state.timedOut = (eg.cause === EG.CAUSE.TIMED_OUT);
  state.result = result;
  state.elapsedMs = egState.elapsedMs;
  state.error = egState.error;
  state.cancelAttempted = !!egState.cancelAttempted;
  state.cancelOk = egState.cancelPrecise === true
    || egState.cancelHitLevel === "cancelRun" || egState.cancelHitLevel === "cancelAll";
  state.cancelTimedOut = !!egState.cancelTimedOut;
  state.drainSettled = egState.settlement === EG.SETTLEMENT.DRAINED
    || egState.settlement === EG.SETTLEMENT.CANCELLED;
  state.drainMs = egState.drainMs;
  state.recoveryRequired = !!egState.recoveryRequired;
  state.transportPromiseAttached = !!egState.transportPromiseAttached;
  state.transportSettled = egState.transportSettled;
  state.transportSettlementAt = egState.transportSettlementAt || null;
  state.transportRunId = egState.transportRunId || state.transportRunId || null;
  state.transportTaskId = egState.transportTaskId || state.transportTaskId || null;
  state.transportAck = !!(egState.transportAck || state.transportAck);
  state.transportLogPath = egState.transportLogPath || state.transportLogPath || null;
  state.transportLogBytes = egState.transportLogBytes == null
    ? state.transportLogBytes : egState.transportLogBytes;
  state.completedAt = egState.completedAt || nowIso();
  state.egOutcome = eg.outcome ? eg.outcome.code : null;   // 保留 EG 业务码供审计
  // C3（codex 阻塞7）：完整保留两维 + 取消层级，供 /status 与失败响应透传，
  // 不再让单维 result 吞掉 cause/settlement/cancelLevels/cancelHitLevel。
  state.cause = eg.cause || null;
  state.settlement = eg.settlement || null;
  state.outcome = eg.outcome ? eg.outcome.code : null;
  state.outcomeBelongsTo = eg.outcome ? eg.outcome.belongsTo : null;
  state.cancelLevels = Array.isArray(egState.cancelLevels) ? egState.cancelLevels : null;
  state.cancelHitLevel = egState.cancelHitLevel || null;
  state.cancelConfirmed = !!egState.cancelConfirmed;
  state.httpStatus = httpStatusFor(state);

  return { ok: eg.ok, timedOut: state.timedOut, result: result,
           stage: stage, state: state,
           // 顶层也透传两维，接线层无需深挖 state（新 dist 直接消费）
           cause: state.cause, settlement: state.settlement,
           outcome: state.outcome, outcomeBelongsTo: state.outcomeBelongsTo,
           cancelLevels: state.cancelLevels, cancelHitLevel: state.cancelHitLevel,
           status: state.httpStatus, recoveryRequired: state.recoveryRequired,
           value: eg.ok ? eg.value : undefined,
           error: eg.ok ? undefined : (eg.error || egState.error) };
}

/**
 * 失败响应 HTTP 状态映射（codex 阻塞7）：
 *   真超时（drain 成功收敛）        → 504
 *   同步异常 / 普通 rejection       → 500
 *   取消或 drain 无法收敛(需恢复)   → 503 + recoveryRequired
 * 纯函数，供 timeoutResponse 与 failureResponse 共用，二者绝不各判各的。
 */
function httpStatusFor(state) {
  if (!state) return 504;
  const res = state.result;
  if (res === RESULT.SYNC_THREW || res === RESULT.REJECTED) return 500;
  if (state.recoveryRequired) return 503;   // cancel-timeout / drain-failed：桥需 reopen
  return 504;                               // 干净超时：操作超限但可恢复
}

/**
 * C4.1#7：失败原因码。非超时（同步异常/rejection）**绝不**用阶段 *_TIMEOUT 码，
 * 否则谎报为超时。只有真超时才用 TIMEOUT_CODE[stage]。
 */
function reasonCodeFor(stage, state) {
  const res = state && state.result;
  if (res === RESULT.SYNC_THREW) return "EXEC_SYNC_THREW";
  if (res === RESULT.REJECTED) return "EXEC_REJECTED";
  return TIMEOUT_CODE[stage] || "PRE_RUN_STAGE_TIMEOUT";
}

/** 生成超时/失败的 HTTP 响应体。payloadDispatched 恒 false —— 这是本修复的核心承诺。
 *  status 由 httpStatusFor 统一裁定（504 真超时 / 500 异常 / 503 需恢复）；
 *  error/reasonCode 由 reasonCodeFor 裁定（非超时不谎报 *_TIMEOUT，C4.1#7）。 */
function timeoutResponse(stage, state, extra) {
  state = state || createStageState(stage, {});
  const code = reasonCodeFor(stage, state);
  const body = {
    ok: false,
    status: httpStatusFor(state),
    error: code,
    reasonCode: code,
    preRunStage: stage,
    runId: state.runId || null,
    sourceMode: state.sourceMode || null,
    snapshotPath: state.snapshotPath || null,
    transportRunId: state.transportRunId || null,
    transportTaskId: state.transportTaskId || null,
    transportAck: !!state.transportAck,
    transportPromiseAttached: !!state.transportPromiseAttached,
    transportSettled: state.transportSettled,
    transportSettlementAt: state.transportSettlementAt || null,
    transportLogPath: state.transportLogPath || null,
    transportLogBytes: state.transportLogBytes,
    payloadDispatched: false,
    timeoutMs: state.timeoutMs,
    elapsedMs: state.elapsedMs,
    cancelAttempted: !!state.cancelAttempted,
    cancelOk: state.cancelOk,
    cancelTimedOut: !!state.cancelTimedOut,
    drainSettled: state.drainSettled,
    drainMs: state.drainMs,
    recoveryRequired: !!state.recoveryRequired,
    // C3/C4.1#8：两维 + **cancelLevels** 也进响应体（审计/诊断）
    cause: state.cause || null,
    settlement: state.settlement || null,
    outcome: state.outcome || null,
    cancelHitLevel: state.cancelHitLevel || null,
    cancelLevels: Array.isArray(state.cancelLevels) ? state.cancelLevels : null,
    stageStartedAt: state.stageStartedAt || null,
  };
  if (extra && typeof extra === "object") Object.assign(body, extra);
  return body;
}

/** failureResponse：timeoutResponse 的语义别名（含非超时失败）。同一 httpStatusFor 裁定。 */
function failureResponse(stage, state, extra) {
  return timeoutResponse(stage, state, extra);
}

/** /status 用的阶段摘要。无进行中阶段时返回 null。 */
function publicStageSummary(state) {
  if (!state) return null;
  return {
    preRunStage: state.preRunStage || null,
    stageStartedAt: state.stageStartedAt || null,
    snapshotPath: state.snapshotPath || null,
    runId: state.runId || null,
    sourceMode: state.sourceMode || null,
    timedOut: !!state.timedOut,
    result: state.result || null,
    timeoutMs: state.timeoutMs == null ? null : state.timeoutMs,
    elapsedMs: state.elapsedMs == null ? null : state.elapsedMs,
    cancelAttempted: !!state.cancelAttempted,
    cancelOk: state.cancelOk == null ? null : state.cancelOk,
    cancelTimedOut: !!state.cancelTimedOut,
    drainSettled: state.drainSettled == null ? null : state.drainSettled,
    recoveryRequired: !!state.recoveryRequired,
    // C3（codex 阻塞7）：两维 + 取消层级进 /status，单维 result 不再吞信息
    cause: state.cause || null,
    settlement: state.settlement || null,
    outcome: state.outcome || null,
    outcomeBelongsTo: state.outcomeBelongsTo || null,
    cancelHitLevel: state.cancelHitLevel || null,
    cancelLevels: Array.isArray(state.cancelLevels) ? state.cancelLevels : null,
    cancelConfirmed: !!state.cancelConfirmed,
    httpStatus: state.httpStatus == null ? null : state.httpStatus,
    transportRunId: state.transportRunId || null,
    transportTaskId: state.transportTaskId || null,
    transportAck: !!state.transportAck,
    transportPromiseAttached: !!state.transportPromiseAttached,
    transportSettled: state.transportSettled,
    transportSettlementAt: state.transportSettlementAt || null,
    transportLogPath: state.transportLogPath || null,
    transportLogBytes: state.transportLogBytes,
    payloadDispatched: !!state.payloadDispatched,
    completedAt: state.completedAt || null,
  };
}

/**
 * v4 修正 codex 指控3：payload 真正派发前原子置 true。
 * 接线层在 guard 返回 ok=true 之后、真正 await payload 之前调用本函数。
 */
function markPayloadDispatched(state) {
  if (state) state.payloadDispatched = true;
  return state;
}

module.exports = {
  SNAPSHOT_TIMEOUT_MS,
  ENRICH_TIMEOUT_MS,
  DRAIN_TIMEOUT_MS,
  CANCEL_DEADLINE_MS,
  STAGE_SNAPSHOT,
  STAGE_ENRICH,
  TIMEOUT_CODE,
  RESULT,
  createStageState,
  guardStage,
  timeoutResponse,
  failureResponse,
  httpStatusFor,
  publicStageSummary,
  markPayloadDispatched,
};
