#!/usr/bin/env node
"use strict";

const fs = require("fs");
const path = require("path");

const target = path.join(__dirname, "..", "dist", "extension.js");
let text = fs.readFileSync(target, "utf8");

const marker = "codex patch rc.6.4.2: restored terminal rebases current webview resources";

function count(value) {
  return text.split(value).length - 1;
}

function replaceOnce(name, before, after) {
  const first = text.indexOf(before);
  const second = first < 0 ? -1 : text.indexOf(before, first + before.length);
  if (first < 0) throw new Error(`missing rc.6.4.2 anchor: ${name}`);
  if (second >= 0) throw new Error(`non-unique rc.6.4.2 anchor: ${name}`);
  text = text.slice(0, first) + after + text.slice(first + before.length);
}

function replaceExactly(name, before, after, expectedCount) {
  const actualCount = count(before);
  if (actualCount !== expectedCount) {
    throw new Error(
      `unexpected rc.6.4.2 anchor count for ${name}: expected ${expectedCount}, got ${actualCount}`,
    );
  }
  text = text.split(before).join(after);
}

function verifyApplied() {
  const serializer = 'iA.window.registerWebviewPanelSerializer&&iA.window.registerWebviewPanelSerializer("stataTerminal",{async deserializeWebviewPanel(o,s){Gg.restorePanel(o,s,g.extensionUri)}})';
  const setUriAt = text.indexOf("Gg.setExtensionUri(g.extensionUri)");
  const serializerAt = text.indexOf(serializer);
  const checks = [
    ["single patch marker", count(marker) === 1],
    ["single extension URI initialization", count("Gg.setExtensionUri(g.extensionUri)") === 1],
    ["URI initialized before serializer", setUriAt >= 0 && serializerAt > setUriAt],
    ["serializer passes current URI", serializerAt >= 0],
    ["restore accepts current URI", text.includes("static restorePanel(A,I,Q){let B=Q||g.extensionUri")],
    ["restore resets webview options", text.includes("g.currentPanel.webview.options={enableScripts:!0,localResourceRoots:")],
    ["status exposes terminal webview", text.includes("terminalWebview:(function(){try{return globalThis.__codexTerminalWebviewStatus")],
    ["ready handler records probes", text.includes("styleReady:Q.styleReady===!0")],
    ["ready handler records initialization errors", text.includes("initializationError:Q.initializationError||null")],
    ["webview ready payload includes probes", text.includes("terminalWebview: __codexTerminalWebviewProbe")],
    ["restore errors still signal readiness", text.includes("__codexCollectTerminalWebviewProbe(err)")],
  ];
  const failed = checks.filter(([, ok]) => !ok).map(([name]) => name);
  if (failed.length) throw new Error(`incomplete rc.6.4.2 patch: ${failed.join(", ")}`);
}

if (text.includes(marker)) {
  const readyHandlerBefore = 'if(g._testCapture&&g._testCapture(I),I.type==="ready"){g._webviewReady=!0;try{let Q=I.terminalWebview||{};globalThis.__codexTerminalWebviewStatus={...(globalThis.__codexTerminalWebviewStatus||{}),panelExists:!!g.currentPanel,scriptReady:Q.scriptReady===!0,styleReady:Q.styleReady===!0,bundleId:g.extensionUri?.fsPath||g.extensionUri?.toString?.()||null,readyAt:new Date().toISOString(),stylesheetCount:Number.isFinite(Q.stylesheetCount)?Q.stylesheetCount:null,inputPosition:Q.inputPosition||null,themeBackground:Q.themeBackground||null}}catch{}g._flushPendingMessages();return}';
  const readyHandlerAfter = 'if(g._testCapture&&g._testCapture(I),I.type==="ready"){g._webviewReady=!0;try{let Q=I.terminalWebview||{};globalThis.__codexTerminalWebviewStatus={...(globalThis.__codexTerminalWebviewStatus||{}),panelExists:!!g.currentPanel,scriptReady:Q.scriptReady===!0,styleReady:Q.styleReady===!0,bundleId:g.extensionUri?.fsPath||g.extensionUri?.toString?.()||null,readyAt:new Date().toISOString(),stylesheetCount:Number.isFinite(Q.stylesheetCount)?Q.stylesheetCount:null,inputPosition:Q.inputPosition||null,themeBackground:Q.themeBackground||null,initializationError:Q.initializationError||null}}catch{}g._flushPendingMessages();return}';
  let repaired = false;
  if (text.includes(readyHandlerBefore)) {
    replaceOnce("ready handler initialization-error repair", readyHandlerBefore, readyHandlerAfter);
    repaired = true;
  }
  verifyApplied();
  if (repaired) {
    fs.writeFileSync(target, text, "utf8");
    console.log("RC642_WEBVIEW_PATCH_REPAIRED", target);
  } else {
    console.log("RC642_WEBVIEW_PATCH_ALREADY_APPLIED");
  }
  process.exit(0);
}

replaceOnce(
  "restored panel rebases resources",
  'static restorePanel(A,I){if(g.currentPanel=A,g._panelInstanceId+=1,g.currentPanel.__stataPanelId=g._panelInstanceId,g._webviewReady=!1,g._pendingWebviewMessages=[],g.currentPanel.onDidDispose(()=>{g.currentPanel=null,g._webviewReady=!0,g._pendingWebviewMessages=[]}),g._setupWebviewHandlers(),g._handlersFactory&&g._bindHandlers(g._handlersFactory()),!g.extensionUri)return;let Q=pDA();g.currentPanel.webview.html=FDA(g.currentPanel.webview,g.extensionUri,Q,g._activeFilePath,[])}',
  'static restorePanel(A,I,Q){let B=Q||g.extensionUri;if(!B)return;g.extensionUri=B,g.currentPanel=A,g.currentPanel.webview.options={enableScripts:!0,localResourceRoots:[oB.Uri.joinPath(B,"src","ui-shared"),oB.Uri.joinPath(B,"dist","ui-shared"),oB.Uri.file(Jag())]},g._panelInstanceId+=1,g.currentPanel.__stataPanelId=g._panelInstanceId,g._webviewReady=!1,g._pendingWebviewMessages=[],globalThis.__codexTerminalWebviewStatus={panelExists:!0,scriptReady:!1,styleReady:!1,bundleId:B.fsPath||B.toString(),readyAt:null,renderedAt:new Date().toISOString(),restored:!0},g.currentPanel.onDidDispose(()=>{g.currentPanel=null,g._webviewReady=!0,g._pendingWebviewMessages=[]}),g._setupWebviewHandlers(),g._handlersFactory&&g._bindHandlers(g._handlersFactory());let C=pDA();g.currentPanel.webview.html=FDA(g.currentPanel.webview,B,C,g._activeFilePath,[])}/* codex patch rc.6.4.2: restored terminal rebases current webview resources */',
);

replaceExactly(
  "panel disposal clears readiness",
  'g.currentPanel.onDidDispose(()=>{g.currentPanel=null,g._webviewReady=!0,g._pendingWebviewMessages=[]})',
  'g.currentPanel.onDidDispose(()=>{g.currentPanel=null,g._webviewReady=!0,g._pendingWebviewMessages=[],globalThis.__codexTerminalWebviewStatus={...(globalThis.__codexTerminalWebviewStatus||{}),panelExists:!1,scriptReady:!1,styleReady:!1,disposedAt:new Date().toISOString()}})',
  2,
);

replaceOnce(
  "new panel records pending readiness",
  'g.currentPanel.webview.html=FDA(a,g.extensionUri,c,g._activeFilePath,h),g._webviewReady=!1,g._pendingWebviewMessages=[],g.currentPanel.reveal(r,!0)',
  'g.currentPanel.webview.html=FDA(a,g.extensionUri,c,g._activeFilePath,h),g._webviewReady=!1,g._pendingWebviewMessages=[],globalThis.__codexTerminalWebviewStatus={panelExists:!0,scriptReady:!1,styleReady:!1,bundleId:g.extensionUri?.fsPath||g.extensionUri?.toString?.()||null,readyAt:null,renderedAt:new Date().toISOString(),restored:!1},g.currentPanel.reveal(r,!0)',
);

replaceOnce(
  "ready handler records webview probes",
  'if(g._testCapture&&g._testCapture(I),I.type==="ready"){g._webviewReady=!0,g._flushPendingMessages();return}',
  'if(g._testCapture&&g._testCapture(I),I.type==="ready"){g._webviewReady=!0;try{let Q=I.terminalWebview||{};globalThis.__codexTerminalWebviewStatus={...(globalThis.__codexTerminalWebviewStatus||{}),panelExists:!!g.currentPanel,scriptReady:Q.scriptReady===!0,styleReady:Q.styleReady===!0,bundleId:g.extensionUri?.fsPath||g.extensionUri?.toString?.()||null,readyAt:new Date().toISOString(),stylesheetCount:Number.isFinite(Q.stylesheetCount)?Q.stylesheetCount:null,inputPosition:Q.inputPosition||null,themeBackground:Q.themeBackground||null,initializationError:Q.initializationError||null}}catch{}g._flushPendingMessages();return}',
);

replaceOnce(
  "initialize URI before serializer",
  'iA.window.registerWebviewPanelSerializer&&iA.window.registerWebviewPanelSerializer("stataTerminal",{async deserializeWebviewPanel(o,s){Gg.restorePanel(o,s)}});;',
  'Gg.setExtensionUri(g.extensionUri),iA.window.registerWebviewPanelSerializer&&iA.window.registerWebviewPanelSerializer("stataTerminal",{async deserializeWebviewPanel(o,s){Gg.restorePanel(o,s,g.extensionUri)}});;',
);

replaceOnce(
  "remove late URI initialization",
  'Qn=g.extensionUri,Gg.setExtensionUri(g.extensionUri),Gg.setLogProvider',
  'Qn=g.extensionUri,Gg.setLogProvider',
);

replaceOnce(
  "status exposes terminal readiness",
  'bridgePort:(function(){try{return globalThis.__codexBridgePort||null}catch(e){return null}})(),graphPanel:',
  'bridgePort:(function(){try{return globalThis.__codexBridgePort||null}catch(e){return null}})(),terminalWebview:(function(){try{return globalThis.__codexTerminalWebviewStatus||{panelExists:!!Gg.currentPanel,scriptReady:!1,styleReady:!1,bundleId:(yC&&yC.extensionUri&&yC.extensionUri.fsPath)||null,readyAt:null}}catch(e){return null}})(),graphPanel:',
);

replaceOnce(
  "webview probe helper",
  "    // Render initial entries if any\n    try {",
  "    const __codexCollectTerminalWebviewProbe = (initializationError) => {\n        const inputArea = document.querySelector('.input-area');\n        const inputStyle = inputArea ? window.getComputedStyle(inputArea) : null;\n        const themeBackground = window.getComputedStyle(document.documentElement).getPropertyValue('--bg-app').trim();\n        return {\n            scriptReady: window.__stataWorkbenchSharedUiLoaded === true,\n            styleReady: !!(inputStyle && inputStyle.position === 'fixed' && themeBackground === '#09090b'),\n            stylesheetCount: Array.from(document.querySelectorAll('link[rel=\"stylesheet\"]')).filter(link => !!link.sheet).length,\n            inputPosition: inputStyle ? inputStyle.position : null,\n            themeBackground: themeBackground || null,\n            initializationError: initializationError ? String(initializationError.message || initializationError) : null\n        };\n    };\n\n    // Render initial entries if any\n    try {",
);

replaceOnce(
  "successful restore signals readiness",
  "        // Notify ready\n        vscode.postMessage({ type: 'ready' });\n        requestVariables();\n    } catch (err) {\n        Sentry.captureException(err);\n        console.error('Failed to render initial entries', err);\n        vscode.postMessage({ type: 'log', level: 'error', message: err.message });\n    }",
  "        // Notify ready with external-resource probes.\n        const __codexTerminalWebviewProbe = __codexCollectTerminalWebviewProbe(null);\n        vscode.postMessage({ type: 'ready', terminalWebview: __codexTerminalWebviewProbe });\n        requestVariables();\n    } catch (err) {\n        if (Sentry && typeof Sentry.captureException === 'function') Sentry.captureException(err);\n        console.error('Failed to render initial entries', err);\n        vscode.postMessage({ type: 'ready', terminalWebview: __codexCollectTerminalWebviewProbe(err) });\n        vscode.postMessage({ type: 'log', level: 'error', message: err.message });\n        try { requestVariables(); } catch (_) {}\n    }",
);

verifyApplied();
fs.writeFileSync(target, text, "utf8");
console.log("RC642_WEBVIEW_PATCH_APPLIED", target);
