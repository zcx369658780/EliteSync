@echo off
setlocal enabledelayedexpansion

REM EliteSync API Windows starter with file logging
REM Usage:
REM   scripts\start_windows.bat
REM   scripts\start_windows.bat 8000

set PORT=%~1
if "%PORT%"=="" set PORT=8000
set HOST=0.0.0.0

set ROOT_DIR=%~dp0..
set API_DIR=%ROOT_DIR%\services\api
set VENV_ACT=%API_DIR%\.venv\Scripts\activate.bat
set LOG_DIR=%ROOT_DIR%\logs

if not exist "%VENV_ACT%" (
  echo [ERROR] Virtual env not found: %VENV_ACT%
  echo Please run scripts\setup_env_windows.ps1 first.
  exit /b 1
)

if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"
for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss"') do set TS=%%i
set LOG_FILE=%LOG_DIR%\api_%TS%.log

cd /d "%API_DIR%"
call "%VENV_ACT%"

for /f %%i in ('python -c "import sys; print(f""{sys.version_info.major}.{sys.version_info.minor}""")"') do set PY_VERSION=%%i
echo [INFO] Detected venv Python version: %PY_VERSION%
echo [INFO] Detected venv Python version: %PY_VERSION%>> "%LOG_FILE%"

if not "%PY_VERSION%"=="3.11" (
  echo [ERROR] Unsupported venv Python version: %PY_VERSION%
  echo [ERROR] Expected 3.11. Recreate services\api\.venv via scripts\setup_env_windows.ps1.
  echo [ERROR] Unsupported venv Python version: %PY_VERSION%>> "%LOG_FILE%"
  echo [ERROR] Expected 3.11. Recreate services\api\.venv via scripts\setup_env_windows.ps1.>> "%LOG_FILE%"
  exit /b 1
)

echo [INFO] Starting EliteSync API on http://%HOST%:%PORT%
echo [INFO] Logging to %LOG_FILE%

echo ===== EliteSync API start %date% %time% =====>> "%LOG_FILE%"
uvicorn app.main:app --reload --host %HOST% --port %PORT% >> "%LOG_FILE%" 2>&1

set EXIT_CODE=%ERRORLEVEL%
echo ===== EliteSync API stop %date% %time% code=%EXIT_CODE% =====>> "%LOG_FILE%"
echo [INFO] Process exited with code %EXIT_CODE%
echo [INFO] Log file: %LOG_FILE%

exit /b %EXIT_CODE%
