# verify_stata_execution.ps1
#
# Reads the audit log written by invoke_stata_visible.ps1 and verifies that the
# most recent Stata execution was real (bridge-routed) and not fabricated by a
# sub-agent reporting pre-existing output files as fresh.
#
# Usage:
#   & .\verify_stata_execution.ps1                  # check last entry
#   & .\verify_stata_execution.ps1 -Last 3          # check last 3 entries
#   & .\verify_stata_execution.ps1 -Label "seg01"   # filter by label pattern
#   & .\verify_stata_execution.ps1 -OutputFile "path\to\output.dta"
#   & .\verify_stata_execution.ps1 -RunRoot "C:\path\to\reexec_xxx"
#   & .\verify_stata_execution.ps1 -RunRoot "C:\path\to\reexec_xxx" -StrictLedgerCompleteness
#
# Exit codes:
#   0 = VERIFIED (audit log confirms bridge call with ok=true, rc=0)
#   1 = FABRICATED or UNVERIFIABLE (no audit entry, missing timestamps, or file predates run)
#   2 = FAILED (bridge returned ok=false or non-zero rc — execution attempted but errored)

param(
  [int]$Last = 1,
  [string]$Label = "",
  [string]$OutputFile = "",
  [string]$RunRoot = "",
  [switch]$StrictLedgerCompleteness,
  [switch]$Quiet
)

if ($RunRoot) {
  if (-not (Test-Path -LiteralPath $RunRoot)) {
    Write-Warning "Run root not found: $RunRoot"
    exit 1
  }

  $resultsPath = Join-Path $RunRoot "results.json"
  $orchestratorPath = Join-Path $RunRoot "orchestrator.log"

  if (-not (Test-Path -LiteralPath $resultsPath)) {
    Write-Warning "Run-root verification failed: missing results.json"
    exit 1
  }
  if (-not (Test-Path -LiteralPath $orchestratorPath)) {
    Write-Warning "Run-root verification failed: missing orchestrator.log"
    exit 1
  }

  try {
    $resultsRaw = Get-Content -LiteralPath $resultsPath -Raw -Encoding UTF8
    $resultsObj = $resultsRaw | ConvertFrom-Json
  } catch {
    Write-Warning "Run-root verification failed: results.json is not valid JSON"
    exit 1
  }

  $segments = @()
  if ($resultsObj -is [System.Array]) {
    $segments = @($resultsObj)
  } elseif ($null -ne $resultsObj.segments) {
    $segments = @($resultsObj.segments)
  }

  if ($segments.Count -eq 0) {
    Write-Warning "Run-root verification failed: no executed segments found in results.json"
    Write-Warning "A module plan or empty segments array is not proof of execution."
    exit 1
  }

  $missingEvidence = @()
  $badRc = @()
  $incompleteExpectedOutputs = @()
  foreach ($segment in $segments) {
    $segmentId = [string]$segment.id
    if ([string]::IsNullOrWhiteSpace($segmentId)) {
      $missingEvidence += "<missing-id>"
      continue
    }
    if ([string]::IsNullOrWhiteSpace([string]$segment.logPath)) {
      $missingEvidence += $segmentId
    } elseif (-not (Test-Path -LiteralPath ([string]$segment.logPath))) {
      $missingEvidence += "$segmentId(log-missing)"
    }
    if ($null -eq $segment.ok -or $segment.ok -ne $true) {
      $badRc += $segmentId
    }
    if ($null -eq $segment.rc -or [int]$segment.rc -ne 0) {
      $badRc += $segmentId
    }

    $runnerPath = $null
    if (-not [string]::IsNullOrWhiteSpace([string]$segment.runnerPath)) {
      $runnerPath = [string]$segment.runnerPath
    } else {
      $fallbackRunner = Join-Path $RunRoot ($segmentId + ".do")
      if (Test-Path -LiteralPath $fallbackRunner) {
        $runnerPath = $fallbackRunner
      }
    }

    if ($StrictLedgerCompleteness -and ([string]::IsNullOrWhiteSpace($runnerPath) -or -not (Test-Path -LiteralPath $runnerPath))) {
      $missingEvidence += "$segmentId(runner-missing)"
      continue
    }

    if ($runnerPath -and (Test-Path -LiteralPath $runnerPath)) {
      $runnerLines = Get-Content -LiteralPath $runnerPath -Encoding UTF8
      $declaredOutputs = @($segment.expectedOutputs | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) })
      $inferredOutputs = New-Object System.Collections.Generic.HashSet[string]
      $logicalLines = New-Object System.Collections.Generic.List[string]
      $buffer = ""
      $inBlockComment = $false
      foreach ($line in $runnerLines) {
        $working = $line
        while ($true) {
          if ($inBlockComment) {
            $endIdx = $working.IndexOf('*/')
            if ($endIdx -ge 0) {
              $working = $working.Substring($endIdx + 2)
              $inBlockComment = $false
              continue
            } else {
              $working = ""
              break
            }
          } else {
            $startIdx = $working.IndexOf('/*')
            if ($startIdx -ge 0) {
              $endIdx = $working.IndexOf('*/', $startIdx + 2)
              if ($endIdx -ge 0) {
                $working = $working.Substring(0, $startIdx) + $working.Substring($endIdx + 2)
                continue
              } else {
                $working = $working.Substring(0, $startIdx)
                $inBlockComment = $true
              }
            }
            break
          }
        }

        $trimmedRight = $working.TrimEnd()
        if ([string]::IsNullOrWhiteSpace($trimmedRight)) { continue }
        if ($trimmedRight -match '^\s*(\*|//)') { continue }
        if ($trimmedRight -match '///\s*$') {
          $buffer += ($trimmedRight -replace '///\s*$', '') + " "
          continue
        }
        $buffer += $trimmedRight
        if (-not [string]::IsNullOrWhiteSpace($buffer)) {
          [void]$logicalLines.Add($buffer)
        }
        $buffer = ""
      }
      if (-not [string]::IsNullOrWhiteSpace($buffer)) {
        [void]$logicalLines.Add($buffer)
      }

      foreach ($line in $logicalLines) {
        if ($line -match '^\s*save\s+"([^"]+\.(?:dta|csv))"' -or
            $line -match '^\s*export\s+delimited\b.*\busing\s+"([^"]+\.(?:csv|txt))"') {
          [void]$inferredOutputs.Add($Matches[1])
        }
      }
      if ($inferredOutputs.Count -gt 0 -and $declaredOutputs.Count -lt $inferredOutputs.Count) {
        $incompleteExpectedOutputs += "$segmentId(declared=$($declaredOutputs.Count), inferred=$($inferredOutputs.Count))"
      }
    }
  }

  if ($missingEvidence.Count -gt 0) {
    Write-Warning ("Run-root verification failed: missing per-segment evidence for: " + (($missingEvidence | Select-Object -Unique) -join ", "))
    exit 1
  }
  if ($badRc.Count -gt 0) {
    Write-Warning ("Run-root verification failed: non-success status detected for: " + (($badRc | Select-Object -Unique) -join ", "))
    exit 2
  }
  if ($incompleteExpectedOutputs.Count -gt 0) {
    $message = "Run-root ledger completeness warning: expectedOutputs may be incomplete for " + (($incompleteExpectedOutputs | Select-Object -Unique) -join ", ")
    if ($StrictLedgerCompleteness) {
      Write-Warning $message
      exit 1
    } elseif (-not $Quiet) {
      Write-Warning $message
    }
  }

  $orchLines = Get-Content -LiteralPath $orchestratorPath -Encoding UTF8
  foreach ($segment in $segments) {
    $segmentId = [string]$segment.id
    $idPattern = [regex]::Escape($segmentId)
    $hasPreparing = @($orchLines | Where-Object { $_ -match "Preparing\s+$idPattern\b" }).Count -gt 0
    $hasRunning = @($orchLines | Where-Object { $_ -match "Running\s+$idPattern\b" }).Count -gt 0
    $hasCompleted = @($orchLines | Where-Object { $_ -match "Completed\s+$idPattern\b" }).Count -gt 0
    if (-not ($hasPreparing -and $hasRunning -and $hasCompleted)) {
      Write-Warning "Run-root verification failed: orchestrator.log is missing a full Preparing/Running/Completed trail for segment $segmentId"
      exit 1
    }
  }

  $runStart = $null
  foreach ($line in $orchLines) {
    if ($line -match '^\[(?<ts>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})\]') {
      try {
        $runStart = [datetime]::ParseExact($Matches['ts'], 'yyyy-MM-dd HH:mm:ss', $null)
        break
      } catch {}
    }
  }

  if (-not $runStart) {
    Write-Warning "Run-root verification failed: could not parse run start time from orchestrator.log"
    exit 1
  }

  $freshOutputCount = 0
  $checkedOutputCount = 0
  foreach ($segment in $segments) {
    foreach ($expected in @($segment.expectedOutputs)) {
      if ([string]::IsNullOrWhiteSpace([string]$expected)) { continue }
      if (Test-Path -LiteralPath $expected) {
        $checkedOutputCount++
        if ((Get-Item -LiteralPath $expected).LastWriteTime -ge $runStart) {
          $freshOutputCount++
        }
      }
    }
  }

  if ($checkedOutputCount -eq 0) {
    Write-Warning "Run-root verification failed: no expected output files could be resolved from the executed-segment ledger"
    exit 1
  }
  if ($freshOutputCount -eq 0) {
    Write-Warning "Run-root verification failed: every checked expected output predates the run start"
    Write-Warning "This usually means the agent reported pre-existing files as fresh outputs."
    exit 1
  }

  if ($OutputFile) {
    if (-not (Test-Path -LiteralPath $OutputFile)) {
      Write-Warning "Run-root verification failed: requested OutputFile not found: $OutputFile"
      exit 1
    }
    $fileTime = (Get-Item -LiteralPath $OutputFile).LastWriteTime
    if ($fileTime -lt $runStart) {
      Write-Warning "Run-root verification failed: OutputFile predates run start: $OutputFile"
      exit 1
    }
  }

  if (-not $Quiet) {
    Write-Host ""
    Write-Host "=== Run Root Verification ===" -ForegroundColor Cyan
    Write-Host "  RunRoot:           $RunRoot"
    Write-Host "  Segments:          $($segments.Count)"
    Write-Host "  RunStart:          $runStart"
    Write-Host "  Checked outputs:   $checkedOutputCount"
    Write-Host "  Fresh outputs:     $freshOutputCount"
    Write-Host "  RESULT:            VERIFIED — run-root evidence bundle is complete" -ForegroundColor Green
    Write-Host ""
  }

  exit 0
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$workspaceRoot = if (-not [string]::IsNullOrWhiteSpace($env:STATA_WORKBENCH_WORKSPACE)) { $env:STATA_WORKBENCH_WORKSPACE } else { $repoRoot }
$auditLog = Join-Path $workspaceRoot "7_temp\stata-execution-audit.jsonl"

if (-not (Test-Path -LiteralPath $auditLog)) {
  Write-Warning "No audit log found at: $auditLog"
  Write-Warning "This means invoke_stata_visible.ps1 was not called through the patched bridge, or 7_temp does not exist."
  exit 1
}

$lines = Get-Content -LiteralPath $auditLog -Encoding UTF8
$entries = foreach ($line in $lines) {
  $t = $line.Trim()
  if ($t -ne "") {
    try { $t | ConvertFrom-Json } catch {}
  }
}

if (-not $Label -and $Last -eq 1) {
  $latestEvent = $entries | Select-Object -Last 1
  if ($null -eq $latestEvent) {
    Write-Warning "Audit log is empty or unreadable."
    exit 1
  }
  if ($latestEvent.event -ne "complete") {
    Write-Warning "Latest audit event is '$($latestEvent.event)', not 'complete'."
    Write-Warning "The newest visible Stata run started but did not finish cleanly; refusing to certify an older run as success."
    exit 1
  }
}

# Filter to 'complete' events only
$completes = @($entries | Where-Object { $_.event -eq "complete" })

if ($completes.Count -eq 0) {
  Write-Warning "No 'complete' entries in audit log — only 'start' entries found."
  Write-Warning "This suggests a run was started but never returned (crash, timeout, or fabrication)."
  exit 1
}

# Optionally filter by label pattern
if ($Label) {
  $filtered = @($completes | Where-Object { $_.label -like "*$Label*" })
  if ($filtered.Count -eq 0) {
    Write-Warning "No complete entries matching label pattern '$Label' found in audit log."
    exit 1
  }
  $completes = $filtered
}

$recent = @($completes | Select-Object -Last $Last)
$allVerified = $true

foreach ($entry in $recent) {
  $startDt = try { [DateTime]::Parse($entry.startTime) } catch { $null }
  $endDt   = try { [DateTime]::Parse($entry.endTime)   } catch { $null }
  $duration = if ($startDt -and $endDt) { ($endDt - $startDt).TotalSeconds } else { $null }

  if (-not $Quiet) {
    Write-Host ""
    Write-Host "=== Audit Entry: $($entry.label) ===" -ForegroundColor Cyan
    Write-Host "  Start:    $($entry.startTime)"
    Write-Host "  End:      $($entry.endTime)"
    if ($null -ne $duration) { Write-Host "  Duration: $([Math]::Round($duration, 1))s" }
    Write-Host "  ok:       $($entry.ok)"
    Write-Host "  rc:       $($entry.rc)"
    if ($entry.logPath) { Write-Host "  logPath:  $($entry.logPath)" }
  }

  if ($entry.ok -eq $true -and ($null -eq $entry.rc -or $entry.rc -eq 0)) {
    if (-not $Quiet) {
      Write-Host "  RESULT:   VERIFIED — bridge returned ok=true, rc=0" -ForegroundColor Green
    }
  } elseif ($entry.ok -eq $true) {
    if (-not $Quiet) {
      Write-Host "  RESULT:   VERIFIED WITH WARNINGS — ok=true but rc=$($entry.rc)" -ForegroundColor Yellow
    }
    $allVerified = $false
  } else {
    if (-not $Quiet) {
      Write-Host "  RESULT:   EXECUTION FAILED — ok=$($entry.ok), rc=$($entry.rc)" -ForegroundColor Red
    }
    $allVerified = $false
  }
}

# Optional: check OutputFile timestamp against start of earliest entry in $recent
if ($OutputFile -and (Test-Path -LiteralPath $OutputFile)) {
  $firstStart = $recent | ForEach-Object { try { [DateTime]::Parse($_.startTime) } catch { $null } } | Where-Object { $_ } | Sort-Object | Select-Object -First 1
  $fileTime = (Get-Item -LiteralPath $OutputFile).LastWriteTime

  if (-not $Quiet) {
    Write-Host ""
    Write-Host "=== Output File Timestamp Check ===" -ForegroundColor Cyan
    Write-Host "  File:       $OutputFile"
    Write-Host "  FileTime:   $fileTime"
    Write-Host "  RunStart:   $firstStart"
  }

  if ($firstStart -and $fileTime -lt $firstStart) {
    Write-Host "  RESULT:     FABRICATED — file LastWriteTime ($fileTime) predates run start ($firstStart)" -ForegroundColor Red
    Write-Host "              This file was NOT produced by the current run. Sub-agent fabrication detected." -ForegroundColor Red
    exit 1
  } elseif ($firstStart) {
    if (-not $Quiet) {
      Write-Host "  RESULT:     TIMESTAMP OK — file was written after run start" -ForegroundColor Green
    }
  }
} elseif ($OutputFile) {
  Write-Warning "Requested OutputFile not found: $OutputFile"
  exit 1
}

if (-not $Quiet) { Write-Host "" }

if ($allVerified) { exit 0 } else { exit 2 }
