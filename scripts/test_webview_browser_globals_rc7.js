#!/usr/bin/env node
"use strict";

const assert = require("assert");
const fs = require("fs");
const path = require("path");

const root = path.join(__dirname, "..");
const files = [
  "src/ui-shared/main.js",
  "src/ui-shared/data-browser.js",
  "dist/ui-shared/main.js",
  "dist/ui-shared/data-browser.js",
];

for (const relative of files) {
  const text = fs.readFileSync(path.join(root, relative), "utf8");
  assert.strictEqual(
    /release\s*:\s*process\.env\.SENTRY_RELEASE\b/.test(text),
    false,
    `${relative} must not read process.env.SENTRY_RELEASE at webview startup`
  );
  assert.strictEqual(
    text.includes("globalThis.__SENTRY_RELEASE__"),
    true,
    `${relative} must use the browser-safe release hook`
  );
  console.log("PASS", relative, "has no unsafe Node-only release lookup");
}

console.log("WEBVIEW_BROWSER_GLOBALS_RC7_PASS");
