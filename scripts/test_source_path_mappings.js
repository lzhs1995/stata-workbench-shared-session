"use strict";

const test = require("node:test"), assert = require("node:assert/strict");
const fs = require("node:fs"), os = require("node:os"), path = require("node:path"), vm = require("node:vm");
const crypto = require("node:crypto");
const core = require("./stata_source_compat_core");
const adapter = require("./darwin_compat_adapter");
const patch = require("./apply_stata_source_path_mappings_patch");
const extensionRoot = path.join(__dirname, "..");
let bundle = fs.readFileSync(path.join(extensionRoot, "dist", "extension.js"), "utf8");
if (bundle.includes(patch.MARKER)) bundle = patch.revertBundle(bundle, { finalize: false });
const mappedBundle = patch.patchBundle(bundle, { finalize: false });
const sha = bytes => crypto.createHash("sha256").update(bytes).digest("hex");
const FROM = "C:/Users/Example Analyst/Desktop/Study Project";
const MAPPINGS = [{ from: FROM, to: "/Users/fixture/研究 專案" }];
const map = (source, sourcePathMappings = MAPPINGS, platform = "darwin") => core.transformSource(source, { platform, sourcePathMappings });

function temp(t) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "wb-path-map-"));
  t.after(() => fs.rmSync(root, { recursive: true, force: true }));
  return root;
}
function extract(source, start, end) {
  const lo = source.indexOf(start), hi = source.indexOf(end, lo + start.length);
  assert.ok(lo >= 0 && hi > lo, start);
  return source.slice(lo, hi);
}
function actualAdapter(sourcePathMappings, platform = "darwin", source = mappedBundle) {
  const calls = [], globals = {};
  const workspace = { workspaceFolders: [], getConfiguration: (section, uri) => {
    calls.push({ section, uri });
    return { get: (name, fallback) => name === "sourcePathMappings" ? (sourcePathMappings === undefined ? fallback : sourcePathMappings) : fallback };
  } };
  const context = { globalThis: globals, process: { platform, cwd: () => extensionRoot },
    yC: { extensionUri: { fsPath: extensionRoot } }, rg: path, require, iA: { workspace },
    FHg: () => ({ Uri: { file: fsPath => ({ scheme: "file", fsPath }) } }) };
  vm.runInNewContext(extract(source, "globalThis.__codexPrepareCompatExecution=", "/* codex patch rc.7: shared source compatibility adapter */"), context);
  return { context, globals, calls, prepare: globals.__codexPrepareCompatExecution };
}

test("default never guesses a Desktop/research root from cwd, workspace or source path", () => {
  const input = 'global folder "' + FROM + '"\nuse "C:/Users/Other Analyst/Desktop/Study Project/data.dta"';
  for (const platform of ["darwin", "win32"]) {
    const result = core.transformSource(input, { platform, cwd: "/Users/fixture/projects", workspaceRoots: ["/Users/fixture"],
      sourcePath: "/Users/fixture/demo.do", stataRoot: "/old-root-option", cnmRoot: "/old-project-option" });
    assert.equal(result.code, input); assert.equal(result.diagnostics.rootRewrites, 0);
    assert.equal(result.diagnostics.configuredPathMappings, 0);
  }
});
test("longest prefix wins regardless of order and replacement is not cascaded", () => {
  const mappings = [{ from: FROM, to: "/broad" }, { from: FROM + "/data", to: "/specific" },
    { from: "/specific", to: "/must-not-cascade" }];
  assert.equal(map('use "' + FROM + '/data/模型.dta"', mappings).code, 'use "/specific/模型.dta"');
  assert.equal(map('cd "' + FROM + '"', mappings).code, 'cd "/broad"');
  assert.equal(map('use "' + FROM + '/data2/a.dta"', mappings).code, 'use "/broad/data2/a.dta"');
});
test("directory and token boundaries prevent other accounts, siblings and embedded prose remapping", () => {
  for (const value of [FROM + "-archive/a.dta", FROM + "2/a.dta", "prefix" + FROM + "/a.dta",
    "notes: " + FROM + "/a.dta", FROM.replace("Example Analyst", "Another Analyst") + "/a.dta"]) {
    const source = 'display "' + value + '"';
    assert.equal(map(source).code, source);
  }
});
test("mixed separators, drive case, quoted spaces/Unicode and compound quotes map literally", () => {
  const source = 'use "c:\\users\\example analyst\\Desktop/Study Project\\資料 😀.dta"';
  assert.equal(map(source).code, 'use "/Users/fixture/研究 專案/資料 😀.dta"');
  const compound = 'global folder `"' + FROM + '/資料"\'';
  assert.equal(map(compound).code, 'global folder `"/Users/fixture/研究 專案/資料"\'');
  assert.equal(map("cd C:/Project", [{ from: "C:/Project", to: "/a path/模型" }]).code, 'cd "/a path/模型"');
});
test("POSIX paths are case sensitive; Windows/UNC mappings work on either OS when opted in", () => {
  assert.equal(map('cd "/Data"', [{ from: "/data", to: "/new" }]).code, 'cd "/Data"');
  const mappings = [{ from: "\\\\EXAMPLE-SERVER\\Share\\Project", to: "D:\\Local Projects\\模型" }];
  assert.equal(map('use "//example-server/share/Project/data.dta"', mappings, "win32").code, 'use "D:/Local Projects/模型/data.dta"');
  assert.equal(map('cd "C:/"', [{ from: "C:/", to: "/" }]).code, 'cd "/"');
});
test("invalid, ambiguous and executable mapping values are rejected rather than ignored", () => {
  for (const sourcePathMappings of [null, {}, [{ from: "relative", to: "/dest" }], [{ from: FROM, to: "relative" }],
    [{ from: FROM, to: '/x"\nexit 0' }], [{ from: FROM, to: "/x/../dest" }], [{ from: FROM, to: "$guess" }],
    [{ from: FROM, to: "/one" }, { from: FROM.toLowerCase(), to: "/two" }]]) {
    assert.throws(() => map('display 1', sourcePathMappings), { code: "SOURCE_PATH_MAPPINGS_INVALID" });
  }
});
test("Mac transport/graph protections stay active and Windows no-config bytes stay unchanged", () => {
  const source = 'capture log close _all\nhistogram price, name(g_`i\', replace)\nuse "C:\\Users\\Example\\Desktop\\data.dta"';
  const mac = core.transformSource(source, { platform: "darwin", protectTransportLog: true });
  assert.equal(mac.diagnostics.transportLogCloseGuards, 1);
  assert.equal(mac.diagnostics.dynamicGraphNameProtections, 1);
  assert.equal(mac.diagnostics.rootRewrites, 0);
  assert.equal(core.transformSource(source, { platform: "win32" }).code, source);
  assert.equal(core.transformSource(source, { platform: "win32", protectTransportLog: true }).diagnostics.transportLogCloseGuards, 1);
});
test("recursive mapped references prepare copies while all original source bytes/hashes remain intact", t => {
  const root = temp(t), leaf = path.join(root, "葉 模型.do"), parent = path.join(root, "parent.do");
  const leafSource = 'global data "' + FROM + '/資料/data.dta"\ngraph export "' + FROM + '/figure.png", replace\n';
  const parentSource = 'do "' + FROM + '/葉 模型.do"\n';
  fs.writeFileSync(leaf, leafSource); fs.writeFileSync(parent, parentSource);
  const hashes = [leaf, parent].map(f => sha(fs.readFileSync(f)));
  for (const platform of ["darwin", "win32"]) {
    const result = adapter.prepareVisibleExecution('do "' + FROM + '/parent.do"', {
      platform, sourcePathMappings: [{ from: FROM, to: root }], cwd: root, tempRoot: root, extensionRoot,
    });
    assert.equal(result.darwinDiagnostics.ok, true);
    assert.equal(result.sourceDiagnostics.referencedDoCopies.length, 2);
    const leafCopy = result.sourceDiagnostics.referencedDoCopies.find(c => c.sourcePath === leaf);
    const parentCopy = result.sourceDiagnostics.referencedDoCopies.find(c => c.sourcePath === parent);
    assert.ok(fs.readFileSync(parentCopy.tempPath, "utf8").includes(leafCopy.tempPath.replace(/\\/g, "/")));
    const text = fs.readFileSync(leafCopy.tempPath, "utf8");
    assert.ok(text.includes(root.replace(/\\/g, "/") + "/資料/data.dta"));
    assert.equal(text.includes(".__pngcompat__.svg"), platform === "darwin");
  }
  assert.deepEqual([leaf, parent].map(f => sha(fs.readFileSync(f))), hashes);
});
test("actual bundle adapter reads configuration per source resource; no config gives no redirect", () => {
  const file = "/Users/fixture/第二 workspace/model.do", input = 'use "' + FROM + '/data.dta"';
  const api = actualAdapter(MAPPINGS);
  assert.ok(api.prepare(input, { sourcePath: file, sourceMode: "human-file" }).includes('/Users/fixture/研究 專案/data.dta'));
  assert.equal(api.calls[0].section, "stataMcp"); assert.equal(api.calls[0].uri.fsPath, file);
  const plain = actualAdapter(undefined);
  assert.equal(plain.prepare(input, {}), "set more off\n" + input);
  assert.equal(plain.calls[0].uri, undefined);
  assert.equal(actualAdapter(undefined, "win32").prepare(input, {}), "set more off\n" + input);
});
test("actual agent/selection/file/terminal callsites propagate configuration to executed text", () => {
  const api = actualAdapter(MAPPINGS), input = 'use "' + FROM + '/data.dta"', file = "/workspace/stage.do";
  const calls = [
    ['globalThis.__codexPrepareCompatExecution(__code,', '):__code;', { __code: input, __source: "agent", __runId: "r1", __cwd: "/workspace", __p: { agentWorkflow: { sourcePath: file } } }],
    ['globalThis.__codexPrepareCompatExecution(__codexSelectionBody,', '):__codexSelectionBody;', { __codexSelectionBody: input, e: "r2", Q: file, B: "/workspace" }],
    ['globalThis.__codexPrepareCompatExecution(__codexHumanFileRunner,', '):__codexHumanFileRunner;', { __codexHumanFileRunner: input, r: "r3", e: file, C: "/workspace" }],
    ['globalThis.__codexPrepareCompatExecution(g,', '):g;', { g: input, A: { sourceMode: "terminal-input", runId: "r4", cwd: "/workspace" } }],
  ];
  for (const [start, end, variables] of calls) {
    const expression = extract(mappedBundle, start, end) + ")";
    const result = vm.runInNewContext(expression, { ...api.context, ...variables });
    assert.ok(result.includes('/Users/fixture/研究 專案/data.dta'));
  }
  assert.deepEqual(api.calls.map(c => c.uri?.fsPath), [file, file, file, undefined]);
});
test("actual finalizer writer and shared adapter pass configured mapping into body copies", t => {
  const root = temp(t), authorPath = path.join(root, "author.do");
  const author = 'cd "' + FROM + '/模型"\ngraph export "' + FROM + '/figure.png", replace\nexit 601\n';
  fs.writeFileSync(authorPath, author);
  const source = extract(mappedBundle, "function __codexWriteVerifiedInlineSnapshot(", "globalThis.__codexWriteVerifiedInlineSnapshot");
  const writer = new Function("JA", "rg", "yC", "require", "process", "__dirname", "__codexStataString", "__codexGraphMark", "__codexGraphLog",
    source + "\nreturn __codexWriteVerifiedInlineSnapshot;")(fs, path, { extensionUri: { fsPath: extensionRoot } }, require,
    { platform: "darwin", cwd: () => root }, __dirname, s => String(s).replace(/"/g, '""'), () => {}, () => {});
  const record = writer(root, author, "mapping_finalizer", authorPath, "test");
  assert.equal(record.ok, true);
  const before = fs.readFileSync(record.tempDoFile);
  const api = actualAdapter(MAPPINGS);
  const prepared = api.prepare(record.executionCode, { sourcePath: authorPath, sourceMode: "human-file", cwd: root });
  const copy = api.globals.__codexLastSourceCompat.referencedDoCopies[0];
  t.after(() => fs.rmSync(path.dirname(copy.tempPath), { recursive: true, force: true }));
  const copiedText = fs.readFileSync(copy.tempPath, "utf8");
  assert.ok(copiedText.includes('cd "/Users/fixture/研究 專案/模型"'));
  assert.ok(copiedText.includes(".__pngcompat__.svg"));
  const executablePaths = copiedText.split("\n").filter(line => !line.trim().startsWith("display as error")).join("\n");
  assert.equal(executablePaths.includes(FROM), false, "path operands generated by the earlier PNG/finalizer layer also receive the mapping");
  assert.ok(copiedText.includes("missing " + FROM), "embedded diagnostic prose is not a path operand");
  assert.ok(prepared.includes('capture noisily do "' + copy.tempPath.replace(/\\/g, "/") + '"'));
  assert.ok(prepared.includes("___CODEX_RUN_DONE_mapping_finalizer___"));
  assert.deepEqual(fs.readFileSync(record.tempDoFile), before);
  assert.equal(fs.readFileSync(authorPath, "utf8"), author);
  assert.equal(api.calls[0].uri.fsPath, authorPath);
});
test("invalid config fails closed through the actual adapter on both platforms", () => {
  for (const platform of ["darwin", "win32"]) {
    const api = actualAdapter([{ from: "relative", to: "/dest" }], platform);
    const code = api.prepare('display "SHOULD_NOT_RUN"', {});
    assert.ok(code.includes("exit 693")); assert.ok(!code.includes("SHOULD_NOT_RUN"));
    assert.match(api.globals.__codexLastSourceCompat.error, /SOURCE_PATH_MAPPINGS_INVALID/);
  }
});
test("explicit Windows mapping preparation failure never falls back to unmodified source", t => {
  const root = temp(t), api = actualAdapter([{ from: FROM, to: root.replace(/\\/g, "/") }], "win32");
  const result = api.prepare('do "' + FROM + '/missing.do"\ndisplay "SHOULD_NOT_RUN"', { cwd: root });
  assert.ok(result.includes("exit 693")); assert.ok(!result.includes("SHOULD_NOT_RUN"));
  assert.ok(api.globals.__codexLastSourceCompat.error);
});
test("mapping layer is reversible/idempotent, preserves finalizer and parses actual bundle", () => {
  assert.equal(patch.patchBundle(mappedBundle, { finalize: false }), mappedBundle);
  assert.equal(patch.revertBundle(mappedBundle, { finalize: false }), bundle);
  new vm.Script(mappedBundle);
  const start = "function __codexWriteVerifiedInlineSnapshot(", end = "globalThis.__codexWriteVerifiedInlineSnapshot";
  assert.equal(extract(mappedBundle, start, end), extract(bundle, start, end));
  assert.throws(() => patch.patchBundle(bundle.replace("sourcePath:__meta.sourcePath,workspaceRoots:", "sourcePath:null,workspaceRoots:")), /anchor/);
});
test("new layer composes after daily agent guard without losing its pre-dispatch source check", () => {
  const edits = require("./apply_edit_proposal_patch");
  const guarded = edits.patchBundle(bundle, { finalize: false });
  const final = patch.patchBundle(guarded, { finalize: false });
  assert.ok(final.includes(edits.GUARD));
  assert.equal(patch.revertBundle(final, { finalize: false }), guarded);
  assert.equal(edits.patchBundle(final, { finalize: false }), final);
  assert.equal(patch.patchBundle(edits.patchBundle(mappedBundle, { finalize: false }), { finalize: false }), final);
  new vm.Script(final);
});
