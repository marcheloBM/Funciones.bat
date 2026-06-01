Clear-Host
Write-Host "=============================="
Write-Host "   BACKUP / RESTORE MENU"
Write-Host "=============================="
Write-Host "1. Backup todo (programas agrupados)"
Write-Host "2. Restore todo (todos los equipos)"
Write-Host "3. Restore equipo específico"
Write-Host "4. Salir"
Write-Host "=============================="

$opcion = Read-Host "Seleccione opcion"

switch ($opcion) {
    "1" {
        Write-Host "Iniciando backup de todos los programas agrupados..."
        & "$PSScriptRoot\BackupRestore.ps1" -Mode backup
        Write-Host "Backup finalizado."
    }
    "2" {
        Write-Host "Restaurando todos los programas agrupados de todos los equipos..."
        & "$PSScriptRoot\BackupRestore.ps1" -Mode restore -Target all
        Write-Host "Restore finalizado."
    }
    "3" {
        $backupRoot = "F:\Backup AppData\Backups"
        if (!(Test-Path $backupRoot)) {
            Write-Host "No existe la carpeta de backups: $backupRoot"
            return
        }

        $equipos = Get-ChildItem $backupRoot -Directory | Select-Object -ExpandProperty Name
        if ($equipos.Count -eq 0) {
            Write-Host "No hay equipos con backups disponibles."
            return
        }

        Write-Host "Equipos disponibles:"
        for ($i=0; $i -lt $equipos.Count; $i++) {
            Write-Host "$i. $($equipos[$i])"
        }

        $sel = Read-Host "Ingrese el número del equipo a restaurar"
        if ($sel -match '^\d+$' -and [int]$sel -lt $equipos.Count) {
            $equipoSel = $equipos[$sel]
            Write-Host "Restaurando todos los programas agrupados del equipo $equipoSel..."
            & "$PSScriptRoot\BackupRestore.ps1" -Mode restore -Target $equipoSel
            Write-Host "Restore finalizado."
        } else {
            Write-Host "Selección inválida."
        }
    }
    "4" {
        Write-Host "Saliendo..."
        exit
    }
    default {
        Write-Host "Opción inválida."
    }
}
