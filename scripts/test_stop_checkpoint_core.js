#!/usr/bin/env node
"use strict";

const assert = require("assert");
const fs = require("fs");
const os = require("os");
const path = require("path");
const checkpoint = require("./stop_checkpoint_core");

const root = fs.mkdtempSync(path.join(os.tmpdir(), "stop-checkpoint-core-"));
const snapshot = {
  path: path.join(root, "state.dta"),
  bytes: 1024,
  runId: "unit-run",
  sourceMode: "agent",
};

function writeCheckpointFiles(target) {
  const paths = checkpoint.checkpointPaths(target);
  fs.writeFileSync(paths.globalsPath, "RC7_GLOBAL\tdmFsdWU=\n", "utf8");
  fs.writeFileSync(paths.estimatesPath, "good_est\n../bad\n", "utf8");
  fs.writeFileSync(paths.graphsPath, "good_graph\nbad-name\n", "utf8");
  fs.writeFileSync(paths.currentGraphPath, "good_graph\n", "utf8");
  fs.writeFileSync(paths.defaultGraphObjectPath, "0\n", "utf8");
  fs.writeFileSync(path.join(paths.stateDir, "estimate_good_est.ster"), "est", "utf8");
  fs.writeFileSync(path.join(paths.stateDir, "graph_good_graph.gph"), "graph", "utf8");
}

function writeSnapshotReady(target) {
  const paths = checkpoint.checkpointPaths(target);
  fs.writeFileSync(
    paths.snapshotReadyPath,
    `ready\t${target.checkpointNonce}\t${target.snapshotKind || "data"}\n`,
    "utf8"
  );
}

try {
  snapshot.checkpointNonce = "1".repeat(32);
  fs.writeFileSync(snapshot.path, Buffer.alloc(1024, 1));
  assert.strictEqual(checkpoint.isRestoreCapable(snapshot), true);
  assert.strictEqual(checkpoint.isSnapshotReady(snapshot), false);
  fs.mkdirSync(checkpoint.checkpointPaths(snapshot).stateDir, { recursive: true });
  writeSnapshotReady(snapshot);
  assert.strictEqual(checkpoint.isSnapshotReady(snapshot), true);
  assert.strictEqual(checkpoint.snapshotReadyRecord(snapshot).kind, "data");
  fs.writeFileSync(
    checkpoint.checkpointPaths(snapshot).snapshotReadyPath,
    `ready\t${"2".repeat(32)}\tdata\n`,
    "utf8"
  );
  assert.strictEqual(checkpoint.isSnapshotReady(snapshot), false, "stale nonce must be rejected");
  writeSnapshotReady(snapshot);
  assert.strictEqual(checkpoint.isRestoreCapable(null), false);
  assert.strictEqual(checkpoint.isRestoreCapable({}), false);
  assert.strictEqual(checkpoint.isRestoreCapable({ path: path.join(root, "missing.dta") }), false);
  const partialPath = path.join(root, "partial.dta");
  fs.writeFileSync(partialPath, Buffer.alloc(511, 1));
  assert.strictEqual(checkpoint.isRestoreCapable(Object.freeze({ path: partialPath })), false);
  fs.writeFileSync(partialPath, Buffer.alloc(512, 1));
  assert.strictEqual(checkpoint.isRestoreCapable(Object.freeze({ path: partialPath })), true);
  assert.strictEqual(checkpoint.shouldCleanupAfterFailure(null), true);
  assert.strictEqual(checkpoint.shouldCleanupAfterFailure(Object.freeze({ stopOwned: false })), true);
  assert.strictEqual(checkpoint.shouldCleanupAfterFailure(Object.freeze({ stopOwned: true })), false);
  assert.strictEqual(checkpoint.restoreTimeoutMs(null), 30000);
  assert.strictEqual(checkpoint.restoreTimeoutMs({ estimateCount: 4, graphCount: 8 }), 33000);
  assert.strictEqual(checkpoint.restoreTimeoutMs({ estimateCount: 60, graphCount: 60 }), 45000);
  assert.strictEqual(checkpoint.restoreTimeoutMs({ estimateCount: -1, graphCount: "bad" }), 30000);
  assert.strictEqual(checkpoint.restoreTimeoutMs({ estimateCount: 100000, graphCount: 100000 }), 45000);
  const unreadableOwnership = {};
  Object.defineProperty(unreadableOwnership, "stopOwned", {
    get() { throw new Error("ownership unavailable"); },
  });
  assert.strictEqual(
    checkpoint.shouldCleanupAfterFailure(unreadableOwnership),
    false,
    "unreadable cleanup ownership must retain the only restore-capable snapshot"
  );
  assert.deepStrictEqual(
    checkpoint.softStopReadiness({ ok: true }, null),
    {
      ready: true,
      readinessState: "ready",
      readinessReason: "soft-stop-complete",
      lastClientError: null,
      recoveryClass: "RECOVERED_FULL",
      continuityLost: null,
    }
  );
  const degradedRecovery = checkpoint.softStopReadiness({
    ok: true,
    degraded: {
      mode: "dataset-only",
      skippedEstimates: 3,
      skippedGraphs: 2,
      datasetRestored: true,
      globalsRestored: true,
    },
  }, null);
  assert.strictEqual(degradedRecovery.ready, false);
  assert.strictEqual(degradedRecovery.readinessState, "stale");
  assert.strictEqual(degradedRecovery.readinessReason, "soft-stop-degraded-recovery");
  assert.strictEqual(degradedRecovery.recoveryClass, "RECOVERED_DEGRADED");
  assert.deepStrictEqual(degradedRecovery.continuityLost, {
    reason: "soft-stop-degraded-recovery",
    detail: "dataset/globals restored, but 3 estimates and 2 graphs were not restored",
    skippedEstimates: 3,
    skippedGraphs: 2,
    datasetRestored: true,
    globalsRestored: true,
  });
  const zeroLossDowngrade = checkpoint.softStopReadiness({
    ok: true,
    degraded: {
      mode: "dataset-only",
      skippedEstimates: 0,
      skippedGraphs: 0,
      datasetRestored: true,
      globalsRestored: true,
    },
  }, null);
  assert.strictEqual(zeroLossDowngrade.ready, true);
  assert.strictEqual(zeroLossDowngrade.recoveryClass, "RECOVERED_FULL");
  const resetRecovered = checkpoint.softStopReadiness(
    { ok: false, error: "STOP_RESTORE_TIMEOUT" },
    { ok: true, trueReady: true }
  );
  assert.strictEqual(resetRecovered.ready, false);
  assert.strictEqual(resetRecovered.readinessReason, "soft-stop-checkpoint-not-restored");
  assert.strictEqual(resetRecovered.recoveryClass, "RECOVERY_FAILED");
  assert.strictEqual(resetRecovered.continuityLost.reason,
    "soft-stop-checkpoint-not-restored");
  assert.ok(resetRecovered.lastClientError.includes("STOP_RESTORE_TIMEOUT"));
  for (const hardReset of [
    null,
    {},
    { ok: false, trueReady: true },
    { ok: true, trueReady: false },
    { ok: true, trueReady: true, retry: { ok: false, trueReady: false } },
  ]) {
    const failed = checkpoint.softStopReadiness(
      { ok: false, error: "STOP_RESTORE_TIMEOUT" }, hardReset
    );
    assert.strictEqual(failed.ready, false);
    assert.strictEqual(failed.readinessState, "stale");
    assert.strictEqual(failed.recoveryClass, "RECOVERY_FAILED");
    assert.ok(failed.continuityLost);
  }
  const throwingReset = {};
  Object.defineProperty(throwingReset, "retry", {
    get() { throw new Error("reset identity unreadable"); },
  });
  const unreadableReadiness = checkpoint.softStopReadiness(
    { ok: false, error: "STOP_RESTORE_TIMEOUT" }, throwingReset
  );
  assert.strictEqual(unreadableReadiness.ready, false);
  assert.strictEqual(unreadableReadiness.readinessReason, "soft-stop readiness arbitration failed");
  assert.strictEqual(unreadableReadiness.recoveryClass, "RECOVERY_FAILED");
  assert.ok(unreadableReadiness.continuityLost);
  let observedCode = "";
  checkpoint.enrich({
    snapshot,
    cwd: root,
    stataString: (value) => String(value).replace(/\\/g, "/").replace(/"/g, '""'),
    runSelection: async (code, options) => {
      observedCode = code;
      assert.strictEqual(options.runId, "pre-run-full-state-unit-run");
      writeCheckpointFiles(snapshot);
      return { success: true, rc: 0, logPath: "/tmp/checkpoint.log" };
    },
  }).then(async () => {
    assert.ok(observedCode.includes('st_dir("global", "macro", "*")'));
    assert.ok(observedCode.includes("base64encode(st_global(__codex_name))"));
    assert.ok(observedCode.includes("estimates save"));
    assert.ok(observedCode.includes("graph save"));
    assert.ok(observedCode.includes("classutil describe Graph"));
    assert.ok(observedCode.includes(snapshot.defaultGraphObjectPath));
    const generatedIdentifiers = Array.from(
      observedCode.matchAll(/\b__codex_[A-Za-z0-9_]+\b/g),
      (match) => match[0]
    );
    assert.ok(generatedIdentifiers.length > 0);
    assert.deepStrictEqual(
      generatedIdentifiers.filter((name) => name.length > 31),
      [],
      "generated Stata/Mata identifiers must stay within Stata's 31-character limit"
    );
    assert.strictEqual(snapshot.stateComplete, true);
    assert.strictEqual(snapshot.defaultGraphObjectPreexisting, false);
    assert.strictEqual(snapshot.globalCount, 1);
    assert.strictEqual(snapshot.estimateCount, 1);
    assert.strictEqual(snapshot.graphCount, 1);

    let rejectTransport;
    const pendingTransport = new Promise((resolve, reject) => {
      rejectTransport = reject;
    });
    const transportSnapshot = { runId: "payload-run", sourceMode: "human-file" };
    checkpoint.trackTransport(transportSnapshot, pendingTransport, {
      runId: "payload-run",
      sourceMode: "human-file",
    });
    const terminalRun = {
      _runId: "payload-run",
      taskId: "task-1",
      _taskDonePayload: { event: "task_done", status: "done" },
    };
    const drainedClient = {
      _active: false,
      _pending: 0,
      _activeRun: null,
      _runsByTaskId: new Map([["task-1", terminalRun]]),
      _cancellationSourcesByRunId: new Map(),
    };
    const pendingSummary = checkpoint.transportSummary(
      transportSnapshot, drainedClient, "task-1"
    );
    assert.strictEqual(pendingSummary.serverTaskTerminal, true);
    assert.strictEqual(pendingSummary.transportPromiseSettled, false);
    assert.strictEqual(pendingSummary.safeForRestore, false);
    rejectTransport(new Error("cancelled after worker acknowledgement"));
    await pendingTransport.catch(() => {});
    await Promise.resolve();
    const settledSummary = checkpoint.transportSummary(
      transportSnapshot, drainedClient, "task-1"
    );
    assert.strictEqual(settledSummary.transportPromiseOutcome, "rejected");
    assert.strictEqual(settledSummary.transportPromiseError,
      "cancelled after worker acknowledgement");
    assert.strictEqual(settledSummary.safeForRestore, true);
    drainedClient._activeRun = terminalRun;
    drainedClient._cancellationSourcesByRunId.set("payload-run", {});
    assert.strictEqual(
      checkpoint.transportSummary(transportSnapshot, drainedClient, "task-1").safeForRestore,
      false,
      "matching local ownership must be removed before restore"
    );
    drainedClient._activeRun = null;
    drainedClient._cancellationSourcesByRunId.clear();

    const restore = checkpoint.restoreCode(snapshot, (value) => String(value).replace(/\\/g, "/"));
    assert.ok(restore.startsWith(`use "${snapshot.path}", clear`));
    assert.ok(restore.includes("base64decode"));
    assert.ok(restore.includes("estimates store good_est"));
    assert.ok(!restore.includes("../bad"));
    assert.ok(restore.includes("name(good_graph, replace)"));
    assert.strictEqual(restore.split("\n").filter((line) => line === "discard").length, 1,
      "full Stop restoration must clear the interrupted graphics class cache exactly once");
    assert.ok(restore.indexOf("\ndiscard\n") < restore.indexOf("estimates use"),
      "discard clears estimates too, so it must precede all checkpoint rehydration");
    assert.ok(!checkpoint.restoreCode(snapshot, null, { datasetOnly: true }).split("\n").includes("discard"),
      "dataset-only degraded restoration must not clear the non-data state it cannot restore");
    assert.ok(restore.includes("classutil drop .Graph"));
    assert.ok(restore.includes("graph drop good_graph"));
    assert.ok(restore.includes("classutil drop .good_graph"));
    const namedGraphCleanup = restore.slice(
      restore.indexOf("classutil drop .good_graph"),
      restore.indexOf("graph use", restore.indexOf("classutil drop .good_graph"))
    );
    assert.ok(!namedGraphCleanup.includes("local __codex_restore_rc = _rc"),
      "non-critical named class cleanup must defer failure authority to graph use");
    assert.ok(restore.includes("if `__codex_restore_rc' != 0 exit `__codex_restore_rc'"));
    assert.ok(!restore.includes("bad-name"));
    assert.ok(restore.includes("graph display good_graph"));
    // R16J113: the real selection transport returned r(198) after losing the
    // closing lines of Stata if-blocks. Mata blocks survive that transport, but
    // generated Stata restoration must use self-contained conditional lines.
    const stataRestore = restore.slice(restore.indexOf("\nend\n") + 5);
    assert.ok(!/[{}]/.test(stataRestore),
      "checkpoint Stata restore must not depend on multiline brace replay");
    assert.ok(stataRestore.includes("if `__codex_step_rc' == 0 capture estimates store good_est"));
    assert.ok(stataRestore.includes("if `__codex_step_rc' == 0 local __codex_step_rc = _rc"),
      "a failed estimates use must not be replaced with the store result");
    assert.ok(stataRestore.includes("if !_rc capture quietly classutil drop .good_graph"));

    fs.writeFileSync(snapshot.defaultGraphObjectPath, "1\n", "utf8");
    const preexistingObjectRestore = checkpoint.restoreCode(
      snapshot,
      (value) => String(value).replace(/\\/g, "/")
    );
    assert.ok(!preexistingObjectRestore.includes("classutil drop .Graph"),
      "a preexisting user .Graph object must not be removed");
    assert.ok(!preexistingObjectRestore.split("\n").includes("discard"),
      "an uncheckpointed preexisting .Graph object forbids resetting the class system");
    fs.writeFileSync(snapshot.defaultGraphObjectPath, "0\n", "utf8");
    const estimateFile = path.join(snapshot.stateDir, "estimate_good_est.ster");
    const savedEstimate = fs.readFileSync(estimateFile);
    fs.unlinkSync(estimateFile);
    assert.strictEqual(checkpoint.restoreCode(snapshot), "exit 459\n",
      "missing saved estimates must reject before a reset can discard the remaining live state");
    fs.writeFileSync(estimateFile, savedEstimate);
    const graphFile = path.join(snapshot.stateDir, "graph_good_graph.gph");
    const savedGraph = fs.readFileSync(graphFile);
    fs.unlinkSync(graphFile);
    assert.strictEqual(checkpoint.restoreCode(snapshot), "exit 459\n",
      "a missing graph must fail closed before discard, never be silently skipped");
    fs.writeFileSync(graphFile, savedGraph);
    fs.writeFileSync(snapshot.defaultGraphObjectPath, "invalid\n", "utf8");
    assert.strictEqual(checkpoint.restoreCode(snapshot), "exit 459\n",
      "a malformed object-presence checkpoint must fail closed");

    const summary = checkpoint.publicSummary(snapshot);
    assert.strictEqual(summary.stateComplete, true);
    assert.strictEqual(summary.exists, true);
    assert.strictEqual(summary.defaultGraphObjectPreexisting, false);
    checkpoint.cleanup(snapshot);
    assert.strictEqual(fs.existsSync(snapshot.path), false);
    assert.strictEqual(fs.existsSync(snapshot.stateDir), false);
    checkpoint.cleanup(snapshot);
    fs.rmSync(partialPath, { force: true });

    const atomicSnapshot = {
      path: path.join(root, "atomic.dta"), runId: "atomic-run",
      sourceMode: "visible-bridge", provisional: true,
    };
    let atomicCalls = 0;
    let fallbackCalls = 0;
    const atomic = checkpoint.beginAtomic({
      snapshot: atomicSnapshot,
      cwd: root,
      stataString: (value) => String(value).replace(/\\/g, "/").replace(/"/g, '""'),
      runSelection: async (code, options) => {
        atomicCalls += 1;
        assert.ok(code.indexOf('save "') < code.indexOf('st_dir("global", "macro", "*")'));
        assert.strictEqual(options.runId, "pre-run-full-state-atomic-run");
        fs.writeFileSync(atomicSnapshot.path, Buffer.alloc(1024, 2));
        atomicSnapshot.snapshotKind = "data";
        writeSnapshotReady(atomicSnapshot);
        writeCheckpointFiles(atomicSnapshot);
        return { success: true, rc: 0, logPath: "/tmp/atomic.log" };
      },
    });
    await atomic.snapshotReady;
    const atomicDone = await checkpoint.completeAtomic(atomic, {
      legacyRunSelection: async () => { fallbackCalls += 1; },
    });
    assert.strictEqual(atomicCalls, 1, "normal atomic path must dispatch exactly once");
    assert.strictEqual(fallbackCalls, 0, "normal atomic path must not reuse transport");
    assert.strictEqual(atomic.fallbackDispatchCount, 0);
    assert.strictEqual(atomicDone.stateComplete, true);
    assert.strictEqual(atomicDone.provisional, false);
    assert.strictEqual(atomicDone.snapshotKind, "data");
    assert.strictEqual(atomicSnapshot.transportPromiseAttached, true);
    assert.strictEqual(atomicSnapshot.transportPromiseSettled, true);
    assert.strictEqual(atomicSnapshot.transportPromiseOutcome, "fulfilled");

    const emptySnapshot = {
      path: path.join(root, "empty.dta"), runId: "empty-run",
      sourceMode: "visible-bridge", provisional: true,
    };
    let emptyCode = "";
    const emptyAtomic = checkpoint.beginAtomic({
      snapshot: emptySnapshot,
      runSelection: async (code) => {
        emptyCode = code;
        fs.writeFileSync(emptySnapshot.path, Buffer.alloc(1024, 5));
        emptySnapshot.snapshotKind = "empty";
        writeSnapshotReady(emptySnapshot);
        writeCheckpointFiles(emptySnapshot);
        return { success: true, rc: 0, logPath: "/tmp/empty.log" };
      },
    });
    await emptyAtomic.snapshotReady;
    await checkpoint.completeAtomic(emptyAtomic);
    assert.ok(emptyCode.includes("if c(k) == 0"));
    assert.ok(emptyCode.includes("generate byte __codex_empty_state = ."));
    const expectedReadyWrite =
      `file write \`__codex_sfh' "ready" _tab "${emptySnapshot.checkpointNonce}" _tab "\`__codex_snapshot_kind'" _n`;
    assert.ok(emptyCode.includes(expectedReadyWrite));
    assert.strictEqual(
      emptyCode.includes(`ready\t${emptySnapshot.checkpointNonce}\t`),
      false,
      "literal tabs inside a Stata string are normalized to spaces and must never encode the marker"
    );
    const transportedReadyBytes = Buffer.from(
      `ready\t${emptySnapshot.checkpointNonce}\tempty\n`,
      "utf8"
    );
    assert.strictEqual(transportedReadyBytes[5], 0x09);
    assert.strictEqual(transportedReadyBytes[38], 0x09);
    fs.writeFileSync(
      checkpoint.checkpointPaths(emptySnapshot).snapshotReadyPath,
      transportedReadyBytes
    );
    assert.deepStrictEqual(
      checkpoint.snapshotReadyRecord(emptySnapshot),
      {
        nonce: emptySnapshot.checkpointNonce,
        kind: "empty",
        path: checkpoint.checkpointPaths(emptySnapshot).snapshotReadyPath,
      },
      "the bytes emitted by Stata _tab tokens must satisfy the strict parser"
    );
    assert.strictEqual(checkpoint.restoreCode(emptySnapshot).split("\n")[0], "clear");
    assert.ok(!checkpoint.restoreCode(emptySnapshot).includes(`use "${emptySnapshot.path}"`));

    const fallbackSnapshot = {
      path: path.join(root, "fallback.dta"), runId: "fallback-run",
      sourceMode: "human-file", provisional: true,
    };
    let fallbackPrimaryCalls = 0;
    const fallbackAtomic = checkpoint.beginAtomic({
      snapshot: fallbackSnapshot,
      cwd: root,
      runSelection: async () => {
        fallbackPrimaryCalls += 1;
        fs.writeFileSync(fallbackSnapshot.path, Buffer.alloc(1024, 3));
        writeSnapshotReady(fallbackSnapshot);
        if (fallbackPrimaryCalls > 1) writeCheckpointFiles(fallbackSnapshot);
        return { success: true, rc: 0, logPath: "/tmp/incomplete.log" };
      },
    });
    await fallbackAtomic.snapshotReady;
    await checkpoint.completeAtomic(fallbackAtomic, { cwd: root });
    assert.strictEqual(fallbackPrimaryCalls, 2, "incomplete atomic state reuses the runner exactly once");
    assert.strictEqual(fallbackAtomic.fallbackDispatchCount, 1);

    const invalidSnapshot = {
      path: path.join(root, "invalid.dta"), runId: "invalid-run",
    };
    const invalidAtomic = checkpoint.beginAtomic({
      snapshot: invalidSnapshot,
      runSelection: async () => ({ success: true, rc: 0 }),
    });
    await assert.rejects(invalidAtomic.snapshotReady, /without a restore-capable snapshot/);
    await assert.rejects(
      checkpoint.completeAtomic(invalidAtomic),
      /atomic checkpoint state incomplete/
    );

    const rejectedSnapshot = {
      path: path.join(root, "rejected.dta"), runId: "rejected-run",
    };
    const rejectedAtomic = checkpoint.beginAtomic({
      snapshot: rejectedSnapshot,
      runSelection: async () => { throw new Error("transport rejected"); },
    });
    await assert.rejects(rejectedAtomic.snapshotReady, /transport rejected/);
    await assert.rejects(rejectedAtomic.complete, /transport rejected/);
    assert.strictEqual(checkpoint.isSnapshotReady(rejectedSnapshot), false);

    const staleSnapshot = {
      path: path.join(root, "stale.dta"), runId: "stale-run",
    };
    fs.writeFileSync(staleSnapshot.path, Buffer.alloc(1024, 4));
    fs.mkdirSync(checkpoint.checkpointPaths(staleSnapshot).stateDir, { recursive: true });
    writeSnapshotReady(staleSnapshot);
    const staleAtomic = checkpoint.beginAtomic({
      snapshot: staleSnapshot,
      runSelection: async () => ({ success: true, rc: 0 }),
    });
    await assert.rejects(staleAtomic.snapshotReady, /without a restore-capable snapshot/);
    assert.strictEqual(fs.existsSync(staleSnapshot.path), false, "stale DTA must be removed before dispatch");
    assert.strictEqual(
      fs.existsSync(checkpoint.checkpointPaths(staleSnapshot).snapshotReadyPath),
      false,
      "stale milestone must be removed before dispatch"
    );
    checkpoint.cleanup(atomicSnapshot);
    checkpoint.cleanup(fallbackSnapshot);
    checkpoint.cleanup(invalidSnapshot);
    checkpoint.cleanup(staleSnapshot);
    checkpoint.cleanup(emptySnapshot);
    checkpoint.cleanup(rejectedSnapshot);
    console.log("STOP_CHECKPOINT_CORE_PASS");
  }).catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
} catch (error) {
  fs.rmSync(root, { recursive: true, force: true });
  throw error;
}
