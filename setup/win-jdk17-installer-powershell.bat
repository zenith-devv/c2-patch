@echo off

cd ..\resources\

set "url=https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.13+11/OpenJDK17U-jdk_x64_windows_hotspot_17.0.13_11.zip"

for %%F in ("%url%") do set "filename=%%~nxF"

if not exist "%filename%" (
    curl -o %filename% -LJO "%url%"
    powershell -command "Expand-Archive -Path %filename% -DestinationPath ."
    del %filename%
)

python -m pip install PySide6-Essentials

cd ..

chcp 65001 >nul

set "CURRENT_DIR=%~dp0"

for %%I in ("%CURRENT_DIR%\..") do set "ROOT_DIR=%%~fI"

for /f "tokens=2*" %%a in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v Desktop 2^>nul') do set "DESKTOP_PATH=%%b"

set "FULL_ICON_PATH=%ROOT_DIR%\launcher\resources\icon.ico"

powershell -Command ^
    "$sh = New-Object -COM WScript.Shell; " ^
    "$lnk = $sh.CreateShortcut('%DESKTOP_PATH%\Cultris II Patch Launcher.lnk'); " ^
    "$lnk.TargetPath = 'pythonw.exe'; " ^
    "$lnk.WorkingDirectory = '%ROOT_DIR%'; " ^
    "$lnk.Arguments = '\"%ROOT_DIR%\c2-launcher.py\"'; " ^
    "$lnk.IconLocation = '%FULL_ICON_PATH%'; " ^
    "$lnk.Save()"

echo Shortcut created at %DESKTOP_PATH%

echo Done!
