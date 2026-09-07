#!/usr/bin/env node
"use strict";

const assert = require("assert");
const fs = require("fs");
const path = require("path");

const root = path.join(__dirname, "..");
const bundle = fs.readFileSync(path.join(root, "dist", "extension.js"), "utf8");
const srcMain = fs.readFileSync(path.join(root, "src", "ui-shared", "main.js"), "utf8");
const distMain = fs.readFileSync(path.join(root, "dist", "ui-shared", "main.js"), "utf8");
const marker = "codex patch rc.6.4.2: restored terminal rebases current webview resources";

function count(text, value) {
  return text.split(value).length - 1;
}

function windowFrom(start, length = 3500) {
  const at = bundle.indexOf(start);
  assert.ok(at >= 0, `missing rc.6.4.2 wiring anchor: ${start}`);
  return bundle.slice(at, at + length);
}

assert.strictEqual(count(bundle, marker), 1);
assert.strictEqual(count(bundle, "Gg.setExtensionUri(g.extensionUri)"), 1);

const setUriAt = bundle.indexOf("Gg.setExtensionUri(g.extensionUri)");
const serializerAt = bundle.indexOf("registerWebviewPanelSerializer");
assert.ok(setUriAt >= 0 && serializerAt > setUriAt, "extension URI must be set before serializer registration");

const serializer = windowFrom("registerWebviewPanelSerializer", 500);
assert.ok(serializer.includes("Gg.restorePanel(o,s,g.extensionUri)"));

const restore = windowFrom("static restorePanel(A,I,Q)", 2300);
assert.ok(restore.includes("let B=Q||g.extensionUri"));
assert.ok(restore.includes("g.extensionUri=B"));
assert.ok(restore.includes("webview.options={enableScripts:!0,localResourceRoots:"));
assert.ok(restore.includes('oB.Uri.joinPath(B,"src","ui-shared")'));
assert.ok(restore.includes('oB.Uri.joinPath(B,"dist","ui-shared")'));
assert.ok(restore.includes("oB.Uri.file(Jag())"));
assert.ok(restore.includes("webview.html=FDA(g.currentPanel.webview,B"));
assert.ok(restore.includes(marker));

const readyHandler = windowFrom('I.type==="ready"', 1500);
assert.ok(readyHandler.includes("__codexTerminalWebviewStatus"));
assert.ok(readyHandler.includes("scriptReady:Q.scriptReady===!0"));
assert.ok(readyHandler.includes("styleReady:Q.styleReady===!0"));
assert.ok(readyHandler.includes("initializationError:Q.initializationError||null"));

const status = windowFrom("extensionVersion:", 1800);
assert.ok(status.includes("terminalWebview:"));
assert.ok(status.includes("__codexTerminalWebviewStatus"));

const webviewProbe = windowFrom("const __codexCollectTerminalWebviewProbe", 7000);
assert.ok(webviewProbe.includes("window.__stataWorkbenchSharedUiLoaded === true"));
assert.ok(webviewProbe.includes("inputStyle.position === 'fixed'"));
assert.ok(webviewProbe.includes("themeBackground === '#09090b'"));
assert.ok(webviewProbe.includes("terminalWebview: __codexTerminalWebviewProbe"));
assert.ok(webviewProbe.includes("__codexCollectTerminalWebviewProbe(err)"));
assert.ok(webviewProbe.includes("typeof Sentry !== 'undefined' && Sentry && typeof Sentry.captureException === 'function'"));

const sharedUiMarker = "window.__stataWorkbenchSharedUiLoaded = true;";
assert.strictEqual(count(srcMain, sharedUiMarker), 1);
assert.strictEqual(count(distMain, sharedUiMarker), 1);
assert.strictEqual(srcMain, distMain, "src/dist shared UI main.js must stay byte-identical");

console.log("WEBVIEW_RESTORE_RC642_PASS");
