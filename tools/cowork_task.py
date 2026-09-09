"""Write-once source versions and fail-closed sequential task orchestration.

No Stata or GUI calls at import time. Each stage has independent receipts and
explicit checkpoints. The caller supplies the verified single-dispatch client.
"""
import hashlib
import json
import os
from pathlib import Path
import re
import time


def identity(path):
    path = Path(path).resolve(strict=True)
    if not path.is_file():
        raise ValueError("regular file required: " + str(path))
    raw = path.read_bytes()
    return {"path": str(path), "bytes": len(raw), "sha256": hashlib.sha256(raw).hexdigest()}


def write_once(path, raw):
    path = Path(path)
    if not isinstance(raw, bytes):
        raw = (json.dumps(raw, ensure_ascii=False, indent=2) + "\n").encode()
    fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
    with os.fdopen(fd, "wb") as handle:
        handle.write(raw)
        handle.flush()
        os.fsync(handle.fileno())


def safe_stata_path(path):
    value = str(Path(path).resolve())
    if any(c in value for c in ('"', "\r", "\n", "`", "$")):
        raise ValueError("unsupported Stata path quoting: " + value)
    return value


def freeze_program(source, directory, dependencies=()):
    """Preserve relative code layout. Dependencies may only be beneath source.parent.

    Scripts should use explicit data checkpoint paths; dynamic includes must be
    declared. The original source is never edited or made read-only.
    """
    source = Path(source).resolve(strict=True)
    if source.suffix.lower() != ".do":
        raise ValueError("annotated .do required")
    base, directory = source.parent, Path(directory).resolve()
    directory.mkdir(parents=True, exist_ok=False, mode=0o700)
    files = [source] + [Path(p).resolve(strict=True) for p in dependencies]
    if len(set(files)) != len(files):
        raise ValueError("duplicate source dependency")
    records = []
    for p in files:
        relative = p.relative_to(base)
        raw = p.read_bytes()
        # Stata uses UTF-8 saved code; invalid encoding cannot be visibly matched.
        raw.decode("utf8")
        dest = directory / relative
        safe_stata_path(dest)
        dest.parent.mkdir(parents=True, exist_ok=True)
        write_once(dest, raw)
        records.append({"source": identity(p), "execution": identity(dest)})
        if records[-1]["source"]["sha256"] != records[-1]["execution"]["sha256"]:
            raise RuntimeError("source changed while freezing")
    for p in files:
        record = next(r for r in records if r["source"]["path"] == str(p))
        if identity(p) != record["source"]:
            raise RuntimeError("source changed while freezing dependencies")
    result = {"program": str(directory / source.name), "source": str(source), "files": records,
              "sha256": records[0]["execution"]["sha256"]}
    write_once(directory / "source-manifest.json", result)
    return result


def frozen_unchanged(frozen):
    return all(identity(r["source"]["path"]) == r["source"]
               and identity(r["execution"]["path"]) == r["execution"] for r in frozen["files"])


def load_manifest(path):
    path = Path(path).resolve(strict=True)
    manifest = json.loads(path.read_bytes())
    if manifest.get("schema") != "stata-cowork-task/1":
        raise ValueError("unsupported task schema")
    if not re.fullmatch(r"[a-zA-Z0-9_-]{1,80}", manifest.get("taskId", "")):
        raise ValueError("invalid taskId")
    stages, seen = manifest.get("stages"), set()
    if not isinstance(stages, list) or not stages:
        raise ValueError("nonempty stages required")
    for stage in stages:
        key = stage.get("id")
        if not isinstance(key, str) or not re.fullmatch(r"[a-zA-Z0-9_-]{1,80}", key) or key in seen:
            raise ValueError("stage id invalid or duplicated")
        if not set(stage.get("requires", [])).issubset(seen):
            raise ValueError("dependencies must refer to preceding stages")
        seen.add(key)
        for field in ("program", "cwd"):
            value = Path(stage[field])
            if not value.is_absolute():
                value = path.parent / value
            stage[field] = safe_stata_path(value.resolve(strict=True))
        if not Path(stage["cwd"]).is_dir():
            raise ValueError("cwd not a directory")
        arguments = stage.get("arguments", [])
        if not isinstance(arguments, list) or any(not isinstance(x, str) or any(c in x for c in ('"', "\r", "\n", "`", "$")) for x in arguments):
            raise ValueError("invalid program arguments")
        stage["arguments"] = arguments
        for field in ("inputs", "outputs", "dependencies"):
            values = stage.get(field, [])
            if not isinstance(values, list) or any(not isinstance(p, str) for p in values):
                raise ValueError("path list required: " + field)
            stage[field] = [safe_stata_path(Path(p) if Path(p).is_absolute() else path.parent / p) for p in values]
        if not stage["outputs"]:
            raise ValueError("declared output checkpoints required")
        if set(stage["outputs"]) & set(stage["inputs"]):
            raise ValueError("cannot overwrite stage inputs")
    return manifest


def completed_prefix(manifest, prior_directory):
    """Reuse only a byte-verified completed prefix; never resend an uncertain stage."""
    prior = Path(prior_directory).resolve(strict=True)
    old_manifest = json.loads((prior / "task.json").read_bytes())
    old_result = json.loads((prior / "result.json").read_bytes())
    if old_manifest.get("taskId") != manifest["taskId"] or old_result.get("taskId") != manifest["taskId"]:
        raise ValueError("resume task identity mismatch")
    rows = []
    for index, old_row in enumerate(old_result.get("stages", [])):
        if old_row.get("checkpointsVerified") is not True:
            raise ValueError("prior stage has an incomplete/uncertain outcome; inspect and reconcile it, never resend through resume")
        if index >= len(manifest["stages"]) or old_manifest["stages"][index] != manifest["stages"][index]:
            raise ValueError("completed stage specification changed; do not reuse its outputs")
        if old_row.get("id") != manifest["stages"][index]["id"] or old_row.get("verdict") != "PASS_VISIBLE_COWORK_RUN":
            raise ValueError("completed stage identity/verdict mismatch")
        receipt = old_row.get("receiptIdentity") or {}
        if not receipt or identity(receipt["path"]) != receipt:
            raise ValueError("completed receipt changed or unmeasured")
        for record in old_row.get("outputs", []) + old_row.get("inputs", []):
            if identity(record["path"]) != record:
                raise ValueError("completed checkpoint drift")
        if [r["path"] for r in old_row.get("outputs", [])] != manifest["stages"][index]["outputs"]:
            raise ValueError("completed output domain mismatch")
        frozen = old_row.get("frozen")
        if not frozen or not frozen_unchanged(frozen):
            raise ValueError("completed source version drift")
        rows.append({**old_row, "reusedWithoutDispatch": True, "reusedFrom": str(prior)})
    return rows


def run_task(manifest, directory, dispatch, control, timeout=3600, resume_from=None):
    root = Path(directory).resolve()
    root.mkdir(parents=True, exist_ok=False, mode=0o700)
    write_once(root / "task.json", manifest)
    result = {"schema": "stata-cowork-task-result/1", "taskId": manifest["taskId"],
              "verdict": "INCOMPLETE", "stages": [], "startedAt": time.time(), "error": None}
    try:
        if resume_from:
            result["stages"] = completed_prefix(manifest, resume_from)
            result["resumeFrom"] = str(Path(resume_from).resolve(strict=True))
        result["reusedStageCount"] = len(result["stages"])
        for stage in manifest["stages"][len(result["stages"]):]:
            if control().get("paused") is not False:
                raise RuntimeError("paused-or-control-unmeasured; explicit resume then fresh invocation required")
            if any(Path(p).exists() for p in stage["outputs"]):
                raise RuntimeError("output already exists; choose new versioned paths")
            inputs = [identity(p) for p in stage["inputs"]]
            folder = root / stage["id"]
            folder.mkdir(mode=0o700)
            frozen = freeze_program(stage["program"], folder / "execution", stage["dependencies"])
            write_once(folder / "inputs.json", inputs)
            request = {"code": 'do "' + frozen["program"] + '"', "cwd": stage["cwd"],
                "source": "agent", "agentId": "visible-cowork-client", "label": stage.get("label", stage["id"]),
                "cowork": {**frozen, "task": manifest["taskId"], "arguments": stage.get("arguments", [])}}
            request["code"] += ''.join(' "' + arg + '"' for arg in stage.get("arguments", []))
            if not frozen_unchanged(frozen):
                raise RuntimeError("source changed before stage")
            outcome = dispatch(request, folder / "receipt", timeout)
            row = {"id": stage["id"], "receipt": str(folder / "receipt/result.json"),
                   "executionVerdict": outcome.get("executionVerdict"), "visibilityVerdict": outcome.get("visibilityVerdict"),
                   "verdict": outcome.get("verdict"), "outputs": [], "inputs": inputs,
                   "frozen": frozen, "checkpointsVerified": False}
            result["stages"].append(row)
            if outcome.get("verdict") != "PASS_VISIBLE_COWORK_RUN":
                raise RuntimeError("stage did not pass; dependent stages were not dispatched")
            if [identity(p["path"]) for p in inputs] != inputs:
                raise RuntimeError("stage mutated an input checkpoint")
            row["outputs"] = [identity(p) for p in stage["outputs"]]
            write_once(folder / "outputs.json", row["outputs"])
            if not frozen_unchanged(frozen):
                raise RuntimeError("source changed during stage; human/agent reconciliation required")
            row["receiptIdentity"] = identity(folder / "receipt/result.json")
            row["checkpointsVerified"] = True
        result["verdict"] = "PASS_ALL_DECLARED_STAGES"
    except Exception as e:
        result["error"] = str(e)
    finally:
        result["endedAt"] = time.time()
        write_once(root / "result.json", result)
    return result
