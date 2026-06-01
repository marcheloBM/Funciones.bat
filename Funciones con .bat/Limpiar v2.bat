@echo off
setlocal

:: Relanzar con prioridad alta
if "%~1"=="" (
    start "" /high "%~f0" relanzado
    exit
)

:: --- Elevación a administrador ---
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Este script requiere privilegios de administrador.
    pause
    exit /b
)

:: --- Definir ruta del log con fecha y hora ---
set LOGDIR=%USERPROFILE%\Documents\MarcheBMPC
if not exist "%LOGDIR%" mkdir "%LOGDIR%"

:: Formato YYYY-MM-DD_HH-MM
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do set FECHA=%%c-%%b-%%a
for /f "tokens=1-2 delims=: " %%a in ('time /t') do set HORA=%%a-%%b
set LOGFILE=%LOGDIR%\limpieza_%FECHA%_%HORA%.txt

echo Registro de limpieza iniciado > "%LOGFILE%"

call :log "Iniciando limpieza avanzada de PC..."

:: --- LIMPIEZAS EXISTENTES ---

:: 1. Carpeta temporal del sistema
if exist "%windir%\Temp" (
    call :log "Limpiando carpeta temporal del sistema..."
    del /f /s /q "%windir%\Temp\*.*" >> "%LOGFILE%" 2>&1
    for /d %%D in ("%windir%\Temp\*") do rd /s /q "%%D" >> "%LOGFILE%" 2>&1
)

:: 2. Carpeta temporal del usuario
if exist "%TEMP%" (
    call :log "Limpiando carpeta temporal del usuario..."
    del /f /s /q "%TEMP%\*.*" >> "%LOGFILE%" 2>&1
    for /d %%D in ("%TEMP%\*") do rd /s /q "%%D" >> "%LOGFILE%" 2>&1
)

:: 3. Prefetch
if exist "%windir%\Prefetch" (
    call :log "Borrando Prefetch..."
    del /f /s /q "%windir%\Prefetch\*.*" >> "%LOGFILE%" 2>&1
    for /d %%D in ("%windir%\Prefetch\*") do rd /s /q "%%D" >> "%LOGFILE%" 2>&1
)

:: 4. Papelera de reciclaje
call :log "Vaciando papelera de reciclaje..."
powershell -NoProfile -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >> "%LOGFILE%" 2>&1

:: 5. Caché de navegadores
call :log "Limpiando cache de navegadores..."
:: Google Chrome
rd /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" >> "%LOGFILE%" 2>&1
:: Microsoft Edge
rd /s /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" >> "%LOGFILE%" 2>&1
:: Mozilla Firefox (perfiles completos)
rd /s /q "%APPDATA%\Mozilla\Firefox\Profiles" >> "%LOGFILE%" 2>&1
:: Brave
rd /s /q "%LOCALAPPDATA%\BraveSoftware\Brave-Browser\User Data\Default\Cache" >> "%LOGFILE%" 2>&1
:: Opera
rd /s /q "%APPDATA%\Opera Software\Opera Stable\Cache" >> "%LOGFILE%" 2>&1
:: Vivaldi
rd /s /q "%LOCALAPPDATA%\Vivaldi\User Data\Default\Cache" >> "%LOGFILE%" 2>&1


:: 6. Logs de Windows
call :log "Eliminando logs de Windows..."
del /f /s /q "%windir%\Logs\*.*" >> "%LOGFILE%" 2>&1

:: 7. Archivos de Windows Update
call :log "Limpiando archivos de Windows Update..."
net stop wuauserv >> "%LOGFILE%" 2>&1
rd /s /q "%windir%\SoftwareDistribution\Download" >> "%LOGFILE%" 2>&1
net start wuauserv >> "%LOGFILE%" 2>&1

:: 8. Miniaturas (Thumbs.db y caché de Explorer)
call :log "Borrando miniaturas..."
del /f /s /q "%userprofile%\AppData\Local\Microsoft\Windows\Explorer\thumbcache_*.*" >> "%LOGFILE%" 2>&1

:: 9. Volcados de memoria
call :log "Eliminando volcados de memoria..."
del /f /s /q "%SystemRoot%\MEMORY.DMP" >> "%LOGFILE%" 2>&1

:: 10. Flush DNS
call :log "Vaciando caché DNS..."
ipconfig /flushdns >> "%LOGFILE%" 2>&1

:: 11. Reportes de errores (WER)
call :log "Eliminando reportes de errores (WER)..."
rd /s /q "%ProgramData%\Microsoft\Windows\WER" >> "%LOGFILE%" 2>&1

:: 12. Caché de drivers
call :log "Eliminando caché de drivers..."
rd /s /q "%SystemRoot%\System32\DriverStore\FileRepository" >> "%LOGFILE%" 2>&1

:: 13. Liberador de espacio en disco (requiere configuración previa)
call :log "Ejecutando Liberador de espacio en disco..."
cleanmgr /sagerun:1 >> "%LOGFILE%" 2>&1

:: --- NUEVAS OPCIONES DE DIAGNOSTICO ---

:: A. DISM StartComponentCleanup
call :log "Ejecutando DISM StartComponentCleanup..."
dism /online /cleanup-image /startcomponentcleanup >> "%LOGFILE%" 2>&1

:: B. Forzar búsqueda de actualizaciones
call :log "Forzando búsqueda de actualizaciones..."
wuauclt /detectnow >> "%LOGFILE%" 2>&1
wuauclt /updatenow >> "%LOGFILE%" 2>&1

:: C. Verificar servicios críticos (Windows Update y BITS)
call :log "Verificando servicios críticos..."
sc query wuauserv >> "%LOGFILE%" 2>&1
sc query bits >> "%LOGFILE%" 2>&1

:: D. Listar drivers instalados
call :log "Listando drivers instalados..."
driverquery /v >> "%LOGFILE%" 2>&1

:: E. Información del sistema
call :log "Mostrando información del sistema..."
systeminfo >> "%LOGFILE%" 2>&1

:: F. Procesos activos
call :log "Listando procesos activos..."
tasklist >> "%LOGFILE%" 2>&1

:: --- RESUMEN FINAL ---
echo.
echo ================================
echo   RESUMEN DE LIMPIEZA Y DIAGNOSTICO
echo ================================
echo - Limpieza de temporales, Prefetch y logs
echo - Vaciado de papelera y DNS
echo - Eliminación de volcados y reportes WER
echo - Caché de navegadores (Chrome, Edge, Firefox, Brave, Opera, Vivaldi)
echo - Caché de drivers y Windows Update
echo - DISM StartComponentCleanup
echo - Forzar búsqueda de actualizaciones
echo - Verificación de servicios críticos
echo - Listado de drivers instalados
echo - Información del sistema
echo - Procesos activos
echo ================================
echo Revisa el archivo de log en: %LOGFILE%
pause
exit

call :log "Limpieza y diagnóstico completados con éxito"
call :log "Programado por MarcheBMPC."

endlocal
exit /b

:: --- Función para log y pantalla ---
:log
echo [%date% %time%] %~1
echo [%date% %time%] %~1 >> "%LOGFILE%"
goto :eof
