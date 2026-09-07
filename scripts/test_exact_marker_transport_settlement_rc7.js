#!/usr/bin/env node
"use strict";

const assert = require("assert");
const fs = require("fs");
const path = require("path");
const lifecycle = require("./execution_lifecycle_core");

const extension = fs.readFileSync(path.join(__dirname, "..", "dist", "extension.js"), "utf8");
const methodStart = extension.indexOf("settleRunFromExactMarker(A,I={}){");
const methodEnd = extension.indexOf(
  "/* codex patch rc.7.10.24: exact marker settles missing task_done */",
  methodStart
);

assert.ok(methodStart >= 0 && methodEnd > methodStart, "missing exact-marker settlement method");

const methodSource = extension.slice(methodStart, methodEnd);
const settleRunFromExactMarker = Function(`return ({${methodSource}}).settleRunFromExactMarker`)();

async function main() {
  let resolveTaskDone;
  let queueActive = true;
  let cleanupTaskId = null;
  const bridge = {};
  lifecycle.beginRun(bridge, {
    runId: "run_exact_1",
    sourceMode: "manual-selection",
    perRunEvidenceRequired: true,
  }, 1000);
  const run = {
    _runId: "run_exact_1",
    taskId: "task_exact_1",
    logPath: "/tmp/exact.log",
    _taskDoneResolve: (payload) => resolveTaskDone(payload),
  };
  const client = {
    _activeRun: run,
    _runsByTaskId: new Map([[run.taskId, run]]),
    _scheduleRunCleanup: (taskId) => {
      cleanupTaskId = taskId;
    },
  };
  client.settleRunFromExactMarker = settleRunFromExactMarker;

  const basePromise = new Promise((resolve) => {
    resolveTaskDone = resolve;
  }).then((payload) => {
    queueActive = false;
    return payload;
  });
  const guardedCompletion = basePromise;

  assert.strictEqual(
    lifecycle.transportSettlementDecision({ success: true, rc: 0 }, bridge.lifecycle).release,
    false,
    "lifecycle cannot be READY while transport is unsettled"
  );
  assert.strictEqual(queueActive, true, "first transport must still own the queue before settlement");
  assert.strictEqual(
    client.settleRunFromExactMarker("run_other", { logPath: "/tmp/wrong.log" }),
    false,
    "a stale marker must not settle another run"
  );
  assert.strictEqual(bridge.lifecycle.perRunCompletionMarkerVerified, false);

  lifecycle.recordSessionCompletionMarker(bridge, 1100, "run_exact_1");
  assert.strictEqual(
    client.settleRunFromExactMarker("run_exact_1", { logPath: "/tmp/final.log" }),
    true,
    "the matching exact marker must settle the missing task_done"
  );
  const payload = await guardedCompletion;

  assert.strictEqual(queueActive, false, "synthetic task_done must release the transport queue");
  assert.strictEqual(
    lifecycle.transportSettlementDecision(payload.result, bridge.lifecycle).release,
    false,
    "session evidence may release transport but cannot expose verified success"
  );
  assert.strictEqual(run._tailCancelled, true);
  assert.strictEqual(run._fastDrain, true);
  assert.strictEqual(payload.status, "completed");
  assert.strictEqual(payload.rc, 0);
  assert.strictEqual(payload.result.log_path, "/tmp/final.log");
  assert.strictEqual(cleanupTaskId, "task_exact_1");

  lifecycle.recordPerRunCompletionMarker(bridge, 1200, "run_exact_1");
  assert.strictEqual(
    lifecycle.transportSettlementDecision(payload.result, bridge.lifecycle).release,
    true,
    "READY is allowed only after the per-run marker converges"
  );

  const nextCommand = await (queueActive
    ? Promise.reject(new Error("queue remained blocked"))
    : Promise.resolve("next-command-completed"));
  assert.strictEqual(nextCommand, "next-command-completed");

  assert.ok(
    extension.includes("if (__codexBaseSettled && globalThis.__codexExecutionAdapter.ensureLifecycle"),
    "completed-log release must retain the transport-settled prerequisite"
  );
  console.log("EXACT_MARKER_TRANSPORT_SETTLEMENT_RC7_PASS");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
