#!/usr/bin/env node
"use strict";

const fs = require("fs");
const path = require("path");

const target = path.join(__dirname, "..", "dist", "extension.js");
let text = fs.readFileSync(target, "utf8");

if (text.includes("codex patch rc.6.4: unified recovery control plane")) {
  const graphClearBefore = 'if(__req.method==="POST"&&__req.url==="/graph-clear"){/* codex patch v7.2: graph clear endpoint */let __graphPanel=globalThis.__codexClearGraphPanel?globalThis.__codexClearGraphPanel("http /graph-clear"):null;try{let __bridge=globalThis.__codexBridgeState||{};__bridge.postRunBusy=false;__bridge.lastPostRunBusyReason=null;__bridge.lastPostRunBusyRunId=null;__bridge.lastPostRunBusyAt=new Date().toISOString()}catch{}__send(__res,200,{ok:true,patch:__patch,graphPanel:__graphPanel,recovery:__codexControl.publicRecovery(globalThis.__codexRecoveryState)});return}';
  const graphClearAfter = 'if(__req.method==="POST"&&__req.url==="/graph-clear"){/* codex patch v7.2: graph clear endpoint *//* codex patch rc.6.4: graph clear is UI-only */let __graphPanel=globalThis.__codexClearGraphPanel?globalThis.__codexClearGraphPanel("http /graph-clear"):null;__send(__res,200,{ok:true,patch:__patch,graphPanel:__graphPanel,recovery:__codexControl.publicRecovery(globalThis.__codexRecoveryState)});return}';
  let repaired = false;
  if (text.includes(graphClearBefore)) {
    text = text.replace(graphClearBefore, graphClearAfter);
    repaired = true;
  } else if (!text.includes(graphClearAfter)) {
    throw new Error("rc.6.4 graph-clear shape is neither the known pre-repair nor UI-only form");
  }
  const clearHelperBefore = '    lastCompletionMarker: null,\n    readinessState: (globalThis.__codexBridgeState?.busy || globalThis.__codexBridgeState?.postRunBusy) ? (globalThis.__codexGraphPanelDiag?.readinessState || "draining") : "ready",\n    readinessReason: (globalThis.__codexBridgeState?.busy || globalThis.__codexBridgeState?.postRunBusy) ? (globalThis.__codexGraphPanelDiag?.readinessReason || "clear during active run") : String(reason || "graph-clear") + "-complete",\n    readinessRunId: (globalThis.__codexBridgeState?.busy || globalThis.__codexBridgeState?.postRunBusy) ? (globalThis.__codexGraphPanelDiag?.readinessRunId || null) : null,\n    readinessUpdatedAt: new Date().toISOString()';
  const clearHelperAfter = '    lastCompletionMarker: null\n    /* codex patch rc.6.4: graph panel clear preserves execution readiness */';
  if (text.includes(clearHelperBefore)) {
    text = text.replace(clearHelperBefore, clearHelperAfter);
    repaired = true;
  } else if (!text.includes(clearHelperAfter)) {
    throw new Error("rc.6.4 graph panel clear helper still has an unknown readiness shape");
  }
  const hydrateBefore = '    const state = globalThis.__codexGraphPanelDiag || {};\n    if (state.readinessState !== "draining") return;';
  const hydrateAfter = '    const state = globalThis.__codexGraphPanelDiag || {};\n    if (state.lastBatchSource === "clear") return;\n    /* codex patch rc.6.4: clear snapshot hydration cannot release readiness */\n    if (state.readinessState !== "draining") return;';
  if (text.includes(hydrateBefore)) {
    text = text.replace(hydrateBefore, hydrateAfter);
    repaired = true;
  } else if (!text.includes(hydrateAfter)) {
    throw new Error("rc.6.4 graph hydrate helper has an unknown clear-snapshot shape");
  }
  if (repaired) {
    fs.writeFileSync(target, text, "utf8");
    console.log("RC64_PATCH_REPAIRED_GRAPH_CLEAR", target);
  } else {
    console.log("RC64_PATCH_ALREADY_APPLIED");
  }
  process.exit(0);
}

function replaceOnce(name, before, after) {
  const first = text.indexOf(before);
  const second = first < 0 ? -1 : text.indexOf(before, first + before.length);
  if (first < 0) throw new Error(`missing rc.6.4 anchor: ${name}`);
  if (second >= 0) throw new Error(`non-unique rc.6.4 anchor: ${name}`);
  text = text.slice(0, first) + after + text.slice(first + before.length);
}

replaceOnce(
  "load shared control-plane core",
  'try{let __http=require("http"),__port=',
  'try{let __http=require("http"),__codexControl=require(rg.join(((yC&&yC.extensionUri&&yC.extensionUri.fsPath)||process.cwd()),"scripts","control_plane_core.js")),__port='
);

replaceOnce(
  "bridge patch id",
  '__patch="codex-display-only-clear-v6-cleanup-v9-postrun-busy",__staleAfter=21600000;',
  '__patch="codex-rc64-control-plane",__staleAfter=21600000;/* codex patch rc.6.4: unified recovery control plane */'
);

replaceOnce(
  "initialize recovery and ownership state",
  'globalThis.__codexBridgeState=globalThis.__codexBridgeState||{busy:false,runId:null,label:null,source:null,startedAt:null,lastHeartbeatAt:null,codePreview:null,logPath:null,rc:null,postRunBusy:false};/* codex patch v4: single-flight state */',
  'globalThis.__codexBridgeState=globalThis.__codexBridgeState||{busy:false,runId:null,label:null,source:null,startedAt:null,lastHeartbeatAt:null,codePreview:null,logPath:null,rc:null,postRunBusy:false};globalThis.__codexControlPlane=__codexControl;globalThis.__codexRecoveryState=__codexControl.ensureRecoveryState(globalThis.__codexRecoveryState);globalThis.__codexOwnedBackendPids=globalThis.__codexOwnedBackendPids instanceof Map?globalThis.__codexOwnedBackendPids:new Map;globalThis.__codexBackendOwnerId=globalThis.__codexBackendOwnerId||(String(process.pid)+"-"+String(__port)+"-"+Math.random().toString(36).slice(2));/* codex patch v4: single-flight state */'
);

replaceOnce(
  "status recovery payload",
  'continuityRunId:globalThis.__codexContinuityRunId||null,extensionVersion:',
  'continuityRunId:globalThis.__codexContinuityRunId||null,recovery:__codexControl.publicRecovery(globalThis.__codexRecoveryState),backendOwnerId:globalThis.__codexBackendOwnerId||null,ownedBackendPids:Array.from((globalThis.__codexOwnedBackendPids||new Map).keys()),extensionVersion:'
);

replaceOnce(
  "structured acquire decision",
  'let __acquire=o=>{let s=globalThis.__codexBridgeState;let __codexAcquireStatus=s.busy&&s.startedAt&&Date.now()-s.startedAt>__staleAfter?"stale":s.busy?"running":"idle";let __codexAcquireReady=globalThis.__codexTrueReadyStatus?__codexTrueReadyStatus(s,__codexAcquireStatus):{ready:!s.busy&&!s.postRunBusy,reason:null,status:__codexAcquireStatus};let __codexAllowRecoverySmoke=!!(o&&o.allowRecoverySmoke&&!s.busy&&!s.postRunBusy&&!__codexAcquireReady.ready&&/force-reset-needs-smoke/i.test(String(__codexAcquireReady.reason||"")));if(s.busy||s.postRunBusy||(!__codexAcquireReady.ready&&!__codexAllowRecoverySmoke))return false;/* codex patch v7.16: bridge acquire checks true READY *//* codex patch v7.24n: bridge acquire permits recovery smoke after panic */return Object.assign(s,{busy:true,runId:o.runId,label:o.label,source:o.source,startedAt:Date.now(),lastHeartbeatAt:Date.now(),codePreview:o.codePreview,logPath:null,rc:null}),true};',
  'let __acquire=o=>{let s=globalThis.__codexBridgeState;let __codexAcquireStatus=s.busy&&s.startedAt&&Date.now()-s.startedAt>__staleAfter?"stale":s.busy?"running":"idle";let __codexAcquireReady=globalThis.__codexTrueReadyStatus?__codexTrueReadyStatus(s,__codexAcquireStatus):{ready:!s.busy&&!s.postRunBusy,reason:null,status:__codexAcquireStatus};let __codexDecision=__codexControl.acquireDecision({bridge:s,readiness:__codexAcquireReady,recovery:globalThis.__codexRecoveryState,request:{kind:o&&o.kind||"normal",recoveryToken:o&&o.recoveryToken,recoveryGeneration:o&&o.recoveryGeneration}});globalThis.__codexLastAcquireDecision={...__codexDecision,at:new Date().toISOString(),runId:o&&o.runId||null};if(!__codexDecision.ok)return false;if(__codexDecision.kind==="recovery-smoke"){let __recovery=__codexControl.ensureRecoveryState(globalThis.__codexRecoveryState);__recovery.activeRunId=o.runId;__recovery.lastAttempt={at:new Date().toISOString(),ok:null,runId:o.runId,markerVerified:false};globalThis.__codexRecoveryState=__recovery}/* codex patch v7.16: bridge acquire checks true READY *//* codex patch rc.6.4: only current internal recovery generation may bypass stale */return Object.assign(s,{busy:true,runId:o.runId,label:o.label,source:o.source,startedAt:Date.now(),lastHeartbeatAt:Date.now(),codePreview:o.codePreview,logPath:null,rc:null}),true};'
);

replaceOnce(
  "structured HTTP rejection",
  'let __busy=o=>{let s=__current();RI("[Codex bridge] rejected busy request: "+(s.current?.label||"unknown"));/* codex patch v4: busy 409 */__send(o,409,{ok:false,busy:true,status:s.status,error:"Stata Workbench is already running a visible command.",current:s.current,patch:__patch})};',
  'let __reject=(o,d)=>{let s=__current(),__decision=d||globalThis.__codexLastAcquireDecision||{kind:"busy",httpStatus:409,reason:"bridge busy"},__status=Number(__decision.httpStatus)||409;RI("[Codex bridge] rejected request: "+String(__decision.kind||"unknown")+" "+String(__decision.reason||""));__send(o,__status,{ok:false,busy:__decision.kind==="busy",status:s.status,error:__decision.reason||"Stata Workbench request rejected.",reasonCode:__decision.kind||"rejected",current:s.current,recovery:s.recovery,patch:__patch})};let __busy=o=>__reject(o,{kind:"busy",httpStatus:409,reason:"Stata Workbench is already running a visible command."});'
);

replaceOnce(
  "capture existing recovery requirement",
  'globalThis.__codexForceReset=async o=>{let s=globalThis.__codexBridgeState||{};let __codexHadContinuityLost=false;',
  'globalThis.__codexForceReset=async o=>{let s=globalThis.__codexBridgeState||{};let __codexRecoveryWasRequired=!!__codexControl.ensureRecoveryState(globalThis.__codexRecoveryState).required;let __codexHadContinuityLost=false;'
);

replaceOnce(
  "guard Windows panic escalation",
  'if(__codexForceResetWasBusy&&!/panic-kill/i.test(String(o||"")))try{',
  'if(process.platform==="win32"&&__codexForceResetWasBusy&&!/panic-kill/i.test(String(o||"")))try{'
);

replaceOnce(
  "record non-Windows panic skip",
  '}/* codex patch v7.24l: running force-reset escalates to panic-kill before READY */try{s.busy=false,',
  '}if(process.platform!=="win32")s.lastForceResetPanic={ok:null,platform:process.platform,skipped:"owned-client-reset-only"};/* codex patch v7.24l: running force-reset escalates to panic-kill before READY */try{s.busy=false,'
);

replaceOnce(
  "platform-owned backend cleanup",
  'let __cleanup=null;try{let cp=require("child_process"),__script=rg.join(((yC&&yC.extensionUri&&yC.extensionUri.fsPath)||process.cwd()),"scripts","cleanup_mcp_stata_processes.ps1");let __out=cp.execFileSync("powershell.exe",["-NoProfile","-ExecutionPolicy","Bypass","-File",__script,"-Force"],{encoding:"utf8",timeout:15000,windowsHide:true});try{__cleanup=JSON.parse(__out)}catch{__cleanup={ok:true,raw:__out}}}catch(e){__cleanup={ok:false,error:e?.message||String(e)}}/* codex patch v6: cleanup orphan mcp-stata processes */',
  'let __cleanup=null;try{let cp=require("child_process"),__owned=Array.from((globalThis.__codexOwnedBackendPids||new Map).keys()).filter(__pid=>Number.isInteger(Number(__pid))&&Number(__pid)>1);if(process.platform==="win32"){let __script=rg.join(((yC&&yC.extensionUri&&yC.extensionUri.fsPath)||process.cwd()),"scripts","cleanup_mcp_stata_processes.ps1"),__args=["-NoProfile","-ExecutionPolicy","Bypass","-File",__script,"-Force","-OwnedPidCsv",__owned.join(",")],__out=cp.execFileSync("powershell.exe",__args,{encoding:"utf8",timeout:15000,windowsHide:true});try{__cleanup=JSON.parse(__out)}catch{__cleanup={ok:true,mode:"owned-pids",pids:__owned,raw:__out}}}else if(process.platform==="darwin"){if(__owned.length){let __script=rg.join(((yC&&yC.extensionUri&&yC.extensionUri.fsPath)||process.cwd()),"scripts","mac","cleanup.sh"),__args=[__script,"--force"];for(let __pid of __owned)__args.push("--pid",String(__pid));let __out=cp.execFileSync("/bin/bash",__args,{encoding:"utf8",timeout:15000});__cleanup={ok:true,mode:"owned-pids",pids:__owned,raw:__out}}else __cleanup={ok:true,mode:"owned-pids",pids:[],skipped:"no-owned-backend-pids"}}else __cleanup={ok:null,mode:"owned-pids",pids:__owned,skipped:"unsupported-platform"};if(__cleanup&&__cleanup.ok===true)for(let __pid of __owned)(globalThis.__codexOwnedBackendPids||new Map).delete(__pid)}catch(e){__cleanup={ok:false,mode:"owned-pids",error:e?.message||String(e)}}/* codex patch rc.6.4: cleanup only backend PIDs owned by this extension host */'
);

replaceOnce(
  "recovery state on force reset",
  'let __needsSmoke=!!(typeof __codexHadContinuityLost!=="undefined"&&__codexHadContinuityLost)||/pre-log|hard-stall|panic-kill|error transport reset|continuity/i.test(String(o||""));let __smokeReason=__needsSmoke?(!!(typeof __codexHadContinuityLost!=="undefined"&&__codexHadContinuityLost)?"force-reset-needs-smoke: continuity-lost":("force-reset-needs-smoke: "+(o||"unknown"))):"force-reset-complete";globalThis.__codexGraphMark&&__codexGraphMark({readinessState:__needsSmoke?"stale":"ready",',
  'let __needsSmoke=__codexRecoveryWasRequired||!!(typeof __codexHadContinuityLost!=="undefined"&&__codexHadContinuityLost)||/pre-log|hard-stall|panic-kill|error transport reset|continuity/i.test(String(o||""));let __smokeReason=__needsSmoke?(!!(typeof __codexHadContinuityLost!=="undefined"&&__codexHadContinuityLost)?"force-reset-needs-smoke: continuity-lost":("force-reset-needs-smoke: "+(o||"unknown"))):"force-reset-complete";if(__needsSmoke)globalThis.__codexRecoveryState=__codexControl.requestRecovery(globalThis.__codexRecoveryState,__smokeReason);globalThis.__codexGraphMark&&__codexGraphMark({readinessState:__needsSmoke?"stale":"ready",'
);

replaceOnce(
  "graph clear cannot change readiness",
  'if(__req.method==="POST"&&__req.url==="/graph-clear"){/* codex patch v7.2: graph clear endpoint */let __graphPanel=globalThis.__codexClearGraphPanel?globalThis.__codexClearGraphPanel("http /graph-clear"):null;try{globalThis.__codexSetPostRunBusy&&globalThis.__codexSetPostRunBusy(false,"graph-clear-complete",null)}catch{}try{globalThis.__codexGraphMark&&(__graphPanel=__codexGraphMark({readinessState:"ready",readinessReason:"graph-clear-complete",readinessRunId:null,readinessUpdatedAt:new Date().toISOString(),lastClientError:null}))}catch{}__send(__res,200,{ok:true,patch:__patch,graphPanel:__graphPanel});return}',
  'if(__req.method==="POST"&&__req.url==="/graph-clear"){/* codex patch v7.2: graph clear endpoint *//* codex patch rc.6.4: graph clear is UI-only */let __graphPanel=globalThis.__codexClearGraphPanel?globalThis.__codexClearGraphPanel("http /graph-clear"):null;__send(__res,200,{ok:true,patch:__patch,graphPanel:__graphPanel,recovery:__codexControl.publicRecovery(globalThis.__codexRecoveryState)});return}'
);

replaceOnce(
  "graph panel clear helper preserves readiness",
  '    lastCompletionMarker: null,\n    readinessState: (globalThis.__codexBridgeState?.busy || globalThis.__codexBridgeState?.postRunBusy) ? (globalThis.__codexGraphPanelDiag?.readinessState || "draining") : "ready",\n    readinessReason: (globalThis.__codexBridgeState?.busy || globalThis.__codexBridgeState?.postRunBusy) ? (globalThis.__codexGraphPanelDiag?.readinessReason || "clear during active run") : String(reason || "graph-clear") + "-complete",\n    readinessRunId: (globalThis.__codexBridgeState?.busy || globalThis.__codexBridgeState?.postRunBusy) ? (globalThis.__codexGraphPanelDiag?.readinessRunId || null) : null,\n    readinessUpdatedAt: new Date().toISOString()',
  '    lastCompletionMarker: null\n    /* codex patch rc.6.4: graph panel clear preserves execution readiness */'
);

replaceOnce(
  "clear snapshot hydration preserves readiness",
  '    const state = globalThis.__codexGraphPanelDiag || {};\n    if (state.readinessState !== "draining") return;',
  '    const state = globalThis.__codexGraphPanelDiag || {};\n    if (state.lastBatchSource === "clear") return;\n    /* codex patch rc.6.4: clear snapshot hydration cannot release readiness */\n    if (state.readinessState !== "draining") return;'
);

replaceOnce(
  "recovery readiness precedence",
  'if (postRunBusy) return { ready: false, status: "draining", reason: bridge.lastPostRunBusyReason || "post-run cleanup in progress" };try{if(globalThis.__codexContinuityLost)',
  'if (postRunBusy) return { ready: false, status: "draining", reason: bridge.lastPostRunBusyReason || "post-run cleanup in progress" };try{let __recovery=globalThis.__codexControlPlane&&globalThis.__codexControlPlane.ensureRecoveryState(globalThis.__codexRecoveryState);if(__recovery&&__recovery.required)return{ready:false,status:"recovery-required",reason:__recovery.reason||"recovery smoke required"}}catch{}/* codex patch rc.6.4: recovery gate precedes graph readiness */try{if(globalThis.__codexContinuityLost)'
);

replaceOnce(
  "recovery-aware post-run readiness",
  'readinessState: flag ? "draining" : "ready",\n      readinessReason: reason || null,',
  'readinessState: flag ? "draining" : ((globalThis.__codexRecoveryState&&globalThis.__codexRecoveryState.required)?"stale":"ready"),\n      readinessReason: (globalThis.__codexRecoveryState&&globalThis.__codexRecoveryState.required)?globalThis.__codexRecoveryState.reason:(reason || null),'
);

replaceOnce(
  "internal recovery authorization",
  'let __codexAllowRecoverySmoke=/smoke/i.test(__label)&&/^\\s*display\\s+as\\s+text\\s+"[^"]*smoke[^"]*"\\s*$/i.test(__code);if(!__acquire({runId:__runId,label:__label,source:__source,codePreview:__code.slice(0,300),allowRecoverySmoke:__codexAllowRecoverySmoke})){__busy(__res);return}',
  'let __recoveryToken=String(__req.headers["x-codex-recovery-token"]||""),__recoveryGeneration=parseInt(String(__req.headers["x-codex-recovery-generation"]||"0"),10)||0,__recoveryKind=__recoveryToken?"recovery-smoke":"normal";if(!__acquire({runId:__runId,label:__label,source:__source,codePreview:__code.slice(0,300),kind:__recoveryKind,recoveryToken:__recoveryToken,recoveryGeneration:__recoveryGeneration})){__reject(__res,globalThis.__codexLastAcquireDecision);return}'
);

replaceOnce(
  "block terminal during recovery",
  'var kM=async(g,A)=>{let __codexStoppedSession=',
  'var kM=async(g,A)=>{let __codexTerminalRecovery=globalThis.__codexControlPlane&&globalThis.__codexControlPlane.ensureRecoveryState(globalThis.__codexRecoveryState);if(__codexTerminalRecovery&&__codexTerminalRecovery.required&&!A?.__codexRecoveryInternal)return{success:false,rc:-1,controlPlaneRejected:true,httpStatus:423,reasonCode:"recovery-required",stderr:__codexTerminalRecovery.reason||"recovery smoke required",error:{message:__codexTerminalRecovery.reason||"recovery smoke required"}};let __codexStoppedSession='
);

replaceOnce(
  "selection rejection receipt",
  'if(globalThis.__codexVisibleAcquire&&!globalThis.__codexVisibleAcquire({runId:__codexHumanRunId,label:"Running selection",source:"human-selection",codePreview:I.slice(0,300)})){iA.window.showWarningMessage("Stata Workbench is already running a visible command. Wait for it to finish before starting another.");return}',
  'if(globalThis.__codexVisibleAcquire&&!globalThis.__codexVisibleAcquire({runId:__codexHumanRunId,label:"Running selection",source:"human-selection",codePreview:I.slice(0,300),kind:"normal"})){let __decision=globalThis.__codexLastAcquireDecision||{kind:"busy",reason:"bridge busy"};iA.window.showWarningMessage(__decision.kind==="recovery-required"?"Stata Workbench requires a verified recovery smoke before running code.":"Stata Workbench is already running a visible command. Wait for it to finish before starting another.");return{accepted:false,runId:__codexHumanRunId,decision:__decision}}'
);

replaceOnce(
  "run file rejection receipt",
  'if(globalThis.__codexVisibleAcquire&&!globalThis.__codexVisibleAcquire({runId:__codexHumanFileRunId,label:`Running ${rg.basename(A)}`,source:"human-file",codePreview:`do "${rg.basename(A)}"`})){globalThis.__codexHumanFileDebug={stage:"acquire-failed",at:new Date().toISOString(),path:A,runId:__codexHumanFileRunId,status:globalThis.__codexBridgeState||null};iA.window.showWarningMessage("Stata Workbench is already running a visible command. Wait for it to finish before starting another.");return}',
  'if(globalThis.__codexVisibleAcquire&&!globalThis.__codexVisibleAcquire({runId:__codexHumanFileRunId,label:`Running ${rg.basename(A)}`,source:"human-file",codePreview:`do "${rg.basename(A)}"`,kind:"normal"})){let __decision=globalThis.__codexLastAcquireDecision||{kind:"busy",reason:"bridge busy"};globalThis.__codexHumanFileDebug={stage:"acquire-failed",at:new Date().toISOString(),path:A,runId:__codexHumanFileRunId,status:globalThis.__codexBridgeState||null,decision:__decision};iA.window.showWarningMessage(__decision.kind==="recovery-required"?"Stata Workbench requires a verified recovery smoke before running code.":"Stata Workbench is already running a visible command. Wait for it to finish before starting another.");return{accepted:false,runId:__codexHumanFileRunId,decision:__decision}}'
);

replaceOnce(
  "register backend pid after connect",
  'let C=Q._process||Q.process||Q._serverProcess;return C&&C.stderr',
  'let C=Q._process||Q.process||Q._serverProcess;try{let __pid=Number(Q.pid||(C&&C.pid));if(__pid>1){globalThis.__codexOwnedBackendPids=globalThis.__codexOwnedBackendPids instanceof Map?globalThis.__codexOwnedBackendPids:new Map;globalThis.__codexOwnedBackendPids.set(__pid,{pid:__pid,ownerId:globalThis.__codexBackendOwnerId||null,startedAt:new Date().toISOString()})}}catch{}return C&&C.stderr'
);

replaceOnce(
  "backend owner environment",
  'STATA_SETUP_TIMEOUT:r,PYTHONUNBUFFERED:"1"}}),k=',
  'STATA_SETUP_TIMEOUT:r,PYTHONUNBUFFERED:"1",STATA_WORKBENCH_OWNER_ID:globalThis.__codexBackendOwnerId||"",STATA_WORKBENCH_BRIDGE_PORT:String(globalThis.__codexBridgePort||"")}}),k='
);

fs.writeFileSync(target, text, "utf8");
console.log("RC64_PATCH_APPLIED", target);
