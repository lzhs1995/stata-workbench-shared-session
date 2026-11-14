#!/usr/bin/env node
"use strict";
const fs = require("node:fs");
const crypto = require("node:crypto");
const cp = require("node:child_process");
const path = require("node:path");
const root = path.resolve(__dirname, "..");
const pkg = require(path.join(root, "package.json"));
const hash = () => crypto.createHash("sha256").update(fs.readFileSync(path.join(root, "dist/extension.js"))).digest("hex");
const before = hash();
// Exclude patch application, not regressions; retain --check finalization.
const mutators = new Set(["node scripts/apply_rc7_shared_execution_patch.js", "node scripts/finalize_bundle_identity.js"]);
const commands = ["node scripts/audit_candidate_readonly.js", "node --check scripts/test_activation_isolation.js",
  "node scripts/test_activation_isolation.js", "node scripts/test_edit_proposal_core.js",
  "node --check scripts/apply_private_environment_patch.js",
  "node --check scripts/private_environment_core.js",
  "node --test scripts/test_private_environment.js",
  "node scripts/test_edit_proposal_patch.js",
  "node --test scripts/test_window_session_core.js",
  "node --test scripts/test_runtime_copy_reservation.js",
  "node --test scripts/test_runtime_source_selection.js",
  "node --test scripts/test_window_slot_recovery.js",
  "node scripts/test_source_path_mappings.js",
  "node scripts/test_backend_shutdown.js",
  "node --test scripts/test_native_close_evidence.js",
  "node scripts/test_backend_shutdown_bundle.js",
  "node scripts/test_backend_shutdown_process.js",
  "node scripts/test_backend_shutdown_darwin.js",
  "node scripts/test_backend_recovery_admission.js",
  ...pkg.scripts["check:legacy"].split(" && ")];
let count = 0;
const keepGoing = process.argv.includes("--keep-going");
const failed = [];
for (const command of commands) {
  if (mutators.has(command)) continue;
  const argv = command.split(" ");
  if (argv[0] !== "node") throw new Error("unrecognized verifier command");
  const r = cp.spawnSync(process.execPath, argv.slice(1), {cwd: root, encoding: "utf8"});
  count++;
  if (r.status !== 0) {
    console.error(command, r.stdout, r.stderr);
    process.exitCode = 1;
    failed.push(command);
    if (!keepGoing) break;
  }
}
if (hash() !== before) throw new Error("Verifier modified sealed runtime");
console.log(JSON.stringify({verdict: process.exitCode ? "FAIL" : "PASS", commands: count, failed, runtimeUnchanged: true, bundleSha256: before}));
