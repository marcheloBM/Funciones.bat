@echo off
setlocal enabledelayedexpansion

:: Archivo de log
set LOGFILE=%~dp0red_tools.log

:MENU
cls
echo =====================================
echo     OPTIMIZACION DE RED - MENU
echo =====================================
echo 1. Flush DNS
echo 2. Renovar IP (DHCP)
echo 3. Reiniciar Winsock
echo 4. Reiniciar TCP/IP
echo 5. Vaciar caché ARP
echo 6. Vaciar caché NetBIOS
echo 7. Salir
echo =====================================
set /p opt="Seleccione una opcion: "

if "%opt%"=="1" goto FLUSH_DNS
if "%opt%"=="2" goto RENEW_IP
if "%opt%"=="3" goto WINSOCK
if "%opt%"=="4" goto TCPIP
if "%opt%"=="5" goto ARP
if "%opt%"=="6" goto NETBIOS
if "%opt%"=="7" goto END
goto MENU

:FLUSH_DNS
call :log "Vaciando cache DNS..."
ipconfig /flushdns >> "%LOGFILE%" 2>&1
goto MENU

:RENEW_IP
call :log "Renovando configuracion IP..."
ipconfig /release >> "%LOGFILE%" 2>&1
ipconfig /renew >> "%LOGFILE%" 2>&1
goto MENU

:WINSOCK
call :log "Reiniciando Winsock..."
netsh winsock reset >> "%LOGFILE%" 2>&1
goto MENU

:TCPIP
call :log "Reiniciando TCP/IP..."
netsh int ip reset >> "%LOGFILE%" 2>&1
goto MENU

:ARP
call :log "Vaciando cache ARP..."
arp -d * >> "%LOGFILE%" 2>&1
goto MENU

:NETBIOS
call :log "Vaciando cache NetBIOS..."
nbtstat -R >> "%LOGFILE%" 2>&1
nbtstat -RR >> "%LOGFILE%" 2>&1
goto MENU

:END
echo Revisa el archivo de log en: %LOGFILE%
pause
call :log "Limpieza y diagnóstico completados con éxito"
call :log "Programado por MarcheBMPC."
endlocal
exit /b

:: --- Función para log y pantalla ---
:log
echo [%date% %time%] %~1
echo [%date% %time%] %~1 >> "%LOGFILE%"
goto :eof
