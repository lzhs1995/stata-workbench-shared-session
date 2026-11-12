#!/usr/bin/env node
"use strict";

const fs = require("node:fs");
const path = require("node:path");
const fingerprint = require("./finalize_bundle_identity");
const multi = require("./apply_next_multi_session_patch");
const MARKER = "/* Workbench 0.2: ordinary-window session runtime */";
const req = 'require(rg.join(g.extensionUri.fsPath,"scripts","window_session_vscode.js"))';
const activate = 'function HHg(g){yC=g;';
const setup = 'fRA={...fRA,...require(rg.join(g.extensionUri.fsPath,"package.json"))};globalThis.__codexWindowSession='+req+'.install(g,iA,zg);globalThis.__codexWindowTempDir=globalThis.__codexWindowSession.dirs.tmp;';
const newMulti = 'try{let __nextMultiCore=require(rg.join(g.extensionUri.fsPath,"scripts","next_multi_session_core.js")),'
  +'__wm=globalThis.__codexWindowSession,__nextMulti={...__wm.registryFields(),sessionName:__wm.sessionName,refreshes:0,lastError:null};'
  +'globalThis.__codexNextMultiCoreRef=__nextMultiCore;globalThis.__codexNextMultiRef=__nextMulti;'
  +'globalThis.__codexNextRegistryRefresh=()=>{let __a=globalThis.__codexNextAuthRef;if(!__a)return;'
  +'Object.assign(__nextMulti,__wm.registryFields());let __bi=globalThis.__codexBundleIdentityStatus?globalThis.__codexBundleIdentityStatus():{};'
  +'let __u=__a.update(__nextMultiCore.registryFields({...__nextMulti,generation:Number(globalThis.__codexResetGeneration||0),'
  +'backendPid:__nextMultiCore.latestBackendPid(globalThis.__codexOwnedBackendPids,__p=>{try{process.kill(__p,0);return true}catch(__e){return __e&&__e.code==="ESRCH"?false:true}}),diskBundleSha256:__bi.diskBundleSha256||null}));'
  +'if(__u.changed)__nextMulti.refreshes++;if(__u.error&&__u.error!=="not published")__nextMulti.lastError=__u.error};'
  +'}catch(__nextMultiError){throw __nextMultiError}'+multi.MARKER;

function edits(source) {
  const portStart = source.indexOf('__port=(function(){try{const __p=parseInt(iA.workspace.getConfiguration("stataMcp").get("visibleBridgePort",17601),10);');
  const portEnd = source.indexOf('})(),__patch=', portStart);
  const eagerStart = source.indexOf('JI=UF();let C=uM();');
  const eagerEnd = source.indexOf('if(HF(Io?"missing":"idle"),', eagerStart);
  if (portStart < 0 || portEnd < 0 || eagerStart < 0 || eagerEnd < 0) throw new Error("missing window startup anchors");
  return [
    [activate, activate+setup],
    ['__nextCore.createSession({env:process.env})', '__nextCore.createSession({stateRoot:globalThis.__codexWindowSession.stateRoot,sessionId:globalThis.__codexWindowSession.sessionId})'],
    [multi.ACTIVATE, newMulti],
    [source.slice(portStart, portEnd+4), '__port=globalThis.__codexWindowSession.requestedPort'],
    ['onBound:__state=>{try{globalThis.__codexBridgePort=__port;}', 'onBound:__state=>{__port=__state.port;try{globalThis.__codexBridgePort=__port;}'],
    [source.slice(eagerStart,eagerEnd), 'JI=UF();Io=!1;'],
    ['A.get("loadStataOnStartup",!0)&&!Io&&zg.connect()', 'A.get("loadStataOnStartup",!1)&&!Io&&zg.connect()'],
    ['function FF(g){', 'function FF(g){if(globalThis.__codexWindowSession)return;'],
    ['return{ok:true,bridge:"stata-workbench-visible",patch:__patch,', 'return{ok:true,bridge:"stata-workbench-visible",patch:__patch,windowSession:globalThis.__codexWindowSession.status(),'],
    ['A.push(kDA.tmpdir())', 'A.push(globalThis.__codexWindowTempDir||kDA.tmpdir())'],
    ['__path.join(__os.tmpdir(),"codex_prerun_agent_state_', '__path.join(globalThis.__codexWindowTempDir,"codex_prerun_agent_state_'],
    ['__path.join(__os.tmpdir(),"codex_prerun_state_', '__path.join(globalThis.__codexWindowTempDir,"codex_prerun_state_'],
    ['rg.join(require("os").tmpdir(),"mcp_sel_', 'rg.join(globalThis.__codexWindowTempDir,"mcp_sel_'],
    ['__codexPath.join(__codexOs.tmpdir(),"codex-human-file-")', '__codexPath.join(globalThis.__codexWindowTempDir,"codex-human-file-")'],
    ['rg.join(require("os").tmpdir(),"codex_humanfile_state_', 'rg.join(globalThis.__codexWindowTempDir,"codex_humanfile_state_'],
  ];
}

function patchBundle(source, options = {}) {
  if (source.includes(MARKER)) return source;
  const pairs = edits(source);
  for (const [before, after] of pairs) {
    if (source.split(before).length !== 2) throw new Error("missing or ambiguous ordinary-window anchor: "+before.slice(0,90));
    source = source.replace(before, () => after);
  }
  // Preserve exact inverse material privately in the patch marker, not runtime state.
  source += '\n'+MARKER+'\n/* window-session-originals:'+Buffer.from(JSON.stringify(pairs)).toString("base64")+' */\n';
  return options.finalize === false ? source : fingerprint.finalize(source).text;
}

function revertBundle(source) {
  const match = /\n\/\* Workbench 0\.2: ordinary-window session runtime \*\/\n\/\* window-session-originals:([A-Za-z0-9+/=]+) \*\/\n/.exec(source);
  if (!match) throw new Error("missing window patch inverse");
  for (const [before, after] of JSON.parse(Buffer.from(match[1],"base64").toString("utf8")).reverse()) {
    if (source.split(after).length !== 2) throw new Error("window patch inverse anchor changed");
    source = source.replace(after, () => before);
  }
  return fingerprint.finalize(source.replace(match[0], "")).text;
}

if (require.main === module) {
  const file = path.join(__dirname,"..","dist","extension.js");
  fs.writeFileSync(file, patchBundle(fs.readFileSync(file,"utf8")));
}
module.exports = { MARKER, patchBundle, revertBundle };
