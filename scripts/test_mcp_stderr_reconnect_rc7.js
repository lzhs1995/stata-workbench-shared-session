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
  assert.ok(bundle.includes('require("../scripts/backend_shutdown_runtime").lifecycle(this).ensureClient('));
  const runtime=fs.readFileSync(path.join(__dirname,"backend_shutdown_runtime.js"),"utf8");
  assert.ok(runtime.includes('scope._attachStderrListener(entry.process.stderr, "spawn", entry.transport)'));
});

test("actual final ensure wires runtime birth callback before handshake and fences stale stderr", async () => {
  const {createLifecycle}=require("./backend_shutdown_core");
  const runtimeSource=fs.readFileSync(path.join(__dirname,"backend_shutdown_runtime.js"),"utf8");
  const runtimeBox={module:{exports:{}},globalThis:{},require:name=>name==="./backend_shutdown_core"?{forClient:(c,opts)=>createLifecycle(c,opts)}:
    name==="./backend_shutdown_process"?{createAdapter:()=>({capture:async()=>({pid:99,createdMs:1}),close:async()=>({backendCleanup:"complete"})})}:require(name)};
  vm.runInNewContext(runtimeSource,runtimeBox);
  const c=client();let ready;const pending=new Promise(r=>ready=r),streams=[];
  const life=runtimeBox.module.exports.lifecycle(c,{});
  const {between}=require("./test_daily_bundle_helpers");
  Object.assign(c,vm.runInNewContext('({'+between(bundle,'async _ensureClient(){','async _fetchLatestVersion(')+'})',
    {MM:()=>({MCP_STATA_PACKAGE_SPEC:"synthetic"}),require:()=>({lifecycle:()=>life})}));
  c._createClient=async()=>({transport:{async start(){this._process={pid:99,stderr:new PassThrough()};streams.push(this._process.stderr);},async close(){}},
    client:{async connect(t){await t.start();await pending;}}});c._refreshToolList=async()=>{};
  const connecting=c._ensureClient().catch(e=>e);for(let i=0;i<60;i++)await Promise.resolve();
  streams[0].write("before");assert.equal(c.bytes,6,"stderr drained while connect still pending");
  const closing=life.shutdown();streams[0].write("after");ready();await connecting;await closing;
  assert.equal(c.bytes,6,"old transport cannot publish stderr after close");
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
