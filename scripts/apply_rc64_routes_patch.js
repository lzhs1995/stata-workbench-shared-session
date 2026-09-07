#!/usr/bin/env node
"use strict";

const fs = require("fs");
const path = require("path");

const target = path.join(__dirname, "..", "dist", "extension.js");
let text = fs.readFileSync(target, "utf8");

const visibleBridgeWatchdogBefore = 'let __codexBridgeWatchdog=__run&&globalThis.__codexCreateManualSelectionWatchdog?__codexCreateManualSelectionWatchdog(__run,{source:"visible-bridge",idleAfterMs:5000,pollMs:2000,hardStallAfterMs:600000,hardStallIdleMs:60000,hasDocumentOutput:__codexBridgeHasDocumentOutput}):null;';
const visibleBridgeWatchdogAfter = 'let __codexBridgeWatchdog=__run&&globalThis.__codexCreateManualSelectionWatchdog?__codexCreateManualSelectionWatchdog(__run,{source:"visible-bridge",idleAfterMs:5000,pollMs:2000,hardStallAfterMs:600000,hardStallIdleMs:60000,hasDocumentOutput:__codexBridgeHasDocumentOutput,acceptGraphCompletionMarkerAsDone:false}):null;/* codex patch rc.6.4.1: visible bridge waits for executed completion */';

if (text.includes("codex patch rc.6.4: dedicated verified recovery endpoint")) {
  const noGraphBefore = 'return __codexTerminalResult},__codexFinish=';
  const noGraphAfter = 'if(A?.runId&&!__codexTerminalPrepared&&__codexTerminalResult&&!(__codexTerminalResult.success===!1||__codexTerminalResult.error||__codexTerminalResult.raw?.error))try{let __recoveryRequired=!!(globalThis.__codexRecoveryState&&globalThis.__codexRecoveryState.required);globalThis.__codexGraphMark&&__codexGraphMark({lastRunId:A.runId,readinessState:__recoveryRequired?"stale":"ready",readinessReason:__recoveryRequired?(globalThis.__codexRecoveryState.reason||"recovery smoke required"):"terminal-no-graph-complete",readinessRunId:A.runId,readinessUpdatedAt:new Date().toISOString(),lastBatchSource:"no-graph-fast-path",lastGraphExportMode:"no-graph-fast-path",lastClientError:null})}catch{}/* codex patch rc.6.4: successful no-graph terminal run refreshes readiness runId */return __codexTerminalResult},__codexFinish=';
  const noGraphInjection = noGraphAfter.slice(0, -noGraphBefore.length);
  const duplicatedNoGraph = noGraphInjection + noGraphAfter;
  let repaired = false;
  while (text.includes(duplicatedNoGraph)) {
    text = text.replace(duplicatedNoGraph, noGraphAfter);
    repaired = true;
  }
  if (text.includes(noGraphAfter)) {
    // Already applied once.
  } else if (text.includes(noGraphBefore)) {
    text = text.replace(noGraphBefore, noGraphAfter);
    repaired = true;
  } else {
    throw new Error("rc.6.4 no-graph terminal readiness shape is unknown");
  }
  if (text.includes(visibleBridgeWatchdogBefore)) {
    text = text.replace(visibleBridgeWatchdogBefore, visibleBridgeWatchdogAfter);
    repaired = true;
  } else if (!text.includes(visibleBridgeWatchdogAfter)) {
    throw new Error("rc.6.4 visible bridge watchdog shape is unknown");
  }
  if (repaired) {
    fs.writeFileSync(target, text, "utf8");
    console.log("RC64_ROUTES_REPAIRED", target);
  } else {
    console.log("RC64_ROUTES_ALREADY_APPLIED");
  }
  process.exit(0);
}

function replaceOnce(name, before, after) {
  const first = text.indexOf(before);
  const second = first < 0 ? -1 : text.indexOf(before, first + before.length);
  if (first < 0) throw new Error(`missing rc.6.4 route anchor: ${name}`);
  if (second >= 0) throw new Error(`non-unique rc.6.4 route anchor: ${name}`);
  text = text.slice(0, first) + after + text.slice(first + before.length);
}

replaceOnce(
  "preflight helper",
  'let __busy=o=>__reject(o,{kind:"busy",httpStatus:409,reason:"Stata Workbench is already running a visible command."});let __srv=',
  'let __busy=o=>__reject(o,{kind:"busy",httpStatus:409,reason:"Stata Workbench is already running a visible command."});let __preflight=()=>{let s=globalThis.__codexBridgeState||{},__base=s.busy?"running":"idle",__ready=globalThis.__codexTrueReadyStatus?globalThis.__codexTrueReadyStatus(s,__base):{ready:!s.busy&&!s.postRunBusy,status:__base,reason:null};return __codexControl.acquireDecision({bridge:s,readiness:__ready,recovery:globalThis.__codexRecoveryState,request:{kind:"normal"}})};let __srv='
);

const recoveryRoute = String.raw`if(__req.method==="POST"&&__req.url==="/recovery-smoke"){/* codex patch rc.6.4: dedicated verified recovery endpoint */let __recovery=__codexControl.ensureRecoveryState(globalThis.__codexRecoveryState);if(!__recovery.required){__send(__res,409,{ok:false,error:"recovery smoke is not required",reasonCode:"recovery-not-required",recovery:__codexControl.publicRecovery(__recovery),patch:__patch});return}if((globalThis.__codexBridgeState||{}).busy||(globalThis.__codexBridgeState||{}).postRunBusy){__busy(__res);return}let __payload=JSON.stringify({code:'display as text "'+__recovery.marker+'"',cwd:MD.homedir(),label:"verified recovery smoke",source:"internal-recovery"});let __internal=await new Promise((__resolve,__rejectPromise)=>{let __request=__http.request({host:"127.0.0.1",port:__port,path:"/run-command",method:"POST",headers:{"content-type":"application/json","content-length":Buffer.byteLength(__payload),"x-codex-recovery-token":__recovery.token,"x-codex-recovery-generation":String(__recovery.generation),connection:"close"}},__response=>{let __body="";__response.on("data",__chunk=>__body+=__chunk);__response.on("end",()=>__resolve({statusCode:__response.statusCode||0,body:__body}))});__request.setTimeout(120000,()=>__request.destroy(new Error("recovery smoke internal request timed out")));__request.on("error",__rejectPromise);__request.end(__payload)}).catch(__error=>({statusCode:0,error:__error?.message||String(__error),body:""}));let __internalBody=null;try{__internalBody=JSON.parse(__internal.body||"{}")}catch{__internalBody={ok:false,error:"invalid internal recovery response"}}let __logText="";if(__internalBody.logPath&&JA.existsSync(__internalBody.logPath))try{__logText=JA.readFileSync(__internalBody.logPath,"utf8")}catch{}let __verification=__codexControl.verifyRecoveryAttempt({recovery:globalThis.__codexRecoveryState,runId:__internalBody.runId,transportOk:__internal.statusCode===200&&__internalBody.ok===true,rc:__internalBody.rc,logText:__logText});if(__verification.ok){globalThis.__codexRecoveryState=__codexControl.clearRecovery(globalThis.__codexRecoveryState,{runId:__internalBody.runId});try{globalThis.__codexGraphMark&&__codexGraphMark({readinessState:"ready",readinessReason:"recovery-smoke-verified",readinessRunId:__internalBody.runId,readinessUpdatedAt:new Date().toISOString(),lastClientError:null})}catch{}__send(__res,200,{ok:true,runId:__internalBody.runId,markerVerified:true,rc:__internalBody.rc,recovery:__codexControl.publicRecovery(globalThis.__codexRecoveryState),state:__current(),patch:__patch});return}let __failed=__codexControl.ensureRecoveryState(globalThis.__codexRecoveryState);__failed.lastAttempt={at:new Date().toISOString(),ok:false,runId:__internalBody&&__internalBody.runId||null,markerVerified:__verification.markerVerified,reason:__verification.reason||__internal.error||__internalBody.error||"recovery verification failed"};globalThis.__codexRecoveryState=__failed;try{globalThis.__codexGraphMark&&__codexGraphMark({readinessState:"stale",readinessReason:__failed.reason,readinessRunId:null,readinessUpdatedAt:new Date().toISOString(),lastClientError:__failed.lastAttempt.reason})}catch{}__send(__res,503,{ok:false,error:__failed.lastAttempt.reason,reasonCode:"recovery-smoke-failed",markerVerified:__verification.markerVerified,recovery:__codexControl.publicRecovery(__failed),state:__current(),patch:__patch});return}`;

replaceOnce(
  "dedicated recovery route",
  'if(__req.method==="POST"&&__req.url&&__req.url.startsWith("/debug-terminal-input"))',
  recoveryRoute + 'if(__req.method==="POST"&&__req.url&&__req.url.startsWith("/debug-terminal-input"))'
);

replaceOnce(
  "terminal preflight",
  'if(__req.method==="POST"&&__req.url&&__req.url.startsWith("/debug-terminal-input")){/* codex patch v7.26: terminal input diagnostic endpoint exercises runCommand handler */let __terminalBody="";',
  'if(__req.method==="POST"&&__req.url&&__req.url.startsWith("/debug-terminal-input")){/* codex patch v7.26: terminal input diagnostic endpoint exercises runCommand handler */let __terminalDecision=__preflight();if(!__terminalDecision.ok){__reject(__res,__terminalDecision);return}let __terminalBody="";'
);

replaceOnce(
  "selection requires path and preflight",
  '__selTimeoutSec=parseInt(__selUrl.searchParams.get("timeoutSec")||"180",10)||180;(async()=>{',
  '__selTimeoutSec=parseInt(__selUrl.searchParams.get("timeoutSec")||"180",10)||180;if(!__selFile){__send(__res,400,{ok:false,error:"path query parameter is required",reasonCode:"missing-path",patch:__patch});return}let __selDecision=__preflight();if(!__selDecision.ok){__reject(__res,__selDecision);return}(async()=>{'
);

replaceOnce(
  "selection handler rejection receipt",
  'let __selBefore=__current();await iA.commands.executeCommand("stata-workbench.runSelection");let __selState=',
  'let __selBefore=__current(),__selReceipt=await iA.commands.executeCommand("stata-workbench.runSelection");if(__selReceipt&&__selReceipt.accepted===false){__reject(__res,__selReceipt.decision);return}let __selState='
);

replaceOnce(
  "run file requires path and preflight",
  'let __debugUrl=new URL(__req.url,"http://127.0.0.1"),__debugFile=__debugUrl.searchParams.get("path");(async()=>{',
  'let __debugUrl=new URL(__req.url,"http://127.0.0.1"),__debugFile=__debugUrl.searchParams.get("path");if(!__debugFile){__send(__res,400,{ok:false,error:"path query parameter is required",reasonCode:"missing-path",patch:__patch});return}let __debugDecision=__preflight();if(!__debugDecision.ok){__reject(__res,__debugDecision);return}(async()=>{'
);

replaceOnce(
  "run file handler rejection receipt",
  'if(globalThis.__codexRunFileHandler)await globalThis.__codexRunFileHandler();else await iA.commands.executeCommand("stata-workbench.runFile");globalThis.__codexRunFileOverridePath=null;',
  'let __debugReceipt;if(globalThis.__codexRunFileHandler)__debugReceipt=await globalThis.__codexRunFileHandler();else __debugReceipt=await iA.commands.executeCommand("stata-workbench.runFile");globalThis.__codexRunFileOverridePath=null;if(__debugReceipt&&__debugReceipt.accepted===false){__reject(__res,__debugReceipt.decision);return}'
);

replaceOnce(
  "successful no-graph terminal refreshes readiness",
  'return __codexTerminalResult},__codexFinish=',
  'if(A?.runId&&!__codexTerminalPrepared&&__codexTerminalResult&&!(__codexTerminalResult.success===!1||__codexTerminalResult.error||__codexTerminalResult.raw?.error))try{let __recoveryRequired=!!(globalThis.__codexRecoveryState&&globalThis.__codexRecoveryState.required);globalThis.__codexGraphMark&&__codexGraphMark({lastRunId:A.runId,readinessState:__recoveryRequired?"stale":"ready",readinessReason:__recoveryRequired?(globalThis.__codexRecoveryState.reason||"recovery smoke required"):"terminal-no-graph-complete",readinessRunId:A.runId,readinessUpdatedAt:new Date().toISOString(),lastBatchSource:"no-graph-fast-path",lastGraphExportMode:"no-graph-fast-path",lastClientError:null})}catch{}/* codex patch rc.6.4: successful no-graph terminal run refreshes readiness runId */return __codexTerminalResult},__codexFinish='
);

replaceOnce(
  "visible bridge waits for executed completion",
  visibleBridgeWatchdogBefore,
  visibleBridgeWatchdogAfter
);

fs.writeFileSync(target, text, "utf8");
console.log("RC64_ROUTES_APPLIED", target);
