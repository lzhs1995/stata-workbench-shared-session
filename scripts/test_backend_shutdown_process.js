"use strict";
const assert = require("node:assert/strict");
const { createAdapter } = require("./backend_shutdown_process");
const binding={sessionId:"A",ownerId:"host-A",profilePath:"C:/sessions/A"};
const row=(pid,ppid,name,birth)=>({pid,ppid,name,cimCreatedMs:birth,handleCreatedMs:birth});
const machine=()=>[row(100,10,"Code.exe",1000),row(110,100,"python.exe",2000),row(111,110,"python.exe",2100),
  row(112,110,"conhost.exe",2050),row(200,10,"Code.exe",1000),row(210,200,"python.exe",2200),
  row(211,210,"python.exe",2300),row(300,10,"WINWORD.EXE",800),row(301,10,"rstudio.exe",900)];
const receipt=()=>({ok:true,dryRun:false,scope:"this-session",targets:[{pid:110,ppid:100,createdMs:2000},{pid:111,ppid:110,createdMs:2100}],
  kill:{ok:true,mode:"scoped",scanOk:true,results:[{pid:110,code:0,seenMs:2000,endedAtMs:3000},{pid:111,code:0,seenMs:2100,endedAtMs:3000}]}});
function harness({modify,changeBinding,killResult,missing=false,completedScope}={}) {
  const calls=[];
  const execFile=(file,args,opts,done)=>{
    calls.push({file,args,opts});
    assert.equal(file,"powershell.exe");assert.ok(opts.timeout>0&&opts.timeout<=8000);
    if(args.includes("-Command"))return done(null,JSON.stringify([{pid:100,ppid:10,name:"Code.exe",createdMs:1000,cimMs:1000},
      {pid:110,ppid:100,name:"python.exe",createdMs:2000,cimMs:2000}]),"");
    if(args.includes("-ListProcesses")){
      let rows=machine();if(modify)modify(rows);if(missing)rows=rows.filter(r=>r.pid!==110);
      return done(null,JSON.stringify({ok:true,processes:rows}),"");
    }
    assert.deepEqual(args.slice(-3),["-Force","-ScopedTargetCsv","110:2000,111:2100,112:2050"]);
    done(null,JSON.stringify(killResult||{ok:true,scanOk:true,results:[110,111,112].map(pid=>({pid,code:0,endedAtMs:3000}))}),"");
  };
  const adapter=createAdapter({platform:"win32",hostPid:100,execFile,binding:()=>changeBinding?{...binding,ownerId:"other"}:binding,completedScope:()=>completedScope});
  const identity={pid:110,ppid:100,createdMs:2000,host:{pid:100,createdMs:1000},...binding,epoch:0};
  const entry={identity,process:{pid:110,exitCode:null},rawClose:()=>{throw Error("unverified SDK kill forbidden on Windows");}};
  return {adapter,entry,calls};
}
(async()=>{
  let count=0;
  {
    const h=harness();const captured=await h.adapter.capture(h.entry.process,{}, {epoch:4});
    assert.equal(captured.createdMs,2000);assert.equal(captured.epoch,4);assert.equal(captured.sessionId,"A");
    const result=await h.adapter.close(h.entry,8000);assert.equal(result.backendCleanup,"complete");
    assert.deepEqual(result.targets.map(r=>r.pid),[110,111,112]);count++;
  }
  for(const modify of [
    rows=>rows.find(r=>r.pid===110).handleCreatedMs=2001,
    rows=>rows.find(r=>r.pid===110).ppid=200,
    rows=>rows.find(r=>r.pid===100).handleCreatedMs=1001,
    rows=>rows.find(r=>r.pid===111).handleCreatedMs=9999,
    rows=>rows.find(r=>r.pid===111).handleCreatedMs=null,
  ]){
    const h=harness({modify});assert.equal((await h.adapter.close(h.entry,8000)).backendCleanup,"unknown");
    assert.equal(h.calls.filter(r=>r.args.includes("-Force")).length,0);count++;
  }
  {
    const h=harness({changeBinding:true});assert.equal((await h.adapter.close(h.entry,8000)).backendCleanup,"unknown");
    assert.equal(h.calls.length,0);count++;
  }
  for(const code of [4,5,6]){
    const h=harness({killResult:{ok:false,results:[{pid:110,code}]}});
    const result=await h.adapter.close(h.entry,8000);assert.equal(result.backendCleanup,code===4?"unknown":"pending");count++;
  }
  {
    const h=harness({missing:true});assert.equal((await h.adapter.close(h.entry,8000)).backendCleanup,"unknown");count++;
  }
  {
    const h=harness({missing:true,completedScope:receipt()});
    assert.equal((await h.adapter.close(h.entry,8000)).backendCleanup,"complete");count++;
  }
  for(const change of [
    r=>r.dryRun=true, r=>r.scope="other", r=>r.targets[0].createdMs++, r=>r.targets[0].ppid=200,
    r=>r.kill.results[0].code=1, r=>r.kill.results[0].seenMs++, r=>r.kill.scanOk=false,
    r=>r.kill.results.pop(), r=>r.kill.results[1].code=5, r=>r.kill.results[0].endedAtMs=null,
  ]){
    const r=receipt();change(r);const h=harness({completedScope:r});
    assert.equal(h.adapter.reconcile(h.entry),null);assert.equal(h.calls.length,0);count++;
  }
  {
    const h=harness({completedScope:receipt()});h.entry.closeTargets=[{pid:112,createdMs:2050}];
    assert.equal(h.adapter.reconcile(h.entry),null);assert.equal(h.calls.length,0);count++;
  }
  {
    const h=harness({completedScope:receipt()});const proof=h.adapter.reconcile(h.entry);
    assert.equal(proof.backendCleanup,"complete");assert.equal(h.calls.length,0);count++;
  }
  console.log(JSON.stringify({verdict:"PASS",groups:count,scope:"injected process adapter; no OS calls"}));
})().catch(e=>{console.error(e);process.exitCode=1;});
