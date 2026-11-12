"use strict";

const fs = require("node:fs");
const path = require("node:path");
const fingerprint = require("./finalize_bundle_identity");
const LEGACY_MARKER = "/* next patch E1: agent .do edits require explicit diff acceptance */";
const MARKER = "/* daily E2: durable proposals and run-bound agent controls */";
const INIT = 'let __send=(o,s,n)=>{o.writeHead(s,{"content-type":"application/json"}),o.end(JSON.stringify(n))};';
const RUN = 'if(__req.method!=="POST"||__req.url!=="/run-command"){__res.writeHead(404);__res.end("not found");return}';
const PREPARE = '__code=globalThis.__codexPrepareCompatExecution?';
const ROUTE = 'if(globalThis.__codexAgentApi.route(__req,__res,__send))return;';
const GUARD = 'if(__p.agentWorkflow){try{globalThis.__codexAgentApi.bindRun(__p.agentWorkflow,__runId)}catch(__e){__send(__res,409,{ok:false,reasonCode:"AGENT_PRECONDITION_FAILED",payloadDispatched:false,error:String(__e.message)});return}}';
const INSTALL = MARKER + 'globalThis.__codexAgentApi=require(rg.join(((yC&&yC.extensionUri&&yC.extensionUri.fsPath)||process.cwd()),"scripts","agent_edit_vscode.js")).createAgentApi(FHg(),{snapshotRoot:(globalThis.__codexWindowSession&&globalThis.__codexWindowSession.dirs["edit-snapshots"])||require("node:path").join(globalThis.__codexNextSessionRef.dataDir,"edit-snapshots"),identity:()=>({sessionId:globalThis.__codexNextSessionRef.sessionId,generation:Number(globalThis.__codexResetGeneration||0),closing:!!(globalThis.__codexWindowSession&&globalThis.__codexWindowSession.status().closing)}),current:()=>__current(),softStop:__reason=>globalThis.__codexSoftStop(__reason),subscriptions:yC&&yC.subscriptions,onEvent:__event=>{try{let __session=globalThis.__codexNextSessionRef;if(__session&&__session.record){let __copy={...__event};delete __copy.content;__session.record("edit-proposal",{proposalType:__event.type,...__copy})}}catch{}}});globalThis.__codexEditGate=globalThis.__codexAgentApi.gate;';

function once(source, needle, replacement) {
  if (source.split(needle).length !== 2) throw new Error("missing or ambiguous edit gate anchor: " + needle.slice(0, 80));
  return source.replace(needle, replacement);
}
function stripLegacy(source) {
  if (!source.includes(LEGACY_MARKER)) return source;
  // F0/F2 inserted their own initializers after E1's marker. Preserve them.
  const start = source.indexOf('globalThis.__codexEditGate=globalThis.__codexEditGate||require(');
  if (start < 0) return source;
  const end = source.indexOf("let __acquire", start);
  if (end < 0) throw new Error("legacy edit init end missing");
  source = source.slice(0, start) + source.slice(end);
  const route = source.indexOf('if(__req.method==="POST"&&__req.url==="/propose-edit")');
  const run = source.indexOf(RUN, route);
  if (route < 0 || run < 0) throw new Error("legacy edit route end missing");
  return source.slice(0, route) + source.slice(run);
}
function patchBundle(source, options = {}) {
  if (source.includes(MARKER)) {
    if (![INSTALL, ROUTE, GUARD].every(s => source.includes(s))) throw new Error("partial daily edit patch");
  } else {
    source = stripLegacy(source);
    if (!source.includes(LEGACY_MARKER)) source = once(source, INIT, INIT + LEGACY_MARKER);
    source = once(source, INIT, INIT + INSTALL);
    source = once(source, RUN, ROUTE + RUN);
    source = once(source, PREPARE, GUARD + PREPARE);
  }
  return options.finalize === false ? source : fingerprint.finalize(source).text;
}
function revertBundle(source) {
  if (!source.includes(MARKER) && source.includes(LEGACY_MARKER)) return fingerprint.finalize(stripLegacy(source).replace(LEGACY_MARKER, "")).text;
  source = once(source, INSTALL, ""); source = once(source, ROUTE, ""); source = once(source, GUARD, "");
  source = once(source, LEGACY_MARKER, "");
  return fingerprint.finalize(source).text;
}
if (require.main === module) {
  const target = path.join(__dirname, "..", "dist", "extension.js");
  const before = fs.readFileSync(target, "utf8"), after = patchBundle(before);
  if (after !== before) fs.writeFileSync(target, after);
  console.log(JSON.stringify({ changed: before !== after, target, installed: false }));
}
module.exports = { patchBundle, revertBundle, MARKER, INSTALL, ROUTE, GUARD };
