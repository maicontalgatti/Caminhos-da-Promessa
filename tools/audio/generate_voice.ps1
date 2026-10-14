# Geracao de voz a partir do manifesto de audio de um episodio (fabrica de missoes).
# Ver docs/mission_factory.md, secao "Audio".
#
#   powershell -ExecutionPolicy Bypass -File tools\audio\generate_voice.ps1 -Episode ep_006_a_importancia_dos_pocos -DryRun
#   powershell -ExecutionPolicy Bypass -File tools\audio\generate_voice.ps1 -Episode <id> -Provider sapi -OutDir C:\TEMP\voz_teste -Limit 3
#
# Provedores:
#   none        apenas conta falas e caracteres (padrao).
#   sapi        voz do Windows (System.Speech). SOMENTE TESTE TECNICO: grava WAV fora do projeto.
#               Nao e autorizado para o jogo (licenca de redistribuicao das vozes nao confirmada).
#   elevenlabs  nao implementado. Exige decisao humana registrada (provedor, licenca comercial,
#               orcamento) antes de existir. A chave viria de variavel de ambiente, nunca de arquivo.
#
# Este script nunca grava em assets/ nem altera o manifesto; o integrador importa o audio aprovado.

param(
    [Parameter(Mandatory = $true)][string]$Episode,
    [ValidateSet("none", "sapi", "elevenlabs")][string]$Provider = "none",
    [string]$OutDir = "",
    [int]$Limit = 0,
    [switch]$DryRun,
    [switch]$ApproveBudget
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$manifestPath = Join-Path $root "production\episodes\$Episode\audio_manifest.json"
if (-not (Test-Path $manifestPath)) {
    Write-Error "Manifesto nao encontrado: $manifestPath (rode: tools/factory.gd -- audio-manifest $Episode)"
}
$manifest = Get-Content $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
$lines = @($manifest.lines | Where-Object { $_.status -ne "text_only" })
$pending = @($lines | Where-Object { $_.status -in @("pending", "stale") })
$chars = ($pending | ForEach-Object { $_.text.Length } | Measure-Object -Sum).Sum
if ($null -eq $chars) { $chars = 0 }

Write-Host ("Episodio {0}: {1} falas com voz, {2} pendentes, {3} caracteres pendentes." -f $Episode, $lines.Count, $pending.Count, $chars)
Write-Host "Custo: nao mensurado (nenhum provedor pago configurado; o preco depende do plano contratado)."

if ($DryRun -or $Provider -eq "none") {
    Write-Host "Nada gerado (simulacao)."
    exit 0
}

if ($Provider -eq "elevenlabs") {
    if (-not $ApproveBudget) { Write-Error "Provedor pago exige -ApproveBudget (orcamento aprovado por uma pessoa)." }
    Write-Error "Provedor 'elevenlabs' nao implementado: falta autorizacao humana de provedor, licenca e orcamento (docs/mission_factory.md)."
}

# sapi: teste tecnico, nunca dentro do projeto
if ($OutDir -eq "") { Write-Error "Informe -OutDir fora do projeto (ex.: C:\TEMP\voz_teste)." }
$outFull = [System.IO.Path]::GetFullPath($OutDir)
if ($outFull.StartsWith([System.IO.Path]::GetFullPath($root), [System.StringComparison]::OrdinalIgnoreCase)) {
    Write-Error "O teste SAPI nao pode gravar dentro do projeto ($outFull)."
}
New-Item -ItemType Directory -Force -Path $outFull | Out-Null

Add-Type -AssemblyName System.Speech
$synth = New-Object System.Speech.Synthesis.SpeechSynthesizer
$voice = $synth.GetInstalledVoices() | Where-Object { $_.VoiceInfo.Culture.Name -eq "pt-BR" -and $_.Enabled } | Select-Object -First 1
if ($null -eq $voice) { Write-Error "Nenhuma voz SAPI pt-BR instalada." }
$synth.SelectVoice($voice.VoiceInfo.Name)
$synth.Rate = 0

$todo = $pending
if ($Limit -gt 0) { $todo = @($pending | Select-Object -First $Limit) }
$report = @()
foreach ($l in $todo) {
    $name = ($l.line_id -replace "/", "__") + ".wav"
    $file = Join-Path $outFull $name
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $synth.SetOutputToWaveFile($file)
    $synth.Speak($l.text)
    $synth.SetOutputToNull()
    $sw.Stop()
    $size = (Get-Item $file).Length
    $report += [pscustomobject]@{ line_id = $l.line_id; hash = $l.hash; file = $file; bytes = $size; seconds_to_generate = [math]::Round($sw.Elapsed.TotalSeconds, 2) }
    Write-Host ("  {0} -> {1} ({2} bytes)" -f $l.line_id, $name, $size)
}
$synth.Dispose()
$reportPath = Join-Path $outFull "report.json"
[pscustomobject]@{
    episode = $Episode
    provider = "sapi"
    voice = $voice.VoiceInfo.Name
    purpose = "teste tecnico; nao e asset do jogo"
    generated = (Get-Date -Format "yyyy-MM-dd HH:mm")
    cost = "zero (voz local do sistema); nao autorizado para distribuicao"
    lines = $report
} | ConvertTo-Json -Depth 4 | Set-Content -Path $reportPath -Encoding UTF8
Write-Host ("{0} arquivo(s) de teste em {1}; relatorio em {2}" -f $report.Count, $outFull, $reportPath)
