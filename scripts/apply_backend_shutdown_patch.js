#!/usr/bin/env node
"use strict";

const fs = require("node:fs");
const path = require("node:path");
const fingerprint = require("./finalize_bundle_identity");
const MARKER = "/* Workbench 0.2: fenced backend terminal shutdown */";
const CORE = 'require("../scripts/backend_shutdown_runtime").lifecycle(this)';
const ENSURE = `async _ensureClient(){return ${CORE}.ensureClient(async __scope=>{let __env=MM();if(!__scope._pypiVersion&&!__env.MCP_STATA_PACKAGE_SPEC)try{let __versions=await __scope._fetchLatestVersion();__scope._pypiVersion=__versions.latest}catch(__error){if(!${CORE}.status().closing)__scope._log("[mcp-stata] version lookup unavailable")}})}`;
const DISPOSE = `async dispose(){return ${CORE}.dispose()}__codexLifecycle(){return ${CORE}}`;
const DEACTIVATE = 'async function bHg(){let __l=zg.__codexLifecycle();globalThis.__codexShutdownResult=await __l.shutdown();try{await GB.flush(2e3)}catch{}}';
const CLOSE_ENDPOINT = 'if(__req.method==="POST"&&String(__req.url||"").startsWith("/session-close?")){let __q=new URL(__req.url,"http://127.0.0.1").searchParams,__s=__current();if(__q.get("sessionId")!==__s.nextSession?.sessionId||__q.get("hostPid")!==String(process.pid)||__q.get("generation")!==String(__s.resetGeneration)||__q.get("bundle")!==__s.diskBundleSha256){__send(__res,409,{ok:false,error:"SESSION_IDENTITY_MISMATCH"});return}if(globalThis.__codexWindowCloseRequested){__send(__res,409,{ok:false,error:"CLOSE_ALREADY_REQUESTED_NO_REPLAY"});return}globalThis.__codexWindowCloseRequested=true;let __closed=await zg.__codexLifecycle().shutdown();__send(__res,200,{ok:__closed.backendCleanup==="complete",sessionId:__s.nextSession.sessionId,extensionHostPid:process.pid,backendCleanup:__closed.backendCleanup,shutdown:__closed,windowCloseRequested:true});setTimeout(()=>{Promise.resolve(iA.commands.executeCommand("workbench.action.closeWindow")).catch(()=>{})},0);return}';

function unique(source, text) {
  if (!text || source.split(text).length !== 2) throw new Error("missing or ambiguous shutdown anchor: " + text.slice(0,90));
}
function span(source, start, end) {
  unique(source,start); unique(source,end);
  const a = source.indexOf(start), b = source.indexOf(end,a+start.length);
  if (b<a) throw new Error("shutdown method boundary changed");
  return source.slice(a,b);
}
function pairs(source) {
  const dispose = span(source,'async dispose(){let __transport=this._transport;', 'async cancelAll(){');
  const ensure = span(source,'async _ensureClient(){return this._clientPromise?', 'async _fetchLatestVersion(A=2e3){');
  const deactivate = span(source,'async function bHg(){', 'function HF(g){');
  // The lifecycle adapter now owns Darwin capture/close/reap. Keeping the old
  // parallel reaper and bare-PID shell fallback would bypass its identity fence.
  const resetCapture = span(source, '/* codex patch rc.7.89: force reset ends this session\'s orphaned Stata worker */', 'try{RI("[Codex bridge] force reset requested:');
  const resetReap = span(source, '/* codex patch rc.7.89: end recorded orphan workers after dispose */', 'let __cleanup=null;');
  const resetMac = span(source, 'else if(process.platform==="darwin"){if(__owned.length){let __script=', 'else __cleanup={ok:null,mode:"owned-pids"');
  return [
    [dispose,DISPOSE], [ensure,ENSURE], [deactivate,DEACTIVATE],
    [resetCapture, '/* shutdown adapter owns reset capture */globalThis.__codexOrphanCaptureP=null;'],
    [resetReap, '/* codex patch rc.7.89: lifecycle adapter owns recorded orphan workers */__shutdownResetCheck();'],
    [resetMac, 'else if(process.platform==="darwin"){let __ls=zg.__codexLifecycle().status(),__rows=__ls.transports,__complete=__ls.pendingAttempts===0&&__rows.every(__r=>__r.cleanup&&__r.cleanup.backendCleanup==="complete");__cleanup={ok:__complete,mode:"verified-lifecycle",pids:__owned,processes:__rows};let __workers=__rows.flatMap(__r=>__r.cleanup&&__r.cleanup.orphanWorkers||[]);globalThis.__codexOrphanReap={at:new Date().toISOString(),generation:__codexThisResetGeneration,orphanWorkers:__workers,clean:__complete,unresolved:__complete?0:Math.max(1,__workers.filter(__w=>__w.unresolved).length)}}'],
    ['async _enqueue(A,I={},Q,B={},C=!1,E=!1){', 'async _enqueue(A,I={},Q,B={},C=!1,E=!1){let __shutdownLife=this.__codexLifecycle(),__shutdownToken=__shutdownLife.token();'],
    ['let H=Date.now();if(r.token.isCancellationRequested)', 'let H=Date.now();__shutdownLife.assert(__shutdownToken);if(r.token.isCancellationRequested)'],
    ['let m=await this._ensureClient(),L=await this._withTimeout(Q(m),t,A,r.token),f=Date.now()', 'let m=await this._ensureClient();__shutdownLife.assert(__shutdownToken);let L=await this._withTimeout(Q(m),t,A,r.token);__shutdownLife.assert(__shutdownToken);let f=Date.now()'],
    ['}}let m=await this._ensureClient();__shutdownLife.assert', '}}__shutdownLife.assert(__shutdownToken);let m=await this._ensureClient();__shutdownLife.assert'],
    ['return HA}catch(m){let L=Date.now()-H;', ' __shutdownLife.assert(__shutdownToken);return HA}catch(m){__shutdownLife.assert(__shutdownToken);let L=Date.now()-H;'],
    ['finally{this._active=!1,this._activeCancellation=null,G&&G.dispose(),this._pending=Math.max(0,this._pending-1),this._cancellationSourcesByRunId.delete(String(n)),this._pending===0?this._statusEmitter.emit("status","connected"):this._statusEmitter.emit("status","queued")}',
      'finally{G&&G.dispose();if(__shutdownLife.current(__shutdownToken)){if(this._activeCancellation===r){this._active=!1;this._activeCancellation=null}this._pending=Math.max(0,this._pending-1);if(this._cancellationSourcesByRunId.get(String(n))===r)this._cancellationSourcesByRunId.delete(String(n));this._statusEmitter.emit("status",this._pending===0?"connected":"queued")}}'],
    ['async _callTool(A,I,Q,B={}){', 'async _callTool(A,I,Q,B={}){let __toolLife=this.__codexLifecycle(),__toolToken=__toolLife.token();'],
    ['let s;if(o.type==="cursor-bridge"', '__toolLife.assert(__toolToken);let s;if(o.type==="cursor-bridge"'],
    ['}let n=Date.now()-t;return this._log(`[mcp-stata] tool ${I} completed', '}__toolLife.assert(__toolToken);let n=Date.now()-t;return this._log(`[mcp-stata] tool ${I} completed'],
    ['s}catch(o){let s=Date.now()-t;if(this._isCancellationError(o))', 's}catch(o){__toolLife.assert(__toolToken);let s=Date.now()-t;if(this._isCancellationError(o))'],
    ['async _ensureLatestServerForMissingTool(A){', 'async _ensureLatestServerForMissingTool(A){let __missingLife=this.__codexLifecycle(),__missingToken=__missingLife.token();'],
    ['catch{}this._resetClientState()}}_formatMissingToolError', 'catch{}__missingLife.assert(__missingToken);this._resetClientState()}}_formatMissingToolError'],
    ['async _withActiveRun(A,I){let Q=this._activeRun;', 'async _withActiveRun(A,I){let __runLife=this.__codexLifecycle(),__runToken=__runLife.token();let Q=this._activeRun;'],
    ['finally{this._activeRun=Q,A?.taskId&&this._scheduleRunCleanup', 'finally{if(__runLife.current(__runToken)){this._activeRun=Q,A?.taskId&&this._scheduleRunCleanup'],
    ['this._orphanOpen(A._runId)}}}_appendBounded', 'this._orphanOpen(A._runId)}}}}_appendBounded'],
    ['globalThis.__codexForceReset=async o=>{', 'globalThis.__codexForceReset=async o=>{zg.__codexLifecycle().token();'],
    ['let __codexThisResetGeneration=globalThis.__codexResetGeneration;', 'let __codexThisResetGeneration=globalThis.__codexResetGeneration;let __shutdownResetCheck=()=>{zg.__codexLifecycle().token();if(globalThis.__codexResetGeneration!==__codexThisResetGeneration)throw new Error("RESET_SUPERSEDED")};'],
    ['let __codexFrReconnectMs=', '__shutdownResetCheck();let __codexFrReconnectMs='],
    ['let __codexDispose={attempted:true,settled:false,ok:false,error:null};', '__shutdownResetCheck();let __codexDispose={attempted:true,settled:false,ok:false,error:null};'],
    ['try{HF("connected")}catch{}/* codex patch rc.7.89:', '__shutdownResetCheck();try{HF("connected")}catch{}/* codex patch rc.7.89:'],
    ['let __cleanup=null;try{let cp=require("child_process")', '__shutdownResetCheck();let __cleanup=null;try{let cp=require("child_process")'],
    ['__reconnect.timeoutMs=__codexFrReconnectMs;', '__shutdownResetCheck();__reconnect.timeoutMs=__codexFrReconnectMs;'],
    ['globalThis.__codexRunRecoverySmoke=async(__why)=>{', 'globalThis.__codexRunRecoverySmoke=async(__why)=>{let __shutdownLife=zg.__codexLifecycle(),__shutdownToken=__shutdownLife.token(),__removeAbort=()=>{};'],
    ['__req.setTimeout(180000,()=>__req.destroy(new Error("recovery smoke request timed out")));', '__removeAbort=__shutdownLife.onClose(()=>__req.destroy(new Error("SESSION_CLOSING")));__req.setTimeout(180000,()=>__req.destroy(new Error("recovery smoke request timed out")));'],
    ['__req.end()});let __parsed=null;', '__req.end()});__removeAbort();__shutdownLife.assert(__shutdownToken);let __parsed=null;'],
    ['if(__req.method==="GET"&&__req.url==="/status"){/* codex patch v4: status endpoint */__send(__res,200,__current());return}',
      'if(__req.method==="GET"&&__req.url==="/status"){/* codex patch v4: status endpoint */let __status=__current(),__ls=zg.__codexLifecycle().status();__status.backendLifecycle=__ls;if(__ls.closing){__status.trueReady=false;__status.status="closing"}__send(__res,200,__status);return}'+CLOSE_ENDPOINT+'if(zg.__codexLifecycle().status().closing){__send(__res,409,{ok:false,error:"SESSION_CLOSING"});return}'],
  ];
}

function patchBundle(source, options = {}) {
  if (source.includes(MARKER)) {
    const m = /\/\* backend-shutdown-originals:([A-Za-z0-9+/=]+) \*\//.exec(source);
    if (!m) throw new Error("partial shutdown patch");
    for (const [,after] of JSON.parse(Buffer.from(m[1],"base64").toString())) unique(source,after);
    return options.finalize === false ? source : fingerprint.finalize(source).text;
  }
  if (source.includes("backend_shutdown_runtime")) throw new Error("partial shutdown patch");
  const edits = pairs(source);
  for (const [before,after] of edits) { unique(source,before); source=source.replace(before,()=>after); }
  source+='\n'+MARKER+'\n/* backend-shutdown-originals:'+Buffer.from(JSON.stringify(edits)).toString("base64")+' */\n';
  return options.finalize === false ? source : fingerprint.finalize(source).text;
}
function revertBundle(source, options = {}) {
  const m=/\n\/\* Workbench 0\.2: fenced backend terminal shutdown \*\/\n\/\* backend-shutdown-originals:([A-Za-z0-9+/=]+) \*\/\n/.exec(source);
  if (!m) throw new Error("missing shutdown inverse");
  for (const [before,after] of JSON.parse(Buffer.from(m[1],"base64").toString()).reverse()) {unique(source,after);source=source.replace(after,()=>before);}
  source=source.replace(m[0],"");
  return options.finalize === false ? source : fingerprint.finalize(source).text;
}
if (require.main===module) {
  const file=path.join(__dirname,"..","dist","extension.js");
  fs.writeFileSync(file,patchBundle(fs.readFileSync(file,"utf8")));
}
module.exports={MARKER,ENSURE,DISPOSE,DEACTIVATE,CLOSE_ENDPOINT,patchBundle,revertBundle};
