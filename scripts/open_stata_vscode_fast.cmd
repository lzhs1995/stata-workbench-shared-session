@echo off
chcp 65001 >nul
setlocal

pushd "%~dp0" || (
  echo Cannot enter script directory: %~dp0
  pause
  exit /b 1
)

echo Starting Stata-focused VS Code launcher through hidden WScript...
echo Log: %~dp0open_stata_vscode_fast.log

wscript.exe "%~dp0open_stata_vscode_fast_hidden.vbs"
set "ERR=%ERRORLEVEL%"

popd

if not "%ERR%"=="0" (
  echo.
  echo Failed to open Stata-focused VS Code.
  echo Check: open_stata_vscode_fast.log
  pause
)

exit /b %ERR%
