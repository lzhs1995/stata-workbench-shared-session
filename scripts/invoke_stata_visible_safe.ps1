# Safe wrapper for visible Stata Workbench execution.
# It enforces the documented single-flight protocol before delegating to
# invoke_stata_visible.ps1.
#
# Important scope: this wrapper only gates bridge state before a visible run
# starts. It is not a full segmented-run orchestrator and does not, by itself,
# implement anti-stall logic after a long segment has already started. For that,
# prefer invoke_stata_segmented_visible.ps1.

param(
  [string]$Code,
  [string]$DoFile,
  [string]$Cwd = "",
  [string]$Label = "Visible Stata Safe Run",
  [int]$TimeoutSec = 900,
  [switch]$TailLog,
  [int]$TailLines = 80,
  [switch]$PlainTextTail,
  [switch]$NoSharedStateMutation,
  [switch]$AllowHttp500Retry,
  [switch]$UseRunFileHandler,
  [ValidateSet("fail", "wait", "reset")]
  [string]$BusyPolicy = "wait",
  [int]$MaxWaitSec = 60,
  [int]$PollSec = 5,
  [switch]$VerifyPatch,
  [switch]$SmokeAfterReset
)

$repoRoot = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($Cwd)) {
  if (-not [string]::IsNullOrWhiteSpace($env:STATA_WORKBENCH_WORKSPACE)) {
    $Cwd = $env:STATA_WORKBENCH_WORKSPACE
  } else {
    $Cwd = $repoRoot
  }
}
$bridgeBase = "http://127.0.0.1:17485"
$innerWrapper = Join-Path $PSScriptRoot "invoke_stata_visible.ps1"
$verifyScript = Join-Path $PSScriptRoot "stata_patch.ps1"

function Get-BridgeStatus {
  Invoke-RestMethod -Uri "$bridgeBase/status" -Method Get -TimeoutSec 5
}

function Wait-BridgeIdle {
  param(
    [int]$WaitSec,
    [int]$PollIntervalSec
  )

  $deadline = (Get-Date).AddSeconds($WaitSec)
  while ((Get-Date) -lt $deadline) {
    $status = Get-BridgeStatus
    if ($status.busy -ne $true) {
      return $status
    }
    $currentLabel = if ($status.current -and $status.current.label) { $status.current.label } else { "unknown" }
    $elapsed = if ($status.current -and $null -ne $status.current.elapsedSec) { $status.current.elapsedSec } else { "unknown" }
    Write-Host "Bridge busy; waiting ${PollIntervalSec}s (job=$currentLabel, elapsed=${elapsed}s)..." -ForegroundColor Yellow
    Start-Sleep -Seconds $PollIntervalSec
  }

  return (Get-BridgeStatus)
}

function Invoke-BridgeReset {
  Write-Host "Requesting /force-reset ..." -ForegroundColor Yellow
  Invoke-RestMethod -Uri "$bridgeBase/force-reset" -Method Post -TimeoutSec 20
}

function Invoke-BridgeVerify {
  Write-Host "Running patch verify ..." -ForegroundColor Cyan
  & $verifyScript verify
  if ($LASTEXITCODE -ne 0) {
    throw "stata_patch.ps1 verify failed with exit code $LASTEXITCODE."
  }
}

function Invoke-BridgeSmokeTest {
  Write-Host "Running post-reset smoke test ..." -ForegroundColor Cyan
  $smokeArgs = @{
    Code = 'display as text "visible bridge recovered"'
    Label = 'safe wrapper smoke test'
    Cwd = $Cwd
    TimeoutSec = 120
    TailLog = $true
    TailLines = 40
  }
  & $innerWrapper @smokeArgs
  if ($LASTEXITCODE -ne 0) {
    throw "Smoke test failed with exit code $LASTEXITCODE."
  }
}

if ([string]::IsNullOrWhiteSpace($Code) -and [string]::IsNullOrWhiteSpace($DoFile)) {
  Write-Error "Provide either -Code or -DoFile."
  exit 2
}

try {
  $status = Get-BridgeStatus
} catch {
  Write-Error "Failed to query visible bridge status: $($_.Exception.Message)"
  exit 1
}

if ($status.busy -eq $true) {
  switch ($BusyPolicy) {
    "fail" {
      $labelText = if ($status.current -and $status.current.label) { $status.current.label } else { "unknown" }
      $elapsedText = if ($status.current -and $null -ne $status.current.elapsedSec) { "$($status.current.elapsedSec)s" } else { "unknown" }
      Write-Error "Bridge busy; refusing to queue (job=$labelText, elapsed=$elapsedText)."
      exit 9
    }
    "wait" {
      $status = Wait-BridgeIdle -WaitSec $MaxWaitSec -PollIntervalSec $PollSec
      if ($status.busy -eq $true) {
        $labelText = if ($status.current -and $status.current.label) { $status.current.label } else { "unknown" }
        $elapsedText = if ($status.current -and $null -ne $status.current.elapsedSec) { "$($status.current.elapsedSec)s" } else { "unknown" }
        Write-Error "Bridge still busy after waiting ${MaxWaitSec}s (job=$labelText, elapsed=$elapsedText). Re-run with -BusyPolicy reset if you want to abort the stuck job. For long segmented reruns, prefer invoke_stata_segmented_visible.ps1 so repeated status checks do not turn into an indefinite wait loop."
        exit 9
      }
    }
    "reset" {
      $null = Invoke-BridgeReset
      Start-Sleep -Seconds 2
      Invoke-BridgeVerify
      Invoke-BridgeSmokeTest
      $status = Get-BridgeStatus
      if ($status.busy -eq $true) {
        Write-Error "Bridge still busy after /force-reset."
        exit 9
      }
    }
  }
} elseif ($VerifyPatch) {
  Invoke-BridgeVerify
}

$invokeArgs = @{
  Cwd = $Cwd
  Label = $Label
  TimeoutSec = $TimeoutSec
  TailLines = $TailLines
}
if (-not [string]::IsNullOrWhiteSpace($Code)) { $invokeArgs.Code = $Code }
if (-not [string]::IsNullOrWhiteSpace($DoFile)) { $invokeArgs.DoFile = $DoFile }
if ($TailLog) { $invokeArgs.TailLog = $true }
if ($PlainTextTail) { $invokeArgs.PlainTextTail = $true }
if ($NoSharedStateMutation) { $invokeArgs.NoSharedStateMutation = $true }
if ($AllowHttp500Retry) { $invokeArgs.AllowHttp500Retry = $true }
if ($UseRunFileHandler) { $invokeArgs.UseRunFileHandler = $true }

& $innerWrapper @invokeArgs
exit $LASTEXITCODE
