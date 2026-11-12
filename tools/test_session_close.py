"""Authenticated receiver-window close: no application/process/network actions."""
import io
import json
import socket
import tempfile
import unittest
from pathlib import Path
from unittest.mock import Mock, patch
import stata_session as ss


class Response(io.BytesIO):
    status = 200
    def __init__(self, data):
        super().__init__(json.dumps(data).encode())


class SessionCloseTests(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        self.session = ss.Sessions(root=Path(tmp.name), platform="win32")
        self.record = {"sessionId": "a", "sessionName": "A", "extensionHostPid": 42, "port": 17777,
                       "generation": 2, "diskBundleSha256": "bundle", "token": "synthetic"}
        self.session.records = lambda: [self.record]
        self.status = {"nextSession": {"sessionId": "a"}, "nextAuth": {"port": 17777},
                       "extensionHostPid": 42, "resetGeneration": 2, "diskBundleSha256": "bundle"}
        for obj, name in ((socket.socket, "connect"), (ss.os, "kill"), (ss.subprocess, "run")):
            guard = patch.object(obj, name, side_effect=AssertionError("live side effect forbidden"))
            guard.start()
            self.addCleanup(guard.stop)

    def test_complete_pending_unknown_are_distinct_and_never_imply_window_closed(self):
        for cleanup in ("complete", "pending", "unknown"):
            with self.subTest(cleanup=cleanup):
                opener = Mock()
                opener.open.side_effect = [Response(self.status), Response({"sessionId": "a", "extensionHostPid": 42, "backendCleanup": cleanup})]
                with patch.object(ss.urllib.request, "build_opener", return_value=opener):
                    result = self.session.close("A")
                self.assertEqual(result["backendCleanup"], cleanup)
                self.assertIsNone(result["windowClosed"])
                self.assertEqual(result["verdict"], "CLOSE_REQUESTED")
                calls = [c.args[0] for c in opener.open.call_args_list]
                self.assertEqual([r.get_method() for r in calls], ["GET", "POST"])
                self.assertIn("/session-close?sessionId=a&hostPid=42&generation=2&bundle=bundle", calls[1].full_url)
                self.assertEqual(calls[1].get_header("Authorization"), "Bearer synthetic")
                self.assertEqual(result["signalled"], [])

    def test_status_mismatch_refuses_before_post(self):
        for key in ("extensionHostPid", "resetGeneration", "diskBundleSha256"):
            with self.subTest(key=key):
                opener=Mock()
                opener.open.return_value=Response({**self.status, key: "foreign"})
                with patch.object(ss.urllib.request, "build_opener", return_value=opener):
                    with self.assertRaisesRegex(ss.SessionError, "IDENTITY_MISMATCH"):
                        self.session.close("A")
                self.assertEqual(opener.open.call_count, 1)

    def test_status_unavailable_records_zero_posts(self):
        opener=Mock()
        opener.open.side_effect=TimeoutError("preflight timed out")
        with patch.object(ss.urllib.request, "build_opener", return_value=opener):
            result=self.session.close("A")
        self.assertEqual(result["reason"], "CLOSE_PREFLIGHT_UNAVAILABLE")
        self.assertEqual((result["postCount"], result["retryCount"]), (0, 0))
        self.assertEqual(opener.open.call_count, 1)

    def test_lost_post_response_never_retries_or_signals_code(self):
        opener=Mock()
        opener.open.side_effect=[Response(self.status), TimeoutError("unknown after send")]
        with patch.object(ss.urllib.request, "build_opener", return_value=opener):
            result=self.session.close("A")
        self.assertEqual(result["reason"], "CLOSE_RESPONSE_UNKNOWN_NO_RETRY")
        self.assertEqual((result["postCount"], result["retryCount"]), (1, 0))
        self.assertEqual(opener.open.call_count, 2)

    def test_ambiguous_same_profile_windows_are_not_selected_by_code_pid(self):
        self.session.records=lambda: [self.record, {**self.record, "sessionId": "b", "extensionHostPid": 43}]
        result=self.session.close("A")
        self.assertEqual(result["postCount"], 0)
        self.assertEqual(result["backendCleanup"], "unknown")

    def test_windows_legacy_absence_is_not_backend_clean(self):
        self.session.profile("legacy").mkdir(parents=True)
        self.session.kill=Mock()  # explicit legacy window-close adapter; no production PID signal
        self.session._instances=lambda profile: []
        result=self.session.close("legacy")
        self.assertTrue(result["windowClosed"])
        self.assertEqual(result["backendCleanup"], "unknown")
        self.session.kill.assert_not_called()


if __name__ == "__main__":
    unittest.main()
