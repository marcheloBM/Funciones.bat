@echo off
title Menu Maestro - Optimizaciones SSD y Memoria Virtual
color 0A

:MENU
cls
echo ============================================
echo        MENU MAESTRO DE OPTIMIZACIONES
echo ============================================
echo SSD:
echo   1. Verificar AHCI (abrir Administrador de dispositivos)
echo   2. Activar TRIM
echo   3. Desactivar Indexado (Windows Search)
echo   4. Desactivar Superfetch (SysMain)
echo   5. Desactivar Prefetch
echo   6. Desactivar ClearPageFileAtShutdown
echo   7. Activar Cache de escritura (Disco 0)
echo   8. Ejecutar TODAS las optimizaciones SSD
echo.
echo Memoria Virtual:
echo   9. Activar en C: (2048 y 3072 MB)
echo  10. Desactivar memoria virtual
echo  11. Mover a D: (3072 y 4096 MB)
echo.
echo  12. Salir
echo ============================================
set /p opcion=Elige una opcion (1-12): 

if "%opcion%"=="1" goto AHCI
if "%opcion%"=="2" goto TRIM
if "%opcion%"=="3" goto INDEXADO
if "%opcion%"=="4" goto SUPERFETCH
if "%opcion%"=="5" goto PREFETCH
if "%opcion%"=="6" goto CLEARPAGE
if "%opcion%"=="7" goto CACHE
if "%opcion%"=="8" goto TODO_SSD
if "%opcion%"=="9" goto MV_ACTIVAR
if "%opcion%"=="10" goto MV_DESACTIVAR
if "%opcion%"=="11" goto MV_MOVER
if "%opcion%"=="12" goto SALIR
goto MENU

:AHCI
echo Abriendo Administrador de dispositivos...
start devmgmt.msc
pause
goto MENU

:TRIM
echo Activando TRIM...
fsutil behavior set DisableDeleteNotify 0
pause
goto MENU

:INDEXADO
echo Desactivando servicio de indexado...
sc stop WSearch
sc config WSearch start= disabled
pause
goto MENU

:SUPERFETCH
echo Desactivando Superfetch...
sc stop SysMain
sc config SysMain start= disabled
pause
goto MENU

:PREFETCH
echo Desactivando Prefetch...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v EnablePrefetcher /t REG_DWORD /d 0 /f
pause
goto MENU

:CLEARPAGE
echo Desactivando ClearPageFileAtShutdown...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v ClearPageFileAtShutdown /t REG_DWORD /d 0 /f
pause
goto MENU

:CACHE
echo Activando cache de escritura en disco 0...
wmic diskdrive where Index=0 set EnableWriteCache=True
pause
goto MENU

:TODO_SSD
echo Ejecutando todas las optimizaciones SSD...
fsutil behavior set DisableDeleteNotify 0
sc stop WSearch
sc config WSearch start= disabled
sc stop SysMain
sc config SysMain start= disabled
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v EnablePrefetcher /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v ClearPageFileAtShutdown /t REG_DWORD /d 0 /f
wmic diskdrive where Index=0 set EnableWriteCache=True
echo Todas las optimizaciones SSD aplicadas.
pause
goto MENU

:MV_ACTIVAR
echo Activando memoria virtual en C: (2048 y3072 MB)...
wmic computersystem where name="%computername%" set AutomaticManagedPagefile=False
wmic pagefileset where name="C:\\pagefile.sys" set InitialSize=2048,MaximumSize=3072
echo Configuracion aplicada. Reinicia el sistema para que tenga efecto.
pause
goto MENU

:MV_DESACTIVAR
echo Desactivando memoria virtual...
wmic pagefileset delete
echo Memoria virtual desactivada. Reinicia el sistema para confirmar.
pause
goto MENU

:MV_MOVER
echo Moviendo memoria virtual a D: (3072 y 4096 MB)...
wmic computersystem where name="%computername%" set AutomaticManagedPagefile=False
wmic pagefileset delete
wmic pagefileset create name="D:\\pagefile.sys" InitialSize=3072,MaximumSize=4096
echo Archivo de paginacion creado en D:. Reinicia el sistema para aplicar cambios.
pause
goto MENU

:SALIR
echo Saliendo...
exit
