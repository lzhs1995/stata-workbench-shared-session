"use strict";
// Test-only layer accounting. A historical-layer check is not a final-runtime
// behavior check. Every peeled layer must recompose to the exact shipped bytes.
const assert = require("node:assert/strict");
const crypto = require("node:crypto");
const { LATER, revertAfter } = require("./later_bundle_patches");
const fingerprint = require("./finalize_bundle_identity");
const { createLifecycle } = require("./backend_shutdown_core");
const sha = source => crypto.createHash("sha256").update(source).digest("hex");
function historicalLayer(bundle, name) {
  const layer = revertAfter(bundle, name);
  let recomposed = layer;
  for (const later of LATER.slice(LATER.indexOf(name)+1)) recomposed = require(later).patchBundle(recomposed);
  assert.equal(sha(fingerprint.finalize(recomposed).text), sha(bundle), "historical peel/reapply must restore exact final bytes: "+name);
  return layer;
}
function beforeDaily(bundle) { return historicalLayer(bundle, "./apply_windows_kill_reset_patch"); }
function reapplyDaily(layer) {
  for (const name of LATER.slice(LATER.indexOf("./apply_windows_kill_reset_patch")+1)) layer = require(name).patchBundle(layer);
  return fingerprint.finalize(layer).text;
}
function attachLifecycle(client, options = {}) {
  const life = createLifecycle(client, options);
  client.__codexLifecycle = () => life;
  return life;
}
function between(source, start, end) {
  const at=source.indexOf(start), stop=source.indexOf(end,at+start.length);
  assert.ok(at>=0 && source.indexOf(start,at+1)<0 && stop>at,"unique bounded source: "+start);
  return source.slice(at,stop);
}
module.exports = { historicalLayer, beforeDaily, reapplyDaily, attachLifecycle, between, sha };
