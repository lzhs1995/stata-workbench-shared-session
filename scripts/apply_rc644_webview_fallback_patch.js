#!/usr/bin/env node
"use strict";

const fs = require("fs");
const path = require("path");
const vm = require("vm");

const target = path.join(__dirname, "..", "dist", "extension.js");
let text = fs.readFileSync(target, "utf8");

const marker = "codex-smcl-fallback-v2-template-safe";
const rc643Marker = "codex patch rc.6.4.3: terminal inline script parse gate";

function count(value) {
  return text.split(value).length - 1;
}

function replaceOnce(name, before, after) {
  const first = text.indexOf(before);
  const second = first < 0 ? -1 : text.indexOf(before, first + before.length);
  if (first < 0) throw new Error(`missing rc.6.4.4 anchor: ${name}`);
  if (second >= 0) throw new Error(`non-unique rc.6.4.4 anchor: ${name}`);
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
  const inlineScript = extractTerminalInlineScript();
  const checks = [
    ["single fallback v2 marker", count(marker) === 1],
    ["rc.6.4.3 marker retained", count(rc643Marker) === 1],
    ["fallback active flag", inlineScript.includes("window.__stataWorkbenchFallbackActive = true;")],
    ["fallback version flag", inlineScript.includes("window.__stataWorkbenchFallbackVersion = 'v2';")],
    ["probe exposes fallback active", inlineScript.includes("fallbackActive: window.__stataWorkbenchFallbackActive === true")],
    ["probe exposes fallback version", inlineScript.includes("fallbackVersion: window.__stataWorkbenchFallbackVersion || null")],
    ["extension status stores fallback state", text.includes("fallbackActive:Q.fallbackActive===!0,fallbackVersion:Q.fallbackVersion||null")],
  ];
  const failed = checks.filter(([, ok]) => !ok).map(([name]) => name);
  if (failed.length) throw new Error(`incomplete rc.6.4.4 patch: ${failed.join(", ")}`);
  new vm.Script(inlineScript, { filename: "terminal-inline.js" });
}

if (text.includes(marker)) {
  verifyApplied();
  console.log("RC644_WEBVIEW_FALLBACK_PATCH_ALREADY_APPLIED");
  process.exit(0);
}

const fallbackStart = text.indexOf("    // Defensive: keep the Terminal operable");
const fallbackEnd = text.indexOf("    // Global error handler", fallbackStart);
if (fallbackStart < 0 || fallbackEnd < 0) {
  throw new Error("missing rc.6.4.4 fallback block anchors");
}

const fallback = `    // Defensive: keep the Terminal readable if the packaged shared UI cannot load.
    if (!window.stataUI) {
        window.__stataWorkbenchFallbackActive = true;
        window.__stataWorkbenchFallbackVersion = 'v2';
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
                if (text == null) return '';
                const styleTags = new Set([
                    'smcl', '/smcl', 'txt', '/txt', 'res', '/res', 'com', '/com',
                    'err', '/err', 'inp', '/inp', 'input', '/input', 'result', '/result',
                    'text', '/text', 'error', '/error', 'bf', '/bf', 'it', '/it',
                    'sf', '/sf', 'ul', '/ul', 'hi', '/hi', 'hilite', '/hilite',
                    'bold', '/bold', 'italic', '/italic'
                ]);
                const charMap = {
                    '-': 9472, '|': 9474, '+': 9532, 'TLC': 9484, 'TRC': 9488,
                    'BLC': 9492, 'BRC': 9496, 'LT': 9500, 'RT': 9508, 'TT': 9516,
                    'BT': 9524, 'S|': 9474, 'M+': 9532, 'dash': 8211,
                    'rularrow': 8594, 'lularrow': 8592, 'ldblqq': 8220,
                    'rdblqq': 8221, 'lq': 8216, 'rq': 8217, 'sect': 167, 'space': 32
                };
                const isDigits = function (value) {
                    if (!value) return false;
                    for (let index = 0; index < value.length; index += 1) {
                        if (value[index] < '0' || value[index] > '9') return false;
                    }
                    return true;
                };
                const boundedCount = function (value, fallbackValue) {
                    const parsed = isDigits(value) ? Number(value) : fallbackValue;
                    return Math.max(0, Math.min(400, parsed));
                };
                const splitWords = function (value) {
                    return value.trim().split(' ').filter(function (part) { return part.length > 0; });
                };
                const source = String(text);
                let output = '';
                let index = 0;
                while (index < source.length) {
                    const code = source.charCodeAt(index);
                    if (code === 10 || code === 13) {
                        if (code === 13 && source.charCodeAt(index + 1) === 10) index += 1;
                        output += '<br>';
                        index += 1;
                        continue;
                    }
                    if (source[index] !== '{') {
                        let next = index + 1;
                        while (next < source.length && source[next] !== '{' && source.charCodeAt(next) !== 10 && source.charCodeAt(next) !== 13) next += 1;
                        output += this.escapeHtml(source.slice(index, next));
                        index = next;
                        continue;
                    }
                    const close = source.indexOf('}', index + 1);
                    if (close < 0) {
                        output += this.escapeHtml(source.slice(index));
                        break;
                    }
                    const rawTag = source.slice(index + 1, close);
                    const trimmed = rawTag.trim();
                    const lower = trimmed.toLowerCase();
                    const words = splitWords(trimmed);
                    const command = words.length ? words[0].toLowerCase() : '';
                    if (styleTags.has(lower)) {
                        // Styling-only wrappers do not need visible fallback output.
                    } else if (command === 'c') {
                        const arg = trimmed.slice(command.length).trim();
                        if (Object.prototype.hasOwnProperty.call(charMap, arg)) output += String.fromCharCode(charMap[arg]);
                        else if (isDigits(arg)) output += String.fromCharCode(Number(arg));
                    } else if (command === 'hline') {
                        output += String.fromCharCode(9472).repeat(boundedCount(words[1], 60));
                    } else if (command === 'dup') {
                        const colon = trimmed.indexOf(':');
                        const countText = colon < 0 ? '' : trimmed.slice(command.length, colon).trim();
                        const content = colon < 0 ? '' : trimmed.slice(colon + 1);
                        output += this.escapeHtml(content.repeat(boundedCount(countText, 0)));
                    } else if (command === 'space') {
                        output += ' '.repeat(boundedCount(words[1], 1));
                    } else if (command === 'col' || command === 'column') {
                        output += ' ';
                    } else {
                        const colon = rawTag.indexOf(':');
                        if (colon >= 0) output += this.escapeHtml(rawTag.slice(colon + 1));
                    }
                    index = close + 1;
                }
                return output;
            }
        };
        /* ${rc643Marker} */
        /* ${marker} */
    }

`;

text = text.slice(0, fallbackStart) + fallback + text.slice(fallbackEnd);

replaceOnce(
  "terminal fallback probe",
  "            scriptReady: window.__stataWorkbenchSharedUiLoaded === true,\n            styleReady: !!(inputStyle && inputStyle.position === 'fixed' && themeBackground === '#09090b'),",
  "            scriptReady: window.__stataWorkbenchSharedUiLoaded === true,\n            styleReady: !!(inputStyle && inputStyle.position === 'fixed' && themeBackground === '#09090b'),\n            fallbackActive: window.__stataWorkbenchFallbackActive === true,\n            fallbackVersion: window.__stataWorkbenchFallbackVersion || null,",
);

replaceOnce(
  "extension-host fallback status",
  "initializationError:Q.initializationError||null}",
  "initializationError:Q.initializationError||null,fallbackActive:Q.fallbackActive===!0,fallbackVersion:Q.fallbackVersion||null}",
);

verifyApplied();
fs.writeFileSync(target, text, "utf8");
console.log("RC644_WEBVIEW_FALLBACK_PATCH_APPLIED", target);
