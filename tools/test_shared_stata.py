import copy
import json
from pathlib import Path
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import Mock, patch

import shared_stata as client


def state(rid="old"):
    s = {"busy": False, "postRunBusy": False, "trueReady": True, "recovery": {"required": False},
         "runId": rid, "requestId": "req-" + rid, "ownedBackendPids": [14], "lifecycleVersion": "rc7.27", "completionMarkerVerified": True,
         "perRunCompletionMarkerVerified": True, "perRunEvidenceFailure": None}
    s["lastCompletedRun"] = dict(s)
    return {"identityOk": True, "axWindowCount": 1, "launcherPid": 12,
            "owner": {"pid": 13, "ppid": 12}, "status": s}


class SharedClientTests(unittest.TestCase):
    def test_exact_completion_and_missing_matrix(self):
        before, after = state(), state("new")
        body = {"ok": True, "rc": 0, "runId": "new", "requestId": "req"}
        request = {"runId": "req"}
        self.assertTrue(all(client.completion_checks(request, 200, body, before, after).values()))
        for key in after["status"]:
            bad = copy.deepcopy(after)
            del bad["status"][key]
            if key not in ("runId", "requestId"):
                self.assertFalse(all(client.completion_checks(request, 200, body, before, bad).values()), key)
        for key in ("rc", "ok", "requestId", "runId"):
            bad = dict(body)
            del bad[key]
            self.assertFalse(all(client.completion_checks(request, 200, bad, before, after).values()), key)
        for value in (False, None, "0"):
            self.assertFalse(all(client.completion_checks(request, 200, dict(body, rc=value), before, after).values()))
        for value in (None, {}, {"required": None}, {"required": 0}, {"required": True}):
            bad = copy.deepcopy(after)
            bad["status"]["recovery"] = value
            self.assertFalse(client.ready(bad))

    def test_identity_and_stale_rejection(self):
        body = {"ok": True, "rc": 0, "runId": "new", "requestId": "new"}
        for key, value in (("launcherPid", 99), ("owner", {"pid": 99}), ("identityOk", False), ("axWindowCount", True)):
            bad = state("new")
            bad[key] = value
            self.assertFalse(all(client.completion_checks({"runId": "new"}, 200, body, state(), bad).values()))
        self.assertFalse(all(client.completion_checks({"runId": "new"}, 200, body, state("new"), state("new")).values()))
        changed = state("new")
        changed["status"]["ownedBackendPids"] = [15]
        self.assertFalse(all(client.completion_checks({"runId": "new"}, 200, body, state(), changed).values()))
        for value in (None, [], [False], [0], [-1], ["14"], [14, 14]):
            before, after = state(), state("new")
            before["status"]["ownedBackendPids"] = value
            after["status"]["ownedBackendPids"] = value
            self.assertFalse(client.ready(before), repr(value))
            self.assertFalse(all(client.completion_checks({"runId": "new"}, 200, body, before, after).values()), repr(value))
        server_body = {"ok": True, "rc": 0, "runId": "new", "requestId": "req-new",
                       "lifecycle": {"requestId": "req-new", "runId": "new", "sourceMode": "agent"}}
        self.assertTrue(all(client.completion_checks({"clientToken": "token"}, 200, server_body, state(), state("new")).values()))
        for key in ("requestId", "runId", "sourceMode"):
            bad = copy.deepcopy(server_body)
            del bad["lifecycle"][key]
            self.assertFalse(all(client.completion_checks({"clientToken": "token"}, 200, bad, state(), state("new")).values()), key)

    def test_one_post_retained_log_and_no_overwrite(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            log = root / "source.log"
            client.write_once(log, b"___VERIFIED_CLIENT_token___\n___CODEX_RUN_DONE_new___\n")
            post = Mock(return_value=(200, {"ok": True, "rc": 0, "runId": "new", "requestId": "req-new", "logPath": str(log),
                "lifecycle": {"requestId": "req-new", "runId": "new", "sourceMode": "agent"}}))
            d = SimpleNamespace(w=SimpleNamespace(http_post=post))
            with patch.object(client.uuid, "uuid4", return_value=SimpleNamespace(hex="token")):
                result = client.execute_once(d, {"code": "display 1"}, root / "receipt", observe=Mock(side_effect=[state(), state("new")]))
            self.assertEqual(result["verdict"], "PASS_VISIBLE_SHARED_RUN")
            self.assertEqual(post.call_count, 1)
            self.assertNotIn("runId", post.call_args.args[1])
            self.assertIn("___VERIFIED_CLIENT_token___", post.call_args.args[1]["code"])
            self.assertEqual((root / "receipt/run.log").read_bytes(), log.read_bytes())
            with self.assertRaises(FileExistsError):
                client.execute_once(d, {"code": "display 1"}, root / "receipt")
            self.assertEqual(post.call_count, 1)
            with patch.object(client.uuid, "uuid4", return_value=SimpleNamespace(hex="wrong-token")):
                missing = client.execute_once(d, {"code": "display 1"}, root / "missing-marker", observe=Mock(side_effect=[state(), state("new")]))
            self.assertEqual(missing["verdict"], "EXECUTION_UNCONFIRMED_NO_RETRY")
            self.assertIn("client request marker absent", missing["error"])
            self.assertEqual(post.call_count, 2)

    def test_busy_no_post_and_timeout_no_retry(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            post = Mock(side_effect=TimeoutError("unknown execution outcome"))
            d = SimpleNamespace(w=SimpleNamespace(http_post=post))
            busy = state()
            busy["status"]["busy"] = True
            blocked = client.execute_once(d, {"code": "display 1"}, root / "busy", observe=lambda _: busy)
            self.assertEqual(blocked["postCount"], 0)
            post.assert_not_called()
            unmeasured = state()
            del unmeasured["status"]["ownedBackendPids"]
            blocked = client.execute_once(d, {"code": "display 1"}, root / "unmeasured", observe=lambda _: unmeasured)
            self.assertEqual(blocked["postCount"], 0)
            post.assert_not_called()
            timed = client.execute_once(d, {"code": "display 1"}, root / "timeout", observe=lambda _: state())
            self.assertEqual(timed["postCount"], 1)
            self.assertEqual(post.call_count, 1)
            self.assertEqual(timed["verdict"], "EXECUTION_UNCONFIRMED_NO_RETRY")
            self.assertEqual(json.loads((root / "timeout/result.json").read_bytes())["retryCount"], 0)


if __name__ == "__main__":
    unittest.main()
