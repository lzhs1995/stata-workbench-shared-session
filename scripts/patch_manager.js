#!/usr/bin/env node
/**
 * Stata Workbench shared-session patch manager.
 *
 * This manager treats the current, verified extension.js as a full patch set:
 *   - visible HTTP bridge on 127.0.0.1:17485
 *   - mcp-stata pinned to 1.26.1 with no --refresh/@latest
 *   - get_variable_list output noise filtered
 *   - terminal variable provider disabled
 *   - DataBrowser automatic refresh disabled
 *   - optional temp do-file selection patch for Stata /// continuation
 *   - Stata Terminal display-only clear before visible runs
 *   - Clear button no longer runs Stata "clear all"
 *   - visible bridge single-flight lock with GET /status and busy 409
 *   - force reset Stop button and HTTP /force-reset recovery path
 *   - V6 cleanup of orphan tmonk/mcp-stata helper processes
 *   - V7 separate Stata Graphs panel routing with Clear All
 *   - V7.1 graph panel feedback ACK layer with /graph-status
 *   - V8 bridge BUSY/IDLE status bar updater
 *   - V9 postRunBusy flag: IDLE = bridge free + no post-run cleanup + bridge healthy
 *
 * Commands:
 *   node patch_manager.js status
 *   node patch_manager.js verify
 *   node patch_manager.js apply
 *   node patch_manager.js revert
 */

const fs = require("fs");
const path = require("path");
const os = require("os");
const http = require("http");
const crypto = require("crypto");
const { execFileSync } = require("child_process");

const WORKSPACE = process.env.STATA_WORKBENCH_WORKSPACE || path.resolve(__dirname, "..");
const EXT_ROOT = path.join(os.homedir(), ".vscode", "extensions");
const EXTENSION_ID_PREFIX = "tmonk.stata-workbench-";
const MANIFEST = path.join(WORKSPACE, "stata_workbench_patch_manifest.json");
const PATCHED_BASELINE = path.join(WORKSPACE, "dist", "extension.js");
const BRIDGE_URL = { host: "127.0.0.1", port: 17485, path: "/status" };
const GRAPH_STATUS_URL = { host: "127.0.0.1", port: 17485, path: "/graph-status" };

const REQUIRED_MARKERS = [
  {
    key: "visibleBridge",
    label: "visible HTTP bridge",
    marker: "Codex visible bridge",
  },
  {
    key: "mcpPinned",
    label: "mcp-stata pinned to 1.26.1",
    marker: "mcp-stata==1.26.1",
  },
  {
    key: "variableProviderDisabled",
    label: "terminal variable provider disabled",
    marker: "lM=async()=>[]",
  },
  {
    key: "dataBrowserRefreshDisabled",
    label: "DataBrowser auto refresh disabled",
    marker: "disable automatic DataBrowser refresh",
  },
  {
    key: "getVariableListLogFiltered",
    label: "get_variable_list logs filtered",
    marker: 'o.includes("get_variable_list")?void 0',
  },
  {
    key: "displayOnlyClearBeforeRun",
    label: "display-only clear before visible runs",
    marker: "codex patch v3: display-only clear before visible run",
  },
  {
    key: "displayOnlyClearBeforeBridgeRun",
    label: "display-only clear before visible bridge runs",
    marker: "codex patch v4: display-only clear before visible bridge run",
  },
  {
    key: "clearButtonDisplayOnly",
    label: "Clear button is display-only",
    marker: "codex patch v3: Clear button is display-only; no Stata clear all",
  },
  {
    key: "visibleBridgePatchMarker",
    label: "visible bridge returns V6 cleanup marker",
    marker: "codex-display-only-clear-v6-cleanup",
  },
  {
    key: "singleFlightState",
    label: "single-flight state",
    marker: "codex patch v4: single-flight state",
  },
  {
    key: "statusEndpoint",
    label: "GET /status endpoint",
    marker: "codex patch v4: status endpoint",
  },
  {
    key: "busy409",
    label: "busy requests return HTTP 409",
    marker: "codex patch v4: busy 409",
  },
  {
    key: "forceResetStateCleanup",
    label: "force reset cleans bridge state",
    marker: "codex patch v5: force reset state cleanup",
  },
  {
    key: "forceResetEndpoint",
    label: "HTTP /force-reset endpoint",
    marker: "codex patch v5: force reset endpoint",
  },
  {
    key: "forceResetV6Cleanup",
    label: "force reset cleans orphan mcp-stata helpers",
    marker: "codex patch v6: cleanup orphan mcp-stata processes",
  },
  {
    key: "separateGraphViewerPanel",
    label: "separate Stata Graphs panel routing",
    marker: "codex patch v7: separate graph viewer panel",
  },
  {
    key: "graphPanelFeedbackAckLayer",
    label: "graph panel feedback ack layer",
    marker: "codex patch v7.1: graph panel feedback ack layer",
  },
  {
    key: "graphPanelIncludedInStatus",
    label: "graph panel diagnostics included in /status",
    marker: 'graphPanel:globalThis.__codexGraphPanelStatus?globalThis.__codexGraphPanelStatus():null',
  },
  {
    key: "graphStatusEndpoint",
    label: "GET /graph-status endpoint",
    marker: "codex patch v7.1: graph status endpoint",
  },
  {
    key: "graphClearFunction",
    label: "graph panel clear diagnostics function",
    marker: "globalThis.__codexClearGraphPanel = __codexClearGraphPanel",
  },
  {
    key: "graphClearEndpoint",
    label: "POST /graph-clear endpoint",
    marker: "codex patch v7.2: graph clear endpoint",
  },
  {
    key: "graphClearReleasesPostRunBusy",
    label: "graph clear releases stale postRunBusy",
    marker: '__codexSetPostRunBusy&&globalThis.__codexSetPostRunBusy(false,"graph-clear-complete",null)',
  },
  {
    key: "graphViewerPanelId",
    label: "dedicated graph webview panel",
    marker: "codexStataGraphs",
  },
  {
    key: "manualRunFinishedRouting",
    label: "manual runFinished image artifact routing",
    marker: "manual runFinished artifact routing failed",
  },
  {
    key: "safeGraphRouteScheduler",
    label: "safe graph route scheduler",
    marker: "globalThis.__codexRouteArtifactSafe = __codexRouteArtifactSafe",
  },
  {
    key: "manualPostRunGraphExport",
    label: "manual post-run graph export",
    marker: "globalThis.__codexExportCurrentGraphsForPanel = __codexExportCurrentGraphsForPanel",
  },
  {
    key: "inlineGraphSnapshotFastPath",
    label: "scoped manual-selection inline graph snapshot helper",
    marker: "codex patch v7.7: inline graph snapshot manifest fast path",
  },
  {
    key: "nativeFirstNoSourceRewriteGraphCapture",
    label: "native-first graph capture does not rewrite Stata source",
    marker: "codex patch v7.11: native-first no source rewrite graph capture",
  },
  {
    key: "sourceRewriteDisabledDiagnostic",
    label: "graph status reports source rewriting policy",
    marker: "sourceRewriteDisabled: true",
  },
  {
    key: "scopedManualSelectionSnapshot",
    label: "scoped manual-selection inline snapshot fast path",
    marker: "codex patch v7.12: scoped manual-selection inline snapshot fast path",
  },
  {
    key: "graphIncludeGate",
    label: "graph scanning is gated by Stata code content",
    marker: "globalThis.__codexShouldIncludeGraphs = __codexShouldIncludeGraphs",
  },
  {
    key: "doFileGraphScan",
    label: "visible bridge scans do-file content before graph inventory",
    marker: "__codexGraphScanTextForCode",
  },
  {
    key: "graphInventoryTimeout",
    label: "graph inventory timeout cannot block execution",
    marker: "graph inventory timeout cannot block execution",
  },
  {
    key: "visibleBridgeIncludeGate",
    label: "visible bridge disables duplicate mcp graph_ready scans",
    marker: "normalizeResult:!0,includeGraphs:!1,cwd:__cwd",
  },
  {
    key: "manualSelectionIncludeGate",
    label: "manual selection disables duplicate mcp graph_ready scans",
    marker: "normalizeResult:!0,includeGraphs:!1,cwd:B",
  },
  {
    key: "mcpRunSelectionGraphReadyPropagation",
    label: "runSelection passes emit_graph_ready to mcp-stata",
    marker: "emit_graph_ready:B===!0",
  },
  {
    key: "mcpRunFileGraphReadyPropagation",
    label: "runFile passes emit_graph_ready to mcp-stata",
    marker: "path:A,cwd:a,emit_graph_ready:B===!0",
  },
  {
    key: "graphRunCodePreparation",
    label: "graph run code preparation",
    marker: "globalThis.__codexPrepareGraphRunCode = __codexPrepareGraphRunCode",
  },
  {
    key: "manifestFirstGraphRouting",
    label: "manifest-first graph routing",
    marker: "globalThis.__codexRouteGraphManifestOrExport = __codexRouteGraphManifestOrExport",
  },
  {
    key: "graphRunLifecycle",
    label: "execution-scoped graph lifecycle",
    marker: "globalThis.__codexBeginGraphRun = __codexBeginGraphRun",
  },
  {
    key: "manualGraphRunBeginHook",
    label: "manual graph run begin hook",
    marker: "__codexPreparedGraphRun",
  },
  {
    key: "manualSelectionTempInstrumentation",
    label: "manual selection instrumentation before temp do-file write",
    marker: "codex patch v7.8: instrument manual selection before temp do-file write",
  },
  {
    key: "manualSelectionPreparedBody",
    label: "manual selection prepared body is written to temp do-file",
    marker: "__codexSelectionBody",
  },
  {
    key: "manualSelectionStaleWatchdog",
    label: "manual selected-code stale UI watchdog",
    marker: "globalThis.__codexCreateManualSelectionWatchdog = __codexCreateManualSelectionWatchdog",
  },
  {
    key: "watchdogDiskLogTail",
    label: "watchdog reads mcp log tail for DONE marker",
    marker: "readLogTail",
  },
  {
    key: "manualSelectionWatchdogGuard",
    label: "manual selected-code watchdog guards runSelection",
    marker: "__codexManualSelectionWatchdog.guard",
  },
  {
    key: "manualSelectionPreLogWatchdog",
    label: "manual selected-code pre-log zombie watchdog",
    marker: "manual pre-log zombie watchdog release",
  },
  {
    key: "manualSelectionManifestWatchdog",
    label: "manual selected-code passes manifest path to watchdog",
    marker: "manifestPath:__codexPreparedGraphRun&&__codexPreparedGraphRun.manifestPath",
  },
  {
    key: "manualSelectionCompletedLogRoutesManifest",
    label: "manual selected-code completed-log watchdog routes inline manifest",
    marker: "manual-selection completed-log routes inline manifest",
  },
  {
    key: "manifestWatchdogWaitsForDocuments",
    label: "inline manifest watchdog does not pre-release document-output runs",
    marker: "manifest watchdog waits for document output",
  },
  {
    key: "manualSelectionHardStallBound",
    label: "manual selected-code hard-stall watchdog is bounded",
    marker: "hardStallAfterMs:(__codexManualSelectionLongRun?14400000:120000)",
  },
  {
    key: "manualSelectionLongRunWatchdog",
    label: "MI/document/large manual selections use long-run watchdog",
    marker: "codex patch v7.40: MI/document/large manual selections use long-run watchdog",
  },
  {
    key: "manualSelectionGraphCompletionMarker",
    label: "manual-selection watchdog accepts graph completion marker",
    marker: "codex patch v7.40: manual-selection watchdog accepts graph completion marker",
  },
  {
    key: "humanFileDocumentHardStallBound",
    label: "human-file document-output hard-stall watchdog is bounded",
    marker: "v7.24m: human-file document-output hard-stall bounded to 120s",
  },
  {
    key: "humanFilePreLogZombieBound",
    label: "human-file pre-log zombie watchdog is bounded",
    marker: "codex patch v7.41: human-file pre-log zombie watchdog is bounded",
  },
  {
    key: "humanFileDocumentLogIdleBound",
    label: "human-file document-output log-idle hard-stall watchdog is bounded",
    marker: "codex patch v7.42: human-file document-output hard-stall bounded after live log idle",
  },
  {
    key: "humanFileInlineSnapshotOptOut",
    label: "temporary human-file runners can opt out of inline snapshots",
    marker: "codex patch v7.43: temp runners can opt out of human-file inline snapshots",
  },
  {
    key: "hugeMiHumanFileInlineOptOut",
    label: "huge MI/document Run File uses post-do export instead of inline snapshots",
    marker: "codex patch v7.52: huge MI/document Run File opts out of inline snapshots",
  },
  {
    key: "hugeMiHumanFileExtendedWatchdog",
    label: "huge MI/document Run File gets extended no-log watchdog",
    marker: "codex patch v7.53: huge MI/document Run File gets extended no-log watchdog",
  },
  {
    key: "longHumanProgressSentinel",
    label: "long human-file/selection progress sentinel uses five-minute health windows",
    marker: "codex patch v7.54: long human-file/selection progress sentinel uses five-minute health windows",
  },
  {
    key: "hugeMiSelectionBoilerplateOptOut",
    label: "huge MI/document manual selection suppresses inline helper boilerplate",
    marker: "codex patch v7.54: huge MI/document manual selection suppresses inline helper boilerplate",
  },
  {
    key: "smallDocumentSelectionInlineSnapshots",
    label: "small document manual selections keep inline snapshot graph parity",
    marker: "codex patch v7.60: small document selections keep inline snapshots; huge MI/large selections opt out",
  },
  {
    key: "hugeMiSelectionLogCloseGuard",
    label: "huge MI/document manual selection guards log close _all",
    marker: "codex patch v7.59: huge MI/document manual selection guards log close _all",
  },
  {
    key: "hugeMiRunFileNoPassiveWait",
    label: "huge MI/document Run File uses progress sentinel instead of passive no-log waiting",
    marker: "codex patch v7.54: huge MI/document Run File uses progress sentinel instead of passive no-log waiting",
  },
  {
    key: "longHumanNoGraphMarkerRelease",
    label: "long human-file/selection does not release on graph marker alone",
    marker: "codex patch v7.55: long human runs do not release on graph marker alone",
  },
  {
    key: "longHumanIgnoreCodexMarkerEcho",
    label: "long human-file/selection ignores CODEX marker echoes",
    marker: "codex patch v7.55b: long human runs ignore CODEX marker echoes",
  },
  {
    key: "noGraphHumanIgnoreGraphMarker",
    label: "no-graph human-file/selection ignores graph completion marker",
    marker: "codex patch v7.55c: no-graph human runs ignore graph completion marker",
  },
  {
    key: "longHumanStaleEvidenceWindows",
    label: "long human progress sentinel releases after stale-evidence windows",
    marker: "staleEvidenceWindows",
  },
  {
    key: "hugeMiRunFileSourceSelection",
    label: "huge MI/document Run File uses source-selection transport for visible progress",
    marker: "codex patch v7.56: huge MI/document Run File uses source-selection transport for visible progress",
  },
  {
    key: "hugeMiRunFileLogCloseGuard",
    label: "huge MI/document Run File guards log close _all to preserve Terminal progress",
    marker: "codex patch v7.56b: huge MI/document Run File guards log close _all to preserve Terminal progress",
  },
  {
    key: "hugeMiRunFileTempDoGuard",
    label: "huge MI/document Run File uses guarded temp do-file to preserve Stata continuations",
    marker: "codex patch v7.57: huge MI/document Run File uses guarded temp do-file to preserve Stata line continuations",
  },
  {
    key: "hugeMiRunFileCompletionGuard",
    label: "huge MI/document Run File temp do has terminal completion guard",
    marker: "codex patch v7.90: huge MI/document Run File appends and verifies terminal completion guard after temp do",
  },
  {
    key: "hugeMiRunFileTempDoRunFile",
    label: "huge MI/document Run File executes guarded temp do through runFile",
    marker: "codex patch v7.94: huge MI/document Run File executes guarded temp do via runFile",
  },
  {
    key: "hugeMiRunFileTempDoActivatesExports",
    label: "huge MI/document Run File temp do activates all named graph exports",
    marker: "codex patch v7.95: huge MI/document Run File temp do activates all named graph exports",
  },
  {
    key: "hugeMiRunFileSourceSelectionAfterTempDoStall",
    label: "huge MI/document Run File uses source-selection after temp-do graph stall",
    marker: "codex patch v7.96: huge MI/document Run File uses source-selection transport after temp-do graph stall",
  },
  {
    key: "progressSentinelExposesLogPath",
    label: "progress sentinel exposes discovered live logPath through bridge status",
    marker: "codex patch v7.58: progress sentinel exposes discovered logPath through bridge status",
  },
  {
    key: "manualSelectionHardStallReset",
    label: "manual selected-code hard-stall triggers reset",
    marker: "manual-selection-hard-stall-reset",
  },
  {
    key: "manualSelectionCompletionMarkerHardStallRelease",
    label: "manual selected-code hard-stall accepts current completion marker",
    marker: "codex patch v7.66: manual-selection hard-stall releases cleanly when current completion marker exists",
  },
  {
    key: "manualSelectionCompletionMarkerPreLogRelease",
    label: "manual selected-code pre-log watchdog accepts current completion marker",
    marker: "codex patch v7.67: manual-selection pre-log watchdog accepts current completion marker",
  },
  {
    key: "longGraphDocumentRunFileOptOut",
    label: "long graph/document Run File opts out of inline snapshots",
    marker: "codex patch v7.68: long graph/document Run File opts out of inline snapshots",
  },
  {
    key: "longGraphDocumentRunFileActivatesNamedExports",
    label: "long graph/document Run File activates named graph exports without inline snapshots",
    marker: "codex patch v7.69: long graph/document Run File activates all named graph exports while source rewrite stays disabled",
  },
  {
    key: "longGraphDocumentRunFileUsesActivatedTempCopy",
    label: "long graph/document Run File executes activated temp copy before post-run export",
    marker: "codex patch v7.70: long graph/document Run File executes activated temp copy before post-run export",
  },
  {
    key: "documentRunFileActivatesGraphExportName",
    label: "document Run File activates named graph exports whenever graph export name() is present",
    marker: "codex patch v7.97: document Run File activates named graph exports whenever graph export name() is present",
  },
  {
    key: "documentRunFileNamedExportBypassesNoGraphEarlyReturn",
    label: "document Run File named graph export bypasses no-graph early return",
    marker: "codex patch v7.98: document Run File named graph export bypasses no-graph early return",
  },
  {
    key: "runFileTrailingBlockCommentTrimKeepsBody",
    label: "Run File trailing block-comment trim keeps executable body",
    marker: "codex patch v7.99: Run File trailing block-comment trim keeps executable body",
  },
  {
    key: "humanFilePreAcquireInlineSnapshotSettle",
    label: "human Run File waits briefly after prior inline snapshot transport",
    marker: "codex patch v7.91: graph/document Run File pre-acquire waits briefly for prior inline snapshot transport to settle",
  },
  {
    key: "humanFileErrorReleasesPostRunBusy",
    label: "human Run File errors release postRunBusy",
    marker: "codex patch v7.91: human-file runSelection errors release postRunBusy",
  },
  {
    key: "smallDocumentRunFileUsesSelectionStyleSnapshots",
    label: "small document Run File uses selection-style named-loop snapshots",
    marker: "codex patch v7.93: small document Run File snapshots named loop graphs like manual selection",
  },
  {
    key: "smallDocumentRunFileSnapshotsNamedLoopGraphs",
    label: "small document Run File snapshots named loop graphs like manual selection",
    marker: "codex patch v7.93: small document Run File snapshots named loop graphs like manual selection",
  },
  {
    key: "inlineSnapshotReadinessRelease",
    label: "inline snapshot routing releases postRunBusy",
    marker: "inline-snapshot-route-complete",
  },
  {
    key: "trueReadyGate",
    label: "true READY gate includes graph readiness",
    marker: "codex patch v7.16: true READY gate includes graph readiness",
  },
  {
    key: "statusPayloadTrueReady",
    label: "/status exposes true READY result",
    marker: "trueReady:!!__codexReady.ready",
  },
  {
    key: "manualTrueReadyGuard",
    label: "manual selection refuses false READY",
    marker: "codex patch v7.16: manual true READY guard",
  },
  {
    key: "bridgeAcquireTrueReady",
    label: "bridge acquire checks true READY",
    marker: "codex patch v7.16: bridge acquire checks true READY",
  },
  {
    key: "bridgeAcquireRecoverySmoke",
    label: "bridge acquire permits recovery smoke after panic",
    marker: "v7.24n: bridge acquire permits recovery smoke after panic",
  },
  {
    key: "bridgeAcquireRecoverySmokeReason",
    label: "bridge recovery smoke acquire reads true READY reason",
    marker: "__codexAcquireStatus=s.busy",
  },
  {
    key: "statusBarTrueReady",
    label: "status bar uses true READY gate",
    marker: "codex patch v7.16: status bar uses true READY gate",
  },
  {
    key: "artifactRouteReadinessRunId",
    label: "artifact routing refreshes readiness runId",
    marker: 'readinessReason: String(source || "artifact-batch") + "-routed"',
  },
  {
    key: "noGraphFastPathReadinessRunId",
    label: "no-graph fast path refreshes readiness runId",
    marker: "no-graph fast path refreshes graph readiness for current run",
  },
  {
    key: "noGraphFastPathReadyMismatchTolerance",
    label: "no-graph terminal/debug runs tolerate graph readiness runId mismatch",
    marker: "no-graph terminal/debug runs do not fail true READY on graph run-id mismatch",
  },
  {
    key: "emptyExportRefreshesLastRunId",
    label: "empty graph export refreshes lastRunId",
    marker: "lastRunId: runId",
  },
  {
    key: "humanFileWatchdog",
    label: "human Run File has watchdog release",
    marker: "human-file completed-log watchdog preserves shared Stata memory",
  },
  {
    key: "humanFileCompletedLogPreservesMemory",
    label: "human Run File completed-log watchdog preserves Stata memory",
    marker: "completed-log watchdog preserved Stata session; no force-reset",
  },
  {
    key: "humanFileWatchdogGraphTimeout",
    label: "human Run File watchdog graph export is bounded",
    marker: '__codexHumanFileReason+"-graph-timeout"',
  },
  {
    key: "humanFilePostRunSettleReset",
    label: "human Run File keeps worker after normal completion",
    marker: "normal completion keeps worker alive",
  },
  {
    key: "humanFileReadyGuard",
    label: "human Run File relies on acquire true READY gate",
    marker: "acquire itself enforces true READY",
  },
  {
    key: "humanFilePreAcquireManualSelectionReset",
    label: "human Run File pre-acquire reset after prior manual-selection/no-graph",
    marker: "v7.24o-preacquire: human-file pre-acquire reset after prior manual-selection/no-graph fast path",
  },
  {
    key: "heavyDocumentGraphRunFileExtendedWatchdog",
    label: "heavy document graph Run File gets extended watchdog",
    marker: "v7.24p: heavy document graph Run File gets extended watchdog",
  },
  {
    key: "largeDocumentOutputRunFileExtendedWatchdog",
    label: "large document-output Run File extends watchdog by source size",
    marker: "v7.24q: large document-output Run File extends watchdog by source size",
  },
  {
    key: "humanFilePostDoGraphExport",
    label: "human Run File exports graphs inside same do execution",
    marker: "__codexPreparedHumanFileRun",
  },
  {
    key: "humanFilePostDoGraphExportMode",
    label: "human Run File graph export avoids source rewrite",
    marker: "human-file-post-do-export",
  },
  {
    key: "humanFileInlineSnapshotTempDo",
    label: "human Run File captures transient graphs with temp do inline snapshots",
    marker: "human-file-inline-snapshot",
  },
  {
    key: "humanFileDocumentInlineSnapshot",
    label: "human Run File document-output still captures transient graphs",
    marker: "human Run File document-output still captures inline snapshots",
  },
  {
    key: "humanFileInlineRetainedBeforeDocuments",
    label: "human Run File captures document graphs with loop-internal snapshots",
    marker: "codex patch v7.93: document Run File uses loop-internal snapshots for graph parity",
  },
  {
    key: "humanFilePreparedManifestRestored",
    label: "human Run File preserves prepared inline manifest through TerminalPanel dispatch",
    marker: "restore human-file prepared graph manifest after TerminalPanel dispatch",
  },
  {
    key: "debugRunFileEndpoint",
    label: "manual Run File diagnostic endpoint",
    marker: "activeBefore:__debugBefore",
  },
  {
    key: "debugRunFileHandlerExposed",
    label: "manual Run File handler exposed for diagnostics",
    marker: "__codexRunFileHandler=xHg",
  },
  {
    key: "humanFileLifecycleDebug",
    label: "human Run File lifecycle probes",
    marker: "__codexHumanFileDebug",
  },
  {
    key: "graphPanelTerminalColumn",
    label: "Stata Graphs follows Stata Terminal column",
    marker: "globalThis.__codexGraphTargetColumn = __codexGraphTargetColumn",
  },
  {
    key: "bridgeGraphRunBeginHook",
    label: "bridge graph run begin hook",
    marker: "__codexPreparedBridgeRun",
  },
  {
    key: "bridgeStaleWatchdogGuard",
    label: "visible bridge completed-log watchdog preserves shared memory",
    marker: "visible bridge completed-log watchdog preserves shared Stata memory",
  },
  {
    key: "bridgeCompletionSentinel",
    label: "completion marker helper available for watchdog diagnostics",
    marker: "___CODEX_RUN_DONE_",
  },
  {
    key: "visibleBridgeRefreshGuard",
    label: "visible bridge ignores post-run refresh errors",
    marker: "post-run refresh ignored after visible bridge run",
  },
  {
    key: "visibleBridgeErrorRelease",
    label: "visible bridge errors release postRunBusy",
    marker: "visible-bridge-error-release",
  },
  {
    key: "bridgePostRunGraphExportHook",
    label: "bridge post-run graph export hook",
    marker: "__codexBridgeGraphExportError",
  },
  {
    key: "bridgeWatchdogGraphExportBounded",
    label: "bridge watchdog release attempts bounded graph export",
    marker: "bridge watchdog release attempts bounded graph export",
  },
  {
    key: "visibleBridgeDocumentOutputNoInlineSnapshot",
    label: "visible bridge suppresses inline snapshot for document-output code",
    marker: "visible bridge suppresses inline snapshot for document-output code",
  },
  {
    key: "visibleBridgeDoFileDocumentOutputDetection",
    label: "visible bridge scans embedded do-file content for document-output suppression",
    marker: "codex patch v7.22a: visible bridge scans embedded do-file content for document-output suppression",
  },
  {
    key: "visibleBridgeDocumentOutputDetectsPtdocx",
    label: "visible bridge treats p_tdocx as document-output code",
    marker: "\\bp_tdocx\\b",
  },
  {
    key: "namedGraphExportActivation",
    label: "named graph export activates graph before export",
    marker: "codex patch v7.21: activate named graph before graph export",
  },
  {
    key: "selectiveNamedGraphExportActivation",
    label: "selective named graph activation skips immediately-created exports",
    marker: "codex patch v7.23: selective named graph activation skips immediately-created graph exports",
  },
  {
    key: "graphCombineExportActivation",
    label: "graph combine exports are activated even when immediately created",
    marker: "codex patch v7.61: graph combine exports are activated even when immediately created",
  },
  {
    key: "longDocumentSelectionCompletionWait",
    label: "long document manual selection waits for end-of-do-file before postprocessing",
    marker: "codex patch v7.62: long document manual selection waits for end-of-do-file before postprocessing",
  },
  {
    key: "longDocumentSelectionSkipsDatasetRefresh",
    label: "long document manual selection skips dataset refresh after completion",
    marker: "codex patch v7.62: long document manual selection skips dataset refresh after completion",
  },
  {
    key: "longDocumentSelectionActivatesAllNamedGraphExports",
    label: "long document manual selection activates all named graph exports",
    marker: "codex patch v7.63: long document manual selection activates all named graph exports",
  },
  {
    key: "hugeMiVisibleBridgeGuardedDoFile",
    label: "huge MI/document visible bridge do-files use guarded source-preserving temp copy",
    marker: "codex patch v7.64: huge MI/document visible bridge do-files use guarded source-preserving temp copy",
  },
  {
    key: "hugeMiVisibleBridgeGraphActivation",
    label: "huge MI/document visible bridge guarded temp copy activates all named graph exports",
    marker: "codex patch v7.65: huge MI/document visible bridge guarded temp copy activates all named graph exports",
  },
  {
    key: "documentDoFileSelectiveActivation",
    label: "document do-files use selective activation while suppressing inline snapshots",
    marker: "codex patch v7.23: document do-files use selective activation while suppressing inline snapshots",
  },
  {
    key: "visibleBridgeDoFileNoInlineSnapshot",
    label: "visible bridge direct do-files use delta graph routing, not inline snapshots",
    marker: "codex patch v7.23b: visible bridge direct do-files use delta graph routing, not inline snapshots",
  },
  {
    key: "namedGraphActivationIgnoresCrlfOnlyChanges",
    label: "named graph activation ignores CRLF-only differences",
    marker: "codex patch v7.30: named graph activation ignores CRLF-only differences",
  },
  {
    key: "singleDoFileNamedGraphExportActivation",
    label: "single do-file graph export uses activated temp copy",
    marker: "codex patch v7.21b: single do-file graph export uses activated temp copy",
  },
  {
    key: "inlineManifestGrowthCountsAsProgress",
    label: "inline manifest growth counts as watchdog progress",
    marker: "codex patch v7.21c: inline manifest growth counts as watchdog progress",
  },
  {
    key: "humanFilePreflightAfterNoGraphSelection",
    label: "human-file preflight after manual-selection/no-graph fast path",
    marker: "codex patch v7.24: human-file preflight after manual-selection/no-graph fast path",
  },
  {
    key: "humanFileSkipsSecondaryRunSelectionPreflight",
    label: "human-file skips secondary runSelection preflight after current-line",
    marker: "codex patch v7.25: human-file skips secondary runSelection preflight after current-line",
  },
  {
    key: "preAcquireUsesBoundedBarrier",
    label: "pre-acquire uses bounded barrier before dispatch",
    marker: "codex patch v7.25d: clear pre-acquire barrier immediately before selection acquire",
  },
  {
    key: "healthyNoGraphDoesNotForceHumanFilePreAcquire",
    label: "healthy no-graph fast path does not force human-file pre-acquire reset",
    marker: "codex patch v7.25b: healthy no-graph fast path does not force human-file pre-acquire reset",
  },
  {
    key: "preAcquireResetNoFalseReadySelection",
    label: "manual-selection pre-acquire reset cannot expose false READY",
    marker: "codex patch v7.25d: pre-acquire reset cannot expose false READY before selection dispatch",
  },
  {
    key: "preAcquireResetNoFalseReadyHumanFile",
    label: "human-file pre-acquire reset cannot expose false READY",
    marker: "codex patch v7.25d: pre-acquire reset cannot expose false READY before human-file dispatch",
  },
  {
    key: "preAcquireBarrierStatusGate",
    label: "true READY honors pre-acquire barrier without blocking acquire",
    marker: "codex patch v7.25d: /status trueReady honors pre-acquire barrier without blocking acquire",
  },
  {
    key: "runFileOverridePreventsStaleActiveEditor",
    label: "Run File path override prevents stale active-editor reuse",
    marker: "codex patch v7.25e: debug/manual Run File path override prevents stale active-editor reuse",
  },
  {
    key: "runFileActiveTabResync",
    label: "Run File resyncs stale activeTextEditor from active tab",
    marker: "codex patch v7.25g: Run Selection/File resync stale activeTextEditor from active tab",
  },
  {
    key: "debugActiveEditorEndpoint",
    label: "debug endpoint exposes active editor/tab state",
    marker: "codex patch v7.25h: debug active editor/tab state for stale Run File diagnosis",
  },
  {
    key: "graphDocumentRunFilePreAcquireReset",
    label: "graph/document Run File resets transport before acquire",
    marker: "codex patch v7.25i: graph/document Run File resets transport before acquire",
  },
  {
    key: "debugRunFilePinsRequestedPath",
    label: "debug-run-file pins requested path through Run File handler",
    marker: "codex patch v7.25e: debug-run-file pins requested path through Run File handler",
  },
  {
    key: "debugRunFileCanRevertFromDisk",
    label: "debug-run-file can discard dirty editor buffer before Run File",
    marker: "debug-run-file can refresh active buffer from disk",
  },
  {
    key: "documentOutputHumanFileLongHardStall",
    label: "all human-file document-output runs get long hard-stall watchdog",
    marker: "codex patch v7.25f: all human-file document-output runs get long hard-stall watchdog",
  },
  {
    key: "humanFileDebugStaleDetection",
    label: "debug-run-file reports human-file watchdog stale as failure",
    marker: "human-file watchdog reported stale state",
  },
  {
    key: "forceResetNeedsSmokeAfterPrelog",
    label: "force reset marks pre-log/hard-stall recovery as needs-smoke",
    marker: "force-reset-needs-smoke",
  },
  {
    key: "humanFileGraphDocumentPostRunRecycle",
    label: "human-file graph/document runs preserve memory after completion",
    marker: "human-file graph/document runs do not force-reset after completion",
  },
  {
    key: "humanFileHybridTransientRetainedGraphs",
    label: "human-file inline snapshots exclude retained graph sweep from live do",
    marker: "codex patch v7.29d: human-file inline snapshot excludes retained graph sweep from live do to preserve worker",
  },
  {
    key: "humanFileRetainedGraphsBeforeDocuments",
    label: "human Run File retained graph export occurs before document output",
    marker: "bodyLines.splice(docIndex, 0, retainedGraphExport)",
  },
  {
    key: "humanFileInlineSnapshotMoreOff",
    label: "human Run File inline snapshot temp do disables Stata pagination",
    marker: "set more off\\n\" + graphPrepared.code",
  },
  {
    key: "humanFileRecycleSettle",
    label: "human-file graph/document settles without clearing memory",
    marker: "human-file graph/document runs do not force-reset after completion",
  },
  {
    key: "humanFileInlineSnapshotGraphicsOff",
    label: "human Run File inline snapshot preserves native graphics state",
    marker: "human-file inline snapshots keep native graphics state to preserve live worker",
  },
  {
    key: "humanFileDocumentHardStallWindow",
    label: "human Run File document-output does not use an unbounded hard-stall window",
    marker: "v7.24m: human-file document-output hard-stall bounded to 120s",
  },
  {
    key: "humanFileDocumentOutputInlineSnapshot",
    label: "human Run File document-output keeps inline snapshot rewriting",
    marker: "human Run File document-output still captures inline snapshots",
  },
  {
    key: "humanFileInlineTempRunSelectionTransport",
    label: "human Run File uses runSelection transport with streaming callbacks",
    marker: "human Run File uses runSelection transport to preserve live Stata memory while streaming",
  },
  {
    key: "humanFileTrimTrailingNonExecutable",
    label: "human Run File temp copy trims trailing non-executable comments",
    marker: "__codexTrimTrailingRunFileNonExecutable",
  },
  {
    key: "humanFileFinalDatasetSnapshotRestore",
    label: "human Run File snapshots/restores inside-do final dataset around graph routing",
    marker: "human Run File restores inside-do dataset snapshot after graph routing to preserve shared memory",
  },
  {
    key: "humanFileTerminalPanelWatchdogNoPrelogReset",
    label: "human Run File TerminalPanel watchdog does not false pre-log reset",
    marker: "TerminalPanel Run File watchdog must not pre-log reset while kM owns live Stata memory",
  },
  {
    key: "humanFilePostRecycleReadyReason",
    label: "successful human-file settle has memory-preserving READY reason",
    marker: "human-file-post-run-settle-preserve-session-complete",
  },
  {
    key: "humanFileGraphDocDefersDatasetRefresh",
    label: "human Run File graph/document completion defers dataset summary refresh to preserve live memory",
    marker: "human-file graph/document completion defers dataset summary refresh to preserve live Stata memory",
  },
  {
    key: "humanFileManifestNoPreRelease",
    label: "human Run File manifest progress does not pre-release full file",
    marker: "codex patch v7.24h: human-file manifest progress must not pre-release Run File",
  },
  {
    key: "humanFileExplicitGraphExportKeepsGraphicsOn",
    label: "human Run File inline snapshots never toggle native graphics state",
    marker: "codex patch v7.29: human-file inline snapshots keep native graphics state to preserve live worker",
  },
  {
    key: "humanFilePreflightAfterInlineSnapshot",
    label: "human Run File pre-acquire resets after prior inline-snapshot graph batch",
    marker: "codex patch v7.24k-preacquire: human-file pre-acquire reset after prior inline-snapshot graph batch",
  },
  {
    key: "manualSelectionPreflightAfterInlineSnapshot",
    label: "manual selection pre-acquire resets after prior inline-snapshot graph batch",
    marker: "codex patch v7.24r-preacquire: manual-selection pre-acquire reset after prior inline-snapshot graph batch",
  },
  {
    key: "runningForceResetPanicEscalation",
    label: "running force-reset escalates to panic-kill before READY",
    marker: "codex patch v7.24l: running force-reset escalates to panic-kill before READY",
  },
  {
    key: "graphBeginFailureReleasesReady",
    label: "graph run begin failure releases postRunBusy",
    marker: "graph-run-begin-error",
  },
  {
    key: "manualSelectionExportHook",
    label: "manual selection manifest-first graph export hook",
    marker: "__codexRouteGraphManifestOrExport(e,B)",
  },
  {
    key: "batchedGraphUpdates",
    label: "batched graph updates",
    marker: "codex patch v7.3: batched graph updates",
  },
  {
    key: "postRunBusyFlag",
    label: "postRunBusy flag in bridge state",
    marker: "postRunBusy:false",
  },
  {
    key: "acquireChecksPostRunBusy",
    label: "acquire checks postRunBusy/trueReady before granting lock",
    marker: "codex patch v7.16: bridge acquire checks true READY",
  },
  {
    key: "forceResetSetsPostRunBusy",
    label: "forceReset sets postRunBusy during async cleanup",
    marker: "s.postRunBusy=true",
  },
  {
    key: "forceResetClearsPostRunBusy",
    label: "forceReset clears postRunBusy and readiness after cleanup completes",
    marker: "force-reset-complete",
  },
  {
    key: "graphMarkGlobalExport",
    label: "graph readiness marker is globally callable",
    marker: "globalThis.__codexGraphMark = __codexGraphMark",
  },
  {
    key: "statusBarChecksPostRunBusy",
    label: "status bar IDLE requires both busy and postRunBusy false",
    marker: "if(s.busy||s.postRunBusy)",
  },
  {
    key: "statusExposesPostRunBusy",
    label: "/status exposes postRunBusy to agents",
    marker: "postRunBusy:!!o.postRunBusy",
  },
  {
    key: "watchdogNoForceReset",
    label: "visible bridge completed-log watchdog preserves shared memory",
    marker: "visible bridge completed-log watchdog preserves shared Stata memory",
  },
  {
    key: "manualSelectionWatchdogPreservesMemory",
    label: "manual selection completed-log watchdog preserves shared memory",
    marker: "manual selection completed-log watchdog preserves shared Stata memory",
  },
  {
    key: "humanFilePostRunPreservesMemory",
    label: "human-file graph/document completion preserves shared memory",
    marker: "human-file graph/document completion preserves shared Stata memory",
  },
  {
    key: "humanFilePreAcquirePreservesMemory",
    label: "human-file graph/document pre-acquire preserves shared memory",
    marker: "graph/document pre-acquire preserves shared Stata memory",
  },
  {
    key: "panicKillEndpoint",
    label: "HTTP /panic-kill endpoint",
    marker: "codex patch v10: panic kill endpoint",
  },
  {
    key: "panicKillStatusButton",
    label: "status bar panic kill button",
    marker: "codex patch v10: panic kill status button",
  },
  {
    key: "panicKillCommand",
    label: "VS Code panic kill command",
    marker: 'registerCommand("stata-workbench.panicKill"',
  },
  {
    key: "panicKillAllStataDefault",
    label: "panic kill defaults to the full Stata execution chain",
    marker: "Kill all Stata processes",
  },
  {
    key: "panicKillTransportReset",
    label: "panic kill resets stale MCP transport before READY",
    marker: "panic-kill transport reset",
  },
  {
    key: "panicKillErrorCleanup",
    label: "panic kill cleans state but requires smoke after partial failure",
    marker: "panic-kill-error-needs-smoke",
  },
  {
    key: "panicKillRequiresSmoke",
    label: "panic kill leaves readiness stale until smoke test",
    marker: "panic-kill-command-needs-smoke",
  },
  {
    key: "debugTerminalInputEndpoint",
    label: "debug endpoint exercises TerminalPanel runCommand handler",
    marker: "terminal input diagnostic endpoint exercises runCommand handler",
  },
  {
    key: "debugRunSelectionEndpoint",
    label: "debug endpoint invokes real Run Selection/Current Line handler",
    marker: "debug current-line endpoint invokes real runSelection handler",
  },
  {
    key: "debugRunSelectionRangeEndpoint",
    label: "debug Run Selection endpoint supports range/all selection",
    marker: "codex patch v7.40: debug-run-selection supports range/all selection",
  },
  {
    key: "terminalInputStoppedSessionRetry",
    label: "terminal input recovers stopped default session once",
    marker: "terminal-input stopped-session auto-recovery",
  },
  {
    key: "terminalInputWorkerErrorRetry",
    label: "terminal input recovers worker error once",
    marker: "terminal-input worker-error auto-recovery",
  },
  {
    key: "terminalInputGraphRouting",
    label: "terminal input graph commands use graph lifecycle without clearing memory",
    marker: "terminal input graph routing uses graph lifecycle without clearing Stata memory",
  },
  {
    key: "terminalInputGraphRouteTimeout",
    label: "terminal input graph routing is bounded and releases postRunBusy",
    marker: "terminal-input-graph-route-timeout",
  },
  {
    key: "terminalInputRunSelectionTimeoutRecovery",
    label: "terminal input runSelection timeout is recovered after visible dispatch",
    marker: "runSelection timeout recovered after visible log dispatch",
  },
  {
    key: "terminalInputSkipsDatasetRefresh",
    label: "terminal input skips dataset refresh to preserve shared memory",
    marker: "terminal input skips dataset refresh to preserve shared memory",
  },
  {
    key: "graphPdfDownloadBaseDir",
    label: "graph PDF download preserves artifact baseDir",
    marker: "baseDir: activeModalArtifact.baseDir",
  },
];

const AUXILIARY_MARKERS = [
  {
    key: "autocompleteEmptyVarsNoRefreshLoop",
    label: "autocomplete empty-variable update does not requestVars loop",
    relativePath: path.join("src", "ui-shared", "autocomplete.js"),
    marker: "if (!vars.length) { close(); return; }",
  },
  {
    key: "dataBrowserStataMissingValue",
    label: "Data Browser renders Stata numeric missing values as dot",
    relativePath: path.join("src", "ui-shared", "data-browser.js"),
    marker: "STATA_MISSING_VALUE = 8.98846567431158e+307",
  },
  {
    key: "runtimeOwnerLoopRecorded",
    label: "mcp-stata records the MCP owner event loop",
    base: "workspace",
    relativePath: path.join("stata-mcp-py311", "Lib", "site-packages", "mcp_stata", "sessions.py"),
    marker: "self._loop: Optional[asyncio.AbstractEventLoop] = None",
  },
  {
    key: "runtimeRejectsListenerLoopTheft",
    label: "mcp-stata rejects non-owner listener loop theft",
    base: "workspace",
    relativePath: path.join("stata-mcp-py311", "Lib", "site-packages", "mcp_stata", "sessions.py"),
    marker: "dispatch must be marshalled to the MCP owner loop",
  },
  {
    key: "runtimeMissingWorkerConnIsStopped",
    label: "missing worker connection is treated as stopped before dispatch",
    base: "workspace",
    relativePath: path.join("stata-mcp-py311", "Lib", "site-packages", "mcp_stata", "sessions.py"),
    marker: "worker connection is unavailable",
  },
  {
    key: "runtimeStartupRemovalIsStopped",
    label: "startup race removal is treated as stopped before dispatch",
    base: "workspace",
    relativePath: path.join("stata-mcp-py311", "Lib", "site-packages", "mcp_stata", "sessions.py"),
    marker: "session was removed during startup",
  },
  {
    key: "runtimeRecoverStoppedLiveListener",
    label: "mcp-stata recovers stopped listener without replacing live worker",
    base: "workspace",
    relativePath: path.join("stata-mcp-py311", "Lib", "site-packages", "mcp_stata", "sessions.py"),
    marker: "Recovering stopped listener for live Stata session",
  },
  {
    key: "runtimeMarshalsUiCalls",
    label: "UI/DataBrowser calls marshal to the MCP owner loop",
    base: "workspace",
    relativePath: path.join("stata-mcp-py311", "Lib", "site-packages", "mcp_stata", "server.py"),
    marker: "UI/DataBrowser HTTP threads must not",
  },
  {
    key: "runtimeUsesRunCoroutineThreadsafe",
    label: "cross-thread runtime calls use run_coroutine_threadsafe",
    base: "workspace",
    relativePath: path.join("stata-mcp-py311", "Lib", "site-packages", "mcp_stata", "server.py"),
    marker: "asyncio.run_coroutine_threadsafe(",
  },
];

const OPTIONAL_MARKERS = [
  {
    key: "tempDoSelectionPatch",
    label: "temp do-file selection patch",
    marker: "codex patch v2: temp do-file so Stata handles /// continuation natively",
  },
];

const FORBIDDEN_MARKERS = [
  { key: "noRefreshFlag", label: "no --refresh flag", marker: "--refresh" },
  { key: "noRefreshPackage", label: "no refresh-package flag", marker: "refresh-package" },
  { key: "noLatestSpec", label: "no mcp-stata@latest", marker: "mcp-stata@latest" },
];

function findExtension() {
  if (!fs.existsSync(EXT_ROOT)) {
    fail(`VS Code extension root not found: ${EXT_ROOT}`);
  }
  const candidates = fs.readdirSync(EXT_ROOT)
    .filter((name) => name.startsWith(EXTENSION_ID_PREFIX))
    .map((name) => {
      const full = path.join(EXT_ROOT, name);
      const js = path.join(full, "dist", "extension.js");
      const pkg = path.join(full, "package.json");
      let version = name.slice(EXTENSION_ID_PREFIX.length);
      try {
        version = JSON.parse(fs.readFileSync(pkg, "utf8")).version || version;
      } catch {}
      let mtime = 0;
      try {
        mtime = fs.statSync(js).mtimeMs;
      } catch {}
      return { name, full, js, pkg, version, mtime };
    })
    .filter((entry) => fs.existsSync(entry.js))
    .sort((a, b) => b.mtime - a.mtime);
  if (!candidates.length) {
    fail("Stata Workbench extension.js not found under " + EXT_ROOT);
  }
  return candidates[0];
}

function sha256(textOrBuffer) {
  return crypto.createHash("sha256").update(textOrBuffer).digest("hex");
}

function readText(file) {
  return fs.readFileSync(file, "utf8");
}

function writeText(file, text) {
  fs.writeFileSync(file, text, "utf8");
}

function syntaxCheckFile(file) {
  const tmp = path.join(os.tmpdir(), `stata-workbench-check-${Date.now()}.js`);
  fs.copyFileSync(file, tmp);
  try {
    execFileSync("node", ["--check", tmp], { stdio: "pipe" });
    return { ok: true };
  } catch (err) {
    return {
      ok: false,
      error: (err.stderr && err.stderr.toString()) || err.message,
    };
  } finally {
    try { fs.unlinkSync(tmp); } catch {}
  }
}

function syntaxCheckText(text) {
  const tmp = path.join(os.tmpdir(), `stata-workbench-check-${Date.now()}.js`);
  writeText(tmp, text);
  try {
    execFileSync("node", ["--check", tmp], { stdio: "pipe" });
    return { ok: true };
  } catch (err) {
    return {
      ok: false,
      error: (err.stderr && err.stderr.toString()) || err.message,
    };
  } finally {
    try { fs.unlinkSync(tmp); } catch {}
  }
}

function inspectContent(content) {
  const required = {};
  const optional = {};
  const forbidden = {};
  for (const item of REQUIRED_MARKERS) {
    required[item.key] = content.includes(item.marker);
  }
  for (const item of OPTIONAL_MARKERS) {
    optional[item.key] = content.includes(item.marker);
  }
  for (const item of FORBIDDEN_MARKERS) {
    forbidden[item.key] = content.includes(item.marker);
  }
  const requiredOk = Object.values(required).every(Boolean);
  const forbiddenOk = Object.values(forbidden).every((present) => !present);
  return {
    required,
    optional,
    forbidden,
    requiredOk,
    forbiddenOk,
    fullyPatched: requiredOk && forbiddenOk,
  };
}

function inspectAuxiliary(extension) {
  const auxiliary = {};
  for (const item of AUXILIARY_MARKERS) {
    const file = path.join(item.base === "workspace" ? WORKSPACE : extension.full, item.relativePath);
    try {
      auxiliary[item.key] = fs.existsSync(file) && readText(file).includes(item.marker);
    } catch {
      auxiliary[item.key] = false;
    }
  }
  const auxiliaryOk = Object.values(auxiliary).every(Boolean);
  return { auxiliary, auxiliaryOk };
}

function loadManifest() {
  if (!fs.existsSync(MANIFEST)) return null;
  try {
    return JSON.parse(readText(MANIFEST));
  } catch {
    return null;
  }
}

function saveManifest(data) {
  fs.mkdirSync(path.dirname(MANIFEST), { recursive: true });
  writeText(MANIFEST, JSON.stringify(data, null, 2));
}

function ensureBaseline(extension) {
  if (fs.existsSync(PATCHED_BASELINE)) return;
  const current = readText(extension.js);
  const check = inspectContent(current);
  if (!check.fullyPatched) {
    fail([
      "No patched baseline exists and current extension is not fully patched.",
      "A safe apply cannot be synthesized from this bundle.",
      "Restore a known-good patched extension.js first, then run status again.",
    ].join("\n"));
  }
  const syntax = syntaxCheckText(current);
  if (!syntax.ok) fail("Current patched extension.js fails node --check:\n" + syntax.error);
  writeText(PATCHED_BASELINE, current);
  console.log(`[baseline] Saved current verified patched baseline: ${PATCHED_BASELINE}`);
}

function makeBackup(extension, reason) {
  const stamp = new Date().toISOString().replace(/[-:.TZ]/g, "").slice(0, 14);
  const dest = `${extension.js}.pm-backup-${stamp}-${reason}`;
  fs.copyFileSync(extension.js, dest);
  return dest;
}

function statusData() {
  const extension = findExtension();
  const content = readText(extension.js);
  const syntax = syntaxCheckFile(extension.js);
  const inspection = inspectContent(content);
  const auxiliaryInspection = inspectAuxiliary(extension);
  const manifest = loadManifest();
  return {
    extension,
    syntax,
    inspection,
    auxiliaryInspection,
    manifest,
    size: fs.statSync(extension.js).size,
    sha256: sha256(content),
    baselineExists: fs.existsSync(PATCHED_BASELINE),
  };
}

function printStatus() {
  const data = statusData();
  console.log("");
  console.log("=== Stata Workbench Shared Session Patch Manager ===");
  console.log(`Extension : ${data.extension.name} (v${data.extension.version})`);
  console.log(`File      : ${data.extension.js}`);
  console.log(`Size      : ${(data.size / 1024 / 1024).toFixed(2)} MB`);
  console.log(`SHA256    : ${data.sha256.slice(0, 16)}...`);
  console.log(`Baseline  : ${data.baselineExists ? PATCHED_BASELINE : "missing"}`);
  console.log(`Manifest  : ${data.manifest ? MANIFEST : "missing"}`);
  console.log(`Syntax    : ${data.syntax.ok ? "OK" : "FAIL"}`);
  if (!data.syntax.ok) console.log(indent(data.syntax.error));
  console.log("");
  console.log("Required patch checks:");
  for (const item of REQUIRED_MARKERS) {
    console.log(`  ${data.inspection.required[item.key] ? "OK  " : "MISS"} ${item.label}`);
  }
  console.log("");
  console.log("Forbidden drift checks:");
  for (const item of FORBIDDEN_MARKERS) {
    console.log(`  ${data.inspection.forbidden[item.key] ? "FAIL" : "OK  "} ${item.label}`);
  }
  console.log("");
  console.log("Auxiliary source checks:");
  for (const item of AUXILIARY_MARKERS) {
    console.log(`  ${data.auxiliaryInspection.auxiliary[item.key] ? "OK  " : "MISS"} ${item.label}`);
  }
  console.log("");
  console.log("Optional checks:");
  for (const item of OPTIONAL_MARKERS) {
    console.log(`  ${data.inspection.optional[item.key] ? "OK  " : "MISS"} ${item.label}`);
  }
  console.log("");
  console.log(`Overall   : ${data.syntax.ok && data.inspection.fullyPatched && data.auxiliaryInspection.auxiliaryOk ? "OK fully patched" : "NOT fully patched"}`);
  return data;
}

function httpGetJson(target) {
  return new Promise((resolve) => {
    let settled = false;
    const req = http.request(
      {
        host: target.host,
        port: target.port,
        path: target.path,
        method: "GET",
      },
      (res) => {
        let data = "";
        res.on("data", (chunk) => { data += chunk; });
        res.on("end", () => {
          if (settled) return;
          settled = true;
          let body = data;
          try { body = JSON.parse(data); } catch {}
          const ok = typeof res.statusCode === "number" ? res.statusCode >= 200 && res.statusCode < 300 : false;
          resolve({ online: ok, statusCode: res.statusCode, body });
        });
      },
    );
    req.on("error", (error) => {
      if (settled) return;
      settled = true;
      resolve({ online: false, error: error.message });
    });
    req.setTimeout(2500, () => {
      if (settled) return;
      settled = true;
      req.destroy();
      resolve({ online: false, error: "timeout" });
    });
    req.end();
  });
}

function checkBridgeOnline() {
  return httpGetJson(BRIDGE_URL);
}

function checkGraphStatusOnline() {
  return httpGetJson(GRAPH_STATUS_URL);
}

async function cmdVerify() {
  const data = printStatus();
  console.log("");
  process.stdout.write("Bridge    : checking http://127.0.0.1:17485/status ... ");
  const bridge = await checkBridgeOnline();
  if (bridge.online) {
    console.log("OK online");
    console.log(`Response  : ${JSON.stringify(bridge.body)}`);
  } else {
    console.log("OFFLINE");
    console.log(`Reason    : ${bridge.error || "unknown"}`);
  }
  process.stdout.write("Graphs    : checking http://127.0.0.1:17485/graph-status ... ");
  const graphStatus = await checkGraphStatusOnline();
  if (graphStatus.online) {
    console.log("OK online");
    console.log(`Response  : ${JSON.stringify(graphStatus.body)}`);
  } else {
    console.log("OFFLINE");
    console.log(`Reason    : ${graphStatus.error || "unknown"}`);
  }
  if (!data.syntax.ok || !data.inspection.fullyPatched || !data.auxiliaryInspection.auxiliaryOk || !bridge.online || !graphStatus.online) {
    process.exitCode = 1;
  }
}

function cmdApply() {
  const extension = findExtension();
  const current = readText(extension.js);
  const currentInspection = inspectContent(current);
  if (currentInspection.fullyPatched) {
    ensureBaseline(extension);
    writeApplyManifest(extension, current, null, "already-patched");
    console.log("[apply] Extension is already fully patched. No write needed.");
    return;
  }

  if (!fs.existsSync(PATCHED_BASELINE)) {
    fail("Patched baseline missing. Cannot safely reconstruct full patch set.");
  }
  const manifest = loadManifest();
  if (manifest && manifest.extensionVersion && manifest.extensionVersion !== extension.version) {
    fail([
      `Extension version changed: manifest=${manifest.extensionVersion}, current=${extension.version}.`,
      "Refusing to overwrite a different Workbench version with an old patched baseline.",
      "Inspect the new extension.js and create a new baseline for this version.",
    ].join("\n"));
  }
  if (manifest && manifest.extensionName && manifest.extensionName !== extension.name) {
    fail([
      `Extension directory changed: manifest=${manifest.extensionName}, current=${extension.name}.`,
      "Refusing to apply baseline across extension directories.",
    ].join("\n"));
  }
  const baseline = readText(PATCHED_BASELINE);
  const baselineInspection = inspectContent(baseline);
  if (!baselineInspection.fullyPatched) {
    fail("Patched baseline is not fully patched. Refusing to apply.");
  }
  const syntax = syntaxCheckText(baseline);
  if (!syntax.ok) {
    fail("Patched baseline fails node --check:\n" + syntax.error);
  }

  const backupPath = makeBackup(extension, "pre-apply");
  writeText(extension.js, baseline);
  const afterSyntax = syntaxCheckFile(extension.js);
  if (!afterSyntax.ok) {
    fs.copyFileSync(backupPath, extension.js);
    fail("Patched file failed node --check; restored backup:\n" + afterSyntax.error);
  }
  writeApplyManifest(extension, baseline, backupPath, "applied-baseline");
  console.log(`[apply] Applied full patched baseline to ${extension.js}`);
  console.log(`[apply] Backup: ${backupPath}`);
  console.log("[apply] Reload VS Code window before verifying bridge online.");
}

function writeApplyManifest(extension, patchedContent, backupPath, action) {
  const existing = loadManifest() || {};
  saveManifest({
    schema: 1,
    patchSet: "stata-workbench-shared-session/full-v2",
    action,
    updatedAt: new Date().toISOString(),
    extensionName: extension.name,
    extensionVersion: extension.version,
    extensionFile: extension.js,
    backupPath: backupPath || existing.backupPath || null,
    patchedBaselinePath: PATCHED_BASELINE,
    patchedSha256: sha256(patchedContent),
  });
}

function cmdRevert() {
  const extension = findExtension();
  const manifest = loadManifest();
  if (!manifest || !manifest.backupPath) {
    fail("No manifest backupPath found. Refusing to guess a backup.");
  }
  if (!fs.existsSync(manifest.backupPath)) {
    fail(`Manifest backup missing: ${manifest.backupPath}`);
  }
  const safetyBackup = makeBackup(extension, "pre-revert");
  fs.copyFileSync(manifest.backupPath, extension.js);
  const syntax = syntaxCheckFile(extension.js);
  if (!syntax.ok) {
    fs.copyFileSync(safetyBackup, extension.js);
    fail("Reverted file failed node --check; restored pre-revert backup:\n" + syntax.error);
  }
  saveManifest({
    ...manifest,
    action: "reverted",
    updatedAt: new Date().toISOString(),
    revertedFromBackup: manifest.backupPath,
    preRevertBackup: safetyBackup,
  });
  console.log(`[revert] Restored extension.js from manifest backup: ${manifest.backupPath}`);
  console.log(`[revert] Pre-revert safety backup: ${safetyBackup}`);
  console.log("[revert] Reload VS Code window to unload patched extension code.");
}

function indent(text) {
  return String(text || "").split(/\r?\n/).map((line) => `  ${line}`).join("\n");
}

function fail(message) {
  console.error("[ERROR] " + message);
  process.exit(1);
}

const command = process.argv[2] || "status";
if (command === "status") {
  printStatus();
} else if (command === "verify") {
  cmdVerify().catch((err) => fail(err.stack || err.message || String(err)));
} else if (command === "apply") {
  cmdApply();
} else if (command === "revert") {
  cmdRevert();
} else {
  fail(`Unknown command: ${command}\nUsage: node patch_manager.js [status|verify|apply|revert]`);
}
