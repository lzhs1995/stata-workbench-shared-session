#!/usr/bin/env node
"use strict";

const assert = require("assert");
const core = require("./control_plane_core");

let failed = 0;
function check(name, fn) {
  try {
    fn();
    console.log("PASS", name);
  } catch (error) {
    failed += 1;
    console.error("FAIL", name, error && error.message || error);
  }
}

const recovery = core.requestRecovery(null, "force-reset-needs-smoke: continuity-lost", {
  now: 0,
  token: "fixed_token",
});

check("recovery state hides its token", () => {
  const view = core.publicRecovery(recovery);
  assert.strictEqual(view.required, true);
  assert.strictEqual(view.generation, 1);
  assert.strictEqual(Object.prototype.hasOwnProperty.call(view, "token"), false);
  assert.strictEqual(Object.prototype.hasOwnProperty.call(view, "marker"), false);
});

check("ordinary execution is locked during recovery", () => {
  const decision = core.acquireDecision({
    bridge: { busy: false, postRunBusy: false },
    readiness: { ready: true },
    recovery,
    request: { kind: "normal" },
  });
  assert.deepStrictEqual(
    { ok: decision.ok, kind: decision.kind, httpStatus: decision.httpStatus },
    { ok: false, kind: "recovery-required", httpStatus: 423 }
  );
});

check("only the current internal recovery token is accepted", () => {
  const wrong = core.acquireDecision({
    bridge: {}, readiness: { ready: false }, recovery,
    request: { kind: "recovery-smoke", recoveryToken: "wrong", recoveryGeneration: 1 },
  });
  assert.strictEqual(wrong.ok, false);
  const current = core.acquireDecision({
    bridge: {}, readiness: { ready: false }, recovery,
    request: {
      kind: "recovery-smoke",
      recoveryToken: "fixed_token",
      recoveryGeneration: 1,
    },
  });
  assert.strictEqual(current.ok, true);
});

check("busy wins over recovery permission", () => {
  const decision = core.acquireDecision({
    bridge: { busy: true }, readiness: { ready: false }, recovery,
    request: {
      kind: "recovery-smoke",
      recoveryToken: "fixed_token",
      recoveryGeneration: 1,
    },
  });
  assert.strictEqual(decision.kind, "busy");
  assert.strictEqual(decision.httpStatus, 409);
});

check("current run marker and rc zero verify recovery", () => {
  const active = { ...recovery, activeRunId: "run-1" };
  const result = core.verifyRecoveryAttempt({
    recovery: active,
    runId: "run-1",
    transportOk: true,
    rc: 0,
    logText: `before\n${active.marker}\nafter`,
  });
  assert.strictEqual(result.ok, true);
});

check("SMCL-prefixed output line verifies recovery", () => {
  const active = { ...recovery, activeRunId: "run-smcl" };
  const result = core.verifyRecoveryAttempt({
    recovery: active,
    runId: "run-smcl",
    transportOk: true,
    rc: 0,
    logText: `{com}. display as text "${active.marker}"\n{res}{txt}${active.marker}\n`,
  });
  assert.strictEqual(result.ok, true);
  assert.strictEqual(result.markerVerified, true);
});

check("command echo alone cannot verify recovery", () => {
  const active = { ...recovery, activeRunId: "run-echo" };
  const result = core.verifyRecoveryAttempt({
    recovery: active,
    runId: "run-echo",
    transportOk: true,
    rc: 0,
    logText: `{com}. display as text "${active.marker}"\n`,
  });
  assert.strictEqual(result.ok, false);
  assert.strictEqual(result.markerVerified, false);
  assert.strictEqual(result.reason, "marker-missing");
});

check("old marker, transport failure, and nonzero rc stay locked", () => {
  const active = { ...recovery, activeRunId: "run-2" };
  assert.strictEqual(core.verifyRecoveryAttempt({
    recovery: active, runId: "run-2", transportOk: true, rc: 0, logText: "old marker",
  }).ok, false);
  assert.strictEqual(core.verifyRecoveryAttempt({
    recovery: active, runId: "run-2", transportOk: false, rc: 0, logText: active.marker,
  }).ok, false);
  assert.strictEqual(core.verifyRecoveryAttempt({
    recovery: active, runId: "run-2", transportOk: true, rc: 9, logText: active.marker,
  }).ok, false);
  assert.strictEqual(core.verifyRecoveryAttempt({
    recovery, runId: "unregistered-run", transportOk: true, rc: 0, logText: recovery.marker,
  }).ok, false);
});

check("clear keeps generation and records verified attempt", () => {
  const cleared = core.clearRecovery(recovery, { now: 1, runId: "run-1" });
  assert.strictEqual(cleared.required, false);
  assert.strictEqual(cleared.generation, recovery.generation);
  assert.strictEqual(cleared.lastAttempt.markerVerified, true);
});

if (failed) process.exit(1);
console.log("CONTROL_PLANE_RC64_PASS");
