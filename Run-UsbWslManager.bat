@echo off
setlocal

start "" powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -STA -File "%~dp0UsbWslManager.ps1"

endlocal
