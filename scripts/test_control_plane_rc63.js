#!/usr/bin/env node
/**
 * rc.6.3 control-plane pure-logic tests (not full extension host).
 * Covers: restoreEnabled fail-closed, transport+marker, force-reset needsSmoke.
 */
"use strict";
const assert = require("assert");
let failed = 0;
function check(name, fn) {
  try {
    fn();
    console.log("PASS", name);
  } catch (e) {
    failed++;
    console.error("FAIL", name, e && e.message || e);
  }
}

function restoreEnabled(cfgValue, globalKill, throws) {
  let enabled = false;
  try {
    if (throws) throw new Error("cfg");
    enabled = cfgValue === true && !globalKill;
  } catch {
    enabled = false;
  }
  return enabled;
}

function evalRestore({ transportFail, log, runId }) {
  let ok = false;
  let detail = "restore-unconfirmed";
  let transportOk = true;
  const marker =
    "__CODEX_USE_RC_" + String(runId || "na").replace(/[^A-Za-z0-9_]/g, "_");
  const res = transportFail
    ? { success: false, error: "boom", stdout: log }
    : { success: true, stdout: log };
  if (res.success === false || res.error) {
    transportOk = false;
    detail = String(res.error || "restore-failed");
  }
  const text = String(res.stdout || "");
  const m = text.match(
    new RegExp(marker.replace(/[.*+?^${}()|[\]\\]/g, "\\$&") + "=(\\d+)(?:\\D|$)")
  );
  if (transportOk && m && m[1] === "0") {
    ok = true;
    detail = "use-rc-0";
  } else if (!transportOk) {
    ok = false;
  } else if (m && m[1] !== "0") {
    ok = false;
    detail = "use-rc-nonzero:" + m[1];
  } else if (text) {
    ok = false;
    detail = "use-rc-marker-missing:" + marker;
  } else {
    ok = false;
    detail = "use-rc-log-empty";
  }
  return { ok, detail, marker };
}

function needsSmoke(reason, hadContinuityLost) {
  return (
    !!hadContinuityLost ||
    /pre-log|hard-stall|panic-kill|error transport reset|continuity/i.test(
      String(reason || "")
    )
  );
}

function smokeReason(reason, hadContinuityLost) {
  if (!needsSmoke(reason, hadContinuityLost)) return "force-reset-complete";
  if (hadContinuityLost) return "force-reset-needs-smoke: continuity-lost";
  return "force-reset-needs-smoke: " + (reason || "unknown");
}

check("restoreEnabled default/catch false", () => {
  assert.strictEqual(restoreEnabled(undefined, false, false), false);
  assert.strictEqual(restoreEnabled(false, false, false), false);
  assert.strictEqual(restoreEnabled(true, false, false), true);
  assert.strictEqual(restoreEnabled(true, true, false), false);
  assert.strictEqual(restoreEnabled(true, false, true), false); // throw → false
});

check("transport fail not flipped by marker 0", () => {
  const r = evalRestore({
    transportFail: true,
    log: "__CODEX_USE_RC_r1=0\n",
    runId: "r1",
  });
  assert.strictEqual(r.ok, false);
});

check("current run marker 0 succeeds", () => {
  const r = evalRestore({ log: "__CODEX_USE_RC_r1=0\n", runId: "r1" });
  assert.strictEqual(r.ok, true);
  assert.strictEqual(r.detail, "use-rc-0");
});

check("old run marker ignored", () => {
  const r = evalRestore({ log: "__CODEX_USE_RC_old=0\n", runId: "r1" });
  assert.strictEqual(r.ok, false);
});

check("http force-reset with continuityLost needs smoke", () => {
  assert.strictEqual(needsSmoke("http /force-reset", true), true);
  assert.strictEqual(
    smokeReason("http /force-reset", true),
    "force-reset-needs-smoke: continuity-lost"
  );
  assert.strictEqual(needsSmoke("http /force-reset", false), false);
  assert.strictEqual(smokeReason("http /force-reset", false), "force-reset-complete");
});

check("panic reason still needs smoke", () => {
  assert.strictEqual(needsSmoke("panic-kill transport reset", false), true);
});

if (failed) {
  console.error(failed + " failure(s)");
  process.exit(1);
}
console.log("\nCONTROL_PLANE_RC63_PASS");
