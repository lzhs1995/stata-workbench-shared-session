"use strict";

// A no-op is allowed only before any backend preparation or execution history.
// All observations are synchronous: no queue turn, connection, or reservation is
// created between the proof and the return. Unknown state keeps the normal Stop.
function coldNoop(client, globals, reason) {
  try {
    const emptyMap = value => value instanceof Map && value.size === 0;
    const emptyList = value => Array.isArray(value) && value.length === 0;
    if (!client || client._clientPromise !== null || client._transport !== null
        || client._active !== false || client._pending !== 0 || client._activeRun !== null
        || client._activeCancellation !== null
        || !emptyMap(client._cancellationSourcesByRunId) || !emptyMap(client._runsByTaskId)
        || !emptyMap(client._runCleanupTimers)) return null;

    const manager = globals.__codexWindowSession;
    const window = manager.status();
    if (window.phase !== "idle" || window.closing !== false || window.slot !== null
        || window.lastError !== null || manager.getConfig() !== null) return null;
    const backend = client.__codexLifecycle().status();
    if (backend.closing !== false || backend.epoch !== 0 || backend.pendingAttempts !== 0
        || backend.lastShutdown !== null || backend.lastAdmission !== null
        || !emptyList(backend.transports) || !emptyMap(globals.__codexOwnedBackendPids)) return null;

    const bridge = globals.__codexBridgeState, life = bridge.lifecycle;
    if (bridge.busy !== false || bridge.postRunBusy !== false || bridge.runId != null
        || !life || life.phase !== "idle" || life.runId != null || life.requestId != null
        || life.startedAt != null || bridge.lastCompletedRun != null) return null;
    const start = globals.__codexBackendStartSummary();
    if (start.connected !== false || start.current !== null || start.lastCold !== null
        || globals.__codexBackendWarmupSummary() !== null
        || globals.__codexPreRunStage != null || globals.__codexActivePreRunSnapshot != null
        || !emptyMap(globals.__codexPreRunSnapshots)) return null;

    const recovery = globals.__codexRecoveryState;
    if (!recovery || recovery.required !== false || recovery.generation !== 0
        || recovery.activeRunId != null || recovery.lastAttempt != null
        || (globals.__codexResetGeneration !== undefined && globals.__codexResetGeneration !== 0)
        || globals.__codexContinuityLost
        || globals.__codexUnresolvedCleanup != null
        || globals.__codexGuardCancelBusy || globals.__codexSoftStopInFlight
        || globals.__codexWindowCloseRequested) return null;
    const restore = globals.__codexRestoreReadinessRef.status();
    const outcomes = globals.__codexPendingOutcomesRef.status();
    if (restore.active !== false || restore.ready !== true || restore.runId != null
        || outcomes.pending !== 0 || !emptyList(outcomes.entries)) return null;
    const gate = globals.__codexDbGate.snapshot();
    if (gate.channelUncertain !== false || gate.uncertainty != null
        || !emptyList(gate.uncertainGenerations) || gate.activeReservation !== false
        || !emptyList(gate.reservations) || !emptyList(gate.http)
        || gate.openHttpCount !== 0 || gate.drainWaiters !== 0) return null;

    return { at: new Date().toISOString(), ok: true, noop: true, runId: null,
      generation: 0, cancelled: false, restored: false,
      skipped: "cold idle session has no work", reason: String(reason || "user") };
  } catch {
    // Missing, throwing or partially initialized evidence is never a cold proof.
    return null;
  }
}

module.exports = { coldNoop };
