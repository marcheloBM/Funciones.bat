@echo off
:: Script de optimización SSD basado en el video
:: Ejecutar como Administrador

:: 1. AHCI 
echo === Verificación AHCI ===
echo Este script abrirá el Administrador de dispositivos.
echo Revisa en "Controladoras ATA/ATAPI IDE" que aparezca:
echo -> Controladora SATA AHCI estándar
echo.
pause
start devmgmt.msc


:: 1. Verificar TRIM
fsutil behavior query DisableDeleteNotify
if %errorlevel%==0 (
    echo TRIM ya esta activo
) else (
    echo Activando TRIM...
    fsutil behavior set DisableDeleteNotify 0
)

:: 2. Desactivar Indexado (Windows Search)
echo Desactivando servicio de indexado...
sc stop WSearch
sc config WSearch start= disabled

:: 3. Desactivar Superfetch (SysMain)
echo Desactivando Superfetch...
sc stop SysMain
sc config SysMain start= disabled

:: 4. Deshabilitar Prefetch vía registro
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v EnablePrefetcher /t REG_DWORD /d 0 /f

:: 5. Deshabilitar ClearPageFileAtShutdown
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v ClearPageFileAtShutdown /t REG_DWORD /d 0 /f

:: 6. Configurar caché de escritura (ejemplo en disco 0)
echo Activando cache de escritura en disco 0...
wmic diskdrive where Index=0 set EnableWriteCache=True

echo === OPTIMIZACION COMPLETA ===
pause
