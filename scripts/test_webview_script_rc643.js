#!/usr/bin/env node
"use strict";

const assert = require("assert");
const fs = require("fs");
const path = require("path");
const vm = require("vm");

const root = path.join(__dirname, "..");
const bundle = fs.readFileSync(path.join(root, "dist", "extension.js"), "utf8");
const marker = "codex patch rc.6.4.3: terminal inline script parse gate";

function count(value) {
  return bundle.split(value).length - 1;
}

const htmlStart = bundle.indexOf("function FDA");
const htmlEnd = bundle.indexOf("function JO", htmlStart);
assert.ok(htmlStart >= 0 && htmlEnd > htmlStart, "terminal HTML generator must exist");

const htmlGenerator = bundle.slice(htmlStart, htmlEnd);
const inlineTag = '<script nonce="${I}">';
const firstInline = htmlGenerator.indexOf(inlineTag);
const terminalInline = htmlGenerator.indexOf(inlineTag, firstInline + inlineTag.length);
const terminalInlineEnd = htmlGenerator.indexOf("</script>", terminalInline + inlineTag.length);
assert.ok(firstInline >= 0 && terminalInline > firstInline && terminalInlineEnd > terminalInline);

const templateSource = htmlGenerator.slice(terminalInline + inlineTag.length, terminalInlineEnd);
const inlineScript = vm.runInNewContext(`\`${templateSource}\``);
assert.doesNotThrow(
  () => new vm.Script(inlineScript, { filename: "terminal-inline.js" }),
  "generated Terminal inline JavaScript must parse independently",
);

assert.strictEqual(count(marker), 1);
for (const variable of ["t", "o", "e", "s"]) {
  assert.strictEqual(
    count(`<script nonce="\${I}" src="\${${variable}}"></script>`),
    1,
    `external Terminal script ${variable} must carry the current nonce`,
  );
}
assert.ok(inlineScript.includes("vscode.postMessage({ type: 'log', level: 'info', message: 'Terminal webview booted' })"));
assert.ok(inlineScript.includes("vscode.postMessage({ type: 'ready', terminalWebview: __codexTerminalWebviewProbe })"));
assert.ok(inlineScript.includes("typeof Sentry !== 'undefined'"));
assert.ok(!inlineScript.includes("        }\n        };\n    }"), "malformed fallback close must stay absent");

console.log("WEBVIEW_SCRIPT_RC643_PASS");
