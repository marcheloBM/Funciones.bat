@echo off
set "destino=%USERPROFILE%\Documents\MarcheBMPC\InformesWinSAT"
if not exist "%destino%" mkdir "%destino%"

echo Ejecutando WinSAT formal (esto puede tardar)...
winsat formal > "%destino%\winsat_result.txt"

echo Generando informe con PowerShell...
powershell -NoProfile -ExecutionPolicy Bypass -File "GenerarInformeWinSAT.ps1" -Destino "%destino%"

pause
