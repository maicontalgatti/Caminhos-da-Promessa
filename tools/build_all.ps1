# Regenera a arte provisória, reconstrói o mundo e roda os testes.
# Uso (PowerShell, na raiz do projeto):  .\tools\build_all.ps1 [-PropsOnly] [-Screenshots]
param(
    [switch]$PropsOnly,
    [switch]$Screenshots
)
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$godot = Join-Path $root "tools\godot\Godot_v4.7.2-stable_win64_console.exe"
if (-not (Test-Path $godot)) { throw "Godot não encontrado em $godot (veja README.md)" }
Set-Location $root

function Step($label, [string[]]$godotArgs) {
    Write-Host "==> $label"
    & $godot @godotArgs 2>&1 | Where-Object { $_ -match "ERROR|SCRIPT|concluido|passaram|FAIL|captura" } | ForEach-Object { "$_" }
    if ($LASTEXITCODE -ne 0) { throw "Falhou: $label" }
}

Step "Gerando arte" @("--headless", "--path", ".", "--script", "res://tools/art_gen/generate_art.gd")
Step "Importando" @("--headless", "--path", ".", "--import")
$buildArgs = @("--headless", "--path", ".", "--script", "res://tools/art_gen/build_world.gd")
if ($PropsOnly) { $buildArgs += @("--", "--props-only") }
Step "Construindo mundo" $buildArgs
Step "Importando" @("--headless", "--path", ".", "--import")
Step "Prancha de assets" @("--headless", "--path", ".", "--script", "res://tools/art_gen/preview.gd")
Step "Testes" @("--headless", "--path", ".", "res://tests/test_runner.tscn")
Step "Teste de fluxo" @("--headless", "--path", ".", "--script", "res://tests/flow_smoke.gd")
if ($Screenshots) {
    Step "Capturas de tela" @("--path", ".", "res://tools/screenshot/capture.tscn")
}
Write-Host "Pronto."
