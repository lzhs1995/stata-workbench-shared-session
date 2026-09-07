#!/usr/bin/env node
"use strict";

const assert = require("assert");
const fs = require("fs");
const path = require("path");

const bundle = fs.readFileSync(path.join(__dirname, "..", "dist", "extension.js"), "utf8");
const endpointAt = bundle.indexOf('__req.url==="/soft-stop"');
const forceResetAt = bundle.indexOf('__req.url==="/force-reset"');

assert.ok(endpointAt >= 0, "soft Stop endpoint must exist");
assert.ok(forceResetAt > endpointAt, "soft Stop must be routed before force reset");

const endpoint = bundle.slice(endpointAt, forceResetAt);
assert.ok(endpoint.includes("globalThis.__codexSoftStop"));
assert.ok(endpoint.includes('"no active Stata Workbench request"'));
assert.ok(endpoint.includes("__last.ok===true"));
assert.ok(endpoint.includes("!__state.busy"));
assert.ok(endpoint.includes("!__state.postRunBusy"));
assert.ok(endpoint.includes("__state.trueReady"));
assert.ok(!endpoint.includes("__codexForceReset"));

console.log("SOFT_STOP_BRIDGE_RC7_PASS");
