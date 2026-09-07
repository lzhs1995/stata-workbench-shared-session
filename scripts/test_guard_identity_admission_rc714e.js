"use strict";
/**
 * rc.7.14e：guard 模块身份必须在**准入**上 fail closed —— 可执行负向测试
 * ==================================================================
 * 为什么需要这一套（R1 的教训，必须写下来）：
 *   R1 的 test_guard_module_identity_rc714.js 有 9 个测试全绿，却**测不出** supervisor 的 P1。
 *   原因是那套 harness 只抽 COMPUTE / STATUS_FN 两个片段跑，能断言的事实只有
 *   「guardModuleIdentityState 这个字段的值对不对」。而缺陷恰恰在字段之外：
 *   字段被 spread 进 /status 的时机在 trueReady **算完之后**，且没有任何准入路径读它，
 *   于是 {trueReady:true, guardModuleIdentityState:"MODULE_UNREADABLE"} 可表示且照常放行。
 *   ——「测一个字段的覆盖」不等于「测一道门禁的覆盖」，这与 R1-2C 本身
 *   （语法覆盖 ≠ 作用域可执行）是同一类错误。
 *
 * 所以本文件的断言对象一律是**判决**，不是字段：
 *   gate.ready / acquireDecision().ok / httpStatus / kind。
 * 且必须真跑 dist 里生成的门禁函数与回退函数，不用 grep 代替。
 */
const assert = require("assert");
const fs = require("fs");
const path = require("path");
const crypto = require("crypto");

const REPO = path.resolve(__dirname, "..");
// 允许指向变异后的 bundle：变异探针（mutation probe）用它证明本套测试确有判别力。
// 默认仍是仓库产物；env 覆盖不改变默认行为。
const DIST = process.env.ADMISSION_DIST
  ? path.resolve(process.env.ADMISSION_DIST)
  : path.join(REPO, "dist", "extension.js");
const SRC = fs.readFileSync(DIST, "utf8");
const CONTROL = require("./control_plane_core.js");

let pass = 0;
const fails = [];
function t(name, fn) {
  try { fn(); pass++; console.log("  PASS " + name); }
  catch (e) { fails.push(name + " :: " + (e && e.message)); console.log("  FAIL " + name + "\n        " + (e && e.message)); }
}

/** 从 dist 精确抽取一段（起点字面量 → 括号配平的函数体结束） */
function cutFunction(headLiteral) {
  const at = SRC.indexOf(headLiteral);
  assert.ok(at >= 0, "抽取失败：找不到 " + headLiteral.slice(0, 60));
  assert.strictEqual(SRC.indexOf(headLiteral, at + headLiteral.length), -1,
    "抽取失败：不唯一 " + headLiteral.slice(0, 60));
  const brace = SRC.indexOf("{", at + headLiteral.length - 1);
  let d = 0, i = brace;
  for (; i < SRC.length; i++) {
    if (SRC[i] === "{") d++;
    else if (SRC[i] === "}") { d--; if (d === 0) { i++; break; } }
  }
  return { at, text: SRC.slice(at, i) };
}

const VERDICT = cutFunction("globalThis.__codexGuardIdentityVerdict=function()");
const FALLBACK = cutFunction("globalThis.__codexReadinessFallback=function(__b,__base)");
const GATE = cutFunction("function __codexTrueReadyStatus(bridgeState, baseStatus)");

/**
 * 造一个隔离的 global 舞台并把三段真实生成代码装进去。
 * 注意：new Function 体在全局作用域运行，形参 g 会**遮蔽**真 globalThis，
 * 故门禁内部对 globalThis.* 的读取必须走我们注入的 g（R1 楔死 harness 踩过同一个坑）。
 */
function stage(opts) {
  const o = opts || {};
  const g = {
    __codexBridgeState: o.bridge || { busy: false, postRunBusy: false },
    __codexGraphPanelDiag: o.graph || {},
    __codexControlPlane: o.controlPlane || null,
    __codexRecoveryState: o.recovery || null,
    __codexContinuityLost: o.continuityLost || null,
    __codexPreAcquireBarrier: o.barrier || null,
  };
  // rc.7.14 全局导出契约：默认在场（=本 bundle 确实打过 guard 补丁）
  if (o.exportsPresent !== false) {
    g.__codexExecGuardRef = {}; g.__codexPreRunGuardRef = {};
  }
  // 身份助手：可注入任意状态，或整体缺席
  if (o.identity !== "absent") {
    const I = o.identity || { guardModuleIdentityState: "OK", guardModuleIdentityError: null };
    g.__codexGuardModuleIdentityStatus = o.identityThrows
      ? function () { throw new Error(o.identityThrows); }
      : function () { return I; };
  }
  new Function("globalThis", VERDICT.text + ";" + FALLBACK.text + ";")(g);
  if (o.gate !== "absent") {
    const fn = new Function("globalThis", GATE.text + "; return __codexTrueReadyStatus;")(g);
    g.__codexTrueReadyStatus = fn;
  }
  return g;
}

/**
 * 4 个消费点的**原样字节**抽取。
 * 关键：不许我自己手写一份「等价的」就绪表达式再断言它 —— 那只证明我的复制品自洽，
 * 一旦 dist 里某个消费点没改到（3/4 半修），手写版照样全绿。
 * 故这里逐点抽 dist 中真实的三元表达式文本并直接求值。
 * 四点形态本就不统一（实参顺序不同、bare 名与 globalThis. 前缀混用、
 * poller 用 !(s.busy||s.postRunBusy)），抽取必须按点独立做。
 */
function cutTernaries() {
  const HEAD = "globalThis.__codexTrueReadyStatus?";
  const MID = ":(globalThis.__codexReadinessFallback?";
  const out = [];
  let i = -1;
  while ((i = SRC.indexOf(HEAD, i + 1)) >= 0) {
    const mid = SRC.indexOf(MID, i);
    assert.ok(mid > 0, "消费点缺共享回退分支 @" + i);
    // MID 必须属于**本**消费点：若 i..mid 之间还夹着另一个 HEAD，
    // 说明本点的回退分支被摘掉了（半修），而我们错抓了下一个点的标记。
    const nextHead = SRC.indexOf(HEAD, i + HEAD.length);
    assert.ok(nextHead < 0 || nextHead > mid,
      "消费点 @" + i + " 的共享回退分支缺失（抓到的是下一个消费点的标记）→ 疑似只改了部分消费点");
    let d = 0, j = mid + 1, end = -1;
    for (; j < SRC.length; j++) {
      if (SRC[j] === "(") d++;
      else if (SRC[j] === ")") { d--; if (d === 0) { end = j + 1; break; } }
    }
    assert.ok(end > 0, "三元表达式括号未配平 @" + i);
    out.push({ at: i, expr: SRC.slice(i, end) });
  }
  return out;
}
const TERNARIES = cutTernaries();
assert.strictEqual(TERNARIES.length, 4, "消费点数不是 4，实得 " + TERNARIES.length);

// 每点的自由变量（顺序即 dist 中出现顺序：status / acquire / preflight / poller）
const SITE_VARS = [
  { name: "status endpoint", params: ["o", "s"] },
  { name: "normal acquire", params: ["s", "__codexAcquireStatus"] },
  { name: "http preflight", params: ["s", "__base"] },
  { name: "status bar poller", params: ["s"] },
];

/** 用 dist 原样表达式求就绪判决；bare `__codexTrueReadyStatus` 需显式入参（形参会遮蔽 globalThis） */
function readinessAt(siteIdx, g, args) {
  const { expr } = TERNARIES[siteIdx];
  const params = SITE_VARS[siteIdx].params;
  const fn = new Function("globalThis", "__codexTrueReadyStatus", ...params, "return (" + expr + ");");
  return fn(g, g.__codexTrueReadyStatus, ...params.map((p) => args[p]));
}

/** /status：dist 原样就绪表达式 + dist 原样字段映射 */
function statusLeg(g) {
  const o = g.__codexBridgeState || {};
  const s = o.busy ? "running" : "idle";
  const r = readinessAt(0, g, { o, s });
  // 字段映射也取自 dist（证明 trueReady 真由该判决驱动，而非另算一份）
  const seg = SRC.slice(TERNARIES[0].at, TERNARIES[0].at + 900);
  assert.ok(/trueReady:!!__codexReady\.ready/.test(seg), "/status 的 trueReady 未由共享判决驱动");
  assert.ok(/status:__codexReady\.status/.test(seg), "/status 的 status 未由共享判决驱动");
  assert.ok(/notReadyReason:__codexReady\.reason/.test(seg), "/status 未透出 notReadyReason");
  return { trueReady: !!r.ready, status: r.status, notReadyReason: r.reason || null };
}

/** 正常 acquire：dist 原样就绪表达式 → 真实 control plane 判决 */
function admissionLeg(g, request) {
  const s = g.__codexBridgeState || {};
  const st = s.busy ? "running" : "idle";
  const readiness = readinessAt(1, g, { s, __codexAcquireStatus: st });
  return CONTROL.acquireDecision({
    bridge: s, readiness, recovery: g.__codexRecoveryState, request: request || { kind: "normal" },
  });
}

/** HTTP 预检：抽 dist 里真实的 __codexPreflight 箭头函数整体来跑 */
const PREFLIGHT_SRC = (function () {
  const key = "__preflight=()=>{";
  const at = SRC.indexOf(key);
  assert.ok(at >= 0, "找不到 __preflight");
  assert.strictEqual(SRC.indexOf(key, at + key.length), -1, "__preflight 不唯一");
  const brace = at + key.length - 1;
  let d = 0, i = brace;
  for (; i < SRC.length; i++) {
    if (SRC[i] === "{") d++;
    else if (SRC[i] === "}") { d--; if (d === 0) { i++; break; } }
  }
  return SRC.slice(at + key.indexOf("=") + 1, i); // 只取 ()=>{...}
})();
function preflightLeg(g) {
  const fn = new Function("globalThis", "__codexControl", "return (" + PREFLIGHT_SRC + ");")(g, CONTROL);
  return fn();
}

/** 状态栏 poller：dist 原样表达式（仅 1 个自由变量，且用 !(s.busy||s.postRunBusy)） */
function pollerLeg(g) {
  return readinessAt(3, g, { s: g.__codexBridgeState || {} });
}

const UNREADABLE = {
  guardModuleIdentityState: "MODULE_UNREADABLE",
  guardModuleIdentityError: "executionGuard:ENOENT: no such file or directory",
  guardModuleCombinedSha256: null, guardModules: {},
};

console.log("=== rc.7.14e guard 身份准入 fail-closed 测试 ===\n");

console.log("[A] 基线：身份 OK 时不得误杀");
t("A.1 身份 OK → 门禁 ready:true，/status trueReady:true", () => {
  const g = stage({});
  assert.strictEqual(g.__codexTrueReadyStatus(g.__codexBridgeState, "idle").ready, true);
  assert.strictEqual(statusLeg(g).trueReady, true);
});
t("A.2 身份 OK → 正常 acquire 放行（ok:true / 202）", () => {
  const d = admissionLeg(stage({}));
  assert.strictEqual(d.ok, true, "身份 OK 却被拒：" + JSON.stringify(d));
  assert.strictEqual(d.httpStatus, 202);
});

console.log("\n[B] P1 核心：身份不可读 → 门禁 ready:false 且准入被拒");
t("B.1 MODULE_UNREADABLE → 门禁 ready:false / status=identity-unreadable / reason 含模块错因", () => {
  const g = stage({ identity: UNREADABLE });
  const r = g.__codexTrueReadyStatus(g.__codexBridgeState, "idle");
  assert.strictEqual(r.ready, false, "身份不可读却 ready:true —— 正是 P1 缺陷");
  assert.strictEqual(r.status, "identity-unreadable", "status=" + r.status);
  assert.ok(/MODULE_UNREADABLE/.test(r.reason), "reason 未含状态：" + r.reason);
  assert.ok(/executionGuard/.test(r.reason), "reason 未含模块身份错因：" + r.reason);
});
t("B.2 /status 必须报 trueReady:false（R1 可表示的坏状态现在不可表示）", () => {
  const st = statusLeg(stage({ identity: UNREADABLE }));
  assert.strictEqual(st.trueReady, false,
    "仍可表示 {trueReady:true, guardModuleIdentityState:MODULE_UNREADABLE}");
  assert.strictEqual(st.status, "identity-unreadable");
  assert.ok(st.notReadyReason, "缺 notReadyReason");
});
t("B.3 正常 acquire 必须拒（ok:false / kind=not-ready / 423）", () => {
  const d = admissionLeg(stage({ identity: UNREADABLE }));
  assert.strictEqual(d.ok, false, "身份不可读却放行 acquire：" + JSON.stringify(d));
  assert.strictEqual(d.kind, "not-ready", "kind=" + d.kind);
  assert.strictEqual(d.httpStatus, 423, "httpStatus=" + d.httpStatus);
  assert.ok(/identity/.test(String(d.reason)), "拒绝原因未提身份：" + d.reason);
});
t("B.4 HTTP 预检（dist 原样 __codexPreflight）独立求值也必须拒", () => {
  const g = stage({ identity: UNREADABLE });
  const pre = preflightLeg(g);
  assert.strictEqual(pre.ok, false, "预检放行了身份坏的请求：" + JSON.stringify(pre));
  assert.strictEqual(pre.kind, "not-ready");
  assert.strictEqual(pre.httpStatus, 423);
  // 与 acquire 判决一致 ⇒ 同一条策略路径，而非两套各判一次
  assert.deepStrictEqual(pre, admissionLeg(g), "预检与 acquire 判决不一致 → 存在并行策略路径");
});
t("B.4b 状态栏 poller（第 4 个消费点，形态最不一样）同样拒", () => {
  const r = pollerLeg(stage({ identity: UNREADABLE }));
  assert.strictEqual(r.ready, false, "poller 消费点漏改 → 状态栏会显示可用");
  assert.strictEqual(r.status, "identity-unreadable");
});
t("B.4c 四个消费点在身份坏时判决一致（逐点用 dist 原样字节求值）", () => {
  const g = stage({ identity: UNREADABLE });
  const args = [
    { o: g.__codexBridgeState, s: "idle" },
    { s: g.__codexBridgeState, __codexAcquireStatus: "idle" },
    { s: g.__codexBridgeState, __base: "idle" },
    { s: g.__codexBridgeState },
  ];
  for (let k = 0; k < 4; k++) {
    const r = readinessAt(k, g, args[k]);
    assert.strictEqual(r.ready, false, SITE_VARS[k].name + " 放行了身份坏状态（半修）");
    assert.strictEqual(r.status, "identity-unreadable", SITE_VARS[k].name + " status=" + r.status);
  }
});
t("B.5 UNKNOWN 与任意非 OK 状态一律拒（不是只认 MODULE_UNREADABLE 字面量）", () => {
  for (const st of ["UNKNOWN", "IDENTITY_UNREADABLE", "TAMPERED", "", "whatever"]) {
    const g = stage({ identity: { guardModuleIdentityState: st, guardModuleIdentityError: "x" } });
    assert.strictEqual(g.__codexTrueReadyStatus(g.__codexBridgeState, "idle").ready, false,
      "状态 " + JSON.stringify(st) + " 被放行");
    assert.strictEqual(admissionLeg(g).ok, false, "状态 " + JSON.stringify(st) + " 的 acquire 被放行");
  }
});

console.log("\n[C] 助手缺席 / 抛错也必须 fail closed");
t("C.1 身份助手整体缺席（补丁在场）→ 门禁拒 + acquire 拒", () => {
  const g = stage({ identity: "absent" });
  const r = g.__codexTrueReadyStatus(g.__codexBridgeState, "idle");
  assert.strictEqual(r.ready, false, "身份助手缺席却放行");
  assert.ok(/helper is missing/.test(r.reason), "reason=" + r.reason);
  assert.strictEqual(admissionLeg(g).httpStatus, 423);
});
t("C.2 身份助手抛错 → 门禁拒（不得把异常当通过）", () => {
  const g = stage({ identityThrows: "boom-from-identity" });
  const r = g.__codexTrueReadyStatus(g.__codexBridgeState, "idle");
  assert.strictEqual(r.ready, false);
  assert.ok(/threw/.test(r.reason) && /boom-from-identity/.test(r.reason), "reason=" + r.reason);
  assert.strictEqual(admissionLeg(g).ok, false);
});
t("C.3 共享门禁本身缺席（补丁在场）→ 回退按同一策略拒", () => {
  // 这是 R1 遗留的另一个洞：4 个消费点的内联回退原本无条件 ready:!busy&&!postRunBusy
  const g = stage({ gate: "absent", identity: UNREADABLE });
  assert.strictEqual(g.__codexTrueReadyStatus, undefined, "门禁本应缺席");
  const st = statusLeg(g);
  assert.strictEqual(st.trueReady, false, "门禁缺席时回退仍放行");
  assert.strictEqual(admissionLeg(g).ok, false, "门禁缺席时 acquire 仍放行");
});
t("C.4 门禁缺席 + 身份 OK（补丁在场）→ 仍判完整性故障（门禁不该消失）", () => {
  const g = stage({ gate: "absent" });
  const r = g.__codexReadinessFallback(g.__codexBridgeState, "idle");
  assert.strictEqual(r.ready, false, "补丁在场却没有门禁，应判完整性故障");
  assert.ok(/readiness gate is missing/.test(r.reason), "reason=" + r.reason);
});
t("C.5 未打补丁的 bundle（无导出、无助手）→ 保留旧语义，不得凭空判死", () => {
  const g = stage({ gate: "absent", identity: "absent", exportsPresent: false });
  const r = g.__codexReadinessFallback({ busy: false, postRunBusy: false }, "idle");
  assert.strictEqual(r.ready, true, "未打补丁的 bundle 被误判死（会砸掉安装前窗口）");
  const busy = g.__codexReadinessFallback({ busy: true, postRunBusy: false }, "running");
  assert.strictEqual(busy.ready, false, "旧语义 busy 判定丢失");
});

console.log("\n[D] 恢复通道必须保留（要求 4）");
t("D.1 身份坏 + recovery required + 合法 token → 仍放行 recovery-smoke", () => {
  const gate = CONTROL.ensureRecoveryState({ required: true, token: "TK", generation: 7, reason: "smoke required" });
  const g = stage({ identity: UNREADABLE, recovery: gate });
  const d = admissionLeg(g, { kind: "recovery-smoke", recoveryToken: gate.token, recoveryGeneration: gate.generation });
  assert.strictEqual(d.ok, true, "身份坏时恢复通道被堵死 → 隔离 profile 无法修：" + JSON.stringify(d));
  assert.strictEqual(d.kind, "recovery-smoke");
});
t("D.2 身份坏 + recovery required + 无 token 的普通请求 → 仍拒", () => {
  const gate = CONTROL.ensureRecoveryState({ required: true, token: "TK", generation: 7, reason: "smoke required" });
  const g = stage({ identity: UNREADABLE, recovery: gate });
  assert.strictEqual(admissionLeg(g, { kind: "normal" }).ok, false);
});
t("D.3 POST /force-reset 不经就绪门禁（结构断言：直接调 __codexForceReset）", () => {
  const at = SRC.indexOf("__req.url===\"/force-reset\"");
  assert.ok(at > 0, "找不到 /force-reset 路由");
  const seg = SRC.slice(at, at + 260);
  assert.ok(/globalThis\.__codexForceReset/.test(seg), "force-reset 未直调 __codexForceReset");
  assert.ok(!/acquireDecision|__codexTrueReadyStatus/.test(seg),
    "force-reset 竟经过就绪门禁 → 身份坏会把恢复堵死：" + seg.slice(0, 120));
});
t("D.4 GET /status 无条件 200（身份坏时仍可观测）", () => {
  const at = SRC.indexOf("__req.url===\"/status\"");
  assert.ok(at > 0, "找不到 /status 路由");
  const seg = SRC.slice(at, at + 160);
  assert.ok(/__send\(__res,200,__current\(\)\)/.test(seg), "status 非无条件 200：" + seg.slice(0, 120));
});

console.log("\n[E] 结构契约：单点策略、四处回退、不破坏既有次序");
t("E.1 身份裁决只有一份实现（策略不得复制成并行路径）", () => {
  assert.strictEqual(SRC.split("globalThis.__codexGuardIdentityVerdict=function").length - 1, 1);
  assert.strictEqual(SRC.split("globalThis.__codexReadinessFallback=function").length - 1, 1);
});
t("E.2 四个消费点全部改走共享回退（3/4 会造出更坏的半修状态）", () => {
  assert.strictEqual(SRC.split("globalThis.__codexReadinessFallback(").length - 1, 4,
    "回退改写数不是 4");
  assert.strictEqual(SRC.split("guard module identity fails closed in the single readiness gate").length - 1, 1,
    "门禁早退不是恰好一处");
});
t("E.3 门禁内次序：recovery / continuity 早退仍在身份之前", () => {
  const g = GATE.text;
  const iRec = g.indexOf("recovery-required");
  const iCont = g.indexOf("continuity-lost");
  const iId = g.indexOf("identity-unreadable");
  const iGraph = g.indexOf("graph readiness is ");
  assert.ok(iRec > 0 && iCont > 0 && iId > 0 && iGraph > 0, "锚点缺失");
  assert.ok(iRec < iId, "recovery 早退被排到身份之后");
  assert.ok(iCont < iId, "continuity 早退被排到身份之后");
  assert.ok(iId < iGraph, "身份未置于 graph readiness 之前");
});
t("E.4 recovery-required 优先于身份暴露给运维（可操作状态先行）", () => {
  const gate = CONTROL.ensureRecoveryState({ required: true, token: "TK", generation: 1, reason: "smoke required" });
  const g = stage({ identity: UNREADABLE, controlPlane: CONTROL, recovery: gate });
  const r = g.__codexTrueReadyStatus(g.__codexBridgeState, "idle");
  assert.strictEqual(r.status, "recovery-required", "status=" + r.status + "（应先报可操作的 recovery）");
  assert.strictEqual(r.ready, false);
});
t("E.5 busy / postRunBusy 仍最先短路（身份检查不得抢占）", () => {
  const g = stage({ identity: UNREADABLE, bridge: { busy: true, postRunBusy: false } });
  assert.strictEqual(g.__codexTrueReadyStatus(g.__codexBridgeState, "running").status, "running");
  const g2 = stage({ identity: UNREADABLE, bridge: { busy: false, postRunBusy: true, lastPostRunBusyReason: "x" } });
  assert.strictEqual(g2.__codexTrueReadyStatus(g2.__codexBridgeState, "idle").status, "draining");
});

console.log("\n[F] 判别力：这套测试必须能否决 R1 的旧形态");
t("F.1 把身份早退从门禁里删掉（复现 R1）→ B.1/B.3 必须翻转为失败", () => {
  // 逆变换：删除 rc.7.14e 早退块，重建 R1 的门禁，证明本套断言真的在起作用
  const marker = "/* codex patch rc.7.14e: guard module identity fails closed in the single readiness gate */";
  const end = GATE.text.indexOf(marker);
  assert.ok(end > 0, "找不到 rc.7.14e 标记");
  const start = GATE.text.indexOf("try{var __idfn=globalThis.__codexGuardIdentityVerdict;");
  assert.ok(start > 0 && start < end, "找不到早退块起点");
  const old = GATE.text.slice(0, start) + GATE.text.slice(end + marker.length);
  const g = stage({ identity: UNREADABLE });
  const oldGate = new Function("globalThis", old + "; return __codexTrueReadyStatus;")(g);
  const r = oldGate(g.__codexBridgeState, "idle");
  assert.strictEqual(r.ready, true, "R1 旧门禁本应放行（否则本测试无判别力）");
  const d = CONTROL.acquireDecision({
    bridge: g.__codexBridgeState, readiness: r, recovery: null, request: { kind: "normal" },
  });
  assert.strictEqual(d.ok, true, "R1 旧形态本应放行 acquire —— 这正是 P1");
});
t("F.2 R1 的坏状态在旧形态下确实可表示（trueReady:true + MODULE_UNREADABLE）", () => {
  const g = stage({ identity: UNREADABLE });
  const marker = "/* codex patch rc.7.14e: guard module identity fails closed in the single readiness gate */";
  const end = GATE.text.indexOf(marker);
  const start = GATE.text.indexOf("try{var __idfn=globalThis.__codexGuardIdentityVerdict;");
  const old = GATE.text.slice(0, start) + GATE.text.slice(end + marker.length);
  g.__codexTrueReadyStatus = new Function("globalThis", old + "; return __codexTrueReadyStatus;")(g);
  const st = statusLeg(g);
  const idField = g.__codexGuardModuleIdentityStatus();
  assert.strictEqual(st.trueReady, true);
  assert.strictEqual(idField.guardModuleIdentityState, "MODULE_UNREADABLE");
  // 现形态下同一组合不可表示
  const fixed = statusLeg(stage({ identity: UNREADABLE }));
  assert.strictEqual(fixed.trueReady, false);
});

console.log("\n[G] 模块摘要契约未回归");
t("G.1 combined = sha256(executionGuard=<sha>\\npreRunStageGuard=<sha>) 仍成立", () => {
  const e = crypto.createHash("sha256").update(fs.readFileSync(path.join(REPO, "scripts/execution_guard.js"))).digest("hex");
  const p = crypto.createHash("sha256").update(fs.readFileSync(path.join(REPO, "scripts/prerun_stage_guard.js"))).digest("hex");
  const want = crypto.createHash("sha256")
    .update(Buffer.from("executionGuard=" + e + "\npreRunStageGuard=" + p, "utf8")).digest("hex");
  const COMPUTE = cutFunction("globalThis.__codexComputeGuardModuleIdentity=function()");
  const g = { __codexExecGuardPath: path.join(REPO, "scripts/execution_guard.js"),
              __codexPreRunGuardPath: path.join(REPO, "scripts/prerun_stage_guard.js") };
  new Function("globalThis", "require", COMPUTE.text + ";")(g, require);
  const I = g.__codexComputeGuardModuleIdentity();
  assert.strictEqual(I.guardModuleIdentityState, "OK");
  assert.strictEqual(I.guardModuleCombinedSha256, want);
});

console.log("\n" + "=".repeat(60));
console.log("  PASS=" + pass + "  FAIL=" + fails.length);
if (fails.length) { fails.forEach((f) => console.log("   - " + f)); process.exit(1); }
console.log("  GUARD_IDENTITY_ADMISSION_TESTS  " + pass + "/" + pass + " passed");
console.log("  RC714E_FAIL_CLOSED_OK");
