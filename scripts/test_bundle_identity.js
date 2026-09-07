"use strict";
/**
 * test_bundle_identity.js —— 「磁盘装了新包 ≠ host 加载了新包」的身份契约门禁
 *
 * 为什么存在：rc.7.0 那次事故里，装机映像 152baa79 的 mtime 比 extension host 的
 * 启动时间**晚 29.2 小时** —— 也就是说 host 从头到尾跑的是旧代码，而 /status 里
 * 没有任何字段能暴露这件事，于是「已部署」被当成了「已生效」。
 *
 * 本门禁的两个层次：
 *   [纯函数层] finalize_bundle_identity.js：命名槽位唯一、归一化指纹正确、finalize 幂等、
 *              槽位缺失/畸形/不唯一一律抛（fail closed）。
 *   [运行时层] 从 **dist 里把真的 __codexComputeBundleIdentity 抠出来**放进 vm 沙箱执行，
 *              用受控文件把它逼进全部 5 个状态。测「真正会随包发出去的那段代码」，
 *              而不是测一份长得像它的复制品 —— 后者只能证明我会写测试。
 *
 * 归一化为什么必要：指纹要盖住整个映像，又要写回映像内部。做法是先把 64 位 hex 槽位
 * 清零再摘要，于是写槽位不改变被摘要的对象，finalize 可以幂等重跑。
 */
const assert = require("node:assert");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const vm = require("node:vm");
const crypto = require("node:crypto");
const FIN = require("./finalize_bundle_identity.js");

const DIST = path.join(__dirname, "..", "dist", "extension.js");
const ZERO64 = "0".repeat(64);
const FN_START = "globalThis.__codexComputeBundleIdentity=function(){";
const FN_END = "globalThis.__codexBundleIdentityStatus=function(){";

let pass = 0; const fails = [];
function t(name, fn) {
  try { fn(); pass++; console.log("  PASS " + name); }
  catch (e) { fails.push(name + " — " + ((e && e.message) || e));
              console.log("  FAIL " + name + "  — " + ((e && e.message) || e)); }
}
const tmp = [];
function tmpFile(tag, content) {
  const p = path.join(os.tmpdir(), "rc713-identity-" + tag + "-" + process.pid + ".js");
  fs.writeFileSync(p, content, "utf8");
  tmp.push(p);
  return p;
}
/** 把 dist 里那段真身份函数抠出来，在沙箱里按给定 __filename / 内存指纹执行 */
function runIdentity(distSrc, filePath, memFingerprint) {
  const i = distSrc.indexOf(FN_START);
  const j = distSrc.indexOf(FN_END);
  assert.ok(i >= 0 && j > i, "dist 里找不到 __codexComputeBundleIdentity（rc.7.13c 没打上？）");
  const sandbox = { require, __filename: filePath, Buffer, process, console };
  vm.createContext(sandbox);
  vm.runInContext(distSrc.slice(i, j), sandbox);
  if (memFingerprint !== undefined) sandbox.__codexGuardBuildFingerprint = memFingerprint;
  return sandbox.__codexComputeBundleIdentity();
}

(function main() {
  console.log("=== rc.7.13c 打包身份契约门禁 ===\n");
  assert.ok(fs.existsSync(DIST), "dist/extension.js 不存在");
  const dist = fs.readFileSync(DIST, "utf8");
  const realFp = FIN.fingerprintOf(dist);

  console.log("[A] 纯函数层：命名槽位与归一化指纹");
  t("A.1 槽位在 dist 中**恰好一个**（前缀由拼接生成，故裸标记名出现两次是合法的）", () => {
    const slot = FIN.locateSlot(dist); // 内部已断言唯一 + 长度 + 闭合引号
    assert.strictEqual(typeof slot.at, "number", "槽位定位失败");
    assert.ok(/^[0-9a-f]{64}$/.test(slot.value), "槽位值不是 64 位小写 hex：" + slot.value.slice(0, 20));
    // 裸标记名会出现两次（一次是槽位本体，一次是运行时拼前缀用的字面量）——不要断言 ==1
    const bare = FIN.SLOT_PREFIX.slice(0, "codex-bundle-fingerprint-slot-v1".length);
    assert.ok(dist.split(bare).length - 1 >= 1, "连裸标记名都找不到");
  });
  t("A.2 归一化 = 槽位清零；指纹 = 归一化映像的 SHA256（自引用无悖论）", () => {
    const norm = FIN.normalize(dist);
    assert.strictEqual(norm.length, dist.length, "归一化改变了长度（不该）");
    const slot = FIN.locateSlot(dist);
    assert.strictEqual(norm.substr(slot.at, 64), ZERO64, "归一化后槽位不是全 0");
    const want = crypto.createHash("sha256").update(Buffer.from(norm, "utf8")).digest("hex");
    assert.strictEqual(FIN.fingerprintOf(dist), want, "指纹算法与「清零后 SHA256」不一致");
  });
  t("A.3 dist 槽位里记录的值 == 重算指纹（verify 通过）", () => {
    const v = FIN.verify(dist);
    assert.strictEqual(v.unfinalized, false, "dist 尚未 finalize");
    assert.strictEqual(v.ok, true, "记录 " + String(v.recorded).slice(0, 16) + " ≠ 重算 " + String(v.expected).slice(0, 16));
  });
  t("A.4 finalize 幂等：对已 finalize 的文本再跑，字节不变、changed=false", () => {
    const again = FIN.finalize(dist);
    assert.strictEqual(again.text, dist, "重复 finalize 改了字节");
    assert.strictEqual(again.changed, false, "changed 应为 false");
    assert.strictEqual(again.fingerprint, realFp, "指纹漂移");
  });
  t("A.5 从全零槽位 finalize 一次即达到不动点（清零→写值→再写值不变）", () => {
    const zeroed = FIN.normalize(dist);
    const once = FIN.finalize(zeroed);
    assert.strictEqual(once.changed, true, "从全零 finalize 竟报 changed=false");
    assert.strictEqual(once.previous, ZERO64, "previous 不是全零");
    assert.strictEqual(once.fingerprint, realFp, "从全零算出的指纹与 dist 不一致（归一化没生效）");
    assert.strictEqual(once.text, dist, "从全零 finalize 的结果与 dist 不逐字节相同");
    assert.strictEqual(FIN.finalize(once.text).text, once.text, "不是不动点");
  });
  console.log("\n[B] 纯函数层负例：槽位缺失 / 不唯一 / 畸形 / 截断 / 未闭合 —— 全部 fail closed");
  t("B.1 槽位**缺失** → 抛 slot not found", () => {
    const broken = dist.replace(FIN.SLOT_PREFIX, "/*SLOT_GONE*/");
    assert.throws(() => FIN.locateSlot(broken), /slot not found/, "缺槽位竟不抛");
  });
  t("B.2 槽位**不唯一** → 抛 not unique（绝不赌第一个）", () => {
    const broken = dist + "\n//" + FIN.SLOT_PREFIX + ZERO64 + '"\n';
    assert.throws(() => FIN.locateSlot(broken), /not unique/, "重复槽位竟不抛");
  });
  t("B.3 槽位**畸形**（含非 hex 字符）→ 抛 malformed", () => {
    const slot = FIN.locateSlot(dist);
    const broken = dist.slice(0, slot.at) + ("Z".repeat(64)) + dist.slice(slot.at + 64);
    assert.throws(() => FIN.locateSlot(broken), /malformed/, "畸形槽位竟不抛");
  });
  t("B.4 槽位**未被引号闭合**（宽度被改）→ 抛 not closed by a quote", () => {
    const slot = FIN.locateSlot(dist);
    // 把 64 位 hex 改成 63 位 + 一个 hex 字符占掉引号位 → 宽度仍能取到 64 但闭合检查失败
    const broken = dist.slice(0, slot.at) + "a".repeat(64) + "b" + dist.slice(slot.at + 65);
    assert.throws(() => FIN.locateSlot(broken), /not closed by a quote/, "未闭合槽位竟不抛");
  });
  t("B.5 verify 对「finalize 后又被改一个字节」必须报不一致", () => {
    const at = dist.indexOf("timeoutMs:30000");
    assert.ok(at > 0, "样本失效：dist 里找不到 timeoutMs:30000");
    const tampered = dist.slice(0, at) + "timeoutMs:30001" + dist.slice(at + 15);
    const v = FIN.verify(tampered);
    assert.strictEqual(v.ok, false, "改了字节 verify 竟仍报 ok");
    assert.notStrictEqual(v.recorded, v.expected, "recorded 与 expected 竟相同");
  });

  console.log("\n[C] 运行时层：把 dist 里真的身份函数逼进全部 5 个状态");
  t("C.1 OK —— 内存指纹 == 磁盘指纹", () => {
    const R = runIdentity(dist, DIST, realFp);
    assert.strictEqual(R.identityState, "OK", "状态不是 OK：" + R.identityState + " / " + R.identityError);
    assert.strictEqual(R.identityError, null, "OK 状态竟带错误信息");
    assert.strictEqual(R.guardBuildFingerprint, realFp, "内存指纹不对");
    assert.strictEqual(R.diskGuardFingerprint, realFp, "磁盘指纹不对");
    assert.strictEqual(R.diskSlotFingerprint, realFp, "磁盘槽位值不对");
    assert.strictEqual(R.diskBundleSha256,
      crypto.createHash("sha256").update(fs.readFileSync(DIST)).digest("hex"), "整文件 sha 不对");
    assert.strictEqual(R.runtimeBundleBytes, fs.statSync(DIST).size, "字节数不对");
    assert.ok(R.extensionHostPid, "缺 host pid（审计要靠它和 host 启动时间对账）");
  });
  t("C.2 STALE_HOST —— host 内存里是旧映像（正是 29.2 小时事故的形态）", () => {
    const stale = "f".repeat(64); // 合法 hex 但与磁盘不符
    const R = runIdentity(dist, DIST, stale);
    assert.strictEqual(R.identityState, "STALE_HOST", "状态不是 STALE_HOST：" + R.identityState);
    assert.strictEqual(R.guardBuildFingerprint, stale, "内存指纹未被沙箱采纳，测试无效");
    assert.strictEqual(R.diskGuardFingerprint, realFp, "磁盘指纹不对");
    assert.ok(/differs from dist/.test(String(R.identityError)), "错误信息未说明内存与磁盘不一致");
  });
  t("C.3 BYTE_IDENTITY_MISMATCH —— 磁盘在 finalize 之后又被改过", () => {
    const at = dist.indexOf("timeoutMs:30000");
    const tampered = dist.slice(0, at) + "timeoutMs:30001" + dist.slice(at + 15);
    const p = tmpFile("tampered", tampered);
    // 内存指纹给「篡改后重算」的值，排除 STALE_HOST 抢先命中，逼出槽位对不上这条
    const R = runIdentity(dist, p, FIN.fingerprintOf(tampered));
    assert.strictEqual(R.identityState, "BYTE_IDENTITY_MISMATCH", "状态不是 BYTE_IDENTITY_MISMATCH：" + R.identityState);
    assert.ok(/mutated after finalization/.test(String(R.identityError)), "错误信息不对：" + R.identityError);
  });
  t("C.4 UNFINALIZED —— 内存槽位仍是全零（从没跑 finalize）", () => {
    const R = runIdentity(dist, DIST, ZERO64);
    assert.strictEqual(R.identityState, "UNFINALIZED", "状态不是 UNFINALIZED：" + R.identityState);
    assert.ok(/never finalized/.test(String(R.identityError)), "错误信息不对：" + R.identityError);
  });
  t("C.5 IDENTITY_UNREADABLE —— __filename 不可用", () => {
    const R = runIdentity(dist, undefined, realFp);
    assert.strictEqual(R.identityState, "IDENTITY_UNREADABLE", "状态不是 IDENTITY_UNREADABLE：" + R.identityState);
    assert.ok(/__filename unavailable/.test(String(R.identityError)), "错误信息不对：" + R.identityError);
  });
  t("C.6 IDENTITY_UNREADABLE —— 文件读不到（路径不存在）", () => {
    const R = runIdentity(dist, path.join(os.tmpdir(), "rc713-does-not-exist-" + process.pid + ".js"), realFp);
    assert.strictEqual(R.identityState, "IDENTITY_UNREADABLE", "状态不是 IDENTITY_UNREADABLE：" + R.identityState);
    assert.ok(R.identityError, "缺错误信息");
  });
  t("C.7 内存指纹**畸形** → IDENTITY_UNREADABLE，不当成 OK 混过去", () => {
    const R = runIdentity(dist, DIST, "not-a-fingerprint");
    assert.strictEqual(R.identityState, "IDENTITY_UNREADABLE", "状态不是 IDENTITY_UNREADABLE：" + R.identityState);
    assert.ok(/in-memory fingerprint/.test(String(R.identityError)), "错误信息不对：" + R.identityError);
  });
  t("C.8 磁盘槽位缺失/不唯一 → BYTE_IDENTITY_MISMATCH（不静默降级成 OK）", () => {
    const p = tmpFile("noslot", dist.replace(FIN.SLOT_PREFIX, "/*SLOT_GONE*/"));
    const R = runIdentity(dist, p, realFp);
    assert.strictEqual(R.identityState, "BYTE_IDENTITY_MISMATCH", "状态不是 BYTE_IDENTITY_MISMATCH：" + R.identityState);
    assert.ok(/missing or not unique/.test(String(R.identityError)), "错误信息不对：" + R.identityError);
  });
  t("C.9 五个状态互斥且已全部覆盖（OK/STALE_HOST/BYTE_IDENTITY_MISMATCH/UNFINALIZED/IDENTITY_UNREADABLE）", () => {
    const seen = new Set([
      runIdentity(dist, DIST, realFp).identityState,
      runIdentity(dist, DIST, "f".repeat(64)).identityState,
      runIdentity(dist, tmpFile("t2", dist.replace(FIN.SLOT_PREFIX, "/*X*/")), realFp).identityState,
      runIdentity(dist, DIST, ZERO64).identityState,
      runIdentity(dist, undefined, realFp).identityState,
    ]);
    assert.deepStrictEqual([...seen].sort(),
      ["BYTE_IDENTITY_MISMATCH", "IDENTITY_UNREADABLE", "OK", "STALE_HOST", "UNFINALIZED"],
      "状态覆盖不全：" + [...seen].join(","));
  });

  console.log("\n[D] /status 契约");
  t("D.1 dist 里 /status 会带上身份字段（__codexBundleIdentityStatus 已接入）", () => {
    assert.ok(dist.includes("globalThis.__codexBundleIdentityStatus"), "缺 __codexBundleIdentityStatus 定义");
    assert.ok(dist.includes("...(globalThis.__codexBundleIdentityStatus?globalThis.__codexBundleIdentityStatus():{})"),
      "/status 构造处没有展开身份字段（装了也看不见＝等于没装）");
  });
  t("D.2 身份结果只算一次并缓存在 __codexBundleIdentity（不给每次 /status 读 5.5MB）", () => {
    assert.ok(dist.includes("globalThis.__codexBundleIdentity||(globalThis.__codexBundleIdentity=globalThis.__codexComputeBundleIdentity())"),
      "缺缓存写法");
  });

  for (const p of tmp) { try { fs.rmSync(p, { force: true }); } catch { /* 清理失败不影响判定 */ } }

  console.log("\n" + "=".repeat(58));
  console.log("  PASS=" + pass + "  FAIL=" + fails.length);
  if (fails.length) { fails.forEach((f) => console.log("   - " + f)); process.exit(1); }
  console.log("  BUNDLE_IDENTITY_CONTRACT_OK");
})();
