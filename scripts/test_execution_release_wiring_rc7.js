#!/usr/bin/env node
"use strict";

const assert = require("assert");
const fs = require("fs");
const path = require("path");

const extension = fs.readFileSync(path.join(__dirname, "..", "dist", "extension.js"), "utf8");
const darwinAdapter = fs.readFileSync(
  path.join(__dirname, "darwin_compat_adapter.js"), "utf8"
);
const terminalUiAdapter = fs.readFileSync(
  path.join(__dirname, "terminal_ui_command.js"), "utf8"
);

assert.ok(
  extension.includes("codex patch rc.7: graph marker is progress only"),
  "graph markers must be recorded only as routing progress"
);
assert.strictEqual(
  extension.includes("if (options?.acceptGraphCompletionMarkerAsDone !== false) state.sawEndOfDoFile = true"),
  false,
  "graph markers must not set sawEndOfDoFile"
);
assert.ok(
  extension.includes("if (false && !state.sawLog") &&
    extension.includes("codex patch rc.7: graph marker cannot pre-log release"),
  "graph-only pre-log success release must stay disabled"
);
assert.ok(
  extension.includes("if (false && elapsedMs >= hardStallAfterMs") &&
    extension.includes("codex patch rc.7: graph marker cannot hard-stall release"),
  "graph-only hard-stall success release must stay disabled"
);
assert.ok(
  extension.includes("acceptGraphCompletionMarkerAsDone:false/* codex patch rc.7: manual selection rejects graph-only completion */"),
  "Manual Selection must reject graph-only completion"
);
assert.ok(
  extension.includes("acceptGraphCompletionMarkerAsDone:false/* codex patch rc.7: human file rejects graph-only completion */"),
  "Manual Run File must reject graph-only completion"
);
assert.ok(
  extension.includes("codex patch rc.7.6: watchdog log ownership is run-scoped") &&
    extension.includes("birthtimeMs") &&
    !extension.includes("if (st.mtimeMs + 5000 < state.startedAt) continue;"),
  "watchdog discovery must not claim a pre-existing log merely because it was updated late"
);
assert.ok(
  extension.includes("codex patch rc.7.6: stale end-of-do-file cannot release current run") &&
    extension.includes("perRunCompletionMarkerVerified===true") &&
    !extension.includes("if (state.sawEndOfDoFile && !state.sawError && idleMs >= completionIdleMs)"),
  "watchdog completion must require the exact marker in the current per-run log"
);
assert.ok(
  extension.includes("codex patch rc.7: release discovers final run log"),
  "release must attach the exact current-run Stata log before lifecycle completion"
);
assert.ok(
  extension.includes("codex patch rc.7.5: exact-marker log overrides stale log") &&
    !extension.includes("if(!__logPath)try{let __found=__codexExecution.findRunLog") &&
    extension.includes("recordLogPath(s,__logPath,Date.now(),__life.runId)"),
  "an existing stale log path must be replaced by the log containing the current exact marker"
);
assert.ok(
  extension.includes("codex patch rc.7: human file exact completion marker"),
  "Manual Run File must append an exact current-run marker to its Workbench transport"
);
assert.ok(
  extension.includes("exact marker is added only to Workbench transport"),
  "non-prepared Manual Run File execution must add the marker in memory"
);
assert.ok(
  extension.includes("codex patch rc.7: graph inventory probes are quiet"),
  "internal graph inventory probes must not leak stale Graph-window errors"
);
assert.ok(
  extension.includes("codex patch rc.7: Terminal input owns shared lifecycle"),
  "Terminal input must acquire the same lifecycle as Manual and Agent execution"
);
assert.ok(
  extension.includes("codex patch rc.7: Terminal input exact completion marker"),
  "Terminal input must append an exact current-run Stata completion marker"
);
assert.ok(
  extension.includes("codex patch rc.7.7: Agent bridge exact completion marker") &&
    extension.includes("___CODEX_RUN_DONE_\"+String(__run)+\"___"),
  "Agent bridge execution must append the same exact Terminal run marker as Manual execution"
);
assert.ok(
  extension.includes("codex patch rc.7.10.21: transport success waits for exact marker") &&
    extension.includes("transportSettlementDecision(__codexBaseResult || {}, __life)") &&
    extension.includes("if (__codexResolveBaseResultIfReady()) return"),
  "successful background transport settlement must remain single-flight until exact completion"
);
assert.ok(
  extension.includes("codex patch rc.7.10.22: authoritative session log marker fallback") &&
    extension.includes("includeSessionLogs: true") &&
    extension.includes('state.lastEvidenceType = "authoritative-session-log-marker"') &&
    extension.includes("recordSessionCompletionMarker") &&
    extension.includes("recordPerRunCompletionMarker") &&
    extension.includes('logKind === "per-run"'),
  "session and per-run marker evidence must remain distinct"
);
assert.ok(
  extension.includes("codex patch rc.7.10.23: authoritative exact marker releases unsettled transport") &&
    extension.includes("if (!globalThis.__codexExecutionAdapter.ensureLifecycle") &&
    !extension.includes("if (__codexBaseSettled && !globalThis.__codexExecutionAdapter.ensureLifecycle"),
  "an exact current-run session marker must be discoverable while the transport callback is stalled"
);
assert.ok(
  extension.includes("codex patch rc.7.10.24: exact marker settles missing task_done") &&
    extension.includes("settleRunFromExactMarker(runId") &&
    extension.includes("if (__codexBaseSettled && globalThis.__codexExecutionAdapter.ensureLifecycle") &&
    extension.includes("lastExactMarkerTransportSettlement:globalThis.__codexLastExactMarkerTransportSettlement||null"),
  "exact marker evidence must settle the matching transport before the completed-log watchdog exposes READY"
);
assert.ok(
  extension.includes("codex patch rc.7.25: per-run log completion is fail-closed") &&
    extension.includes('code: "PER_RUN_LOG_INCOMPLETE"') &&
    extension.includes("rc: 11003") &&
    extension.includes("graceMs: 10000") &&
    extension.includes("completionMarkerVerified: false"),
  "a session-only marker must fail closed after bounded per-run convergence"
);
assert.ok(
  extension.includes("ingestLogText(text, true, false)") &&
    extension.includes("ingestLogText(snap.text, grew, true)") &&
    !extension.includes("if (__codexBaseResult.completionMarkerVerified === true)"),
  "callbacks and upstream result booleans must not masquerade as per-run disk evidence"
);
assert.ok(
  extension.includes("codex patch rc.7: Terminal input verified lifecycle release"),
  "Terminal input must release only after its result and exact log evidence are bound"
);
assert.ok(
  extension.includes("codex patch rc.7.10.10: Terminal browse opens Data Browser") &&
    extension.includes("terminal_ui_command.js") &&
    extension.includes('executeCommand("stata-workbench.viewData")') &&
    terminalUiAdapter.includes("classifyTerminalUiCommand"),
  "bare Terminal browse/edit commands must use the visible Data Browser after lifecycle release"
);
assert.ok(
  extension.includes("codex patch rc.7.10.11: Data Browser channel recovery") &&
    extension.includes("await g.currentPanel._fetchCredentials()") &&
    extension.includes("this._credentialRecoveryAttempts<2"),
  "reused Data Browser panels must reacquire their UI channel and retry boundedly"
);
assert.ok(
  extension.includes("codex patch rc.7.10.12: exact Data Browser readiness") &&
    extension.includes("__dbStatus.lastArrowBytes!==null&&__dbStatus.lastArrowBytes!==undefined"),
  "Data Browser completion must wait for non-null Arrow evidence"
);
assert.ok(
  extension.includes("codex patch rc.7.10.13: fresh Data Browser command completion") &&
    extension.includes("return await GD.createOrShow(Qn)") &&
    extension.includes("Number(__dbStatus.credentialRefreshes||0)>__dbRefreshBefore"),
  "Terminal browse must bind completion to a fresh Data Browser credential generation"
);
assert.ok(
  extension.includes("codex patch rc.7: shared source compatibility adapter"),
  "all visible execution paths must share the Darwin source compatibility adapter"
);
for (const marker of [
  "shared compatibility: agent",
  "shared compatibility: manual selection",
  "shared compatibility: manual file",
  "shared compatibility: terminal input",
]) {
  assert.ok(extension.includes(marker), `missing source compatibility wiring: ${marker}`);
}
assert.ok(
  extension.includes("codex patch rc.7.1: Terminal graph prep keeps source compatibility"),
  "Terminal graph instrumentation must not discard compatibility-protected code"
);
assert.ok(
  extension.includes("codex patch rc.7.2: shared Darwin graph/document compatibility"),
  "all visible execution paths must share the Darwin graph and document transform"
);
assert.ok(
  extension.includes("codex patch rc.7.3: referenced do-files use Darwin compatibility") &&
    extension.includes("darwin_compat_adapter.js"),
  "referenced temporary do-files must use the same Darwin compatibility adapter"
);
assert.ok(
  extension.includes("codex patch rc.7.4: lifecycle callbacks are run-scoped") &&
    extension.includes("recordPerRunCompletionMarker(globalThis.__codexBridgeState||{},Date.now(),runId)") &&
    extension.includes("recordLogPath(globalThis.__codexBridgeState||{},B.logPath,Date.now(),A?.runId)"),
  "late Manual/Agent/Terminal callbacks must not mutate a newer run"
);
assert.ok(
  extension.includes("darwin_compat_adapter.js") &&
    darwinAdapter.includes("docx_image_inject.py") &&
    extension.includes("darwinCompatibility:"),
  "status and shared adapter must expose the external DOCX image injection path"
);
assert.ok(
  extension.includes('__codexPrepareGraphRunCode(__codexTerminalCode,A.runId,"terminal-input"'),
  "Terminal graph preparation must consume the shared adapter output"
);
assert.ok(
  extension.includes("codex patch rc.7.8: manual command diagnostics") &&
    extension.includes("manualCommand:globalThis.__codexManualCommandDebug||null") &&
    extension.includes('command:"runSelection",stage:"entered"') &&
    extension.includes('stage:"acquired"'),
  "Manual command entry and acquire stages must remain observable in /status"
);

console.log("EXECUTION_RELEASE_WIRING_RC7_PASS");
