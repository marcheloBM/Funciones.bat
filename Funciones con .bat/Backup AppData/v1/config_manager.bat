@echo off
title Gestor de Configuraciones
color 0A

:: Elevación a administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Este script requiere privilegios de administrador.
    pause
    exit /b
)

:: Obtener marca del equipo
for /f %%i in ('powershell -command "(Get-CimInstance Win32_ComputerSystem).Manufacturer"') do set BRAND=%%i

:: Obtener fecha y hora en formato AAAA-MM-DD_HH-mm
for /f %%i in ('powershell -command "Get-Date -Format yyyy-MM-dd_HH-mm"') do set FECHA_HORA=%%i

:: Carpeta de destino = misma carpeta del .bat + marca (sin fecha)
set BACKUP=%~dp0Backups_%BRAND%
if not exist "%BACKUP%" mkdir "%BACKUP%"

:: ================================
:: RUTAS DE PROGRAMAS (EDITABLES)
:: ================================
set RUTA_ANDROIDSTUDIO=%USERPROFILE%\AppData\Roaming\Google\AndroidStudio*
set RUTA_GRADLE=%USERPROFILE%\.gradle
set RUTA_ANDROID=%USERPROFILE%\.android

set RUTA_FILEZILLA=%APPDATA%\FileZilla
set RUTA_NETBEANS=%APPDATA%\NetBeans

set RUTA_NOTEPADPP=%APPDATA%\Notepad++
set RUTA_NOTEPADPP_PLUGINS=C:\Program Files\Notepad++\plugins
set RUTA_NOTEPADPP_THEMES=C:\Program Files\Notepad++\themes

set RUTA_OBS=%APPDATA%\obs-studio
set RUTA_OBS_DISTROAV=C:\ProgramData\obs-studio\plugins\distroav
set RUTA_OBS_DATA=C:\Program Files\obs-studio\data
set RUTA_OBS_PLUGINS=C:\Program Files\obs-studio\obs-plugins

:menu
cls
echo ================================
echo   Gestor de Configuraciones
echo ================================
echo [1] Backup TODO
echo [2] Restore TODO
echo [3] Salir
echo ================================
set /p option=Elige una opcion: 

if "%option%"=="1" goto backup_all
if "%option%"=="2" goto restore_all
if "%option%"=="3" goto salir
goto menu

:: ---------------- FUNCION DE COPIA ----------------
:CopyIfExist
:: %~1 = ruta origen
:: %~2 = ruta destino
:: %~3 = archivo log
:: %~4 = nombre del programa

if exist "%~1" (
    echo Copiando %~4 desde %~1 >> "%~3"
    xcopy "%~1" "%~2" /E /I /Y >> "%~3"
    echo [OK] Copiado: %~4
) else (
    echo [AVISO] Carpeta no encontrada para %~4 >> "%~3"
    echo [AVISO] No se pudo copiar porque %~4 no está instalado en este equipo.
)
goto :eof


:: ---------------- COMPRESION GENERICA ----------------
:compress_folder
set CARPETA=%~1
set ARCHIVO=%~2

echo Iniciando compresion de %CARPETA%...

:: Cambiar al directorio donde está el .bat
pushd %~dp0

if exist "C:\Program Files\7-Zip\7z.exe" (
    echo Usando 7-Zip...
    "C:\Program Files\7-Zip\7z.exe" a -tzip "%ARCHIVO%" "%~nx1" -mx9
    goto :compress_done
)

if exist "C:\Program Files\WinRAR\WinRAR.exe" (
    echo Usando WinRAR...
    "C:\Program Files\WinRAR\WinRAR.exe" a "%ARCHIVO%" "%~nx1"
    goto :compress_done
)

echo Usando compresion nativa de Windows...
powershell -command "Compress-Archive -Path '%~nx1' -DestinationPath '%ARCHIVO%' -Force"

:compress_done
popd
echo [OK] Carpeta comprimida en: %ARCHIVO%

:: Eliminar carpeta original después de comprimir
echo Eliminando carpeta original: %CARPETA%
rmdir /S /Q "%CARPETA%"

goto :eof

:: ---------------- BACKUP TODO ----------------
:backup_all
set LOG=%BACKUP%\backup_log.txt
echo Backup completo iniciado en %DATE% > "%LOG%"

for /d %%D in ("%RUTA_ANDROIDSTUDIO%") do (
    call :CopyIfExist "%%D" "%BACKUP%\AndroidStudio\%%~nxD" "%LOG%" "Android Studio"
)
call :CopyIfExist "%RUTA_GRADLE%" "%BACKUP%\Gradle" "%LOG%" "Gradle"
call :CopyIfExist "%RUTA_ANDROID%" "%BACKUP%\Android" "%LOG%" "Android SDK"
call :CopyIfExist "%RUTA_FILEZILLA%" "%BACKUP%\FileZilla" "%LOG%" "FileZilla"
call :CopyIfExist "%RUTA_NETBEANS%" "%BACKUP%\NetBeans" "%LOG%" "NetBeans"
call :CopyIfExist "%RUTA_NOTEPADPP%" "%BACKUP%\Notepad++" "%LOG%" "Notepad++"
call :CopyIfExist "%RUTA_OBS%" "%BACKUP%\OBS" "%LOG%" "OBS Studio"
call :CopyIfExist "%RUTA_NOTEPADPP_PLUGINS%" "%BACKUP%\Notepad++_plugins" "%LOG%" "Notepad++ Plugins"
call :CopyIfExist "%RUTA_NOTEPADPP_THEMES%" "%BACKUP%\Notepad++_themes" "%LOG%" "Notepad++ Themes"
call :CopyIfExist "%RUTA_OBS_DISTROAV%" "%BACKUP%\OBS_distroav" "%LOG%" "OBS DistroAV"
call :CopyIfExist "%RUTA_OBS_DATA%" "%BACKUP%\OBS_data" "%LOG%" "OBS Data"
call :CopyIfExist "%RUTA_OBS_PLUGINS%" "%BACKUP%\OBS_plugins" "%LOG%" "OBS Plugins"

echo Backup completo finalizado.

:: Comprimir y eliminar carpeta BACKUP como raíz
call :compress_folder "%BACKUP%" "%~dp0Backup_%BRAND%.zip"

pause
goto menu

:: ---------------- RESTORE PREVENTIVO ----------------
:PreRestoreBackup
set PREV_BACKUP=%~dp0PrevRestore_%BRAND%
mkdir "%PREV_BACKUP%"
set LOG=%PREV_BACKUP%\pre_restore_log.txt
echo Respaldo preventivo antes de restaurar > "%LOG%"

call :CopyIfExist "%RUTA_GRADLE%" "%PREV_BACKUP%\Gradle" "%LOG%" "Gradle"
call :CopyIfExist "%RUTA_ANDROID%" "%PREV_BACKUP%\Android" "%LOG%" "Android SDK"
call :CopyIfExist "%RUTA_FILEZILLA%" "%PREV_BACKUP%\FileZilla" "%LOG%" "FileZilla"
call :CopyIfExist "%RUTA_NETBEANS%" "%PREV_BACKUP%\NetBeans" "%LOG%" "NetBeans"
call :CopyIfExist "%RUTA_NOTEPADPP%" "%PREV_BACKUP%\Notepad++" "%LOG%" "Notepad++"
call :CopyIfExist "%RUTA_OBS%" "%PREV_BACKUP%\OBS" "%LOG%" "OBS Studio"
call :CopyIfExist "%RUTA_NOTEPADPP_PLUGINS%" "%PREV_BACKUP%\Notepad++_plugins" "%LOG%" "Notepad++ Plugins"
call :CopyIfExist "%RUTA_NOTEPADPP_THEMES%" "%PREV_BACKUP%\Notepad++_themes" "%LOG%" "Notepad++ Themes"
call :CopyIfExist "%RUTA_OBS_DISTROAV%" "%PREV_BACKUP%\OBS_distroav" "%LOG%" "OBS DistroAV"
call :CopyIfExist "%RUTA_OBS_DATA%" "%PREV_BACKUP%\OBS_data" "%LOG%" "OBS Data"
call :CopyIfExist "%RUTA_OBS_PLUGINS%" "%PREV_BACKUP%\OBS_plugins" "%LOG%" "OBS Plugins"

echo [OK] Respaldo preventivo guardado en %PREV_BACKUP%

:: Comprimir y eliminar carpeta PREV_BACKUP como raíz
call :compress_folder "%PREV_BACKUP%" "%~dp0PrevRestore_%BRAND%.zip"

goto :eof

:: ---------------- RESTORE TODO ----------------
:restore_all
cls
echo ================================
echo   Restaurar Configuraciones
echo ================================
echo Buscando backups disponibles...
echo.

:: Listar archivos ZIP de backup
setlocal enabledelayedexpansion
set COUNT=0
for %%F in ("%~dp0Backup_*.zip") do (
    set /a COUNT+=1
    echo [!COUNT!] %%~nxF
    set "BACKUP_FILE[!COUNT!]=%%F"
)
if %COUNT%==0 (
    echo No se encontraron backups en la carpeta.
    pause
    goto menu
)

echo ================================
set /p CHOICE=Elige el numero de backup: 

set "SELECTED_BACKUP=!BACKUP_FILE[%CHOICE%]!"
if "%SELECTED_BACKUP%"=="" (
    echo Opcion invalida.
    pause
    goto restore_all
)

echo Has elegido: %SELECTED_BACKUP%
echo.

:: Extraer backup elegido a carpeta temporal
set RESTORE_DIR=%~dp0RestoreTemp
if exist "%RESTORE_DIR%" rmdir /S /Q "%RESTORE_DIR%"
mkdir "%RESTORE_DIR%"

echo Extrayendo backup...

:: Cambiar al directorio del .bat
pushd %~dp0

:: Si existe 7-Zip
if exist "C:\Program Files\7-Zip\7z.exe" (
    echo Usando 7-Zip para extraer...
    "C:\Program Files\7-Zip\7z.exe" x "%SELECTED_BACKUP%" -o"%RESTORE_DIR%" -y
    goto :extract_done
)

:: Si existe WinRAR
if exist "C:\Program Files\WinRAR\WinRAR.exe" (
    echo Usando WinRAR para extraer...
    "C:\Program Files\WinRAR\WinRAR.exe" x "%SELECTED_BACKUP%" "%RESTORE_DIR%\" -y
    goto :extract_done
)

:: Si no hay 7-Zip ni WinRAR, usar PowerShell
echo Usando extraccion nativa de Windows...
powershell -command "Expand-Archive -Path '%SELECTED_BACKUP%' -DestinationPath '%RESTORE_DIR%' -Force"

:extract_done
popd
echo [OK] Backup extraido en: %RESTORE_DIR%

:: Submenu de restauracion
:restore_menu
cls
echo ================================
echo   Restaurar desde %SELECTED_BACKUP%
echo ================================
echo [1] Restaurar TODO
echo [2] Restaurar Android Studio
echo [3] Restaurar Gradle
echo [4] Restaurar Android SDK
echo [5] Restaurar FileZilla
echo [6] Restaurar NetBeans
echo [7] Restaurar Notepad++
echo [8] Restaurar OBS Studio
echo [9] Restaurar Notepad++ Plugins
echo [10] Restaurar Notepad++ Themes
echo [11] Restaurar OBS DistroAV
echo [12] Restaurar OBS Data
echo [13] Restaurar OBS Plugins
echo [14] Volver al menu principal
echo ================================
set /p ROPTION=Elige una opcion: 

if "%ROPTION%"=="1" goto restore_all_programs
if "%ROPTION%"=="2" call :CopyIfExist "%RESTORE_DIR%\Backups_%BRAND%_%FECHA_HORA%\AndroidStudio" "%RUTA_ANDROIDSTUDIO%" "%RESTORE_DIR%\restore_log.txt" "Android Studio"
if "%ROPTION%"=="3" call :CopyIfExist "%RESTORE_DIR%\Backups_%BRAND%_%FECHA_HORA%\Gradle" "%RUTA_GRADLE%" "%RESTORE_DIR%\restore_log.txt" "Gradle"
if "%ROPTION%"=="4" call :CopyIfExist "%RESTORE_DIR%\Backups_%BRAND%_%FECHA_HORA%\Android" "%RUTA_ANDROID%" "%RESTORE_DIR%\restore_log.txt" "Android SDK"
if "%ROPTION%"=="5" call :CopyIfExist "%RESTORE_DIR%\Backups_%BRAND%_%FECHA_HORA%\FileZilla" "%RUTA_FILEZILLA%" "%RESTORE_DIR%\restore_log.txt" "FileZilla"
if "%ROPTION%"=="6" call :CopyIfExist "%RESTORE_DIR%\Backups_%BRAND%_%FECHA_HORA%\NetBeans" "%RUTA_NETBEANS%" "%RESTORE_DIR%\restore_log.txt" "NetBeans"
if "%ROPTION%"=="7" call :CopyIfExist "%RESTORE_DIR%\Backups_%BRAND%_%FECHA_HORA%\Notepad++" "%RUTA_NOTEPADPP%" "%RESTORE_DIR%\restore_log.txt" "Notepad++"
if "%ROPTION%"=="8" call :CopyIfExist "%RESTORE_DIR%\Backups_%BRAND%_%FECHA_HORA%\OBS" "%RUTA_OBS%" "%RESTORE_DIR%\restore_log.txt" "OBS Studio"
if "%ROPTION%"=="9" call :CopyIfExist "%RESTORE_DIR%\Backups_%BRAND%_%FECHA_HORA%\Notepad++_plugins" "%RUTA_NOTEPADPP_PLUGINS%" "%RESTORE_DIR%\restore_log.txt" "Notepad++ Plugins"
if "%ROPTION%"=="10" call :CopyIfExist "%RESTORE_DIR%\Backups_%BRAND%_%FECHA_HORA%\Notepad++_themes" "%RUTA_NOTEPADPP_THEMES%" "%RESTORE_DIR%\restore_log.txt" "Notepad++ Themes"
if "%ROPTION%"=="11" call :CopyIfExist "%RESTORE_DIR%\Backups_%BRAND%_%FECHA_HORA%\OBS_distroav" "%RUTA_OBS_DISTROAV%" "%RESTORE_DIR%\restore_log.txt" "OBS DistroAV"
if "%ROPTION%"=="12" call :CopyIfExist "%RESTORE_DIR%\Backups_%BRAND%_%FECHA_HORA%\OBS_data" "%RUTA_OBS_DATA%" "%RESTORE_DIR%\restore_log.txt" "OBS Data"
if "%ROPTION%"=="13" call :CopyIfExist "%RESTORE_DIR%\Backups_%BRAND%_%FECHA_HORA%\OBS_plugins" "%RUTA_OBS_PLUGINS%" "%RESTORE_DIR%\restore_log.txt" "OBS Plugins"
if "%ROPTION%"=="14" goto menu

pause
goto restore_menu

:: Restaurar todo
:restore_all_programs
echo Restaurando todos los programas desde %SELECTED_BACKUP%...
call :CopyIfExist "%RESTORE_DIR%\Backups_%BRAND%_%FECHA_HORA%\AndroidStudio" "%RUTA_ANDROIDSTUDIO%" "%RESTORE_DIR%\restore_log.txt" "Android Studio"
call :CopyIfExist "%RESTORE_DIR%\Backups_%BRAND%_%FECHA_HORA%\Gradle" "%RUTA_GRADLE%" "%RESTORE_DIR%\restore_log.txt" "Gradle"
call :CopyIfExist "%RESTORE_DIR%\Backups_%BRAND%_%FECHA_HORA%\Android" "%RUTA_ANDROID%" "%RESTORE_DIR%\restore_log.txt" "Android SDK"
call :CopyIfExist "%RESTORE_DIR%\Backups_%BRAND%_%FECHA_HORA%\FileZilla" "%RUTA_FILEZILLA%" "%RESTORE_DIR%\restore_log.txt" "FileZilla"
call :CopyIfExist "%RESTORE_DIR%\Backups_%BRAND%_%FECHA_HORA%\NetBeans" "%RUTA_NETBEANS%" "%RESTORE_DIR%\restore_log.txt" "NetBeans"
call :CopyIfExist "%RESTORE_DIR%\Backups_%BRAND%_%FECHA_HORA%\Notepad++" "%RUTA_NOTEPADPP%" "%RESTORE_DIR%\restore_log.txt" "Notepad++"
call :CopyIfExist "%RESTORE_DIR%\Backups_%BRAND%_%FECHA_HORA%\OBS" "%RUTA_OBS%" "%RESTORE_DIR%\restore_log.txt" "OBS Studio"
call :CopyIfExist "%RESTORE_DIR%\Backups_%BRAND%_%FECHA_HORA%\Notepad++_plugins" "%RUTA_NOTEPADPP_PLUGINS%" "%RESTORE_DIR%\restore_log.txt" "Notepad++ Plugins"
call :CopyIfExist "%RESTORE_DIR%\Backups_%BRAND%_%FECHA_HORA%\Notepad++_themes" "%RUTA_NOTEPADPP_THEMES%" "%RESTORE_DIR%\restore_log.txt" "Notepad++ Themes"
call :CopyIfExist "%RESTORE_DIR%\Backups_%BRAND%_%FECHA_HORA%\OBS_distroav" "%RUTA_OBS_DISTROAV%" "%RESTORE_DIR%\restore_log.txt" "OBS DistroAV"
call :CopyIfExist "%RESTORE_DIR%\Backups_%BRAND%_%FECHA_HORA%\OBS_data" "%RUTA_OBS_DATA%" "%RESTORE_DIR%\restore_log.txt" "OBS Data"
call :CopyIfExist "%RESTORE_DIR%\Backups_%BRAND%_%FECHA_HORA%\OBS_plugins" "%RUTA_OBS_PLUGINS%" "%RESTORE_DIR%\restore_log.txt" "OBS Plugins"

echo Restauracion completa finalizada.
pause
goto menu


:salir
exit
