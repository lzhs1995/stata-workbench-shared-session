# Stata Workbench Shared Session

Stata Workbench Shared Session is a patched VS Code extension distribution for users who want a visible, real-time Stata session shared by humans and AI agents.

The project is derived from `tmonk/stata-workbench` and incorporates local design lessons from comparing `hanlulong/stata-mcp`. The production goal is simple: Stata execution should be visible in the same VS Code Stata Terminal, preserve the live Stata session, keep graph rendering responsive, and provide recovery tools when long research scripts stress the Workbench lifecycle.

## Status

Version `v0.1.0` is available now as a GitHub Release with an attached VSIX package:

- Release: https://github.com/lzhs1995/stata-workbench-shared-session/releases/tag/v0.1.0
- VSIX: `stata-workbench-shared-session-0.1.0.vsix`

Visual Studio Marketplace and Open VSX publication are planned next. Until those channels are published, install from the GitHub Release VSIX.

## Features

- Visible human-agent shared Stata execution path.
- Single-flight bridge for agent-triggered visible runs.
- Stata Terminal text kept separate from graph rendering.
- `Stata Graphs` panel for current-run graph artifacts.
- Recovery endpoints and scripts for stale UI, stopped sessions, and graph/lifecycle drain.
- Verification scripts for audit logs, run roots, and output freshness.
- Segmented long-run orchestration for large `.do` files.

## Requirements

- Windows with VS Code.
- A locally installed and licensed Stata.
- Node.js for packaging and development.
- Python/uv only as required by `mcp-stata` and the upstream Workbench runtime.

This project does not include Stata, Stata license files, private data, or research outputs.

## Install from VSIX

Download `stata-workbench-shared-session-0.1.0.vsix` from the `v0.1.0` GitHub Release, then run:

```powershell
code --install-extension .\stata-workbench-shared-session-0.1.0.vsix
```

Then configure your local Stata path in VS Code settings.

Marketplace and Open VSX direct install links will be added after publication.

## Quick smoke test

Open `examples/stata_workbench_smoke.do`, then run the current line/selection through `Stata: Run Selection/Current Line`. A healthy run prints:

```text
STATA_WORKBENCH_SMOKE_OK
```

## Development

```powershell
npm install
npm run check
npm run package
```

The extension entry point is `dist/extension.js`. Helper scripts are kept in `scripts/` for local setup, visible bridge invocation, verification, and recovery workflows.

Set optional environment variables before using helper scripts outside the repository root:

```powershell
$env:STATA_WORKBENCH_WORKSPACE = "C:\path\to\your\stata\workspace"
$env:STATA_WORKBENCH_CODE = "C:\path\to\Code.exe"
```

## Important safety notes

- Do not commit Stata license files.
- Do not commit private `.dta`, `.csv`, tables, graphs, or logs.
- Do not publish local `7_temp` run evidence.
- Do not describe hidden Stata execution as shared-session execution.

## Community docs

- Known limitations: `docs/LIMITATIONS.md`
- FAQ: `docs/FAQ.md`
- Publishing: `docs/PUBLISHING.md`
- Roadmap: `docs/ROADMAP.md`

## Upstream attribution

See `NOTICE` for upstream attribution and license notes.
