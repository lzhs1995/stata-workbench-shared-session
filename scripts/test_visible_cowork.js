"use strict";
const {test} = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs"), os = require("node:os"), path = require("node:path");
const {create, sha, prepareSource} = require("./visible_cowork");

function fixture(t) {
  const root = fs.realpathSync(fs.mkdtempSync(path.join(os.tmpdir(), "stata-cowork-test-")));
  t.after(() => fs.rmSync(root, {recursive: true, force: true}));
  const program = path.join(root, "program.do"), raw = "display 42\n";
  fs.writeFileSync(program, raw);
  const listeners = {}, commands = {};
  const on = name => fn => { listeners[name] = fn; return {dispose() {}}; };
  const doc = {uri: {fsPath: program}, isDirty: false, getText: () => raw};
  const editor = {document: doc, viewColumn: 1};
  const group = {viewColumn: 1, activeTab: {input: {uri: doc.uri}}};
  const panel = {visible: true, viewColumn: 2, reveal(col) { this.viewColumn = col; }};
  const state = {busy: false, postRunBusy: false, trueReady: true, recovery: {required: false}, ownedBackendPids: [9], runId: "old"};
  let at = 100, canceled = 0;
  const v = {StatusBarAlignment: {Left: 1}, Uri: {file: p => ({fsPath: p})},
    commands: {executeCommand: async () => {}, registerCommand(n, f) {commands[n] = f; return {dispose() {}};}},
    workspace: {textDocuments: [doc], openTextDocument: async () => doc, onDidChangeTextDocument: on("edit")},
    window: {state: {focused: true}, visibleTextEditors: [editor], activeTextEditor: editor,
      showTextDocument: async () => editor, createStatusBarItem: () => ({show() {}, dispose() {}}),
      onDidChangeWindowState: on("window"), onDidChangeVisibleTextEditors: on("visible"),
      tabGroups: {all: [group, {viewColumn: 2}], onDidChangeTabs: on("tabs"), onDidChangeTabGroups: on("groups")}}};
  globalThis.__codexTerminalWebviewStatus = {scriptReady: true};
  const service = create({vscode: v, terminal: () => panel, openTerminal: async () => {},
    cancel: async () => { canceled++; }, current: () => state, clock: () => at, sleep: async () => {}});
  const prepare = () => service.prepare({program, sha256: sha(raw), task: "test", label: "stage1"});
  const payload = token => {const marker = "___VERIFIED_CLIENT_" + "a".repeat(32) + "___";
    return {coworkToken: token, coworkMarker: marker, cwd: root, code: `display as text "${marker}START"\ndo "${program}"\n#delimit cr\ndisplay as text "${marker}"\n`};};
  return {service, prepare, payload, program, raw, state, doc, editor, group, panel, v, listeners,
    setTime: x => at = x, canceled: () => canceled, commands};
}
test("real split, exact bytes, one-use ticket, separated visibility result", async t => {
  const f = fixture(t), p = await f.prepare();
  assert.equal(p.layout.ok, true);
  f.service.consume(f.payload(p.token));
  assert.throws(() => f.service.consume(f.payload(p.token)), /used-ticket/);
  const end = f.service.finish({token: p.token});
  assert.equal(end.ticket.visibilityVerdict, "OBSERVED_VISIBLE");
  assert.equal(end.ticket.executionVerdict, undefined);
  assert.equal(end.ticket.events.length, 3);
});
test("same-group tabs, wrong active file, hidden terminal, nonready webview reject", async t => {
  for (const mutate of [f => {f.panel.reveal = () => {f.panel.viewColumn = 1;};},
    f => {f.group.activeTab.input.uri.fsPath = "/missing";}, f => {f.panel.visible = false;},
    () => {globalThis.__codexTerminalWebviewStatus.scriptReady = false;}]) {
    const f = fixture(t); mutate(f);
    await assert.rejects(f.prepare(), /visible-layout-not-established/);
  }
});
test("dirty source and changed disk fail before Stata", async t => {
  const f = fixture(t); f.doc.isDirty = true;
  await assert.rejects(f.prepare(), /unsaved/);
  f.doc.isDirty = false;
  const p = await f.prepare(); fs.writeFileSync(f.program, "display 99\n");
  assert.throws(() => f.service.consume(f.payload(p.token)), /source-changed/);
});
test("human run or changed backend invalidates pending ticket", async t => {
  for (const mutate of [f => {f.state.runId = "human-run";}, f => {f.state.ownedBackendPids = [10];},
    f => {f.state.busy = true;}]) {
    const f = fixture(t), p = await f.prepare(); mutate(f);
    assert.throws(() => f.service.consume(f.payload(p.token)), /intervened/);
  }
});
test("cwd substitution and unsaved author edits invalidate execution", async t => {
  const f = fixture(t), p = await f.prepare();
  assert.throws(() => f.service.consume({...f.payload(p.token), cwd: os.tmpdir()}), /directory-not-bound/);
  assert.throws(() => f.service.consume({...f.payload(p.token), cwd: undefined}), /directory-not-bound/);
  f.v.workspace.textDocuments.push({uri: {fsPath:f.program}, isDirty:true});
  assert.throws(() => f.service.consume(f.payload(p.token)), /source-changed/);
});
test("TTL both directions and mismatched code reject", async t => {
  for (const at of [99, 15100]) {
    const f = fixture(t), p = await f.prepare(); f.setTime(at);
    assert.throws(() => f.service.consume(f.payload(p.token)), /expired/);
  }
  const f = fixture(t), p = await f.prepare();
  assert.throws(() => f.service.consume({...f.payload(p.token), code: "clear all"}), /not-bound/);
});
test("visibility loss is sticky; restoration cannot certify history", async t => {
  const f = fixture(t), p = await f.prepare(); f.service.consume(f.payload(p.token));
  f.v.window.state.focused = false; f.listeners.window();
  f.v.window.state.focused = true; f.listeners.window();
  const end = f.service.finish({token: p.token});
  assert.equal(end.ticket.visibilityVerdict, "INTERRUPTED"); assert.equal(end.paused, true);
  assert.equal(f.canceled(), 0);
  await assert.rejects(f.prepare(), /paused/);
});
test("pause affects later stages, cancel alone requests product stop", async t => {
  const f = fixture(t), p = await f.prepare();
  await f.service.control({action: "pause"});
  assert.throws(() => f.service.consume(f.payload(p.token)), /invalid/);
  assert.equal(f.canceled(), 0);
  await f.service.control({action: "resume"});
  assert.throws(() => f.service.consume(f.payload(p.token)), /used/);
  await f.service.control({action: "cancel"}); assert.equal(f.canceled(), 1);
});
test("prepare cannot replace pending or running operation", async t => {
  const f = fixture(t), p = await f.prepare();
  await assert.rejects(f.prepare(), /existing-unused-ticket/);
  f.service.consume(f.payload(p.token)); f.setTime(20000);
  await assert.rejects(f.prepare(), /existing-operation/);
});
test("real Darwin compiler prepares stable named-log bytes without Stata", async t => {
  const f = fixture(t), raw = "version 19\ntempname ownlog\nlog using test.log, text name(`ownlog')\nlog close `ownlog'\n";
  fs.writeFileSync(f.program, raw);
  const result = prepareSource(f.program, sha(raw), [], {platform:"darwin", cwd:path.dirname(f.program), tempRoot:path.dirname(f.program)});
  assert.equal(result.changed, true); assert.equal(result.stable, true);
  assert.equal(fs.readFileSync(f.program,"utf8"),raw);
  assert.notEqual(result.sha256,sha(raw));
  assert.equal(result.sha256,sha(fs.readFileSync(result.program)));
  const again=prepareSource(result.program,result.sha256,[],{platform:"darwin",cwd:path.dirname(f.program),tempRoot:path.dirname(f.program)});
  assert.equal(again.changed,false); assert.equal(again.program,result.program);
  assert.equal(f.canceled(),0);
});
test("compiled version, not author input, is displayed and ticket-consumed", async t => {
  const f=fixture(t), raw="tempname ownlog\nlog using test.log, text name(`ownlog')\n";
  fs.writeFileSync(f.program,raw);
  f.v.workspace.openTextDocument=async uri => ({uri,isDirty:false,getText:()=>fs.readFileSync(uri.fsPath,"utf8")});
  f.v.window.showTextDocument=async doc => {
    f.v.window.visibleTextEditors=[{document:doc,viewColumn:1}];
    f.group.activeTab.input.uri=doc.uri;
    return f.v.window.visibleTextEditors[0];
  };
  const p=await f.service.prepare({program:f.program,sha256:sha(raw)});
  if(p.ticket.program!==f.program) {
    const generated=path.dirname(p.ticket.program);
    assert.ok(path.basename(generated).startsWith("stata-workbench-compat-"));
    t.after(()=>fs.rmSync(generated,{recursive:true,force:true}));
  }
  assert.equal(p.layout.ok,true); assert.equal(p.ticket.inputSha256,sha(raw));
  const wire=f.payload(p.token);
  wire.code=wire.code.replace(f.program,p.ticket.program);
  f.service.consume(wire);
  assert.equal(f.service.finish({token:p.token}).ticket.visibilityVerdict,"OBSERVED_VISIBLE");
});
