"use strict";

const DEFAULT_RETRY_DELAYS_MS = Object.freeze([
  250, 500, 1000, 2000, 4000, 5000, 5000, 5000,
]);

function createBridgeBinder(options = {}) {
  const server = options.server;
  if (!server || typeof server.listen !== "function" || typeof server.on !== "function") {
    throw new TypeError("bridge binder requires an HTTP server");
  }
  const port = Number(options.port);
  const host = options.host || "127.0.0.1";
  const retryDelaysMs = Array.isArray(options.retryDelaysMs)
    ? options.retryDelaysMs.slice()
    : DEFAULT_RETRY_DELAYS_MS.slice();
  const setTimer = options.setTimeoutFn || setTimeout;
  const clearTimer = options.clearTimeoutFn || clearTimeout;
  const now = options.now || (() => Date.now());
  let timer = null;
  let pendingListeningHandler = null;
  let disposed = false;

  const state = {
    port,
    host,
    attempts: 0,
    retriesScheduled: 0,
    bound: false,
    exhausted: false,
    lastError: null,
    lastErrorCode: null,
    nextRetryAt: null,
    boundAt: null,
  };

  function snapshot() {
    return { ...state };
  }

  function publish() {
    if (typeof options.onState === "function") options.onState(snapshot());
  }

  function scheduleRetry(error) {
    if (state.retriesScheduled >= retryDelaysMs.length) return false;
    const delayMs = Math.max(0, Number(retryDelaysMs[state.retriesScheduled]) || 0);
    state.retriesScheduled += 1;
    state.nextRetryAt = new Date(now() + delayMs).toISOString();
    publish();
    if (typeof options.onRetry === "function") {
      options.onRetry({ error, delayMs, state: snapshot() });
    }
    timer = setTimer(() => {
      timer = null;
      state.nextRetryAt = null;
      bind();
    }, delayMs);
    return true;
  }

  function handleListening() {
    pendingListeningHandler = null;
    if (disposed) return;
    state.bound = true;
    state.exhausted = false;
    state.lastError = null;
    state.lastErrorCode = null;
    state.nextRetryAt = null;
    state.boundAt = new Date(now()).toISOString();
    if (timer !== null) {
      clearTimer(timer);
      timer = null;
    }
    publish();
    if (typeof options.onBound === "function") options.onBound(snapshot());
  }

  function handleError(error) {
    if (disposed) return;
    if (pendingListeningHandler !== null && typeof server.removeListener === "function") {
      server.removeListener("listening", pendingListeningHandler);
      pendingListeningHandler = null;
    }
    state.lastError = error && error.message ? error.message : String(error);
    state.lastErrorCode = error && error.code ? String(error.code) : null;
    state.bound = false;
    state.boundAt = null;
    if (state.lastErrorCode === "EADDRINUSE" && scheduleRetry(error)) return;
    state.exhausted = true;
    state.nextRetryAt = null;
    publish();
    if (typeof options.onTerminalError === "function") {
      options.onTerminalError(error, snapshot());
    }
  }

  function bind() {
    if (disposed || state.bound || server.listening) return snapshot();
    state.attempts += 1;
    state.exhausted = false;
    publish();
    try {
      pendingListeningHandler = handleListening;
      server.once("listening", pendingListeningHandler);
      server.listen(port, host);
    } catch (error) {
      if (pendingListeningHandler !== null && typeof server.removeListener === "function") {
        server.removeListener("listening", pendingListeningHandler);
        pendingListeningHandler = null;
      }
      handleError(error);
    }
    return snapshot();
  }

  function dispose() {
    disposed = true;
    if (timer !== null) {
      clearTimer(timer);
      timer = null;
    }
    if (pendingListeningHandler !== null && typeof server.removeListener === "function") {
      server.removeListener("listening", pendingListeningHandler);
      pendingListeningHandler = null;
    }
    state.nextRetryAt = null;
    if (typeof server.removeListener === "function") {
      server.removeListener("error", handleError);
    }
    publish();
  }

  server.on("error", handleError);
  publish();
  return { start: bind, dispose, state: snapshot };
}

module.exports = { DEFAULT_RETRY_DELAYS_MS, createBridgeBinder };
