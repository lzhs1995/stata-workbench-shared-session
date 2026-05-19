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
$code = if (-not [string]::IsNullOrWhiteSpace($CodePath)) { $CodePath } elseif (-not [string]::IsNullOrWhiteSpace($env:STATA_WORKBENCH_CODE)) { $env:STATA_WORKBENCH_CODE } else { "code.cmd" }
$activationDoFile = if (-not [string]::IsNullOrWhiteSpace($ActivationDoFile)) { $ActivationDoFile } else { Join-Path $workspace "demo.do" }

if (-not ((Test-Path -LiteralPath $code) -or (Get-Command $code -ErrorAction SilentlyContinue))) {
    throw "VS Code executable not found: $code"
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

Write-Host "Starting hosted Stata-focused VS Code window..."
Write-Host "Workspace: $workspace"
Write-Host "Executable: $code"
Write-Host "This PowerShell host intentionally stays alive so the VS Code process tree is not reaped by the agent runtime."

& $code @codeArgs

Write-Host "Code.exe returned; keeping host process alive. Stop this PowerShell session to close the hosted lifecycle."
while ($true) {
    Start-Sleep -Seconds 3600
}
