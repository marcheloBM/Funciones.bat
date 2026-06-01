@echo off
title Actualización de aplicaciones con Winget
setlocal

REM Carpeta base: Documentos\MarcheBMPC
set BASEDIR=%USERPROFILE%\Documents\MarcheBMPC

REM Carpeta UpdateProgramas dentro de MarcheBMPC
set CONTROLADORES=%BASEDIR%\UpdateProgramas
@echo off
title Actualización de aplicaciones con Winget
setlocal

REM Carpeta base: Documentos\MarcheBMPC
set BASEDIR=%USERPROFILE%\Documents\MarcheBMPC

REM Carpeta UpdateProgramas dentro de MarcheBMPC
set CONTROLADORES=%BASEDIR%\UpdateProgramas
set LOGDIR=%CONTROLADORES%\Logs
set LOGFILE=%LOGDIR%\Winget.log

REM Detectar marca del equipo con PowerShell
for /f "usebackq tokens=* delims=" %%M in (`powershell -NoProfile -Command "(Get-WmiObject Win32_ComputerSystem).Manufacturer"`) do set MARCA=%%M

REM Si no se detecta, pedir manualmente
if "%MARCA%"=="" set /p MARCA=Ingrese la marca del equipo: 

REM Obtener fecha y hora en formato YYYY-MM-DD_HH-mm-ss con PowerShell
for /f %%D in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd_HH-mm-ss"') do set FECHA=%%D

REM Carpeta específica por marca
set MARCADIR=%CONTROLADORES%\%MARCA%
set EXPORTFILE=%MARCADIR%\%MARCA%_%FECHA%.json

REM Crear carpetas si no existen
if not exist "%CONTROLADORES%" mkdir "%CONTROLADORES%"
if not exist "%LOGDIR%" mkdir "%LOGDIR%"
if not exist "%MARCADIR%" mkdir "%MARCADIR%"

:MENU
cls
echo ============================================
echo   Actualización de aplicaciones con Winget
echo ============================================
echo.
echo 1. Ver aplicaciones con actualizaciones disponibles
echo 2. Actualizar todas las aplicaciones (modo normal)
echo 3. Actualizar todas las aplicaciones (incluyendo unknown)
echo 4. Exportar lista de programas instalados
echo 5. Importar lista de programas desde archivo
echo 6. Salir
echo.
set /p opcion=Elige una opción (1-6): 

if "%opcion%"=="1" goto LISTAR
if "%opcion%"=="2" goto ACTUALIZAR
if "%opcion%"=="3" goto ACTUALIZARUNKNOWN
if "%opcion%"=="4" goto EXPORTAR
if "%opcion%"=="5" goto IMPORTAR
if "%opcion%"=="6" goto SALIR
goto MENU

:LISTAR
cls
echo Listando aplicaciones con actualizaciones disponibles...
echo [%DATE% %TIME%] Consultando actualizaciones disponibles >> "%LOGFILE%"
powershell -command "winget upgrade | Tee-Object -FilePath '%LOGFILE%' -Append"

echo.
echo Resultado guardado en %LOGFILE%
pause
goto MENU

:ACTUALIZAR
cls
echo Actualizando todas las aplicaciones (modo normal)...
echo [%DATE% %TIME%] Iniciando actualizacion de aplicaciones (normal) >> "%LOGFILE%"
powershell -command "winget upgrade --all --accept-source-agreements --accept-package-agreements | Tee-Object -FilePath '%LOGFILE%' -Append"

echo.
echo Actualización completada. Revisa %LOGFILE% para detalles.
pause
goto MENU

:ACTUALIZARUNKNOWN
cls
echo Actualizando todas las aplicaciones (incluyendo unknown)...
echo [%DATE% %TIME%] Iniciando actualizacion de aplicaciones (include-unknown) >> "%LOGFILE%"
powershell -command "winget upgrade --all --include-unknown --accept-source-agreements --accept-package-agreements | Tee-Object -FilePath '%LOGFILE%' -Append"

echo.
echo Actualización completada (incluyendo unknown). Revisa %LOGFILE% para detalles.
pause
goto MENU

:EXPORTAR
cls
echo Exportando lista de programas instalados a %EXPORTFILE%...
echo [%DATE% %TIME%] Exportando lista de programas >> "%LOGFILE%"
powershell -command "winget export -o '%EXPORTFILE%' | Tee-Object -FilePath '%LOGFILE%' -Append"

echo.
echo Exportación completada. Archivo guardado en %EXPORTFILE%
pause
goto MENU

:IMPORTAR
cls
echo Importando lista de programas desde %EXPORTFILE%...
echo [%DATE% %TIME%] Importando lista de programas >> "%LOGFILE%"
powershell -command "winget import '%EXPORTFILE%' | Tee-Object -FilePath '%LOGFILE%' -Append"

echo.
echo Importación completada. Revisa %LOGFILE% para detalles.
pause
goto MENU

:SALIR
cls
echo ============================================
echo   Salida del programa
echo ============================================
echo.

REM Eliminar copias antiguas de .json y dejar solo la última
echo.
echo Limpiando copias antiguas de archivos JSON...
pushd "%MARCADIR%"
for %%F in (*.json) do (
    if /I not "%%F"=="%MARCA%_%FECHA%.json" del "%%F"
)
popd

echo Limpieza completada. Se mantiene el archivo más reciente: %MARCA%_%FECHA%.json

REM Preguntar si abrir el log
set /p verlog=¿Quieres abrir el archivo de log antes de salir (S/N)? 
if /I "%verlog%"=="S" start notepad "%LOGFILE%"

REM Revisar si hay errores en el log
echo.
findstr /I "error failed" "%LOGFILE%" >nul
if %errorlevel%==0 (
    set /p vererror=Se detectaron errores en el log. ¿Quieres abrirlo para ver detalles (S/N)? 
    if /I "%vererror%"=="S" start notepad "%LOGFILE%"
)

pause

endlocal
exit