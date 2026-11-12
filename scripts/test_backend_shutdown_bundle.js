"use strict";
// Execute methods extracted from the actual patched shipping bundle. No extension
// activation, sockets, process observation, spawn or Stata invocation is allowed.
const assert=require("node:assert/strict"),fs=require("node:fs"),path=require("node:path"),vm=require("node:vm");
const {EventEmitter}=require("node:events");
const {createLifecycle}=require("./backend_shutdown_core");
const patch=require("./apply_backend_shutdown_patch");
const bundle=patch.patchBundle(fs.readFileSync(path.join(__dirname,"../dist/extension.js"),"utf8"),{finalize:false});
function between(a,b){const i=bundle.indexOf(a),j=bundle.indexOf(b,i+a.length);assert.ok(i>=0&&j>i);return bundle.slice(i,j);}
const deferred=()=>{let resolve,reject;const promise=new Promise((a,b)=>{resolve=a;reject=b;});return {promise,resolve,reject};};
const tick=async()=>{for(let i=0;i<40;i++)await Promise.resolve();};
class CancellationTokenSource {
  constructor(){this.token={isCancellationRequested:false,onCancellationRequested:()=>({dispose(){}})};}
  cancel(){this.token.isCancellationRequested=true;}
}
function fixture(){
  const events=[],env={Promise,Map,Set,Date,Error,URL,Buffer,console,
    EE:{workspace:{getConfiguration:()=>({get:(key,fallback)=>fallback})},CancellationTokenSource},
    CI:{startSpan:(_meta,fn)=>fn(),captureException(){}},MM:()=>({}),
    setTimeout,clearTimeout,process:{pid:42,platform:"win32"},RI(){},HF(){},Gg:{_postMessage(){}},
    __current:()=>({nextSession:{sessionId:"A"},resetGeneration:0,diskBundleSha256:"bundle"}),
    __codexControl:{ensureRecoveryState:s=>s||{},requestRecovery:s=>s},__send:(_res,code,data)=>events.push({code,data}),
  };
  const context=vm.createContext(env);
  const method=(a,b)=>vm.runInContext('({'+between(a,b)+'})',context);
  const client={_pending:0,_active:false,_queue:Promise.resolve(),_cancellationSourcesByRunId:new Map(),
    _clientPromise:null,_statusEmitter:new EventEmitter(),_availableTools:new Set(["run","list_sessions"]),
    _log(){},_isCancellationError:()=>false,_formatRecentStderr:()=>"",_captureMcpError(){},
    _resolveToolName:x=>x,_formatMissingToolError:()=>"missing",_resetClientState(){this.resetCalls=(this.resetCalls||0)+1;},
    _scheduleRunCleanup(){},_orphanOpen(){},_appendBounded:(a,b)=>a+b,
  };
  const life=createLifecycle(client);client.__codexLifecycle=()=>life;
  client._statusEmitter.on("status",s=>events.push(s));
  Object.assign(client,method('async _enqueue(', 'async _withTimeout('),method('async _withTimeout(','_normalizeResponse('),
    method('async _callTool(','_requiredToolNames(){'),method('async _withActiveRun(','_appendBounded(A,I,Q){'));
  client._ensureClient=async()=>({});env.zg=client;
  return {client,life,events,env,context};
}
(async()=>{
  let count=0;
  for(const fail of [false,true]){
    const f=fixture(),old=deferred(),next=deferred();
    const a=f.client._enqueue("run",{runId:"old",bypassQueue:true},()=>old.promise).catch(e=>e);await tick();
    await f.life.dispose();
    const b=f.client._enqueue("run",{runId:"new",bypassQueue:true},()=>next.promise);await tick();
    const source=f.client._activeCancellation,events=f.events.length;
    fail?old.reject(Error("old failed")):old.resolve({ok:true});await a;
    assert.equal(f.client._active,true);assert.equal(f.client._activeCancellation,source);assert.equal(f.client._pending,1);
    assert.equal(f.events.length,events);assert.ok(f.client._cancellationSourcesByRunId.has("new"));
    next.resolve({ok:true});await b;await f.life.shutdown();count++;
  }
  {
    const f=fixture(),gate=deferred();let sent=0;f.client._queue=gate.promise;
    const p=f.client._enqueue("run",{},()=>{sent++;return Promise.resolve({});}).catch(e=>e);
    await f.life.shutdown();gate.resolve();assert.match((await p).message,/CLOSING/);assert.equal(sent,0);count++;
  }
  for(const fail of [false,true]){
    const f=fixture(),gate=deferred();let published=0;f.env.__codexWbSessionStatus=()=>published++;
    const p=f.client._callTool({callTool:()=>gate.promise},"list_sessions",{}).catch(e=>e);await tick();
    await f.life.dispose();f.client._clientPromise=Promise.resolve("new");const next=f.client._clientPromise;
    fail?gate.reject(Error("Connection closed")):gate.resolve({ok:true});
    assert.match((await p).message,/CLOSING/);assert.equal(f.client.resetCalls,undefined);
    assert.equal(f.client._clientPromise,next);assert.equal(published,0);count++;
  }
  {
    const f=fixture(),gate=deferred();const p=f.client._withActiveRun({_runId:"old"},()=>gate.promise);
    await f.life.dispose();const next={_runId:"new"};f.client._activeRun=next;gate.resolve();await p;
    assert.equal(f.client._activeRun,next);count++;
  }
  // Real ensure/dispose/deactivate wiring, including early tracked transport.
  {
    const f=fixture(),gate=deferred();let spawned=0,closed=0,flushed=0;
    const life=createLifecycle(f.client,{adapter:{capture:async p=>({pid:p.pid}),close:async()=>{closed++;return {backendCleanup:"complete"};}}});
    f.env.require=name=>{assert.equal(name,"../scripts/backend_shutdown_runtime");return {lifecycle:()=>life};};
    f.env.GB={flush:async()=>flushed++};
    Object.assign(f.client,vm.runInContext('({'+between('async _ensureClient(){','async _fetchLatestVersion(')+'})',f.context),
      vm.runInContext('({'+between('async dispose(){','__codexLifecycle(){')+'})',f.context),
      vm.runInContext('({'+between('__codexLifecycle(){','async cancelAll(){')+'})',f.context));
    f.client._fetchLatestVersion=async()=>({latest:"synthetic"});
    f.client._createClient=async()=>({transport:{async start(){spawned++;this._process={pid:99};},async close(){}},
      client:{async connect(t){await t.start();await gate.promise;}}});f.client._refreshToolList=async()=>{};
    const pending=f.client._ensureClient().catch(e=>e);await tick();
    vm.runInContext(between('async function bHg(){','function HF(g){'),f.context);
    const deactivate=vm.runInContext('bHg()',f.context);gate.resolve();await deactivate;await pending;
    assert.equal(spawned,1);assert.equal(closed,1);assert.equal(flushed,1);
    assert.equal(f.env.__codexShutdownResult.backendCleanup,"complete");count++;
  }
  {
    const f=fixture();let destroyed=0;
    f.env.__codexBridgePort=17777;f.env.__codexRecoveryState={required:true};
    f.env.require=name=>{assert.equal(name,"node:http");return {request(){const r=new EventEmitter();r.setTimeout=()=>{};r.end=()=>{};r.destroy=e=>{destroyed++;r.emit("error",e);};return r;}};};
    vm.runInContext(between('globalThis.__codexRunRecoverySmoke=async',';globalThis.__codexGuardCancelRef=')+';',f.context);
    const p=f.env.__codexRunRecoverySmoke("test").catch(e=>e);await tick();await f.life.shutdown();
    assert.match((await p).message,/CLOSING/);assert.equal(destroyed,1);assert.equal(f.env.__codexLastAutoRecoverySmoke,undefined);count++;
  }
  for(const phase of ["cancel","dispose","reconnect","darwin-success"]){
    const f=fixture(),gate=deferred();let connected=0,disposed=0;
    f.env.setTimeout=()=>0;f.env.__codexBridgeState={busy:false};f.env.__codexOwnedBackendPids=new Map();
    f.env.__codexOpenCleanupGate=()=>{};f.env.__codexWindowsKillScopeRun=()=>({ok:true});
    f.env.require=name=>{assert.equal(name,"child_process");return {};};
    if(phase==="darwin-success")f.env.process.platform="darwin";
    f.client.cancelAll=()=>phase==="cancel"?gate.promise:Promise.resolve();
    f.client.dispose=()=>{disposed++;return phase==="dispose"?gate.promise:Promise.resolve();};
    f.client.connect=()=>{connected++;return phase==="reconnect"?gate.promise:Promise.resolve();};
    vm.runInContext(between('globalThis.__codexForceReset=async',';/* codex patch v5: force reset state cleanup */')+';',f.context);
    const p=f.env.__codexForceReset("test").catch(e=>e);await tick();
    if(phase==="darwin-success"){
      const result=await p;assert.equal(result.cleanup.ok,true);assert.equal(result.cleanup.mode,"verified-lifecycle");
      assert.equal(f.env.__codexOrphanReap.clean,true);assert.equal(connected,1);count++;continue;
    }
    await f.life.shutdown();gate.resolve();
    assert.match((await p).message,/CLOSING/);assert.equal(connected,phase==="reconnect"?1:0);
    assert.equal(disposed,phase==="cancel"?0:1);assert.equal(f.env.__codexLastForceResetReconnect,undefined);count++;
  }
  // Real reset calls connect even after its 2.5s dispose wait times out. Exercise
  // that exact path with the real patched ensure/dispose and a held old backend.
  for(const outcome of ["complete","pending","unknown","deadline"]){
    const f=fixture(),gate=deferred();let time=0,spawned=0,closes=0;const timers=new Map();
    const life=createLifecycle(f.client,{cleanupTimeoutMs:100,now:()=>time,
      setTimeout:(fn,ms)=>{const id={};timers.set(id,{fn,due:time+ms});return id;},clearTimeout:id=>timers.delete(id),
      adapter:{capture:async p=>({pid:p.pid,createdMs:1000}),close:async()=>{closes++;await gate.promise;return {backendCleanup:outcome==="deadline"?"complete":outcome};}}});
    f.env.require=name=>{if(name==="child_process")return {};assert.equal(name,"../scripts/backend_shutdown_runtime");return {lifecycle:()=>life};};
    Object.assign(f.client,vm.runInContext('({'+between('async _ensureClient(){','async _fetchLatestVersion(')+'})',f.context),
      vm.runInContext('({'+between('async dispose(){','__codexLifecycle(){')+'})',f.context),
      vm.runInContext('({'+between('__codexLifecycle(){','async cancelAll(){')+'})',f.context));
    f.client._fetchLatestVersion=async()=>({latest:"synthetic"});f.client._refreshToolList=async()=>{};
    f.client._createClient=async()=>({transport:{async start(){spawned++;this._process={pid:90+spawned};},async close(){}},
      client:{async connect(t){await t.start();}}});f.client.connect=()=>f.client._ensureClient();f.client.cancelAll=async()=>{};
    f.env.process.platform="darwin";f.env.__codexBridgeState={busy:false};f.env.__codexOwnedBackendPids=new Map();
    const disposeTimers=[];f.env.setTimeout=(fn,ms)=>{if(ms===2500)disposeTimers.push(fn);return 0;};
    await f.client.connect();assert.equal(spawned,1);
    vm.runInContext(between('globalThis.__codexForceReset=async',';/* codex patch v5: force reset state cleanup */')+';',f.context);
    const resetting=f.env.__codexForceReset("recovery overlap test");await tick();
    disposeTimers.forEach(fn=>fn());await tick();
    assert.equal(spawned,1);assert.equal(closes,1);
    if(outcome==="deadline"){
      time=100;for(const [id,t] of [...timers])if(t.due<=time){timers.delete(id);t.fn();}await tick();
    }else gate.resolve();
    const result=await resetting;
    assert.equal(result.cleanup.ok,false,"reset's early cleanup snapshot is not fabricated as complete");
    assert.equal(f.env.__codexLastForceResetReconnect.ok,outcome==="complete");
    assert.equal(spawned,outcome==="complete"?2:1);assert.equal(closes,1);
    if(outcome==="deadline"){gate.resolve();await tick();await assert.rejects(f.client.connect(),/BACKEND_CLEANUP_REQUIRED/);assert.equal(spawned,1);}
    await life.shutdown();count++;
  }
  {
    const f=fixture(),gate=deferred();let closes=0;const callbacks=[];
    f.env.iA={commands:{executeCommand:async command=>{assert.equal(command,"workbench.action.closeWindow");closes++;}}};
    f.env.setTimeout=fn=>callbacks.push(fn);f.env.__req={method:"POST",url:"/session-close?sessionId=A&hostPid=42&generation=0&bundle=bundle"};f.env.__res={};
    const ownLife=createLifecycle(f.client,{manager:()=>({beginClose(){},finishClose:()=>gate.promise})});f.client.__codexLifecycle=()=>ownLife;
    const endpoint=vm.runInContext('(async()=>{'+patch.CLOSE_ENDPOINT+'})',f.context);
    const p=endpoint();await tick();assert.equal(closes,0);assert.equal(ownLife.status().closing,true);
    await endpoint();assert.equal(f.events.at(-1).data.error,"CLOSE_ALREADY_REQUESTED_NO_REPLAY");
    gate.resolve({});await p;assert.equal(f.events.at(-1).data.backendCleanup,"complete");
    assert.equal(callbacks.length,1);await callbacks[0]();assert.equal(closes,1);count++;
  }
  {
    const f=fixture();f.env.__req={method:"POST",url:"/session-close?sessionId=B"};f.env.__res={};
    await vm.runInContext('(async()=>{'+patch.CLOSE_ENDPOINT+'})()',f.context);
    assert.equal(f.events.at(-1).code,409);assert.equal(f.life.status().closing,false);count++;
  }
  console.log(JSON.stringify({verdict:"PASS",groups:count,scope:"actual patched bundle methods; injected boundaries only"}));
})().catch(e=>{console.error(e);process.exitCode=1;});
