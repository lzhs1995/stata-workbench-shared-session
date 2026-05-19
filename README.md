# Stata Workbench Shared Session

Stata Workbench Shared Session is a patched VS Code extension distribution for users who want a visible, real-time Stata session shared by humans and AI agents.

The project is derived from `tmonk/stata-workbench` and incorporates local design lessons from comparing `hanlulong/stata-mcp`. The production goal is simple: Stata execution should be visible in the same VS Code Stata Terminal, preserve the live Stata session, keep graph rendering responsive, and provide recovery tools when long research scripts stress the Workbench lifecycle.

## Status

This repository is being prepared as a clean public release from a local research workspace. The first public channel is expected to be a GitHub Release with a `.vsix` package. Marketplace publication can follow after publisher identity and token setup.

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

After a `.vsix` package is available:

```powershell
code --install-extension .\stata-workbench-shared-session-0.1.0.vsix
```

Then configure your local Stata path in VS Code settings.

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

## Upstream attribution

See `NOTICE` for upstream attribution and license notes.
