@echo off
setlocal
set "converter_python=%USERPROFILE%\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\pythonw.exe"
if exist "%converter_python%" (
    start "" "%converter_python%" "%~dp0app.py"
) else (
    py -3 "%~dp0app.py"
    if errorlevel 1 pause
)
