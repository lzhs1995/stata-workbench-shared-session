# Troubleshooting

## Stata Terminal appears busy forever

Check bridge status before running more code. Do not queue another long run into a busy shared session.

## Graphs do not appear

Check graph status and whether the command produces retained graph objects or transient unnamed graphs.

## Long script stalls

Use segmented execution, preserve logs under a run root, and verify output freshness. A large log can poison the next bridge call; reset and smoke-test before retrying.

## Stata session is stopped

Use the recovery scripts in `scripts/` and verify true READY before productive work.

## The `code` command cannot install the VSIX

Confirm which executable PowerShell resolves:

```powershell
Get-Command code
code --version
```

If `code --version` fails, install from VSIX through the VS Code UI or fix your shell PATH so `code` points to the current VS Code `bin\code.cmd`.

## Marketplace or Open VSX cannot find the extension

For current releases, use Open VSX or the GitHub Release VSIX. The Visual Studio Marketplace package is not currently published.
