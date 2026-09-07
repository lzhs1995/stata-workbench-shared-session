#!/usr/bin/env node
"use strict";

const assert = require("assert");
const fs = require("fs");
const path = require("path");
const vm = require("vm");

const root = path.join(__dirname, "..");
const bundle = fs.readFileSync(path.join(root, "dist", "extension.js"), "utf8");
const marker = "codex-smcl-fallback-v2-template-safe";

function count(value) {
  return bundle.split(value).length - 1;
}

function extractTerminalInlineScript() {
  const htmlStart = bundle.indexOf("function FDA");
  const htmlEnd = bundle.indexOf("function JO", htmlStart);
  assert.ok(htmlStart >= 0 && htmlEnd > htmlStart, "terminal HTML generator must exist");
  const htmlGenerator = bundle.slice(htmlStart, htmlEnd);
  const tag = '<script nonce="${I}">';
  const first = htmlGenerator.indexOf(tag);
  const second = htmlGenerator.indexOf(tag, first + tag.length);
  const end = htmlGenerator.indexOf("</script>", second + tag.length);
  assert.ok(first >= 0 && second > first && end > second, "terminal inline script must exist");
  return vm.runInNewContext(`\`${htmlGenerator.slice(second + tag.length, end)}\``);
}

function loadFallback(existingUi) {
  const inlineScript = extractTerminalInlineScript();
  const start = inlineScript.indexOf("    // Defensive: keep the Terminal readable");
  const end = inlineScript.indexOf("    // Global error handler", start);
  assert.ok(start >= 0 && end > start, "rendered fallback block must exist");
  const context = { window: {} };
  if (existingUi) context.window.stataUI = existingUi;
  vm.runInNewContext(inlineScript.slice(start, end), context, { filename: "terminal-fallback-v2.js" });
  return context.window;
}

const inlineScript = extractTerminalInlineScript();
assert.doesNotThrow(() => new vm.Script(inlineScript, { filename: "terminal-inline.js" }));
assert.strictEqual(count(marker), 1);
assert.ok(inlineScript.includes("fallbackActive: window.__stataWorkbenchFallbackActive === true"));
assert.ok(bundle.includes("fallbackActive:Q.fallbackActive===!0,fallbackVersion:Q.fallbackVersion||null"));

const fallbackWindow = loadFallback();
assert.strictEqual(fallbackWindow.__stataWorkbenchFallbackActive, true);
assert.strictEqual(fallbackWindow.__stataWorkbenchFallbackVersion, "v2");
const render = fallbackWindow.stataUI.smclToHtml.bind(fallbackWindow.stataUI);
const line = String.fromCharCode(9472);

const cases = [
  ["null", null, ""],
  ["plain", "hello", "hello"],
  ["html escape", "<b>&\"'", "&lt;b&gt;&amp;&quot;&#039;"],
  ["LF", "a\nb", "a<br>b"],
  ["CRLF", "a\r\nb", "a<br>b"],
  ["txt wrapper", "{txt}hello{/txt}", "hello"],
  ["real garble sample", "{res}{txt}编码探测中文测试", "编码探测中文测试"],
  ["command wrapper", "{com}. summarize{/com}", ". summarize"],
  ["error wrapper", "{err}bad{/err}", "bad"],
  ["input wrapper", "{inp}x{/inp}", "x"],
  ["bold content", "{bf:bold}", "bold"],
  ["italic content", "{it:italic}", "italic"],
  ["command content", "{cmd:display}", "display"],
  ["help label", "{help regress:Regression}", "Regression"],
  ["short hline", "{hline 4}", line.repeat(4)],
  ["default hline", "{hline}", line.repeat(60)],
  ["box character", "{c -}", line],
  ["numeric character", "{c 65}", "A"],
  ["smart quotes", "{c ldblqq}x{c rdblqq}", String.fromCharCode(8220) + "x" + String.fromCharCode(8221)],
  ["duplicate", "{dup 3:x}", "xxx"],
  ["space", "{space 3}x", "   x"],
  ["column", "{col 12}x", " x"],
];

for (const [name, input, expected] of cases) {
  assert.strictEqual(render(input), expected, name);
}

const existingUi = { sentinel: true };
const existingWindow = loadFallback(existingUi);
assert.strictEqual(existingWindow.stataUI, existingUi, "fallback must not replace the packaged shared UI");
assert.strictEqual(existingWindow.__stataWorkbenchFallbackActive, undefined);

console.log(`WEBVIEW_FALLBACK_RC644_PASS ${cases.length}/22`);
