"use strict";

const crypto = require("crypto");

function isoNow(now) {
  return new Date(now == null ? Date.now() : now).toISOString();
}

function ensureRecoveryState(value) {
  const source = value && typeof value === "object" ? value : {};
  return {
    required: source.required === true,
    generation: Number.isInteger(source.generation) && source.generation >= 0
      ? source.generation
      : 0,
    reason: source.reason ? String(source.reason) : null,
    since: source.since ? String(source.since) : null,
    token: source.token ? String(source.token) : null,
    marker: source.marker ? String(source.marker) : null,
    activeRunId: source.activeRunId ? String(source.activeRunId) : null,
    lastAttempt: source.lastAttempt && typeof source.lastAttempt === "object"
      ? { ...source.lastAttempt }
      : null,
  };
}

function createMarker(generation, token) {
  const safeToken = String(token || "").replace(/[^A-Za-z0-9_]/g, "_");
  return `__CODEX_RECOVERY_SMOKE_G${generation}_${safeToken}__`;
}

function requestRecovery(previous, reason, options = {}) {
  const current = ensureRecoveryState(previous);
  const generation = current.generation + 1;
  const token = options.token || crypto.randomBytes(12).toString("hex");
  return {
    required: true,
    generation,
    reason: String(reason || "force-reset-needs-smoke"),
    since: isoNow(options.now),
    token,
    marker: createMarker(generation, token),
    activeRunId: null,
    lastAttempt: null,
  };
}

function clearRecovery(previous, options = {}) {
  const current = ensureRecoveryState(previous);
  return {
    ...current,
    required: false,
    reason: null,
    since: null,
    token: null,
    marker: null,
    activeRunId: null,
    lastAttempt: {
      at: isoNow(options.now),
      ok: true,
      runId: options.runId ? String(options.runId) : null,
      markerVerified: true,
    },
  };
}

function publicRecovery(value) {
  const state = ensureRecoveryState(value);
  return {
    required: state.required,
    generation: state.generation,
    reason: state.reason,
    since: state.since,
    activeRunId: state.activeRunId,
    lastAttempt: state.lastAttempt,
  };
}

function acquireDecision({ bridge, readiness, recovery, request } = {}) {
  const state = bridge || {};
  const ready = readiness || { ready: !state.busy && !state.postRunBusy };
  const gate = ensureRecoveryState(recovery);
  const attempt = request || {};

  if (state.busy || state.postRunBusy) {
    return {
      ok: false,
      kind: "busy",
      httpStatus: 409,
      reason: state.busy ? "bridge busy" : "post-run cleanup in progress",
    };
  }

  if (gate.required) {
    const validRecovery =
      attempt.kind === "recovery-smoke" &&
      attempt.recoveryToken === gate.token &&
      attempt.recoveryGeneration === gate.generation;
    if (!validRecovery) {
      return {
        ok: false,
        kind: "recovery-required",
        httpStatus: 423,
        reason: gate.reason || "recovery smoke required",
      };
    }
    return { ok: true, kind: "recovery-smoke", httpStatus: 202, reason: null };
  }

  if (!ready.ready) {
    return {
      ok: false,
      kind: "not-ready",
      httpStatus: 423,
      reason: ready.reason || ready.status || "bridge not ready",
    };
  }

  return { ok: true, kind: "normal", httpStatus: 202, reason: null };
}

function verifyRecoveryAttempt({ recovery, runId, transportOk, rc, logText } = {}) {
  const state = ensureRecoveryState(recovery);
  const text = String(logText || "");
  const markerVerified = !!state.marker && text
    .split(/\r?\n/)
    .some((line) => line
      .trim()
      .replace(/^(?:\{(?:res|txt|com|err|inp)\})+/i, "")
      .trim() === state.marker);
  const runMatches =
    !!runId &&
    !!state.activeRunId &&
    String(runId) === String(state.activeRunId);
  const ok =
    state.required &&
    transportOk === true &&
    Number(rc) === 0 &&
    runMatches &&
    markerVerified;
  return {
    ok,
    markerVerified,
    runMatches,
    reason: ok
      ? null
      : !state.required
        ? "recovery-not-required"
        : transportOk !== true
          ? "transport-failed"
          : Number(rc) !== 0
            ? `nonzero-rc:${rc}`
            : !runMatches
              ? "run-id-mismatch"
              : "marker-missing",
  };
}

module.exports = {
  acquireDecision,
  clearRecovery,
  createMarker,
  ensureRecoveryState,
  publicRecovery,
  requestRecovery,
  verifyRecoveryAttempt,
};
