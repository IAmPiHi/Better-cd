@echo off
setlocal enabledelayedexpansion


set "TARGET_DIR="
for /f "delims=" %%i in ('better-cd-core.exe') do set "TARGET_DIR=%%i"


if "%TARGET_DIR%"=="" (
    echo No folder selected.
    goto :EOF
)

endlocal & cd /d "%TARGET_DIR%"