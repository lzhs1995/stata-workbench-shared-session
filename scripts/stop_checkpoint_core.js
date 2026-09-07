"use strict";

const fs = require("fs");
const path = require("path");
const crypto = require("crypto");

const STATA_NAME = /^[A-Za-z_][A-Za-z0-9_]{0,31}$/;

function safeStataPath(value, stataString) {
  const text = typeof stataString === "function"
    ? stataString(value)
    : String(value || "").replace(/\\/g, "/").replace(/"/g, '""');
  return text;
}

function readNames(file) {
  if (!file || !fs.existsSync(file)) return [];
  return fs.readFileSync(file, "utf8")
    .split(/\r?\n/)
    .map((name) => name.trim())
    .filter((name) => STATA_NAME.test(name));
}

function checkpointPaths(snapshot) {
  const stateDir = snapshot.stateDir || `${snapshot.path}.state`;
  return {
    stateDir,
    snapshotReadyPath: path.join(stateDir, "snapshot.ready"),
    globalsPath: path.join(stateDir, "globals.b64.tsv"),
    estimatesPath: path.join(stateDir, "estimates.txt"),
    graphsPath: path.join(stateDir, "graphs.txt"),
    currentGraphPath: path.join(stateDir, "current_graph.txt"),
    defaultGraphObjectPath: path.join(stateDir, "default_graph_object.txt"),
  };
}

function readBinaryFlag(file) {
  if (!file || !fs.existsSync(file)) return null;
  try {
    const value = fs.readFileSync(file, "utf8").trim();
    return value === "0" || value === "1" ? Number(value) : null;
  } catch {
    return null;
  }
}

function checkpointNonce(snapshot) {
  const value = snapshot && snapshot.checkpointNonce;
  return typeof value === "string" && /^[0-9a-f]{32}$/.test(value) ? value : null;
}

function snapshotReadyRecord(snapshot) {
  const nonce = checkpointNonce(snapshot);
  if (!nonce) return null;
  const readyPath = checkpointPaths(snapshot).snapshotReadyPath;
  try {
    const stat = fs.statSync(readyPath);
    if (!stat.isFile() || stat.size <= 0 || stat.size > 128) return null;
    const text = fs.readFileSync(readyPath, "utf8");
    const match = /^ready\t([0-9a-f]{32})\t(data|empty)\r?\n?$/.exec(text);
    if (!match || match[1] !== nonce) return null;
    return { nonce: match[1], kind: match[2], path: readyPath };
  } catch {
    return null;
  }
}

function checkpointCode(snapshot, stataString) {
  const paths = checkpointPaths(snapshot);
  const q = (value) => safeStataPath(value, stataString);
  return [
    "mata:",
    `__codex_fh = fopen("${q(paths.globalsPath)}", "w")`,
    '__codex_names = st_dir("global", "macro", "*")',
    "for (__codex_i=1; __codex_i<=rows(__codex_names); __codex_i++) {",
    "    __codex_name = __codex_names[__codex_i]",
    '    if (substr(__codex_name,1,2)=="S_" | substr(__codex_name,1,1)=="_" | substr(__codex_name,1,3)=="mcp" | substr(__codex_name,1,2)=="T_" | regexm(__codex_name,"^F[0-9]+$")) continue',
    "    fput(__codex_fh, __codex_name + char(9) + base64encode(st_global(__codex_name)))",
    "}",
    "fclose(__codex_fh)",
    "end",
    "capture estimates store __codex_checkpoint_current",
    "local __codex_has_current = (_rc == 0)",
    "quietly estimates dir",
    'local __codex_estimates `"`r(names)\'"\'',
    "tempname __codex_efh",
    `file open \`__codex_efh\' using "${q(paths.estimatesPath)}", write text replace`,
    "foreach __codex_name of local __codex_estimates {",
    '    if "`__codex_name\'" != "__codex_checkpoint_current" {',
    "        capture quietly estimates restore `__codex_name'",
    "        if !_rc {",
    `            capture quietly estimates save "${q(paths.stateDir)}/estimate_\`__codex_name\'.ster", replace`,
    "            if !_rc file write `__codex_efh' \"`__codex_name'\" _n",
    "        }",
    "    }",
    "}",
    "file close `__codex_efh'",
    "if `__codex_has_current' {",
    "    capture quietly estimates restore __codex_checkpoint_current",
    "    capture estimates drop __codex_checkpoint_current",
    "}",
    "capture quietly classutil describe Graph",
    "local __codex_had_graph_obj = (_rc == 0)",
    "tempname __codex_dfh",
    `file open \`__codex_dfh' using "${q(paths.defaultGraphObjectPath)}", write text replace`,
    "file write `__codex_dfh' \"`__codex_had_graph_obj'\" _n",
    "file close `__codex_dfh'",
    "quietly graph dir, memory",
    'local __codex_graphs `"`r(list)\'"\'',
    'local __codex_current_graph `"`c(curgraph)\'"\'',
    "tempname __codex_gfh __codex_cfh",
    `file open \`__codex_gfh\' using "${q(paths.graphsPath)}", write text replace`,
    `file open \`__codex_cfh\' using "${q(paths.currentGraphPath)}", write text replace`,
    "file write `__codex_cfh' \"`__codex_current_graph'\" _n",
    "file close `__codex_cfh'",
    "foreach __codex_name of local __codex_graphs {",
    `    capture quietly graph save \`__codex_name\' "${q(paths.stateDir)}/graph_\`__codex_name\'.gph", replace`,
    "    if !_rc file write `__codex_gfh' \"`__codex_name'\" _n",
    "}",
    "file close `__codex_gfh'",
    "display as text \"___CODEX_CHECKPOINT_DONE___\"",
    "",
  ].join("\n");
}

function snapshotCode(snapshot, stataString) {
  const paths = checkpointPaths(snapshot);
  const nonce = checkpointNonce(snapshot);
  if (!nonce) throw new Error("checkpoint nonce missing or malformed");
  const q = (value) => safeStataPath(value, stataString);
  return [
    'local __codex_snapshot_kind "data"',
    "if c(k) == 0 {",
    "    quietly set obs 1",
    "    generate byte __codex_empty_state = .",
    `    capture quietly save "${q(snapshot.path)}", replace`,
    "    local __codex_snapshot_rc = _rc",
    "    clear",
    '    local __codex_snapshot_kind "empty"',
    "}",
    "else {",
    "    capture preserve",
    `    capture quietly save "${q(snapshot.path)}", replace`,
    "    local __codex_snapshot_rc = _rc",
    "    capture restore",
    "}",
    "if `__codex_snapshot_rc' == 0 {",
    "    tempname __codex_sfh",
    `    capture file open \`__codex_sfh' using "${q(paths.snapshotReadyPath)}", write text replace`,
    "    if !_rc {",
    `        file write \`__codex_sfh' "ready" _tab "${nonce}" _tab "\`__codex_snapshot_kind'" _n`,
    "        file close `__codex_sfh'",
    "    }",
    "}",
    "",
  ].join("\n");
}

function atomicCheckpointCode(snapshot, stataString) {
  return snapshotCode(snapshot, stataString) + checkpointCode(snapshot, stataString);
}

function initializeCheckpoint(snapshot, options = {}) {
  const paths = checkpointPaths(snapshot);
  if (options.cleanStart) {
    if (fs.existsSync(snapshot.path)) fs.unlinkSync(snapshot.path);
    if (fs.existsSync(paths.stateDir)) fs.rmSync(paths.stateDir, { recursive: true, force: true });
  }
  Object.assign(snapshot, paths, {
    checkpointNonce: typeof options.checkpointNonce === "string"
      ? options.checkpointNonce
      : ((!options.cleanStart && checkpointNonce(snapshot)) ||
        crypto.randomBytes(16).toString("hex")),
    stateComplete: false,
    stateError: null,
    sourceMode: snapshot.sourceMode || options.sourceMode || null,
  });
  fs.mkdirSync(paths.stateDir, { recursive: true });
  return paths;
}

function finalizeCheckpoint(snapshot, result) {
  const paths = checkpointPaths(snapshot);
  const estimates = readNames(paths.estimatesPath);
  const graphs = readNames(paths.graphsPath);
  const globals = fs.existsSync(paths.globalsPath)
    ? fs.readFileSync(paths.globalsPath, "utf8").split(/\r?\n/).filter(Boolean)
    : [];
  const defaultGraphObjectPreexisting = readBinaryFlag(paths.defaultGraphObjectPath);
  const ok = result?.success !== false && !result?.error && Number(result?.rc || 0) === 0;
  Object.assign(snapshot, {
    stateComplete: ok && fs.existsSync(paths.globalsPath) &&
      fs.existsSync(paths.estimatesPath) && fs.existsSync(paths.graphsPath) &&
      defaultGraphObjectPreexisting !== null,
    stateError: ok ? null : (result?.error?.message || result?.error || result?.stderr || "checkpoint command failed"),
    defaultGraphObjectPreexisting: defaultGraphObjectPreexisting === null
      ? null
      : defaultGraphObjectPreexisting === 1,
    globalCount: globals.length,
    estimateCount: estimates.length,
    graphCount: graphs.length,
    checkpointLogPath: result?.logPath || null,
  });
  return snapshot;
}

function waitForSnapshot(snapshot, workPromise, options = {}) {
  const pollMs = Number.isFinite(options.pollMs) ? Math.max(1, options.pollMs) : 20;
  let workSettled = false;
  let workError = null;
  Promise.resolve(workPromise).then(
    () => { workSettled = true; },
    (error) => { workSettled = true; workError = error; }
  );
  return new Promise((resolve, reject) => {
    const poll = () => {
      try {
        if (isSnapshotReady(snapshot)) {
          const stat = fs.statSync(snapshot.path);
          const ready = snapshotReadyRecord(snapshot);
          Object.assign(snapshot, {
            bytes: stat.size,
            at: new Date().toISOString(),
            provisional: false,
            snapshotKind: ready.kind,
          });
          resolve(snapshot);
          return;
        }
      } catch (error) {
        reject(error);
        return;
      }
      if (workSettled) {
        reject(workError || new Error("atomic checkpoint completed without a restore-capable snapshot"));
        return;
      }
      setTimeout(poll, pollMs);
    };
    poll();
  });
}

function trackTransport(snapshot, promise, metadata = {}) {
  if (!snapshot || (typeof snapshot !== "object" && typeof snapshot !== "function")) {
    throw new Error("transport tracking requires a snapshot object");
  }
  const runId = metadata.runId == null
    ? (snapshot.runId == null ? null : String(snapshot.runId))
    : String(metadata.runId);
  const generation = Number(snapshot._transportGeneration || 0) + 1;
  const transportPromise = Promise.resolve(promise);
  Object.assign(snapshot, {
    _transportGeneration: generation,
    transportRunId: runId,
    transportSource: metadata.sourceMode || metadata.source || snapshot.sourceMode || null,
    transportPromiseAttached: true,
    transportPromiseSettled: false,
    transportPromiseOutcome: null,
    transportSettlementAt: null,
    transportPromiseError: null,
  });
  transportPromise.then(
    () => {
      if (snapshot._transportGeneration !== generation) return;
      Object.assign(snapshot, {
        transportPromiseSettled: true,
        transportPromiseOutcome: "fulfilled",
        transportSettlementAt: new Date().toISOString(),
        transportPromiseError: null,
      });
    },
    (error) => {
      if (snapshot._transportGeneration !== generation) return;
      Object.assign(snapshot, {
        transportPromiseSettled: true,
        transportPromiseOutcome: "rejected",
        transportSettlementAt: new Date().toISOString(),
        transportPromiseError: String((error && error.message) || error || "transport rejected"),
      });
    }
  );
  return transportPromise;
}

function transportSummary(snapshot, client, taskId) {
  const runId = snapshot && (snapshot.transportRunId ?? snapshot.runId);
  const runKey = runId == null ? null : String(runId);
  const taskKey = taskId == null || taskId === "" ? null : String(taskId);
  let trackedRun = null;
  if (client && taskKey && client._runsByTaskId instanceof Map) {
    trackedRun = client._runsByTaskId.get(taskKey) || null;
  }
  if (!trackedRun && client && client._activeRun) {
    const activeTaskId = client._activeRun.taskId ?? client._activeRun._taskDoneTaskId;
    if (taskKey && String(activeTaskId ?? "") === taskKey) trackedRun = client._activeRun;
  }
  const payload = trackedRun && trackedRun._taskDonePayload;
  const event = String((payload && payload.event) || "").toLowerCase();
  const status = String(
    (payload && (payload.status || payload.state || payload.result?.status)) || ""
  ).toLowerCase();
  const serverTaskTerminal = taskKey === null || Boolean(
    payload && (event === "task_done" ||
      ["done", "completed", "finished", "error", "failed", "cancelled", "canceled"]
        .includes(status))
  );
  const activeRunId = client && client._activeRun && client._activeRun._runId;
  const matchingActiveRunRemoved = !runKey || !client || !client._activeRun ||
    String(activeRunId ?? "") !== runKey;
  const cancellationSources = client && client._cancellationSourcesByRunId;
  const matchingCancellationSourceRemoved = !runKey ||
    (cancellationSources instanceof Map && !cancellationSources.has(runKey));
  const summary = {
    runId: runKey,
    taskId: taskKey,
    serverTaskRequired: taskKey !== null,
    serverTaskObserved: Boolean(payload),
    serverTaskTerminal,
    serverTaskStatus: status || event || null,
    transportPromiseAttached: snapshot?.transportPromiseAttached === true,
    transportPromiseSettled: snapshot?.transportPromiseSettled === true,
    transportPromiseOutcome: snapshot?.transportPromiseOutcome || null,
    transportSettlementAt: snapshot?.transportSettlementAt || null,
    transportPromiseError: snapshot?.transportPromiseError || null,
    clientInactive: Boolean(client && client._active === false),
    pendingZero: Boolean(client && Number(client._pending) === 0),
    matchingActiveRunRemoved,
    matchingCancellationSourceRemoved,
  };
  summary.safeForRestore = Boolean(
    summary.serverTaskTerminal &&
    summary.transportPromiseAttached &&
    summary.transportPromiseSettled &&
    summary.clientInactive &&
    summary.pendingZero &&
    summary.matchingActiveRunRemoved &&
    summary.matchingCancellationSourceRemoved
  );
  return summary;
}

function beginAtomic(options = {}) {
  const snapshot = options.snapshot;
  if (!snapshot || !snapshot.path || typeof options.runSelection !== "function") {
    throw new Error("atomic checkpoint requires snapshot.path and runSelection");
  }
  initializeCheckpoint(snapshot, { ...options, cleanStart: true });
  snapshot.atomicDispatchCount = Number(snapshot.atomicDispatchCount || 0) + 1;
  snapshot.fallbackDispatchCount = 0;
  const runId = `pre-run-full-state-${String(snapshot.runId || Date.now())}`;
  const workPromise = Promise.resolve().then(() => options.runSelection(
    atomicCheckpointCode(snapshot, options.stataString),
    {
      normalizeResult: true,
      includeGraphs: false,
      cwd: options.cwd || undefined,
      runId,
    }
  ));
  trackTransport(snapshot, workPromise, { runId, sourceMode: options.sourceMode });
  workPromise.catch(() => {});
  const snapshotReady = waitForSnapshot(snapshot, workPromise, options);
  snapshotReady.catch(() => {});
  const complete = workPromise.then(
    (result) => ({ snapshot: finalizeCheckpoint(snapshot, result), result }),
    (error) => {
      snapshot.stateError = error?.message || String(error);
      throw error;
    }
  );
  complete.catch(() => {});
  return {
    runId,
    snapshot,
    snapshotReady,
    complete,
    runSelection: options.runSelection,
    stataString: options.stataString,
    cwd: options.cwd,
    sourceMode: options.sourceMode,
    fallbackDispatchCount: 0,
  };
}

async function completeAtomic(atomic, options = {}) {
  if (!atomic || !atomic.complete || !atomic.snapshot) {
    throw new Error("invalid atomic checkpoint handle");
  }
  const completed = await atomic.complete;
  if (completed.snapshot.stateComplete) return completed.snapshot;
  const fallback = typeof options.legacyRunSelection === "function"
    ? options.legacyRunSelection
    : (options.allowFallback === false ? null : atomic.runSelection);
  if (typeof fallback === "function") {
    atomic.fallbackDispatchCount += 1;
    completed.snapshot.fallbackDispatchCount = atomic.fallbackDispatchCount;
    await enrich({
      snapshot: completed.snapshot,
      runSelection: fallback,
      stataString: options.stataString || atomic.stataString,
      cwd: options.cwd || atomic.cwd,
      sourceMode: options.sourceMode || atomic.sourceMode,
    });
  }
  if (!completed.snapshot.stateComplete) {
    throw new Error(completed.snapshot.stateError || "atomic checkpoint state incomplete");
  }
  return completed.snapshot;
}

async function enrich(options = {}) {
  const snapshot = options.snapshot;
  if (!snapshot || !snapshot.path || typeof options.runSelection !== "function") {
    return snapshot;
  }
  const paths = initializeCheckpoint(snapshot, options);
  try {
    const result = await options.runSelection(
      checkpointCode(snapshot, options.stataString),
      {
        normalizeResult: true,
        includeGraphs: false,
        cwd: options.cwd || undefined,
        runId: `pre-run-full-state-${String(snapshot.runId || Date.now())}`,
      }
    );
    finalizeCheckpoint(snapshot, result);
  } catch (error) {
    snapshot.stateError = error?.message || String(error);
  }
  return snapshot;
}

function restoreCode(snapshot, stataString, options = {}) {
  if (!snapshot?.path) return "";
  const paths = checkpointPaths(snapshot);
  const q = (value) => safeStataPath(value, stataString);
  const ready = snapshotReadyRecord(snapshot);
  if (!ready) return "";
  const defaultGraphObjectPreexisting = readBinaryFlag(paths.defaultGraphObjectPath);
  if (defaultGraphObjectPreexisting === null) return "exit 459\n";
  // datasetOnly：升级路径（L2）专用的降级恢复。只做数据集 + 全局，
  // 跳过 estimates/graphs 的逐条重建 —— 那是 PF-4 里真正耗时的部分。
  const datasetOnly = options && options.datasetOnly === true;
  const estimateNames = readNames(paths.estimatesPath);
  const graphNames = readNames(paths.graphsPath);
  if (!datasetOnly) {
    // Do not reset live state unless every declared saved component remains
    // available. A missing file is not an empty inventory or a successful restore.
    const required = [paths.globalsPath, paths.estimatesPath, paths.graphsPath,
      paths.currentGraphPath,
      ...estimateNames.map((name) => path.join(paths.stateDir, `estimate_${name}.ster`)),
      ...graphNames.map((name) => path.join(paths.stateDir, `graph_${name}.gph`))];
    if (required.some((file) => !fs.existsSync(file) || !fs.statSync(file).isFile())) {
      return "exit 459\n";
    }
  }
  const lines = ready.kind === "empty"
    ? ["clear"]
    : [`use "${q(snapshot.path)}", clear`];
  // R16J116: a drained cancellation in native graphics left a broken axis/view
  // class cache (Super invalid member variable identifier). Dropping graph names
  // cannot reset that cache. Stata's supported discard resets it, but also clears
  // estimates/graphs, so run it once BEFORE reconstructing all saved components.
  // Never apply it to dataset-only recovery or an unsaved user .Graph instance.
  if (!datasetOnly && (defaultGraphObjectPreexisting === 0 || graphNames.includes("Graph"))) {
    lines.push("discard");
  }
  lines.push("local __codex_restore_rc = 0");
  if (fs.existsSync(paths.globalsPath)) {
    lines.push(
      "mata:",
      `__codex_fh = fopen("${q(paths.globalsPath)}", "r")`,
      'while ((__codex_line=fget(__codex_fh)) != J(0,0,"")) {',
      "    __codex_tab = strpos(__codex_line, char(9))",
      "    if (__codex_tab>1) st_global(substr(__codex_line,1,__codex_tab-1), base64decode(substr(__codex_line,__codex_tab+1,.)))",
      "}",
      "fclose(__codex_fh)",
      "end"
    );
  }
  // An interrupted unnamed graph can leave a non-graph top-level `.Graph`
  // object behind. Remove it only when the checkpoint proves it did not exist
  // before the payload; a preexisting user object must remain untouched.
  if (defaultGraphObjectPreexisting === 0) {
    lines.push(
      "capture quietly classutil describe Graph",
      "local __codex_graph_object_rc = _rc",
      "if `__codex_graph_object_rc' == 0 capture quietly classutil drop .Graph",
      "if `__codex_graph_object_rc' == 0 local __codex_restore_rc = _rc"
    );
  }
  if (!datasetOnly) {
    for (const name of estimateNames) {
      const file = path.join(paths.stateDir, `estimate_${name}.ster`);
      if (!fs.existsSync(file)) continue;
      lines.push(
        `capture quietly estimates use "${q(file)}"`,
        "local __codex_step_rc = _rc",
        // Keep the original use error, or the store error when use succeeded.
        // Independent lines also survive the visible selection transport's
        // Stata block replay (which lost closing braces in R16J113).
        `if \`__codex_step_rc' == 0 capture estimates store ${name}`,
        "if `__codex_step_rc' == 0 local __codex_step_rc = _rc",
        "if `__codex_restore_rc' == 0 & `__codex_step_rc' != 0 local __codex_restore_rc = `__codex_step_rc'"
      );
    }
    for (const name of graphNames) {
      const file = path.join(paths.stateDir, `graph_${name}.gph`);
      if (!fs.existsSync(file)) continue;
      // A stale class object is only an obstacle if the authoritative graph
      // restore below also fails.  Some valid named graphs make classutil
      // return r(198) even though graph use, replace succeeds.
      lines.push(
        `capture quietly graph drop ${name}`,
        `capture quietly classutil describe ${name}`,
        `if !_rc capture quietly classutil drop .${name}`,
        `capture quietly graph use "${q(file)}", name(${name}, replace)`,
        "local __codex_step_rc = _rc",
        "if `__codex_restore_rc' == 0 & `__codex_step_rc' != 0 local __codex_restore_rc = `__codex_step_rc'"
      );
    }
    if (fs.existsSync(paths.currentGraphPath)) {
      const current = fs.readFileSync(paths.currentGraphPath, "utf8").trim();
      if (STATA_NAME.test(current)) {
        lines.push(
          `capture quietly graph display ${current}`,
          "local __codex_step_rc = _rc",
          "if `__codex_restore_rc' == 0 & `__codex_step_rc' != 0 local __codex_restore_rc = `__codex_step_rc'"
        );
      }
    }
  }
  lines.push(
    "if `__codex_restore_rc' != 0 exit `__codex_restore_rc'",
    'display as text "___CODEX_CHECKPOINT_RESTORED___"',
    ""
  );
  return lines.join("\n");
}

/** L2 降级恢复的工作量证据：跳过了多少条 estimates/graphs 重建。 */
function restoreDowngradeSummary(snapshot) {
  if (!snapshot?.path) return null;
  const paths = checkpointPaths(snapshot);
  let estimates = 0;
  let graphs = 0;
  try {
    estimates = readNames(paths.estimatesPath).length;
  } catch { /* 清单不可读时按 0 计，不得因此让恢复路径抛错 */ }
  try {
    graphs = readNames(paths.graphsPath).length;
  } catch { /* 同上 */ }
  return {
    mode: "dataset-only",
    skippedEstimates: estimates,
    skippedGraphs: graphs,
    datasetRestored: true,
    globalsRestored: fs.existsSync(paths.globalsPath),
  };
}

function isRestoreCapable(snapshot) {
  if (!snapshot || typeof snapshot.path !== "string" || !snapshot.path) return false;
  try {
    const stat = fs.statSync(snapshot.path);
    return stat.isFile() && stat.size >= 512;
  } catch {
    return false;
  }
}

function isSnapshotReady(snapshot) {
  if (!isRestoreCapable(snapshot)) return false;
  return snapshotReadyRecord(snapshot) !== null;
}

function shouldCleanupAfterFailure(snapshot) {
  if (!snapshot) return true;
  try {
    return snapshot.stopOwned !== true;
  } catch {
    return false;
  }
}

function softStopReadiness(restore, hardReset) {
  try {
    if (restore && restore.ok === true) {
      const degraded = restore.degraded;
      const skippedEstimates = Number(degraded && degraded.skippedEstimates);
      const skippedGraphs = Number(degraded && degraded.skippedGraphs);
      const estimatesLost = Number.isFinite(skippedEstimates) && skippedEstimates > 0
        ? skippedEstimates
        : 0;
      const graphsLost = Number.isFinite(skippedGraphs) && skippedGraphs > 0
        ? skippedGraphs
        : 0;
      if (estimatesLost > 0 || graphsLost > 0) {
        const detail = `dataset/globals restored, but ${estimatesLost} estimates and ${graphsLost} graphs were not restored`;
        return {
          ready: false,
          readinessState: "stale",
          readinessReason: "soft-stop-degraded-recovery",
          lastClientError: detail,
          recoveryClass: "RECOVERED_DEGRADED",
          continuityLost: {
            reason: "soft-stop-degraded-recovery",
            detail,
            skippedEstimates: estimatesLost,
            skippedGraphs: graphsLost,
            datasetRestored: degraded.datasetRestored === true,
            globalsRestored: degraded.globalsRestored === true,
          },
        };
      }
      return {
        ready: true,
        readinessState: "ready",
        readinessReason: "soft-stop-complete",
        lastClientError: null,
        recoveryClass: "RECOVERED_FULL",
        continuityLost: null,
      };
    }

    const restoreError = String(
      (restore && (restore.error || restore.initialError)) || "dataset restore failed"
    );
    let finalReset = hardReset;
    if (hardReset && Object.prototype.hasOwnProperty.call(hardReset, "retry")) {
      finalReset = hardReset.retry;
    }
    if (finalReset && finalReset.ok === true && finalReset.trueReady === true) {
      const detail = `backend recovered, but the pre-run checkpoint was not restored: ${restoreError}`;
      return {
        ready: false,
        readinessState: "stale",
        readinessReason: "soft-stop-checkpoint-not-restored",
        lastClientError: detail,
        recoveryClass: "RECOVERY_FAILED",
        continuityLost: {
          reason: "soft-stop-checkpoint-not-restored",
          detail,
        },
      };
    }
    return {
      ready: false,
      readinessState: "stale",
      readinessReason: "soft-stop dataset restore failed",
      lastClientError: restoreError,
      recoveryClass: "RECOVERY_FAILED",
      continuityLost: {
        reason: "soft-stop-checkpoint-restore-failed",
        detail: restoreError,
      },
    };
  } catch (error) {
    const detail = String((error && error.message) || error || "unknown arbitration error");
    return {
      ready: false,
      readinessState: "stale",
      readinessReason: "soft-stop readiness arbitration failed",
      lastClientError: detail,
      recoveryClass: "RECOVERY_FAILED",
      continuityLost: {
        reason: "soft-stop-readiness-arbitration-failed",
        detail,
      },
    };
  }
}

function restoreTimeoutMs(snapshot) {
  const estimateCount = Number(snapshot && snapshot.estimateCount);
  const graphCount = Number(snapshot && snapshot.graphCount);
  const artifacts =
    (Number.isFinite(estimateCount) && estimateCount > 0 ? estimateCount : 0) +
    (Number.isFinite(graphCount) && graphCount > 0 ? graphCount : 0);
  return Math.min(45000, 30000 + artifacts * 250);
}

// ===================================================================
// 缺陷 PF-4：soft-stop 的失败升级阶梯期限**单调递减**
// -------------------------------------------------------------------
// 实测来源：FULL45 正式跑 BROAD-RC734-20260823_055413_530294，S12 step5。
//
//   L1 soft-stop restore      restoreTimeoutMs()，实测取到天花板 45000 ms → 超时
//   L2 hard-fallback restore  硬编码 30000 ms（内嵌 10000 ms reconnect）  → 必然也超时
//   L3 force-reset reconnect  硬编码 10000 ms（实测 durationMs=10002）    → 必然也超时
//
// 升级本应放宽期限。原实现越升越紧，于是「restore 在 L1 内做不完」按构造
// 保证后两级也做不完 —— 可预测的必然失败，不是偶发负载抖动。终态是
// status=recovery-required / trueReady=false，自愈报 transport-failed，不可自愈。
//
// 两条修法同时生效，缺一不可：
//   1. 期限单调不减：后级 restore ≥ 前级 restore（放宽系数 ESCALATION_SLACK），
//      reconnect 与 restore **分别计时**，reconnect 不得侵占 restore 预算。
//   2. 工作量单调递减：L2 只恢复数据集 + 全局（datasetOnly），不重建
//      estimates/graphs。慢的从来不是 160 KB 数据量，而是 artifacts>=60 条
//      estimates/graphs 的逐条重建（见 restoreCode 的 per-name 循环）。
//      「更多时间做更少的事」才是升级；降级恢复也要如实标注 degraded。
const ESCALATION_SLACK = 1.5;
// 重连下限。实测健康态 force-reset 重连耗时 7.49 s（phase1-bridge-recovery-20260823/
// 03_recovery_smoke.json），原 10000 只有 25% 余量，压测下实测 10002 ms 卡死。
const RECONNECT_FLOOR_MS = 15000;
const RECONNECT_DIVISOR = 3;
// force-reset 是通用路径，调用点拿不到 snapshot，只能取静态值；必须同时
// ≥ RECONNECT_FLOOR_MS 与最坏情况下 L2 的 reconnect 预算。
const FORCE_RESET_RECONNECT_MS = 30000;

function hardRestoreTimeoutMs(snapshot) {
  return Math.ceil(restoreTimeoutMs(snapshot) * ESCALATION_SLACK);
}

function reconnectTimeoutMs(snapshot) {
  return Math.max(
    RECONNECT_FLOOR_MS,
    Math.ceil(restoreTimeoutMs(snapshot) / RECONNECT_DIVISOR)
  );
}

function forceResetReconnectTimeoutMs() {
  return Math.max(FORCE_RESET_RECONNECT_MS, RECONNECT_FLOOR_MS);
}

/** 阶梯全貌 + 单调性谓词。dist 与静态判据都从这里取值，避免两处各写一份。 */
function escalationLadder(snapshot) {
  const l1RestoreMs = restoreTimeoutMs(snapshot);
  const l2ReconnectMs = reconnectTimeoutMs(snapshot);
  const l2RestoreMs = hardRestoreTimeoutMs(snapshot);
  const l3ReconnectMs = forceResetReconnectTimeoutMs();
  return {
    l1RestoreMs,
    l2ReconnectMs,
    l2RestoreMs,
    l3ReconnectMs,
    // PF-4 的三条判据同时为假才算修好：后级 restore 不小于前级、
    // L3 reconnect 不小于 L2 reconnect、且没有任何一级退回硬编码 10 s。
    monotonic: l2RestoreMs >= l1RestoreMs && l3ReconnectMs >= l2ReconnectMs,
  };
}

function cleanup(snapshot) {
  if (!snapshot) return;
  if (snapshot.path && fs.existsSync(snapshot.path)) fs.unlinkSync(snapshot.path);
  const stateDir = snapshot.stateDir || (snapshot.path ? `${snapshot.path}.state` : null);
  if (stateDir && fs.existsSync(stateDir)) fs.rmSync(stateDir, { recursive: true, force: true });
}

function publicSummary(snapshot) {
  if (!snapshot) return null;
  return {
    runId: snapshot.runId == null ? null : String(snapshot.runId),
    sourceMode: snapshot.sourceMode || null,
    path: snapshot.path || null,
    bytes: snapshot.bytes || null,
    at: snapshot.at || null,
    stopOwned: !!snapshot.stopOwned,
    exists: !!(snapshot.path && fs.existsSync(snapshot.path)),
    snapshotReady: isSnapshotReady(snapshot),
    snapshotKind: snapshotReadyRecord(snapshot)?.kind || null,
    stateComplete: snapshot.stateComplete === true,
    stateError: snapshot.stateError || null,
    globalCount: Number(snapshot.globalCount || 0),
    estimateCount: Number(snapshot.estimateCount || 0),
    graphCount: Number(snapshot.graphCount || 0),
    defaultGraphObjectPreexisting: snapshot.defaultGraphObjectPreexisting === true
      ? true
      : (snapshot.defaultGraphObjectPreexisting === false ? false : null),
    atomicDispatchCount: Number(snapshot.atomicDispatchCount || 0),
    fallbackDispatchCount: Number(snapshot.fallbackDispatchCount || 0),
    transportRunId: snapshot.transportRunId || null,
    transportSource: snapshot.transportSource || null,
    transportPromiseAttached: snapshot.transportPromiseAttached === true,
    transportPromiseSettled: snapshot.transportPromiseSettled === true,
    transportPromiseOutcome: snapshot.transportPromiseOutcome || null,
    transportSettlementAt: snapshot.transportSettlementAt || null,
    transportPromiseError: snapshot.transportPromiseError || null,
  };
}

module.exports = {
  STATA_NAME,
  atomicCheckpointCode,
  beginAtomic,
  checkpointCode,
  checkpointPaths,
  cleanup,
  completeAtomic,
  enrich,
  escalationLadder,
  finalizeCheckpoint,
  forceResetReconnectTimeoutMs,
  hardRestoreTimeoutMs,
  initializeCheckpoint,
  isRestoreCapable,
  isSnapshotReady,
  reconnectTimeoutMs,
  restoreDowngradeSummary,
  softStopReadiness,
  shouldCleanupAfterFailure,
  publicSummary,
  readNames,
  restoreCode,
  restoreTimeoutMs,
  snapshotReadyRecord,
  snapshotCode,
  trackTransport,
  transportSummary,
  waitForSnapshot,
};
