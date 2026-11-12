"use strict";

const core = require("./backend_shutdown_core");
const { createAdapter } = require("./backend_shutdown_process");

function lifecycle(client, store = globalThis) {
  const binding = () => {
    const window = store.__codexWindowSession, multi = store.__codexNextMultiRef;
    return { sessionId: window ? window.sessionId : store.__codexNextSessionRef && store.__codexNextSessionRef.sessionId,
      ownerId: store.__codexBackendOwnerId,
      profilePath: window ? require("node:path").join(window.stateRoot, "runs", window.sessionId) : multi && multi.profilePath };
  };
  return core.forClient(client, {
    manager: () => store.__codexWindowSession,
    adapter: createAdapter({ binding, directories: () => {
      const multi = store.__codexNextMultiRef || {};
      return [multi.workspacePath, multi.dirs && multi.dirs.tempDir, multi.dirs && multi.dirs.logDir].filter(Boolean);
    }, completedScope: () => store.__codexLastKillScope }),
    onIdentity(entry, scope) {
      const id = entry.identity;
      const map = store.__codexOwnedBackendPids = store.__codexOwnedBackendPids instanceof Map ? store.__codexOwnedBackendPids : new Map();
      // Compatibility consumers still read startedAt; it is real birth, not the
      // much later handshake completion timestamp. Full identity remains available.
      const record = { ...id, startedAt: new Date(id.createdMs).toISOString() };
      map.set(id.pid, record);
      if (entry.process && typeof entry.process.once === "function") entry.process.once("exit", () => {
        if (map.get(id.pid) === record) map.delete(id.pid);
      });
      if (entry.process && entry.process.stderr && typeof client._attachStderrListener === "function")
        scope._attachStderrListener(entry.process.stderr, "spawn", entry.transport);
    },
  });
}

module.exports = { lifecycle };
