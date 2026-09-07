#!/usr/bin/env node
"use strict";

const assert = require("assert");
const fs = require("fs");
const os = require("os");
const path = require("path");
const adapter = require("./darwin_compat_adapter");

const root = fs.mkdtempSync(path.join(os.tmpdir(), "darwin-ref-compat-"));
const nested = path.join(root, "activated.do");
const source = [
  'graph export "/tmp/case2.png", name(case2) replace width(1400)',
  'putdocx image "/tmp/case2.png", width(4)',
  'putdocx save "/tmp/case2.docx", replace',
  "",
].join("\n");
fs.writeFileSync(nested, source, "utf8");

const prepared = adapter.prepareVisibleExecution(`do "${nested}"`, {
  platform: "darwin",
  cwd: root,
  tempRoot: root,
  extensionRoot: path.join(__dirname, ".."),
});
assert.strictEqual(prepared.darwinDiagnostics.ok, true, JSON.stringify(prepared.darwinDiagnostics));
assert.strictEqual(prepared.darwinDiagnostics.referencedFiles, 1);
assert.strictEqual(prepared.darwinDiagnostics.replacements, 3);
assert.strictEqual(prepared.sourceDiagnostics.referencedDoCopies.length, 1);
assert.strictEqual(prepared.sourceDiagnostics.paginationGuardApplied, true);
assert.ok(prepared.code.startsWith("set more off\n"));
const copied = prepared.sourceDiagnostics.referencedDoCopies[0].tempPath;
assert.notStrictEqual(copied, nested);
const copiedText = fs.readFileSync(copied, "utf8");
assert.ok(copiedText.includes(".__pngcompat__.svg"));
assert.ok(copiedText.includes("__CODEX_DOCX_IMAGE_V1__"));
assert.ok(copiedText.includes("docx_image_inject.py"));
assert.strictEqual(fs.readFileSync(nested, "utf8"), source,
  "referenced research do-file must stay byte-identical");

const win = adapter.prepareVisibleExecution(`do "${nested}"`, {
  platform: "win32",
  cwd: root,
  tempRoot: root,
  extensionRoot: path.join(__dirname, ".."),
});
assert.strictEqual(win.code, `set more off\ndo "${nested}"`);
assert.strictEqual(win.sourceDiagnostics.paginationGuardApplied, true);
assert.strictEqual(win.sourceDiagnostics.referencedDoCopies.length, 0);
assert.strictEqual(win.darwinDiagnostics.reason, "non-darwin");

console.log("DARWIN_COMPAT_ADAPTER_PASS");
