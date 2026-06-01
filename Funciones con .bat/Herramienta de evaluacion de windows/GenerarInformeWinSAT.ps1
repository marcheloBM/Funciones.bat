# Script PowerShell para generar informe WinSAT en HTML
param(
    [string]$Destino = "%USERPROFILE%\Documents\MarcheBMPC\InformesWinSAT"
)

# Crear carpeta si no existe
if (!(Test-Path $Destino)) {
    New-Item -ItemType Directory -Path $Destino | Out-Null
}

# Obtener datos
$data = Get-CimInstance Win32_WinSAT
$fecha = Get-Date -Format 'dd/MM/yyyy HH:mm:ss'
$timestamp = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'
$pcname = $env:COMPUTERNAME
$filename = Join-Path $Destino ("Informe_WinSAT_" + $pcname + "_" + $timestamp + ".html")

# Generar HTML
$html = @"
<html>
<head>
<title>Informe WinSAT - $pcname</title>
<style>
body { font-family: Arial; margin: 20px; }
table { border-collapse: collapse; width: 80%; margin-bottom: 30px; }
th, td { border: 1px solid #333; padding: 8px; text-align: center; }
th { background-color: #f2f2f2; }
h1 { color: #004080; }
.bar-container { width: 100%; background-color: #f2f2f2; }
.bar { height: 20px; text-align: right; padding-right: 5px; color: white; }
.cpu { background-color: #1E90FF; }
.d3d { background-color: #FF4500; }
.disk { background-color: #8B4513; }
.graphics { background-color: #32CD32; }
.memory { background-color: #FFD700; }
.winspr { background-color: #800080; }
</style>
</head>
<body>
<h1>Informe de Evaluación del Sistema (WinSAT)</h1>
<p><b>Equipo:</b> $pcname</p>
<p><b>Fecha de evaluación:</b> $fecha</p>
<h2>Resultados</h2>
<table>
<tr><th>Métrica</th><th>Puntuación</th><th>Descripción</th><th>Gráfico</th></tr>
<tr><td>CPUScore</td><td>$($data.CPUScore)</td><td>Evalúa la capacidad del procesador</td>
<td><div class='bar-container'><div class='bar cpu' style='width:$($data.CPUScore*10)%'>$($data.CPUScore)</div></div></td></tr>
<tr><td>D3DScore</td><td>$($data.D3DScore)</td><td>Rendimiento en gráficos 3D</td>
<td><div class='bar-container'><div class='bar d3d' style='width:$($data.D3DScore*10)%'>$($data.D3DScore)</div></div></td></tr>
<tr><td>DiskScore</td><td>$($data.DiskScore)</td><td>Velocidad de disco (SSD/HDD)</td>
<td><div class='bar-container'><div class='bar disk' style='width:$($data.DiskScore*10)%'>$($data.DiskScore)</div></div></td></tr>
<tr><td>GraphicsScore</td><td>$($data.GraphicsScore)</td><td>Rendimiento gráfico general (2D)</td>
<td><div class='bar-container'><div class='bar graphics' style='width:$($data.GraphicsScore*10)%'>$($data.GraphicsScore)</div></div></td></tr>
<tr><td>MemoryScore</td><td>$($data.MemoryScore)</td><td>Velocidad y capacidad de RAM</td>
<td><div class='bar-container'><div class='bar memory' style='width:$($data.MemoryScore*10)%'>$($data.MemoryScore)</div></div></td></tr>
<tr><td>WinSPRLevel</td><td>$($data.WinSPRLevel)</td><td>Índice global basado en el componente más débil</td>
<td><div class='bar-container'><div class='bar winspr' style='width:$($data.WinSPRLevel*10)%'>$($data.WinSPRLevel)</div></div></td></tr>
</table>
<h2>Notas</h2>
<p>Los puntajes van de 1.0 a 9.9, donde valores más altos indican mejor rendimiento.</p>
</body>
</html>
"@

# Guardar archivo
Set-Content -Path $filename -Value $html

# Actualizar índice
$index = Join-Path $Destino "Indice_Informes.html"
$links = Get-ChildItem $Destino -Filter "Informe_WinSAT_*.html" | Sort-Object LastWriteTime -Descending | ForEach-Object { "<li><a href='$($_.Name)'>$($_.Name)</a></li>" }
$indexHtml = "<html><head><title>Indice de Informes WinSAT</title></head><body><h1>Índice de Informes WinSAT</h1><ul>$($links -join '')</ul></body></html>"
Set-Content -Path $index -Value $indexHtml

# Abrir informe e índice
Start-Process $filename
Start-Process $index
