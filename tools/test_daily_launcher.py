import unittest
from unittest.mock import Mock
import stata_session


class DailyLauncherTests(unittest.TestCase):
    def test_stable_open_retires_legacy_before_creating_or_starting_anything(self):
        sessions = Mock()
        for args in (["open", "A"], ["open", "A", "--prepare-only"]):
            with self.assertRaisesRegex(stata_session.SessionError, "LEGACY_LAUNCH_RETIRED"):
                stata_session.main(args, sessions=sessions)
        self.assertEqual(sessions.method_calls, [])
