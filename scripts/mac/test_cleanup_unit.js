#!/usr/bin/env node
"use strict";

const assert = require("assert");
const childProcess = require("child_process");
const path = require("path");

if (process.platform !== "darwin") {
  console.log("CLEANUP_MAC_UNIT_SKIP platform=" + process.platform);
  process.exit(0);
}

const cleanup = path.join(__dirname, "cleanup.sh");
const fixture = childProcess.spawn(
  "/bin/bash",
  ["-c", 'trap "exit 0" TERM; while :; do sleep 1; done', "/tmp/mcp-stata-rc64-cleanup-test"],
  { stdio: "ignore" }
);

function processActive(pid) {
  try {
    const state = childProcess.execFileSync(
      "/bin/ps",
      ["-o", "stat=", "-p", String(pid)],
      { encoding: "utf8" }
    ).trim();
    return !!state && !state.startsWith("Z");
  } catch {
    return false;
  }
}

try {
  assert.ok(Number.isInteger(fixture.pid) && fixture.pid > 1, "fixture PID missing");
  const output = childProcess.execFileSync(
    "/bin/bash",
    [cleanup, "--force", "--pid", String(fixture.pid)],
    { encoding: "utf8", timeout: 10000 }
  );
  assert.match(output, new RegExp(`pid=${fixture.pid}\\s`), "exact owned PID was not selected");
  assert.strictEqual(processActive(fixture.pid), false, "owned fixture process survived cleanup");
  console.log("CLEANUP_MAC_UNIT_PASS pid=" + fixture.pid);
} finally {
  if (processActive(fixture.pid)) {
    try { process.kill(fixture.pid, "SIGKILL"); } catch {}
  }
}
