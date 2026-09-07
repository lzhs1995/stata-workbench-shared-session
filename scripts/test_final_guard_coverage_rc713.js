"use strict";
/**
 * test_final_guard_coverage_rc713.js —— 对**将要打包的那份 dist** 收口
 *
 * 定位：前面几个门禁验的是「模块逻辑对不对」「重放能不能复现」，本门禁只问一件事——
 * 真正要装到用户 profile 里的这份 dist/extension.js，是不是 15/15 全守卫、0 裸调用、
 * 每处 policy 与声明表逐条一致、身份槽位已 finalize。
 *
 * 为什么单列一个文件：R1-128 的本质是「某个 await zg.runSelection 不返回就永久卡桥」。
 * 少守一处就等于 bug 仍然活着，而这类漏接线在功能测试里**看不出来**（正常路径全过），
 * 只能靠静态覆盖率门禁在打包前拦住。
 *
 * ⚠️ 覆盖率 ≠ 运行时有效。本门禁只证明「守卫接上了」，不证明「超时真会触发」；
 * 后者要靠 Phase 2 的故障注入（人为让某处 promise 永不 resolve）来验。
 */
const assert = require("node:assert");
const fs = require("node:fs");
const path = require("node:path");
const crypto = require("node:crypto");
const AST = require("./ast_reachability_gate.js");
const G = require("./guard_wiring_rc713.js");
const FIN = require("./finalize_bundle_identity.js");

const DIST = path.join(__dirname, "..", "dist", "extension.js");

let pass = 0; const fails = [];
function t(name, fn) {
  try { fn(); pass++; console.log("  PASS " + name); }
  catch (e) { fails.push(name + " — " + ((e && e.message) || e));
              console.log("  FAIL " + name + "  — " + ((e && e.message) || e)); }
}

(function main() {
  console.log("=== rc.7.13 最终 dist 守卫覆盖率门禁 ===\n");
  assert.ok(fs.existsSync(DIST), "dist/extension.js 不存在：" + DIST);
  const src = fs.readFileSync(DIST, "utf8");
  const sha = crypto.createHash("sha256").update(Buffer.from(src, "utf8")).digest("hex");
  const ast = AST.analyze(src);
  const sites = ast.callsites.slice().sort((a, b) => a.start - b.start);
  console.log("  dist sha256 :", sha.slice(0, 16), " bytes:", Buffer.byteLength(src, "utf8"));
  console.log("  fingerprint :", FIN.fingerprintOf(src).slice(0, 16), "\n");

  console.log("[A] 调用点普查");
  t("A.1 zg.runSelection 调用点共 17 个（AST 与字符串计数一致）", () => {
    assert.strictEqual(sites.length, 17, "AST 调用点数不是 17：" + sites.length);
    assert.strictEqual(G.countOccurrences(src, G.CALL_HEAD), 17,
      "字符串计数不是 17：" + G.countOccurrences(src, G.CALL_HEAD));
  });
  t("A.2 退役（不可达）点恰为 [8,12]，且**保持裸态**（注 guard 即假接线）", () => {
    const deadOrds = sites.map((s, i) => (s.reachable ? null : i + 1)).filter((x) => x !== null);
    assert.deepStrictEqual(deadOrds, [8, 12], "退役序号不是 [8,12]：" + deadOrds);
    sites.filter((s) => !s.reachable).forEach((s, i) => {
      assert.strictEqual(s.guarded, false, "退役点 #" + deadOrds[i] + " 竟被注了 guard = 假接线");
    });
  });
  t("A.3 可达点 15 个，其中已守卫 15、裸调用 0", () => {
    const live = sites.filter((s) => s.reachable);
    assert.strictEqual(live.length, 15, "可达点不是 15：" + live.length);
    const naked = live.map((s, i) => (s.guarded ? null : i + 1)).filter((x) => x !== null);
    assert.strictEqual(naked.length, 0, "仍有裸活跃调用（R1-128 仍活着）序号：" + naked);
    assert.strictEqual(live.filter((s) => s.guarded).length, 15, "已守卫数不是 15");
  });
  t("A.4 transport guardKind 分布 = {guardWrap:12, guardStage:2, guardProgress:1}", () => {
    const k = {};
    sites.filter((s) => s.guarded).forEach((s) => { k[s.guardKind] = (k[s.guardKind] || 0) + 1; });
    assert.deepStrictEqual(k, { guardWrap: 12, guardStage: 2, guardProgress: 1 }, "分布不符：" + JSON.stringify(k));
  });
  console.log("\n[B] 逐条 policy 与声明表一致（15/15，不是「总数对得上」）");
  t("B.1 15 条锚点在最终 dist 中仍各唯一", () => {
    const rows = G.assertAnchorUniqueness(src, "final-dist");
    assert.strictEqual(rows.length, 15, "校验条数不是 15");
  });
  t("B.2 apply() 对最终 dist 判定为「已接线且逐字节相符」（12 wrap + 3 core 全验过）", () => {
    const { text, report } = G.apply(src);
    assert.strictEqual(report.alreadyWired, true, "最终 dist 竟未被识别为已接线");
    assert.strictEqual(report.wrapped.length, 0, "最终 dist 还需新接线 " + report.wrapped.length + " 处");
    assert.strictEqual(report.verifiedWrapped.length, 12, "verifiedWrapped 不是 12");
    assert.strictEqual(report.verifiedCore.length, 3, "verifiedCore 不是 3");
    assert.strictEqual(text, src, "对最终 dist 跑 apply 竟改了字节（不幂等，打包会漂移）");
  });
  t("B.3 逐条核对 15 处：wrap 看内联 policy/超时，core 看 guard 阶段名（两种机制分开验）", () => {
    const STAGE_BY_POLICY = { "ABSOLUTE-60s": "snapshot", "ABSOLUTE-120s": "enrich" };
    let wrapChecked = 0; let coreChecked = 0;
    for (const e of G.POLICY_TABLE) {
      const anchor = e.finalAnchor && src.includes(e.finalAnchor) ? e.finalAnchor : e.anchor;
      const at = src.indexOf(anchor);
      assert.ok(at >= 0, "#" + e.ord + " (" + e.id + ") 锚点在 dist 中缺失");
      if (e.mode === "wrap") {
        // wrap：policy 表达式与 timeoutMs 由本次接线内联生成，就在锚点之后
        const region = src.substr(at + anchor.length, 500);
        assert.ok(region.includes(G.POLICY_EXPR[e.policy]),
          "#" + e.ord + " (" + e.id + ") 未见声明的 policy 表达式 " + G.POLICY_EXPR[e.policy]);
        const to = G.TIMEOUT_MS[e.policy];
        if (to) assert.ok(region.includes("timeoutMs:" + to), "#" + e.ord + " 未见 timeoutMs:" + to);
        wrapChecked++;
      } else {
        // core：超时来自 prerun_stage_guard 的阶段常量，锚点前后应见对应 guard 调用
        const stage = STAGE_BY_POLICY[e.policy];
        if (stage) {
          const before = src.substr(Math.max(0, at - 400), 400 + anchor.length);
          assert.ok(before.includes('guardStage("' + stage + '"'),
            "#" + e.ord + " (" + e.id + ") 附近未见 guardStage(\"" + stage + "\")");
        } else {
          assert.ok(anchor.includes(e.guardKind + "("),
            "#" + e.ord + " (" + e.id + ") 锚点未内嵌 " + e.guardKind + "(");
        }
        coreChecked++;
      }
    }
    assert.strictEqual(wrapChecked, 12, "wrap 只核到 " + wrapChecked + " 条");
    assert.strictEqual(coreChecked, 3, "core 只核到 " + coreChecked + " 条");
  });
  t("B.3a 原子 pre-run 有四个阶段 guard，但只有两个 snapshot guard 含 transport dispatch", () => {
    assert.strictEqual((src.match(/guardStage\(\"snapshot\"/g) || []).length, 2);
    assert.strictEqual((src.match(/guardStage\(\"enrich\"/g) || []).length, 2);
    assert.strictEqual((src.match(/StopCheckpointRef\.beginAtomic\(/g) || []).length, 2);
    assert.strictEqual((src.match(/StopCheckpointRef\.completeAtomic\(/g) || []).length, 2);
  });
  t("B.3b core 站点的超时常量与声明表一致（snapshot=60s / enrich=120s，单一事实源）", () => {
    const PG = require("./prerun_stage_guard.js");
    assert.strictEqual(PG.SNAPSHOT_TIMEOUT_MS, G.TIMEOUT_MS["ABSOLUTE-60s"],
      "snapshot 超时 " + PG.SNAPSHOT_TIMEOUT_MS + " ≠ 声明 " + G.TIMEOUT_MS["ABSOLUTE-60s"]);
    assert.strictEqual(PG.ENRICH_TIMEOUT_MS, G.TIMEOUT_MS["ABSOLUTE-120s"],
      "enrich 超时 " + PG.ENRICH_TIMEOUT_MS + " ≠ 声明 " + G.TIMEOUT_MS["ABSOLUTE-120s"]);
  });
  t("B.4 SHORT_INTERNAL(30s) 在 dist 中只出现 4 次 —— 没被误套到别处", () => {
    const n = G.countOccurrences(src, "timeoutMs:30000");
    assert.strictEqual(n, 4, "timeoutMs:30000 出现 " + n + " 次（应为 4：仅内部探测点）");
  });

  console.log("\n[C] 身份槽位与打包可信度");
  t("C.1 身份槽位唯一、已 finalize、且值等于重算的归一化指纹", () => {
    const v = FIN.verify(src);
    assert.strictEqual(v.unfinalized, false, "槽位仍是全 0（忘了跑 finalize_bundle_identity.js）");
    assert.strictEqual(v.ok, true, "槽位值 " + String(v.recorded).slice(0, 16) +
      " ≠ 重算 " + String(v.expected).slice(0, 16) + "（dist 在 finalize 后又被改过）");
  });
  t("C.2 dist 语法可解析（acorn 已成功走完全文，A 段即证）", () => {
    assert.ok(sites.length > 0 && ast.deadRanges.length >= 1, "AST 结果异常");
  });
  t("C.3 wrapper 与接线标记各就位（marker 存在、wrapper hook 唯一）", () => {
    assert.ok(src.includes(G.MARKER), "接线标记缺失：" + G.MARKER);
    assert.strictEqual(G.countOccurrences(src, G.WRAPPER_HOOK), 1,
      "wrapper hook 不唯一：" + G.countOccurrences(src, G.WRAPPER_HOOK));
    assert.strictEqual(G.countOccurrences(src, G.WRAP_HEAD + "("), 0, "出现 " + G.WRAP_HEAD + "( 双括号畸形");
  });

  console.log("\n" + "=".repeat(58));
  console.log("  PASS=" + pass + "  FAIL=" + fails.length);
  if (fails.length) { fails.forEach((f) => console.log("   - " + f)); process.exit(1); }
  console.log("  FINAL_GUARD_COVERAGE_15_OF_15_OK");
  console.log("  注意：静态覆盖 ≠ 运行时生效；超时真触发须由 Phase 2 故障注入证明。");
})();
