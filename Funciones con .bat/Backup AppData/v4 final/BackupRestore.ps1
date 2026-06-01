param(
    [string]$Mode,   # backup o restore
    [string]$Target  # "all" o nombre de equipo
)

# ================================
# CONFIGURACION
# ================================
$BackupDir = Join-Path $PSScriptRoot "Backups"

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
        Write-Host "Usando compresión con 7-Zip para $destZip"
        & $SevenZip a -tzip $destZip $srcPath | Out-Null
    }
    elseif ($WinRAR) {
        Write-Host "Usando compresión con WinRAR para $destZip"
        & $WinRAR a $destZip $srcPath | Out-Null
    }
    else {
        Write-Host "Usando compresión nativa de Windows para $destZip"
        Compress-Archive -Path $srcPath -DestinationPath $destZip -Force
    }
}

function Extract-Folder($zip,$dest) {
    if ($SevenZip) {
        Write-Host "Usando descompresión con 7-Zip para $zip"
        & $SevenZip x $zip -o"$dest" -y | Out-Null
    }
    elseif ($WinRAR) {
        Write-Host "Usando descompresión con WinRAR para $zip"
        & $WinRAR x $zip "$dest\" -y | Out-Null
    }
    else {
        Write-Host "Usando descompresión nativa de Windows para $zip"
        Expand-Archive -Path $zip -DestinationPath $dest -Force
    }
}


# ================================
# FUNCIONES DE BACKUP / RESTORE
# ================================
function Do-BackupAll {
    # Normalizar fabricante
    $brandRaw = (Get-CimInstance Win32_ComputerSystem).Manufacturer
    $brand = $brandRaw.TrimEnd('.',' ')

    $date  = Get-Date -Format "yyyy-MM-dd_HH-mm"
    $teamDir = Join-Path $BackupDir $brand
    if (!(Test-Path $teamDir)) { New-Item -ItemType Directory -Path $teamDir | Out-Null }

    $total = $ProgramPaths.Keys.Count
    $done = 0

    foreach ($program in $ProgramPaths.Keys) {
        $path = $ProgramPaths[$program]

        if ($path -like "*`*") {
            $base = Split-Path $path
            $filter = Split-Path $path -Leaf
            $dirs = Get-ChildItem $base -Directory -Filter $filter
            foreach ($dir in $dirs) {
                $zip = Join-Path $teamDir "$program-$($dir.Name)-$date.zip"
                try {
                    Compress-Folder $dir.FullName $zip
                    $done++
                    Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - [$done/$total] Backup OK: $zip"
                } catch {
                    Write-Host ("ERROR al hacer backup de {0}: {1}" -f $dir.FullName, $_.Exception.Message)
                }
            }
        }
        elseif (Test-Path $path) {
            $zip = Join-Path $teamDir "$program-$date.zip"
            try {
                Compress-Folder $path $zip
                $done++
                Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - [$done/$total] Backup OK: $zip"
            } catch {
                Write-Host ("ERROR al hacer backup de {0}: {1}" -f $path, $_.Exception.Message)
            }
        }
        else {
            Write-Host "No se encontró la ruta para $program"
        }
    }

    Write-Host "✅ Backup completado: $done de $total programas respaldados."
}

function Do-RestoreAll {
    # Normalizar fabricante
    $brandRaw = (Get-CimInstance Win32_ComputerSystem).Manufacturer
    $brand = $brandRaw.TrimEnd('.',' ')

    $total = 0
    $done = 0

    if ($Target -eq "all") {
        $dirs = Get-ChildItem $BackupDir -Directory
        foreach ($d in $dirs) {
            foreach ($program in $ProgramPaths.Keys) {
                $files = Get-ChildItem $d.FullName -Filter "$program*.zip" | Sort-Object LastWriteTime -Descending
                foreach ($f in $files) { $total++ }
            }
        }

        foreach ($d in $dirs) {
            foreach ($program in $ProgramPaths.Keys) {
                $files = Get-ChildItem $d.FullName -Filter "$program*.zip" | Sort-Object LastWriteTime -Descending
                foreach ($f in $files) {
                    try {
                        # Buscar ruta original del programa
                        $dest = $ProgramPaths[$program]

                        # Crear carpeta si no existe
                        if (!(Test-Path $dest)) { New-Item -ItemType Directory -Path $dest -Force | Out-Null }

                        # Restaurar en la ruta correcta
                        Extract-Folder $f.FullName $dest

                        $done++
                        Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - [$done/$total] Restore OK: $($f.Name) → $dest"
                    } catch {
                        Write-Host ("ERROR al restaurar {0}: {1}" -f $f.Name, $_.Exception.Message)
                    }
                }
            }
        }
    } else {
        $teamDir = Join-Path $BackupDir $Target.TrimEnd('.',' ')
        if (Test-Path $teamDir) {
            $files = Get-ChildItem $teamDir -Filter "*.zip"
            $total = $files.Count

            foreach ($program in $ProgramPaths.Keys) {
                $files = Get-ChildItem $teamDir -Filter "$program*.zip" | Sort-Object LastWriteTime -Descending
                foreach ($f in $files) {
                    try {
                        # Buscar ruta original del programa
                        $dest = $ProgramPaths[$program]

                        # Crear carpeta si no existe
                        if (!(Test-Path $dest)) { New-Item -ItemType Directory -Path $dest -Force | Out-Null }

                        # Restaurar en la ruta correcta
                        Extract-Folder $f.FullName $dest

                        $done++
                        Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - [$done/$total] Restore OK: $($f.Name) → $dest"
                    } catch {
                        Write-Host ("ERROR al restaurar {0}: {1}" -f $f.Name, $_.Exception.Message)
                    }
                }
            }
        } else {
            Write-Host "No existe carpeta para el equipo $Target"
        }
    }

    Write-Host "✅ Restore completado: $done de $total programas restaurados."
}

# ================================
# EJECUCION
# ================================
switch ($Mode) {
    "backup" { Do-BackupAll }
    "restore" { Do-RestoreAll }
    default { Write-Host "Modo invalido. Use backup o restore." }
}
