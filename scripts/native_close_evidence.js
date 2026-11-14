"use strict";

// Evidence for the real extension deactivation entrypoint, never a close driver.
// Deactivation can also mean reload/disable: native window action provenance is
// separate. One best-effort, exclusive record; failures never gate shutdown.
const fs = require("node:fs");
const path = require("node:path");
const attempts = new WeakMap();
const FILE = "native-deactivate-admission.json";

function capture(life, store = globalThis, io = fs) {
  if (attempts.has(life)) return attempts.get(life);
  attempts.set(life, { state: "capture-in-progress" }); // before any callback/reentry
  let outcome;
  try {
    const manager = store.__codexWindowSession;
    if (!manager || typeof store.__codexVisibleState !== "function") throw new Error("STATUS_UNAVAILABLE");
    if (!/^[A-Za-z0-9_-]{1,80}$/.test(manager.sessionId || "") ||
        !path.isAbsolute(manager.stateRoot || "") || !path.isAbsolute(manager.dataDir || "") ||
        path.resolve(manager.dataDir) !== path.join(path.resolve(manager.stateRoot), "runs", manager.sessionId))
      throw new Error("WINDOW_DIRECTORY_MISMATCH");
    const directory = io.lstatSync(manager.dataDir);
    if (!directory.isDirectory() || directory.isSymbolicLink()) throw new Error("WINDOW_DIRECTORY_UNVERIFIED");
    const current = store.__codexVisibleState(), state = life.status();
    const validInt = value => Number.isSafeInteger(value) && value >= 0;
    if (current?.nextSession?.sessionId !== manager.sessionId || current.extensionHostPid !== process.pid ||
        !validInt(current.resetGeneration) || !/^[a-f0-9]{64}$/.test(current.diskBundleSha256 || "") ||
        !validInt(state.epoch) || !validInt(state.pendingAttempts) || typeof state.closing !== "boolean" ||
        typeof current.busy !== "boolean" || typeof current.trueReady !== "boolean")
      throw new Error("PUBLIC_IDENTITY_UNVERIFIED");
    const monotonicMs = life.now();
    if (!Number.isFinite(monotonicMs) || monotonicMs < 0) throw new Error("MONOTONIC_TIME_UNAVAILABLE");
    // Detached scalars only. Never copy private recovery objects, auth, raw
    // transport state, stack traces, or the possibly stale top-level runId.
    const snapshot = {
      schema: "stata-native-deactivate-admission/1", entrypoint: "vscode-extension-deactivate",
      capturedBeforeShutdownInvocation: true, sessionId: manager.sessionId,
      extensionHostPid: process.pid, generation: current.resetGeneration,
      bundleSha256: current.diskBundleSha256, observedAtUtc: new Date().toISOString(), monotonicMs,
      lifecycleEpoch: state.epoch, pendingAttempts: state.pendingAttempts, closing: state.closing,
      endpointClosePreviouslyRequested: store.__codexWindowCloseRequested === true,
      trueReady: current.trueReady, busy: current.busy,
      runId: current.busy && typeof current.current?.runId === "string" ? current.current.runId : null,
      recovery: { required: current.recovery?.required === true,
        generation: validInt(current.recovery?.generation) ? current.recovery.generation : null,
        activeRunId: typeof current.recovery?.activeRunId === "string" ? current.recovery.activeRunId : null },
    };
    io.writeFileSync(path.join(manager.dataDir, FILE), JSON.stringify(snapshot, null, 2) + "\n",
      { flag: "wx", mode: 0o600 });
    outcome = { state: "recorded" };
  } catch {
    // An existing/partial file stays untouched. No new name, overwrite, retry,
    // or exception details are produced; lack of proof remains unproven.
    outcome = { state: "unavailable" };
  }
  attempts.set(life, outcome);
  return outcome;
}

module.exports = { capture, FILE };
