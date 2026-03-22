Param(
  [string]$PythonVersion = "3.11",
  [switch]$RunTests,
  [switch]$StartServer
)

$ErrorActionPreference = "Stop"

Write-Host "[1/8] 进入后端目录 services/api"
Set-Location "$PSScriptRoot\..\services\api"

Write-Host "[2/8] 选择 Python 解释器"
$pythonCmd = $null

try {
  py -$PythonVersion --version | Out-Null
  $pythonCmd = "py -$PythonVersion"
} catch {
  throw "未找到 py -$PythonVersion。请安装 Python $PythonVersion，并确保 py 启动器可用。"
}

Write-Host "[3/8] 创建虚拟环境 .venv"
Invoke-Expression "$pythonCmd -m venv .venv"

Write-Host "[4/8] 激活虚拟环境"
& .\.venv\Scripts\Activate.ps1

Write-Host "[5/8] 升级 pip"
python -m pip install --upgrade pip

Write-Host "[6/8] 清理错误 jose 包并安装依赖"
python -m pip uninstall -y jose | Out-Null
python -m pip uninstall -y python-jose | Out-Null
python -m pip install -r requirements.txt
python -m pip install "python-jose[cryptography]==3.3.0"

Write-Host "[7/8] 验证关键依赖"
python -m pip show python-jose

if ($RunTests) {
  Write-Host "[8/8] 运行测试"
  $env:PYTHONPATH = "."
  python -m pytest -q
} else {
  Write-Host "[8/8] 跳过测试（可加 -RunTests）"
}

Write-Host "环境配置完成。"
Write-Host "启动命令："
Write-Host "  .\\scripts\\start_windows.ps1"

if ($StartServer) {
  Write-Host "按参数要求直接启动服务..."
  & "$PSScriptRoot\start_windows.ps1"
}
