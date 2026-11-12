#!/usr/bin/env node
"use strict";

// 回归：Next 开发线身份。bundle 的端口回退值、package.json 默认端口、工具默认值都必须
// 是 17601，任何地方都不能回落到稳定版和研究实例占用的 17485。
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const patch = require("./apply_next_identity_patch");
const fingerprint = require("./finalize_bundle_identity");
const { LATER, revertAfter } = require("./later_bundle_patches");

const root = path.join(__dirname, "..");
const bundle = fs.readFileSync(path.join(root, "dist", "extension.js"), "utf8");
const pkg = JSON.parse(fs.readFileSync(path.join(root, "package.json"), "utf8"));

// 1. 幂等、精确可逆，锚点 fail closed。
// Exact historical layer; final runtime behavior remains below.
assert.equal(fingerprint.verify(bundle).ok, true);
const name = "./apply_next_identity_patch";
const sealed = require("./test_daily_bundle_helpers").historicalLayer(bundle, name);
assert.equal(patch.patchBundle(sealed), sealed, "historical byte idempotence");
const legacy = patch.revertBundle(sealed);
const previous = LATER[LATER.indexOf(name) - 1];
assert.equal(legacy, revertAfter(bundle, previous), "this patch directly follows the previous later layer");
assert.equal(patch.patchBundle(legacy), sealed, "replay reproduces the sealed layer");
assert.throws(() => patch.patchBundle(legacy.replace(patch.ANCHORS.catchDefault[0], "")), /anchor/);
assert.throws(() => patch.patchBundle(legacy + patch.ANCHORS.configDefault[0]), /anchor/);
assert.throws(() => patch.patchBundle(legacy + 'get("visibleBridgePort",17601)'), /partial/);

// Historical Next fallback remains verifiable in the exact peeled layer.
assert.equal(sealed.includes("17485"), false);
assert.equal(legacy.split("17485").length - 1, 2);
assert.ok(sealed.includes('get("visibleBridgePort",17601)'));
// Final daily contract: stable extension identity and per-window OS-assigned port.
const port = pkg.contributes.configuration.properties["stataMcp.visibleBridgePort"];
assert.equal(port.default, 0);
assert.equal(pkg.publisher, "lzhs1995");
assert.equal(pkg.name, "stata-workbench-shared-session");
assert.equal(pkg.version, "0.2.0");
assert.equal(/\(Next\)$/.test(pkg.displayName), false);
assert.ok(bundle.includes("__port=globalThis.__codexWindowSession.requestedPort"));
assert.ok(bundle.includes("onBound:__state=>{__port=__state.port;"));
assert.equal(bundle.includes('get("visibleBridgePort",17601)'), false);
const {configuredPort} = require("./window_session_core");
assert.equal(configuredPort({inspect:()=>({defaultValue:17601})}),0);
assert.equal(configuredPort({inspect:()=>({globalValue:17991})}),17991);
assert.throws(()=>configuredPort({inspect:()=>({workspaceValue:"17991"})}), /INVALID_BRIDGE_PORT/);
// Preserve the old cross-tool isolation negative. Legacy compatibility paths
// may retain 17601; ordinary-window clients bind the actual registry port.
for (const rel of ["tools/verified_workbench.py", "tools/workbench_doctor.py", "examples/platform-acceptance/stress.py",
  "scripts/mac/lib.sh", "scripts/patch_manager.js"]) {
  const text = fs.readFileSync(path.join(root, rel), "utf8");
  assert.equal(/17485/.test(text), false, rel + " must not fall back to the historical stable port");
}
const verified = fs.readFileSync(path.join(root, "tools", "verified_workbench.py"), "utf8");
assert.ok(verified.includes(`"extensions/${pkg.publisher}.${pkg.name}-${pkg.version}"`));
assert.ok(verified.includes('str(Path.home() / ".stata-workbench")'));
console.log("PASS historical Next identity exact inverse/replay; final daily stable ID, port 0 and explicit-port validation");
