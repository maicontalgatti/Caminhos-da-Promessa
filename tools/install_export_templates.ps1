# Instala os templates oficiais de exportação Windows do Godot.
# Baixa o pacote .tpz oficial (cerca de 1,2 GB) para tools/godot/cache, confere o
# SHA-512 publicado pelo projeto Godot e extrai apenas os arquivos do Windows
# para %APPDATA%\Godot\export_templates\<versão>\.
#
# Uso: .\tools\install_export_templates.ps1 -Version 4.7.2.stable
param(
    [Parameter(Mandatory = $true)][string]$Version,
    [string]$TemplatesDir = (Join-Path $env:APPDATA "Godot\export_templates"),
    [switch]$KeepCache
)
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot

# "4.7.2.stable" -> tag "4.7.2-stable"; "4.7.stable" -> "4.7-stable"
if ($Version -notmatch '^(\d+\.\d+(?:\.\d+)?)\.([a-z0-9]+)$') { throw "Versão inesperada: $Version" }
$tag = "$($Matches[1])-$($Matches[2])"
$tpzName = "Godot_v$tag`_export_templates.tpz"
$baseUrl = "https://github.com/godotengine/godot/releases/download/$tag"
$cache = Join-Path $root "tools\godot\cache"
$tpz = Join-Path $cache $tpzName
$sums = Join-Path $cache "SHA512-SUMS-$tag.txt"
$dest = Join-Path $TemplatesDir $Version
New-Item -ItemType Directory -Force $cache, $dest | Out-Null

Write-Host "Baixando lista de SHA-512 ($tag)..."
& curl.exe -L --fail -s -o $sums "$baseUrl/SHA512-SUMS.txt"
if ($LASTEXITCODE -ne 0) { throw "Falha ao baixar SHA512-SUMS.txt de $baseUrl" }
$expected = (Get-Content $sums | Where-Object { $_ -match "\s$([regex]::Escape($tpzName))$" } | ForEach-Object { ($_ -split '\s+')[0] }) | Select-Object -First 1
if (-not $expected) { throw "Hash de $tpzName não encontrado em SHA512-SUMS.txt" }

function Test-Tpz {
    if (-not (Test-Path $tpz)) { return $false }
    Write-Host "Conferindo SHA-512 de $tpzName..."
    return ((Get-FileHash $tpz -Algorithm SHA512).Hash -ieq $expected)
}

if (-not (Test-Tpz)) {
    Write-Host "Baixando $tpzName (cerca de 1,2 GB)..."
    & curl.exe -L --fail -C - -o $tpz "$baseUrl/$tpzName"
    if ($LASTEXITCODE -ne 0) { throw "Falha no download de $tpzName" }
    if (-not (Test-Tpz)) { Remove-Item $tpz -Force; throw "SHA-512 não confere; arquivo removido. Tente novamente." }
}
Write-Host "SHA-512 confere."

Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::OpenRead($tpz)
try {
    $wanted = $zip.Entries | Where-Object { $_.FullName -match '^templates/(windows_[^/]+|version\.txt)$' }
    if (-not ($wanted | Where-Object { $_.Name -eq "windows_release_x86_64.exe" })) {
        throw "windows_release_x86_64.exe não está no pacote"
    }
    foreach ($e in $wanted) {
        $out = Join-Path $dest $e.Name
        Write-Host "  extraindo $($e.Name)"
        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($e, $out, $true)
    }
} finally { $zip.Dispose() }

$verTxt = (Get-Content (Join-Path $dest "version.txt") -Raw).Trim()
if ($verTxt -ne $Version) { throw "version.txt ($verTxt) não corresponde a $Version" }
if (-not $KeepCache) { Remove-Item $tpz -Force; Write-Host "Cache do .tpz removido." }
Write-Host "Templates Windows $Version instalados em $dest"
