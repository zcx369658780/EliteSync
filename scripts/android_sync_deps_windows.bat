@echo off
setlocal
cd /d %~dp0\..\apps\android

echo [1/2] Downloading Android/Gradle dependencies (including Material themes)...
call gradlew.bat --refresh-dependencies :app:dependencies
if errorlevel 1 exit /b %errorlevel%

echo [2/2] Running assembleDebug to validate resources...
call gradlew.bat :app:assembleDebug
if errorlevel 1 exit /b %errorlevel%

echo Done.
