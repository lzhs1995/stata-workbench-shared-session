#!/usr/bin/env python3
"""Inspect/install the exact daily VSIX without closing apps or editing host configs."""
import argparse
import hashlib
import io
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import zipfile

import workbench_platform as host

EXTENSION_ID = "lzhs1995.stata-workbench-shared-session"
VERSION = "0.2.0"
RECEIPT_SCHEMA = "stata-workbench-install/1"
COPY_NAME = "verified-candidate.vsix"


def runtime_root(platform=sys.platform, home=None, env=None):
    home = Path.home() if home is None else Path(home)
    env = os.environ if env is None else env
    if env.get("MCP_STATA_RUNTIME_ROOT"):
        root = Path(env["MCP_STATA_RUNTIME_ROOT"])
        if not root.is_absolute():
            raise ValueError("MCP_STATA_RUNTIME_ROOT must be absolute")
        return root
    if platform == "win32":
        return Path(env.get("LOCALAPPDATA", str(home / "AppData/Local"))) / "stata-workbench/mcp-stata-1.26.1"
    return home / ".local/share/stata-workbench/mcp-stata-1.26.1"


def inspect_runtime(root, platform=sys.platform, run=subprocess.run):
    candidates = [root / "Scripts/python.exe", root / "python.exe"] if platform == "win32" else [root / "bin/python3", root / "bin/python"]
    python = next((p for p in candidates if p.is_file()), None)
    if not python:
        return {"ready": False, "reason": "RUNTIME_SOURCE_MISSING", "root": str(root)}
    # Metadata lookup does not import mcp_stata or initialize licensed Stata.
    probe = "import importlib.metadata,json; print(json.dumps({x:importlib.metadata.version(x) for x in ('mcp-stata','mcp')}))"
    result = run([str(python), "-I", "-B", "-c", probe], capture_output=True, text=True, timeout=20)
    try:
        versions = json.loads(result.stdout)
        ready = result.returncode == 0 and versions["mcp-stata"] == "1.26.1" and versions["mcp"].split(".")[0] == "1"
    except (ValueError, KeyError):
        versions, ready = {}, False
    return {"ready": ready, "root": str(root), "python": str(python), "versions": versions,
            "reason": None if ready else "RUNTIME_DEPENDENCIES_MISMATCH"}


def verify_vsix(file, expected_sha):
    # Read the source once: hash, ZIP inspection and installation all consume
    # this snapshot, even if the caller replaces the original path afterwards.
    data = Path(file).read_bytes()
    actual = hashlib.sha256(data).hexdigest()
    if actual != expected_sha:
        raise ValueError("VSIX_SHA_MISMATCH")
    with zipfile.ZipFile(io.BytesIO(data)) as archive:
        names = archive.namelist()
        if len(names) != len(set(names)):
            raise ValueError("VSIX_DUPLICATE_MEMBER")
        package = json.loads(archive.read("extension/package.json"))
        if not isinstance(package, dict) or (package.get("publisher"), package.get("name"), package.get("version")) != (
                "lzhs1995", "stata-workbench-shared-session", VERSION):
            raise ValueError("VSIX_IDENTITY_MISMATCH")
        required = ["tools/workbench_agent.py", "scripts/window_session_core.js", "scripts/backend_shutdown_core.js", "dist/extension.js"]
        for name in required:
            if "extension/" + name not in names:
                raise ValueError("VSIX_RUNTIME_MISSING: " + name)
        hashes = {}
        for name in names:
            if not name.startswith("extension/") or name.endswith("/"):
                continue
            relative = name[len("extension/"):]
            if any(part in ("", ".", "..") for part in relative.split("/")) or "\\" in relative or ":" in relative:
                raise ValueError("VSIX_UNSAFE_MEMBER: " + name)
            hashes[relative] = hashlib.sha256(archive.read(name)).hexdigest()
    return {"bytes": data, "package": package, "hashes": hashes}


def _launcher_targets(shim, suffix):
    """Read literal launcher paths, without cmd.exe or environment expansion."""
    content = host._cmd_text(shim)
    content = "\n".join(line for line in content.splitlines()
                        if not line.lstrip().lower().startswith(("rem ", "@rem ", "::")))
    pattern = r'"([^"\r\n]*' + re.escape(suffix) + r')"'
    literals = re.findall(pattern, content, re.IGNORECASE)
    if suffix.lower() in re.sub(pattern, "", content, flags=re.IGNORECASE).lower():
        raise ValueError("WINDOWS_CODE_LAUNCHER_UNRESOLVED: " + str(shim))
    targets = set()
    for raw in literals:
        raw = raw.replace("\\", "/")
        if raw.lower().startswith("%~dp0"):
            candidate = shim.parent / raw[5:].lstrip("/")
        elif Path(raw).is_absolute():
            candidate = Path(raw)
        elif raw.startswith(("../", "./")):
            candidate = shim.parent / raw
        else:
            raise ValueError("WINDOWS_CODE_LAUNCHER_UNRESOLVED: " + str(shim))
        if "%" in str(candidate):
            raise ValueError("WINDOWS_CODE_LAUNCHER_UNRESOLVED: " + str(shim))
        target = candidate.resolve(strict=True)
        if not target.is_file():
            raise ValueError("WINDOWS_CODE_LAUNCHER_TARGET_MISSING: " + str(target))
        targets.add(target)
    if len(targets) > 1:
        raise ValueError("WINDOWS_CODE_LAUNCHER_AMBIGUOUS: " + str(shim))
    return targets


def code_cli_command(code, platform=None):
    """Resolve install/locate CLI separately from the host's GUI launcher."""
    platform = sys.platform if platform is None else platform
    if platform != "win32":
        return host.code_launch_command(code, platform), {}
    configured = Path(code).expanduser().resolve(strict=True)
    supplied_shim = configured if configured.suffix.lower() in (".cmd", ".bat") else None
    if supplied_shim:
        targets = _launcher_targets(supplied_shim, "Code.exe")
        if not targets:
            raise ValueError("WINDOWS_CODE_EXECUTABLE_UNRESOLVED")
        executable = next(iter(targets))
    else:
        executable = configured
    if executable.name.lower() != "code.exe" or not executable.is_file():
        raise ValueError("WINDOWS_CODE_EXECUTABLE_UNRESOLVED")
    base = executable.parent
    launchers = list(dict.fromkeys(p for p in (supplied_shim, base / "bin/code.cmd") if p and p.is_file()))
    declared = set()
    for launcher in launchers:
        targets = _launcher_targets(launcher, "Code.exe")
        if targets and targets != {executable}:
            raise ValueError("WINDOWS_CODE_LAUNCHER_EXECUTABLE_MISMATCH")
        declared.update(_launcher_targets(launcher, "cli.js"))
    if len(declared) > 1:
        raise ValueError("WINDOWS_CODE_CLI_AMBIGUOUS")
    if declared:
        cli = next(iter(declared))
    else:
        # A unique on-disk layout is usable when no launcher declares a target.
        candidates = {p.resolve() for p in [base / "resources/app/out/cli.js", *base.glob("*/resources/app/out/cli.js")]
                      if p.is_file()}
        if len(candidates) != 1:
            raise ValueError("WINDOWS_CODE_CLI_MISSING_OR_AMBIGUOUS")
        cli = candidates.pop()
    relative = cli.relative_to(base).parts
    if len(relative) not in (4, 5) or tuple(x.lower() for x in relative[-4:]) != ("resources", "app", "out", "cli.js"):
        raise ValueError("WINDOWS_CODE_CLI_LAYOUT_UNRESOLVED")
    return [str(executable), str(cli)], {"ELECTRON_RUN_AS_NODE": "1", "VSCODE_DEV": ""}


def _write_once(path, data):
    """Exclusive, flushed receipt writes; never replace an earlier attempt."""
    with os.fdopen(os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600), "wb") as stream:
        stream.write(data)
        stream.flush()
        os.fsync(stream.fileno())
    if os.name != "nt":
        descriptor = os.open(Path(path).parent, os.O_RDONLY)
        try:
            os.fsync(descriptor)
        finally:
            os.close(descriptor)


def _write_json(path, value):
    _write_once(path, (json.dumps(value, ensure_ascii=False, indent=2) + "\n").encode("utf-8"))


def _output_bytes(value):
    return value if isinstance(value, bytes) else (value or "").encode("utf-8", errors="backslashreplace")


def _save_output(receipt, label, completed):
    errors = []
    for suffix in ("stdout", "stderr"):
        try:
            _write_once(receipt / (label + "." + suffix), _output_bytes(getattr(completed, suffix, None)))
        except OSError as exc:
            errors.append({"file": label + "." + suffix, "errorType": type(exc).__name__, "error": str(exc)})
    return errors


def _manifest_content(package):
    if not isinstance(package, dict):
        raise ValueError("INSTALLED_PACKAGE_NOT_OBJECT")
    # Canonical JSON also distinguishes booleans from numbers (True == 1 in
    # Python). Only the top-level field written by Code is exempted.
    return json.dumps({k: v for k, v in package.items() if k != "__metadata"}, sort_keys=True, separators=(",", ":"))


def verify_installed(extension, verified):
    failures = [name for name, digest in verified["hashes"].items() if name != "package.json" and
                (not (extension / name).is_file() or hashlib.sha256((extension / name).read_bytes()).hexdigest() != digest)]
    package = json.loads((extension / "package.json").read_bytes())
    if _manifest_content(package) != _manifest_content(verified["package"]):
        failures.append("package.json content")
    return {"state": "installed-files-verified" if not failures else "installed-files-mismatch",
            "extensionPath": str(extension), "failedFiles": failures,
            "agentCommand": [sys.executable, str(extension / "tools/workbench_agent.py")]}


def _located_path(completed):
    output = _output_bytes(completed.stdout).decode("utf-8").strip()
    extension = Path(output)
    if completed.returncode or not extension.is_absolute() or not extension.is_dir():
        raise ValueError("INSTALLED_EXTENSION_PATH_UNAVAILABLE")
    return extension


def _run_cli(run, argv, environment, timeout):
    return run(argv, capture_output=True, timeout=timeout, env=environment,
               stdin=subprocess.DEVNULL, shell=False)


def install(file, expected_sha, code, receipt, run=subprocess.run, *, platform=None):
    platform = sys.platform if platform is None else platform
    file = Path(file).resolve(strict=True)
    verified = verify_vsix(file, expected_sha)
    command, overrides = code_cli_command(code, platform)
    receipt = Path(receipt).expanduser().resolve()
    receipt.mkdir(parents=True, mode=0o700, exist_ok=False)
    copy = receipt / COPY_NAME
    _write_once(copy, verified["bytes"])
    copy.chmod(0o400)
    installer = command + ["--install-extension", str(copy), "--force"]
    locator = command + ["--locate-extension", EXTENSION_ID]
    result = {"schema": RECEIPT_SCHEMA, "state": "install-requested", "vsix": str(file), "sha256": expected_sha,
              "verifiedCopy": str(copy), "verifiedBytes": len(verified["bytes"]), "platform": platform,
              "code": str(Path(code).expanduser().resolve()), "cliArgv": command, "installerArgv": installer,
              "locatorArgv": locator, "environmentOverrides": overrides, "automaticRetries": 0,
              "extensionId": EXTENSION_ID, "version": VERSION, "activated": False}
    _write_json(receipt / "intent.json", result)
    environment = {**os.environ, **overrides}
    stage = "installer"
    try:
        completed = _run_cli(run, installer, environment, 120)
        result["returnCode"] = completed.returncode
        result["state"] = "install-not-confirmed" if completed.returncode else "verification-incomplete"
        result["outputErrors"] = _save_output(receipt, "installer", completed)
        if completed.returncode == 0:
            stage = "locator"
            located = _run_cli(run, locator, environment, 30)
            result["locatorReturnCode"] = located.returncode
            result["outputErrors"].extend(_save_output(receipt, "locator", located))
            extension = _located_path(located)
            result["extensionPath"] = str(extension)
            stage = "file-verification"
            result.update(verify_installed(extension, verified))
            if result["outputErrors"]:
                result.update(state="verification-incomplete", failedStage="receipt-output")
    except BaseException as exc:
        if stage == "installer" and "returnCode" not in result:
            result["state"] = "install-outcome-unknown"
        elif result["state"] != "install-not-confirmed":
            result["state"] = "verification-incomplete"
        result.update(failedStage=stage, errorType=type(exc).__name__, error=str(exc))
        if isinstance(exc, subprocess.TimeoutExpired):
            result.setdefault("outputErrors", []).extend(_save_output(receipt, stage, exc))
        _write_json(receipt / "result.json", result)
        if not isinstance(exc, Exception):
            raise
        return result
    _write_json(receipt / "result.json", result)
    return result


def reconcile(receipt, run=subprocess.run, *, platform=None):
    """Observe the original target once; never change receipts or reinstall."""
    platform = sys.platform if platform is None else platform
    receipt = Path(receipt).expanduser().resolve(strict=True)
    result = {"state": "verification-incomplete", "mode": "read-only-reconciliation", "receipt": str(receipt),
              "installationAttempted": False, "activated": False, "automaticRetries": 0,
              "originalState": "install-outcome-unknown", "originalOutcomeChanged": False}
    stage = "receipt-verification"
    try:
        intent = json.loads((receipt / "intent.json").read_bytes())
        previous = receipt / "result.json"
        if previous.exists():
            result["originalState"] = json.loads(previous.read_bytes())["state"]
        if intent.get("schema") != RECEIPT_SCHEMA or intent.get("platform") != platform:
            raise ValueError("ORIGINAL_RECEIPT_SCHEMA_OR_PLATFORM_MISMATCH")
        copy = receipt / COPY_NAME
        if copy.is_symlink() or intent.get("verifiedCopy") != str(copy):
            raise ValueError("ORIGINAL_RECEIPT_COPY_BINDING_MISMATCH")
        verified = verify_vsix(copy, intent["sha256"])
        command, overrides = code_cli_command(intent["code"], platform)
        locator = command + ["--locate-extension", EXTENSION_ID]
        if (intent.get("cliArgv") != command or intent.get("environmentOverrides") != overrides or
                intent.get("locatorArgv") != locator or intent.get("extensionId") != EXTENSION_ID or
                intent.get("version") != VERSION or intent.get("verifiedBytes") != len(verified["bytes"])):
            raise ValueError("ORIGINAL_RECEIPT_TARGET_BINDING_MISMATCH")
        result.update(sha256=intent["sha256"], locatorArgv=locator, environmentOverrides=overrides)
        stage = "locator"
        located = _run_cli(run, locator, {**os.environ, **overrides}, 30)
        result.update(locatorReturnCode=located.returncode,
                      locatorStdout=_output_bytes(located.stdout).decode("utf-8", errors="replace"),
                      locatorStderr=_output_bytes(located.stderr).decode("utf-8", errors="replace"))
        extension = _located_path(located)
        stage = "file-verification"
        observed = verify_installed(extension, verified)
        result.update(observed)
        result["state"] = "reconciled-files-verified" if not observed["failedFiles"] else "reconciled-files-mismatch"
    except Exception as exc:
        result.update(failedStage=stage, errorType=type(exc).__name__, error=str(exc))
        if isinstance(exc, subprocess.TimeoutExpired):
            result.update(locatorStdout=_output_bytes(exc.stdout).decode("utf-8", errors="replace"),
                          locatorStderr=_output_bytes(exc.stderr).decode("utf-8", errors="replace"))
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--code")
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--vsix", type=Path)
    mode.add_argument("--reconcile-receipt", type=Path,
                      help="observe original installation once; preserve its receipt and never reinstall")
    parser.add_argument("--sha256")
    parser.add_argument("--receipt", type=Path)
    args = parser.parse_args()
    if args.reconcile_receipt:
        if args.code or args.sha256 or args.receipt:
            parser.error("reconciliation uses only the original receipt's target")
        result = reconcile(args.reconcile_receipt)
        print(json.dumps(result, ensure_ascii=False))
        return 0 if result["state"] == "reconciled-files-verified" else 2
    args.code = args.code or host.default_code()
    if args.vsix:
        if not args.sha256 or not args.receipt:
            parser.error("installation requires --sha256 and a new --receipt directory")
        result = install(args.vsix, args.sha256, args.code, args.receipt)
        print(json.dumps(result, ensure_ascii=False))
        return 0 if result["state"] == "installed-files-verified" else 2
    if args.sha256 or args.receipt:
        parser.error("--sha256 and --receipt require --vsix")
    result = {"platform": sys.platform, "code": args.code, "runtime": inspect_runtime(runtime_root()),
              "freeBytes": shutil.disk_usage(Path.home()).free,
              "stateRoot": str(Path(os.environ.get("STATA_WORKBENCH_HOME", str(Path.home() / ".stata-workbench")))),
              "liveSessionStarted": False}
    print(json.dumps(result, ensure_ascii=False))
    return 0 if result["runtime"]["ready"] else 2


if __name__ == "__main__":
    raise SystemExit(main())
