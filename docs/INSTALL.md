# Installation

## From VSIX

Download the VSIX from the `v0.1.0` GitHub Release:

https://github.com/lzhs1995/stata-workbench-shared-session/releases/tag/v0.1.0

Then install it:

```powershell
code --install-extension .\stata-workbench-shared-session-0.1.0.vsix
```

If the `code` command is unavailable, open VS Code and use:

```text
Extensions: Install from VSIX...
```

## From source

```powershell
git clone https://github.com/lzhs1995/stata-workbench-shared-session.git
cd stata-workbench-shared-session
npm install
npm run package
code --install-extension .\stata-workbench-shared-session-0.1.0.vsix
```

## Configure Stata

Set `stataMcp.stataPath` to your local Stata executable path in VS Code settings.

Do not commit your local path, license files, or local data into the repository.

## Smoke test

1. Open `examples/stata_workbench_smoke.do`.
2. Run `Stata: Open Interactive Terminal`.
3. Run `Stata: Run Current File` or select the file contents and run `Stata: Run Selection/Current Line`.
4. Confirm the Stata Terminal prints `STATA_WORKBENCH_SMOKE_OK`.

Direct Marketplace and Open VSX installation are not available until those registries are published.
