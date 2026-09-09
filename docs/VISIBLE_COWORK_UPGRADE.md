# Visible co-working candidate — not yet live accepted

This development branch adds `visible-cowork/1`. The installed/released legacy
runtime remains separate; **do not install this branch over an active research
session or reuse its historical FULL45 result as acceptance of this candidate**.

## What changed

- `tools/shared_stata.py --file` now freezes the saved program to a new execution
  version and requires a runtime visibility ticket. `--code` materializes an
  annotated `.do` first. `--task` drives ordered stages with explicit checkpoint
  inputs, fresh output paths and dependency gates.
- The exact execution file is in editor group 1; the actual Stata Terminal is in
  group 2. These must be simultaneously visible, with the target window focused,
  document saved, and disk/buffer hashes matching. Tab-group state is checked
  independently of a stale `activeTextEditor` reference.
- Graphs and Data Browser use a third group during a co-working task. A log tab
  cannot substitute for the live Terminal panel.
- No per-stage approval is required. `Stata: Pause Following Stages` affects the
  next stage; `Cancel Current and Pause Following Stages` also requests the
  existing product cancellation. Neither resets or kills the backend.
- After an inter-stage pause, `--task task.json --resume-from /absolute/prior-receipt-directory`
  starts a new receipt directory and reuses only the verified completed prefix.
  Source, input, output and receipt drift reject reuse. Failed or unknown stages
  cannot be retried by this option; reconcile them explicitly and version repairs.
- Tickets are one-use, bound to program bytes, dependency bytes, working directory, backend and
  prior run identity, and expire after 15 seconds. Readiness/layout preparation
  completes before the ticket clock starts. Unknown outcomes are never resent.
- A visibility interruption is retained even if the layout is subsequently
  restored; future stages pause. This is observed software visibility, not a
  claim that a person watched or understood the screen.
- Program execution, visibility, replayability and task completion are separate
  receipt fields. Legacy `PASS_VISIBLE_SHARED_RUN` is transport-only evidence.
- Raw readable failure logs are retained. Legacy nested HTTP failure JSON is
  decoded without destroying the raw response. `Stata error r(N)` requires
  actual request/run/phase/backend and raw-log binding; a string alone cannot
  turn an unknown transport result into a confirmed program error.
- Screen lock is reported as `SCREEN_LOCKED` with an unknown window count,
  separately from denied Automation permission or a missing Stata backend.
  A locked screen never triggers automatic restart, unlock or hidden execution.
- Compatibility conversion happens before display and ticket issuance. The
  source compiler closure is pinned; a second compilation must prove stability.
  The actual transformed file is displayed and copied into the receipt as
  `runtime-execution.do`, separately from the editable author's original.
- The command `Prepare Visible Collaboration Layout (No Execution)` only
  arranges/validates the view. It does not execute a do-file. Use the matching
  client to submit; never present preparation as an executed manual run.

## Task example

```json
{
  "schema": "stata-cowork-task/1",
  "taskId": "example",
  "stages": [{
    "id": "describe",
    "program": "describe.do",
    "cwd": ".",
    "arguments": ["/absolute/new-output-directory"],
    "inputs": ["/absolute/saved-input.dta"],
    "outputs": ["/absolute/new-output-directory/summary.csv"],
    "dependencies": [],
    "requires": []
  }]
}
```

Arguments are passed as quoted literal Stata strings; macro-expanding or
newline/quote-bearing arguments are rejected. The program owns its data and
statistical assertions; the manifest does not invent them. Relative declared
paths resolve from the manifest location. Declare included code and explicit
checkpoint inputs; copying the main `.do` does not rewrite undeclared dynamic
includes. Reconcile source edits before submitting a new version.

`--diagnostic` explicitly uses the old transport-only mode and cannot obtain
`PASS_VISIBLE_COWORK_RUN`. New default mode refuses an old runtime rather than
quietly bypassing visibility. The current local formal tools are intentionally
not overwritten while the original research backend is in use.

## Required remaining release acceptance

**Exact-source issue discovered in the first real replay:** the legacy Darwin
compatibility adapter may create a different `.do` (including `name()` option
protection on a named log). The author input and the transformed runtime file are
not byte-identical. The new client records both identities and refuses an
exact-source co-working PASS on that path (`EXECUTED_SOURCE_IDENTITY_NOT_CERTIFIED`).
The candidate now prepares and displays a stable transformed version before
dispatch, with positive tests using the real Darwin compiler and negative tests
for substituted cwd, changed code and mismatched receipts. That repair has only
offline verification so far. Do not certify V751 or runtime acceptance from
layout/transport checks alone.

Offline unit/replay checks are necessary, not sufficient. Still required:
actual target-window layout and failed program controls; human pause/edit/save/
rejoin and current-file execution; graphs without replacing Terminal; V751 all
declared replay entries via both requested routes; new FULL45 on the exact
candidate runtime; explicit state-preserving migration and installation check.
Cancellation control invocation is covered offline; a live confirmed-cancellation
receipt classification is not yet certified. Neither a stop request nor a stale
idle status is proof that the correct computation stopped.

The independent operating skill lives in the paired
`stata-workbench-shared-session-skill` repository. Its compatibility manifest and
this runtime must be released as a tested pair.

API semantics: [VS Code API](https://code.visualstudio.com/api/references/vscode-api)
and [Webview API](https://code.visualstudio.com/api/extension-guides/webview).
