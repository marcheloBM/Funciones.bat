param(
    [string]$Mode,   # backup o restore
    [string]$Target  # "all" o nombre de equipo
)

# ================================
# CONFIGURACION
# ================================
$BackupDir = Join-Path $PSScriptRoot "Backups"

# Lista de rutas individuales (cada una se respalda por separado)
$ProgramPaths = @{
    "RUTA_ANDROIDSTUDIO"   = "$env:LOCALAPPDATA\Google\AndroidStudio*"
    "RUTA_GRADLE"          = "$env:USERPROFILE\.gradle"
    "RUTA_ANDROID"         = "$env:USERPROFILE\.android"

    "RUTA_FILEZILLA"       = "$env:APPDATA\FileZilla"
    "RUTA_NETBEANS"        = "$env:APPDATA\NetBeans"

    "RUTA_NOTEPADPP"       = "$env:APPDATA\Notepad++"
    "RUTA_NOTEPADPP_PLUGINS" = "C:\Program Files\Notepad++\plugins"
    "RUTA_NOTEPADPP_THEMES"  = "C:\Program Files\Notepad++\themes"

    "RUTA_OBS"             = "$env:APPDATA\obs-studio"
    "RUTA_OBS_DISTROAV"    = "C:\ProgramData\obs-studio\plugins\distroav"
    "RUTA_OBS_DATA"        = "C:\Program Files\obs-studio\data"
    "RUTA_OBS_PLUGINS"     = "C:\Program Files\obs-studio\obs-plugins"
}


# ================================
# DETECCION DE COMPRESORES
# ================================
$SevenZipPaths = @(
    "C:\Program Files\7-Zip\7z.exe",
    "C:\Program Files (x86)\7-Zip\7z.exe"
)
$WinRARPaths = @(
    "C:\Program Files\WinRAR\rar.exe",
    "C:\Program Files (x86)\WinRAR\rar.exe"
)

$SevenZip = $SevenZipPaths | Where-Object { Test-Path $_ } | Select-Object -First 1
$WinRAR   = $WinRARPaths | Where-Object { Test-Path $_ } | Select-Object -First 1

function Compress-Folder($srcPath,$destZip) {
    if ($SevenZip) {
        & $SevenZip a -tzip $destZip $srcPath | Out-Null
        Write-Host "Usando 7-Zip para $destZip"
    }
    elseif ($WinRAR) {
        & $WinRAR a $destZip $srcPath | Out-Null
        Write-Host "Usando WinRAR para $destZip"
    }
    else {
        Compress-Archive -Path $srcPath -DestinationPath $destZip -Force
        Write-Host "Usando compresion nativa de Windows para $destZip"
    }
}

function Extract-Folder($zip,$dest) {
    if ($SevenZip) {
        & $SevenZip x $zip -o"$dest" -y | Out-Null
        Write-Host "Usando 7-Zip para restaurar $zip"
    }
    elseif ($WinRAR) {
        & $WinRAR x $zip "$dest\" -y | Out-Null
        Write-Host "Usando WinRAR para restaurar $zip"
    }
    else {
        Expand-Archive -Path $zip -DestinationPath $dest -Force
        Write-Host "Usando descompresion nativa de Windows para $zip"
    }
}

# ================================
# FUNCIONES DE BACKUP / RESTORE
# ================================
function Do-BackupAll {
    $brand = (Get-CimInstance Win32_ComputerSystem).Manufacturer
    $date  = Get-Date -Format "yyyy-MM-dd_HH-mm"
    $teamDir = Join-Path $BackupDir $brand
    if (!(Test-Path $teamDir)) { New-Item -ItemType Directory -Path $teamDir | Out-Null }

    foreach ($program in $ProgramPaths.Keys) {
        $path = $ProgramPaths[$program]
        if (Test-Path $path) {
            $zip = Join-Path $teamDir "$program-$date.zip"
            try {
                Compress-Folder $path $zip
                Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Backup OK: $zip"
            } catch {
                Write-Host ("ERROR al hacer backup de {0}: {1}" -f $program, $_.Exception.Message)
            }
        } else {
            Write-Host "No se encontró la ruta para $program"
        }
    }
}

function Do-RestoreAll {
    if ($Target -eq "all") {
        $dirs = Get-ChildItem $BackupDir -Directory
        foreach ($d in $dirs) {
            foreach ($program in $ProgramPaths.Keys) {
                $files = Get-ChildItem $d.FullName -Filter "$program*.zip" | Sort-Object LastWriteTime -Descending
                if ($files.Count -gt 0) {
                    $f = $files[0]
                    try {
                        Extract-Folder $f.FullName $BackupDir
                        Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Restore OK: $($f.Name)"
                    } catch {
                        Write-Host ("ERROR al restaurar {0}: {1}" -f $f.Name, $_.Exception.Message)
                    }
                }
            }
        }
    } else {
        $teamDir = Join-Path $BackupDir $Target
        if (Test-Path $teamDir) {
            foreach ($program in $ProgramPaths.Keys) {
                $files = Get-ChildItem $teamDir -Filter "$program*.zip" | Sort-Object LastWriteTime -Descending
                if ($files.Count -gt 0) {
                    $f = $files[0]
                    try {
                        Extract-Folder $f.FullName $BackupDir
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

# ================================
# EJECUCION
# ================================
switch ($Mode) {
    "backup" { Do-BackupAll }
    "restore" { Do-RestoreAll }
    default { Write-Host "Modo invalido. Use backup o restore." }
}
