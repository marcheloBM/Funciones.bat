@echo off
title Consulta de clave en Registro
setlocal

REM Ruta del registro a consultar
set REGPATH=HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform

REM Nombre de la clave que quieres leer
set REGKEY=BackupProductKeyDefault

REM Nombre del archivo de salida con el nombre del equipo
set RESULTFILE=resultado_registro_%COMPUTERNAME%.txt

echo ============================================
echo   Consulta de Registro (SoftwareProtectionPlatform)
echo ============================================
echo Equipo: %COMPUTERNAME%
echo.

REM Consultar el valor y capturarlo
for /f "tokens=2,*" %%A in ('reg query "%REGPATH%" /v "%REGKEY%" 2^>nul') do (
    set VALOR=%%B
)

if defined VALOR (
    echo La clave encontrada es: %VALOR%
    echo [%DATE% %TIME%] Clave %REGKEY% = %VALOR% >> "%RESULTFILE%"
) else (
    echo No se encontró la clave "%REGKEY%" en %REGPATH%.
    echo [%DATE% %TIME%] Clave %REGKEY% no encontrada >> "%RESULTFILE%"
)

echo.
echo Resultado guardado en %RESULTFILE%
echo Abriendo archivo de resultados...
start notepad "%RESULTFILE%"

pause
endlocal
