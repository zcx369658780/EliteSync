Param(
    [string]$ConfigPath = "infra/project_config.json",
    [switch]$Apply
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $ConfigPath)) {
    throw "Config file not found: $ConfigPath"
}

$config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
$rule = $config.document_naming

if (-not $rule.enabled) {
    Write-Host "document_naming is disabled in config."
    exit 0
}

$extensions = @($rule.extensions) | ForEach-Object { $_.ToLowerInvariant() }
$suffixRegex = [string]$rule.suffix_regex
$excludeDirs = @($rule.exclude_directories) | ForEach-Object { $_.ToLowerInvariant() }
$excludeFiles = @($rule.exclude_files) | ForEach-Object { $_.ToLowerInvariant() }

function Get-GitCreatedDate([string]$path) {
    $date = git log --all --follow --diff-filter=A --date=format:%Y%m%d --format=%ad -- "$path" | Select-Object -First 1
    if ([string]::IsNullOrWhiteSpace($date)) {
        return (Get-Date).ToString("yyyyMMdd")
    }
    return $date.Trim()
}

function Should-ExcludePath([string]$fullPath) {
    $normalized = $fullPath.Replace('\', '/').ToLowerInvariant()
    foreach ($d in $excludeDirs) {
        if ($normalized -match "/$([regex]::Escape($d))/") {
            return $true
        }
    }
    return $false
}

$targetDirs = @($rule.target_directories)
$allFiles = @()
foreach ($dir in $targetDirs) {
    if (-not (Test-Path $dir)) {
        continue
    }
    if ($dir -eq "." -or $dir -eq ".\\") {
        $allFiles += Get-ChildItem $dir -File
    } else {
        $allFiles += Get-ChildItem $dir -Recurse -File
    }
}

$candidates = $allFiles | Where-Object {
    ($extensions -contains $_.Extension.ToLowerInvariant()) -and
    (-not ($excludeFiles -contains $_.Name.ToLowerInvariant())) -and
    (-not (Should-ExcludePath $_.FullName))
}

$changes = @()

foreach ($file in $candidates) {
    $nameNoExt = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
    if ($nameNoExt -match $suffixRegex) {
        continue
    }

    $date = Get-GitCreatedDate $file.FullName
    $newName = "{0}_{1}{2}" -f $nameNoExt, $date, $file.Extension
    $newPath = Join-Path $file.DirectoryName $newName

    $changes += [PSCustomObject]@{
        OldPath = $file.FullName
        NewPath = $newPath
    }
}

if ($changes.Count -eq 0) {
    Write-Host "No files need suffix updates."
    exit 0
}

Write-Host ("Planned rename count: {0}" -f $changes.Count)
$changes | ForEach-Object { Write-Host ("- {0} -> {1}" -f $_.OldPath, $_.NewPath) }

if (-not $Apply) {
    Write-Host "Dry run only. Re-run with -Apply to rename."
    exit 0
}

foreach ($c in $changes) {
    Rename-Item -Path $c.OldPath -NewName ([System.IO.Path]::GetFileName($c.NewPath))
}

Write-Host "Rename completed."
