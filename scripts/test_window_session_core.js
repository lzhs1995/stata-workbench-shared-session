"use strict";

const { test } = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const http = require("node:http");
const vm = require("node:vm");
const cp = require("node:child_process");
const { promisify } = require("node:util");
const { createWindowSession, configuredPort } = require("./window_session_core");
const { createBridgeBinder } = require("./bridge_rebind_core");
const { venvProbe } = require("./runtime_source_fixture");

function fixture(t) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "wb-window-test-"));
  t.after(() => fs.rmSync(root, { force: true, recursive: true }));
  const source = path.join(root, "source");
  fs.mkdirSync(path.join(source, "bin"), { recursive: true });
  fs.writeFileSync(path.join(source, "bin", "python3"), "fixture-python");
  fs.mkdirSync(path.join(source, "lib", "python3.11", "site-packages"), { recursive: true });
  return { root, home: root, source, env: { MCP_STATA_RUNTIME_ROOT: source }, probeRuntime: venvProbe("darwin"),
    stateRoot: path.join(root, "state"), platform: "darwin",
    readBootIdentity: () => ({ platform: "darwin", id: "22222222-2222-4222-8222-222222222222" }),
    snapshotProcesses: () => [{ pid: process.pid, ppid: 1, birth: "2026-01-01T10:00:00Z", command: "Code Helper" }],
    statfsSync: () => ({ bavail: 100, bsize: 1024 ** 3 }),
    cloneRuntime: (a, b) => fs.promises.cp(a, b, { recursive: true }),
    patchRuntime: () => ({ ok: true }) };
}

function wideDirectoryIdentity(t, directory, inode) {
  const lstat = fs.lstatSync;
  t.mock.method(fs, "lstatSync", (file, options) => {
    const stat = lstat(file, options);
    if (stat && typeof file === "string" && path.resolve(file) === path.resolve(directory)) {
      stat.dev = options?.bigint ? 23n : 23;
      stat.ino = options?.bigint ? inode() : Number(inode());
    }
    return stat;
  });
}

test("two ordinary windows share a workspace, not identities or mutable runtime", async (t) => {
  const f = fixture(t), env = { ...f.env }, before = { ...env };
  const a = createWindowSession({ ...f, env, workspacePath: "/same/project" });
  const b = createWindowSession({ ...f, env, workspacePath: "/same/project" });
  assert.notEqual(a.sessionId, b.sessionId);
  assert.equal(fs.existsSync(path.join(f.stateRoot, "engine-slots")), false, "opening the extension allocates no engine slot");
  const [ac, bc] = await Promise.all([a.prepare(), b.prepare()]);
  assert.notEqual(ac.command, bc.command);
  for (const key of ["MCP_STATA_RUNTIME_ROOT", "MCP_STATA_TEMP", "TMPDIR", "PYTHONPYCACHEPREFIX"]) assert.notEqual(ac.env[key], bc.env[key]);
  assert.deepEqual(env, before, "parent environment untouched");
  await a.finishClose({ backendCleanup: "complete" });
  assert.ok(b.status().slot, "closing A leaves B admitted");
  assert.equal(b.status().closing, false);
});

test("third starting engine refused; unknown cleanup keeps admission reserved", async (t) => {
  const f = fixture(t), a = createWindowSession(f), b = createWindowSession(f), c = createWindowSession(f);
  a.acquire(); b.acquire();
  await a.finishClose({ backendCleanup: "unknown" });
  assert.throws(() => c.acquire(), { code: "SESSION_LIMIT" });
  await a.finishClose({ backendCleanup: "complete" });
  c.acquire();
  assert.notEqual(c.status().slot, b.status().slot);
});

test("two-slot admission is atomic across actual extension-host processes", async (t) => {
  const f = fixture(t), runner = promisify(cp.execFile);
  const script = 'const {createWindowSession}=require(process.argv[1]);try {const s=createWindowSession({home:process.argv[2],stateRoot:process.argv[3],readBootIdentity:()=>({platform:"darwin",id:"22222222-2222-4222-8222-222222222222"}),snapshotProcesses:()=>[{pid:process.pid,ppid:1,birth:"2026-01-01T10:00:00Z"}]});s.acquire();console.log("ADMITTED")} catch(e){console.log(e.code)}';
  const results = await Promise.all(Array.from({ length: 3 }, (_, i) => runner(process.execPath,
    ["-e", script, require.resolve("./window_session_core"), f.root, path.join(f.root, "state-"+i)])));
  assert.equal(results.filter((r) => r.stdout.trim() === "ADMITTED").length, 2);
  assert.equal(results.filter((r) => r.stdout.trim() === "SESSION_LIMIT").length, 1);
});

test("legacy live, warming and unmanaged engines refuse before admission", (t) => {
  const f = fixture(t), legacy = path.join(f.home, ".stata-workbench-next", "sessions");
  fs.mkdirSync(legacy, { recursive: true });
  const file = path.join(legacy, "legacy.json");
  fs.writeFileSync(file, JSON.stringify({ extensionHostPid: process.pid }));
  assert.throws(() => createWindowSession(f).acquire(), { code: "LEGACY_SESSION_ACTIVE" });
  fs.unlinkSync(file);
  const opening = path.join(f.home, ".stata-workbench-next", "profiles", "old", "opening.json");
  fs.mkdirSync(path.dirname(opening), { recursive: true });
  fs.writeFileSync(opening, JSON.stringify({ pid: process.pid }));
  assert.throws(() => createWindowSession(f).acquire(), { code: "LEGACY_SESSION_OPENING" });
  fs.unlinkSync(opening);
  const unmanaged = createWindowSession({ ...f, snapshotProcesses: () => [...f.snapshotProcesses(),
    { pid: 88000, ppid: 1, birth: "2026-01-01T10:05:00Z", command: "/python -m mcp_stata" }] });
  assert.throws(() => unmanaged.acquire(), { code: "UNMANAGED_STATA_SESSION" });
  assert.equal(unmanaged.status().slot, null);
});

test("admitted host birth and ancestry are required to recognize a backend", (t) => {
  const f = fixture(t), a = createWindowSession(f); a.acquire();
  const engine = { pid: 88000, ppid: process.pid, birth: "2026-01-01T10:05:00Z", command: "/python -m mcp_stata" };
  const b = createWindowSession({ ...f, snapshotProcesses: () => [...f.snapshotProcesses(), engine] });
  b.acquire();
  const reused = createWindowSession({ ...f, snapshotProcesses: () => [
    { ...f.snapshotProcesses()[0], birth: "2026-01-01T10:10:00Z" }, engine] });
  assert.throws(() => reused.acquire(), { code: "UNMANAGED_STATA_SESSION" });
  for (const rows of [
    [...f.snapshotProcesses(), { ...engine, birth: "2026-01-01T09:00:00Z" }],
    [...f.snapshotProcesses(), { ...engine, ppid: 88001 }, { pid: 88001, ppid: process.pid, birth: "2026-01-01T10:10:00Z" }],
    [...f.snapshotProcesses(), { ...engine, birth: "unreadable" }],
  ]) assert.throws(() => createWindowSession({ ...f, snapshotProcesses: () => rows }).acquire(), { code: "UNMANAGED_STATA_SESSION" });
  assert.throws(() => createWindowSession({ ...f, snapshotProcesses: () => [...f.snapshotProcesses(), ...f.snapshotProcesses()] }).acquire(), { code: "ADMISSION_UNKNOWN" });
});

test("legacy orphaned PyStata worker blocks new engines without blocking unrelated multiprocessing", (t) => {
  const f = fixture(t), admission = require("./window_session_admission");
  const birth = "Thu Nov 12 10:00:00 2026";
  // Real next.6 macOS shape: multiprocessing argv names shared base Python,
  // not the copied profile runtime that launched this worker.
  const worker = { pid: 88000, ppid: 1, birth,
    command: "/Users/fixture/.local/share/uv/python/cpython-3.11.15-macos-aarch64-none/bin/python3.11 -B -s -c from multiprocessing.spawn import spawn_main; spawn_main(tracker_fd=11, pipe_handle=13) --multiprocessing-fork" };
  const legacy = path.join(f.home, ".stata-workbench-next", "sessions");
  fs.mkdirSync(legacy, { recursive: true });
  fs.writeFileSync(path.join(legacy, "dead.json"), JSON.stringify({ extensionHostPid: 87999 }));
  let reads = 0;
  const tagged = admission.observeWorkerMarkers([{ ...worker }], (file, args, opts) => {
    reads++; assert.equal(file, "/bin/ps"); assert.deepEqual(args.slice(-2), ["-p", "88000"]); assert.ok(opts.timeout <= 10000);
    return `88000 ${birth} ${worker.command} HOME=/Users/fixture STATA_WORKBENCH_OWNER_ID=87999-17601-original MCP_STATA_RUNTIME_ROOT=/legacy/private runtime UV_CACHE_DIR=/cache SECRET=not-retained\n`;
  });
  assert.equal(reads, 1); assert.equal(tagged[0].workbenchRuntimeRoot, "/legacy/private runtime");
  assert.equal(JSON.stringify(tagged).includes("not-retained"), false);
  assert.throws(() => createWindowSession({ ...f, snapshotProcesses: () => [...f.snapshotProcesses(), ...tagged] }).acquire(), { code: "UNMANAGED_STATA_SESSION" });
  const unrelated = admission.observeWorkerMarkers([{ ...worker }], () =>
    `88000 ${birth} ${worker.command} HOME=/Users/fixture VIRTUAL_ENV=/research/python TMPDIR=/research/tmp\n`);
  const session = createWindowSession({ ...f, snapshotProcesses: () => [...f.snapshotProcesses(), ...unrelated] });
  session.acquire(); assert.ok(session.status().slot, "unrelated multiprocessing using the same base interpreter remains allowed");
});

test("worker ownership probes bind process birth and do not infer ownership from Python alone", (t) => {
  const f = fixture(t), admission = require("./window_session_admission");
  const worker = { pid: 88000, ppid: process.pid, birth: "Thu Nov 12 10:00:00 2026",
    command: "/shared/python3 -c from multiprocessing.spawn import spawn_main; spawn_main() --multiprocessing-fork" };
  assert.throws(() => admission.observeWorkerMarkers([{ ...worker }], () =>
    `88000 Thu Nov 12 10:00:01 2026 ${worker.command} STATA_WORKBENCH_OWNER_ID=legacy\n`), { code: "ADMISSION_UNKNOWN" });
  assert.deepEqual(admission.observeWorkerMarkers([{ ...worker }], () => { throw new Error("unreadable unrelated process"); }), [worker]);
  const a = createWindowSession(f); a.acquire();
  const b = createWindowSession({ ...f, snapshotProcesses: () => [...f.snapshotProcesses(), { ...worker, workbenchOwnerId: "admitted-A" }] });
  b.acquire(); assert.ok(b.status().slot, "verified ancestry of an admitted worker remains accepted");
});

test("private runtime worker paths are admission evidence on Windows; research Python paths are not", () => {
  const admission = require("./window_session_admission");
  const options = { platform: "win32", home: "C:\\Users\\fixture", env: {}, roots: new Set(["D:\\Workbench state"]) };
  const argv = executable => ({ command: `"${executable}" -c "from multiprocessing.spawn import spawn_main; spawn_main(parent_pid=100, pipe_handle=200)" --multiprocessing-fork` });
  assert.equal(admission.isWorkbenchWorker(argv("D:\\Workbench state\\runs\\w-A\\runtime\\Scripts\\python.exe"), options), true);
  assert.equal(admission.isWorkbenchWorker(argv("C:\\Users\\fixture\\AppData\\Local\\stata-workbench\\mcp-stata-1.26.1\\Scripts\\python.exe"), options), true);
  assert.equal(admission.isWorkbenchWorker(argv("D:\\research\\Scripts\\python.exe"), options), false);
  assert.equal(admission.isWorkbenchWorker({ ...argv("D:\\research\\Scripts\\python.exe"), workbenchRuntimeRoot: "D:\\Workbench state\\profiles\\old\\runtime" }, options), true);
});

test("new boot archives old pending slots; release is idempotent and keeps original evidence", async t => {
  const f = fixture(t), parent = require("./window_session_admission").authorityRoot(f.home);
  const original = { sessionId: "old-A", extensionHostPid: 88000, hostBirth: "2026-01-01T10:00:00Z",
    bootIdentity: { platform: "darwin", id: "11111111-1111-4111-8111-111111111111" }, backendCleanup: "pending" };
  fs.mkdirSync(path.join(parent, "1"), { recursive: true });
  const bytes = JSON.stringify(original); fs.writeFileSync(path.join(parent, "1", "owner.json"), bytes);
  const current = createWindowSession(f); current.acquire();
  const record = JSON.parse(fs.readFileSync(path.join(parent, current.status().slot, "owner.json")));
  assert.deepEqual(record.bootIdentity, f.readBootIdentity());
  const archive = fs.readdirSync(path.join(parent, "recovered")); assert.equal(archive.length, 1);
  const archived = path.join(parent, "recovered", archive[0], "owner.json");
  assert.equal(fs.readFileSync(archived, "utf8"), bytes);
  const first = await current.finishClose({ backendCleanup: "complete" });
  const second = await current.finishClose({ backendCleanup: "complete" });
  assert.equal(first.slot, null); assert.equal(second.phase, "closed");
  assert.equal(fs.readFileSync(archived, "utf8"), bytes);
});

test("same-boot unresolved or missing-boot slots never recover because their host is gone", t => {
  const f = fixture(t), parent = require("./window_session_admission").authorityRoot(f.home);
  for (const number of [1, 2]) {
    fs.mkdirSync(path.join(parent, String(number)), { recursive: true });
    fs.writeFileSync(path.join(parent, String(number), "owner.json"), JSON.stringify({
      sessionId: "old-" + number, extensionHostPid: 88000 + number, hostBirth: "2026-01-01T10:00:00Z",
      ...(number === 1 ? { bootIdentity: f.readBootIdentity() } : {}) }));
  }
  assert.throws(() => createWindowSession(f).acquire(), { code: "SESSION_LIMIT" });
  assert.equal(fs.existsSync(path.join(parent, "recovered")), false);
});

test("verified close refuses a replaced owner even when its session id is unchanged", async t => {
  const f = fixture(t), session = createWindowSession(f); session.acquire();
  const parent = require("./window_session_admission").authorityRoot(f.home);
  const file = path.join(parent, session.status().slot, "owner.json");
  const original = JSON.parse(fs.readFileSync(file)); fs.writeFileSync(file, JSON.stringify({ ...original, hostBirth: "2026-01-02T10:00:00Z" }));
  await assert.rejects(session.finishClose({ backendCleanup: "complete" }), { code: "SLOT_OWNER_CHANGED" });
  assert.ok(fs.existsSync(file));
});

test("close while runtime clone is pending does not publish a runnable config", async (t) => {
  const f = fixture(t); let resume, entered;
  const reached = new Promise((resolve) => { entered = resolve; });
  const gate = new Promise((resolve) => { resume = resolve; });
  const a = createWindowSession({ ...f, cloneRuntime: async (...args) => { entered(); await gate; return f.cloneRuntime(...args); } });
  const preparing = a.prepare(); await reached; a.beginClose();
  const closing = a.finishClose({ backendCleanup: "complete" });
  resume();
  await assert.rejects(preparing, { code: "SESSION_CLOSING" }); await closing;
  assert.equal(a.getConfig(), null); assert.equal(a.status().slot, null);
  assert.equal(fs.existsSync(path.join(a.dataDir, "mcp.json")), false);
});

test("concurrent first commands prepare only one runtime", async (t) => {
  const f = fixture(t); let copies = 0;
  const a = createWindowSession({ ...f, cloneRuntime: async (...args) => { copies++; return f.cloneRuntime(...args); } });
  const [one, two] = await Promise.all([a.prepare(), a.prepare()]);
  assert.equal(copies, 1); assert.equal(one, two);
});

test("wide runtime identity stays exact in JSON and permits an unchanged retry", async t => {
  const f = fixture(t); let ready = false, copies = 0;
  const session = createWindowSession({ ...f,
    cloneRuntime: async (...args) => { copies++; return f.cloneRuntime(...args); },
    patchRuntime: () => ({ ok: ready, status: "fixture pause" }) });
  const runtime = path.join(session.dataDir, "runtime"), inode = 9007199254740993n;
  wideDirectoryIdentity(t, runtime, () => inode);
  await assert.rejects(session.prepare(), { code: "RUNTIME_PATCH_FAILED" });
  const origin = JSON.parse(fs.readFileSync(path.join(session.dataDir, "runtime-origin.json")));
  assert.deepEqual(origin.runtime, { dev: "23", ino: inode.toString() });
  ready = true;
  const config = await session.prepare();
  assert.ok(fs.existsSync(config.command)); assert.equal(copies, 1);
  await session.finishClose({ backendCleanup: "complete" });
});

test("legacy Number runtime proof is refused without rewriting its evidence", async t => {
  const f = fixture(t), session = createWindowSession({ ...f,
    patchRuntime: () => ({ ok: false, status: "fixture pause" }) });
  const runtime = path.join(session.dataDir, "runtime"), originPath = path.join(session.dataDir, "runtime-origin.json");
  wideDirectoryIdentity(t, runtime, () => 9007199254740993n);
  await assert.rejects(session.prepare(), { code: "RUNTIME_PATCH_FAILED" });
  const origin = JSON.parse(fs.readFileSync(originPath));
  origin.runtime = { dev: Number(origin.runtime.dev), ino: Number(origin.runtime.ino) };
  const legacy = JSON.stringify(origin); fs.writeFileSync(originPath, legacy);
  await assert.rejects(session.prepare(), { code: "RUNTIME_ORIGIN_UNVERIFIED" });
  assert.equal(fs.readFileSync(originPath, "utf8"), legacy);
  assert.ok(fs.existsSync(runtime)); assert.equal(session.status().slot, null);
});

test("runtime replacement with an adjacent wide inode is preserved and refused", async t => {
  const f = fixture(t), session = createWindowSession({ ...f,
    patchRuntime: () => ({ ok: false, status: "fixture pause" }) });
  const runtime = path.join(session.dataDir, "runtime"), originPath = path.join(session.dataDir, "runtime-origin.json");
  let inode = 9007199254740992n;
  wideDirectoryIdentity(t, runtime, () => inode);
  await assert.rejects(session.prepare(), { code: "RUNTIME_PATCH_FAILED" });
  const original = fs.readFileSync(originPath);
  fs.renameSync(runtime, runtime + ".preserved");
  fs.cpSync(runtime + ".preserved", runtime, { recursive: true });
  inode += 1n; assert.equal(Number(inode), Number(inode - 1n), "fixture aliases when represented as Number");
  await assert.rejects(session.prepare(), { code: "RUNTIME_ORIGIN_UNVERIFIED" });
  assert.deepEqual(fs.readFileSync(originPath), original);
  assert.ok(fs.existsSync(runtime)); assert.ok(fs.existsSync(runtime + ".preserved"));
  assert.equal(session.status().slot, null);
});

test("copy-lock replacement with an adjacent wide inode cannot authorize publication or cleanup", async t => {
  const f = fixture(t), lock = path.join(require("./window_session_admission").authorityRoot(f.home), "runtime-copy");
  let inode = 9007199254740992n;
  wideDirectoryIdentity(t, lock, () => inode);
  const session = createWindowSession({ ...f, cloneRuntime: async (...args) => {
    await f.cloneRuntime(...args);
    fs.renameSync(lock, lock + ".preserved"); fs.mkdirSync(lock);
    fs.copyFileSync(path.join(lock + ".preserved", "owner.json"), path.join(lock, "owner.json"));
    inode += 1n;
  } });
  await assert.rejects(session.prepare(), { code: "RUNTIME_COPY_OWNER_CHANGED" });
  assert.ok(fs.existsSync(path.join(lock, "owner.json")));
  assert.ok(fs.existsSync(path.join(lock + ".preserved", "owner.json")));
  assert.ok(fs.existsSync(path.join(session.dataDir, "runtime.partial")));
  assert.equal(fs.existsSync(path.join(session.dataDir, "runtime")), false);
  assert.equal(session.status().slot, null);
});

test("missing runtime and disk reserve fail before any backend starts", async (t) => {
  const f = fixture(t);
  const a = createWindowSession({ ...f, env: { MCP_STATA_RUNTIME_ROOT: path.join(f.root, "missing") } });
  await assert.rejects(a.prepare(), { code: "RUNTIME_SOURCE_MISSING" }); assert.equal(a.status().slot, null);
  const b = createWindowSession({ ...f, statfsSync: () => ({ bavail: 1, bsize: 1024 ** 3 }) });
  await assert.rejects(b.prepare(), { code: "DISK_RESERVE" }); assert.equal(b.status().slot, null);
});

test("explicit ports are respected, schema default does not bind all windows to it", () => {
  assert.equal(configuredPort({ inspect: () => ({ defaultValue: 17601 }) }), 0);
  assert.equal(configuredPort({ inspect: () => ({ globalValue: 17711, workspaceValue: 17712 }) }), 17712);
  assert.throws(() => configuredPort({ inspect: () => ({ workspaceValue: "17712" }) }), { code: "INVALID_BRIDGE_PORT" });
});

test("real HTTP windows publish distinct OS-assigned bound ports", async (t) => {
  const servers = [], binders = [];
  t.after(async () => { binders.forEach((b) => b.dispose()); await Promise.all(servers.map((s) => new Promise((r) => s.close(r)))); });
  const ports = await Promise.all([0, 1].map(() => new Promise((resolve, reject) => {
    const server = http.createServer((req, res) => res.end("ok")); servers.push(server);
    const binder = createBridgeBinder({ server, port: 0, onBound: (s) => resolve(s.port), onTerminalError: reject });
    binders.push(binder); binder.start();
  })));
  assert.ok(ports.every((port) => port >= 1024)); assert.notEqual(ports[0], ports[1]);
});

test("bundle wiring is reversible and syntax-valid, without global temp mutation", () => {
  const patch = require("./apply_window_session_patch");
  let original = fs.readFileSync(path.join(__dirname, "..", "dist", "extension.js"), "utf8");
  if (original.includes(patch.MARKER)) {
    original = require("./later_bundle_patches").revertAfter(original, "./apply_window_session_patch");
    original = patch.revertBundle(original);
  }
  const changed = patch.patchBundle(original);
  new vm.Script(changed);
  assert.equal(patch.patchBundle(changed), changed);
  assert.equal(patch.revertBundle(changed), original);
  assert.equal(changed.includes('__nextMultiCore.applyTempDir(process.env'), false);
  assert.ok(changed.includes('__port=globalThis.__codexWindowSession.requestedPort'));
  assert.ok(changed.includes('__port=__state.port;'));
});

test("VS Code adapter is lazy and delegates using a private config", async (t) => {
  const f = fixture(t), originalEnv = { ...process.env }; let connected = 0;
  const context = { subscriptions: [], extensionUri: { fsPath: "/installed/extension" } };
  const commands = new Map();
  const vscode = { env: {}, workspace: { workspaceFolders: [{ uri: { scheme: "file", fsPath: "/same" } }], getConfiguration: () => ({ inspect: () => ({}) }) },
    commands: { registerCommand: (name, fn) => { commands.set(name, fn); return { dispose() {} }; }, executeCommand: async () => {} },
    StatusBarAlignment: { Left: 1 },
    window: { createStatusBarItem: () => ({ show() {}, dispose() {} }), showErrorMessage: (message) => { throw new Error(message); } } };
  const client = { _loadServerConfig: () => ({ env: f.env }), _log() {},
    async _ensureClient() { connected++; assert.ok(this._loadServerConfig().command.startsWith(f.stateRoot)); return "connected"; },
    connect() { return this._ensureClient(); } };
  const manager = require("./window_session_vscode").install(context, vscode, client, f);
  assert.equal(connected, 0); assert.equal(manager.getConfig(), null);
  await commands.get("stata-workbench.startSession")();
  assert.equal(connected, 1);
  assert.ok(JSON.stringify({ ...process.env }) === JSON.stringify(originalEnv), "parent environment was not mutated");
  manager.beginClose(); await assert.rejects(client.connect(), /SESSION_CLOSING/);
  for (const d of context.subscriptions) d.dispose();
});

test("status shows run, stop, edit review and close as distinct phases", () => {
  const { describe } = require("./window_session_status");
  const manager = { status: () => ({ sessionName: "stata-A", sessionId: "w-A", phase: "ready" }) };
  const store = { __codexBridgeState: { busy: true, source: "agent" } };
  assert.equal(describe(manager, store).phase, "running");
  store.__codexSoftStopInFlight = true;
  assert.equal(describe(manager, store).phase, "stopping");
  store.__codexSoftStopInFlight = false; store.__codexBridgeState.busy = false;
  store.__codexLastSoftStop = { runId: "A1", ok: true, restored: true };
  store.__codexBridgeState.lastCompletedRun = { runId: "A1" };
  assert.equal(describe(manager, store).phase, "paused");
  store.__codexEditGate = { pending: () => [{ status: "pending" }] };
  assert.equal(describe(manager, store).phase, "review edit");
  store.__codexRecoveryState = { required: true };
  assert.equal(describe(manager, store).phase, "recovery required");
  assert.equal(describe({ status: () => ({ closing: true, phase: "cleanup-pending" }) }, store).phase, "cleanup-pending");
});
