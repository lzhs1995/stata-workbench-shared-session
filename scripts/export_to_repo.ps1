# export_to_repo.ps1
#
# Preview or apply a narrow workspace -> repository export for public runtime scripts.
# Default mode is -Preview. Use -Apply to copy changed/missing whitelist files.
# The extension bundle is intentionally excluded and must be checked separately.

param(
  [string]$WorkspaceRoot = "",
  [string]$RepoRoot = "",
  [switch]$Preview,
  [switch]$Apply
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$DefaultWorkspaceName = -join ([char[]](0x5f00, 0x9898, 0x62a5, 0x544a))
if ([string]::IsNullOrWhiteSpace($WorkspaceRoot)) {
  $WorkspaceRoot = Join-Path (Join-Path $env:USERPROFILE "Desktop") $DefaultWorkspaceName
}

if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
  $RepoRoot = Split-Path -Parent $PSScriptRoot
}

if ($Preview -and $Apply) {
  throw "Use either -Preview or -Apply, not both."
}
if (-not $Preview -and -not $Apply) {
  $Preview = $true
}

$WorkspaceRoot = (Resolve-Path -LiteralPath $WorkspaceRoot).Path
$RepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path
$RepoScripts = Join-Path $RepoRoot "scripts"

$whitelist = @(
  "cleanup_mcp_stata_processes.ps1",
  "invoke_stata_segmented_visible.ps1",
  "invoke_stata_visible.ps1",
  "invoke_stata_visible_safe.ps1",
  "open_stata_vscode_fast.cmd",
  "open_stata_vscode_fast.ps1",
  "open_stata_vscode_hosted.ps1",
  "panic_kill_stata_chain.ps1",
  "patch_manager.js",
  "stata_patch.ps1",
  "unblock_stata_terminal.ps1",
  "verify_stata_execution.ps1",
  "write_stata_run_ledger.ps1"
)

function Get-Sha256OrNull {
  param([string]$Path)
  if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
    return $null
  }
  return (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash.ToLowerInvariant()
}

function Short-Hash {
  param([AllowNull()][string]$Hash)
  if ([string]::IsNullOrWhiteSpace($Hash)) {
    return ""
  }
  return $Hash.Substring(0, [Math]::Min(12, $Hash.Length))
}

function Assert-UnderRoot {
  param(
    [string]$Root,
    [string]$Path,
    [string]$Label
  )
  $resolvedRoot = (Resolve-Path -LiteralPath $Root).Path.TrimEnd('\') + '\'
  $resolvedPath = if (Test-Path -LiteralPath $Path) {
    (Resolve-Path -LiteralPath $Path).Path
  } else {
    $full = [System.IO.Path]::GetFullPath($Path)
    $full
  }
  if (-not $resolvedPath.StartsWith($resolvedRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "$Label is outside expected root: $resolvedPath"
  }
}

$rows = foreach ($name in $whitelist) {
  $source = Join-Path $WorkspaceRoot $name
  $target = Join-Path $RepoScripts $name
  Assert-UnderRoot -Root $WorkspaceRoot -Path $source -Label "Source"
  Assert-UnderRoot -Root $RepoScripts -Path $target -Label "Target"

  $sourceHash = Get-Sha256OrNull -Path $source
  $targetHash = Get-Sha256OrNull -Path $target
  $status = if ($null -eq $sourceHash) {
    "missing-source"
  } elseif ($null -eq $targetHash) {
    "missing-in-repo"
  } elseif ($sourceHash -eq $targetHash) {
    "same"
  } else {
    "changed"
  }

  [pscustomobject]@{
    File = $name
    Status = $status
    SourceHash = $sourceHash
    TargetHash = $targetHash
    SourceShort = Short-Hash $sourceHash
    TargetShort = Short-Hash $targetHash
    SourcePath = $source
    TargetPath = $target
  }
}

Write-Host "Workspace: $WorkspaceRoot"
Write-Host "Repo:      $RepoRoot"
$mode = if ($Apply) { "Apply" } else { "Preview" }
Write-Host "Mode:      $mode"
Write-Host ""

$rows |
  Select-Object File, Status, SourceShort, TargetShort |
  Format-Table -AutoSize

$nonSameRows = @($rows | Where-Object { $_.Status -ne "same" })
if ($nonSameRows.Count -gt 0) {
  Write-Host ""
  Write-Host "Full SHA256 for non-same files:"
  $nonSameRows |
    Select-Object File, Status, SourceHash, TargetHash |
    Format-List
}

$missingSource = @($rows | Where-Object { $_.Status -eq "missing-source" })
if ($missingSource.Count -gt 0) {
  Write-Warning "Some whitelist files are missing in the workspace. They will not be copied."
}

$toCopy = @($rows | Where-Object { $_.Status -in @("changed", "missing-in-repo") })

if ($Preview) {
  Write-Host ""
  if ($toCopy.Count -eq 0) {
    Write-Host "Preview result: no whitelist files need copying."
  } else {
    Write-Host "Preview result: $($toCopy.Count) whitelist file(s) would be copied with -Apply."
  }
  Write-Host ""
  Write-Host "Bundle is excluded. Check it separately:"
  Write-Host "  workspace: $WorkspaceRoot\extension.patched-baseline.js"
  Write-Host "  repo:      $RepoRoot\dist\extension.js"
  exit 0
}

if ($toCopy.Count -eq 0) {
  Write-Host "No whitelist files need copying."
  exit 0
}

New-Item -ItemType Directory -Force -Path $RepoScripts | Out-Null
foreach ($row in $toCopy) {
  if ($row.Status -eq "missing-source") {
    continue
  }
  Copy-Item -LiteralPath $row.SourcePath -Destination $row.TargetPath -Force
  Write-Host "Copied: $($row.File)"
}

Write-Host ""
Write-Host "Repository diff after export:"
try {
  git -C $RepoRoot diff --stat -- scripts
} catch {
  Write-Warning "Could not run git diff --stat. Inspect the repository manually."
}

Write-Host ""
Write-Host "Next checks:"
Write-Host "  npm run check"
Write-Host "  npm run package"
Write-Host "  npx vsce ls --tree"
Write-Host "  then run the bundle and smoke-test checklist in docs/MAINTENANCE.md"