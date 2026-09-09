"use strict";
// Versioned identity metadata, never live acceptance. Preserve prior manifest.
const fs = require("node:fs"), path = require("node:path"), crypto = require("node:crypto");
const root = path.resolve(__dirname, "..");
const file = path.join(root, "release/runtime-manifest.json");
const raw = fs.readFileSync(file), prior = JSON.parse(raw);
const argv = process.argv.slice(2), opt = key => argv[argv.indexOf(key) + 1];
const digest = crypto.createHash("sha256").update(raw).digest("hex");
if (!argv.includes("--expected-prior-sha256") || opt("--expected-prior-sha256") !== digest)
  throw new Error("explicit exact prior manifest SHA256 required");
const id = opt("--candidate-id");
if (!argv.includes("--candidate-id") || !/^visible-cowork-1-dev\.[1-9][0-9]*$/.test(id) || id === prior.candidateId)
  throw new Error("explicit fresh development candidate id required; never a formal release verdict");
const history = path.join(root, "release/history");
fs.mkdirSync(history, {recursive:true});
fs.writeFileSync(path.join(history, (prior.candidateId || "public.2") + "-runtime-manifest.json"), raw, {flag:"wx"});
const extras = ["scripts/visible_cowork.js", "scripts/wire_visible_cowork.js", "scripts/test_visible_cowork.js",
  "tools/shared_stata.py", "tools/cowork_task.py", "tools/verified_workbench.py", "tools/mac_permissions.py",
  "tools/test_cowork_task.py", "tools/test_shared_stata.py"];
const files = {};
for (const rel of [...new Set([...Object.keys(prior.files), ...extras])]) {
  const bytes=fs.readFileSync(path.join(root,rel));
  files[rel]={sha256:crypto.createHash("sha256").update(bytes).digest("hex"),bytes:bytes.length};
}
const candidate={schemaVersion:1,version:require(path.join(root,"package.json")).version,
  candidateId:id,acceptance:"PENDING_LIVE_AND_FULL45",files,
  priorManifestSha256:digest,
  scope:"Source identity only. Original research instance is not upgraded by this operation."};
fs.writeFileSync(file,JSON.stringify(candidate,null,2)+"\n");
console.log(JSON.stringify({candidateId:candidate.candidateId,files:Object.keys(files).length,acceptance:candidate.acceptance}));
