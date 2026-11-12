"use strict";
const test = require("node:test"), assert = require("node:assert/strict");
const fs = require("node:fs"), path = require("node:path"), vm = require("node:vm");
const patch = require("./apply_edit_proposal_patch");
const auth = require("./apply_next_bridge_auth_patch");
const bundle = fs.readFileSync(path.join(__dirname, "..", "dist", "extension.js"), "utf8");
test("actual candidate upgrades old E1, is idempotent, parses, and reverts", () => {
  const sealed = patch.patchBundle(bundle, { finalize: false });
  assert.equal(patch.patchBundle(sealed, { finalize: false }), sealed);
  new vm.Script(sealed);
  const siblings = bundle.slice(bundle.indexOf("globalThis.__codexRestoreReadinessRef=require"), bundle.indexOf("globalThis.__codexEditGate=globalThis.__codexEditGate||require"));
  assert.ok(siblings.length > 0); assert.ok(sealed.includes(siblings), "F0/F2 restore and cancel initializers remain byte-identical");
  assert.ok(sealed.indexOf(patch.ROUTE) > sealed.indexOf('let __nextAuth='), "authenticated before new routes");
  assert.ok(sealed.indexOf(patch.GUARD) < sealed.indexOf('__code=globalThis.__codexPrepareCompatExecution?'));
  assert.equal(patch.patchBundle(patch.revertBundle(sealed), { finalize: false }).includes(patch.INSTALL), true);
  assert.throws(() => patch.patchBundle(sealed.replace(patch.GUARD, "")), /partial/);
});
test("runtime wiring uses real vscode module, per-window snapshot dir and session identity", () => {
  const vscode = {}, captured = {}, globals = { __codexNextSessionRef: { sessionId: "s", dataDir: "/session", record: () => {} },
    __codexResetGeneration: 3, __codexWindowSession: { dirs: { "edit-snapshots": "/window/snapshots" }, status: () => ({ closing: true }) } };
  const requireMock = name => name.endsWith("agent_edit_vscode.js") ? { createAgentApi: (api, options) => { captured.api = api; captured.options = options; return { gate: {} }; } } : require(name);
  vm.runInNewContext(patch.INSTALL, { globalThis: globals, FHg: () => vscode, rg: path, yC: { extensionUri: { fsPath: "/extension" }, subscriptions: [] }, require: requireMock });
  assert.equal(captured.api, vscode); assert.equal(captured.options.snapshotRoot, "/window/snapshots");
  assert.equal(captured.options.identity().closing, true); assert.equal(captured.options.identity().generation, 3);
});
test("auth refusals do not reach agent route", () => {
  const text = auth.EDITS[2][1], gate = text.slice(text.indexOf("let __nextAuth="));
  for (const status of [401, 403]) {
    let reached = false, sent;
    const globals = { __codexNextAuthRef: { check: () => ({ ok: false, status, reason: "AUTH" }), shouldRecordRefusal: () => false } };
    const run = new Function("globalThis", "__req", "__res", "__send", "__routed", gate + ";__routed()");
    run(globals, { headers: {} }, {}, (res, code) => { sent = code; }, () => { reached = true; });
    assert.equal(sent, status); assert.equal(reached, false);
  }
});
