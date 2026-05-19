# Publishing

## Current Public Channels

`v0.1.1` is intended as the first release that includes the public taught-task examples and expanded dependency documentation.

Public channels:

- GitHub Releases: https://github.com/lzhs1995/stata-workbench-shared-session/releases
- Open VSX: https://open-vsx.org/extension/lzhs1995/stata-workbench-shared-session

The Visual Studio Marketplace package is not currently published. Marketplace publication is deferred because it requires the Microsoft publisher/PAT workflow.

## Maintenance Workflow

Before publishing a runtime patch that was developed in the live Stata workspace, follow `docs/MAINTENANCE.md`. In short: export only whitelisted runtime scripts from the workspace, check the extension bundle separately, then run the packaging and smoke-test checklist below.

## GitHub Release

To recreate the package locally:

```powershell
npm install
npm run check
npm run package
```

Users can install the VSIX with:

```powershell
code --install-extension .\stata-workbench-shared-session-0.1.1.vsix
```

Before uploading a release asset:

1. Confirm `package.json` has the intended version.
2. Confirm `LICENSE` and `NOTICE` are correct.
3. Confirm no private paths, data, logs, generated outputs, license files, or tokens are included.
4. Install the generated `.vsix` in a clean VS Code profile.

## Open VSX

Open VSX is the active registry channel for direct extension installation outside the GitHub Release VSIX flow.

```powershell
npm run check
npm run package
npx ovsx publish .\stata-workbench-shared-session-0.1.1.vsix
```

Do not commit Open VSX tokens. Prefer passing tokens through the environment or an interactive login flow.

After publication, verify:

```powershell
Invoke-WebRequest https://open-vsx.org/api/lzhs1995/stata-workbench-shared-session
```

## Visual Studio Marketplace

Marketplace is intentionally not the active channel at this stage. If publication is resumed later:

```powershell
npx vsce login lzhs1995
npx vsce publish
```

Required Marketplace steps:

1. Create or confirm the `lzhs1995` publisher.
2. Create a Marketplace PAT with publishing rights.
3. Run package checks and clean-profile smoke tests.
4. Publish with `vsce`.

Do not paste Marketplace PATs into repository files, issues, docs, or chat logs.
