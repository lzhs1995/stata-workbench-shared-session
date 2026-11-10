"""Public hygiene: tracked text must not carry personal home paths or private run artifacts."""
import re
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
# A home directory followed by an account name: C:\Users\<name>, C:/Users/<name>, /Users/<name>, /home/<name>
HOME = re.compile(r"(?:\b[A-Za-z]:(?:\\|/)+Users(?:\\|/)+|/Users/|/home/)([A-Za-z][A-Za-z0-9._-]*)")
NEUTRAL_ACCOUNTS = {"fixture", "test", "example", "runner", "user", "you", "Shared", "Public"}
# Reviewed exceptions: fixtures for the pinned author-path rewrite in scripts/stata_source_compat_core.js.
# They go away together with that runtime rule (a runtime change needs a new version).
REVIEWED = {
    ("scripts/test_stata_source_compat_rc7.js", 18),
    ("scripts/test_stata_source_compat_rc7.js", 61),
    ("scripts/test_runfile_finalizer_rc740.js", 95),
}
SKIP_PREFIXES = ("node_modules/", "upstream/")


def tracked_text():
    names = subprocess.run(["git", "ls-files", "-z"], cwd=ROOT, capture_output=True, check=True).stdout
    for rel in filter(None, names.decode("utf-8").split("\0")):
        if rel.startswith(SKIP_PREFIXES):
            continue
        data = (ROOT / rel).read_bytes()
        if b"\0" not in data:
            yield rel, data.decode("utf-8", "replace")


def personal_paths(rel, text):
    for number, line in enumerate(text.splitlines(), 1):
        for match in HOME.finditer(line):
            if match.group(1) not in NEUTRAL_ACCOUNTS:
                yield rel, number


class PublicHygieneTests(unittest.TestCase):
    def test_scanner_detects_personal_paths(self):
        # Built from parts so that this file itself does not contain a matching path.
        bs, sl = "\\\\", "/"
        sample = (f"a = 'C:{bs}Users{bs}someone{bs}x'\nb = '{sl}Users{sl}someone{sl}x'\n"
                  f"c = '{sl}home{sl}someone{sl}x'\nd = '{sl}Users{sl}fixture{sl}x'\n")
        self.assertEqual(list(personal_paths("sample", sample)), [("sample", 1), ("sample", 2), ("sample", 3)])

    def test_no_unreviewed_personal_paths(self):
        found = set()
        for rel, text in tracked_text():
            found.update(personal_paths(rel, text))
        self.assertEqual(sorted(found - REVIEWED), [], "personal home path in tracked file (file, line)")
        self.assertEqual(sorted(REVIEWED - found), [], "stale reviewed exception: remove it")

    def test_no_tracked_receipts(self):
        names = subprocess.run(["git", "ls-files"], cwd=ROOT, capture_output=True, check=True, text=True).stdout.split("\n")
        self.assertEqual([n for n in names if ".stata-receipts/" in n], [])


if __name__ == "__main__":
    unittest.main()
