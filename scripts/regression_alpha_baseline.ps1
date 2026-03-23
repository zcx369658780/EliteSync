Param(
    [string]$ServerHost = "101.133.161.203",
    [string]$BaseUrl = "",
    [string]$Phone = "",
    [string]$Password = "",
    [switch]$SkipBackendTests,
    [switch]$SkipGate,
    [switch]$GateQuickOnly,
    [string]$ReportPath = "docs/devlogs/REGRESSION_BASELINE_LOG.md"
)

$ErrorActionPreference = "Stop"

$psRunner = ""
if (Get-Command "pwsh" -ErrorAction SilentlyContinue) {
    $psRunner = "pwsh"
}
elseif (Get-Command "powershell.exe" -ErrorAction SilentlyContinue) {
    $psRunner = "powershell.exe"
}
elseif (Get-Command "powershell" -ErrorAction SilentlyContinue) {
    $psRunner = "powershell"
}
else {
    throw "No PowerShell runner found (pwsh/powershell)."
}

function Add-StepResult {
    param(
        [System.Collections.Generic.List[object]]$List,
        [string]$Name,
        [bool]$Pass,
        [string]$Detail
    )
    $List.Add([PSCustomObject]@{
        Name = $Name
        Pass = $Pass
        Detail = $Detail
    }) | Out-Null
}

if ([string]::IsNullOrWhiteSpace($BaseUrl)) {
    $BaseUrl = "http://$ServerHost"
}
$BaseUrl = $BaseUrl.TrimEnd("/")

$repoRoot = (Resolve-Path "$PSScriptRoot\..").Path
$results = New-Object 'System.Collections.Generic.List[object]'

if (-not $SkipBackendTests) {
    try {
        Push-Location (Join-Path $repoRoot "services\backend-laravel")
        php artisan test
        if ($LASTEXITCODE -ne 0) {
            throw "php artisan test exit code: $LASTEXITCODE"
        }
        Add-StepResult -List $results -Name "Backend Tests" -Pass $true -Detail "php artisan test passed"
    }
    catch {
        Add-StepResult -List $results -Name "Backend Tests" -Pass $false -Detail $_.Exception.Message
    }
    finally {
        Pop-Location
    }
}
else {
    Add-StepResult -List $results -Name "Backend Tests" -Pass $true -Detail "SKIPPED"
}

if (-not $SkipGate) {
    try {
        $gateScript = Join-Path $repoRoot "scripts\release_gate_alpha.ps1"
        $args = @(
            "-NoProfile",
            "-ExecutionPolicy", "Bypass",
            "-File", $gateScript,
            "-ServerHost", $ServerHost,
            "-BaseUrl", $BaseUrl
        )
        if ($GateQuickOnly) {
            $args += "-QuickUpdateOnly"
        }
        else {
            if (-not [string]::IsNullOrWhiteSpace($Phone)) { $args += @("-Phone", $Phone) }
            if (-not [string]::IsNullOrWhiteSpace($Password)) { $args += @("-Password", $Password) }
        }

        & $psRunner @args
        $gateExit = $LASTEXITCODE
        if ($gateExit -ne 0) {
            throw "release gate exit code: $gateExit"
        }
        $detail = if ($GateQuickOnly) { "quick gate passed" } else { "full gate passed" }
        Add-StepResult -List $results -Name "Release Gate" -Pass $true -Detail $detail
    }
    catch {
        Add-StepResult -List $results -Name "Release Gate" -Pass $false -Detail $_.Exception.Message
    }
}
else {
    Add-StepResult -List $results -Name "Release Gate" -Pass $true -Detail "SKIPPED"
}

$failCount = @($results | Where-Object { -not $_.Pass }).Count
$overall = if ($failCount -eq 0) { "PASS" } else { "FAIL" }

Write-Host ""
Write-Host "=== Regression Baseline Summary ==="
foreach ($r in $results) {
    $flag = if ($r.Pass) { "[PASS]" } else { "[FAIL]" }
    Write-Host ("{0} {1} -> {2}" -f $flag, $r.Name, $r.Detail)
}
Write-Host ("Overall: {0} (fail={1})" -f $overall, $failCount)
Write-Host ("BASELINE_RESULT={0}" -f $overall)

$logPath = Join-Path $repoRoot $ReportPath
$logDir = Split-Path -Parent $logPath
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Force -Path $logDir | Out-Null
}
if (-not (Test-Path $logPath)) {
    Set-Content -Path $logPath -Value "# Regression Baseline Log`r`n" -Encoding utf8
}

$ts = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
$md = New-Object System.Collections.Generic.List[string]
$md.Add("")
$md.Add("## $ts")
$md.Add("- BaseUrl: $BaseUrl")
$md.Add("- Overall: $overall")
$md.Add("- Steps:")
foreach ($r in $results) {
    $flag = if ($r.Pass) { "PASS" } else { "FAIL" }
    $md.Add("  - [$flag] $($r.Name): $($r.Detail)")
}
Add-Content -Path $logPath -Value ($md -join "`r`n") -Encoding utf8
Write-Host "Baseline log appended: $logPath"

if ($failCount -gt 0) {
    exit 2
}
exit 0
