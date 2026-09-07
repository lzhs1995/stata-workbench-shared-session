#!/usr/bin/env node
"use strict";

const fs = require("fs");
const path = require("path");
const vm = require("vm");

const target = path.join(__dirname, "..", "dist", "extension.js");
let text = fs.readFileSync(target, "utf8");

const marker = "codex patch rc.6.4.3: terminal inline script parse gate";

function count(value) {
  return text.split(value).length - 1;
}

function replaceOnce(name, before, after) {
  const first = text.indexOf(before);
  const second = first < 0 ? -1 : text.indexOf(before, first + before.length);
  if (first < 0) throw new Error(`missing rc.6.4.3 anchor: ${name}`);
  if (second >= 0) throw new Error(`non-unique rc.6.4.3 anchor: ${name}`);
  text = text.slice(0, first) + after + text.slice(first + before.length);
}

function extractTerminalInlineScript() {
  const htmlStart = text.indexOf("function FDA");
  const htmlEnd = text.indexOf("function JO", htmlStart);
  if (htmlStart < 0 || htmlEnd < 0) throw new Error("terminal HTML generator not found");
  const htmlGenerator = text.slice(htmlStart, htmlEnd);
  const tag = '<script nonce="${I}">';
  const first = htmlGenerator.indexOf(tag);
  const second = htmlGenerator.indexOf(tag, first + tag.length);
  const end = htmlGenerator.indexOf("</script>", second + tag.length);
  if (first < 0 || second < 0 || end < 0) throw new Error("terminal inline script not found");
  const templateSource = htmlGenerator.slice(second + tag.length, end);
  return vm.runInNewContext(`\`${templateSource}\``);
}

function verifyApplied() {
  const checks = [
    ["single patch marker", count(marker) === 1],
    ["highlight script has nonce", count('<script nonce="${I}" src="${t}"></script>') === 1],
    ["mark script has nonce", count('<script nonce="${I}" src="${o}"></script>') === 1],
    ["shared UI script has nonce", count('<script nonce="${I}" src="${e}"></script>') === 1],
    ["autocomplete script has nonce", count('<script nonce="${I}" src="${s}"></script>') === 1],
    ["safe optional Sentry access", text.includes("typeof Sentry !== 'undefined' && Sentry && typeof Sentry.captureException === 'function'")],
  ];
  const failed = checks.filter(([, ok]) => !ok).map(([name]) => name);
  if (failed.length) throw new Error(`incomplete rc.6.4.3 patch: ${failed.join(", ")}`);
  new vm.Script(extractTerminalInlineScript(), { filename: "terminal-inline.js" });
}

if (text.includes(marker)) {
  verifyApplied();
  console.log("RC643_WEBVIEW_SCRIPT_PATCH_ALREADY_APPLIED");
  process.exit(0);
}

const fallbackStart = text.indexOf("    // Defensive: if shared UI script fails to load");
const fallbackEnd = text.indexOf("    // Global error handler", fallbackStart);
if (fallbackStart < 0 || fallbackEnd < 0) {
  throw new Error("missing rc.6.4.3 fallback block anchors");
}
const fallback = `    // Defensive: keep the Terminal operable if the packaged shared UI cannot load.
    if (!window.stataUI) {
        window.stataUI = {
            escapeHtml: function (text) {
                return String(text == null ? '' : text)
                    .replace(/&/g, '&amp;')
                    .replace(/</g, '&lt;')
                    .replace(/>/g, '&gt;')
                    .replace(/"/g, '&quot;')
                    .replace(/'/g, '&#039;');
            },
            formatDuration: function (ms) {
                if (ms === null || ms === undefined) return '';
                if (ms < 1000) return ms + ' ms';
                const seconds = ms / 1000;
                if (seconds < 60) return seconds.toFixed(1) + ' s';
                const minutes = Math.floor(seconds / 60);
                return minutes + 'm ' + (seconds - minutes * 60).toFixed(0) + 's';
            },
            bindArtifactEvents: function () {},
            smclToHtml: function (text) {
                const escaped = this.escapeHtml(text);
                return escaped.split(String.fromCharCode(10)).join('<br>');
            }
        };
        /* ${marker} */
    }

`;
text = text.slice(0, fallbackStart) + fallback + text.slice(fallbackEnd);

for (const variable of ["t", "o", "e", "s"]) {
  replaceOnce(
    `${variable} external script nonce`,
    `<script src="\${${variable}}"></script>`,
    `<script nonce="\${I}" src="\${${variable}}"></script>`,
  );
}

replaceOnce(
  "optional Sentry access",
  "if (Sentry && typeof Sentry.captureException === 'function') Sentry.captureException(err);",
  "if (typeof Sentry !== 'undefined' && Sentry && typeof Sentry.captureException === 'function') Sentry.captureException(err);",
);

verifyApplied();
fs.writeFileSync(target, text, "utf8");
console.log("RC643_WEBVIEW_SCRIPT_PATCH_APPLIED", target);
