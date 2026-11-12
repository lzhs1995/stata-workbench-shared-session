"""Ordinary windows may share one Code root; target the authenticated window."""
import copy
import tempfile
import unittest
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import Mock, patch

import verified_workbench as entry
import shared_stata as client
from test_shared_stata import state as legacy_state


class WindowBindingTests(unittest.TestCase):
    def setUp(self):
        self.rec = {"ordinaryWindow": True, "sessionId": "w-A", "sessionName": "stata-A", "port": 19001,
                    "extensionHostPid": 1234, "startedAt": "same-host", "profilePath": "/tmp/session-A",
                    "extensionPath": "/tmp/installed"}
        self.status = {"extensionHostPid": 1234, "extensionVersion": entry.VERSION,
                       "diskBundleSha256": entry.BUNDLE_SHA256, "bundleIdentityState": "OK",
                       "guardModuleIdentityState": "OK", "bundleId": "/tmp/installed",
                       "windowSession": {"sessionId": "w-A"}, "nextSession": {"sessionId": "w-A"},
                       "terminalWebview": {"panelExists": True, "scriptReady": True},
                       "busy": False, "postRunBusy": False, "trueReady": True,
                       "recovery": {"required": False}, "ownedBackendPids": [1500]}

    def observe(self, status=None, listeners=None):
        status = self.status if status is None else status
        with patch.object(entry, "verify_session_identity", return_value={"sessionId": "w-A"}), \
                patch.object(entry, "EXTENSION", Path("/tmp/installed")):
            return entry.observe_window_session(SimpleNamespace(w=SimpleNamespace(status=lambda timeout: status)), self.rec,
                                                listeners or (lambda port: {1234}))

    def test_shared_code_root_does_not_require_one_ax_window(self):
        state = self.observe()
        self.assertTrue(state["identityOk"])
        self.assertIsNone(state["axWindowCount"])
        self.assertFalse(state["windowObservation"]["ok"], "do not invent visual observation")
        self.assertTrue(client.ready(state))

    def execution_state(self, rid="old"):
        status = {**copy.deepcopy(self.status), **legacy_state(rid)["status"], "resetGeneration": 0}
        return self.observe(status)

    def test_real_ordinary_observation_reaches_one_post_and_checks_log(self):
        with tempfile.TemporaryDirectory() as directory, \
                patch.object(entry, "verify_session_identity", return_value={"sessionId": "w-A"}), \
                patch.object(client.uuid, "uuid4", return_value=SimpleNamespace(hex="token")):
            log = Path(directory) / "run.log"
            log.write_text("___VERIFIED_CLIENT_token___\n___CODEX_RUN_DONE_new___\n")
            body = {"ok": True, "rc": 0, "runId": "new", "requestId": "req-new", "logPath": str(log),
                    "lifecycle": {"requestId": "req-new", "runId": "new", "sourceMode": "agent"}}
            for valid_log in (True, False):
                if not valid_log:
                    log.write_text("unrelated output\n")
                post = Mock(return_value=(200, body))
                result = client.execute_once(SimpleNamespace(w=SimpleNamespace(http_post=post)), {"code": "display 1"},
                    Path(directory) / str(valid_log), observe=Mock(side_effect=[self.execution_state(), self.execution_state("new")]))
                self.assertEqual(post.call_count, 1)
                self.assertEqual(result["verdict"], "PASS_VISIBLE_SHARED_RUN" if valid_log else "EXECUTION_UNCONFIRMED_NO_RETRY", result)
                self.assertEqual(result["after"]["windowObservation"]["status"], "NOT_MEASURED")

    def test_ordinary_stop_waits_for_same_run_restore_without_reposting(self):
        before, after = self.execution_state(), self.execution_state("new")
        after["status"].update(resetGeneration=1, resetGenerationKind="soft-stop",
            lastSoftStop={"runId": "new", "generation": 1, "ok": True, "restored": True})
        after["status"]["lastCompletedRun"].update(phase="failed", completionMarkerVerified=False)
        settling = copy.deepcopy(after)
        settling["status"].update(trueReady=False, postRunBusy=True, lastSoftStop=None)
        body = {"ok": False, "error": "Request cancelled", "runId": "req-new",
                "stoppedBy": {"by": "person", "runId": "new", "generation": 1}}
        post, sleep = Mock(return_value=(500, body)), Mock()
        with tempfile.TemporaryDirectory() as directory, patch.object(entry, "verify_session_identity", return_value={"sessionId": "w-A"}):
            result = client.execute_once(SimpleNamespace(w=SimpleNamespace(http_post=post)), {"code": "display 1"},
                Path(directory) / "receipt", sleep=sleep, observe=Mock(side_effect=[before, settling, after]))
        self.assertEqual(result["verdict"], "STOPPED_NO_RETRY", result)
        self.assertEqual(post.call_count, 1)
        sleep.assert_called_once_with(1)

    def test_wait_ready_accepts_ordinary_binding_and_rejects_changes(self):
        good = self.execution_state()
        busy = copy.deepcopy(good); busy["status"]["busy"] = True
        sleep = Mock()
        result = client.wait_ready(None, 10, observe=Mock(side_effect=[busy, good]), clock=lambda: 0, sleep=sleep)
        self.assertEqual(result, good)
        sleep.assert_called_once()
        for key, value in (("verified", False), ("sessionId", "w-B"), ("terminalReady", False)):
            bad = copy.deepcopy(good); bad["windowBinding"][key] = value
            with self.assertRaises(entry.permissions.WindowObservationError):
                client.wait_ready(None, 10, observe=lambda _: bad)

    def test_wrong_listener_and_wrong_window_fail(self):
        for pids in ({9999}, {1234, 9999}, set()):
            with self.subTest(pids=pids):
                state = self.observe(listeners=lambda port: pids)
                self.assertFalse(state["identityOk"])
                self.assertFalse(client.ready(state))
        status = copy.deepcopy(self.status); status["windowSession"]["sessionId"] = "w-B"
        self.assertFalse(self.observe(status)["identityOk"])

    def test_hidden_or_unloaded_terminal_not_ready_to_dispatch(self):
        status = copy.deepcopy(self.status); status["terminalWebview"]["scriptReady"] = False
        state = self.observe(status)
        self.assertTrue(state["identityOk"])
        self.assertFalse(client.ready(state))

    def test_bind_uses_actual_installed_path_not_fake_private_profile(self):
        with patch.object(entry, "select_session", return_value=self.rec), \
                patch.object(entry, "EXTENSION"), patch.object(entry, "PROFILE"), \
                patch.object(entry, "PORT"), patch.object(entry, "BOUND_SESSION_ID"):
            entry.bind_session("w-A")
            self.assertEqual(entry.EXTENSION, Path("/tmp/installed").resolve())
            self.assertEqual(entry.PROFILE, Path("/tmp/session-A").resolve())
            self.assertEqual(entry.PORT, 19001)
            self.assertEqual(entry.BOUND_SESSION_ID, "w-A")

    def test_no_installation_identity_is_refused(self):
        for extension in (None, "relative", 123):
            with self.subTest(extension=extension), patch.object(entry, "select_session", return_value={**self.rec, "extensionPath": extension}):
                with self.assertRaises(entry.SessionRegistryError):
                    entry.bind_session("w-A")


if __name__ == "__main__":
    unittest.main()
