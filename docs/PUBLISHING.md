# Publishing

## GitHub Releases

The first distribution channel is already live as `v0.1.0`:

https://github.com/lzhs1995/stata-workbench-shared-session/releases/tag/v0.1.0

To recreate the package locally:

```powershell
npm install
npm run check
npm run package
```

Users can install it with:

```powershell
code --install-extension .\stata-workbench-shared-session-0.1.0.vsix
```

## Visual Studio Marketplace

Marketplace publication is not complete yet. Use publisher ID `lzhs1995` to match `package.json`.

Create or confirm the publisher in the Visual Studio Marketplace publisher portal, then create a Personal Access Token with Marketplace publishing permissions. Do not paste the token into files or commit it.

```powershell
npm install
npm run check
npm run package
npx vsce login lzhs1995
npx vsce publish
```

Before publishing:

1. Confirm the publisher ID in `package.json`.
2. Confirm `LICENSE` and `NOTICE` are correct.
3. Confirm no private paths, data, logs, or license files are included.
4. Install the generated `.vsix` in a clean VS Code profile.

## Open VSX

Open VSX publication is not complete yet. Publish after the Marketplace package has been smoke-tested:

```powershell
npm install -g ovsx
ovsx publish .\stata-workbench-shared-session-0.1.0.vsix
```

Do not commit Marketplace/Open VSX tokens.

After publication, verify:

```powershell
Invoke-WebRequest https://open-vsx.org/api/lzhs1995/stata-workbench-shared-session
```
