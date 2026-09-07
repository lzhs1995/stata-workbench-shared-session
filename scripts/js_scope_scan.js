"use strict";
/**
 * ⚠️ 已废弃为「历史反证」——权威判据是 scripts/ast_reachability_gate.js（acorn 真 AST）。
 *
 * 本文件被 codex 实证击穿：`return /}/` 与 `typeof /}/` 中的正则被误判为除号，
 * 导致死分支提前收尾 → 不可达调用被误报为**可达**（假可达）。
 * 根因是 regexAllowedAfter() 只看前一个字符，而 `return`/`typeof` 结尾都是标识符字符。
 * 结论：可达性是**语法**问题，不是词法问题；补词法规则等于重写解析器。
 * 保留原因：其测试用例作为 AST 门禁的反证样本（ast_reachability_gate.test.js A 节）。
 */
/**
 * js_scope_scan.js —— 极小的**括号配平作用域扫描器**（C5.1-3）
 *
 * 用途：在 5.5MB minified 的 dist/extension.js 里精确求出「常量假分支」`if(false && …)`
 * 的**真实语句范围**，替代此前 4000 字节固定窗口的近似（codex 指出：代码长度或相邻
 * 调用变化即可误分类）。
 *
 * 为什么不用 acorn/AST：
 *   · acorn / acorn-walk **本机未安装**、也没有任何依赖间接带入；新增 devDependency 会改动
 *     打包清单，须重过四方 SHA 门禁，且解析 5.5MB minified 代价高。
 *   · 已有 devDep 里的 esbuild **不暴露 JS AST**，无法直接做节点级判定。
 *   · 本门禁只需回答「某偏移是否落在某个 if(false…) 的 consequent 内」——这是纯粹的
 *     词法配平问题，不需要完整语法树。故实现一个**正确处理字符串/模板/注释/正则**的
 *     配平扫描器即可，零新依赖、可单测、确定性。
 *
 * 已覆盖的坑（minified 代码里真会出现）：
 *   · 单/双引号与模板串（含 ${} 嵌套）、转义
 *   · 行注释 // 与块注释 /* *\/
 *   · 正则字面量 /…/flags（靠前一个有意义字符判别除号 vs 正则起始）
 *   · consequent 是 block `{…}`、也可能是单语句（如 `if(false&&x)try{…}catch{}`）
 *
 * 导出：
 *   findConstFalseBranches(src) → [{condStart, bodyStart, bodyEnd}]  // bodyEnd 独占
 *   inAnyRange(ranges, pos)     → boolean
 */

/** 判断 `/` 在此位置是除法还是正则开头：看前一个有意义字符 */
function regexAllowedAfter(prevChar) {
  if (prevChar == null) return true;
  return !/[A-Za-z0-9_$)\].]/.test(prevChar);
}

/**
 * 从 from 起做词法扫描，遇到 depth 归零的收尾就停。
 * 返回 {end}（独占）。mode:
 *   "parens" —— 期望起点是 '('，配平到对应 ')'
 *   "block"  —— 期望起点是 '{'，配平到对应 '}'
 *   "stmt"   —— 单语句：在深度 0 处遇 ';' 结束；但要跨过成对的 {} () []
 *               且允许 try{}catch{}finally{} 这类连续块（遇 '}' 后若紧跟
 *               catch/finally/else 则继续）
 */
function scanBalanced(src, from, mode) {
  let i = from;
  const n = src.length;
  let depthParen = 0, depthBrace = 0, depthBracket = 0;
  let prevMeaning = null;                 // 上一个有意义字符（跳过空白/注释）
  let started = false;
  // 模板串栈：进入 ${} 时压入，回到模板文本时弹出
  const tmplStack = [];

  const atDepthZero = () => depthParen === 0 && depthBrace === 0 && depthBracket === 0;

  while (i < n) {
    const c = src[i];

    // --- 注释 ---
    if (c === "/" && src[i + 1] === "/") {
      const nl = src.indexOf("\n", i);
      i = nl < 0 ? n : nl + 1;
      continue;
    }
    if (c === "/" && src[i + 1] === "*") {
      const close = src.indexOf("*/", i + 2);
      i = close < 0 ? n : close + 2;
      continue;
    }
    // --- 正则字面量 ---
    if (c === "/" && regexAllowedAfter(prevMeaning)) {
      let j = i + 1, inClass = false, closed = false;
      while (j < n) {
        const d = src[j];
        if (d === "\\") { j += 2; continue; }
        if (d === "\n") break;                 // 未闭合 → 当作除号
        if (inClass) { if (d === "]") inClass = false; }
        else if (d === "[") inClass = true;
        else if (d === "/") { closed = true; j++; break; }
        j++;
      }
      if (closed) {
        while (j < n && /[a-z]/i.test(src[j])) j++;   // flags
        i = j; prevMeaning = "/"; continue;
      }
      // 未闭合 → 落到普通字符处理
    }
    // --- 字符串 ---
    if (c === '"' || c === "'") {
      const q = c; let j = i + 1;
      while (j < n) {
        if (src[j] === "\\") { j += 2; continue; }
        if (src[j] === q) { j++; break; }
        if (src[j] === "\n") { j++; break; }   // 容错
        j++;
      }
      i = j; prevMeaning = q; continue;
    }
    // --- 模板串 ---
    if (c === "`") {
      let j = i + 1;
      while (j < n) {
        if (src[j] === "\\") { j += 2; continue; }
        if (src[j] === "`") { j++; break; }
        if (src[j] === "$" && src[j + 1] === "{") {
          // 进入表达式：递归配平到匹配的 }
          const r = scanBalanced(src, j + 1, "block");
          j = r.end; continue;
        }
        j++;
      }
      i = j; prevMeaning = "`"; continue;
    }

    // --- 结构字符 ---
    if (c === "(") { depthParen++; started = true; }
    else if (c === ")") {
      depthParen--;
      if (mode === "parens" && depthParen === 0) return { end: i + 1 };
    }
    else if (c === "{") { depthBrace++; started = true; }
    else if (c === "}") {
      depthBrace--;
      if (mode === "block" && depthBrace === 0) return { end: i + 1 };
      if (mode === "stmt" && atDepthZero() && started) {
        // try{}catch{}/finally、if{}else 需要继续
        let k = i + 1;
        while (k < n && /\s/.test(src[k])) k++;
        if (/^(catch|finally|else)\b/.test(src.slice(k, k + 8))) { i = k; continue; }
        return { end: i + 1 };
      }
    }
    else if (c === "[") { depthBracket++; started = true; }
    else if (c === "]") { depthBracket--; }
    else if (c === ";" && mode === "stmt" && atDepthZero()) {
      return { end: i + 1 };
    }

    if (!/\s/.test(c)) prevMeaning = c;
    i++;
  }
  return { end: n };
}

/**
 * 找出所有 `if(false&&…)` / `if(false)` / `if(!1&&…)` 常量假分支的 consequent 范围。
 * 返回 [{condStart, bodyStart, bodyEnd}]，bodyEnd 独占。
 */
function findConstFalseBranches(src) {
  const out = [];
  // 允许 if 与 ( 之间有空白；条件以 false / !1 起头
  const re = /\bif\s*\(\s*(?:false|!1)\b/g;
  let m;
  while ((m = re.exec(src)) !== null) {
    // 从 'if' 后的 '(' 开始配平条件
    const lp = src.indexOf("(", m.index);
    if (lp < 0) continue;
    const cond = scanBalanced(src, lp, "parens");
    let b = cond.end;
    while (b < src.length && /\s/.test(src[b])) b++;
    let body;
    if (src[b] === "{") body = scanBalanced(src, b, "block");
    else body = scanBalanced(src, b, "stmt");
    out.push({ condStart: m.index, bodyStart: b, bodyEnd: body.end });
  }
  return out;
}

function inAnyRange(ranges, pos) {
  return ranges.some((r) => pos >= r.bodyStart && pos < r.bodyEnd);
}

module.exports = { findConstFalseBranches, inAnyRange, scanBalanced };
