import copy
import json
from pathlib import Path
import tempfile
import unittest
from types import SimpleNamespace
from unittest.mock import Mock, patch
import cowork_task as task
import shared_stata as client
from test_shared_stata import state


class CoworkTests(unittest.TestCase):
    def test_client_dispatches_archived_compiled_file_not_undisplayed_original(self):
        with tempfile.TemporaryDirectory() as tmp:
            root=Path(tmp).resolve(); source=root/"author.do"; source.write_text("display 1\n")
            frozen=task.freeze_program(source,root/"frozen")
            compiled=root/"compiled.do"; compiled.write_text("* stable compatibility code\ndisplay 1\n")
            actual=task.identity(compiled)
            compilation={"stable":True,"program":str(compiled),"sha256":actual["sha256"],
                "inputProgram":frozen["program"],"inputSha256":frozen["sha256"]}
            ticket={**compilation,"sourceCompilation":compilation}
            marker="___VERIFIED_CLIENT_"+"a"*32+"___"
            log=root/"source.log";log.write_text(marker+"START\n"+marker+"\n___CODEX_RUN_DONE_new___\n")
            body={"ok":True,"rc":0,"runId":"new","requestId":"req-new","logPath":str(log),
                "lifecycle":{"runId":"new","requestId":"req-new","sourceMode":"agent"}}
            after=state("new");after["status"]["sourceCompatibility"]={"runId":"req-new","sourceMode":"agent","referencedDoCopies":[]}
            post=Mock(side_effect=[(200,{"ok":True,"token":"ticket","layout":{"ok":True},"ticket":ticket}),
                (200,body),(200,{"ticket":{"visibilityVerdict":"OBSERVED_VISIBLE"}})])
            with patch.object(client.uuid,"uuid4",return_value=SimpleNamespace(hex="a"*32)):
                result=client.execute_once(SimpleNamespace(w=SimpleNamespace(http_post=post)),
                    {"code":"unused","cwd":tmp,"cowork":frozen},root/"receipt",observe=Mock(side_effect=[state(),after]))
            self.assertEqual(result["verdict"],"PASS_VISIBLE_COWORK_RUN",result)
            self.assertIn('do "'+str(compiled)+'"',post.call_args_list[1].args[1]["code"])
            self.assertNotIn(frozen["program"],post.call_args_list[1].args[1]["code"])
            self.assertEqual((root/"receipt/runtime-execution.do").read_bytes(),compiled.read_bytes())
            self.assertEqual(result["postCount"],1)

    def test_runtime_compatibility_copy_is_never_mislabeled_as_displayed_bytes(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp); original=root/"source.do"; actual=root/"compat.do"
            original.write_text("log using x, name(`ownlog')\n")
            actual.write_text("local option name\nlog using x, `option'(`ownlog')\n")
            report={"sourcePath":str(original),"tempPath":str(actual),"sourceIntact":True,
                "sourceSha256":task.identity(original)["sha256"]}
            evidence=client.execution_source_evidence({"status":{"requestId":"req1","sourceCompatibility":{"runId":"req1","sourceMode":"agent","referencedDoCopies":[report]}}},{})
            self.assertEqual(evidence["verdict"], "RUNTIME_TRANSFORMED_NOT_DISPLAYED")
            self.assertTrue(evidence["copies"][0]["sourceIntact"])
            self.assertNotEqual(evidence["copies"][0]["original"]["sha256"],evidence["copies"][0]["executed"]["sha256"])
            self.assertEqual(client.execution_source_evidence({"status":{}},{})["verdict"],"UNMEASURED")
    def test_resume_reuses_checkpoint_without_reexecuting_it(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp).resolve(); source = root / "stage.do"; source.write_text("display 1\n")
            manifest = {"taskId": "test", "stages": [
                {"id": str(i), "program": str(source), "cwd": tmp, "inputs": [],
                 "outputs": [str(root / (str(i) + ".dta"))], "dependencies": []} for i in (1, 2)]}
            count = []
            def dispatch(request, directory, timeout):
                stage = Path(directory).parent.name
                count.append(stage); (root / (stage + ".dta")).write_bytes(stage.encode())
                Path(directory).mkdir()
                outcome = {"verdict": "PASS_VISIBLE_COWORK_RUN"}
                task.write_once(Path(directory) / "result.json", outcome)
                return outcome
            first = task.run_task(manifest, root / "first", dispatch, Mock(side_effect=[{"paused": False}, {"paused": True}]))
            self.assertEqual(first["verdict"], "INCOMPLETE")
            self.assertTrue(first["stages"][0]["checkpointsVerified"])
            second = task.run_task(manifest, root / "second", dispatch, lambda: {"paused": False}, resume_from=root / "first")
            self.assertEqual(second["verdict"], "PASS_ALL_DECLARED_STAGES", second)
            self.assertEqual(count, ["1", "2"])
            self.assertTrue(second["stages"][0]["reusedWithoutDispatch"])
            (root / "1.dta").write_bytes(b"drift")
            third = task.run_task(manifest, root / "third", Mock(), lambda: {"paused": False}, resume_from=root / "second")
            self.assertEqual(third["verdict"], "INCOMPLETE")
            self.assertIn("drift", third["error"])

    def test_resume_never_resends_an_uncertain_or_failed_stage(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp); source = root / "stage.do"; source.write_text("display 1\n")
            manifest = {"taskId": "test", "stages": [{"id": "first", "program": str(source), "cwd": tmp,
                "inputs": [], "outputs": [str(root / "out.dta")], "dependencies": []}]}
            for index, verdict in enumerate(("EXECUTION_UNCONFIRMED_NO_RETRY", "STATA_ERROR_CONFIRMED_NO_RETRY")):
                prior = root / ("prior" + str(index))
                task.run_task(manifest, prior, Mock(return_value={"verdict": verdict}), lambda: {"paused": False})
                dispatch = Mock()
                result = task.run_task(manifest, root / ("resume" + str(index)), dispatch, lambda: {"paused": False}, resume_from=prior)
                dispatch.assert_not_called()
                self.assertEqual(result["verdict"], "INCOMPLETE")
                self.assertIn("never resend", result["error"])

    def test_freeze_preserves_source_and_rejects_drift(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source = root / "stage.do"
            source.write_text("display 1\n")
            original = source.read_bytes()
            frozen = task.freeze_program(source, root / "frozen")
            self.assertTrue(task.frozen_unchanged(frozen))
            self.assertEqual(source.read_bytes(), original)
            source.write_text("display 2\n")
            self.assertFalse(task.frozen_unchanged(frozen))
            self.assertEqual(Path(frozen["program"]).read_bytes(), original)
            with self.assertRaises(FileExistsError):
                task.freeze_program(source, root / "frozen")

    def test_failed_or_invisible_stage_never_runs_dependent(self):
        for verdict in ("STATA_ERROR_CONFIRMED_NO_RETRY", "EXECUTED_WITH_VISIBILITY_INTERRUPTION", "EXECUTION_UNCONFIRMED_NO_RETRY"):
            with tempfile.TemporaryDirectory() as tmp:
                root = Path(tmp); source = root / "stage.do"; source.write_text("display 1\n")
                manifest = {"taskId": "test", "stages": [
                    {"id": str(i), "program": str(source), "cwd": tmp, "inputs": [],
                     "outputs": [str(root / (str(i) + ".dta"))], "dependencies": []} for i in (1, 2)]}
                dispatch = Mock(return_value={"verdict": verdict})
                result = task.run_task(manifest, root / "run", dispatch, lambda: {"paused": False})
                self.assertEqual(dispatch.call_count, 1)
                self.assertEqual(result["verdict"], "INCOMPLETE")
                self.assertEqual(len(result["stages"]), 1)

    def test_pause_or_existing_output_has_zero_dispatch(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp); source = root / "stage.do"; source.write_text("display 1\n")
            target = root / "old.dta"; target.write_bytes(b"old")
            manifest = {"taskId": "test", "stages": [{"id": "first", "program": str(source), "cwd": tmp,
                "inputs": [], "outputs": [str(target)], "dependencies": []}]}
            for control in ({"paused": True}, {}, {"paused": False}):
                dispatch = Mock()
                folder = root / ("run" + str(len(list(root.iterdir()))))
                result = task.run_task(manifest, folder, dispatch, lambda: control)
                self.assertEqual(result["verdict"], "INCOMPLETE"); dispatch.assert_not_called()
            self.assertEqual(target.read_bytes(), b"old")

    def test_success_requires_actual_outputs_not_just_callback(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp); source = root / "stage.do"; source.write_text("display 1\n")
            manifest = {"taskId": "test", "stages": [{"id": "first", "program": str(source), "cwd": tmp,
                "inputs": [], "outputs": [str(root / "missing.dta")], "dependencies": []}]}
            result = task.run_task(manifest, root / "run", Mock(return_value={"verdict": "PASS_VISIBLE_COWORK_RUN"}), lambda: {"paused": False})
            self.assertEqual(result["verdict"], "INCOMPLETE")

    def test_real_error_shape_does_not_confuse_request_and_run(self):
        body = {"ok": False, "runId": "req-new", "error": "Stata error r(9)",
                "state": {"runId": "new", "requestId": "req-new", "phase": "failed"}}
        self.assertEqual(client.decode_response({"_httperror": json.dumps(body)}), body)
        log = b"CLIENT_START\nassert 0\nr(9);\n"
        observed = client.failure_evidence(body, state(), state("new"), log, "CLIENT_START")
        self.assertTrue(observed["confirmed"])
        self.assertEqual(observed["runId"], "new")
        for changed in [dict(body, state={}), dict(body, error="timeout"), dict(body, ok=True)]:
            self.assertFalse(client.failure_evidence(changed, state(), state("new"), log, "CLIENT_START")["confirmed"])
        self.assertFalse(client.failure_evidence(body, state(), state("new"), b"r(9);\n", "CLIENT_START")["confirmed"])
        self.assertFalse(client.failure_evidence(body, state(), state("new"), b"CLIENT_START\n", "CLIENT_START")["confirmed"])
        self.assertTrue(client.failure_evidence(body, state(), state("new"), b"{res}{txt}CLIENT_START\n{err}r(9);\n", "CLIENT_START")["confirmed"])
        self.assertFalse(client.failure_evidence(body, state(), state("new"), b'{com}. display "CLIENT_START"\n{err}r(9);\n', "CLIENT_START")["confirmed"])

    def test_client_uses_prepare_run_finish_and_keeps_failure_log(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp); source = root / "stage.do"; source.write_text("assert 0\n")
            frozen = task.freeze_program(source, root / "frozen")
            log = root / "source.log"; marker = "___VERIFIED_CLIENT_" + "a"*32 + "___"
            log.write_text(marker + "START\nr(9);\n")
            body = {"ok": False, "runId": "req-new", "error": "Stata error r(9)",
                "state": {"runId": "new", "requestId": "req-new", "phase": "failed", "logPath": str(log)}}
            ticket={"program":frozen["program"],"sha256":frozen["sha256"],"inputProgram":frozen["program"],"inputSha256":frozen["sha256"],"sourceCompilation":{"stable":True}}
            post = Mock(side_effect=[(200, {"ok": True, "token": "ticket", "layout": {"ok": True},"ticket":ticket}),
                (500, {"_httperror": json.dumps(body)}), (200, {"ticket": {"visibilityVerdict": "OBSERVED_VISIBLE"}})])
            with patch.object(client.uuid, "uuid4", return_value=SimpleNamespace(hex="a"*32)):
                result = client.execute_once(SimpleNamespace(w=SimpleNamespace(http_post=post)),
                    {"code": 'do "' + frozen["program"] + '"', "cowork": frozen}, root / "receipt",
                    observe=Mock(side_effect=[state(), state("new")]))
            self.assertEqual(result["verdict"], "STATA_ERROR_CONFIRMED_NO_RETRY")
            self.assertEqual(result["postCount"], 1)
            self.assertEqual([x.args[0] for x in post.call_args_list], ["/cowork/prepare", "/run-command", "/cowork/finish"])
            self.assertEqual((root / "receipt/run.log").read_bytes(), log.read_bytes())

    def test_old_runtime_cannot_silently_fallback(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp); source = root / "stage.do"; source.write_text("display 1\n")
            frozen = task.freeze_program(source, root / "frozen")
            post = Mock(return_value=(404, {}))
            result = client.execute_once(SimpleNamespace(w=SimpleNamespace(http_post=post)),
                {"code": "display 1", "cowork": frozen}, root / "receipt", observe=lambda _: state())
            self.assertEqual(result["postCount"], 0); self.assertEqual(post.call_count, 1)
            self.assertEqual(result["verdict"], "BLOCKED_NO_DISPATCH")


if __name__ == "__main__":
    unittest.main()
