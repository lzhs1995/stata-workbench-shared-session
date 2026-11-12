"use strict";
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");
const { EventEmitter } = require("node:events");
const { createLifecycle } = require("./backend_shutdown_core");
const patch = require("./apply_backend_shutdown_patch");
const { historicalLayer, sha } = require("./test_daily_bundle_helpers");
const deferred = () => { let resolve,reject;const promise=new Promise((a,b)=>{resolve=a;reject=b;});return {promise,resolve,reject}; };
const tick = async () => { for(let i=0;i<20;i++)await Promise.resolve(); };

function fixture({createGate,connectGate,listGate,closeGate}={}) {
  const events=[], transports=[], manager={begin:0,finish:[],beginClose(){this.begin++;},async finishClose(r){this.finish.push(r);return r;}};
  let spawned=0,closed=0;
  const client={_clientPromise:null,_transport:null,_availableTools:new Set(),_statusEmitter:new EventEmitter(),
    async _createClient(){
      if(createGate)await createGate.promise;
      const transport={_process:null,async start(){spawned++;this._process={pid:100+spawned,exitCode:null};},async close(){closed++;}};
      transports.push(transport);
      return {transport,setupTimeoutSeconds:1,client:{async connect(t){await t.start();if(connectGate)await connectGate.promise;}}};
    },async _refreshToolList(){if(listGate)await listGate.promise;this._availableTools=new Set(["run"]);},
  };
  client._statusEmitter.on("status",s=>events.push(s));
  const adapter={async capture(p){return {pid:p.pid,createdMs:1000,sessionId:"a"};},async close(entry){
    closed++;if(closeGate)await closeGate.promise;entry.process.exitCode=0;return {backendCleanup:"complete"};}};
  const life=createLifecycle(client,{adapter,manager:()=>manager});
  return {client,life,events,transports,manager,get spawned(){return spawned;},get closed(){return closed;}};
}

(async()=>{
  let count=0;
  for(const phase of ["create","connect","list"]){
    const gate=deferred(),f=fixture({[phase+"Gate"]:gate});
    const pending=f.life.ensureClient().catch(e=>e);await tick();
    const shut=f.life.shutdown(200),same=f.life.shutdown(200);
    assert.equal(shut,same,"shutdown promise identity");assert.equal(f.manager.begin,1);
    assert.throws(()=>f.life.ensureClient(),/CLOSING/);
    gate.resolve();const result=await shut;assert.equal(result.backendCleanup,"complete");
    assert.match((await pending).message,/CLOSING/);assert.equal(f.client._transport,null);
    assert.deepEqual(f.events,[]);assert.equal(f.spawned,phase==="create"?0:1);
    assert.equal(f.closed,1);assert.equal(f.manager.finish.length,1);count++;
  }
  {
    const f=fixture();const a=f.life.ensureClient(),b=f.life.ensureClient();assert.equal(a,b);await a;
    await f.life.dispose();assert.equal(f.life.status().closing,false);await f.life.ensureClient();
    assert.equal(f.spawned,2);assert.equal(f.events.filter(x=>x==="connected").length,2);
    const r=await f.life.shutdown();assert.equal(r.backendCleanup,"complete");assert.equal(f.closed,2);count++;
  }
  {
    const gate=deferred(),f=fixture({connectGate:gate});const old=f.life.ensureClient().catch(e=>e);await tick();
    await f.life.dispose();const newer=f.life.ensureClient();await tick();gate.resolve();await newer;await old;
    assert.equal(f.client._clientPromise,newer);assert.equal(f.client._transport,f.transports[1]);
    assert.equal(f.events.filter(x=>x==="connected").length,1);await f.life.shutdown();count++;
  }
  {
    const gate=deferred(),f=fixture({closeGate:gate});await f.life.ensureClient();
    const r=await f.life.shutdown(15);assert.equal(r.backendCleanup,"pending");assert.equal(f.life.status().closing,true);
    gate.resolve();await tick();assert.equal(f.life.status().lastShutdown.backendCleanup,"pending","late cleanup must not silently upgrade the returned receipt");count++;
  }
  {
    const gate=deferred(),f=fixture({createGate:gate});const p=f.life.ensureClient().catch(e=>e);await tick();
    const r=await f.life.shutdown(15);assert.equal(r.backendCleanup,"pending");gate.resolve();await p;
    assert.equal(f.spawned,0);assert.deepEqual(f.events,[]);count++;
  }
  for (const method of ["beginClose", "finishClose"]) {
    const f=fixture();f.manager[method]=()=>{throw Error("manager failed");};
    const p=f.life.shutdown(50);assert.equal(p,f.life.shutdown());
    const r=await p;assert.equal(r.backendCleanup,"unknown");assert.match(r.reason,/failed/);
    assert.equal(f.life.status().lastShutdown,r);assert.throws(()=>f.life.ensureClient(),/CLOSING/);count++;
  }
  {
    const f=fixture(),gate=deferred();let released=false;
    f.manager.finishClose=async result=>{await gate.promise;released=result.backendCleanup==="complete";return result;};
    const r=await f.life.shutdown(15);assert.equal(r.backendCleanup,"pending");
    gate.resolve();await tick();assert.equal(released,false);count++;
  }
  {
    const f=fixture();let reentered;
    f.manager.beginClose=()=>{reentered=f.life.shutdown();};
    const first=f.life.shutdown();assert.equal(first,reentered);assert.equal((await first).backendCleanup,"complete");count++;
  }
  {
    const f=fixture();const r=await f.life.bounded(Promise.reject(Error("after deadline")),0,"expired");
    assert.equal(r,"expired");await new Promise(resolve=>setImmediate(resolve));count++;
  }
  // Patch-only checks use the exact shutdown layer, not the already composed
  // daily bundle. The helper also reapplies later layers to prove final bytes.
  const bundle=fs.readFileSync(path.join(__dirname,"../dist/extension.js"),"utf8");
  const layer=historicalLayer(bundle,"./apply_backend_shutdown_patch");
  const original=patch.revertBundle(layer,{finalize:false});
  const patched=patch.patchBundle(original,{finalize:false});
  new vm.Script(patched);
  assert.equal(sha(patched),sha(layer),"replay restores the exact historical shutdown layer");
  assert.equal(sha(patch.patchBundle(patched,{finalize:false})),sha(patched));
  assert.equal(sha(patch.revertBundle(patched,{finalize:false})),sha(original));
  assert.throws(()=>patch.patchBundle(original.replace('async function bHg(){','async function renamed(){'),{finalize:false}),/anchor/);
  assert.throws(()=>patch.patchBundle(original+'async function bHg(){',{finalize:false}),/anchor/);
  count+=6;
  console.log(JSON.stringify({verdict:"PASS",groups:count,scope:"offline lifecycle/patch only",distWritten:false}));
})().catch(error=>{console.error(error);process.exitCode=1;});
