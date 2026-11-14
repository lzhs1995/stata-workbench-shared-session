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
const target = path.join(__dirname, "../dist/extension.js");
const disk = fs.readFileSync(target, "utf8");
const original = disk.includes(patch.MARKER) ? patch.revertBundle(disk) : disk;
const changed = patch.patchBundle(original);
assert.equal(disk, changed, "shipped bundle must contain the exact private-environment layer");
const sha256 = value => crypto.createHash("sha256").update(value).digest("hex");
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
const old = index(original), fixed = index(changed);
function watchedEnv(initial) {
  const values = { ...initial }, writes = [];
  const env = new Proxy(values, {
    set(obj, key, value) { const text = `${value}`; writes.push({ op: "set", key, value: text }); obj[key] = text; return true; },
    deleteProperty(obj, key) { writes.push({ op: "delete", key }); return delete obj[key]; },
    defineProperty() { throw Error("unexpected environment defineProperty"); },
  });
  return { env, values, writes, initial: { ...values } };
}
function moduleContext(env) {
  const denied = () => { throw Error("unexpected external boundary"); };
  return {
    process: { env, platform: "darwin", stderr: { fd: 2, write: denied } }, i() {},
    D(factory) { let done = false; const module = { exports: {} }; return () => {
      if (!done) { done = true; factory(module.exports, module); } return module.exports;
    }; },
    require(name) {
      if (name === "async_hooks") return { AsyncLocalStorage };
      if (name === "fs" || name === "child_process") return new Proxy({}, { get: () => denied });
      if (name === "tty") return { isatty: () => false };
      if (name === "util") return { deprecate: fn => fn, inspect: denied, formatWithOptions: denied };
      throw Error("unexpected require: " + name);
    },
    a1: () => null, e1: () => value => String(value), console: { warn: denied },
  };
}
function runtime(code, watched) {
  const sandbox = moduleContext(watched.env);
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
async function check(name, fn) { await fn(); cases.push(name); }

async function main() {
  await check("reversible canonical patch, idempotence and partial/duplicate rejection", () => {
    assert.equal(patch.patchBundle(changed), changed);
    assert.equal(patch.revertBundle(changed), original);
    assert.equal(patch.revertBundle(patch.patchBundle(original, { finalize: false }), { finalize: false }), original);
    assert.throws(() => patch.patchBundle(original.replace(patch.PAIRS[0][0], "missing")), /anchor/);
    assert.throws(() => patch.patchBundle(changed.replace(patch.PAIRS[1][1], patch.PAIRS[1][0])), /partial/);
    assert.throws(() => patch.patchBundle(changed + patch.PAIRS[0][1]), /ambiguous/);
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
    for (const installed of [false, true]) {
      const host = watchedEnv({ PATH: "/host" }), r = runtime(fixed, host); let probes = 0, spawns = 0;
      Object.assign(r.sandbox, { UF: () => ++probes === 1 && installed ? null : "/fake/uv", ng() {}, LF() {},
        rg: path, JA: { mkdirSync() {} }, gP: () => ({ command: "/fake/installer", args: [] }),
        mF() { throw Error("unexpected install failure prompt"); },
        mB: { spawnSync(command, args, options) { spawns++; assert.equal(command, "/fake/installer");
          assert.equal(options.env.PATH, "/host"); assert.equal(options.env.UV_INSTALL_DIR, "/fake/storage/uv");
          assert.notEqual(options.env, r.api.getEnv()); options.env.CHILD_ONLY = "1"; return { status: 0 }; } },
      });
      assert.equal(r.sandbox.TRA({ globalStoragePath: "/fake/storage" }), true);
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
  console.log(JSON.stringify({ verdict: "PASS_OFFLINE_EXTRACTED_BEHAVIOR", tests: cases.length, cases, negativeControls,
    originalBundleSha256: sha256(original), inMemoryPatchedBundleSha256: sha256(changed), bundleUnchanged: true,
    executed: "only AST-extracted runtime-context, debug, mRA/TRA and child-env expressions; mocked external boundaries",
    live: false, sourceFilesWritten: false }, null, 2));
}
main().catch(error => { console.error(error.stack || error); process.exitCode = 1; });
