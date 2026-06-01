@echo off
:: Script para exportar e importar drivers con extras y fecha corregida
:: Requiere ejecución como Administrador

setlocal enabledelayedexpansion

:: Carpeta base en Documents\MarcheBMPC\Controladores
set BASE_DIR=%USERPROFILE%\Documents\MarcheBMPC\Controladores
set DRIVER_BACKUP=%BASE_DIR%\DriversBackup

:: Crear carpeta base si no existe
if not exist "%BASE_DIR%" mkdir "%BASE_DIR%"
if not exist "%DRIVER_BACKUP%" mkdir "%DRIVER_BACKUP%"

:: Obtener fecha y hora en formato AAAA-MM-DD_HH-MM (compatible Win10/11)
for /f %%i in ('powershell -command "Get-Date -Format yyyy-MM-dd_HH-mm"') do set FECHA_HORA=%%i

:menu
echo ============================================
echo   MENU DE DRIVERS
echo ============================================
echo 1. Exportar drivers instalados
echo 2. Importar drivers desde respaldo
echo 3. Abrir carpeta de respaldo
echo 4. Borrar respaldo anterior
echo 5. Salir
echo ============================================
set /p opcion=Elige una opción (1-5): 

if "%opcion%"=="1" goto exportar
if "%opcion%"=="2" goto importar
if "%opcion%"=="3" goto abrir
if "%opcion%"=="4" goto borrar
if "%opcion%"=="5" goto salir
goto menu

:exportar
:: Crear subcarpeta con fecha y hora corregida
set SUBFOLDER=%DRIVER_BACKUP%\%FECHA_HORA%
mkdir "%SUBFOLDER%"

echo Exportando drivers a "%SUBFOLDER%" ...
pnputil /export-driver * "%SUBFOLDER%"
echo Exportación completada.

:: Contar y listar drivers exportados
set count=0
for %%f in ("%SUBFOLDER%\*.inf") do (
    set /a count+=1
    echo Exportado: %%~nxf
)

echo ============================================
echo Se exportaron %count% drivers.
echo Respaldo guardado en: %SUBFOLDER%
echo ============================================

pause
goto menu

:importar
echo Importando drivers desde "%DRIVER_BACKUP%" ...
pnputil /add-driver "%DRIVER_BACKUP%\*.inf" /install
echo Importación completada.

:: Contar y listar drivers importados
set count=0
for %%f in ("%DRIVER_BACKUP%\*.inf") do (
    set /a count+=1
    echo Importado: %%~nxf
)

echo ============================================
echo Se intentaron importar %count% drivers.
echo ============================================

pause
goto menu

:abrir
echo Abriendo carpeta de respaldo...
explorer "%DRIVER_BACKUP%"
goto menu

:borrar
echo ============================================
echo ADVERTENCIA: Esta acción borrará todos los drivers respaldados.
set /p confirm=¿Estás seguro? (S/N): 
if /I "%confirm%"=="S" (
    echo Borrando respaldo anterior en "%DRIVER_BACKUP%" ...
    rmdir /s /q "%DRIVER_BACKUP%"
    mkdir "%DRIVER_BACKUP%"
    echo Respaldo anterior eliminado. Carpeta limpia lista para nueva exportación.
) else (
    echo Operación cancelada. No se borró nada.
)
pause
goto menu

:salir
endlocal
exit
