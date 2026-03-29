Param(
    [string]$ServerHost = "101.133.161.203",
    [string]$BaseUrl = "",
    [string]$Phone = "",
    [string]$Password = "",
    [int]$SmokeRetryCount = 1,
    [int]$SmokeRetryDelaySec = 3,
    [switch]$SkipAndroidBuild,
    [switch]$SkipBackendSmoke,
    [switch]$SkipAstroRegression,
    [switch]$SmokeSkipAuthChecks,
    [switch]$QuickUpdateOnly,
    [string]$GateLogPath = "docs/devlogs/RELEASE_GATE_LOG.md"
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

function New-GateStepResult {
    param(
        [string]$Name,
        [bool]$Pass,
        [string]$Detail
    )
    return [PSCustomObject]@{
        Name = $Name
        Pass = $Pass
        Detail = $Detail
    }
}

if ([string]::IsNullOrWhiteSpace($BaseUrl)) {
    $BaseUrl = "http://$ServerHost"
}
$BaseUrl = $BaseUrl.TrimEnd("/")

if ($QuickUpdateOnly) {
    $SkipAndroidBuild = $true
    $SkipBackendSmoke = $false
    $SmokeSkipAuthChecks = $true
    $SkipAstroRegression = $false
}

$repoRoot = (Resolve-Path "$PSScriptRoot\..").Path
$appDir = Join-Path $repoRoot "apps\android"
$smokeScript = Join-Path $repoRoot "scripts\smoke_backend_alpha.ps1"
$backendDir = Join-Path $repoRoot "services\backend-laravel"

$results = New-Object 'System.Collections.Generic.List[object]'

if (-not $SkipAndroidBuild) {
    try {
        Push-Location $appDir
        $isWindowsHost = $false
        if ($env:OS -eq "Windows_NT") {
            $isWindowsHost = $true
        }
        elseif ($PSVersionTable.PSEdition -eq "Desktop") {
            $isWindowsHost = $true
        }

        if ($isWindowsHost) {
            & .\gradlew.bat :app:compileDebugKotlin --no-daemon
        }
        else {
            if (Test-Path "./gradlew") {
                chmod +x ./gradlew
            }
            & ./gradlew :app:compileDebugKotlin --no-daemon
        }
        if ($LASTEXITCODE -ne 0) {
            throw "Gradle exit code: $LASTEXITCODE"
        }
        $results.Add((New-GateStepResult -Name "Android Compile" -Pass $true -Detail "compileDebugKotlin passed")) | Out-Null
    }
    catch {
        $results.Add((New-GateStepResult -Name "Android Compile" -Pass $false -Detail $_.Exception.Message)) | Out-Null
    }
    finally {
        Pop-Location
    }
}
else {
    $results.Add((New-GateStepResult -Name "Android Compile" -Pass $true -Detail "SKIPPED")) | Out-Null
}

if (-not $SkipBackendSmoke) {
    try {
        if (-not (Test-Path $smokeScript)) {
            throw "Smoke script not found: $smokeScript"
        }

        $attempt = 0
        $passed = $false
        $lastSmokeExit = -1
        while ($attempt -le $SmokeRetryCount -and -not $passed) {
            $attempt++

            $smokeArgs = @(
                "-NoProfile",
                "-ExecutionPolicy", "Bypass",
                "-File", $smokeScript,
                "-ServerHost", $ServerHost,
                "-BaseUrl", $BaseUrl
            )
            if ($SmokeSkipAuthChecks) {
                $smokeArgs += "-SkipAuthChecks"
            }
            else {
                if (-not [string]::IsNullOrWhiteSpace($Phone)) { $smokeArgs += @("-Phone", $Phone) }
                if (-not [string]::IsNullOrWhiteSpace($Password)) { $smokeArgs += @("-Password", $Password) }
            }

            & $psRunner @smokeArgs
            $lastSmokeExit = $LASTEXITCODE
            if ($lastSmokeExit -eq 0) {
                $passed = $true
                break
            }

            if ($attempt -le $SmokeRetryCount) {
                Write-Host ("Smoke failed (attempt {0}/{1}), retrying in {2}s..." -f $attempt, ($SmokeRetryCount + 1), $SmokeRetryDelaySec)
                Start-Sleep -Seconds $SmokeRetryDelaySec
            }
        }

        if (-not $passed) {
            throw ("Smoke exit code: {0} after {1} attempt(s)" -f $lastSmokeExit, ($SmokeRetryCount + 1))
        }

        $detail = if ($SmokeSkipAuthChecks) { "public smoke passed" } else { "full smoke passed" }
        $detail = "{0} (attempt={1})" -f $detail, $attempt
        $results.Add((New-GateStepResult -Name "Backend Smoke" -Pass $true -Detail $detail)) | Out-Null
    }
    catch {
        $results.Add((New-GateStepResult -Name "Backend Smoke" -Pass $false -Detail $_.Exception.Message)) | Out-Null
    }
}
else {
    $results.Add((New-GateStepResult -Name "Backend Smoke" -Pass $true -Detail "SKIPPED")) | Out-Null
}

if (-not $SkipAstroRegression) {
    try {
        Push-Location $backendDir
        & php artisan test --filter "BaziFeatureExtractorTest|ZodiacDerivationTest|AstroEngineAdapterTest"
        if ($LASTEXITCODE -ne 0) {
            throw "Laravel astro regression exit code: $LASTEXITCODE"
        }
        $results.Add((New-GateStepResult -Name "Astro Regression" -Pass $true -Detail "targeted astro tests passed")) | Out-Null
    }
    catch {
        $results.Add((New-GateStepResult -Name "Astro Regression" -Pass $false -Detail $_.Exception.Message)) | Out-Null
    }
    finally {
        Pop-Location
    }
}
else {
    $results.Add((New-GateStepResult -Name "Astro Regression" -Pass $true -Detail "SKIPPED")) | Out-Null
}

$failCount = @($results | Where-Object { -not $_.Pass }).Count
$overall = if ($failCount -eq 0) { "PASS" } else { "FAIL" }

Write-Host ""
Write-Host "=== Release Gate Summary ==="
foreach ($r in $results) {
    $flag = if ($r.Pass) { "[PASS]" } else { "[FAIL]" }
    Write-Host ("{0} {1} -> {2}" -f $flag, $r.Name, $r.Detail)
}
Write-Host ("Overall: {0} (fail={1})" -f $overall, $failCount)
Write-Host ("GATE_RESULT={0}" -f $overall)

$logPath = Join-Path $repoRoot $GateLogPath
$logDir = Split-Path -Parent $logPath
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Force -Path $logDir | Out-Null
}
if (-not (Test-Path $logPath)) {
    Set-Content -Path $logPath -Value "# Release Gate Log`r`n" -Encoding utf8
}

$ts = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
$md = New-Object System.Collections.Generic.List[string]
$md.Add("")
$md.Add("## $ts")
$md.Add("- BaseUrl: $BaseUrl")
$md.Add("- Overall: $overall")
$md.Add("- QuickUpdateOnly: $QuickUpdateOnly")
$md.Add("- SkipAstroRegression: $SkipAstroRegression")
$md.Add("- SmokeRetryCount: $SmokeRetryCount")
$md.Add("- SmokeRetryDelaySec: $SmokeRetryDelaySec")
$md.Add("- Steps:")
foreach ($r in $results) {
    $flag = if ($r.Pass) { "PASS" } else { "FAIL" }
    $md.Add("  - [$flag] $($r.Name): $($r.Detail)")
}
Add-Content -Path $logPath -Value ($md -join "`r`n") -Encoding utf8
Write-Host "Gate log appended: $logPath"

if ($failCount -gt 0) {
    exit 2
}
exit 0
