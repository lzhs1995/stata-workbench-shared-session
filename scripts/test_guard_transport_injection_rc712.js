"use strict";
/**
 * test_guard_transport_injection_rc712.js —— rc.7.12 注入代码的**执行级**验证
 *
 * 为什么需要它：静态 grep 只能证明「字符串进了 dist」，不能证明「这段 JS 真能跑对」。
 * 本测试把 dist 里注入的 __codexGuardTransport / __codexRecordSupersede **原样抽出**，
 * 在受控 sandbox 里配 mock zg / JA 执行，断言行为：
 *   · getRunExecutionState 能从 _runsByTaskId / _activeRun 解析出 taskId/logPath/logBytes
 *   · cancelTask 走协议 tasks/cancel，且回执如实（terminal:false → guard 会继续降级）
 *   · cancelRun/cancelAll 布尔归一
 *   · supersedeLookup 按 runId 命中历史记录；不匹配返回 null
 *   · __codexRecordSupersede 写出的记录能被 execution_guard 的证据核验**接受**
 *     （这是端到端契约：dist 生产的证据 ⇄ guard 消费的证据）
 *
 * 不需要真桥、不需要装机。`node scripts/test_guard_transport_injection_rc712.js`
 */
const assert = require("node:assert");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");
const EG = require("./execution_guard.js");

const DIST = path.join(__dirname, "..", "dist", "extension.js");

let pass = 0; const failures = [];
async function t(name, fn) {
  try { await fn(); pass++; console.log("  PASS " + name); }
  catch (e) { failures.push(name + " — " + ((e && e.message) || e));
              console.log("  FAIL " + name + "  — " + ((e && e.message) || e)); }
}

/** 从 dist 抽出注入块：__codexRecordSupersede=... 到 helper 结束的 marker */
function extractInjection(dist) {
  const start = dist.indexOf("globalThis.__codexRecordSupersede=");
  assert.ok(start > 0, "dist 里找不到 __codexRecordSupersede 注入");
  const endMarker = "};/* codex patch rc.7.12: guard transport adapter */";
  const end = dist.indexOf(endMarker, start);
  assert.ok(end > start, "dist 里找不到 rc.7.12 helper 结束 marker");
  return dist.slice(start, end + 2);   // 含 "};"
}

/** 在 sandbox 里执行注入块，注入 mock zg / JA */
function runInjection(mockZg, mockFs) {
  const dist = fs.readFileSync(DIST, "utf8");
  const code = extractInjection(dist);
  const sandbox = { zg: mockZg, JA: mockFs, Date: Date, String: String,
                    Number: Number, globalThis: null };
  sandbox.globalThis = sandbox;
  vm.createContext(sandbox);
  vm.runInContext(code, sandbox, { timeout: 5000 });
  return sandbox;
}

const mockFsWith = (sizes) => ({
  existsSync: (p) => Object.prototype.hasOwnProperty.call(sizes, p),
  statSync: (p) => ({ size: sizes[p] }),
});

(async function main() {
  console.log("=== rc.7.12 注入代码执行级验证（抽出真码跑，非 grep）===\n");

  console.log("[A] getRunExecutionState 身份解析");
  await t("A.1 从 _runsByTaskId 解析出 taskId/logPath/logBytes", () => {
    const run = { _runId: "run_1", taskId: "task_9", logPath: "/tmp/a.log" };
    const zg = { _runsByTaskId: new Map([["task_9", run]]), _activeRun: null };
    const s = runInjection(zg, mockFsWith({ "/tmp/a.log": 4096 }));
    const st = s.globalThis.__codexGuardTransport.getRunExecutionState("run_1");
    assert.strictEqual(st.found, true, "应解析到 run");
    assert.strictEqual(st.runId, "run_1");
    assert.strictEqual(st.taskId, "task_9", "taskId 未解析");
    assert.strictEqual(st.logPath, "/tmp/a.log");
    assert.strictEqual(st.logBytes, 4096, "logBytes 未从 statSync 取到");
    assert.strictEqual(st.transportAck, true);
  });
  await t("A.2 未知 runId → found=false 且不抛（不得续命）", () => {
    const zg = { _runsByTaskId: new Map(), _activeRun: null };
    const s = runInjection(zg, mockFsWith({}));
    const st = s.globalThis.__codexGuardTransport.getRunExecutionState("nope");
    assert.strictEqual(st.found, false);
    assert.strictEqual(st.taskId, null);
    assert.strictEqual(st.transportAck, false);
  });
  await t("A.3 _activeRun 兜底解析（无 taskId 映射时）", () => {
    const zg = { _runsByTaskId: new Map(),
                 _activeRun: { _runId: "run_2", taskId: null, logPath: null } };
    const s = runInjection(zg, mockFsWith({}));
    const st = s.globalThis.__codexGuardTransport.getRunExecutionState("run_2");
    assert.strictEqual(st.found, true);
    assert.strictEqual(st.runId, "run_2");
  });
  await t("A.4 logPath 不存在时 logBytes=null（不编造字节数）", () => {
    const zg = { _runsByTaskId: new Map([["t", { _runId: "r", taskId: "t",
                                                 logPath: "/missing.log" }]]) };
    const s = runInjection(zg, mockFsWith({}));
    const st = s.globalThis.__codexGuardTransport.getRunExecutionState("r");
    assert.strictEqual(st.logBytes, null);
  });

  console.log("\n[B] 三级取消原语");
  await t("B.1 cancelTask 按 Task.status 判终态（C5-2：非固定 true/false）", async () => {
    const seen = [];
    // 终态三种
    for (const st of ["completed", "failed", "cancelled"]) {
      const zg = { cancelTask: async (id) => { seen.push(id); return { taskId: id, status: st }; } };
      const s = runInjection(zg, mockFsWith({}));
      const r = await s.globalThis.__codexGuardTransport.cancelTask("T1");
      assert.strictEqual(r.terminal, true, st + " 应判终态");
      assert.strictEqual(r.confirmed, true, st + " 终态应记 confirmed");
      assert.strictEqual(r.taskStatus, st);
      assert.strictEqual(EG.normalizeCancelReceipt(r).confirmed, true,
                         st + " 经 guard 归一化后应算确认");
    }
    assert.deepStrictEqual(seen, ["T1", "T1", "T1"], "未把 taskId 直接传给 zg.cancelTask");
  });
  await t("B.1b working/input_required → 非终态，guard 不当确认（受理≠终止）", async () => {
    for (const st of ["working", "input_required"]) {
      const zg = { cancelTask: async () => ({ status: st }) };
      const s = runInjection(zg, mockFsWith({}));
      const r = await s.globalThis.__codexGuardTransport.cancelTask("T");
      assert.strictEqual(r.terminal, false, st + " 不该判终态");
      assert.strictEqual(r.confirmed, false);
      assert.strictEqual(EG.normalizeCancelReceipt(r).confirmed, false,
                         st + " 不该被当成终态确认");
    }
  });
  await t("B.1c status 缺失/异常形状 → 保守判非终态", async () => {
    for (const ret of [{}, { status: null }, { status: "weird" }, null, "str"]) {
      const zg = { cancelTask: async () => ret };
      const s = runInjection(zg, mockFsWith({}));
      const r = await s.globalThis.__codexGuardTransport.cancelTask("T");
      const conf = r === false ? false : r.confirmed;
      assert.strictEqual(conf, false, "异常返回 " + JSON.stringify(ret) + " 不该判终态");
    }
  });
  await t("B.2 无 cancelTask 能力 / null taskId → false（记 skipped 由 guard 处理）", async () => {
    const s = runInjection({}, mockFsWith({}));
    assert.strictEqual(await s.globalThis.__codexGuardTransport.cancelTask("X"), false);
    const s2 = runInjection({ cancelTask: async () => true }, mockFsWith({}));
    assert.strictEqual(await s2.globalThis.__codexGuardTransport.cancelTask(null), false);
  });
  await t("B.3 cancelRun 布尔归一 + 收到精确 runId", async () => {
    const seen = [];
    const zg = { cancelRun: async (id) => { seen.push(id); return true; } };
    const s = runInjection(zg, mockFsWith({}));
    assert.strictEqual(await s.globalThis.__codexGuardTransport.cancelRun("run_X"), true);
    assert.deepStrictEqual(seen, ["run_X"]);
    const zg2 = { cancelRun: async () => false };
    const s2 = runInjection(zg2, mockFsWith({}));
    assert.strictEqual(await s2.globalThis.__codexGuardTransport.cancelRun("r"), false,
                       "无源应返 false 以便继续降级");
  });
  await t("B.4 取消原语抛错被吞成 false（不外泄异常）", async () => {
    const zg = { cancelRun: async () => { throw new Error("boom"); },
                 cancelAll: async () => { throw new Error("boom2"); } };
    const s = runInjection(zg, mockFsWith({}));
    assert.strictEqual(await s.globalThis.__codexGuardTransport.cancelRun("r"), false);
    assert.strictEqual(await s.globalThis.__codexGuardTransport.cancelAll(), false);
  });

  console.log("\n[C] 控制面换代登记 ⇄ guard 证据核验（端到端契约）");
  await t("C.1 soft-stop 登记的记录能被 guard 接受为预期换代", () => {
    const s = runInjection({}, mockFsWith({}));
    // C5-4：登记侧显式传递递增前 generation（不再由 toGen-1 推导）
    const rec = s.globalThis.__codexRecordSupersede("soft-stop", "run_A", 5, "user stop", 4);
    assert.strictEqual(rec.kind, "soft-stop");
    assert.strictEqual(rec.fromGeneration, 4);
    assert.strictEqual(rec.beforeGeneration, 4, "须显式落盘 beforeGeneration");
    assert.strictEqual(rec.afterGeneration, 5, "须显式落盘 afterGeneration");
    assert.strictEqual(rec.toGeneration, 5);
    assert.ok(rec.token, "须带 token");
    assert.strictEqual(rec.consumedAt, null, "新登记应未消费");
    // 用 guard 的真核验器验证这条 dist 生产的记录
    const st = EG.createState(EG.POLICY.PROGRESS, { runId: "run_A", generation: 4 });
    const ok = EG.verifySupersedeEvidence(st, { runId: "run_A", generation: 5 },
      { supersedeLookup: () => rec });
    assert.strictEqual(ok, true, "dist 产的证据被 guard 拒了：" + st.supersedeRejectReason);
    assert.strictEqual(st.supersedeEvidence.kind, "soft-stop");
  });
  await t("C.1b dist 登记的 token 唯一（防两次换代撞同一 token）", () => {
    const s = runInjection({}, mockFsWith({}));
    const a = s.globalThis.__codexRecordSupersede("soft-stop", "r", 2, "x", 1);
    const b = s.globalThis.__codexRecordSupersede("soft-stop", "r", 3, "y", 2);
    assert.notStrictEqual(a.token, b.token, "两次登记 token 不得相同");
  });
  await t("C.2 force-reset 同样被接受", () => {
    const s = runInjection({}, mockFsWith({}));
    const rec = s.globalThis.__codexRecordSupersede("force-reset", "run_B", 9, "reset", 8);
    const st = EG.createState(EG.POLICY.PROGRESS, { runId: "run_B", generation: 8 });
    assert.strictEqual(EG.verifySupersedeEvidence(st, { runId: "run_B", generation: 9 },
      { supersedeLookup: () => rec }), true, st.supersedeRejectReason);
  });
  await t("C.3 未知 kind 登记后仍被 guard 拒（白名单生效）", () => {
    const s = runInjection({}, mockFsWith({}));
    const rec = s.globalThis.__codexRecordSupersede("mystery-relaunch", "run_C", 3, "?", 2);
    const st = EG.createState(EG.POLICY.PROGRESS, { runId: "run_C", generation: 2 });
    assert.strictEqual(EG.verifySupersedeEvidence(st, { runId: "run_C", generation: 3 },
      { supersedeLookup: () => rec }), false, "非白名单 kind 不该被接受");
    assert.strictEqual(st.supersedeRejectReason, "KIND_NOT_ALLOWED");
  });
  await t("C.4 supersedeLookup 按 runId 命中历史；不匹配返 null", () => {
    const s = runInjection({}, mockFsWith({}));
    const T = s.globalThis.__codexGuardTransport;
    s.globalThis.__codexRecordSupersede("soft-stop", "run_1", 2, "a", 1);
    s.globalThis.__codexRecordSupersede("force-reset", "run_2", 3, "b", 2);
    assert.strictEqual(T.supersedeLookup({ runId: "run_2" }).kind, "force-reset");
    assert.strictEqual(T.supersedeLookup({ runId: "run_1" }).kind, "soft-stop",
                       "应能回溯历史，不只看最后一条");
    assert.strictEqual(T.supersedeLookup({ runId: "never" }), null,
                       "不匹配必须返 null（否则会误排除计分）");
  });
  await t("C.5 无任何登记时 lookup 返 null（不得凭空排除）", () => {
    const s = runInjection({}, mockFsWith({}));
    assert.strictEqual(s.globalThis.__codexGuardTransport.supersedeLookup({ runId: "x" }), null);
  });
  await t("C.6 历史上限 50 条，不无限增长", () => {
    const s = runInjection({}, mockFsWith({}));
    for (let i = 0; i < 60; i++) s.globalThis.__codexRecordSupersede("soft-stop", "r" + i, i + 1, "x", i);
    assert.strictEqual(s.globalThis.__codexSupersedeHistory.length, 50);
  });
  await t("C.7b dist 登记器缺 fromGeneration → 拒绝登记（C5.1 fail-closed，无 -1 回退）", () => {
    const s = runInjection({}, mockFsWith({}));
    // 不传第 5 参（fromGen）→ 必须返回 null，而不是用 toGen-1 猜
    assert.strictEqual(s.globalThis.__codexRecordSupersede("soft-stop", "r", 5, "x"), null,
                       "缺 fromGeneration 仍登记 = 会造出无法核验的证据");
    assert.strictEqual(s.globalThis.__codexRecordSupersede("soft-stop", "r", 5, "x", null), null);
    // 显式给了才登记
    const ok = s.globalThis.__codexRecordSupersede("soft-stop", "r", 5, "x", 4);
    assert.ok(ok && ok.fromGeneration === 4);
  });

  await t("C.7 端到端一次性：dist 记录被 guard 消费后不可复用", () => {
    const s = runInjection({}, mockFsWith({}));
    const rec = s.globalThis.__codexRecordSupersede("soft-stop", "run_X", 3, "stop", 2);
    const s1 = EG.createState(EG.POLICY.PROGRESS, { runId: "run_X", generation: 2 });
    assert.strictEqual(EG.verifySupersedeEvidence(s1, { runId: "run_X", generation: 3 },
      { supersedeLookup: () => rec }), true, s1.supersedeRejectReason);
    const s2 = EG.createState(EG.POLICY.PROGRESS, { runId: "run_X", generation: 2 });
    assert.strictEqual(EG.verifySupersedeEvidence(s2, { runId: "run_X", generation: 3 },
      { supersedeLookup: () => rec }), false, "同一 dist 记录不得二次排除计分");
    assert.strictEqual(s2.supersedeRejectReason, "TOKEN_ALREADY_CONSUMED");
  });

  console.log("\n" + "=".repeat(58));
  console.log("  PASS=" + pass + "  FAIL=" + failures.length);
  if (failures.length) { failures.forEach((f) => console.log("   - " + f)); process.exit(1); }
})();
