# Verifica a estrutura e os links da AI Wiki (docs/ai-wiki) e da documentacao do projeto.
# Uso (na raiz do projeto):  powershell -ExecutionPolicy Bypass -File tools\check_wiki.ps1 [-Strict]
# Codigo de saida: 0 sem erros; 1 com erros (com -Strict, avisos tambem contam como erro).
# Nao verifica se o conteudo descreve corretamente o codigo: isso continua sendo revisao humana.
param([switch]$Strict)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$utf8 = New-Object System.Text.UTF8Encoding($false)
$errors = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]

function Rel([string]$path) { return $path.Substring($root.Length + 1).Replace('\', '/') }
function Read-Text([string]$path) { return [System.IO.File]::ReadAllText($path, $utf8) }

# 1. Arquivos obrigatorios
$required = @(
    "AGENTS.md",
    "docs/ai-wiki/README.md", "docs/ai-wiki/PROJECT_OVERVIEW.md", "docs/ai-wiki/CURRENT_STATE.md",
    "docs/ai-wiki/ARCHITECTURE_MAP.md", "docs/ai-wiki/GAME_SYSTEMS.md", "docs/ai-wiki/BIBLICAL_RULES.md",
    "docs/ai-wiki/DEVELOPMENT_RULES.md", "docs/ai-wiki/DECISIONS.md", "docs/ai-wiki/KNOWN_ISSUES.md",
    "docs/ai-wiki/TESTING.md", "docs/ai-wiki/HANDOFF.md", "docs/ai-wiki/CHANGELOG.md"
)
foreach ($r in $required) {
    if (-not (Test-Path (Join-Path $root $r))) { $errors.Add("arquivo obrigatorio ausente: $r") }
}

# 2. Links relativos e caminhos citados entre crases
$docs = @()
foreach ($f in @("AGENTS.md", "README.md")) {
    $p = Join-Path $root $f
    if (Test-Path $p) { $docs += Get-Item $p }
}
$docs += Get-ChildItem (Join-Path $root "docs") -Recurse -Filter *.md
$docs += Get-ChildItem (Join-Path $root ".cursor\rules") -Filter *.mdc -ErrorAction SilentlyContinue

$linkRe = [regex]'!?\[[^\]]*\]\(([^)\s]+)(?:\s+"[^"]*")?\)'
$tickRe = [regex]'`([^`\s]+)`'
$repoPrefix = '^(res://)?(scripts|scenes|data|docs|tools|tests|addons|assets)/'
$rootFiles = @("project.godot", "export_presets.cfg", "AGENTS.md", "README.md", "criar_exe_atualizado.bat", ".gitignore")
# Caminhos ignorados pelo Git (podem nao existir num clone novo)
$ignored = '^(tools/godot|build|dist|\.godot)(/|$)|^CaminhosDaPromessa\.exe$'
$linkCount = 0
$pathCount = 0

foreach ($doc in $docs) {
    $dir = Split-Path -Parent $doc.FullName
    $inFence = $false
    $lineNo = 0
    foreach ($line in (Read-Text $doc.FullName) -split "`n") {
        $lineNo++
        if ($line.TrimStart().StartsWith('```')) { $inFence = -not $inFence; continue }
        if ($inFence) { continue }
        foreach ($m in $linkRe.Matches($line)) {
            $target = $m.Groups[1].Value
            if ($target -match '^(https?:|mailto:|#)') { continue }
            $target = [uri]::UnescapeDataString(($target -split '#')[0])
            if ($target -eq "") { continue }
            $linkCount++
            if (-not (Test-Path (Join-Path $dir $target))) {
                $errors.Add("link quebrado em $(Rel $doc.FullName):$lineNo -> $target")
            }
        }
        foreach ($m in $tickRe.Matches($line)) {
            $v = $m.Groups[1].Value
            if (-not (($v -match $repoPrefix) -or ($rootFiles -contains $v))) { continue }
            if ($v -match '[\*<>\{\}\|]') { continue }
            $v = $v -replace '^res://', ''
            $v = $v.TrimEnd('.', ',', ';', ':')
            if ($v -match $ignored) { continue }
            $pathCount++
            if (-not (Test-Path (Join-Path $root $v))) {
                $errors.Add("caminho citado nao existe em $(Rel $doc.FullName):$lineNo -> $v")
            }
        }
    }
}

# 3. Conteudo minimo
$agents = Join-Path $root "AGENTS.md"
if (Test-Path $agents) {
    $t = Read-Text $agents
    if ($t -notmatch 'Antes de realizar altera') { $errors.Add("AGENTS.md sem a instrucao obrigatoria de consultar a AI Wiki") }
    $n = ($t -split "`n").Count
    if ($n -gt 120) { $warnings.Add("AGENTS.md tem $n linhas; deve continuar curto (ate ~120)") }
}

$state = Join-Path $root "docs/ai-wiki/CURRENT_STATE.md"
$stateDate = $null
if (Test-Path $state) {
    $t = Read-Text $state
    foreach ($field in @('\*\*Vers.o:\*\*', '\*\*.ltima atualiza..o:\*\*', '\*\*Commit de refer.ncia:\*\*', '\*\*Fase:\*\*')) {
        if ($t -notmatch $field) { $errors.Add("CURRENT_STATE.md sem o campo $field") }
    }
    $m = [regex]::Match($t, '\*\*.ltima atualiza..o:\*\*\s*(\d{4}-\d{2}-\d{2})')
    if ($m.Success) { $stateDate = [datetime]::ParseExact($m.Groups[1].Value, 'yyyy-MM-dd', $null) }
    else { $errors.Add("CURRENT_STATE.md: data da ultima atualizacao ausente ou fora do formato AAAA-MM-DD") }
    $v = [regex]::Match($t, '\*\*Vers.o:\*\*\s*([0-9][0-9.]*)')
    $proj = [regex]::Match((Read-Text (Join-Path $root "project.godot")), 'config/version="([^"]+)"')
    if ($v.Success -and $proj.Success -and $v.Groups[1].Value.TrimEnd('.') -ne $proj.Groups[1].Value) {
        $errors.Add("versao em CURRENT_STATE.md ($($v.Groups[1].Value)) difere de project.godot ($($proj.Groups[1].Value))")
    }
}

$handoff = Join-Path $root "docs/ai-wiki/HANDOFF.md"
$handoffDate = $null
if (Test-Path $handoff) {
    $t = Read-Text $handoff
    foreach ($section in @('## .ltima tarefa', '## Resultado', '## Testes', '## Pend.ncias', '## Pr.xima a..o', '## Cuidados')) {
        if ($t -notmatch $section) { $errors.Add("HANDOFF.md sem a secao '$section'") }
    }
    $m = [regex]::Match($t, '\*\*Data:\*\*\s*(\d{4}-\d{2}-\d{2})')
    if ($m.Success) { $handoffDate = [datetime]::ParseExact($m.Groups[1].Value, 'yyyy-MM-dd', $null) }
    else { $errors.Add("HANDOFF.md: campo **Data:** AAAA-MM-DD ausente") }
}

$rules = Get-ChildItem (Join-Path $root ".cursor\rules") -Filter *.mdc -ErrorAction SilentlyContinue
if (-not $rules) { $warnings.Add("nenhuma regra em .cursor/rules (Cursor nao vai apontar para a wiki automaticamente)") }
elseif (-not ($rules | Where-Object { (Read-Text $_.FullName) -match 'alwaysApply:\s*true' -and (Read-Text $_.FullName) -match 'AGENTS\.md' })) {
    $warnings.Add("nenhuma regra alwaysApply em .cursor/rules aponta para AGENTS.md")
}

# 4. Desatualizacao (heuristica por data de modificacao; nao substitui revisao)
$codeDirs = @("scripts", "scenes", "data", "addons", "tests", "tools") | ForEach-Object { Join-Path $root $_ }
$newest = Get-ChildItem $codeDirs -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch '\\tools\\godot\\' -and $_.Extension -notin @('.uid', '.import') } |
    Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($newest) {
    $day = $newest.LastWriteTime.Date
    if ($stateDate -and $day -gt $stateDate) {
        $warnings.Add("CURRENT_STATE.md ($($stateDate.ToString('yyyy-MM-dd'))) e mais antigo que $(Rel $newest.FullName) ($($day.ToString('yyyy-MM-dd'))): confira se o estado mudou")
    }
    if ($handoffDate -and $day -gt $handoffDate) {
        $warnings.Add("HANDOFF.md ($($handoffDate.ToString('yyyy-MM-dd'))) e mais antigo que $(Rel $newest.FullName): atualize a passagem de bastao")
    }
}

# Relatorio
Write-Host "Wiki: $($docs.Count) documentos, $linkCount links relativos, $pathCount caminhos citados verificados."
foreach ($w in $warnings) { Write-Host "AVISO: $w" }
foreach ($e in $errors) { Write-Host "ERRO: $e" }
$fail = $errors.Count -gt 0 -or ($Strict -and $warnings.Count -gt 0)
if ($fail) { Write-Host "WIKI: FALHOU ($($errors.Count) erros, $($warnings.Count) avisos)"; exit 1 }
Write-Host "WIKI: OK ($($warnings.Count) avisos)"
exit 0
