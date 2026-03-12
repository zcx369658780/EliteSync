Param(
  [int]$Port = 8000,
  [string]$BindHost = "0.0.0.0",
  [switch]$NoReload
)

$ErrorActionPreference = "Stop"
Set-Location "$PSScriptRoot\..\services\api"

if (-not (Test-Path ".\.venv\Scripts\Activate.ps1")) {
  throw "未找到虚拟环境。请先执行 .\\scripts\\setup_env_windows.ps1"
}

& .\.venv\Scripts\Activate.ps1

$pythonVersion = (python -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
if ($pythonVersion -ne "3.11") {
  throw "当前 .venv Python 版本为 $pythonVersion，必须为 3.11。请先删除 services/api/.venv 并执行 .\\scripts\\setup_env_windows.ps1。"
}

$reloadArg = "--reload"
if ($NoReload) {
  $reloadArg = ""
}

Write-Host "启动 EliteSync API: http://$BindHost`:$Port"
$cmd = "uvicorn app.main:app $reloadArg --host $BindHost --port $Port"
Invoke-Expression $cmd
