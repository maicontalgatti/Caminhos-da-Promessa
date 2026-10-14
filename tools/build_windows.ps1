# Gera CaminhosDaPromessa.exe (Windows x86_64, release, PCK embutido) na raiz
# do projeto. dist\windows é a área de montagem; o .exe da raiz só é substituído
# se todos os testes passarem. Atalho com duplo clique: criar_exe_atualizado.bat
#
# Uso (PowerShell, a partir de qualquer pasta):
#   .\tools\build_windows.ps1                  # build completo com validações e testes
#   .\tools\build_windows.ps1 -SkipTests       # pula os testes do projeto (não recomendado)
#   .\tools\build_windows.ps1 -SkipExeTest     # não executa o .exe gerado
#   .\tools\build_windows.ps1 -NoRenderTest    # não abre janela (máquinas sem GPU / CI)
#   .\tools\build_windows.ps1 -NoDownload      # falha em vez de baixar templates ausentes
#   .\tools\build_windows.ps1 -Godot C:\caminho\Godot_console.exe
#
# Retorna código 0 em caso de sucesso e 1 em caso de falha.
[CmdletBinding()]
param(
    [string]$Godot = "",
    [switch]$SkipTests,
    [switch]$SkipExeTest,
    [switch]$NoRenderTest,
    [switch]$NoDownload
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$presetName = "Windows Desktop"
$exeName = "CaminhosDaPromessa.exe"
$distDir = Join-Path $root "dist\windows"
$logDir = Join-Path $root "dist\logs"
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
New-Item -ItemType Directory -Force $logDir | Out-Null
$logFile = Join-Path $logDir "build-windows-$stamp.log"
$started = Get-Date

function Log([string]$msg, [string]$color = "Gray") {
    $line = "[{0}] {1}" -f (Get-Date -Format "HH:mm:ss"), $msg
    Write-Host $line -ForegroundColor $color
    Add-Content -Path $logFile -Value $line -Encoding UTF8
}

function Fail([string]$msg) {
    Log "FALHA: $msg" "Red"
    Log "Log completo: $logFile" "Red"
    exit 1
}

function Quote([string]$a) {
    if ($a -match '[\s"]') { return '"' + ($a -replace '"', '\"') + '"' }
    return $a
}

# Executa um processo, grava stdout/stderr no log e devolve código e saída.
function Invoke-Tool([string]$exe, [string[]]$argList, [string]$label, [int]$timeoutSec = 600, [string]$workDir = $root) {
    Log "> $label"
    $out = Join-Path $env:TEMP "cdp-$stamp-out.txt"
    $err = Join-Path $env:TEMP "cdp-$stamp-err.txt"
    $argString = ($argList | ForEach-Object { Quote $_ }) -join " "
    Add-Content -Path $logFile -Value "    $exe $argString" -Encoding UTF8
    $p = Start-Process -FilePath $exe -ArgumentList $argString -WorkingDirectory $workDir `
        -RedirectStandardOutput $out -RedirectStandardError $err -NoNewWindow -PassThru
    $null = $p.Handle
    $timedOut = -not $p.WaitForExit($timeoutSec * 1000)
    if ($timedOut) { try { $p.Kill() } catch {} }
    $p.WaitForExit()
    $text = ""
    foreach ($f in @($out, $err)) {
        if (Test-Path $f) { $text += (Get-Content $f -Raw -Encoding UTF8); Remove-Item $f -Force }
    }
    if ($null -eq $text) { $text = "" }
    # Remove a barra de progresso do importador para manter o log legível.
    $clean = ($text -split "`r?`n" | Where-Object { $_ -notmatch '^\s*$' -and $_ -notmatch '\[\s*\d+% \]|\[ DONE \]' }) -join "`n"
    if ($clean) { Add-Content -Path $logFile -Value $clean -Encoding UTF8 }
    if ($timedOut) { Fail "$label excedeu o tempo limite de $timeoutSec s (saída no log)" }
    return @{ Code = $p.ExitCode; Text = $clean }
}

function Get-ErrorLines([string]$text) {
    return @($text -split "`n" | Where-Object { $_ -match '^\s*(SCRIPT ERROR|ERROR|Parse Error|USER ERROR)' })
}

Log "=== Caminhos da Promessa - build Windows ===" "Cyan"
Log "Projeto: $root"

# 1. project.godot
$projectFile = Join-Path $root "project.godot"
if (-not (Test-Path $projectFile)) { Fail "project.godot não encontrado em $root" }
$projectText = Get-Content $projectFile -Raw -Encoding UTF8
$gameVersion = "0.0.0"
if ($projectText -match 'config/version="([^"]+)"') { $gameVersion = $Matches[1] }
Log "Versão do jogo (project.godot): $gameVersion"

# 2. Godot
if (-not $Godot) { $Godot = $env:GODOT_BIN }
if (-not $Godot) {
    $candidate = Get-ChildItem (Join-Path $root "tools\godot") -Filter "Godot_v*_win64_console.exe" -ErrorAction SilentlyContinue |
        Sort-Object Name -Descending | Select-Object -First 1
    if ($candidate) { $Godot = $candidate.FullName }
}
if (-not $Godot) {
    $cmd = Get-Command godot -ErrorAction SilentlyContinue
    if ($cmd) { $Godot = $cmd.Source }
}
if (-not $Godot -or -not (Test-Path $Godot)) {
    Fail "Executável do Godot não encontrado. Use -Godot <caminho>, defina GODOT_BIN ou coloque o Godot em tools\godot\."
}
Log "Godot: $Godot"
$verResult = Invoke-Tool $Godot @("--version") "Versão do Godot" 60
$fullVersion = ($verResult.Text -split "`n" | Where-Object { $_ -match '^\d+\.\d+' } | Select-Object -First 1)
if (-not $fullVersion) { Fail "Não foi possível ler a versão do Godot" }
$fullVersion = $fullVersion.Trim()
# "4.7.2.stable.official.ed1daf0bf" -> "4.7.2.stable" (nome da pasta de templates)
$parts = $fullVersion.Split(".")
$tplParts = @()
foreach ($part in $parts) { $tplParts += $part; if ($part -notmatch '^\d+$') { break } }
$tplVersion = $tplParts -join "."
Log "Versão real do Godot: $fullVersion (templates: $tplVersion)"
if ($projectText -match 'config/features=PackedStringArray\("(\d+\.\d+)"') {
    $projMinor = $Matches[1]
    if (-not $tplVersion.StartsWith("$projMinor.") -and $tplVersion -ne "$projMinor") {
        Log "AVISO: projeto marcado para Godot $projMinor, mas a versão encontrada é $tplVersion" "Yellow"
    }
}

# 3. Templates de exportação
$godotDir = Split-Path -Parent $Godot
if ((Test-Path (Join-Path $godotDir "_sc_")) -or (Test-Path (Join-Path $godotDir "._sc_"))) {
    $templatesRoot = Join-Path $godotDir "editor_data\export_templates"
} else {
    $templatesRoot = Join-Path $env:APPDATA "Godot\export_templates"
}
$tplDir = Join-Path $templatesRoot $tplVersion
$releaseTpl = Join-Path $tplDir "windows_release_x86_64.exe"
$verFile = Join-Path $tplDir "version.txt"
$tplOk = (Test-Path $releaseTpl) -and (Test-Path $verFile) -and ((Get-Content $verFile -Raw).Trim() -eq $tplVersion)
if (-not $tplOk) {
    if ($NoDownload) { Fail "Templates $tplVersion ausentes em $tplDir (use sem -NoDownload para instalar)" }
    Log "Templates $tplVersion ausentes; instalando..." "Yellow"
    & (Join-Path $PSScriptRoot "install_export_templates.ps1") -Version $tplVersion -TemplatesDir $templatesRoot *>&1 |
        ForEach-Object { Log "    $_" }
    $tplOk = (Test-Path $releaseTpl) -and ((Get-Content $verFile -Raw).Trim() -eq $tplVersion)
    if (-not $tplOk) { Fail "Instalação dos templates não concluída" }
}
Log ("Template release: {0} ({1:N1} MB)" -f $releaseTpl, ((Get-Item $releaseTpl).Length / 1MB))

# 4. Predefinição de exportação
$presetsFile = Join-Path $root "export_presets.cfg"
if (-not (Test-Path $presetsFile)) { Fail "export_presets.cfg não encontrado" }
$presets = Get-Content $presetsFile -Raw -Encoding UTF8
if ($presets -notmatch "name=`"$presetName`"") { Fail "Predefinição '$presetName' não existe em export_presets.cfg" }
foreach ($required in @('binary_format/embed_pck=true', 'include_filter="[^"]*data/\*\.json')) {
    if ($presets -notmatch $required) { Fail "export_presets.cfg sem a configuração obrigatória: $required" }
}
# Mantém a versão do executável sincronizada com project.godot.
$numeric = ($gameVersion -replace '[^\d\.]', '').Split(".") | Where-Object { $_ -ne "" }
while ($numeric.Count -lt 4) { $numeric += "0" }
$fileVersion = ($numeric[0..3]) -join "."
$updated = $presets -replace 'application/file_version="[^"]*"', "application/file_version=`"$fileVersion`"" `
                    -replace 'application/product_version="[^"]*"', "application/product_version=`"$fileVersion`""
if ($updated -ne $presets) {
    [System.IO.File]::WriteAllText($presetsFile, $updated, (New-Object System.Text.UTF8Encoding($false)))
    Log "Versão do executável atualizada para $fileVersion em export_presets.cfg"
}

# 5. Importação de recursos (incremental)
$imp = Invoke-Tool $Godot @("--headless", "--path", $root, "--import") "Importando recursos" 900
$impErrors = Get-ErrorLines $imp.Text
if ($imp.Code -ne 0 -or $impErrors.Count -gt 0) {
    $impErrors | ForEach-Object { Log "    $_" "Red" }
    Fail "Erros durante a importação (código $($imp.Code))"
}
Log "Importação OK" "Green"

# 6. Validação antes de exportar
if ($SkipTests) {
    Log "AVISO: testes do projeto pulados (-SkipTests)" "Yellow"
} else {
    $t1 = Invoke-Tool $Godot @("--headless", "--path", $root, "res://tests/test_runner.tscn") "Testes do projeto" 600
    $summary = ($t1.Text -split "`n" | Where-Object { $_ -match 'passaram' } | Select-Object -Last 1)
    $errs = Get-ErrorLines $t1.Text
    if ($t1.Code -ne 0 -or $errs.Count -gt 0) {
        $t1.Text -split "`n" | Where-Object { $_ -match 'FAIL|ERROR' } | ForEach-Object { Log "    $_" "Red" }
        Fail "Testes do projeto falharam ($summary)"
    }
    Log "Testes do projeto: $summary" "Green"
    $t2 = Invoke-Tool $Godot @("--headless", "--path", $root, "--script", "res://tests/flow_smoke.gd") "Teste de fluxo de menus" 300
    $summary2 = ($t2.Text -split "`n" | Where-Object { $_ -match 'passaram' } | Select-Object -Last 1)
    if ($t2.Code -ne 0 -or (Get-ErrorLines $t2.Text).Count -gt 0) { Fail "Teste de fluxo falhou ($summary2)" }
    Log "Teste de fluxo: $summary2" "Green"
    $vc = Invoke-Tool $Godot @("--headless", "--path", $root, "--script", "res://tools/validate_content.gd") "Validação de conteúdo bíblico e missões" 120
    $vc.Text -split "`n" | Where-Object { $_ -match 'ERRO|NÃO podem|missão |==' } | ForEach-Object { Log "    $_" }
    if ($vc.Code -ne 0 -or (Get-ErrorLines $vc.Text).Count -gt 0) { Fail "Validação de conteúdo encontrou erros de dados" }
    Log "Validação de conteúdo: sem erros de dados (itens sem aprovação humana listados acima)" "Green"
}

# 6b. Documentação da AI Wiki (informativo: não bloqueia a build)
$wikiCheck = Join-Path $PSScriptRoot "check_wiki.ps1"
if (Test-Path $wikiCheck) {
    $wk = Invoke-Tool "powershell.exe" @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $wikiCheck) "Verificação da AI Wiki" 120
    $wk.Text -split "`n" | Where-Object { $_ -match '^(WIKI|ERRO|AVISO)' } | ForEach-Object { Log "    $_" }
    if ($wk.Code -ne 0) { Log "AVISO: a AI Wiki tem problemas (veja acima); a build continua" "Yellow" }
}

# 7. Exportação release
if (Test-Path $distDir) { Remove-Item $distDir -Recurse -Force }
New-Item -ItemType Directory -Force $distDir | Out-Null
$exePath = Join-Path $distDir $exeName
$exp = Invoke-Tool $Godot @("--headless", "--path", $root, "--export-release", $presetName, $exePath) "Exportando ($presetName, release)" 900
$expErrors = Get-ErrorLines $exp.Text
if ($exp.Code -ne 0 -or $expErrors.Count -gt 0) {
    $expErrors | ForEach-Object { Log "    $_" "Red" }
    Fail "Exportação falhou (código $($exp.Code))"
}

# 8. Verificação do executável
if (-not (Test-Path $exePath)) { Fail "Exportação terminou, mas $exePath não foi criado" }
$exeSize = (Get-Item $exePath).Length
$tplSize = (Get-Item $releaseTpl).Length
$loosePck = Get-ChildItem $distDir -Filter "*.pck" -ErrorAction SilentlyContinue
if ($loosePck) { Fail "Foi gerado um .pck separado; o PCK deveria estar embutido no .exe" }
if ($exeSize -le $tplSize) { Fail "O executável não é maior que o template; o PCK não parece ter sido embutido" }
$sha = (Get-FileHash $exePath -Algorithm SHA256).Hash
Log ("Executável criado: {0} ({1:N1} MB; dados embutidos: {2:N1} MB)" -f $exePath, ($exeSize / 1MB), (($exeSize - $tplSize) / 1MB)) "Green"

# Avisos de licença ao lado do executável.
$translationId = (Select-String -Path (Join-Path $root "project.godot") -Pattern 'bible_translation="([^"]+)"').Matches[0].Groups[1].Value
$scriptureCredit = (Get-Content (Join-Path $root "data\bible\texts\$translationId.json") -Raw -Encoding UTF8 | ConvertFrom-Json).translation.credit
$licenses = @"
Caminhos da Promessa $gameVersion
https://github.com/maicontalgatti/Caminhos-da-Promessa

Código: licença MIT. Arte, sons e textos próprios: CC BY 4.0 (LICENSE e LICENSE-ASSETS.md no repositório).
Fontes Pixelify Sans e Lora - SIL Open Font License 1.1 (textos completos abaixo).
Godot Engine - licença MIT, https://godotengine.org/license
$scriptureCredit

---------------------------------------------------------------------
"@
$licenses += "`r`n" + (Get-Content (Join-Path $root "assets\fonts\OFL.txt") -Raw -Encoding UTF8)
$licenses += "`r`n---------------------------------------------------------------------`r`nLora`r`n" + (Get-Content (Join-Path $root "assets\fonts\OFL-Lora.txt") -Raw -Encoding UTF8)
[System.IO.File]::WriteAllText((Join-Path $distDir "LICENSES.txt"), $licenses, (New-Object System.Text.UTF8Encoding($false)))

# 9. Teste automatizado do executável (cópia isolada, fora da pasta do projeto)
if ($SkipExeTest) {
    Log "AVISO: teste do executável pulado (-SkipExeTest)" "Yellow"
} else {
    $sandbox = Join-Path $env:TEMP "CaminhosDaPromessa-exetest-$stamp"
    New-Item -ItemType Directory -Force $sandbox | Out-Null
    $sandboxExe = Join-Path $sandbox $exeName
    Copy-Item $exePath $sandboxExe

    # Templates de exportação ignoram --script; o autoteste é ativado pelo
    # argumento de usuário --self-test (ver scripts/build/export_self_test.gd).
    $selfLog = Join-Path $logDir "exe-selftest-$stamp.log"
    $st = Invoke-Tool $sandboxExe @("--headless", "--", "--self-test") "Autoteste do executável (dados, mapa, save)" 120 $sandbox
    $stText = $st.Text
    Set-Content -Path $selfLog -Value $stText -Encoding UTF8
    $stText -split "`r?`n" | Where-Object { $_ -match '^\s+(ok|FAIL|info)' } | ForEach-Object { Log "    $_" }
    $stErrors = Get-ErrorLines $stText
    if ($st.Code -ne 0 -or $stText -notmatch 'AUTOTESTE: OK' -or $stErrors.Count -gt 0) {
        $stErrors | ForEach-Object { Log "    $_" "Red" }
        Fail "Autoteste do executável falhou (código $($st.Code)); veja $selfLog"
    }
    Log "Autoteste do executável: OK" "Green"

    $bootLog = Join-Path $logDir "exe-boot-headless-$stamp.log"
    $bt = Invoke-Tool $sandboxExe @("--headless", "--quit-after", "600") "Inicialização normal do jogo (headless, 600 quadros)" 120 $sandbox
    $btText = $bt.Text
    Set-Content -Path $bootLog -Value $btText -Encoding UTF8
    $btErrors = Get-ErrorLines $btText
    if ($bt.Code -ne 0 -or $btErrors.Count -gt 0) {
        $btErrors | ForEach-Object { Log "    $_" "Red" }
        Fail "O jogo exportado apresentou erros ao iniciar; veja $bootLog"
    }
    Log "Inicialização headless: OK" "Green"

    if ($NoRenderTest) {
        Log "AVISO: teste com renderização pulado (-NoRenderTest)" "Yellow"
    } else {
        $renderLog = Join-Path $logDir "exe-boot-render-$stamp.log"
        $rt = Invoke-Tool $sandboxExe @("--quit-after", "240") "Inicialização com janela e GPU (240 quadros)" 120 $sandbox
        $rtText = $rt.Text
        Set-Content -Path $renderLog -Value $rtText -Encoding UTF8
        $renderer = ($rtText -split "`r?`n" | Where-Object { $_ -match '^(OpenGL|Vulkan|D3D12)' } | Select-Object -First 1)
        $rtErrors = Get-ErrorLines $rtText
        if ($rt.Code -ne 0 -or $rtErrors.Count -gt 0) {
            $rtErrors | ForEach-Object { Log "    $_" "Red" }
            Fail "O jogo exportado apresentou erros com renderização; veja $renderLog"
        }
        Log "Inicialização com renderização: OK ($renderer)" "Green"
    }
    Remove-Item $sandbox -Recurse -Force -ErrorAction SilentlyContinue
    Log "Lembrete: estes testes verificam inicialização e dados; não substituem jogar e avaliar a interface." "Yellow"
}

# 10. Cópia final na raiz do projeto, só depois de todos os testes passarem,
# para que uma build com defeito nunca substitua o .exe que já funcionava.
$finalExe = Join-Path $root $exeName
try {
    Copy-Item $exePath $finalExe -Force
} catch {
    Fail "Não foi possível substituir $finalExe. O jogo está aberto? Feche-o e rode de novo. ($($_.Exception.Message))"
}
if ((Get-FileHash $finalExe -Algorithm SHA256).Hash -ne $sha) { Fail "Cópia de $finalExe ficou diferente da build" }

$elapsed = (Get-Date) - $started
Log "=== BUILD CONCLUÍDO ===" "Cyan"
Log "Arquivo: $finalExe" "Cyan"
Log ("Tamanho: {0:N1} MB" -f ($exeSize / 1MB)) "Cyan"
Log "SHA-256: $sha" "Cyan"
Log ("Duração: {0:mm\:ss}" -f $elapsed) "Cyan"
Log "Log: $logFile" "Cyan"
exit 0
