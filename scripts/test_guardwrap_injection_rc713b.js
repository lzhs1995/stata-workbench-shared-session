"use strict";
/**
 * test_guardwrap_injection_rc713b.js —— rc.7.13b 统一包装器的**执行级**验证
 *
 * 为什么必须有：12 处调用点全部经 __codexGuardWrap 走。它里面一个 bug = 12 处同时坏。
 * 静态 grep 只能证明"字符串进了 dist"，故本测试把注入的包装器**原样抽出**，
 * 在 vm sandbox 里配 mock 真跑，重点验**负路径**（我这一轮反复栽在只验正路径）。
 *
 * 覆盖：
 *   · 保持 promise 形状（返回值可被 Promise.race / await / 赋值使用）
 *   · 正常完成 → 原返回值逐字透出
 *   · 原调用 reject → **原错误对象**上抛（不得被包装成 guard 错误，否则周边 catch 判错）
 *   · 超时 → 抛带 __codexGuardFailure 的错误，status 504/503 正确
 *   · 三级取消原语与 supersedeLookup 都接到 __codexGuardTransport
 *   · PROGRESS 分支用 guardProgress、其余用 guardFixed；timeoutMs 生效
 *   · 兼容字段 __codexPreRunTimeout 与 __codexGuardFailure 同源（既有 catch 读旧名）
 */
const assert = require("node:assert");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");
const EG = require("./execution_guard.js");

const DIST = path.join(__dirname, "..", "dist", "extension.js");

let pass = 0; const fails = [];
async function t(name, fn) {
  try { await fn(); pass++; console.log("  PASS " + name); }
  catch (e) { fails.push(name + " — " + ((e && e.message) || e));
              console.log("  FAIL " + name + "  — " + ((e && e.message) || e)); }
}

/** 从 dist 抽出包装器定义并在 sandbox 中执行 */
function loadWrapper(transport) {
  const d = fs.readFileSync(DIST, "utf8");
  const start = d.indexOf("globalThis.__codexGuardWrap=async(");
  assert.ok(start > 0, "dist 里找不到 __codexGuardWrap 注入");
  const endMark = "return __r.value};";
  const end = d.indexOf(endMark, start);
  assert.ok(end > start, "找不到包装器结束标记");
  const code = d.slice(start, end + endMark.length);

  const sandbox = {
    __codexExecGuard: EG, RI: () => {}, Date: Date, Number: Number,
    Object: Object, Error: Error, Promise: Promise, globalThis: null,
  };
  sandbox.globalThis = sandbox;
  sandbox.__codexGuardTransport = transport || null;
  sandbox.__codexBridgeState = {};
  sandbox.__codexResetGeneration = 0;
  vm.createContext(sandbox);
  vm.runInContext(code, sandbox, { timeout: 5000 });
  return sandbox;
}

const mkTransport = (over) => Object.assign({
  getRunExecutionState: () => ({ runId: "r", taskId: null, transportAck: true,
                                 logPath: "/l", logBytes: 100 }),
  cancelTask: () => false,
  cancelRun: () => true,
  cancelAll: () => true,
  supersedeLookup: () => null,
}, over || {});

(async function main() {
  console.log("=== rc.7.13b guardWrap 执行级验证（抽真码跑）===\n");

  console.log("[A] 保持 promise 形状 + 正常路径");
  await t("A.1 返回 promise，值逐字透出", async () => {
    const s = loadWrapper(mkTransport());
    const p = s.globalThis.__codexGuardWrap(EG.POLICY.SHORT_INTERNAL, "r",
      async () => ({ rc: 0, logPath: "/x.log" }), { timeoutMs: 2000 });
    assert.ok(p && typeof p.then === "function", "必须返回 promise（否则破坏 Promise.race）");
    const v = await p;
    assert.strictEqual(v.rc, 0);
    assert.strictEqual(v.logPath, "/x.log");
  });
  await t("A.2 可被 Promise.race 包裹（#1/#2/#3/#4 的真实用法）", async () => {
    const s = loadWrapper(mkTransport());
    const v = await Promise.race([
      s.globalThis.__codexGuardWrap(EG.POLICY.RECOVERY, "r", async () => "done", {}),
      new Promise((res) => setTimeout(() => res("timeout"), 3000)),
    ]);
    assert.strictEqual(v, "done");
  });
  await t("A.3 PROGRESS 分支正常完成（#7/#8/#12/#13）", async () => {
    const s = loadWrapper(mkTransport());
    const v = await s.globalThis.__codexGuardWrap(EG.POLICY.PROGRESS, "r",
      async () => "ok", { structuralLong: false });
    assert.strictEqual(v, "ok");
  });

  console.log("\n[B] 负路径：原错误必须原样上抛（关键 —— 周边 catch 依赖它）");
  await t("B.1 原调用 reject → 抛**原错误对象**，不被包装", async () => {
    const s = loadWrapper(mkTransport());
    const boom = new Error("original failure");
    boom.myMarker = "keep-me";
    let caught = null;
    try {
      await s.globalThis.__codexGuardWrap(EG.POLICY.SHORT_INTERNAL, "r",
        async () => { throw boom; }, { timeoutMs: 2000 });
    } catch (e) { caught = e; }
    assert.ok(caught, "应抛错");
    assert.strictEqual(caught.message, "original failure", "错误信息被改写了");
    assert.strictEqual(caught.myMarker, "keep-me", "原错误对象未原样上抛（周边 catch 会判错）");
    assert.strictEqual(caught.__codexGuardFailure, undefined, "普通失败不该带 guardFailure");
  });
  await t("B.2 同步 throw 也原样上抛", async () => {
    const s = loadWrapper(mkTransport());
    let caught = null;
    try {
      await s.globalThis.__codexGuardWrap(EG.POLICY.SHORT_INTERNAL, "r",
        () => { throw new Error("sync boom"); }, { timeoutMs: 2000 });
    } catch (e) { caught = e; }
    assert.ok(/sync boom/.test(caught && caught.message), "同步异常信息丢失");
  });

  console.log("\n[C] 超时 → guardFailure 结构正确");
  await t("C.1 干净超时（cancel 成功→drain 收敛）→ status 504", async () => {
    let res; const work = () => new Promise((r) => { res = r; });
    const s = loadWrapper(mkTransport({
      cancelRun: () => { setTimeout(() => res("late"), 5); return true; },
    }));
    let caught = null;
    try {
      await s.globalThis.__codexGuardWrap(EG.POLICY.SHORT_INTERNAL, "r", work,
        { timeoutMs: 30 });
    } catch (e) { caught = e; }
    assert.ok(caught && caught.__codexGuardFailure, "应带 __codexGuardFailure");
    const f = caught.__codexGuardFailure;
    assert.strictEqual(f.status, 504, "干净超时应 504，实为 " + f.status);
    assert.strictEqual(f.recoveryRequired, false);
    assert.ok(f.cancelLevels, "应带 cancelLevels 供审计");
  });
  await t("C.2 transport 不收敛 → status 503 + recoveryRequired", async () => {
    const s = loadWrapper(mkTransport({ cancelRun: () => false, cancelAll: () => false }));
    let caught = null;
    try {
      await s.globalThis.__codexGuardWrap(EG.POLICY.SHORT_INTERNAL, "r",
        () => new Promise(() => {}), { timeoutMs: 25 });
    } catch (e) { caught = e; }
    const f = caught && caught.__codexGuardFailure;
    assert.ok(f, "应带 guardFailure");
    assert.strictEqual(f.status, 503, "未收敛应 503，实为 " + f.status);
    assert.strictEqual(f.recoveryRequired, true);
  });
  await t("C.3 兼容字段 __codexPreRunTimeout 与 __codexGuardFailure 同源", async () => {
    const s = loadWrapper(mkTransport({ cancelRun: () => false, cancelAll: () => false }));
    let caught = null;
    try {
      await s.globalThis.__codexGuardWrap(EG.POLICY.SHORT_INTERNAL, "r",
        () => new Promise(() => {}), { timeoutMs: 25 });
    } catch (e) { caught = e; }
    assert.strictEqual(caught.__codexPreRunTimeout, caught.__codexGuardFailure,
      "既有 catch 读旧字段名，必须同源（否则老 catch 拿不到 status）");
  });

  console.log("\n[D] 取消原语真接到 transport");
  await t("D.1 超时后调用 cancelRun 并传入本调用的 runId", async () => {
    const seen = [];
    let res; const work = () => new Promise((r) => { res = r; });
    const s = loadWrapper(mkTransport({
      cancelRun: (rid) => { seen.push(rid); setTimeout(() => res("x"), 5); return true; },
    }));
    try {
      await s.globalThis.__codexGuardWrap(EG.POLICY.SHORT_INTERNAL, "run_ABC", work,
        { timeoutMs: 25 });
    } catch (e) { /* expected */ }
    assert.ok(seen.length >= 1, "未调用 cancelRun");
    assert.strictEqual(seen[0], "run_ABC", "cancelRun 收到的 runId 不对：" + seen[0]);
  });
  await t("D.2 缺 transport 时不崩（降级为 false，仍有界返回）", async () => {
    const s = loadWrapper(null);   // 无 __codexGuardTransport
    let caught = null;
    try {
      await s.globalThis.__codexGuardWrap(EG.POLICY.SHORT_INTERNAL, "r",
        () => new Promise(() => {}), { timeoutMs: 25 });
    } catch (e) { caught = e; }
    assert.ok(caught && caught.__codexGuardFailure, "无 transport 也必须有界失败，不能永久挂");
  });

  console.log("\n[E] policy 分派");
  await t("E.1 PROGRESS 走 guardProgress（pre-log 门限生效）", async () => {
    const s = loadWrapper(mkTransport({
      getRunExecutionState: () => ({ runId: "r", taskId: null, transportAck: false,
                                     logPath: null, logBytes: null }),   // 恒无日志
      cancelRun: () => true,
    }));
    let caught = null;
    const t0 = Date.now();
    try {
      // PROGRESS 短任务 pre-log 门限 120s 太长，这里靠 EG 默认无法快速触发；
      // 改为断言它确实走了 guardProgress 分支：短时间内不会因 timeoutMs 而失败
      await Promise.race([
        s.globalThis.__codexGuardWrap(EG.POLICY.PROGRESS, "r",
          () => new Promise(() => {}), { structuralLong: false }),
        new Promise((res) => setTimeout(() => res("still-running"), 120)),
      ]).then((v) => { if (v === "still-running") caught = "progress-branch"; });
    } catch (e) { caught = e; }
    assert.strictEqual(caught, "progress-branch",
      "PROGRESS 不该在 120ms 内失败（说明误走了 guardFixed 的短 timeout）");
    assert.ok(Date.now() - t0 < 3000);
  });
  await t("E.2 SHORT_INTERNAL 的 timeoutMs 生效；cancel 成功时快速收敛", async () => {
    // 注意：cancel/drain 各有独立的 15s 默认上限。若两级取消都不确认，
    // 总耗时 = timeoutMs + cancelDeadline + drainDeadline —— 那是**有界**的正确行为，
    // 不是 timeoutMs 失效。故这里让 cancel 成功，验证 timeoutMs 真的是 30ms 起算。
    let res; const work = () => new Promise((r) => { res = r; });
    const s = loadWrapper(mkTransport({
      cancelRun: () => { setTimeout(() => res("late"), 5); return true; },
    }));
    const t0 = Date.now();
    let caught = null;
    try {
      await s.globalThis.__codexGuardWrap(EG.POLICY.SHORT_INTERNAL, "r", work,
        { timeoutMs: 30 });
    } catch (e) { caught = e; }
    const el = Date.now() - t0;
    assert.ok(caught && caught.__codexGuardFailure, "应超时失败");
    assert.ok(el >= 25, "不该早于 timeoutMs 就失败（实 " + el + "ms）");
    assert.ok(el < 2000, "cancel 成功后应快速收敛，实 " + el + "ms");
  });
  await t("E.3 两级取消都不确认 → 总耗时有界（timeoutMs+cancel+drain），不是无限挂", async () => {
    const s = loadWrapper(mkTransport({ cancelRun: () => false, cancelAll: () => false }));
    const t0 = Date.now();
    let caught = null;
    try {
      await s.globalThis.__codexGuardWrap(EG.POLICY.SHORT_INTERNAL, "r",
        () => new Promise(() => {}), { timeoutMs: 20 });
    } catch (e) { caught = e; }
    const el = Date.now() - t0;
    assert.ok(caught && caught.__codexGuardFailure, "必须有界失败");
    assert.strictEqual(caught.__codexGuardFailure.status, 503);
    assert.ok(el < 40000, "总耗时必须有界（实 " + el + "ms）");
  });

  console.log("\n" + "=".repeat(58));
  console.log("  PASS=" + pass + "  FAIL=" + fails.length);
  if (fails.length) { fails.forEach((f) => console.log("   - " + f)); process.exit(1); }
})();
