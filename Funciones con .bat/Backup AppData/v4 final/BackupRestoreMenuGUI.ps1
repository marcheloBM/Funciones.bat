Add-Type -AssemblyName PresentationFramework

function Show-Menu {
    $window = New-Object System.Windows.Window
    $window.Title = "Backup / Restore Menu"
    $window.Width = 400
    $window.Height = 300
    $window.WindowStartupLocation = "CenterScreen"

    $stack = New-Object System.Windows.Controls.StackPanel
    $stack.Margin = "20"

    $btnBackup = New-Object System.Windows.Controls.Button
    $btnBackup.Content = "Backup todo (este equipo)"
    $btnBackup.Margin = "5"
    $btnBackup.Add_Click({
        [System.Windows.MessageBox]::Show("Iniciando backup de este equipo...")
        & "$PSScriptRoot\BackupRestore.ps1" -Mode backup
        [System.Windows.MessageBox]::Show("✅ Backup completado. Revise el log para ver el total de programas respaldados.")
    })

    $btnRestoreAll = New-Object System.Windows.Controls.Button
    $btnRestoreAll.Content = "Restore todo (todos los equipos)"
    $btnRestoreAll.Margin = "5"
    $btnRestoreAll.Add_Click({
        $confirm = [System.Windows.MessageBox]::Show("⚠️ ¿Está seguro que desea restaurar TODOS los equipos?", "Confirmación", "YesNo", "Warning")
        if ($confirm -eq "Yes") {
            [System.Windows.MessageBox]::Show("Restaurando todos los equipos...")
            & "$PSScriptRoot\BackupRestore.ps1" -Mode restore -Target all
            [System.Windows.MessageBox]::Show("✅ Restore completado. Revise el log para ver el total de programas restaurados.")
        } else {
            [System.Windows.MessageBox]::Show("Operación cancelada.")
        }
    })

    $btnRestoreEquipo = New-Object System.Windows.Controls.Button
    $btnRestoreEquipo.Content = "Restore equipo específico"
    $btnRestoreEquipo.Margin = "5"
    $btnRestoreEquipo.Add_Click({
        $backupRoot = Join-Path $PSScriptRoot "Backups"
        if (!(Test-Path $backupRoot)) {
            [System.Windows.MessageBox]::Show("No existe la carpeta de backups: $backupRoot")
        }
        else {
            $equipos = Get-ChildItem $backupRoot -Directory | Select-Object -ExpandProperty Name
            if ($equipos.Count -eq 0) {
                [System.Windows.MessageBox]::Show("No hay equipos con backups disponibles.")
            }
            else {
                $selWindow = New-Object System.Windows.Window
                $selWindow.Title = "Seleccione equipo"
                $selWindow.Width = 300
                $selWindow.Height = 200
                $selWindow.WindowStartupLocation = "CenterScreen"

                $listBox = New-Object System.Windows.Controls.ListBox
                foreach ($eq in $equipos) { $listBox.Items.Add($eq) }

                $btnOk = New-Object System.Windows.Controls.Button
                $btnOk.Content = "Restaurar"
                $btnOk.Margin = "5"
                $btnOk.Add_Click({
                    if ($listBox.SelectedItem) {
                        $equipoSel = $listBox.SelectedItem
                        [System.Windows.MessageBox]::Show("Restaurando equipo $equipoSel...")
                        & "$PSScriptRoot\BackupRestore.ps1" -Mode restore -Target $equipoSel
                        [System.Windows.MessageBox]::Show("✅ Restore completado. Revise el log para ver el total de programas restaurados.")
                        $selWindow.Close()
                    }
                })

                $panelSel = New-Object System.Windows.Controls.StackPanel
                $panelSel.Children.Add($listBox)
                $panelSel.Children.Add($btnOk)

                $selWindow.Content = $panelSel
                $selWindow.ShowDialog() | Out-Null
            }
        }
    })

    $btnSalir = New-Object System.Windows.Controls.Button
    $btnSalir.Content = "Salir"
    $btnSalir.Margin = "5"
    $btnSalir.Add_Click({
        $window.Close()
    })

    $stack.Children.Add($btnBackup)
    $stack.Children.Add($btnRestoreAll)
    $stack.Children.Add($btnRestoreEquipo)
    $stack.Children.Add($btnSalir)

    $window.Content = $stack
    $window.ShowDialog() | Out-Null
}

# Bucle: la ventana se vuelve a mostrar hasta que el usuario cierre con "Salir"
while ($true) {
    Show-Menu
    break
}
