param(
    [string]$Workspace = "",
    [string]$CodePath = "",
    [string]$ActivationDoFile = ""
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($Workspace)) {
    if (-not [string]::IsNullOrWhiteSpace($env:STATA_WORKBENCH_WORKSPACE)) { $Workspace = $env:STATA_WORKBENCH_WORKSPACE } else { $Workspace = $repoRoot }
}
$workspace = $Workspace
$log = Join-Path $workspace "open_stata_vscode_fast.log"
$visibleInvoker = Join-Path $PSScriptRoot "invoke_stata_visible.ps1"
$patchVerifier = Join-Path $PSScriptRoot "stata_patch.ps1"
$statusEndpoint = "http://127.0.0.1:17485/status"
$activationDoFile = if (-not [string]::IsNullOrWhiteSpace($ActivationDoFile)) { $ActivationDoFile } else { Join-Path $workspace "demo.do" }
$reloadScript = Join-Path $workspace "7_temp\reload_vscode.ps1"
$codeCandidates = @(
    $CodePath,
    $env:STATA_WORKBENCH_CODE,
    "code.cmd",
    "code"
)

$code = $codeCandidates | Where-Object {
    -not [string]::IsNullOrWhiteSpace($_) -and ((Test-Path -LiteralPath $_) -or (Get-Command $_ -ErrorAction SilentlyContinue))
} | Select-Object -First 1

if ([string]::IsNullOrWhiteSpace($code)) {
    "VS Code command not found. Checked: $($codeCandidates -join '; ')" | Set-Content -LiteralPath $log -Encoding UTF8
    throw "VS Code command not found. Checked: $($codeCandidates -join '; ')"
}

$existingReady = $false
try {
    $existingStatus = Invoke-RestMethod -Uri $statusEndpoint -Method Get -TimeoutSec 1
    if ($existingStatus.ok -eq $true -and $existingStatus.busy -ne $true -and $existingStatus.postRunBusy -ne $true -and ($null -eq $existingStatus.trueReady -or $existingStatus.trueReady -eq $true)) {
        $existingReady = $true
    }
} catch {
    $existingReady = $false
}

if ($existingReady -and $env:STATA_FAST_FORCE_NEW_WINDOW -ne "1") {
    $lines = @(
        "Existing Stata Workbench bridge is already ready; launcher returned without opening another VS Code window.",
        "Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')",
        "Workspace: $workspace",
        "Set STATA_FAST_FORCE_NEW_WINDOW=1 to force a new Stata-focused VS Code window."
    )
    $lines | Set-Content -LiteralPath $log -Encoding UTF8
    Write-Host $lines[0]
    exit 0
}

$disableExtensions = @(
    "DeepEcon.stata-mcp",
    "brapifra.c-compiler",
    "continue.continue",
    "cweijan.vscode-office",
    "davidanson.vscode-markdownlint",
    "formulahendry.code-runner",
    "james-yu.latex-workshop",
    "kylebarron.stata-enhanced",
    "ms-python.debugpy",
    "ms-python.python",
    "ms-python.vscode-pylance",
    "ms-toolsai.datawrangler",
    "ms-toolsai.jupyter",
    "ms-toolsai.jupyter-keymap",
    "ms-toolsai.jupyter-renderers",
    "ms-toolsai.vscode-jupyter-cell-tags",
    "ms-toolsai.vscode-jupyter-slideshow",
    "ms-vscode.wasm-dwarf-debugging",
    "reditorsupport.r",
    "reditorsupport.r-syntax",
    "tomoki1207.pdf",
    "yeaoh.statarun",
    "zhuangtongfa.material-theme"
)

$codeArgs = @("--new-window")
foreach ($extensionId in $disableExtensions) {
    $codeArgs += "--disable-extension"
    $codeArgs += $extensionId
}
$codeArgs += $workspace
if (Test-Path -LiteralPath $activationDoFile) {
    $codeArgs += $activationDoFile
}

$lines = @(
    "Opening Stata-focused VS Code window.",
    "Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')",
    "Command: $code",
    "Workspace: $workspace",
    "Activation do-file: $activationDoFile",
    "Temporarily disabled extensions: $($disableExtensions.Count)"
)
$lines | Set-Content -LiteralPath $log -Encoding UTF8

Write-Host "Opening Stata-focused VS Code window..."
Write-Host "Workspace: $workspace"
Write-Host "Temporarily disabled extensions: $($disableExtensions.Count)"

if ($env:STATA_FAST_DRYRUN -eq "1") {
    Write-Host "Dry run enabled; VS Code was not launched."
    "Dry run: VS Code was not launched." | Add-Content -LiteralPath $log -Encoding UTF8
    exit 0
}

& $code @codeArgs

if ($env:STATA_FAST_SKIP_VERIFY -eq "1") {
    Write-Host "Auto verification skipped by STATA_FAST_SKIP_VERIFY=1."
    "Auto verification skipped by STATA_FAST_SKIP_VERIFY=1." | Add-Content -LiteralPath $log -Encoding UTF8
    exit 0
}

Write-Host "Waiting for Stata Workbench bridge..."
"Waiting for Stata Workbench bridge..." | Add-Content -LiteralPath $log -Encoding UTF8

$bridgeOnline = $false
$maxBridgeWaitSeconds = 90
$bridgePollMilliseconds = 200
$bridgeCheckStarted = Get-Date
$lastStatusLogSecond = -1

while (((Get-Date) - $bridgeCheckStarted).TotalSeconds -lt $maxBridgeWaitSeconds) {
    try {
        $status = Invoke-RestMethod -Uri $statusEndpoint -Method Get -TimeoutSec 1
        if ($status.ok -eq $true -and $status.busy -ne $true -and $status.postRunBusy -ne $true -and ($null -eq $status.trueReady -or $status.trueReady -eq $true)) {
            $bridgeOnline = $true
            $elapsed = [math]::Round(((Get-Date) - $bridgeCheckStarted).TotalSeconds, 1)
            "Bridge ready after $elapsed seconds via lightweight /status polling." | Add-Content -LiteralPath $log -Encoding UTF8
            break
        }
        $elapsedSecond = [int][math]::Floor(((Get-Date) - $bridgeCheckStarted).TotalSeconds)
        if ($elapsedSecond -ge 1 -and $elapsedSecond % 5 -eq 0 -and $elapsedSecond -ne $lastStatusLogSecond) {
            $lastStatusLogSecond = $elapsedSecond
            "Bridge not ready at ${elapsedSecond}s: busy=$($status.busy), postRunBusy=$($status.postRunBusy), trueReady=$($status.trueReady), reason=$($status.notReadyReason)" | Add-Content -LiteralPath $log -Encoding UTF8
        }
    } catch {
        $elapsedSecond = [int][math]::Floor(((Get-Date) - $bridgeCheckStarted).TotalSeconds)
        if ($elapsedSecond -eq 0 -or ($elapsedSecond % 5 -eq 0 -and $elapsedSecond -ne $lastStatusLogSecond)) {
            $lastStatusLogSecond = $elapsedSecond
            "Bridge status check at ${elapsedSecond}s failed: $($_.Exception.Message)" | Add-Content -LiteralPath $log -Encoding UTF8
        }
    }
    if (-not $bridgeOnline) {
        Start-Sleep -Milliseconds $bridgePollMilliseconds
    }
}

if ($bridgeOnline) {
    if ($env:STATA_FAST_FULL_VERIFY -eq "1") {
        "Running one full patch verification after bridge readiness because STATA_FAST_FULL_VERIFY=1." | Add-Content -LiteralPath $log -Encoding UTF8
        $verifyOutput = & $patchVerifier verify 2>&1
        $verifyText = ($verifyOutput | Out-String)
        $verifyText | Add-Content -LiteralPath $log -Encoding UTF8
        if ($verifyText -notmatch "Overall\s+:\s+OK fully patched" -or $verifyText -notmatch "Bridge\s+:.*OK online") {
            $bridgeOnline = $false
            "Patch verification failed after /status readiness; treating bridge as not online." | Add-Content -LiteralPath $log -Encoding UTF8
        }
    } else {
        "Full patch verification skipped for low-latency startup. Set STATA_FAST_FULL_VERIFY=1 to force it." | Add-Content -LiteralPath $log -Encoding UTF8
    }
}

if (-not $bridgeOnline) {
    if (Test-Path -LiteralPath $reloadScript) {
        "Bridge did not become online; attempting automated VS Code reload." | Add-Content -LiteralPath $log -Encoding UTF8
        Write-Warning "Bridge did not become online; attempting automated VS Code reload."
        try {
            & $reloadScript | Add-Content -LiteralPath $log -Encoding UTF8
            for ($i = 1; $i -le 60; $i++) {
                try {
                    $status = Invoke-RestMethod -Uri $statusEndpoint -Method Get -TimeoutSec 1
                    if ($status.ok -eq $true -and $status.busy -ne $true -and $status.postRunBusy -ne $true -and ($null -eq $status.trueReady -or $status.trueReady -eq $true)) {
                        $bridgeOnline = $true
                        "Bridge ready after automated reload via lightweight /status polling." | Add-Content -LiteralPath $log -Encoding UTF8
                        break
                    }
                } catch {
                    "Bridge reload check attempt $i failed: $($_.Exception.Message)" | Add-Content -LiteralPath $log -Encoding UTF8
                }
                if (-not $bridgeOnline) {
                    Start-Sleep -Milliseconds $bridgePollMilliseconds
                }
            }
            if ($bridgeOnline) {
                if ($env:STATA_FAST_FULL_VERIFY -eq "1") {
                    $verifyOutput = & $patchVerifier verify 2>&1
                    $verifyText = ($verifyOutput | Out-String)
                    $verifyText | Add-Content -LiteralPath $log -Encoding UTF8
                    if ($verifyText -notmatch "Overall\s+:\s+OK fully patched" -or $verifyText -notmatch "Bridge\s+:.*OK online") {
                        $bridgeOnline = $false
                        "Patch verification failed after automated reload readiness." | Add-Content -LiteralPath $log -Encoding UTF8
                    }
                } else {
                    "Full patch verification after automated reload skipped for low-latency startup. Set STATA_FAST_FULL_VERIFY=1 to force it." | Add-Content -LiteralPath $log -Encoding UTF8
                }
            }
        } catch {
            "Automated reload failed: $($_.Exception.Message)" | Add-Content -LiteralPath $log -Encoding UTF8
        }
    }
}

if (-not $bridgeOnline) {
    $message = @(
        "Bridge did not become online within $maxBridgeWaitSeconds seconds.",
        "Automated reload did not recover the bridge. Agent recovery should use /force-reset, /panic-kill, then reopen with this launcher.",
        "Manual check: & `"$patchVerifier`" verify"
    )
    $message | Add-Content -LiteralPath $log -Encoding UTF8
    Write-Warning ($message -join " ")
    exit 0
}

if ($env:STATA_FAST_FORCE_SMOKE -ne "1") {
    $message = "Bridge verified; startup smoke skipped for low latency. Set STATA_FAST_FORCE_SMOKE=1 to force the visible smoke test."
    Write-Host $message
    $message | Add-Content -LiteralPath $log -Encoding UTF8
    exit 0
}

Write-Host "Running visible Stata bridge test command..."
"Running visible Stata bridge test command because STATA_FAST_FORCE_SMOKE=1." | Add-Content -LiteralPath $log -Encoding UTF8

try {
    $bridgeStatus = Invoke-RestMethod -Uri $statusEndpoint -Method Get -TimeoutSec 5
    if ($bridgeStatus.busy -eq $true) {
        $busyMessage = "Visible Stata bridge is busy; launcher test skipped to avoid queueing. Current: $($bridgeStatus.current.label)"
        $busyMessage | Add-Content -LiteralPath $log -Encoding UTF8
        Write-Warning $busyMessage
        exit 0
    }
    $testOutput = & $visibleInvoker `
        -Code 'display as text "Stata visible bridge task test from fast launcher"' `
        -Label "Fast launcher visible bridge test" `
        -TailLog `
        -TimeoutSec 120 2>&1
    $testText = ($testOutput | Out-String)
    $testText | Add-Content -LiteralPath $log -Encoding UTF8
    Write-Host $testText
} catch {
    "Visible test failed: $($_.Exception.Message)" | Add-Content -LiteralPath $log -Encoding UTF8
    Write-Warning "Visible Stata test failed. See open_stata_vscode_fast.log."
}
