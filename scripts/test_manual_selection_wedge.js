"use strict";
/**
 * test_manual_selection_wedge.js —— manual-selection 错误路径「卡死楔子」的**可执行**测试
 *
 * 真机血证（rc.7.13）：
 *   manual-selection 在 try 之前调 __codexBeginGraphRun(...)，它内部会
 *   __codexSetPostRunBusy(true,"manual-selection-begin",runId)；而它的 catch 原本**只有**
 *     }catch(t){throw e&&Gg.failStreamingEntry(e,t?.message||String(t)),t}
 *   ——一行释放都没有。于是 runSelection 结算前的任何抛出（含 guard 拒绝）都会把
 *   postRunBusy 永久钉在 true：实测 status=draining / trueReady=false 持续 371s 不自愈，
 *   期间所有 run 一律 409，只有 /force-reset 能在 9.0s 内救回。
 *
 * 为什么这个测试必须**真跑**而不是 grep：
 *   任务包明确「grep-only 断言不充分」。grep 只能证明字节在场，证不了
 *   「释放恰好一次」「原错误被原样重抛」「不会自动 PASS / 自动 force-reset」。
 *   完整 bundle 无法在测试进程里执行（需要 vscode 宿主），故按任务包给的第二条路：
 *   **从 dist 里抽出生成的确切 catch/处理片段**，配有状态的 stub 执行。
 *   片段是从 dist 字节现抽的——生成物一变，测试立刻跟着变（不会僵化成快照）。
 */
const assert = require("assert");
const fs = require("fs");
const path = require("path");

const DIST = path.join(__dirname, "..", "dist", "extension.js");
const SRC = fs.readFileSync(DIST, "utf8");

let pass = 0;
function t(name, fn) {
  const r = fn();
  const done = () => { pass++; console.log("  ok  " + name); };
  return r && typeof r.then === "function" ? r.then(done) : (done(), Promise.resolve());
}

// ---------------------------------------------------------------------------
// 1. 从 dist 抽出**确切的**生成片段（抽不到就失败，绝不退化成"跳过"）
// ---------------------------------------------------------------------------
function cut(from, to, startAt) {
  const a = SRC.indexOf(from, startAt || 0);
  if (a < 0) throw new Error("抽取失败：找不到起点 " + JSON.stringify(from.slice(0, 48)));
  const b = SRC.indexOf(to, a + from.length);
  if (b < 0) throw new Error("抽取失败：找不到终点 " + JSON.stringify(to.slice(0, 48)));
  return { text: SRC.slice(a, b + to.length), start: a, end: b + to.length };
}

function cutExact(literal, startAt) {
  const a = SRC.indexOf(literal, startAt || 0);
  if (a < 0) throw new Error("抽取失败：找不到片段 " + JSON.stringify(literal.slice(0, 48)));
  return { text: literal, start: a, end: a + literal.length };
}

const CAPTURE = cutExact(
  "let __codexManualResetGeneration=Number(globalThis.__codexResetGeneration||0);"
);
const BEGIN = cut(
  'if(e&&globalThis.__codexBeginGraphRun)await __codexBeginGraphRun(e,"manual-selection",B,',
  ");",
  CAPTURE.end
);
const CATCH = cut(
  "}catch(t){let __codexManualResetStale=",
  "throw e&&Gg.failStreamingEntry(e,t?.message||String(t)),t}",
  BEGIN.end
);

// 生成片段唯一性：同形态字节只能出现一次，否则说明补丁重复注入
for (const [label, frag] of [["capture", CAPTURE], ["catch", CATCH]]) {
  const n = SRC.split(frag.text).length - 1;
  assert.strictEqual(n, 1, label + " 片段应恰好出现 1 次，实际 " + n);
}

// ---------------------------------------------------------------------------
// 2. 有状态 stub：模拟真实 graph/post-run readiness 状态机
// ---------------------------------------------------------------------------
function makeWorld(opts) {
  const o = opts || {};
  const w = {
    postRunBusy: false,
    postRunReason: null,
    releases: [],          // 每次释放（无论走哪条腿）
    beginCalls: [],
    marks: [],
    logs: [],
    failStreaming: [],
    forceResets: 0,        // 必须恒为 0：绝不允许自动 force-reset
    resetGeneration: Number(o.resetGeneration || 0),
  };
  const G = {
    __codexResetGeneration: w.resetGeneration,
    __codexBeginGraphRun: async (runId, source, cwd, captureBaseline) => {
      w.beginCalls.push({ runId, source, cwd, captureBaseline });
      w.postRunBusy = true;
      w.postRunReason = String(source || "run") + "-begin";
    },
    __codexGraphMark: (patch) => { w.marks.push(patch); },
    // 只有生产已存在的两条释放腿；哪条被调用由生成片段决定
    __codexSetPostRunBusy: (busy, reason, runId) => {
      w.releases.push({ leg: "setPostRunBusy", busy, reason, runId });
      w.postRunBusy = !!busy;
      w.postRunReason = reason;
    },
    // 触发一次 reset 世代跳变（模拟并发 /force-reset）
    __bumpGeneration: () => { G.__codexResetGeneration = Number(G.__codexResetGeneration) + 1; },
    // 哨兵：若生成片段擅自调 force-reset，这里会记账 → 断言必然失败
    __codexForceReset: () => { w.forceResets++; },
  };
  if (o.withNoExport !== false) {
    G.__codexFinishGraphRunNoExport = (runId, reason) => {
      w.releases.push({ leg: "finishGraphRunNoExport", busy: false, reason, runId });
      w.postRunBusy = false;
      w.postRunReason = reason;
    };
  }
  return { w, G };
}

/**
 * 用**抽出的确切片段**合成可执行体。
 * 结构与 dist 完全同形：capture → begin → try{ body } → 抽出的 catch。
 *
 * 关于双形态名字（必须忠实复刻，否则测试会测错东西）：
 *   生成片段既读 `globalThis.__codexFinishGraphRunNoExport`（作存在性闸门），
 *   又裸调 `__codexFinishGraphRunNoExport(...)`。生产里两者都能解析——
 *   四个助手是 activate 大箭头 [5225979,5539751) 内的函数声明（裸名词法可达），
 *   同时各有**恰好一个** `globalThis.X = ...` 导出点
 *   （__codexSetPostRunBusy@5395097 / __codexBeginGraphRun@5487123 /
 *     __codexFinishGraphRunNoExport@5496126 / __codexGraphMark@5395994 族）。
 *   所以 prelude 必须把两种形态都喂上，只喂一种都会得出假结论。
 */
function buildRunner() {
  const prelude =
    "let __codexBeginGraphRun=globalThis.__codexBeginGraphRun," +
    "__codexFinishGraphRunNoExport=globalThis.__codexFinishGraphRunNoExport," +
    "__codexSetPostRunBusy=globalThis.__codexSetPostRunBusy," +
    "__codexGraphMark=globalThis.__codexGraphMark;";
  const body =
    "return (async function(e,B,Gg,RI,__codexPreparedGraphRun,__body){" +
    prelude +
    CAPTURE.text +
    BEGIN.text +
    "try{ return await __body(); " +
    CATCH.text +
    "})";
  // 片段里所有 globalThis.* 访问都落到注入的 G 上
  return new Function("globalThis", body);
}
const RUNNER_SRC = buildRunner;

function run(world, bodyFn, opts) {
  const o = opts || {};
  const fn = RUNNER_SRC()(world.G);
  const Gg = {
    failStreamingEntry: (id, msg) => { world.w.failStreaming.push({ id, msg }); },
  };
  const RI = (m) => { world.w.logs.push(m); };
  return fn(
    o.runId === undefined ? "run-A" : o.runId,
    o.cwd || "/tmp/cwd",
    Gg,
    RI,
    o.prepared === undefined ? { captureBaseline: true } : o.prepared,
    bodyFn
  );
}

// ---------------------------------------------------------------------------
// 3. 测试
// ---------------------------------------------------------------------------
const tests = [];

tests.push(() => t("W0: 抽出的片段可解析且 begin 真会置 postRunBusy（复现楔子前提）", async () => {
  const world = makeWorld();
  await run(world, async () => "ok");
  assert.strictEqual(world.w.beginCalls.length, 1, "begin 必须被调用");
  assert.strictEqual(world.w.beginCalls[0].source, "manual-selection");
  // 成功路径不经过 catch，故这里 busy 仍为 true —— 正是楔子的成因
  assert.strictEqual(world.w.postRunBusy, true, "begin 置 busy=true 是楔子前提");
}));

tests.push(() => t("W1: runSelection 前的**同步实参求值失败**仍释放 post-run readiness", async () => {
  const world = makeWorld();
  const boom = new Error("argument evaluation exploded before runSelection");
  let caught = null;
  try {
    // 同步抛出，模拟 guardWrap 实参（policy 表达式 / 选区字符串）求值即炸
    await run(world, () => { throw boom; });
  } catch (e) { caught = e; }
  assert.strictEqual(caught, boom, "必须原样重抛原错误对象");
  assert.strictEqual(world.w.postRunBusy, false, "楔子核心：必须已释放");
  assert.strictEqual(world.w.releases.length, 1, "释放恰好一次");
  assert.strictEqual(world.w.releases[0].leg, "finishGraphRunNoExport", "优先走 NoExport 腿");
  assert.strictEqual(world.w.releases[0].reason, "manual-selection-error-release");
  assert.strictEqual(world.w.releases[0].runId, "run-A");
}));

tests.push(() => t("W2: guard 拒绝（异步 reject）释放恰好一次，且错误原样重抛", async () => {
  const world = makeWorld();
  const guardErr = new Error("guard: PROGRESS idle deadline exceeded");
  guardErr.code = "GUARD_TIMEOUT";
  let caught = null;
  try {
    await run(world, async () => { throw guardErr; });
  } catch (e) { caught = e; }
  assert.strictEqual(caught, guardErr, "guard 错误必须原样重抛，不能被包装/吞掉");
  assert.strictEqual(caught.code, "GUARD_TIMEOUT", "错误属性不得丢失");
  assert.strictEqual(world.w.postRunBusy, false);
  assert.strictEqual(world.w.releases.length, 1, "释放恰好一次");
  assert.deepStrictEqual(world.w.marks, [{ lastClientError: "guard: PROGRESS idle deadline exceeded" }]);
}));

tests.push(() => t("W3: 普通产品错误（非 guard）同样释放恰好一次", async () => {
  const world = makeWorld();
  const prodErr = new Error("r(603) file not found");
  let caught = null;
  try {
    await run(world, async () => { throw prodErr; });
  } catch (e) { caught = e; }
  assert.strictEqual(caught, prodErr);
  assert.strictEqual(world.w.postRunBusy, false, "产品错误也必须释放，不能只救 guard 错误");
  assert.strictEqual(world.w.releases.length, 1);
  assert.strictEqual(world.w.failStreaming.length, 1, "产品的 failStreamingEntry 行为保持");
  assert.strictEqual(world.w.failStreaming[0].msg, "r(603) file not found");
}));

tests.push(() => t("W4: 成功的 manual selection 保持成功/导出行为——不被释放逻辑污染", async () => {
  const world = makeWorld();
  const out = await run(world, async () => ({ ok: true, rc: 0, graphs: ["g1.svg"] }));
  assert.deepStrictEqual(out, { ok: true, rc: 0, graphs: ["g1.svg"] }, "成功值必须原样返回");
  assert.strictEqual(world.w.releases.length, 0, "成功路径不得触发错误释放");
  assert.strictEqual(world.w.marks.length, 0, "成功路径不得写 lastClientError");
  assert.strictEqual(world.w.failStreaming.length, 0, "成功路径不得 failStreamingEntry");
  assert.strictEqual(world.w.logs.length, 0, "成功路径不得打错误释放日志");
}));

tests.push(() => t("W5: 绝不自动 PASS、绝不自动 force-reset", async () => {
  const world = makeWorld();
  const err = new Error("must surface to user");
  let threw = false;
  try { await run(world, async () => { throw err; }); } catch (e) { threw = true; assert.strictEqual(e, err); }
  assert.strictEqual(threw, true, "错误必须冒出去——不允许把产品错误变成 PASS");
  assert.strictEqual(world.w.forceResets, 0, "不允许静默 force-reset");
  assert.ok(!CATCH.text.includes("__codexForceReset"), "生成片段本身不得含 force-reset");
  assert.ok(!/return\s+(?:{|true|null)/.test(CATCH.text), "catch 不得改成返回值（吞错误）");
  assert.ok(CATCH.text.trimEnd().endsWith(",t}"), "catch 必须以重抛原错误 t 结尾");
}));

tests.push(() => t("W6: 无 FinishGraphRunNoExport 时退化到 SetPostRunBusy 腿，仍恰好释放一次", async () => {
  const world = makeWorld({ withNoExport: false });
  const err = new Error("fallback leg");
  try { await run(world, async () => { throw err; }); } catch { /* 预期 */ }
  assert.strictEqual(world.w.releases.length, 1, "回退腿也只释放一次");
  assert.strictEqual(world.w.releases[0].leg, "setPostRunBusy");
  assert.strictEqual(world.w.releases[0].busy, false);
  assert.strictEqual(world.w.postRunBusy, false);
}));

tests.push(() => t("W7: reset 世代跳变（并发 force-reset）时**不**释放——避免踩别人的新 run", async () => {
  const world = makeWorld({ resetGeneration: 7 });
  const err = new Error("stale run error");
  let caught = null;
  try {
    await run(world, async () => { world.G.__bumpGeneration(); throw err; });
  } catch (e) { caught = e; }
  assert.strictEqual(caught, err, "陈旧也必须重抛原错误");
  assert.strictEqual(world.w.releases.length, 0, "世代已变 → 释放必须跳过");
  assert.strictEqual(world.w.marks.length, 0);
}));

tests.push(() => t("W8: 释放腿自身抛出也不得掩盖产品错误（try/catch 包裹生效）", async () => {
  const world = makeWorld();
  world.G.__codexFinishGraphRunNoExport = () => { throw new Error("release leg itself failed"); };
  const prodErr = new Error("the real product error");
  let caught = null;
  try { await run(world, async () => { throw prodErr; }); } catch (e) { caught = e; }
  assert.strictEqual(caught, prodErr, "用户必须看到产品错误，而不是释放腿的内部错误");
}));

tests.push(() => t("W9: 错误释放会留可诊断痕迹（日志 + lastClientError）", async () => {
  const world = makeWorld();
  try { await run(world, async () => { throw new Error("diagnosable"); }); } catch { /* 预期 */ }
  assert.strictEqual(world.w.logs.length, 1);
  assert.ok(/\[Codex manual\] error release: diagnosable/.test(world.w.logs[0]), world.w.logs[0]);
  assert.deepStrictEqual(world.w.marks, [{ lastClientError: "diagnosable" }]);
}));

tests.push(() => t("W10: 非 Error 抛出物（字符串/undefined）也释放且原样重抛", async () => {
  for (const thrown of ["plain string failure", undefined, 0]) {
    const world = makeWorld();
    let caught = "NOTHING";
    try { await run(world, async () => { throw thrown; }); } catch (e) { caught = e; }
    assert.strictEqual(caught, thrown, "必须原样重抛 " + String(thrown));
    assert.strictEqual(world.w.releases.length, 1, "非 Error 也必须释放：" + String(thrown));
    assert.strictEqual(world.w.postRunBusy, false);
  }
}));

tests.push(() => t("W11: rc.7.13 的**旧 catch**在同一 harness 下必然楔死（证明测试有鉴别力）", async () => {
  const OLD_CATCH = "}catch(t){throw e&&Gg.failStreamingEntry(e,t?.message||String(t)),t}";
  assert.ok(!SRC.includes(OLD_CATCH), "rc.7.14 dist 里不应再有裸旧 catch");
  const world = makeWorld();
  const Gg = { failStreamingEntry: () => {} };
  try {
    const oldRunner = new Function(
      "globalThis",
      "return (async function(e,B,Gg,RI,__codexPreparedGraphRun,__body){" +
        "let __codexBeginGraphRun=globalThis.__codexBeginGraphRun;" +
        CAPTURE.text + BEGIN.text + "try{ return await __body(); " + OLD_CATCH + "})"
    );
    await oldRunner(world.G)("run-A", "/tmp/cwd", Gg, () => {}, { captureBaseline: true },
      async () => { throw new Error("boom"); });
  } catch { /* 预期 */ }
  assert.strictEqual(world.w.postRunBusy, true, "旧 catch 必须复现楔死（否则本测试没有鉴别力）");
  assert.strictEqual(world.w.releases.length, 0);
}));

(async () => {
  try {
    for (const fn of tests) await fn();
    console.log("MANUAL_SELECTION_WEDGE_TESTS  " + pass + "/" + tests.length + " passed");
    if (pass !== tests.length) process.exit(1);
  } catch (e) {
    console.error("MANUAL_SELECTION_WEDGE_TESTS FAILED :: " + (e && e.stack ? e.stack : e));
    process.exit(1);
  }
})();
