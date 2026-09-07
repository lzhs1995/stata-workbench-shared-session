"use strict";

/**
 * data_browser_execution_gate.js — R16J90 execution-priority isolation gate.
 *
 * Pure Node, zero external dependencies, deterministic under injected clock and
 * timer hooks. This module does NOT claim to repair the mcp-stata server wedge
 * observed at R16J88 S13 step27 (102 Data Browser sends / 98 healthy 200s / one
 * unanswered live-port GET / 46,063 ms run_selection stall / separate 10,004 ms
 * break_session timeout). Concurrency there is a confound and an attribution
 * gap. This module (a) forbids NEW Data Browser HTTP admission once execution
 * has reserved, (b) drains only already-admitted requests under a bounded
 * budget, and (c) makes every unresolved HTTP generation explicitly uncertain
 * instead of silently absent.
 *
 * R16J90 repairs the R16J89 audit findings: drain waiters now reject on
 * uncertainty / release / rotation / generation change; reconnect clearance is
 * bound to an exact generation plus uncertainty identity and fences old
 * callbacks by advancing the epoch; HTTP transitions are a strict one-start
 * state machine; handles are frozen and opaque; budgets, origins and rotations
 * are validated rather than defaulted; terminal records are pruned to bounded
 * history while active records stay lossless.
 *
 * Four independent budgets, normative ordering (R16J88 R4 / P2-2). The drain
 * barrier must report FIRST when execution arrives behind an unresolved request;
 * none of these widens or weakens the existing progress sentinel:
 *   1. HTTP drain budget, execution side, before any MCP callback ..... 5,000 ms
 *   2. Data Browser socket-idle timeout (pre-existing, not owned here) . 30,000 ms
 *   3. Data Browser wall-clock settlement watchdog .................... 32,000 ms
 *   4. Execution progress sentinel (pre-existing, NOT owned here) ..... ~46,000 ms
 */

const GATE_VERSION = "r16j90.1";

const EXECUTION_OPERATIONS = Object.freeze([
  "run_selection",
  "run_file",
  "run_command",
]);

const DRAIN_BUDGET_MS = 5000;
const SOCKET_IDLE_TIMEOUT_MS = 30000;
const WALL_SETTLE_MS = 32000;
const PROGRESS_SENTINEL_MS = 46000;

/** Bounded diagnostic history (P2-1): active records stay lossless, terminal
 *  records are pruned so /status and extension memory cannot grow without end. */
const MAX_TERMINAL_HTTP_HISTORY = 32;
const MAX_TERMINAL_RESERVATION_HISTORY = 32;
const MAX_DIAGNOSTIC_HISTORY = 8;

/** Gate refusal codes. These are NOT credential failures and must be excluded
 *  from the Data Browser dataset credential-recovery loop (R4 / P1-2). */
const CODE_EXECUTION_RESERVED = "execution-reserved";
const CODE_CHANNEL_UNCERTAIN = "channel-uncertain";
const CODE_HTTP_DRAIN_TIMEOUT = "http-drain-timeout";
const GATE_ERROR_CODES = Object.freeze([
  CODE_EXECUTION_RESERVED,
  CODE_CHANNEL_UNCERTAIN,
  CODE_HTTP_DRAIN_TIMEOUT,
]);

/** Fail-closed drain codes distinct from a plain budget expiry (P0-2). */
const CODE_RESERVATION_RELEASED = "reservation-released";
const CODE_RESERVATION_UNKNOWN = "reservation-unknown";
const CODE_RESERVATION_STALE = "reservation-stale-generation";
const CODE_INVALID_BUDGET = "invalid-drain-budget";

/** Terminal HTTP outcomes. Only these two settle a token *successfully*. */
const OUTCOME_RESPONSE_END = "response-end";
const OUTCOME_CONSTRUCTION_FAILED = "construction-failed";
/** These finalize the local token but leave the server side unknown. */
const OUTCOME_TIMEOUT = "timeout";
const OUTCOME_ERROR = "error";
const OUTCOME_ABORT = "abort";
const OUTCOME_WALL_EXPIRY = "wall-expiry";
/** Administrative retirement; never clears and never blocks. */
const OUTCOME_STALE_CHANNEL = "stale-channel";
/** An impossible or ambiguous transition (P1-1). Always uncertain. */
const OUTCOME_ILLEGAL_TRANSITION = "illegal-transition";

const SUCCESS_OUTCOMES = Object.freeze([
  OUTCOME_RESPONSE_END,
  OUTCOME_CONSTRUCTION_FAILED,
]);
const UNCERTAIN_OUTCOMES = Object.freeze([
  OUTCOME_TIMEOUT,
  OUTCOME_ERROR,
  OUTCOME_ABORT,
  OUTCOME_WALL_EXPIRY,
  OUTCOME_ILLEGAL_TRANSITION,
]);
const CALLER_OUTCOMES = Object.freeze([
  OUTCOME_RESPONSE_END,
  OUTCOME_CONSTRUCTION_FAILED,
  OUTCOME_TIMEOUT,
  OUTCOME_ERROR,
  OUTCOME_ABORT,
  OUTCOME_WALL_EXPIRY,
]);

/* ---------------------------------------------------------------- helpers */

function isRecord(value) {
  return !!value && typeof value === "object" && !Array.isArray(value);
}

/** Strict finite number. `typeof` already excludes booleans; the explicit
 *  boolean rejection documents the "boolean-as-number fails closed" rule so a
 *  later refactor cannot reintroduce coercion. */
function isStrictNumber(value) {
  if (typeof value === "boolean") return false;
  return typeof value === "number" && Number.isFinite(value);
}

function isStrictPositive(value) {
  return isStrictNumber(value) && value > 0;
}

function isText(value) {
  return typeof value === "string" && value.length > 0;
}

function fail(code, detail) {
  const out = { ok: false, code: String(code) };
  if (detail !== undefined) out.detail = detail;
  return Object.freeze(out);
}

/** Canonical HTTP(S) origin (P1-4/P1-5). Returns null for anything that is not
 *  a parseable http/https URL, so slash spelling or a trailing path cannot
 *  simulate a different endpoint. */
function canonicalOrigin(value) {
  if (!isText(value)) return null;
  let parsed = null;
  try {
    parsed = new URL(value);
  } catch (_e) {
    return null;
  }
  if (parsed.protocol !== "http:" && parsed.protocol !== "https:") return null;
  if (!parsed.hostname) return null;
  return parsed.origin;
}

/** Freeze a shallow public view so a caller cannot mutate gate state (P1-2). */
function frozenView(source, keys) {
  const out = {};
  for (const key of keys) out[key] = source[key];
  return Object.freeze(out);
}

/* ------------------------------------------------------------------- gate */

class DataBrowserExecutionGate {
  constructor(hooks) {
    const h = isRecord(hooks) ? hooks : {};
    this._now = typeof h.now === "function" ? h.now : () => Date.now();
    this._setTimer = typeof h.setTimer === "function"
      ? h.setTimer
      : ((fn, ms) => setTimeout(fn, ms));
    this._clearTimer = typeof h.clearTimer === "function"
      ? h.clearTimer
      : ((handle) => clearTimeout(handle));
    this._pidAlive = typeof h.pidAlive === "function" ? h.pidAlive : null;

    /** Monotonic epoch. Advanced by rotation AND by a successful reconnect
     *  clearance, so stale token/timer callbacks are fenced (P0-3). */
    this._generation = 1;
    this._origin = null;
    this._uncertain = new Map();
    this._uncertaintySeq = 0;

    this._http = new Map();
    this._reservations = new Map();
    this._waiters = [];
    this._httpHistory = [];
    this._reservationHistory = [];
    this._diagnostics = [];

    this._seqHttp = 0;
    this._seqReservation = 0;
    this._counters = {
      httpAdmitted: 0,
      httpRejected: 0,
      httpSettled: 0,
      httpUncertain: 0,
      httpStale: 0,
      httpIllegal: 0,
      reservations: 0,
      reservationsRejected: 0,
      drainOk: 0,
      drainTimeout: 0,
      drainFailClosed: 0,
      doubleReleases: 0,
      doubleSettles: 0,
      doubleStarts: 0,
      rotations: 0,
      rotationsRejected: 0,
      reconnectResets: 0,
      reconnectRejected: 0,
      prunedHttp: 0,
      prunedReservations: 0,
    };
  }

  get generation() { return this._generation; }

  /* ---------------------------------------------------- operation identity */

  isExecutionOperation(op) {
    return isText(op) && EXECUTION_OPERATIONS.indexOf(op) !== -1;
  }

  /* ---------------------------------------------------------- uncertainty */

  isChannelUncertain() {
    return this._uncertain.has(this._generation);
  }

  /** Uncertainty identity: generation + a monotonic id, so a reconnect callback
   *  can only clear the exact uncertainty it was issued against (P0-3). */
  uncertaintyIdentity() {
    const record = this._uncertain.get(this._generation);
    return record ? frozenView(record, ["generation", "uncertaintyId", "reason", "at"]) : null;
  }

  _markUncertain(generation, reason, token) {
    if (!isStrictNumber(generation)) return;
    if (this._uncertain.has(generation)) return;
    this._uncertaintySeq += 1;
    this._uncertain.set(generation, {
      generation,
      uncertaintyId: "unc-" + this._uncertaintySeq,
      reason: String(reason || "unknown"),
      httpId: token && token.id ? token.id : null,
      path: token && token.path ? token.path : null,
      origin: token && token.origin ? token.origin : null,
      at: this._now(),
    });
    this._counters.httpUncertain += 1;
    // P0-1: any pending waiter in this generation must fail closed now.
    this._pumpWaiters();
  }

  /* ------------------------------------------------------------- pruning */

  _pruneHistory() {
    while (this._httpHistory.length > MAX_TERMINAL_HTTP_HISTORY) {
      this._httpHistory.shift();
      this._counters.prunedHttp += 1;
    }
    while (this._reservationHistory.length > MAX_TERMINAL_RESERVATION_HISTORY) {
      this._reservationHistory.shift();
      this._counters.prunedReservations += 1;
    }
    while (this._diagnostics.length > MAX_DIAGNOSTIC_HISTORY) {
      this._diagnostics.shift();
    }
  }

  /** Move a settled token out of the live map into bounded history (P2-1). */
  _retireHttp(record) {
    this._http.delete(record.id);
    this._httpHistory.push(frozenView(record, [
      "id", "path", "method", "origin", "generation", "admittedAt",
      "startedAt", "settledAt", "socketStarted", "outcome",
    ]));
    this._pruneHistory();
  }

  _retireReservation(record) {
    this._reservations.delete(record.id);
    this._reservationHistory.push(frozenView(record, [
      "id", "op", "runId", "generation", "createdAt", "releasedAt",
    ]));
    this._pruneHistory();
  }

  /* ---------------------------------------------- execution reservation */

  /** Synchronous. Called in `_enqueue` immediately after the op/run id is known
   *  and BEFORE the first await or queue wait. Returns a FROZEN opaque handle;
   *  mutating it cannot alter gate state (P1-2). */
  reserveExecution(meta) {
    const m = isRecord(meta) ? meta : null;
    if (!m) {
      this._counters.reservationsRejected += 1;
      return fail("invalid-reservation-meta");
    }
    if (!this.isExecutionOperation(m.op)) {
      this._counters.reservationsRejected += 1;
      return fail("not-execution-operation", { op: m.op === undefined ? null : m.op });
    }
    if (this.isChannelUncertain()) {
      this._counters.reservationsRejected += 1;
      return fail(CODE_CHANNEL_UNCERTAIN, this.uncertaintyIdentity());
    }
    this._seqReservation += 1;
    const record = {
      id: "exec-" + this._seqReservation,
      op: m.op,
      runId: isText(m.runId) ? m.runId : null,
      generation: this._generation,
      createdAt: this._now(),
      released: false,
      releasedAt: null,
    };
    this._reservations.set(record.id, record);
    this._counters.reservations += 1;
    return Object.freeze({
      ok: true,
      reservation: frozenView(record, ["id", "op", "runId", "generation", "createdAt"]),
    });
  }

  hasActiveReservation() {
    for (const r of this._reservations.values()) if (!r.released) return true;
    return false;
  }

  _reservationRecord(handle) {
    const id = isRecord(handle) ? handle.id : handle;
    if (!isText(id)) return null;
    return this._reservations.get(id) || null;
  }

  /** Released from the REAL internal operation promise `d` in `finally`, never
   *  from the outer `Promise.race([d, c])`. */
  releaseExecution(handle) {
    const held = this._reservationRecord(handle);
    if (!held) {
      const id = isRecord(handle) ? handle.id : handle;
      const wasKnown = this._reservationHistory.some((r) => r.id === id);
      if (wasKnown) {
        this._counters.doubleReleases += 1;
        return fail("already-released", { id });
      }
      return fail(CODE_RESERVATION_UNKNOWN, { id: isText(id) ? id : null });
    }
    if (held.released) {
      this._counters.doubleReleases += 1;
      return fail("already-released", { id: held.id, releasedAt: held.releasedAt });
    }
    held.released = true;
    held.releasedAt = this._now();
    // P0-2: any waiter bound to this reservation must fail closed, not succeed.
    this._pumpWaiters();
    this._retireReservation(held);
    return Object.freeze({ ok: true, id: held.id, releasedAt: held.releasedAt });
  }

  /* --------------------------------------------------------- drain barrier */

  /** Every failure mode carries distinct evidence and never resolves ok:true
   *  (P0-1, P0-2). The budget must be the exact normative value; invalid budgets
   *  are rejected rather than defaulted (P1-3). */
  waitForHttpDrain(handle, budgetMs) {
    // P1-3: the public budget is the exact normative value, not "any positive
    // number". Widening it in a test is how a 37,000 ms drain slipped through.
    if (!isStrictNumber(budgetMs) || budgetMs !== DRAIN_BUDGET_MS) {
      this._counters.drainFailClosed += 1;
      return Promise.resolve(fail(CODE_INVALID_BUDGET, {
        budgetMs: isStrictNumber(budgetMs) ? budgetMs : null,
        expected: DRAIN_BUDGET_MS,
      }));
    }
    const held = this._reservationRecord(handle);
    if (!held) {
      this._counters.drainFailClosed += 1;
      return Promise.resolve(fail(CODE_RESERVATION_UNKNOWN));
    }
    if (held.released) {
      this._counters.drainFailClosed += 1;
      return Promise.resolve(fail(CODE_RESERVATION_RELEASED, { id: held.id }));
    }
    if (held.generation !== this._generation) {
      this._counters.drainFailClosed += 1;
      return Promise.resolve(fail(CODE_RESERVATION_STALE, {
        id: held.id, reservationGeneration: held.generation,
        currentGeneration: this._generation,
      }));
    }
    if (this.isChannelUncertain()) {
      this._counters.drainFailClosed += 1;
      return Promise.resolve(fail(CODE_CHANNEL_UNCERTAIN, this.uncertaintyIdentity()));
    }

    const startedAt = this._now();
    const blocking = this._blockingHttpFor(held);
    if (blocking.length === 0) {
      this._counters.drainOk += 1;
      return Promise.resolve(Object.freeze({
        ok: true, waitedMs: 0, pendingAtEntry: 0,
      }));
    }
    return new Promise((resolve) => {
      const waiter = {
        reservationId: held.id,
        generation: held.generation,
        pendingAtEntry: blocking.length,
        startedAt,
        settled: false,
        timer: null,
        resolve,
      };
      waiter.timer = this._setTimer(
        () => this._settleWaiter(waiter, { kind: "timeout" }), budgetMs);
      this._waiters.push(waiter);
      this._pumpWaiters();
    });
  }

  /** Same generation, still open, admitted strictly before the reservation. */
  _blockingHttpFor(reservation) {
    const out = [];
    for (const token of this._http.values()) {
      if (token.outcome !== null) continue;
      if (token.generation !== reservation.generation) continue;
      if (token.admittedAt > reservation.createdAt) continue;
      out.push(token.id);
    }
    return out;
  }

  _openTokensIn(generation) {
    const out = [];
    for (const token of this._http.values()) {
      if (token.outcome !== null) continue;
      if (token.generation !== generation) continue;
      out.push(Object.freeze({
        id: token.id,
        path: token.path,
        origin: token.origin,
        ageMs: this._now() - token.admittedAt,
        socketStarted: token.socketStarted,
      }));
    }
    return out;
  }

  _settleWaiter(waiter, verdict) {
    if (waiter.settled) return;
    waiter.settled = true;
    if (waiter.timer !== null) {
      this._clearTimer(waiter.timer);
      waiter.timer = null;
    }
    const index = this._waiters.indexOf(waiter);
    if (index !== -1) this._waiters.splice(index, 1);
    const waitedMs = this._now() - waiter.startedAt;

    if (verdict.kind === "drained") {
      this._counters.drainOk += 1;
      waiter.resolve(Object.freeze({
        ok: true, waitedMs, pendingAtEntry: waiter.pendingAtEntry,
      }));
      return;
    }
    if (verdict.kind === "timeout") {
      this._counters.drainTimeout += 1;
      waiter.resolve(Object.freeze({
        ok: false,
        code: CODE_HTTP_DRAIN_TIMEOUT,
        waitedMs,
        pendingAtEntry: waiter.pendingAtEntry,
        pending: Object.freeze(this._openTokensIn(waiter.generation)),
      }));
      return;
    }
    this._counters.drainFailClosed += 1;
    waiter.resolve(Object.freeze({
      ok: false,
      code: verdict.code,
      waitedMs,
      pendingAtEntry: waiter.pendingAtEntry,
      detail: verdict.detail === undefined ? null : verdict.detail,
    }));
  }

  /** Re-evaluates every pending waiter. Order matters: uncertainty and
   *  reservation validity are checked BEFORE "zero blocking tokens", because a
   *  token that failed is simultaneously "no longer blocking" and a reason to
   *  refuse (P0-1). */
  _pumpWaiters() {
    for (const waiter of this._waiters.slice()) {
      if (waiter.settled) continue;
      const reservation = this._reservations.get(waiter.reservationId);
      if (!reservation) {
        this._settleWaiter(waiter, {
          kind: "closed", code: CODE_RESERVATION_UNKNOWN,
          detail: { id: waiter.reservationId },
        });
        continue;
      }
      if (reservation.released) {
        this._settleWaiter(waiter, {
          kind: "closed", code: CODE_RESERVATION_RELEASED,
          detail: { id: reservation.id },
        });
        continue;
      }
      if (reservation.generation !== this._generation) {
        this._settleWaiter(waiter, {
          kind: "closed", code: CODE_RESERVATION_STALE,
          detail: {
            id: reservation.id,
            reservationGeneration: reservation.generation,
            currentGeneration: this._generation,
          },
        });
        continue;
      }
      if (this._uncertain.has(waiter.generation) || this.isChannelUncertain()) {
        this._settleWaiter(waiter, {
          kind: "closed", code: CODE_CHANNEL_UNCERTAIN,
          detail: this._uncertain.get(waiter.generation)
            ? frozenView(this._uncertain.get(waiter.generation),
                ["generation", "uncertaintyId", "reason", "at"])
            : this.uncertaintyIdentity(),
        });
        continue;
      }
      if (this._blockingHttpFor(reservation).length === 0) {
        this._settleWaiter(waiter, { kind: "drained" });
      }
    }
  }

  /* ------------------------------------------------------- HTTP admission */

  /** Requires a canonical http(s) origin and binds the token to it (P1-4).
   *  Returns a FROZEN opaque handle (P1-2). */
  beginHttp(meta) {
    const m = isRecord(meta) ? meta : null;
    if (!m) {
      this._counters.httpRejected += 1;
      return fail("invalid-http-meta");
    }
    if (!isText(m.path)) {
      this._counters.httpRejected += 1;
      return fail("invalid-http-path");
    }
    const origin = canonicalOrigin(m.baseUrl);
    if (!origin) {
      this._counters.httpRejected += 1;
      return fail("invalid-http-origin", {
        baseUrl: isText(m.baseUrl) ? m.baseUrl : null,
      });
    }
    if (this.hasActiveReservation()) {
      this._counters.httpRejected += 1;
      return fail(CODE_EXECUTION_RESERVED, { path: m.path });
    }
    if (this.isChannelUncertain()) {
      this._counters.httpRejected += 1;
      return fail(CODE_CHANNEL_UNCERTAIN, this.uncertaintyIdentity());
    }
    if (this._origin === null) this._origin = origin;
    if (origin !== this._origin) {
      this._counters.httpRejected += 1;
      return fail("stale-origin", { requested: origin, current: this._origin });
    }
    this._seqHttp += 1;
    const record = {
      id: "http-" + this._seqHttp,
      path: m.path,
      method: isText(m.method) ? m.method : "GET",
      origin,
      generation: this._generation,
      admittedAt: this._now(),
      startedAt: null,
      socketStarted: false,
      outcome: null,
      settledAt: null,
      wallTimer: null,
    };
    this._http.set(record.id, record);
    this._counters.httpAdmitted += 1;
    return Object.freeze({
      ok: true,
      token: frozenView(record, ["id", "path", "method", "origin", "generation", "admittedAt"]),
    });
  }

  _httpRecord(handle) {
    const id = isRecord(handle) ? handle.id : handle;
    if (!isText(id)) return null;
    return this._http.get(id) || null;
  }

  /** Exactly one start (P1-1). A repeated start is an illegal transition and
   *  makes the generation uncertain rather than silently succeeding. */
  markHttpStarted(handle) {
    const held = this._httpRecord(handle);
    if (!held) return fail("unknown-http-token");
    if (held.outcome !== null) return fail("already-settled", { id: held.id });
    if (held.socketStarted) {
      this._counters.doubleStarts += 1;
      this._counters.httpIllegal += 1;
      this._terminate(held, OUTCOME_ILLEGAL_TRANSITION, "duplicate-start");
      return fail("already-started", { id: held.id });
    }
    held.socketStarted = true;
    held.startedAt = this._now();
    return Object.freeze({ ok: true, id: held.id, startedAt: held.startedAt });
  }

  /** Single terminal transition point. Sets the outcome, clears the watchdog,
   *  marks uncertainty when required, retires the record into bounded history,
   *  then re-evaluates waiters. */
  _terminate(record, outcome, reason) {
    record.outcome = outcome;
    record.settledAt = this._now();
    if (record.wallTimer !== null) {
      this._clearTimer(record.wallTimer);
      record.wallTimer = null;
    }
    this._counters.httpSettled += 1;
    if (outcome === OUTCOME_STALE_CHANNEL) this._counters.httpStale += 1;
    const uncertainNow = UNCERTAIN_OUTCOMES.indexOf(outcome) !== -1;
    this._retireHttp(record);
    if (uncertainNow) {
      // _markUncertain pumps waiters itself, which is where P0-1 is enforced.
      this._markUncertain(record.generation, reason || outcome, record);
    } else {
      this._pumpWaiters();
    }
  }

  /** Strict state machine (P1-1):
   *   - before start: only `construction-failed` is safe; every other caller
   *     outcome is impossible and therefore uncertain;
   *   - after start: `response-end` is the only safe settlement;
   *     `construction-failed` is impossible and downgraded to uncertain. */
  finishHttp(handle, outcome) {
    const held = this._httpRecord(handle);
    if (!held) {
      const id = isRecord(handle) ? handle.id : handle;
      const known = this._httpHistory.some((r) => r.id === id);
      if (known) {
        this._counters.doubleSettles += 1;
        return fail("already-settled", { id: isText(id) ? id : null });
      }
      return fail("unknown-http-token");
    }
    if (!isText(outcome) || CALLER_OUTCOMES.indexOf(outcome) === -1) {
      return fail("invalid-outcome", {
        outcome: isText(outcome) ? outcome : null,
      });
    }
    if (held.generation !== this._generation) {
      // A retired endpoint can neither block nor clear the live generation.
      this._terminate(held, OUTCOME_STALE_CHANNEL, "stale-generation");
      return Object.freeze({
        ok: true, id: held.id, outcome: OUTCOME_STALE_CHANNEL, stale: true,
      });
    }

    let effective = outcome;
    let illegal = false;
    if (!held.socketStarted) {
      if (outcome !== OUTCOME_CONSTRUCTION_FAILED) {
        effective = OUTCOME_ILLEGAL_TRANSITION;
        illegal = true;
      }
    } else if (outcome === OUTCOME_CONSTRUCTION_FAILED) {
      effective = OUTCOME_ILLEGAL_TRANSITION;
      illegal = true;
    }
    if (illegal) this._counters.httpIllegal += 1;
    this._terminate(held, effective, illegal ? "illegal:" + outcome : outcome);
    return Object.freeze({
      ok: !illegal,
      code: illegal ? OUTCOME_ILLEGAL_TRANSITION : undefined,
      id: held.id,
      outcome: effective,
      stale: false,
      uncertain: this.isChannelUncertain(),
    });
  }

  /** May be armed only after the unique start (P1-1). */
  armWallWatchdog(handle, onExpiry) {
    const held = this._httpRecord(handle);
    if (!held) return fail("unknown-http-token");
    if (held.outcome !== null) return fail("already-settled", { id: held.id });
    if (!held.socketStarted) return fail("not-started", { id: held.id });
    if (held.wallTimer !== null) return fail("already-armed", { id: held.id });
    const armedGeneration = held.generation;
    const armedId = held.id;
    held.wallTimer = this._setTimer(() => {
      const live = this._http.get(armedId);
      // Fence stale timers: rotation/reset retires the record or moves the epoch.
      if (!live || live.outcome !== null || live.generation !== armedGeneration) return;
      live.wallTimer = null;
      this._terminate(live, OUTCOME_WALL_EXPIRY, OUTCOME_WALL_EXPIRY);
      if (typeof onExpiry === "function") onExpiry(armedId);
    }, WALL_SETTLE_MS);
    return Object.freeze({ ok: true, id: held.id, wallMs: WALL_SETTLE_MS });
  }

  /* ------------------------------------------- channel rotation / recovery */

  _retireGeneration(generation, reason) {
    const retired = [];
    for (const token of Array.from(this._http.values())) {
      if (token.outcome !== null) continue;
      if (token.generation !== generation) continue;
      token.outcome = OUTCOME_STALE_CHANNEL;
      token.settledAt = this._now();
      if (token.wallTimer !== null) {
        this._clearTimer(token.wallTimer);
        token.wallTimer = null;
      }
      this._counters.httpStale += 1;
      this._counters.httpSettled += 1;
      retired.push(token.id);
      this._retireHttp(token);
    }
    this._uncertain.delete(generation);
    return retired;
  }

  /** Requires strict `verifiedFresh === true`, the exact expected current
   *  generation, the exact expected prior canonical origin, and a canonically
   *  CHANGED http(s) origin (P1-5). */
  rotateChannel(meta) {
    const m = isRecord(meta) ? meta : null;
    if (!m) { this._counters.rotationsRejected += 1; return fail("invalid-rotation-meta"); }
    if (m.verifiedFresh !== true) {
      this._counters.rotationsRejected += 1;
      return fail("rotation-not-verified-fresh", {
        verifiedFresh: m.verifiedFresh === undefined ? null : m.verifiedFresh,
      });
    }
    if (!isStrictNumber(m.expectedGeneration) || m.expectedGeneration !== this._generation) {
      this._counters.rotationsRejected += 1;
      return fail("rotation-generation-mismatch", {
        expected: isStrictNumber(m.expectedGeneration) ? m.expectedGeneration : null,
        current: this._generation,
      });
    }
    const next = canonicalOrigin(m.baseUrl);
    if (!next) {
      this._counters.rotationsRejected += 1;
      return fail("invalid-rotation-origin", {
        baseUrl: isText(m.baseUrl) ? m.baseUrl : null,
      });
    }
    const expectedPrior = m.expectedPriorBaseUrl === undefined
      ? undefined
      : canonicalOrigin(m.expectedPriorBaseUrl);
    if (expectedPrior === undefined || expectedPrior !== this._origin) {
      this._counters.rotationsRejected += 1;
      return fail("rotation-prior-origin-mismatch", {
        expectedPrior: expectedPrior === undefined ? null : expectedPrior,
        current: this._origin,
      });
    }
    if (next === this._origin) {
      this._counters.rotationsRejected += 1;
      return fail("rotation-origin-unchanged", { origin: next });
    }
    const previousGeneration = this._generation;
    const retired = this._retireGeneration(previousGeneration, "rotation");
    this._generation += 1;
    this._origin = next;
    this._counters.rotations += 1;
    this._pumpWaiters();
    return Object.freeze({
      ok: true,
      generation: this._generation,
      previousGeneration,
      origin: this._origin,
      retired: Object.freeze(retired),
    });
  }

  /** Bound to an exact generation and uncertainty identity captured BEFORE the
   *  reconnect, so a delayed callback cannot clear a newer generation (P0-3).
   *  On success the epoch advances, which fences old token and timer callbacks.
   *  There is deliberately no generic public clear API. */
  resetAfterReconnect(meta) {
    const m = isRecord(meta) ? meta : null;
    if (!m) { this._counters.reconnectRejected += 1; return fail("invalid-reconnect-meta"); }
    if (m.reconnectOk !== true) {
      this._counters.reconnectRejected += 1;
      return fail("reconnect-not-ok", {
        reconnectOk: m.reconnectOk === undefined ? null : m.reconnectOk,
      });
    }
    if (!isStrictNumber(m.expectedGeneration) || m.expectedGeneration !== this._generation) {
      this._counters.reconnectRejected += 1;
      return fail("reconnect-generation-mismatch", {
        expected: isStrictNumber(m.expectedGeneration) ? m.expectedGeneration : null,
        current: this._generation,
      });
    }
    const live = this._uncertain.get(this._generation) || null;
    const liveId = live ? live.uncertaintyId : null;
    // The caller must pass the identity it captured before the reconnect. `null`
    // is the exact identity of a HEALTHY generation, so a force-reset over a
    // live-but-not-yet-failed request still fences the old tokens (P0-2). The
    // key must be present explicitly; a missing key is not the same as null.
    if (!Object.prototype.hasOwnProperty.call(m, "expectedUncertaintyId")) {
      this._counters.reconnectRejected += 1;
      return fail("reconnect-uncertainty-identity-required", { current: liveId });
    }
    const expectedId = m.expectedUncertaintyId === null
      ? null
      : (isText(m.expectedUncertaintyId) ? m.expectedUncertaintyId : undefined);
    if (expectedId === undefined || expectedId !== liveId) {
      this._counters.reconnectRejected += 1;
      return fail("reconnect-uncertainty-mismatch", {
        expected: m.expectedUncertaintyId === null ? null : m.expectedUncertaintyId,
        current: liveId,
      });
    }
    const previousGeneration = this._generation;
    const cleared = live
      ? frozenView(live, ["generation", "uncertaintyId", "reason", "at"])
      : null;
    const retired = this._retireGeneration(previousGeneration, "reconnect");
    this._generation += 1;
    const nextOrigin = canonicalOrigin(m.baseUrl);
    if (nextOrigin) this._origin = nextOrigin;
    this._counters.reconnectResets += 1;
    this._pumpWaiters();
    return Object.freeze({
      ok: true,
      generation: this._generation,
      previousGeneration,
      cleared,
      retired: Object.freeze(retired),
      origin: this._origin,
    });
  }

  /* --------------------------------------------- diagnostics and snapshot */

  _liveHttpCensus() {
    const out = [];
    for (const token of this._http.values()) {
      out.push(Object.freeze({
        id: token.id,
        path: token.path,
        method: token.method,
        origin: token.origin,
        generation: token.generation,
        ageMs: this._now() - token.admittedAt,
        socketStarted: token.socketStarted,
        responseEndObserved: token.outcome === OUTCOME_RESPONSE_END,
        settled: token.outcome !== null,
        outcome: token.outcome,
      }));
    }
    return out;
  }

  _liveReservationCensus() {
    const out = [];
    for (const r of this._reservations.values()) {
      out.push(Object.freeze({
        id: r.id, op: r.op, runId: r.runId, generation: r.generation,
        ageMs: this._now() - r.createdAt, released: r.released,
      }));
    }
    return out;
  }

  _budgets() {
    return Object.freeze({
      httpDrainMs: DRAIN_BUDGET_MS,
      socketIdleMs: SOCKET_IDLE_TIMEOUT_MS,
      wallSettleMs: WALL_SETTLE_MS,
      progressSentinelMs: PROGRESS_SENTINEL_MS,
    });
  }

  /** Captured BEFORE a product-owned force reset tears the backend down, so a
   *  later stall can be attributed. A census proving zero overlapping HTTP
   *  points at the server/execution channel rather than this concurrency. */
  captureDiagnostic(meta) {
    const m = isRecord(meta) ? meta : {};
    const pids = Array.isArray(m.ownedPids) ? m.ownedPids.filter(isStrictPositive) : [];
    const pidSamples = pids.map((pid) => {
      let alive = null;
      if (this._pidAlive) {
        try { alive = this._pidAlive(pid) === true; } catch (_e) { alive = null; }
      }
      return Object.freeze({ pid, alive });
    });
    const live = this._liveHttpCensus();
    const record = Object.freeze({
      at: this._now(),
      reason: isText(m.reason) ? m.reason : "unspecified",
      runId: isText(m.runId) ? m.runId : null,
      generation: this._generation,
      origin: this._origin,
      channelUncertain: this.isChannelUncertain(),
      uncertainty: this.uncertaintyIdentity(),
      http: Object.freeze(live),
      openHttpCount: live.filter((t) => !t.settled).length,
      recentHttp: Object.freeze(this._httpHistory.slice(-MAX_TERMINAL_HTTP_HISTORY)),
      reservations: Object.freeze(this._liveReservationCensus()),
      activeReservation: this.hasActiveReservation(),
      ownedPids: Object.freeze(pidSamples),
      budgets: this._budgets(),
    });
    this._diagnostics.push(record);
    this._pruneHistory();
    return Object.freeze({ ok: true, diagnostic: record });
  }

  get lastDiagnostic() {
    return this._diagnostics.length
      ? this._diagnostics[this._diagnostics.length - 1]
      : null;
  }

  snapshot() {
    const live = this._liveHttpCensus();
    return Object.freeze({
      version: GATE_VERSION,
      generation: this._generation,
      origin: this._origin,
      channelUncertain: this.isChannelUncertain(),
      uncertainty: this.uncertaintyIdentity(),
      uncertainGenerations: Object.freeze(Array.from(this._uncertain.keys())),
      activeReservation: this.hasActiveReservation(),
      reservations: Object.freeze(this._liveReservationCensus()),
      http: Object.freeze(live),
      openHttpCount: live.filter((t) => !t.settled).length,
      recentHttp: Object.freeze(this._httpHistory.slice(-MAX_TERMINAL_HTTP_HISTORY)),
      recentReservations: Object.freeze(
        this._reservationHistory.slice(-MAX_TERMINAL_RESERVATION_HISTORY)),
      drainWaiters: this._waiters.length,
      counters: Object.freeze(Object.assign({}, this._counters)),
      budgets: this._budgets(),
      historyLimits: Object.freeze({
        http: MAX_TERMINAL_HTTP_HISTORY,
        reservations: MAX_TERMINAL_RESERVATION_HISTORY,
        diagnostics: MAX_DIAGNOSTIC_HISTORY,
      }),
      lastDiagnostic: this.lastDiagnostic,
    });
  }
}

/* ------------------------------------------------------------- singleton */

let sharedGate = null;

/** One shared singleton for both the MCP and Data Browser code paths. */
function getSharedGate(hooks) {
  if (!sharedGate) sharedGate = new DataBrowserExecutionGate(hooks);
  return sharedGate;
}

/** Test-only reset; never called from runtime paths. */
function __resetSharedGateForTests() {
  sharedGate = null;
}

/** True when an error code came from this gate and therefore must NOT consume
 *  or trigger the Data Browser dataset credential-recovery tries. */
function isGateErrorCode(code) {
  return isText(code) && GATE_ERROR_CODES.indexOf(code) !== -1;
}

module.exports = {
  DataBrowserExecutionGate,
  getSharedGate,
  __resetSharedGateForTests,
  isGateErrorCode,
  canonicalOrigin,
  GATE_VERSION,
  EXECUTION_OPERATIONS,
  GATE_ERROR_CODES,
  DRAIN_BUDGET_MS,
  SOCKET_IDLE_TIMEOUT_MS,
  WALL_SETTLE_MS,
  PROGRESS_SENTINEL_MS,
  MAX_TERMINAL_HTTP_HISTORY,
  MAX_TERMINAL_RESERVATION_HISTORY,
  MAX_DIAGNOSTIC_HISTORY,
  CODE_EXECUTION_RESERVED,
  CODE_CHANNEL_UNCERTAIN,
  CODE_HTTP_DRAIN_TIMEOUT,
  CODE_RESERVATION_RELEASED,
  CODE_RESERVATION_UNKNOWN,
  CODE_RESERVATION_STALE,
  CODE_INVALID_BUDGET,
  OUTCOME_RESPONSE_END,
  OUTCOME_CONSTRUCTION_FAILED,
  OUTCOME_TIMEOUT,
  OUTCOME_ERROR,
  OUTCOME_ABORT,
  OUTCOME_WALL_EXPIRY,
  OUTCOME_STALE_CHANNEL,
  OUTCOME_ILLEGAL_TRANSITION,
};













