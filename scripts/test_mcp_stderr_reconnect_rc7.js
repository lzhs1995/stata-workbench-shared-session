"use strict";
const assert = require("node:assert/strict");
const test = require("node:test");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");
const { PassThrough } = require("node:stream");
const { spawn } = require("node:child_process");

const bundle = fs.readFileSync(path.join(__dirname, "../dist/extension.js"), "utf8");
function method(start, end) {
  const a = bundle.indexOf(start);
  assert.ok(a >= 0);
  const b = bundle.indexOf(end, a + start.length);
  assert.ok(b > a);
  return vm.runInNewContext("({" + bundle.slice(a, b) + "})");
}
function client() {
  return Object.assign({ bytes: 0, _handleStderrData(chunk) { this.bytes += Buffer.byteLength(chunk); } },
    method("_attachStderrListener(", "setLogger("),
    method("_resetClientState(){", "_handleStderrData("));
}

test("one stderr consumer per transport, including post-connect fallback", () => {
  const c = client(), owner = {}, first = new PassThrough(), wrapper = new PassThrough();
  assert.equal(c._attachStderrListener(first, "transport", owner), true);
  assert.equal(c._attachStderrListener(first, "transport", owner), false);
  assert.equal(c._attachStderrListener(wrapper, "post_connect", owner), false);
  first.write("one");
  assert.equal(c.bytes, 3);
});

test("a newly reconnected transport obtains its own consumer", () => {
  const c = client(), oldStream = new PassThrough(), nextStream = new PassThrough();
  assert.equal(c._attachStderrListener(oldStream, "transport", {}), true);
  c._resetClientState();
  assert.equal(c._attachStderrListener(nextStream, "transport", {}), true);
  oldStream.write("old"); nextStream.write("new");
  assert.equal(c.bytes, 6);
});

test("all generated attachment call sites bind their concrete transport", () => {
  assert.ok(bundle.includes('this._attachStderrListener(F.stderr,"proc",d)'));
  assert.ok(bundle.includes('this._attachStderrListener(H,"transport",d)'));
  assert.ok(bundle.includes('this._attachStderrListener(C.stderr,"post_connect",Q)'));
});

async function flood(c, owner) {
  // This child cannot reach its stdout marker until the stderr write callback
  // proves a full MiB has drained. No Stata, GUI, or network is involved.
  const child = spawn(process.execPath, ["-e",
    'process.stderr.write(Buffer.alloc(1024*1024,120),()=>process.stdout.write("DRAINED\\n"));'],
    { stdio: ["ignore", "pipe", "pipe"] });
  let out = "", timer;
  child.stdout.on("data", b => { out += b; });
  c._attachStderrListener(child.stderr, "transport", owner);
  try {
    await Promise.race([
      new Promise((resolve, reject) => {
        child.once("error", reject);
        child.once("close", (code, signal) => code === 0 ? resolve() : reject(new Error("child exit " + code + "/" + signal)));
      }),
      new Promise((_, reject) => { timer = setTimeout(() => reject(new Error("stderr pipe did not drain")), 2500); }),
    ]);
    assert.equal(out, "DRAINED\n");
  } finally {
    clearTimeout(timer);
    // Kill only this test-created child on a regression; never an application.
    if (child.exitCode === null && child.signalCode === null) {
      child.kill("SIGKILL");
      await new Promise(resolve => child.once("close", resolve));
    }
  }
}

test("real stderr pipes drain across two reconnects, not just initial launch", async () => {
  const c = client();
  for (let i = 0; i < 3; i++) {
    if (i) c._resetClientState();
    await flood(c, {});
  }
  assert.equal(c.bytes, 3 * 1024 * 1024);
});
