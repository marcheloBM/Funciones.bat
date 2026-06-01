do {
    Clear-Host
    Write-Host "=============================="
    Write-Host "   BACKUP / RESTORE MENU"
    Write-Host "=============================="
    Write-Host "1. Backup todo (este equipo)"
    Write-Host "2. Restore todo (todos los equipos)"
    Write-Host "3. Restore equipo específico"
    Write-Host "4. Salir"
    Write-Host "=============================="

    $opcion = Read-Host "Seleccione opcion"

    switch ($opcion) {
        "1" {
            Write-Host "Iniciando backup de este equipo..."
            & "$PSScriptRoot\BackupRestore.ps1" -Mode backup
            Write-Host "✅ Backup completado. Revise el log para ver el total de programas respaldados."
        }
        "2" {
            $confirm = Read-Host "⚠️ ¿Está seguro que desea restaurar TODOS los equipos? (S/N)"
            if ($confirm -match "^[Ss]$") {
                Write-Host "Restaurando todos los equipos..."
                & "$PSScriptRoot\BackupRestore.ps1" -Mode restore -Target all
                Write-Host "✅ Restore completado. Revise el log para ver el total de programas restaurados."
            } else {
                Write-Host "Operación cancelada."
            }
        }
        "3" {
            $backupRoot = Join-Path $PSScriptRoot "Backups"
            if (!(Test-Path $backupRoot)) {
                Write-Host "No existe la carpeta de backups: $backupRoot"
            }
            else {
                $equipos = Get-ChildItem $backupRoot -Directory | Select-Object -ExpandProperty Name
                if ($equipos.Count -eq 0) {
                    Write-Host "No hay equipos con backups disponibles."
                }
                else {
                    Write-Host "Equipos disponibles:"
                    for ($i=0; $i -lt $equipos.Count; $i++) {
                        Write-Host "$i. $($equipos[$i])"
                    }

                    $sel = Read-Host "Ingrese el número del equipo a restaurar"
                    if ($sel -match '^\d+$' -and [int]$sel -lt $equipos.Count) {
                        $equipoSel = $equipos[$sel]
                        Write-Host "Restaurando equipo $equipoSel..."
                        & "$PSScriptRoot\BackupRestore.ps1" -Mode restore -Target $equipoSel
                        Write-Host "✅ Restore completado. Revise el log para ver el total de programas restaurados."
                    } else {
                        Write-Host "Selección inválida."
                    }
                }
            }
        }
        "4" {
            Write-Host "Saliendo..."
            break
        }
        default {
            Write-Host "Opción inválida."
        }
    }

    Write-Host ""
    Write-Host "Operación finalizada. Presione Enter para continuar..."
    Read-Host
} while ($true)
