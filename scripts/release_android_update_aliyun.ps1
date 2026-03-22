Param(
    [Parameter(Mandatory = $true)]
    [string]$VersionName,

    [Parameter(Mandatory = $true)]
    [string]$Changelog,

    [int]$VersionCode = 0,
    [string]$MinSupportedVersionName = "0.01.01",
    [string]$Platform = "android",
    [string]$Channel = "stable",

    [string]$ServerHost = "101.133.161.203",
    [string]$User = "root",
    [string]$KeyPath = "$env:USERPROFILE\.ssh\CodexKey.pem",
    [string]$RemoteRoot = "/opt/elitesync",
    [int]$KeepApkCount = 2,
    [int]$ProbeTimeoutSec = 20,
    [string]$ReleaseLogPath = "docs/devlogs/RELEASE_LOG.md",

    [switch]$SkipLocalVersionUpdate,
    [switch]$SkipBuild,
    [switch]$SkipRemote,
    [switch]$SkipPostCheck
)

$ErrorActionPreference = "Stop"

function Assert-Tool([string]$Name) {
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Missing required command: $Name"
    }
}

function Run-Step([string]$Title, [scriptblock]$Action) {
    Write-Host "==> $Title"
    & $Action
    Write-Host "OK: $Title"
}

function Get-VersionCodeFromName([string]$Ver) {
    if ($Ver -notmatch '^\s*(\d+)\.(\d+)\.(\d+)\s*$') {
        throw "Invalid version format: $Ver (expected major.minor.patch)"
    }
    $major = [int]$Matches[1]
    $minor = [int]$Matches[2]
    $patch = [int]$Matches[3]
    return ($major * 10000 + $minor * 100 + $patch)
}

function Add-CheckResult {
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

$postCheckResults = New-Object 'System.Collections.Generic.List[object]'
$postCheckOverallPass = $null
$postCheckExecuted = $false

Assert-Tool "ssh"
Assert-Tool "scp"

if (-not (Test-Path $KeyPath)) {
    throw "SSH key not found: $KeyPath"
}

if ($VersionCode -le 0) {
    $VersionCode = Get-VersionCodeFromName $VersionName
}

$repoRoot = (Resolve-Path "$PSScriptRoot\..").Path
$androidDir = Join-Path $repoRoot "apps\android"
$gradleFile = Join-Path $androidDir "app\build.gradle.kts"
$changelogFile = Join-Path $androidDir "app\src\main\assets\changelog_v0.txt"
$backendDir = Join-Path $repoRoot "services\backend-laravel"

$apkLocalPath = Join-Path $androidDir "app\build\outputs\apk\debug\app-debug.apk"
$apkRemoteName = "elitesync-$VersionName.apk"
$apkRemotePath = "$RemoteRoot/services/backend-laravel/public/downloads/$apkRemoteName"
$downloadUrl = "http://$ServerHost/downloads/$apkRemoteName"
$changelogB64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Changelog))

if (-not $SkipLocalVersionUpdate) {
    Run-Step "Update Android version in build.gradle.kts" {
        if (-not (Test-Path $gradleFile)) {
            throw "File not found: $gradleFile"
        }
        $content = Get-Content $gradleFile -Raw
        $content = [regex]::Replace($content, 'versionCode\s*=\s*\d+', "versionCode = $VersionCode")
        $content = [regex]::Replace($content, 'versionName\s*=\s*".*?"', "versionName = `"$VersionName`"")
        Set-Content -Path $gradleFile -Value $content -Encoding utf8
    }

    Run-Step "Append changelog (v0 file)" {
        if (-not (Test-Path $changelogFile)) {
            throw "File not found: $changelogFile"
        }
        $existing = Get-Content $changelogFile -Raw
        if ($existing -notmatch "(?m)^$([regex]::Escape($VersionName))\s*$") {
            $append = @"

$VersionName
1) $Changelog
"@
            Add-Content -Path $changelogFile -Value $append -Encoding utf8
        } else {
            Write-Host "Version $VersionName already exists in changelog, skip append."
        }
    }
}

if (-not $SkipBuild) {
    Run-Step "Build debug APK" {
        Push-Location $androidDir
        try {
            .\gradlew.bat :app:assembleDebug
        } finally {
            Pop-Location
        }
    }
}

if (-not (Test-Path $apkLocalPath)) {
    throw "APK not found: $apkLocalPath"
}

$sha256 = (Get-FileHash $apkLocalPath -Algorithm SHA256).Hash.ToUpperInvariant()
Write-Host "APK SHA256: $sha256"

if (-not $SkipRemote) {
    Run-Step "Upload APK to Aliyun" {
        scp -o StrictHostKeyChecking=no -i $KeyPath `
            $apkLocalPath `
            "$User@${ServerHost}:$apkRemotePath"
    }

    $changelogEnv = $Changelog.Replace("`r", " ").Replace("`n", " ")

    $remoteScript = @"
set -euo pipefail
cd $RemoteRoot/services/backend-laravel

cp .env ".env.bak_`$(date +%Y%m%d_%H%M%S)"
tmp_env="`$(mktemp)"
grep -vE '^(ANDROID_LATEST_VERSION_NAME|ANDROID_LATEST_VERSION_CODE|ANDROID_MIN_SUPPORTED_VERSION_NAME|ANDROID_DOWNLOAD_URL|ANDROID_CHANGELOG|ANDROID_APK_SHA256|ANDROID_FORCE_UPDATE)=' .env > "`$tmp_env" || true
cat >> "`$tmp_env" <<'EOF'
ANDROID_LATEST_VERSION_NAME=$VersionName
ANDROID_LATEST_VERSION_CODE=$VersionCode
ANDROID_MIN_SUPPORTED_VERSION_NAME=$MinSupportedVersionName
ANDROID_DOWNLOAD_URL=$downloadUrl
ANDROID_CHANGELOG=$changelogEnv
ANDROID_APK_SHA256=$sha256
ANDROID_FORCE_UPDATE=false
EOF
mv "`$tmp_env" .env
chown root:www-data .env || true
chmod 640 .env || true

php artisan optimize:clear
php artisan config:cache

php artisan app:release:upsert \
  --platform=$Platform \
  --channel=$Channel \
  --version-name=$VersionName \
  --version-code=$VersionCode \
  --min-supported-version-name=$MinSupportedVersionName \
  --download-url="$downloadUrl" \
  --changelog-b64="$changelogB64" \
  --sha256="$sha256" \
  --force-update=0

systemctl restart php8.4-fpm
systemctl restart nginx

cd $RemoteRoot/services/backend-laravel/public/downloads
keep=$KeepApkCount
total="`$(ls -1 elitesync-*.apk 2>/dev/null | wc -l | tr -d ' ')"
if [ "`$total" -gt "`$keep" ]; then
  remove_count="`$((total - keep))"
  ls -1 elitesync-*.apk 2>/dev/null | sort -V | head -n "`$remove_count" | xargs -r rm -f
fi

echo "kept_apks:"
ls -1 elitesync-*.apk | sort -V
"@

    Run-Step "Apply remote release metadata + cleanup old APKs" {
        ssh -o BatchMode=yes -o StrictHostKeyChecking=no -i $KeyPath `
            "$User@$ServerHost" `
            $remoteScript
    }
}

if ((-not $SkipRemote) -and (-not $SkipPostCheck)) {
    Run-Step "Post-release self check" {
        $checks = New-Object 'System.Collections.Generic.List[object]'

        # 1) version/check must report the just released version
        $vcUrl = "http://$ServerHost/api/v1/app/version/check?platform=$Platform&version_name=0.00.01&version_code=1&channel=$Channel"
        try {
            $vcRaw = curl.exe -s "$vcUrl"
            $vcResp = $vcRaw | ConvertFrom-Json
            $pass = ($vcResp.latest_version_name -eq $VersionName) -and ([int]$vcResp.latest_version_code -eq $VersionCode)
            Add-CheckResult -List $checks -Name "Version API" -Pass $pass -Detail ("latest={0}({1})" -f $vcResp.latest_version_name, $vcResp.latest_version_code)
        }
        catch {
            Add-CheckResult -List $checks -Name "Version API" -Pass $false -Detail ("{0}; url={1}" -f $_.Exception.Message, $vcUrl)
        }

        # 2) Download URL should be reachable
        try {
            $head = curl.exe -I -s --max-time $ProbeTimeoutSec "$downloadUrl"
            $statusLine = ($head -split "`n" | Select-Object -First 1).Trim()
            $statusCode = 0
            if ($statusLine -match 'HTTP/\d+(\.\d+)?\s+(\d{3})') {
                $statusCode = [int]$Matches[2]
            }
            $pass = ($statusCode -ge 200 -and $statusCode -lt 400)
            Add-CheckResult -List $checks -Name "Download URL" -Pass $pass -Detail ("{0}" -f $statusLine)
        }
        catch {
            Add-CheckResult -List $checks -Name "Download URL" -Pass $false -Detail $_.Exception.Message
        }

        # 3) Remote APK count must be <= KeepApkCount
        try {
            $countRaw = ssh -o BatchMode=yes -o StrictHostKeyChecking=no -i $KeyPath "$User@$ServerHost" `
                "ls -1 $RemoteRoot/services/backend-laravel/public/downloads/elitesync-*.apk 2>/dev/null | wc -l"
            $count = [int]($countRaw | Select-Object -First 1).Trim()
            $pass = $count -le $KeepApkCount
            Add-CheckResult -List $checks -Name "Remote APK Retention" -Pass $pass -Detail ("count={0}, keep={1}" -f $count, $KeepApkCount)
        }
        catch {
            Add-CheckResult -List $checks -Name "Remote APK Retention" -Pass $false -Detail $_.Exception.Message
        }

        # 4) Remote APK SHA256 should match local
        try {
            $remoteShaRaw = ssh -o BatchMode=yes -o StrictHostKeyChecking=no -i $KeyPath "$User@$ServerHost" `
                "sha256sum $apkRemotePath | cut -d' ' -f1"
            $remoteSha = ($remoteShaRaw | Select-Object -First 1).Trim().ToUpperInvariant()
            $pass = ($remoteSha -eq $sha256)
            Add-CheckResult -List $checks -Name "Remote APK SHA256" -Pass $pass -Detail ("remote={0}" -f $remoteSha)
        }
        catch {
            Add-CheckResult -List $checks -Name "Remote APK SHA256" -Pass $false -Detail $_.Exception.Message
        }

        Write-Host ""
        Write-Host "=== Post-Release Self Check Summary ==="
        foreach ($c in $checks) {
            $flag = if ($c.Pass) { "[PASS]" } else { "[FAIL]" }
            Write-Host ("{0} {1} -> {2}" -f $flag, $c.Name, $c.Detail)
        }

        $failCount = @($checks | Where-Object { -not $_.Pass }).Count
        $postCheckExecuted = $true
        $postCheckResults = $checks
        $postCheckOverallPass = ($failCount -eq 0)
        if ($failCount -gt 0) {
            throw "Post-release self check failed: $failCount item(s)."
        }
    }
}

Run-Step "Append release log" {
    $repoRoot = (Resolve-Path "$PSScriptRoot\..").Path
    $logPath = Join-Path $repoRoot $ReleaseLogPath
    $logDir = Split-Path -Parent $logPath
    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Force -Path $logDir | Out-Null
    }
    if (-not (Test-Path $logPath)) {
        Set-Content -Path $logPath -Value "# Release Log`r`n" -Encoding utf8
    }

    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $resultText = if ($postCheckExecuted) {
        if ($postCheckOverallPass) { "PASS" } else { "FAIL" }
    } else {
        "SKIPPED"
    }

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("")
    $lines.Add("## $timestamp - $VersionName")
    $lines.Add("- VersionCode: $VersionCode")
    $lines.Add("- DownloadURL: $downloadUrl")
    $lines.Add("- SHA256: $sha256")
    $lines.Add("- Changelog: $Changelog")
    $lines.Add("- PostCheck: $resultText")

    if ($postCheckExecuted -and $postCheckResults.Count -gt 0) {
        $lines.Add("- Check Details:")
        foreach ($c in $postCheckResults) {
            $flag = if ($c.Pass) { "PASS" } else { "FAIL" }
            $lines.Add("  - [$flag] $($c.Name): $($c.Detail)")
        }
    }

    Add-Content -Path $logPath -Value ($lines -join "`r`n") -Encoding utf8
    Write-Host "Release log appended: $logPath"
}

Write-Host ""
Write-Host "Release done."
Write-Host "VersionName: $VersionName"
Write-Host "VersionCode: $VersionCode"
Write-Host "DownloadURL: $downloadUrl"
Write-Host "SHA256: $sha256"
