# Stata Workbench shared-session patch manager wrapper.

param(
  [ValidateSet("status", "verify", "apply", "revert")]
  [string]$Cmd = "status"
)

$PatchManager = Join-Path $PSScriptRoot "patch_manager.js"

if (-not (Test-Path -LiteralPath $PatchManager)) {
  Write-Error "Cannot find patch_manager.js: $PatchManager"
  exit 1
}

node $PatchManager $Cmd
$code = $LASTEXITCODE

if ($Cmd -eq "apply" -and $code -eq 0) {
  Write-Host ""
  Write-Host "Next: reload VS Code window before verifying bridge online." -ForegroundColor Yellow
  Write-Host "Command Palette: Developer: Reload Window" -ForegroundColor Yellow
}

exit $code
