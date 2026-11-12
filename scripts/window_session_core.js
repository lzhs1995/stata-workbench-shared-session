"use strict";

// One local extension-host window owns one session. A bridge alone does not
// consume a licensed engine slot. No shared VS Code process is signalled here.
const fs = require("node:fs");
const path = require("node:path");
const os = require("node:os");
const crypto = require("node:crypto");
const cp = require("node:child_process");
const { promisify } = require("node:util");
const execFile = promisify(cp.execFile);
const admission = require("./window_session_admission");
const slotRecovery = require("./window_slot_recovery");

function failure(code, detail) {
  return Object.assign(new Error(`${code}: ${detail}`), { code });
}

function writePrivate(file, value) {
  fs.writeFileSync(file, JSON.stringify(value, null, 2) + "\n", { mode: 0o600, flag: "wx" });
}

function runtimePython(root, platform) {
  const candidates = platform === "win32"
    ? [path.join(root, "Scripts", "python.exe"), path.join(root, "python.exe")]
    : [path.join(root, "bin", "python3"), path.join(root, "bin", "python")];
  return candidates.find((file) => fs.existsSync(file)) || null;
}

function runtimeBytes(root) {
  let bytes = 0;
  for (const entry of fs.readdirSync(root, { withFileTypes: true })) {
    const file = path.join(root, entry.name);
    if (entry.isDirectory()) bytes += runtimeBytes(file);
    else if (entry.isFile()) bytes += fs.statSync(file).size;
  }
  return bytes;
}

function templateRoot(config, env, platform, home) {
  const configured = config.env && config.env.MCP_STATA_RUNTIME_ROOT || env.MCP_STATA_RUNTIME_ROOT;
  if (configured) {
    if (!path.isAbsolute(configured)) throw failure("RUNTIME_INVALID", "runtime source must be absolute");
    return configured;
  }
  if (config.command && path.isAbsolute(config.command) && /^python(?:3(?:\.\d+)?)?(?:\.exe)?$/i.test(path.basename(config.command))) {
    const parent = path.dirname(config.command);
    return /^(bin|scripts)$/i.test(path.basename(parent)) ? path.dirname(parent) : parent;
  }
  return platform === "win32"
    ? path.join(env.LOCALAPPDATA || path.join(home, "AppData", "Local"), "stata-workbench", "mcp-stata-1.26.1")
    : path.join(home, ".local", "share", "stata-workbench", "mcp-stata-1.26.1");
}

function configuredPort(configuration) {
  const inspected = configuration.inspect && configuration.inspect("visibleBridgePort");
  // A schema default is not a user request for the same port in every window.
  const explicit = inspected && [inspected.workspaceFolderValue, inspected.workspaceValue, inspected.globalValue]
    .find((value) => value !== undefined && value !== null);
  if (explicit === undefined || explicit === null || explicit === 0) return 0;
  if (!Number.isInteger(explicit) || explicit < 1024 || explicit > 65535) {
    throw failure("INVALID_BRIDGE_PORT", "choose 0 (automatic) or an integer from 1024 to 65535");
  }
  return explicit;
}

function configuredDiskReserve(value, platform) {
  if (value === undefined || value === 0) return platform === "darwin" ? 20 : 10;
  if (typeof value !== "number" || !Number.isFinite(value) || value < 10)
    throw failure("INVALID_DISK_RESERVE", "minimumFreeDiskGiB must be 0 (platform default) or a finite number of at least 10");
  return value;
}

function createWindowSession(options = {}) {
  const env = { ...(options.env || process.env) };
  const platform = options.platform || process.platform;
  const minimumFreeDiskGiB = configuredDiskReserve(options.minimumFreeDiskGiB, platform);
  const home = options.home || os.homedir();
  const stateRoot = path.resolve(options.stateRoot || env.STATA_WORKBENCH_HOME || path.join(home, ".stata-workbench"));
  const sessionId = options.sessionId || "w-" + crypto.randomUUID();
  if (!/^[A-Za-z0-9_-]{1,80}$/.test(sessionId)) throw failure("INVALID_SESSION", "invalid session identity");
  const dataDir = path.join(stateRoot, "runs", sessionId);
  const dirs = Object.fromEntries(["tmp", "mcp-temp", "pycache", "checkpoints", "edit-snapshots"].map((name) => [name, path.join(dataDir, name)]));
  for (const dir of Object.values(dirs)) fs.mkdirSync(dir, { recursive: true, mode: 0o700 });
  const sessionName = (options.label || "stata") + "-" + sessionId.slice(-8);
  let phase = "idle", closing = false, preparing = null, slot = null, config = null, lastError = null, copyAuthority = null, slotOwnership = null;
  const readBootIdentity = options.readBootIdentity || (() => slotRecovery.readBootIdentity({ platform }));
  const mutationOptions = { readBootIdentity };
  const onState = options.onState || (() => {});
  const setPhase = (next) => { phase = next; onState(status()); };
  function status() {
    return { sessionId, sessionName, stateRoot, dataDir, phase, closing, slot: slot && path.basename(slot), lastError, minimumFreeDiskGiB,
      workspacePath: options.workspacePath || null, tempDir: dirs.tmp, logDir: dirs["mcp-temp"],
      graphDir: dirs["mcp-temp"], checkpointDir: dirs.checkpoints };
  }
  function checkOpen() { if (closing) throw failure("SESSION_CLOSING", "this window is closing"); }
  function acquire() {
    checkOpen();
    if (slot) return;
    const { parent, hostBirth } = admission.inspectAdmission({ home, stateRoot, env, platform, snapshot: options.snapshotProcesses });
    fs.mkdirSync(parent, { recursive: true, mode: 0o700 });
    const currentBoot = slotRecovery.validateBootIdentity(readBootIdentity());
    for (const number of [1, 2]) {
      const inspected = slotRecovery.inspectSlot({ parent, number, currentBoot });
      if (!inspected.eligible) continue;
      try { slotRecovery.recoverSlot(inspected, mutationOptions); }
      catch (error) { if (error.code !== "SLOT_RECOVERY_CHANGED") throw error; }
    }
    return slotRecovery.withSlotMutationLock(parent, lock => {
      checkOpen();
      for (let i = 1; i <= 2; i++) {
        const candidate = path.join(lock.parent, String(i));
        try { fs.mkdirSync(candidate, { mode: 0o700 }); }
        catch (error) { if (error.code === "EEXIST") continue; throw error; }
        slot = candidate;
        try { writePrivate(path.join(slot, "owner.json"), { sessionId, extensionHostPid: process.pid, hostBirth,
          bootIdentity: lock.bootIdentity, stateRoot, dataDir, at: new Date().toISOString() }); }
        catch (error) { fs.rmdirSync(candidate); slot = null; throw error; }
        slotOwnership = slotRecovery.inspectSlot({ parent: lock.parent, number: i, currentBoot: lock.bootIdentity });
        copyAuthority = { parent: lock.parent, hostBirth };
        return;
      }
      // Same-boot dead hosts and records without boot proof remain reserved.
      throw failure("SESSION_LIMIT", "two sessions are active or awaiting verified cleanup; close one first");
    }, mutationOptions);
  }
  function releaseVerified() {
    if (!slot) return;
    return slotRecovery.withSlotMutationLock(path.dirname(slot), lock => {
      const seen = slotRecovery.inspectSlot({ parent: lock.parent, number: Number(path.basename(slot)), currentBoot: lock.bootIdentity });
      const original = slotOwnership;
      if (!original || !seen.owner || seen.owner.sessionId !== sessionId || seen.ownerSha256 !== original.ownerSha256
        || seen.directoryIdentity?.dev !== original.directoryIdentity?.dev || seen.directoryIdentity?.ino !== original.directoryIdentity?.ino
        || seen.ownerFileIdentity?.dev !== original.ownerFileIdentity?.dev || seen.ownerFileIdentity?.ino !== original.ownerFileIdentity?.ino)
        throw failure("SLOT_OWNER_CHANGED", "slot owner or directory changed; preserve it for inspection");
      lock.assertOwnership();
      fs.unlinkSync(path.join(slot, "owner.json")); fs.rmdirSync(slot); slot = null; slotOwnership = null;
    }, mutationOptions);
  }
  async function withRuntimeCopyLock(action) {
    // Admission supplies one authority per OS account, even for different
    // state roots. The fresh free-space check and complete copy share this lock.
    const lock = path.join(copyAuthority.parent, "runtime-copy");
    const requestedWait = options.runtimeCopyWaitMs ?? 5000;
    const waitMs = Number.isFinite(requestedWait) ? Math.max(0, Math.min(requestedWait, 5000)) : 5000;
    const deadline = performance.now() + waitMs;
    for (;;) {
      checkOpen();
      try { fs.mkdirSync(lock, { mode: 0o700 }); break; }
      catch (error) { if (error.code !== "EEXIST") throw error; }
      const remaining = deadline - performance.now();
      if (remaining <= 0) throw failure("RUNTIME_COPY_BUSY", "another runtime copy is pending or unverified; inspect it before trying again");
      // No age/PID heuristic steals a live, stale or unreadable reservation.
      await new Promise(resolve => setTimeout(resolve, Math.min(25, remaining)));
    }
    const identity = fs.lstatSync(lock);
    const ownerFile = path.join(lock, "owner.json");
    const owner = { token: crypto.randomUUID(), sessionId, extensionHostPid: process.pid,
      hostBirth: copyAuthority.hostBirth, stateRoot, dataDir };
    let written = false;
    function checkOwner() {
      const current = fs.lstatSync(lock);
      if (!current.isDirectory() || current.dev !== identity.dev || current.ino !== identity.ino)
        throw failure("RUNTIME_COPY_OWNER_CHANGED", "copy reservation identity changed; preserve it for inspection");
      if (written) {
        let record;
        try { record = JSON.parse(fs.readFileSync(ownerFile, "utf8")); }
        catch { throw failure("RUNTIME_COPY_OWNER_CHANGED", "copy reservation owner is unreadable; preserve it for inspection"); }
        if (record.token !== owner.token || record.sessionId !== sessionId || record.extensionHostPid !== process.pid || record.hostBirth !== owner.hostBirth)
          throw failure("RUNTIME_COPY_OWNER_CHANGED", "copy reservation belongs to another owner; it was not removed");
      }
    }
    try {
      writePrivate(ownerFile, owner); written = true;
      checkOpen();
      return await action(checkOwner);
    } finally {
      checkOwner();
      if (written) fs.unlinkSync(ownerFile);
      // If writing our owner failed, rmdir only removes our still-empty inode.
      // Never recursively remove a reservation or any partial runtime evidence.
      fs.rmdirSync(lock);
    }
  }
  async function prepare(sourceConfig = {}) {
    checkOpen();
    if (config) return config;
    if (preparing) return preparing;
    preparing = (async () => {
      acquire(); setPhase("preparing");
      const source = templateRoot(sourceConfig, env, platform, home);
      if (!runtimePython(source, platform)) throw failure("RUNTIME_SOURCE_MISSING", "install the matching Workbench runtime before starting this session");
      const runtime = path.join(dataDir, "runtime");
      if (!runtimePython(runtime, platform)) {
        await withRuntimeCopyLock(async (checkOwner) => {
          checkOpen();
          if (runtimePython(runtime, platform)) return;
          const staging = path.join(dataDir, "runtime.partial");
          if (fs.existsSync(staging) || fs.existsSync(runtime)) throw failure("RUNTIME_INCOMPLETE", "a previous preparation needs inspection; it was not overwritten");
          const stat = (options.statfsSync || fs.statfsSync)(stateRoot);
          const reserve = minimumFreeDiskGiB;
          const available = stat.bavail * stat.bsize, needed = runtimeBytes(source);
          if (!Number.isSafeInteger(available) || available < 0 || !Number.isSafeInteger(needed) || needed < 0 || !(stat.bsize > 0))
            throw failure("DISK_RESERVE_UNKNOWN", "available capacity or runtime size could not be verified");
          if (available - needed < reserve * 1024 ** 3) throw failure("DISK_RESERVE", `keep at least ${reserve} GiB free after preparing a runtime`);
          checkOpen();
          if (options.cloneRuntime) await options.cloneRuntime(source, staging);
          else if (platform === "darwin") await execFile("/bin/cp", ["-c", "-R", source, staging], { timeout: 120000 });
          else await fs.promises.cp(source, staging, { recursive: true, dereference: false, errorOnExist: true, force: false });
          checkOpen();
          if (!runtimePython(staging, platform)) throw failure("RUNTIME_COPY_INVALID", "copied runtime has no Python executable");
          checkOwner();
          fs.renameSync(staging, runtime);
        });
      }
      checkOpen();
      const childEnv = { ...(sourceConfig.env || {}), MCP_STATA_RUNTIME_ROOT: runtime,
        MCP_STATA_TEMP: dirs["mcp-temp"], TMPDIR: dirs.tmp, PYTHONPYCACHEPREFIX: dirs.pycache,
        PYTHONDONTWRITEBYTECODE: "1", PYTHONNOUSERSITE: "1", MCP_STATA_PACKAGE_SPEC: "mcp-stata==1.26.1" };
      if (platform === "win32") Object.assign(childEnv, { TEMP: dirs.tmp, TMP: dirs.tmp });
      const next = { command: runtimePython(runtime, platform), args: ["-m", "mcp_stata"], env: childEnv,
        configPath: path.join(dataDir, "mcp.json") };
      if (options.patchRuntime) {
        const patched = await options.patchRuntime({ runtimeRoot: runtime, env: { ...env, ...childEnv } });
        if (!patched || !patched.ok) throw failure("RUNTIME_PATCH_FAILED", patched && patched.status || "unknown result");
      }
      checkOpen();
      writePrivate(next.configPath, { servers: { mcp_stata: { type: "stdio", ...next } } });
      config = next; setPhase("prepared"); return config;
    })().catch((error) => {
      lastError = error.code || error.message; setPhase(closing ? "closing" : "error");
      // prepare never starts a backend. Failed preparation may release its own slot.
      releaseVerified(); throw error;
    }).finally(() => { preparing = null; });
    return preparing;
  }
  function beginClose() { closing = true; setPhase("closing"); }
  async function finishClose(cleanup) {
    beginClose();
    if (preparing) { try { await preparing; } catch {} }
    if (cleanup && cleanup.backendCleanup === "complete") { releaseVerified(); setPhase("closed"); }
    else setPhase("cleanup-pending");
    return status();
  }
  return { sessionId, sessionName, stateRoot, dataDir, dirs, status, prepare, acquire, beginClose, finishClose,
    getConfig: () => config, mark: setPhase };
}

module.exports = { createWindowSession, configuredPort, configuredDiskReserve, runtimePython, templateRoot };
