"use strict";
/**
 * gen_callsite_manifest_v4.js —— 从指定 bundle 现算调用点台账（**派生报告，非接线输入**）
 *
 * rc.7.13 的定位变化（重要）：
 *   以前接线脚本要**读**这份 manifest 拿 policy（还带静默回落），于是一份可能过期的
 *   生成物成了接线的事实依据。现在权威源是 scripts/guard_wiring_rc713.js 里的声明式
 *   策略表；本脚本降级为**只读派生报告 + 一致性校验**：
 *     · policy 一律从权威表推导，本文件不再自带第二份 POLICY_BY_N；
 *     · 生成后立刻拿权威表校验（总数 / 退役集 / 逐点 policy / 锚点唯一性），
 *       任何不一致直接非零退出，不写出「看起来合理」的台账。
 *   任何人都不应再把它当接线输入；charOffset 只是本次快照的观测值。
 *
 * 用法：
 *   node scripts/gen_callsite_manifest_v4.js --out <out.json> [--in <bundle.js>]
 *   node scripts/gen_callsite_manifest_v4.js --check [--in <bundle.js>]   # 只校验不写盘
 *   node scripts/gen_callsite_manifest_v4.js <out.json>                   # 兼容旧位置参数
 */
const fs = require("fs");
const path = require("path");
const crypto = require("crypto");
const AST = require("./ast_reachability_gate.js"); // C5.2：权威判据是真 AST
const guardWiring = require("./guard_wiring_rc713.js"); // 权威 policy 表来源

const DEFAULT_BUNDLE = path.join(__dirname, "..", "dist", "extension.js");

/** 从权威表推导 ordinal → policy（退役点由 RETIRED_ORDINALS 决定） */
function policyByOrdinal() {
  const map = {};
  for (const ord of guardWiring.RETIRED_ORDINALS) map[ord] = "RETIRED_UNREACHABLE";
  for (const e of guardWiring.POLICY_TABLE) map[e.ord] = e.policy;
  return map;
}

/** 取一段唯一 anchor：以调用点为中心向前扩展，直到在全文唯一 */
function uniqueAnchor(src, pos, minLen, maxLen) {
  const lo = minLen || 48;
  const hi = maxLen || 260;
  for (let len = lo; len <= hi; len += 12) {
    const start = Math.max(0, pos - len);
    const cand = src.slice(start, pos + "zg.runSelection".length);
    const first = src.indexOf(cand);
    if (first < 0) continue;
    if (src.indexOf(cand, first + cand.length) < 0) {
      return { anchorPrefix: cand, anchorLen: cand.length, resolvedCharPos: pos, unique: true };
    }
  }
  return { anchorPrefix: null, anchorLen: 0, resolvedCharPos: pos, unique: false };
}

/**
 * 校验 AST 死分支区间：每个区间必须是有序、有限的整数偏移。
 * 失败即抛（fail-closed）—— 宁可不出台账，也不出「五个 {}」这种看着像证据的空壳。
 * P1-2：原实现映射 r.bodyStart/r.bodyEnd（analyze() 压根不返回这两个名），
 * 于是 deadBranchRanges 恒为 5 个空对象，是「无效证据」而非「小瑕疵」。
 * @param {Array<{start:number,end:number,testStart:number}>} ranges
 * @param {number} srcLen bundle 长度（区间不得越界）
 * @returns {Array<{start:number,end:number,testStart:number}>} 归一化后的纯数字区间
 */
function normalizeDeadRanges(ranges, srcLen) {
  if (!Array.isArray(ranges)) {
    throw new Error("DEAD_RANGES_INVALID: analyze().deadRanges 不是数组");
  }
  const isIdx = (v) => Number.isInteger(v) && Number.isFinite(v) && v >= 0;
  return ranges.map((r, i) => {
    const at = `deadRanges[${i}]`;
    if (!r || typeof r !== "object") {
      throw new Error(`DEAD_RANGES_INVALID: ${at} 不是对象`);
    }
    const { start, end, testStart } = r;
    for (const [name, v] of [["start", start], ["end", end], ["testStart", testStart]]) {
      if (!isIdx(v)) {
        throw new Error(
          `DEAD_RANGES_INVALID: ${at}.${name} 必须是有限非负整数，实得 ${JSON.stringify(v)}`
        );
      }
    }
    if (!(start < end)) {
      throw new Error(`DEAD_RANGES_INVALID: ${at} 区间无序：start=${start} 不小于 end=${end}`);
    }
    if (end > srcLen) {
      throw new Error(`DEAD_RANGES_INVALID: ${at}.end=${end} 越过 bundle 末尾 ${srcLen}`);
    }
    if (!(testStart <= start)) {
      throw new Error(
        `DEAD_RANGES_INVALID: ${at}.testStart=${testStart} 应位于 consequent 之前（start=${start}）`
      );
    }
    return { start, end, testStart };
  });
}

/**
 * 从给定 bundle 文本现算 manifest（纯函数：不读盘、不写盘、不退出进程）
 * @param {string} src bundle 全文
 * @param {string} bundleRelPath 记进 manifest 的相对路径（仅作标注）
 */
function buildManifest(src, bundleRelPath) {
  const bundleSha = crypto.createHash("sha256").update(src).digest("hex");
  const astResult = AST.analyze(src);
  const DEAD = normalizeDeadRanges(astResult.deadRanges, src.length);
  const POLICY_BY_ORD = policyByOrdinal();

  // 找出全部 zg.runSelection 调用点（出现顺序即 ordinal）
  const positions = [];
  {
    const re = /zg\.runSelection/g;
    let m;
    while ((m = re.exec(src)) !== null) positions.push(m.index);
  }

  // guarded 由 AST 祖先链判定（本节点须落在 guard 调用的 arguments 子树内），
  // 不用「向前 900 字节」窗口 —— 窗口会把邻近但无关的 guard 误算进来。
  const AST_BY_START = new Map(astResult.callsites.map((c) => [c.start, c]));
  const guardedNow = (pos) => {
    const c = AST_BY_START.get(pos);
    return c ? !!c.guarded : false;
  };

  const callsites = positions.map((pos, idx) => {
    const n = idx + 1;
    const dead = astResult.inDead(pos);
    const a = uniqueAnchor(src, pos);
    return {
      n,
      charOffset: pos,
      reachable: !dead,
      guardedNow: guardedNow(pos),
      // 不可达 ⇒ 一律 RETIRED_UNREACHABLE（此前 #9 虽记 reachable:false
      // 却仍被算进 active SHORT_INTERNAL —— 退役曾是硬编码名单而非按可达性推导）
      policy: dead ? "RETIRED_UNREACHABLE" : POLICY_BY_ORD[n] || "UNASSIGNED",
      declaredPolicy: POLICY_BY_ORD[n] || "UNASSIGNED",
      context: src.slice(Math.max(0, pos - 70), pos + 90).replace(/\s+/g, " "),
      anchor: a,
    };
  });

  const active = callsites.filter((c) => c.policy !== "RETIRED_UNREACHABLE");
  const retired = callsites.filter((c) => c.policy === "RETIRED_UNREACHABLE");
  const byPolicy = {};
  active.forEach((c) => {
    (byPolicy[c.policy] = byPolicy[c.policy] || []).push(c.n);
  });

  return {
    schemaVersion: 4,
    generatedAt: new Date().toISOString(),
    purpose: "R1-128/R1-118 guard 接线的调用点派生台账（从指定 bundle 现算，含可达性）",
    role: "DERIVED_REPORT_ONLY",
    policySourceOfTruth: "scripts/guard_wiring_rc713.js (POLICY_TABLE)",
    bundleSha256: bundleSha,
    bundlePath: bundleRelPath,
    totalCallsites: callsites.length,
    activeCallsites: active.length,
    retiredCallsites: retired.map((c) => ({
      n: c.n,
      policy: "RETIRED_UNREACHABLE",
      reachable: c.reachable,
      reason: "位于 dist 常量假分支 if(false&&__codexPreparedHumanFileRun&&(…)) 内，运行时不可达",
      decidedAt: "2026-08-08",
      decidedBy: "codex review (C5-1)",
      excludedFromActiveDenominator: true,
      note: "此前对它注 guard 属假接线，并致误报 ABSOLUTE 5/5。若将来启用须重新设计+生产测试，并先移出 retired 名单。",
      gate: "scripts/test_callsite_reachability_gate.js + scripts/ast_reachability_gate.js",
      charOffset: c.charOffset,
    })),
    guardedNow: active.filter((c) => c.guardedNow).length,
    byPolicy: byPolicy,
    coverage: {
      denominator: active.length,
      guarded: active.filter((c) => c.guardedNow).length,
      unguarded: active.filter((c) => !c.guardedNow).map((c) => c.n),
      note: "分母仅含可达活跃点。静态「裸调用归零」不等于运行时覆盖；可达性由 acorn AST 判定。",
    },
    reachability: {
      method: "acorn AST (scripts/ast_reachability_gate.js)",
      replaces: "自制词法扫描器 js_scope_scan.js —— 被 return /}/ 与 typeof /}/ 实证击穿（假可达）",
      deadBranchCount: DEAD.length,
      // P1-2：写出真实数字偏移（start/end/testStart）。此前映射不存在的
      // bodyStart/bodyEnd → 恒 undefined → JSON 里变成 5 个 {}，等于没有证据。
      deadBranchRanges: DEAD.map((r) => ({ start: r.start, end: r.end, testStart: r.testStart })),
      deadBranchRangesValidated: "normalizeDeadRanges(): 有限非负整数 + start<end + end<=len + testStart<=start，违反即抛 DEAD_RANGES_INVALID",
      adversarialTests: "scripts/js_scope_scan.test.js（超长死分支/嵌套 try-catch/紧邻活跃调用/字符串模板注释正则）",
    },
    anchorIntegrity: {
      allUnique: callsites.every((c) => c.anchor.unique),
      nonUnique: callsites.filter((c) => !c.anchor.unique).map((c) => c.n),
      wiringMustAssert: "接线每处前 assert dist.indexOf(anchorPrefix) 唯一；anchor 以 zg.runSelection 结尾",
      warning: "本文件的 charOffset/anchor 只对 bundleSha256 所指那份 bundle 有效，换 bundle 必须重生成",
      authoritativeAnchors: "scripts/guard_wiring_rc713.js POLICY_TABLE（接线只用那里的 anchor，不读本文件）",
    },
    supersedeEvidence: {
      failClosed: true,
      rejectReasons: ["NO_LOOKUP", "LOOKUP_THREW", "NO_RECORD", "RUNID_MISMATCH",
        "TOKEN_MISSING", "TOKEN_ALREADY_CONSUMED", "TOKEN_CONSUME_FAILED",
        "FROM_GENERATION_MISMATCH", "TO_GENERATION_MISSING", "TO_GENERATION_MISMATCH",
        "KIND_NOT_ALLOWED", "TIMESTAMP_MISSING", "EVIDENCE_EXPIRED"],
      registrarRejectsMissingFromGeneration: true,
      maxAgeMs: 300000,
    },
    rollbackBasis: {
      baselineSha256_16: "95aa8079aa18dcab",
      baselinePath: "~/.stata-workbench-rc70-profile/extensions/lzhs1995.stata-workbench-shared-session-0.1.3-rc.7.0/dist/extension.js",
      vsix: "stata-workbench-shared-session-0.1.3-rc.7.0.vsix",
      vsixSha256_16: "b1c1dd2f0da3dc3e",
      note: "不以 /tmp 副本作回滚依据",
    },
    callsites: callsites,
  };
}

/**
 * 拿权威表校验派生台账；返回问题清单（空数组=一致）。
 * 这是本次重写的核心：manifest 不再是「可能过期的事实来源」，而是必须与
 * guard_wiring_rc713.js 对齐的派生产物；不一致就非零退出，别写出去骗下游。
 */
function validateAgainstAuthority(manifest, src) {
  const problems = [];
  const table = guardWiring.POLICY_TABLE;
  const retiredSet = new Set(guardWiring.RETIRED_ORDINALS);

  if (manifest.totalCallsites !== guardWiring.TOTAL_CALLSITES) {
    problems.push("总调用点数 " + manifest.totalCallsites + " ≠ 权威 " + guardWiring.TOTAL_CALLSITES);
  }
  const retiredFound = manifest.retiredCallsites.map((c) => c.n).sort((a, b) => a - b);
  const retiredWant = guardWiring.RETIRED_ORDINALS.slice().sort((a, b) => a - b);
  if (retiredFound.join(",") !== retiredWant.join(",")) {
    problems.push("退役序号 [" + retiredFound + "] ≠ 权威 [" + retiredWant + "]");
  }
  const byOrd = new Map(manifest.callsites.map((c) => [c.n, c]));
  let anchorsOk = 0;
  let baselineAnchorsUsed = 0;
  for (const entry of table) {
    const site = byOrd.get(entry.ord);
    if (!site) {
      problems.push("#" + entry.ord + " (" + entry.id + ") 在 bundle 中找不到对应调用点");
      continue;
    }
    if (retiredSet.has(entry.ord)) {
      problems.push("#" + entry.ord + " 同时出现在权威策略表与退役名单，表本身自相矛盾");
    }
    if (!site.reachable) {
      problems.push("#" + entry.ord + " (" + entry.id + ") 权威表要求接线，但 AST 判为不可达");
    }
    if (site.policy !== entry.policy) {
      problems.push("#" + entry.ord + " (" + entry.id + ") policy=" + site.policy + " ≠ 权威 " + entry.policy);
    }
    // anchor 必须在**这份** bundle 里存在且唯一。core 模式的 anchor 内嵌 guard 头，
    // 只在打过核心补丁的文本里才有；指向原始基线时回落到 baselineAnchor。
    let anchor = entry.finalAnchor && guardWiring.countOccurrences(src, entry.finalAnchor) === 1
      ? entry.finalAnchor
      : entry.anchor;
    let used = anchor === entry.finalAnchor ? "finalAnchor" : "anchor";
    if (guardWiring.countOccurrences(src, anchor) !== 1 && entry.baselineAnchor) {
      anchor = entry.baselineAnchor;
      used = "baselineAnchor";
    }
    const hits = guardWiring.countOccurrences(src, anchor);
    if (hits === 1) {
      anchorsOk++;
      if (used === "baselineAnchor") baselineAnchorsUsed++;
    } else {
      problems.push("#" + entry.ord + " (" + entry.id + ") " + used + " 在此 bundle 中出现 " + hits + " 次（须恰好 1）");
    }
  }
  manifest.anchorIntegrity.authorityCrossCheck = {
    entriesChecked: table.length,
    anchorsUniqueInThisBundle: anchorsOk,
    baselineAnchorFallbacks: baselineAnchorsUsed,
    problems: problems.length,
  };
  return problems;
}

/** 解析参数：支持 --in/--out/--check，并兼容旧的位置参数写法 */
function parseArgs(argv) {
  const opt = { inPath: DEFAULT_BUNDLE, outPath: null, check: false };
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === "--check") opt.check = true;
    else if (a === "--in") opt.inPath = argv[++i];
    else if (a === "--out") opt.outPath = argv[++i];
    else if (a.startsWith("--")) throw new Error("未知参数：" + a);
    else if (!opt.outPath) opt.outPath = a; // 兼容 `gen_callsite_manifest_v4.js <out.json>`
    else throw new Error("多余的位置参数：" + a);
  }
  if (!opt.inPath) throw new Error("--in 缺少路径");
  if (!opt.check && !opt.outPath) {
    throw new Error("usage: node gen_callsite_manifest_v4.js --out <out.json> [--in <bundle.js>] | --check");
  }
  return opt;
}

function main(argv) {
  const opt = parseArgs(argv);
  const inPath = path.resolve(opt.inPath);
  if (!fs.existsSync(inPath)) throw new Error("输入 bundle 不存在：" + inPath);
  const st = fs.statSync(inPath);
  if (!st.isFile()) throw new Error("输入不是文件：" + inPath);
  if (st.size < 1024) throw new Error("输入 bundle 太小（" + st.size + " 字节），疑似路径写错：" + inPath);

  const src = fs.readFileSync(inPath, "utf8");
  const relPath = path.relative(path.join(__dirname, ".."), inPath) || path.basename(inPath);
  const manifest = buildManifest(src, relPath);
  const problems = validateAgainstAuthority(manifest, src);

  console.log("input             :", inPath);
  console.log("bundleSha256      :", manifest.bundleSha256.slice(0, 16));
  console.log("total/active/retired:", manifest.totalCallsites, "/", manifest.activeCallsites,
              "/", manifest.retiredCallsites.length);
  console.log("byPolicy          :", JSON.stringify(manifest.byPolicy));
  console.log("guarded(active)   :", manifest.coverage.guarded,
              "unguarded:", manifest.coverage.unguarded.join(",") || "(none)");
  console.log("anchors all unique:", manifest.anchorIntegrity.allUnique,
              manifest.anchorIntegrity.allUnique ? "" : "NON-UNIQUE:" + manifest.anchorIntegrity.nonUnique);
  console.log("authority x-check :", JSON.stringify(manifest.anchorIntegrity.authorityCrossCheck));
  console.log("dead branches     :", manifest.reachability.deadBranchCount,
              "regions=" + JSON.stringify(manifest.reachability.deadBranchRanges),
              "(区域数≠退役调用点数：19 个 runSelection 中仅 " +
              manifest.retiredCallsites.length + " 个落在其中)");

  if (problems.length) {
    console.error("MANIFEST_AUTHORITY_MISMATCH（未写出台账）：");
    for (const p of problems) console.error("  - " + p);
    return 1;
  }
  if (opt.check) {
    console.log("MANIFEST_CHECK_OK  : 派生台账与权威策略表一致（--check 不写盘）");
    return 0;
  }
  const outPath = path.resolve(opt.outPath);
  const outDir = path.dirname(outPath);
  if (!fs.existsSync(outDir)) throw new Error("输出目录不存在：" + outDir);
  fs.writeFileSync(outPath, JSON.stringify(manifest, null, 2), "utf8");
  console.log("written           :", outPath);
  console.log("MANIFEST_WRITTEN_OK");
  return 0;
}

module.exports = { buildManifest, validateAgainstAuthority, parseArgs, policyByOrdinal, uniqueAnchor, normalizeDeadRanges, main, DEFAULT_BUNDLE };

if (require.main === module) {
  try {
    process.exit(main(process.argv.slice(2)));
  } catch (e) {
    console.error("GEN_MANIFEST_FAILED:", e && e.message ? e.message : e);
    process.exit(2);
  }
}
