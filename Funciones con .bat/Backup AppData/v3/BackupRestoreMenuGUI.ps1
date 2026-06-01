Add-Type -AssemblyName PresentationFramework

# Ventana principal
$window = New-Object Windows.Window
$window.Title = "Backup / Restore Menu"
$window.Width = 400
$window.Height = 270
$window.WindowStartupLocation = "CenterScreen"

# StackPanel para organizar los controles
$stack = New-Object Windows.Controls.StackPanel
$stack.Margin = "10"
$window.Content = $stack

# Etiqueta principal
$label = New-Object Windows.Controls.TextBlock
$label.Text = "Seleccione una opción:"
$label.FontSize = 16
$label.Margin = "0,0,0,10"
$stack.Children.Add($label)

# Botón: Backup todo
$btnBackup = New-Object Windows.Controls.Button
$btnBackup.Content = "Backup todo (programas agrupados)"
$btnBackup.Margin = "0,0,0,5"
$btnBackup.Add_Click({
    [System.Windows.MessageBox]::Show("Iniciando backup de todos los programas agrupados...")
    & "$PSScriptRoot\BackupRestore.ps1" -Mode backup
    [System.Windows.MessageBox]::Show("Backup finalizado.")
})
$stack.Children.Add($btnBackup)

# Botón: Restore todo
$btnRestoreAll = New-Object Windows.Controls.Button
$btnRestoreAll.Content = "Restore todo (todos los equipos)"
$btnRestoreAll.Margin = "0,0,0,5"
$btnRestoreAll.Add_Click({
    [System.Windows.MessageBox]::Show("Restaurando todos los programas agrupados de todos los equipos...")
    & "$PSScriptRoot\BackupRestore.ps1" -Mode restore -Target all
    [System.Windows.MessageBox]::Show("Restore finalizado.")
})
$stack.Children.Add($btnRestoreAll)

# Botón: Restore equipo específico (lista automática)
$btnRestoreSpecific = New-Object Windows.Controls.Button
$btnRestoreSpecific.Content = "Restore equipo específico"
$btnRestoreSpecific.Margin = "0,0,0,5"
$btnRestoreSpecific.Add_Click({
    $backupRoot = "F:\Backup AppData\Backups"
    if (!(Test-Path $backupRoot)) {
        [System.Windows.MessageBox]::Show("No existe la carpeta de backups: $backupRoot")
        return
    }

    $equipos = Get-ChildItem $backupRoot -Directory | Select-Object -ExpandProperty Name
    if ($equipos.Count -eq 0) {
        [System.Windows.MessageBox]::Show("No hay equipos con backups disponibles.")
        return
    }

    # Ventana de selección
    $selWin = New-Object Windows.Window
    $selWin.Title = "Seleccionar equipo"
    $selWin.Width = 300
    $selWin.Height = 180
    $selWin.WindowStartupLocation = "CenterScreen"

    $panel = New-Object Windows.Controls.StackPanel
    $panel.Margin = "10"
    $selWin.Content = $panel

    $labelSel = New-Object Windows.Controls.TextBlock
    $labelSel.Text = "Seleccione el equipo:"
    $labelSel.Margin = "0,0,0,10"
    $panel.Children.Add($labelSel)

    $combo = New-Object Windows.Controls.ComboBox
    $combo.ItemsSource = $equipos
    $combo.SelectedIndex = 0
    $panel.Children.Add($combo)

    $btnOk = New-Object Windows.Controls.Button
    $btnOk.Content = "Restaurar"
    $btnOk.Margin = "0,10,0,0"
    $btnOk.Add_Click({
        $equipoSel = $combo.SelectedItem
        [System.Windows.MessageBox]::Show("Restaurando todos los programas agrupados del equipo $equipoSel...")
        & "$PSScriptRoot\BackupRestore.ps1" -Mode restore -Target $equipoSel
        [System.Windows.MessageBox]::Show("Restore finalizado.")
        $selWin.Close()
    })
    $panel.Children.Add($btnOk)

    $selWin.ShowDialog() | Out-Null
})
$stack.Children.Add($btnRestoreSpecific)

# Botón: Salir
$btnExit = New-Object Windows.Controls.Button
$btnExit.Content = "Salir"
$btnExit.Margin = "0,0,0,5"
$btnExit.Add_Click({ $window.Close() })
$stack.Children.Add($btnExit)

# Mostrar ventana
$window.ShowDialog() | Out-Null
