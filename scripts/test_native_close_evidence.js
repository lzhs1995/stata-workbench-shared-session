"use strict";
// Actual regenerated deactivation fragment with real lifecycle, synthetic state
// and tiny temporary records only. No activation, sockets, processes or Stata.
const test = require("node:test"), assert = require("node:assert/strict");
const fs = require("node:fs"), os = require("node:os"), path = require("node:path"), vm = require("node:vm");
const evidence = require("./native_close_evidence"), patch = require("./apply_backend_shutdown_patch");
const { createLifecycle } = require("./backend_shutdown_core");
const { historicalLayer, between } = require("./test_daily_bundle_helpers");
const recorded = historicalLayer(fs.readFileSync(path.join(__dirname, "../dist/extension.js"), "utf8"), "./apply_backend_shutdown_patch");
const current = patch.patchBundle(patch.revertBundle(recorded, { finalize: false }), { finalize: false });
const deactivate = between(current, "async function bHg(){", "function HF(g){");
assert.equal(deactivate, patch.DEACTIVATE);
new vm.Script(current);
const deferred = () => { let resolve; const promise = new Promise(r => { resolve = r; }); return { promise, resolve }; };
const tick = async () => { for (let i = 0; i < 40; i++) await Promise.resolve(); };

function fixture(t, options = {}) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "wb-native-close-"));
  t.after(() => fs.rmSync(root, { recursive: true, force: true }));
  const dataDir = path.join(root, "runs", "A"); fs.mkdirSync(dataDir, { recursive: true, mode: 0o700 });
  const state = { nextSession: { sessionId: "A" }, extensionHostPid: process.pid,
    resetGeneration: 7, diskBundleSha256: "a".repeat(64), busy: false, trueReady: false,
    current: null, runId: "old-completed-run", recovery: { required: true, generation: 3,
      activeRunId: null, token: "NEVER_TOKEN", marker: "NEVER_MARKER" } };
  const finish = deferred(), calls = { shutdown: 0, fence: 0, flush: 0, writes: 0 };
  const manager = { sessionId: "A", stateRoot: root, dataDir, closing: true,
    beginClose() { calls.fence++; }, finishClose() { return finish.promise; } };
  const client = { _availableTools: new Set(), _statusEmitter: { emit() {} },
    _createClient() { throw Error("must not create any backend"); } };
  const life = createLifecycle(client, { now: () => 123.25, manager: () => manager });
  const shutdown = life.shutdown;
  life.shutdown = (...args) => { calls.shutdown++; return shutdown(...args); };
  const store = { __codexWindowSession: manager, __codexVisibleState: () => state,
    __codexRecoveryState: { token: "PRIVATE_TOKEN", activeRunId: "WRONG_PRIVATE_ID" } };
  const io = { lstatSync: fs.lstatSync, writeFileSync(...args) { calls.writes++; return fs.writeFileSync(...args); }, ...options.io };
  const env = Object.assign(store, { zg: { __codexLifecycle: () => life }, GB: { flush: async () => { calls.flush++; } },
    require(name) { assert.equal(name, "../scripts/native_close_evidence");
      if (options.requireFails) throw Error("module unavailable");
      return { capture: target => evidence.capture(target, store, io) }; } });
  const context = vm.createContext(env); vm.runInContext(deactivate, context);
  return { state, manager, life, calls, store, io, finish, dataDir,
    run: () => vm.runInContext("bHg()", context),
    read: () => JSON.parse(fs.readFileSync(path.join(dataDir, evidence.FILE), "utf8")) };
}

test("native pending reconnect records busy=false before the synchronous fence", async t => {
  const f = fixture(t), prepare = deferred(); await f.life.dispose(); await f.life.dispose();
  const pending = f.life.ensureClient(() => prepare.promise).catch(error => error); await tick();
  assert.equal(f.life.status().pendingAttempts, 1);
  const closing = f.run(), record = f.read();
  assert.equal(f.calls.shutdown, 1); assert.equal(f.calls.fence, 1); assert.equal(f.life.status().closing, true);
  assert.deepEqual({ epoch: record.lifecycleEpoch, pending: record.pendingAttempts, busy: record.busy,
    runId: record.runId, closing: record.closing }, { epoch: 2, pending: 1, busy: false, runId: null, closing: false });
  assert.equal(record.monotonicMs, 123.25); assert.equal(record.generation, 7);
  assert.equal(record.schema, "stata-native-deactivate-admission/1");
  assert.equal(record.entrypoint, "vscode-extension-deactivate");
  assert.equal(record.capturedBeforeShutdownInvocation, true); assert.equal(record.endpointClosePreviouslyRequested, false);
  assert.ok(Number.isFinite(Date.parse(record.observedAtUtc)));
  assert.equal(record.extensionHostPid, process.pid); assert.equal(record.bundleSha256, "a".repeat(64));
  prepare.resolve(); f.finish.resolve({}); await closing;
  assert.match((await pending).message, /CLOSING/); assert.equal(f.store.__codexShutdownResult.backendCleanup, "complete");
});

test("native smoke snapshot uses current run and remains unchanged during awaited cleanup", async t => {
  const f = fixture(t); Object.assign(f.state, { busy: true, current: { runId: "smoke-now" } });
  f.state.recovery.activeRunId = "smoke-now";
  const closing = f.run(), bytes = fs.readFileSync(path.join(f.dataDir, evidence.FILE));
  Object.assign(f.state, { busy: false, resetGeneration: 8, trueReady: true });
  f.state.current.runId = "later"; f.state.recovery.activeRunId = "later";
  f.finish.resolve({}); await closing;
  assert.deepEqual(fs.readFileSync(path.join(f.dataDir, evidence.FILE)), bytes);
  const record = JSON.parse(bytes); assert.equal(record.runId, "smoke-now");
  assert.deepEqual(record.recovery, { required: true, generation: 3, activeRunId: "smoke-now" });
  assert.doesNotMatch(bytes.toString(), /TOKEN|MARKER|WRONG_PRIVATE|old-completed|later/);
  if (process.platform !== "win32") assert.equal(fs.statSync(path.join(f.dataDir, evidence.FILE)).mode & 0o777, 0o600);
});

test("idle completed recovery cannot be relabeled an in-flight native close", async t => {
  const f = fixture(t); f.state.trueReady = true; f.state.recovery.required = false;
  const closing = f.run(), record = f.read();
  assert.equal(record.trueReady, true); assert.equal(record.pendingAttempts, 0); assert.equal(record.runId, null);
  f.finish.resolve({}); await closing;
});

test("deactivation after endpoint shutdown truthfully records the prior closing state", async t => {
  const f = fixture(t); f.store.__codexWindowCloseRequested = true;
  const prior = f.life.shutdown(); f.finish.resolve({}); await prior;
  await f.run(); const record = f.read();
  assert.equal(record.closing, true); assert.equal(record.endpointClosePreviouslyRequested, true);
  assert.equal(f.calls.fence, 1, "shared lifecycle shutdown remains idempotent");
});

test("duplicate native invocation preserves one original trace and one shutdown operation", async t => {
  const f = fixture(t), first = f.run(), bytes = fs.readFileSync(path.join(f.dataDir, evidence.FILE));
  const second = f.run(); assert.equal(f.calls.writes, 1); assert.equal(f.calls.fence, 1);
  f.finish.resolve({}); await Promise.all([first, second]);
  assert.deepEqual(fs.readFileSync(path.join(f.dataDir, evidence.FILE)), bytes);
});

test("synchronous reentry cannot capture a second admission", async t => {
  const f = fixture(t); let nested;
  f.io.writeFileSync = (...args) => { f.calls.writes++; nested = f.run(); fs.writeFileSync(...args); };
  const first = f.run(); f.finish.resolve({}); await Promise.all([first, nested]);
  assert.equal(f.calls.writes, 1); assert.equal(f.calls.fence, 1); assert.equal(f.read().closing, false);
});

test("separate windows keep independent records and lifecycle ownership", async t => {
  const a = fixture(t), b = fixture(t);
  b.manager.sessionId = "B"; b.state.nextSession.sessionId = "B";
  b.manager.dataDir = path.join(b.manager.stateRoot, "runs", "B");
  fs.mkdirSync(b.manager.dataDir, { mode: 0o700 });
  const closingA = a.run(); a.finish.resolve({}); await closingA;
  assert.equal(b.life.status().closing, false); assert.equal(b.calls.writes, 0);
  const closingB = b.run(); b.finish.resolve({}); await closingB;
  assert.equal(a.read().sessionId, "A");
  assert.equal(JSON.parse(fs.readFileSync(path.join(b.manager.dataDir, evidence.FILE))).sessionId, "B");
});

test("an existing or partial original trace is never overwritten or retried", async t => {
  const f = fixture(t), file = path.join(f.dataDir, evidence.FILE);
  fs.writeFileSync(file, "preserved-original-partial");
  const first = f.run(), second = f.run(); f.finish.resolve({}); await Promise.all([first, second]);
  assert.equal(fs.readFileSync(file, "utf8"), "preserved-original-partial");
  assert.equal(f.calls.writes, 1); assert.equal(f.calls.fence, 1);
});

for (const problem of ["ENOSPC", "EACCES", "require", "status", "manager", "identity", "directory"]) {
  test(`native evidence ${problem} failure cannot block lifecycle shutdown`, async t => {
    let writes = 0;
    const f = fixture(t, { requireFails: problem === "require", io: ["ENOSPC", "EACCES"].includes(problem)
      ? { writeFileSync() { writes++; throw Object.assign(Error("secret must not escape"), { code: problem }); } } : {} });
    if (problem === "status") f.store.__codexVisibleState = () => { throw Error("unavailable"); };
    if (problem === "manager") delete f.store.__codexWindowSession;
    if (problem === "identity") f.state.nextSession.sessionId = "B";
    if (problem === "directory") f.manager.dataDir = path.join(f.dataDir, "other");
    const closing = f.run(); assert.equal(f.life.status().closing, true); assert.equal(f.calls.fence, 1);
    f.finish.resolve({}); await closing; await f.run();
    assert.equal(f.store.__codexShutdownResult.backendCleanup, "complete");
    assert.equal(fs.existsSync(path.join(f.dataDir, evidence.FILE)), false);
    assert.ok(writes <= 1); assert.equal(f.calls.fence, 1);
  });
}
