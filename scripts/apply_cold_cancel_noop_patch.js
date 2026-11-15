#!/usr/bin/env node
"use strict";
const fs = require("node:fs");
const path = require("node:path");
const fingerprint = require("./finalize_bundle_identity");
const MARKER = "/* Workbench 0.2: cold idle Stop does not start a backend */";
const STOP_BEFORE = "globalThis.__codexSoftStop=(__codexInnerSoftStop=>async __reason=>{let __stop=null";
const STOP_AFTER = "globalThis.__codexSoftStop=(__codexInnerSoftStop=>async __reason=>{"
  + "let __coldStop=require(\"../scripts/cold_cancel_core\").coldNoop(zg,globalThis,__reason);"
  + "if(__coldStop)return globalThis.__codexLastSoftStop=__coldStop;"
  + MARKER + "let __stop=null";
const TOAST_BEFORE = 'iA.window.showWarningMessage(g&&(g.fenced===true||!!globalThis.__codexContinuityLost)?';
const TOAST_AFTER = 'iA.window.showWarningMessage(g&&g.noop===true?'
  + '"No Stata work is running; nothing was stopped or restored.":'
  + 'g&&(g.fenced===true||!!globalThis.__codexContinuityLost)?';
const PAIRS = [[STOP_BEFORE, STOP_AFTER], [TOAST_BEFORE, TOAST_AFTER]];
function unique(source, text) {
  if (source.split(text).length !== 2) throw new Error("missing or ambiguous cold Cancel anchor");
}
function patchBundle(source, options = {}) {
  if (source.includes(MARKER)) {
    for (const [, after] of PAIRS) unique(source, after);
  } else {
    for (const [before] of PAIRS) unique(source, before);
    for (const [before, after] of PAIRS) source = source.replace(before, () => after);
  }
  return options.finalize === false ? source : fingerprint.finalize(source).text;
}
function revertBundle(source, options = {}) {
  for (const [, after] of PAIRS) unique(source, after);
  for (const [before, after] of [...PAIRS].reverse()) source = source.replace(after, () => before);
  return options.finalize === false ? source : fingerprint.finalize(source).text;
}
if (require.main === module) {
  const file = path.join(__dirname, "..", "dist", "extension.js");
  const before = fs.readFileSync(file, "utf8"), after = patchBundle(before);
  if (before !== after) fs.writeFileSync(file, after);
  console.log(JSON.stringify({ changed: before !== after, installed: false }));
}
module.exports = { MARKER, STOP_BEFORE, STOP_AFTER, TOAST_BEFORE, TOAST_AFTER, PAIRS, patchBundle, revertBundle };
