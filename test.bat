@echo off

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
"$p = Start-Process powershell.exe -Verb RunAs -PassThru -Wait -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%~dp0test.ps1""'; exit $p.ExitCode"

pause