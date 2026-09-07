#!/usr/bin/env node
"use strict";
/**
 * rc.7.39 产品回归：空 inline manifest 分支不得提前释放 postRunBusy。
 *
 * 【为什么必须动态跑真源码】R9 证明的缺陷是**时序**性质的：
 *   __codexRouteGraphSnapshotManifest 的 empty 分支同步释放 postRunBusy 后 return false，
 *   而调用方 __codexRouteGraphManifestOrExport 收到 false 还要 await fallback。
 * 只数字符串（grep「有没有那行」）无法证明「await 未返回前 busy 仍为 true」——
 * 那是纯静态断言，改个变量名就假绿。故本测试从 dist/extension.js **抽取真函数体**
 * 并在受控沙箱里 eval，用一个**可控延迟**的 fallback 把「pending 窗口」真正撑开。
 *
 * 判据（对应 productRequirements[3][4]）：
 *   1. fallback pending 期间           → postRunBusy 必须为 true
 *   2. fallback resolve 后             → 外层 finally 释放（post-run-drain-complete）
 *   3. fallback reject 后              → 外层 finally 仍释放（不得永久 busy 楔死）
 *   4. legacy 负控制：把提前释放塞回去   → 断言 1 必须**失败**（证明断言有鉴别力）
 *
 * 只读 dist/extension.js，不写任何文件；不连桥、不跑 Stata、不碰安装目录。
 */

const fs = require("fs");
const path = require("path");

const BUNDLE = path.resolve(__dirname, "..", "dist", "extension.js");

let passed = 0;
let failed = 0;
const failures = [];

function check(name, cond, detail) {
  if (cond) {
    passed += 1;
    console.log("  PASS  " + name);
  } else {
    failed += 1;
    failures.push(name + (detail ? " :: " + detail : ""));
    console.log("  FAIL  " + name + (detail ? " :: " + detail : ""));
  }
}

/** 从 bundle 里按大括号配平抽出一个顶层函数体（返回源码字符串）。 */
function extractFunction(lines, startLine1) {
  let depth = 0;
  const out = [];
  for (let i = startLine1 - 1; i < lines.length; i += 1) {
    const line = lines[i];
    out.push(line);
    for (const ch of line) {
      if (ch === "{") depth += 1;
      else if (ch === "}") depth -= 1;
    }
    if (depth === 0 && out.length > 1) return out.join("\n");
  }
  throw new Error("unbalanced function starting at line " + startLine1);
}

function findLine(lines, needle) {
  const hits = [];
  lines.forEach((line, index) => {
    if (line.includes(needle)) hits.push(index + 1);
  });
  if (hits.length !== 1) {
    throw new Error("expected exactly 1 match for " + JSON.stringify(needle)
      + ", got " + JSON.stringify(hits));
  }
  return hits[0];
}

/**
 * 建一个沙箱，把两个真函数装进去。
 * @param {object} opts
 *   opts.legacyPrematureRelease  true 时把已删掉的提前释放**塞回**空分支（负控制）
 *   opts.manifestEntries         __codexParseGraphSnapshotManifest 的返回值
 *   opts.fallbackController      外部控制 fallback 何时 resolve/reject
 */
function buildSandbox(opts) {
  const source = fs.readFileSync(BUNDLE, "utf8");
  const lines = source.split("\n");

  const snapshotStart = findLine(lines, "function __codexRouteGraphSnapshotManifest(runId) {");
  const routeStart = findLine(lines, "async function __codexRouteGraphManifestOrExport(runId, cwd) {");

  let snapshotSrc = extractFunction(lines, snapshotStart);
  const routeSrc = extractFunction(lines, routeStart);

  // 负控制：把 R10 删掉的那一行原样塞回 empty 分支（在 `return false;` 之前）。
  if (opts.legacyPrematureRelease) {
    const anchor = "    return false;\n  }";
    if (!snapshotSrc.includes(anchor)) {
      throw new Error("legacy control anchor not found; refusing to fabricate a control");
    }
    snapshotSrc = snapshotSrc.replace(
      anchor,
      '    __codexSetPostRunBusy(false, "inline-snapshot-empty", runId);\n'
      + "    return false;\n  }");
  }

  const state = {
    postRunBusy: null,
    releaseReasons: [],
    graphMarks: [],
    logs: [],
    routedArtifacts: [],
    exportCalls: 0
  };

  const sandbox = {
    // 记账用的 shim（不是产品逻辑，只是观测点）
    __codexSetPostRunBusy(flag, reason) {
      state.postRunBusy = !!flag;
      if (!flag) state.releaseReasons.push(String(reason));
    },
    __codexGraphMark(patch) { state.graphMarks.push(patch); },
    __codexGraphLog(message) { state.logs.push(String(message)); },
    __codexRouteArtifactsSafe(runId, artifacts) {
      state.routedArtifacts = artifacts.slice();
    },
    __codexParseGraphSnapshotManifest() { return opts.manifestEntries || []; },
    __codexExportCurrentGraphsForPanel() {
      state.exportCalls += 1;
      return opts.fallbackController.promise;
    },
    __codexPreparedGraphRuns: new Map(),
    __codexGraphRunBaselines: new Map(),
    __codexGraphState: { version: 0, graphs: [] },
    __codexHumanFileDebug: {},
    // artifact 非空判定读文件大小；测试里让它按 entry 自带的 size 走
    JA: {
      statSync(p) {
        const entry = (opts.manifestEntries || []).find((e) => e.exportPath === p);
        return { size: entry && entry.size != null ? entry.size : 0 };
      }
    },
    state
  };

  const factory = new Function(
    "sandbox",
    "with (sandbox) {\n"
    + snapshotSrc + "\n"
    + routeSrc + "\n"
    + "return { __codexRouteGraphSnapshotManifest, __codexRouteGraphManifestOrExport };\n"
    + "}");
  const fns = factory(sandbox);
  return { fns, state, sandbox };
}

function deferred() {
  const controller = {};
  controller.promise = new Promise((resolve, reject) => {
    controller.resolve = resolve;
    controller.reject = reject;
  });
  // 避免 reject 分支在未附加 handler 时触发 unhandled rejection 噪声
  controller.promise.catch(() => {});
  return controller;
}

function preparedInline(runId) {
  return {
    runId,
    mode: "inline-snapshot",
    manifestPath: "/tmp/does-not-need-to-exist/manifest.tsv",
    graphCommandCount: 52,
    startedAt: Date.now()
  };
}

/** A. 空 manifest + fallback 挂起：pending 期间必须仍 busy。 */
async function caseEmptyManifestPendingHoldsBusy() {
  console.log("\n[A] empty manifest, fallback PENDING -> postRunBusy must stay true");
  const controller = deferred();
  const { fns, state, sandbox } = buildSandbox({
    manifestEntries: [],
    fallbackController: controller
  });
  const runId = "run_pending";
  sandbox.__codexPreparedGraphRuns.set(runId, preparedInline(runId));
  state.postRunBusy = true; // 派发时产品已置 true

  const inflight = fns.__codexRouteGraphManifestOrExport(runId, "/tmp");
  await new Promise((r) => setImmediate(r));

  check("A1 fallback was entered", state.exportCalls === 1,
    "exportCalls=" + state.exportCalls);
  check("A2 fallback log emitted",
    state.logs.some((l) => l.includes("inline graph snapshot manifest empty")),
    JSON.stringify(state.logs));
  check("A3 postRunBusy STILL true while fallback pending",
    state.postRunBusy === true,
    "postRunBusy=" + state.postRunBusy + " releases=" + JSON.stringify(state.releaseReasons));
  check("A4 no premature release reason recorded",
    !state.releaseReasons.includes("inline-snapshot-empty"),
    JSON.stringify(state.releaseReasons));

  controller.resolve();
  await inflight;

  check("A5 released after fallback resolved", state.postRunBusy === false,
    "postRunBusy=" + state.postRunBusy);
  check("A6 release owned by outer finally",
    state.releaseReasons[state.releaseReasons.length - 1] === "post-run-drain-complete",
    JSON.stringify(state.releaseReasons));
  return state;
}

/** B. fallback reject：finally 仍须释放，绝不永久 busy。 */
async function caseFallbackRejectStillReleases() {
  console.log("\n[B] empty manifest, fallback REJECTS -> finally must still release");
  const controller = deferred();
  const { fns, state, sandbox } = buildSandbox({
    manifestEntries: [],
    fallbackController: controller
  });
  const runId = "run_reject";
  sandbox.__codexPreparedGraphRuns.set(runId, preparedInline(runId));
  state.postRunBusy = true;

  const inflight = fns.__codexRouteGraphManifestOrExport(runId, "/tmp");
  await new Promise((r) => setImmediate(r));
  check("B1 busy held while pending", state.postRunBusy === true,
    "postRunBusy=" + state.postRunBusy);

  controller.reject(new Error("synthetic fallback failure"));
  await inflight; // 产品自身 catch 掉，不应向外抛

  check("B2 released after rejection (no permanent wedge)",
    state.postRunBusy === false, "postRunBusy=" + state.postRunBusy);
  check("B3 release reason is the finally owner",
    state.releaseReasons[state.releaseReasons.length - 1] === "post-run-drain-complete",
    JSON.stringify(state.releaseReasons));
  check("B4 error was recorded, not swallowed silently",
    state.graphMarks.some((m) => m && m.lastGraphExportMode === "route-or-export-error"),
    JSON.stringify(state.graphMarks.map((m) => m && m.lastGraphExportMode)));
  return state;
}

/** C. 非空 manifest（inline 成功路径）必须完全不受本次改动影响。 */
async function caseInlineSuccessUnchanged() {
  console.log("\n[C] non-empty manifest -> inline success path unchanged");
  const controller = deferred();
  controller.resolve();
  const entries = [];
  for (let i = 1; i <= 52; i += 1) {
    entries.push({
      sequence: i,
      graphName: "t9g_" + String(i).padStart(3, "0"),
      exportPath: "/tmp/g" + i + ".svg",
      size: 1024
    });
  }
  const { fns, state, sandbox } = buildSandbox({
    manifestEntries: entries,
    fallbackController: controller
  });
  const runId = "run_inline_ok";
  sandbox.__codexPreparedGraphRuns.set(runId, preparedInline(runId));
  state.postRunBusy = true;

  const ok = fns.__codexRouteGraphSnapshotManifest(runId);
  check("C1 inline manifest routed successfully", ok === true, "returned " + ok);
  check("C2 all 52 artifacts routed", state.routedArtifacts.length === 52,
    "routed=" + state.routedArtifacts.length);
  check("C3 inline success still releases on its own path",
    state.releaseReasons.includes("inline-snapshot-route-complete"),
    JSON.stringify(state.releaseReasons));
  check("C4 fallback NOT used on success path", state.exportCalls === 0,
    "exportCalls=" + state.exportCalls);
  return state;
}

/** D. legacy 负控制：塞回提前释放 → A3 那条断言必须失败。 */
async function caseLegacyNegativeControl() {
  console.log("\n[D] LEGACY negative control: premature release reinserted");
  const controller = deferred();
  const { fns, state, sandbox } = buildSandbox({
    manifestEntries: [],
    fallbackController: controller,
    legacyPrematureRelease: true
  });
  const runId = "run_legacy";
  sandbox.__codexPreparedGraphRuns.set(runId, preparedInline(runId));
  state.postRunBusy = true;

  const inflight = fns.__codexRouteGraphManifestOrExport(runId, "/tmp");
  await new Promise((r) => setImmediate(r));

  const legacyBusyDuringPending = state.postRunBusy;
  const legacyReleases = state.releaseReasons.slice();

  controller.resolve();
  await inflight;

  // 负控制的意义：同一条断言在旧代码下必须为 false，否则断言没有鉴别力。
  check("D1 legacy DID prematurely release while fallback pending",
    legacyBusyDuringPending === false,
    "postRunBusy during pending=" + legacyBusyDuringPending);
  check("D2 legacy release reason is inline-snapshot-empty",
    legacyReleases.includes("inline-snapshot-empty"),
    JSON.stringify(legacyReleases));
  check("D3 therefore assertion A3 is discriminating (fails on legacy, passes on fixed)",
    legacyBusyDuringPending === false,
    "legacy=" + legacyBusyDuringPending);
  return { legacyBusyDuringPending, legacyReleases };
}

/** E. 静态确认：修复后的真源码里空分支不再含提前释放。 */
function caseStaticShapeOfFixedSource() {
  console.log("\n[E] static shape of the FIXED source (supporting, not sufficient)");
  const source = fs.readFileSync(BUNDLE, "utf8");
  const lines = source.split("\n");
  const start = findLine(lines, "function __codexRouteGraphSnapshotManifest(runId) {");
  const body = extractFunction(lines, start);
  const emptyBranch = body.slice(body.indexOf("if (!artifacts.length)"),
    body.indexOf("__codexGraphState = {"));

  check("E1 empty branch has no postRunBusy release",
    !emptyBranch.includes("__codexSetPostRunBusy"), "empty branch still releases");
  check("E2 empty branch still returns false",
    emptyBranch.includes("return false;"), "missing return false");
  check("E3 inline success release still present in function",
    body.includes('__codexSetPostRunBusy(false, "inline-snapshot-route-complete", runId)'),
    "success release missing");
  check("E4 outer finally release still present in bundle",
    source.includes('__codexSetPostRunBusy(false, "post-run-drain-complete", runId)'),
    "finally release missing");
}

async function main() {
  console.log("=== rc.7.39 inline-snapshot fallback readiness regression ===");
  console.log("bundle: " + BUNDLE);

  const fixed = await caseEmptyManifestPendingHoldsBusy();
  await caseFallbackRejectStillReleases();
  await caseInlineSuccessUnchanged();
  const legacy = await caseLegacyNegativeControl();
  caseStaticShapeOfFixedSource();

  console.log("\n--- fixed vs legacy, same assertion ---");
  console.log("  fixed  postRunBusy during pending fallback : true (correct)");
  console.log("  legacy postRunBusy during pending fallback : "
    + legacy.legacyBusyDuringPending + " (premature)");

  console.log("\n=== " + passed + " passed, " + failed + " failed ===");
  if (failed) {
    console.log("FAILURES:");
    failures.forEach((f) => console.log("  - " + f));
  }
  return failed === 0 ? 0 : 1;
}

main().then((code) => process.exit(code)).catch((error) => {
  console.error("HARNESS ERROR: " + (error && error.stack || error));
  process.exit(2);
});
