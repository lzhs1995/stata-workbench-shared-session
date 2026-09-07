#!/usr/bin/env node
"use strict";

const assert = require("assert");
const fs = require("fs");
const os = require("os");
const path = require("path");
const core = require("./execution_lifecycle_core");

let failed = 0;
function check(name, fn) {
  try {
    fn();
    console.log("PASS", name);
  } catch (error) {
    failed += 1;
    console.error("FAIL", name, error && error.message || error);
  }
}

check("MCP_STATA_TEMP is the first log discovery directory", () => {
  const dirs = core.resolveLogDirectories({
    env: { MCP_STATA_TEMP: "/tmp/session-specific/mcp-stata-temp" },
    cwd: "/workspace/project",
    workspaceRoots: ["/workspace"],
  });
  assert.strictEqual(dirs[0], path.resolve("/tmp/session-specific/mcp-stata-temp"));
});

check("exact SMCL result line verifies current completion marker", () => {
  const result = core.inspectLogText(
    '{com}. display as text "___CODEX_RUN_DONE_run_1___"\n' +
    "{res}{txt}___CODEX_RUN_DONE_run_1___\n{txt}end of do-file\n",
    "run_1"
  );
  assert.strictEqual(result.completionMarkerVerified, true);
  assert.strictEqual(result.endOfDoFile, true);
});

check("command echo and another run marker cannot complete current run", () => {
  const result = core.inspectLogText(
    '{com}. display as text "___CODEX_RUN_DONE_run_1___"\n' +
    "{res}{txt}___CODEX_RUN_DONE_run_2___\n",
    "run_1"
  );
  assert.strictEqual(result.completionMarkerVerified, false);
});

check("graph routing marker text cannot complete the current Stata run", () => {
  const result = core.inspectLogText(
    "[Graph Panel] prepared ___CODEX_RUN_DONE_run_1___ for routing\n",
    "run_1"
  );
  assert.strictEqual(result.completionMarkerVerified, false);
  assert.strictEqual(result.endOfDoFile, false);
  assert.strictEqual(result.rc, null);
});

check("SMCL search links do not become Stata return codes", () => {
  const result = core.inspectLogText(
    "{txt}{search r(111), local:r(111);}\n{search r(111), local:r(111);}\n",
    "run_1"
  );
  assert.strictEqual(result.rc, null);
  assert.strictEqual(result.noVariablesDefined, false);
});

check("a real standalone rc is retained", () => {
  const result = core.inspectLogText("{err}no variables defined\n{txt}r(111);\n", "run_1");
  assert.strictEqual(result.rc, 111);
  assert.strictEqual(result.noVariablesDefined, true);
});

check("final log discovery binds only the exact current run marker", () => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "rc7-run-log-"));
  try {
    const oldLog = path.join(directory, "mcp_stata_old.log");
    const currentLog = path.join(directory, "mcp_stata_current.log");
    fs.writeFileSync(oldLog, "___CODEX_RUN_DONE_run_old___\n", "utf8");
    fs.writeFileSync(currentLog, "{res}{txt}___CODEX_RUN_DONE_run_current___\n", "utf8");
    const now = new Date();
    fs.utimesSync(currentLog, new Date(now.getTime() - 1000), new Date(now.getTime() - 1000));
    fs.utimesSync(oldLog, now, now);
    const found = core.findRunLog({
      directories: [directory],
      runId: "run_current",
      startedAt: Date.now() - 1000,
    });
    assert.ok(found);
    assert.strictEqual(found.logPath, currentLog);
    assert.strictEqual(found.inspection.completionMarkerVerified, true);
  } finally {
    fs.rmSync(directory, { recursive: true, force: true });
  }
});

check("session evidence identifies execution completion but cannot replace a truncated per-run log", () => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "rc7-session-log-"));
  try {
    const perRunLog = path.join(directory, "mcp_stata_truncated.log");
    const sessionLog = path.join(directory, "mcp_session_active.smcl");
    fs.writeFileSync(perRunLog, "{res}{txt}long summarize output without its tail\n", "utf8");
    fs.writeFileSync(
      sessionLog,
      '{com}. display as text "___CODEX_RUN_DONE_run_current___"\n' +
      "{res}{txt}___CODEX_RUN_DONE_run_current___\n",
      "utf8"
    );
    const input = {
      directories: [directory],
      runId: "run_current",
      startedAt: Date.now() - 1000,
    };
    assert.strictEqual(core.findRunLog(input), null);
    const found = core.findRunLog({ ...input, includeSessionLogs: true });
    assert.ok(found);
    assert.strictEqual(found.logPath, sessionLog);
    assert.strictEqual(found.inspection.completionMarkerVerified, true);
    assert.deepStrictEqual(core.transportSettlementDecision(
      { success: true, rc: 0, completionMarkerVerified: true },
      {
        completionMarkerVerified: true,
        perRunEvidenceRequired: true,
        perRunCompletionMarkerVerified: false,
      }
    ), {
      failed: false,
      completionMarkerVerified: false,
      perRunEvidenceRequired: true,
      release: false,
    });
    assert.strictEqual(core.findRunLog({
      ...input,
      runId: "run_other",
      includeSessionLogs: true,
    }), null);
  } finally {
    fs.rmSync(directory, { recursive: true, force: true });
  }
});

check("lifecycle adopts the Terminal run id and records completion", () => {
  const bridge = {};
  core.beginRun(bridge, {
    requestId: "http_1",
    sourceMode: "visible-bridge",
    perRunEvidenceRequired: true,
  }, 0);
  core.adoptRunId(bridge, "terminal_1");
  core.recordStarted(bridge, 10);
  core.recordLogPath(bridge, "/tmp/run.log", 20);
  core.recordCompletionMarker(bridge, 30);
  core.finishRun(bridge, { rc: 0, logPath: "/tmp/run.log", completionMarkerVerified: true }, 40);
  const view = core.publicLifecycle(bridge);
  assert.strictEqual(view.phase, "completed");
  assert.strictEqual(view.rc, 0);
  assert.strictEqual(view.releasedAt, new Date(40).toISOString());
  assert.strictEqual(view.runId, "terminal_1");
  assert.strictEqual(view.lastCompletedRun.requestId, "http_1");
  assert.strictEqual(view.lastCompletedRun.completionMarkerVerified, true);
  assert.strictEqual(view.perRunEvidenceRequired, true);
  assert.strictEqual(view.perRunCompletionMarkerVerified, true);
  assert.strictEqual(view.perRunEvidenceFailure, null);
  assert.strictEqual(view.lastCompletedRun.phase, "completed");
});

check("session completion starts convergence but cannot verify per-run evidence", () => {
  const bridge = {};
  core.beginRun(bridge, {
    runId: "run_session_only",
    sourceMode: "visible-bridge",
    perRunEvidenceRequired: true,
  }, 1000);
  core.recordSessionCompletionMarker(bridge, 1100, "run_session_only");
  let view = core.publicLifecycle(bridge);
  assert.strictEqual(view.phase, "converging");
  assert.strictEqual(view.sessionCompletionMarkerAt, new Date(1100).toISOString());
  assert.strictEqual(view.completionMarkerVerified, false);
  assert.strictEqual(view.perRunCompletionMarkerVerified, false);
  assert.strictEqual(core.transportSettlementDecision(
    { success: true, rc: 0, completionMarkerVerified: true },
    bridge.lifecycle
  ).release, false);

  core.recordPerRunEvidenceFailure(
    bridge,
    "PER_RUN_LOG_INCOMPLETE",
    11100,
    "run_session_only"
  );
  view = core.publicLifecycle(bridge);
  assert.strictEqual(view.phase, "failed");
  assert.strictEqual(view.perRunEvidenceFailure, "PER_RUN_LOG_INCOMPLETE");
  assert.strictEqual(view.completionMarkerVerified, false);
});

check("only the per-run marker produces verified completion", () => {
  const bridge = {};
  core.beginRun(bridge, {
    runId: "run_per_run",
    sourceMode: "human-file",
    perRunEvidenceRequired: true,
  }, 2000);
  core.recordSessionCompletionMarker(bridge, 2100, "run_per_run");
  core.recordPerRunCompletionMarker(bridge, 2200, "run_per_run");
  const view = core.publicLifecycle(bridge);
  assert.strictEqual(view.phase, "completing");
  assert.strictEqual(view.completionMarkerVerified, true);
  assert.strictEqual(view.perRunCompletionMarkerVerified, true);
  assert.strictEqual(view.completionMarkerAt, new Date(2200).toISOString());
  assert.strictEqual(core.transportSettlementDecision(
    { success: true, rc: 0 },
    bridge.lifecycle
  ).release, true);
});

check("late callbacks cannot reopen a released lifecycle", () => {
  const bridge = {};
  core.beginRun(bridge, { requestId: "http_2", sourceMode: "manual-selection" }, 0);
  core.adoptRunId(bridge, "terminal_2");
  core.recordCompletionMarker(bridge, 30);
  core.finishRun(bridge, { rc: 0, completionMarkerVerified: true }, 40);
  core.recordProgress(bridge, 50);
  core.recordCompletionMarker(bridge, 60);
  const view = core.publicLifecycle(bridge);
  assert.strictEqual(view.phase, "completed");
  assert.strictEqual(view.releasedAt, new Date(40).toISOString());
  assert.strictEqual(view.lastProgressAt, new Date(40).toISOString());
});

check("late callbacks from a previous run cannot mutate the current lifecycle", () => {
  const bridge = {};
  core.beginRun(bridge, { runId: "run_old", sourceMode: "agent" }, 10);
  core.beginRun(bridge, { runId: "run_current", sourceMode: "human-selection" }, 20);
  core.recordStarted(bridge, 21, "run_old");
  core.recordLogPath(bridge, "/tmp/old.log", 22, "run_old");
  core.recordProgress(bridge, 23, "run_old");
  core.recordCompletionMarker(bridge, 24, "run_old");
  let view = core.publicLifecycle(bridge);
  assert.strictEqual(view.runId, "run_current");
  assert.strictEqual(view.phase, "acquired");
  assert.strictEqual(view.logPath, null);
  assert.strictEqual(view.completionMarkerVerified, false);

  core.recordStarted(bridge, 25, "run_current");
  core.recordLogPath(bridge, "/tmp/current.log", 26, "run_current");
  core.recordCompletionMarker(bridge, 27, "run_current");
  view = core.publicLifecycle(bridge);
  assert.strictEqual(view.phase, "completing");
  assert.strictEqual(view.logPath, "/tmp/current.log");
  assert.strictEqual(view.completionMarkerVerified, true);
});

check("completion evidence and release use one timestamp", () => {
  const bridge = {};
  core.beginRun(bridge, { requestId: "terminal_clock", sourceMode: "terminal-input" }, 10);
  const originalNow = Date.now;
  let clock = 100;
  Date.now = () => clock++;
  try {
    core.finishRun(bridge, {
      rc: 0,
      logPath: "/tmp/terminal-clock.log",
      completionMarkerVerified: true,
    });
  } finally {
    Date.now = originalNow;
  }
  const view = core.publicLifecycle(bridge);
  assert.strictEqual(view.completionMarkerAt, view.releasedAt);
  assert.strictEqual(view.lastProgressAt, view.releasedAt);
  assert.strictEqual(view.lastCompletedRun.durationMs, 90);
});

check("successful transport settlement waits for the exact marker", () => {
  const pending = core.transportSettlementDecision(
    { success: true, rc: 0, logPath: "/tmp/growing.log" },
    { completionMarkerVerified: false }
  );
  assert.deepStrictEqual(pending, {
    failed: false,
    completionMarkerVerified: false,
    perRunEvidenceRequired: false,
    release: false,
  });
});

check("per-run completion waits through a bounded session-log convergence window", () => {
  assert.deepStrictEqual(core.perRunLogCompletionDecision({
    sessionCompletionMarkerAt: 1000,
    perRunCompletionMarkerVerified: false,
    now: 10999,
    graceMs: 10000,
  }), { state: "converging", release: false, failed: false });
  assert.deepStrictEqual(core.perRunLogCompletionDecision({
    sessionCompletionMarkerAt: 1000,
    perRunCompletionMarkerVerified: true,
    now: 1001,
    graceMs: 10000,
  }), { state: "verified", release: true, failed: false });
  assert.deepStrictEqual(core.perRunLogCompletionDecision({
    sessionCompletionMarkerAt: 1000,
    perRunCompletionMarkerVerified: false,
    now: 11000,
    graceMs: 10000,
  }), { state: "incomplete", release: true, failed: true });
});

check("verified or failed transport settlement can release", () => {
  assert.strictEqual(core.transportSettlementDecision(
    { success: true, rc: 0 },
    { completionMarkerVerified: true }
  ).release, true);
  assert.strictEqual(core.transportSettlementDecision(
    { success: false, rc: 111, error: "no variables defined" },
    { completionMarkerVerified: false }
  ).release, true);
});

check("verified transport result preserves base fields and log evidence", () => {
  const result = core.verifiedTransportResult(
    { success: true, rc: 0, label: "base" },
    { logPath: "/tmp/final.log", logSize: 63061 }
  );
  assert.strictEqual(result.label, "base");
  assert.strictEqual(result.logPath, "/tmp/final.log");
  assert.strictEqual(result.logSize, 63061);
  assert.strictEqual(result.completionMarkerVerified, true);
});

if (failed) process.exit(1);
console.log("EXECUTION_LIFECYCLE_RC7_PASS");
