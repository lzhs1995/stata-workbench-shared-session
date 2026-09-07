#!/usr/bin/env node
"use strict";

const assert = require("assert");
const fs = require("fs");
const path = require("path");
const checkpoint = require("./stop_checkpoint_core");

const bundle = fs.readFileSync(path.join(__dirname, "..", "dist", "extension.js"), "utf8");

const softAt = bundle.indexOf("globalThis.__codexSoftStop=async");
const hardAt = bundle.indexOf("globalThis.__codexForceReset=async", softAt);
assert.ok(softAt >= 0 && hardAt > softAt, "soft Stop must precede hard reset");
const soft = bundle.slice(softAt, hardAt);
assert.ok(soft.includes("await zg.cancelRun(__runId)"));
assert.ok(soft.includes("Promise.resolve(zg.cancelAll())"));
assert.ok(soft.includes('zg._callTool(__client,"cancel_task"'));
assert.ok(soft.includes("soft Stop cancels the server background task"));
assert.ok(soft.includes("server task drain before snapshot restore"));
assert.ok(soft.includes("cancelled task_done drains before restore"));
assert.ok(soft.includes('zg._runsByTaskId.get(String(__taskId))'));
assert.ok(soft.includes('let __payload=__trackedRun?._taskDonePayload||null'));
assert.ok(!soft.includes('zg._callTool(__drainClient,"get_task_status"'));
assert.ok(soft.includes('__taskDrain.terminal=true'));
assert.ok(soft.includes('taskDrain:__taskDrain'));
assert.ok(soft.includes('transportDrain:__transportDrain'));
assert.ok(soft.includes("StopCheckpointRef.transportSummary(__snapshot,zg,__taskId)"));
assert.ok(soft.includes("if(__transportDrain.safeForRestore)break"));
assert.ok(soft.includes("transport promise did not settle"));
assert.ok(!soft.includes("if(!__drained&&!__codexPreDispatchRestore)"));
assert.ok(!soft.includes("__drained||__codexPreDispatchRestore"));
assert.ok(bundle.includes('codex patch rc.7.10.41: full Stop checkpoint'));
assert.ok(bundle.includes('stop_checkpoint_core.js'));
assert.ok(soft.includes('globalThis.__codexStopCheckpointRef.restoreCode'));
assert.ok(soft.includes('globalThis.__codexStopCheckpointRef.cleanup'));
assert.ok(soft.includes('if(globalThis.__codexStopCheckpointRef.softStopReadiness(__restore,__hardReset).ready===true)globalThis.__codexStopCheckpointRef.cleanup(__snapshot)'),
  "failed/degraded Stop must retain its checkpoint, not destroy the recovery evidence");
assert.ok(bundle.includes('globalThis.__codexStopCheckpointRef.publicSummary'));
assert.ok(soft.includes("checkpoint-aware soft Stop restore window"));
assert.ok(soft.includes("restoreTimeoutMs(__snapshot)"));
assert.ok(soft.includes("timeoutMs:__restoreTimeoutMs"));
assert.ok(soft.includes('soft-stop dataset restore timed out after "+String(__restoreTimeoutMs)+"ms'));
assert.ok(!soft.includes("soft-stop dataset restore timed out after 5000ms"));
assert.ok(soft.includes("soft Stop hard fallback restores the dataset"));
assert.ok(soft.includes("soft-stop-hard-restore-"));
// codex patch rc.7.35（缺陷 PF-4）：L2 期限不得再是硬编码 30000（< L1 的 45000）。
assert.ok(!soft.includes("hard-fallback dataset restore timed out after 30000ms"),
  "L2 restore must not carry a hardcoded 30000ms budget (defect PF-4)");
assert.ok(soft.includes('hard-fallback dataset restore timed out after "+String(__codexL2RestoreMs)+"ms'));
assert.ok(soft.includes("monotonic escalation ladder"));
assert.ok(soft.includes("escalationLadder(__snapshot)"));
assert.ok(soft.includes("snapshotless Stop proves backend quiescence"));
assert.ok(soft.includes("soft-stop-quiescence-"));
assert.ok(soft.includes("snapshotless soft-stop quiescence probe timed out after 5000ms"));
assert.ok(soft.includes("soft-stop escalation: snapshotless backend not quiescent"));
assert.ok(soft.includes('skipped:"no pre-run dataset snapshot",escalated:true'));
assert.ok(soft.includes("hard fallback reconnects before restore"));
assert.ok(soft.includes("Promise.resolve(zg.connect())"));
assert.ok(!soft.includes("hard-fallback reconnect timed out after 10000ms"),
  "L2 reconnect must not carry a hardcoded 10000ms budget (defect PF-4)");
assert.ok(soft.includes('hard-fallback reconnect timed out after "+String(__codexL2ReconnectMs)+"ms'));
assert.ok(soft.includes("reconnect:__reconnectAttempt"));
// 降级恢复必须如实标注：L2 只恢复 dataset + globals，不重建 estimates/graphs。
assert.ok(soft.includes("restoreCode(__snapshot,__codexStataString,{datasetOnly:true})"));
assert.ok(soft.includes("degraded:__codexL2Downgrade"));
assert.ok(soft.includes("ladder:__codexLadder"));
assert.ok(soft.includes("zg.runSelection(__codexL2RestoreCode,"));
assert.ok(soft.includes("stale reconnect gets one owned retry"));
assert.ok(soft.includes("bounded cancellation latency"));
assert.ok(soft.includes("soft-stop escalation: stale reconnect retry after"));
assert.ok(soft.includes("soft-stop-hard-restore-retry-"));
assert.ok(!soft.includes("stale-reconnect dataset restore retry timed out after 30000ms"),
  "stale-reconnect restore retry must not carry a hardcoded 30000ms budget (defect PF-4)");
assert.ok(soft.includes('stale-reconnect dataset restore retry timed out after "+String(__codexL2RestoreMs)+"ms'));
assert.ok(!soft.includes("stale-reconnect retry timed out after 10000ms"),
  "stale-reconnect reconnect must not carry a hardcoded 10000ms budget (defect PF-4)");
assert.ok(soft.includes('stale-reconnect retry timed out after "+String(__codexL2ReconnectMs)+"ms'));
assert.ok(soft.includes("__hardReset.retry="));
assert.ok(soft.includes("soft Stop always requests bounded break_session"));
assert.ok(soft.includes("setTimeout(()=>__resolve({settled:false,timeout:true,taskId:String(__taskId)}),2500)"));
assert.ok(soft.includes("setTimeout(()=>__resolve({settled:false,timeout:true}),2500)"));
assert.ok(!soft.includes("if(!__cancelled)try{__cancelled=!!(await zg.cancelAll())"));
assert.ok(soft.includes("__codexPreRunSnapshots"));
assert.ok(soft.includes("__activeSnapshot"));
assert.ok(soft.includes("String(__activeSnapshot.runId)===String(__runId)"));
assert.ok(soft.includes('delete(String(__runId||""))'));
assert.ok(soft.includes("if(__snapshot)__snapshot.stopOwned=true"));
assert.ok(soft.includes("globalThis.__codexStopCheckpointRef.softStopReadiness(__restore,__hardReset)"));
assert.ok(soft.includes("successful hard reset owns final readiness"));
assert.ok(!soft.includes('readinessState:__restore&&__restore.ok===false?"stale":"ready"'));
const recoveredReadiness = checkpoint.softStopReadiness(
  { ok: false, error: "STOP_RESTORE_TIMEOUT" },
  { ok: true, trueReady: true }
);
assert.strictEqual(recoveredReadiness.ready, false);
assert.strictEqual(recoveredReadiness.readinessReason, "soft-stop-checkpoint-not-restored");
assert.strictEqual(recoveredReadiness.recoveryClass, "RECOVERY_FAILED");
assert.ok(recoveredReadiness.continuityLost);
assert.ok(recoveredReadiness.lastClientError.includes("STOP_RESTORE_TIMEOUT"));
const degradedReadiness = checkpoint.softStopReadiness({
  ok: true,
  degraded: {
    mode: "dataset-only",
    skippedEstimates: 3,
    skippedGraphs: 2,
    datasetRestored: true,
    globalsRestored: true,
  },
}, { ok: true, trueReady: true });
assert.strictEqual(degradedReadiness.ready, false);
assert.strictEqual(degradedReadiness.readinessReason, "soft-stop-degraded-recovery");
assert.strictEqual(degradedReadiness.recoveryClass, "RECOVERED_DEGRADED");
assert.strictEqual(degradedReadiness.continuityLost.skippedEstimates, 3);
assert.strictEqual(degradedReadiness.continuityLost.skippedGraphs, 2);
const failedReadiness = checkpoint.softStopReadiness(
  { ok: false, error: "STOP_RESTORE_TIMEOUT" },
  { ok: true, trueReady: false }
);
assert.strictEqual(failedReadiness.readinessReason, "soft-stop dataset restore failed");
assert.ok(!soft.includes("zg.dispose()"), "soft Stop must delegate any hard fallback to the owned reset path");
assert.ok(!soft.includes("cleanup.sh"), "soft Stop must not directly kill an unscoped backend");

const humanAt = bundle.indexOf("async function xHg");
const humanEnd = bundle.indexOf("globalThis.__codexRunFileHandler=xHg", humanAt);
const human = bundle.slice(humanAt, humanEnd);
assert.ok(human.includes("codex_prerun_state_"));
assert.ok(human.includes("pre-run dataset snapshot for soft Stop"));
assert.ok(human.includes("globalThis.__codexStopCheckpointRef.beginAtomic"));
assert.ok(human.includes("globalThis.__codexStopCheckpointRef.completeAtomic"));
assert.ok(human.includes("trackTransport(__codexHumanFilePreRunSnapshot,__codexHumanFilePromise"));
assert.ok(human.includes("normal completion removes pre-run snapshot"));

const bridgeAt = bundle.indexOf("let __codexBridgeDocScanText=");
const bridgeEnd = bundle.indexOf("__send(__res,200", bridgeAt);
const bridge = bundle.slice(bridgeAt, bridgeEnd);
assert.ok(bridge.includes("codex_prerun_agent_state_"));
assert.ok(bridge.includes("visible bridge snapshots pre-run dataset"));
assert.ok(bridge.includes("globalThis.__codexStopCheckpointRef.beginAtomic"));
assert.ok(bridge.includes("globalThis.__codexStopCheckpointRef.completeAtomic"));
assert.ok(bridge.includes("trackTransport(__codexBridgePreRunSnapshot,__codexBridgePromise"));
assert.ok(bridge.includes("globalThis.__codexPreRunSnapshots.set(__run"));
assert.ok(bridge.includes("globalThis.__codexPreRunSnapshots.set(String(__run)"));
assert.ok(bridge.includes("globalThis.__codexActivePreRunSnapshot=__codexBridgePreRunSnapshot"));
assert.ok(bridge.includes("normal visible bridge completion removes pre-run snapshot"));
assert.ok(bridge.includes("globalThis.__codexActivePreRunSnapshot=null"));
assert.ok(bridge.includes("try{await qF()}"));
assert.ok(bundle.includes("codex patch rc.7.10.42: post-run refresh drains before release"));
assert.ok(!bundle.includes("try{qF()}catch("));
assert.ok(!bundle.includes("else qF()}catch"));
assert.ok(bundle.includes("cancelled Agent preserves Stop-owned snapshot"));
assert.ok(bundle.includes("__codexBridgePreRunSnapshot.stopOwned"));
assert.ok(human.includes("shouldCleanupAfterFailure(__codexHumanFilePreRunSnapshot)"));
assert.ok(bundle.includes("Stop-owned human snapshot survives cancellation race"));

assert.ok(bundle.includes("preRunSnapshot:globalThis.__codexStopCheckpointRef.publicSummary("));
assert.ok(soft.includes("globalThis.__codexStopCheckpointRef.isSnapshotReady(__snapshot)"));
assert.ok(bundle.includes("Stop resolves the active Agent snapshot"));
assert.ok(bundle.includes("Stop owns Agent snapshot cleanup"));
assert.ok(bundle.includes('o&&o._cancelled&&e!=="task_done"'));

const stopAt = bundle.indexOf("async function yM()");
const stop = bundle.slice(stopAt, stopAt + 1800);
assert.ok(stop.includes('__codexSoftStop("terminal Stop button")'));
assert.ok(!stop.includes('__codexForceReset("terminal Stop button")'));
assert.ok(bundle.includes("codex patch rc.7.37: degraded Stop recovery blocks shared continuity"));
assert.ok(soft.includes("__softStopRecoveryClass"));
assert.ok(soft.includes("globalThis.__codexContinuityLost={at:new Date().toISOString(),runId:__runId"));
assert.ok(soft.includes('recoveryClass:"RECOVERY_FAILED"'));
assert.ok(stop.includes('g&&g.recoveryClass==="RECOVERED_DEGRADED"'));
assert.ok(stop.includes("shared-session continuity is blocked"));
assert.ok(!stop.includes("restored the pre-run dataset when available"));

// codex patch rc.7.35c（缺陷 PF-5）：成功的 soft-stop 不得被判 graph readiness stale。
// 被取消的运行永不产生图批次，graph.lastRunId 追不上 readinessRunId，
// runMismatch 永久成立 → 停成功了却 trueReady=false、端点 500、桥留在 stale。
assert.ok(bundle.includes("codex patch rc.7.35c: successful soft-stop is not graph-readiness stale"));
assert.ok(bundle.includes("const benignSoftStopMismatch = runMismatch && readiness === \"ready\""));
assert.ok(bundle.includes("const benignMismatch = benignNoGraphMismatch || benignSoftStopMismatch;"));
// 逃生口必须证据绑定：同一 run + 那次 stop 真的成功。少任一条就变成「万能放行」。
assert.ok(bundle.includes('graph.readinessReason === "soft-stop-complete"'),
  "benign soft-stop escape must be attributable to a soft-stop transition");
assert.ok(bundle.includes("__codexStopReceipt.ok === true"),
  "benign soft-stop escape must require a genuinely successful stop (fail-closed)");
assert.ok(bundle.includes('String(__codexStopReceipt.runId || "") === String(readinessRunId)'),
  "benign soft-stop escape must bind to the same runId");
// 反向闸门：判死分支与 status 分支必须用同一个 benignMismatch，否则会出现
// 「放行了 ready 但 status 还写 stale」的自相矛盾态。
assert.ok(bundle.includes('const status = readiness === "stale" || (runMismatch && !benignMismatch) ? "stale"'),
  "status branch must honor the same benignMismatch as the readiness gate");
assert.ok(!bundle.includes('const status = readiness === "stale" || runMismatch ? "stale"'),
  "old status branch (ignoring benignMismatch) must be gone");

console.log("SOFT_STOP_SESSION_RC7_PASS");
