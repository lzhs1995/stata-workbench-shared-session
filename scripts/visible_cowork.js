"use strict";
// Runtime-owned visibility and dispatch ticket. Never executes Stata itself.
const fs = require("node:fs");
const crypto = require("node:crypto");
const path = require("node:path");
const sha = data => crypto.createHash("sha256").update(data).digest("hex");
const real = p => fs.realpathSync(p);
const exact = (a, b) => { try { return real(a) === real(b); } catch { return false; } };
const fail = message => { throw new Error(message); };
// This module is SHA-bound by the runtime bundle; bind the compilation closure
// before require(), too. A changed compiler requires a new audited candidate.
const COMPILATION_PINS = Object.freeze({
  "darwin_compat_adapter.js": "9657949e13589cad804ec1d8306040dae4db49dac566bedc197285f1f48dab7f",
  "stata_source_compat_core.js": "b9414fdb2897f67b5d446ede21da3883ee63eb0bfafc766d91138252c0b7ecc7",
  "mac/png_compat_transform.js": "cdea12886a1d5bb5b4c2b3e38829de1c7e68ed70e7777e8d6e2eb02bb0ce3514",
});

function prepareSource(program, sha256, args, options = {}) {
  for (const [file, expected] of Object.entries(COMPILATION_PINS)) {
    if (sha(fs.readFileSync(path.join(__dirname, file))) !== expected) fail("compiler-pin-mismatch:" + file);
  }
  const adapter = require("./darwin_compat_adapter");
  const makeCall = file => `do "${file}"` + args.map(x => ` "${x}"`).join("");
  const original = fs.readFileSync(program);
  if (sha(original) !== sha256) fail("input-changed-before-compatibility");
  const prepared = adapter.prepareVisibleExecution(makeCall(program), options);
  const copies = prepared.sourceDiagnostics?.referencedDoCopies;
  if (prepared.darwinDiagnostics?.ok !== true || !Array.isArray(copies) || copies.length > 1) fail("unsupported-compatibility-preparation");
  let executed = program;
  if (copies.length) {
    const copy = copies[0];
    if (!exact(copy.sourcePath, program) || copy.sourceSha256 !== sha256 || copy.sourceIntact !== true) fail("compatibility-source-not-bound");
    executed = real(copy.tempPath);
  }
  const bytes = fs.readFileSync(executed);
  // Compilation only. Prove the existing adapter will not rewrite the displayed
  // file again; no Stata, keys, cancellation, or backend operation occurs here.
  const second = adapter.prepareVisibleExecution(makeCall(executed), options);
  if (second.darwinDiagnostics?.ok !== true || second.sourceDiagnostics?.referencedDoCopies?.length !== 0
      || second.code !== "set more off\n" + makeCall(executed)) fail("compatibility-source-not-stable");
  if (sha(fs.readFileSync(program)) !== sha256 || sha(fs.readFileSync(executed)) !== sha(bytes)) fail("source-changed-during-compatibility");
  return {program: executed, sha256: sha(bytes), inputProgram: program, inputSha256: sha256,
    stable: true, changed: executed !== program, sourceDiagnostics: prepared.sourceDiagnostics,
    darwinDiagnostics: prepared.darwinDiagnostics};
}

function create({vscode: v, terminal, openTerminal, cancel, current, clock = Date.now,
  sleep = ms => new Promise(resolve => setTimeout(resolve, ms))}) {
  let ticket = null, paused = false, preparing = false;
  const disposables = [];
  // Result panels may use a third group, never replace source or Terminal.
  const resultColumn = () => ticket ? 3 : null;
  globalThis.__stataCoworkResultColumn = resultColumn;
  const statusbar = v.window.createStatusBarItem(v.StatusBarAlignment.Left, 100);
  statusbar.command = "stata-workbench.coworkPause";
  disposables.push(statusbar);

  function layout(t = ticket) {
    if (!t) return {ok: false, reason: "no-task"};
    const panel = terminal();
    const editors = v.window.visibleTextEditors.filter(e => exact(e.document.uri.fsPath, t.program));
    const group = v.window.tabGroups.all.find(g => g.viewColumn === 1);
    const editor = editors[0];
    const checks = {
      windowFocused: v.window.state.focused === true,
      sourceUnique: editors.length === 1,
      sourceInLeftGroup: editor?.viewColumn === 1,
      sourceActiveTab: exact(group?.activeTab?.input?.uri?.fsPath, t.program),
      sourceSaved: editor?.document.isDirty === false,
      sourceBufferExact: !!editor && sha(Buffer.from(editor.document.getText(), "utf8")) === t.sha256,
      sourceDiskExact: sha(fs.readFileSync(t.program)) === t.sha256,
      declaredSourcesUnchanged: t.files.every(r => sha(fs.readFileSync(r.source.path)) === r.source.sha256
        && sha(fs.readFileSync(r.execution.path)) === r.execution.sha256),
      declaredSourcesSaved: !v.workspace.textDocuments.some(d => d.isDirty
        && t.files.some(r => exact(d.uri.fsPath, r.source.path) || exact(d.uri.fsPath, r.execution.path))),
      terminalVisible: panel?.visible === true,
      terminalInRightGroup: panel?.viewColumn === 2,
      terminalReady: globalThis.__codexTerminalWebviewStatus?.scriptReady === true,
      groupsDistinct: editor?.viewColumn !== panel?.viewColumn,
    };
    return {ok: Object.values(checks).every(x => x === true), checks,
      source: t.program, sha256: t.sha256, terminalViewColumn: panel?.viewColumn ?? null,
      sourceViewColumn: editor?.viewColumn ?? null, atEpochMs: clock()};
  }
  function witness(reason) {
    if (!ticket || ticket.phase !== "running") return;
    let observation;
    try { observation = layout(); } catch (e) { observation = {ok: false, error: String(e)}; }
    if (!observation.ok) ticket.visibilityInterrupted = true;
    if (ticket.events.length < 1000) ticket.events.push({reason, ...observation});
    else { ticket.evidenceOverflow = true; ticket.visibilityInterrupted = true; }
    render();
  }
  function render() {
    statusbar.text = paused ? "$(debug-pause) Stata: 后续阶段已暂停" : ticket
      ? `$(eye) Stata: ${ticket.label} · ${ticket.phase}${ticket.visibilityInterrupted ? " · 可见性中断" : ""}`
      : "$(eye) Stata: 可见协作就绪";
    statusbar.tooltip = "点击暂停后续阶段；取消当前计算请用 Stata: Cancel Current Request。"
      + (ticket ? `\n执行版本: ${ticket.program}\nSHA256: ${ticket.sha256}\n可编辑源: ${ticket.source || ticket.program}` : "");
    statusbar.show();
  }
  function snapshot() {
    return {protocol: "visible-cowork/1", paused, preparing,
      ticket: ticket && {...ticket, token: undefined}, layout: ticket ? layout() : null};
  }
  function sameBackend(s, t) {
    return Array.isArray(s.ownedBackendPids) && s.ownedBackendPids.length > 0
      && s.ownedBackendPids.every(x => Number.isInteger(x) && x > 0)
      && JSON.stringify(s.ownedBackendPids) === JSON.stringify(t.backendPids);
  }
  function idle(s) {
    return s.busy === false && s.postRunBusy === false && s.trueReady === true
      && s.recovery?.required === false;
  }
  async function prepare(p) {
    if (paused || preparing || ticket?.phase === "running") fail("paused-or-existing-operation");
    if (ticket?.phase === "prepared" && clock() - ticket.createdAt < 15000) fail("existing-unused-ticket");
    if (!idle(current())) fail("backend-not-ready");
    if (!path.isAbsolute(p.program || "") || !/^[a-f0-9]{64}$/.test(p.sha256 || "")) fail("invalid-program-identity");
    let program = real(p.program);
    if (!program.endsWith(".do") || /[\r\n\"`$]/.test(program)) fail("unsafe-program-path");
    if (!fs.statSync(program).isFile() || sha(fs.readFileSync(program)) !== p.sha256) fail("program-hash-mismatch");
    const cwd = p.cwd === undefined ? path.dirname(program) : p.cwd;
    if (typeof cwd !== "string" || !path.isAbsolute(cwd) || !fs.statSync(cwd).isDirectory()) fail("invalid-working-directory");
    const workingDirectory = real(cwd);
    const args = p.arguments || [];
    if (!Array.isArray(args) || args.some(x => typeof x !== "string" || /[\r\n\"`$]/.test(x))) fail("invalid-program-arguments");
    if (v.workspace.textDocuments.some(d => exact(d.uri.fsPath, program) && d.isDirty)) fail("unsaved-execution-document");
    // Do not silently discard a user's editable source when presenting the snapshot.
    if (p.source && v.workspace.textDocuments.some(d => exact(d.uri.fsPath, p.source) && d.isDirty)) fail("unsaved-source-document");
    const files = p.files || [{source: {path: program, sha256: p.sha256}, execution: {path: program, sha256: p.sha256}}];
    if (!Array.isArray(files) || !files.length || files.length > 1000 || files.some(r =>
      !path.isAbsolute(r?.source?.path || "") || !path.isAbsolute(r?.execution?.path || "")
      || !/^[a-f0-9]{64}$/.test(r?.source?.sha256 || "") || r.source.sha256 !== r.execution.sha256)
      || !files.some(r => exact(r.execution.path, program) && r.execution.sha256 === p.sha256)) fail("invalid-source-manifest");
    preparing = true;
    try {
      const start = current();
      if (!Array.isArray(start.ownedBackendPids) || !start.ownedBackendPids.length) fail("backend-unmeasured");
      const compilation = prepareSource(program, p.sha256, args, {platform: process.platform,
        extensionRoot: path.resolve(__dirname, ".."), cwd: workingDirectory,
        workspaceRoots: (v.workspace.workspaceFolders || []).map(f => f.uri.fsPath)});
      program = compilation.program;
      const boundFiles = files.slice();
      if (compilation.changed) boundFiles.push({source: {path: program, sha256: compilation.sha256},
        execution: {path: program, sha256: compilation.sha256}});
      await v.commands.executeCommand("vscode.setEditorLayout", {orientation: 0, groups: [{size: 0.5}, {size: 0.5}]});
      const document = await v.workspace.openTextDocument(v.Uri.file(program));
      await v.window.showTextDocument(document, {viewColumn: 1, preview: false, preserveFocus: false});
      if (!terminal()) await openTerminal();
      const panel = terminal();
      if (!panel) fail("real-stata-terminal-missing");
      panel.reveal(2, true);
      await v.window.showTextDocument(document, {viewColumn: 1, preview: false, preserveFocus: false});
      // Renderer readiness is asynchronous. This bounded read-only preparation
      // wait occurs before the 15-second ticket is minted, never during Stata.
      for (let i = 0; i < 50 && globalThis.__codexTerminalWebviewStatus?.scriptReady !== true; i++) {
        if (paused) fail("paused-during-layout");
        await sleep(100);
      }
      const candidate = {token: crypto.randomBytes(24).toString("hex"), phase: "prepared", program,
        source: p.source || null, sha256: compilation.sha256, files: boundFiles, sourceCompilation: compilation,
        inputProgram: compilation.inputProgram, inputSha256: compilation.inputSha256,
        arguments: args, cwd: workingDirectory, task: String(p.task || "single-file"),
        label: String(p.label || path.basename(program)).slice(0, 160), createdAt: clock(),
        previousRunId: start.runId, backendPids: start.ownedBackendPids,
        visibilityInterrupted: false, evidenceOverflow: false, events: []};
      if (paused || !idle(current()) || !sameBackend(current(), candidate) || current().runId !== start.runId) fail("state-changed-during-layout");
      const measured = layout(candidate);
      if (!measured.ok) fail("visible-layout-not-established:" + JSON.stringify(measured.checks));
      candidate.events.push({reason: "prepared", ...measured});
      ticket = candidate; render();
      return {...snapshot(), token: ticket.token};
    } finally { preparing = false; }
  }
  function consume(p) {
    if (!p.coworkToken) return; // Legacy callers get no co-working certification.
    if (paused || !ticket || ticket.token !== p.coworkToken || ticket.phase !== "prepared") fail("invalid-or-used-ticket");
    const age = clock() - ticket.createdAt;
    if (!(age >= 0 && age < 15000)) fail("expired-ticket");
    const now = current();
    if (!idle(now) || !sameBackend(now, ticket) || now.runId !== ticket.previousRunId) fail("human-or-agent-run-intervened");
    if (typeof p.cwd !== "string" || !path.isAbsolute(p.cwd) || !exact(p.cwd, ticket.cwd)) fail("working-directory-not-bound");
    // No awaits from this final measurement to existing run-command admission.
    const measured = layout();
    if (!measured.ok) fail("visibility-or-source-changed-before-dispatch");
    const expected = `do "${ticket.program}"` + ticket.arguments.map(x => ` "${x}"`).join("");
    if (p.code !== 'display as text "' + p.coworkMarker + 'START"\n' + expected + "\n#delimit cr\ndisplay as text \"" + p.coworkMarker + "\"\n"
        || !/^___VERIFIED_CLIENT_[a-f0-9]{32}___$/.test(p.coworkMarker || "")) fail("dispatch-bytes-not-bound");
    ticket.phase = "running"; ticket.startedAt = clock();
    ticket.events.push({reason: "dispatch", ...measured}); render();
  }
  async function control(p) {
    if (p.action === "pause") paused = true;
    else if (p.action === "resume") {
      if (!idle(current())) fail("resume-requires-settled-backend");
      paused = false; // A fresh prepare is still required; no old ticket is revived.
      if (ticket?.phase === "prepared") ticket.phase = "invalidated";
    } else if (p.action === "cancel") { paused = true; await cancel(); }
    else fail("unknown-control-action");
    render(); return snapshot();
  }
  function finish(p) {
    if (!ticket || p.token !== ticket.token || ticket.phase !== "running") fail("finish-not-bound");
    if (!idle(current())) fail("finish-requires-settled-backend; continuing-visibility-watch");
    witness("finish"); ticket.phase = "finished"; ticket.finishedAt = clock();
    // Client separately binds the Stata execution result. Visibility alone cannot certify rc.
    ticket.visibilityVerdict = ticket.visibilityInterrupted || ticket.evidenceOverflow ? "INTERRUPTED" : "OBSERVED_VISIBLE";
    if (ticket.visibilityInterrupted) paused = true;
    render(); return snapshot();
  }
  for (const [obj, event] of [[v.window, "onDidChangeWindowState"], [v.window, "onDidChangeVisibleTextEditors"],
    [v.window.tabGroups, "onDidChangeTabGroups"], [v.window.tabGroups, "onDidChangeTabs"],
    [v.workspace, "onDidChangeTextDocument"]]) {
    disposables.push(obj[event](() => witness(event)));
  }
  for (const [name, action] of [["coworkPause", "pause"], ["coworkResume", "resume"], ["coworkCancel", "cancel"]]) {
    disposables.push(v.commands.registerCommand("stata-workbench." + name, () => control({action})));
  }
  disposables.push(v.commands.registerCommand("stata-workbench.coworkStart", async () => {
    const editor = v.window.activeTextEditor;
    if (!editor || editor.document.isDirty) fail("save-an-active-do-file-first");
    return prepare({program: editor.document.uri.fsPath, sha256: sha(fs.readFileSync(editor.document.uri.fsPath))});
  }));
  render();
  async function handle(req, res, send) {
    if (!req.url?.startsWith("/cowork/")) return false;
    try {
      if (req.headers.origin) fail("browser-origin-not-allowed");
      if (req.method === "GET" && req.url === "/cowork/status") { send(res, 200, snapshot()); return true; }
      if (req.method !== "POST") fail("unsupported-method");
      const chunks = []; let bytes = 0;
      for await (const chunk of req) { bytes += chunk.length; if (bytes > 65536) fail("body-too-large"); chunks.push(chunk); }
      const p = JSON.parse(Buffer.concat(chunks).toString("utf8"));
      const value = req.url === "/cowork/prepare" ? await prepare(p) : req.url === "/cowork/control"
        ? await control(p) : req.url === "/cowork/finish" ? finish(p) : fail("unknown-cowork-route");
      send(res, 200, {ok: true, ...value});
    } catch (e) { send(res, 409, {ok: false, error: String(e.message || e), zeroStataDispatch: true}); }
    return true;
  }
  return {prepare, consume, control, finish, snapshot, handle, dispose() {
    if (globalThis.__stataCoworkResultColumn === resultColumn) delete globalThis.__stataCoworkResultColumn;
    for (const d of disposables) d.dispose();
  }};
}
module.exports = {create, sha, prepareSource};
