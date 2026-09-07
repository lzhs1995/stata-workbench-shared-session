"use strict";
/**
 * checkpoint_global_export_rc715.js —— rc.7.15：StopCheckpoint 模块引用全局化（唯一权威实现）
 *
 * 解决的真问题（rc.7.14 真机血证 + acorn 铁证）：
 *   `__codexStopCheckpoint` 是 BlockStatement 内的词法 `let`（let@5229112 ∈
 *   BlockStatement@5228541-5309154 ∈ FunctionDeclaration@5227763-5317601），
 *   且**零 globalThis 导出**。8 个消费点里有 2 个在该函数之外：
 *     · @5369791 human-file pre-run enrich → 「内存里有数据集」的 Run File 必 500
 *       （SYNC_THREW / elapsedMs=0），随后桥卡 postRunBusy=True/draining，
 *       /soft-stop 返回 409
 *     · @5391352 human-file 完成清理 → 抛错被 try{}catch{} 吞掉，快照静默泄漏
 *   这同时是 Phase 2C C4 无法取证的原因：唯一能给 soft-stop registry 装快照的
 *   授权路径被这个 ReferenceError 打死（site @5257441 自身在作用域内，故一直健康）。
 *
 * 修法（与 rc.7.14 完全同构，均为**结构化**改写，不依赖任何硬编码字符偏移）：
 *   1. 在 require 成功那一刻链式赋全局，并顺带捕获**实际传入的路径**：
 *        __codexStopCheckpoint=(globalThis.__codexStopCheckpointRef=
 *          require(globalThis.__codexStopCheckpointPath=rg.join(...)))
 *      require 抛错 → 全局不被设置 → **fail closed**。
 *   2. 把**全部**裸消费点改写成 `globalThis.__codexStopCheckpointRef`，
 *      唯一例外是 declarator 声明点自身（否则没有词法绑定可言）。
 *
 * 为什么全部改写而不只改越界的 2 处：与 rc.7.14 同理 —— in/out 是随 minifier
 *   布局漂移的属性，混用两种形态早晚再爆一次；统一后闸门不变式极简且无特例：
 *   「除声明点外，不得存在裸 __codexStopCheckpoint 引用」。
 *
 * 顺序约束（硬，两条）：
 *   a) 必须在 rc.7.11.1 补丁块**之后**执行 —— 该块用裸 require 串
 *      '__codexStopCheckpoint=require(...\"stop_checkpoint_core.js\")),' 当锚点，
 *      先全局化会把它的锚点改没。
 *   b) 必须在 guard_wiring_rc713.apply() **之前**执行 —— wiring 对已接线点做
 *      逐字节重建比对，POLICY_TABLE ord6/ord11 的 anchor 已指向全局化形态。
 *   放在既有 rc.7.14 全局化块相邻位置同时满足 a 与 b。
 *
 * 幂等 / 双路径收敛：改写规则是**最终文本的属性**（"除声明点外无裸引用"），
 *   与历史无关，故基线重放与 rc.7.14 迁移两条路径落到同一批字节；
 *   再跑一次本模块无任何可改之处 → 逐字节幂等。
 */
const SCOPE = require("./checkpoint_scope_gate.js");
const RC714 = require("./guard_global_export_rc714.js");

/**
 * 复用 rc.7.14 的路径表达式：同一 minified 形态，避免两处各写一份而漂移。
 * （rg 是 minified 的 path 模块别名；yC 是 extension context）
 */
const PATH_EXPR = RC714.PATH_EXPR;

/** 受管规格：与 checkpoint_scope_gate.MODULES 单一来源对齐 */
const SPEC = {
  lexical: "__codexStopCheckpoint",
  globalRef: SCOPE.MODULES.__codexStopCheckpoint.globalRef,
  globalPath: SCOPE.MODULES.__codexStopCheckpoint.globalPath,
  moduleFile: SCOPE.MODULES.__codexStopCheckpoint.moduleFile,
};

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
function injectExport(text) {
  const to = requireTo(SPEC);
  if (text.includes(to)) return { text: text, action: "already" };
  const from = requireFrom(SPEC);
  const n = countOf(text, from);
  if (n !== 1) {
    throw new Error(
      "rc.7.15 require anchor for " + SPEC.lexical + " must be unique, found " + n
    );
  }
  return { text: text.replace(from, to), action: "injected" };
}

/**
 * 第 2 步：结构化改写全部裸消费点（降序改写，偏移不漂移）。
 * @returns {{text:string, rewritten:Array}}
 */
function rewriteBareRefs(text) {
  const model = SCOPE.analyze(text);

  // 导出点必须恰好一次，否则改写会指向不存在/歧义的全局 → 直接抛错
  const hits = model.exports.get(SPEC.globalRef) || [];
  if (hits.length !== 1) {
    throw new Error(
      "rc.7.15 global export " + SPEC.globalRef + " must appear exactly once, found " + hits.length
    );
  }

  const targets = [];
  for (const ref of model.bareRefs) {
    const c = SCOPE.classifyBareRef(ref, model);
    if (c.allow === "declarator") continue;
    targets.push({ name: ref.name, start: ref.start, resolvable: c.resolvable });
  }

  let out = text;
  const rewritten = [];
  for (const ref of targets.slice().sort((a, b) => b.start - a.start)) {
    const end = ref.start + ref.name.length;
    if (out.slice(ref.start, end) !== ref.name) {
      throw new Error("rc.7.15 identifier slice mismatch at " + ref.start + " for " + ref.name);
    }
    out = out.slice(0, ref.start) + "globalThis." + SPEC.globalRef + out.slice(end);
    rewritten.push({ name: ref.name, start: ref.start, wasResolvable: ref.resolvable });
  }
  return { text: out, rewritten: rewritten };
}

/**
 * 全量应用（导出 + 改写），并自检最终文本不再含裸消费点。
 * @param {string} text bundle 文本
 * @returns {{text:string, report:object}}
 */
function apply(text) {
  if (typeof text !== "string") throw new Error("rc.7.15 apply() expects a string");

  const step1 = injectExport(text);
  const step2 = rewriteBareRefs(step1.text);
  const out = step2.text;

  // 自检：最终态必须过闸门（导出恰一次 + 零裸消费点 + 零越界）
  const verify = SCOPE.report(out);
  if (!verify.ok) {
    throw new Error(
      "rc.7.15 post-rewrite gate failed: " + verify.problems.slice(0, 4).join(" | ")
    );
  }

  return {
    text: out,
    report: {
      exportAction: step1.action,
      rewritten: step2.rewritten.length,
      rewrittenWasResolvable: step2.rewritten.filter((r) => r.wasResolvable).length,
      rewrittenWasOutOfScope: step2.rewritten.filter((r) => !r.wasResolvable).length,
    },
  };
}

module.exports = {
  SPEC,
  PATH_EXPR,
  requireFrom,
  requireTo,
  injectExport,
  rewriteBareRefs,
  apply,
};
