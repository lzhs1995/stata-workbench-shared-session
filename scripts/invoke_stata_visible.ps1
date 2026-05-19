# Send Stata code through the patched Stata Workbench visible terminal bridge.
#
# Default policy: run in the human shared Stata Terminal session.
# Use -NoSharedStateMutation, or set STATA_VISIBLE_NO_MUTATION=1, only when the
# user explicitly asks not to touch the visible Workbench session.

param(
  [string]$Code,
  [string]$DoFile,
  [string]$Cwd = "",
  [string]$Label = "Visible Stata Run",
  [int]$TimeoutSec = 300,
  [switch]$TailLog,
  [int]$TailLines = 80,
  [switch]$PlainTextTail,
  [switch]$NoSharedStateMutation,
  [switch]$AllowHttp500Retry,
  [switch]$UseRunFileHandler
)

$repoRoot = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($Cwd)) {
  if (-not [string]::IsNullOrWhiteSpace($env:STATA_WORKBENCH_WORKSPACE)) {
    $Cwd = $env:STATA_WORKBENCH_WORKSPACE
  } else {
    $Cwd = $repoRoot
  }
}
$tempLogDir = Join-Path $Cwd "7_temp\mcp-stata-temp"
$resolvedDoFilePath = $null

function ConvertFrom-SmclTailText {
  param([string]$Text)

  if ([string]::IsNullOrEmpty($Text)) {
    return $Text
  }

  $plain = $Text
  $plain = [regex]::Replace($plain, '\{browse\s+"[^"]*":([^{}]*)\}', '$1')
  $plain = [regex]::Replace($plain, '\{(txt|res|com|err|inp|bf|it|sf|pstd|pmore|phang|p_end|p2line|p2colreset)\}', '')
  $plain = [regex]::Replace($plain, '\{ul\s+(on|off)\}', '')
  $plain = [regex]::Replace($plain, '\{(hline|break|space|col)\s+[^{}]*\}', '')
  $plain = [regex]::Replace($plain, '\{c\s+[^{}]*\}', '')
  $plain = [regex]::Replace($plain, '\{p2colset\s+[^{}]*\}', '')
  $plain = [regex]::Replace($plain, '\{p2col\s+[^{}]*\}', '')
  $plain = [regex]::Replace($plain, '\{help\s+([^{}:]+)(?::[^{}]*)?\}', '$1')
  $plain = [regex]::Replace($plain, '\{[a-zA-Z0-9_]+\}', '')
  return $plain
}

function Set-ObjectPropertyValue {
  param(
    [Parameter(Mandatory = $true)] [object]$Object,
    [Parameter(Mandatory = $true)] [string]$Name,
    [object]$Value
  )

  if ($null -ne $Object.PSObject.Properties[$Name]) {
    $Object.$Name = $Value
  } else {
    $Object | Add-Member -NotePropertyName $Name -NotePropertyValue $Value
  }
}

function Resolve-VisibleLogPath {
  param(
    [datetime]$Since,
    [string]$DoFilePath,
    [string]$CodeText,
    [string]$RunLabel,
    [string[]]$ExtraNeedles = @()
  )

  if (-not (Test-Path -LiteralPath $tempLogDir)) {
    return ""
  }

  $needles = @()
  if (-not [string]::IsNullOrWhiteSpace($DoFilePath)) {
    $needles += $DoFilePath
    $needles += ($DoFilePath -replace '\\', '/')
    $needles += [System.IO.Path]::GetFileName($DoFilePath)
    $needles += [System.IO.Path]::GetFileNameWithoutExtension($DoFilePath)
  }
  if (-not [string]::IsNullOrWhiteSpace($CodeText) -and $CodeText -match 'do\s+"([^"]+)"') {
    $needles += $Matches[1]
    $needles += [System.IO.Path]::GetFileName($Matches[1])
  }
  if (-not [string]::IsNullOrWhiteSpace($RunLabel)) {
    $needles += $RunLabel
  }
  foreach ($needle in @($ExtraNeedles)) {
    if (-not [string]::IsNullOrWhiteSpace([string]$needle)) {
      $needles += [string]$needle
      $needles += ([string]$needle -replace '\\', '/')
      try { $needles += [System.IO.Path]::GetFileName([string]$needle) } catch {}
    }
  }

  $candidates = Get-ChildItem -LiteralPath $tempLogDir -File -Filter "mcp_stata_*.log" -ErrorAction SilentlyContinue |
    Where-Object { $_.LastWriteTime -ge $Since.AddSeconds(-5) } |
    Sort-Object LastWriteTime -Descending

  foreach ($candidate in $candidates) {
    foreach ($needle in ($needles | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique)) {
      try {
        if (Select-String -LiteralPath $candidate.FullName -Pattern ([regex]::Escape($needle)) -Quiet) {
          return $candidate.FullName
        }
      } catch {}
    }
  }

  if (($needles | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }).Count -gt 0) {
    return ""
  }

  $fallback = $candidates | Sort-Object LastWriteTime -Descending | Select-Object -First 1
  if ($fallback) {
    return $fallback.FullName
  }
  return ""
}

function Resolve-CompletedHttp500Result {
  param(
    [datetime]$Since,
    [string]$DoFilePath,
    [string]$CodeText,
    [string]$RunLabel,
    [string]$BodyText
  )

  $freshLogPath = Resolve-VisibleLogPath -Since $Since -DoFilePath $DoFilePath -CodeText $CodeText -RunLabel $RunLabel
  if ([string]::IsNullOrWhiteSpace($freshLogPath) -or -not (Test-Path -LiteralPath $freshLogPath)) {
    return $null
  }

  $item = Get-Item -LiteralPath $freshLogPath -ErrorAction SilentlyContinue
  if (-not $item -or $item.LastWriteTime -lt $Since.AddSeconds(-5)) {
    return $null
  }

  $hasDoneMarker = $false
  try {
    $hasDoneMarker = Select-String -LiteralPath $freshLogPath -Pattern '___CODEX_RUN_DONE_' -Quiet
  } catch {
    $hasDoneMarker = $false
  }
  if (-not $hasDoneMarker -and -not [string]::IsNullOrWhiteSpace($DoFilePath)) {
    try {
      $hasRunnerDone = Select-String -LiteralPath $freshLogPath -Pattern '<<< DONE:' -Quiet
      $hasEndOfDoFile = Select-String -LiteralPath $freshLogPath -Pattern 'end of do-file' -Quiet
      $hasDoneMarker = ($hasRunnerDone -and $hasEndOfDoFile)
    } catch {
      $hasDoneMarker = $false
    }
  }
  if (-not $hasDoneMarker) {
    return $null
  }

  $identityNeedles = @()
  if (-not [string]::IsNullOrWhiteSpace($DoFilePath)) {
    $identityNeedles += $DoFilePath
    $identityNeedles += [System.IO.Path]::GetFileName($DoFilePath)
  }
  if (-not [string]::IsNullOrWhiteSpace($CodeText) -and $CodeText -match 'display\s+as\s+text\s+"([^"]+)"') {
    $identityNeedles += $Matches[1]
  }
  if (-not [string]::IsNullOrWhiteSpace($RunLabel)) {
    $identityNeedles += $RunLabel
  }
  $identityNeedles = $identityNeedles | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) } | Select-Object -Unique
  $hasIdentity = $false
  foreach ($needle in $identityNeedles) {
    try {
      if (Select-String -LiteralPath $freshLogPath -Pattern ([regex]::Escape([string]$needle)) -Quiet) {
        $hasIdentity = $true
        break
      }
    } catch {}
  }
  if (-not $hasIdentity) {
    return $null
  }

  [pscustomobject]@{
    ok = $true
    rc = 0
    logPath = $freshLogPath
    logPathResolvedBy = "invoke_stata_visible_http500_completed_log"
    salvagedAfterHttp500 = $true
    http500BodyPreview = if ([string]::IsNullOrWhiteSpace($BodyText)) { "" } else { $BodyText.Substring(0, [Math]::Min(500, $BodyText.Length)) }
  }
}

function Test-StataCodeMutatesSharedState {
  param([string]$Text)

  $withoutBlockComments = [regex]::Replace($Text, "(?s)/\*.*?\*/", "")
  $lines = $withoutBlockComments -split "`r?`n"
  $active = foreach ($line in $lines) {
    $trim = $line.Trim()
    if ($trim.Length -eq 0) { continue }
    if ($trim.StartsWith("*")) { continue }
    if ($trim.StartsWith("//")) { continue }
    $trim
  }
  $joined = ($active -join "`n").ToLowerInvariant()

  $patterns = @(
    '\bdiscard\b',
    '\bclear\b',
    '\bcls\b',
    '\bset\s+',
    '(^|\s)do\s+',
    '(^|\s)run\s+',
    '(^|\s)use\s+',
    '(^|\s)sysuse\s+',
    '(^|\s)save\s+',
    '\bglobal\s+',
    '\blocal\s+',
    '\bmatrix\s+',
    '\bscalar\s+',
    '\bgen(erate)?\s+',
    '\begen\s+',
    '\breplace\s+',
    '\bdrop\s+',
    '\bkeep\s+',
    '\brename\s+',
    '\brecode\s+',
    '\bmerge\s+',
    '\bappend\s+',
    '\bcollapse\s+',
    '\breshape\s+',
    '\bsort\s+',
    '\bbysort\s+',
    '\bcenter\s+',
    '\bigenerate\s+',
    '\bregress\s+',
    '\blogit\s+',
    '\bprobit\s+',
    '\best(imate|imates)?\s+',
    '\bcoefplot\b',
    '\bgraph\s+(use|display|combine|export|save|drop|close)\b',
    '\bgopen\b',
    '\bputdocx\b'
  )

  foreach ($pattern in $patterns) {
    if ($joined -match $pattern) {
      return $true
    }
  }
  return $false
}

if ([string]::IsNullOrWhiteSpace($Code)) {
  if ([string]::IsNullOrWhiteSpace($DoFile)) {
    Write-Error "Provide either -Code or -DoFile."
    exit 2
  }
  $resolved = Resolve-Path -LiteralPath $DoFile -ErrorAction Stop
  $resolvedDoFilePath = $resolved.Path
  $Code = "do `"$($resolved.Path)`""
}

$noMutation = $NoSharedStateMutation -or $env:STATA_VISIBLE_NO_MUTATION -eq "1"
if ($noMutation -and (Test-StataCodeMutatesSharedState -Text $Code)) {
  Write-Error @"
Refusing to mutate the human shared Stata session because no-mutation mode is enabled.

This visible bridge uses the same Stata session that the human operates in
through Stata Terminal. Mutating commands can change data, globals, estimates,
graphs, or working state and make later selected blocks fail.

Remove -NoSharedStateMutation to run in the shared visible session. For
diagnostics that must not touch the visible session, use invoke_stata_isolated.ps1.
"@
  exit 12
}

$bridgeBase = "http://127.0.0.1:17485"
$extraLogNeedles = @()
$preflightResetAfterHumanFile = $false
$preflightGraphClearAfterHumanFile = $false
$preflightWarmupAfterHumanFile = $false
$preflightWarmupRetriedAfterHttp500 = $false
$allowHttp500Retry = $AllowHttp500Retry -or $env:STATA_VISIBLE_ALLOW_HTTP500_RETRY -eq "1"

function Wait-VisibleBridgeTrueReady {
  param(
    [int]$MaxAttempts = 24,
    [int]$RequiredStableCount = 3
  )

  $local:status = $null
  $local:stableReadyCount = 0
  for ($readyAttempt = 0; $readyAttempt -lt $MaxAttempts; $readyAttempt++) {
    $local:status = Invoke-RestMethod -Uri "$bridgeBase/status" -Method Get -TimeoutSec 5
    if ($local:status.busy -ne $true -and $local:status.postRunBusy -ne $true -and $local:status.trueReady -eq $true) {
      $local:stableReadyCount++
      if ($local:stableReadyCount -ge $RequiredStableCount) {
        return $local:status
      }
    } else {
      $local:stableReadyCount = 0
    }
    Start-Sleep -Milliseconds 500
  }

  return $local:status
}

function Invoke-VisibleBridgeWarmup {
  param(
    [string]$Reason,
    [switch]$RecoverOnHttp500
  )

  $warmupLabel = "CODEX_PREFLIGHT_WARMUP_${Reason}_" + (Get-Date -Format "yyyyMMdd_HHmmss_fff")
  $warmupBody = @{
    code = "display as text `"$warmupLabel`""
    cwd = $Cwd
    label = $warmupLabel
    source = "agent-preflight"
  } | ConvertTo-Json -Compress

  try {
    return Invoke-RestMethod -Uri "$bridgeBase/run-command" -Method Post -ContentType "application/json" -Body $warmupBody -TimeoutSec 120
  } catch {
    $response = $_.Exception.Response
    if ($RecoverOnHttp500 -and $response -and [int]$response.StatusCode -eq 500) {
      Invoke-RestMethod -Uri "$bridgeBase/force-reset" -Method Post -TimeoutSec 20 | Out-Null
      Start-Sleep -Seconds 1
      try { Invoke-RestMethod -Uri "$bridgeBase/graph-clear" -Method Post -TimeoutSec 20 | Out-Null } catch {}
      Start-Sleep -Seconds 1
      $retryStatus = Wait-VisibleBridgeTrueReady -MaxAttempts 30 -RequiredStableCount 3
      if ($retryStatus.busy -eq $true -or $retryStatus.postRunBusy -eq $true -or $retryStatus.trueReady -ne $true) {
        throw "bridge not ready after warmup HTTP 500 recovery"
      }
      $script:preflightWarmupRetriedAfterHttp500 = $true
      return Invoke-RestMethod -Uri "$bridgeBase/run-command" -Method Post -ContentType "application/json" -Body $warmupBody -TimeoutSec 120
    }
    throw
  }
}

try {
  $status = $null
  $stableReadyCount = 0
  for ($readyAttempt = 0; $readyAttempt -lt 20; $readyAttempt++) {
    $status = Invoke-RestMethod `
      -Uri "$bridgeBase/status" `
      -Method Get `
      -TimeoutSec 5
    if ($status.busy -ne $true -and $status.postRunBusy -ne $true -and $status.trueReady -eq $true) {
      $stableReadyCount++
      if ($stableReadyCount -ge 3) { break }
    } else {
      $stableReadyCount = 0
    }
    Start-Sleep -Milliseconds 500
  }
} catch {
  Write-Error "Failed to call Stata visible bridge status endpoint: $($_.Exception.Message)"
  exit 1
}

if ($status.busy -eq $true) {
  $current = $status.current
  $labelText = if ($current -and $current.label) { $current.label } else { "unknown" }
  $elapsedText = if ($current -and $null -ne $current.elapsedSec) { "$($current.elapsedSec)s" } else { "unknown" }
  $previewText = if ($current -and $current.codePreview) { $current.codePreview } else { "" }
  Write-Error "Stata visible session is busy ($($status.status)): $labelText, elapsed=$elapsedText. Refusing to queue. $previewText"
  exit 9
}

<#
After /panic-kill the bridge intentionally reports trueReady:false with
force-reset-needs-smoke. Permit only a one-line display smoke through this
gate; productive commands must still wait for true READY.
#>
$isRecoverySmoke = (
  $status.postRunBusy -ne $true -and
  $status.trueReady -ne $true -and
  [string]$status.notReadyReason -match 'force-reset-needs-smoke' -and
  [string]$Label -match '(?i)smoke' -and
  [string]$Code -match '^\s*display\s+as\s+text\s+"[^"]*smoke[^"]*"\s*$'
)

if (($status.postRunBusy -eq $true -or $status.trueReady -ne $true) -and -not $isRecoverySmoke) {
  Write-Error "Stata visible session is not true READY: busy=$($status.busy), postRunBusy=$($status.postRunBusy), trueReady=$($status.trueReady), reason=$($status.notReadyReason)"
  exit 9
}

$graphPanel = $status.graphPanel
$recentHumanInline = $false
if ($graphPanel) {
  $graphText = @(
    $graphPanel.sourceRewriteScope,
    $graphPanel.lastGraphExportMode,
    $graphPanel.lastBatchSource,
    $graphPanel.lastGraphCaptureOwner,
    $graphPanel.readinessReason
  ) | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) }
  $graphText = $graphText -join " "
}
if ($graphPanel -and $graphText -match 'human-file-inline-snapshot|manual-selection-inline-snapshot|visible-bridge-inline-snapshot|inline-snapshot|graph-clear-complete') {
  $recentHumanInline = $true
}

if ($recentHumanInline) {
  try {
    try {
      Invoke-RestMethod -Uri "$bridgeBase/graph-clear" -Method Post -TimeoutSec 20 | Out-Null
      $preflightGraphClearAfterHumanFile = $true
    } catch {
      Write-Warning "Human-file inline-snapshot preflight graph-clear failed: $($_.Exception.Message)"
    }
    $status = Wait-VisibleBridgeTrueReady -MaxAttempts 30 -RequiredStableCount 3
    if ($status.busy -eq $true -or $status.postRunBusy -eq $true -or $status.trueReady -ne $true) {
      Write-Error "Stata visible session did not become true READY before human-file inline-snapshot preflight warmup: busy=$($status.busy), postRunBusy=$($status.postRunBusy), trueReady=$($status.trueReady), reason=$($status.notReadyReason)"
      exit 9
    }
    try {
      $warmup = Invoke-VisibleBridgeWarmup -Reason "after_inline_snapshot"
    } catch {
      Invoke-RestMethod -Uri "$bridgeBase/force-reset" -Method Post -TimeoutSec 20 | Out-Null
      Start-Sleep -Seconds 1
      try { Invoke-RestMethod -Uri "$bridgeBase/graph-clear" -Method Post -TimeoutSec 20 | Out-Null } catch {}
      Start-Sleep -Seconds 1
      $preflightResetAfterHumanFile = $true
      $status = Wait-VisibleBridgeTrueReady -MaxAttempts 30 -RequiredStableCount 3
      if ($status.busy -eq $true -or $status.postRunBusy -eq $true -or $status.trueReady -ne $true) {
        Write-Error "Stata visible session did not become true READY after human-file inline-snapshot fallback reset: busy=$($status.busy), postRunBusy=$($status.postRunBusy), trueReady=$($status.trueReady), reason=$($status.notReadyReason)"
        exit 9
      }
      $warmup = Invoke-VisibleBridgeWarmup -Reason "after_inline_snapshot_reset" -RecoverOnHttp500
    }
    if ($warmup.ok -ne $true -or ($null -ne $warmup.rc -and $warmup.rc -ne 0)) {
      Write-Error "Human-file inline-snapshot preflight warmup failed: ok=$($warmup.ok), rc=$($warmup.rc)"
      exit 9
    }
    $preflightWarmupAfterHumanFile = $true
    $status = Wait-VisibleBridgeTrueReady -MaxAttempts 30 -RequiredStableCount 3
    if ($status.busy -eq $true -or $status.postRunBusy -eq $true -or $status.trueReady -ne $true) {
      Write-Error "Stata visible session did not become true READY after human-file inline-snapshot preflight warmup: busy=$($status.busy), postRunBusy=$($status.postRunBusy), trueReady=$($status.trueReady), reason=$($status.notReadyReason)"
      exit 9
    }
  } catch {
    Write-Error "Failed human-file inline-snapshot preflight reset before visible bridge call: $($_.Exception.Message)"
    exit 1
  }
}

# --- Audit log: record start of bridge call (tool-level enforcement, fires for any caller) ---
$_auditDir = Join-Path $Cwd "7_temp"
$_auditLog = Join-Path $_auditDir "stata-execution-audit.jsonl"
$_startDate = Get-Date
$_startTime = $_startDate.ToString("o")
$_preEntry = [ordered]@{
  event       = "start"
  startTime   = $_startTime
  label       = $Label
  codePreview = ($Code.Substring(0, [Math]::Min(200, $Code.Length)))
  callerPid   = $PID
} | ConvertTo-Json -Compress
try {
  New-Item -ItemType Directory -Force -Path $_auditDir | Out-Null
  Add-Content -LiteralPath $_auditLog -Value $_preEntry -Encoding UTF8 -ErrorAction SilentlyContinue
} catch {}

$body = @{
  code = $Code
  cwd = $Cwd
  label = $Label
  source = "agent"
} | ConvertTo-Json -Compress

try {
  if ($UseRunFileHandler) {
    if ([string]::IsNullOrWhiteSpace($resolvedDoFilePath)) {
      throw "-UseRunFileHandler requires -DoFile so the Workbench Run File handler can bind to a real file."
    }
    # codex patch v7.96: agent do-file wrapper can route through real Workbench Run File handler to avoid visible-bridge false success on huge MI/document runs.
    $debugUri = "$bridgeBase/debug-run-file?disk=1&path=$([uri]::EscapeDataString($resolvedDoFilePath))"
    $debugResult = Invoke-RestMethod -Uri $debugUri -Method Post -TimeoutSec $TimeoutSec
    if ($debugResult.humanFileDebug -and $debugResult.humanFileDebug.path) {
      $extraLogNeedles += [string]$debugResult.humanFileDebug.path
    }
    $result = [pscustomobject]@{
      ok = ($debugResult.ok -eq $true)
      rc = if ($debugResult.ok -eq $true) { 0 } else { 11003 }
      ran = $debugResult.ran
      runFileHandler = $true
      path = $debugResult.path
      humanFileDebug = $debugResult.humanFileDebug
      graphPanel = $debugResult.graphPanel
      raw = $debugResult
    }
  } else {
    $result = Invoke-RestMethod `
      -Uri "$bridgeBase/run-command" `
      -Method Post `
      -ContentType "application/json" `
      -Body $body `
      -TimeoutSec $TimeoutSec
  }
} catch {
  $response = $_.Exception.Response
  $bodyText = ""
  if ($response) {
    try {
      $reader = [System.IO.StreamReader]::new($response.GetResponseStream())
      $bodyText = $reader.ReadToEnd()
      $reader.Dispose()
    } catch {}
  }
  if ($response -and [int]$response.StatusCode -eq 409) {
    Write-Error "Stata visible session is busy; bridge returned HTTP 409. Refusing to queue. $bodyText"
    exit 9
  }
  if ($response -and [int]$response.StatusCode -eq 500) {
    $completedHttp500Result = Resolve-CompletedHttp500Result -Since $_startDate -DoFilePath $resolvedDoFilePath -CodeText $Code -RunLabel $Label -BodyText $bodyText
    if ($completedHttp500Result) {
      $result = $completedHttp500Result
    } elseif ($allowHttp500Retry) {
    try {
      Invoke-RestMethod -Uri "$bridgeBase/force-reset" -Method Post -TimeoutSec 20 | Out-Null
      Start-Sleep -Seconds 1
      try { Invoke-RestMethod -Uri "$bridgeBase/graph-clear" -Method Post -TimeoutSec 20 | Out-Null } catch {}
      Start-Sleep -Seconds 1
      $retryStatus = Wait-VisibleBridgeTrueReady -MaxAttempts 30 -RequiredStableCount 3
      if ($retryStatus.busy -eq $true -or $retryStatus.postRunBusy -eq $true) {
        throw "bridge still busy after HTTP 500 recovery"
      }
      $result = Invoke-RestMethod `
        -Uri "$bridgeBase/run-command" `
        -Method Post `
        -ContentType "application/json" `
        -Body $body `
        -TimeoutSec $TimeoutSec
      Set-ObjectPropertyValue -Object $result -Name "retriedAfterHttp500" -Value $true
    } catch {
        $completedRetryResult = Resolve-CompletedHttp500Result -Since $_startDate -DoFilePath $resolvedDoFilePath -CodeText $Code -RunLabel $Label -BodyText $bodyText
        if ($completedRetryResult) {
          Set-ObjectPropertyValue -Object $completedRetryResult -Name "salvagedAfterHttp500RetryFailure" -Value $true
          $result = $completedRetryResult
        } else {
          Write-Error "Failed to call Stata visible bridge after HTTP 500 recovery retry: $($_.Exception.Message) $bodyText"
          exit 1
        }
      }
    } else {
      Write-Error "Stata visible bridge returned HTTP 500 after execution started or recovery changed state. Refusing to retry the original command automatically. $bodyText"
      exit 1
    }
  } else {
  Write-Error "Failed to call Stata visible bridge: $($_.Exception.Message) $bodyText"
  exit 1
  }
}

if ($result.ok -eq $true -and [string]::IsNullOrWhiteSpace([string]$result.logPath)) {
  $fallbackLogPath = Resolve-VisibleLogPath -Since $_startDate -DoFilePath $resolvedDoFilePath -CodeText $Code -RunLabel $Label -ExtraNeedles $extraLogNeedles
  if ([string]::IsNullOrWhiteSpace($fallbackLogPath) -and $UseRunFileHandler -and (Test-Path -LiteralPath $tempLogDir)) {
    $largestFreshLog = Get-ChildItem -LiteralPath $tempLogDir -File -Filter "mcp_stata_*.log" -ErrorAction SilentlyContinue |
      Where-Object { $_.LastWriteTime -ge $_startDate.AddSeconds(-5) -and $_.Length -gt 8192 } |
      Sort-Object Length -Descending |
      Select-Object -First 1
    if ($largestFreshLog) {
      $fallbackLogPath = $largestFreshLog.FullName
      Set-ObjectPropertyValue -Object $result -Name "logPathResolvedBy" -Value "invoke_stata_visible_runfile_largest_fresh_log"
    }
  }
  if (-not [string]::IsNullOrWhiteSpace($fallbackLogPath)) {
    Set-ObjectPropertyValue -Object $result -Name "logPath" -Value $fallbackLogPath
    if ([string]::IsNullOrWhiteSpace([string]$result.logPathResolvedBy)) {
      Set-ObjectPropertyValue -Object $result -Name "logPathResolvedBy" -Value "invoke_stata_visible_fallback"
    }
  } else {
    Set-ObjectPropertyValue -Object $result -Name "logPathResolveWarning" -Value "No fresh mcp_stata_*.log found after run start."
  }
}

if ($preflightResetAfterHumanFile) {
  Set-ObjectPropertyValue -Object $result -Name "preflightResetAfterInlineSnapshot" -Value $true
}
if ($preflightGraphClearAfterHumanFile) {
  Set-ObjectPropertyValue -Object $result -Name "preflightGraphClearAfterInlineSnapshot" -Value $true
}
if ($preflightWarmupAfterHumanFile) {
  Set-ObjectPropertyValue -Object $result -Name "preflightWarmupAfterInlineSnapshot" -Value $true
}
if ($preflightWarmupRetriedAfterHttp500) {
  Set-ObjectPropertyValue -Object $result -Name "preflightWarmupRetriedAfterHttp500" -Value $true
}

$result | ConvertTo-Json -Depth 6

# --- Audit log: record completion (enables verify_stata_execution.ps1 to detect fabrication) ---
$_postEntry = [ordered]@{
  event     = "complete"
  startTime = $_startTime
  endTime   = (Get-Date -Format "o")
  label     = $Label
  ok        = [bool]($result.ok)
  rc        = if ($null -ne $result.rc) { $result.rc } else { $null }
  logPath   = $result.logPath
} | ConvertTo-Json -Compress
try { Add-Content -LiteralPath $_auditLog -Value $_postEntry -Encoding UTF8 -ErrorAction SilentlyContinue } catch {}

if ($TailLog -and $result.logPath -and (Test-Path -LiteralPath $result.logPath)) {
  Write-Host ""
  $tailLabel = if ($PlainTextTail) { "plain-text Stata log tail" } else { "Stata log tail" }
  Write-Host "---- ${tailLabel}: $($result.logPath) ----" -ForegroundColor Cyan
  $tailContent = Get-Content -LiteralPath $result.logPath -Tail $TailLines
  if ($PlainTextTail) {
    $tailContent | ForEach-Object { ConvertFrom-SmclTailText -Text $_ }
  } else {
    $tailContent
  }
}

if ($result.ok -ne $true) {
  exit 1
}
if ($null -ne $result.rc -and $result.rc -ne 0) {
  exit $result.rc
}

exit 0
