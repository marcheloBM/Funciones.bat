# BackupRestoreMenuGUI.ps1
# Menu grafico para BackupRestore.ps1 con seleccion de equipo

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$ScriptPath = Join-Path $PSScriptRoot "BackupRestore.ps1"
$BackupDir  = Join-Path $PSScriptRoot "Backups"

$form = New-Object System.Windows.Forms.Form
$form.Text = "Backup / Restore Menu"
$form.Size = New-Object System.Drawing.Size(500,250)
$form.StartPosition = "CenterScreen"

# ComboBox para equipos
$combo = New-Object System.Windows.Forms.ComboBox
$combo.Location = New-Object System.Drawing.Point(20,20)
$combo.Size = New-Object System.Drawing.Size(440,25)
$combo.DropDownStyle = "DropDownList"

if (Test-Path $BackupDir) {
    $dirs = Get-ChildItem $BackupDir -Directory
    foreach ($d in $dirs) { $combo.Items.Add($d.Name) }
} else {
    [System.Windows.Forms.MessageBox]::Show("No existe la carpeta de backups: $BackupDir")
}

$form.Controls.Add($combo)

# Boton Backup todo (este equipo)
$btnBackupAll = New-Object System.Windows.Forms.Button
$btnBackupAll.Location = New-Object System.Drawing.Point(20,70)
$btnBackupAll.Size = New-Object System.Drawing.Size(200,30)
$btnBackupAll.Text = "Backup todo (este equipo)"
$btnBackupAll.Add_Click({
    & $ScriptPath -Mode backup -Target all
    [System.Windows.Forms.MessageBox]::Show("Backup completado del equipo actual")
})
$form.Controls.Add($btnBackupAll)

# Boton Restore todo (todos los equipos)
$btnRestoreAll = New-Object System.Windows.Forms.Button
$btnRestoreAll.Location = New-Object System.Drawing.Point(260,70)
$btnRestoreAll.Size = New-Object System.Drawing.Size(200,30)
$btnRestoreAll.Text = "Restore todo (todos los equipos)"
$btnRestoreAll.Add_Click({
    & $ScriptPath -Mode restore -Target all
    [System.Windows.Forms.MessageBox]::Show("Restore completado de todos los equipos")
})
$form.Controls.Add($btnRestoreAll)

# Boton Restore equipo especifico
$btnRestoreTeam = New-Object System.Windows.Forms.Button
$btnRestoreTeam.Location = New-Object System.Drawing.Point(20,120)
$btnRestoreTeam.Size = New-Object System.Drawing.Size(440,30)
$btnRestoreTeam.Text = "Restore equipo seleccionado"
$btnRestoreTeam.Add_Click({
    if ($combo.SelectedItem) {
        & $ScriptPath -Mode restore -Target $combo.SelectedItem
        [System.Windows.Forms.MessageBox]::Show("Restore completado del equipo: $($combo.SelectedItem)")
    } else {
        [System.Windows.Forms.MessageBox]::Show("Seleccione un equipo primero")
    }
})
$form.Controls.Add($btnRestoreTeam)

# Boton Salir
$btnExit = New-Object System.Windows.Forms.Button
$btnExit.Location = New-Object System.Drawing.Point(180,170)
$btnExit.Size = New-Object System.Drawing.Size(120,30)
$btnExit.Text = "Salir"
$btnExit.Add_Click({ $form.Close() })
$form.Controls.Add($btnExit)

$form.ShowDialog()
