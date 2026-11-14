"use strict";
const { test } = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const os = require("node:os");
const cp = require("node:child_process");
const { promisify } = require("node:util");
const recovery = require("./window_slot_recovery");

const oldBoot = { platform: "darwin", id: "11111111-1111-4111-8111-111111111111" };
const newBoot = { platform: "darwin", id: "22222222-2222-4222-8222-222222222222" };
const thirdBoot = { platform: "darwin", id: "33333333-3333-4333-8333-333333333333" };
const owner = bootIdentity => ({ sessionId: "w-A", extensionHostPid: 12345,
  hostBirth: "2026-11-11T10:00:00.000Z", bootIdentity, backendCleanup: "pending", reason: "original-shutdown-deadline" });
function fixture(t, record = owner(oldBoot)) {
  const parent = fs.mkdtempSync(path.join(os.tmpdir(), "wb-slot-recovery-"));
  t.after(() => fs.rmSync(parent, { force: true, recursive: true }));
  const slot = path.join(parent, "1"), file = path.join(slot, "owner.json");
  fs.mkdirSync(slot); fs.writeFileSync(file, JSON.stringify(record, null, 2) + "\n");
  return { parent, slot, file, inspect: currentBoot => recovery.inspectSlot({ parent, number: 1, currentBoot: currentBoot || newBoot }) };
}

function mockLargeSlotIdentities(t, f) {
  const original = 9007199254740992n, replacement = original + 1n, device = 73n;
  const canonical = fs.realpathSync(f.parent);
  const slots = new Set([f.slot, path.join(canonical, "1")]);
  const owners = new Set([f.file, path.join(canonical, "1", "owner.json")]);
  const native = { lstatSync: fs.lstatSync, fstatSync: fs.fstatSync, openSync: fs.openSync, closeSync: fs.closeSync };
  const descriptors = new Map();
  let ownerInode = original;
  function substitute(stat, options, inode) {
    stat.dev = options?.bigint ? device : Number(device);
    stat.ino = options?.bigint ? inode : Number(inode);
    return stat;
  }
  t.mock.method(fs, "lstatSync", (file, options) => {
    const stat = native.lstatSync(file, options), name = String(file);
    if (slots.has(name)) return substitute(stat, options, original + 2n);
    return owners.has(name) ? substitute(stat, options, ownerInode) : stat;
  });
  // Bind fstat to the identity at open time, while all bytes and file types
  // remain real. No assumption about the host filesystem's inode values.
  t.mock.method(fs, "openSync", (file, ...args) => {
    const fd = native.openSync(file, ...args);
    if (owners.has(String(file))) descriptors.set(fd, ownerInode);
    return fd;
  });
  t.mock.method(fs, "fstatSync", (fd, options) => {
    const stat = native.fstatSync(fd, options);
    return descriptors.has(fd) ? substitute(stat, options, descriptors.get(fd)) : stat;
  });
  t.mock.method(fs, "closeSync", fd => {
    try { return native.closeSync(fd); }
    finally { descriptors.delete(fd); }
  });
  return { original, replacement, replaceOwner: () => { ownerInode = replacement; } };
}

test("read-only inspection refuses same boot, unknown owner boot and malformed records", t => {
  for (const [record, reason] of [[owner(newBoot), "same-boot-cleanup-unresolved"],
    [{ ...owner(oldBoot), bootIdentity: undefined }, "owner-boot-unknown"],
    [{ ...owner(oldBoot), extensionHostPid: null }, "owner-invalid"],
    [{ ...owner(oldBoot), bootIdentity: { platform: "win32", id: "2026-11-11T00:00:00.000Z" } }, "boot-platform-mismatch"]]) {
    const f = fixture(t, record), before = fs.readFileSync(f.file);
    const result = f.inspect(); assert.equal(result.eligible, false); assert.equal(result.reason, reason);
    assert.deepEqual(fs.readFileSync(f.file), before); assert.deepEqual(fs.readdirSync(f.parent), ["1"]);
    assert.throws(() => recovery.recoverSlot(result, { readBootIdentity: () => newBoot }), { code: "SLOT_RECOVERY_REFUSED" });
  }
});

test("cross-boot recovery archives exact original pending evidence without signals or rewriting it", t => {
  const f = fixture(t), before = fs.readFileSync(f.file), proof = f.inspect();
  assert.equal(proof.eligible, true);
  const result = recovery.recoverSlot(proof, { readBootIdentity: () => newBoot });
  assert.equal(result.recovered, true); assert.deepEqual(result.signalled, []);
  assert.equal(result.backendCleanup, "original-receipt-preserved");
  assert.equal(fs.existsSync(f.slot), false);
  assert.deepEqual(fs.readFileSync(path.join(result.archivePath, "owner.json")), before);
  assert.equal(JSON.parse(before).backendCleanup, "pending");
  assert.throws(() => recovery.recoverSlot(proof, { readBootIdentity: () => newBoot }), { code: "SLOT_RECOVERY_CHANGED" });
});

test("owner contents, owner inode, slot directory, and current boot changes reject the exact action", t => {
  for (const mutate of [
    f => fs.appendFileSync(f.file, " "),
    f => { const bytes = fs.readFileSync(f.file); fs.renameSync(f.file, path.join(f.parent, "old-owner")); fs.writeFileSync(f.file, bytes); },
    f => { fs.renameSync(f.slot, path.join(f.parent, "original-slot")); fs.mkdirSync(f.slot); fs.writeFileSync(f.file, JSON.stringify(owner(oldBoot))); },
  ]) {
    const f = fixture(t), proof = f.inspect(); mutate(f);
    assert.throws(() => recovery.recoverSlot(proof, { readBootIdentity: () => newBoot }), { code: "SLOT_RECOVERY_CHANGED" });
    assert.ok(fs.existsSync(f.file), "changed owner remains in place");
  }
  const f = fixture(t), proof = f.inspect();
  assert.throws(() => recovery.recoverSlot(proof, { readBootIdentity: () => thirdBoot }), { code: "SLOT_RECOVERY_CHANGED" });
  assert.ok(fs.existsSync(f.file));
});

test("adjacent owner inodes that collide as Numbers reject a same-byte replacement", t => {
  const f = fixture(t), ids = mockLargeSlotIdentities(t, f), before = fs.readFileSync(f.file), proof = f.inspect();
  assert.equal(Number(ids.original), Number(ids.replacement), "the fixture reproduces Number precision loss");
  assert.equal(proof.eligible, true);
  const oldOwner = path.join(f.parent, "original-owner.json");
  fs.renameSync(f.file, oldOwner); fs.writeFileSync(f.file, before); ids.replaceOwner();
  const fresh = f.inspect();
  assert.equal(fresh.eligible, true); assert.equal(fresh.ownerSha256, proof.ownerSha256);
  assert.deepEqual(fresh.directoryIdentity, proof.directoryIdentity, "only the owner inode changed");
  assert.throws(() => recovery.recoverSlot(proof, { readBootIdentity: () => newBoot }), { code: "SLOT_RECOVERY_CHANGED" });
  assert.equal(proof.ownerFileIdentity.ino, ids.original.toString());
  assert.equal(fresh.ownerFileIdentity.ino, ids.replacement.toString());
  assert.deepEqual(fs.readFileSync(f.file), before); assert.deepEqual(fs.readFileSync(oldOwner), before);
  assert.equal(fs.existsSync(path.join(f.parent, "recovered")), false, "neither owner was archived by the refused action");
});

test("exact string identities survive proof JSON round trips and permit unchanged recovery", t => {
  const f = fixture(t), ids = mockLargeSlotIdentities(t, f), before = fs.readFileSync(f.file), proof = f.inspect();
  assert.equal(proof.eligible, true);
  assert.deepEqual(proof.directoryIdentity, { dev: "73", ino: (ids.original + 2n).toString() });
  assert.deepEqual(proof.ownerFileIdentity, { dev: "73", ino: ids.original.toString() });
  const transported = JSON.parse(JSON.stringify(proof));
  assert.deepEqual(transported, proof);
  const result = recovery.recoverSlot(transported, { readBootIdentity: () => newBoot });
  assert.equal(result.recovered, true); assert.deepEqual(result.signalled, []);
  assert.equal(fs.existsSync(f.slot), false);
  assert.deepEqual(fs.readFileSync(path.join(result.archivePath, "owner.json")), before);
});

test("legacy Number identity proofs are refused without converting or removing the original slot", t => {
  const f = fixture(t); mockLargeSlotIdentities(t, f);
  const before = fs.readFileSync(f.file), proof = f.inspect();
  assert.equal(proof.eligible, true);
  for (const fields of [["directoryIdentity"], ["ownerFileIdentity"], ["directoryIdentity", "ownerFileIdentity"]]) {
    const legacy = JSON.parse(JSON.stringify(proof));
    for (const field of fields) legacy[field] = { dev: Number(legacy[field].dev), ino: Number(legacy[field].ino) };
    assert.throws(() => recovery.recoverSlot(legacy, { readBootIdentity: () => newBoot }), { code: "SLOT_RECOVERY_CHANGED" });
    assert.deepEqual(fs.readFileSync(f.file), before); assert.deepEqual(fs.readdirSync(f.slot), ["owner.json"]);
    assert.equal(fs.existsSync(path.join(f.parent, "recovered")), false);
  }
});

test("unknown slot contents and symlinks are preserved and never recovered", t => {
  const f = fixture(t); fs.writeFileSync(path.join(f.slot, "unknown"), "keep");
  assert.equal(f.inspect().reason, "slot-contents-unknown");
  const g = fixture(t), original = path.join(g.parent, "original");
  fs.renameSync(g.slot, original); fs.symlinkSync(original, g.slot, "junction");
  assert.equal(g.inspect().reason, "slot-directory-unknown");
  const h = fixture(t), originalFile = path.join(h.parent, "original-owner.json");
  fs.renameSync(h.file, originalFile); fs.symlinkSync(originalFile, h.file);
  assert.equal(h.inspect().reason, "owner-file-unknown");
});

test("current-boot mutex blocks recovery; stale prior-boot mutex does not get deleted", t => {
  const f = fixture(t), proof = f.inspect();
  const oldLock = path.join(f.parent, ".slot-mutation-locks", recovery.bootKey(oldBoot));
  fs.mkdirSync(oldLock, { recursive: true }); fs.writeFileSync(path.join(oldLock, "owner.json"), "original-lock-evidence");
  recovery.withSlotMutationLock(f.parent, lock => {
    assert.deepEqual(lock.bootIdentity, newBoot);
    assert.throws(() => recovery.recoverSlot(proof, { readBootIdentity: () => newBoot, timeoutMs: 0 }), { code: "SLOT_MUTATION_BUSY" });
    assert.ok(fs.existsSync(f.file));
  }, { readBootIdentity: () => newBoot });
  assert.equal(recovery.recoverSlot(proof, { readBootIdentity: () => newBoot }).recovered, true);
  assert.equal(fs.readFileSync(path.join(oldLock, "owner.json"), "utf8"), "original-lock-evidence");
});

test("real independent processes serialize recovery and replacement under one boot mutex", async t => {
  const f = fixture(t), proof = f.inspect(), run = promisify(cp.execFile);
  const script = `const fs=require('node:fs'),path=require('node:path'),r=require(process.argv[1]);
const proof=JSON.parse(process.argv[2]),boot=JSON.parse(process.argv[3]);
try { if(process.argv[4]==='recover') console.log(JSON.stringify(r.recoverSlot(proof,{readBootIdentity:()=>boot,timeoutMs:3000})));
else r.withSlotMutationLock(proof.parent,()=>{const slot=path.join(proof.parent,'1');if(fs.existsSync(slot)) console.log('EXISTING');else {fs.mkdirSync(slot);fs.writeFileSync(path.join(slot,'owner.json'),JSON.stringify({replacement:true}));console.log('REPLACED');}},{readBootIdentity:()=>boot,timeoutMs:3000}); }
catch(e){console.log(e.code)}`;
  const args = ["-e", script, require.resolve("./window_slot_recovery"), JSON.stringify(proof), JSON.stringify(newBoot)];
  const output = await Promise.all([run(process.execPath, [...args, "recover"]), run(process.execPath, [...args, "replace"])]);
  const recovered = JSON.parse(output[0].stdout); assert.equal(recovered.recovered, true);
  assert.equal(JSON.parse(fs.readFileSync(path.join(recovered.archivePath, "owner.json"))).backendCleanup, "pending");
  assert.ok(["EXISTING", "REPLACED"].includes(output[1].stdout.trim()));
  if (fs.existsSync(f.file)) assert.equal(JSON.parse(fs.readFileSync(f.file)).replacement, true);
});

test("OS boot readers are fixed bounded commands and fail closed", () => {
  assert.deepEqual(recovery.readBootIdentity({ platform: "darwin", execFileSync(file, args, opts) {
    assert.equal(file, "/usr/sbin/sysctl"); assert.deepEqual(args, ["-n", "kern.bootsessionuuid"]); assert.ok(opts.timeout <= 3000); return newBoot.id;
  } }), newBoot);
  const win = { platform: "win32", id: "2026-11-12T02:30:00.000Z" };
  assert.deepEqual(recovery.readBootIdentity({ platform: "win32", execFileSync(file, args, opts) {
    assert.equal(file, "powershell.exe"); assert.ok(args.at(-1).includes("Win32_OperatingSystem")); assert.ok(opts.timeout <= 3000); return "\uFEFF" + win.id + "\r\n";
  } }), win);
  for (const result of ["", "not-a-boot", "2026-11-12T02:30:00.000Z"]) assert.throws(() =>
    recovery.readBootIdentity({ platform: "darwin", execFileSync: () => result }), { code: "BOOT_IDENTITY_UNKNOWN" });
  assert.throws(() => recovery.readBootIdentity({ platform: "darwin", execFileSync: () => { throw Error("timeout"); } }), { code: "BOOT_IDENTITY_UNKNOWN" });
});

test("Windows recovery requires a later OS boot timestamp", t => {
  const boot = { platform: "win32", id: "2026-11-12T02:30:00.000Z" }, f = fixture(t, owner(boot));
  assert.equal(f.inspect({ ...boot, id: "2026-11-11T02:30:00.000Z" }).reason, "boot-order-unknown");
  assert.equal(f.inspect(boot).reason, "same-boot-cleanup-unresolved");
  assert.equal(f.inspect({ ...boot, id: "2026-11-13T02:30:00.000Z" }).eligible, true);
});
