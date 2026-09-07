#!/usr/bin/env node
"use strict";

const assert = require("assert");
const fs = require("fs");
const path = require("path");
const policy = require("./manual_run_policy");

const root = path.resolve(__dirname, "..");
// Public structural fixture; no dependency on a private research do-file.
const demoMed = ["mi estimate: regress outcome treatment", ...Array.from({length: 196}, () => "display 1")].join("\n");

assert.strictEqual(policy.isLongManualSelection("display 2 + 2"), false);
assert.strictEqual(policy.isLongManualSelection("mi estimate: regress y x"), true);
assert.strictEqual(policy.isLongManualSelection(demoMed), true);
assert.strictEqual(policy.isLongManualSelection(
  Array.from({ length: 45 }, (_, index) => index === 20 ? "tab1 x" : "display 1").join("\n")
), true);
assert.strictEqual(policy.isLongManualSelection(
  Array.from({ length: 121 }, () => "display 1").join("\n")
), true);

const bundle = fs.readFileSync(path.join(root, "dist", "extension.js"), "utf8");
assert.ok(bundle.includes("codex patch rc.7.10.8: structural long-selection watchdog"));
assert.ok(bundle.includes("codex patch rc.7.10.8.1: manual run policy is command-visible"));
assert.ok(bundle.includes("globalThis.__codexManualRunPolicy=__codexManualPolicy"));
assert.ok(bundle.includes("globalThis.__codexManualRunPolicy.isLongManualSelection(I)"));
assert.ok(!bundle.includes("=__codexManualPolicy.isLongManualSelection(I)"));
assert.ok(bundle.includes("codex patch rc.7.10.9: long manual selections keep exact completion markers"));
assert.ok(bundle.includes("let __codexManualSelectionExactMarker=e?"));
assert.ok(bundle.includes("__codexSelectionBody=String(__codexSelectionBody||\"\").replace"));
assert.ok(bundle.includes("codex patch rc.7.10.35: structural long bridge watchdog"));
assert.ok(bundle.includes("globalThis.__codexManualRunPolicy.isLongManualSelection(__codexBridgeDocScanText)"));
assert.ok(bundle.includes("codex patch rc.7.10.48: large document graph runs extend the pre-log watchdog"));
assert.ok(bundle.includes("&&__codexHumanFileDoc&&__codexHumanFileGraphCount>25)"));
assert.ok(bundle.includes("let __codexHumanFilePreLogStallMs=(__codexHumanFileIsHugeMiDocumentRun?900000:"));
assert.ok(bundle.includes("preLogStallAfterMs:(__codexManualSelectionLongRun?900000:45000)"));
assert.ok(bundle.includes("preLogStallAfterMs:(__codexBridgeLongRun?900000:120000)"));
assert.ok(bundle.includes("hardStallAfterMs:(__codexBridgeLongRun?14400000:600000)"));
assert.ok(bundle.includes("hardStallIdleMs:(__codexBridgeLongRun?1800000:60000)"));

console.log("MANUAL_RUN_POLICY_RC7_PASS");
