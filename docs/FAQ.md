# FAQ

## Does this include Stata?

No. You need a local licensed Stata installation and must configure `stataMcp.stataPath`.

## Which Stata version is supported?

The tested and supported baseline is Stata 18 MP on Windows. Other Stata versions or editions may work, but they are not the main verified target yet.

## How do I install the current version?

Use Open VSX:

https://open-vsx.org/extension/lzhs1995/stata-workbench-shared-session

Or download the latest VSIX from GitHub Releases and install it with:

```powershell
code --install-extension .\stata-workbench-shared-session-0.1.1.vsix
```

## Why is it not in the VS Code Marketplace search?

The Visual Studio Marketplace package is not published at this stage. Use Open VSX or the GitHub Release VSIX.

## What makes this different from hidden Stata execution?

The core workflow is a visible shared Stata Terminal in VS Code. Human and agent execution should be observable in the same Workbench session.

## Are the taught task files real data?

No private data is included. The examples use Stata's built-in `auto` data or synthetic data derived from it.

## Which taught task should I run first?

Run `examples/taught-tasks/taught_task1.do` first. Tasks 8 and 9 are extreme stress fixtures and are not appropriate first-run smoke tests.

## Where do example outputs go?

The examples write to `7_temp/` and `4_tables/` relative to the current Stata working directory. For portability, set `stataMcp.runFileWorkingDirectory` to `${fileDir}` when running files from `examples/taught-tasks/`.

## What should I report in issues?

Include your OS, editor, VS Code-compatible version, Stata version/edition, install method, command used, bridge status if available, and the smallest `.do` file that reproduces the issue.
