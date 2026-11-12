"use strict";
const assert = require("node:assert/strict");
const { EventEmitter } = require("node:events");
const { createLifecycle } = require("./backend_shutdown_core");
const deferred = () => { let resolve, reject; const promise = new Promise((a,b) => { resolve=a; reject=b; }); return { promise, resolve, reject }; };
const tick = async () => { for (let i=0;i<80;i++) await Promise.resolve(); };
function fixture({ createGate, connectGate, listGate, beforeStartGate, closeGate, closeState="complete", failConnect=false }={}) {
  let time=0, spawned=0, created=0, closes=0, proof=null;
  const timers=new Map(), events=[], made=[];
  const client={_clientPromise:null,_transport:null,_availableTools:new Set(),_statusEmitter:new EventEmitter(),
    async _createClient(){
      created++;if(createGate && created===1)await createGate.promise;
      const transport={async start(){spawned++;this._process={pid:100+spawned};},async close(){closes++;}};
      made.push(transport);const number=created;
      return {transport,setupTimeoutSeconds:1,client:{async connect(t){if(number===1 && beforeStartGate)await beforeStartGate.promise;
        await t.start();if(number===1 && connectGate)await connectGate.promise;
        if(number===1 && failConnect)throw Error("connect failed");}}};
    },async _refreshToolList(){if(listGate && created===1)await listGate.promise;this._availableTools=new Set(["run"]);},
  };
  client._statusEmitter.on("status",s=>events.push(s));
  const life=createLifecycle(client,{cleanupTimeoutMs:100,now:()=>time,
    setTimeout:(fn,ms)=>{const id={};timers.set(id,{fn,due:time+ms});return id;},clearTimeout:id=>timers.delete(id),
    adapter:{capture:async p=>({pid:p.pid,createdMs:1000}),close:async()=>{closes++;if(closeGate)await closeGate.promise;return {backendCleanup:closeState};},
      reconcile:()=>proof},
  });
  return {client,life,events,made,get spawned(){return spawned;},get created(){return created;},get closes(){return closes;},
    setProof:p=>{proof=p;},advance:async ms=>{time+=ms;for(const [id,t] of [...timers])if(t.due<=time){timers.delete(id);t.fn();}await tick();},
  };
}
(async()=>{
  let groups=0;
  {
    const gate=deferred(),f=fixture({closeGate:gate});await f.life.ensureClient();
    const disposing=f.life.dispose(),next=f.life.ensureClient();assert.equal(next,f.life.ensureClient());await tick();
    assert.equal(f.spawned,1);assert.equal(f.created,1);assert.equal(f.closes,1);
    gate.resolve();await disposing;await next;assert.equal(f.spawned,2);
    assert.equal(f.client._clientPromise,next);await f.life.shutdown();groups++;
  }
  for(const closeState of ["pending","unknown"]){
    const f=fixture({closeState});await f.life.ensureClient();await f.life.dispose();
    for(let n=0;n<2;n++)await assert.rejects(f.life.ensureClient(),e=>e.code==="BACKEND_CLEANUP_REQUIRED"&&e.backendCleanup===closeState);
    assert.equal(f.spawned,1);assert.equal(f.created,1);assert.equal(f.closes,1);
    assert.equal((await f.life.shutdown()).backendCleanup,closeState);groups++;
  }
  {
    const gate=deferred(),f=fixture({closeGate:gate});await f.life.ensureClient();
    const disposing=f.life.dispose();await f.advance(60);
    const next=f.life.ensureClient().catch(e=>e);await tick();assert.equal(f.spawned,1);
    await f.advance(40);await disposing;assert.equal((await next).code,"BACKEND_CLEANUP_REQUIRED");
    gate.resolve();await tick();
    await assert.rejects(f.life.ensureClient(),/BACKEND_CLEANUP_REQUIRED/);
    assert.equal(f.spawned,1);assert.equal(f.closes,1);assert.equal((await f.life.shutdown()).backendCleanup,"pending");groups++;
  }
  {
    const gate=deferred(),f=fixture({createGate:gate});const old=f.life.ensureClient().catch(e=>e);await tick();
    await f.life.dispose();const next=f.life.ensureClient();await tick();assert.equal(f.created,1);assert.equal(f.spawned,0);
    gate.resolve();await old;await next;assert.equal(f.spawned,1);assert.equal(f.created,2);
    assert.equal(f.client._clientPromise,next);await f.life.shutdown();groups++;
  }
  for(const phase of ["create","connect","list"]){
    const gate=deferred(),f=fixture({[phase+"Gate"]:gate});const old=f.life.ensureClient().catch(e=>e);await tick();
    await f.life.dispose();const next=f.life.ensureClient().catch(e=>e);await tick();await f.advance(100);
    assert.equal((await next).code,"BACKEND_CLEANUP_REQUIRED");assert.equal(f.spawned,phase==="create"?0:1);
    gate.resolve();await old;const fresh=f.life.ensureClient();await fresh;assert.equal(f.spawned,phase==="create"?1:2);
    assert.equal(f.client._clientPromise,fresh);await f.life.shutdown();groups++;
  }
  {
    const gate=deferred(),f=fixture({beforeStartGate:gate});const old=f.life.ensureClient().catch(e=>e);await tick();
    await f.advance(1000);assert.match((await old).message,/timed out/);assert.equal(f.spawned,0);
    await f.life.ensureClient();assert.equal(f.spawned,1);const next=f.client._clientPromise;
    gate.resolve();await tick();assert.equal(f.spawned,1,"late timed-out start is permanently retired");
    assert.equal(f.client._clientPromise,next);await f.life.shutdown();groups++;
  }
  for(const closeState of ["complete","unknown"]){
    const f=fixture({failConnect:true,closeState});await assert.rejects(f.life.ensureClient(),/connect failed/);
    assert.equal(f.client._clientPromise,null);
    if(closeState==="complete"){await f.life.ensureClient();assert.equal(f.spawned,2);}
    else{await assert.rejects(f.life.ensureClient(),/BACKEND_CLEANUP_REQUIRED/);assert.equal(f.spawned,1);}
    await f.life.shutdown();groups++;
  }
  {
    const f=fixture({closeState:"unknown"});await f.life.ensureClient();await f.life.dispose();
    await assert.rejects(f.life.ensureClient(),/BACKEND_CLEANUP_REQUIRED/);
    f.setProof({backendCleanup:"complete",reason:"exact external receipt"});await f.life.ensureClient();
    assert.equal(f.spawned,2);assert.equal(f.closes,1);
    const old=f.life.status().transports[0];assert.equal(old.cleanup.backendCleanup,"unknown");
    assert.equal(old.recoveryProof.backendCleanup,"complete");await f.life.shutdown();groups++;
  }
  {
    const gate=deferred(),f=fixture({closeGate:gate});await f.life.ensureClient();const disposing=f.life.dispose();
    const blocked=f.life.ensureClient().catch(e=>e);await tick();await f.advance(100);await disposing;await blocked;
    f.setProof({backendCleanup:"complete"});await assert.rejects(f.life.ensureClient(),/BACKEND_CLEANUP_REQUIRED/);
    assert.equal(f.spawned,1);gate.resolve();await tick();await f.life.ensureClient();assert.equal(f.spawned,2);await f.life.shutdown();groups++;
  }
  {
    const gate=deferred(),f=fixture({connectGate:gate});const old=f.life.ensureClient().catch(e=>e);await tick();
    await f.life.dispose();const middle=f.life.ensureClient().catch(e=>e);await tick();await f.life.dispose();
    const next=f.life.ensureClient();await tick();assert.equal(f.spawned,1);gate.resolve();await old;await middle;await next;
    assert.equal(f.spawned,2);assert.equal(f.client._clientPromise,next);await f.life.shutdown();groups++;
  }
  {
    const gate=deferred(),f=fixture({closeGate:gate});await f.life.ensureClient();const disposing=f.life.dispose();
    const next=f.life.ensureClient().catch(e=>e);await tick();const closing=f.life.shutdown();gate.resolve();
    await disposing;assert.match((await next).message,/CLOSING/);await closing;assert.equal(f.spawned,1);groups++;
  }
  console.log(JSON.stringify({verdict:"PASS",groups,scope:"deterministic admission/cleanup deadlines; no processes or sockets"}));
})().catch(e=>{console.error(e);process.exitCode=1;});
