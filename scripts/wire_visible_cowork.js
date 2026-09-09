"use strict";
// Three unique audited seams; no heuristic global replacement of minified code.
const fs = require("node:fs"), path = require("node:path"), crypto = require("node:crypto");
const root = path.resolve(__dirname, "..");
const {finalize} = require("./finalize_bundle_identity");
const hash = p => crypto.createHash("sha256").update(fs.readFileSync(p)).digest("hex");
const marker = "/* visible-cowork-v1 */";
function wire(source, moduleSha) {
  let result = source;
  if (source.includes(marker)) {
    const slots = source.match(/__coworkModuleSha="[a-f0-9]{64}"/g) || [];
    if (slots.length !== 1) throw new Error("missing or nonunique module pin slot");
    result = source.replace(slots[0], `__coworkModuleSha="${moduleSha}"`);
  }
  const seams = source.includes(marker) ? [] : [
    ['let __srv=__http.createServer((__req,__res)=>{(async()=>{try{',
      `const __coworkModuleSha="${moduleSha}";const __coworkPath=require("path").join(__dirname,"../scripts/visible_cowork.js");if(require("crypto").createHash("sha256").update(require("fs").readFileSync(__coworkPath)).digest("hex")!==__coworkModuleSha)throw new Error("visible-cowork-module-identity-mismatch");const __cowork=require(__coworkPath).create({vscode:iA,terminal:()=>Gg.currentPanel,openTerminal:VHg,cancel:yM,current:__current});g.subscriptions.push(__cowork);${marker}let __srv=__http.createServer((__req,__res)=>{(async()=>{try{if(await __cowork.handle(__req,__res,__send))return;`],
    ['let __p=JSON.parse(__body||"{}"),__code=String(__p.code||""),',
      'let __p=JSON.parse(__body||"{}");try{__cowork.consume(__p)}catch(__coworkError){__send(__res,409,{ok:false,error:String(__coworkError.message),zeroStataDispatch:true,gate:"visible-cowork"});return}let __code=String(__p.code||""),'],
  ];
  if (!source.includes("/* visible-cowork-result-columns */")) seams.push(
    ['function __codexGraphTargetColumn() {',
      'function __codexGraphTargetColumn() {/* visible-cowork-result-columns */\n  const coworkColumn = globalThis.__stataCoworkResultColumn?.();\n  if (coworkColumn) return coworkColumn;'],
    ['static async createOrShow(A){let I=Ut.ViewColumn.Beside;if(g.currentPanel){let B=g.currentPanel._panel.viewColumn||Ut.ViewColumn.Beside;',
      'static async createOrShow(A){let I=globalThis.__stataCoworkResultColumn?.()||Ut.ViewColumn.Beside;if(g.currentPanel){let B=globalThis.__stataCoworkResultColumn?.()||g.currentPanel._panel.viewColumn||Ut.ViewColumn.Beside;']
  );
  for (const [from, to] of seams) {
    if (result.split(from).length !== 2) throw new Error("nonunique or absent bridge seam");
    result = result.replace(from, to);
  }
  return result;
}
if (require.main === module) {
  const file = path.join(root, "dist/extension.js");
  const source = fs.readFileSync(file, "utf8");
  const next = finalize(wire(source, hash(path.join(__dirname, "visible_cowork.js")))).text;
  if (process.argv.includes("--check")) {
    if (next !== source) throw new Error("co-working wiring/finalization missing");
  } else if (next !== source) fs.writeFileSync(file, next);
  console.log("VISIBLE_COWORK_WIRING_OK " + hash(file));
}
module.exports = {wire};
