@echo off
setlocal enabledelayedexpansion

set "RELEASE_ZIP=g57-local-assistant-be-release.zip"
set "INSTALLER_ZIP=g57-copilot-installer-windows.zip"
set "PROGRAM_FOLDER=g57-program-files"
set "INSTALL_DIR=%USERPROFILE%\%PROGRAM_FOLDER%"
set "URL=https://github.com/jorgexxx/g57-copilot-local-public/raw/master/%RELEASE_ZIP%"
set "SHORTCUT_NAME=g57-copilot-local.bat"

echo Stopping processes on port 30101...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :30101') do taskkill /PID %%a /F

echo Cleaning old files...
if exist "%INSTALL_DIR%" rmdir /S /Q "%INSTALL_DIR%"
if exist "%RELEASE_ZIP%" del "%RELEASE_ZIP%"

echo Downloading new ZIP...
powershell -Command "Invoke-WebRequest -Uri '%URL%' -OutFile '%RELEASE_ZIP%'"

echo Unzipping...
powershell -Command "Expand-Archive -Path '%RELEASE_ZIP%' -DestinationPath '%USERPROFILE%' -Force"

if not exist "%INSTALL_DIR%" (
    echo Error: Unzip failed.
    goto :error
)

echo Creating desktop shortcut...
set "DESKTOP_PATH=%USERPROFILE%\Desktop"
(
echo @echo off
echo call %%USERPROFILE%%\AppData\Roaming\nvm\nvm.exe
echo cd /d "%INSTALL_DIR%" ^&^& npm run pro
echo pause
) > "%DESKTOP_PATH%\%SHORTCUT_NAME%"

echo Installation completed. Shortcut created on desktop.

echo Cleaning up...
if exist "%~dp0%RELEASE_ZIP%" del "%~dp0%RELEASE_ZIP%"
if exist "%~dp0%INSTALLER_ZIP%" del "%~dp0%INSTALLER_ZIP%"
if exist "%~dp0%PROGRAM_FOLDER%" rmdir /S /Q "%~dp0%PROGRAM_FOLDER%"

set /p RUN_NOW="Do you want to run the process now? (Y/N): "
if /i "%RUN_NOW%"=="Y" or /i "%RUN_NOW%"=="y" (
    call "%DESKTOP_PATH%\%SHORTCUT_NAME%"
) else (
    echo You can run the process later using the desktop shortcut.
)

goto :end

:error
echo Installation failed.

:end
pause