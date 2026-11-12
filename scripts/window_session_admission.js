"use strict";

// One admission directory per OS account, independent of workspace/profile and
// STATA_WORKBENCH_HOME. This observes legacy owners; it never terminates them.
const fs = require("node:fs");
const path = require("node:path");
const cp = require("node:child_process");

function fail(code, detail) { throw Object.assign(new Error(`${code}: ${detail}`), { code }); }
function authorityRoot(home) { return path.join(home, ".stata-workbench", "engine-slots"); }

function isSpawnWorker(row) {
  return /\bfrom multiprocessing\.spawn import spawn_main\b/.test(row.command || "")
    && /(?:^|\s)--multiprocessing-fork(?:\s|$)/.test(row.command || "");
}

// macOS multiprocessing can replace a venv executable in argv with its shared
// base Python. Observe only the Workbench markers inherited by those workers;
// never retain/log the rest of their environment or classify all Python workers.
function observeWorkerMarkers(rows, read = cp.execFileSync) {
  const candidates = rows.filter(isSpawnWorker);
  if (!candidates.length) return rows;
  let text;
  try {
    text = read("/bin/ps", ["eww", "-o", "pid=,lstart=,command=", "-p", candidates.map(r => r.pid).join(",")],
      { encoding: "utf8", timeout: 10000, maxBuffer: 16 * 1024 * 1024,
        env: { ...process.env, LC_ALL: "C", LANG: "C" } });
  } catch { return rows; } // Unrelated Python is not Workbench ownership evidence.
  const byPid = new Map(candidates.map(r => [r.pid, r]));
  for (const line of String(text).split("\n")) {
    const m = /^\s*(\d+)\s+(.{24})\s+(.*)$/.exec(line);
    if (!m) continue;
    const row = byPid.get(Number(m[1]));
    if (!row || !m[3].startsWith(row.command + " ")) continue;
    const environment = m[3].slice(row.command.length + 1);
    const owner = /(?:^|\s)STATA_WORKBENCH_OWNER_ID=([^\s]+)/.exec(environment);
    const runtime = /(?:^|\s)MCP_STATA_RUNTIME_ROOT=(.*?)(?=\s+[A-Za-z_][A-Za-z0-9_]*=|$)/.exec(environment);
    if (!owner && !runtime) continue;
    if (m[2] !== row.birth) fail("ADMISSION_UNKNOWN", "a Workbench worker changed identity during observation");
    if (owner) row.workbenchOwnerId = owner[1];
    if (runtime) row.workbenchRuntimeRoot = runtime[1].trim();
  }
  return rows;
}

function snapshotProcesses(platform) {
  const opts = { encoding: "utf8", timeout: 10000, maxBuffer: 16 * 1024 * 1024,
    windowsHide: true, env: { ...process.env, LC_ALL: "C", LANG: "C" } };
  if (platform === "win32") {
    const script = "$ErrorActionPreference='Stop'; @(Get-CimInstance Win32_Process | ForEach-Object { [pscustomobject]@{pid=[int]$_.ProcessId;ppid=[int]$_.ParentProcessId;birth=$(if($_.CreationDate){$_.CreationDate.ToUniversalTime().ToString('o')}else{$null});command=[string]$_.CommandLine;name=[string]$_.Name} }) | ConvertTo-Json -Compress";
    const rows = JSON.parse(cp.execFileSync("powershell.exe", ["-NoProfile", "-Command", script], opts).replace(/^\uFEFF/, ""));
    return (Array.isArray(rows) ? rows : [rows]).filter(Boolean);
  }
  if (platform !== "darwin") fail("ADMISSION_UNSUPPORTED", "only local Mac/Windows engines are supported");
  const rows = cp.execFileSync("/bin/ps", ["-axo", "pid=,ppid=,lstart=,args="], opts).trim().split("\n").map(line => {
    const m = /^\s*(\d+)\s+(\d+)\s+(.{24})\s+(.*)$/.exec(line);
    if (!m) fail("ADMISSION_UNKNOWN", "process identity could not be parsed");
    return { pid: Number(m[1]), ppid: Number(m[2]), birth: m[3], command: m[4] };
  });
  return observeWorkerMarkers(rows);
}

function isEngine(row) {
  const command = row.command || "", name = row.name || "";
  return /^Stata(?:MP|SE|BE)?(?:-64)?\.exe$/i.test(name)
    || /\/Contents\/MacOS\/Stata(?:MP|SE|BE)?(?:\s|$)/i.test(command)
    || /(?:^|\s)-m\s+mcp_stata(?:\s|$)/.test(command)
    || /(?:^|[\/\\])mcp-stata(?:\.exe)?(?:\s|$)/.test(command);
}

function readRecords(directory) {
  let names;
  try { names = fs.readdirSync(directory); }
  catch (e) { if (e.code === "ENOENT") return []; throw e; }
  return names.filter(n => n.endsWith(".json") && !n.startsWith(".")).map(n => {
    try { return JSON.parse(fs.readFileSync(path.join(directory, n), "utf8")); }
    catch { fail("ADMISSION_UNKNOWN", "a session record is unreadable; inspect it before starting another engine"); }
  });
}

function isWorkbenchWorker(row, { roots, home, env, platform }) {
  if (!isSpawnWorker(row)) return false;
  if (typeof row.workbenchOwnerId === "string" && row.workbenchOwnerId) return true;
  const paths = platform === "win32" ? path.win32 : path;
  const normalize = value => platform === "win32" ? paths.resolve(value).toLowerCase() : paths.resolve(value);
  const known = [env.MCP_STATA_RUNTIME_ROOT, platform === "win32"
    ? paths.join(env.LOCALAPPDATA || paths.join(home, "AppData", "Local"), "stata-workbench", "mcp-stata-1.26.1")
    : paths.join(home, ".local", "share", "stata-workbench", "mcp-stata-1.26.1")]
    .filter(value => typeof value === "string" && paths.isAbsolute(value)).map(normalize);
  function pinned(root) {
    if (typeof root !== "string" || !paths.isAbsolute(root)) return false;
    const value = normalize(root);
    if (known.includes(value)) return true;
    return [...roots].some(base => ["runs", "profiles"].some(kind => {
      const relative = paths.relative(normalize(paths.join(base, kind)), value);
      const parts = relative.split(paths.sep);
      return parts.length === 2 && parts[0] !== ".." && parts[0] !== "." && parts[1] === "runtime";
    }));
  }
  if (pinned(row.workbenchRuntimeRoot)) return true;
  const match = /^\s*(?:"([^"]+[/\\]python(?:\d+(?:\.\d+)*)?(?:\.exe)?)"|(.+?[/\\]python(?:\d+(?:\.\d+)*)?(?:\.exe)?))(?=\s|$)/i.exec(row.command || "");
  if (!match) return false;
  const executable = match[1] || match[2], parent = paths.dirname(executable);
  return pinned(/^(bin|scripts)$/i.test(paths.basename(parent)) ? paths.dirname(parent) : parent);
}

function inspectAdmission({ home, stateRoot, env, platform, snapshot = snapshotProcesses }) {
  const rows = snapshot(platform), byPid = new Map(rows.map(r => [r.pid, r]));
  const roots = new Set([stateRoot, path.join(home, ".stata-workbench"), path.join(home, ".stata-workbench-next"), env.STATA_WORKBENCH_NEXT_HOME].filter(Boolean));
  if (byPid.size !== rows.length) fail("ADMISSION_UNKNOWN", "duplicate process identities in one snapshot");
  const birth = row => row && typeof row.birth === "string" && row.birth ? Date.parse(row.birth) : NaN;
  const host = byPid.get(process.pid);
  if (!host || !Number.isFinite(birth(host))) fail("ADMISSION_UNKNOWN", "extension-host birth could not be verified");
  const parent = authorityRoot(home), owners = [];
  for (const number of [1, 2]) {
    const dir = path.join(parent, String(number));
    if (!fs.existsSync(dir)) continue;
    try { owners.push(JSON.parse(fs.readFileSync(path.join(dir, "owner.json"), "utf8"))); }
    catch { /* An atomic mkdir may precede owner.json. It still occupies a slot. */ }
  }
  function admitted(row) {
    for (const owner of owners) {
      const h = byPid.get(owner.extensionHostPid);
      if (!h || h.birth !== owner.hostBirth) continue;
      let cursor = row; const seen = new Set();
      while (cursor && !seen.has(cursor.pid)) {
        if (!Number.isFinite(birth(cursor))) break;
        if (cursor.pid === h.pid) return true;
        seen.add(cursor.pid);
        const parent = byPid.get(cursor.ppid);
        if (!parent || !Number.isFinite(birth(parent)) || birth(cursor) < birth(parent)) break;
        cursor = parent;
      }
    }
    return false;
  }
  if (rows.some(row => (isEngine(row) || isWorkbenchWorker(row, { roots, home, env, platform })) && !admitted(row)))
    fail("UNMANAGED_STATA_SESSION", "an existing Stata/backend is outside window admission; close it normally before starting Workbench 0.2");
  for (const root of roots) {
    for (const record of readRecords(path.join(root, "sessions"))) {
      if (record.ordinaryWindow === true) continue;
      if (!Number.isInteger(record.extensionHostPid) || byPid.has(record.extensionHostPid))
        fail("LEGACY_SESSION_ACTIVE", "a legacy Workbench window is active or unverified; close that window before starting 0.2");
    }
    const profiles = path.join(root, "profiles");
    let dirs = [];
    try { dirs = fs.readdirSync(profiles, { withFileTypes: true }).filter(d => d.isDirectory()); }
    catch (e) { if (e.code !== "ENOENT") throw e; }
    for (const d of dirs) {
      const file = path.join(profiles, d.name, "opening.json");
      if (!fs.existsSync(file)) continue;
      let r;
      try { r = JSON.parse(fs.readFileSync(file, "utf8")); }
      catch { fail("ADMISSION_UNKNOWN", "legacy launcher reservation unreadable"); }
      if (!Number.isInteger(r.pid) || byPid.has(r.pid)) fail("LEGACY_SESSION_OPENING", "a legacy launch is pending; do not start both launch modes together");
    }
  }
  return { parent, hostBirth: host.birth };
}

module.exports = { authorityRoot, snapshotProcesses, isEngine, isSpawnWorker, isWorkbenchWorker, observeWorkerMarkers, inspectAdmission };
