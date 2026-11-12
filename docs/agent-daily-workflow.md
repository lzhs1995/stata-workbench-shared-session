# Codex and Claude Code: daily Workbench workflow

This contract targets the **Stata Workbench Shared Session 0.2.0 candidate**,
which is undergoing delivery and is **not released**, extension ID
`lzhs1995.stata-workbench-shared-session`. The agent CLI is shipped in
`tools/workbench_agent.py`. It uses the authenticated local window registry;
it does not launch a new VS Code window, install an extension, choose another
session or recover a stale session. Manually Start the intended window before
agent work; a submission can still invoke that session's backend warm-up.
Release installation and actual-host acceptance
must be completed against the integrated 0.2.0 package before calling this a
validated daily installation. Next evidence is not evidence for that package.

## Install and discover once

Install a locally supplied, reviewed 0.2.0 VSIX in the **ordinary local VS Code
profile** used for work, using Extensions → Install from VSIX. Verify its
SHA256 against that delivery's reviewed value; no public 0.2.0 download URL is
asserted yet. Follow [installation prerequisites](../README.md#install) first;
installing the VSIX does not provision or validate the Stata service runtime.
Open the project folder and manually run **Stata: Start Shared Session** from
the Command Palette. Keep `stataMcp.loadStataOnStartup` false, including any
inherited setting. There are at most **two** independent ordinary-window
sessions, including two windows in the same VS Code profile. An unrelated
non-Stata window must not start an engine. People and agents use each session
serially; two separate sessions can run independent models in parallel.
Use the installed extension's Python tools, so the client and bundle pins match.
Python 3.10 or later is required. Do not point these tools at another checkout's
bundle or run both Stable and Next extensions in the same target window.

macOS shell (Code CLI must be installed in PATH):

```sh
WB_EXTENSION="$(code --locate-extension lzhs1995.stata-workbench-shared-session)"
WB_AGENT="$WB_EXTENSION/tools/workbench_agent.py"
test -f "$WB_AGENT" || { printf '%s\n' 'Matching Workbench agent tool not found'; exit 1; }
python3 -B "$WB_AGENT" sessions
```

Windows PowerShell (use the configured Python executable):

```powershell
$WbPython = Join-Path $env:LOCALAPPDATA 'Programs\Python\Python314\python.exe'
$WbExtension = (code --locate-extension lzhs1995.stata-workbench-shared-session).Trim()
$WbAgent = Join-Path $WbExtension 'tools\workbench_agent.py'
if (-not (Test-Path $WbPython) -or -not (Test-Path $WbAgent)) { throw 'Check Python and the installed Workbench path' }
& $WbPython -B $WbAgent sessions
```

Select an exact `sessionId` from that output. Do not select merely by whichever
port happens to answer. Check the workspace and session shown in the intended
window. The default state root is **`~/.stata-workbench`**, or the absolute
directory set in **`STATA_WORKBENCH_HOME`**. VS Code must inherit the same root
as the agent shell. Clear a legacy `STATA_WORKBENCH_NEXT_HOME` in this workflow;
the compatibility fallback in older tools is not the ordinary-window root.
`--state-root /absolute/path` before the subcommand selects an explicit registry
root for this CLI; it does not move or create a window session. A lost session is an error,
never an invitation to bind another session. Registry tokens stay local and
are not printed by `sessions`.

## Run, observe, Stop, edit and continue

The examples below assume `/abs/project/stage01.do` is a saved file inside the
receiving window's workspace. Replace these example absolute paths and the
session ID with the actual values. Each run needs a **new** workflow directory.

```sh
python3 "$WB_AGENT" status --session SESSION_ID
python3 "$WB_AGENT" run --session SESSION_ID --file /abs/project/stage01.do --cwd /abs/project --workflow-dir /abs/receipts/stage01 --agent-name Codex
python3 "$WB_AGENT" status --workflow /abs/receipts/stage01
python3 "$WB_AGENT" reconcile --workflow /abs/receipts/stage01
```

For Claude Code use `--agent-name 'Claude Code'`. PowerShell uses the same
arguments after `& $WbPython -B $WbAgent`, with absolute Windows paths. There is
one implementation and receipt contract for both hosts, not two competing
Stata execution integrations.

Scripts that contain paths from another computer require explicit
[`stataMcp.sourcePathMappings`](source-path-mappings.md). The default does not
guess a replacement account or research directory. Agent workflows use the
selected source's folder configuration and preserve the original saved file.

`run` returns after starting a detached local worker. It does not wait for the
regression; the host remains able to read progress, receive user instructions,
and request Stop. The worker invokes the existing single-dispatch verifier.
`status --workflow` reads local receipt/worker state only; it does not stream
Stata output. The person sees live output in the Stata Terminal. `reconcile` additionally observes
the same authenticated session and original run binding. It never submits
code. A successful query (exit 0) is **not** an execution PASS: inspect `state`
and the original receipt's `verdict`. The receipt alone certifies execution;
an idle window or a missing event cannot establish completion.

When the person says “stop it”, issue:

```sh
python3 "$WB_AGENT" stop --workflow /abs/receipts/stage01 --user-action 'stop it'
python3 "$WB_AGENT" reconcile --workflow /abs/receipts/stage01
```

The Stop request checks the original session, generation and active run ID in
the receiver. It returns before restoration finishes. Keep observing that
original workflow until the receipt confirms the Stop restored the pre-run
checkpoint and the session is ready. Code may have partly run before Stop;
external file writes are not undone. A user clicking Workbench Stop is recorded
as `person`; the CLI honoring a spoken Stop is recorded as `api`. Neither
origin is relabeled. A native Codex/Claude cancellation only cancels the host
operation: it is not proof of a Workbench Stop. The durable worker can outlive
that host operation, so use the original workflow to observe/stop it.

If Stop says `stop-pending-original-run`, the intent is already recorded and
the worker refuses a not-yet-submitted run. If an HTTP submission was racing,
poll the same workflow and call `stop` again once its original run is visible;
the durable stop-dispatch claim allows at most one actual Stop input. If that
input's response is lost, only reconcile. Do not create another run.

To propose a change, supply proposed text on stdin or a separate proposal file;
**do not overwrite the target .do first**:

```sh
python3 "$WB_AGENT" propose-edit --workflow /abs/receipts/stage01 --content-file /abs/proposals/stage01-proposed.txt --reason 'Apply the requested model change'
python3 "$WB_AGENT" reconcile --workflow /abs/receipts/stage01 --proposal-id RETURNED_PROPOSAL_ID
```

The proposal targets the workflow's original source path; there is no separate
`--file` option for this subcommand. The receiving window displays two immutable,
readonly texts. The person can
Accept or Reject. If they instead edit the original buffer, save it and submit
a new proposal; dirty/version/SHA conflicts invalidate the old one. The gate
also checks workspace realpaths and session generation, retains an original
snapshot, and serializes final checks and writes per target. Proposals expire
after two minutes by default; clicking an old Accept afterward has no effect.
A duplicate proposal ID with identical bytes returns its original state;
different bytes under that ID are refused. If the submit response is lost,
query the returned durable ID from the workflow's `proposals/` directory.
An extension restart invalidates pending proposals; an interrupted write is
`unknown`, never auto-replayed or declared accepted.

**Accept writes only.** Continue is a separate, fresh user instruction:

```sh
python3 "$WB_AGENT" continue --workflow /abs/receipts/stage01 --file /abs/project/stage03.do --workflow-dir /abs/receipts/stage03-continued --user-action 'Continue only the saved stage03.do'
```

Continue requires a confirmed pause, the same restored generation, a ready
session, no intervening completed run and a clean, explicitly selected saved
stage inside the same window's workspace. `--file` is mandatory; the CLI
inspects that stage's document version, rereads its bytes and creates a new
workflow and receipt with its own source SHA, linked to the paused parent.
It runs only the selected file from its beginning, with the parent's working
directory. Select a saved stage containing exactly the work the person wants
to continue. The parent's source is allowed only when explicitly selected
with `--file`; it is never the default. There is no inference or extraction
of a continuation point from a Stata line number.
For a five-stage task, submit one stage at a time and reconcile its receipt
before selecting the next file. An unsaved edit to a future stage must be
resolved by the person; never run an older disk copy silently.

## Host adapter rules

Codex and Claude Code invoke the CLI with their ordinary shell tool. There is
no automatic native Stop/diff/continue hook installed by this change. A host
adapter should persist the returned workflow path in its task state, poll
`status`/`reconcile`, and route fresh user Stop/continue instructions explicitly.
It must return control after submission rather than wait synchronously on a
long Stata call. Use these rules in each host's project instructions:

> Run Stata only through the installed workbench_agent.py CLI and an explicitly
> selected session. Preserve workflow paths and receipts. Never retry unknown
> execution, auto-continue after Stop, or infer continue from Accept. Propose
> Stata source edits via propose-edit; do not use native Edit/Write/apply_patch
> or shell redirection on those target files. Honor dirty-buffer conflicts and
> wait for the person's saved version. Report raw status and origin truthfully.

These are host instructions, **not an OS write sandbox**. Claude Edit/Write
deny rules do not prevent shell writes; no unverified Codex per-glob restriction
is claimed. Hard prevention requires separate verified source access isolation.
The CLI's guards protect its own routes, not arbitrary tools the host can run.

## API and integration boundaries

| Operation | Existing or added interface | Mutation |
|---|---|---|
| sessions/status | Existing registry and authenticated `GET /status` | None |
| run | Existing `POST /run-command` plus `agentWorkflow` precondition and durable workflow/run binding | Single execution |
| original run lookup | Added `GET /agent-runs/:workflowId` | None; reservation is not proof of dispatch |
| Stop | Added `POST /agent-stop`, `sessionId`, `generation`, `expectedRunId` | One original-run Stop |
| editor state | Added `POST /document-state` | Opens document for inspection; never saves |
| proposal | Added asynchronous `POST /propose-edit` with client proposal ID | Writes only after human Accept |
| proposal lookup | Added `GET /proposals/:proposalId` | None except interrupted-state finalization |
| reconcile/continue | New CLI wrappers over original receipts and guarded APIs | Reconcile observes; continue starts a distinct user-requested run |

The candidate uses the Shared Session identity and ordinary-window state root
above. Final release integration still owns package/pin verification and exact
build acceptance. Execution locks are keyed by session, not shared VS Code
profile. Actual Codex and Claude discovery, host
cancellation, human diff interactions and Windows/macOS ordinary-window flows
remain required acceptance; offline mocks do not establish them.
