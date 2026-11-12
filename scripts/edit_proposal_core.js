"use strict";

// No execution capability lives here. Accept only commits the reviewed bytes.
const crypto = require("node:crypto");
const fs = require("node:fs");
const path = require("node:path");
const MAX_CONTENT_BYTES = 2 * 1024 * 1024;
const DEFAULT_TIMEOUT_MS = 120000;
const ID = /^[A-Za-z0-9_-]{1,80}$/;
const sha256 = value => crypto.createHash("sha256").update(value).digest("hex");

function validateRequest(r) {
  if (!r || !ID.test(r.proposalId || "")) throw new Error("proposalId is required (1-80 letters, digits, _ or -)");
  if (!r.path || !path.isAbsolute(r.path) || !/\.(do|ado|mata)$/i.test(r.path)) throw new Error("absolute .do, .ado or .mata path required");
  if (typeof r.content !== "string" || Buffer.byteLength(r.content) > MAX_CONTENT_BYTES) throw new Error("content must be a string up to 2 MiB");
  if (!/^[a-f0-9]{64}$/.test(r.expectedSha256 || "")) throw new Error("expectedSha256 required");
  if (!ID.test(r.sessionId || "") || !Number.isSafeInteger(r.generation) || r.generation < 0) throw new Error("sessionId and generation required");
  if (!Number.isSafeInteger(r.documentVersion) || r.documentVersion < 1) throw new Error("documentVersion required");
  return { proposalId: r.proposalId, path: path.resolve(r.path), content: r.content,
    expectedSha256: r.expectedSha256, sessionId: r.sessionId, generation: r.generation,
    documentVersion: r.documentVersion, agentName: String(r.agentName || "agent").slice(0, 120),
    reason: String(r.reason || "").slice(0, 1000),
    timeoutMs: Math.max(1000, Math.min(900000, Number(r.timeoutMs) || DEFAULT_TIMEOUT_MS)) };
}

function within(root, file) {
  const relative = path.relative(root, file);
  return relative !== "" && relative !== ".." && !relative.startsWith(".." + path.sep) && !path.isAbsolute(relative);
}

function createEditGate(options = {}) {
  if (!options.snapshotRoot || !options.inspect) throw new Error("snapshotRoot and synchronous editor inspector required");
  const snapshotRoot = path.resolve(options.snapshotRoot);
  const recordRoot = path.resolve(options.recordRoot || path.join(snapshotRoot, "proposals"));
  const jobs = new Map(), writers = new Map();
  const now = options.now || Date.now;
  const iso = () => new Date(now()).toISOString();
  const recordPath = id => { if (!ID.test(id)) throw new Error("invalid proposal ID"); return path.join(recordRoot, id + ".json"); };

  function persist(record) {
    fs.mkdirSync(recordRoot, { recursive: true, mode: 0o700 });
    const file = recordPath(record.id), tmp = file + "." + crypto.randomBytes(8).toString("hex") + ".tmp";
    const fd = fs.openSync(tmp, "wx", 0o600);
    try { fs.writeFileSync(fd, JSON.stringify(record) + "\n"); fs.fsyncSync(fd); } finally { fs.closeSync(fd); }
    fs.renameSync(tmp, file);
    try { options.onEvent?.({ type: "edit_proposal_" + record.status, at: iso(), ...record }); } catch { /* disk record is authoritative */ }
    return record;
  }

  function get(id) {
    const file = recordPath(id);
    if (!fs.existsSync(file)) return null;
    const record = JSON.parse(fs.readFileSync(file, "utf8"));
    if (["pending", "applying"].includes(record.status) && !jobs.has(id)) {
      // A restarted extension cannot resurrect an Accept button or replay a write.
      return persist({ ...record, status: record.status === "applying" ? "unknown" : "rejected",
        reasonCode: "REVIEW_INTERRUPTED", endedAt: iso() });
    }
    return record;
  }

  function inspect(request, baseline) {
    const editor = options.inspect(request.path);
    if (!editor || editor.then) throw new Error("EDITOR_STATE_UNAVAILABLE");
    if (editor.closing || editor.sessionId !== request.sessionId || editor.generation !== request.generation) throw new Error("SESSION_CHANGED");
    if (editor.dirty !== false) throw new Error("DIRTY_DOCUMENT");
    if (editor.version !== request.documentVersion) throw new Error("DOCUMENT_VERSION_CHANGED");
    const realPath = fs.realpathSync(request.path);
    const roots = (editor.workspaceRoots || []).map(root => ({ logical: path.resolve(root), real: fs.realpathSync(root) }));
    const workspace = roots.find(root => within(root.logical, request.path) && within(root.real, realPath));
    if (!workspace) throw new Error("OUTSIDE_WORKSPACE");
    const stat = fs.statSync(realPath);
    if (!stat.isFile() || stat.nlink !== 1) throw new Error("UNSAFE_TARGET");
    const state = { realPath, workspace, dev: stat.dev, ino: stat.ino, documentId: editor.documentId };
    if (baseline && JSON.stringify(state) !== JSON.stringify(baseline)) throw new Error("TARGET_IDENTITY_CHANGED");
    const before = fs.readFileSync(realPath);
    if (sha256(before) !== request.expectedSha256) throw new Error(baseline ? "SHA_CHANGED_DURING_REVIEW" : "SHA_MISMATCH");
    return { state, before };
  }

  function terminal(record, status, reasonCode, extra = {}) {
    return persist({ ...record, ...extra, status, reasonCode, endedAt: iso() });
  }

  function submit(rawRequest, decide) {
    const request = validateRequest(rawRequest), id = request.proposalId;
    const requestSha256 = sha256(JSON.stringify(request)), existing = get(id);
    if (existing) {
      if (existing.requestSha256 !== requestSha256) throw new Error("PROPOSAL_ID_CONFLICT");
      return existing;
    }
    const record = { id, requestSha256, path: request.path, sessionId: request.sessionId, generation: request.generation,
      documentVersion: request.documentVersion, beforeSha256: request.expectedSha256,
      proposedSha256: sha256(request.content), agentName: request.agentName, reason: request.reason,
      createdAt: iso(), expiresAt: new Date(Number(now()) + request.timeoutMs).toISOString(), status: "pending" };
    let baseline;
    try { baseline = inspect(request); } catch (error) { return terminal(record, "rejected", error.message); }
    const controller = new AbortController();
    // Register before writing pending so duplicate submissions see the same job.
    const job = { controller, promise: null };
    jobs.set(id, job);
    try { persist(record); } catch (error) { jobs.delete(id); throw error; }
    job.promise = finish(request, record, baseline, decide, controller).finally(() => jobs.delete(id));
    // Durable unknown remains queryable if persistence itself fails.
    job.promise.catch(() => {});
    return record;
  }

  async function finish(request, record, baseline, decide, controller) {
    let timer;
    try {
      const decision = await Promise.race([
        Promise.resolve().then(() => decide(record, request.content, { before: baseline.before.toString("utf8"), signal: controller.signal })),
        new Promise(resolve => { timer = setTimeout(() => resolve({ status: "timeout" }), request.timeoutMs); }),
      ]);
      clearTimeout(timer);
      if (decision?.status !== "accepted") return terminal(record, decision?.status === "timeout" ? "timeout" : "rejected",
        decision?.status === "timeout" ? "DECISION_TIMEOUT" : "USER_REJECTED");
      // Serialize the final guard, snapshot and write for this real file. No await
      // occurs between the last editor/disk check and the actual file write.
      const key = baseline.state.realPath, previous = writers.get(key) || Promise.resolve();
      const write = previous.catch(() => {}).then(() => {
        if (Number(now()) >= Date.parse(record.expiresAt) || controller.signal.aborted) return terminal(record, "timeout", "DECISION_TIMEOUT");
        let current;
        try { current = inspect(request, baseline.state); } catch (error) { return terminal(record, "rejected", error.message); }
        fs.mkdirSync(snapshotRoot, { recursive: true, mode: 0o700 });
        const snapshot = path.join(snapshotRoot, record.id + ".snapshot");
        const snapshotFd = fs.openSync(snapshot, "wx", 0o600);
        try { fs.writeFileSync(snapshotFd, current.before); fs.fsyncSync(snapshotFd); } finally { fs.closeSync(snapshotFd); }
        const applying = persist({ ...record, status: "applying", snapshotPath: snapshot });
        try {
          // Do not truncate until checking the opened inode as well.
          const fd = fs.openSync(current.state.realPath, fs.constants.O_WRONLY | (fs.constants.O_NOFOLLOW || 0));
          try {
            const stat = fs.fstatSync(fd);
            if (stat.ino !== current.state.ino || stat.dev !== current.state.dev || stat.nlink !== 1) throw new Error("TARGET_IDENTITY_CHANGED");
            fs.ftruncateSync(fd, 0); fs.writeFileSync(fd, request.content); fs.fsyncSync(fd);
          } finally { fs.closeSync(fd); }
          if (sha256(fs.readFileSync(request.path)) !== record.proposedSha256) throw new Error("WRITE_NOT_CONFIRMED");
          return terminal(applying, "accepted", "USER_ACCEPTED", { finalSha256: record.proposedSha256 });
        } catch (error) { return terminal(applying, "unknown", "WRITE_NOT_CONFIRMED", { error: String(error.message) }); }
      });
      writers.set(key, write);
      try { return await write; } finally { if (writers.get(key) === write) writers.delete(key); }
    } catch (error) {
      const saved = JSON.parse(fs.readFileSync(recordPath(record.id), "utf8"));
      const uncertain = ["applying", "accepted", "unknown"].includes(saved.status);
      return terminal(saved, uncertain ? "unknown" : "rejected", uncertain ? "WRITE_NOT_CONFIRMED" : "REVIEW_ERROR", { error: String(error.message) });
    }
    finally { clearTimeout(timer); controller.abort(); }
  }

  async function propose(request, decide) {
    const record = submit(request, decide);
    return jobs.get(record.id)?.promise || record;
  }
  return { submit, get, propose, inspect, pending: () => [...jobs.keys()].map(get), validateRequest, sha256 };
}

module.exports = { createEditGate, validateRequest, sha256, MAX_CONTENT_BYTES, DEFAULT_TIMEOUT_MS, within };
