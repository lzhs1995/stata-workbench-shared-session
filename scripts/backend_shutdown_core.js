"use strict";

// Per-client lifecycle. Reset detaches one generation; terminal shutdown is final.
// No process discovery or signalling here: the injected adapter owns that boundary.
const states = new WeakMap();
const DEFAULT_SHUTDOWN_MS = 8000;

function cancelled() {
  const error = new Error("SESSION_CLOSING_OR_SUPERSEDED");
  error.code = "SESSION_CLOSING_OR_SUPERSEDED";
  return error;
}

function createLifecycle(client, options = {}) {
  const now = options.now || (() => performance.now());
  const timer = options.setTimeout || setTimeout, untimer = options.clearTimeout || clearTimeout;
  const adapter = options.adapter;
  let epoch = 0, closing = false, shutdownPromise = null, last = null, lastAdmission = null;
  const cleanupMs = Math.max(1, Math.min(Number(options.cleanupTimeoutMs) || DEFAULT_SHUTDOWN_MS, 30000));
  const attempts = new Set(), transports = new Set(), aborters = new Set();
  const originalEmit = client._statusEmitter && client._statusEmitter.emit.bind(client._statusEmitter);
  if (originalEmit) client._statusEmitter.emit = (...args) => closing ? false : originalEmit(...args);
  const current = token => !closing && !token.retired && token.epoch === epoch;
  const assert = token => { if (!current(token)) throw cancelled(); };
  const token = () => { const t = { epoch }; assert(t); return t; };

  function bounded(promise, end, fallback) {
    let id;
    const left = end - now();
    const pending = Promise.resolve(promise);
    if (!(left > 0)) { pending.catch(() => {}); return Promise.resolve(fallback); }
    return Promise.race([pending, new Promise(resolve => {
      id = timer(() => resolve(fallback), left);
    })]).finally(() => { if (id !== undefined) untimer(id); });
  }

  // The real client's asynchronous create/listTools methods run with this scope.
  // Late setters and callbacks cannot reset/publish another generation's state.
  function scopeFor(t) {
    return new Proxy(client, {
      set(target, key, value) { if (current(t)) target[key] = value; return true; },
      get(target, key, receiver) {
        if (key === "_statusEmitter") return { emit: (...args) => current(t) && originalEmit && originalEmit(...args) };
        if (key === "_activeRun" && !current(t)) return null;
        const value = Reflect.get(target, key, receiver);
        if (!current(t) && Array.isArray(value)) return value.slice();
        if (!current(t) && value instanceof Map) return new Map(value);
        if (!current(t) && value instanceof Set) return new Set(value);
        if (typeof value === "function") return (...args) => {
          if (!current(t)) {
            // SDK notifications/errors may arrive after close. Do not throw out
            // of an EventEmitter callback, and do not touch a newer run's maps.
            if (["_log", "_captureMcpError", "_onLoggingMessage", "_rejectPendingTaskWaiters",
              "_handleStderrData", "_attachStderrListener"].includes(key)) return;
            throw cancelled();
          }
          return value.apply(receiver, args);
        };
        return value;
      },
    });
  }

  function closeTransport(entry, end) {
    if (entry.closePromise) return entry.closePromise;
    entry.token.retired = true; // a timed-out connect cannot spawn later via start()
    // Called only after start() settles, so a deferred spawn cannot follow cleanup.
    entry.closePromise = (async () => {
      if (entry.startPromise) {
        const started = await bounded(entry.startPromise.then(() => true, () => true), end, false);
        if (!started) return { backendCleanup: "pending", reason: "transport-start-pending" };
      }
      if (!entry.started) {
        try {
          const done = await bounded(Promise.resolve(entry.rawClose()).then(() => true), end, false);
          if (!done) return { backendCleanup: "pending", reason: "unstarted-transport-close-pending" };
        }
        catch (error) { return { backendCleanup: "unknown", reason: String(error.message || error) }; }
        return { backendCleanup: "complete", reason: "transport-never-started" };
      }
      if (!entry.identity || !adapter) return { backendCleanup: "unknown", reason: "spawn-identity-unavailable" };
      try {
        const operation = Promise.resolve().then(() => adapter.close(entry, Math.max(0, end-now())));
        operation.then(() => { entry.closeOperationSettled = true; }, () => { entry.closeOperationSettled = true; });
        return await bounded(operation, end,
          { backendCleanup: "pending", reason: "process-cleanup-deadline" });
      } catch (error) { return { backendCleanup: "unknown", reason: String(error.message || error) }; }
    })();
    entry.closePromise.then(result => { entry.result = result; }, () => {});
    return entry.closePromise;
  }

  function track(transport, t) {
    const entry = { transport, token: t, started: false, identity: null,
      rawClose: typeof transport.close === "function" ? transport.close.bind(transport) : async () => {} };
    transports.add(entry);
    const rawStart = transport.start.bind(transport);
    transport.start = () => {
      assert(t); // before the actual SDK spawn, not merely before connect()
      if (entry.startPromise) throw new Error("transport start attempted twice");
      entry.started = true;
      const started = rawStart();
      // SDK start() creates _process synchronously; birth is read at this boundary.
      entry.process = transport._process || transport.process || transport._serverProcess;
      const captured = (adapter ? Promise.resolve().then(() => adapter.capture(entry.process, transport, t)) : Promise.resolve(null)).then(identity => {
        entry.identity = identity;
        if (!identity) throw new Error("BACKEND_SPAWN_IDENTITY_UNKNOWN");
        if (options.onIdentity && current(t)) options.onIdentity(entry, scopeFor(t));
        return identity;
      });
      entry.startPromise = Promise.allSettled([started, captured]).then(results => {
        entry.startSettled = true;
        for (const result of results) if (result.status === "rejected") throw result.reason;
        assert(t);
      });
      entry.startPromise.catch(() => {});
      return entry.startPromise;
    };
    transport.close = () => closeTransport(entry, now()+cleanupMs);
    return entry;
  }

  function recoveryCleanup(entry) {
    if (entry.result && entry.result.backendCleanup === "complete") return entry.result;
    if (entry.recoveryProof) return entry.recoveryProof;
    // Receipt reconciliation reads prior evidence only. Never repeat a signal,
    // extend an original close deadline, or use PID absence as cleanup proof.
    if (entry.startSettled && entry.closeOperationSettled && adapter && adapter.reconcile) {
      try {
        const proof = adapter.reconcile(entry);
        if (proof && proof.backendCleanup === "complete") return entry.recoveryProof = proof;
      } catch {} // Unreadable evidence leaves the original outcome unchanged.
    }
    return entry.result || { backendCleanup: "pending", reason: "original-cleanup-unsettled" };
  }

  async function admit(attempt, prior, end) {
    // Only wait older attempts: a later reset may enqueue a newer admission and
    // must never form a dependency cycle with this one. Retire old callbacks now.
    for (const a of prior) a.token.retired = true;
    const initial = [...transports];
    for (const e of initial) closeTransport(e, end);
    const settled = await bounded(Promise.all(prior.map(a => a.promise.then(() => true, () => true))), end, null);
    assert(attempt.token);
    if (settled === null) throw admissionError("pending", "prior-attempts-unsettled");
    // A deferred old _createClient may have registered a transport while awaited.
    const old = [...transports];
    const closed = await bounded(Promise.all(old.map(e => closeTransport(e, end))), end, null);
    assert(attempt.token);
    if (closed === null) throw admissionError("pending", "prior-cleanup-deadline");
    const results = old.map(recoveryCleanup);
    const state = results.some(r => r.backendCleanup === "pending") ? "pending"
      : results.some(r => r.backendCleanup !== "complete") ? "unknown" : "complete";
    if (state !== "complete") throw admissionError(state, "prior-backend-not-clean");
    lastAdmission = { backendCleanup: "complete", epoch, priorTransports: old.length };
  }

  function admissionError(backendCleanup, reason) {
    lastAdmission = { backendCleanup, reason, epoch };
    return Object.assign(new Error("BACKEND_CLEANUP_REQUIRED: " + reason),
      { code: "BACKEND_CLEANUP_REQUIRED", backendCleanup, reason });
  }

  function ensureClient(prepare) {
    const t = token();
    if (client._clientPromise) return client._clientPromise;
    const prior = [...attempts], end = now()+cleanupMs;
    const attempt = { token: t, settled: false };
    attempts.add(attempt);
    const scope = scopeFor(t);
    // Defer work one microtask so the shared promise exists before any callback.
    const promise = Promise.resolve().then(async () => {
      let entry;
      try {
        assert(t);
        await admit(attempt, prior, end);
        assert(t);
        if (prepare) await prepare(scope);
        assert(t);
        const made = await scope._createClient();
        if (!made || !made.transport || !made.client) throw new Error("private stdio backend required");
        entry = track(made.transport, t); // before connect, including listTools wait
        assert(t);
        let id;
        try {
          await Promise.race([made.client.connect(made.transport), new Promise((_, reject) => {
            id = timer(() => reject(new Error("backend connection timed out")), (parseInt(made.setupTimeoutSeconds,10)||60)*1000);
          })]);
        } finally { if (id !== undefined) untimer(id); }
        assert(t);
        await scope._refreshToolList(made.client);
        assert(t);
        client._transport = made.transport;
        client._statusEmitter.emit("status", "connected");
        return made.client;
      } catch (error) {
        // Preserve original-promise/epoch ownership before retiring this attempt.
        const ownsState = !closing && t.epoch === epoch && client._clientPromise === promise;
        t.retired = true;
        if (entry) await closeTransport(entry, now()+cleanupMs);
        // Compare promise identity as well as epoch: late failure cannot erase B/new A.
        if (ownsState && !closing && t.epoch === epoch && client._clientPromise === promise) {
          client._clientPromise = null;
          client._transport = null;
          client._availableTools = new Set();
        }
        throw error;
      } finally { attempt.settled = true; attempts.delete(attempt); }
    });
    attempt.promise = promise;
    client._clientPromise = promise;
    promise.catch(() => {});
    return promise;
  }

  function detach() {
    epoch++;
    client._clientPromise = null;
    client._transport = null;
    client._availableTools = new Set();
    client._active = false;
    client._activeCancellation = null;
    client._activeRun = null;
    client._pending = 0;
    client._queue = Promise.resolve();
    client._cancellationSourcesByRunId = new Map();
  }

  async function drain(end) {
    let pending = false;
    // Entries can appear after an in-flight _createClient returns. Drain attempts
    // and take another entry snapshot; nothing may spawn after the fence.
    for (const a of [...attempts]) {
      const settled = await bounded(a.promise.then(() => true, () => true), end, false);
      if (!settled) pending = true;
    }
    const old = [...transports];
    await Promise.all(old.map(e => closeTransport(e, end)));
    const results = old.map(recoveryCleanup);
    const backendCleanup = pending || results.some(r => r.backendCleanup === "pending") ? "pending"
      : results.some(r => r.backendCleanup !== "complete") ? "unknown" : "complete";
    return { backendCleanup, epoch, closing, pendingAttempts: attempts.size, processes: results };
  }

  function dispose() {
    detach(); // recoverable: a new ensureClient is permitted in the new epoch
    const old = [...transports];
    const end = now()+cleanupMs;
    return Promise.all(old.map(e => closeTransport(e, end)));
  }

  function shutdown(ms = DEFAULT_SHUTDOWN_MS) {
    if (shutdownPromise) return shutdownPromise;
    const end = now()+Math.max(1, Math.min(Number(ms)||DEFAULT_SHUTDOWN_MS, 30000));
    closing = true; // MUST happen before any await or manager callback
    detach();
    // Publish the shared promise before external callbacks can re-enter close.
    let resolveShutdown;
    shutdownPromise = new Promise(resolve => { resolveShutdown = resolve; });
    let manager, managerError;
    try {
      manager = options.manager && options.manager();
      if (manager) manager.beginClose();
    } catch (error) { managerError = String(error.message || error); }
    for (const abort of aborters) { try { abort(); } catch {} }
    (async () => {
      // Start close concurrently with waiting for a connection to unwind.
      for (const e of transports) closeTransport(e, end);
      let result = await bounded(drain(end), end, { backendCleanup: "pending", reason: "shutdown-deadline", epoch, closing });
      if (managerError) result = { ...result, backendCleanup: "unknown", reason: "window-close-fence-failed", error: managerError };
      if (manager) {
        const cleanup = { backendCleanup: result.backendCleanup };
        let finished;
        try { finished = await bounded(Promise.resolve().then(() => manager.finishClose(cleanup)), end, null); }
        catch (error) {
          cleanup.backendCleanup = "unknown";
          result = { ...result, backendCleanup: "unknown", reason: "window-close-finish-failed", error: String(error.message || error) };
        }
        if (finished === null) {
          // finishClose may still be waiting for runtime preparation. Keep its
          // late continuation from releasing a slot after our deadline.
          cleanup.backendCleanup = "pending";
          result = { ...result, backendCleanup: "pending", reason: "runtime-preparation-pending" };
        }
      }
      last = result;
      return result;
    })().then(resolveShutdown, error => {
      last = { backendCleanup: "unknown", reason: "shutdown-failed", error: String(error.message || error), epoch, closing };
      resolveShutdown(last);
    });
    return shutdownPromise;
  }

  function onClose(abort) { if (closing) abort(); else aborters.add(abort); return () => aborters.delete(abort); }
  function status() { return { closing, epoch, pendingAttempts: attempts.size, lastShutdown: last, lastAdmission,
    transports: [...transports].map(e => ({ identity: e.identity, started: e.started, cleanup: e.result || null,
      recoveryProof: e.recoveryProof || null })) }; }
  return { token, assert, current, ensureClient, dispose, shutdown, onClose, status, bounded, now };
}

function forClient(client, options) {
  if (!states.has(client)) states.set(client, createLifecycle(client, options));
  return states.get(client);
}

module.exports = { createLifecycle, forClient, DEFAULT_SHUTDOWN_MS };
