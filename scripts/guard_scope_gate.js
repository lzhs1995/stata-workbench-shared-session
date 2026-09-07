"use strict";
/**
 * guard_scope_gate.js —— 权威「作用域可解析性」判据（真 AST，acorn）
 *
 * 为什么必须新增这一维（rc.7.13 的血证）：
 *   rc.7.13 静态覆盖率 17/17「全绿」，但真机执行时 10 个调用点在 33–444ms 内
 *   直接抛 `ReferenceError: __codexExecGuard is not defined`——guard 逻辑一行都没跑。
 *   根因：`__codexExecGuard` / `__codexPreRunGuard` 是 activate()
 *   （minified `HHg`，FunctionDeclaration span 85660 B）内部的词法 `let` 绑定，
 *   而 17 个被包装的调用点里有 10 个在这个函数**之外**，裸标识符压根解析不到。
 *
 *   已有闸门为什么全瞎（必须理解，否则会再加一个瞎闸门）：
 *     · ast_reachability_gate  只证「语法上被包住 + 不在死分支」，**不做作用域解析**
 *     · bundle_identity/指纹    只证字节，不证语义
 *     · POLICY 表               只匹配**文本**
 *     · 单元测试                直接 require 模块，永远在作用域内，物理上无法复现
 *   → 覆盖率是**语法**属性；能不能跑是**作用域**属性。两者必须分开证。
 *
 *   补充事实（本闸门反查 rc70 baseline 95aa8079 得到）：该缺陷**早于 rc.7.13**——
 *   baseline 自身已有 4 处越界 `__codexPreRunGuard`（human-file 的 ABSOLUTE 前置阶段
 *   其实从未生效）。rc.7.13 不是引入者，而是把 4 处放大到 19 处。
 *
 * 判据：
 *   1. 沿真祖先链做函数作用域解析（Program / FunctionDeclaration /
 *      FunctionExpression / ArrowFunctionExpression 才建作用域）
 *   2. 显式 `globalThis.<X>Ref` 成员表达式 → 全局可解析（前提：该全局有导出点）
 *   3. 裸标识符只有落在其声明作用域的**后代**里才算可解析；兄弟/外层函数一律判死
 *   4. 每个全局绑定必须**恰好导出一次**；引用未导出的全局 = 失败
 *   5. 检查**全部** guard 相关引用，不只 zg.runSelection 调用点
 *
 * 退出码：不一致 → 非零；同时输出机器可读 JSON 行。
 */
const acorn = require("acorn");

/** 受管的两个 guard 模块：词法名 → 显式全局名 */
const GUARDS = {
  __codexExecGuard: "__codexExecGuardRef",
  __codexPreRunGuard: "__codexPreRunGuardRef",
};
const GLOBAL_NAMES = Object.values(GUARDS);
const LEXICAL_NAMES = Object.keys(GUARDS);

/** 只有这些节点类型建立函数作用域（块级 let 不在本闸门关心的粒度内：
 *  两个 guard 都是 activate() 顶层 declarator，函数粒度足够且更保守） */
const FUNC = new Set([
  "FunctionDeclaration",
  "FunctionExpression",
  "ArrowFunctionExpression",
  "Program",
]);

const SKIP_KEYS = new Set(["start", "end", "type", "loc", "range"]);

/** 允许保留裸引用的白名单原因（必须可判定，不能是"看着没事"） */
const BARE_ALLOWED = {
  DECLARATOR: "declarator",     // 声明点自身
  WRAPPER_CLOSURE: "wrapper",   // __codexGuardWrap 包装器体内（其安装点在声明作用域内，词法可解析）
};

function analyze(src) {
  const ast = acorn.parse(src, {
    ecmaVersion: "latest",
    sourceType: "script",
    allowReturnOutsideFunction: true,
  });

  /** 词法名 → 声明所在函数作用域节点 */
  const declScope = new Map();
  /** 声明点 Identifier 的 start 集合 */
  const declaratorIds = new Set();
  /** 显式全局导出点：全局名 → [start,...] */
  const exports = new Map(GLOBAL_NAMES.map((n) => [n, []]));
  /** __codexGuardWrap 包装器赋值表达式范围 */
  let wrapperRange = null;
  /** 裸标识符引用 */
  const bareRefs = [];
  /** 显式全局成员引用 globalThis.<Ref> */
  const globalRefs = [];

  function isGlobalThisMember(node, propName) {
    return (
      node &&
      node.type === "MemberExpression" &&
      !node.computed &&
      node.object &&
      node.object.type === "Identifier" &&
      node.object.name === "globalThis" &&
      node.property &&
      node.property.type === "Identifier" &&
      (propName ? node.property.name === propName : GLOBAL_NAMES.includes(node.property.name))
    );
  }

  function walk(node, scopes) {
    if (!node || typeof node.type !== "string") return;
    const sc = FUNC.has(node.type) ? scopes.concat([node]) : scopes;

    // 声明点
    if (
      node.type === "VariableDeclarator" &&
      node.id &&
      node.id.type === "Identifier" &&
      LEXICAL_NAMES.includes(node.id.name)
    ) {
      declScope.set(node.id.name, sc[sc.length - 1]);
      declaratorIds.add(node.id.start);
    }

    // 显式全局导出：globalThis.<Ref> = <expr>（赋值左值才算导出，读取不算）
    if (
      node.type === "AssignmentExpression" &&
      node.operator === "=" &&
      isGlobalThisMember(node.left)
    ) {
      exports.get(node.left.property.name).push(node.left.start);
    }

    // 包装器范围
    if (
      node.type === "AssignmentExpression" &&
      node.left &&
      node.left.type === "MemberExpression" &&
      !node.left.computed &&
      node.left.object &&
      node.left.object.type === "Identifier" &&
      node.left.object.name === "globalThis" &&
      node.left.property &&
      node.left.property.name === "__codexGuardWrap"
    ) {
      wrapperRange = { start: node.start, end: node.end };
    }

    // 显式全局读取引用（排除导出赋值的左值本身）
    if (isGlobalThisMember(node)) {
      globalRefs.push({ name: node.property.name, start: node.start });
    }

    // 裸标识符引用
    if (node.type === "Identifier" && LEXICAL_NAMES.includes(node.name)) {
      bareRefs.push({ name: node.name, start: node.start, scopes: sc.slice() });
    }

    for (const k in node) {
      if (SKIP_KEYS.has(k)) continue;
      const v = node[k];
      if (Array.isArray(v)) {
        for (const x of v) if (x && typeof x.type === "string") walk(x, sc);
      } else if (v && typeof v === "object" && typeof v.type === "string") {
        walk(v, sc);
      }
    }
  }
  walk(ast, []);

  return { ast, declScope, declaratorIds, exports, wrapperRange, bareRefs, globalRefs };
}

/**
 * 对单个裸引用判定：可解析 / 允许保留的原因 / 违规
 * @returns {{resolvable:boolean, allow:string|null}}
 */
function classifyBareRef(ref, model) {
  const d = model.declScope.get(ref.name);
  const resolvable = !!d && ref.scopes.includes(d);
  let allow = null;
  if (model.declaratorIds.has(ref.start)) allow = BARE_ALLOWED.DECLARATOR;
  else if (
    model.wrapperRange &&
    ref.start >= model.wrapperRange.start &&
    ref.start < model.wrapperRange.end
  ) {
    // 包装器闭包只有在其安装点确实位于声明作用域内时才允许保留裸引用
    allow = resolvable ? BARE_ALLOWED.WRAPPER_CLOSURE : null;
  }
  return { resolvable, allow };
}

/**
 * 把「某个 guard 调用点的 guard 引用」定位出来并判定可解析性。
 *
 * 关联方式是**结构化**的：沿祖先链找到包住本调用点的 guard 调用
 * （__codexGuardWrap / guardStage / guardProgress），再检查该调用的
 * callee 与 arguments 子树里出现的 guard 引用。绝不用"附近多少字节"这种近似。
 */
function guardRefsForSite(site, model, ast) {
  const out = { bare: [], global: [], guardCall: null };
  // 找包住 site 的 guard 调用（复用 ast_reachability_gate 的判据语义）
  const path = [];
  (function find(node, chain) {
    if (!node || typeof node.type !== "string") return;
    if (node.start <= site.start && node.end >= site.end) {
      chain = chain.concat([node]);
      if (node.start === site.start && node.end === site.end) { path.push(...chain); return; }
    } else return;
    for (const k in node) {
      if (SKIP_KEYS.has(k)) continue;
      const v = node[k];
      if (Array.isArray(v)) { for (const x of v) if (x && typeof x.type === "string") find(x, chain); }
      else if (v && typeof v === "object" && typeof v.type === "string") find(v, chain);
    }
  })(ast, []);

  let guardCall = null;
  for (let i = path.length - 1; i >= 0; i--) {
    const n = path[i];
    if (n.type !== "CallExpression") continue;
    const c = n.callee;
    let nm = null;
    if (c && c.type === "Identifier") nm = c.name;
    else if (c && c.type === "MemberExpression" && !c.computed && c.property && c.property.type === "Identifier") nm = c.property.name;
    if (nm === "__codexGuardWrap" || nm === "guardStage" || nm === "guardProgress") {
      const inArgs = (n.arguments || []).some((a) => a && site.start >= a.start && site.end <= a.end);
      if (inArgs) { guardCall = { node: n, name: nm }; break; }
    }
  }
  if (!guardCall) return out;
  out.guardCall = guardCall.name;

  // 在 guard 调用的 callee + 直接实参里收集 guard 引用（不下潜进 ()=>zg.runSelection 工作体）
  const scan = [];
  if (guardCall.node.callee) scan.push(guardCall.node.callee);
  for (const a of guardCall.node.arguments || []) {
    if (a && site.start >= a.start && site.end <= a.end) continue; // 跳过工作体本身
    scan.push(a);
  }
  for (const root of scan) {
    (function collect(node) {
      if (!node || typeof node.type !== "string") return;
      if (node.type === "Identifier" && LEXICAL_NAMES.includes(node.name)) {
        const ref = model.bareRefs.find((r) => r.start === node.start);
        const cls = ref ? classifyBareRef(ref, model) : { resolvable: false, allow: null };
        out.bare.push({ name: node.name, start: node.start, resolvable: cls.resolvable, allow: cls.allow });
      }
      if (node.type === "MemberExpression" && !node.computed && node.object &&
          node.object.type === "Identifier" && node.object.name === "globalThis" &&
          node.property && GLOBAL_NAMES.includes(node.property.name)) {
        out.global.push({ name: node.property.name, start: node.start });
      }
      for (const k in node) {
        if (SKIP_KEYS.has(k)) continue;
        const v = node[k];
        if (Array.isArray(v)) { for (const x of v) if (x && typeof x.type === "string") collect(x); }
        else if (v && typeof v === "object" && typeof v.type === "string") collect(v);
      }
    })(root);
  }
  return out;
}

/** 期望值（硬门禁；漂移即失败，不允许"看起来差不多"） */
const EXPECT = {
  totalCallsites: 17,
  retired: 2,
  reachable: 15,
  guarded: 15,
  scopeResolvable: 15,
  unresolvable: 0,
  policyMatched: 15,
};

/**
 * 完整闸门报告。
 * @param {string} src bundle 文本
 * @param {{expectCounts?:boolean}} [opts] expectCounts=false 时跳过 EXPECT 硬计数
 *        （仅供对抗性合成夹具使用；对真 bundle 必须开着）
 * @returns {{ok:boolean, counts:object, rows:Array, problems:Array}}
 */
function gateReport(src, opts) {
  const expectCounts = !opts || opts.expectCounts !== false;
  const AST = require("./ast_reachability_gate.js");
  const WIRING = require("./guard_wiring_rc713.js");
  const acornMod = require("acorn");

  const model = analyze(src);
  const ast = acornMod.parse(src, { ecmaVersion: "latest", sourceType: "script", allowReturnOutsideFunction: true });
  const reach = AST.analyze(src);
  const sites = reach.callsites.slice().sort((a, b) => a.start - b.start);
  const problems = [];

  // ---- 全局导出契约：每个受管全局必须**恰好**导出一次 ----
  const exportRows = [];
  for (const [lex, glob] of Object.entries(GUARDS)) {
    const hits = model.exports.get(glob) || [];
    exportRows.push({ lexical: lex, global: glob, exportCount: hits.length });
    if (hits.length === 0) problems.push("全局导出缺失：" + glob + "（引用它的调用点全部会拿到 undefined）");
    else if (hits.length > 1) problems.push("全局导出重复：" + glob + " 出现 " + hits.length + " 次（无法判定最终绑定）");
  }
  const exportedGlobals = new Set(
    exportRows.filter((r) => r.exportCount === 1).map((r) => r.global)
  );

  // ---- 引用未导出的全局绑定 = 失败 ----
  for (const g of model.globalRefs) {
    if (!exportedGlobals.has(g.name)) {
      problems.push("引用了未成功导出的全局绑定 " + g.name + " @" + g.start);
    }
  }

  // ---- 全部裸引用（不限 zg.runSelection）必须词法可解析或属白名单 ----
  let bareViolations = 0;
  for (const ref of model.bareRefs) {
    const { resolvable, allow } = classifyBareRef(ref, model);
    if (allow) continue;
    if (!resolvable) {
      bareViolations++;
      problems.push("越界裸引用 " + ref.name + " @" + ref.start + "（其声明作用域不在祖先链上）");
    } else {
      bareViolations++;
      problems.push("裸引用 " + ref.name + " @" + ref.start + " 虽词法可解析，但未使用统一全局形态");
    }
  }

  // ---- 逐调用点：可达性 / 已 guard / guard 引用可解析 / policy ----
  const byOrd = new Map(WIRING.POLICY_TABLE.map((e) => [e.ord, e]));
  const rows = [];
  let reachableN = 0, guardedN = 0, resolvableN = 0, unresolvableN = 0, policyN = 0;

  for (let i = 0; i < sites.length; i++) {
    const ord = i + 1;
    const site = sites[i];
    const entry = byOrd.get(ord) || null;
    const retired = !site.reachable;
    const row = {
      ord, start: site.start, reachable: !!site.reachable, retired,
      guarded: !!site.guarded, guardKind: site.guardKind || null,
      id: entry ? entry.id : null, policyDeclared: entry ? entry.policy : null,
      guardRefs: { bare: 0, global: 0, unresolvable: 0 }, scopeResolvable: null,
      policyMatched: null,
    };

    if (retired) {
      rows.push(row);
      continue;
    }
    reachableN++;
    if (site.guarded) guardedN++;
    else problems.push("#" + ord + " 可达但未被 guard 包裹");

    const refs = guardRefsForSite(site, model, ast);
    row.guardRefs.bare = refs.bare.length;
    row.guardRefs.global = refs.global.length;
    const badBare = refs.bare.filter((b) => !b.resolvable);
    row.guardRefs.unresolvable = badBare.length;
    // 可解析 = 没有不可解析的裸引用，且（用了全局形态 或 裸引用词法可解析）
    const hasAnyRef = refs.bare.length + refs.global.length > 0;
    const allGlobalsExported = refs.global.every((g) => exportedGlobals.has(g.name));
    row.scopeResolvable = hasAnyRef && badBare.length === 0 && allGlobalsExported;
    if (row.scopeResolvable) resolvableN++;
    else {
      unresolvableN += Math.max(1, badBare.length);
      problems.push(
        "#" + ord + " " + (row.id || "?") + " guard 引用不可解析" +
          (badBare.length ? "（越界裸引用 " + badBare.map((b) => b.name + "@" + b.start).join(",") + "）"
                          : hasAnyRef ? "（全局绑定未导出）" : "（找不到任何 guard 引用）")
      );
    }

    if (entry) {
      const expr = require("./guard_wiring_rc713.js").POLICY_EXPR[entry.policy];
      if (entry.mode === "wrap") {
        row.policyMatched = expr ? src.slice(site.start - 400, site.start).includes(expr) : false;
      } else {
        // core：guardStage/guardProgress 的 guardKind 必须与表一致
        row.policyMatched = String(site.guardKind) === String(entry.guardKind);
      }
      if (row.policyMatched) policyN++;
      else problems.push("#" + ord + " " + entry.id + " policy 表述与 bundle 不一致（declared " + entry.policy + "）");
    } else {
      problems.push("#" + ord + " 可达但不在权威 POLICY 表中");
    }
    rows.push(row);
  }

  const counts = {
    totalCallsites: sites.length,
    retired: sites.filter((s) => !s.reachable).length,
    reachable: reachableN,
    guarded: guardedN,
    scopeResolvable: resolvableN,
    unresolvable: unresolvableN,
    policyMatched: policyN,
    bareRefsTotal: model.bareRefs.length,
    bareRefsKept: model.bareRefs.filter((r) => !!classifyBareRef(r, model).allow).length,
    bareViolations,
    globalRefs: model.globalRefs.length,
    exports: exportRows,
  };

  for (const [k, want] of Object.entries(EXPECT)) {
    if (expectCounts && counts[k] !== want) problems.push("计数不符：" + k + "=" + counts[k] + "，要求 " + want);
  }

  // ---- rc.7.15：StopCheckpoint 模块引用的作用域契约（块粒度，见 checkpoint_scope_gate 头注） ----
  // 为什么并进本闸门：打包期只跑一个门就必须能拦住**同一缺陷类**的所有实例。
  //   rc.7.13 是 guard 越界（函数粒度可判），rc.7.14 残留的是 __codexStopCheckpoint
  //   越界（let 在 BlockStatement 内，必须块粒度才判得准）。两者同类，不该两个门各判一半。
  // 不写进 EXPECT：EXPECT 是 guard 调用点的硬计数契约，混入模块引用计数会让
  //   「17/17」这个已被反复引用的口径产生歧义。
  const CKPT = require("./checkpoint_scope_gate.js");
  const ckpt = CKPT.report(src);
  counts.checkpoint = {
    bareViolations: ckpt.counts.bareViolations,
    outOfScope: ckpt.counts.outOfScope,
    globalRefs: ckpt.counts.globalRefs,
    declKind: ckpt.counts.declKind,
    exports: ckpt.counts.exports,
  };
  for (const p of ckpt.problems) problems.push("[checkpoint] " + p);

  return { ok: problems.length === 0, counts, rows, problems };
}

module.exports = {
  GUARDS,
  GLOBAL_NAMES,
  LEXICAL_NAMES,
  FUNC,
  BARE_ALLOWED,
  EXPECT,
  analyze,
  classifyBareRef,
  guardRefsForSite,
  gateReport,
};

// ---------------- CLI ----------------
if (require.main === module) {
  const fs = require("fs");
  const path = require("path");
  const args = process.argv.slice(2);
  const fileIdx = args.indexOf("--file");
  const jsonOut = args.indexOf("--json") >= 0;
  const expectFail = args.indexOf("--expect-fail") >= 0;
  const target = fileIdx >= 0 && args[fileIdx + 1]
    ? path.resolve(args[fileIdx + 1])
    : path.join(__dirname, "..", "dist", "extension.js");

  let rep;
  try {
    rep = gateReport(fs.readFileSync(target, "utf8"));
  } catch (e) {
    console.error("GUARD_SCOPE_GATE_ERROR " + target + " :: " + (e && e.message ? e.message : e));
    process.exit(3);
  }

  if (jsonOut) {
    console.log(JSON.stringify({ target, ok: rep.ok, counts: rep.counts, rows: rep.rows, problems: rep.problems }, null, 2));
  } else {
    const c = rep.counts;
    console.log(
      (rep.ok ? "GUARD_SCOPE_GATE_OK " : "GUARD_SCOPE_GATE_FAILED ") + target +
        "\n  total=" + c.totalCallsites + " retired=" + c.retired + " reachable=" + c.reachable +
        " guarded=" + c.guarded + " scopeResolvable=" + c.scopeResolvable +
        " unresolvable=" + c.unresolvable + " policy=" + c.policyMatched + "/" + EXPECT.policyMatched +
        "\n  bareRefs=" + c.bareRefsTotal + "（保留 " + c.bareRefsKept + " 违规 " + c.bareViolations + "）" +
        " globalRefs=" + c.globalRefs +
        "\n  exports=" + c.exports.map((e) => e.global + ":" + e.exportCount).join(", ") +
        "\n  checkpoint: violations=" + c.checkpoint.bareViolations +
        " outOfScope=" + c.checkpoint.outOfScope +
        " globalRefs=" + c.checkpoint.globalRefs +
        " declKind=" + c.checkpoint.declKind +
        " exports=" + c.checkpoint.exports.map((e) => e.global + ":" + e.exportCount).join(", ")
    );
    if (!rep.ok) {
      const dead = rep.rows.filter((r) => !r.retired && r.scopeResolvable === false).map((r) => r.ord);
      if (dead.length) console.error("  作用域不可解析的序号: [" + dead.join(",") + "]");
      for (const p of rep.problems.slice(0, 24)) console.error("  · " + p);
      if (rep.problems.length > 24) console.error("  · …其余 " + (rep.problems.length - 24) + " 条");
    }
  }

  if (expectFail) process.exit(rep.ok ? 1 : 0);
  process.exit(rep.ok ? 0 : 1);
}
