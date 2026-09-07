"use strict";
/**
 * wire_rc713b_remaining.js —— rc.7.13b 的**兼容 CLI 外壳**（已无自有逻辑）
 *
 * 历史：本脚本原来自带一整套接线实现，问题有两条致命的：
 *   1. policy 来自生成物 manifest（runselection_callsite_manifest_v5_*.json），
 *      用「上下文模糊匹配」回查，查不到就**静默回落 SHORT_INTERNAL** —— 一个
 *      PROGRESS 长任务被当 30s 固定超时守，等于把 guard 装反。
 *   2. 依赖 manifest 里记录的 charOffset，bundle 一重建就全部失效。
 *
 * rc.7.13 起，唯一权威实现是纯函数模块 scripts/guard_wiring_rc713.js：
 * 声明式 policy 表 + 基线派生长锚点 + AST 序号交叉校验，任何漂移都抛错。
 * 本文件只保留命令行入口，避免既有文档/脚本里的调用路径断掉；
 * **禁止**在这里重新长出第二套接线逻辑。
 *
 * 正常构建请走 `node scripts/apply_rc7_shared_execution_patch.js`
 * （它会在写盘前调用同一个纯函数模块），随后 `node scripts/finalize_bundle_identity.js`。
 *
 * 用法：
 *   node scripts/wire_rc713b_remaining.js               # 就地接线 dist/extension.js
 *   node scripts/wire_rc713b_remaining.js --file <path> # 指定文件
 *   node scripts/wire_rc713b_remaining.js --check       # 只校验覆盖，不写盘
 */
const fs = require("fs");
const path = require("path");
const guardWiring = require("./guard_wiring_rc713.js");

function main(argv) {
  const args = argv.slice(2);
  const checkOnly = args.indexOf("--check") >= 0;
  const fileIdx = args.indexOf("--file");
  const target =
    fileIdx >= 0 && args[fileIdx + 1]
      ? path.resolve(args[fileIdx + 1])
      : path.join(__dirname, "..", "dist", "extension.js");

  const before = fs.readFileSync(target, "utf8");
  const result = guardWiring.apply(before);
  const r = result.report;
  const changed = result.text !== before;

  if (checkOnly) {
    if (changed) {
      console.error(
        "RC713B_CHECK_FAILED " + target + "\n  " + r.wrapped.length + " callsite(s) are still unguarded"
      );
      process.exitCode = 1;
      return;
    }
    console.log(
      "RC713B_CHECK_OK  verifiedWrapped=" + r.verifiedWrapped.length +
        " verifiedCore=" + r.verifiedCore.length +
        " retired=" + r.retired.length
    );
    return;
  }

  if (changed) fs.writeFileSync(target, result.text, "utf8");
  console.log(
    (changed ? "RC713B_APPLIED " : "RC713B_ALREADY_APPLIED ") + target +
      "\n  wrapped=" + r.wrapped.length +
      " verifiedWrapped=" + r.verifiedWrapped.length +
      " verifiedCore=" + r.verifiedCore.length +
      " retired=" + r.retired.length +
      " total=" + r.totalCallsites
  );
  for (const w of r.wrapped) console.log("  wrapped  #" + w.ord + " " + w.id + "  " + w.policy);
  if (changed) {
    console.log("  NOTE: bundle identity fingerprint is now stale — run scripts/finalize_bundle_identity.js");
  }
}

if (require.main === module) main(process.argv);

module.exports = { main };
