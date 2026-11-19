"use strict";
const test = require("node:test"), assert = require("node:assert/strict");
const fs = require("node:fs"), os = require("node:os"), path = require("node:path"), { EventEmitter } = require("node:events");
const { createAgentApi } = require("./agent_edit_vscode");

function fixture(t) {
  const root = fs.realpathSync(fs.mkdtempSync(path.join(os.tmpdir(), "wb-editor-")));
  t.after(() => fs.rmSync(root, { recursive: true, force: true }));
  const file = path.join(root, "analysis.do"); fs.writeFileSync(file, "display 1\n");
  const uri = { scheme: "file", fsPath: file };
  const doc = { uri, version: 1, isDirty: false }, calls = [], providers = [], warnings = [];
  let click = async () => "Accept";
  const vscode = {
    Uri: { file: fsPath => ({ scheme: "file", fsPath }), parse: str => ({ scheme: str.split(":")[0], toString: () => str }) },
    workspace: { textDocuments: [doc], workspaceFolders: [{ uri: { scheme: "file", fsPath: root } }],
      registerTextDocumentContentProvider: (scheme, provider) => { providers.push([scheme, provider]); return { dispose() {} }; },
      openTextDocument: async () => doc },
    commands: { executeCommand: async (...args) => { calls.push(args); } },
    window: { showInformationMessage: (...args) => click(...args), showWarningMessage: async message => { warnings.push(message); } },
  };
  const identity = { sessionId: "s1", generation: 1, closing: false };
  const state = { busy: true, runId: "r1" };
  let stops = 0;
  const api = createAgentApi(vscode, { snapshotRoot: path.join(root, "snapshots"), identity: () => identity, current: () => state,
    softStop: () => { stops++; return new Promise(() => {}); } });
  const request = { proposalId: "p1", sessionId: "s1", generation: 1, path: file, content: "display 2\n", documentVersion: 1 };
  function route(method, url, body) {
    return new Promise(resolve => {
      const req = new EventEmitter(); Object.assign(req, { method, url, destroy: () => resolve({ code: 413 }) });
      assert.equal(api.route(req, {}, (res, code, value) => resolve({ code, value })), true);
      if (method === "POST") { req.emit("data", Buffer.from(JSON.stringify(body))); req.emit("end"); }
    });
  }
  return { root, file, doc, identity, state, api, request, route, calls, providers, warnings, setClick: fn => { click = fn; }, stops: () => stops };
}
test("readonly diff displays captured bytes; Accept never executes or auto-runs", async t => {
  const f = fixture(t), d = await f.api.documentState(f.request);
  f.request.expectedSha256 = d.sha256;
  f.setClick(async () => {
    const [command, left, right] = f.calls[0];
    assert.equal(command, "vscode.diff"); assert.equal(right.scheme, "stata-proposal");
    assert.equal(f.providers[0][1].provideTextDocumentContent(left), "display 1\n");
    assert.equal(f.providers[0][1].provideTextDocumentContent(right), "display 2\n");
    return "Accept";
  });
  const result = await f.api.gate.propose(f.request, f.api.review);
  assert.equal(result.status, "accepted"); assert.equal(f.calls.length, 1); assert.equal(f.stops(), 0);
  assert.deepEqual(f.warnings, []);
});
test("Accept after an unsaved edit explains the rejected proposal once and preserves the file", async t => {
  const f = fixture(t);
  f.request.expectedSha256 = (await f.api.documentState(f.request)).sha256;
  let decide;
  f.setClick(() => new Promise(resolve => { decide = resolve; }));
  assert.equal((await f.route("POST", "/propose-edit", f.request)).code, 202);
  await new Promise(setImmediate);
  assert.equal(f.calls[0][0], "vscode.diff");
  assert.equal((await f.route("POST", "/propose-edit", f.request)).code, 202);
  f.doc.version++;
  f.doc.isDirty = true;
  decide("Accept");
  await f.api.gate.propose(f.request, f.api.review);
  const result = (await f.route("GET", "/proposals/p1")).value.proposal;
  assert.equal(result.status, "rejected");
  assert.equal(result.reasonCode, "DIRTY_DOCUMENT");
  assert.equal(result.snapshotPath, undefined);
  const state = await f.api.documentState(f.request);
  assert.equal(state.sha256, f.request.expectedSha256);
  assert.equal(state.dirty, true);
  assert.equal(state.documentVersion, 2);
  assert.deepEqual((await f.route("POST", "/propose-edit", f.request)).value.proposal, result);
  assert.equal(f.warnings.length, 1);
  assert.ok(f.warnings[0].includes(f.file));
  assert.match(f.warnings[0], /unsaved edits/i);
  assert.equal(f.calls.length, 1);
});
test("a refusal before review and an explicit Reject have no conflict notification", async t => {
  const f = fixture(t);
  f.request.expectedSha256 = (await f.api.documentState(f.request)).sha256;
  f.doc.isDirty = true;
  const before = await f.route("POST", "/propose-edit", f.request);
  assert.equal(before.value.proposal.reasonCode, "DIRTY_DOCUMENT");
  assert.equal(f.calls.length, 0);
  f.doc.isDirty = false;
  const next = { ...f.request, proposalId: "p2" };
  f.setClick(async () => { f.doc.isDirty = true; return "Reject"; });
  await f.route("POST", "/propose-edit", next);
  assert.equal((await f.api.gate.propose(next, f.api.review)).reasonCode, "USER_REJECTED");
  assert.deepEqual(f.warnings, []);
});
test("proposal POST returns pending immediately; GET finds durable final result", async t => {
  const f = fixture(t); f.request.expectedSha256 = (await f.api.documentState(f.request)).sha256;
  let accept; f.setClick(() => new Promise(resolve => { accept = resolve; }));
  const response = await f.route("POST", "/propose-edit", f.request);
  assert.equal(response.code, 202); await new Promise(setImmediate);
  assert.equal((await f.route("GET", "/proposals/p1")).value.proposal.status, "pending");
  accept("Accept"); await f.api.gate.propose(f.request, f.api.review);
  assert.equal((await f.route("GET", "/proposals/p1")).value.proposal.status, "accepted");
  assert.equal((await f.route("POST", "/propose-edit", f.request)).value.proposal.status, "accepted");
});
test("run precondition rejects saved or unsaved source changes, wrong generation and closing", async t => {
  const f = fixture(t), d = await f.api.documentState(f.request);
  const binding = { sourcePath: f.file, sourceSha256: d.sha256, documentVersion: 1, sessionId: "s1", generation: 1 };
  f.api.assertRun(binding);
  f.doc.isDirty = true; assert.throws(() => f.api.assertRun(binding), /DIRTY_DOCUMENT/);
  f.doc.isDirty = false; f.identity.generation++; assert.throws(() => f.api.assertRun(binding), /SESSION_CHANGED/);
  f.identity.generation--; f.identity.closing = true; assert.throws(() => f.api.assertRun(binding), /SESSION_CHANGED/);
});
test("run-bound Stop rejects stale run/generation/session/idle and returns before recovery finishes", async t => {
  const f = fixture(t), request = { expectedRunId: "r1", sessionId: "s1", generation: 1 };
  for (const bad of [{ ...request, expectedRunId: "old" }, { ...request, generation: 0 }, { ...request, sessionId: "other" }]) {
    assert.equal((await f.route("POST", "/agent-stop", bad)).code, 409);
  }
  f.state.busy = false; assert.equal((await f.route("POST", "/agent-stop", request)).code, 409);
  f.state.busy = true; assert.equal(f.stops(), 0);
  assert.equal((await f.route("POST", "/agent-stop", request)).code, 202); assert.equal(f.stops(), 1);
});
test("workflow run ID is durably reserved once, and continuations bind the paused run", async t => {
  const f = fixture(t), doc = await f.api.documentState(f.request);
  const binding = { workflowId: "wf_1", sourcePath: f.file, sourceSha256: doc.sha256, documentVersion: 1, sessionId: "s1", generation: 1 };
  f.api.bindRun(binding, "r1");
  const response = await f.route("GET", "/agent-runs/wf_1");
  assert.equal(response.value.run.runId, "r1"); assert.equal(response.value.run.sourceSha256, doc.sha256);
  assert.throws(() => f.api.bindRun(binding, "r2"), /EEXIST/);
  f.state.lastCompletedRun = { runId: "stopped", requestId: "original" };
  const continuation = { ...binding, workflowId: "wf_2", continuationOf: { ...f.state.lastCompletedRun } };
  f.api.assertRun(continuation);
  f.state.lastCompletedRun = { runId: "human", requestId: "other" };
  assert.throws(() => f.api.bindRun(continuation, "r2"), /PAUSED_RUN_CHANGED/);
  assert.equal((await f.route("GET", "/agent-runs/wf_2")).code, 404);
});

// Keep document identity coverage in the agent route suite.
require("./test_document_case.cjs");
require("./test_document_ambiguity");
