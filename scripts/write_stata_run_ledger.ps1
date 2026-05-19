# Canonical helper for segmented visible Stata run ledgers.
# It reduces ad-hoc results.json rewriting by giving agents one append-oriented path.
#
# Usage:
#   # initialize a run root
#   & .\write_stata_run_ledger.ps1 -RunRoot "C:\...\reexec_xxx" -ScriptPath "C:\...\target.do" -Init
#
#   # append orchestrator lines
#   & .\write_stata_run_ledger.ps1 -RunRoot "C:\...\reexec_xxx" -OrchestratorLine "Preparing seg01"
#
#   # append a segment result
#   & .\write_stata_run_ledger.ps1 -RunRoot "C:\...\reexec_xxx" -SegmentId "seg01" -Start 1 -End 828 `
#       -RunnerPath "C:\...\seg01.do" -LogPath "C:\...\mcp_stata_x.log" -Ok $true -Rc 0 `
#       -ExpectedOutputs @("C:\...\out1.dta","C:\...\out1.csv")
#
# Default behavior is append-only. Replacing an existing segment requires -ReplaceExisting.

param(
  [Parameter(Mandatory = $true)]
  [string]$RunRoot,
  [string]$ScriptPath,
  [switch]$Init,
  [string]$OrchestratorLine,
  [string]$SegmentId,
  [int]$Start,
  [int]$End,
  [string]$RunnerPath,
  [string]$LogPath,
  [Nullable[bool]]$Ok,
  [Nullable[int]]$Rc,
  [string[]]$ExpectedOutputs = @(),
  [string]$Title,
  [switch]$ReplaceExisting
)

$ErrorActionPreference = "Stop"

function Get-ResultsPath {
  Join-Path $RunRoot "results.json"
}

function Get-OrchestratorPath {
  Join-Path $RunRoot "orchestrator.log"
}

function Read-Ledger {
  $resultsPath = Get-ResultsPath
  if (-not (Test-Path -LiteralPath $resultsPath)) {
    return [pscustomobject]@{
      script = $ScriptPath
      created = (Get-Date).ToString("o")
      segments = @()
    }
  }
  return (Get-Content -LiteralPath $resultsPath -Raw -Encoding UTF8 | ConvertFrom-Json)
}

function Write-Ledger($ledger) {
  $resultsPath = Get-ResultsPath
  $json = $ledger | ConvertTo-Json -Depth 8
  [System.IO.File]::WriteAllText($resultsPath, $json, [System.Text.UTF8Encoding]::new($false))
}

if (-not (Test-Path -LiteralPath $RunRoot)) {
  New-Item -ItemType Directory -Path $RunRoot -Force | Out-Null
}

if ($Init) {
  $ledger = [pscustomobject]@{
    script = $ScriptPath
    created = (Get-Date).ToString("o")
    segments = @()
  }
  Write-Ledger $ledger
}

if (-not [string]::IsNullOrWhiteSpace($OrchestratorLine)) {
  $orchPath = Get-OrchestratorPath
  $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
  Add-Content -LiteralPath $orchPath -Value ("[{0}] {1}" -f $timestamp, $OrchestratorLine) -Encoding UTF8
}

if (-not [string]::IsNullOrWhiteSpace($SegmentId)) {
  $ledger = Read-Ledger
  if ($null -eq $ledger.segments) {
    $ledger | Add-Member -NotePropertyName segments -NotePropertyValue @() -Force
  }

  if ([string]::IsNullOrWhiteSpace($RunnerPath)) {
    $RunnerPath = Join-Path $RunRoot ($SegmentId + ".do")
  }

  $existing = @($ledger.segments | Where-Object { $_.id -eq $SegmentId })
  if ($existing.Count -gt 0 -and -not $ReplaceExisting) {
    throw "Segment '$SegmentId' already exists in results.json. Use -ReplaceExisting to overwrite explicitly."
  }

  $segment = [pscustomobject]@{
    id = $SegmentId
    start = $Start
    end = $End
    runnerPath = $RunnerPath
    logPath = $LogPath
    ok = if ($null -ne $Ok) { [bool]$Ok } else { $null }
    rc = if ($null -ne $Rc) { [int]$Rc } else { $null }
    expectedOutputs = @($ExpectedOutputs)
  }
  if (-not [string]::IsNullOrWhiteSpace($Title)) {
    $segment | Add-Member -NotePropertyName title -NotePropertyValue $Title -Force
  }

  if ($existing.Count -gt 0) {
    $newSegments = @()
    foreach ($s in @($ledger.segments)) {
      if ($s.id -eq $SegmentId) {
        $newSegments += $segment
      } else {
        $newSegments += $s
      }
    }
    $ledger.segments = $newSegments
  } else {
    $ledger.segments += $segment
  }

  Write-Ledger $ledger
}
