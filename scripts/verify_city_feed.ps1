param(
    [string]$BaseUrl = 'http://101.133.161.203',
    [string]$Password = '1234567aa',
    [string]$Ranker = 'auto', # auto|weighted|legacy
    [string]$HomeTab = 'nearby',
    [string]$DiscoverTab = 'local',
    [switch]$AllRankers,
    [switch]$WriteLog,
    [string]$CasesFile = 'scripts/verify_city_feed_accounts.json',
    [string]$CityFilter = ''
)

$ErrorActionPreference = 'Stop'

$cases = @()
if (Test-Path $CasesFile) {
    $raw = Get-Content -Path $CasesFile -Raw
    $json = ConvertFrom-Json -InputObject $raw
    foreach ($item in $json) {
        $phone = ($item.phone ?? '').ToString().Trim()
        $expect = ($item.expect ?? '').ToString().Trim()
        if ($phone -eq '' -or $expect -eq '') { continue }
        if ($CityFilter -ne '' -and ($expect -notlike "*$CityFilter*")) { continue }
        $cases += @{ phone = $phone; expect = $expect }
    }
} else {
    $cases = @(
        @{ phone='13800000022'; expect='南阳' }
    )
}

if ($cases.Count -eq 0) {
    throw "No test cases found. CasesFile=$CasesFile, CityFilter=$CityFilter"
}

function Invoke-Json {
    param(
        [ValidateSet('GET','POST')] [string]$Method,
        [string]$Url,
        [hashtable]$Headers,
        $Body = $null
    )
    if ($Method -eq 'POST') {
        return Invoke-RestMethod -Method Post -Uri $Url -Headers $Headers -Body ($Body | ConvertTo-Json -Depth 8) -ContentType 'application/json'
    }
    return Invoke-RestMethod -Method Get -Uri $Url -Headers $Headers
}

$ok = 0
$fail = 0
$rankers = if ($AllRankers) { @('auto', 'weighted', 'legacy') } else { @($Ranker) }
$logLines = @()

foreach ($rk in $rankers) {
    Write-Host "`n=== Ranker: $rk ==="
    $logLines += "`n## Ranker: $rk"
    foreach ($c in $cases) {
        $phone = $c.phone
        $expect = $c.expect
        try {
            $login = Invoke-Json -Method POST -Url "$BaseUrl/api/v1/auth/login" -Headers @{} -Body @{ phone=$phone; password=$Password }
            $token = $login.access_token
            if ([string]::IsNullOrWhiteSpace($token)) {
                throw "empty token"
            }
            $headers = @{ Authorization = "Bearer $token" }

            $homeResp = Invoke-Json -Method GET -Url "$BaseUrl/api/v1/home/feed?tab=$HomeTab&limit=8&ranker=$rk" -Headers $headers
            $discoverResp = Invoke-Json -Method GET -Url "$BaseUrl/api/v1/discover/feed?tab=$DiscoverTab&limit=8&ranker=$rk" -Headers $headers

            $homeHit = @($homeResp.data | Where-Object { $_.city -like "*$expect*" }).Count
            $discoverHit = @($discoverResp.data | Where-Object { $_.city -like "*$expect*" }).Count

            if ($homeHit -gt 0 -or $discoverHit -gt 0) {
                $ok++
                Write-Host "[PASS] $phone expect=$expect ranker=$rk homeHit=$homeHit discoverHit=$discoverHit"
                $logLines += "- [PASS] $phone expect=$expect homeHit=$homeHit discoverHit=$discoverHit"
            } else {
                $fail++
                Write-Host "[FAIL] $phone expect=$expect ranker=$rk homeHit=0 discoverHit=0"
                $logLines += "- [FAIL] $phone expect=$expect homeHit=0 discoverHit=0"
            }

            $topHome = @($homeResp.data | Select-Object -First 3 | ForEach-Object { "{0}|{1}" -f $_.id, $_.city }) -join '; '
            $topDiscover = @($discoverResp.data | Select-Object -First 3 | ForEach-Object { "{0}|{1}" -f $_.id, $_.city }) -join '; '
            Write-Host "  homeTop: $topHome"
            Write-Host "  discoverTop: $topDiscover"
            $logLines += "  - homeTop: $topHome"
            $logLines += "  - discoverTop: $topDiscover"
        }
        catch {
            $fail++
            Write-Host "[FAIL] $phone -> $($_.Exception.Message)"
            $logLines += "- [FAIL] $phone -> $($_.Exception.Message)"
        }
    }
}

Write-Host "\nSummary: pass=$ok fail=$fail"
$logLines += "`nSummary: pass=$ok fail=$fail"

if ($WriteLog) {
    $logPath = "docs/devlogs/CITY_FEED_VERIFY_LOG.md"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $header = "`n---`n# $timestamp`nBaseUrl: $BaseUrl, HomeTab: $HomeTab, DiscoverTab: $DiscoverTab, CasesFile: $CasesFile, CityFilter: $CityFilter`n"
    if (-not (Test-Path $logPath)) {
        New-Item -ItemType File -Path $logPath -Force | Out-Null
    }
    Add-Content -Path $logPath -Value $header
    Add-Content -Path $logPath -Value ($logLines -join "`n")
    Write-Host "Log appended: $logPath"
}

if ($fail -gt 0) { exit 1 }
