"use strict";
const test = require("node:test"), assert = require("node:assert/strict");
const fs = require("node:fs"), os = require("node:os"), path = require("node:path");
const { createEditGate, sha256 } = require("./edit_proposal_core");

function fixture(t) {
  const root = fs.realpathSync(fs.mkdtempSync(path.join(os.tmpdir(), "wb-proposal-")));
  t.after(() => fs.rmSync(root, { recursive: true, force: true }));
  const file = path.join(root, "model.do"); fs.writeFileSync(file, "display 1\n");
  const editor = { sessionId: "s1", generation: 3, dirty: false, version: 7, documentId: 1, workspaceRoots: [root] };
  const options = { snapshotRoot: path.join(root, "snapshots"), inspect: () => editor };
  const gate = createEditGate(options);
  const request = { proposalId: "proposal1", sessionId: "s1", generation: 3, documentVersion: 7,
    path: file, content: "display 2\n", expectedSha256: sha256(fs.readFileSync(file)) };
  return { root, file, editor, options, gate, request };
}
const accept = async () => ({ status: "accepted" });

test("accept retains original snapshot and durable result across gate recreation", async t => {
  const f = fixture(t), result = await f.gate.propose(f.request, accept);
  assert.equal(result.status, "accepted"); assert.equal(fs.readFileSync(f.file, "utf8"), f.request.content);
  assert.equal(fs.readFileSync(result.snapshotPath, "utf8"), "display 1\n");
  assert.deepEqual(createEditGate(f.options).get(f.request.proposalId), result);
});
test("duplicate submission and lost response never reopen review or overwrite twice", async t => {
  const f = fixture(t); let calls = 0, resolve;
  const decide = () => { calls++; return new Promise(r => { resolve = r; }); };
  const first = f.gate.submit(f.request, decide);
  assert.deepEqual(f.gate.submit(f.request, decide), first);
  await Promise.resolve(); resolve({ status: "accepted" });
  const final = await f.gate.propose(f.request, decide);
  assert.equal(calls, 1); assert.equal(final.status, "accepted");
  assert.deepEqual(f.gate.submit(f.request, decide), final);
  assert.throws(() => f.gate.submit({ ...f.request, content: "display 3" }, decide), /PROPOSAL_ID_CONFLICT/);
});
for (const [name, change, reason] of [
  ["dirty", f => { f.editor.dirty = true; }, "DIRTY_DOCUMENT"],
  ["version", f => { f.editor.version++; }, "DOCUMENT_VERSION_CHANGED"],
  ["session", f => { f.editor.generation++; }, "SESSION_CHANGED"],
  ["closing", f => { f.editor.closing = true; }, "SESSION_CHANGED"],
  ["workspace", f => { f.editor.workspaceRoots = []; }, "OUTSIDE_WORKSPACE"],
]) {
  test(name + " is checked at proposal and acceptance", async t => {
    const f = fixture(t); change(f);
    assert.equal((await f.gate.propose(f.request, accept)).reasonCode, reason);
    const g = fixture(t);
    const result = await g.gate.propose(g.request, async () => { change(g); return accept(); });
    assert.equal(result.reasonCode, reason); assert.equal(fs.readFileSync(g.file, "utf8"), "display 1\n");
  });
}
test("saved human edits and document close/reopen invalidate review", async t => {
  const f = fixture(t);
  assert.equal((await f.gate.propose(f.request, async () => { fs.writeFileSync(f.file, "human\n"); return accept(); })).reasonCode, "SHA_CHANGED_DURING_REVIEW");
  const g = fixture(t);
  assert.equal((await g.gate.propose(g.request, async () => { g.editor.documentId++; return accept(); })).reasonCode, "TARGET_IDENTITY_CHANGED");
});
test("symlink escape and workspace removal do not write outside workspace", async t => {
  const f = fixture(t), outside = fixture(t);
  const link = path.join(f.root, "escape.do"); fs.symlinkSync(outside.file, link);
  const result = await f.gate.propose({ ...f.request, path: link }, accept);
  assert.equal(result.reasonCode, "OUTSIDE_WORKSPACE"); assert.equal(fs.readFileSync(outside.file, "utf8"), "display 1\n");
});
test("concurrent accepts for one target serialize; only first snapshot/write wins", async t => {
  const f = fixture(t);
  const results = await Promise.all([f.gate.propose(f.request, accept),
    f.gate.propose({ ...f.request, proposalId: "second", content: "display 3\n" }, accept)]);
  assert.deepEqual(results.map(r => r.status), ["accepted", "rejected"]);
  assert.equal(results[1].reasonCode, "SHA_CHANGED_DURING_REVIEW");
});
test("timeout invalidates late Accept, aborts review and persists terminal status", async t => {
  const f = fixture(t); let late, signal;
  const result = await f.gate.propose({ ...f.request, timeoutMs: 1000 }, (r, c, context) => {
    signal = context.signal; return new Promise(resolve => { late = resolve; });
  });
  assert.equal(result.status, "timeout"); assert.equal(signal.aborted, true);
  late({ status: "accepted" }); await Promise.resolve();
  assert.equal(fs.readFileSync(f.file, "utf8"), "display 1\n"); assert.equal(f.gate.get(f.request.proposalId).status, "timeout");
});
test("restart pending/applying never resumes an acceptance", async t => {
  const f = fixture(t);
  const pending = f.gate.submit(f.request, async () => ({ status: "rejected" }));
  const fresh = createEditGate(f.options);
  assert.equal(fresh.get(pending.id).reasonCode, "REVIEW_INTERRUPTED");
  await f.gate.propose(f.request, accept);
  const file = path.join(f.options.snapshotRoot, "proposals", "applying.json");
  fs.writeFileSync(file, JSON.stringify({ ...pending, id: "applying", status: "applying" }));
  assert.equal(fresh.get("applying").status, "unknown");
});
test("rejection/review error leave data unchanged; malformed request fails before UI", async t => {
  const f = fixture(t);
  assert.equal((await f.gate.propose(f.request, async () => { throw new Error("UI unavailable"); })).reasonCode, "REVIEW_ERROR");
  assert.equal(fs.readFileSync(f.file, "utf8"), "display 1\n");
  assert.throws(() => f.gate.submit({ ...f.request, proposalId: "../bad" }, accept));
});
