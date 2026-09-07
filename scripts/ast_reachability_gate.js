"use strict";
/**
 * ast_reachability_gate.js —— 权威可达性判据（真 AST，acorn）
 *
 * 为什么必须替掉自制词法扫描器（js_scope_scan.js）：
 *   codex 实测击穿了它 —— `return /}/` 与 `typeof /}/` 会让死分支**提前收尾**，
 *   把不可达调用误判成活跃（假可达）。根因是 `regexAllowedAfter()` 只看前一个字符：
 *   `return` 结尾是 `n`（标识符字符）→ 把 `/` 当除号 → 正则内的 `}` 被当作块结束。
 *   继续补词法规则等于重写解析器。**可达性是语法问题，不是词法问题。**
 *   实测 acorn 解析 5.5MB minified 仅 ~140ms，代价远低于维护一个必然漏的近似实现。
 *
 * 判据（全部基于语法树，不用字节窗口）：
 *   · 死分支：IfStatement 的 test 恒假（false / !1 / !!0 / 0 / "" 等），其 consequent
 *     子树内所有节点不可达（alternate 仍可达）
 *   · 调用点：CallExpression callee 为 MemberExpression `zg.runSelection`（非 computed）
 *   · 是否已 guard：沿**祖先链**找 guardStage(…) / guardProgress(…) 调用，
 *     且本节点必须落在该调用的 **arguments 子树**内（不是"附近 900 字节"）
 *
 * 导出 analyze(src) → { deadRanges, callsites:[{start,reachable,guarded,guardKind}] }
 */
const acorn = require("acorn");

/** test 是否恒假（覆盖 minifier 常见形态） */
function isConstFalse(node) {
  if (!node) return false;
  if (node.type === "Literal") {
    return node.value === false || node.value === 0 || node.value === "" || node.value === null;
  }
  // !1 / !!0
  if (node.type === "UnaryExpression" && node.operator === "!") {
    const a = node.argument;
    if (a && a.type === "Literal") return !!a.value;          // !1 → false
    if (a && a.type === "UnaryExpression" && a.operator === "!") return isConstFalse(a.argument);
  }
  // false && anything  → 恒假
  if (node.type === "LogicalExpression" && node.operator === "&&") {
    return isConstFalse(node.left);
  }
  return false;
}

function isRunSelectionCall(node) {
  if (!node || node.type !== "CallExpression") return false;
  const c = node.callee;
  return !!(c && c.type === "MemberExpression" && !c.computed &&
            c.object && c.object.type === "Identifier" && c.object.name === "zg" &&
            c.property && c.property.type === "Identifier" && c.property.name === "runSelection");
}

/** 该 CallExpression 是否是 guardStage/guardProgress 调用；返回 kind 或 null */
function guardKindOf(node) {
  if (!node || node.type !== "CallExpression") return null;
  const c = node.callee;
  let name = null;
  if (c.type === "Identifier") name = c.name;
  else if (c.type === "MemberExpression" && !c.computed && c.property.type === "Identifier") {
    name = c.property.name;
  }
  if (name === "guardStage") return "guardStage";
  if (name === "guardProgress") return "guardProgress";
  // rc.7.13b：统一包装器。这 12 处调用形态各异（Promise.race / 赋值 / 三元 return），
  // 只能原地包一层以保持 promise 形状，故它也是合法的 guard 归属。
  if (name === "__codexGuardWrap") return "guardWrap";
  return null;
}

function analyze(src) {
  const ast = acorn.parse(src, {
    ecmaVersion: "latest", sourceType: "script", allowReturnOutsideFunction: true,
  });

  const deadRanges = [];
  const callsites = [];
  const stack = [];   // 祖先栈

  function visit(node) {
    if (!node || typeof node.type !== "string") return;

    if (node.type === "IfStatement" && isConstFalse(node.test) && node.consequent) {
      deadRanges.push({ start: node.consequent.start, end: node.consequent.end,
                        testStart: node.test.start });
    }

    if (isRunSelectionCall(node)) {
      // 沿祖先链找 guard：必须遍历**全部**祖先，且本节点须在该 guard 的 arguments 子树内。
      // （早期版本一遇到第一个可命名祖先就 break，会停在 onStarted 之类的回调上。）
      let guarded = false, guardKind = null;
      for (let i = stack.length - 1; i >= 0; i--) {
        const anc = stack[i];
        const kind = guardKindOf(anc);
        if (!kind) continue;
        const inArgs = (anc.arguments || []).some(
          (a) => a && node.start >= a.start && node.end <= a.end);
        if (inArgs) { guarded = true; guardKind = kind; break; }
      }
      callsites.push({ start: node.start, end: node.end, guarded: guarded, guardKind: guardKind });
    }

    stack.push(node);
    for (const k in node) {
      if (k === "start" || k === "end" || k === "type" || k === "loc" || k === "range") continue;
      const v = node[k];
      if (Array.isArray(v)) { for (const x of v) if (x && typeof x.type === "string") visit(x); }
      else if (v && typeof v === "object" && typeof v.type === "string") visit(v);
    }
    stack.pop();
  }
  visit(ast);

  const inDead = (pos) => deadRanges.some((r) => pos >= r.start && pos < r.end);
  callsites.forEach((c) => { c.reachable = !inDead(c.start); });
  return { deadRanges, callsites, inDead };
}

module.exports = { analyze, isConstFalse, isRunSelectionCall, guardKindOf };
