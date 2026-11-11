@echo off
setlocal
set "SCRIPT=%~dp0uart_tcp_bridge.ps1"
set /p "COMPORT=Enter the board UART COM port (for example COM5): "
if "%COMPORT%"=="" (
  echo COM port is required.
  pause
  exit /b 1
)
set /p "BINDIP=Listen IP, preferably the lab PC Tailscale IP (blank for 0.0.0.0): "
if "%BINDIP%"=="" set "BINDIP=0.0.0.0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" -ComPort "%COMPORT%" -ListenAddress "%BINDIP%" -Port 5001 -BaudRate 115200
pause
