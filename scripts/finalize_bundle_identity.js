"use strict";
/**
 * finalize_bundle_identity.js —— rc.7.13：bundle 身份指纹 finalizer（**必须最后跑**）
 *
 * 解决的是一个自引用悖论：想把「这个文件的 SHA」写进这个文件本身是不可能的——
 * 写入常数就改变了产生该 SHA 的字节。
 *
 * 归一化固定槽位法（与「签名字段不参与自身摘要」同构）：
 *   1. 在映像里定位**恰好一个**命名固定宽度槽位（64 位 hex）。
 *   2. 把槽位清零得到**归一化映像**。
 *   3. 指纹 = SHA256(归一化映像)。
 *   4. 把指纹写回槽位。
 * 重跑时第 1-3 步得到完全相同的归一化映像 → 相同指纹 → 输出逐字节不变（幂等）。
 *
 * 这里算出的 guardBuildFingerprint 是**内存侧**身份：它被编进映像，运行时从已加载的
 * 字面量读出。运行时另有一路在 activation 时读磁盘重算同一个归一化指纹
 * （diskGuardFingerprint）+ 整文件 SHA256（diskBundleSha256）。两轴独立，
 * 因此「装了新包但 host 还跑旧映像」会被 /status 判成 STALE_HOST 而不是静静通过。
 *
 * 用法：
 *   node scripts/finalize_bundle_identity.js                    # 就地 finalize dist/extension.js
 *   node scripts/finalize_bundle_identity.js --file <path>      # 指定文件
 *   node scripts/finalize_bundle_identity.js --check            # 只校验，不写入（非零退出=不合规）
 */
const fs = require("fs");
const path = require("path");
const crypto = require("crypto");

/** 槽位前缀。注意逐段拼接：若写成完整字面量，本脚本被打进任何 bundle 时会造出第二个匹配。 */
const SLOT_PREFIX = "codex-bundle-fingerprint-slot-v1 *" + '/globalThis.__codexGuardBuildFingerprint="';
const SLOT_WIDTH = 64;
const ZERO_SLOT = "0".repeat(SLOT_WIDTH);
const HEX64 = /^[0-9a-f]{64}$/;

/** 定位唯一槽位；缺失或非唯一都抛（fail closed，绝不猜） */
function locateSlot(src) {
  const first = src.indexOf(SLOT_PREFIX);
  if (first < 0) throw new Error("bundle identity slot not found (run apply_rc7_shared_execution_patch.js first)");
  const second = src.indexOf(SLOT_PREFIX, first + SLOT_PREFIX.length);
  if (second >= 0) throw new Error("bundle identity slot is not unique (found at least 2 occurrences)");
  const at = first + SLOT_PREFIX.length;
  const value = src.substr(at, SLOT_WIDTH);
  if (value.length !== SLOT_WIDTH) throw new Error("bundle identity slot is truncated");
  if (!HEX64.test(value)) {
    throw new Error("bundle identity slot is malformed (expected 64 lowercase hex, got " + JSON.stringify(value) + ")");
  }
  if (src.charAt(at + SLOT_WIDTH) !== '"') throw new Error("bundle identity slot is not closed by a quote");
  return { at, value };
}

/** 归一化映像 = 把槽位清零之后的完整文本 */
function normalize(src) {
  const slot = locateSlot(src);
  return src.slice(0, slot.at) + ZERO_SLOT + src.slice(slot.at + SLOT_WIDTH);
}

/** 归一化指纹（内存侧与磁盘侧共用同一算法） */
function fingerprintOf(src) {
  return crypto.createHash("sha256").update(Buffer.from(normalize(src), "utf8")).digest("hex");
}

/** 把指纹写回槽位（纯函数：吃文本吐文本） */
function finalize(src) {
  const slot = locateSlot(src);
  const fingerprint = fingerprintOf(src);
  const out = src.slice(0, slot.at) + fingerprint + src.slice(slot.at + SLOT_WIDTH);
  return { text: out, fingerprint, previous: slot.value, changed: out !== src };
}

/** 校验：槽位值必须等于重算的归一化指纹 */
function verify(src) {
  const slot = locateSlot(src);
  const expected = fingerprintOf(src);
  return {
    ok: slot.value === expected,
    recorded: slot.value,
    expected,
    unfinalized: slot.value === ZERO_SLOT,
  };
}

function main(argv) {
  const args = argv.slice(2);
  const checkOnly = args.indexOf("--check") >= 0;
  const fileIdx = args.indexOf("--file");
  const target =
    fileIdx >= 0 && args[fileIdx + 1]
      ? path.resolve(args[fileIdx + 1])
      : path.join(__dirname, "..", "dist", "extension.js");

  const buf = fs.readFileSync(target);
  const src = buf.toString("utf8");

  if (checkOnly) {
    const v = verify(src);
    const sha = crypto.createHash("sha256").update(buf).digest("hex");
    if (!v.ok) {
      console.error(
        "BUNDLE_IDENTITY_CHECK_FAILED " +
          target +
          "\n  recorded=" +
          v.recorded +
          "\n  expected=" +
          v.expected +
          (v.unfinalized ? "\n  reason=slot is still all-zero (never finalized)" : "\n  reason=bundle mutated after finalization")
      );
      process.exitCode = 1;
      return;
    }
    console.log("BUNDLE_IDENTITY_OK fingerprint=" + v.recorded + " diskBundleSha256=" + sha);
    return;
  }

  const r = finalize(src);
  if (r.changed) fs.writeFileSync(target, r.text, "utf8");
  const after = fs.readFileSync(target);
  const v = verify(after.toString("utf8"));
  if (!v.ok) throw new Error("finalizer wrote a bundle that fails its own verification");
  console.log(
    (r.changed ? "BUNDLE_IDENTITY_FINALIZED " : "BUNDLE_IDENTITY_ALREADY_FINAL ") +
      target +
      "\n  guardBuildFingerprint=" +
      r.fingerprint +
      "\n  previousSlot=" +
      r.previous +
      "\n  diskBundleSha256=" +
      crypto.createHash("sha256").update(after).digest("hex") +
      "\n  bytes=" +
      after.length
  );
}

module.exports = {
  SLOT_PREFIX,
  SLOT_WIDTH,
  ZERO_SLOT,
  locateSlot,
  normalize,
  fingerprintOf,
  finalize,
  verify,
};

if (require.main === module) main(process.argv);
