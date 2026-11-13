import contextlib
import hashlib
import io
import json
import os
from pathlib import Path
import stat
import subprocess
import sys
from types import SimpleNamespace
import tempfile
import unittest
from unittest.mock import Mock, patch
import zipfile

import workbench_setup as setup


def completed(returncode=0, stdout=b"", stderr=b""):
    return SimpleNamespace(returncode=returncode, stdout=stdout, stderr=stderr)


class SetupTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name).resolve()
        package = {"name": "stata-workbench-shared-session", "publisher": "lzhs1995", "version": "0.2.0",
                   "main": "./dist/extension.js", "activationEvents": ["onStartupFinished"],
                   "capabilities": {"untrustedWorkspaces": {"supported": False}},
                   "engines": {"vscode": "^1.90.0"}, "contributes": {"commands": []}}
        self.members = {"package.json": json.dumps(package)}
        for name in ("dist/extension.js", "tools/workbench_agent.py", "scripts/window_session_core.js", "scripts/backend_shutdown_core.js"):
            self.members[name] = "synthetic"
        self.file = self.root / "candidate.vsix"
        self.file.write_bytes(self.archive_bytes(self.members))
        self.digest = hashlib.sha256(self.file.read_bytes()).hexdigest()
        self.installed = self.root / "installed"
        for name, content in self.members.items():
            output = self.installed / name
            output.parent.mkdir(parents=True, exist_ok=True)
            output.write_text(content, encoding="utf-8")
        self.receipt = self.root / "receipt"

    def archive_bytes(self, members):
        output = io.BytesIO()
        with zipfile.ZipFile(output, "w") as archive:
            for name, content in members.items():
                archive.writestr("extension/" + name, content)
        return output.getvalue()

    def install(self, run, **kwargs):
        return setup.install(self.file, self.digest, kwargs.pop("code", self.root / "code"),
                             kwargs.pop("receipt", self.receipt), run, platform=kwargs.pop("platform", "darwin"), **kwargs)

    def successful_runner(self):
        return Mock(side_effect=[completed(stdout=b"installed"), completed(stdout=str(self.installed).encode())])

    def read_result(self):
        return json.loads((self.receipt / "result.json").read_bytes())

    def receipt_bytes(self):
        return {p.name: p.read_bytes() for p in self.receipt.iterdir()}

    def windows_layout(self, versions=("resources",), launcher=None):
        base = self.root / "VS Code 中文 O'Brien"
        base.mkdir(exist_ok=True)
        executable = base / "Code.exe"
        executable.touch()
        for version in versions:
            cli = base / ("resources/app/out/cli.js" if version == "resources" else version + "/resources/app/out/cli.js")
            cli.parent.mkdir(parents=True, exist_ok=True)
            cli.touch()
        shim = base / "bin/code.cmd"
        if launcher is not None:
            shim.parent.mkdir(exist_ok=True)
            shim.write_text(launcher, encoding="utf-8")
        return executable, shim

    def test_hash_mismatch_never_invokes_install_or_creates_receipt(self):
        run = Mock()
        with self.assertRaisesRegex(ValueError, "VSIX_SHA_MISMATCH"):
            setup.install(self.file, "0" * 64, "/Code", self.receipt, run)
        run.assert_not_called()
        self.assertFalse(self.receipt.exists())

    def test_install_verifies_files_and_only_top_level_metadata_is_exempt(self):
        package = json.loads(self.members["package.json"])
        package["__metadata"] = {"installedTimestamp": 1}
        (self.installed / "package.json").write_text(json.dumps(package, indent=4), encoding="utf-8")
        run = self.successful_runner()
        result = self.install(run)
        self.assertEqual(result["state"], "installed-files-verified")
        self.assertFalse(result["activated"])
        self.assertEqual(run.call_count, 2)
        self.assertEqual(self.read_result(), result)
        self.assertEqual(run.call_args_list[0].args[0], result["installerArgv"])
        self.assertEqual(run.call_args_list[1].args[0], result["locatorArgv"])
        self.assertEqual(Path(result["verifiedCopy"]).read_bytes(), self.file.read_bytes())
        self.assertNotEqual(result["verifiedCopy"], str(self.file))
        self.assertEqual(result["automaticRetries"], 0)
        if os.name != "nt":
            self.assertEqual(stat.S_IMODE(self.receipt.stat().st_mode), 0o700)
            self.assertEqual(stat.S_IMODE(Path(result["verifiedCopy"]).stat().st_mode), 0o400)

    def test_custom_target_is_durable_before_install_and_identical_for_locate(self):
        extensions = self.root / "Extensions 中文 O'Brien"
        extensions.mkdir()
        self.installed = self.installed.rename(extensions / setup.EXTENSION_ID)
        user_data = self.root / "User data 中文 O'Brien"
        target = {"userDataDir": str(user_data), "extensionsDir": str(extensions), "profile": "Research 中文 O'Brien"}
        selectors = ["--user-data-dir", str(user_data), "--extensions-dir", str(extensions),
                     "--profile", target["profile"]]
        calls = []
        before_environment = dict(os.environ)

        def run(argv, **kwargs):
            intent = json.loads((self.receipt / "intent.json").read_bytes())
            self.assertEqual(intent["target"], target)
            self.assertEqual(argv[1:7], selectors)
            self.assertEqual(intent["cliArgv"], [str(self.root / "code"), *selectors])
            self.assertIs(kwargs["shell"], False)
            calls.append(argv)
            return completed(stdout=b"installed" if "--install-extension" in argv else str(self.installed).encode())

        result = self.install(run, user_data_dir=user_data, extensions_dir=extensions, profile=target["profile"])
        self.assertEqual(result["state"], "installed-files-verified")
        self.assertEqual(result["target"], target)
        self.assertEqual(calls, [result["installerArgv"], result["locatorArgv"]])
        self.assertEqual(dict(os.environ), before_environment)
        self.assertFalse(user_data.exists())  # Only Code, not the helper, may create the target.

    def test_each_target_selector_is_optional_and_defaults_add_no_arguments(self):
        cases = ({}, {"user_data_dir": self.root / "user data"},
                 {"extensions_dir": self.root}, {"profile": "Named profile"})
        for index, options in enumerate(cases):
            with self.subTest(options=options):
                result = self.install(self.successful_runner(), receipt=self.root / str(index), **options)
                self.assertEqual(result["state"], "installed-files-verified")
                for key, option in (("user_data_dir", "--user-data-dir"), ("extensions_dir", "--extensions-dir"),
                                    ("profile", "--profile")):
                    self.assertEqual(option in result["installerArgv"], key in options)
                    self.assertEqual(option in result["locatorArgv"], key in options)
                if not options:
                    self.assertEqual(result["cliArgv"], [str(self.root / "code")])
                    self.assertEqual(result["target"], {"userDataDir": None, "extensionsDir": None, "profile": None})

    def test_invalid_targets_refuse_before_receipt_or_subprocess(self):
        invalid = [{key: value} for key in ("user_data_dir", "extensions_dir")
                   for value in ("", "relative/path", "~/path", "/absolute\npath", self.file)]
        invalid += [{"profile": value} for value in ("", " \t ", "--install-extension", "bad\nprofile")]
        for options in invalid:
            with self.subTest(options=options):
                run = Mock()
                with self.assertRaises(ValueError):
                    self.install(run, **options)
                run.assert_not_called()
                self.assertFalse(self.receipt.exists())

    def test_windows_target_paths_require_drive_or_unc_absolute_paths(self):
        user_data = r"C:\Users\Example\.stata-workbench\user-data\default"
        extensions = r"C:\Users\Example\.stata-workbench\extensions\default"
        target, selectors = setup.installation_target(user_data, extensions, "Research profile", platform="win32")
        self.assertEqual(target, {"userDataDir": user_data, "extensionsDir": extensions, "profile": "Research profile"})
        self.assertEqual(selectors, ["--user-data-dir", user_data, "--extensions-dir", extensions,
                                     "--profile", "Research profile"])
        unc = r"\\server\share\extensions"
        self.assertEqual(setup.installation_target(extensions_dir=unc, platform="win32")[0]["extensionsDir"], unc)
        for invalid in ("", r"C:relative", r"\rooted-without-drive", "relative", "/posix/path"):
            with self.subTest(value=invalid), self.assertRaisesRegex(ValueError, "absolute directory"):
                setup.installation_target(user_data_dir=invalid, platform="win32")

    def test_explicit_extensions_directory_rejects_other_valid_installation(self):
        extensions = self.root / "chosen extensions"
        result = self.install(self.successful_runner(), extensions_dir=extensions)
        self.assertEqual(result["state"], "verification-incomplete")
        self.assertEqual(result["error"], "INSTALLED_EXTENSION_TARGET_MISMATCH")
        self.assertEqual(result["failedStage"], "locator")
        before = self.receipt_bytes()
        run = Mock(return_value=completed(stdout=str(self.installed).encode()))
        result = setup.reconcile(self.receipt, run, platform="darwin")
        self.assertEqual(result["state"], "verification-incomplete")
        self.assertEqual(result["error"], "INSTALLED_EXTENSION_TARGET_MISMATCH")
        self.assertEqual(self.receipt_bytes(), before)
        run.assert_called_once()

    def test_manifest_changes_with_same_id_and_version_are_rejected(self):
        original = json.loads(self.members["package.json"])
        changes = {"main": "./wrong.js", "activationEvents": [],
                   "capabilities": {"untrustedWorkspaces": {"supported": True}},
                   "engines": {"vscode": "*"}, "contributes": {"commands": [{"command": "different"}]},
                   "newManifestField": True}
        for key, value in changes.items():
            with self.subTest(field=key):
                (self.installed / "package.json").write_text(json.dumps({**original, key: value}), encoding="utf-8")
                result = self.install(self.successful_runner(), receipt=self.root / ("receipt-" + key))
                self.assertEqual(result["state"], "installed-files-mismatch")
                self.assertEqual(result["failedFiles"], ["package.json content"])

    def test_nested_metadata_json_type_and_removed_field_changes_are_rejected(self):
        for change in ("nested", "boolean-to-number", "removed-field"):
            with self.subTest(change=change):
                package = json.loads(self.members["package.json"])
                if change == "nested":
                    package["capabilities"]["__metadata"] = {"extra": 1}
                elif change == "boolean-to-number":
                    package["capabilities"]["untrustedWorkspaces"]["supported"] = 0
                else:
                    del package["activationEvents"]
                (self.installed / "package.json").write_text(json.dumps(package), encoding="utf-8")
                result = self.install(self.successful_runner(), receipt=self.root / change)
                self.assertEqual(result["failedFiles"], ["package.json content"])

    def test_changed_or_missing_installed_runtime_is_a_mismatch(self):
        (self.installed / "scripts/backend_shutdown_core.js").write_text("wrong", encoding="utf-8")
        (self.installed / "scripts/window_session_core.js").unlink()
        result = self.install(self.successful_runner())
        self.assertEqual(result["state"], "installed-files-mismatch")
        self.assertEqual(set(result["failedFiles"]), {"scripts/backend_shutdown_core.js", "scripts/window_session_core.js"})

    def test_original_candidate_replacement_cannot_change_checked_or_installed_bytes(self):
        original = self.file.read_bytes()
        replacement = self.archive_bytes({**self.members, "dist/extension.js": "changed"})
        real_read = Path.read_bytes
        source_reads = []

        def racing_read(path):
            data = real_read(path)
            if path == self.file:
                source_reads.append(path)
                self.file.write_bytes(replacement)
            return data

        def run(argv, **kwargs):
            if "--install-extension" in argv:
                candidate = Path(argv[argv.index("--install-extension") + 1])
                self.assertEqual(candidate.read_bytes(), original)
                self.assertEqual(hashlib.sha256(candidate.read_bytes()).hexdigest(), self.digest)
                return completed()
            return completed(stdout=str(self.installed).encode())

        with patch.object(Path, "read_bytes", racing_read):
            result = self.install(Mock(side_effect=run))
        self.assertEqual(result["state"], "installed-files-verified")
        self.assertEqual(len(source_reads), 1)
        self.assertNotEqual(self.file.read_bytes(), original)

    def test_existing_receipt_is_never_overwritten_or_replayed(self):
        self.receipt.mkdir()
        (self.receipt / "intent.json").write_bytes(b"original")
        run = Mock()
        with self.assertRaises(FileExistsError):
            self.install(run)
        run.assert_not_called()
        self.assertEqual((self.receipt / "intent.json").read_bytes(), b"original")

    def test_failed_install_is_not_repeated_or_followed_by_locate(self):
        run = Mock(return_value=completed(2, b"partial", b"failed"))
        result = self.install(run)
        self.assertEqual(result["state"], "install-not-confirmed")
        self.assertEqual(self.read_result()["returnCode"], 2)
        self.assertEqual((self.receipt / "installer.stderr").read_bytes(), b"failed")
        run.assert_called_once()

    def test_installer_timeout_preserves_unknown_and_partial_bytes_without_retry(self):
        run = Mock(side_effect=subprocess.TimeoutExpired(["mock"], 120, output=b"partial\xff", stderr=b"error\xfe"))
        result = self.install(run)
        self.assertEqual(result["state"], "install-outcome-unknown")
        self.assertEqual(result["failedStage"], "installer")
        self.assertEqual(result["errorType"], "TimeoutExpired")
        self.assertEqual(self.read_result(), result)
        self.assertEqual((self.receipt / "installer.stdout").read_bytes(), b"partial\xff")
        self.assertEqual((self.receipt / "installer.stderr").read_bytes(), b"error\xfe")
        self.assertIn("--install-extension", result["installerArgv"])
        run.assert_called_once()

    def test_installer_oserror_has_durable_unknown_receipt(self):
        run = Mock(side_effect=OSError("mock executable unavailable"))
        result = self.install(run)
        self.assertEqual(result["state"], "install-outcome-unknown")
        self.assertEqual(self.read_result()["errorType"], "OSError")
        run.assert_called_once()

    def test_timeout_log_write_failure_still_preserves_result(self):
        original_write = setup._write_once

        def cannot_write_stdout(path, data):
            if path.name == "installer.stdout":
                raise PermissionError("synthetic log write denied")
            return original_write(path, data)

        run = Mock(side_effect=subprocess.TimeoutExpired(["mock"], 120, output=b"partial", stderr=b"error"))
        with patch.object(setup, "_write_once", side_effect=cannot_write_stdout):
            result = self.install(run)
        self.assertEqual(self.read_result(), result)
        self.assertEqual(result["state"], "install-outcome-unknown")
        self.assertEqual(result["outputErrors"][0]["file"], "installer.stdout")
        self.assertEqual((self.receipt / "installer.stderr").read_bytes(), b"error")
        run.assert_called_once()

    def test_keyboard_interrupt_persists_unknown_before_propagating(self):
        run = Mock(side_effect=KeyboardInterrupt())
        with self.assertRaises(KeyboardInterrupt):
            self.install(run)
        self.assertEqual(self.read_result()["state"], "install-outcome-unknown")
        self.assertEqual(self.read_result()["errorType"], "KeyboardInterrupt")
        run.assert_called_once()

    def test_locator_timeout_persists_incomplete_not_failed_install(self):
        run = Mock(side_effect=[completed(stdout=b"installed"),
                                subprocess.TimeoutExpired(["mock"], 30, output=b"path partial", stderr=b"wait")])
        result = self.install(run)
        self.assertEqual(result["state"], "verification-incomplete")
        self.assertEqual(result["returnCode"], 0)
        self.assertEqual(result["failedStage"], "locator")
        self.assertEqual((self.receipt / "locator.stdout").read_bytes(), b"path partial")
        self.assertEqual(self.read_result(), result)
        self.assertEqual(run.call_count, 2)

    def test_invalid_location_has_durable_incomplete_receipt(self):
        for index, located in enumerate((completed(2, b"not found", b"failed"), completed(stdout=b"relative/path"),
                                         completed(stdout=str(self.root / "missing").encode()), completed(stdout=b"\xff"))):
            with self.subTest(index=index):
                receipt = self.root / str(index)
                run = Mock(side_effect=[completed(), located])
                result = self.install(run, receipt=receipt)
                self.assertEqual(result["state"], "verification-incomplete")
                self.assertEqual(result["failedStage"], "locator")
                self.assertEqual(json.loads((receipt / "result.json").read_bytes()), result)
                self.assertEqual((receipt / "locator.stdout").read_bytes(), located.stdout)
                self.assertEqual(run.call_count, 2)

    def test_installed_package_json_error_has_durable_incomplete_receipt(self):
        (self.installed / "package.json").write_bytes(b"{broken")
        result = self.install(self.successful_runner())
        self.assertEqual(result["state"], "verification-incomplete")
        self.assertEqual(result["failedStage"], "file-verification")
        self.assertEqual(result["errorType"], "JSONDecodeError")
        self.assertEqual(self.read_result(), result)

    def test_installed_file_read_failure_has_durable_incomplete_receipt(self):
        real_read = Path.read_bytes

        def unreadable(path):
            if path == self.installed / "dist/extension.js":
                raise PermissionError("synthetic unreadable installed file")
            return real_read(path)

        with patch.object(Path, "read_bytes", unreadable):
            result = self.install(self.successful_runner())
        self.assertEqual(result["state"], "verification-incomplete")
        self.assertEqual(result["failedStage"], "file-verification")
        self.assertEqual(self.read_result()["errorType"], "PermissionError")

    def test_windows_exe_and_cmd_use_cli_js_and_scoped_node_environment(self):
        executable, shim = self.windows_layout(launcher='@echo off\n"%~dp0..\\Code.exe" "%~dp0..\\resources\\app\\out\\cli.js" %*\n')
        for index, configured in enumerate((executable, shim)):
            with self.subTest(configured=str(configured)), patch.dict(os.environ, {"ELECTRON_RUN_AS_NODE": "original", "VSCODE_DEV": "original"}):
                before = dict(os.environ)
                run = self.successful_runner()
                result = self.install(run, code=configured, platform="win32", receipt=self.root / ("win-" + str(index)))
                self.assertEqual(result["state"], "installed-files-verified")
                for call in run.call_args_list:
                    self.assertEqual(call.args[0][:2], [str(executable), str(executable.parent / "resources/app/out/cli.js")])
                    self.assertEqual(call.kwargs["env"]["ELECTRON_RUN_AS_NODE"], "1")
                    self.assertEqual(call.kwargs["env"]["VSCODE_DEV"], "")
                    self.assertIs(call.kwargs["shell"], False)
                    self.assertEqual(call.kwargs["stdin"], subprocess.DEVNULL)
                    self.assertNotIn("cmd.exe", call.args[0])
                self.assertEqual(dict(os.environ), before)

    def test_windows_launcher_selects_declared_version_over_stale_legacy(self):
        executable, shim = self.windows_layout(("resources", "old", "new"),
            '"%~dp0..\\Code.exe" "%~dp0..\\new\\resources\\app\\out\\cli.js" %*')
        for configured in (executable, shim):
            command, overrides = setup.code_cli_command(configured, "win32")
            self.assertEqual(command[1], str(executable.parent / "new/resources/app/out/cli.js"))
            self.assertEqual(overrides, {"ELECTRON_RUN_AS_NODE": "1", "VSCODE_DEV": ""})

    def test_windows_forwarding_shim_does_not_guess_sibling_executable(self):
        executable, _ = self.windows_layout()
        forwarder = self.root / "forward/bin/code.cmd"
        forwarder.parent.mkdir(parents=True)
        (forwarder.parent.parent / "Code.exe").touch()
        forwarder.write_text('"' + str(executable) + '" %*', encoding="utf-8")
        command, _ = setup.code_cli_command(forwarder, "win32")
        self.assertEqual(command[0], str(executable))

    def test_windows_unique_version_without_launcher_is_resolved(self):
        executable, _ = self.windows_layout(("one-version",))
        command, _ = setup.code_cli_command(executable, "win32")
        self.assertEqual(command[1], str(executable.parent / "one-version/resources/app/out/cli.js"))

    def test_windows_ambiguous_layout_fails_before_receipt_or_process(self):
        executable, _ = self.windows_layout(("resources", "new"))
        run = Mock()
        with self.assertRaisesRegex(ValueError, "AMBIGUOUS"):
            self.install(run, code=executable, platform="win32")
        run.assert_not_called()
        self.assertFalse(self.receipt.exists())

    def test_windows_conflicting_launcher_references_are_rejected_even_with_legacy(self):
        executable, _ = self.windows_layout(("resources", "old", "new"),
            '"%~dp0..\\Code.exe" "%~dp0..\\new\\resources\\app\\out\\cli.js" %*\n'
            '"%~dp0..\\Code.exe" "%~dp0..\\old\\resources\\app\\out\\cli.js" %*')
        with self.assertRaisesRegex(ValueError, "AMBIGUOUS"):
            setup.code_cli_command(executable, "win32")

    def test_windows_missing_declared_target_is_not_replaced_by_another_version(self):
        executable, _ = self.windows_layout(("resources", "old"),
            '"%~dp0..\\Code.exe" "%~dp0..\\missing\\resources\\app\\out\\cli.js" %*')
        with self.assertRaises(FileNotFoundError):
            setup.code_cli_command(executable, "win32")

    def test_windows_unresolved_launcher_environment_is_not_executed(self):
        executable, _ = self.windows_layout(launcher='"%CODE_HOME%\\Code.exe" "%CLI_HOME%\\cli.js" %*')
        with self.assertRaisesRegex(ValueError, "UNRESOLVED"):
            setup.code_cli_command(executable, "win32")

    def test_windows_mixed_literal_and_unresolved_cli_declarations_are_rejected(self):
        executable, _ = self.windows_layout(("resources", "new"),
            '"%~dp0..\\Code.exe" "%~dp0..\\resources\\app\\out\\cli.js" %*\n'
            'set CLI=%~dp0..\\new\\resources\\app\\out\\cli.js\n"%CLI%"')
        with self.assertRaisesRegex(ValueError, "UNRESOLVED"):
            setup.code_cli_command(executable, "win32")

    def test_read_only_reconciliation_preserves_original_unknown_and_receipt_bytes(self):
        self.install(Mock(side_effect=subprocess.TimeoutExpired(["mock"], 120, output=b"partial")))
        before = self.receipt_bytes()
        run = Mock(return_value=completed(stdout=str(self.installed).encode()))
        result = setup.reconcile(self.receipt, run, platform="darwin")
        self.assertEqual(result["state"], "reconciled-files-verified")
        self.assertEqual(result["originalState"], "install-outcome-unknown")
        self.assertFalse(result["originalOutcomeChanged"])
        self.assertFalse(result["installationAttempted"])
        self.assertFalse(result["activated"])
        run.assert_called_once()
        self.assertEqual(run.call_args.args[0][-2:], ["--locate-extension", setup.EXTENSION_ID])
        self.assertNotIn("--install-extension", run.call_args.args[0])
        self.assertEqual(self.receipt_bytes(), before)

    def test_custom_target_unknown_reconciles_original_target_once_without_install(self):
        original = self.install(Mock(side_effect=subprocess.TimeoutExpired(["mock"], 120, output=b"partial")),
                                user_data_dir=self.root / "original user data", extensions_dir=self.root,
                                profile="Original profile")
        before = self.receipt_bytes()
        run = Mock(return_value=completed(stdout=str(self.installed).encode()))
        result = setup.reconcile(self.receipt, run, platform="darwin")
        self.assertEqual(result["state"], "reconciled-files-verified")
        self.assertEqual(result["originalState"], "install-outcome-unknown")
        self.assertEqual(result["target"], original["target"])
        self.assertFalse(result["installationAttempted"])
        self.assertFalse(result["originalOutcomeChanged"])
        run.assert_called_once()
        self.assertEqual(run.call_args.args[0], original["locatorArgv"])
        self.assertNotIn("--install-extension", run.call_args.args[0])
        self.assertEqual(self.receipt_bytes(), before)

    def test_reconciliation_rejects_selector_and_installer_drift_before_locate(self):
        self.install(self.successful_runner(), user_data_dir=self.root / "original", extensions_dir=self.root,
                     profile="Original profile")
        intent_path = self.receipt / "intent.json"
        original = json.loads(intent_path.read_bytes())
        changes = [{"target": {**original["target"], key: value}} for key, value in (
            ("userDataDir", str(self.root / "different")), ("extensionsDir", str(self.root / "different")),
            ("profile", "Different profile"))]
        changes += [{"target": None}, {"target": {}}, {"target": {**original["target"], "extra": "ignored?"}},
                    {"installerArgv": original["installerArgv"][:-1]},
                    {"locatorArgv": [str(self.root / "code"), "--locate-extension", setup.EXTENSION_ID]}]
        for change in changes:
            with self.subTest(change=change):
                intent_path.write_text(json.dumps({**original, **change}), encoding="utf-8")
                run = Mock()
                result = setup.reconcile(self.receipt, run, platform="darwin")
                self.assertEqual(result["state"], "verification-incomplete")
                self.assertIn("BINDING_MISMATCH", result["error"])
                run.assert_not_called()
        without_target = {key: value for key, value in original.items() if key != "target"}
        intent_path.write_text(json.dumps(without_target), encoding="utf-8")
        run = Mock()
        result = setup.reconcile(self.receipt, run, platform="darwin")
        self.assertIn("BINDING_MISMATCH", result["error"])
        run.assert_not_called()

    def test_legacy_default_receipt_still_reconciles_without_adding_selectors(self):
        self.install(Mock(side_effect=subprocess.TimeoutExpired(["mock"], 120)))
        intent_path = self.receipt / "intent.json"
        intent = json.loads(intent_path.read_bytes())
        del intent["target"]
        intent_path.write_text(json.dumps(intent), encoding="utf-8")
        before = self.receipt_bytes()
        run = Mock(return_value=completed(stdout=str(self.installed).encode()))
        result = setup.reconcile(self.receipt, run, platform="darwin")
        self.assertEqual(result["state"], "reconciled-files-verified")
        self.assertEqual(result["originalState"], "install-outcome-unknown")
        run.assert_called_once()
        self.assertEqual(run.call_args.args[0], intent["locatorArgv"])
        self.assertEqual(self.receipt_bytes(), before)

    def test_reconciliation_without_original_result_keeps_outcome_unknown(self):
        self.install(self.successful_runner())
        (self.receipt / "result.json").unlink()  # Synthetic process-exit receipt.
        result = setup.reconcile(self.receipt, Mock(return_value=completed(stdout=str(self.installed).encode())), platform="darwin")
        self.assertEqual(result["originalState"], "install-outcome-unknown")
        self.assertEqual(result["state"], "reconciled-files-verified")
        self.assertFalse((self.receipt / "result.json").exists())

    def test_reconciliation_rejects_changed_copy_or_binding_before_locate(self):
        self.install(self.successful_runner())
        intent_path = self.receipt / "intent.json"
        original = json.loads(intent_path.read_bytes())
        intent_path.write_text(json.dumps({**original, "cliArgv": ["different"]}), encoding="utf-8")
        run = Mock()
        result = setup.reconcile(self.receipt, run, platform="darwin")
        self.assertEqual(result["state"], "verification-incomplete")
        self.assertIn("BINDING_MISMATCH", result["error"])
        run.assert_not_called()
        intent_path.write_text(json.dumps(original), encoding="utf-8")
        candidate = self.receipt / setup.COPY_NAME
        candidate.chmod(0o600)
        candidate.write_bytes(b"changed")
        result = setup.reconcile(self.receipt, run, platform="darwin")
        self.assertEqual(result["state"], "verification-incomplete")
        self.assertEqual(result["error"], "VSIX_SHA_MISMATCH")
        run.assert_not_called()

    def test_reconciliation_timeout_does_not_write_or_retry(self):
        self.install(self.successful_runner())
        before = self.receipt_bytes()
        run = Mock(side_effect=subprocess.TimeoutExpired(["mock"], 30, output=b"partial", stderr=b"error"))
        result = setup.reconcile(self.receipt, run, platform="darwin")
        self.assertEqual(result["state"], "verification-incomplete")
        self.assertEqual(result["originalState"], "installed-files-verified")
        self.assertEqual(result["locatorStdout"], "partial")
        self.assertEqual(self.receipt_bytes(), before)
        run.assert_called_once()

    def test_reconcile_cli_does_not_enter_install_or_runtime_probe(self):
        result = {"state": "reconciled-files-verified", "originalState": "install-outcome-unknown"}
        with patch.object(sys, "argv", ["workbench_setup.py", "--reconcile-receipt", str(self.receipt)]), \
                patch.object(setup, "reconcile", return_value=result) as reconcile, \
                patch.object(setup, "install") as install, patch.object(setup, "inspect_runtime") as inspect, \
                contextlib.redirect_stdout(io.StringIO()) as output:
            self.assertEqual(setup.main(), 0)
        reconcile.assert_called_once_with(self.receipt)
        install.assert_not_called()
        inspect.assert_not_called()
        self.assertEqual(json.loads(output.getvalue()), result)

    def test_reconcile_cli_rejects_target_override(self):
        for option, value in (("--code", "/different"), ("--user-data-dir", str(self.root)),
                              ("--extensions-dir", str(self.root)), ("--profile", "Other"), ("--profile", ""),
                              ("--user-data-dir", ""), ("--extensions-dir", "")):
            with self.subTest(option=option, value=value), \
                    patch.object(sys, "argv", ["workbench_setup.py", "--reconcile-receipt", str(self.receipt), option, value]), \
                    patch.object(setup, "reconcile") as reconcile, contextlib.redirect_stderr(io.StringIO()):
                with self.assertRaises(SystemExit) as error:
                    setup.main()
            self.assertEqual(error.exception.code, 2)
            reconcile.assert_not_called()

    def test_install_cli_passes_exact_selectors_to_install(self):
        user_data = str(self.root / "user data")
        result = {"state": "installed-files-verified"}
        argv = ["workbench_setup.py", "--code", "/Code", "--vsix", str(self.file), "--sha256", self.digest,
                "--receipt", str(self.receipt), "--user-data-dir", user_data, "--extensions-dir", str(self.root),
                "--profile", "Research profile"]
        with patch.object(sys, "argv", argv), patch.object(setup, "install", return_value=result) as install, \
                patch.object(setup, "inspect_runtime") as inspect, contextlib.redirect_stdout(io.StringIO()):
            self.assertEqual(setup.main(), 0)
        install.assert_called_once_with(self.file, self.digest, "/Code", self.receipt,
                                        user_data_dir=user_data, extensions_dir=str(self.root), profile="Research profile")
        inspect.assert_not_called()

    def test_invalid_cli_target_does_not_probe_runtime_or_install(self):
        for option, value in (("--user-data-dir", "relative"), ("--extensions-dir", ""), ("--profile", " ")):
            with self.subTest(option=option), patch.object(sys, "argv", ["workbench_setup.py", option, value]), \
                    patch.object(setup, "install") as install, patch.object(setup, "inspect_runtime") as inspect, \
                    contextlib.redirect_stderr(io.StringIO()):
                with self.assertRaises(SystemExit) as error:
                    setup.main()
            self.assertEqual(error.exception.code, 2)
            install.assert_not_called()
            inspect.assert_not_called()

    def test_runtime_metadata_probe_does_not_import_stata(self):
        python = self.root / "bin/python3"
        python.parent.mkdir()
        python.touch()
        run = Mock(return_value=completed(stdout='{"mcp-stata":"1.26.1","mcp":"1.20.0"}'))
        self.assertTrue(setup.inspect_runtime(self.root, "darwin", run)["ready"])
        command = run.call_args.args[0]
        self.assertIn("importlib.metadata", command[-1])
        self.assertNotIn("import mcp_stata", command[-1])
