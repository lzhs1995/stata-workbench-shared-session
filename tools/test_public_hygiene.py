"""Narrow tracked-text home-path and receipt checks, not a comprehensive secret scan."""
import hashlib
import re
import subprocess
import unittest
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
# A home directory followed by an account name: C:\Users\<name>, C:/Users/<name>, /Users/<name>, /home/<name>
# Intentionally limited to ASCII account characters; not a complete path parser.
HOME = re.compile(r"(?:\b[A-Za-z]:(?:\\|/)+(?i:Users)(?:\\|/)+|/Users/|/home/)([A-Za-z0-9._-]+)")
NEUTRAL_ACCOUNTS = {"fixture", "test", "example", "runner", "user", "you", "Shared", "Public"}
# Reviewed exceptions: fixtures for the pinned author-path rewrite in scripts/stata_source_compat_core.js.
# They go away together with that runtime rule (a runtime change needs a new version).
# Each value binds the complete UTF-8 line (excluding its newline) and the exact
# number of non-neutral home paths. Never copy personal plaintext into this list.
REVIEWED = {
    ("scripts/test_stata_source_compat_rc7.js", 18):
        ("8b4a88d4cddaa7ce90661f3be70420f086811d129dad036837fa16fd29a633f9", 1),
    ("scripts/test_stata_source_compat_rc7.js", 61):
        ("8cbbef77d61f95b3e690e26622a5a6d619947b698ad7018836be0deff808e608", 1),
    ("scripts/test_runfile_finalizer_rc740.js", 95):
        ("a576b36b01948ca9e3a0fd814be3d03dbf1d3723adb61ccaadb34b63d2a1b809", 1),
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


def review_findings(texts, reviewed=REVIEWED):
    """Return changed/unreviewed locations and stale exceptions without path values."""
    found = {}
    for rel, text in texts:
        lines = text.splitlines()
        for location, count in Counter(personal_paths(rel, text)).items():
            line = lines[location[1] - 1]
            found[location] = (hashlib.sha256(line.encode("utf-8")).hexdigest(), count)
    unreviewed = sorted(location for location, signature in found.items()
                        if reviewed.get(location) != signature)
    stale = sorted(set(reviewed) - found.keys())
    return unreviewed, stale


class PublicHygieneTests(unittest.TestCase):
    def test_scanner_detects_personal_paths(self):
        # Built from parts so that this file itself does not contain a matching path.
        bs, sl = "\\\\", "/"
        sample = (f"a = 'C:{bs}Users{bs}someone{bs}x'\nb = '{sl}Users{sl}someone{sl}x'\n"
                  f"c = '{sl}home{sl}someone{sl}x'\nd = '{sl}Users{sl}fixture{sl}x'\n")
        self.assertEqual(list(personal_paths("sample", sample)), [("sample", 1), ("sample", 2), ("sample", 3)])

    def test_windows_prefix_case_and_account_characters(self):
        for prefix in ("Users", "users", "uSeRs"):
            for separator in ("\\", "\\\\", "/"):
                for account in ("someone", "123person", "_person", "person.name"):
                    with self.subTest(prefix=prefix, separator=separator, account=account):
                        text = f"c:{separator}{prefix}{separator}{account}{separator}private"
                        self.assertEqual(list(personal_paths("sample", text)), [("sample", 1)])

    def test_reviewed_line_rejects_appended_path_and_account_replacement(self):
        # Mutate each real approved line in memory only; leave pinned fixtures intact.
        for location in REVIEWED:
            rel, number = location
            lines = (ROOT / rel).read_text(encoding="utf-8").splitlines()
            original = lines[number - 1]
            account = next(match for match in HOME.finditer(original)
                           if match.group(1) not in NEUTRAL_ACCOUNTS)
            sl = "/"
            changes = {
                "appended_path": original + f" // {sl}Users{sl}differentPerson{sl}private",
                "replaced_account": original[:account.start(1)] + "differentPerson" + original[account.end(1):],
                "changed_line_content": original + " // newly edited",
            }
            for change, line in changes.items():
                with self.subTest(location=location, change=change):
                    modified = list(lines)
                    modified[number - 1] = line
                    unreviewed, stale = review_findings([(rel, "\n".join(modified))])
                    self.assertIn(location, unreviewed)
                    self.assertNotIn(location, stale)
            with self.subTest(location=location, change="stale_exception"):
                lines[number - 1] = "// reviewed path removed"
                unreviewed, stale = review_findings([(rel, "\n".join(lines))])
                self.assertIn(location, stale)
                self.assertNotIn(location, unreviewed)

    def test_reviewed_match_count_is_exact(self):
        sl = "/"
        line = f"{sl}Users{sl}someone{sl}private {sl}home{sl}someone{sl}other"
        location = ("sample", 1)
        digest = hashlib.sha256(line.encode("utf-8")).hexdigest()
        self.assertEqual(review_findings([("sample", line)], {location: (digest, 2)}), ([], []))
        self.assertEqual(review_findings([("sample", line)], {location: (digest, 1)}), ([location], []))

    def test_new_file_match_is_unreviewed(self):
        sl = "/"
        self.assertEqual(review_findings([("new.md", f"{sl}home{sl}newPerson{sl}private")], {}),
                         ([("new.md", 1)], []))

    def test_missing_reviewed_file_is_stale(self):
        self.assertEqual(review_findings([]), ([], sorted(REVIEWED)))

    def test_no_unreviewed_personal_paths(self):
        unreviewed, stale = review_findings(tracked_text())
        self.assertEqual(unreviewed, [], "unreviewed or changed personal home path (file, line)")
        self.assertEqual(stale, [], "stale reviewed exception: remove it")

    def test_no_tracked_receipts(self):
        names = subprocess.run(["git", "ls-files"], cwd=ROOT, capture_output=True, check=True, text=True).stdout.split("\n")
        self.assertEqual([n for n in names if ".stata-receipts/" in n], [])


if __name__ == "__main__":
    unittest.main()
