#!/usr/bin/env node
"use strict";

// Exercise the registered command, both real softStop layers and original client
// methods. Only filesystem provisioning, SDK/process transport and tool I/O are
// replaced. The extension itself is never loaded; no engine, socket or UI opens.
// Derived from the retained cold-cancel-review/reproduce.cjs callback proof.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const vm = require("node:vm");
const crypto = require("node:crypto");
const { EventEmitter } = require("node:events");
const acorn = require("acorn");
const walk = require("acorn-walk");
const patch = require("./apply_cold_cancel_noop_patch");
const shutdown = require("./backend_shutdown_core");
const execution = require("./execution_lifecycle_core");
const checkpoint = require("./stop_checkpoint_core");
const fence = require("./guard_cancel_restore_core");
const control = require("./control_plane_core");
const guard = require("./execution_guard");
const { createRestoreReadiness } = require("./restore_readiness_core");
const { createWindowSession } = require("./window_session_core");
const gateCore = require("./data_browser_execution_gate");
const coldStart = require("./apply_backend_cold_start_patch");
const warmup = require("./apply_backend_warmup_patch");
const stopDuringStart = require("./apply_stop_during_backend_start_patch");
const bundlePath = path.join(__dirname, "..", "dist", "extension.js");
const bundle = fs.readFileSync(bundlePath, "utf8");
const digest = text => crypto.createHash("sha256").update(text).digest("hex");
const originalDigest = digest(bundle);
const corePath = path.join(__dirname, "cold_cancel_core.js");
const coreDigest = digest(fs.readFileSync(corePath));
const plain = value => JSON.parse(JSON.stringify(value));
const generationEvidence = sandbox => ({
  ownProperty: Object.hasOwn(sandbox, "__codexResetGeneration"),
  type: typeof sandbox.__codexResetGeneration,
  value: sandbox.__codexResetGeneration === undefined ? "<undefined>"
    : Number.isNaN(sandbox.__codexResetGeneration) ? "NaN" : sandbox.__codexResetGeneration,
});
const deferred = () => {
  let resolve;
  const promise = new Promise(done => { resolve = done; });
  return { promise, resolve };
};
const turn = () => new Promise(resolve => setImmediate(resolve));

function extract(source) {
  const assignments = [], methods = [], registrations = [], callbacks = [];
  const names = new Set(["globalThis.__codexSoftStop", "globalThis.__codexSoftStopExpectation",
    "globalThis.__codexSoftStopRestoreFence"]);
  const methodNames = new Set(["constructor", "cancelRun", "cancelAll", "runSelection",
    "_enqueue", "_ensureClient", "_createCancellationSource"]);
  let startup, guardWrap;
  const text = node => source.slice(node.start, node.end);
  walk.simple(acorn.parse(source, { ecmaVersion: "latest", allowReturnOutsideFunction: true }), {
    FunctionDeclaration(node) {
      if (node.id?.name === "yM") callbacks.push(text(node));
    },
    AssignmentExpression(node) {
      const name = text(node.left);
      if (names.has(name)) assignments.push({ start: node.start, text: text(node) });
      if (name === "globalThis.__codexGuardWrap") guardWrap = text(node);
    },
    ClassExpression(node) {
      if (node.body.body.some(method => method.key?.name === "runSelection")) {
        for (const method of node.body.body) {
          if (methodNames.has(method.key?.name)) methods.push(text(method));
        }
      }
    },
    CallExpression(node) {
      if (node.callee?.type === "MemberExpression"
          && node.callee.property?.name === "registerCommand"
          && node.arguments[0]?.value === "stata-workbench.cancelRequest") registrations.push(text(node));
    },
    LogicalExpression(node) {
      if (text(node).startsWith('A.get("loadStataOnStartup",!1)&&!Io&&zg.connect().catch(')) startup = text(node);
    },
  });
  assert.equal(callbacks.length, 1, "one actual Cancel callback");
  assert.equal(registrations.length, 1, "one actual Cancel registration");
  assert.equal(assignments.length, 4, "inner Stop, outer fence, expectation and restore fence");
  assert.equal(methods.length, 7, "complete original client method set");
  assert.ok(startup && guardWrap, "actual startup gate and execution guard wrapper");
  // These exported patch constants must occur byte-for-byte in the source under
  // test. They create real cold/start/warm states, not copies of the new predicate.
  const helpers = [coldStart.HELPER, warmup.HELPER, stopDuringStart.HELPER];
  for (const helper of helpers) assert.ok(source.includes(helper), "shipped backend helper bytes");
  return {
    methods: methods.join("\n"),
    program: helpers.join("\n") + "\n" + guardWrap + ";\n"
      + assignments.sort((a, b) => a.start - b.start).map(item => item.text + ";").join("\n")
      + "\n" + callbacks[0] + "\n" + registrations[0] + ";\n" + startup + ";",
  };
}

const adapterSource = fs.readFileSync(path.join(__dirname, "window_session_vscode.js"), "utf8");
const adapterAssignments = [];
walk.simple(acorn.parse(adapterSource, { ecmaVersion: "latest" }), {
  AssignmentExpression(node) {
    if (adapterSource.slice(node.left.start, node.left.end) === "client._ensureClient") {
      adapterAssignments.push(adapterSource.slice(node.start, node.end));
    }
  },
});
assert.equal(adapterAssignments.length, 1, "original window manager ensure wrapper");

function world(code, options = {}) {
  const trace = [], toasts = [], commands = new Map(), timers = new Set();
  const temporary = fs.mkdtempSync(path.join(os.tmpdir(), "wb-cold-cancel-"));
  const event = (name, detail) => trace.push({ name, ...(detail === undefined ? {} : { detail }) });
  const config = { get: (key, fallback) => key === "loadStataOnStartup" ? false : fallback };
  const bridge = { busy: false, postRunBusy: false, runId: null };
  execution.ensureLifecycle(bridge);
  const manager = createWindowSession({ stateRoot: temporary, sessionId: "synthetic-cancel", env: {} });
  // A real cold manager owns only temporary directories. Provisioning is the
  // intercepted boundary: calling prepare is observable, but cannot copy runtime.
  manager.prepare = async () => event("manager.prepare");
  const readiness = createRestoreReadiness();
  const pending = fence.createPendingOutcomes();
  const gate = new gateCore.DataBrowserExecutionGate();
  const sandbox = {
    Map, Set, Promise, AbortController, Buffer, Date, Math, Number, String, Object, Array, Error, JSON,
    process: { env: {} }, console: { log() {}, error() {} },
    setTimeout: (fn, ms) => {
      const id = setTimeout(() => { timers.delete(id); fn(); }, ms);
      timers.add(id); return id;
    },
    clearTimeout: id => { timers.delete(id); clearTimeout(id); },
    DHg: EventEmitter, MHg: { version: "0.2.0" }, MM: () => ({}),
    EE: { workspace: { getConfiguration: () => config } },
    CI: { startSpan: (_options, fn) => fn(), captureException() {} },
    iA: {
      commands: { registerCommand: (id, fn) => { commands.set(id, fn); return { dispose() {} }; } },
      window: {
        showWarningMessage: text => toasts.push(text), showErrorMessage: text => toasts.push(text),
      },
    },
    __codexExecution: execution, __codexControl: control, __codexBridgeState: bridge,
    __codexWindowSession: manager, __codexRestoreReadinessRef: readiness,
    __codexPendingOutcomesRef: pending, __codexDbGate: gate,
    __codexRecoveryState: control.ensureRecoveryState(),
    __codexStopCheckpointRef: checkpoint, __codexGuardCancelRef: fence,
    __codexPreRunSnapshots: new Map(), __codexActivePreRunSnapshot: null,
    // Activation does not initialize ResetGeneration; do not manufacture zero.
    __codexOwnedBackendPids: new Map(), __codexExecGuardRef: guard, __codexExecGuard: guard,
    Gg: { _postMessage: message => event("terminal.message", message) }, RI() {},
    JA: { existsSync: () => false },
    __codexGraphMark: state => event("graph.mark", state),
    __codexRecordSupersede: (...args) => event("supersede", args),
    __codexForceReset: async reason => {
      event("forceReset", reason); return { ok: false, trueReady: false };
    },
  };
  let life;
  sandbox.require = name => {
    if (name === "../scripts/backend_shutdown_runtime") return { lifecycle: () => life };
    if (name === "../scripts/cold_cancel_core") return require("./cold_cancel_core");
    throw new Error("VM dependency refused: " + name);
  };
  vm.createContext(sandbox);
  vm.runInContext("globalThis.ExtractedClient=class {\n" + code.methods + "\n}", sandbox);
  const client = sandbox.zg = new sandbox.ExtractedClient();
  client._pypiVersion = "1.26.1";
  const transport = { start: async () => event("transport.start"), close: async () => event("transport.close") };
  const sdk = { connect: async value => {
    event("sdk.connect");
    if (options.connectBarrier) await options.connectBarrier.promise;
    await value.start();
  } };
  life = shutdown.createLifecycle(client, { adapter: {
    capture: async () => ({ pid: 7, createdMs: 1, fixtureOnly: true }),
    close: async () => ({ backendCleanup: "complete" }),
  } });
  client.__codexLifecycle = () => life;
  client._createClient = async () => { event("client.create"); return { client: sdk, transport }; };
  client._refreshToolList = async () => event("tools.refresh");
  client._withTimeout = promise => promise;
  client._withActiveRun = async (_run, fn) => fn();
  client._breakSession = async () => event("break_session");
  client._callTool = async (_client, name, args) => {
    event("tool.dispatch", name);
    if (name === "list_sessions") return { sessions: [{ id: "default", status: "starting" }] };
    return { success: true, rc: 0,
      stdout: (String(args.code || "").match(/___CODEX_SOFT_STOP_QUIESCENT_[A-Za-z0-9_.-]*___/) || [""])[0] + "\n" };
  };
  client._parseToolJson = value => value;
  client._awaitBackgroundResult = async (_client, _run, value) => value;
  client._extractLogPathFromResponse = () => null;
  client._drainActiveRunLog = async () => {};
  client._normalizeResponse = value => value;
  client._isCancellationError = error => /cancelled/i.test(error.message || "");
  client._formatRecentStderr = () => "";
  const originalEnsure = client._ensureClient.bind(client);
  sandbox.client = client;
  sandbox.originalEnsure = async (...args) => { event("client.ensure"); return originalEnsure(...args); };
  sandbox.originalLoad = () => ({ fixtureOnly: true });
  sandbox.manager = manager;
  vm.runInContext(adapterAssignments[0] + ";", sandbox);
  // Observers call the extracted originals. The optional callback only releases
  // a deliberately held fake transport/queue after real cancellation is entered.
  const hooks = {};
  for (const name of ["cancelAll", "cancelRun", "runSelection", "_enqueue"]) {
    const original = client[name].bind(client);
    client[name] = async (...args) => {
      event(name, args[0] ?? null);
      const result = original(...args);
      if (hooks[name]) hooks[name]();
      return result;
    };
  }
  client.connect = async () => { event("automatic.connect"); return client._ensureClient(); };
  sandbox.A = config; sandbox.Io = false;
  vm.runInContext(code.program, sandbox);
  const cleanup = () => {
    for (const timer of timers) clearTimeout(timer);
    timers.clear(); fs.rmSync(temporary, { recursive: true, force: true });
  };
  return { sandbox, client, life, manager, gate, readiness, pending, bridge, trace, toasts, hooks, cleanup,
    cancel: () => commands.get("stata-workbench.cancelRequest")(),
    names: () => trace.map(item => item.name),
  };
}

const cases = [];
async function runCase(name, fn, code, options) {
  const w = world(code, options);
  try {
    await fn(w);
    cases.push({ name, trace: w.trace, toasts: w.toasts,
      generation: generationEvidence(w.sandbox), stopReceipt: w.sandbox.__codexLastSoftStop || null });
  } catch (error) {
    console.log(JSON.stringify({ schema: "cold-cancel-actual-callback-test/1", verdict: "FAIL",
      bundleSha256: originalDigest, coreSha256: coreDigest, passed: cases, failed: { name, trace: w.trace,
        toasts: w.toasts, stopReceipt: w.sandbox.__codexLastSoftStop || null,
        error: error.message } }, null, 2));
    throw error;
  } finally { w.cleanup(); }
}
function activeRun(w, id) {
  w.bridge.runId = id;
  execution.beginRun(w.bridge, { runId: id, sourceMode: "terminal-input" });
}
function assertNormalStop(w, expectedGeneration = 1) {
  assert.equal(w.sandbox.__codexResetGeneration, expectedGeneration, "normal Stop retains generation change");
  assert.notEqual(w.sandbox.__codexLastSoftStop?.noop, true, "work/uncertainty is never cold no-op");
  assert.ok(w.names().includes("cancelRun") && w.names().includes("cancelAll"), "original cancellation path");
  assert.ok(w.names().includes("supersede"), "normal supersede bookkeeping retained");
  assert.ok(!w.toasts.some(text => text.includes("No Stata work is running")), "no misleading no-op toast");
}

(async () => {
  const current = extract(bundle);
  const beforeSource = patch.revertBundle(bundle);
  const previous = extract(beforeSource);
  assert.equal(patch.patchBundle(beforeSource), bundle, "negative control is exact inverse/replay layer");

  await runCase("startup=false without Cancel remains cold", async w => {
    assert.equal(w.client._clientPromise, null);
    assert.equal(w.client._transport, null);
    assert.deepEqual(w.names(), []);
  }, current);
  await runCase("direct cold cancelAll negative control", async w => {
    assert.equal(await w.client.cancelAll(), false);
    assert.deepEqual(w.names(), ["cancelAll"]);
  }, current);
  for (const explicitZero of [false, true]) {
  await runCase("actual registered cold Cancel with " + (explicitZero ? "explicit zero" : "real undefined generation") + " is truthful no-op", async w => {
    assert.equal(Object.hasOwn(w.sandbox, "__codexResetGeneration"), false, "activation does not initialize generation");
    assert.equal(w.sandbox.__codexResetGeneration, undefined);
    if (explicitZero) w.sandbox.__codexResetGeneration = 0;
    const before = plain({ lifecycle: w.life.status(), restore: w.readiness.status(),
      recovery: w.sandbox.__codexRecoveryState, bridge: w.bridge, gate: w.gate.snapshot(),
      generation: generationEvidence(w.sandbox), ownedBackendPids: [...w.sandbox.__codexOwnedBackendPids] });
    await w.cancel();
    const receipt = w.sandbox.__codexLastSoftStop;
    assert.equal(receipt.noop, true);
    assert.equal(receipt.ok, true);
    assert.equal(receipt.cancelled, false);
    assert.equal(receipt.restored, false);
    assert.equal(receipt.runId, null);
    assert.equal(receipt.generation, 0);
    assert.equal(receipt.restore, undefined, "no fabricated restore or quiescence proof");
    assert.equal(w.sandbox.__codexResetGeneration, explicitZero ? 0 : undefined);
    assert.equal(Object.hasOwn(w.sandbox, "__codexResetGeneration"), explicitZero, "no generation assignment on no-op");
    assert.equal(w.sandbox.__codexLastSoftStopRestoreVerdict, undefined, "fence not entered");
    assert.equal(w.sandbox.__codexSoftStopInFlight, undefined);
    assert.equal(w.client._clientPromise, null);
    assert.equal(w.client._transport, null);
    assert.deepEqual(w.names(), [], "no cancellation, prepare, reservation, connect, probe or graph-ready mutation");
    assert.deepEqual(plain({ lifecycle: w.life.status(), restore: w.readiness.status(),
      recovery: w.sandbox.__codexRecoveryState, bridge: w.bridge, gate: w.gate.snapshot(),
      generation: generationEvidence(w.sandbox), ownedBackendPids: [...w.sandbox.__codexOwnedBackendPids] }), before);
    assert.deepEqual(w.toasts, ["No Stata work is running; nothing was stopped or restored."]);
  }, current);
  }
  for (const [name, value, expectedGeneration] of [
    ["null", null, 1], ["false", false, 1], ["string zero", "0", 1],
    ["NaN", NaN, 1], ["nonzero number", 1, 2],
  ]) {
    await runCase("invalid generation " + name + " cannot become a coerced no-op", async w => {
      w.sandbox.__codexResetGeneration = value;
      await w.cancel();
      assertNormalStop(w, expectedGeneration);
      assert.ok(w.names().includes("runSelection"), "invalid state retains the original Stop path");
    }, current);
  }
  await runCase("owned backend PID prevents cold no-op", async w => {
    w.sandbox.__codexOwnedBackendPids.set(7, { pid: 7, fixtureOnly: true });
    await w.cancel();
    assertNormalStop(w);
    assert.equal(w.sandbox.__codexOwnedBackendPids.size, 1, "Stop does not erase ownership evidence");
    assert.ok(w.names().includes("runSelection"));
  }, current);
  await runCase("previous layer reproduces actual cold callback provisioning", async w => {
    await w.cancel();
    assertNormalStop(w);
    for (const name of ["runSelection", "_enqueue", "manager.prepare", "client.ensure",
      "client.create", "sdk.connect", "transport.start"]) assert.ok(w.names().includes(name), name);
    assert.equal(w.names().filter(name => name === "sdk.connect").length, 1);
    assert.equal(w.sandbox.__codexLastSoftStop.restore.quiescenceProbe.markerSeen, true);
  }, previous);

  const connectBarrier = deferred();
  await runCase("pending backend startup still cancels before dispatch", async w => {
    activeRun(w, "starting");
    const start = w.sandbox.__codexEnsureBackendStarted("starting", "terminal-input").catch(error => error);
    await turn();
    assert.equal(w.life.status().pendingAttempts, 1);
    assert.equal(w.sandbox.__codexBackendStartSummary().current.outcome, "WAITING");
    w.hooks.cancelRun = () => connectBarrier.resolve();
    await w.cancel();
    assertNormalStop(w);
    assert.equal((await start).code, "PRE_RUN_BACKEND_START_CANCELLED");
    assert.ok(!w.names().includes("runSelection"), "start cancellation skips quiescence payload");
    assert.ok(w.names().includes("break_session"));
  }, current, { connectBarrier });

  await runCase("queued real client request is cancelled before payload", async w => {
    const queue = deferred();
    w.client._queue = queue.promise;
    activeRun(w, "queued");
    const queued = w.client.runSelection("display 42", { runId: "queued", includeGraphs: false, normalizeResult: true });
    assert.equal(w.client._pending, 1);
    assert.equal(w.client._active, false);
    w.hooks.cancelRun = () => queue.resolve();
    await w.cancel();
    const result = await queued;
    assertNormalStop(w);
    assert.equal(result.rc, -1);
    assert.equal(w.client._pending, 0);
    assert.equal(w.client._cancellationSourcesByRunId.size, 0);
    assert.equal(w.sandbox.__codexLastSoftStop.cancelled, true, "cancelRun cancelled the queued request");
    // The queued source can drain before cancelAll observes it, so break_session
    // is not required. Only the normal Stop quiescence tool call can dispatch.
    assert.equal(w.trace.filter(item => item.name === "tool.dispatch").length, 1);
  }, current);

  await runCase("existing backend retains break and quiescence", async w => {
    await w.client._ensureClient();
    assert.ok(w.client._transport);
    w.trace.length = 0;
    await w.cancel();
    assertNormalStop(w);
    assert.ok(w.names().includes("break_session") && w.names().includes("runSelection"));
    assert.ok(!w.names().includes("sdk.connect"), "reuse existing fake backend");
  }, current);

  await runCase("actual warmup WAITING is cancelled without payload", async w => {
    await w.client._ensureClient();
    w.client._availableTools.add("list_sessions");
    activeRun(w, "warming");
    const warming = w.sandbox.__codexEnsureBackendWarm("warming", "terminal-input").catch(error => error);
    await turn();
    assert.equal(w.sandbox.__codexBackendWarmupSummary().outcome, "WAITING");
    await w.cancel();
    assertNormalStop(w);
    assert.equal((await warming).code, "PRE_RUN_BACKEND_WARMUP_CANCELLED");
    assert.ok(!w.names().includes("runSelection"));
  }, current);

  await runCase("uncertain HTTP channel cannot claim a cold no-op", async w => {
    const begun = w.gate.beginHttp({ path: "/synthetic-only", baseUrl: "http://127.0.0.1:1" });
    assert.equal(begun.ok, true);
    w.gate.markHttpStarted(begun.token);
    w.gate.finishHttp(begun.token, gateCore.OUTCOME_TIMEOUT);
    assert.equal(w.gate.snapshot().channelUncertain, true);
    await w.cancel();
    assertNormalStop(w);
    assert.equal(w.gate.snapshot().channelUncertain, true, "uncertainty not cleared by Stop");
    assert.ok(w.names().includes("forceReset"), "refused quiescence follows original recovery path");
  }, current);

  await runCase("required recovery remains non-noop", async w => {
    w.sandbox.__codexRecoveryState = control.requestRecovery(w.sandbox.__codexRecoveryState, "synthetic recovery");
    await w.cancel();
    assertNormalStop(w);
    assert.equal(w.sandbox.__codexRecoveryState.required, true);
    assert.ok(w.names().includes("runSelection"));
  }, current);
  for (const [name, setup] of [
    ["unresolved cleanup", w => { w.sandbox.__codexUnresolvedCleanup = { open: true, items: ["unknown"] }; }],
    ["pending outcome", w => w.pending.open("unsettled", { reason: "synthetic uncertainty" })],
    ["restore in progress", w => w.readiness.begin("restoring")],
    ["missing manager", w => { delete w.sandbox.__codexWindowSession; }],
    ["throwing state reader", w => { w.sandbox.__codexBackendStartSummary = () => { throw Error("synthetic unavailable"); }; }],
  ]) {
    await runCase(name + " keeps original Stop", async w => {
      setup(w); await w.cancel(); assertNormalStop(w);
    }, current);
  }
  assert.equal(digest(fs.readFileSync(bundlePath)), originalDigest, "bundle unchanged by tests");
  assert.equal(digest(fs.readFileSync(corePath)), coreDigest, "tested core bytes unchanged during run");
  console.log(JSON.stringify({ schema: "cold-cancel-actual-callback-test/1", verdict: "PASS",
    cases: cases.length, bundleSha256: originalDigest, coreSha256: coreDigest, coreStable: true,
    previousLayerSha256: digest(beforeSource),
    noEngine: true, noNetwork: true, noUI: true, results: cases }, null, 2));
})().catch(error => { console.error(error); process.exitCode = 1; });
