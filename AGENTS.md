# Agent entry point — Stata Workbench Shared Session 0.2.0

**0.2.0 is a candidate undergoing delivery, not a released or live-accepted
daily package.** These instructions target extension ID
`lzhs1995.stata-workbench-shared-session`. They apply to shell-capable agents;
they do not establish that Codex, Claude Code or another host has completed
actual-host acceptance.

## Install and select the person's window

Read [README](README.md) ([简体中文](README.zh-CN.md),
[繁體中文](README.zh-TW.md)) and [the daily agent workflow](docs/agent-daily-workflow.md).
Use a locally supplied, reviewed 0.2.0 VSIX and its matching installed tools.
There is no asserted public 0.2.0 download URL yet. The separately versioned
[operating skill](https://github.com/lzhs1995/stata-workbench-shared-session-skill)
must explicitly match the installed build before use; an rc.7.45 or Next pin
does not certify this candidate.

The person opens a local project in an ordinary VS Code window and manually
runs **Stata: Start Shared Session**. Keep `stataMcp.loadStataOnStartup` false,
including any inherited user/workspace setting. An unrelated window must not
start Stata. Up to **two** independent ordinary-window sessions are supported,
including two windows using the same VS Code profile. People and agents take
turns within each session. Do not launch a replacement to bypass a refusal.

The registry default is `~/.stata-workbench/sessions/`, under
`STATA_WORKBENCH_HOME` when explicitly configured. VS Code and the shell must
use the same root. Do not inherit `STATA_WORKBENCH_NEXT_HOME` for this workflow;
the legacy launcher is not the daily startup route.

macOS shell, with the Code CLI on PATH and the reviewed extension installed in
the profile being used:

```sh
WB_EXTENSION="$(code --locate-extension lzhs1995.stata-workbench-shared-session)"
WB_AGENT="$WB_EXTENSION/tools/workbench_agent.py"
python3 -B "$WB_AGENT" sessions
python3 -B "$WB_AGENT" status --session SESSION_ID
```

Replace `SESSION_ID` with the exact ID for the person's workspace/window.
Windows discovery and equivalent PowerShell commands are in the daily guide.
Use that ID throughout the task, not whichever port answers. Identity or
bundle mismatches refuse execution; never bypass them or redirect to another
window. Tokens stay in the private registry and must not be copied into source
or public receipts.

## Run once, observe and honor Stop

Use saved Stata source inside that window's workspace, an existing working
directory, and a new workflow directory for every run:

```sh
python3 -B "$WB_AGENT" run --session SESSION_ID --file /abs/project/stage01.do --cwd /abs/project --workflow-dir /abs/receipts/stage01 --agent-name Codex
python3 -B "$WB_AGENT" status --workflow /abs/receipts/stage01
python3 -B "$WB_AGENT" reconcile --workflow /abs/receipts/stage01
```

Claude Code uses `--agent-name 'Claude Code'`. `run` starts a detached local
worker and returns; retain its workflow path and keep observing. CLI exit 0
alone is not execution success. Require the original receipt verdict
`PASS_VISIBLE_SHARED_RUN`, then inspect output and deliverables. A timeout,
missing run or idle window does not prove that nothing ran. Never resubmit an
`EXECUTION_UNCONFIRMED_NO_RETRY` run. A confirmed Stata error may follow partial
execution; inspect its `stataRc` and state before further work.

On a fresh user instruction to stop:

```sh
python3 -B "$WB_AGENT" stop --workflow /abs/receipts/stage01 --user-action 'stop it'
python3 -B "$WB_AGENT" reconcile --workflow /abs/receipts/stage01
```

Wait for confirmed pause/restoration and readiness of the same session.
External file writes are not rolled back. Native host cancellation is not a
Workbench Stop; its worker can remain active. The daily guide explains the
bounded original-run Stop claim and lost-response handling. Do not replay
execution or continue automatically. Recovery-required status is a refusal;
KILL may lose in-memory data and requires the person's informed confirmation.

## Human review of source changes

For `.do`, `.ado` and `.mata`, write proposed content to a separate proposal
file, not to the target. Use the bundled subcommand:

```sh
python3 -B "$WB_AGENT" propose-edit --workflow /abs/receipts/stage01 --content-file /abs/proposals/stage01-proposed.txt --reason 'Apply the requested model change'
python3 -B "$WB_AGENT" reconcile --workflow /abs/receipts/stage01 --proposal-id RETURNED_PROPOSAL_ID
```

This proposes an edit to the workflow's original source file. The person
reviews the immutable diff and selects **Accept** or **Reject**. Dirty buffers,
changed document versions/file hashes, expiry and session changes invalidate
acceptance. Preserve the person's edits, let them save, then propose again.
Never use direct Edit/Write/apply_patch or shell redirection on the target to
bypass the gate. This host rule is not an OS write sandbox.

The review window defaults to 120 seconds. Add `--review-timeout 900` when the
person needs fifteen minutes; accepted values are whole seconds from 1 to 900.
The original request records that duration. Polling never extends expiry, and
an unknown submission must still be queried by its original proposal ID.

**Accept only writes the file. It never executes or authorizes continuation.**
A fresh user continuation instruction must select the saved stage explicitly:

```sh
python3 -B "$WB_AGENT" continue --workflow /abs/receipts/stage01 --file /abs/project/stage03.do --workflow-dir /abs/receipts/stage03-continued --user-action 'Continue only the saved stage03.do'
```

`continue` requires the confirmed paused parent, the same ready session and no
intervening completed run. It runs the selected file from its beginning using
the parent's working directory; it does not infer a line or default to the old
file. Submit multi-stage work one saved stage at a time and inspect each receipt.
An unsaved future-stage edit must be resolved by the person before that stage.

## Repository work and evidence limits

Read [CONTRIBUTING.md](CONTRIBUTING.md) and [Development](README.md#development).
Use synthetic fixtures and preserve [upstream attribution](NOTICE). A docs-only
task must not regenerate bundles, pins or manifests. Check changed Markdown
links, examples against the CLI parser and `git diff --check`. Runtime release
checks and licensed live acceptance belong to separately scoped work.

The README's [platform results](README.md#platform-test-results) are historical
Next builds using isolated profiles. They do not validate the ordinary-window
0.2.0 candidate, human interaction or actual agent discovery. No native
Codex/Claude Stop/diff/continue hooks are installed by these instructions.
Preserve private workflow receipts and original attempts; do not commit research
data, registry tokens, logs or `.stata-receipts/`.
