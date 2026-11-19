"use strict";
const test = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const vm = require("node:vm");
const { createRequire } = require("node:module");
const { EventEmitter } = require("node:events");

// Run the real route and its edit gate with Windows path semantics. Only disk I/O
// for the one synthetic workspace maps onto the host's temporary directory.
function fixture(t, windows) {
  const disk = fs.realpathSync(fs.mkdtempSync(path.join(os.tmpdir(), "wb-drive-")));
  t.after(() => fs.rmSync(disk, { recursive: true, force: true }));
  const paths = windows ? path.win32 : path.posix;
  const root = windows ? "c:\\Work" : disk;
  const file = paths.join(root, "sample.do");
  const requested = windows ? file.replace(/^c:/, "C:") : file;
  fs.writeFileSync(path.join(disk, "sample.do"), "display 1\n");
  const fsAdapter = Object.create(fs);
  const local = name => windows && typeof name === "string" ? path.join(disk, paths.relative(root, name)) : name;
  for (const key of ["readFileSync", "statSync"]) fsAdapter[key] = name => fs[key](local(name));
  fsAdapter.realpathSync = name => {
    fs.realpathSync(local(name));
    return name;
  };
  const cache = new Map();
  function load(name) {
    if (cache.has(name)) return cache.get(name);
    const filename = path.join(process.env.WB_TEST_SOURCE || __dirname, name + ".js");
    const module = { exports: {} };
    const ordinary = createRequire(filename);
    function substitute(id) {
      if (id === "node:path") return paths;
      if (id === "node:fs") return fsAdapter;
      if (id === "./edit_proposal_core") return load("edit_proposal_core");
      return ordinary(id);
    }
    const context = { require: substitute, module, process: { platform: windows ? "win32" : "darwin" }, Buffer };
    vm.runInNewContext(fs.readFileSync(filename, "utf8"), context, { filename });
    cache.set(name, module.exports);
    return module.exports;
  }
  const doc = { uri: { scheme: "file", fsPath: file }, isDirty: false, version: 7 };
  const workspace = { textDocuments: [doc], workspaceFolders: [{ uri: { scheme: "file", fsPath: root } }],
    registerTextDocumentContentProvider: () => ({ dispose() {} }), openTextDocument: async () => doc };
  const api = load("agent_edit_vscode").createAgentApi({ workspace, Uri: { file: fsPath => ({ scheme: "file", fsPath }) } },
    { snapshotRoot: disk, identity: () => ({ sessionId: "test", generation: 0 }) });
  const state = p => new Promise(resolve => {
    const req = Object.assign(new EventEmitter(), { method: "POST", url: "/document-state" });
    api.route(req, {}, (_, code, value) => resolve({ code, ...value }));
    req.emit("data", Buffer.from(JSON.stringify({ path: p, generation: 0, sessionId: "test" })));
    req.emit("end");
  });
  return { api, state, file, requested, workspace, doc };
}


test("Windows lookup refuses ambiguous clean and dirty document aliases", async t => {
  for (const alias of ["same path", "drive alias"]) {
    for (const dirtyFirst of [false, true]) {
      await t.test(alias + ": dirty " + (dirtyFirst ? "first" : "last"), async t => {
        const f = fixture(t, true);
        const other = { ...f.doc, isDirty: true,
          uri: { scheme: "file", fsPath: alias === "same path" ? f.file : f.requested } };
        f.workspace.textDocuments = dirtyFirst ? [other, f.doc] : [f.doc, other];
        const request = { path: f.requested, sessionId: "test", generation: 0,
          documentVersion: 7, expectedSha256: require("node:crypto").createHash("sha256").update("display 1\n").digest("hex") };
        assert.throws(() => f.api.gate.inspect(request), /EDITOR_DOCUMENT_UNAVAILABLE/);
        assert.equal((await f.state(f.requested)).code, 409);
      });
    }
  }
});

test("Windows lookup keeps distinct component casing separate with two open documents", t => {
  const f = fixture(t, true);
  const other = f.file.replace("sample.do", "Sample.do");
  f.workspace.textDocuments.push({ ...f.doc, isDirty: true,
    uri: { scheme: "file", fsPath: other } });
  assert.equal(f.api.inspect(f.requested).dirty, false);
  assert.equal(f.api.inspect(other).dirty, true);
  assert.notEqual(f.api.inspect(f.requested).documentId, f.api.inspect(other).documentId);
});
