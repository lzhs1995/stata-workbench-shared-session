"use strict";

// Offline platform adapter only: the production adapter and core execute unchanged
// in private CommonJS contexts. node:path.win32 resolves Windows paths; real fs
// operations target per-case local fixtures. No VS Code/Windows endpoint is used.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");
const { test } = require("node:test");
const { EventEmitter } = require("node:events");
const sourceRoot = path.resolve(process.env.DOCUMENT_CASE_SOURCE || __dirname);
const fixtureRoot = process.env.DOCUMENT_CASE_FIXTURES
  ? path.resolve(process.env.DOCUMENT_CASE_FIXTURES)
  : fs.mkdtempSync(path.join(require("node:os").tmpdir(), "wb-document-case-"));
if (!process.env.DOCUMENT_CASE_FIXTURES)
  require("node:test").after(() => fs.rmSync(fixtureRoot, { recursive: true, force: true }));
fs.mkdirSync(fixtureRoot, { recursive: true });

function fixture(platform = "win32", documentPath) {
  const root = fs.mkdtempSync(path.join(fixtureRoot, platform + "-"));
  const win = platform === "win32", paths = win ? path.win32 : path.posix;
  const logicalRoot = win ? "C:\\workspace" : path.join(root, "workspace");
  const file = paths.join(logicalRoot, "source.do");
  function physical(value) {
    if (typeof value !== "string" || !win) return value;
    const normalized = paths.resolve(value), match = /^([A-Za-z]):\\(.*)$/.exec(normalized);
    assert.ok(match, "test filesystem requires an absolute drive path");
    return path.join(root, match[1].toLowerCase(), ...match[2].split("\\"));
  }
  function logical(value) {
    if (!win) return value;
    const parts = path.relative(root, value).split(path.sep);
    const drive = parts.shift();
    assert.match(drive, /^[a-z]$/);
    return drive.toUpperCase() + ":\\" + parts.join("\\");
  }
  const fsAdapter = Object.create(fs);
  for (const name of ["readFileSync", "writeFileSync", "openSync", "mkdirSync", "statSync", "lstatSync", "existsSync", "unlinkSync"])
    fsAdapter[name] = (first, ...rest) => fs[name](physical(first), ...rest);
  fsAdapter.renameSync = (from, to) => fs.renameSync(physical(from), physical(to));
  fsAdapter.realpathSync = value => logical(fs.realpathSync(physical(value)));
  fs.mkdirSync(physical(logicalRoot), { recursive: true });
  const before = "display 240\n", content = "display 8\n";
  fs.writeFileSync(physical(file), before);
  const cache = new Map();
  function load(name) {
    if (cache.has(name)) return cache.get(name).exports;
    const filename = path.join(sourceRoot, name + ".js");
    const mod = { exports: {} }; cache.set(name, mod);
    const context = vm.createContext({ module: mod, exports: mod.exports, Buffer,
      AbortController, setTimeout, clearTimeout, process: Object.freeze({ platform }),
      require(id) {
        if (id === "node:fs") return fsAdapter;
        if (id === "node:path") return paths;
        if (id === "node:crypto") return require(id);
        if (id === "./edit_proposal_core") return load("edit_proposal_core");
        throw new Error("Unexpected dependency: " + id);
      } });
    new vm.Script(fs.readFileSync(filename, "utf8"), { filename }).runInContext(context);
    return mod.exports;
  }
  const identity = { sessionId: "session-one", generation: 0, closing: false };
  const doc = { uri: { scheme: "file", fsPath: documentPath || file },
    isClosed: false, isDirty: false, version: 1 };
  const workspace = { textDocuments: [doc], workspaceFolders: [{ uri: { scheme: "file", fsPath: logicalRoot } }],
    registerTextDocumentContentProvider() { return { dispose() {} }; },
    async openTextDocument() { return workspace.textDocuments[0]; } };
  let uiCalls = 0;
  const vscode = { workspace, Uri: { file: fsPath => ({ scheme: "file", fsPath }), parse: value => ({ toString: () => value }) },
    commands: { executeCommand() { uiCalls++; throw new Error("UI forbidden in offline test"); } },
    window: { showInformationMessage() { uiCalls++; throw new Error("UI forbidden in offline test"); } } };
  const api = load("agent_edit_vscode").createAgentApi(vscode, {
    identity: () => identity, current: () => ({}),
    snapshotRoot: win ? "C:\\snapshots" : path.join(root, "snapshots") });
  const core = load("edit_proposal_core");
  const request = { proposalId: "case", path: file, expectedSha256: core.sha256(before),
    content, documentVersion: 1, sessionId: identity.sessionId, generation: 0 };
  return { root, file, physical, logicalRoot, paths, before, content, doc, workspace,
    identity, api, core, request, uiCalls: () => uiCalls };
}

async function rejection(f, mutate, reason, afterBaseline = false) {
  if (!afterBaseline) mutate();
  const result = await f.api.gate.propose(f.request, async () => {
    if (afterBaseline) mutate();
    return { status: "accepted" };
  });
  assert.equal(result.status, "rejected");
  assert.equal(result.reasonCode, reason);
  assert.equal(fs.readFileSync(f.physical(f.file), "utf8"), f.before);
  assert.equal(f.uiCalls(), 0);
}

test("Windows uppercase request and lowercase document drive use actual adapter and core", async () => {
  const f = fixture("win32", "c:\\workspace\\source.do");
  const result = await f.api.documentState(f.request);
  assert.equal(result.sha256, f.request.expectedSha256);
  assert.equal(result.documentVersion, 1);
  assert.equal(result.dirty, false);
  const accepted = await f.api.gate.propose(f.request, async () => ({ status: "accepted" }));
  assert.equal(accepted.status, "accepted");
  assert.equal(accepted.finalSha256, f.core.sha256(f.content));
  assert.equal(fs.readFileSync(f.physical(f.file), "utf8"), f.content);
  assert.equal(f.uiCalls(), 0);
});

test("Windows lowercase request and uppercase document drive match", async () => {
  const f = fixture(); f.request.path = "c:\\workspace\\source.do";
  assert.equal((await f.api.documentState(f.request)).sha256, f.request.expectedSha256);
});

test("Windows forward slash absolute request resolves before drive matching", async () => {
  const f = fixture("win32", "c:\\workspace\\source.do"); f.request.path = "C:/workspace/source.do";
  assert.equal((await f.api.documentState(f.request)).documentVersion, 1);
});

test("Windows different file and drive do not match", () => {
  const f = fixture();
  assert.throws(() => f.api.inspect("C:\\workspace\\other.do"), /EDITOR_DOCUMENT_UNAVAILABLE/);
  assert.throws(() => f.api.inspect("D:\\workspace\\source.do"), /EDITOR_DOCUMENT_UNAVAILABLE/);
});

test("Windows remaining component casing is not merged", () => {
  const f = fixture();
  assert.throws(() => f.api.inspect("C:\\workspace\\SOURCE.do"), /EDITOR_DOCUMENT_UNAVAILABLE/);
  assert.throws(() => f.api.inspect("C:\\Workspace\\source.do"), /EDITOR_DOCUMENT_UNAVAILABLE/);
});

test("Windows drive-relative requests are refused by original public gate", async () => {
  const f = fixture(); f.request.path = "C:source.do";
  await assert.rejects(f.api.documentState(f.request), /absolute Stata source path required/);
  assert.throws(() => f.api.gate.submit(f.request, () => ({ status: "accepted" })), /absolute .do, .ado or .mata path required/);
});

test("POSIX exact path still works; distinct casing is refused", async () => {
  const f = fixture("linux");
  assert.equal((await f.api.documentState(f.request)).sha256, f.request.expectedSha256);
  assert.throws(() => f.api.inspect(f.file.replace("source.do", "SOURCE.do")), /EDITOR_DOCUMENT_UNAVAILABLE/);
});

test("Darwin also preserves case-sensitive document identity", () => {
  const f = fixture("darwin");
  assert.equal(f.api.inspect(f.file).version, 1);
  assert.throws(() => f.api.inspect(f.file.replace("source.do", "SOURCE.do")), /EDITOR_DOCUMENT_UNAVAILABLE/);
});

test("Closed and non-file documents remain unavailable", () => {
  const f = fixture(); f.doc.isClosed = true;
  assert.throws(() => f.api.inspect(f.file), /EDITOR_DOCUMENT_UNAVAILABLE/);
  f.doc.isClosed = false; f.doc.uri.scheme = "untitled";
  assert.throws(() => f.api.inspect(f.file), /EDITOR_DOCUMENT_UNAVAILABLE/);
});

test("Original dirty guard rejects before writing", async () => {
  const f = fixture(); await rejection(f, () => { f.doc.isDirty = true; }, "DIRTY_DOCUMENT");
});

test("Original version guard rejects before writing", async () => {
  const f = fixture(); await rejection(f, () => { f.doc.version = 2; }, "DOCUMENT_VERSION_CHANGED");
});

test("Original session generation and closing guards reject", async () => {
  for (const update of [{ sessionId: "foreign" }, { generation: 1 }, { closing: true }]) {
    const f = fixture(); await rejection(f, () => Object.assign(f.identity, update), "SESSION_CHANGED");
  }
});

test("Original SHA guard rejects changed expected content", async () => {
  const f = fixture(); await rejection(f, () => { f.request.expectedSha256 = "0".repeat(64); }, "SHA_MISMATCH");
});

test("Editor entity replacement after review remains rejected", async () => {
  const f = fixture(); await rejection(f, () => { f.workspace.textDocuments = [{ ...f.doc }]; }, "TARGET_IDENTITY_CHANGED", true);
});

test("Same-byte filesystem entity replacement remains rejected", async () => {
  const f = fixture(); await rejection(f, () => {
    fs.renameSync(f.physical(f.file), f.physical(f.file) + ".original");
    fs.writeFileSync(f.physical(f.file), f.before);
  }, "TARGET_IDENTITY_CHANGED", true);
});

test("Workspace escape and link-to-outside remain rejected", async () => {
  const f = fixture(); const outside = f.paths.join(f.paths.dirname(f.logicalRoot), "outside.do");
  fs.writeFileSync(f.physical(outside), f.before);
  await assert.rejects(f.api.documentState({ ...f.request, path: outside }), /OUTSIDE_WORKSPACE/);
  fs.renameSync(f.physical(f.file), f.physical(f.file) + ".original");
  fs.symlinkSync(f.physical(outside), f.physical(f.file));
  await assert.rejects(f.api.documentState(f.request), /OUTSIDE_WORKSPACE/);
});

test("Original hardlink guard rejects nlink greater than one", async () => {
  const f = fixture(); await rejection(f, () => fs.linkSync(f.physical(f.file), f.physical(f.file) + ".alias"), "UNSAFE_TARGET");
});

test("Public document-state route returns HTTP200 for mismatched drive case", async () => {
  const f = fixture("win32", "c:\\workspace\\source.do");
  const req = new EventEmitter(); req.method = "POST"; req.url = "/document-state";
  const result = new Promise(resolve => {
    assert.equal(f.api.route(req, {}, (_res, status, body) => resolve({ status, body })), true);
  });
  req.emit("data", Buffer.from(JSON.stringify(f.request))); req.emit("end");
  const response = await result;
  assert.equal(response.status, 200);
  assert.equal(response.body.document.sha256, f.request.expectedSha256);
  assert.equal(f.uiCalls(), 0);
});
