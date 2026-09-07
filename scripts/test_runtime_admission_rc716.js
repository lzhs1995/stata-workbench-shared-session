#!/usr/bin/env node
"use strict";

const assert = require("assert");
const fs = require("fs");
const path = require("path");

const bundle = fs.readFileSync(path.join(__dirname, "..", "dist", "extension.js"), "utf8");
let passed = 0;
function test(name, fn) {
  fn();
  passed += 1;
  console.log("  ok  " + name);
}

test("PF1 human-file pre-run timeout performs bounded ownership cleanup before rethrow", () => {
  const marker = "codex patch rc.7.16: human-file pre-dispatch failure cleanup";
  assert.strictEqual(bundle.split(marker).length - 1, 1);
  const at = bundle.indexOf(marker);
  const region = bundle.slice(Math.max(0, at - 2200), at + 300);
  assert.ok(region.includes("__snapshotError.__codexPreRunTimeout"));
  assert.ok(region.includes('__codexFinishGraphRunNoExport(r,"human-file-predispatch-error-release")'));
  assert.ok(region.includes('__codexSetPostRunBusy(false,"human-file-predispatch-error-release",r)'));
  assert.ok(region.includes("shouldCleanupAfterFailure(__codexHumanFilePreRunSnapshot)"));
  const cleanupAt = region.indexOf("StopCheckpointRef.cleanup(__codexHumanFilePreRunSnapshot)");
  const ownershipAt = region.indexOf("shouldCleanupAfterFailure(__codexHumanFilePreRunSnapshot)");
  assert.ok(ownershipAt >= 0 && cleanupAt > ownershipAt,
    "cleanup must be dominated by the Stop ownership decision");
  assert.ok(region.includes("globalThis.__codexPreRunSnapshots.delete(r)"));
  assert.ok(region.includes("throw __snapshotError"), "original timeout object must be rethrown");
  assert.ok(!region.includes("__codexForceReset"), "cleanup must not silently heal with force-reset");
});

test("rc.7.20 retains the ready human snapshot after soft Stop claims cleanup ownership", () => {
  const marker = "codex patch rc.7.20: Stop-owned human snapshot survives cancellation race";
  assert.strictEqual(bundle.split(marker).length - 1, 2,
    "one inline marker and one patch-ledger marker are required");
  const humanAt = bundle.indexOf("__codexHumanFilePreRunSnapshot=null");
  const humanEnd = bundle.indexOf("/* codex patch rc.7.10: pre-run dataset snapshot", humanAt);
  const region = bundle.slice(humanAt, humanEnd);
  assert.ok(region.includes("shouldCleanupAfterFailure(__codexHumanFilePreRunSnapshot)"));
  assert.ok(region.includes("StopCheckpointRef.cleanup(__codexHumanFilePreRunSnapshot)"));
  const catchAt = region.indexOf("catch(__snapshotError)");
  const failureRegion = region.slice(catchAt);
  assert.ok(failureRegion.indexOf("shouldCleanupAfterFailure") <
    failureRegion.indexOf("StopCheckpointRef.cleanup"));
});

test("rc.7.21 arbitrates final readiness through the last hard-reset result", () => {
  const marker = "codex patch rc.7.21: successful hard reset owns final readiness";
  assert.strictEqual(bundle.split(marker).length - 1, 2,
    "one inline marker and one patch-ledger marker are required");
  const softAt = bundle.indexOf("globalThis.__codexSoftStop=async");
  const hardAt = bundle.indexOf("globalThis.__codexForceReset=async", softAt);
  const soft = bundle.slice(softAt, hardAt);
  assert.ok(soft.includes("StopCheckpointRef.softStopReadiness(__restore,__hardReset)"));
  assert.ok(!soft.includes('readinessState:__restore&&__restore.ok===false?"stale":"ready"'));
});

test("rc.7.30 checkpoint readiness never bypasses unsettled transport ownership", () => {
  const softAt = bundle.indexOf("globalThis.__codexSoftStop=async");
  const hardAt = bundle.indexOf("globalThis.__codexForceReset=async", softAt);
  const soft = bundle.slice(softAt, hardAt);
  assert.ok(soft.includes("codex patch rc.7.16: pre-dispatch Stop restores matching checkpoint"));
  assert.ok(soft.includes("__codexPreDispatchRestore"));
  assert.ok(!soft.includes("if(!__drained&&!__codexPreDispatchRestore)"));
  assert.ok(!soft.includes("__drained||__codexPreDispatchRestore"));
  assert.ok(soft.includes("StopCheckpointRef.transportSummary(__snapshot,zg,__taskId)"));
  assert.ok(soft.includes("if(__transportDrain.safeForRestore)break"));
  const early = soft.indexOf("if(!__drained&&__snapshot)");
  const restore = soft.indexOf("restoreCode(__snapshot");
  assert.ok(early >= 0 && restore > early,
    "unsettled transport must hard-reset before checkpoint restore remains reachable");
  assert.ok(soft.includes("drainedForRestore:!!__drained"));
});

test("PF2 terminal failure envelope is observable through status and HTTP mapping", () => {
  assert.ok(bundle.includes("lastTerminalGuardFailure:globalThis.__codexLastTerminalFailure||null"));
  const endpointAt = bundle.indexOf('startsWith("/debug-terminal-input")');
  assert.ok(endpointAt >= 0);
  const endpoint = bundle.slice(endpointAt, endpointAt + 6500);
  assert.ok(endpoint.includes("__terminalGuardFailure"));
  assert.ok(endpoint.includes("(__terminalGuardFailure&&__terminalGuardFailure.status)||"));
  assert.ok(endpoint.includes("guardFailure:__terminalGuardFailure||null"));
  assert.ok(bundle.includes("globalThis.__codexLastTerminalFailure=__codexTermErr.__codexPreRunTimeout"));
  for (const field of ["cause", "settlement", "stallReason", "cancelLevels", "outcome", "recoveryRequired"]) {
    assert.ok(bundle.includes(field + ":"), "missing envelope field " + field);
  }
});

test("C4 arming exposes restore-capable residency and payload dispatch", () => {
  assert.ok(bundle.includes("restoreCapable:"));
  assert.ok(bundle.includes("payloadDispatched:"));
});

test("rc.7.17 publishes the exact provisional checkpoint before snapshot dispatch", () => {
  const marker = "codex patch rc.7.17: provisional checkpoint publication";
  assert.strictEqual(bundle.split(marker).length - 1, 1);
  const humanAt = bundle.indexOf("__codexHumanFilePreRunSnapshot={path:__snapshotPath,bytes:null");
  const snapshotDispatchAt = bundle.indexOf("guardStage(\"snapshot\"", humanAt);
  const completeAt = bundle.indexOf("Object.assign(__codexHumanFilePreRunSnapshot", snapshotDispatchAt);
  assert.ok(humanAt >= 0 && snapshotDispatchAt > humanAt);
  assert.ok(completeAt > snapshotDispatchAt, "completion must update the same provisional object");
  const region = bundle.slice(humanAt, completeAt + 500);
  assert.ok(region.includes("globalThis.__codexPreRunSnapshots.set(r,__codexHumanFilePreRunSnapshot)"));
  assert.ok(region.includes("globalThis.__codexActivePreRunSnapshot=__codexHumanFilePreRunSnapshot"));
  assert.ok(bundle.includes("globalThis.__codexStopCheckpointRef.isSnapshotReady(__snapshot)"));
  assert.ok(bundle.includes("globalThis.__codexStopCheckpointRef.isSnapshotReady(__snap)"));
  assert.ok(bundle.includes("codex patch rc.7.18: active pre-run task remains restore-capable"));
  assert.ok(!bundle.includes("isRestoreCapable(__snapshot)&&!(zg._activeRun"),
    "active snapshot/enrich task must not make an otherwise complete checkpoint invisible");
});

test("rc.7.19 uses one atomic pre-run transport dispatch per user path", () => {
  assert.strictEqual(bundle.split("codex patch rc.7.19: atomic pre-run checkpoint transport").length - 1, 1);
  assert.strictEqual((bundle.match(/StopCheckpointRef\.beginAtomic\(/g) || []).length, 2);
  assert.strictEqual((bundle.match(/StopCheckpointRef\.completeAtomic\(/g) || []).length, 2);
  assert.strictEqual((bundle.match(/StopCheckpointRef\.enrich\(/g) || []).length, 0,
    "legacy enrichment must live only inside the core fallback");
  for (const start of ["__codexHumanFilePreRunSnapshot=null", "__codexBridgePreRunSnapshot=null"]) {
    const at = bundle.indexOf(start);
    const end = bundle.indexOf("/* codex patch rc.7.10", at);
    const region = bundle.slice(at, end);
    assert.strictEqual((region.match(/zg\.runSelection\(/g) || []).length, 1,
      start + " must contain exactly one checkpoint transport dispatch");
    assert.ok(region.includes("guardStage(\"snapshot\""));
    assert.ok(region.includes("guardStage(\"enrich\""));
    assert.ok(region.indexOf("StopCheckpointRef.cleanup(") < region.indexOf("__codexPreRunSnapshots.set("),
      start + " must remove stale bytes before provisional publication");
  }
});

test("rc.7.19 Stop admission requires the post-save milestone", () => {
  assert.ok(bundle.includes("globalThis.__codexStopCheckpointRef.isSnapshotReady(__snapshot)"));
  assert.ok(bundle.includes("globalThis.__codexStopCheckpointRef.isSnapshotReady(__snap)"));
  assert.ok(!bundle.includes("globalThis.__codexStopCheckpointRef.isRestoreCapable(__snapshot)"));
});

console.log(`RUNTIME_ADMISSION_RC721 ${passed}/${passed} passed`);
