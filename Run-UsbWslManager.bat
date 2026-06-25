@echo off
setlocal

powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File "%~dp0UsbWslManager.ps1"

endlocal
