"use strict";

// Only extracted shipped modules/functions execute in VM contexts. The target
// bundle is parsed as data, never required/evaluated. All OS/process/VS Code
// boundaries are denied or stubbed; no child process, file write or network.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");
const crypto = require("node:crypto");
const { AsyncLocalStorage } = require("node:async_hooks");
const acorn = require("acorn");
const patch = require("./apply_private_environment_patch");
const environment = require("./private_environment_core");
const fingerprint = require("./finalize_bundle_identity");
// Exact preceding sealed layer, for explicit offline negative controls only.
// Production patch/revert does not automatically migrate old private layers.
const legacyPairs = [
  ['MO=process.env,GO=', 'MO={...process.env},GO='],
  ['nag=g=>{MO=g||process.env}', 'nag=g=>{MO=g&&g!==process.env?g:{...process.env}}'],
  ['wag=()=>Ta.getStore()?.env||MO||process.env', 'wag=()=>Ta.getStore()?.env||MO'],
  ['env:g?.env??MO,fs:g?.fs??GO', 'env:(__env=>__env===process.env?{...process.env}:__env??MO)(g?.env),fs:g?.fs??GO'],
  patch.PAIRS[4],
];
const inMemory = process.argv.includes("--in-memory");
assert(process.argv.slice(2).every(arg => arg === "--in-memory"), "only --in-memory is supported");
const target = path.join(__dirname, "../dist/extension.js");
const disk = fs.readFileSync(target, "utf8");
let original = disk;
if (disk.includes(patch.MARKER)) {
  if (disk.includes(patch.PAIRS[0][1])) original = patch.revertBundle(disk);
  else {
    assert(inMemory, "shipped bundle has the obsolete spread-only private environment layer");
    assert.equal(shaBytes(disk), "37e98d77ffafdcb844561261ce54ab0a1a119fad9b191e1727775f69da73ec02", "only exact sealed old bundle is stripped in review mode");
    for (const [before, after] of [...legacyPairs].reverse()) {
      assert.equal(original.split(after).length, 2); original = original.replace(after, () => before);
    }
    original = fingerprint.finalize(original.replace("\n" + patch.MARKER + "\n", "")).text;
  }
}
const changed = patch.patchBundle(original);
if (!inMemory) assert.equal(disk, changed, "shipped bundle must contain the exact private-environment layer");
function shaBytes(value) { return crypto.createHash("sha256").update(value).digest("hex"); }
const sha256 = shaBytes;
const cases = [], negativeControls = [];

function index(source) {
  const result = { source, declarations: new Map(), functions: new Map(), nodes: [] };
  const ast = acorn.parse(source, { ecmaVersion: "latest" });
  function walk(node) {
    if (!node || typeof node !== "object") return;
    if (node.type) {
      result.nodes.push(node);
      if (node.type === "VariableDeclarator" && node.id.type === "Identifier") {
        const list = result.declarations.get(node.id.name) || [];
        list.push(node); result.declarations.set(node.id.name, list);
      }
      if (node.type === "FunctionDeclaration") result.functions.set(node.id.name, node);
    }
    for (const value of Object.values(node)) {
      if (Array.isArray(value)) value.forEach(walk);
      else if (value && typeof value === "object") walk(value);
    }
  }
  walk(ast);
  result.text = node => source.slice(node.start, node.end);
  result.module = name => {
    const found = (result.declarations.get(name) || []).filter(n => n.init?.callee?.name === "D");
    assert.equal(found.length, 1, "unique shipped module " + name);
    return "var " + result.text(found[0]) + ";";
  };
  result.fn = name => { assert(result.functions.has(name)); return result.text(result.functions.get(name)); };
  return result;
}
let legacyText = original;
for (const [before, after] of legacyPairs) {
  assert.equal(legacyText.split(before).length, 2);
  legacyText = legacyText.replace(before, () => after);
}
legacyText += "\n" + patch.MARKER + "\n";
legacyText = fingerprint.finalize(legacyText).text;
const old = index(original), fixed = index(changed), legacy = index(legacyText);
function watchedEnv(initial, insensitive = false) {
  const values = { ...initial }, writes = [];
  const actual = key => typeof key === "string" && insensitive
    ? Object.keys(values).find(name => name.toUpperCase() === key.toUpperCase()) ?? key : key;
  const env = new Proxy(values, {
    get(obj, key) { return obj[actual(key)]; },
    set(obj, key, value) { const text = `${value}`; key = actual(key); writes.push({ op: "set", key, value: text }); obj[key] = text; return true; },
    deleteProperty(obj, key) { key = actual(key); writes.push({ op: "delete", key }); return delete obj[key]; },
    defineProperty() { throw Error("unexpected environment defineProperty"); },
  });
  return { env, values, writes, initial: { ...values } };
}
function moduleContext(env, platform = "darwin", isMainThread = true) {
  const denied = () => { throw Error("unexpected external boundary"); };
  return {
    process: { env, platform, stderr: { fd: 2, write: denied } }, i() {},
    D(factory) { let done = false; const module = { exports: {} }; return () => {
      if (!done) { done = true; factory(module.exports, module); } return module.exports;
    }; },
    require(name) {
      if (name === "async_hooks") return { AsyncLocalStorage };
      if (name === "../scripts/private_environment_core") return {
        snapshotEnvironment: source => environment.snapshotEnvironment(source, { platform, isMainThread }),
      };
      if (name === "fs" || name === "child_process") return new Proxy({}, { get: () => denied });
      if (name === "tty") return { isatty: () => false };
      if (name === "util") return { deprecate: fn => fn, inspect: denied, formatWithOptions: denied };
      throw Error("unexpected require: " + name);
    },
    a1: () => null, e1: () => value => String(value), console: { warn: denied },
  };
}
function runtime(code, watched, platform, isMainThread) {
  const sandbox = moduleContext(watched.env, platform, isMainThread);
  const api = vm.runInNewContext(code.module("Ji") + ";Ji();", sandbox);
  sandbox.uM = () => api.getEnv();
  vm.runInNewContext(code.fn("mRA") + ";" + code.fn("TRA"), sandbox);
  return { api, sandbox, apply: sandbox.mRA };
}
function debug(code, watched) {
  return vm.runInNewContext(code.module("gp") + code.module("c1") + ";c1();", moduleContext(watched.env));
}
function sameHost(watched) {
  assert.deepEqual(watched.values, watched.initial, "host property presence and values must remain unchanged");
  assert.deepEqual(watched.writes, [], "zero host assignment/delete operations");
}
function childConfig(code, env, explicit = {}) {
  const nodes = code.nodes.filter(n => n.type === "NewExpression" && n.callee.name === "Z_");
  assert.equal(nodes.length, 1, "unique actual Stdio construction");
  return vm.runInNewContext("(function(){return " + code.text(nodes[0]) + ";}).call(receiver)", {
    Z_: function (config) { return config; }, t: "/fake/python", o: ["-m", "mcp_stata"],
    I: env, c: explicit, u: { STATA_PATH: "/fake/stata" }, r: "60",
    receiver: { _resolveWorkspaceRoot: () => "/fake/workspace" },
    __codexBackendOwnerId: "owner-test", __codexBridgePort: 12345,
  });
}
function finalTransportEnv(code, params, host, platform) {
  const defaults = code.nodes.filter(n => n.type === "AssignmentExpression" &&
    n.left.type === "MemberExpression" && n.left.object.name === "Ae" && n.left.property.name === "DEFAULT_INHERITED_ENV_VARS");
  const expression = code.nodes.filter(n => n.type === "ObjectExpression" && code.text(n) === "{...kRA(),...this._serverParams.env}");
  assert.equal(expression.length, 1); assert.equal(defaults.length, 2);
  const populated = defaults.find(n => n.right.type === "ConditionalExpression"); assert(populated);
  return vm.runInNewContext(code.text(populated) + ";" + code.fn("kRA") +
    ";(function(){return " + code.text(expression[0]) + ";}).call(receiver)", {
    Ae: {}, NF: { default: { env: host, platform } }, receiver: { _serverParams: params },
  });
}
function explicitConfig(code, env) {
  const methods = code.nodes.filter(n => n.type === "MethodDefinition" && n.key.name === "_loadServerConfig");
  assert.equal(methods.length, 1);
  const Sample = vm.runInNewContext("(class Sample{" + code.text(methods[0]) + "})", {
    MM: () => env, bA: path.win32, RF: "mcp_stata",
    Lt: { readFileSync(file) {
      assert.equal(file, "C:\\project\\explicit.json");
      return JSON.stringify({ servers: { mcp_stata: { command: "explicit-python", args: [] } } });
    }, existsSync() { throw Error("unexpected shared configuration lookup"); } },
  });
  const instance = new Sample(); instance._safeParseJson = JSON.parse; instance._log = () => {};
  instance._hostMcpConfigPaths = () => []; instance._candidateMcpConfigPaths = () => [];
  return instance._loadServerConfig({ hostOnly: true });
}
function windowsCaseFlow(code) {
  const host = watchedEnv({ Path: "C:\\host", mcp_stata_no_reload_on_clear: "1",
    mcp_stata_config_path: "C:\\project\\explicit.json" }, true);
  const r = runtime(code, host, "win32", true); r.apply(false);
  const env = r.api.getEnv(), config = explicitConfig(code, env);
  const child = childConfig(code, env, config.env || {});
  const final = finalTransportEnv(code, child, host.env, "win32");
  const flags = Object.entries(final).filter(([key]) => key.toUpperCase() === "MCP_STATA_NO_RELOAD_ON_CLEAR");
  return { host, env, config, flags };
}
async function check(name, fn) { await fn(); cases.push(name); }

async function main() {
  await check("reversible canonical patch, idempotence and partial/duplicate rejection", () => {
    assert.equal(patch.patchBundle(changed), changed);
    assert.equal(patch.revertBundle(changed), original);
    assert.equal(patch.revertBundle(patch.patchBundle(original, { finalize: false }), { finalize: false }), original);
    assert.throws(() => patch.patchBundle(original.replace(patch.PAIRS[0][0], "missing")), /anchor/);
    assert.throws(() => patch.patchBundle(changed.replace(patch.PAIRS[1][1], patch.PAIRS[1][0])), /partial/);
    assert.throws(() => patch.patchBundle(changed + patch.PAIRS[0][1]), /ambiguous/);
    assert.throws(() => patch.patchBundle(legacyText), /partial/, "production patch must not migrate the sealed older layer");
  });
  await check("same shipped Windows config/flag flow detects spread-only regression and verifies correction", () => {
    assert.equal(sha256(legacyText), "37e98d77ffafdcb844561261ce54ab0a1a119fad9b191e1727775f69da73ec02");
    const baseline = windowsCaseFlow(old), prior = windowsCaseFlow(legacy), next = windowsCaseFlow(fixed);
    assert.equal(baseline.config.configPath, "C:\\project\\explicit.json");
    assert.equal(baseline.flags.length, 0); assert.equal(baseline.host.writes.length, 1);
    assert.equal(prior.config.configPath, null);
    assert.deepEqual(prior.flags.map(([key, value]) => [key, value]), [["mcp_stata_no_reload_on_clear", "1"]]);
    sameHost(prior.host);
    assert.equal(next.config.configPath, "C:\\project\\explicit.json");
    assert.equal(next.config.command, "explicit-python"); assert.equal(next.flags.length, 0);
    assert.equal(Object.keys(next.env).filter(key => key.toUpperCase() === "MCP_STATA_NO_RELOAD_ON_CLEAR").length, 0);
    sameHost(next.host);
    negativeControls.push({ name: "sealed spread-only Windows regression", bundleSha256: sha256(legacyText),
      priorConfigPath: prior.config.configPath, priorChildFlags: prior.flags,
      fixedConfigPath: next.config.configPath, fixedChildFlags: next.flags });
  });
  await check("Windows main-thread case aliases cover get/set/delete/has/descriptors/enumeration without duplicates", () => {
    const host = watchedEnv({ Path: "C:\\host" }, true), r = runtime(fixed, host, "win32", true), env = r.api.getEnv();
    for (const key of ["PATH", "path", "pAtH"]) {
      assert.equal(env[key], "C:\\host"); assert.equal(key in env, true); assert.equal(Object.hasOwn(env, key), true);
      assert.deepEqual(Object.getOwnPropertyDescriptor(env, key), { value: "C:\\host", writable: true, enumerable: true, configurable: true });
    }
    env.PATH = 42; assert.equal(env.path, "42");
    assert.deepEqual(Object.keys(env), ["Path"]); assert.deepEqual({ ...env }, { Path: "42" });
    assert.equal(delete env.pAtH, true);
    assert.equal("PATH" in env, false); assert.equal(Object.getOwnPropertyDescriptor(env, "path"), undefined);
    assert.deepEqual(Object.keys(env), []);
    env.path = false;
    Object.defineProperty(env, "PATH", { value: null, writable: true, enumerable: true, configurable: true });
    assert.equal(env.PaTh, "null"); assert.deepEqual(Object.keys(env), ["path"]);
    assert.equal(Object.getOwnPropertyDescriptors(env).path.value, "null");
    assert.throws(() => Object.defineProperty(env, "PATH", { value: "bad" }), /data descriptor/);
    assert.throws(() => Object.defineProperty(env, "PATH", { get() { return "bad"; }, configurable: true, enumerable: true }), /data descriptor/);
    assert.equal(env.path, "null");
    assert.throws(() => Object.preventExtensions(env), /preventExtensions/);
    sameHost(host);
  });
  await check("private host snapshots retain Node string-value coercion without mutating the source", () => {
    for (const [platform, main] of [["darwin", true], ["win32", true], ["win32", false]]) {
      const host = watchedEnv({ Seed: "source" }, platform === "win32" && main);
      const env = runtime(fixed, host, platform, main).api.getEnv();
      for (const [value, text] of [[undefined, "undefined"], [null, "null"], [false, "false"], [true, "true"], [0, "0"], [42, "42"]]) {
        env.VALUE = value; assert.equal(env.VALUE, text);
      }
      env.VALUE = { toString: () => "object-string", valueOf() { throw Error("wrong primitive hint"); } };
      assert.equal(env.VALUE, "object-string");
      assert.throws(() => { env.VALUE = Symbol("invalid value"); }, /Symbol/);
      assert.equal(env.VALUE, "object-string"); sameHost(host);
    }
  });
  await check("Unix and Windows Worker snapshots remain case-sensitive", () => {
    for (const [platform, main] of [["darwin", true], ["linux", true], ["win32", false]]) {
      const host = watchedEnv({ Path: "mixed", PATH: "upper" }), env = runtime(fixed, host, platform, main).api.getEnv();
      assert.equal(env.path, undefined); assert.equal("path" in env, false);
      assert.equal(Object.getOwnPropertyDescriptor(env, "path"), undefined);
      env.path = 3; assert.equal(env.Path, "mixed"); assert.equal(env.PATH, "upper"); assert.equal(env.path, "3");
      delete env.PATH; assert.equal(env.Path, "mixed"); assert.equal(Object.hasOwn(env, "PATH"), false);
      assert.deepEqual(Object.keys(env), ["Path", "path"]); sameHost(host);
    }
  });
  await check("Windows default reset and host request copies preserve case rules while explicit mocks keep identity", () => {
    const host = watchedEnv({ Path: "C:\\host", mcp_stata_no_reload_on_clear: "host" }, true);
    const r = runtime(fixed, host, "win32", true), supplied = { Path: "case-sensitive mock" };
    r.api.setDefaultEnv(supplied); assert.equal(r.api.getEnv(), supplied); assert.equal(r.api.getEnv().PATH, undefined);
    for (const reset of [undefined, null, host.env]) {
      r.api.setDefaultEnv(reset); assert.equal(r.api.getEnv().PATH, "C:\\host"); r.apply(false);
      assert.equal(Object.keys(r.api.getEnv()).some(k => k.toUpperCase() === "MCP_STATA_NO_RELOAD_ON_CLEAR"), false);
    }
    r.api.runWithContext({ env: host.env }, () => { assert.equal(r.api.getEnv().PATH, "C:\\host"); r.apply(false); });
    r.api.runWithContext({ env: supplied }, () => assert.equal(r.api.getEnv(), supplied));
    sameHost(host);
  });
  await check("original shipped default mRA and TRA are effective negative controls", () => {
    const host = watchedEnv({ PATH: "/host" }), r = runtime(old, host);
    r.apply(true); r.apply(false);
    Object.assign(r.sandbox, { UF: () => "/fake/uv", ng() {} });
    assert.equal(r.sandbox.TRA({}), true);
    assert.deepEqual(host.writes.map(x => [x.op, x.key]), [
      ["set", "MCP_STATA_NO_RELOAD_ON_CLEAR"], ["delete", "MCP_STATA_NO_RELOAD_ON_CLEAR"], ["set", "MCP_STATA_UVX_CMD"],
    ]);
    negativeControls.push({ name: "original default mRA/TRA", writes: host.writes });
  });
  await check("private default persists across callbacks and setting enable/disable", async () => {
    const host = watchedEnv({ PATH: "/host", MCP_STATA_NO_RELOAD_ON_CLEAR: "inherited" }), r = runtime(fixed, host);
    const privateEnv = r.api.getEnv(); assert.notEqual(privateEnv, host.env);
    r.apply(false); assert.equal(Object.hasOwn(privateEnv, "MCP_STATA_NO_RELOAD_ON_CLEAR"), false);
    await Promise.resolve(); r.apply(true); assert.equal(privateEnv.MCP_STATA_NO_RELOAD_ON_CLEAR, "1");
    r.apply(false); assert.equal(r.api.getEnv(), privateEnv); sameHost(host);
  });
  await check("setDefaultEnv retains explicit private mocks and snapshots host/reset defaults", () => {
    const host = watchedEnv({ PATH: "/host" }), r = runtime(fixed, host), supplied = { PATH: "/supplied" };
    r.api.setDefaultEnv(supplied); r.apply(true);
    assert.equal(r.api.getEnv(), supplied, "preserve explicit private mock identity");
    assert.equal(supplied.MCP_STATA_NO_RELOAD_ON_CLEAR, "1");
    assert.equal(r.api.getEnv().PATH, "/supplied");
    for (const reset of [undefined, null, host.env]) {
      r.api.setDefaultEnv(reset); assert.equal(r.api.getEnv().PATH, "/host"); r.apply(true);
    }
    sameHost(host);
  });
  await check("overlapping AsyncLocal requests retain their own supplied env and default stays separate", async () => {
    const host = watchedEnv({ PATH: "/host" }), r = runtime(fixed, host);
    const a = { PATH: "/a" }, b = { PATH: "/b", MCP_STATA_NO_RELOAD_ON_CLEAR: "old" };
    const results = await Promise.all([a, b].map((env, i) => r.api.runWithContext({ env }, async () => {
      r.apply(i === 0); await Promise.resolve(); assert.equal(r.api.getEnv(), env);
      return childConfig(fixed, r.api.getEnv()).env;
    })));
    assert.equal(results[0].MCP_STATA_NO_RELOAD_ON_CLEAR, "1");
    assert.equal(Object.hasOwn(results[1], "MCP_STATA_NO_RELOAD_ON_CLEAR"), false);
    assert.equal(r.api.getEnv().PATH, "/host"); assert.equal(r.api.getEnv().MCP_STATA_NO_RELOAD_ON_CLEAR, undefined);
    sameHost(host);
  });
  await check("an explicitly supplied host env is copied at the AsyncLocal boundary", () => {
    const host = watchedEnv({ PATH: "/host" }), r = runtime(fixed, host);
    r.api.runWithContext({ env: host.env }, () => { assert.notEqual(r.api.getEnv(), host.env); r.apply(true); });
    sameHost(host);
  });
  await check("request env getter is read once before classifying host aliases", () => {
    const host = watchedEnv({ PATH: "/host" }), r = runtime(fixed, host);
    for (const first of [{ PATH: "/private" }, host.env]) {
      let reads = 0;
      const context = { get env() { reads++; return reads === 1 ? first : host.env; } };
      r.api.runWithContext(context, () => {
        if (first === host.env) assert.notEqual(r.api.getEnv(), host.env);
        else assert.equal(r.api.getEnv(), first);
        r.apply(true);
      });
      assert.equal(reads, 1, "classify and store the same env value");
    }
    sameHost(host);
  });
  await check("empty request env remains valid and an async failure restores the private default", async () => {
    const host = watchedEnv({ PATH: "/host" }), r = runtime(fixed, host);
    const defaults = r.api.getEnv(), empty = {};
    await assert.rejects(r.api.runWithContext({ env: empty }, async () => {
      assert.equal(r.api.getEnv(), empty);
      assert.equal(r.api.getEnv().PATH, undefined);
      r.apply(true);
      await Promise.resolve();
      assert.equal(r.api.getEnv(), empty);
      throw Error("fixture request failed");
    }), /fixture request failed/);
    assert.equal(r.api.getEnv(), defaults);
    assert.equal(defaults.MCP_STATA_NO_RELOAD_ON_CLEAR, undefined);
    sameHost(host);
  });
  await check("TRA found and simulated installer branches update only private and child env", () => {
    const platforms = [
      { platform: "darwin", rules: path.posix, storage: "/fake/storage", uvDir: "/fake/storage/uv" },
      { platform: "win32", rules: path.win32, storage: "C:\\fake\\storage", uvDir: "C:\\fake\\storage\\uv" },
    ];
    for (const { platform, rules, storage, uvDir } of platforms) for (const installed of [false, true]) {
      const host = watchedEnv({ PATH: "/host" }), r = runtime(fixed, host); let probes = 0, spawns = 0;
      r.sandbox.process.platform = platform;
      Object.assign(r.sandbox, { UF: () => ++probes === 1 && installed ? null : "/fake/uv", ng() {}, LF() {},
        rg: rules, JA: { mkdirSync() {} }, gP: () => ({ command: "/fake/installer", args: [] }),
        mF() { throw Error("unexpected install failure prompt"); },
        mB: { spawnSync(command, args, options) { spawns++; assert.equal(command, "/fake/installer");
          assert.equal(options.env.PATH, "/host"); assert.equal(options.env.UV_INSTALL_DIR, uvDir);
          assert.notEqual(options.env, r.api.getEnv()); options.env.CHILD_ONLY = "1"; return { status: 0 }; } },
      });
      assert.equal(r.sandbox.TRA({ globalStoragePath: storage }), true);
      assert.equal(spawns, Number(installed)); assert.equal(r.api.getEnv().MCP_STATA_UVX_CMD, "/fake/uv");
      assert.equal(r.api.getEnv().CHILD_ONLY, undefined); sameHost(host);
    }
  });
  await check("actual Stdio expressions propagate private settings and retain explicit config precedence", () => {
    const host = watchedEnv({ PATH: "/host", MCP_STATA_NO_RELOAD_ON_CLEAR: "host-value" }), r = runtime(fixed, host);
    r.apply(true); const normal = childConfig(fixed, r.api.getEnv());
    assert.equal(normal.env.MCP_STATA_NO_RELOAD_ON_CLEAR, "1");
    assert.equal(normal.env.STATA_WORKBENCH_OWNER_ID, "owner-test");
    assert.equal(normal.env.STATA_WORKBENCH_BRIDGE_PORT, "12345");
    const explicit = { MCP_STATA_NO_RELOAD_ON_CLEAR: "configured", PATH: "/config" };
    const overridden = childConfig(fixed, r.api.getEnv(), explicit);
    assert.equal(overridden.env.MCP_STATA_NO_RELOAD_ON_CLEAR, "configured"); assert.equal(overridden.env.PATH, "/config");
    overridden.env.PATH = "/child-only"; assert.equal(explicit.PATH, "/config"); assert.equal(r.api.getEnv().PATH, "/host");
    r.apply(false); const disabled = childConfig(fixed, r.api.getEnv());
    for (const platform of ["darwin", "win32"]) {
      const final = finalTransportEnv(fixed, disabled, host.env, platform);
      assert.equal(Object.hasOwn(final, "MCP_STATA_NO_RELOAD_ON_CLEAR"), false, "SDK whitelist must not reintroduce host flag");
      assert.equal(final.STATA_PATH, "/fake/stata");
    }
    sameHost(host);
  });
  await check("original debug import and enable/disable prove host writes including empty-key deletion", () => {
    const host = watchedEnv({ DEBUG: "" }), d = debug(old, host);
    assert.equal(Object.hasOwn(host.values, "DEBUG"), false);
    d.enable("old:*"); assert.equal(host.values.DEBUG, "old:*"); d.disable();
    assert(host.writes.some(x => x.op === "delete")); assert(host.writes.some(x => x.op === "set"));
    negativeControls.push({ name: "original debug import/enable/disable", writes: host.writes });
  });
  for (const initial of [{}, { DEBUG: "" }, { DEBUG: "initial:*,-initial:skip" }]) {
    await check("debug private initialization and live namespace toggles preserve host " + JSON.stringify(initial), () => {
      const host = watchedEnv(initial), d = debug(fixed, host), logger = d("alpha:ok");
      assert.equal(d.load(), initial.DEBUG || undefined);
      assert.equal(d.enabled("initial:ok"), Boolean(initial.DEBUG));
      assert.equal(d.enabled("initial:skip"), false);
      d.enable("alpha:*,-alpha:skip"); assert.equal(d.load(), "alpha:*,-alpha:skip");
      assert.equal(logger.enabled, true); assert.equal(d.enabled("alpha:skip"), false);
      const previous = d.disable(); assert.equal(previous, "alpha:*,-alpha:skip");
      assert.equal(d.load(), undefined); assert.equal(logger.enabled, false);
      d.enable(previous); assert.equal(logger.enabled, true);
      d.save(42); assert.equal(d.load(), "42");
      d.save(false); assert.equal(d.load(), undefined);
      assert.throws(() => d.save(Symbol("not an env value")), /Symbol/);
      sameHost(host);
    });
  }
  await check("actual process.env assignment/delete nodes are removed, not merely hidden in strings", () => {
    function writes(code) { return code.nodes.filter(n => {
      const lhs = n.type === "AssignmentExpression" ? n.left : n.type === "UnaryExpression" && n.operator === "delete" ? n.argument : null;
      return lhs?.type === "MemberExpression" && lhs.object?.type === "MemberExpression" &&
        lhs.object.object?.name === "process" && lhs.object.property?.name === "env";
    }).map(code.text); }
    assert.deepEqual(writes(old), ["process.env.DEBUG=g", "delete process.env.DEBUG"]);
    assert.deepEqual(writes(fixed), []);
    for (const name of ["nag", "Nag"]) assert.equal(old.nodes.filter(n => n.type === "CallExpression" && n.callee.name === name).length, 0);
  });
  assert.equal(fs.readFileSync(target, "utf8"), disk, "shipped bundle remains untouched");
  console.log(JSON.stringify({ verdict: inMemory ? "PASS_IN_MEMORY_EXTRACTED_BEHAVIOR" : "PASS_OFFLINE_EXTRACTED_BEHAVIOR", tests: cases.length, cases, negativeControls,
    inMemoryReview: inMemory, shippedLayerRequired: !inMemory,
    originalBundleSha256: sha256(original), inMemoryPatchedBundleSha256: sha256(changed), bundleUnchanged: true,
    executed: "only AST-extracted runtime-context, debug, mRA/TRA and child-env expressions; mocked external boundaries",
    live: false, sourceFilesWritten: false }, null, 2));
}
main().catch(error => { console.error(error.stack || error); process.exitCode = 1; });
