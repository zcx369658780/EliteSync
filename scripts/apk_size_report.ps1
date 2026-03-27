param(
    [string]$ApkPath = "D:\EliteSync\apps\android\app\build\outputs\apk\debug\app-debug.apk",
    [int]$Top = 30
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $ApkPath)) {
    throw "APK not found: $ApkPath"
}

Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::OpenRead($ApkPath)
try {
    $file = Get-Item $ApkPath
    Write-Host "APK: $($file.FullName)"
    Write-Host ("Size: {0:N2} MB" -f ($file.Length / 1MB))
    Write-Host ""
    $zip.Entries |
        Sort-Object Length -Descending |
        Select-Object -First $Top @{Name='Entry';Expression={$_.FullName}}, @{Name='Bytes';Expression={$_.Length}}, @{Name='MB';Expression={[Math]::Round($_.Length / 1MB, 2)}} |
        Format-Table -AutoSize
} finally {
    $zip.Dispose()
}
