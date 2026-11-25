"use strict";
// Actual product bindRun + lifecycle transition, with only VS Code and Stop effects stubbed.
const fs = require("node:fs"), path = require("node:path"), os = require("node:os"), assert = require("node:assert/strict"), crypto = require("node:crypto");
const repo = path.resolve(__dirname, "../..");
const { createAgentApi } = require(path.join(repo, "scripts/agent_edit_vscode.js"));
const lifecycle = require(path.join(repo, "scripts/execution_lifecycle_core.js"));
const requestId = "codex_synthetic_request", canonicalRunId = "run_synthetic_terminal";
const root = fs.realpathSync(fs.mkdtempSync(path.join(os.tmpdir(), "wb-run-binding-")));
try {
  const file = path.join(root, "analysis.do"); fs.writeFileSync(file, "display 1\n");
  const uri = { scheme: "file", fsPath: file }, doc = { uri, version: 1, isDirty: false };
  const vscode = { workspace: { textDocuments: [doc], workspaceFolders: [{ uri: { scheme: "file", fsPath: root } }],
      registerTextDocumentContentProvider: () => ({ dispose() {} }) } };
  const identity = { sessionId: "s1", generation: 3, closing: false }, state = { busy: true, runId: requestId };
  const api = createAgentApi(vscode, { snapshotRoot: path.join(root, "snapshots"), identity: () => identity, current: () => ({ ...state, ...lifecycle.publicLifecycle(state) }), softStop: () => { throw new Error("NO_REAL_STOP_ALLOWED"); } });
  const binding = { workflowId: "wf_contract_fixture", sourcePath: file, sourceSha256: crypto.createHash("sha256").update(fs.readFileSync(file)).digest("hex"), documentVersion: 1, sessionId: "s1", generation: 3 };
  api.bindRun(binding, requestId);
  let response;
  assert.equal(api.route({ method: "GET", url: "/agent-runs/wf_contract_fixture" }, {}, (_, code, body) => { response = { code, body }; }), true);
  assert.equal(response.code, 200);
  lifecycle.beginRun(state, { requestId, runId: requestId, sourceMode: "agent", perRunEvidenceRequired: true });
  state.runId = lifecycle.adoptRunId(state, canonicalRunId).runId;
  const activeStatus = { ...lifecycle.publicLifecycle(state), busy: true, postRunBusy: false, trueReady: false, recovery: { required: false } };
  assert.equal(activeStatus.requestId, requestId); assert.equal(activeStatus.runId, canonicalRunId);
  assert.throws(() => api.assertStop({ expectedRunId: requestId, sessionId: "s1", generation: 3 }, activeStatus), /STOP_TARGET_CHANGED/);
  api.assertStop({ expectedRunId: canonicalRunId, sessionId: "s1", generation: 3 }, activeStatus);
  assert.throws(() => api.assertStop({ expectedRunId: canonicalRunId, sessionId: "s1", generation: 3 }, { ...activeStatus, runId: "foreign" }), /STOP_TARGET_CHANGED/);
  assert.throws(() => api.bindRun(binding, "replay"), /EEXIST/);
  console.log(JSON.stringify({ schema: "workflow-dual-id-offline-fixture/1",
    reservation: { runId: response.body.run.runId, status: response.body.run.status },
    activeStatus: { requestId: activeStatus.requestId, runId: activeStatus.runId, busy: activeStatus.busy,
      postRunBusy: activeStatus.postRunBusy, trueReady: activeStatus.trueReady, recovery: activeStatus.recovery },
    serverCanonicalStopGuardPassed: true, reservedRequestIdStopRejected: true, changedCanonicalRunRejected: true,
    duplicateReservationRejected: true, synthetic: true }));
} finally { fs.rmSync(root, { recursive: true, force: true }); }
