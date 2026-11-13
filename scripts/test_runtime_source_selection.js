"use strict";

// Runtime source selection for ordinary daily windows: which environment a
// window copies, and that nothing is sized or copied before it is verified.
const { test } = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const cp = require("node:child_process");
const core = require("./window_session_core");
const { venvProbe } = require("./runtime_source_fixture");
const { createWindowSession, configuredRuntimeRoot, selectRuntimeSource, inspectRuntimeSource, RUNTIME_PROBE } = core;

const WIN = { platform: "win32", home: "C:\\Users\\Example", env: { LOCALAPPDATA: "C:\\Users\\Example\\AppData\\Local" } };
const MAC = { platform: "darwin", home: "/Users/example", env: {} };
const WIN_MANAGED = "C:\\Users\\Example\\AppData\\Local\\stata-workbench\\mcp-stata-1.26.1";
const MAC_MANAGED = "/Users/example/.local/share/stata-workbench/mcp-stata-1.26.1";
// The shape of the existing Windows system MCP entry (uv base Python + custom wrapper).
const LEGACY_WRAPPER = { command: "C:\\Users\\Example\\AppData\\Roaming\\uv\\python\\cpython-3.11-windows-x86_64-none\\python.exe",
  args: ["C:\\Users\\Example\\stata_mcp_py311_server.py"], env: { MCP_STATA_TEMP: "C:\\Temp\\mcp" },
  configPath: "C:\\Users\\Example\\AppData\\Roaming\\Code\\User\\mcp.json" };
const select = (base, input) => selectRuntimeSource({ ...base, ...input });
const HOST = process.platform === "win32" ? "win32" : "darwin";

test("explicit sources rank window setting, server env, host env, then a standard venv command", () => {
  const venv = { command: "C:\\venvs\\stata\\Scripts\\python.exe", args: ["-m", "mcp_stata"] };
  const server = { ...venv, env: { MCP_STATA_RUNTIME_ROOT: "D:\\server-root" } };
  const env = { ...WIN.env, MCP_STATA_RUNTIME_ROOT: "D:\\host-root" };
  const windowRoot = { root: "E:\\window-root", scope: "workspace" };
  assert.deepEqual(select(WIN, { windowRoot, config: server, env }), { kind: "window-setting", scope: "workspace", root: "E:\\window-root", configPath: null });
  assert.equal(select(WIN, { config: server, env }).kind, "server-env");
  assert.equal(select(WIN, { config: server, env }).root, "D:\\server-root");
  assert.equal(select(WIN, { config: venv, env }).root, "D:\\host-root");
  assert.deepEqual(select(WIN, { config: venv }), { kind: "server-venv", root: "C:\\venvs\\stata", configPath: null });
  assert.deepEqual(select(WIN, { config: {} }), { kind: "managed-default", root: WIN_MANAGED, configPath: null });
  assert.equal(select({ ...WIN, env: {} }, { config: null }).root, WIN_MANAGED, "home\\AppData\\Local without LOCALAPPDATA");
  assert.equal(select(MAC, { config: { command: "/Users/example/venv/bin/python3", args: ["-m", "mcp_stata"] } }).root, "/Users/example/venv");
  assert.equal(select(MAC, { config: undefined }).root, MAC_MANAGED);
  assert.equal(select(MAC, { windowRoot: { root: "/Volumes/research/venv", scope: "user" },
    config: { env: { MCP_STATA_RUNTIME_ROOT: "/server" } }, env: { MCP_STATA_RUNTIME_ROOT: "/host" } }).root, "/Volumes/research/venv");
});

test("an invalid explicit source fails closed instead of falling back", () => {
  const fallbacks = { config: { env: { MCP_STATA_RUNTIME_ROOT: "D:\\server-root" } }, env: { MCP_STATA_RUNTIME_ROOT: "D:\\host-root" } };
  for (const root of ["relative\\venv", "venv", "C:\\venv\nnext", 7])
    assert.throws(() => select(WIN, { ...fallbacks, windowRoot: { root, scope: "workspace" } }), { code: "RUNTIME_INVALID" });
  assert.throws(() => select(WIN, { config: { env: { MCP_STATA_RUNTIME_ROOT: "relative" } }, env: fallbacks.env }), { code: "RUNTIME_INVALID" });
  assert.throws(() => select(MAC, { config: {}, env: { MCP_STATA_RUNTIME_ROOT: "relative/venv" } }), { code: "RUNTIME_INVALID" });
});

test("a custom wrapper is refused with the runtimeRoot remedy; the workspace setting fixes it", () => {
  let refused;
  assert.throws(() => select(WIN, { config: LEGACY_WRAPPER }), (error) => { refused = error; return error.code === "RUNTIME_SOURCE_UNSUPPORTED"; });
  for (const text of ["stataMcp.runtimeRoot", LEGACY_WRAPPER.configPath, WIN_MANAGED, "python.exe", "not changed"])
    assert.ok(refused.message.includes(text), text);
  assert.equal(refused.message.includes("stata_mcp_py311_server.py"), false, "wrapper arguments are not echoed");
  const fixed = select(WIN, { config: LEGACY_WRAPPER, windowRoot: { root: WIN_MANAGED, scope: "workspace" } });
  assert.deepEqual(fixed, { kind: "window-setting", scope: "workspace", root: WIN_MANAGED, configPath: LEGACY_WRAPPER.configPath });
  // Not a venv interpreter, or not the standard module launch: never guess a source.
  for (const config of [{ command: "C:\\Python311\\python.exe", args: ["-m", "mcp_stata"] },
    { command: "C:\\venvs\\stata\\Scripts\\python.exe", args: ["C:\\wrapper.py"] },
    { command: "C:\\venvs\\stata\\Scripts\\python.exe", args: ["-m", "mcp_stata", "--extra"] },
    { command: "python", args: ["-m", "mcp_stata"] }, { command: "C:\\tools\\stata-mcp.cmd", args: [] }])
    assert.throws(() => select(WIN, { config }), { code: "RUNTIME_SOURCE_UNSUPPORTED" });
  assert.throws(() => select(MAC, { config: { command: "/opt/homebrew/bin/python3.14", args: ["/Users/example/wrapper.py"] } }),
    { code: "RUNTIME_SOURCE_UNSUPPORTED" });
});

test("the standard uv package launch keeps the managed runtime; other uv tools do not", () => {
  const mac = select(MAC, { config: { command: "uvx", args: ["--refresh", "--refresh-package", "mcp-stata", "--from", "mcp-stata@latest", "mcp-stata"] } });
  assert.deepEqual(mac, { kind: "managed-default", reason: "standard uv launch", root: MAC_MANAGED, configPath: null });
  assert.equal(select(WIN, { config: { command: "C:\\tools\\uv.exe", args: ["tool", "run", "--from", "mcp-stata==1.26.1", "--with", "mcp<2", "mcp-stata"] } }).root, WIN_MANAGED);
  assert.throws(() => select(MAC, { config: { command: "uvx", args: ["other-tool"] } }), { code: "RUNTIME_SOURCE_UNSUPPORTED" });
  assert.throws(() => select(MAC, { config: { command: "uv", args: ["run", "mcp-stata"] } }), { code: "RUNTIME_SOURCE_UNSUPPORTED" });
});

test("stataMcp.runtimeRoot: only explicit values count and the nearest scope wins", () => {
  const read = (values) => configuredRuntimeRoot({ inspect: (key) => (assert.equal(key, "runtimeRoot"), values) });
  assert.equal(read({ defaultValue: "" }), null);
  assert.equal(read(undefined), null);
  assert.deepEqual(read({ globalValue: "/a" }), { root: "/a", scope: "user" });
  assert.deepEqual(read({ globalValue: "/a", workspaceValue: "/b" }), { root: "/b", scope: "workspace" });
  assert.deepEqual(read({ workspaceValue: "/b", workspaceFolderValue: "/c" }), { root: "/c", scope: "workspaceFolder" });
  assert.equal(read({ globalValue: "/a", workspaceValue: "" }), null, "an empty workspace value restores automatic selection");
  for (const value of [" ", 3, {}, "/a\tb"]) assert.throws(() => read({ workspaceValue: value }), { code: "RUNTIME_INVALID" });
});
function tempRoot(t) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "wb-runtime-source-"));
  t.after(() => fs.rmSync(root, { force: true, recursive: true }));
  return root;
}

// A synthetic environment folder in the platform's venv layout (no real interpreter).
function syntheticVenv(dir, platform, marker = "synthetic") {
  const python = platform === "win32" ? path.join(dir, "Scripts", "python.exe") : path.join(dir, "bin", "python3");
  fs.mkdirSync(path.dirname(python), { recursive: true });
  fs.writeFileSync(python, marker);
  fs.mkdirSync(path.join(dir, ...(platform === "win32" ? ["Lib"] : ["lib", "python3.11"]), "site-packages"), { recursive: true });
  return dir;
}

for (const platform of ["darwin", "win32"]) {
  test(`${platform}: the metadata probe is bounded, isolated and accepts an ordinary venv`, async (t) => {
    const root = syntheticVenv(path.join(tempRoot(t), "venv"), platform), calls = [], env = { KEEP: "1" };
    const result = await inspectRuntimeSource({ root }, { platform, env, home: root, probeRuntime: venvProbe(platform, {}, calls) });
    assert.deepEqual(result.versions, { "mcp-stata": "1.26.1", mcp: "1.28.1" });
    assert.equal(calls.length, 1);
    assert.equal(calls[0].python, platform === "win32" ? path.join(root, "Scripts", "python.exe") : path.join(root, "bin", "python3"));
    assert.deepEqual(calls[0].args, ["-I", "-B", "-c", RUNTIME_PROBE]);
    assert.ok(calls[0].options.timeout > 0 && calls[0].options.timeout <= 20000);
    assert.ok(calls[0].options.maxBuffer <= 64 * 1024);
    assert.deepEqual(calls[0].options.env, env); assert.notEqual(calls[0].options.env, env, "the probe gets a copy of the environment");
    assert.equal(/import\s+mcp_stata|from\s+mcp_stata|mcp_stata\./.test(RUNTIME_PROBE), false, "metadata only; mcp_stata is never imported");
  });

  test(`${platform}: wrong prefix, base installation and dependency facts are rejected`, async (t) => {
    const base = tempRoot(t), root = syntheticVenv(path.join(base, "venv"), platform);
    const sep = platform === "win32" ? "\\" : "/";
    const elsewhere = syntheticVenv(path.join(base, "venv-other"), platform);
    const site = (dir) => dir + sep + (platform === "win32" ? "Lib\\site-packages" : "lib/python3.11/site-packages");
    const cases = [
      ["prefix differs", (f) => ({ ...f, prefix: elsewhere })],
      ["base Python installation", (f) => ({ ...f, basePrefix: f.prefix })],
      ["mcp-stata 1.26.1 (found 1.25.0)", (f) => ({ ...f, packages: { ...f.packages, "mcp-stata": { ...f.packages["mcp-stata"], version: "1.25.0" } } })],
      ["mcp 1.x (found 2.0.0)", (f) => ({ ...f, packages: { ...f.packages, mcp: { ...f.packages.mcp, version: "2.0.0" } } })],
      ["mcp-stata 1.26.1 (found none)", (f) => ({ ...f, packages: { mcp: f.packages.mcp } })],
      ["loads mcp from outside", (f) => ({ ...f, packages: { ...f.packages, mcp: { version: "1.28.1", location: site(elsewhere) } } })],
      ["loads mcp-stata from outside", (f) => ({ ...f, packages: { ...f.packages, "mcp-stata": { version: "1.26.1", location: root + "-sibling" + sep + "site" } } })],
    ];
    for (const [text, change] of cases) {
      await assert.rejects(inspectRuntimeSource({ root }, { platform, env: {}, home: base, probeRuntime: venvProbe(platform, change) }),
        (error) => error.code === "RUNTIME_SOURCE_INVALID" && error.message.includes(text) && error.message.includes("stataMcp.runtimeRoot"), text);
    }
    const failing = async () => { throw Object.assign(new Error("exit"), { code: 1 }); };
    const timing = async () => { throw Object.assign(new Error("killed"), { killed: true, signal: "SIGTERM" }); };
    const garbled = async () => ({ stdout: "not json" });
    for (const [probeRuntime, text] of [[failing, "(1)"], [timing, "timed out"], [garbled, "SyntaxError"]])
      await assert.rejects(inspectRuntimeSource({ root }, { platform, env: {}, home: base, probeRuntime }),
        (error) => error.code === "RUNTIME_SOURCE_INVALID" && error.message.includes(text), text);
  });
}

test("win32: a base python.exe at the folder root is not a virtual environment", async (t) => {
  const root = path.join(tempRoot(t), "cpython-3.11-windows-x86_64-none");
  fs.mkdirSync(root, { recursive: true }); fs.writeFileSync(path.join(root, "python.exe"), "base");
  let probes = 0;
  await assert.rejects(inspectRuntimeSource({ root }, { platform: "win32", env: {}, home: root, probeRuntime: async () => { probes++; } }),
    (error) => error.code === "RUNTIME_SOURCE_MISSING" && error.message.includes("stataMcp.runtimeRoot"));
  assert.equal(probes, 0);
});
// prepare() on this host's platform, counting capacity checks and copies.
function windowFixture(t, extra = {}) {
  const root = tempRoot(t), counts = { statfs: 0, copies: 0 };
  const options = { home: root, stateRoot: path.join(root, "state"), platform: HOST, env: {},
    readBootIdentity: () => HOST === "win32" ? { platform: HOST, id: "2026-11-12T02:30:00.000Z" }
      : { platform: HOST, id: "22222222-2222-4222-8222-222222222222" },
    snapshotProcesses: () => [{ pid: process.pid, ppid: 1, birth: "2026-01-01T10:00:00Z" }],
    statfsSync: () => { counts.statfs++; return { bavail: 100 * 1024 ** 3, bsize: 1 }; },
    cloneRuntime: (a, b) => { counts.copies++; return fs.promises.cp(a, b, { recursive: true }); },
    probeRuntime: venvProbe(HOST), patchRuntime: () => ({ ok: true }), ...extra };
  return { root, counts, options };
}
const hostWrapper = (root) => ({ command: path.join(root, "uv-base", HOST === "win32" ? "python.exe" : "bin/python3.14"),
  args: [path.join(root, "stata_mcp_py311_server.py")], env: { MCP_STATA_TEMP: path.join(root, "mcp-temp") },
  configPath: path.join(root, "Code", "User", "mcp.json") });

test("unsupported or unverified sources are refused before sizing or copying", async (t) => {
  const f = windowFixture(t), bad = syntheticVenv(path.join(f.root, "bad-venv"), HOST);
  const attempts = [
    [{}, hostWrapper(f.root), "RUNTIME_SOURCE_UNSUPPORTED"],
    [{ env: { MCP_STATA_RUNTIME_ROOT: bad }, probeRuntime: venvProbe(HOST, (x) => ({ ...x, basePrefix: x.prefix })) }, {}, "RUNTIME_SOURCE_INVALID"],
    [{ env: { MCP_STATA_RUNTIME_ROOT: path.join(f.root, "missing") } }, {}, "RUNTIME_SOURCE_MISSING"],
    [{ windowRuntimeRoot: () => configuredRuntimeRoot({ inspect: () => ({ workspaceValue: "relative" }) }) }, {}, "RUNTIME_INVALID"],
  ];
  for (const [extra, config, code] of attempts) {
    const session = createWindowSession({ ...f.options, ...extra });
    await assert.rejects(session.prepare(config), { code });
    assert.equal(session.status().slot, null, "a refused preparation releases its slot");
    assert.equal(session.status().lastError, code);
    assert.equal(fs.existsSync(path.join(session.dataDir, "runtime")), false);
    assert.equal(fs.existsSync(path.join(session.dataDir, "mcp.json")), false);
    assert.equal(session.getRuntimeSource(), null);
  }
  assert.deepEqual(f.counts, { statfs: 0, copies: 0 });
});

test("a custom host wrapper prepares from the workspace runtimeRoot, never the wrapper's Python", async (t) => {
  const f = windowFixture(t), chosen = syntheticVenv(path.join(f.root, "verified venv"), HOST, "chosen-python");
  const managed = HOST === "win32" ? path.join(f.root, "AppData", "Local", "stata-workbench", "mcp-stata-1.26.1")
    : path.join(f.root, ".local", "share", "stata-workbench", "mcp-stata-1.26.1");
  syntheticVenv(managed, HOST, "managed-python");
  const env = HOST === "win32" ? { LOCALAPPDATA: path.join(f.root, "AppData", "Local") } : {};
  const before = { ...env };
  const session = createWindowSession({ ...f.options, env,
    windowRuntimeRoot: () => configuredRuntimeRoot({ inspect: () => ({ workspaceValue: chosen }) }) });
  const config = await session.prepare(hostWrapper(f.root));
  assert.ok(config.command.startsWith(path.join(session.dataDir, "runtime")));
  assert.equal(fs.readFileSync(config.command, "utf8"), "chosen-python", "copied from the setting, not the managed runtime");
  assert.deepEqual(config.args, ["-m", "mcp_stata"]);
  assert.equal(config.env.MCP_STATA_TEMP, path.join(session.dataDir, "mcp-temp"));
  assert.deepEqual(env, before, "parent environment untouched");
  const source = session.getRuntimeSource();
  assert.equal(source.kind, "window-setting"); assert.equal(source.scope, "workspace"); assert.equal(source.root, chosen);
  assert.equal(source.configPath, hostWrapper(f.root).configPath);
  assert.deepEqual(source.versions, { "mcp-stata": "1.26.1", mcp: "1.28.1" });
  assert.deepEqual(f.counts, { statfs: 1, copies: 1 });
  await session.finishClose({ backendCleanup: "complete" });
});

test("a missing workspace runtimeRoot never falls back to a valid host or managed runtime", async (t) => {
  const f = windowFixture(t), valid = syntheticVenv(path.join(f.root, "valid"), HOST);
  const session = createWindowSession({ ...f.options, env: { MCP_STATA_RUNTIME_ROOT: valid },
    windowRuntimeRoot: () => ({ root: path.join(f.root, "not-there"), scope: "workspace" }) });
  await assert.rejects(session.prepare({ env: { MCP_STATA_RUNTIME_ROOT: valid } }),
    (error) => error.code === "RUNTIME_SOURCE_MISSING" && error.message.includes("not-there"));
  assert.deepEqual(f.counts, { statfs: 0, copies: 0 });
});

test("a failed patch binds the completed copy: changed source is refused, unchanged source can recover", async (t) => {
  const f = windowFixture(t), a = syntheticVenv(path.join(f.root, "source-A"), HOST, "A"),
    b = syntheticVenv(path.join(f.root, "source-B"), HOST, "B");
  let chosen = a, patches = 0;
  const session = createWindowSession({ ...f.options, windowRuntimeRoot: () => ({ root: chosen, scope: "workspace" }),
    patchRuntime: () => ({ ok: ++patches > 1, status: "first patch failed" }) });
  await assert.rejects(session.prepare({}), { code: "RUNTIME_PATCH_FAILED" });
  const originPath = path.join(session.dataDir, "runtime-origin.json"), original = fs.readFileSync(originPath),
    runtime = path.join(session.dataDir, "runtime");
  assert.equal(session.getRuntimeSource().root, a);
  chosen = b;
  await assert.rejects(session.prepare({}), { code: "RUNTIME_SOURCE_CHANGED" });
  assert.equal(fs.readFileSync(core.runtimePython(runtime, HOST), "utf8"), "A");
  assert.equal(session.getRuntimeSource().root, a, "never report the rejected source as the copied source");
  assert.deepEqual(fs.readFileSync(originPath), original, "the original receipt is immutable");
  assert.equal(session.status().slot, null); assert.equal(patches, 1);
  chosen = a;
  const config = await session.prepare({});
  assert.equal(fs.readFileSync(config.command, "utf8"), "A");
  assert.deepEqual(f.counts, { statfs: 1, copies: 1 }); assert.equal(patches, 2);
  await session.finishClose({ backendCleanup: "complete" });
});

test("source bytes changed at the same path are refused even when package versions are unchanged", async (t) => {
  const f = windowFixture(t), source = syntheticVenv(path.join(f.root, "source"), HOST, "original");
  const session = createWindowSession({ ...f.options, env: { MCP_STATA_RUNTIME_ROOT: source },
    patchRuntime: () => ({ ok: false, status: "patch failed" }) });
  await assert.rejects(session.prepare({}), { code: "RUNTIME_PATCH_FAILED" });
  const original = session.getRuntimeSource().contentSha256;
  fs.writeFileSync(core.runtimePython(source, HOST), "changed");
  await assert.rejects(session.prepare({}), { code: "RUNTIME_SOURCE_CHANGED" });
  assert.equal(session.getRuntimeSource().contentSha256, original);
  assert.equal(fs.readFileSync(core.runtimePython(path.join(session.dataDir, "runtime"), HOST), "utf8"), "original");
  assert.deepEqual(f.counts, { statfs: 1, copies: 1 });
});

for (const invalidOrigin of ["missing", "malformed", "provenance-mismatch", "different-directory"]) {
  test(`a private runtime with ${invalidOrigin} origin proof is preserved and refused`, async (t) => {
    const f = windowFixture(t), source = syntheticVenv(path.join(f.root, "source"), HOST);
    let patches = 0;
    const session = createWindowSession({ ...f.options, env: { MCP_STATA_RUNTIME_ROOT: source },
      patchRuntime: () => { patches++; return { ok: false, status: "patch failed" }; } });
    await assert.rejects(session.prepare({}), { code: "RUNTIME_PATCH_FAILED" });
    const origin = path.join(session.dataDir, "runtime-origin.json"), runtime = path.join(session.dataDir, "runtime");
    if (invalidOrigin === "missing") fs.unlinkSync(origin);
    else if (invalidOrigin === "malformed") fs.writeFileSync(origin, "not JSON");
    else if (invalidOrigin === "provenance-mismatch") {
      const record = JSON.parse(fs.readFileSync(origin, "utf8")); record.provenance.contentSha256 = "0".repeat(64);
      fs.writeFileSync(origin, JSON.stringify(record));
    }
    else { fs.renameSync(runtime, runtime + ".preserved"); fs.cpSync(source, runtime, { recursive: true }); }
    await assert.rejects(session.prepare({}), { code: "RUNTIME_ORIGIN_UNVERIFIED" });
    assert.ok(fs.existsSync(core.runtimePython(runtime, HOST))); assert.equal(patches, 1);
    assert.deepEqual(f.counts, { statfs: 1, copies: 1 }); assert.equal(session.status().slot, null);
  });
}

test("a copied runtime is re-probed before retrying a failed patch", async (t) => {
  const f = windowFixture(t), source = syntheticVenv(path.join(f.root, "source"), HOST);
  let invalid = false, patches = 0, session;
  const probe = venvProbe(HOST), badProbe = venvProbe(HOST, (facts) => ({ ...facts, packages: {} }));
  session = createWindowSession({ ...f.options, env: { MCP_STATA_RUNTIME_ROOT: source },
    probeRuntime: (python, ...args) => (invalid && python.startsWith(session.dataDir) ? badProbe : probe)(python, ...args),
    patchRuntime: () => { patches++; return { ok: false, status: "patch failed" }; } });
  await assert.rejects(session.prepare({}), { code: "RUNTIME_PATCH_FAILED" });
  invalid = true;
  await assert.rejects(session.prepare({}), { code: "RUNTIME_SOURCE_INVALID" });
  assert.equal(patches, 1); assert.deepEqual(f.counts, { statfs: 1, copies: 1 });
});

test("a source directory alias produces a private directory, and patching it leaves the source unchanged", async (t) => {
  const f = windowFixture(t), source = syntheticVenv(path.join(f.root, "source"), HOST, "original"), alias = path.join(f.root, "alias");
  fs.symlinkSync(source, alias, process.platform === "win32" ? "junction" : "dir");
  if (process.platform !== "win32") fs.symlinkSync(path.basename(core.runtimePython(source, HOST)), path.join(source, "bin", "python-link"));
  const cloneRuntime = process.platform === "linux" ? (a, b) => fs.promises.cp(a, b, { recursive: true, verbatimSymlinks: true }) : undefined;
  const session = createWindowSession({ ...f.options, cloneRuntime, env: { MCP_STATA_RUNTIME_ROOT: alias },
    patchRuntime: ({ runtimeRoot }) => { fs.writeFileSync(core.runtimePython(runtimeRoot, HOST), "private-patch"); return { ok: true }; } });
  const config = await session.prepare({}), runtime = path.join(session.dataDir, "runtime");
  assert.equal(fs.lstatSync(runtime).isSymbolicLink(), false);
  assert.notEqual(fs.realpathSync(runtime), fs.realpathSync(source));
  assert.equal(fs.readFileSync(core.runtimePython(source, HOST), "utf8"), "original");
  assert.equal(fs.readFileSync(config.command, "utf8"), "private-patch");
  if (process.platform !== "win32") assert.equal(fs.readlinkSync(path.join(runtime, "bin", "python-link")), path.basename(config.command));
  await session.finishClose({ backendCleanup: "complete" });
});

for (const defect of ["source-changed", "copy-corrupted", "copy-failed"]) {
  test(`${defect} leaves partial evidence without creating an origin binding`, async (t) => {
    const f = windowFixture(t), source = syntheticVenv(path.join(f.root, "source"), HOST, "original");
    const session = createWindowSession({ ...f.options, env: { MCP_STATA_RUNTIME_ROOT: source },
      cloneRuntime: async (a, b) => {
        await f.options.cloneRuntime(a, b);
        if (defect === "source-changed") fs.writeFileSync(core.runtimePython(a, HOST), "changed");
        else if (defect === "copy-corrupted") fs.writeFileSync(core.runtimePython(b, HOST), "corrupted");
        else throw Object.assign(new Error("copy interrupted"), { code: "EIO" });
      } });
    const code = { "source-changed": "RUNTIME_SOURCE_CHANGED", "copy-corrupted": "RUNTIME_COPY_INVALID", "copy-failed": "EIO" }[defect];
    await assert.rejects(session.prepare({}), { code });
    assert.ok(fs.existsSync(path.join(session.dataDir, "runtime.partial")));
    assert.equal(fs.existsSync(path.join(session.dataDir, "runtime")), false);
    assert.equal(fs.existsSync(path.join(session.dataDir, "runtime-origin.json")), false);
    assert.equal(session.getRuntimeSource(), null);
    await assert.rejects(session.prepare({}), { code: "RUNTIME_INCOMPLETE" });
    assert.deepEqual(f.counts, { statfs: 1, copies: 1 });
  });
}

test("with no configuration the managed runtime remains the default", async (t) => {
  const f = windowFixture(t);
  const managed = HOST === "win32" ? path.join(f.root, "Local", "stata-workbench", "mcp-stata-1.26.1")
    : path.join(f.root, ".local", "share", "stata-workbench", "mcp-stata-1.26.1");
  syntheticVenv(managed, HOST, "managed-python");
  const session = createWindowSession({ ...f.options, env: HOST === "win32" ? { LOCALAPPDATA: path.join(f.root, "Local") } : {} });
  const config = await session.prepare(null);
  assert.equal(fs.readFileSync(config.command, "utf8"), "managed-python");
  assert.equal(session.getRuntimeSource().kind, "managed-default");
  await session.finishClose({ backendCleanup: "complete" });
});
function hostPython() {
  for (const candidate of [process.env.STATA_WORKBENCH_PYTHON, process.env.PYTHON, process.platform === "win32" ? "python" : "python3"]) {
    if (!candidate) continue;
    const r = cp.spawnSync(candidate, ["-I", "-c", "import sys; print(sys.version_info[:2] >= (3, 10))"], { encoding: "utf8", timeout: 20000 });
    if (r.status === 0 && r.stdout.trim() === "True") return candidate;
  }
  return null;
}

test("a real venv is verified from metadata alone, including a macOS symlinked interpreter", async (t) => {
  const python = hostPython();
  if (!python) return t.skip("no Python 3.10+ on this host");
  const base = tempRoot(t), venv = path.join(base, "real venv");
  const made = cp.spawnSync(python, ["-m", "venv", "--without-pip", venv], { encoding: "utf8", timeout: 120000 });
  assert.equal(made.status, 0, made.stderr);
  const interpreter = process.platform === "win32" ? path.join(venv, "Scripts", "python.exe") : path.join(venv, "bin", "python3");
  const paths = JSON.parse(cp.execFileSync(interpreter, ["-I", "-c",
    "import json, sys, sysconfig; print(json.dumps([sysconfig.get_paths()['purelib'], sys.base_prefix]))"], { encoding: "utf8" }));
  const [site, basePrefix] = paths, tripwire = path.join(base, "imported");
  for (const [dir, name, version] of [["mcp_stata-1.26.1.dist-info", "mcp-stata", "1.26.1"], ["mcp-1.28.1.dist-info", "mcp", "1.28.1"]]) {
    fs.mkdirSync(path.join(site, dir), { recursive: true });
    fs.writeFileSync(path.join(site, dir, "METADATA"), `Metadata-Version: 2.1\nName: ${name}\nVersion: ${version}\n`);
  }
  fs.mkdirSync(path.join(site, "mcp_stata"));
  fs.writeFileSync(path.join(site, "mcp_stata", "__init__.py"), `open(${JSON.stringify(tripwire)}, "w").close()\n`);
  const options = { platform: process.platform === "win32" ? "win32" : "darwin", env: { ...process.env }, home: base };
  if (process.platform === "linux") options.platform = "linux";
  const verified = await inspectRuntimeSource({ root: venv }, options);
  assert.deepEqual(verified.versions, { "mcp-stata": "1.26.1", mcp: "1.28.1" });
  assert.equal(fs.existsSync(tripwire), false, "mcp_stata was not imported");
  if (process.platform !== "win32") {
    assert.ok(fs.lstatSync(interpreter).isSymbolicLink() || fs.lstatSync(path.join(venv, "bin", "python")).isSymbolicLink(),
      "the venv interpreter is a link to its base Python");
    const link = path.join(base, "linked venv"); fs.symlinkSync(venv, link);
    assert.deepEqual((await inspectRuntimeSource({ root: link }, options)).versions, verified.versions);
  }
  await assert.rejects(inspectRuntimeSource({ root: basePrefix }, options),
    (error) => ["RUNTIME_SOURCE_INVALID", "RUNTIME_SOURCE_MISSING"].includes(error.code), "the base installation is not a source");
  fs.rmSync(path.join(site, "mcp-1.28.1.dist-info"), { recursive: true });
  await assert.rejects(inspectRuntimeSource({ root: venv }, options),
    (error) => error.code === "RUNTIME_SOURCE_INVALID" && error.message.includes("mcp 1.x (found none)"));
});

function vscodeHarness(workspaceValue, hostConfig, f) {
  const context = { subscriptions: [], extensionUri: { fsPath: "/installed/extension" } }, commands = new Map(), shown = [];
  const vscode = { env: {}, StatusBarAlignment: { Left: 1 },
    workspace: { workspaceFolders: [{ uri: { scheme: "file", fsPath: f.root } }],
      getConfiguration: (section) => ({ get: () => 0,
        inspect: (key) => section === "stataMcp" && key === "runtimeRoot" && workspaceValue !== undefined ? { defaultValue: "", workspaceValue } : {} }) },
    commands: { registerCommand: (name, fn) => { commands.set(name, fn); return { dispose() {} }; }, executeCommand: async () => {} },
    window: { createStatusBarItem: () => ({ show() {}, dispose() {} }), showErrorMessage: (message) => { shown.push(message); } } };
  let connected = 0;
  const client = { _loadServerConfig: () => hostConfig, _log() {},
    async _ensureClient() { connected++; return "connected"; }, connect() { return this._ensureClient(); } };
  const manager = require("./window_session_vscode").install(context, vscode, client, f.options);
  return { manager, commands, shown, context, connected: () => connected };
}

test("VS Code: the workspace runtimeRoot fixes a custom host wrapper without touching process.env", async (t) => {
  const f = windowFixture(t), chosen = syntheticVenv(path.join(f.root, "workspace venv"), HOST, "workspace-python");
  const before = JSON.stringify({ ...process.env });
  const h = vscodeHarness(chosen, hostWrapper(f.root), f);
  await h.commands.get("stata-workbench.startSession")();
  assert.deepEqual(h.shown, []);
  assert.equal(h.connected(), 1);
  assert.equal(fs.readFileSync(h.manager.getConfig().command, "utf8"), "workspace-python");
  const runtime = h.manager.registryFields().runtime;
  assert.equal(runtime.source.kind, "window-setting"); assert.equal(runtime.source.root, chosen);
  assert.equal(JSON.stringify({ ...process.env }), before, "parent environment was not mutated");
  await h.manager.finishClose({ backendCleanup: "complete" });
  for (const d of h.context.subscriptions) d.dispose();
});

test("VS Code: an invalid runtimeRoot is reported at session start, without fallback or activation failure", async (t) => {
  const f = windowFixture(t), valid = syntheticVenv(path.join(f.root, "valid"), HOST);
  const h = vscodeHarness("relative" + path.sep + "venv", { env: { MCP_STATA_RUNTIME_ROOT: valid } }, f);
  await h.commands.get("stata-workbench.startSession")();
  assert.equal(h.connected(), 0);
  assert.equal(h.shown.length, 1);
  assert.match(h.shown[0], /RUNTIME_INVALID: stataMcp\.runtimeRoot \(workspace setting\) must be an absolute folder path/);
  assert.deepEqual(f.counts, { statfs: 0, copies: 0 });
  for (const d of h.context.subscriptions) d.dispose();
});

test("package.json declares the machine-overridable runtimeRoot setting with an empty default", () => {
  const setting = require("../package.json").contributes.configuration.properties["stataMcp.runtimeRoot"];
  assert.equal(setting.type, "string"); assert.equal(setting.default, ""); assert.equal(setting.scope, "machine-overridable");
  assert.match(setting.markdownDescription, /never replaced by another source/);
});
