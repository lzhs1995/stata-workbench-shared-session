"use strict";

const { test } = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const cp = require("node:child_process");
const { createWindowSession, configuredDiskReserve } = require("./window_session_core");
const { authorityRoot } = require("./window_session_admission");

const delay = ms => new Promise(resolve => setTimeout(resolve, ms));
function deferred() { let resolve; const promise = new Promise(r => { resolve = r; }); return { promise, resolve }; }
function fixture(t, platform = "darwin") {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "wb-copy-reservation-"));
  t.after(() => fs.rmSync(root, { recursive: true, force: true }));
  const source = path.join(root, "source");
  const python = platform === "win32" ? path.join(source, "Scripts", "python.exe") : path.join(source, "bin", "python3");
  fs.mkdirSync(path.dirname(python), { recursive: true });
  fs.writeFileSync(python, "synthetic-python");
  const options = { home: root, stateRoot: path.join(root, "state-A"), platform,
    readBootIdentity: () => platform === "win32" ? { platform, id: "2026-11-12T02:30:00.000Z" }
      : { platform, id: "22222222-2222-4222-8222-222222222222" },
    env: { MCP_STATA_RUNTIME_ROOT: source }, runtimeCopyWaitMs: 5000,
    snapshotProcesses: () => [{ pid: process.pid, ppid: 1, birth: "2026-01-01T10:00:00Z" }],
    statfsSync: () => ({ bavail: 100 * 1024 ** 3, bsize: 1 }),
    cloneRuntime: (a, b) => fs.promises.cp(a, b, { recursive: true }) };
  return { root, source, options, bytes: fs.statSync(python).size, lock: path.join(authorityRoot(root), "runtime-copy") };
}

for (const [platform, configured, expectedFloor] of [["darwin", 0, 20], ["win32", 0, 10], ["darwin", 10, 10]]) {
  test(`${platform} configured ${configured}: cross-root windows recheck capacity after the first copy`, async t => {
    const f = fixture(t, platform), entered = deferred(), gate = deferred();
    const floor = expectedFloor * 1024 ** 3;
    let available = floor + f.bytes + 1, copies = 0;
    const checks = [];
    const options = { ...f.options, minimumFreeDiskGiB: configured,
      statfsSync: root => { checks.push(root); return { bavail: available, bsize: 1 }; },
      cloneRuntime: async (a, b) => { copies++; entered.resolve(); await gate.promise; await f.options.cloneRuntime(a, b); available -= f.bytes; } };
    const first = createWindowSession(options);
    const second = createWindowSession({ ...options, stateRoot: path.join(f.root, "state-B") });
    const a = first.prepare(); await entered.promise;
    const b = second.prepare(); const refused = assert.rejects(b, { code: "DISK_RESERVE" });
    await delay(60);
    assert.equal(copies, 1);
    assert.deepEqual(checks, [first.stateRoot], "the second window cannot observe pre-copy free space");
    assert.equal(JSON.parse(fs.readFileSync(path.join(f.lock, "owner.json"))).sessionId, first.sessionId);
    gate.resolve(); await a; await refused;
    assert.deepEqual(checks, [first.stateRoot, second.stateRoot]);
    assert.equal(copies, 1); assert.equal(second.status().slot, null);
    assert.equal(fs.existsSync(path.join(second.dataDir, "runtime.partial")), false);
    assert.equal(fs.existsSync(f.lock), false);
    await first.finishClose({ backendCleanup: "complete" });
  });
}

test("configured 10 GiB permits a Mac copy that the unchanged default refuses", async t => {
  const f = fixture(t); let copies = 0;
  const options = { ...f.options, statfsSync: () => ({ bavail: 15 * 1024 ** 3, bsize: 1 }),
    cloneRuntime: async (...args) => { copies++; return f.options.cloneRuntime(...args); } };
  const standard = createWindowSession(options);
  assert.equal(standard.status().minimumFreeDiskGiB, 20);
  await assert.rejects(standard.prepare(), { code: "DISK_RESERVE" });
  assert.equal(copies, 0); assert.equal(fs.existsSync(f.lock), false);
  const approved = createWindowSession({ ...options, stateRoot: path.join(f.root, "approved"), minimumFreeDiskGiB: 10 });
  assert.equal(approved.status().minimumFreeDiskGiB, 10);
  await approved.prepare(); assert.equal(copies, 1);
  await approved.finishClose({ backendCleanup: "complete" });
});

test("disk reserve configuration rejects nonnumeric, nonfinite and below-10 overrides before creating state", async t => {
  const f = fixture(t), stateRoot = path.join(f.root, "invalid-config");
  for (const value of [-1, 1, 9.99, NaN, Infinity, -Infinity, "10", null, false]) {
    assert.throws(() => createWindowSession({ ...f.options, stateRoot, minimumFreeDiskGiB: value }), { code: "INVALID_DISK_RESERVE" });
    assert.equal(fs.existsSync(stateRoot), false);
    assert.equal(fs.existsSync(f.lock), false);
  }
  assert.equal(configuredDiskReserve(0, "darwin"), 20);
  assert.equal(configuredDiskReserve(undefined, "darwin"), 20);
  assert.equal(configuredDiskReserve(0, "win32"), 10);
  assert.equal(configuredDiskReserve(10.5, "darwin"), 10.5);
});

test("VS Code passes the workspace disk floor without changing settings or parent environment", async t => {
  const f = fixture(t), before = { ...process.env };
  const reads = [];
  const context = { subscriptions: [], extensionUri: { fsPath: "/synthetic/extension" } };
  const vscode = { env: {}, workspace: { workspaceFolders: [{ uri: { scheme: "file", fsPath: f.root } }],
    getConfiguration: () => ({ inspect: () => ({}), get: (key, fallback) => { reads.push([key, fallback]); return key === "minimumFreeDiskGiB" ? 10 : fallback; } }) },
    commands: { registerCommand: () => ({ dispose() {} }) }, StatusBarAlignment: { Left: 1 },
    window: { createStatusBarItem: () => ({ show() {}, dispose() {} }) } };
  const client = { _loadServerConfig: () => ({ env: f.options.env }), _ensureClient: async () => "connected", _log() {} };
  const manager = require("./window_session_vscode").install(context, vscode, client, { ...f.options,
    statfsSync: () => ({ bavail: 15 * 1024 ** 3, bsize: 1 }), patchRuntime: () => ({ ok: true }) });
  assert.deepEqual(reads, [["minimumFreeDiskGiB", 0]]);
  assert.equal(manager.status().minimumFreeDiskGiB, 10);
  assert.equal(await client._ensureClient(), "connected");
  assert.deepEqual({ ...process.env }, before);
  await manager.finishClose({ backendCleanup: "complete" });
  for (const subscription of context.subscriptions) subscription.dispose();
});

test("closing a waiting window never checks capacity or starts its clone", async t => {
  const f = fixture(t), entered = deferred(), gate = deferred();
  let copies = 0, checks = 0;
  const options = { ...f.options, statfsSync: () => { checks++; return f.options.statfsSync(); },
    cloneRuntime: async (...args) => { copies++; entered.resolve(); await gate.promise; return f.options.cloneRuntime(...args); } };
  const first = createWindowSession(options), second = createWindowSession({ ...options, stateRoot: path.join(f.root, "state-B") });
  const a = first.prepare(); await entered.promise;
  const b = second.prepare(); const refused = assert.rejects(b, { code: "SESSION_CLOSING" });
  await delay(30); second.beginClose();
  await refused; await second.finishClose({ backendCleanup: "complete" });
  assert.equal(checks, 1); assert.equal(copies, 1);
  assert.equal(JSON.parse(fs.readFileSync(path.join(f.lock, "owner.json"))).sessionId, first.sessionId);
  assert.equal(fs.existsSync(path.join(second.dataDir, "runtime.partial")), false);
  gate.resolve(); await a;
  assert.equal(fs.existsSync(f.lock), false);
  await first.finishClose({ backendCleanup: "complete" });
});

test("failed clone preserves partial evidence and releases only its copy reservation", async t => {
  const f = fixture(t);
  const first = createWindowSession({ ...f.options, cloneRuntime: async (_a, staging) => {
    fs.mkdirSync(staging); fs.writeFileSync(path.join(staging, "evidence"), "original-partial");
    throw Object.assign(new Error("synthetic clone failure"), { code: "COPY_FAILED" });
  } });
  await assert.rejects(first.prepare(), { code: "COPY_FAILED" });
  assert.equal(fs.readFileSync(path.join(first.dataDir, "runtime.partial/evidence"), "utf8"), "original-partial");
  assert.equal(fs.existsSync(f.lock), false); assert.equal(first.status().slot, null);
  const second = createWindowSession({ ...f.options, stateRoot: path.join(f.root, "state-B") });
  await second.prepare();
  assert.equal(fs.existsSync(f.lock), false);
  await assert.rejects(first.prepare(), { code: "RUNTIME_INCOMPLETE" });
  assert.equal(fs.readFileSync(path.join(first.dataDir, "runtime.partial/evidence"), "utf8"), "original-partial");
  await second.finishClose({ backendCleanup: "complete" });
});

test("close during owned copy preserves staging and allows the next window", async t => {
  const f = fixture(t), entered = deferred(), gate = deferred();
  const first = createWindowSession({ ...f.options, cloneRuntime: async (...args) => {
    entered.resolve(); await gate.promise; return f.options.cloneRuntime(...args);
  } });
  const preparing = first.prepare(); const refused = assert.rejects(preparing, { code: "SESSION_CLOSING" });
  await entered.promise; first.beginClose(); gate.resolve(); await refused;
  await first.finishClose({ backendCleanup: "complete" });
  assert.equal(fs.existsSync(path.join(first.dataDir, "runtime.partial/bin/python3")), true);
  assert.equal(fs.existsSync(path.join(first.dataDir, "runtime")), false);
  assert.equal(fs.existsSync(f.lock), false);
  const second = createWindowSession({ ...f.options, stateRoot: path.join(f.root, "state-B") });
  await second.prepare(); await second.finishClose({ backendCleanup: "complete" });
});

test("old malformed and ownerless reservations are bounded refusals, never stolen", async t => {
  const f = fixture(t); fs.mkdirSync(f.lock, { recursive: true });
  for (const evidence of [null, "{incomplete", JSON.stringify({ extensionHostPid: 99999999, at: "1970-01-01" })]) {
    const owner = path.join(f.lock, "owner.json");
    if (evidence !== null) fs.writeFileSync(owner, evidence);
    fs.utimesSync(f.lock, new Date(0), new Date(0));
    const identity = fs.lstatSync(f.lock); let copies = 0, checks = 0;
    const session = createWindowSession({ ...f.options, runtimeCopyWaitMs: 30,
      statfsSync: () => { checks++; return f.options.statfsSync(); }, cloneRuntime: async () => { copies++; } });
    await assert.rejects(session.prepare(), { code: "RUNTIME_COPY_BUSY" });
    assert.equal(copies, 0); assert.equal(checks, 0); assert.equal(session.status().slot, null);
    assert.equal(fs.lstatSync(f.lock).ino, identity.ino);
    if (evidence !== null) assert.equal(fs.readFileSync(owner, "utf8"), evidence);
    else assert.equal(fs.existsSync(owner), false);
  }
});

test("foreign owner change during copying is preserved and blocks runtime publication", async t => {
  const f = fixture(t);
  const foreign = { token: "foreign", sessionId: "other", extensionHostPid: 1, hostBirth: "unknown" };
  const session = createWindowSession({ ...f.options, cloneRuntime: async (...args) => {
    await f.options.cloneRuntime(...args);
    fs.writeFileSync(path.join(f.lock, "owner.json"), JSON.stringify(foreign));
  } });
  await assert.rejects(session.prepare(), { code: "RUNTIME_COPY_OWNER_CHANGED" });
  assert.deepEqual(JSON.parse(fs.readFileSync(path.join(f.lock, "owner.json"))), foreign);
  assert.equal(fs.existsSync(path.join(session.dataDir, "runtime.partial/bin/python3")), true);
  assert.equal(fs.existsSync(path.join(session.dataDir, "runtime")), false);
  assert.equal(session.status().slot, null);
});

test("replacement lock inode is never removed even if it copied the original owner", async t => {
  const f = fixture(t);
  const session = createWindowSession({ ...f.options, cloneRuntime: async (...args) => {
    await f.options.cloneRuntime(...args);
    fs.renameSync(f.lock, f.lock + ".original");
    fs.mkdirSync(f.lock);
    fs.copyFileSync(path.join(f.lock + ".original", "owner.json"), path.join(f.lock, "owner.json"));
  } });
  await assert.rejects(session.prepare(), { code: "RUNTIME_COPY_OWNER_CHANGED" });
  assert.equal(fs.existsSync(path.join(f.lock, "owner.json")), true);
  assert.equal(fs.existsSync(path.join(f.lock + ".original", "owner.json")), true);
  assert.equal(fs.existsSync(path.join(session.dataDir, "runtime")), false);
});

test("unknown capacity fails before copying and releases the owned lock", async t => {
  const f = fixture(t); let copies = 0;
  for (const bavail of [NaN, Infinity, -1]) {
    const session = createWindowSession({ ...f.options, statfsSync: () => ({ bavail, bsize: 1 }),
      cloneRuntime: async () => { copies++; } });
    await assert.rejects(session.prepare(), { code: "DISK_RESERVE_UNKNOWN" });
    assert.equal(fs.existsSync(f.lock), false); assert.equal(session.status().slot, null);
  }
  assert.equal(copies, 0);
});

test("actual processes with different state roots use the same filesystem copy lock", async t => {
  const f = fixture(t), worker = `
    const fs=require('node:fs'), path=require('node:path');
    const {createWindowSession}=require(process.argv[1]);
    const root=process.argv[2], label=process.argv[3], gate=path.join(root,'release-first');
    const sleep=ms=>new Promise(r=>setTimeout(r,ms));
    const s=createWindowSession({home:root,stateRoot:path.join(root,'state-'+label),platform:'darwin',runtimeCopyWaitMs:2000,
      readBootIdentity:()=>({platform:'darwin',id:'22222222-2222-4222-8222-222222222222'}),
      env:{MCP_STATA_RUNTIME_ROOT:path.join(root,'source')},
      snapshotProcesses:()=>[{pid:process.pid,ppid:1,birth:'2026-01-01T10:00:00Z'}],
      statfsSync:()=>{fs.writeFileSync(path.join(root,'checked-'+label),'1');return {bavail:100,bsize:1024**3}},
      cloneRuntime:async(a,b)=>{fs.writeFileSync(path.join(root,'entered-'+label),'1');
        if(label==='A'){while(!fs.existsSync(gate))await sleep(10)}
        await fs.promises.cp(a,b,{recursive:true})}});
    fs.writeFileSync(path.join(root,'started-'+label),'1');
    s.prepare().then(()=>s.finishClose({backendCleanup:'complete'})).then(()=>process.stdout.write('OK'))
      .catch(e=>{process.stderr.write(e.stack);process.exitCode=1});`;
  const children = [];
  t.after(() => { for (const child of children) if (child.exitCode === null) child.kill(); });
  function start(label) {
    const child = cp.spawn(process.execPath, ["-e", worker, require.resolve("./window_session_core"), f.root, label], { stdio: ["ignore", "pipe", "pipe"] });
    children.push(child);
    return new Promise((resolve, reject) => {
      let output = "", errors = "";
      child.stdout.on("data", d => { output += d; }); child.stderr.on("data", d => { errors += d; });
      child.on("error", reject); child.on("close", code => code === 0 ? resolve(output) : reject(new Error(errors)));
    });
  }
  async function waitFor(file) {
    const deadline = performance.now() + 3000;
    while (!fs.existsSync(file)) { assert.ok(performance.now() < deadline, "synthetic worker did not reach marker"); await delay(10); }
  }
  const first = start("A"); await waitFor(path.join(f.root, "entered-A"));
  const second = start("B"); await waitFor(path.join(f.root, "started-B")); await delay(50);
  assert.equal(fs.existsSync(path.join(f.root, "checked-B")), false);
  assert.equal(fs.existsSync(path.join(f.root, "entered-B")), false);
  fs.writeFileSync(path.join(f.root, "release-first"), "1");
  assert.deepEqual(await Promise.all([first, second]), ["OK", "OK"]);
  assert.equal(fs.existsSync(path.join(f.root, "checked-B")), true);
  assert.equal(fs.existsSync(f.lock), false);
});
