param(
    [string]$Mode,   # backup o restore
    [string]$Target  # "all" o nombre de equipo
)

# ================================
# CONFIGURACION
# ================================
$BackupDir = Join-Path $PSScriptRoot "Backups"

# Lista de rutas de programas
$ProgramKeys = @(
    "RUTA_ANDROIDSTUDIO",
    "RUTA_GRADLE",
    "RUTA_ANDROID",
    "RUTA_FILEZILLA",
    "RUTA_NETBEANS",
    "RUTA_NOTEPADPP",
    "RUTA_NOTEPADPP_PLUGINS",
    "RUTA_NOTEPADPP_THEMES",
    "RUTA_OBS",
    "RUTA_OBS_DISTROAV",
    "RUTA_OBS_DATA",
    "RUTA_OBS_PLUGINS"
)

function Get-TargetPath {
    param([string]$Key)
    switch ($Key) {
        "RUTA_ANDROIDSTUDIO" { return "$env:APPDATA\Google\AndroidStudio*" }
        "RUTA_GRADLE"        { return "$env:USERPROFILE\.gradle" }
        "RUTA_ANDROID"       { return "$env:USERPROFILE\.android" }
        "RUTA_FILEZILLA"     { return "$env:APPDATA\FileZilla" }
        "RUTA_NETBEANS"      { return "$env:APPDATA\NetBeans" }
        "RUTA_NOTEPADPP"     { return "$env:APPDATA\Notepad++" }
        "RUTA_NOTEPADPP_PLUGINS" { return "$env:APPDATA\Notepad++\plugins" }
        "RUTA_NOTEPADPP_THEMES"  { return "$env:APPDATA\Notepad++\themes" }
        "RUTA_OBS"           { return "$env:APPDATA\obs-studio" }
        "RUTA_OBS_DISTROAV"  { return "$env:APPDATA\obs-studio\plugin_config\distroav" }
        "RUTA_OBS_DATA"      { return "$env:APPDATA\obs-studio\data" }
        "RUTA_OBS_PLUGINS"   { return "$env:APPDATA\obs-studio\plugins" }
        default              { return $null }
    }
}

function Do-BackupAll {
    $brand = (Get-CimInstance Win32_ComputerSystem).Manufacturer
    $date  = Get-Date -Format "yyyy-MM-dd_HH-mm"
    $teamDir = Join-Path $BackupDir $brand
    if (!(Test-Path $teamDir)) { New-Item -ItemType Directory -Path $teamDir | Out-Null }

    foreach ($key in $ProgramKeys) {
        $src = Get-TargetPath $key
        if (Test-Path $src) {
            $zip = Join-Path $teamDir "$key-$date.zip"
            try {
                Compress-Archive -Path $src -DestinationPath $zip -Force
                Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Backup OK: $zip"
            } catch {
                Write-Host ("ERROR al hacer backup de {0}: {1}" -f $key, $_.Exception.Message)
            }
        } else {
            Write-Host "Ruta no encontrada: $key"
        }
    }
}

function Do-RestoreAll {
    if ($Target -eq "all") {
        # Restaurar todas las copias de todos los equipos
        $dirs = Get-ChildItem $BackupDir -Directory
        foreach ($d in $dirs) {
            foreach ($key in $ProgramKeys) {
                $files = Get-ChildItem $d.FullName -Filter "$key*.zip" | Sort-Object LastWriteTime -Descending
                if ($files.Count -gt 0) {
                    $f = $files[0]
                    $dest = Get-TargetPath $key
                    try {
                        Expand-Archive -Path $f.FullName -DestinationPath $dest -Force
                        Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Restore OK: $($f.Name)"
                    } catch {
                        Write-Host ("ERROR al restaurar {0}: {1}" -f $f.Name, $_.Exception.Message)
                    }
                }
            }
        }
    } else {
        # Restaurar solo las copias de un equipo especifico
        $teamDir = Join-Path $BackupDir $Target
        if (Test-Path $teamDir) {
            foreach ($key in $ProgramKeys) {
                $files = Get-ChildItem $teamDir -Filter "$key*.zip" | Sort-Object LastWriteTime -Descending
                if ($files.Count -gt 0) {
                    $f = $files[0]
                    $dest = Get-TargetPath $key
                    try {
                        Expand-Archive -Path $f.FullName -DestinationPath $dest -Force
                        Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Restore OK: $($f.Name)"
                    } catch {
                        Write-Host ("ERROR al restaurar {0}: {1}" -f $f.Name, $_.Exception.Message)
                    }
                }
            }
        } else {
            Write-Host "No existe carpeta para el equipo $Target"
        }
    }
}

switch ($Mode) {
    "backup" { Do-BackupAll }
    "restore" { Do-RestoreAll }
    default { Write-Host "Modo invalido. Use backup o restore." }
}
