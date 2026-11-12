"use strict";

// Apply after the maintained compatibility/finalizer layers (and daily window
// patches). Pure patch/revert functions let root integrate without touching a
// live installation or editing somebody else's replay list.
const fs = require("node:fs");
const path = require("node:path");
const fingerprint = require("./finalize_bundle_identity");
const MARKER = "/* Workbench: explicit source path mappings */";
const OPTIONS = 'sourcePath:__meta.sourcePath,workspaceRoots:(iA.workspace.workspaceFolders||[]).map(__folder=>__folder?.uri?.fsPath).filter(Boolean)});globalThis.__codexLastSourceCompat=';
const MAPPED_OPTIONS = 'sourcePath:__meta.sourcePath,sourcePathMappings:iA.workspace.getConfiguration("stataMcp",__meta.sourcePath?FHg().Uri.file(__meta.sourcePath):undefined).get("sourcePathMappings",[]),workspaceRoots:(iA.workspace.workspaceFolders||[]).map(__folder=>__folder?.uri?.fsPath).filter(Boolean)});globalThis.__codexLastSourceCompat=';
const CATCH = 'if(process.platform==="darwin"){globalThis.__codexLastDarwinCompatibility={ok:false,applied:true,error:__message';
const MAPPED_CATCH = 'if(process.platform==="darwin"||__compatError?.code==="SOURCE_PATH_MAPPINGS_INVALID"||__compatError?.code==="SOURCE_PATH_MAPPING_PREPARATION_FAILED"){globalThis.__codexLastDarwinCompatibility={ok:false,applied:true,error:__message';
const AGENT_META = '__code,{sourceMode:__source,runId:__runId,cwd:__cwd}';
const MAPPED_AGENT_META = '__code,{sourceMode:__source,runId:__runId,cwd:__cwd,sourcePath:__p.agentWorkflow?.sourcePath}';
const PAIRS = [[OPTIONS, MAPPED_OPTIONS], [CATCH, MAPPED_CATCH], [AGENT_META, MAPPED_AGENT_META]];

function once(source, before, after) {
  if (source.split(before).length !== 2) throw new Error("missing or ambiguous source-path mapping anchor: " + before.slice(0, 100));
  return source.replace(before, () => after);
}
function patchBundle(source, options = {}) {
  if (source.includes(MARKER)) {
    if (!PAIRS.every(([, after]) => source.includes(after))) throw new Error("partial source-path mapping patch");
  } else {
    for (const [before, after] of PAIRS) source = once(source, before, after);
    source += "\n" + MARKER + "\n";
  }
  return options.finalize === false ? source : fingerprint.finalize(source).text;
}
function revertBundle(source, options = {}) {
  source = once(source, "\n" + MARKER + "\n", "");
  for (const [before, after] of [...PAIRS].reverse()) source = once(source, after, before);
  return options.finalize === false ? source : fingerprint.finalize(source).text;
}
if (require.main === module) {
  const target = path.join(__dirname, "..", "dist", "extension.js");
  const before = fs.readFileSync(target, "utf8"), after = patchBundle(before);
  if (after !== before) fs.writeFileSync(target, after);
  console.log(JSON.stringify({ changed: before !== after, target, installed: false }));
}
module.exports = { patchBundle, revertBundle, MARKER };
