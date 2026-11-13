# Stata Workbench Shared Session

[English](README.md) | [简体中文](README.zh-CN.md) | [繁體中文](README.zh-TW.md)

<img src="media/icon.png" alt="Stata Workbench Shared Session icon" width="96">

> **0.2.0 candidate — undergoing delivery, not released.** The ordinary-window
> workflow below describes the candidate. Exact-package installation, live
> acceptance and actual Codex/Claude host interactions are still required.
> Historical Next results below do not establish those passes.

Work with a person and AI agents in the same visible Stata session inside
VS Code. Watch output as a model runs, press Stop, review a proposed code change,
and decide which saved stage to run next. Data, macros, scalars, estimates and
graphs are shared within the session; save results before closing or resetting it.

- **Two independent analysis windows.** Start up to two sessions manually in
  ordinary VS Code windows, including windows in the same profile. Each has its
  own Stata backend, port, runtime, temporary files and checkpoints.
- **Visible collaboration.** People and agents take turns in each session;
  separate sessions can run different models in parallel.
- **Human-reviewed edits.** Agents propose `.do`, `.ado` or `.mata` changes in
  a diff. Accept writes the file; a new user instruction is needed to continue.
- **Receipts and explicit recovery.** An uncertain execution is never retried
  automatically. Failed restoration leaves the session blocked.

Derived from [tmonk/stata-workbench](https://github.com/tmonk/stata-workbench)
(AGPL-3.0-or-later); see [License](#license).

<!-- portfolio-stata-navigation-20261110 -->
## Project family · 專案導覽

| Repository | Role · 角色 |
| --- | --- |
| [Shared Session](https://github.com/lzhs1995/stata-workbench-shared-session) | Current runtime line and versioned releases · 現役執行環境與版本發行 |
| [Operating skill](https://github.com/lzhs1995/stata-workbench-shared-session-skill) | Separately versioned agent guidance and runtime compatibility checks · 獨立版本的代理操作指南與執行環境相容檢查 |
| [Next](https://github.com/lzhs1995/stata-workbench-next) | Development line and historical preview evidence · 開發分支與歷史預覽版證據 |

These repositories have different roles and release cycles. Use the runtime and
skill versions named by their compatibility records; Next remains a separate
preview and does not replace an existing research session.

三個倉庫各自維護版本。請依相容紀錄選用執行環境與操作技能；Next 為獨立預覽版，
不會取代現有的研究工作階段。
<!-- /portfolio-stata-navigation-20261110 -->

## Contents

- [Candidate identity](#candidate-identity) and [Requirements](#requirements)
- [Install](#install) and [Quick start](#quick-start)
- [Agent workflow](docs/agent-daily-workflow.md) and [AGENTS.md](AGENTS.md)
- [Features](#features), [Configuration](#configuration), [Troubleshooting](#troubleshooting)
- [Known limitations](#known-limitations) and [Platform test results](#platform-test-results)
- [Development](#development) and [License](#license)

## Candidate identity

| Item | 0.2.0 candidate |
| --- | --- |
| Extension ID | `lzhs1995.stata-workbench-shared-session` |
| Manual entry | **Stata: Start Shared Session** in the intended ordinary window |
| State root | `~/.stata-workbench`, overridden by `STATA_WORKBENCH_HOME` |
| Registry | `<state-root>/sessions/<sessionId>.json` |
| Local port | Automatically assigned; discover it through the registry |
| Concurrency | At most two independent sessions; one request at a time per session |
| Agent client | The installed extension's `tools/workbench_agent.py` |

Next remains the development line. Its isolated launcher, five-session tests,
`~/.stata-workbench-next` root and extension ID belong to historical previews.
Do not use them as the ordinary-window setup. The operating skill is versioned
separately: its old rc.7.45 compatibility record does not certify 0.2.0.
Do not enable both Shared Session and Next in the target window.

## Requirements

Use a local macOS or Windows window with a licensed Stata installation, VS Code
1.75 or later, and Python 3.10 or later for the bundled agent tools. A matching
Stata service runtime must already be prepared: Python 3.11, `mcp-stata==1.26.1`
and compatible MCP 1.x (the repository constraints pin `mcp==1.28.1`).
Installing a VSIX does not establish that these dependencies exist or work.

The runtime is normally at `~/.local/share/stata-workbench/mcp-stata-1.26.1` on
macOS, or `%LOCALAPPDATA%\stata-workbench\mcp-stata-1.26.1` on Windows. Each
started window prepares a private copy of one source, chosen in this order:

1. the `stataMcp.runtimeRoot` setting (workspace folder, then workspace, then user);
2. `MCP_STATA_RUNTIME_ROOT` in the MCP server's `env`, then in the VS Code process;
3. a server that runs a virtual environment's own Python with `-m mcp_stata`
   (`<venv>/bin/python3`, or `<venv>\Scripts\python.exe` on Windows);
4. the managed runtime above, also when the server is the standard
   `uvx ... mcp-stata` launch or there is no MCP configuration.

Before the copy is sized, the source is checked with a short isolated metadata
query (`python -I -B`; it neither imports `mcp_stata` nor starts Stata): it must
be a virtual environment whose own prefix is the folder and which contains
`mcp-stata==1.26.1` and MCP 1.x. An explicit choice that fails this check stops
the session with the reason; no other source is tried. A server that starts
mcp_stata through any other command, such as a base Python running a wrapper
script, is refused with `RUNTIME_SOURCE_UNSUPPORTED`. Fix it for this workspace,
without editing the existing MCP configuration:

```json
{ "stataMcp.runtimeRoot": "C:\\Users\\you\\AppData\\Local\\stata-workbench\\mcp-stata-1.26.1" }
``` Keep at least
20 GiB free on macOS or 10 GiB on Windows **after** that copy; admission refuses
insufficient space. These are candidate requirements, not current live-test claims.

## Install

1. Obtain the locally supplied, reviewed `stata-workbench-shared-session-0.2.0.vsix`
   and its exact SHA256 from the delivery owner. There is no asserted public
   0.2.0 release URL yet. On macOS use `shasum -a 256 /absolute/path/to/file.vsix`;
   on Windows use `(Get-FileHash 'C:\absolute\path\file.vsix' -Algorithm SHA256).Hash.ToLower()`.
   Compare the complete value with the reviewed delivery before installing.
2. In the ordinary VS Code profile you intend to use, choose **Extensions →
   Install from VSIX…** and select that file. Use the intended window; finish
   existing work and save its data before any requested reload. Installation
   does not prove activation, dependency setup or live readiness.
3. Open your local project folder and grant workspace trust only when you trust
   that folder. Keep `stataMcp.loadStataOnStartup` **false**, including inherited
   user/workspace settings. Set `stataMcp.stataPath` if Stata is not discovered.
4. Manually run **Stata: Start Shared Session** in the Command Palette. This
   connects this window's session and opens its Terminal. Opening an unrelated
   window must not start an engine. For a second independent model, open another
   ordinary window and start it there; no special launcher or profile is needed.

If the runtime is missing or mismatched, stop at the reported setup error and
have the matching runtime prepared before Start. No automatic dependency
installation or completed clean-machine setup is claimed by this candidate.

## Quick start

The person can use **Stata: Run Current File** (`Cmd+Shift+D` on macOS,
`Ctrl+Shift+D` on Windows), **Stata: Run Selection/Current Line**, or the Stata
Terminal. Watch the run's output and identity in that window.

A shell agent uses the tools bundled with the installed extension. With the
Code CLI on PATH, macOS discovery is:

```sh
WB_EXTENSION="$(code --locate-extension lzhs1995.stata-workbench-shared-session)"
WB_AGENT="$WB_EXTENSION/tools/workbench_agent.py"
python3 -B "$WB_AGENT" sessions
```

Windows PowerShell, after selecting the installed Python path:

```powershell
$WbPython = Join-Path $env:LOCALAPPDATA 'Programs\Python\Python314\python.exe'
$WbExtension = (code --locate-extension lzhs1995.stata-workbench-shared-session).Trim()
$WbAgent = Join-Path $WbExtension 'tools\workbench_agent.py'
if (-not (Test-Path $WbPython) -or -not (Test-Path $WbAgent)) { throw 'Check Python and the installed Workbench path' }
& $WbPython -B $WbAgent sessions
```

Use the installation matching the target profile, not an arbitrary source
checkout. Choose the exact `sessionId` for the person's workspace/window.
Replace `SESSION_ID` and `/abs/...` with real values. Use a saved source inside
that workspace and a new workflow directory. On Windows use the same arguments
after `& $WbPython -B $WbAgent`, with absolute Windows paths.

```sh
python3 -B "$WB_AGENT" status --session SESSION_ID
python3 -B "$WB_AGENT" run --session SESSION_ID --file /abs/project/stage01.do --cwd /abs/project --workflow-dir /abs/receipts/stage01 --agent-name Codex
python3 -B "$WB_AGENT" status --workflow /abs/receipts/stage01
python3 -B "$WB_AGENT" reconcile --workflow /abs/receipts/stage01
```

For Claude Code use `--agent-name 'Claude Code'`. `run` returns after starting a
local worker, so the agent remains available for user instructions. Exit 0
from a query/submission is not execution PASS: inspect `state` and the original
receipt's `verdict`. Only `PASS_VISIBLE_SHARED_RUN` confirms checked execution;
scientific correctness still requires reviewing output. Unknown execution must
not be resubmitted. Receipts contain private source/output; keep them local.

When the person says “stop it”:

```sh
python3 -B "$WB_AGENT" stop --workflow /abs/receipts/stage01 --user-action 'stop it'
python3 -B "$WB_AGENT" reconcile --workflow /abs/receipts/stage01
```

Observe the original workflow until pause/restoration and readiness are
confirmed. Host cancellation alone does not stop the Workbench worker. External
file writes are not undone. See the [daily workflow](docs/agent-daily-workflow.md)
for the bounded Stop retry rule when the original run is not yet visible.

Propose new text in a separate file; never overwrite the target first:

```sh
python3 -B "$WB_AGENT" propose-edit --workflow /abs/receipts/stage01 --content-file /abs/proposals/stage01-proposed.txt --reason 'Apply the requested model change'
python3 -B "$WB_AGENT" reconcile --workflow /abs/receipts/stage01 --proposal-id RETURNED_PROPOSAL_ID
```

The proposal targets that workflow's original source. The person selects
**Accept** or **Reject** in the diff. If they edit the original buffer instead,
let them save and submit a fresh proposal; dirty/version/SHA conflicts refuse
the old one. **Accept only writes.** After a confirmed pause, a fresh user
instruction can explicitly select the saved stage to continue:

```sh
python3 -B "$WB_AGENT" continue --workflow /abs/receipts/stage01 --file /abs/project/stage03.do --workflow-dir /abs/receipts/stage03-continued --user-action 'Continue only the saved stage03.do'
```

This runs only the selected file **from its beginning**, using the parent's
working directory. It does not resume at an inferred line. Submit staged work
one file at a time and inspect each receipt. Resolve unsaved edits before
running the next stage. Save needed data and close the intended window through
VS Code when finished; do not terminate a shared Code process to close one session.

## Features

Each session shares Stata state and live output between people and agents.
Execution is serialized within it; a busy target is never rerouted to another
window. The private registry and authenticated bridge bind session, generation
and installed bundle. The bundled CLI exposes `sessions`, `status`, `run`,
`stop`, `propose-edit`, `reconcile` and `continue`.

<a id="reviewed-agent-edits-to-stata-files"></a>

Edit proposals check workspace realpaths, dirty buffers, document version and
file SHA; they expire and preserve an original snapshot. Acceptance does not
execute. Agents must use this flow for Stata source edits; these host
instructions do not create an OS write sandbox.

Stop attempts to restore an agent run's pre-run checkpoint. A person's run may
have no checkpoint. Restoration failure keeps the session blocked. **Stata:
KILL** is a distinct recovery action that can lose in-memory data and requires
informed confirmation; an unknown cleanup is never a clean result.

## Configuration

| Setting | Current ordinary-window guidance |
| --- | --- |
| `stataMcp.loadStataOnStartup` | Keep `false`; start manually |
| `stataMcp.visibleBridgePort` | `0` for automatic assignment; an explicit port must be unique |
| `stataMcp.stataPath` | Local licensed Stata executable when needed |
| `stataMcp.sourcePathMappings` | Explicit mappings only; see [path mapping guide](docs/source-path-mappings.md) |
| `STATA_WORKBENCH_HOME` | Absolute state root; default `~/.stata-workbench`; use the same value in VS Code and the shell |

The CLI also accepts `--state-root /absolute/path` **before** its subcommand.
This selects an existing registry; it does not start or move a session. Clear
legacy `STATA_WORKBENCH_NEXT_HOME` for this workflow. Each session's runtime,
checkpoints and temporary files live under `<state-root>/runs/<sessionId>/`.
Do not copy tokens or hand-edit session ownership records.

## Troubleshooting

| Symptom | Action |
| --- | --- |
| No intended session in `sessions` | Verify the installed extension/profile and state root; manually Start in the intended window |
| `SESSION_LIMIT` | Two engines or unresolved cleanup slots already exist; finish/close the intended session and verify cleanup, without deleting slot files |
| `RUNTIME_SOURCE_MISSING` / dependency error | Prepare the matching service runtime; installing a VSIX alone is insufficient |
| `RUNTIME_SOURCE_UNSUPPORTED` / `RUNTIME_SOURCE_INVALID` / `RUNTIME_INVALID` | Set `stataMcp.runtimeRoot` in the workspace to the absolute folder of a verified mcp-stata 1.26.1 virtual environment; the message names the rejected source and the managed path |
| `DISK_RESERVE` | Restore the required free space before preparing a runtime copy |
| Identity/bundle mismatch | Use matching installed tools and inspect the original window; do not bypass or switch target |
| `unknown-no-retry` / `EXECUTION_UNCONFIRMED_NO_RETRY` | Reconcile original workflow/receipt; never blindly resubmit |
| Dirty/version/SHA proposal conflict | Preserve the person's buffer; have them save, then propose again |
| Recovery required / HTTP 423 | Stop dependent work; inspect the original receipt and window. KILL requires informed confirmation of data loss; never bypass the recovery gate |
| Closing or cleanup pending | Preserve the evidence and investigate the exact owned session; unknown cleanup is not permission to kill shared Code or other Stata processes |

## Known limitations

The **0.2.0 ordinary-window package has not yet completed delivery acceptance**.
Current requirements include exact-package macOS/Windows installation,
same-profile two-window isolation, actual Codex/Claude discovery and execution,
human diff Accept/edit/continue, Stop and recovery/close checks. Offline tests,
installation success and historical Next live results do not establish these.
No native host Stop/diff/continue hook is installed by this guide. Remote
extension hosts, Linux and other unlisted OS variants are not validated.

<details>
<summary>Historical Next limitations and fixes — original builds only</summary>

The following retained notes describe the named Next builds and their isolated
launcher. References to “main”, five sessions, startup flags and profile paths
are historical; do not apply those setup/recovery recipes to 0.2.0 ordinary windows.

Fixed on `main` (`e9b22430`, PR #17) and confirmed live on Windows on `3765d82a`, 11-03, except where noted:

- **Windows: the first command after opening a window could lock the session (the remaining stall is covered by the warm-up fix below).** With `stataMcp.loadStataOnStartup: false`, Stata loads only when the first command arrives. On Windows that first command stalled in 2 of 3 attempts, returned HTTP 504 after about 120 s and locked the session. The launcher now writes `true` by default, so Stata loads while the window opens (57.7 s on Windows 11). The problem still occurs if a profile sets `false` explicitly (last checked on `3765d82a`); the launcher keeps that value and `open` says so in its `backendLoad` field. To unlock such a session, click **Stata: KILL**; to avoid it, remove the `false` entry from `profiles/<name>/user-data/User/settings.json` before `open`. macOS was not affected in the tests so far.
- **Late events from a cancelled command went to the wrong run.** On Windows a command whose cancel was reported as confirmed still ran about 2 s later, and its late log event was given to the run that came next (the quiescence probe). The session was locked, so nothing built on the wrong state, and since PR #15 such a response reports `EXEC_OUTCOME_UNKNOWN` with `payloadMayHaveRun: true` (confirmed live on Windows, `e7e54848`). PR #17 now keeps events with their task: after a run ends without its response, events with an unknown task id are no longer given to the active run but are held or dropped. The holding buffer keeps at most 256 events; if all of them are `log_path` or `task_done` events, a new `task_done` can be dropped.
- **A watchdog cancel could show an earlier failure's reason.** On the agent path the status after a watchdog cancel repeated the reason and timing of an earlier Terminal failure. Each cancel now writes its own `stallReason` and `elapsedMs`, and the lock reason reads for example `EXEC_PRELOG_STALL (IDLE)`. The `reasonCode` itself is still `EXEC_PRELOG_STALL` for every stall kind, because clients match on it.

Fixed on `main` after `0.2.0-next.5`, with offline tests and CI. macOS was retested live on `main` `b0bc49d` (before #27, #28, #22, #30 and #31), PR #30 on its final head `8739778`, and PR #31 on heads before its last review rework. On 11-06 macOS was retested on `d5b03df` (the merged bundle) and Windows on `main` `d020b036`; results are noted per item:

- **Windows: the first Terminal command after Stata loads stalled now and then (W-P1).** Per-step timing (PR #21) located the stall. In the one stalled run out of 33, Stata's own start-up inside the worker took 76.6 s between its pre-flight check and the end of `stata_setup.config` (3.4–8.6 s in the other 32 runs). The command was queued, not lost: the old build counted this wait against the command's 120 s first-log budget and cancelled it 1.7 s before Stata was ready. Since PR #18 a command first waits for Stata to load (up to 300 s by default) outside that budget. Builds with that wait had 0 stalls in 24 runs, 10 of them on fresh profiles. This is a statistical bound (true stall rate below about 12.5 % at 95 % confidence), not proof that the stall cannot occur. A Stata start-up longer than the limit is refused before dispatch (`PRE_RUN_BACKEND_WARMUP_TIMEOUT`) instead of locking the session.
- **Quiet long commands were cancelled after 60 s** (inherited from the stable release). The watchdog now also counts CPU time of this window's own Stata worker as progress (PR #24, rc.7.84). See the CPU-signal limits below; on the 11-04 macOS retest under heavy load such a command was still cancelled, after failed CPU samples; PR #31 changed that (below).
- **Stop before the backend finished connecting locked the session.** It now refuses the command without locking (PR #25, rc.7.83).
- **Concurrent `open` calls timed out after 10 s.** They now reserve inside a short lock and launch outside it (PR #23).
- **An agent submission right after a window opened was refused** (`BLOCKED_NO_DISPATCH`) while a Terminal command would have waited. It now waits for the same warm-up; refusals carry `retryable` and `retryAfterMs` (PR #26, rc.7.86).
- **The warm-up cache could trust a replaced worker.** It now records the worker's pid, start time and transport, checks them again before use, and treats a failed or timed-out check as not ready. A Terminal command whose worker died while starting restarts it once (PR #20, rc.7.81).
- **Stata errors were reported as an unknown outcome.** A confirmed error now returns `STATA_ERROR_CONFIRMED` with Stata's return code (`stataRc`) to an agent, and that return code instead of -1 on the Terminal path (PR #27, rc.7.85; PR #28 makes mcp-stata send the return code). Checked live on macOS on `b82203d` and `d5b03df`, and on Windows on `d020b036` (agent path); see the limits below.
- **Stata: KILL on Windows ended every Stata GUI process and every mcp-stata backend on the machine**, not only this session's; a busy force reset did the same. It now ends only this window's confirmed backend tree (PR #22, rc.7.82). One live run on `d020b036` with two sessions confirmed the scope: only the killed window's tree ended, and the other window kept its pids and ran its next command. Recovery after that KILL fails on Windows; see the note at the top of [Platform test results](#platform-test-results) and the limits below.
- **A person's Run File could not be stopped.** Its progress notification "Running <file> [Cancel]" covered the Terminal Stop button (macOS retest of `b0bc49d`), and the notification's **Cancel** was not connected, so the run went on until the watchdog cancelled it at 375 s and the session locked. The notification's **Cancel** on a Run File or Run Selection now calls the same Stop as the Terminal button, only while the run that opened the notification is still active (the same execution lifecycle and request id) (PR #30, rc.7.87). Checked live on macOS on `8739778` for Run File; Run Selection has unit tests only. That an old notification's Cancel does not stop a newer run, or an agent run that took over, has offline tests only; on 11-06 the live check could not set up that state (the old notification closed before the newer run's appeared).
- **A person's Stop on an agent's run reached the agent as `EXECUTION_UNCONFIRMED_NO_RETRY`.** The agent now gets `STOPPED_NO_RETRY` (exit 2, nothing retried) when a person stops its run in VS Code with the Terminal Stop button or **Stata: Cancel Current Request**. The Run File and Run Selection notifications belong to a person's own run and cannot stop an agent run. The client gives it only when the Stop belongs to this request and run, came after this submission, restored this run's pre-run checkpoint in the same Stop (same run id, `restored` true, same reset generation), and the session is ready again (PR #30). Checked live on macOS on `8739778` with the Terminal Stop button; **Stata: Cancel Current Request** was not tried live on an agent run. The HTTP 423 `checkpoint restore in progress` seen about 2 s after a Stop in the `b0bc49d` retest came from commands sent through the test endpoint `/debug-terminal-input`; the agent client waits for the session to be ready before it sends.
- **A person's failing command had the plain card title "Stata Output".** It is now "Stata Output (failed)", as for an agent (PR #30).
- **A quiet long command could be cancelled after one failed CPU sample under heavy load.** A failed, late or timed-out sample of the worker's CPU time reset the watchdog's CPU baseline, so two failed samples about 12 s apart could leave more than 60 s without credit while the worker was still computing. On the 11-04 macOS retest (load average about 200) `bootstrap _b, reps(400) nodots` was cancelled after 99 s. Such a sample now gives no credit but keeps the baseline and is counted by kind (`cpuErrorKinds`). Credit still needs two verified samples of the same process tree, and a changed tree or new log output still resets the baseline (PR #31, rc.7.88). `/status.watchdogCpu` shows these counters for the running guard and the last agent and Terminal guards. On the PR head `db105f28`, three quiet `bootstrap` runs at load average 61–76 finished with rc 0 and no sample errors. The heavy load that triggered the cancel was not reproduced, so the fix under that load rests on unit tests. On 11-06 a `bootstrap` silent for 105 s finished with CPU credit and no sample errors on macOS (`d5b03df`), as did a 192.8 s run without log output on Windows (`d020b036`).
- **macOS: a KILL or force reset during a running command could leave the old Stata worker running** with parent pid 1, while `/status` and `close` reported the session clean (`b82203d`, 11-05). KILL and force reset ended only the `mcp-stata` server, and its worker exits only when the server exits normally. A force reset now first takes one `ps` snapshot of the backend's tree. The root must be the registered pid, a direct child of this extension host, started no later than 5 s after it was registered. After the server is ended, it sends SIGTERM and then SIGKILL only to a recorded descendant that still has the same start time, a working directory inside this session's workspace or `mcp-temp`, and parent pid 1 or its recorded parent. Anything it cannot read or confirm, such as an unreadable registration, a presence check that fails, a second live backend or no live backend, is listed as unresolved in `/status.orphanWorkers`. It is not signalled and not reported as clean (PR #31, rc.7.89). `close` only reports and signals nothing beyond the VS Code window. Its result has `leftoverProcesses`, `orphanWorkers` and `orphanCleanup` (`mode: "report-only"`, `signalled: []`, `clean`, `unresolved`, `holders`). A process read that fails, times out, prints to stderr or returns partial output counts as unknown, not empty. `clean` is true only when nothing is unresolved and the final scan of the session's files read successfully and found no holder. Live on the PR head `4a1ac2e` (macOS, 11-05), before the last review rework: a KILL 20 s into a quiet command ended the old worker and its resource tracker. A test process in the same working directory with a `spawn_main` command line was not signalled, and a `close` listed it as unresolved. The review rework after that, closing the cases that could read as clean, has offline tests and mutants. The merged code was retested on `d5b03df` (11-06): a KILL during a quiet command again ended the old worker and its resource tracker and left the test process alone. That retest found the defects in the next two items.
- **macOS: `close` could not list a live worker or holder on a real workspace** (11-06 retest). `lsof +d <workspace>` exits 1 whenever the folder contains a file that no process has open, and it still prints the processes it found. #31 counted that as unknown, so `close` reported `identity-unreadable` and `holders: unknown` on any real workspace. Directory discovery now reads the rows when the exit status is 0 or 1 and stderr is empty; any other status, any stderr output (for example a folder that cannot be opened) or a timeout still counts as unknown (PR #32). Checked live with macOS lsof 4.91 only: a test process holding the workspace was listed as unresolved (`holders: present:1`, `clean: false`, nothing signalled). `close` stays report-only and best effort; see the limits below.
- **macOS: a force reset with a stopped backend process ended VS Code's extension host** (11-06 retest, 4 of 4 runs). With this window's Stata worker stopped by SIGSTOP, a watchdog cancel escalated to a force reset; about a second after the server ended, the extension host exited (code 0) and only VS Code's main process was left. The cause is strongly supported by the live runs but was not directly observed (no SIGHUP was captured). In the tested launch mode (macOS, a window started by `tools/stata_session.py` with an isolated profile), every process of the window, including the mcp-stata server, its resource tracker and its worker, is in VS Code main's process group. After the server exits, the tracker and worker are re-parented to launchd and stay in that group. When such a member exits while another member is stopped, the kernel treats the group as orphaned and sends SIGHUP and SIGCONT to all of it: the extension host and helpers end, VS Code main survives. The rc.7.89 cleanup triggered this by ending the re-parented tracker while the worker was stopped. Before each SIGTERM or SIGKILL the cleanup now reads the host's process group. Stopped members that match a recorded identity (pid and start time) get SIGCONT and the group is read again. A stopped member that is not ours (`host-group-stopped`) or a group that cannot be read (`host-group-unknown`) means no signal, and the row stays unresolved. The deadline, a cancel and a newer reset are checked after each group read and right before each SIGCONT (PR #33, rc.7.89-v4). Live on PR #33's first head `3c8e4f3`, 2 of 2: the host survived, **Stata: KILL** unlocked the session, the next command returned rc 0 and `close` returned `CLOSED`; one run had one `host-group-unknown` row whose cause was not found. The added stop checks have offline tests and mutants only.
- **Windows: after a successful KILL the window kept refusing runs** (11-06 retest). The command ran its recovery smoke on the connection to the backend it had just ended, so the smoke failed with `transport-failed` and the next command got HTTP 423 `panic-kill-command-needs-smoke`; the test then closed the window (a second KILL or `POST /recovery-smoke` was not tried). A successful scoped kill now runs a force reset that reuses the kill's recorded result, opens a new connection and leaves the session needing a smoke; the smoke then runs on the new connection (PR #34, rc.7.90). The fail-closed path and a partial kill are unchanged. Live on `main` `80e01c8` (11-07), one run with two sessions: the killed window recovered by itself and ran its next command with rc 0; the other window was not affected.

Open problems on the current `main`:

- **A command sent while Stata is still loading.** `trueReady` does not wait for the background load. A Terminal command or an agent submission waits until the Stata worker is running. After 2 s the Terminal shows "Waiting for Stata to finish loading…"; the Terminal Stop button or `POST /soft-stop` cancels the wait. After 300 s, or if the warm-up fails, the command is refused before it is sent (`PRE_RUN_BACKEND_WARMUP_TIMEOUT` or `PRE_RUN_BACKEND_WARMUP_FAILED`, `payloadDispatched=false`). Only an older mcp-stata that does not provide `list_sessions` is let through without this check (a compatibility fallback, not proof that Stata is ready). When `list_sessions` exists but keeps failing or timing out, the warm-up ends as `FAILED` and the command is refused; when the worker changes or cannot be confirmed right after the warm-up, the command waits once more and is then refused. On 11-04 the wait message, Stop during the wait (through `/soft-stop`), the timeout and the failure refusal were confirmed live on macOS; on Windows all of them except the failure refusal, and the wait message only in the Output log; on 11-06 Windows (`d020b036`) also showed the failure refusal and the wait message in the real Terminal panel. On 11-05 a command typed into the Terminal panel on macOS (`b0bc49d`) showed Stop enabled during the wait; a click on it refused the command with `PRE_RUN_BACKEND_WARMUP_CANCELLED`, nothing was sent, and the next command returned rc 0. An earlier report that the button is disabled during the wait came from a test endpoint (`/debug-terminal-input`) that sends the command without going through the panel's Run handler, so the panel never showed the command as running; it was not a product defect.
- **Windows KILL scope rests on two live runs.** On `d020b036` and on `80e01c8`, with two sessions each, KILL on window A ended only A's backend tree, and window B kept its pids and ran its next command with rc 0. Two runs are not a statistical bound. The root is matched to its registration time within 1 s, not by a recorded creation time; identities are compared to the millisecond; the process listing is not atomic; and only direct children are rescanned after the kill. When cleanup fails or a process identity cannot be read, the session stays not ready and `/recovery-smoke` returns HTTP 423 `unresolved-cleanup`.
- **Windows: Stop on a fully frozen backend locks the session.** With every backend process of a session suspended, `/soft-stop` took 58 s and returned 500 (`RECOVERY_FAILED`: the quiescence probe timed out after 5 s) and force-reset the session's own tree. The session then refused commands with HTTP 423 (`soft-stop-needs-smoke`) until the window was closed. The log names **Stata: KILL** or `POST /force-reset`; neither was tried on a frozen session. Since PR #34 a successful KILL resets the connection before its smoke, but KILL after this Stop has not been tried live. A slow but alive backend was not tested.
- **Windows: a command typed into the panel and refused during the warm-up leaves `/status.lastTerminalGuardFailure` empty.** The refusal shows in the panel and the log only.
- **macOS KILL and force reset identify the backend by pid only** (PR #22 changed Windows only). The cleanup ends the registered pid when its command line contains `mcp-stata`; it does not check the process start time or parent. A pid reused by another session's `mcp-stata` within that window could be ended.
- **Limits of the macOS orphaned-worker cleanup.** Signals go to a bare pid: a process that exits after the last check and whose pid is reused before the signal is not ruled out, and start times have 1 s resolution. The root rule is one-sided: another child of this extension host that got the registered pid within 5 s of registration is not ruled out. `close`'s capture and report phases each have their own 8 s limit. These bound the cleanup's process reads, not the whole call: under heavy load `close` can still raise a `ps` timeout from its instance listing instead of returning a verdict. Rows that ran out of capture time stay unresolved even when the process later exited normally. `close` has been shown live listing a test process that held the workspace (11-06), not a real Stata worker that outlived its window: in the 11-05 tests the worker always ended with the VS Code quit, and on 11-06 a worker held with SIGSTOP outlived its window once, on a build whose `close` could not list it (fixed by PR #32), and ended during the quit in the other runs. `close` is report-only and best effort: its scan looks at the workspace folder and the files directly in it (`lsof +d` is not recursive), process reads are not atomic, and it was checked with macOS lsof 4.91 only, so `holders: none` and `clean: true` mean nothing was seen in that scope. Check an unresolved row with `ps -o pid,ppid,lstart,command -p <pid>` before you end anything yourself. Windows is unchanged (PR #22 ends this window's whole backend tree there), and this case was not tested on Windows.
- **macOS: KILL or cleanup while another process of the window is stopped is not supported.** PR #33 only makes sure the force reset does not end a member while one of our recorded processes is stopped. If a process of the window was stopped from outside (SIGSTOP, a debugger), a later **Stata: KILL** or cleanup can still end the extension host the same way (seen live). A stopped process of the window that is not a recorded identity blocks the cleanup (rows unresolved) and is not resumed. A pid reused, or a process stopped again, between the last group read and the signal is not ruled out.
- **The worker CPU signal is a heuristic.** CPU activity is not proof of useful work: a run that loops without output keeps the session until its log has been silent for 30 min. When the process tree cannot be verified (a pid exited during the sample, more than 4 levels or 16 processes, a parent mismatch), the sample gives no credit and the 60 s log rule applies. Same-second pid reuse is below the precision of the start time it checks. On the 11-04 macOS retest of `main` (`b0bc49d`), a run quiet for 57 s finished with rc 0 and a frozen worker was still cancelled; a longer quiet run under heavy load was cancelled (next item).
- **A quiet long command under the heaviest load has not been retested live since PR #31.** The 11-04 cancel (load average about 200, 99 s, `cpuErrors=2`) came from failed CPU samples resetting the baseline, which PR #31 changed (see the fixed list above). On 11-06 quiet runs finished with CPU credit on macOS (silent 105 s) and Windows (192.8 s), but that load and those sample failures were not reproduced, so the fix for them rests on unit tests. A watchdog cancel still locks the session (HTTP 423 `guard-cancel-needs-smoke`) until **Stata: KILL**; the lock is deliberate, because after a cancel the state inside Stata is unknown.
- **The progress notification of a person's Run File or Run Selection covers the Terminal Stop button.** Its **Cancel** now stops the run (see the fixed list above). Clicking the notification body does nothing; Cancel on Run Selection has unit tests only; and neither was checked on Windows. That an old notification's Cancel cannot stop a newer run has offline tests only: in three live attempts on 11-06 the old notification always closed 4.7–10 s before the new run's notification appeared.
- **A Stop through `POST /soft-stop` or by the watchdog reaches the agent as `EXECUTION_UNCONFIRMED_NO_RETRY`**, not as `STOPPED_NO_RETRY`; the receipt names the source in `stopReportedBy`. Check `resetGeneration` in `/status` and the receipt before submitting again. `STOPPED_NO_RETRY` was checked on Windows on `d020b036` (11-06) with the Terminal Stop button.
- **Stata error return codes are confirmed conservatively; on Windows only the agent path was tested live.** An error counts as confirmed only if the run was not cancelled (Stop, watchdog, Break, rc 1), the log is this run's own, the last `r(n)` line is followed only by echoed commands, the completion marker was not printed, and the code is a positive integer equal to mcp-stata's rc. mcp-stata sends that rc with `task_done` only through the runtime patch (PR #28), taken from the response this run already received; a runtime without the patch sends none, and every error stays unconfirmed. Anything else stays rc -1 on the Terminal path and `EXECUTION_UNCONFIRMED_NO_RETRY` to an agent; an error whose text mentions cancel, timeout or stall also stays unconfirmed. On macOS, build `b82203d` (11-05): an agent's `display nosuchvar` returned `STATA_ERROR_CONFIRMED` with `stataRc` 111 and the next command rc 0; the same error typed by a person finished with rc 111 and the next command rc 0; the session stayed usable. That build is not the current `main`; the same checks passed on `d5b03df` (11-06). On Windows (`d020b036`, 11-06) an agent's `display nosuchvar` returned `STATA_ERROR_CONFIRMED` with `stataRc` 111 and the next command rc 0; the Stata log shows `r(111);` and the extension log has no error text. A person's error on Windows was not tested. The offline cross-module test builds the `task_done` result by hand and stubs the UI, so it is not an MCP transport or end-to-end test.
- **The general log parser reads only the plain `r(n);` form**, not the SMCL form `{search r(111), local:r(111);}` that mcp-stata 1.26.1 writes. Only the new error check reads both. The rc inferred at release, the Run File finalizer and the watchdog's error check still see no rc in such logs when the error is not confirmed.
- **Wrapper lines are visible in the Terminal.** The RESULT tab shows lines added around each command, for example `display as text "___CODEX_RUN_DONE_…___"`, a second `r(111);` and `scalar _wb_rc_… = _rc`; an agent card's command line also shows the client's verification marker. They come from the command wrapping in the extension and the mcp-stata runtime. The completion check and the log evidence of a run depend on that wrapping, so the lines are not hidden yet.
- **A reopened session can get a new port.** Right after `close`, the old port can still be in TIME_WAIT; the launcher then picks the next free one. Tools look sessions up by name.
- **Windows dispatch overhead.** Each agent submission on Windows took about 15 s longer than the Stata work itself (pre-dispatch checks and receipt verification); a short command took 17.4 s end to end. In 20 rounds of an 8 s command the fixed cost was 12–18 s per submission.
- **Service start can wait for PyPI.** Before starting the Stata service, the extension checks PyPI for the `mcp-stata` version. On a machine where that request times out, the timeout adds to the first start.
- **Memory.** Each session is a full VS Code plus Stata. On macOS five sessions used 3852–4000 MB RSS in total (718–850 MB each). On a 16.8 GB Windows machine, two idle sessions had working sets of 1.93 and 2.16 GB, and 2.00–2.39 GB each under load. Check free memory before opening a third session on a machine of that size.
- **Workspace Trust.** A new workspace needs one **Trust** click before the extension starts.
- **Agent hosts.** Codex has no per-file deny rule for `.do` files; see [Reviewed agent edits](#reviewed-agent-edits-to-stata-files).
- **Inherited from the stable release:** a top-level `exit` inside a multi-line selection ends the whole selection and is reported as a failure; the Data Browser frame name updates only when the browser opens; `graph use` alone does not create a Terminal graph card; equality of the displayed source and the executed bytes is not certified.
- `dist/extension.js` is the maintained bundle. A reference source build exists, but feature parity with the bundle is not established.

</details>

## Platform test results

**Historical evidence only.** These are the original Next results, not passes
for the 0.2.0 candidate, ordinary windows or actual human/agent-host acceptance.
Their build hashes and limitations are retained without relabeling.

<details>
<summary>Original Next platform records</summary>

All live tests used isolated Next profiles, synthetic `.do` files and ports
`17601`–`17620`; no research data was involved. Interface actions (Stop, Trust,
KILL) were driven through the VS Code DevTools protocol, not by a person at the
keyboard. Dates are 2026, Taipei time. Builds are `main` commits; `e7e54848`,
`579b0fe9` and `171138b6` are all version `0.2.0-next.5`, `8d63cb45` is
`0.2.0-next.4`.

Rows dated 11-04 come from two kinds of build. `aba81779` is the
`v0.2.0-next.5` release. `a1a2832b` (PR #21), `40abcbea` (PR #20) and
`2ec968a` (PR #24) are pull-request heads tested before their review rework
and before merging. macOS was later retested live on `main` `b0bc49d` and, for
Stata error return codes and the orphaned worker after KILL only, on `b82203d`.
PR #30 was checked live on its final head `8739778`, which has the same tree as
its merge `e0b4e11`. PR #31 was checked live on macOS on its heads `db105f28`
and `4a1ac2e`, before its last review rework; see
[Known limitations](#known-limitations).

<!-- FMAC-RESULT -->
On 11-06 the merged runtime was retested live: macOS on `d5b03df` (PR #31's merge candidate; the same extension bundle and cleanup core as `main` `d020b036`, only the Python `close` tool differs) and Windows on `main` `d020b036` (15 of 16 checks passed). These runs found the two macOS defects fixed by PR #32 and PR #33 and the Windows KILL recovery defect below. PR #33's last commit `32ff282` (the stop checks around its resume step) has offline tests only. The checks run on the release commit itself are listed in its GitHub release notes.
<!-- /FMAC-RESULT -->

<!-- KW-RESULT -->
The Windows KILL recovery defect they found is fixed by PR #34 (rc.7.90). On 11-07 Windows was retested live on `main` `80e01c8` (the merge of #34): with two live sessions, a real **Stata: KILL** on one ended only that window's backend tree, the window recovered by itself (recovery smoke passed, next command rc 0) and the other window kept its processes and ran its next command with rc 0.
<!-- /KW-RESULT -->

### macOS (Apple Silicon, macOS 26.5, StataNow, VS Code 1.139.1)

| Check | Build, date | Result |
| --- | --- | --- |
| Person and agent share one session (globals, variables, estimates, graphs; Terminal card shows the agent name and receipt runId) | `8d63cb45`, 11-01 | Pass |
| Two, three and five sessions running at the same time | `8d63cb45`, 11-01 | Pass. Five sessions overlapped 28.57 s and each read back its own owner, N and coefficient; a sixth `open` returned `SESSION_LIMIT` |
| Registry and identity refusals (stale record, reused PID, wrong token, wrong generation, several live sessions without `--session`) | `8d63cb45`, 11-01 | Pass, 7/7 refused with nothing executed |
| Two agents submit to two sessions at the same moment (30 s commands, started 0.008 s apart) | `579b0fe9`, 11-02 | Pass. Both returned HTTP 200 in 34.41 s and 34.26 s |
| One session busy for 60 s while the other takes a short command | `579b0fe9`, 11-02 | Pass. The short command returned in 4.50 s while the long one was still running |
| Stop one of two busy sessions | `579b0fe9`, 11-02 | Pass. The stopped session returned to ready; the other finished normally with its reset generation unchanged |
| No `--session` with two live sessions | `579b0fe9`, 11-02 | Pass. `MULTIPLE_SESSIONS`, nothing executed |
| Close one of two sessions | `579b0fe9`, 11-02 | Pass. Its registry record was gone; the other session still ran code |
| Terminal Stop on the person's long command, twice | `579b0fe9`, 11-02 | Pass. Stopped on the first click each time, same Stata process, data kept |
| Stop on an agent run | `579b0fe9`, 11-02 | Pass. No force reset, pre-run state recovered (`RECOVERED_FULL`) |
| Stop after the pre-run checkpoint was removed | `579b0fe9`, 11-02 | Pass. Session locked (`trueReady: false`, next run 423, status bar STALE) |
| **Stata: KILL** unlock | `579b0fe9`, 11-02 | Pass. One confirmation, recovery smoke rc 0, next run succeeded |
| First command after opening, `loadStataOnStartup` `false` (5) and `true` (2) | `aba81779`, 11-04 | Pass, 7/7 HTTP 200 and rc 0, no stall before the first log line. The command waited for Stata to load (11–14 s with `false`, about 7 s with `true`, 61 s on the first cold start), and the Output log showed "Waiting for Stata to finish loading…" then "finished loading after N s" |
| Command sent while Stata is still loading: Stop, timeout, failed worker | `aba81779`, 11-04 | Pass. Stop during the wait: HTTP 409 `PRE_RUN_BACKEND_WARMUP_CANCELLED`, nothing sent, next command rc 0. Worker frozen: HTTP 504 `PRE_RUN_BACKEND_WARMUP_TIMEOUT` after 336.5 s, session not locked. Worker then killed: HTTP 500 `PRE_RUN_BACKEND_WARMUP_FAILED`; the next command waited 37 s for a new load and returned rc 0 |
| Stop pressed before the backend finished connecting | `aba81779`, 11-04 | Fail. Nothing had been sent, but soft Stop returned 500 after 35.6 s and the session locked (`soft-stop-did-not-restore-checkpoint`). Failed on this build. Fixed in rc.7.83 (PR #25); passed live on `main` `b0bc49d` (Stop before connect refused the command without locking, next command rc 0) |
| Terminal Stop button on a running command | `aba81779`, 11-04 | First run 0/2: the test driver clicked a point covered by the Welcome page's transparent overlay, so the click never reached the Terminal. With Welcome closed, the mouse click, a click inside the Terminal view and **Stata: Cancel Current Request** each stopped the run, without locking |
| Person and agent take turns; person submits during an agent run | `aba81779`, 11-04 | Pass. The person's submission got HTTP 409 `bridge busy` naming the agent; both read the same owner, N and coefficient afterwards |
| **Stata: KILL** with two live sessions | `aba81779`, 11-04 | Pass. Only the locked session's three processes were replaced; the other session's 40 s command finished with rc 0 |
| Five live sessions, three simultaneous submissions | `aba81779`, 11-04 | Partial. A sixth `open` got `SESSION_LIMIT`. Of three simultaneous submissions two passed; an agent submission sent about 20 s after its window reported ready was refused before dispatch (`BLOCKED_NO_DISPATCH`) because its backend had not started. Failed on this build. Fixed in rc.7.86 (PR #26); passed live on `main` `b0bc49d` (agent submission right after opening ran with rc 0 and matched `lastCold.runId`) |
| Quiet long command under heavy load (load average 120–140) | `aba81779`, 11-04 | Fail. A `bootstrap … dots(50)` run wrote no new log for 60 s, was cancelled at 63 s as `EXEC_PRELOG_STALL (IDLE)` and the session locked. rc.7.84 (PR #24) adds the worker CPU signal |
| Worker CPU signal: idle noise and a real hang | `2ec968a`, 11-04 | Pass. An idle worker's CPU time grew 10 ms per 12 s (threshold 200 ms). A worker frozen with SIGSTOP was still cancelled, 69.7 s after it froze; after KILL the next command returned rc 0. The quiet-command check finished inside its first-log budget, so the 60 s idle path with CPU credit was not exercised live |
| Stata error from an agent (`display nosuchvar`) | `b82203d`, 11-05 | Pass. `STATA_ERROR_CONFIRMED`, `stataRc` 111, all error checks true; the Terminal card showed RC 111. The next agent command returned rc 0 and the session stayed ready |
| Stata error typed by a person in the Terminal | `b82203d`, 11-05 | Pass. The run finished as failed with rc 111 and the panel showed `RC 111` and `r(111);`. The next typed command returned rc 0, then an agent command rc 0 |
| **Cancel** in a person's Run File notification ("Running long_dots.do [Cancel]") | `8739778` (PR #30), 11-05 | Pass. The click stopped the run through the same Stop as the Terminal button; the session was idle 5 s later with the pre-run state restored, and the next command typed into the panel returned rc 0 |
| A person's Terminal Stop on an agent run | `8739778` (PR #30), 11-05 | Pass. The agent got `STOPPED_NO_RETRY` with `stoppedBy` person and all stop checks true; one request sent, none retried. The next agent command passed |
| Package, `verify_release` and installed bundle | `d5b03df`, 11-06 | Pass. The VSIX bundle and the installed bundle equal the pinned SHA-256; `verify_release --vsix` 116/116; the 115 files of the runtime manifest match the installed copy |
| First command after opening, `true` and `false`, twice each; Stop while waiting | `d5b03df`, 11-06 | Pass, 4/4 with the wait message in the panel and the log. Stop while waiting (through `/soft-stop`) refused with `PRE_RUN_BACKEND_WARMUP_CANCELLED`, nothing sent, next command rc 0 |
| Run File notification **Cancel**; a person's Terminal Stop on an agent run | `d5b03df`, 11-06 | Pass. Cancel stopped the run with its pre-run state restored and the next typed command returned rc 0. The agent got `STOPPED_NO_RETRY` (one request, no retry, all 8 stop checks true) |
| An old notification's **Cancel** while a newer run is going | `d5b03df`, 11-06 | Not reached. In 3 attempts the old notification closed 4.7–10 s before the newer run's notification appeared; the newer run returned rc 0 each time. Offline tests only |
| Stata error from an agent and from a person | `d5b03df`, 11-06 | Pass. Agent: `STATA_ERROR_CONFIRMED`, `stataRc` 111, next agent command rc 0. Person: rc 111, next typed command rc 0 |
| Four live sessions: turns, a failing command, Stop, KILL on one | `d5b03df`, 11-06 | Pass. KILL on one session replaced only its own three processes; another session's 40 s loop finished with rc 0. A mouse click on the panel Stop during a person's Run File still lands on the notification; the notification's Cancel stops the run |
| KILL during a quiet command (orphaned worker) | `d5b03df`, 11-06 | Pass. The old worker and its resource tracker were ended; a test process in the same folder with a worker-like command line kept its pid and start time |
| Quiet `bootstrap … reps(400) nodots`; `/status.watchdogCpu` | `d5b03df`, 11-06 | Pass. Silent for 105 s, finished rc 0 in 108 s with CPU credit (7 of 8 samples, 0 errors); `watchdogCpu` present in all 22 polls |
| Force reset with this window's worker stopped (SIGSTOP) | `d5b03df`, `d020b036`, 11-06 | Fail, 4 of 4. About a second after the force reset ended the server, the extension host exited (code 0); only VS Code main was left and `close` returned `CLOSE_PENDING`. Not seen on `e0b4e11` (before #31). Fixed by PR #33 |
| The same control on PR #33's first head | `3c8e4f3`, 11-06 | Pass, 2/2. The worker was resumed before any terminating signal and the extension host survived; **Stata: KILL** unlocked the session, the next command returned rc 0 and `close` returned `CLOSED`. One run had one `host-group-unknown` row (nothing sent; cause not found) |
| `close` with a process still holding the workspace | `d5b03df`, `d020b036`, 11-06 | Fail on `d5b03df`: every `lsof +d` exited 1 with rows, and `close` reported `identity-unreadable` and `holders: unknown`. Pass with #32's `close` tool (`main` `d020b036`): a live test process holding the workspace was listed as unresolved (`holders: present:1`, `clean: false`, nothing signalled). A real Stata worker that outlives its window was not produced |

### Windows (Windows 11 x64, Stata 18 MP, VS Code 1.144.0)

| Check | Build, date | Result |
| --- | --- | --- |
| New profiles turn off VS Code and extension auto-update | `171138b6`, 11-02 | Pass |
| Reviewed agent edits: accept, reject, change during review | `171138b6`, 11-02 | Pass |
| Refusals: reused PID, wrong token, port in use, stale record | `171138b6`, 11-02 | Pass, nothing sent |
| Two sessions: simultaneous agent submissions, one busy while the other submits, Stop one, no cross-talk, `MULTIPLE_SESSIONS` | `579b0fe9`, 11-02 | Pass. The two runs overlapped 40.5 s; read-backs `owner=w3a N=111` and `owner=w3b N=222` |
| Terminal Stop on the person's long command, twice | `579b0fe9`, 11-02 | Pass, 2/2: first click stopped it, same Stata process, data kept |
| Agent run stopped from the Terminal | `579b0fe9`, 11-02 | Pass. Pre-run checkpoint restored (`restored=true`); read-back N=77 |
| Stop after the pre-run checkpoint was moved away | `579b0fe9`, 11-02 | Pass. Session locked (`snapshot-expected-not-restored`) |
| Two sessions, 20 rounds of simultaneous agent submissions (40 runs, a Stop in 5 of them) | `e7e54848`, 11-03 | Pass, 20/20. The 35 runs that were not stopped all passed and no log line crossed sessions; the 5 stopped runs were restored without a force reset, and the other session's reset generation stayed unchanged (5/5). Stata PIDs unchanged for all 20 rounds |
| Terminal Stop on the person's long command, five times | `e7e54848`, 11-03 | Pass, 5/5. First click stopped it, same Stata process, data before Stop kept |
| Stop after the pre-run checkpoint was renamed | `e7e54848`, 11-03 | Pass. The notice says the session did not restore the pre-run state, is locked, and needs **Stata: KILL**; status fenced, next run 423. On `579b0fe9` the notice wrongly said the checkpoint was restored |
| Watchdog cancel of a silent agent command | `579b0fe9`, 11-02 | Partial. Pre-run checkpoint restored, but the cancel escalated to a force reset and the status reported the reason of an earlier failure |
| Watchdog cancel of a silent Terminal command | `e7e54848`, 11-03 | Pass. Quiescence probe saw its marker, no force reset; the lock reason was this cancel's own (`elapsedMs 63187`, `stallReason IDLE`) |
| First command after opening, `loadStataOnStartup=false` | `579b0fe9`, 11-02; `e7e54848`, 11-03 | Fails intermittently: stalled in 2 of 3 attempts (HTTP 504 after about 120 s, session locked); the third returned rc 0 in 42.2 s. On `e7e54848` the 504 reports `EXEC_OUTCOME_UNKNOWN` with `payloadMayHaveRun: true` |
| First command after opening, `loadStataOnStartup=true` | `579b0fe9`, 11-02 | Pass. Stata loaded in the background in 57.7 s while the window opened; the first command then took 6.1 s, rc 0 |
| Default `loadStataOnStartup` (key absent), first agent command after opening | `3765d82a`, 11-03 | Pass, 3/3. The launcher wrote `true`; Stata was up 106.6–107.7 s after `open`; the first agent command returned rc 0 in 23.1–25.2 s. A `false` set before `open` was kept |
| Watchdog cancel on the agent path and on the Terminal path | `3765d82a`, 11-03 | Pass. Each cancel recorded its own `runId` and `elapsedMs` (63 615 and 63 159 ms) in `/status.lastGuardFailure`; lock reason `EXEC_PRELOG_STALL (IDLE)`. Only the `IDLE` stall kind occurred |
| Late events of a cancelled cold-start command (`loadStataOnStartup=false`) | `3765d82a`, 11-03 | Pass. The command returned HTTP 504 after 167.1 s; its late `log_path` events were dropped as `not this client's run` instead of being given to the next run |
| Normal commands after such a cancel; first Terminal command after reopening | `3765d82a`, 11-03 | Partial. Same backend after unlock: 5/5 rc 0, about 3.1 s each, no foreign log lines. Reopened window with the default `true`: 0/2. The first Terminal command, sent right after `connect` completed (54.2 s), stalled before any log output and returned HTTP 504 after 163.9 s; the session locked and the second command got 423 |
| Two sessions, 8 rounds of simultaneous agent submissions with a Stop in 2; Terminal Stop 3 times | `3765d82a`, 11-03 | Pass. 14/14 runs that were not stopped passed; both stopped runs were restored without a force reset; no log line crossed sessions; 21.4–24.8 s per round. Terminal Stop 3/3 on the first click |
| `close` removes leftover temporary registry files | `171138b6`, 11-02; `e7e54848`, 11-03 | Partial on `171138b6` (one file left behind). Pass on `e7e54848`: a file whose writer had exited was removed and the registry was empty. The case of an exited process reporting error 5 did not occur (all three reported 87), so that branch has unit tests only |
| KILL notice when the recovery smoke is skipped; probe reading its own log after a late event | `e7e54848`, 11-03 | Partial. The first branch cannot be reached on Windows (KILL always runs the smoke there); the late-event shape did not reproduce in two lazy-load attempts. Both have unit tests only |
| First Terminal command right after `connect` completed, fresh window | `e5d2cda7`, 11-04 | Pass, 3/3. HTTP 200, rc 0 in 3.05–3.12 s; the second command also passed. Before dispatch the extension checked the worker state (`list_sessions` 4–6 ms; the worker was already running, so the wait message did not appear). The same check on `3765d82a` also passed 2/2, so this retest does not show that the earlier stall is gone |
| First agent command after opening; 4 agent runs with a soft Stop in the last; Terminal Stop | `e5d2cda7`, 11-04 | Pass. First agent command rc 0 in 11.5 s. Runs 1–3 passed in 14.4–15.7 s; the stopped run was restored (`restored=true`, no force reset) and the data from before the Stop was kept. Terminal Stop stopped the run on the first click, same Stata process |
| First Terminal command after opening, with per-step timing (`loadStataOnStartup` `true` and `false`, new and reused profiles) | `a1a2832b`, 11-04 | Pass, 24/24 HTTP 200 and rc 0, including 10 runs on fresh profiles. Each first command waited 16–60 s for Stata to load, then the run, its log path and the first output followed within 0.6 s. The older build `3765d82a` with the same timing lines stalled once in 17 runs (HTTP 504 after about 120 s); see [Known limitations](#known-limitations) |
| Four 8 s commands with a soft Stop in the second; one Stop from the Terminal button | `a1a2832b`, 11-04 | Pass. Stop returned in 1.65 s with the checkpoint restored and no force reset; the other three rounds each logged their start and end lines; the Stata process stayed the same. The Terminal Stop stopped the run on the first click. The first Run click right after the panel took focus did nothing, as in earlier Windows tests |
| Command sent while Stata is still loading (worker suspended): Stop, timeout, restart | `40abcbea`, 11-04 | Pass. Stop during the wait: refused with `PRE_RUN_BACKEND_WARMUP_CANCELLED`, nothing in the Stata log. Timeout: HTTP 504 `PRE_RUN_BACKEND_WARMUP_TIMEOUT` after 300.1 s, nothing sent. After resuming, the next command returned rc 0 in 46.1 s; its worker had failed while starting, was restarted once and loaded in 43 s, and the command ran once. A visible `PRE_RUN_BACKEND_WARMUP_FAILED` did not occur (a wrong `stataPath` still loaded Stata). The wait message appeared in the Output log; the test input path does not draw the Terminal panel, so the panel text is unverified on Windows |
| `/panic-kill?dryRun=1` with two live sessions | `d020b036`, 11-06 | Pass, 2/2. Each window selected only its own 4-process tree; the two sets were disjoint |
| **Stata: KILL** on one of two live sessions | `d020b036`, 11-06 | Scope pass, recovery fail. Only the killed window's tree ended; the other window kept its pids and its next command returned rc 0. The killed window's recovery smoke failed (`transport-failed`) and its next command got HTTP 423 `panic-kill-command-needs-smoke`; see the note at the top of this section |
| **Stata: KILL** on one of two live sessions, after PR #34 | `80e01c8`, 11-07 | Pass. Only the killed window's tree ended ("ended 3 of 4 … already exited 1"); 77 s after the click the killed window showed "the verified recovery smoke passed; the session is READY", had a new backend (`resetGeneration` 1) and ran its next command with rc 0 without being closed. The other window kept its pids and ran its next command with rc 0 |
| Stata error, then a person's Terminal Stop, after the KILL recovery | `80e01c8`, 11-07 | Pass. On the recovered window `display nosuchvar` gave `STATA_ERROR_CONFIRMED` with `stataRc` 111 and the next command rc 0. On the other window a person's Terminal Stop on an agent run gave `STOPPED_NO_RETRY` and the next command rc 0; both windows closed with `CLOSED` |
| Stata error from an agent (`display nosuchvar`) | `d020b036`, 11-06 | Pass. `STATA_ERROR_CONFIRMED`, `stataRc` 111, all 12 error checks true, next command rc 0. The Stata log has `r(111);`; the extension log has no error text |
| Quiet long command (`bootstrap … reps(400) nodots`, no log output) | `d020b036`, 11-06 | Pass. Ran 192.8 s with rc 0 and was not cancelled; CPU credit in 14 of 15 samples, 0 errors; `/status.watchdogCpu` present |
| Command sent while the backend is frozen: failure, Stop | `d020b036`, 11-06 | Pass. Failure: after 51 s the panel showed `PRE_RUN_BACKEND_WARMUP_FAILED`, nothing sent, the next command rc 0. Stop during the identity probe: HTTP 409 `PRE_RUN_BACKEND_WARMUP_CANCELLED`, nothing sent; the `/soft-stop` call itself took 58 s and the session stayed locked (Known limitations) |
| First commands; wait message in the real Terminal panel | `d020b036`, 11-06 | Pass. Agent submissions right after opening passed with `loadStataOnStartup` `true` and `false`; the first Terminal command with `false` returned rc 0 in 73.4 s. The panel showed "Waiting for Stata to finish loading" from 4.7 s to 42.7 s, then the output |
| A person's Terminal Stop on an agent run; `close` | `d020b036`, 11-06 | Pass. `STOPPED_NO_RETRY`, `stoppedBy` person, all stop checks true, next command rc 0. Six `close` calls returned `CLOSED` |

macOS Intel and Windows Server 2022 run the offline test suite and packaging in
CI on every pull request (no licensed Stata). Windows 10, Windows on ARM and
Linux are not verified.

PR #15 (Stop/KILL messages that match the actual outcome, Windows process
liveness, quiescence-probe fixes) was retested live on Windows on `e7e54848`
(rows dated 11-03). PR #17 (`e9b22430`: Stata loads at window open, a
watchdog cancel names its own stall, late events stay with their task) was
retested live on Windows on its head `3765d82a` (same bundle as `e9b22430`;
rows marked `3765d82a`). Its three fixes held, but a Terminal command sent right
after the load stalled once. PR #18 (`1bf02d02`: Terminal commands wait for
the Stata warm-up before dispatch) was retested live on Windows on its head
`e5d2cda7` (same source tree; rows dated 11-04); see
[Known limitations](#known-limitations). macOS was retested live on the
`v0.2.0-next.5` release (`aba81779`) on 11-04, and again on `main` `b0bc49d`
(after PRs #19–#21 and #23–#26, before #27, #28 and #22) on 11-04 to 11-05; the
failures found there are listed under [Known limitations](#known-limitations).
On 11-06 macOS was retested on `d5b03df` and Windows on `main` `d020b036`
(rows dated 11-06), and on 11-07 Windows on `main` `80e01c8` after PR #34
(rows dated 11-07).

</details>

## Development

Documentation checks use `git diff --check`, local-link checks and CLI parser
checks. Runtime integration additionally requires the release checks below;
run builds only locally or in CI, never on a production/VPS server.

```sh
npm ci --ignore-scripts
npm run check -- --keep-going
python3 -B -m unittest discover -s tools -p 'test_*.py'
npm run package
python3 -B tools/verify_release.py --packaged
```

The package name is `stata-workbench-shared-session-<version>.vsix`. These are
validation commands, not a statement that this candidate passed them. The
release owner regenerates bundle identity and runtime manifests, checks the
exact VSIX, and records licensed live evidence separately. See
[CONTRIBUTING.md](CONTRIBUTING.md), [release maintenance](docs/RELEASE.md) and
[CHANGELOG.md](CHANGELOG.md). Historical Next operator documents retain their
original scope; use this README and [daily workflow](docs/agent-daily-workflow.md)
for the ordinary-window candidate.

## License

AGPL-3.0-or-later. Derived from
[tmonk/stata-workbench](https://github.com/tmonk/stata-workbench). Design
comparisons with [hanlulong/stata-mcp](https://github.com/hanlulong/stata-mcp)
are acknowledged in [NOTICE](NOTICE); they are not a claim that the runtimes are
interchangeable. See [LICENSE](LICENSE) and [SECURITY.md](SECURITY.md).

Stata, Stata licenses, credentials and data are not included. The bridge
listens on `127.0.0.1` only; it is not a remote or multi-user service.
