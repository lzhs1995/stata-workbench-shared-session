#!/usr/bin/env node
"use strict";

// 回归：Next 阶段 D（多会话）。
// 1. next_multi_session_core：会话名规则与优先级、会话目录、TMPDIR、backendPid、注册表字段。
// 2. next_bridge_auth_core.update：补字段、身份与 token 不可改、没变不写盘、写失败留旧记录、改写后仍只删自己。
// 3. 两个会话并排：各自记录、各自 token，关一个只删它自己的。
// 4. 补丁可逆、紧跟上一层（E）、锚点取自 C、缺失即拒绝、只用 ASCII、不改 B/C 写入的字符。
// 5. 把 bundle 里真实的激活语句和 /status 片段放进沙盒跑：会话名、TMPDIR、注册表刷新、generation 变化。
const assert = require("node:assert/strict");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const multi = require("./next_multi_session_core");
const auth = require("./next_bridge_auth_core");
const patch = require("./apply_next_multi_session_patch");
const C = require("./apply_next_bridge_auth_patch");
const fingerprint = require("./finalize_bundle_identity");
const { LATER, revertAfter } = require("./later_bundle_patches");
const daily = require("./test_daily_bundle_helpers");

const root = path.resolve(__dirname, "..");
const bundle = fs.readFileSync(path.join(root, "dist", "extension.js"), "utf8");
const tmp = fs.mkdtempSync(path.join(os.tmpdir(), "wb-next-multi-"));
const posix = process.platform !== "win32";
let checks = 0;
const ok = (cond, msg) => { assert.ok(cond, msg); checks++; };
const read = (file) => JSON.parse(fs.readFileSync(file, "utf8"));

try {
  // 1. Historical multi-session core helpers (including legacy env mutation).
  // Actual final ordinary-window activation is exercised separately below.
  for (const good of ["default", "p1", "Model-2", "a_b", "x".repeat(40)]) ok(multi.sanitizeSessionName(good) === good, "name ok " + good);
  for (const bad of ["", " ", "-lead", "has space", "x".repeat(41), "../up", "a/b", "中文", null, undefined]) {
    ok(multi.sanitizeSessionName(bad) === null, "name rejected " + JSON.stringify(bad));
  }
  ok(multi.resolveSessionName({ STATA_WORKBENCH_NEXT_SESSION: "envName" }, "cfgName") === "envName", "env wins over settings");
  ok(multi.resolveSessionName({}, "cfgName") === "cfgName", "settings used without env");
  ok(multi.resolveSessionName({ STATA_WORKBENCH_NEXT_SESSION: "bad name" }, "cfgName") === "cfgName", "invalid env ignored");
  ok(multi.resolveSessionName({}, null) === "default", "default name");

  const dataDir = path.join(tmp, "runs", "sA");
  const dirs = multi.sessionDirs(dataDir, { MCP_STATA_TEMP: path.join(tmp, "mcp-temp-A") });
  ok(dirs.tempDir === path.join(dataDir, "tmp") && fs.statSync(dirs.tempDir).isDirectory(), "session tmp created under its own run dir");
  if (posix) ok((fs.statSync(dirs.tempDir).mode & 0o777) === 0o700, "session tmp is 0700");
  ok(dirs.checkpointDir === dirs.tempDir, "checkpoints go to the session tmp");
  ok(dirs.logDir === path.join(tmp, "mcp-temp-A") && dirs.graphDir === dirs.logDir, "backend logs/graphs follow this session's MCP_STATA_TEMP");
  ok(multi.sessionDirs(dataDir, { MCP_STATA_TEMP: "relative/dir" }).logDir === dirs.tempDir, "relative MCP_STATA_TEMP ignored");

  const envPosix = { TMPDIR: "/old" };
  multi.applyTempDir(envPosix, "/s/tmp", "darwin");
  ok(envPosix.TMPDIR === "/s/tmp" && envPosix.TEMP === undefined, "darwin: TMPDIR only");
  const envWin = { TEMP: "C:\\old", TMP: "C:\\old" };
  multi.applyTempDir(envWin, "C:\\s\\tmp", "win32");
  ok(envWin.TEMP === "C:\\s\\tmp" && envWin.TMP === "C:\\s\\tmp" && envWin.TMPDIR === "C:\\s\\tmp", "win32: TEMP and TMP too");
  const savedTmp = { TMPDIR: process.env.TMPDIR, TEMP: process.env.TEMP, TMP: process.env.TMP };
  try {
    multi.applyTempDir(process.env, dirs.tempDir);
    ok(path.resolve(os.tmpdir()) === path.resolve(dirs.tempDir), "os.tmpdir() follows the session tmp at call time");
  } finally {
    for (const [k, v] of Object.entries(savedTmp)) { if (v === undefined) delete process.env[k]; else process.env[k] = v; }
  }

  // 运行时配置：环境变量优先；没有才用 settings，并写进 env 供 bundle 懒读；相对路径不认
  const cfgFile = path.join(tmp, "mcp-A.json");
  fs.writeFileSync(cfgFile, JSON.stringify({ servers: { mcp_stata: { command: "/r/bin/python3", env: { MCP_STATA_TEMP: path.join(tmp, "mt") } } } }));
  const e1 = {};
  const rc1 = multi.applyRuntimeConfig(e1, cfgFile);
  ok(e1.MCP_STATA_CONFIG_PATH === cfgFile && rc1.configPath === cfgFile && rc1.backendTemp === path.join(tmp, "mt"), "settings config applied when env is empty");
  const e2 = { MCP_STATA_CONFIG_PATH: "/from/env.json" };
  const rc2 = multi.applyRuntimeConfig(e2, cfgFile);
  ok(e2.MCP_STATA_CONFIG_PATH === "/from/env.json" && rc2.configPath === path.resolve("/from/env.json") && rc2.backendTemp === null, "env config wins; unreadable -> no backendTemp");
  const e3 = {};
  ok(multi.applyRuntimeConfig(e3, "relative.json").configPath === null && !("MCP_STATA_CONFIG_PATH" in e3), "relative settings path ignored");

  const owned = new Map([[11, {}], [22, {}], [33, {}]]);
  ok(multi.latestBackendPid(owned, () => true) === 33, "latest owned backend pid");
  ok(multi.latestBackendPid(owned, (p) => p !== 33) === 22, "dead latest skipped");
  ok(multi.latestBackendPid(new Map(), () => true) === null && multi.latestBackendPid(null) === null, "no backend -> null");

  const fields = multi.registryFields({ sessionName: "p1", profilePath: "/abs/p1", workspacePath: "rel/ws", dirs, generation: 3,
    backendPid: 4242, diskBundleSha256: "a".repeat(64), token: "leak" });
  ok(fields.sessionName === "p1" && fields.profilePath === path.resolve("/abs/p1") && fields.workspacePath === null, "fields kept, relative path dropped");
  ok(fields.generation === 3 && fields.backendPid === 4242 && fields.diskBundleSha256 === "a".repeat(64), "generation/backend/bundle");
  ok(!("token" in fields) && !("port" in fields) && !("sessionId" in fields), "fields never carry identity or token");
  for (const key of ["sessionName", "backendPid", "profilePath", "workspacePath", "tempDir", "logDir", "graphDir", "checkpointDir", "generation"]) {
    ok(key in fields, "plan field present: " + key);
  }
  ok(multi.registryFields({ generation: -1, backendPid: 1, diskBundleSha256: "XYZ" }).generation === 0, "bad generation -> 0");
  ok(!JSON.stringify(multi.publicMulti({ sessionName: "p1", dirs })).includes("token"), "public view has no token");

  // 2. update()
  const stateRoot = path.join(tmp, "state");
  const a = auth.createAuth({ stateRoot, sessionId: "sA" });
  ok(a.update({ generation: 1 }).error === "not published", "update before publish refused");
  a.publish({ port: 17601, extensionHostPid: process.pid });
  const tokenA = read(a.recordPath).token;
  const r1 = a.update({ ...fields, port: 1, token: "x", sessionId: "evil", schema: "evil", extensionHostPid: 1, startedAt: "x" });
  const recA = read(a.recordPath);
  ok(r1.changed === true && recA.sessionName === "p1" && recA.generation === 3, "update adds D fields");
  ok(recA.port === 17601 && recA.token === tokenA && recA.sessionId === "sA" && recA.schema === auth.RECORD_SCHEMA
    && recA.extensionHostPid === process.pid && recA.startedAt !== "x", "identity fields and token cannot be overridden");
  if (posix) ok((fs.statSync(a.recordPath).mode & 0o777) === 0o600, "rewritten record stays 0600");
  const inode = fs.statSync(a.recordPath).ino;
  ok(a.update({ ...fields }).changed === false && fs.statSync(a.recordPath).ino === inode, "unchanged fields -> no rewrite");
  ok(a.update({ ...fields, generation: 4 }).changed === true && read(a.recordPath).generation === 4, "generation change rewrites");
  ok(fs.readdirSync(path.join(stateRoot, "sessions")).filter((n) => n.endsWith(".tmp")).length === 0, "no temp files left");

  // Windows 路径：限权读回不合格时 update 失败，盘上留旧记录
  const SID = "S-1-5-21-1-2-3-1001";
  const good = [`SID=${SID}`, "PROTECTED=True", "COUNT=1", `RULE=${SID}|Allow|False|2032127`].join("\r\n");
  let aclOut = good;
  const w = auth.createAuth({ stateRoot: path.join(tmp, "win"), sessionId: "sW", platform: "win32", env: {}, execFileSync: () => aclOut });
  w.publish({ port: 17602, extensionHostPid: process.pid });
  w.update({ generation: 1 });
  aclOut = good.replace("PROTECTED=True", "PROTECTED=False");
  const failed = w.update({ generation: 2 });
  ok(failed.changed === false && /not owner-only/.test(failed.error) && read(w.recordPath).generation === 1, "failed rewrite keeps the old record");
  ok(fs.readdirSync(path.join(tmp, "win", "sessions")).length === 1, "failed rewrite leaves no temp file");

  // 3. 两个会话并排
  const b = auth.createAuth({ stateRoot, sessionId: "sB" });
  b.publish({ port: 17602, extensionHostPid: process.pid });
  b.update(multi.registryFields({ sessionName: "p2", generation: 0 }));
  const both = fs.readdirSync(path.join(stateRoot, "sessions")).filter((n) => n.endsWith(".json")).sort();
  ok(JSON.stringify(both) === JSON.stringify(["sA.json", "sB.json"]), "two records side by side");
  ok(read(b.recordPath).token !== tokenA && read(b.recordPath).sessionName === "p2", "separate tokens and names");
  a.remove();
  ok(!fs.existsSync(a.recordPath) && fs.existsSync(b.recordPath), "closing one window removes only its record (after rewrites)");
  b.remove();

  // 4. 补丁
  // Exact historical layer; final runtime behavior remains below.
  assert.equal(fingerprint.verify(bundle).ok, true);
  const name = "./apply_next_multi_session_patch";
  const sealed = daily.historicalLayer(bundle, name);
  assert.equal(patch.patchBundle(sealed), sealed, "historical byte idempotence");
  const below = patch.revertBundle(sealed);
  assert.equal(below, revertAfter(bundle, LATER[LATER.indexOf(name) - 1]), "directly follows the previous later layer");
  // E（PR #6，先合并）排在 C 与 D 之间；D 的锚点仍是 C 插入的文本，E 不改它们
  assert.ok(LATER[LATER.indexOf(name) - 1] === "./apply_edit_proposal_patch", "stacked on E");
  assert.ok(LATER.indexOf("./apply_next_bridge_auth_patch") < LATER.indexOf(name), "after C");
  assert.equal(patch.patchBundle(below), sealed, "replay reproduces the sealed layer");
  assert.throws(() => patch.patchBundle(below.replace(C.EDITS[2][1], "")), /anchor/);
  assert.throws(() => patch.patchBundle(below + "__codexNextMultiRef"), /partial/);
  checks += 8;
  ok(!/[^\x00-\x7f]/.test(patch.EDITS.map((e) => e[1]).join("")), "patch strings are ASCII only");
  for (const [, after] of C.EDITS) ok(sealed.includes(after), "historical C text intact before daily binding");
  ok(bundle.includes(C.EDITS[2][1] + patch.REFRESH), "registry refresh runs right after the auth gate");
  ok(bundle.indexOf(C.EDITS[2][1] + patch.REFRESH) < bundle.indexOf('__req.url==="/status"'), "refresh precedes the /status route");
  const bound = daily.between(bundle, "onBound:__state=>{", ",onTerminalError:");
  ok(bound.includes("__port=__state.port;"), "final callback uses the actual bound port");
  ok(bound.includes(C.EDITS[1][1].slice(C.EDITS[1][1].indexOf("try{let __ns=")) + patch.REFRESH), "registry completed right after publish");
  ok(bundle.split("globalThis.__codexNextAuthRef.publish(").length === 2, "still published only from onBound");
  ok(!bundle.includes("__codexNextAuthRef.token") && !patch.ACTIVATE.includes(".token"), "no code reads a raw token");

  // 5. 沙盒里跑 bundle 里真实的激活语句
  const activate = bundle.slice(bundle.indexOf(C.MARKER) + C.MARKER.length, bundle.indexOf(patch.MARKER) + patch.MARKER.length);
  ok(activate.includes("__wm=globalThis.__codexWindowSession"), "final activation binds manager identity");
  ok(!activate.includes("applyTempDir(process.env"), "final activation never mutates parent temp environment");
  const sandboxRoot = path.join(tmp, "sandbox");
  const g = {};
  const fakeEnv = { STATA_WORKBENCH_NEXT_SESSION: "envSession", MCP_STATA_TEMP: path.join(sandboxRoot, "mcp-temp"),
    STATA_WORKBENCH_NEXT_PROFILE: path.join(sandboxRoot, "profiles", "p1") };
  const killed = [];
  const fakeProcess = { pid: process.pid, env: fakeEnv, cwd: () => root, kill: (pid) => { killed.push(pid); if (pid === 999999) { const e = new Error("x"); e.code = "ESRCH"; throw e; } return true; } };
  const settings = { nextSessionName: "fromSettings", nextProfilePath: "/ignored/because/env" };
  const iA = { workspace: { getConfiguration: () => ({ get: (k, d) => (k in settings ? settings[k] : d) }),
    workspaceFolders: [{ uri: { scheme: "file", fsPath: path.join(sandboxRoot, "ws") } }] } };
  const session = { sessionId: "sSandbox", dataDir: path.join(sandboxRoot, "runs", "sSandbox") };
  g.__codexNextSessionRef = session;
  const windowDirs={tempDir:path.join(session.dataDir,"tmp"),checkpointDir:path.join(session.dataDir,"checkpoints"),logDir:path.join(session.dataDir,"logs"),graphDir:path.join(session.dataDir,"graphs")};
  g.__codexWindowSession={sessionName:"window-A",registryFields:()=>({ordinaryWindow:true,sessionName:"window-A",profilePath:session.dataDir,workspacePath:path.join(sandboxRoot,"ws"),dirs:windowDirs})};
  const beforeEnv={...fakeEnv};
  const run = new Function("globalThis", "iA", "rg", "yC", "g", "require", "process", activate);
  run(g, iA, path, { extensionUri: { fsPath: root } }, { extensionUri: { fsPath: root } }, require, fakeProcess);
  ok(!g.__codexNextMultiError, "activation ran: " + g.__codexNextMultiError);
  ok(g.__codexNextMultiRef.sessionName === "window-A", "session name from ordinary-window manager");
  assert.deepEqual(fakeEnv,beforeEnv,"parent environment unchanged");
  ok(g.__codexNextMultiRef.dirs.tempDir===windowDirs.tempDir,"registry uses window temp directory");
  ok(g.__codexNextMultiRef.profilePath === session.dataDir, "private run directory from window manager");
  ok(g.__codexNextMultiRef.workspacePath === path.join(sandboxRoot, "ws"), "workspace folder recorded");

  const live = auth.createAuth({ stateRoot: path.join(sandboxRoot, "state"), sessionId: "sSandbox" });
  g.__codexNextAuthRef = live;
  g.__codexNextRegistryRefresh();
  ok(g.__codexNextMultiRef.refreshes === 0 && !g.__codexNextMultiRef.lastError, "refresh before publish is a quiet no-op");
  g.__codexResetGeneration = 0;
  g.__codexOwnedBackendPids = new Map([[4321, {}], [999999, {}]]);
  g.__codexBundleIdentityStatus = () => ({ diskBundleSha256: "b".repeat(64) });
  const onBound = new Function("globalThis", "process", "RI", "let __port=0;return ({" + bound + "}).onBound;")(g, fakeProcess, () => {});
  onBound({ port: 17603, attempts: 1 });
  let rec = read(live.recordPath);
  ok(rec.port === 17603 && g.__codexBridgePort === 17603, "actual onBound publishes allocated port, not requested zero");
  ok(rec.sessionName === "window-A" && rec.generation === 0 && rec.backendPid === 4321 && rec.diskBundleSha256 === "b".repeat(64),
    "refresh writes name, generation, live backend pid, bundle sha");
  ok(rec.tempDir === windowDirs.tempDir && rec.checkpointDir === windowDirs.checkpointDir && rec.logDir === windowDirs.logDir, "dirs in the registry");
  const ino = fs.statSync(live.recordPath).ino;
  g.__codexNextRegistryRefresh();
  ok(fs.statSync(live.recordPath).ino === ino, "repeated refresh does not rewrite");
  g.__codexResetGeneration = 2;
  g.__codexNextRegistryRefresh();
  rec = read(live.recordPath);
  ok(rec.generation === 2 && g.__codexNextMultiRef.refreshes === 2, "generation bump rewrites the record");

  const status = daily.between(bundle, "nextMulti:globalThis.__codexNextMultiRef", "ownedBackendPids:");
  const statusPart = new Function("globalThis", "return {" + status + "}")(g);
  ok(statusPart.nextMulti.sessionName === "window-A" && !JSON.stringify(statusPart).includes(rec.token), "actual /status nextMulti without token");
  const noMulti = new Function("globalThis", "return {" + status + "}")({ __codexNextMultiError: "boom" });
  ok(noMulti.nextMulti.error === "boom", "/status explains a disabled D layer");

  // Historical settings-only activation; exact peeled bytes, not final runtime.
  const historicalActivate = sealed.slice(sealed.indexOf(C.MARKER) + C.MARKER.length, sealed.indexOf(patch.MARKER) + patch.MARKER.length);
  assert.equal(historicalActivate, patch.ACTIVATE);
  const g3 = { __codexNextSessionRef: { sessionId: "sSet", dataDir: path.join(sandboxRoot, "runs", "sSet") } };
  const env3 = {};
  const iA3 = { workspace: { getConfiguration: () => ({ get: (k, d) => ({ nextSessionName: "p3", nextMcpConfigPath: cfgFile })[k] ?? d }),
    workspaceFolders: [] } };
  new Function("globalThis", "iA", "rg", "yC", "require", "process", historicalActivate)(g3, iA3, path, { extensionUri: { fsPath: root } }, require, { env: env3, cwd: () => root });
  ok(!g3.__codexNextMultiError && g3.__codexNextMultiRef.sessionName === "p3", "settings-only: name from settings");
  ok(env3.MCP_STATA_CONFIG_PATH === cfgFile, "settings-only: MCP_STATA_CONFIG_PATH set before the backend starts");
  ok(g3.__codexNextMultiRef.dirs.logDir === path.join(tmp, "mt") && env3.MCP_STATA_TEMP === undefined, "settings-only: logDir from the config, MCP_STATA_TEMP not leaked");
  ok(g3.__codexNextMultiRef.workspacePath === null, "no workspace folder -> null");
  const historical = daily.beforeDaily(bundle);
  const hhg = historical.indexOf("function HHg(g){yC=g;");
  const lazy = historical.indexOf("let __runtimeIsolation=!!uM().MCP_STATA_CONFIG_PATH");
  ok(hhg > 0 && hhg < historical.indexOf(patch.MARKER) && historical.indexOf(patch.MARKER) < lazy, "historical D config preceded eager runtime resolution");

  // Historical failure only disables D; daily activation instead fails closed.
  const g2 = {};
  const env2 = { TMPDIR: "/keep" };
  new Function("globalThis", "iA", "rg", "yC", "require", "process", historicalActivate)(g2, iA, path, { extensionUri: { fsPath: root } }, require, { env: env2, cwd: () => root });
  ok(/session unavailable/.test(g2.__codexNextMultiError) && env2.TMPDIR === "/keep" && !g2.__codexNextRegistryRefresh, "no session -> D disabled, TMPDIR untouched");
  assert.throws(() => run({}, iA, path, { extensionUri: { fsPath: root } }, { extensionUri: { fsPath: root } }, require, fakeProcess), /registryFields/, "daily activation requires the ordinary-window manager");
  assert.deepEqual(fakeEnv, beforeEnv, "failed daily activation also preserves parent environment");
  live.remove();

  console.log("PASS next multi-session: " + checks + " checks");
} finally {
  fs.rmSync(tmp, { recursive: true, force: true });
}
