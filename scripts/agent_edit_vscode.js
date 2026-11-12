"use strict";

const fs = require("node:fs");
const path = require("node:path");
const { createEditGate, sha256, within } = require("./edit_proposal_core");

// Receives the actual (unwrapped) vscode module and this window's state only.
function createAgentApi(vscode, options) {
  const previews = new Map(), documentIds = new WeakMap();
  let sequence = 0;
  const provider = vscode.workspace.registerTextDocumentContentProvider("stata-proposal", {
    provideTextDocumentContent(uri) { return previews.get(uri.toString()) ?? "This proposal has expired."; },
  });
  options.subscriptions?.push(provider);
  function inspect(file) {
    const doc = vscode.workspace.textDocuments.find(d => d.uri.scheme === "file" && path.resolve(d.uri.fsPath) === path.resolve(file));
    if (!doc || doc.isClosed) throw new Error("EDITOR_DOCUMENT_UNAVAILABLE");
    if (!documentIds.has(doc)) documentIds.set(doc, ++sequence);
    return { ...options.identity(), dirty: doc.isDirty, version: doc.version, documentId: documentIds.get(doc),
      workspaceRoots: (vscode.workspace.workspaceFolders || []).filter(f => f.uri.scheme === "file").map(f => f.uri.fsPath) };
  }
  const gate = createEditGate({ snapshotRoot: options.snapshotRoot, recordRoot: options.recordRoot,
    inspect, onEvent: options.onEvent });

  async function documentState(request) {
    if (!request.path || !path.isAbsolute(request.path) || !/\.(do|ado|mata)$/i.test(request.path)) throw new Error("absolute Stata source path required");
    // Do not open a document outside the receiving window, including symlink escapes.
    const file = path.resolve(request.path), real = fs.realpathSync(file);
    const roots = vscode.workspace.workspaceFolders || [];
    if (!roots.some(f => f.uri.scheme === "file" && within(path.resolve(f.uri.fsPath), file) && within(fs.realpathSync(f.uri.fsPath), real))) throw new Error("OUTSIDE_WORKSPACE");
    await vscode.workspace.openTextDocument(vscode.Uri.file(file));
    const state = inspect(file);
    if (state.closing || state.sessionId !== request.sessionId || state.generation !== request.generation) throw new Error("SESSION_CHANGED");
    return { path: file, realPath: real, sessionId: state.sessionId, generation: state.generation,
      dirty: state.dirty, documentVersion: state.version, sha256: sha256(fs.readFileSync(file)) };
  }

  async function review(record, content, context) {
    const left = vscode.Uri.parse("stata-proposal:/" + record.id + "/before.do");
    const right = vscode.Uri.parse("stata-proposal:/" + record.id + "/proposed.do");
    previews.set(left.toString(), context.before); previews.set(right.toString(), content);
    const clear = () => { previews.delete(left.toString()); previews.delete(right.toString()); };
    context.signal.addEventListener("abort", clear, { once: true });
    try {
      await vscode.commands.executeCommand("vscode.diff", left, right, "Stata edit proposal: " + record.agentName + " — " + record.path);
      if (context.signal.aborted) return { status: "timeout" };
      const choice = await vscode.window.showInformationMessage("Review " + record.path + ". Accept writes this proposal only; it does not run Stata.", "Accept", "Reject");
      if (context.signal.aborted) return { status: "timeout" };
      return { status: choice === "Accept" ? "accepted" : "rejected" };
    } finally { clear(); context.signal.removeEventListener("abort", clear); }
  }

  function assertRun(binding) {
    if (!binding) return; // Existing human/legacy endpoints retain their contract.
    gate.inspect({ path: binding.sourcePath, expectedSha256: binding.sourceSha256,
      documentVersion: binding.documentVersion, sessionId: binding.sessionId, generation: binding.generation });
    if (binding.continuationOf) {
      const current = options.current().lastCompletedRun || {};
      if (!binding.continuationOf.runId || ["runId", "requestId"].some(key => current[key] !== binding.continuationOf[key])) throw new Error("PAUSED_RUN_CHANGED");
    }
  }

  const runRoot = path.join(options.snapshotRoot, "agent-runs");
  function runPath(id) {
    if (!/^[A-Za-z0-9_-]{1,80}$/.test(id || "")) throw new Error("WORKFLOW_ID_REQUIRED");
    return path.join(runRoot, id + ".json");
  }
  function bindRun(binding, runId) {
    assertRun(binding);
    const file = runPath(binding.workflowId);
    fs.mkdirSync(runRoot, { recursive: true, mode: 0o700 });
    const fd = fs.openSync(file, "wx", 0o600); // Duplicate workflow can never acquire twice.
    try { fs.writeFileSync(fd, JSON.stringify({ ...binding, runId, status: "reserved", at: new Date().toISOString() })); fs.fsyncSync(fd); }
    finally { fs.closeSync(fd); }
  }

  function assertStop(request, state) {
    const identity = options.identity();
    if (identity.closing || request.sessionId !== identity.sessionId || request.generation !== identity.generation ||
        !request.expectedRunId || state.runId !== request.expectedRunId || state.busy !== true) throw new Error("STOP_TARGET_CHANGED");
  }

  function route(req, res, send) {
    const runMatch = req.method === "GET" && /^\/agent-runs\/([A-Za-z0-9_-]{1,80})$/.exec(req.url);
    if (runMatch) {
      try { const file = runPath(runMatch[1]); send(res, fs.existsSync(file) ? 200 : 404, { run: fs.existsSync(file) ? JSON.parse(fs.readFileSync(file, "utf8")) : null }); }
      catch (error) { send(res, 500, { error: error.message }); }
      return true;
    }
    const match = req.method === "GET" && /^\/proposals\/([A-Za-z0-9_-]{1,80})$/.exec(req.url);
    if (match) {
      try { const proposal = gate.get(match[1]); send(res, proposal ? 200 : 404, { proposal }); }
      catch (error) { send(res, 500, { error: error.message }); }
      return true;
    }
    if (req.method !== "POST" || !["/propose-edit", "/document-state", "/agent-stop"].includes(req.url)) return false;
    let body = "", bytes = 0;
    req.on("data", chunk => { bytes += chunk.length; if (bytes > 3145728) req.destroy(); else body += chunk; });
    req.on("end", async () => {
      try {
        const request = JSON.parse(body || "{}");
        if (req.url === "/document-state") return send(res, 200, { document: await documentState(request) });
        if (req.url === "/propose-edit") {
          // Duplicate GET/POST must work even after the file changed on acceptance.
          if (!gate.get(request.proposalId)) await documentState(request);
          const proposal = gate.submit(request, review);
          return send(res, proposal.status === "pending" ? 202 : 200, { proposal });
        }
        assertStop(request, options.current());
        // Invoke synchronously after identity checks; no intervening await/input.
        const operation = options.softStop("http /soft-stop agent workflow");
        Promise.resolve(operation).then(result => options.onEvent?.({ type: "agent_stop_finished", expectedRunId: request.expectedRunId, result }),
          error => options.onEvent?.({ type: "agent_stop_error", expectedRunId: request.expectedRunId, error: String(error.message) })).catch(() => {});
        send(res, 202, { status: "stop-requested", expectedRunId: request.expectedRunId, sessionId: request.sessionId, generation: request.generation });
      } catch (error) { send(res, 409, { error: error.message, payloadDispatched: false }); }
    });
    return true;
  }
  return { route, gate, review, inspect, assertRun, bindRun, assertStop, documentState, dispose: () => provider.dispose() };
}

module.exports = { createAgentApi };
