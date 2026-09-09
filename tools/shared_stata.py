"""Single visible AI dispatch to the verified, existing Workbench session."""
import argparse
from contextlib import ExitStack
import fcntl
import hashlib
import json
import os
from pathlib import Path
import sys
import time
import uuid
import re

import verified_workbench as entry
import cowork_task


def write_once(path, data):
    raw = data if isinstance(data, bytes) else (json.dumps(data, ensure_ascii=False, indent=2) + "\n").encode()
    fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
    with os.fdopen(fd, "wb") as handle:
        handle.write(raw)
        handle.flush()
        os.fsync(handle.fileno())


def _valid_backend_pids(value):
    return (isinstance(value, list) and bool(value)
            and all(type(pid) is int and pid > 0 for pid in value)
            and len(set(value)) == len(value))


def ready(instance):
    s = instance.get("status") or {}
    try:
        entry.permissions.require_window_observation(instance)
    except entry.permissions.WindowObservationError:
        return False
    return (instance.get("identityOk") is True and type(instance.get("axWindowCount")) is int
            and instance["axWindowCount"] == 1 and s.get("busy") is False
            and s.get("postRunBusy") is False and s.get("trueReady") is True
            and isinstance(s.get("recovery"), dict) and s["recovery"].get("required") is False
            and _valid_backend_pids(s.get("ownedBackendPids")))


def completion_checks(request, http, body, before, after):
    body = body if isinstance(body, dict) else {}
    s = after.get("status") or {}
    completed = s.get("lastCompletedRun") or {}
    rid = body.get("runId")
    request_id = body.get("requestId")
    lifecycle = body.get("lifecycle") or {}
    client_token = request.get("clientToken")
    request_bound = (isinstance(request_id, str) and bool(request_id)
        and lifecycle.get("requestId") == request_id
        and completed.get("requestId") == request_id
        and lifecycle.get("runId") == rid
        and lifecycle.get("sourceMode") == "agent"
        and request_id != (before["status"].get("lastCompletedRun") or {}).get("requestId")) if client_token else (request_id == request.get("runId"))
    return {
        "http200": type(http) is int and http == 200,
        "responseOk": body.get("ok") is True,
        "requestBound": request_bound,
        "newRunId": isinstance(rid, str) and bool(rid) and rid != before["status"].get("runId"),
        "responseRcZero": type(body.get("rc")) is int and body["rc"] == 0,
        "sameLauncher": before.get("launcherPid") == after.get("launcherPid"),
        "sameBridgeOwner": before.get("owner") == after.get("owner"),
        "sameStataBackend": _valid_backend_pids(before["status"].get("ownedBackendPids"))
            and before["status"]["ownedBackendPids"] == s.get("ownedBackendPids"),
        "readyAfter": ready(after),
        "completedRunBound": isinstance(rid, str) and completed.get("runId") == rid,
        "currentLifecycle": s.get("lifecycleVersion") == "rc7.27",
        "completedLifecycle": completed.get("lifecycleVersion") == "rc7.27",
        "currentMarker": s.get("completionMarkerVerified") is True,
        "currentPerRunMarker": s.get("perRunCompletionMarkerVerified") is True,
        "currentEvidenceIntact": "perRunEvidenceFailure" in s and s["perRunEvidenceFailure"] is None,
        "completedMarker": completed.get("completionMarkerVerified") is True,
        "completedPerRunMarker": completed.get("perRunCompletionMarkerVerified") is True,
        "completedEvidenceIntact": "perRunEvidenceFailure" in completed and completed["perRunEvidenceFailure"] is None,
    }


def decode_response(body):
    """Preserve raw transport bytes separately from decoded legacy HTTP JSON."""
    if isinstance(body, dict) and isinstance(body.get("_httperror"), str):
        try:
            parsed = json.loads(body["_httperror"])
            if isinstance(parsed, dict):
                return parsed
        except (ValueError, TypeError):
            pass
    return body if isinstance(body, dict) else {}


def output_lines(log):
    # Preserve echoed commands. Strip only leading producer-owned SMCL styles,
    # not arbitrary braces or text that could fabricate an executed marker.
    return [re.sub(r"^(?:\{(?:res|txt|com|err|sf|bf|reset)\})+", "", line.strip()).strip()
            for line in log.decode("utf8", errors="replace").splitlines()]


def execution_source_evidence(after, cowork):
    """A displayed input hash is not proof of literal post-compatibility bytes."""
    compatibility = (after.get("status") or {}).get("sourceCompatibility")
    if not isinstance(compatibility, dict) or not isinstance(compatibility.get("referencedDoCopies"), list):
        return {"verdict": "UNMEASURED", "copies": []}
    request_id = (after.get("status") or {}).get("requestId")
    if not isinstance(request_id, str) or not request_id or compatibility.get("runId") != request_id or compatibility.get("sourceMode") != "agent":
        return {"verdict": "UNMEASURED", "copies": [], "error": "compatibility receipt not bound to current agent request"}
    if compatibility.get("error"):
        return {"verdict": "UNMEASURED", "copies": [], "error": compatibility["error"]}
    copies = []
    for copy in compatibility["referencedDoCopies"]:
        record = {"diagnostics": copy}
        try:
            record["original"] = cowork_task.identity(copy["sourcePath"])
            record["executed"] = cowork_task.identity(copy["tempPath"])
            record["sourceIntact"] = copy.get("sourceIntact") is True and copy.get("sourceSha256") == record["original"]["sha256"]
        except Exception as error:
            record["error"] = repr(error)
        copies.append(record)
    # Even a semantically harmless name() protection requires a separately shown
    # transformed version before an exact-byte co-working claim can be made.
    return {"verdict": "RUNTIME_TRANSFORMED_NOT_DISPLAYED" if copies else "NO_REFERENCED_COPY_REWRITE_REPORTED",
            "copies": copies, "diagnostics": compatibility}


def failure_evidence(body, before, after, log, start_marker):
    """An r(N) string alone never certifies a Stata failure."""
    state = body.get("state") if isinstance(body.get("state"), dict) else {}
    life = body.get("lifecycle") if isinstance(body.get("lifecycle"), dict) else state
    current = after.get("status") or {}
    rid, req = life.get("runId"), life.get("requestId")
    match = re.fullmatch(r"Stata error r\(([1-9][0-9]*)\)", str(body.get("error", "")))
    rc = int(match[1]) if match else None
    lines = output_lines(log)
    checks = {
        "responseFailed": body.get("ok") is False,
        "newRunBound": isinstance(rid, str) and bool(rid) and rid != before["status"].get("runId") and rid == current.get("runId"),
        "requestBound": isinstance(req, str) and bool(req) and req == current.get("requestId") and req != before["status"].get("requestId"),
        "sameBackend": _valid_backend_pids(current.get("ownedBackendPids")) and current.get("ownedBackendPids") == before["status"].get("ownedBackendPids"),
        "sameOwner": before.get("owner") is not None and before.get("owner") == after.get("owner"),
        "failedPhase": life.get("phase") == "failed" or life.get("status") == "failed",
        "executedClientStartMarker": bool(start_marker) and start_marker in lines,
        "rawStataError": rc is not None and ("r(" + str(rc) + ");") in lines,
        "settled": ready(after),
    }
    return {"confirmed": all(checks.values()), "checks": checks, "rc": rc, "runId": rid, "requestId": req}


def execute_once(d, request, receipt, timeout=3600, observe=entry.observe, sleep=time.sleep):
    receipt = Path(receipt)
    receipt.mkdir(mode=0o700, parents=True, exist_ok=False)
    result = {"verdict": "BLOCKED_NO_DISPATCH", "postCount": 0, "retryCount": 0,
              "executionVerdict": "NOT_DISPATCHED", "visibilityVerdict": "NOT_MEASURED",
              "replayVerdict": "NOT_TESTED", "taskCompletionVerdict": "NOT_ASSESSED",
              "sourceExecutionVerdict": "NOT_MEASURED",
              "request": request, "error": None, "startedAtEpoch": time.time()}
    prepared = None
    try:
        before = observe(d)
        result["before"] = before
        entry.permissions.require_window_observation(before)
        if not ready(before):
            raise RuntimeError("existing session is not ready; no launch, reset or dispatch")
        write_once(receipt / "request.json", request)
        write_once(receipt / "before.json", before)
        payload = dict(request)
        cowork = payload.pop("cowork", None)
        token = uuid.uuid4().hex
        payload.pop("runId", None)
        payload.pop("clientToken", None)
        marker = "___VERIFIED_CLIENT_" + token + "___"
        payload["code"] = request["code"] + '\n#delimit cr\ndisplay as text "' + marker + '"\n'
        start_marker = marker + "START" if cowork else None
        if cowork:
            if not cowork_task.frozen_unchanged(cowork):
                raise RuntimeError("saved source or execution snapshot changed")
            http_prepare, prepared = d.w.http_post("/cowork/prepare", {**cowork, "label": request.get("label"), "cwd": request.get("cwd")}, timeout=15)
            write_once(receipt / "visibility-prepare.json", {"http": http_prepare, "body": prepared})
            if http_prepare != 200 or not isinstance(prepared, dict) or prepared.get("ok") is not True or prepared.get("layout", {}).get("ok") is not True:
                raise RuntimeError("visible co-working unavailable; no legacy fallback")
            ticket = prepared.get("ticket") or {}
            compilation = ticket.get("sourceCompilation") or {}
            if ticket.get("inputProgram") != cowork["program"] or ticket.get("inputSha256") != cowork["sha256"] or compilation.get("stable") is not True:
                raise RuntimeError("prepared runtime source not bound to requested snapshot")
            runtime_source = cowork_task.identity(ticket["program"])
            if runtime_source["sha256"] != ticket.get("sha256"):
                raise RuntimeError("prepared runtime source changed")
            write_once(receipt / "runtime-execution.do", Path(runtime_source["path"]).read_bytes())
            result["runtimeSource"] = runtime_source
            result["sourceCompilation"] = compilation
            payload["code"] = 'do "' + cowork_task.safe_stata_path(ticket["program"]) + '"' + ''.join(' "' + x + '"' for x in cowork.get("arguments", [])) + '\n#delimit cr\ndisplay as text "' + marker + '"\n'
            payload["coworkToken"] = prepared["token"]
            payload["coworkMarker"] = marker
            payload["code"] = 'display as text "' + start_marker + '"\n' + payload["code"]
        payload["source"] = "agent"
        result["clientToken"] = token
        result["wireRequest"] = payload
        write_once(receipt / "wire-request.json", payload)
        result["postCount"] = 1
        result["verdict"] = "EXECUTION_UNCONFIRMED_NO_RETRY"
        result["executionVerdict"] = "UNKNOWN_NO_RETRY"
        http, body = d.w.http_post("/run-command", payload, timeout=timeout)
        raw_body, body = body, decode_response(body)
        result.update(http=http, response=body)
        write_once(receipt / "response.json", {"http": http, "body": raw_body, "decoded": body})
        log = b""
        log_path = body.get("logPath") or (body.get("state") or {}).get("logPath")
        if isinstance(log_path, str) and Path(log_path).is_absolute() and Path(log_path).is_file():
            log = Path(log_path).read_bytes()
            write_once(receipt / "run.log", log)
            result["log"] = {"originalPath": log_path, "sha256": hashlib.sha256(log).hexdigest(), "bytes": len(log)}
        after = observe(d)
        # Only observe completion settlement. Never repeat the POST.
        for _ in range(30):
            if ready(after) or http != 200 or after.get("windowObservation", {}).get("ok") is not True:
                break
            sleep(1)
            after = observe(d)
            if after.get("windowObservation", {}).get("ok") is not True:
                break
        result["after"] = after
        if cowork:
            source_evidence = execution_source_evidence(after, cowork)
            result["sourceExecutionEvidence"] = source_evidence
            result["sourceExecutionVerdict"] = source_evidence["verdict"]
            write_once(receipt / "execution-source.json", source_evidence)
        entry.permissions.require_window_observation(after)
        checks = completion_checks({"clientToken": token}, http, body, before, after)
        result["checks"] = checks
        result["failedChecks"] = [k for k, v in checks.items() if v is not True]
        if all(checks.values()):
            path = Path(body.get("logPath") or "")
            if not path.is_file():
                raise RuntimeError("completed run log missing")
            log = path.read_bytes()
            rid = body["runId"]
            if not log or ("___CODEX_RUN_DONE_" + rid + "___") not in output_lines(log):
                raise RuntimeError("exact run completion marker absent from raw log")
            if marker not in output_lines(log):
                raise RuntimeError("client request marker absent from raw log")
            if result.get("log", {}).get("sha256") != hashlib.sha256(log).hexdigest():
                raise RuntimeError("log changed after response; original captured evidence retained")
            result["executionVerdict"] = "PASS_CONFIRMED"
            result["verdict"] = "PASS_VISIBLE_SHARED_RUN"
        else:
            failure = failure_evidence(body, before, after, log, start_marker)
            result["failureEvidence"] = failure
            if failure["confirmed"]:
                result["executionVerdict"] = "STATA_ERROR_CONFIRMED"
                result["verdict"] = "STATA_ERROR_CONFIRMED_NO_RETRY"
    except Exception as exc:
        result["error"] = repr(exc)
        result["windowObservation"] = getattr(exc, "observation", None)
    finally:
        if isinstance(prepared, dict) and prepared.get("ok") is True and result["postCount"] == 1:
            try:
                end_http, end = d.w.http_post("/cowork/finish", {"token": prepared["token"]}, timeout=10)
                write_once(receipt / "visibility-finish.json", {"http": end_http, "body": end})
                result["visibilityVerdict"] = (end.get("ticket") or {}).get("visibilityVerdict", "UNKNOWN") if end_http == 200 else "UNKNOWN"
            except Exception as exc:
                result["visibilityVerdict"] = "UNKNOWN"
                result["visibilityError"] = repr(exc)
            if result["verdict"] == "PASS_VISIBLE_SHARED_RUN":
                if result["sourceExecutionVerdict"] != "NO_REFERENCED_COPY_REWRITE_REPORTED":
                    result["verdict"] = "EXECUTED_SOURCE_IDENTITY_NOT_CERTIFIED"
                else:
                    result["verdict"] = "PASS_VISIBLE_COWORK_RUN" if result["visibilityVerdict"] == "OBSERVED_VISIBLE" else "EXECUTED_WITH_VISIBILITY_INTERRUPTION"
        result["endedAtEpoch"] = time.time()
        write_once(receipt / "result.json", result)
    return result


def main():
    parser = argparse.ArgumentParser()
    source = parser.add_mutually_exclusive_group(required=True)
    source.add_argument("--code")
    source.add_argument("--file", type=Path)
    source.add_argument("--task", type=Path, help="sequential annotated stages with explicit checkpoint inputs/outputs")
    source.add_argument("--control", choices=("pause", "resume", "cancel", "status"))
    parser.add_argument("--diagnostic", action="store_true", help="transport-only; cannot certify visible co-working")
    parser.add_argument("--cwd", type=Path, default=Path.cwd())
    parser.add_argument("--receipt-dir", type=Path)
    parser.add_argument("--timeout", type=int, default=3600)
    parser.add_argument("--resume-from", type=Path, help="with --task: reuse only a verified completed prefix; never retry unknown execution")
    args = parser.parse_args()
    if args.resume_from and not args.task:
        parser.error("--resume-from requires --task")
    if args.timeout < 1 or not args.cwd.is_dir():
        parser.error("positive timeout and existing cwd required")
    os.environ.update(WS_FG_ALLOWED="0", WS_WINDOW_ALLOWED="0", WS_PHYSICAL_KEYS="0")
    d = entry.helpers()
    if args.control:
        response = d.w.request("/cowork/status") if args.control == "status" else d.w.http_post("/cowork/control", {"action": args.control})
        print(json.dumps({"http": response[0], "body": response[1]}, ensure_ascii=False))
        return 0 if response[0] == 200 else 2
    token = "shared_" + uuid.uuid4().hex
    receipt = args.receipt_dir or Path.cwd() / ".stata-receipts" / token
    if args.task:
        manifest = cowork_task.load_manifest(args.task)
        with ExitStack() as stack:
            for lock_path in ("/private/tmp/stata-workbench-broad-rc739-targeted.lock", "/private/tmp/stata-workbench-shared-client.lock"):
                handle = stack.enter_context(open(lock_path, "a+"))
                fcntl.flock(handle, fcntl.LOCK_EX | fcntl.LOCK_NB)
            result = cowork_task.run_task(manifest, receipt,
                lambda request, target, timeout: execute_once(d, request, target, timeout),
                lambda: d.w.request("/cowork/status")[1], args.timeout, resume_from=args.resume_from)
        print(json.dumps({"verdict": result["verdict"], "receipt": str(receipt), "error": result["error"]}, ensure_ascii=False))
        return 0 if result["verdict"] == "PASS_ALL_DECLARED_STAGES" else 2
    if args.file:
        path = args.file.resolve(strict=True)
        if not path.is_file() or '"' in str(path) or "\n" in str(path):
            parser.error("file must be regular and contain no quote/newline in its path")
        code = 'do "' + str(path) + '"'
    else:
        code = args.code
    if not code or not code.strip():
        parser.error("empty code is not an execution")
    request = {"code": code, "cwd": str(args.cwd.resolve()),
               "source": "agent", "agentId": "verified-shared-session-client", "label": "Shared session AI run"}
    if not args.diagnostic:
        sources = receipt.parent / (receipt.name + "-source")
        if args.file:
            original = args.file
        else:
            generated = receipt.parent / (receipt.name + "-draft")
            generated.mkdir(parents=True, mode=0o700, exist_ok=False)
            original = generated / "agent-stage.do"
            write_once(original, ('* Agent-generated visible stage. No execution yet.\n' + code + '\n').encode())
        frozen = cowork_task.freeze_program(original, sources)
        request.update(code='do "' + frozen["program"] + '"', cowork=frozen)
    with ExitStack() as stack:
        for lock_path in ("/private/tmp/stata-workbench-broad-rc739-targeted.lock",
                          "/private/tmp/stata-workbench-shared-client.lock"):
            handle = stack.enter_context(open(lock_path, "a+"))
            fcntl.flock(handle, fcntl.LOCK_EX | fcntl.LOCK_NB)
        result = execute_once(d, request, receipt, args.timeout)
    print(json.dumps({"verdict": result["verdict"], "postCount": result["postCount"], "retryCount": 0,
                      "runId": (result.get("response") or {}).get("runId"), "receipt": str(receipt),
                      "error": result["error"], "failedChecks": result.get("failedChecks"),
                      "windowObservation": result.get("windowObservation")}, ensure_ascii=False))
    return 0 if result["verdict"] in ("PASS_VISIBLE_SHARED_RUN", "PASS_VISIBLE_COWORK_RUN") else 2


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as exc:
        print(json.dumps({"verdict": "BLOCKED", "error": repr(exc), "automaticRetry": False}))
        sys.exit(2)
