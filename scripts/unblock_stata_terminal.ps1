# Unblock Stata Terminal — recovery tool for UI-layer blocking
#
# When the Stata Terminal appears stuck but /status reports busy:false,
# the block is at the extension UI layer (typically graph panel post-processing).
# This script performs the minimum recovery sequence.
#
# Usage:
#   pwsh -File unblock_stata_terminal.ps1
#   pwsh -File unblock_stata_terminal.ps1 -ReloadVsCode

param(
  [switch]$ReloadVsCode,
  [int]$SmokeTimeoutSec = 60
)

$ErrorActionPreference = "Continue"
$bridgeBase = "http://127.0.0.1:17485"

Write-Host "=== Stata Terminal Unblock ===" -ForegroundColor Yellow

# Step 1: Check current state
Write-Host "[1/4] Checking bridge state..."
try {
  $status = Invoke-RestMethod -Uri "$bridgeBase/status" -Method Get -TimeoutSec 5
  Write-Host "  Bridge: busy=$($status.busy) status=$($status.status)" -ForegroundColor Cyan
  Write-Host "  Graph clears: $($status.graphPanel.clearCount)" -ForegroundColor Cyan
  Write-Host "  Last image load: $($status.graphPanel.lastImageLoadOk)" -ForegroundColor $(if ($status.graphPanel.lastImageLoadOk) { "Green" } else { "Red" })
} catch {
  Write-Host "  Bridge OFFLINE: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 2: Clear graph panel (display-only, non-destructive)
Write-Host "[2/4] Clearing graph panel..."
try {
  $r = Invoke-RestMethod -Uri "$bridgeBase/graph-clear" -Method Post -TimeoutSec 10
  Write-Host "  Graph clear: ok=$($r.ok)" -ForegroundColor $(if ($r.ok) { "Green" } else { "Red" })
} catch {
  Write-Host "  Graph clear failed (non-critical)" -ForegroundColor Yellow
}

# Step 3: Force-reset bridge
Write-Host "[3/4] Force-resetting bridge..."
try {
  $r = Invoke-RestMethod -Uri "$bridgeBase/force-reset" -Method Post -TimeoutSec 30
  Write-Host "  Force-reset: ok=$($r.ok)" -ForegroundColor $(if ($r.ok) { "Green" } else { "Red" })
} catch {
  Write-Host "  Force-reset failed: $($_.Exception.Message)" -ForegroundColor Red
}

Start-Sleep -Seconds 3

# Step 4: Smoke test
Write-Host "[4/4] Running smoke test..."
$marker = "UNBLOCK_$(Get-Date -Format 'HHmmss')"
try {
  $result = & (Join-Path $PSScriptRoot "invoke_stata_visible.ps1") `
    -Code "display as text `"$marker`"" `
    -Label "unblock smoke test" `
    -TailLog `
    -TimeoutSec $SmokeTimeoutSec 2>&1
  $jsonLine = $result | Where-Object { $_ -match '"ok"' } | Select-Object -First 1
  if ($jsonLine) {
    $json = $jsonLine | ConvertFrom-Json
    Write-Host "  Smoke: ok=$($json.ok) rc=$($json.rc)" -ForegroundColor $(if ($json.ok -and $json.rc -eq 0) { "Green" } else { "Red" })
  } else {
    Write-Host "  Smoke: NO JSON (bridge may still be recovering)" -ForegroundColor Yellow
  }
} catch {
  Write-Host "  Smoke: FAILED — $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Recovery complete ===" -ForegroundColor Green
Write-Host "If terminal is STILL unresponsive, VS Code Developer: Reload Window is needed."
Write-Host "Run: unblock_stata_terminal.ps1 -ReloadVsCode"
