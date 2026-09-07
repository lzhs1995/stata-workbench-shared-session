#!/usr/bin/env node
"use strict";

/**
 * Candidate audit that never rewrites the repository.
 *
 * Unlike `npm run check`, this command does not run patch application,
 * finalization, packaging, or install steps.  It only reads candidate bytes,
 * verifies their recorded identity, parses the bundle, and recomputes the Stop
 * continuity verdicts that gate rc.7.37 admission.
 */
const assert = require("node:assert");
const crypto = require("node:crypto");
const fs = require("node:fs");
const path = require("node:path");
const { spawnSync } = require("node:child_process");
const FIN = require("./finalize_bundle_identity");
const checkpoint = require("./stop_checkpoint_core");

const ROOT = path.join(__dirname, "..");
const DIST = path.join(ROOT, "dist", "extension.js");
const sha256 = (value) => crypto.createHash("sha256").update(value).digest("hex");

function main() {
  const packageJson = JSON.parse(fs.readFileSync(path.join(ROOT, "package.json"), "utf8"));
  const packageLock = JSON.parse(fs.readFileSync(path.join(ROOT, "package-lock.json"), "utf8"));
  const bundleBytes = fs.readFileSync(DIST);
  const bundle = bundleBytes.toString("utf8");

  assert.strictEqual(packageJson.version, packageLock.version, "package/lock version mismatch");
  assert.strictEqual(packageJson.version, packageLock.packages[""].version,
    "package/lock root version mismatch");
  assert.ok(bundle.includes("codex patch rc.7.37: degraded Stop recovery blocks shared continuity"),
    "rc.7.37 continuity marker missing");
  assert.ok(!bundle.includes("restored the pre-run dataset when available"),
    "Terminal still overclaims partial restoration");

  const syntax = spawnSync(process.execPath, ["--check", DIST], {
    encoding: "utf8",
    stdio: ["ignore", "pipe", "pipe"],
  });
  assert.strictEqual(syntax.status, 0,
    `bundle syntax check failed: ${String(syntax.stderr || syntax.stdout).trim()}`);

  const identity = FIN.verify(bundle);
  assert.strictEqual(identity.ok, true,
    `bundle identity mismatch: recorded=${identity.recorded} expected=${identity.expected}`);

  const full = checkpoint.softStopReadiness({
    ok: true,
    degraded: { skippedEstimates: 0, skippedGraphs: 0 },
  }, null);
  const degraded = checkpoint.softStopReadiness({
    ok: true,
    degraded: {
      skippedEstimates: 3,
      skippedGraphs: 2,
      datasetRestored: true,
      globalsRestored: true,
    },
  }, { ok: true, trueReady: true });
  const failed = checkpoint.softStopReadiness(
    { ok: false, error: "STOP_RESTORE_TIMEOUT" },
    { ok: true, trueReady: true }
  );
  assert.strictEqual(full.recoveryClass, "RECOVERED_FULL");
  assert.strictEqual(full.ready, true);
  assert.strictEqual(degraded.recoveryClass, "RECOVERED_DEGRADED");
  assert.strictEqual(degraded.ready, false);
  assert.strictEqual(degraded.continuityLost.skippedEstimates, 3);
  assert.strictEqual(degraded.continuityLost.skippedGraphs, 2);
  assert.strictEqual(failed.recoveryClass, "RECOVERY_FAILED");
  assert.strictEqual(failed.ready, false);
  assert.ok(failed.continuityLost);

  const guardFiles = ["execution_guard.js", "prerun_stage_guard.js"];
  const guards = Object.fromEntries(guardFiles.map((name) => {
    const bytes = fs.readFileSync(path.join(__dirname, name));
    return [name, sha256(bytes)];
  }));

  console.log(JSON.stringify({
    verdict: "READONLY_AUDIT_PASS",
    version: packageJson.version,
    bundleBytes: bundleBytes.length,
    diskBundleSha256: sha256(bundleBytes),
    guardBuildFingerprint: identity.recorded,
    guards,
    stopContinuity: {
      zeroLoss: full.recoveryClass,
      partialLoss: degraded.recoveryClass,
      checkpointFailure: failed.recoveryClass,
    },
  }, null, 2));
}

main();
