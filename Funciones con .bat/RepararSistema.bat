@echo off
setlocal

:: --- Definir ruta del log con fecha y hora ---
set LOGDIR=%USERPROFILE%\Documents\MarcheBMPC
if not exist "%LOGDIR%" mkdir "%LOGDIR%"

:: Formato YYYY-MM-DD_HH-MM
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do set FECHA=%%c-%%b-%%a
for /f "tokens=1-2 delims=: " %%a in ('time /t') do set HORA=%%a-%%b
set LOGFILE=%LOGDIR%\diagnostico_%FECHA%_%HORA%.txt

echo Registro de diagnostico iniciado > "%LOGFILE%"

:MENU
cls
echo ============================================
echo   MENU DE REVISION Y REPARACION DEL SISTEMA
echo ============================================
echo.
echo [1] Ejecutar CHKDSK en C:
echo [2] Ejecutar SFC /scannow
echo [3] Ejecutar DISM /ScanHealth
echo [4] Ejecutar DISM /RestoreHealth
echo [5] Ejecutar ScanHealth (y si hay errores -> RestoreHealth)
echo [6] CHKDSK con reparacion (/f /r)
echo [7] DISM StartComponentCleanup
echo [8] Ver servicios criticos (Windows Update, BITS)
echo [9] Forzar busqueda de actualizaciones
echo [10] Listar drivers instalados
echo [11] Informacion del sistema (systeminfo)
echo [12] Ver procesos activos (tasklist)
echo [13] Ejecutar TODOS los comandos del menu (con logica de ScanHealth -> RestoreHealth)
echo [0] Salir
echo.
set /p opcion=Seleccione una opcion: 

if "%opcion%"=="1" goto CHKDSK
if "%opcion%"=="2" goto SFC
if "%opcion%"=="3" goto SCANHEALTH
if "%opcion%"=="4" goto RESTOREHEALTH
if "%opcion%"=="5" goto BLOQUE5
if "%opcion%"=="6" goto CHKDSKFR
if "%opcion%"=="7" goto CLEANUP
if "%opcion%"=="8" goto SERVICIOS
if "%opcion%"=="9" goto UPDATE
if "%opcion%"=="10" goto DRIVERS
if "%opcion%"=="11" goto SYSINFO
if "%opcion%"=="12" goto TASKLIST
if "%opcion%"=="13" goto TODOALL
if "%opcion%"=="0" goto SALIR
goto MENU

:CHKDSK
call :log "Ejecutando CHKDSK en C:"
chkdsk C: >> "%LOGFILE%" 2>&1
pause
goto MENU

:SFC
call :log "Ejecutando SFC /scannow"
sfc /scannow >> "%LOGFILE%" 2>&1
pause
goto MENU

:SCANHEALTH
call :log "Ejecutando DISM /ScanHealth"
dism /online /cleanup-image /ScanHealth >> "%LOGFILE%" 2>&1
pause
goto MENU

:RESTOREHEALTH
call :log "Ejecutando DISM /RestoreHealth"
dism /online /cleanup-image /RestoreHealth >> "%LOGFILE%" 2>&1
pause
goto MENU

:BLOQUE5
call :log "Ejecutando ScanHealth con logica de RestoreHealth"
dism /online /cleanup-image /ScanHealth >> "%LOGFILE%" 2>&1
findstr /i "error corruption" "%LOGFILE%" >nul
if %errorlevel%==0 (
    call :log "Se detectaron errores, ejecutando DISM /RestoreHealth"
    dism /online /cleanup-image /RestoreHealth >> "%LOGFILE%" 2>&1
) else (
    call :log "No se detectaron errores en la imagen del sistema"
)
pause
goto MENU

:CHKDSKFR
call :log "Ejecutando CHKDSK con reparacion (/f /r) en C:"
chkdsk C: /f /r >> "%LOGFILE%" 2>&1
pause
goto MENU

:CLEANUP
call :log "Ejecutando DISM StartComponentCleanup"
dism /online /cleanup-image /startcomponentcleanup >> "%LOGFILE%" 2>&1
pause
goto MENU

:SERVICIOS
call :log "Verificando servicios criticos"
sc query wuauserv >> "%LOGFILE%" 2>&1
sc query bits >> "%LOGFILE%" 2>&1
pause
goto MENU

:UPDATE
call :log "Forzando busqueda de actualizaciones"
wuauclt /detectnow >> "%LOGFILE%" 2>&1
wuauclt /updatenow >> "%LOGFILE%" 2>&1
pause
goto MENU

:DRIVERS
call :log "Listando drivers instalados"
driverquery /v >> "%LOGFILE%" 2>&1
pause
goto MENU

:SYSINFO
call :log "Mostrando informacion del sistema"
systeminfo >> "%LOGFILE%" 2>&1
pause
goto MENU

:TASKLIST
call :log "Listando procesos activos"
tasklist >> "%LOGFILE%" 2>&1
pause
goto MENU

:TODOALL
call :log "Ejecutando TODOS los comandos del menu"
chkdsk C: >> "%LOGFILE%" 2>&1
sfc /scannow >> "%LOGFILE%" 2>&1
dism /online /cleanup-image /ScanHealth >> "%LOGFILE%" 2>&1
findstr /i "error corruption" "%LOGFILE%" >nul
if %errorlevel%==0 (
    call :log "Se detectaron errores, ejecutando DISM /RestoreHealth"
    dism /online /cleanup-image /RestoreHealth >> "%LOGFILE%" 2>&1
) else (
    call :log "No se detectaron errores en la imagen del sistema"
)
chkdsk C: /f /r >> "%LOGFILE%" 2>&1
dism /online /cleanup-image /startcomponentcleanup >> "%LOGFILE%" 2>&1
sc query wuauserv >> "%LOGFILE%" 2>&1
sc query bits >> "%LOGFILE%" 2>&1
wuauclt /detectnow >> "%LOGFILE%" 2>&1
wuauclt /updatenow >> "%LOGFILE%" 2>&1
driverquery /v >> "%LOGFILE%" 2>&1
systeminfo >> "%LOGFILE%" 2>&1
tasklist >> "%LOGFILE%" 2>&1
pause
goto MENU

:SALIR
call :log "Cerrando el menu"
exit

:: --- Función para log ---
:log
echo [%date% %time%] %~1
echo [%date% %time%] %~1 >> "%LOGFILE%"
goto :eof
