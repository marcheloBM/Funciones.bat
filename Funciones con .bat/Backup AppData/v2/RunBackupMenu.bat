@echo off
setlocal

:: ================================
:: CONFIGURACION
:: ================================
set PS_CONSOLE=%~dp0BackupRestoreMenu.ps1
set PS_GUI=%~dp0BackupRestoreMenuGUI.ps1

:menu
cls
echo ====================================
echo      LAUNCHER BACKUP / RESTORE
echo ====================================
echo 1. Abrir menu en consola
echo 2. Abrir menu grafico (ventana)
echo 3. Salir
echo ====================================
set /p opc=Seleccione opcion: 

if "%opc%"=="1" goto console
if "%opc%"=="2" goto gui
if "%opc%"=="3" exit
goto menu

:console
powershell -NoLogo -ExecutionPolicy Bypass ^
  -Command "Start-Process PowerShell -ArgumentList '-ExecutionPolicy Bypass -File \"%PS_CONSOLE%\"' -Verb RunAs"
goto :eof

:gui
powershell -NoLogo -ExecutionPolicy Bypass ^
  -Command "Start-Process PowerShell -ArgumentList '-ExecutionPolicy Bypass -File \"%PS_GUI%\"' -Verb RunAs"
goto :eof
