# FAQ

## Does this include Stata?

No. You need a local licensed Stata installation and must configure `stataMcp.stataPath`.

## How do I install version 0.1.0?

Download the VSIX from the GitHub Release and install it with:

```powershell
code --install-extension .\stata-workbench-shared-session-0.1.0.vsix
```

## Why is it not in the VS Code Extensions search yet?

Marketplace and Open VSX publication are still pending. The GitHub Release VSIX is the current public install channel.

## What makes this different from hidden Stata execution?

The core workflow is a visible shared Stata Terminal in VS Code. Human and agent execution should be observable in the same Workbench session.

## What should I report in issues?

Include your OS, VS Code version, Stata version, install method, command used, bridge status if available, and the smallest `.do` file that reproduces the issue.

