#!/usr/bin/env node
"use strict";

const assert = require("assert");
const adapter = require("./terminal_ui_command");

for (const source of ["browse", " BROWSE ", "edit\n"]) {
  const result = adapter.classifyTerminalUiCommand(source);
  assert.ok(result);
  assert.strictEqual(result.kind, "view-data");
  assert.match(adapter.createTerminalUiSurrogate(result), /Opening Data Browser/);
}

for (const source of [
  "browse price mpg",
  "edit price",
  "browse\ndisplay _N",
  "capture browse",
  "display \"browse\"",
  "",
]) {
  assert.strictEqual(adapter.classifyTerminalUiCommand(source), null);
}

assert.strictEqual(adapter.createTerminalUiSurrogate(null), null);
console.log("TERMINAL_UI_COMMAND_RC7_PASS");
