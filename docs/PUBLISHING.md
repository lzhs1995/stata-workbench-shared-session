# Publishing

## GitHub Releases

The first distribution channel is a GitHub Release with an attached `.vsix`.

```powershell
npm install
npm run check
npm run package
gh release create v0.1.0 .\stata-workbench-shared-session-0.1.0.vsix --title "v0.1.0" --notes "Initial public VSIX release."
```

Users can install it with:

```powershell
code --install-extension .\stata-workbench-shared-session-0.1.0.vsix
```

## Visual Studio Marketplace

Marketplace publication is possible, but it requires a registered publisher and a Personal Access Token with Marketplace permissions.

```powershell
npm install
npm run package
npx vsce login <publisher-id>
npx vsce publish
```

Before publishing:

1. Confirm the publisher ID in `package.json`.
2. Confirm `LICENSE` and `NOTICE` are correct.
3. Confirm no private paths, data, logs, or license files are included.
4. Install the generated `.vsix` in a clean VS Code profile.

## Open VSX

Open VSX publication can be added later:

```powershell
npm install -g ovsx
ovsx publish .\stata-workbench-shared-session-0.1.0.vsix
```

Do not commit Marketplace/Open VSX tokens.
