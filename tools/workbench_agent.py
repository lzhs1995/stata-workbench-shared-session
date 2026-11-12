#!/usr/bin/env python3
"""Durable, asynchronous operations for an explicitly selected Workbench window.

The worker calls shared_stata.execute_once exactly once. Polling, proposal
acceptance and Stop never submit execution. No session is launched here.
"""
import argparse
from contextlib import ExitStack
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import time
from types import SimpleNamespace
import uuid

import shared_stata as shared
import verified_workbench as entry

SCHEMA = "stata-workbench-agent-workflow/1"
ID = re.compile(r"[A-Za-z0-9_-]{1,80}\Z")
sha256 = lambda data: hashlib.sha256(data).hexdigest()


def read(path):
    return json.loads(Path(path).read_text(encoding="utf-8"))


def optional(path):
    try:
        return read(path)
    except FileNotFoundError:
        return None


def write(path, value):
    shared.write_once(Path(path), value)


def load_workflow(directory):
    directory = Path(directory).resolve(strict=True)
    workflow = read(directory / "workflow.json")
    if workflow.get("schema") != SCHEMA or not ID.fullmatch(workflow.get("workflowId", "")):
        raise ValueError("invalid workflow")
    return directory, workflow


def bind(selector, root=None):
    if root is not None:
        entry.STATE_ROOT = Path(root).expanduser().resolve()
    entry.bind_session(selector)


def identity(bridge):
    status = bridge.status(timeout=5)
    return entry.verify_session_identity(status), status


def check_identity(expected, actual, generation=True):
    keys = ("sessionId", "port", "bundleSha") + (("generation",) if generation else ())
    if any(expected.get(k) is None or expected.get(k) != actual.get(k) for k in keys):
        raise RuntimeError("SESSION_CHANGED: pinned session identity differs; no rerouting")


def document_state(bridge, ident, file):
    code, body = bridge.request("/document-state", {"path": str(file), "sessionId": ident["sessionId"], "generation": ident["generation"]})
    if code != 200 or not isinstance(body.get("document"), dict):
        raise RuntimeError("document guard refused: " + json.dumps(body))
    doc = body["document"]
    if doc.get("dirty") is not False or doc.get("sessionId") != ident["sessionId"] or doc.get("generation") != ident["generation"]:
        raise RuntimeError("document is dirty or belongs to a changed session")
    return doc


def create_workflow(directory, file, cwd, ident, document, agent_name, timeout=3600, parent=None, user_action=None, continuation_of=None):
    directory = Path(directory).absolute()
    file = Path(file).resolve(strict=True)
    cwd = Path(cwd).resolve(strict=True)
    if not cwd.is_dir() or not file.is_file() or file.suffix.lower() not in (".do", ".ado", ".mata"):
        raise ValueError("existing cwd and Stata source file required")
    source = file.read_bytes()
    if document.get("sha256") != sha256(source) or document.get("dirty") is not False:
        raise RuntimeError("source changed since editor inspection")
    if not source.strip():
        raise ValueError("empty source")
    directory.mkdir(mode=0o700, parents=True, exist_ok=False)
    directory = directory.resolve()
    workflow_id = "wf_" + uuid.uuid4().hex
    workflow = {"schema": SCHEMA, "workflowId": workflow_id, "identity": dict(ident),
        "sourcePath": str(file), "sourceSha256": sha256(source), "sourceBytes": len(source),
        "documentVersion": document["documentVersion"], "cwd": str(cwd), "agentName": agent_name,
        "timeout": timeout, "stateRoot": str(entry.STATE_ROOT), "createdAtEpoch": time.time(),
        "parentWorkflow": str(parent) if parent else None, "userAction": user_action,
        "continuationOf": continuation_of,
        "receipt": str(directory / "receipt")}
    write(directory / "source.do", source)
    write(directory / "workflow.json", workflow)
    return directory, workflow


def launch_worker(directory, spawn=subprocess.Popen):
    directory, workflow = load_workflow(directory)
    # Caller retries cannot start another worker for this workflow.
    write(directory / "launch.json", {"atEpoch": time.time(), "workflowId": workflow["workflowId"]})
    command = [sys.executable, str(Path(__file__).resolve()), "_worker", "--workflow", str(directory)]
    kwargs = {"stdin": subprocess.DEVNULL, "close_fds": True}
    if os.name == "nt":
        kwargs["creationflags"] = subprocess.CREATE_NEW_PROCESS_GROUP | subprocess.DETACHED_PROCESS
    else:
        kwargs["start_new_session"] = True
    with (directory / "worker.log").open("xb") as output:
        process = spawn(command, stdout=output, stderr=subprocess.STDOUT, **kwargs)
    write(directory / "worker-pid.json", {"pid": process.pid, "atEpoch": time.time()})
    return {"state": "submitted-to-worker", "workflow": str(directory), "workflowId": workflow["workflowId"],
        "receipt": workflow["receipt"], "sessionId": workflow["identity"]["sessionId"], "automaticRetry": False}


class BoundBridge:
    def __init__(self, bridge, directory, workflow):
        self.bridge, self.directory, self.workflow = bridge, directory, workflow

    def __getattr__(self, name):
        return getattr(self.bridge, name)

    def http_post(self, path, payload, timeout=30):
        if path != "/run-command":
            raise ValueError("worker may only submit run-command")
        if (self.directory / "stop-intent.json").exists():
            return 409, {"reasonCode": "AGENT_CANCELLED_BEFORE_POST", "payloadDispatched": False}
        ident, _ = identity(self.bridge)
        check_identity(self.workflow["identity"], ident)
        if sha256(Path(self.workflow["sourcePath"]).read_bytes()) != self.workflow["sourceSha256"]:
            return 409, {"reasonCode": "AGENT_SOURCE_CHANGED", "payloadDispatched": False}
        # Written before the HTTP call: a crash/transport timeout means unknown,
        # never proof that a POST did not happen.
        write(self.directory / "dispatch-intent.json", {"atEpoch": time.time(), "payloadSha256": sha256(json.dumps(payload).encode())})
        return self.bridge.http_post(path, payload, timeout=timeout)


def worker(directory, execute=shared.execute_once):
    directory, workflow = load_workflow(directory)
    write(directory / "worker-claim.json", {"pid": os.getpid(), "atEpoch": time.time()})
    try:
        if sha256((directory / "source.do").read_bytes()) != workflow["sourceSha256"]:
            raise RuntimeError("immutable source copy changed")
        bind(workflow["identity"]["sessionId"], workflow["stateRoot"])
        # Existing platform observation still validates installed bundle/ownership.
        os.environ.update(WS_FG_ALLOWED="0", WS_WINDOW_ALLOWED="0", WS_PHYSICAL_KEYS="0")
        d = entry.helpers()
        wrapped = SimpleNamespace(w=BoundBridge(d.w, directory, workflow), _activate_exact_pid_once=d._activate_exact_pid_once)
        binding = {"workflowId": workflow["workflowId"], "sessionId": workflow["identity"]["sessionId"],
            "generation": workflow["identity"]["generation"], "sourcePath": workflow["sourcePath"],
            "sourceSha256": workflow["sourceSha256"], "documentVersion": workflow["documentVersion"],
            "continuationOf": workflow.get("continuationOf")}
        request = {"code": entry.host.stata_file_command(directory / "source.do"), "cwd": workflow["cwd"],
            "source": "agent", "agentId": "workbench-agent", "agentName": workflow["agentName"],
            "label": workflow["workflowId"], "agentWorkflow": binding}
        with ExitStack() as stack:
            # Ordinary windows may share one VS Code profile. Serialize by the
            # pinned session, leaving an independent window's model runnable.
            lock = entry.STATE_ROOT / "runs" / workflow["identity"]["sessionId"] / "agent-execute.lock"
            stack.enter_context(entry.host.file_lock(lock, timeout=0))
            if (directory / "stop-intent.json").exists():
                result = {"verdict": "CANCELLED_BEFORE_DISPATCH", "postCount": 0}
            else:
                result = execute(wrapped, request, workflow["receipt"], workflow["timeout"], source_path=directory / "source.do")
        write(directory / "worker-result.json", {"verdict": result["verdict"], "endedAtEpoch": time.time()})
    except Exception as error:
        write(directory / "worker-result.json", {"verdict": "EXECUTION_UNCONFIRMED_NO_RETRY" if (directory / "dispatch-intent.json").exists() else "BLOCKED_NO_DISPATCH",
            "error": repr(error), "endedAtEpoch": time.time()})
    return local_status(directory)


def pause_evidence(result):
    """Preserve source attribution: API Stop is never represented as a human click."""
    if result.get("verdict") == "STOPPED_NO_RETRY":
        return {"by": "person", "generation": (result.get("after", {}).get("status") or {}).get("resetGeneration"),
            "completed": (result.get("after", {}).get("status") or {}).get("lastCompletedRun")}
    checks = result.get("stopChecks") or {}
    required = ("http500", "notStataError", "requestBound", "stoppedRunBound", "stopAfterSubmit", "restoredAfter", "readyAfter")
    if result.get("stopReportedBy") == "api" and all(checks.get(k) is True for k in required):
        return {"by": "api", "generation": (result.get("after", {}).get("status") or {}).get("resetGeneration"),
            "completed": (result.get("after", {}).get("status") or {}).get("lastCompletedRun")}
    return None


def local_status(directory):
    directory, workflow = load_workflow(directory)
    result = optional(directory / "receipt" / "result.json")
    worker_result = optional(directory / "worker-result.json")
    pause = pause_evidence(result or {})
    verdict = (result or worker_result or {}).get("verdict")
    state = "paused" if pause else {
        "PASS_VISIBLE_SHARED_RUN": "completed", "STATA_ERROR_CONFIRMED": "stata-error",
        "BLOCKED_NO_DISPATCH": "blocked", "CANCELLED_BEFORE_DISPATCH": "cancelled-before-dispatch",
        "REFUSED_NOT_DISPATCHED": "refused", "EXECUTION_UNCONFIRMED_NO_RETRY": "unknown-no-retry",
    }.get(verdict, "stop-requested" if (directory / "stop-intent.json").exists() else "pending-or-unknown")
    # Fail-closed guard refusals are independently explicit, not inferred from a timeout.
    body = (result or {}).get("response") or {}
    if body.get("payloadDispatched") is False and body.get("reasonCode") in ("AGENT_PRECONDITION_FAILED", "AGENT_CANCELLED_BEFORE_POST", "AGENT_SOURCE_CHANGED"):
        state = "refused"
    return {"workflow": str(directory), "workflowId": workflow["workflowId"], "sessionId": workflow["identity"]["sessionId"],
        "generation": workflow["identity"]["generation"], "sourceSha256": workflow["sourceSha256"],
        "state": state, "pause": pause, "receipt": workflow["receipt"], "verdict": verdict,
        "automaticRetry": False, "result": result, "worker": worker_result}


def remote_run(bridge, workflow):
    code, body = bridge.request("/agent-runs/" + workflow["workflowId"])
    if code == 404:
        return None  # Absence never proves no dispatch.
    if code != 200 or not isinstance(body.get("run"), dict):
        raise RuntimeError("workflow run binding unavailable")
    run = body["run"]
    expected = {"workflowId": workflow["workflowId"], "sessionId": workflow["identity"]["sessionId"],
        "generation": workflow["identity"]["generation"], "sourceSha256": workflow["sourceSha256"], "sourcePath": workflow["sourcePath"]}
    if any(run.get(k) != v for k, v in expected.items()) or not run.get("runId"):
        raise RuntimeError("workflow run binding mismatch")
    return run


def reconcile(directory, bridge=None):
    directory, workflow = load_workflow(directory)
    output = local_status(directory)
    if bridge is None:
        bind(workflow["identity"]["sessionId"], workflow["stateRoot"])
        bridge = entry.LocalBridge()
    ident, status = identity(bridge)
    check_identity(workflow["identity"], ident, generation=False)
    run = remote_run(bridge, workflow)
    output.update(observedIdentity=ident, status=status, originalRun=run)
    # The original receipt alone can certify success. Observations only locate
    # the original run; no resubmission and no synthetic PASS from idle state.
    return output


def stop(directory, user_action, bridge=None):
    directory, workflow = load_workflow(directory)
    output = reconcile(directory, bridge)
    if output["state"] in ("completed", "paused", "stata-error", "refused", "blocked", "cancelled-before-dispatch"):
        return output
    if not user_action.strip():
        raise ValueError("Stop requires the current user instruction")
    try:
        write(directory / "stop-intent.json", {"userAction": user_action, "atEpoch": time.time()})
    except FileExistsError:
        pass
    prior = optional(directory / "stop-response.json")
    if prior:
        return {**output, "stop": prior, "automaticRetry": False}
    run = output["originalRun"]
    if not run or output["status"].get("runId") != run["runId"] or output["status"].get("busy") is not True:
        return {**output, "state": "stop-pending-original-run", "automaticRetry": False}
    check_identity(workflow["identity"], output["observedIdentity"])
    # A durable claim precedes Stop input. Lost response -> only reconcile.
    write(directory / "stop-dispatch.json", {"runId": run["runId"], "atEpoch": time.time()})
    bridge = bridge or entry.LocalBridge()
    request = {"expectedRunId": run["runId"], "sessionId": workflow["identity"]["sessionId"], "generation": workflow["identity"]["generation"]}
    code, body = bridge.request("/agent-stop", request, timeout=10)
    response = {"http": code, "body": body}
    write(directory / "stop-response.json", response)
    return {**output, "state": "stop-requested" if code == 202 else "stop-refused", "stop": response}


def continue_workflow(directory, destination, file, user_action, bridge=None, spawn=subprocess.Popen):
    directory, parent = load_workflow(directory)
    if file is None:
        raise ValueError("continue requires an explicitly selected saved stage file")
    file = Path(file).resolve(strict=True)
    if not user_action or not user_action.strip():
        raise ValueError("continue requires a fresh explicit user instruction")
    output = reconcile(directory, bridge)
    if output["state"] != "paused" or output["pause"]["generation"] != output["observedIdentity"]["generation"]:
        raise RuntimeError("continue requires confirmed Stop restoration in this generation")
    status = output["status"]
    if status.get("busy") is not False or status.get("postRunBusy") is not False or status.get("trueReady") is not True or status.get("recovery", {}).get("required") is not False:
        raise RuntimeError("session is not ready after pause")
    completed = output["pause"].get("completed") or {}
    if not completed.get("runId") or any(status.get("lastCompletedRun", {}).get(k) != completed.get(k) for k in ("runId", "requestId")):
        raise RuntimeError("another run changed the paused session; continue needs a new workflow decision")
    bridge = bridge or entry.LocalBridge()
    doc = document_state(bridge, output["observedIdentity"], file)
    # Each paused run can be continued once; acceptance alone never reaches here.
    write(directory / "continue-intent.json", {"userAction": user_action, "atEpoch": time.time(), "destination": str(destination),
        "sourcePath": str(file), "sourceSha256": doc["sha256"], "documentVersion": doc["documentVersion"]})
    child, _ = create_workflow(destination, file, parent["cwd"], output["observedIdentity"], doc,
        parent["agentName"], parent["timeout"], parent=directory, user_action=user_action, continuation_of=completed)
    return launch_worker(child, spawn)


def propose_edit(directory, content, reason, bridge=None):
    directory, workflow = load_workflow(directory)
    if bridge is None:
        bind(workflow["identity"]["sessionId"], workflow["stateRoot"])
        bridge = entry.LocalBridge()
    ident, status = identity(bridge)
    check_identity(workflow["identity"], ident, generation=False)
    pause = local_status(directory)["pause"]
    expected_generation = pause["generation"] if pause else workflow["identity"]["generation"]
    if ident["generation"] != expected_generation:
        raise RuntimeError("session generation changed outside confirmed pause")
    if status.get("busy") is not False or status.get("postRunBusy") is not False:
        raise RuntimeError("pause and reconcile the active run before proposing an edit")
    doc = document_state(bridge, ident, workflow["sourcePath"])
    proposal_id = "edit_" + uuid.uuid4().hex
    request = {"proposalId": proposal_id, "sessionId": ident["sessionId"], "generation": ident["generation"],
        "path": workflow["sourcePath"], "expectedSha256": doc["sha256"], "documentVersion": doc["documentVersion"],
        "content": content, "reason": reason, "agentName": workflow["agentName"]}
    proposal_dir = directory / "proposals" / proposal_id
    proposal_dir.mkdir(parents=True, mode=0o700)
    write(proposal_dir / "request.json", request)
    try:
        code, body = bridge.request("/propose-edit", request, timeout=10)
        write(proposal_dir / "response.json", {"http": code, "body": body})
        return {"workflow": str(directory), "proposalId": proposal_id, "http": code, **body, "automaticRetry": False}
    except Exception as error:
        return {"workflow": str(directory), "proposalId": proposal_id, "state": "proposal-unconfirmed-query-by-id",
            "error": repr(error), "automaticRetry": False}


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--state-root", type=Path, help="explicit local registry root")
    commands = parser.add_subparsers(dest="command", required=True)
    commands.add_parser("sessions")
    status = commands.add_parser("status")
    status.add_argument("--session"); status.add_argument("--workflow", type=Path)
    run = commands.add_parser("run")
    run.add_argument("--session", required=True); run.add_argument("--file", type=Path, required=True)
    run.add_argument("--cwd", type=Path, required=True); run.add_argument("--workflow-dir", type=Path, required=True)
    run.add_argument("--agent-name", type=shared.agent_name, required=True); run.add_argument("--timeout", type=int, default=3600)
    for name in ("stop", "reconcile", "continue", "propose-edit", "_worker"):
        command = commands.add_parser(name); command.add_argument("--workflow", type=Path, required=True)
        if name in ("stop", "continue"):
            command.add_argument("--user-action", required=True, help="verbatim fresh user request; do not infer from Accept")
        if name == "continue":
            command.add_argument("--workflow-dir", type=Path, required=True)
            command.add_argument("--file", type=Path, required=True, help="explicitly selected saved stage; never inferred from parent source or line number")
        if name == "propose-edit":
            command.add_argument("--content-file", type=Path, help="omit to read proposed bytes from stdin")
            command.add_argument("--reason", required=True)
        if name == "reconcile":
            command.add_argument("--proposal-id")
    args = parser.parse_args(argv)
    if args.state_root:
        entry.STATE_ROOT = args.state_root.expanduser().resolve()
    if args.command == "sessions":
        output = {"sessions": entry.list_sessions()}
    elif args.command == "status":
        if args.workflow:
            output = local_status(args.workflow)
        else:
            if not args.session:
                parser.error("status requires --session or --workflow")
            bind(args.session); ident, state = identity(entry.LocalBridge())
            output = {"identity": ident, "status": state}
    elif args.command == "run":
        if args.timeout < 1:
            parser.error("positive timeout required")
        bind(args.session)
        bridge = entry.LocalBridge(); ident, _ = identity(bridge)
        file = args.file.resolve(strict=True)
        doc = document_state(bridge, ident, file)
        directory, _ = create_workflow(args.workflow_dir, file, args.cwd, ident, doc, args.agent_name, args.timeout)
        output = launch_worker(directory)
    elif args.command == "_worker":
        output = worker(args.workflow)
    elif args.command == "stop":
        output = stop(args.workflow, args.user_action)
    elif args.command == "continue":
        output = continue_workflow(args.workflow, args.workflow_dir, args.file, args.user_action)
    elif args.command == "propose-edit":
        content = args.content_file.read_text(encoding="utf-8") if args.content_file else sys.stdin.read()
        output = propose_edit(args.workflow, content, args.reason)
    else:
        if args.proposal_id:
            if not ID.fullmatch(args.proposal_id):
                parser.error("invalid proposal ID")
            directory, wf = load_workflow(args.workflow); bind(wf["identity"]["sessionId"], wf["stateRoot"])
            bridge = entry.LocalBridge(); ident, _ = identity(bridge); check_identity(wf["identity"], ident, generation=False)
            code, body = bridge.request("/proposals/" + args.proposal_id)
            output = {"workflow": str(directory), "http": code, **body, "automaticRetry": False}
        else:
            output = reconcile(args.workflow)
    print(json.dumps(output, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as error:
        print(json.dumps({"state": "blocked-or-unconfirmed", "error": repr(error), "automaticRetry": False}))
        sys.exit(2)
