# Stata Workbench Shared Session

Stata Workbench Shared Session is a patched VS Code extension distribution for users who want a visible, real-time Stata session shared by humans and AI agents.

The project is derived from `tmonk/stata-workbench` and incorporates local design lessons from comparing `hanlulong/stata-mcp`. The production goal is simple: Stata execution should be visible in the same VS Code Stata Terminal, preserve the live Stata session, keep graph rendering responsive, and provide recovery tools when long research scripts stress the Workbench lifecycle.

## Status

Current public package: `v0.1.1`.

Install channels:

- GitHub Release VSIX: https://github.com/lzhs1995/stata-workbench-shared-session/releases
- Open VSX: https://open-vsx.org/extension/lzhs1995/stata-workbench-shared-session
- Visual Studio Marketplace: not published. Marketplace publication is deferred because it requires the Marketplace publisher/PAT workflow.

The earlier `v0.1.0` release remains available, but `v0.1.1` is the first package that includes the public taught-task examples and expanded dependency documentation.

## What This Extension Is For

Use this extension when you want Stata execution to remain visible in VS Code while humans and agents work in the same session:

- Human and agent commands appear in the same `Stata Terminal` surface.
- Stata memory, globals, estimates, graphs, logs, and command history remain observable.
- Graph output is routed to a dedicated `Stata Graphs` panel instead of flooding terminal text.
- Long research scripts can be run through visible execution helpers and verified by audit logs.
- Recovery scripts help diagnose busy/stale Workbench lifecycle states.

This is not a hidden batch runner. If a workflow requires user-facing execution, the shared visible Stata Terminal is the intended path.

## Requirements

The tested and supported environment is:

- Windows 10/11.
- VS Code or an Open VSX-compatible editor.
- Licensed Stata 18 MP installed locally.
- PowerShell 5.1+ or PowerShell 7 for helper scripts.
- Python/uv as required by the upstream `mcp-stata` runtime.
- Node.js only for development, packaging, or publishing from source.

Other Stata versions, non-MP editions, macOS, and Linux are not the primary tested target. They may work, but should be treated as community best-effort until verified.

This project does not include Stata, Stata license files, private data, logs, generated tables, or research outputs.

See `docs/DEPENDENCIES.md` for the full dependency and packaging boundary.

## Install

### Open VSX

Open the extension page and install from your editor:

https://open-vsx.org/extension/lzhs1995/stata-workbench-shared-session

### GitHub Release VSIX

Download the latest `stata-workbench-shared-session-*.vsix` from:

https://github.com/lzhs1995/stata-workbench-shared-session/releases

Then install:

```powershell
code --install-extension .\stata-workbench-shared-session-0.1.1.vsix
```

If `code` is not on PATH, use `Extensions: Install from VSIX...` inside VS Code.

## Quick Smoke Test

Open `examples/minimal-workspace/smoke.do`, then run the current file or selected code through Stata Workbench. A healthy run prints:

```text
STATA_WORKBENCH_SMOKE_OK
```

You should see text output in `Stata Terminal`. Graph-producing examples should populate the separate `Stata Graphs` panel.

## Taught Task Examples

The repository includes nine self-contained Stata do-files in `examples/taught-tasks/`. They use Stata's built-in `auto` data or synthetic data derived from it, so no private dataset is required.

Recommended first run:

```text
examples/taught-tasks/taught_task1.do
```

The later files progressively stress graph routing, terminal output, generated variables, `putdocx`, regression workflows, event-study style code, matching/IV/mediation examples, and MI/document-heavy workflows. They are intentionally larger than a normal smoke test.

Read `examples/taught-tasks/README.md` before running all nine files. For very large files, use visible segmented execution and verify run evidence instead of assuming a long terminal run completed successfully.

## Development

```powershell
npm install
npm run check
npm run package
```

The extension entry point is `dist/extension.js`. Helper scripts are kept in `scripts/` for local setup, visible bridge invocation, verification, and recovery workflows.

Optional helper-script environment variables:

```powershell
$env:STATA_WORKBENCH_WORKSPACE = "C:\path\to\your\stata\workspace"
$env:STATA_WORKBENCH_CODE = "C:\path\to\Code.exe"
```

## Community Docs

- Installation: `docs/INSTALL.md`
- Dependencies: `docs/DEPENDENCIES.md`
- Taught task walkthrough: `examples/taught-tasks/README.md`
- Architecture: `docs/ARCHITECTURE.md`
- Known limitations: `docs/LIMITATIONS.md`
- FAQ: `docs/FAQ.md`
- Publishing: `docs/PUBLISHING.md`
- Maintenance workflow: `docs/MAINTENANCE.md`
- Roadmap: `docs/ROADMAP.md`
- Troubleshooting: `docs/TROUBLESHOOTING.md`

## Safety Notes

- Do not commit Stata license files.
- Do not commit private `.dta`, `.csv`, tables, graphs, logs, or temp outputs.
- Do not publish local `7_temp` run evidence.
- Do not paste Marketplace/Open VSX tokens into files.
- Do not describe hidden Stata execution as shared-session execution.

## Upstream Attribution

See `NOTICE` for upstream attribution and license notes.
