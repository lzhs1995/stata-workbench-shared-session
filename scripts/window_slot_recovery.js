"use strict";

// Slot recovery is a boot-bound namespace change, never a process cleanup.
// Core acquire/release and explicit recovery MUST share withSlotMutationLock.
// A prior receipt is archived byte-for-byte; same-boot uncertainty is retained.
const fs = require("node:fs");
const path = require("node:path");
const crypto = require("node:crypto");
const cp = require("node:child_process");

function fail(code, detail) { throw Object.assign(new Error(`${code}: ${detail}`), { code }); }
const sha = value => crypto.createHash("sha256").update(value).digest("hex");
function identity(stat) {
  if (typeof stat.dev !== "bigint" || typeof stat.ino !== "bigint")
    fail("SLOT_IDENTITY_UNKNOWN", "exact filesystem identity is unavailable");
  // JSON proofs must retain every bit; converting a rounded Number is too late.
  return { dev: stat.dev.toString(), ino: stat.ino.toString() };
}
const same = (a, b) => !!a && !!b && a.dev === b.dev && a.ino === b.ino;

function validateBootIdentity(value) {
  if (!value || typeof value.id !== "string") fail("BOOT_IDENTITY_UNKNOWN", "boot identity is missing");
  if (value.platform === "darwin" && /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(value.id))
    return { platform: "darwin", id: value.id.toLowerCase() };
  if (value.platform === "win32" && /^\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d\.\d{3}Z$/.test(value.id)
    && Number.isFinite(Date.parse(value.id)) && new Date(value.id).toISOString() === value.id)
    return { platform: "win32", id: value.id };
  fail("BOOT_IDENTITY_UNKNOWN", "unsupported or malformed boot identity");
}

function readBootIdentity(options = {}) {
  const platform = options.platform || process.platform, read = options.execFileSync || cp.execFileSync;
  const opts = { encoding: "utf8", timeout: 3000, maxBuffer: 16384, windowsHide: true };
  try {
    if (platform === "darwin") return validateBootIdentity({ platform,
      id: String(read("/usr/sbin/sysctl", ["-n", "kern.bootsessionuuid"], opts)).trim() });
    if (platform === "win32") return validateBootIdentity({ platform,
      id: String(read("powershell.exe", ["-NoProfile", "-Command",
        "$ErrorActionPreference='Stop'; (Get-CimInstance Win32_OperatingSystem).LastBootUpTime.ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss.fffZ')"], opts)).replace(/^\uFEFF/, "").trim() });
  } catch { fail("BOOT_IDENTITY_UNKNOWN", "OS boot identity could not be read"); }
  fail("BOOT_IDENTITY_UNKNOWN", "unsupported platform");
}

function bootKey(boot) { return sha(JSON.stringify(validateBootIdentity(boot))); }
function canonicalParent(parent) {
  if (typeof parent !== "string" || !path.isAbsolute(parent)) fail("SLOT_PATH_INVALID", "absolute admission directory required");
  const stat = fs.lstatSync(parent);
  if (!stat.isDirectory() || stat.isSymbolicLink()) fail("SLOT_PATH_INVALID", "admission directory is not an ordinary directory");
  return fs.realpathSync(parent);
}
function directory(dir) {
  try { fs.mkdirSync(dir, { mode: 0o700 }); } catch (error) { if (error.code !== "EEXIST") throw error; }
  const stat = fs.lstatSync(dir);
  if (!stat.isDirectory() || stat.isSymbolicLink()) fail("SLOT_PATH_INVALID", "slot metadata directory is not an ordinary directory");
  return stat;
}

function withSlotMutationLock(parent, operation, options = {}) {
  const bootIdentity = validateBootIdentity((options.readBootIdentity || readBootIdentity)());
  parent = canonicalParent(parent);
  const locks = path.join(parent, ".slot-mutation-locks"); directory(locks);
  // Old-boot locks are retained. No old process can run in a proven new boot.
  const lockDir = path.join(locks, bootKey(bootIdentity));
  const timeout = Math.max(0, Math.min(Number(options.timeoutMs ?? 1000) || 0, 5000));
  const now = options.now || (() => performance.now()), end = now() + timeout;
  const pause = options.pause || (ms => Atomics.wait(new Int32Array(new SharedArrayBuffer(4)), 0, 0, ms));
  for (;;) {
    try { fs.mkdirSync(lockDir, { mode: 0o700 }); break; }
    catch (error) {
      if (error.code !== "EEXIST") throw error;
      if (now() >= end) fail("SLOT_MUTATION_BUSY", "another admission mutation is active or unresolved in this boot");
      pause(Math.min(10, Math.max(1, end - now())));
    }
  }
  const held = identity(fs.lstatSync(lockDir, { bigint: true })), token = crypto.randomUUID();
  const lockFile = path.join(lockDir, "owner.json");
  fs.writeFileSync(lockFile, JSON.stringify({ token, bootIdentity, pid: process.pid }), { flag: "wx", mode: 0o600 });
  function assertOwnership() {
    try {
      if (!same(held, identity(fs.lstatSync(lockDir, { bigint: true }))) || JSON.parse(fs.readFileSync(lockFile, "utf8")).token !== token)
        fail("SLOT_LOCK_CHANGED", "admission mutation lock changed");
    } catch (error) { if (error.code === "SLOT_LOCK_CHANGED") throw error; fail("SLOT_LOCK_CHANGED", "admission mutation lock is unreadable"); }
  }
  try {
    const value = operation({ parent, bootIdentity, assertOwnership });
    if (value && typeof value.then === "function") fail("SLOT_LOCK_ASYNC_UNSUPPORTED", "slot mutations must finish synchronously under this lock");
    return value;
  } finally {
    assertOwnership();
    fs.unlinkSync(lockFile); fs.rmdirSync(lockDir);
  }
}

function inspectSlot({ parent, number, currentBoot }) {
  if (![1, 2].includes(number)) fail("SLOT_NUMBER_INVALID", "slot must be 1 or 2");
  currentBoot = validateBootIdentity(currentBoot || readBootIdentity());
  parent = canonicalParent(parent);
  const slotDir = path.join(parent, String(number));
  let stat;
  try { stat = fs.lstatSync(slotDir, { bigint: true }); }
  catch (error) { if (error.code === "ENOENT") return { eligible: false, reason: "absent", parent, number }; throw error; }
  const base = { eligible: false, parent, number, currentBoot, directoryIdentity: identity(stat) };
  if (!stat.isDirectory() || stat.isSymbolicLink()) return { ...base, reason: "slot-directory-unknown" };
  let owner, bytes, fileStat;
  try {
    const names = fs.readdirSync(slotDir);
    if (names.length !== 1 || names[0] !== "owner.json") return { ...base, reason: "slot-contents-unknown" };
    const ownerPath = path.join(slotDir, "owner.json"), before = fs.lstatSync(ownerPath, { bigint: true });
    if (!before.isFile() || before.isSymbolicLink() || before.size > 65536n) return { ...base, reason: "owner-file-unknown" };
    const fd = fs.openSync(ownerPath, fs.constants.O_RDONLY | (fs.constants.O_NOFOLLOW || 0));
    try { fileStat = fs.fstatSync(fd, { bigint: true }); bytes = fs.readFileSync(fd); }
    finally { fs.closeSync(fd); }
    if (!same(identity(before), identity(fileStat)) || !same(identity(fileStat), identity(fs.lstatSync(ownerPath, { bigint: true })))
      || !same(base.directoryIdentity, identity(fs.lstatSync(slotDir, { bigint: true })))) return { ...base, reason: "slot-changed-during-read" };
    owner = JSON.parse(bytes.toString("utf8"));
  } catch { return { ...base, reason: "owner-unreadable" }; }
  const proof = { ...base, ownerSha256: sha(bytes), ownerFileIdentity: identity(fileStat), owner };
  if (!owner || typeof owner !== "object" || !/^[A-Za-z0-9_-]{1,80}$/.test(owner.sessionId || "")
    || !Number.isSafeInteger(owner.extensionHostPid) || owner.extensionHostPid <= 1
    || !Number.isFinite(Date.parse(owner.hostBirth || ""))) return { ...proof, reason: "owner-invalid" };
  let previous;
  try { previous = validateBootIdentity(owner.bootIdentity); }
  catch { return { ...proof, reason: "owner-boot-unknown" }; }
  if (previous.platform !== currentBoot.platform) return { ...proof, reason: "boot-platform-mismatch" };
  if (previous.id === currentBoot.id) return { ...proof, reason: "same-boot-cleanup-unresolved" };
  if (currentBoot.platform === "win32" && Date.parse(currentBoot.id) <= Date.parse(previous.id))
    return { ...proof, reason: "boot-order-unknown" };
  return { ...proof, eligible: true, reason: "prior-boot-owner", previousBoot: previous };
}

function recoverSlot(inspected, options = {}) {
  if (!inspected || inspected.eligible !== true) fail("SLOT_RECOVERY_REFUSED", "an eligible original inspection is required");
  return withSlotMutationLock(inspected.parent, lock => {
    if (bootKey(lock.bootIdentity) !== bootKey(inspected.currentBoot)) fail("SLOT_RECOVERY_CHANGED", "current boot differs from the reviewed action");
    const fresh = inspectSlot({ parent: lock.parent, number: inspected.number, currentBoot: lock.bootIdentity });
    if (!fresh.eligible || !same(fresh.directoryIdentity, inspected.directoryIdentity)
      || !same(fresh.ownerFileIdentity, inspected.ownerFileIdentity) || fresh.ownerSha256 !== inspected.ownerSha256)
      fail("SLOT_RECOVERY_CHANGED", "the original slot or owner record changed; inspect it again");
    const archives = path.join(lock.parent, "recovered"); directory(archives);
    const archivePath = path.join(archives, `${fresh.number}-${bootKey(fresh.previousBoot).slice(0, 12)}-${fresh.owner.sessionId}-${crypto.randomUUID()}`);
    lock.assertOwnership();
    fs.renameSync(path.join(lock.parent, String(fresh.number)), archivePath);
    return { recovered: true, reason: "prior-boot-owner-archived", number: fresh.number,
      originalOwnerSha256: fresh.ownerSha256, archivePath, previousBoot: fresh.previousBoot, currentBoot: lock.bootIdentity,
      backendCleanup: "original-receipt-preserved", signalled: [] };
  }, options);
}

module.exports = { validateBootIdentity, readBootIdentity, bootKey, withSlotMutationLock, inspectSlot, recoverSlot };
