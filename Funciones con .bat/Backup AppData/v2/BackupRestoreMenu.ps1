# BackupRestoreMenu.ps1
# Menu interactivo para BackupRestore.ps1 con seleccion de equipo

$ScriptPath = Join-Path $PSScriptRoot "BackupRestore.ps1"

function Show-Menu {
    Clear-Host
    Write-Host "==============================="
    Write-Host "   BACKUP / RESTORE MENU"
    Write-Host "==============================="
    Write-Host "1. Backup todo (este equipo)"
    Write-Host "2. Restore todo (todos los equipos)"
    Write-Host "3. Restore equipo especifico"
    Write-Host "4. Salir"
    Write-Host "==============================="
}

function Select-Team {
    $BackupDir = Join-Path $PSScriptRoot "Backups"
    $dirs = Get-ChildItem $BackupDir -Directory
    if ($dirs.Count -eq 0) {
        Write-Host "No hay equipos disponibles."
        return $null
    }
    Write-Host "Equipos disponibles:"
    for ($i=0; $i -lt $dirs.Count; $i++) {
        Write-Host "$($i+1). $($dirs[$i].Name)"
    }
    $choice = Read-Host "Seleccione numero"
    if ([int]::TryParse($choice, [ref]$null)) {
        $num = [int]$choice
        if ($num -ge 1 -and $num -le $dirs.Count) {
            return $dirs[$num-1].Name
        }
    }
    Write-Host "Seleccion invalida."
    return $null
}

do {
    Show-Menu
    $opc = Read-Host "Seleccione opcion"

    switch ($opc) {
        "1" { & $ScriptPath -Mode backup -Target all; Pause }
        "2" { & $ScriptPath -Mode restore -Target all; Pause }
        "3" {
            $team = Select-Team
            if ($team) { & $ScriptPath -Mode restore -Target $team }
            Pause
        }
        "4" { Write-Host "Saliendo..." }
        Default { Write-Host "Opcion invalida."; Pause }
    }
} while ($opc -ne "4")
