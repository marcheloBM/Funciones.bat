@echo off
setlocal

:: Elevación a administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Este script requiere privilegios de administrador.
    pause
    exit /b
)

:: --- Definir ruta del log ---
set LOGFILE=%USERPROFILE%\Documents\MarcheBMPC\limpieza_log.txt
echo Registro de limpieza iniciado > "%LOGFILE%"

call :log "Iniciando limpieza avanzada de PC..."

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
rd /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" >> "%LOGFILE%" 2>&1
rd /s /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" >> "%LOGFILE%" 2>&1
rd /s /q "%APPDATA%\Mozilla\Firefox\Profiles" >> "%LOGFILE%" 2>&1

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
ipconfig /flushdns
ipconfig /flushdns >> "%LOGFILE%" 2>&1

call :log "Limpieza completada con éxito"
call :log "Programado por MarcheBMPC."

timeout /t 5 >NUL
endlocal
exit /b

:: --- Función para log y pantalla ---
:log
echo %~1
echo %~1 >> "%LOGFILE%"
goto :eof
