"use strict";
/**
 * checkpoint_scope_gate.js —— StopCheckpoint 模块引用的「作用域可解析性」判据（真 AST）
 *
 * 为什么不能直接复用 guard_scope_gate 的分析器：
 *   guard_scope_gate.FUNC 只在 Program/Function* 上建作用域，是**函数粒度**。
 *   两个 guard 都是 activate() 顶层 declarator，函数粒度恰好够用。
 *   但 __codexStopCheckpoint 是 BlockStatement 内的词法 `let`
 *   （rc.7.14 实测 let@5229112 ∈ BlockStatement@5228541-5309154
 *     ∈ FunctionDeclaration@5227763-5317601），
 *   函数粒度会把「同函数、块外」的引用误判为可解析 —— 对 let 是错的判据。
 *   故本闸门按 ES 真实词法规则建作用域：var→函数体，let/const/class→块。
 *
 * rc.7.14 真机缺陷（本闸门必须能判死的形态）：
 *   8 个消费点里 2 个越界（dist @5369791 human-file pre-run enrich、
 *   @5391352 human-file 完成清理）→ 裸标识符抛 ReferenceError：
 *     · 「内存里有数据集」的 Run File 必 500（SYNC_THREW / elapsedMs=0），
 *       随后桥卡 postRunBusy=True/draining，/soft-stop 返回 409；
 *     · 清理点抛错被 try{}catch{} 吞掉 → 快照静默泄漏。
 *
 * 判据设计原则（与 rc.7.14 一致）：fail closed。
 *   导出缺失/重复、越界裸引用、未统一形态，全部计违规；解析失败退出码 3。
 */
const acorn = require("acorn");

/** 受管模块：词法名 → 显式全局名 / 全局路径名 / 模块文件 */
const MODULES = {
  __codexStopCheckpoint: {
    globalRef: "__codexStopCheckpointRef",
    globalPath: "__codexStopCheckpointPath",
    moduleFile: "stop_checkpoint_core.js",
  },
};
const LEXICAL_NAMES = Object.keys(MODULES);
const GLOBAL_NAMES = Object.values(MODULES).map((m) => m.globalRef);

/** 函数作用域宿主（var 落这里） */
const FUNC = new Set([
  "Program",
  "FunctionDeclaration",
  "FunctionExpression",
  "ArrowFunctionExpression",
]);
/** 块作用域宿主（let/const/class 落这里） */
const BLOCK = new Set([
  "BlockStatement",
  "ForStatement",
  "ForInStatement",
  "ForOfStatement",
  "SwitchStatement",
  "CatchClause",
  "StaticBlock",
]);

const SKIP_KEYS = new Set(["start", "end", "type", "loc", "range"]);

/** globalThis.<受管全局> 成员表达式判定（非计算属性） */
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

/**
 * 建作用域链并采集：声明点 / 导出点 / 裸引用 / 全局引用。
 * @param {string} src
 * @returns {{ast:object, declScope:Map, declKind:Map, declaratorIds:Set,
 *            exports:Map, bareRefs:Array, globalRefs:Array}}
 */
function analyze(src) {
  const ast = acorn.parse(src, {
    ecmaVersion: "latest",
    sourceType: "script",
    allowReturnOutsideFunction: true,
  });

  const declScope = new Map(); // 词法名 → 声明所在作用域节点
  const declKind = new Map(); // 词法名 → var|let|const
  const declaratorIds = new Set(); // 声明点 Identifier 的 start
  const exports = new Map(GLOBAL_NAMES.map((n) => [n, []]));
  const bareRefs = [];
  const globalRefs = [];

  // scopes 是作用域链：每项 {node, kind:"func"|"block"}
  function walk(node, scopes, kindHint) {
    if (!node || typeof node.type !== "string") return;

    let sc = scopes;
    if (FUNC.has(node.type)) sc = scopes.concat([{ node: node, kind: "func" }]);
    else if (BLOCK.has(node.type)) sc = scopes.concat([{ node: node, kind: "block" }]);

    // 声明点：按 kind 决定落函数作用域还是最近块作用域
    if (
      node.type === "VariableDeclarator" &&
      node.id &&
      node.id.type === "Identifier" &&
      LEXICAL_NAMES.includes(node.id.name)
    ) {
      const kind = kindHint || "let";
      let host = null;
      if (kind === "var") {
        for (let i = sc.length - 1; i >= 0; i--) {
          if (sc[i].kind === "func") {
            host = sc[i].node;
            break;
          }
        }
      } else {
        host = sc.length ? sc[sc.length - 1].node : null;
      }
      declScope.set(node.id.name, host);
      declKind.set(node.id.name, kind);
      declaratorIds.add(node.id.start);
    }

    // 只有**赋值**才算导出（读取不算），与 rc.7.14 判据一致
    if (
      node.type === "AssignmentExpression" &&
      node.operator === "=" &&
      isGlobalThisMember(node.left)
    ) {
      exports.get(node.left.property.name).push(node.left.start);
    }
    if (isGlobalThisMember(node)) {
      globalRefs.push({ name: node.property.name, start: node.start });
    }
    if (node.type === "Identifier" && LEXICAL_NAMES.includes(node.name)) {
      bareRefs.push({ name: node.name, start: node.start, scopes: sc.map((s) => s.node) });
    }

    const nextHint = node.type === "VariableDeclaration" ? node.kind : kindHint;
    for (const k in node) {
      if (SKIP_KEYS.has(k)) continue;
      const v = node[k];
      if (Array.isArray(v)) {
        for (const x of v) if (x && typeof x.type === "string") walk(x, sc, nextHint);
      } else if (v && typeof v === "object" && typeof v.type === "string") {
        walk(v, sc, nextHint);
      }
    }
  }
  walk(ast, [], null);

  return { ast, declScope, declKind, declaratorIds, exports, bareRefs, globalRefs };
}

/**
 * 裸引用判定：只有落在其声明作用域**后代**里才算词法可解析。
 * 声明点自身（declarator）允许保留，否则没有词法绑定可言。
 */
function classifyBareRef(ref, model) {
  const d = model.declScope.get(ref.name);
  const resolvable = !!d && ref.scopes.includes(d);
  const allow = model.declaratorIds.has(ref.start) ? "declarator" : null;
  return { resolvable: resolvable, allow: allow };
}

/**
 * 闸门报告。
 * @param {string} src bundle 文本
 * @returns {{ok:boolean, counts:object, problems:string[], consumers:Array}}
 */
function report(src) {
  const model = analyze(src);
  const problems = [];

  // ---- 全局导出契约：受管全局必须**恰好**导出一次 ----
  const exportRows = [];
  for (const lex of LEXICAL_NAMES) {
    const spec = MODULES[lex];
    const hits = model.exports.get(spec.globalRef) || [];
    exportRows.push({ lexical: lex, global: spec.globalRef, exportCount: hits.length });
    if (hits.length === 0) {
      problems.push("全局导出缺失：" + spec.globalRef + "（消费点全部会拿到 undefined）");
    } else if (hits.length > 1) {
      problems.push("全局导出重复：" + spec.globalRef + " 出现 " + hits.length + " 次（无法判定最终绑定）");
    }
  }
  const exported = new Set(
    exportRows.filter((r) => r.exportCount === 1).map((r) => r.global)
  );

  // ---- 引用未成功导出的全局绑定 = 失败 ----
  for (const g of model.globalRefs) {
    if (!exported.has(g.name)) {
      problems.push("引用了未成功导出的全局绑定 " + g.name + " @" + g.start);
    }
  }

  // ---- 裸引用：除声明点外一律违规；越界者额外点名（ReferenceError 真因） ----
  const consumers = [];
  let bareViolations = 0;
  let outOfScope = 0;
  for (const ref of model.bareRefs) {
    const c = classifyBareRef(ref, model);
    if (c.allow === "declarator") continue;
    consumers.push({ name: ref.name, start: ref.start, resolvable: c.resolvable });
    bareViolations++;
    if (!c.resolvable) {
      outOfScope++;
      problems.push(
        "越界裸引用 " + ref.name + " @" + ref.start + "（声明作用域不在祖先链上 → ReferenceError）"
      );
    } else {
      problems.push(
        "裸引用 " + ref.name + " @" + ref.start + " 虽词法可解析，但未使用统一全局形态"
      );
    }
  }

  const counts = {
    bareRefsTotal: model.bareRefs.length,
    bareViolations: bareViolations,
    outOfScope: outOfScope,
    globalRefs: model.globalRefs.length,
    exports: exportRows,
    declKind: Array.from(model.declKind.entries())
      .map(function (e) {
        return e[0] + ":" + e[1];
      })
      .join(","),
  };
  return { ok: problems.length === 0, counts: counts, problems: problems, consumers: consumers };
}

module.exports = {
  MODULES,
  LEXICAL_NAMES,
  GLOBAL_NAMES,
  FUNC,
  BLOCK,
  isGlobalThisMember,
  analyze,
  classifyBareRef,
  report,
};

// ---------------- CLI ----------------
if (require.main === module) {
  const fs = require("fs");
  const path = require("path");
  const args = process.argv.slice(2);
  const i = args.indexOf("--file");
  const expectFail = args.indexOf("--expect-fail") >= 0;
  const asJson = args.indexOf("--json") >= 0;
  const target =
    i >= 0 && args[i + 1]
      ? path.resolve(args[i + 1])
      : path.join(__dirname, "..", "dist", "extension.js");

  let rep;
  try {
    rep = report(fs.readFileSync(target, "utf8"));
  } catch (e) {
    console.error(
      "CHECKPOINT_SCOPE_GATE_ERROR " + target + " :: " + ((e && e.message) || e)
    );
    process.exit(3);
  }

  if (asJson) {
    console.log(JSON.stringify({ target: target, ok: rep.ok, counts: rep.counts, consumers: rep.consumers, problems: rep.problems }, null, 2));
  } else {
    const c = rep.counts;
    console.log(
      (rep.ok ? "CHECKPOINT_SCOPE_GATE_OK " : "CHECKPOINT_SCOPE_GATE_FAILED ") +
        target +
        "\n  bareRefs=" + c.bareRefsTotal +
        " violations=" + c.bareViolations +
        " outOfScope=" + c.outOfScope +
        " globalRefs=" + c.globalRefs +
        " declKind=" + c.declKind +
        "\n  exports=" +
        c.exports.map((e) => e.global + ":" + e.exportCount).join(", ")
    );
    if (!rep.ok) {
      for (const p of rep.problems.slice(0, 24)) console.error("  · " + p);
      if (rep.problems.length > 24) {
        console.error("  · …其余 " + (rep.problems.length - 24) + " 条");
      }
    }
  }

  if (expectFail) process.exit(rep.ok ? 1 : 0);
  process.exit(rep.ok ? 0 : 1);
}
