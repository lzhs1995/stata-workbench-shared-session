"""Mock-only launcher tests: no process, network, GUI or Stata launch."""
import copy
import hashlib
from types import SimpleNamespace
import unittest
from unittest.mock import patch
import verified_workbench as v


class LauncherTests(unittest.TestCase):
    def test_declared_dependencies_match_real_disk(self):
        for path, expected in v.PINS.items():
            with self.subTest(path=str(path)):
                self.assertEqual(hashlib.sha256(path.read_bytes()).hexdigest(), expected)

    def setUp(self):
        self.state = {"launcherPid": 20, "owner": {"pid": 21, "ppid": 20},
                      "identityOk": True, "axWindowCount": 1, "status": {}}
        self.launched = []
        self.activated = []
        self.d = SimpleNamespace(w=SimpleNamespace(screen_locked=lambda: False),
            _activate_exact_pid_once=lambda pid: self.activated.append(pid) or {"ok": True})

    def test_reuse_never_launches(self):
        with patch.object(v, "observe", return_value=self.state):
            result = v.open_once(self.d, lambda: self.launched.append(True))
        self.assertEqual(result["verdict"], "REUSED")
        self.assertEqual(self.launched, [])
        self.assertEqual(self.activated, [20])

    def test_cold_launch_once(self):
        absent = dict(self.state, launcherPid=None, identityOk=False)
        with patch.object(v, "observe", side_effect=[absent, self.state, self.state]):
            result = v.open_once(self.d, lambda: self.launched.append(True), foreground=False)
        self.assertEqual(result["launchCount"], 1)
        self.assertEqual(self.launched, [True])
        self.assertEqual(self.activated, [])

    def test_existing_unready_never_restarts(self):
        with patch.object(v, "observe", return_value=dict(self.state, identityOk=False)):
            with self.assertRaisesRegex(RuntimeError, "not ready"):
                v.open_once(self.d, lambda: self.launched.append(True), timeout=0)
        self.assertEqual(self.launched, [])

    def test_multiwindow_rejects_before_activation(self):
        with patch.object(v, "observe", return_value=dict(self.state, axWindowCount=2)):
            with self.assertRaises(RuntimeError):
                v.open_once(self.d, lambda: self.launched.append(True))
        self.assertEqual(self.activated, [])

    def test_instance_swap_rejected(self):
        with patch.object(v, "observe", side_effect=[self.state, self.state, dict(self.state, launcherPid=99)]):
            with self.assertRaisesRegex(RuntimeError, "changed"):
                v.open_once(self.d, lambda: None)

    def test_screen_lock_blocks_launch(self):
        self.d.w.screen_locked = lambda: True
        with patch.object(v, "observe", return_value=dict(self.state, launcherPid=None)):
            with self.assertRaisesRegex(RuntimeError, "locked"):
                v.open_once(self.d, lambda: self.launched.append(True))
        self.assertEqual(self.launched, [])

    def test_binding_rejects_wrong_parent_and_duplicate_instances(self):
        instance = {"launcher": True, "pid": 20}
        status = {"extensionVersion": v.VERSION, "diskBundleSha256": v.BUNDLE_SHA256,
                  "bundleIdentityState": "OK", "guardModuleIdentityState": "OK", "extensionHostPid": 21}
        w = SimpleNamespace(code_instances=lambda: [instance],
            bridge_owner=lambda: {"pid": 21, "ppid": 99, "launcher": True},
            status=lambda **kw: status, launcher_window_count=lambda pid: 1)
        with self.assertRaisesRegex(RuntimeError, "does not belong"):
            v.observe(SimpleNamespace(w=w))
        w.bridge_owner = lambda: {"pid": 21, "ppid": 20, "launcher": True}
        self.assertTrue(v.observe(SimpleNamespace(w=w))["identityOk"])
        w.code_instances = lambda: [instance, copy.deepcopy(instance)]
        with self.assertRaisesRegex(RuntimeError, "multiple"):
            v.observe(SimpleNamespace(w=w))


if __name__ == "__main__":
    unittest.main()
