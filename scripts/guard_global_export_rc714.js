"use strict";
/**
 * guard_global_export_rc714.js —— rc.7.14：guard 模块引用全局化（唯一权威实现）
 *
 * 解决的真问题（rc.7.13 真机血证）：
 *   `__codexExecGuard` / `__codexPreRunGuard` 是 activate() 内的词法 `let` 绑定，
 *   而 17 个被 guard 的调用点有 10 个在该函数之外 → 裸标识符抛
 *   `ReferenceError: __codexExecGuard is not defined`，guard 一行未跑。
 *
 * 修法（两步，均为**结构化**改写，不依赖任何硬编码字符偏移）：
 *   1. 在 require 成功的那一刻，把模块对象链式赋给唯一命名的全局：
 *        __codexPreRunGuard=(globalThis.__codexPreRunGuardRef=require(globalThis.__codexPreRunGuardPath=rg.join(...)))
 *      · require 抛错时全局不会被设置 → **fail closed**
 *      · 顺带把「真正传给 require 的路径」也存成全局，供 /status 模块身份摘要精确读取
 *        （不再二次推导路径，避免"算出来的路径"与"实际加载的文件"不一致）
 *   2. 把所有裸 guard 引用改写成 `globalThis.<X>Ref`，**唯一例外**两类：
 *        · declarator 声明点自身（必须保留，否则没有词法绑定可言）
 *        · `__codexGuardWrap` 包装器体内的引用（其安装点经 AST 证实位于声明作用域内，
 *          词法可解析；任务包要求包装器闭包语义保持不变，故原样保留）
 *
 * 为什么「全部」改写而不是只改越界的 10 处：
 *   · 任务包要求 17 个活跃调用点用**同一种**生成表示；
 *   · 混用两种表示会让 guard_wiring 的逐字节重建比对必须区分 in/out，
 *     而 in/out 是随 minifier 布局变化的属性 → 早晚再爆一次；
 *   · 统一后闸门不变式极简且无特例：「除声明点与包装器外，不得存在裸 guard 引用」。
 *
 * 幂等性与双路径收敛（这是本模块最关键的性质）：
 *   改写规则是**最终文本的属性**（"不存在越界裸引用"），与历史无关，故：
 *     · baseline 重放：此时 12 个 wrap 点尚未包装，只有 core 引用被改写；
 *       随后 guard_wiring 用已更新的 POLICY_EXPR 直接生成全局形态。
 *     · rc.7.13 迁移：wrap 点已存在且为裸形态，在此被改写为全局形态；
 *       随后 guard_wiring 的逐字节比对通过。
 *   两条路径落到**同一批字节**。再跑一次本模块无任何可改之处 → 逐字节幂等。
 *
 * 顺序约束（硬）：必须在 guard_wiring_rc713.apply() **之前**调用。
 *   否则 rc.7.13 迁移路径上，wiring 会用全局形态的 POLICY_EXPR 去比对裸形态的既有字节而报错。
 */
const SCOPE = require("./guard_scope_gate.js");

/** 词法名 → 全局引用名 / 全局路径名 */
const EXPORT_SPECS = [
  {
    lexical: "__codexPreRunGuard",
    globalRef: "__codexPreRunGuardRef",
    globalPath: "__codexPreRunGuardPath",
    moduleFile: "prerun_stage_guard.js",
  },
  {
    lexical: "__codexExecGuard",
    globalRef: "__codexExecGuardRef",
    globalPath: "__codexExecGuardPath",
    moduleFile: "execution_guard.js",
  },
];

/** require 表达式的路径实参（与 dist 中逐字节一致；rg 是 minified 的 path 模块别名） */
const PATH_EXPR = 'rg.join(((yC&&yC.extensionUri&&yC.extensionUri.fsPath)||process.cwd()),"scripts",';

function requireFrom(spec) {
  return spec.lexical + "=require(" + PATH_EXPR + JSON.stringify(spec.moduleFile) + "))";
}
function requireTo(spec) {
  return (
    spec.lexical +
    "=(globalThis." +
    spec.globalRef +
    "=require(globalThis." +
    spec.globalPath +
    "=" +
    PATH_EXPR +
    JSON.stringify(spec.moduleFile) +
    ")))"
  );
}

function countOf(text, needle) {
  return text.split(needle).length - 1;
}

/**
 * 第 1 步：把 require 初始化器改成链式赋全局。
 * 已改写过则原样返回（幂等）。缺锚点/锚点不唯一 → 抛错（fail closed，绝不静默跳过）。
 */
function injectExports(text) {
  let out = text;
  const injected = [];
  for (const spec of EXPORT_SPECS) {
    const to = requireTo(spec);
    if (out.includes(to)) {
      injected.push({ lexical: spec.lexical, globalRef: spec.globalRef, action: "already" });
      continue;
    }
    const from = requireFrom(spec);
    const n = countOf(out, from);
    if (n !== 1) {
      throw new Error(
        "rc.7.14 require anchor for " + spec.lexical + " must be unique, found " + n
      );
    }
    out = out.replace(from, to);
    injected.push({ lexical: spec.lexical, globalRef: spec.globalRef, action: "injected" });
  }
  return { text: out, injected };
}

/**
 * 第 2 步：结构化改写所有裸 guard 引用（降序改写，偏移不漂移）。
 * @returns {{text:string, rewritten:Array, kept:Array}}
 */
function rewriteBareRefs(text) {
  const model = SCOPE.analyze(text);

  // 导出点必须恰好各一次；否则后续改写会指向不存在/歧义的全局 → 直接抛错
  for (const spec of EXPORT_SPECS) {
    const hits = model.exports.get(spec.globalRef) || [];
    if (hits.length !== 1) {
      throw new Error(
        "rc.7.14 global export " + spec.globalRef + " must appear exactly once, found " + hits.length
      );
    }
  }

  const targets = [];
  const kept = [];
  for (const ref of model.bareRefs) {
    const { resolvable, allow } = SCOPE.classifyBareRef(ref, model);
    if (allow) {
      kept.push({ name: ref.name, start: ref.start, reason: allow });
      continue;
    }
    targets.push({ ...ref, resolvable });
  }

  let out = text;
  const rewritten = [];
  for (const ref of targets.slice().sort((a, b) => b.start - a.start)) {
    const globalRef = SCOPE.GUARDS[ref.name];
    const end = ref.start + ref.name.length;
    if (out.slice(ref.start, end) !== ref.name) {
      throw new Error("rc.7.14 identifier slice mismatch at " + ref.start + " for " + ref.name);
    }
    out = out.slice(0, ref.start) + "globalThis." + globalRef + out.slice(end);
    rewritten.push({ name: ref.name, start: ref.start, wasResolvable: ref.resolvable });
  }
  return { text: out, rewritten, kept };
}

/**
 * 全量应用（导出 + 改写），并自检最终文本不再含越界裸引用。
 * @param {string} text bundle 文本
 * @returns {{text:string, report:object}}
 */
function apply(text) {
  if (typeof text !== "string") throw new Error("rc.7.14 apply() expects a string");

  const step1 = injectExports(text);
  const step2 = rewriteBareRefs(step1.text);
  let out = step2.text;

  // 自检：最终态不得存在"既非声明点也非包装器"的裸引用
  const verify = SCOPE.analyze(out);
  const violations = [];
  for (const ref of verify.bareRefs) {
    const { allow } = SCOPE.classifyBareRef(ref, verify);
    if (!allow) violations.push({ name: ref.name, start: ref.start });
  }
  if (violations.length) {
    throw new Error(
      "rc.7.14 post-rewrite still has " + violations.length + " bare guard refs: " +
        violations.map((v) => v.name + "@" + v.start).join(",")
    );
  }

  return {
    text: out,
    report: {
      injected: step1.injected,
      rewritten: step2.rewritten.length,
      rewrittenWasResolvable: step2.rewritten.filter((r) => r.wasResolvable).length,
      rewrittenWasOutOfScope: step2.rewritten.filter((r) => !r.wasResolvable).length,
      kept: step2.kept,
    },
  };
}

module.exports = {
  EXPORT_SPECS,
  PATH_EXPR,
  requireFrom,
  requireTo,
  injectExports,
  rewriteBareRefs,
  apply,
};
