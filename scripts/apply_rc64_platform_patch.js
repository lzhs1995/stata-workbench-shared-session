#!/usr/bin/env node
"use strict";

const fs = require("fs");
const path = require("path");

const target = path.join(__dirname, "..", "dist", "extension.js");
let text = fs.readFileSync(target, "utf8");

if (text.includes("codex patch rc.6.4: platform panic adapter")) {
  const panicCommandBefore = 'globalThis.__codexBridgeState=s;globalThis.__codexGraphMark&&__codexGraphMark({readinessState:"stale",readinessReason:"panic-kill-command-needs-smoke"';
  const panicCommandAfter = 'globalThis.__codexBridgeState=s;globalThis.__codexRecoveryState=globalThis.__codexControlPlane.requestRecovery(globalThis.__codexRecoveryState,"panic-kill-command-needs-smoke");/* codex patch rc.6.4: Windows panic command enters recovery control plane */globalThis.__codexGraphMark&&__codexGraphMark({readinessState:"stale",readinessReason:"panic-kill-command-needs-smoke"';
  if (text.includes(panicCommandBefore)) {
    text = text.replace(panicCommandBefore, panicCommandAfter);
    fs.writeFileSync(target, text, "utf8");
    console.log("RC64_PLATFORM_REPAIRED_WINDOWS_PANIC", target);
  } else if (!text.includes(panicCommandAfter)) {
    throw new Error("rc.6.4 Windows panic command is not wired to recovery state");
  } else {
    console.log("RC64_PLATFORM_ALREADY_APPLIED");
  }
  process.exit(0);
}

function replaceOnce(name, before, after) {
  const first = text.indexOf(before);
  const second = first < 0 ? -1 : text.indexOf(before, first + before.length);
  if (first < 0) throw new Error(`missing rc.6.4 platform anchor: ${name}`);
  if (second >= 0) throw new Error(`non-unique rc.6.4 platform anchor: ${name}`);
  text = text.slice(0, first) + after + text.slice(first + before.length);
}

replaceOnce(
  "status-bar panic platform adapter",
  'if(__choice!=="Kill all Stata processes")return;let cp=require("child_process"),__args=',
  'if(__choice!=="Kill all Stata processes")return;if(process.platform!=="win32"){let __state=globalThis.__codexForceReset?await globalThis.__codexForceReset("panic-kill-command platform adapter"):null;iA.window.showInformationMessage("Stata Workbench owned backend reset. Run the verified recovery smoke before productive work.");return}/* codex patch rc.6.4: platform panic adapter */let cp=require("child_process"),__args='
);

replaceOnce(
  "status-bar Windows panic enters recovery",
  'globalThis.__codexBridgeState=s;globalThis.__codexGraphMark&&__codexGraphMark({readinessState:"stale",readinessReason:"panic-kill-command-needs-smoke"',
  'globalThis.__codexBridgeState=s;globalThis.__codexRecoveryState=globalThis.__codexControlPlane.requestRecovery(globalThis.__codexRecoveryState,"panic-kill-command-needs-smoke");/* codex patch rc.6.4: Windows panic command enters recovery control plane */globalThis.__codexGraphMark&&__codexGraphMark({readinessState:"stale",readinessReason:"panic-kill-command-needs-smoke"'
);

replaceOnce(
  "HTTP panic platform adapter",
  'if(__req.method==="POST"&&__req.url.startsWith("/panic-kill")){/* codex patch v10: panic kill endpoint */let __panic=null;',
  'if(__req.method==="POST"&&__req.url.startsWith("/panic-kill")){/* codex patch v10: panic kill endpoint */if(process.platform!=="win32"){let __state=globalThis.__codexForceReset?await globalThis.__codexForceReset("panic-kill endpoint platform adapter"):__current();__send(__res,200,{ok:true,panicKill:true,platform:process.platform,ownedOnly:true,patch:__patch,state:__state});return}let __panic=null;'
);

replaceOnce(
  "owned process exit deregistration",
  'globalThis.__codexOwnedBackendPids.set(__pid,{pid:__pid,ownerId:globalThis.__codexBackendOwnerId||null,startedAt:new Date().toISOString()})}}catch{}return C&&C.stderr',
  'globalThis.__codexOwnedBackendPids.set(__pid,{pid:__pid,ownerId:globalThis.__codexBackendOwnerId||null,startedAt:new Date().toISOString()});if(C&&typeof C.once==="function")C.once("exit",()=>{try{(globalThis.__codexOwnedBackendPids||new Map).delete(__pid)}catch{}})}}catch{}return C&&C.stderr'
);

fs.writeFileSync(target, text, "utf8");
console.log("RC64_PLATFORM_APPLIED", target);
