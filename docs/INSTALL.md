# Installation

## From VSIX

```powershell
code --install-extension .\stata-workbench-shared-session-0.1.0.vsix
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
