#!/usr/bin/env node
"use strict";

const assert = require("assert");
const fs = require("fs");
const path = require("path");
const guard = require("./prerun_stage_guard.js");

const root = path.resolve(__dirname, "..");
const source = fs.readFileSync(path.join(root, "dist", "extension.js"), "utf8");
const marker = "codex patch rc.7.34: outer pre-run failure contract";

assert.strictEqual(source.split(marker).length - 1, 2,
  "rc.7.34 marker must appear once in the route and once as the replay marker");
assert.ok(source.includes(
  "let __codexOuterPrt=e&&e.__codexPreRunTimeout"),
"outer request catch must inspect the structured pre-run failure");
assert.ok(source.includes(
  "(__codexOuterPrt&&__codexOuterPrt.status)||500"),
"outer request catch must preserve the guard HTTP status");
assert.ok(source.includes(
  "preRunFailure:__codexOuterPrt"),
"outer request catch must expose the complete nested failure");
assert.ok(!source.includes(
  "catch(e){__release();__send(__res,500,{ok:false,error:e?.message||String(e),patch:__patch})"),
"the lossy outer catch must be absent");

const state = guard.createStageState("snapshot", {runId: "r-contract"});
Object.assign(state, {
  result: guard.RESULT.TIMED_OUT,
  timeoutMs: 60000,
  elapsedMs: 60000,
  transportPromiseAttached: true,
  transportSettled: true,
  settlement: "DRAINED",
  recoveryRequired: false,
});
const failure = guard.timeoutResponse("snapshot", state);
const response = Object.assign({}, failure, {
  ok: false,
  preRunFailure: failure,
  patch: "codex-rc7-shared-execution",
});
const decoded = JSON.parse(JSON.stringify(response));
assert.strictEqual(decoded.status, 504);
assert.strictEqual(decoded.payloadDispatched, false);
assert.strictEqual(decoded.transportPromiseAttached, true);
assert.strictEqual(decoded.transportSettled, true);
assert.strictEqual(decoded.settlement, "DRAINED");
assert.strictEqual(decoded.recoveryRequired, false);
assert.deepStrictEqual(decoded.preRunFailure, failure);

console.log("PRERUN_RESPONSE_WIRING_RC734_OK");
