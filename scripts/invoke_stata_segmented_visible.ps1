# Segmented visible Stata run orchestrator with anti-stall guardrails.
#
# This script coordinates a pre-defined segment spec and prevents the common
# low-end-model failure mode:
#   status -> wait -> status -> wait -> ... forever
#
# Segment spec JSON can be either:
#   1. an array of segment objects, or
#   2. an object with { "script": "...", "segments": [ ... ] }
#
# Each segment object should contain:
#   id, runnerPath, start, end, timeoutSec, title, expectedOutputs
#
# Usage:
#   & .\invoke_stata_segmented_visible.ps1 `
#     -RunRoot "C:\...\reexec_xxx" `
#     -SegmentsFile "C:\...\segments.json" `
#     -VerifyPatch `
#     -TailLog

param(
  [Parameter(Mandatory = $true)]
  [string]$RunRoot,
  [Parameter(Mandatory = $true)]
  [string]$SegmentsFile,
  [string]$ScriptPath = "",
  [string]$Cwd = "",
  [string]$LabelPrefix = "Visible Segmented Run",
  [switch]$VerifyPatch,
  [switch]$SmokeAfterReset,
  [ValidateSet("fail", "reset")]
  [string]$StallPolicy = "fail",
  [int]$BusyMaxWaitSec = 60,
  [int]$PollSec = 5,
  [int]$ExtraWaitSec = 30,
  [int]$RecentActivitySec = 45,
  [int]$PostSegmentSettleSec = 0,
  [int]$LargeLogSettleThresholdMB = 5,
  [int]$LargeLogSettleSec = 15,
  [switch]$SmokeAfterLargeLog,
  [switch]$ResetBeforeEachSegment,
  [switch]$AllowHttp500Retry,
  [switch]$TailLog,
  [int]$TailLines = 80,
  [switch]$PlainTextTail,
  [switch]$UseRunFileHandler,
  [switch]$StrictLedgerCompleteness
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($Cwd)) {
  if (-not [string]::IsNullOrWhiteSpace($env:STATA_WORKBENCH_WORKSPACE)) {
    $Cwd = $env:STATA_WORKBENCH_WORKSPACE
  } else {
    $Cwd = $repoRoot
  }
}
$bridgeBase = "http://127.0.0.1:17485"
$safeWrapper = Join-Path $PSScriptRoot "invoke_stata_visible_safe.ps1"
$ledgerHelper = Join-Path $PSScriptRoot "write_stata_run_ledger.ps1"
$verifyScript = Join-Path $PSScriptRoot "verify_stata_execution.ps1"
$patchVerifier = Join-Path $PSScriptRoot "stata_patch.ps1"
$tempLogDir = Join-Path $Cwd "7_temp\mcp-stata-temp"
$runLogDir = Join-Path $RunRoot "logs"

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
  Invoke-RestMethod -Uri "$bridgeBase/force-reset" -Method Post -TimeoutSec 20 | Out-Null
}

function Invoke-BridgeVerify {
  Write-Host "Running patch verify ..." -ForegroundColor Cyan
  & $patchVerifier verify
  if ($LASTEXITCODE -ne 0) {
    throw "stata_patch.ps1 verify failed with exit code $LASTEXITCODE."
  }
}

function Invoke-BridgeSmokeTest {
  param([string]$Reason = "segmented orchestrator smoke test")

  $safeReason = [regex]::Replace($Reason, '[^A-Za-z0-9_]+', '_').Trim('_')
  if ([string]::IsNullOrWhiteSpace($safeReason)) {
    $safeReason = "segmented_orchestrator_smoke"
  }
  $marker = "SMOKE_{0}_{1}" -f $safeReason, (Get-Date -Format "yyyyMMdd_HHmmss_fff")
  Write-Host "Running smoke test ($marker) ..." -ForegroundColor Cyan
  $smokeArgs = @{
    Code = "display as text `"$marker`""
    Label = "segmented orchestrator smoke test $marker"
    Cwd = $Cwd
    TimeoutSec = 120
    TailLog = $true
    TailLines = 40
  }
  if ($PlainTextTail) { $smokeArgs.PlainTextTail = $true }
  & (Join-Path $PSScriptRoot "invoke_stata_visible.ps1") @smokeArgs
  if ($LASTEXITCODE -ne 0) {
    throw "Smoke test failed with exit code $LASTEXITCODE."
  }
  & $verifyScript -Label $marker -Last 1 -Quiet
  if ($LASTEXITCODE -ne 0) {
    throw "Smoke test marker $marker failed verify_stata_execution.ps1."
  }
  Write-OrchestratorLine ("SmokeVerified marker={0} reason={1}" -f $marker, $Reason)
}

function Write-OrchestratorLine {
  param([string]$Line)
  & $ledgerHelper -RunRoot $RunRoot -OrchestratorLine $Line
}

function Ensure-RunRootInitialized {
  param([string]$ResolvedScriptPath)

  $resultsPath = Join-Path $RunRoot "results.json"
  if (-not (Test-Path -LiteralPath $resultsPath)) {
    & $ledgerHelper -RunRoot $RunRoot -ScriptPath $ResolvedScriptPath -Init
  }
}

function Read-SegmentSpec {
  $raw = Get-Content -LiteralPath $SegmentsFile -Raw -Encoding UTF8
  $obj = $raw | ConvertFrom-Json

  $segments = @()
  $resolvedScriptPath = $ScriptPath

  if ($obj -is [System.Array]) {
    $segments = @($obj)
  } elseif ($null -ne $obj.segments) {
    $segments = @($obj.segments)
    if ([string]::IsNullOrWhiteSpace($resolvedScriptPath) -and -not [string]::IsNullOrWhiteSpace([string]$obj.script)) {
      $resolvedScriptPath = [string]$obj.script
    }
  } else {
    throw "SegmentsFile must be a JSON array or an object containing a segments array."
  }

  if ($segments.Count -eq 0) {
    throw "No segments found in $SegmentsFile."
  }

  return [pscustomobject]@{
    ScriptPath = $resolvedScriptPath
    Segments = $segments
  }
}

function Get-StringArray {
  param([object]$Value)

  $items = @()
  if ($null -eq $Value) {
    return $items
  }
  foreach ($item in @($Value)) {
    if ($null -eq $item) {
      continue
    }
    $text = [string]$item
    if (-not [string]::IsNullOrWhiteSpace($text)) {
      $items += $text
    }
  }
  return $items
}

function Get-RecentTempActivity {
  param(
    [int]$WindowSec,
    [datetime]$SegmentStart
  )

  if (-not (Test-Path -LiteralPath $tempLogDir)) {
    return $null
  }

  $cutoff = (Get-Date).AddSeconds(-1 * $WindowSec)
  if ($SegmentStart -gt $cutoff) {
    $cutoff = $SegmentStart
  }
  $recent = Get-ChildItem -LiteralPath $tempLogDir -File -ErrorAction SilentlyContinue |
    Where-Object { $_.LastWriteTime -ge $cutoff } |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

  return $recent
}

function Get-ProgressEvidence {
  param(
    [string[]]$ExpectedOutputs,
    [datetime]$SegmentStart
  )

  $freshOutputs = @()
  foreach ($path in $ExpectedOutputs) {
    if (Test-Path -LiteralPath $path) {
      $item = Get-Item -LiteralPath $path
      if ($item.LastWriteTime -ge $SegmentStart) {
        $freshOutputs += $item.FullName
      }
    }
  }

  $recentTemp = Get-RecentTempActivity -WindowSec $RecentActivitySec -SegmentStart $SegmentStart

  return [pscustomobject]@{
    FreshOutputs = $freshOutputs
    RecentTemp = $recentTemp
    HasAny = ($freshOutputs.Count -gt 0 -or $null -ne $recentTemp)
  }
}

function Parse-WrapperJson {
  param([string[]]$Lines)

  $jsonLine = $Lines | Where-Object { $_ -match '"ok"' } | Select-Object -First 1
  if (-not [string]::IsNullOrWhiteSpace($jsonLine)) {
    try {
      $parsed = $jsonLine | ConvertFrom-Json
      if ($null -ne $parsed -and $null -ne $parsed.PSObject.Properties["rc"]) {
        return $parsed
      }
    } catch {}
  }

  for ($i = 0; $i -lt $Lines.Count; $i++) {
    if ($Lines[$i].TrimStart() -notmatch '^\{') {
      continue
    }
    $candidateLines = New-Object System.Collections.Generic.List[string]
    for ($j = $i; $j -lt $Lines.Count -and $j -lt ($i + 500); $j++) {
      $candidateLines.Add([string]$Lines[$j])
      if ($Lines[$j].TrimEnd() -notmatch '^\}') {
        continue
      }
      $candidate = $candidateLines -join "`n"
      try {
        $parsed = $candidate | ConvertFrom-Json
        if ($null -ne $parsed -and $null -ne $parsed.PSObject.Properties["ok"] -and ($null -ne $parsed.PSObject.Properties["rc"] -or $null -ne $parsed.PSObject.Properties["runFileHandler"] -or $null -ne $parsed.PSObject.Properties["runId"])) {
          return $parsed
        }
      } catch {}
    }
  }

  $text = ($Lines | ForEach-Object { $_.ToString() }) -join "`n"
  foreach ($match in [regex]::Matches($text, '(?s)\{[^{}]*"ok"[^{}]*\}')) {
    $candidate = $match.Value
    if ($candidate -notmatch '"rc"|"runId"') {
      continue
    }
    try {
      return ($candidate | ConvertFrom-Json)
    } catch {}
  }

  return $null
}

function Resolve-SegmentLogPath {
  param(
    [string]$RunnerPath,
    [datetime]$Since
  )

  if (-not (Test-Path -LiteralPath $tempLogDir)) {
    return ""
  }

  $runnerNeedle = [System.IO.Path]::GetFileName($RunnerPath)
  $candidates = Get-ChildItem -LiteralPath $tempLogDir -File -Filter "mcp_stata_*.log" -ErrorAction SilentlyContinue |
    Where-Object { $_.LastWriteTime -ge $Since.AddSeconds(-5) } |
    Sort-Object LastWriteTime -Descending

  foreach ($candidate in $candidates) {
    try {
      if (Select-String -LiteralPath $candidate.FullName -Pattern ([regex]::Escape($RunnerPath)),([regex]::Escape($runnerNeedle)) -Quiet) {
        return $candidate.FullName
      }
    } catch {}
  }

  $fallback = $candidates | Sort-Object Length -Descending | Select-Object -First 1
  if ($fallback) {
    return $fallback.FullName
  }

  return ""
}

function Save-SegmentLogEvidence {
  param(
    [string]$SegmentId,
    [string]$LogPath
  )

  if ([string]::IsNullOrWhiteSpace($LogPath)) {
    return ""
  }
  if (-not (Test-Path -LiteralPath $LogPath)) {
    return $LogPath
  }

  if (-not (Test-Path -LiteralPath $runLogDir)) {
    New-Item -ItemType Directory -Path $runLogDir -Force | Out-Null
  }

  $leaf = [System.IO.Path]::GetFileName($LogPath)
  $dest = Join-Path $runLogDir ("{0}_{1}" -f $SegmentId, $leaf)
  Copy-Item -LiteralPath $LogPath -Destination $dest -Force
  return $dest
}

function Record-SegmentResult {
  param(
    [string]$SegmentId,
    [int]$Start,
    [int]$End,
    [string]$RunnerPath,
    [string]$LogPath,
    [bool]$Ok,
    [int]$Rc,
    [string[]]$ExpectedOutputs,
    [string]$Title
  )

  $args = @{
    RunRoot = $RunRoot
    SegmentId = $SegmentId
    Start = $Start
    End = $End
    RunnerPath = $RunnerPath
    LogPath = $LogPath
    Ok = $Ok
    Rc = $Rc
    ReplaceExisting = $true
  }
  if ($ExpectedOutputs -and $ExpectedOutputs.Count -gt 0) {
    $args.ExpectedOutputs = $ExpectedOutputs
  }
  if (-not [string]::IsNullOrWhiteSpace($Title)) {
    $args.Title = $Title
  }

  & $ledgerHelper @args
}

function Invoke-SafeSegment {
  param(
    [string]$RunnerPath,
    [string]$Label,
    [int]$TimeoutSec,
    [string]$InvocationMode = "DoFile"
  )

  $invokeArgs = @{
    Cwd = $Cwd
    Label = $Label
    TimeoutSec = $TimeoutSec
    BusyPolicy = "wait"
    MaxWaitSec = $BusyMaxWaitSec
    PollSec = $PollSec
    TailLines = $TailLines
  }
  if ($TailLog) { $invokeArgs.TailLog = $true }
  if ($PlainTextTail) { $invokeArgs.PlainTextTail = $true }
  if ($VerifyPatch) { $invokeArgs.VerifyPatch = $true }
  if ($AllowHttp500Retry) { $invokeArgs.AllowHttp500Retry = $true }

  if ($InvocationMode -match '^(code-do|codedo|code_do)$') {
    $stataRunnerPath = $RunnerPath -replace '\\', '/'
    $invokeArgs.Code = @"
capture noisily do "$stataRunnerPath"
exit _rc
"@
  } elseif ($InvocationMode -match '^(run-file-handler|runfilehandler|run_file_handler|human-file)$') {
    $invokeArgs.DoFile = $RunnerPath
    $invokeArgs.UseRunFileHandler = $true
  } else {
    $invokeArgs.DoFile = $RunnerPath
    if ($UseRunFileHandler) { $invokeArgs.UseRunFileHandler = $true }
  }

  $lines = @(
    & $safeWrapper @invokeArgs 2>&1 | ForEach-Object {
      if ($null -eq $_) { return }
      $_.ToString()
    }
  )

  return [pscustomobject]@{
    Lines = $lines
    ExitCode = $LASTEXITCODE
    Json = Parse-WrapperJson -Lines $lines
  }
}

function Wait-PostSegmentSettle {
  param(
    [string]$SegmentId,
    [int]$SettleSec
  )

  if ($SettleSec -le 0) {
    return
  }

  Write-OrchestratorLine ("PostSegmentSettle {0} wait={1}s" -f $SegmentId, $SettleSec)
  Start-Sleep -Seconds $SettleSec
  try {
    $status = Get-BridgeStatus
    $state = if ($status.busy -eq $true) { "busy" } else { "idle" }
    Write-OrchestratorLine ("PostSegmentSettleStatus {0} status={1}" -f $SegmentId, $state)
  } catch {
    Write-OrchestratorLine ("PostSegmentSettleStatus {0} status=unknown error={1}" -f $SegmentId, $_.Exception.Message)
  }
}

function Invoke-LargeLogGuard {
  param(
    [string]$SegmentId,
    [string]$LogPath
  )

  if ($LargeLogSettleThresholdMB -le 0) {
    return
  }
  if ([string]::IsNullOrWhiteSpace($LogPath) -or -not (Test-Path -LiteralPath $LogPath)) {
    return
  }

  $item = Get-Item -LiteralPath $LogPath
  $thresholdBytes = [int64]$LargeLogSettleThresholdMB * 1MB
  if ($item.Length -lt $thresholdBytes) {
    return
  }

  $sizeMb = [Math]::Round($item.Length / 1MB, 2)
  Write-OrchestratorLine ("LargeLogDetected {0} sizeMB={1} thresholdMB={2}" -f $SegmentId, $sizeMb, $LargeLogSettleThresholdMB)

  if ($LargeLogSettleSec -gt 0) {
    Write-OrchestratorLine ("LargeLogSettle {0} wait={1}s" -f $SegmentId, $LargeLogSettleSec)
    Start-Sleep -Seconds $LargeLogSettleSec
    try {
      $status = Get-BridgeStatus
      $state = if ($status.busy -eq $true) { "busy" } else { "idle" }
      Write-OrchestratorLine ("LargeLogSettleStatus {0} status={1}" -f $SegmentId, $state)
    } catch {
      Write-OrchestratorLine ("LargeLogSettleStatus {0} status=unknown error={1}" -f $SegmentId, $_.Exception.Message)
    }
  }

  if ($SmokeAfterLargeLog) {
    Invoke-BridgeSmokeTest -Reason ("large_log_after_{0}" -f $SegmentId)
  }
}

function Handle-Stall {
  param(
    [string]$SegmentId,
    [string]$SegmentLabel,
    [datetime]$SegmentStart,
    [string[]]$ExpectedOutputs
  )

  $status = Get-BridgeStatus
  if ($status.busy -ne $true) {
    return [pscustomobject]@{
      Status = $status
      Decision = "not-busy"
      Progress = $null
    }
  }

  $progress = Get-ProgressEvidence -ExpectedOutputs $ExpectedOutputs -SegmentStart $SegmentStart
  $recentTempText = if ($progress.RecentTemp) {
    "$($progress.RecentTemp.FullName) @ $($progress.RecentTemp.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss'))"
  } else {
    "none"
  }

  Write-OrchestratorLine ("StallCheck {0} busy=true freshOutputs={1} recentTemp={2}" -f $SegmentId, $progress.FreshOutputs.Count, $recentTempText)

  if ($progress.HasAny) {
    Write-OrchestratorLine ("ExtraWait {0} reason=progress-evidence wait={1}s" -f $SegmentId, $ExtraWaitSec)
    $statusAfterWait = Wait-BridgeIdle -WaitSec $ExtraWaitSec -PollIntervalSec $PollSec
    if ($statusAfterWait.busy -eq $true) {
      return [pscustomobject]@{
        Status = $statusAfterWait
        Decision = "stall-after-extra-wait"
        Progress = $progress
      }
    }

    return [pscustomobject]@{
      Status = $statusAfterWait
      Decision = "idle-without-verifiable-success"
      Progress = $progress
    }
  }

  return [pscustomobject]@{
    Status = $status
    Decision = "busy-without-progress"
    Progress = $progress
  }
}

try {
  $spec = Read-SegmentSpec
  $resolvedScriptPath = if (-not [string]::IsNullOrWhiteSpace($spec.ScriptPath)) { $spec.ScriptPath } else { $SegmentsFile }
  Ensure-RunRootInitialized -ResolvedScriptPath $resolvedScriptPath
  Write-OrchestratorLine ("Starting segmented visible run from spec {0}" -f $SegmentsFile)

  foreach ($segment in @($spec.Segments)) {
    $segmentId = [string]$segment.id
    if ([string]::IsNullOrWhiteSpace($segmentId)) {
      throw "Every segment in $SegmentsFile must define a non-empty id."
    }

    $runnerPath = [string]$segment.runnerPath
    if ([string]::IsNullOrWhiteSpace($runnerPath)) {
      $runnerPath = Join-Path $RunRoot ($segmentId + ".do")
    }
    if (-not (Test-Path -LiteralPath $runnerPath)) {
      throw ("Runner file not found for {0}: {1}" -f $segmentId, $runnerPath)
    }

    $start = if ($null -ne $segment.start) { [int]$segment.start } else { 0 }
    $end = if ($null -ne $segment.end) { [int]$segment.end } else { 0 }
    $title = [string]$segment.title
    $timeoutSec = if ($null -ne $segment.timeoutSec -and [int]$segment.timeoutSec -gt 0) { [int]$segment.timeoutSec } else { 1800 }
    $expectedOutputs = Get-StringArray -Value $segment.expectedOutputs
    $invocationMode = if ($null -ne $segment.invocationMode -and -not [string]::IsNullOrWhiteSpace([string]$segment.invocationMode)) { [string]$segment.invocationMode } else { "DoFile" }
    $segmentLabel = "{0} {1}" -f $LabelPrefix, $segmentId

    Write-OrchestratorLine ("Preparing {0} [{1}-{2}] runner={3}" -f $segmentId, $start, $end, $runnerPath)
    if ($ResetBeforeEachSegment) {
      Write-OrchestratorLine ("PreSegmentForceReset {0}" -f $segmentId)
      Invoke-BridgeReset
      Start-Sleep -Seconds 2
      Invoke-BridgeVerify
      if ($SmokeAfterReset) {
        Invoke-BridgeSmokeTest
      }
    }
    Write-OrchestratorLine ("Running {0} label={1} timeout={2}s invocationMode={3}" -f $segmentId, $segmentLabel, $timeoutSec, $invocationMode)

    $segmentStart = Get-Date
    $invokeResult = Invoke-SafeSegment -RunnerPath $runnerPath -Label $segmentLabel -TimeoutSec $timeoutSec -InvocationMode $invocationMode
    $json = $invokeResult.Json
    $exitCode = [int]$invokeResult.ExitCode

    $jsonSuccess = $null -ne $json -and $json.ok -eq $true -and ($null -eq $json.rc -or [int]$json.rc -eq 0)

    if ($jsonSuccess) {
      & $verifyScript -Label $segmentLabel -Last 1 -Quiet
      $resolvedLogPath = [string]$json.logPath
      if ([string]::IsNullOrWhiteSpace($resolvedLogPath)) {
        $resolvedLogPath = Resolve-SegmentLogPath -RunnerPath $runnerPath -Since $segmentStart
        if (-not [string]::IsNullOrWhiteSpace($resolvedLogPath)) {
          Write-OrchestratorLine ("ResolvedLog {0} logPath={1}" -f $segmentId, $resolvedLogPath)
        }
      }
      if ($LASTEXITCODE -ne 0) {
        Record-SegmentResult -SegmentId $segmentId -Start $start -End $end -RunnerPath $runnerPath -LogPath $resolvedLogPath -Ok $false -Rc 1 -ExpectedOutputs $expectedOutputs -Title $title
        throw "Segment $segmentId returned success JSON but failed verify_stata_execution.ps1. Refusing to continue."
      }

      if ($exitCode -ne 0) {
        Write-OrchestratorLine ("WrapperExitNonZeroButVerified {0} exitCode={1}" -f $segmentId, $exitCode)
      }
      $evidenceLogPath = Save-SegmentLogEvidence -SegmentId $segmentId -LogPath $resolvedLogPath
      if (-not [string]::IsNullOrWhiteSpace($evidenceLogPath) -and $evidenceLogPath -ne $resolvedLogPath) {
        Write-OrchestratorLine ("PersistedLog {0} logPath={1}" -f $segmentId, $evidenceLogPath)
        $resolvedLogPath = $evidenceLogPath
      }
      Record-SegmentResult -SegmentId $segmentId -Start $start -End $end -RunnerPath $runnerPath -LogPath $resolvedLogPath -Ok $true -Rc 0 -ExpectedOutputs $expectedOutputs -Title $title
      Write-OrchestratorLine ("Completed {0} rc=0 logPath={1}" -f $segmentId, $resolvedLogPath)
      Wait-PostSegmentSettle -SegmentId $segmentId -SettleSec $PostSegmentSettleSec
      Invoke-LargeLogGuard -SegmentId $segmentId -LogPath $resolvedLogPath
      continue
    }

    $rcToRecord = if ($null -ne $json -and $null -ne $json.rc) { [int]$json.rc } elseif ($exitCode -ne 0) { $exitCode } else { 1 }
    $logPathToRecord = if ($null -ne $json) { [string]$json.logPath } else { "" }

    $stall = Handle-Stall -SegmentId $segmentId -SegmentLabel $segmentLabel -SegmentStart $segmentStart -ExpectedOutputs $expectedOutputs
    $decision = [string]$stall.Decision
    $progress = $stall.Progress

    if ($decision -eq "not-busy") {
      Record-SegmentResult -SegmentId $segmentId -Start $start -End $end -RunnerPath $runnerPath -LogPath $logPathToRecord -Ok $false -Rc $rcToRecord -ExpectedOutputs $expectedOutputs -Title $title
      Write-OrchestratorLine ("Failed {0} rc={1} reason=wrapper-failed-while-bridge-idle" -f $segmentId, $rcToRecord)
      throw "Segment $segmentId failed while the bridge was idle. Inspect the segment log and runner."
    }

    if ($decision -eq "idle-without-verifiable-success") {
      Record-SegmentResult -SegmentId $segmentId -Start $start -End $end -RunnerPath $runnerPath -LogPath $logPathToRecord -Ok $false -Rc $rcToRecord -ExpectedOutputs $expectedOutputs -Title $title
      Write-OrchestratorLine ("Aborted {0} reason=bridge-became-idle-without-verifiable-wrapper-success" -f $segmentId)
      throw "Segment $segmentId may have progressed, but the wrapper did not return a verifiable success payload. Stop here, inspect evidence, and rerun with a smaller segment if needed."
    }

    $reasonText = if ($decision -eq "busy-without-progress") {
      "busy-without-progress"
    } else {
      "stall-after-extra-wait"
    }

    if ($StallPolicy -eq "reset") {
      Write-OrchestratorLine ("ForceReset {0} reason={1}" -f $segmentId, $reasonText)
      Invoke-BridgeReset
      Start-Sleep -Seconds 2
      Invoke-BridgeVerify
      Invoke-BridgeSmokeTest
    }

    Record-SegmentResult -SegmentId $segmentId -Start $start -End $end -RunnerPath $runnerPath -LogPath $logPathToRecord -Ok $false -Rc $rcToRecord -ExpectedOutputs $expectedOutputs -Title $title
    Write-OrchestratorLine ("Aborted {0} reason={1}" -f $segmentId, $reasonText)

    if ($decision -eq "busy-without-progress") {
      throw "Segment $segmentId is still busy but shows no progress evidence. Anti-stall gate fired; refusing to keep waiting."
    }

    throw "Segment $segmentId is still busy after one extra wait window. Anti-stall gate fired; refusing to continue indefinite waiting."
  }

  $verifyArgs = @{
    RunRoot = $RunRoot
  }
  if ($StrictLedgerCompleteness) {
    $verifyArgs.StrictLedgerCompleteness = $true
  }

  & $verifyScript @verifyArgs
  exit $LASTEXITCODE
} catch {
  Write-Error $_.Exception.Message
  exit 1
}
