# Minimal Workspace

Use this folder as a clean smoke-test workspace after installing the VSIX.

1. Copy `.vscode/settings.example.json` to `.vscode/settings.json`.
2. Set `stataMcp.stataPath` to your local Stata executable.
3. Open `smoke.do`.
4. Run `Stata: Open Interactive Terminal`.
5. Run `Stata: Run Current File`.

Expected marker:

```text
STATA_WORKBENCH_SMOKE_OK
```

