"use strict";

const cp = require("node:child_process");
const path = require("node:path");
const windows = require("./windows_kill_scope_core");
const orphan = require("./orphan_worker_core");

function same(a, b) {
  return !!a && !!b && a.pid === b.pid && a.createdMs === b.createdMs;
}

function createAdapter(options = {}) {
  const platform = options.platform || process.platform;
  const hostPid = options.hostPid || process.pid;
  const execFile = options.execFile || cp.execFile;
  const execFileSync = options.execFileSync || cp.execFileSync;
  const now = options.now || (() => performance.now());
  const script = path.join(__dirname, "panic_kill_stata_chain.ps1");
  const psArgs = ["-NoProfile", "-ExecutionPolicy", "Bypass", "-File", script];
  const run = (file, args, ms) => new Promise((resolve, reject) => {
    if (!(ms > 0)) return reject(new Error("process observation budget exhausted"));
    execFile(file, args, { timeout: Math.max(1, Math.floor(ms)), windowsHide: true, maxBuffer: 16*1024*1024,
      env: { ...process.env, LC_ALL: "C", LANG: "C" } }, (error, out, err) => {
      if (error || String(err || "").trim()) reject(error || new Error("process observation stderr"));
      else resolve(String(out));
    });
  });
  const parse = text => JSON.parse(String(text).replace(/^\uFEFF/, ""));

  async function identities(pid, ms) {
    if (!Number.isSafeInteger(pid) || pid <= 1 || pid === hostPid) throw new Error("invalid backend pid");
    if (platform === "win32") {
      // Two exact PIDs, not a global command/name match. Get-Process StartTime
      // is actual kernel creation time and must agree with the CIM identity.
      const command = `$ErrorActionPreference='Stop'; @(${pid},${hostPid}) | ForEach-Object { $q=Get-CimInstance Win32_Process -Filter ('ProcessId='+$_); if($q){ $p=Get-Process -Id $_ -ErrorAction Stop; [pscustomobject]@{pid=[int]$q.ProcessId;ppid=[int]$q.ParentProcessId;name=[string]$q.Name;createdMs=([DateTimeOffset]$p.StartTime.ToUniversalTime()).ToUnixTimeMilliseconds();cimMs=([DateTimeOffset]$q.CreationDate.ToUniversalTime()).ToUnixTimeMilliseconds()} } } | ConvertTo-Json -Compress`;
      const rows = parse(await run("powershell.exe", ["-NoProfile", "-Command", command], ms));
      return (Array.isArray(rows) ? rows : [rows]).filter(Boolean).map(r => {
        if (!Number.isFinite(r.createdMs) || Math.abs(r.createdMs-r.cimMs)>1) throw new Error("PID changed during identity read");
        return r;
      });
    }
    if (platform !== "darwin") throw new Error("unsupported shutdown platform");
    const rows = orphan.parsePs(await run("ps", ["-o", "pid=,ppid=,lstart=", "-p", `${pid},${hostPid}`], ms));
    if (!rows) throw new Error("process birth unreadable");
    return [...rows.values()].map(r => ({ ...r, createdMs: r.startMs, precisionMs: 1000 }));
  }

  async function capture(child, transport, token) {
    const pid = child && child.pid;
    const binding = options.binding && options.binding();
    if (!binding || !binding.sessionId || !binding.ownerId || !binding.profilePath) throw new Error("session ownership unavailable at spawn");
    const rows = await identities(pid, 3000);
    const root = rows.find(r => r.pid === pid), host = rows.find(r => r.pid === hostPid);
    if (!root || !host || root.ppid !== hostPid || root.createdMs < host.createdMs) throw new Error("backend birth/host ancestry mismatch");
    if (platform === "win32" && !/^(pythonw?|uvx?|mcp-stata)\.exe$/i.test(root.name)) throw new Error("unexpected backend executable");
    if (child.exitCode !== null || child.signalCode) throw new Error("backend exited during birth capture");
    return { ...root, host: { pid: host.pid, createdMs: host.createdMs }, ...binding, epoch: token.epoch };
  }

  function reconcile(entry) {
    if (platform !== "win32" || !entry.identity) return null;
    const root = entry.identity, binding = options.binding && options.binding();
    if (!binding || ["sessionId", "ownerId", "profilePath"].some(k => binding[k] !== root[k]) || root.host.pid !== hostPid) return null;
    const scope = options.completedScope && options.completedScope();
    if (!scope || scope.dryRun || scope.ok !== true || scope.failClosed || scope.scope !== "this-session" ||
      !Array.isArray(scope.targets) || !scope.kill || scope.kill.mode !== "scoped" ||
      !Array.isArray(scope.kill.results) || !windows.classifyKill(scope.kill).complete) return null;
    // Require a same-handle termination of the captured root, not "already
    // absent", and a result for every selected identity including old descendants.
    const top = scope.targets.find(r => same(r, root) && r.ppid === hostPid);
    const ended = scope.kill.results.find(r => r.pid === root.pid);
    if (!top || !ended || ended.code !== 0 || ended.seenMs !== root.createdMs ||
      !Number.isFinite(ended.endedAtMs) || ended.endedAtMs < root.createdMs) return null;
    const targets = new Map(scope.targets.map(r => [r.pid, r]));
    if (targets.size !== scope.targets.length || (entry.closeTargets || []).some(r => !same(r, targets.get(r.pid)))) return null;
    if (!scope.targets.every(r => {
      const results = scope.kill.results.filter(k => k.pid === r.pid);
      return results.length === 1 && [0, 1, 2].includes(results[0].code) &&
        (results[0].code !== 0 || results[0].seenMs === r.createdMs);
    })) return null;
    return { backendCleanup: "complete", reason: "same-identity-scoped-kill-complete", identity: root,
      targets: scope.targets.map(r => ({ ...r })), kill: JSON.parse(JSON.stringify(scope.kill)) };
  }

  async function close(entry, ms) {
    const end = now()+ms, left = () => Math.max(0, end-now());
    const root = entry.identity;
    const binding = options.binding && options.binding();
    if (!binding || ["sessionId", "ownerId", "profilePath"].some(k => binding[k] !== root[k]))
      return { backendCleanup: "unknown", reason: "session binding changed", identity: root };
    if (platform === "win32") {
      const listing = parse(await run("powershell.exe", [...psArgs, "-ListProcesses"], left()));
      if (!listing.ok || !Array.isArray(listing.processes)) throw new Error("process census unavailable");
      const row = listing.processes.find(p => p.pid === root.pid);
      const host = listing.processes.find(p => p.pid === hostPid);
      if (!host || host.handleCreatedMs !== root.host.createdMs || host.cimCreatedMs == null || Math.abs(host.cimCreatedMs-host.handleCreatedMs)>1)
        return { backendCleanup: "unknown", reason: "host identity changed", identity: root };
      if (!row) {
        // An immediately preceding scoped KILL may have already proved this
        // exact tree gone. Never borrow a newer generation's cleanup receipt.
        return reconcile(entry) || { backendCleanup: "unknown", reason: "root exited before descendant capture", identity: root };
      }
      if (row.handleCreatedMs !== root.createdMs || row.ppid !== hostPid)
        return { backendCleanup: "unknown", reason: "root identity changed; nothing signalled", identity: root };
      const selection = windows.selectSessionTree({ processes: listing.processes,
        roots: [{ pid: root.pid, startedAtMs: root.createdMs }], hostPid });
      if (!selection.ok || selection.unknownChildren.length || !selection.targets.length)
        return { backendCleanup: "unknown", reason: "tree identity unverified", selection, identity: root };
      entry.closeTargets = selection.targets;
      const result = parse(await run("powershell.exe", [...psArgs, "-Force", "-ScopedTargetCsv",
        selection.targets.map(r => `${r.pid}:${r.createdMs}`).join(",")], left()));
      const verdict = windows.classifyKill(result);
      return { backendCleanup: verdict.complete ? "complete" : verdict.pending.length ? "pending" : "unknown",
        identity: root, targets: selection.targets, result: verdict };
    }
    const rows = await identities(root.pid, left());
    if (!same(rows.find(r => r.pid === root.pid), root) || !same(rows.find(r => r.pid === hostPid), root.host))
      return { backendCleanup: "unknown", reason: "root/host identity changed", identity: root };
    const owned = new Map([[root.pid, { pid: root.pid, startedAt: new Date(root.createdMs).toISOString() }]]);
    const injected = { kill: options.kill, probe: options.probe, sleep: options.sleep };
    const captured = await orphan.startCapture(owned, { ...injected, hostPid, raceMs: Math.max(1,left()), budgetMs: left(), now, execFile });
    if (captured.state !== "ok" || !captured.root || captured.root.lstart !== root.lstart)
      return { backendCleanup: "unknown", reason: "descendant capture unverified", identity: root };
    // The SDK may escalate its own child. Re-read exact birth before each signal;
    // never send a signal to Code, to a reused PID, or after the close deadline.
    const child = entry.process, kill = child.kill.bind(child);
    child.kill = signal => {
      if (!(left() > 0) || child.exitCode !== null || child.signalCode) return false;
      const groupText = execFileSync("ps", ["-axo", "pid=,pgid=,stat=,lstart="],
        { encoding: "utf8", timeout: Math.max(1,Math.floor(left())), env: { ...process.env, LC_ALL: "C", LANG: "C" } });
      const group = orphan.parseGroup(groupText, hostPid);
      if (!group || group.some(r => /^[Tt]/.test(r.stat))) throw new Error("host process group unsafe to signal");
      if (!(left() > 0)) return false;
      const text = execFileSync("ps", ["-o", "pid=,ppid=,lstart=", "-p", String(root.pid)],
        { encoding: "utf8", timeout: Math.max(1,Math.floor(left())), env: { ...process.env, LC_ALL: "C", LANG: "C" } });
      const seen = orphan.parsePs(text), r = seen && seen.get(root.pid);
      if (!r || r.lstart !== root.lstart || r.ppid !== hostPid) throw new Error("root changed before transport signal");
      if (!(left() > 0)) return false;
      return kill(signal);
    };
    await entry.rawClose();
    const reap = await orphan.finishReap(Promise.resolve(captured), options.directories ? options.directories() : [],
      { generation: root.epoch, reason: "terminal-shutdown" }, { ...injected, hostPid, now, execFile,
        budgetMs: left(), raceMs: Math.max(1,left()), isCurrent: () => left()>0, store: {} });
    const rootGone = child.exitCode !== null || !!child.signalCode;
    return { backendCleanup: rootGone && reap.clean ? "complete" : left()<=0 ? "pending" : "unknown",
      identity: root, rootExited: rootGone, orphanWorkers: reap.orphanWorkers };
  }
  return { capture, close, reconcile };
}

module.exports = { createAdapter, same };
