"use strict";
const assert=require("node:assert/strict");
const {createAdapter}=require("./backend_shutdown_process");
const orphan=require("./orphan_worker_core");
// All subprocesses, presence probes and signals are injected; these are not
// observations of the developer's running Mac processes.
const hostBirth="Thu Nov 12 10:00:00 2026",rootBirth="Thu Nov 12 10:00:01 2026",workerBirth="Thu Nov 12 10:00:02 2026";
function fixture({reusedRoot=false,reusedHost=false,foreignParent=false,stopped=false,worker=true,signalRace=false,expired=false,unreadable=false}={}){
  let ms=0,rootAlive=true,workerAlive=worker,closing=false;
  const signals=[],reads=[];
  const birth=()=>closing&&reusedRoot?workerBirth:rootBirth;
  const text=ids=>ids.map(id=>id===100?`100 10 ${closing&&reusedHost?workerBirth:hostBirth}`:
    id===110&&rootAlive?`110 ${closing&&foreignParent?200:100} ${birth()}`:
    id===111&&workerAlive?`111 ${rootAlive?110:1} ${workerBirth}`:"").filter(Boolean).join("\n");
  const group=()=>`100 10 S ${hostBirth}\n${rootAlive?`110 10 S ${rootBirth}\n`:""}${workerAlive?`111 10 S ${workerBirth}\n`:""}200 10 ${stopped?"T":"S"} ${hostBirth}`;
  const execFile=(file,args,opts,done)=>{
    reads.push([file,args]);assert.ok(opts.timeout>0);
    if(expired&&closing)ms+=1000;
    if(unreadable&&closing)return done(Error("unreadable"),"","");
    if(file==="pgrep")return done(null,args.at(-1)==="110"&&workerAlive?"111":"","");
    if(file==="lsof")return done(null,workerAlive?"p111\nn/session/A":"","");
    assert.equal(file,"ps");
    done(null,args.includes("-axo")?group():text(args.at(-1).split(",").map(Number)),"");
  };
  const execFileSync=(file,args)=>{
    assert.equal(file,"ps");reads.push([file,args]);
    if(args.includes("-axo"))return group();
    return signalRace?`110 200 ${workerBirth}`:text([110]);
  };
  const child={pid:110,exitCode:null,signalCode:null,kill(signal){signals.push([110,signal]);rootAlive=false;this.exitCode=0;return true;}};
  const adapter=createAdapter({platform:"darwin",hostPid:100,now:()=>ms,execFile,execFileSync,
    binding:()=>({sessionId:"A",ownerId:"owner-A",profilePath:"/session/A"}),directories:()=>["/session/A"],
    probe:pid=>pid===110&&rootAlive||pid===111&&workerAlive?orphan.PRESENT:orphan.ABSENT,
    kill:(pid,signal)=>{assert.equal(pid,111);signals.push([pid,signal]);workerAlive=false;},sleep:async delay=>{ms+=Math.min(delay,1);},
  });
  return {adapter,child,signals,reads,close:async identity=>{
    closing=true;return adapter.close({identity,process:child,rawClose:async()=>child.kill("SIGTERM")},500);
  }};
}
(async()=>{
  let count=0;
  for(const worker of [false,true]){
    const f=fixture({worker}),id=await f.adapter.capture(f.child,{}, {epoch:0});
    assert.equal(id.createdMs,Date.parse(rootBirth));assert.equal(id.precisionMs,1000);
    const r=await f.close(id);assert.equal(r.backendCleanup,"complete");
    assert.deepEqual(f.signals.map(r=>r[0]),worker?[110,111]:[110]);count++;
  }
  for(const option of ["reusedRoot","reusedHost","foreignParent","stopped","signalRace","unreadable"]){
    const f=fixture({[option]:true}),id=await f.adapter.capture(f.child,{}, {epoch:0});
    let r;try{r=await f.close(id);}catch(e){r={backendCleanup:"unknown",error:e.message};}
    assert.equal(r.backendCleanup,"unknown",option);assert.deepEqual(f.signals,[],option);count++;
  }
  {
    const f=fixture({expired:true}),id=await f.adapter.capture(f.child,{}, {epoch:0});
    const r=await f.close(id);assert.notEqual(r.backendCleanup,"complete");assert.deepEqual(f.signals,[]);count++;
  }
  console.log(JSON.stringify({verdict:"PASS",groups:count,scope:"mock Darwin identities/tree/group/deadline; no OS calls"}));
})().catch(e=>{console.error(e);process.exitCode=1;});
