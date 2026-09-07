"use strict";

function classifyTerminalUiCommand(source) {
  const text = String(source == null ? "" : source).replace(/\r\n?/g, "\n").trim();
  const match = /^(browse|edit)$/i.exec(text);
  if (!match) return null;
  return {
    kind: "view-data",
    command: match[1].toLowerCase(),
    original: text,
  };
}

function createTerminalUiSurrogate(command) {
  if (!command || command.kind !== "view-data") return null;
  return 'display as text "[Stata Workbench] Opening Data Browser"\n';
}

module.exports = {
  classifyTerminalUiCommand,
  createTerminalUiSurrogate,
};
