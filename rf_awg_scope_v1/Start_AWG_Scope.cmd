@echo off
setlocal

rem Find MATLAB from PATH first, then common per-drive installation folders.
set "AWG_GUI_MATLAB="
for /f "delims=" %%M in ('where matlab.exe 2^>nul') do if not defined AWG_GUI_MATLAB set "AWG_GUI_MATLAB=%%~fM"
if not defined AWG_GUI_MATLAB for %%D in (C D E F G H I) do (
    for /d %%R in ("%%D:\Program Files\MATLAB\R*" "%%D:\MATLAB\R*") do (
        if exist "%%~fR\bin\matlab.exe" set "AWG_GUI_MATLAB=%%~fR\bin\matlab.exe"
    )
)
if not defined AWG_GUI_MATLAB (
    echo MATLAB was not found on PATH or in common installation folders.
    echo Install MATLAB, add matlab.exe to PATH, or edit this launcher with its full path.
    pause
    exit /b 1
)

set "AWG_GUI_ROOT=%~dp0"
start "AWG Scope" "%AWG_GUI_MATLAB%" -nosplash -r "try, run(fullfile(getenv('AWG_GUI_ROOT'),'matlab','launch_awg_scope.m')); catch ME, disp(getReport(ME,'extended')); errordlg(getReport(ME,'basic'),'AWG Scope startup failed'); end"
endlocal
