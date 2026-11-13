"""Offline only: original dispatch/receipt, pause, proposal and process contracts."""
import io
import json
from pathlib import Path
import subprocess
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import Mock, patch

import workbench_agent as agent


class WorkflowTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name).resolve()
        self.file = self.root / "analysis.do"
        self.file.write_text("display 1\n")
        self.ident = {"sessionId": "s1", "generation": 3, "port": 17601, "bundleSha": "a" * 64}
        self.doc = {"sha256": agent.sha256(self.file.read_bytes()), "dirty": False, "documentVersion": 1,
            "sessionId": "s1", "generation": 3}
        self.directory, self.wf = agent.create_workflow(self.root / "workflow", self.file, self.root, self.ident, self.doc, "Codex")
        self.bridge = Mock()
        self.bridge.status.return_value = {"busy": True, "runId": "r1", "postRunBusy": False, "trueReady": False, "recovery": {"required": False}}
        self.run = {"workflowId": self.wf["workflowId"], "sessionId": "s1", "generation": 3,
            "sourcePath": str(self.file), "sourceSha256": self.wf["sourceSha256"], "runId": "r1"}
        self.bridge.request.side_effect = self.request
        self.ident_patch = patch.object(agent.entry, "verify_session_identity", side_effect=lambda s: dict(self.ident))
        self.ident_patch.start(); self.addCleanup(self.ident_patch.stop)

    def request(self, path, payload=None, **kwargs):
        if path.startswith("/agent-runs/"):
            return 200, {"run": self.run}
        if path == "/document-state":
            file = Path(payload["path"])
            return 200, {"document": {**self.doc, "path": str(file), "sha256": agent.sha256(file.read_bytes()), "generation": self.ident["generation"]}}
        if path == "/agent-stop":
            return 202, {"status": "stop-requested"}
        if path == "/propose-edit":
            return 202, {"proposal": {"id": payload["proposalId"], "status": "pending"}}
        raise AssertionError(path)

    def receipt(self, result):
        root = self.directory / "receipt"; root.mkdir(exist_ok=True)
        agent.write(root / "result.json", result)

    def paused(self, by="person"):
        self.ident["generation"] = 4
        completed = {"runId": "inner1", "requestId": "r1"}
        self.bridge.status.return_value.update(busy=False, trueReady=True, resetGeneration=4, lastCompletedRun=completed)
        result = {"verdict": "STOPPED_NO_RETRY" if by == "person" else "EXECUTION_UNCONFIRMED_NO_RETRY",
            "stopReportedBy": by, "stopChecks": {k: True for k in ("http500", "notStataError", "requestBound", "stoppedRunBound", "stopAfterSubmit", "restoredAfter", "readyAfter")},
            "after": {"status": {"resetGeneration": 4, "lastCompletedRun": completed}}}
        self.receipt(result)

    def test_freezes_saved_bytes_and_rejects_changed_source_before_creation(self):
        self.file.write_text("human saved edit\n")
        self.assertEqual((self.directory / "source.do").read_text(), "display 1\n")
        with self.assertRaisesRegex(RuntimeError, "source changed"):
            agent.create_workflow(self.root / "other", self.file, self.root, self.ident, self.doc, "Claude")
        self.assertFalse((self.root / "other").exists())

    def test_async_launch_detaches_and_duplicate_never_respawns(self):
        spawn = Mock(return_value=SimpleNamespace(pid=4321))
        result = agent.launch_worker(self.directory, spawn)
        self.assertEqual(result["state"], "submitted-to-worker")
        args, kwargs = spawn.call_args
        self.assertIn("_worker", args[0]); self.assertIs(kwargs["stdin"], subprocess.DEVNULL)
        self.assertTrue(kwargs.get("start_new_session") or kwargs.get("creationflags"))
        with self.assertRaises(FileExistsError):
            agent.launch_worker(self.directory, spawn)
        self.assertEqual(spawn.call_count, 1)

    def test_worker_once_reuses_original_executor_without_restart(self):
        execute = Mock(return_value={"verdict": "EXECUTION_UNCONFIRMED_NO_RETRY"})
        d = SimpleNamespace(w=self.bridge, _activate_exact_pid_once=Mock())
        with patch.object(agent, "bind"), patch.object(agent.entry, "helpers", return_value=d), \
             patch.object(agent.entry.host, "file_lock") as lock:
            output = agent.worker(self.directory, execute)
            with self.assertRaises(FileExistsError):
                agent.worker(self.directory, execute)
        self.assertEqual(execute.call_count, 1)
        self.assertEqual(execute.call_args.args[2], self.wf["receipt"])
        self.assertEqual(execute.call_args.kwargs["source_path"], self.directory / "source.do")
        self.assertEqual(output["state"], "unknown-no-retry")
        self.assertEqual(lock.call_args.args[0].parts[-2:], ("s1", "agent-execute.lock"))

    def test_stop_intent_prevents_worker_dispatch(self):
        agent.write(self.directory / "stop-intent.json", {"userAction": "stop it"})
        execute = Mock()
        d = SimpleNamespace(w=self.bridge, _activate_exact_pid_once=Mock())
        with patch.object(agent, "bind"), patch.object(agent.entry, "helpers", return_value=d), patch.object(agent.entry.host, "file_lock"):
            result = agent.worker(self.directory, execute)
        execute.assert_not_called(); self.assertEqual(result["state"], "cancelled-before-dispatch")

    def test_bridge_single_post_claim_and_immutable_identity(self):
        bridge = agent.BoundBridge(self.bridge, self.directory, self.wf)
        self.bridge.http_post.return_value = (200, {})
        bridge.http_post("/run-command", {"code": "display 1"})
        with self.assertRaises(FileExistsError):
            bridge.http_post("/run-command", {"code": "display 1"})
        self.assertEqual(self.bridge.http_post.call_count, 1)

    def test_bridge_changed_source_or_generation_never_posts(self):
        bridge = agent.BoundBridge(self.bridge, self.directory, self.wf)
        self.file.write_text("new text")
        code, body = bridge.http_post("/run-command", {})
        self.assertEqual(code, 409); self.assertIs(body["payloadDispatched"], False)
        self.file.write_text("display 1\n"); self.ident["generation"] += 1
        with self.assertRaisesRegex(RuntimeError, "SESSION_CHANGED"):
            bridge.http_post("/run-command", {})
        self.bridge.http_post.assert_not_called()

    def test_lost_post_response_claim_prevents_retry(self):
        self.bridge.http_post.side_effect = TimeoutError("transport")
        bridge = agent.BoundBridge(self.bridge, self.directory, self.wf)
        with self.assertRaises(TimeoutError):
            bridge.http_post("/run-command", {})
        with self.assertRaises(FileExistsError):
            bridge.http_post("/run-command", {})
        self.assertEqual(self.bridge.http_post.call_count, 1)

    def test_reconcile_never_converts_idle_or_missing_binding_into_pass(self):
        self.bridge.status.return_value.update(busy=False, trueReady=True)
        self.bridge.request.side_effect = lambda *a, **k: (404, {"run": None})
        for _ in range(2):
            result = agent.reconcile(self.directory, self.bridge)
            self.assertEqual(result["state"], "pending-or-unknown")
            self.assertIsNone(result["verdict"])
        self.assertTrue(all(call.args[0].startswith("/agent-runs/") for call in self.bridge.request.call_args_list))

    def test_receipt_success_is_preserved_without_reexecution(self):
        self.receipt({"verdict": "PASS_VISIBLE_SHARED_RUN", "postCount": 1})
        self.assertEqual(agent.reconcile(self.directory, self.bridge)["state"], "completed")
        self.bridge.http_post.assert_not_called()

    def test_stop_binds_original_run_and_never_repeats_input(self):
        result = agent.stop(self.directory, "stop it", self.bridge)
        self.assertEqual(result["state"], "stop-requested")
        agent.stop(self.directory, "stop it", self.bridge)
        calls = [c for c in self.bridge.request.call_args_list if c.args[0] == "/agent-stop"]
        self.assertEqual(len(calls), 1)
        self.assertEqual(calls[0].args[1], {"expectedRunId": "r1", "sessionId": "s1", "generation": 3})

    def test_stop_will_not_cancel_somebody_elses_run(self):
        self.bridge.status.return_value["runId"] = "other"
        self.assertEqual(agent.stop(self.directory, "stop it", self.bridge)["state"], "stop-pending-original-run")
        self.assertFalse(any(c.args[0] == "/agent-stop" for c in self.bridge.request.call_args_list))

    def test_unknown_or_malformed_stop_evidence_cannot_continue(self):
        self.receipt({"verdict": "EXECUTION_UNCONFIRMED_NO_RETRY", "stopReportedBy": "api", "stopChecks": {"readyAfter": True}})
        with self.assertRaisesRegex(RuntimeError, "confirmed Stop"):
            agent.continue_workflow(self.directory, self.root / "child", self.file, "continue", self.bridge, Mock())
        self.assertIsNone(agent.local_status(self.directory)["pause"])

    def test_api_stop_attribution_is_not_person(self):
        self.paused("api")
        self.assertEqual(agent.local_status(self.directory)["pause"]["by"], "api")

    def test_continue_requires_user_action_then_fresh_source_and_one_child(self):
        self.paused()
        spawn = Mock(return_value=SimpleNamespace(pid=4321))
        with self.assertRaisesRegex(ValueError, "fresh explicit"):
            agent.continue_workflow(self.directory, self.root / "child", self.file, "", self.bridge, spawn)
        self.file.write_text("display 2\n")
        result = agent.continue_workflow(self.directory, self.root / "child", self.file, "continue with my saved edits", self.bridge, spawn)
        child = agent.read(self.root / "child" / "workflow.json")
        self.assertNotEqual(child["workflowId"], self.wf["workflowId"])
        self.assertEqual(child["sourceSha256"], agent.sha256(self.file.read_bytes()))
        self.assertEqual(child["identity"]["generation"], 4)
        self.assertEqual(result["state"], "submitted-to-worker")
        with self.assertRaises(FileExistsError):
            agent.continue_workflow(self.directory, self.root / "second", self.file, "continue again", self.bridge, spawn)
        self.assertEqual(spawn.call_count, 1)

    def test_continue_refuses_an_intervening_run_in_same_generation(self):
        self.paused(); self.bridge.status.return_value["lastCompletedRun"] = {"runId": "another", "requestId": "another"}
        with self.assertRaisesRegex(RuntimeError, "another run"):
            agent.continue_workflow(self.directory, self.root / "child", self.file, "continue", self.bridge, Mock())

    def test_continue_executes_explicit_stage_with_its_own_version_sha_and_pause_binding(self):
        self.paused()
        selected = self.root / "stage03.do"
        selected.write_text("display 3\n")
        self.doc["documentVersion"] = 17
        spawn = Mock(return_value=SimpleNamespace(pid=4321))
        agent.continue_workflow(self.directory, self.root / "stage03-workflow", selected, "Continue only stage03", self.bridge, spawn)
        child = agent.read(self.root / "stage03-workflow" / "workflow.json")
        intent = agent.read(self.directory / "continue-intent.json")
        self.assertEqual(child["sourcePath"], str(selected))
        self.assertEqual(child["documentVersion"], 17)
        self.assertEqual(child["sourceSha256"], agent.sha256(selected.read_bytes()))
        self.assertNotEqual(child["sourceSha256"], self.wf["sourceSha256"])
        self.assertEqual(child["continuationOf"], {"runId": "inner1", "requestId": "r1"})
        self.assertEqual(child["parentWorkflow"], str(self.directory))
        self.assertEqual((self.root / "stage03-workflow" / "source.do").read_bytes(), selected.read_bytes())
        self.assertEqual(intent["sourcePath"], str(selected))
        self.assertEqual(intent["sourceSha256"], child["sourceSha256"])
        self.assertEqual(intent["documentVersion"], 17)
        self.assertEqual([c.args[1]["path"] for c in self.bridge.request.call_args_list if c.args[0] == "/document-state"], [str(selected)])
        self.assertEqual(self.file.read_text(), "display 1\n")

    def test_continue_cli_requires_stage_before_any_observation(self):
        with patch.object(agent, "continue_workflow") as resume, patch("sys.stderr", io.StringIO()), self.assertRaises(SystemExit) as failure:
            agent.main(["continue", "--workflow", str(self.directory), "--workflow-dir", str(self.root / "child"), "--user-action", "continue"])
        self.assertEqual(failure.exception.code, 2)
        resume.assert_not_called()
        with self.assertRaisesRegex(ValueError, "explicitly selected"):
            agent.continue_workflow(self.directory, self.root / "child", None, "continue", self.bridge, Mock())
        self.bridge.status.assert_not_called()

    def test_continue_forwards_explicit_file_from_cli(self):
        selected = self.root / "stage03.do"
        with patch.object(agent, "continue_workflow", return_value={}) as resume, patch("sys.stdout", io.StringIO()):
            agent.main(["continue", "--workflow", str(self.directory), "--workflow-dir", str(self.root / "child"),
                "--file", str(selected), "--user-action", "continue stage03"])
        resume.assert_called_once_with(self.directory, self.root / "child", selected, "continue stage03")

    def test_continue_refuses_selected_dirty_or_outside_workspace_stage(self):
        self.paused()
        selected = self.root / "stage03.do"
        selected.write_text("display 3\n")
        original = self.request
        spawn = Mock()
        for response in [(409, {"error": "OUTSIDE_WORKSPACE"}),
                         (200, {"document": {**self.doc, "dirty": True, "generation": 4}})]:
            self.bridge.request.side_effect = lambda url, *a, **k: response if url == "/document-state" else original(url, *a, **k)
            with self.assertRaises(RuntimeError):
                agent.continue_workflow(self.directory, self.root / "child", selected, "continue stage03", self.bridge, spawn)
            self.assertFalse((self.directory / "continue-intent.json").exists())
            self.assertFalse((self.root / "child").exists())
        spawn.assert_not_called()

    def test_continue_rereads_selected_bytes_and_refuses_save_race(self):
        self.paused()
        selected = self.root / "stage03.do"
        selected.write_text("display 3\n")
        original = self.request
        def save_race(url, *args, **kwargs):
            response = original(url, *args, **kwargs)
            if url == "/document-state":
                selected.write_text("display 4\n")
            return response
        self.bridge.request.side_effect = save_race
        spawn = Mock()
        with self.assertRaisesRegex(RuntimeError, "source changed"):
            agent.continue_workflow(self.directory, self.root / "child", selected, "continue stage03", self.bridge, spawn)
        self.assertFalse((self.root / "child").exists())
        spawn.assert_not_called()

    def test_proposal_acceptance_never_launches_run(self):
        self.bridge.status.return_value.update(busy=False, trueReady=True)
        result = agent.propose_edit(self.directory, "display 2\n", "fix model", self.bridge)
        self.assertEqual(result["proposal"]["status"], "pending")
        self.assertEqual(self.file.read_text(), "display 1\n")
        self.assertFalse((self.directory / "continue-intent.json").exists())
        self.assertFalse(any(c.args[0] == "/run-command" for c in self.bridge.request.call_args_list))

    def test_proposal_cli_serializes_review_seconds_once_and_keeps_default(self):
        self.bridge.status.return_value.update(busy=False, trueReady=True)
        proposed = self.root / "proposed.txt"
        proposed.write_text("display 2\n")
        for extra, expected_ms in (([], 120000), (["--review-timeout", "900"], 900000)):
            self.bridge.request.reset_mock()
            with patch.object(agent, "bind"), patch.object(agent.entry, "LocalBridge", return_value=self.bridge), \
                 patch("sys.stdout", io.StringIO()) as output:
                agent.main(["propose-edit", "--workflow", str(self.directory), "--content-file", str(proposed),
                    "--reason", "review the proposed change", *extra])
            result = json.loads(output.getvalue())
            saved = agent.read(self.directory / "proposals" / result["proposalId"] / "request.json")
            calls = [c for c in self.bridge.request.call_args_list if c.args[0] == "/propose-edit"]
            self.assertEqual(len(calls), 1)
            self.assertEqual(json.loads(json.dumps(calls[0].args[1])), saved)
            self.assertEqual(saved["timeoutMs"], expected_ms)
            self.assertEqual(saved["proposalId"], result["proposalId"])
            self.assertEqual(saved["path"], str(self.file))
            self.assertEqual(self.file.read_text(), "display 1\n")
            self.assertFalse(result["automaticRetry"])

    def test_invalid_review_timeout_refused_before_input_or_bridge(self):
        for value in ("0", "901", "-1", "1.5", "NaN", "Infinity", "True"):
            with self.subTest(value=value), patch.object(agent, "propose_edit") as propose, \
                 patch("sys.stdin") as stdin, patch("sys.stderr", io.StringIO()), self.assertRaises(SystemExit) as failure:
                agent.main(["propose-edit", "--workflow", str(self.directory), "--reason", "review", "--review-timeout", value])
            self.assertEqual(failure.exception.code, 2)
            propose.assert_not_called()
            stdin.read.assert_not_called()
        for value in (0, 901, -1, 1.5, float("nan"), float("inf"), True):
            with self.subTest(direct=value), self.assertRaisesRegex(ValueError, "integer from 1 to 900"):
                agent.propose_edit(self.directory, "display 2\n", "review", self.bridge, review_timeout=value)
        self.bridge.status.assert_not_called()
        self.bridge.request.assert_not_called()

    def test_lost_proposal_response_retains_original_id_and_request_for_query(self):
        self.bridge.status.return_value.update(busy=False, trueReady=True)
        original = self.request
        self.bridge.request.side_effect = lambda url, *a, **k: (_ for _ in ()).throw(TimeoutError()) if url == "/propose-edit" else original(url, *a, **k)
        result = agent.propose_edit(self.directory, "display 2\n", "fix", self.bridge)
        self.assertEqual(result["state"], "proposal-unconfirmed-query-by-id")
        self.assertTrue((self.directory / "proposals" / result["proposalId"] / "request.json").exists())
        self.assertEqual(sum(c.args[0] == "/propose-edit" for c in self.bridge.request.call_args_list), 1)

    def test_endpoint_whitelist_rejects_wrong_methods_and_unsafe_shapes(self):
        bridge = agent.entry.LocalBridge.__new__(agent.entry.LocalBridge)
        for url, data in [("/soft-stop", {}), ("/agent-stop", None), ("/proposals/../x", None), ("/agent-runs/id?x=1", None), ("/proposals/id", {}), ("/status", {})]:
            with self.assertRaisesRegex(ValueError, "unsupported endpoint"):
                bridge.request(url, data)


if __name__ == "__main__":
    unittest.main()
