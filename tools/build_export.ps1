# Gera builds release (PCK embutido) para Windows e Linux, com o SO no nome:
#   CaminhosDaPromessa-Windows.exe
#   CaminhosDaPromessa-Linux.x86_64
# Montagem em dist\windows e dist\linux; cópia para a raiz só se os testes passarem.
# Atalho: criar_exe_atualizado.bat (chama este script).
#
# Uso:
#   .\tools\build_export.ps1
#   .\tools\build_export.ps1 -Platform Windows
#   .\tools\build_export.ps1 -Platform Linux
#   .\tools\build_export.ps1 -SkipTests
#   .\tools\build_export.ps1 -SkipExeTest
#   .\tools\build_export.ps1 -NoRenderTest
#   .\tools\build_export.ps1 -NoDownload
#   .\tools\build_export.ps1 -Godot C:\caminho\Godot_console.exe
[CmdletBinding()]
param(
    [string]$Godot = "",
    [ValidateSet("All", "Windows", "Linux")]
    [string]$Platform = "All",
    [switch]$SkipTests,
    [switch]$SkipExeTest,
    [switch]$NoRenderTest,
    [switch]$NoDownload
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$logDir = Join-Path $root "dist\logs"
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
New-Item -ItemType Directory -Force $logDir | Out-Null
$logFile = Join-Path $logDir "build-export-$stamp.log"
$started = Get-Date

$targets = @(
    @{
        Id = "Windows"
        Preset = "Windows Desktop"
        DistSub = "windows"
        OutName = "CaminhosDaPromessa-Windows.exe"
        TemplateRelease = "windows_release_x86_64.exe"
        CanRunOnHost = ($env:OS -match "Windows") -or ($IsWindows -eq $true)
    },
    @{
        Id = "Linux"
        Preset = "Linux"
        DistSub = "linux"
        OutName = "CaminhosDaPromessa-Linux.x86_64"
        TemplateRelease = "linux_release.x86_64"
        CanRunOnHost = ($IsLinux -eq $true)
    }
)
if ($Platform -ne "All") {
    $targets = @($targets | Where-Object { $_.Id -eq $Platform })
}
if ($targets.Count -eq 0) { throw "Nenhuma plataforma selecionada" }

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
    $clean = ($text -split "`r?`n" | Where-Object { $_ -notmatch '^\s*$' -and $_ -notmatch '\[\s*\d+% \]|\[ DONE \]' }) -join "`n"
    if ($clean) { Add-Content -Path $logFile -Value $clean -Encoding UTF8 }
    if ($timedOut) { Fail "$label excedeu o tempo limite de $timeoutSec s (saída no log)" }
    return @{ Code = $p.ExitCode; Text = $clean }
}

function Get-ErrorLines([string]$text) {
    return @($text -split "`n" | Where-Object { $_ -match '^\s*(SCRIPT ERROR|ERROR|Parse Error|USER ERROR)' })
}

function Get-TestFailureLines([string]$text) {
    # Padrões sem acento: o PowerShell 5.1 pode ler o .ps1 com encoding diferente do UTF-8 do Godot.
    return @($text -split "`n" | Where-Object {
        $_ -match '^\s*FAIL\s' -or
        $_ -match '^\s*(SCRIPT ERROR|Parse Error|USER ERROR)' -or
        ($_ -match '^\s*ERROR:' -and $_ -notmatch 'RID allocations|resources still in use|ObjectDB instances|Failed to open|copiar o save antigo|ele foi mantido')
    })
}

function Test-SuitePassed([hashtable]$result) {
    $summary = ($result.Text -split "`n" | Where-Object { $_ -match 'passaram' } | Select-Object -Last 1)
    $fails = Get-TestFailureLines $result.Text
    return @{
        Ok = ($result.Code -eq 0) -and ($summary -match ',\s*0 falharam') -and ($fails.Count -eq 0)
        Summary = $summary
        Failures = $fails
    }
}

Log "=== Caminhos da Promessa - build export ($(($targets | ForEach-Object { $_.Id }) -join ', ')) ===" "Cyan"
Log "Projeto: $root"

$projectFile = Join-Path $root "project.godot"
if (-not (Test-Path $projectFile)) { Fail "project.godot não encontrado em $root" }
$projectText = Get-Content $projectFile -Raw -Encoding UTF8
$gameVersion = "0.0.0"
if ($projectText -match 'config/version="([^"]+)"') { $gameVersion = $Matches[1] }
Log "Versão do jogo (project.godot): $gameVersion"

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

$godotDir = Split-Path -Parent $Godot
if ((Test-Path (Join-Path $godotDir "_sc_")) -or (Test-Path (Join-Path $godotDir "._sc_"))) {
    $templatesRoot = Join-Path $godotDir "editor_data\export_templates"
} else {
    $templatesRoot = Join-Path $env:APPDATA "Godot\export_templates"
}
$tplDir = Join-Path $templatesRoot $tplVersion
$verFile = Join-Path $tplDir "version.txt"

function Test-TemplatesReady {
    if (-not (Test-Path $verFile)) { return $false }
    if ((Get-Content $verFile -Raw).Trim() -ne $tplVersion) { return $false }
    foreach ($t in $targets) {
        if (-not (Test-Path (Join-Path $tplDir $t.TemplateRelease))) { return $false }
    }
    return $true
}

if (-not (Test-TemplatesReady)) {
    if ($NoDownload) { Fail "Templates $tplVersion ausentes em $tplDir (use sem -NoDownload para instalar)" }
    Log "Templates $tplVersion incompletos; instalando Windows + Linux..." "Yellow"
    & (Join-Path $PSScriptRoot "install_export_templates.ps1") -Version $tplVersion -TemplatesDir $templatesRoot *>&1 |
        ForEach-Object { Log "    $_" }
    if (-not (Test-TemplatesReady)) { Fail "Instalação dos templates não concluída" }
}
foreach ($t in $targets) {
    $p = Join-Path $tplDir $t.TemplateRelease
    Log ("Template {0}: {1} ({2:N1} MB)" -f $t.Id, $p, ((Get-Item $p).Length / 1MB))
}

$presetsFile = Join-Path $root "export_presets.cfg"
if (-not (Test-Path $presetsFile)) { Fail "export_presets.cfg não encontrado" }
$presets = Get-Content $presetsFile -Raw -Encoding UTF8
foreach ($t in $targets) {
    if ($presets -notmatch [regex]::Escape("name=`"$($t.Preset)`"")) {
        Fail "Predefinição '$($t.Preset)' não existe em export_presets.cfg"
    }
}
foreach ($required in @('binary_format/embed_pck=true', 'include_filter="[^"]*data/\*\.json')) {
    if ($presets -notmatch $required) { Fail "export_presets.cfg sem a configuração obrigatória: $required" }
}
$numeric = ($gameVersion -replace '[^\d\.]', '').Split(".") | Where-Object { $_ -ne "" }
while ($numeric.Count -lt 4) { $numeric += "0" }
$fileVersion = ($numeric[0..3]) -join "."
$updated = $presets -replace 'application/file_version="[^"]*"', "application/file_version=`"$fileVersion`"" `
                    -replace 'application/product_version="[^"]*"', "application/product_version=`"$fileVersion`""
if ($updated -ne $presets) {
    [System.IO.File]::WriteAllText($presetsFile, $updated, (New-Object System.Text.UTF8Encoding($false)))
    Log "Versão do executável Windows atualizada para $fileVersion em export_presets.cfg"
    $presets = $updated
}

$imp = Invoke-Tool $Godot @("--headless", "--path", $root, "--import") "Importando recursos" 900
$impErrors = Get-ErrorLines $imp.Text
if ($imp.Code -ne 0 -or $impErrors.Count -gt 0) {
    $impErrors | ForEach-Object { Log "    $_" "Red" }
    Fail "Erros durante a importação (código $($imp.Code))"
}
Log "Importação OK" "Green"

if ($SkipTests) {
    Log "AVISO: testes do projeto pulados (-SkipTests)" "Yellow"
} else {
    $t1 = Invoke-Tool $Godot @("--headless", "--path", $root, "res://tests/test_runner.tscn") "Testes do projeto" 600
    $t1ok = Test-SuitePassed $t1
    if (-not $t1ok.Ok) {
        $t1ok.Failures | ForEach-Object { Log "    $_" "Red" }
        Fail "Testes do projeto falharam ($($t1ok.Summary))"
    }
    Log "Testes do projeto: $($t1ok.Summary)" "Green"
    $t2 = Invoke-Tool $Godot @("--headless", "--path", $root, "--script", "res://tests/flow_smoke.gd") "Teste de fluxo de menus" 300
    $t2ok = Test-SuitePassed $t2
    if (-not $t2ok.Ok) {
        $t2ok.Failures | ForEach-Object { Log "    $_" "Red" }
        Fail "Teste de fluxo falhou ($($t2ok.Summary))"
    }
    Log "Teste de fluxo: $($t2ok.Summary)" "Green"
    $vc = Invoke-Tool $Godot @("--headless", "--path", $root, "--script", "res://tools/validate_content.gd") "Validação de conteúdo bíblico e missões" 120
    $vc.Text -split "`n" | Where-Object { $_ -match 'ERRO|NÃO podem|missão |==' } | ForEach-Object { Log "    $_" }
    if ($vc.Code -ne 0 -or (Get-ErrorLines $vc.Text).Count -gt 0) { Fail "Validação de conteúdo encontrou erros de dados" }
    Log "Validação de conteúdo: sem erros de dados (itens sem aprovação humana listados acima)" "Green"
}

$wikiCheck = Join-Path $PSScriptRoot "check_wiki.ps1"
if (Test-Path $wikiCheck) {
    $wk = Invoke-Tool "powershell.exe" @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $wikiCheck) "Verificação da AI Wiki" 120
    $wk.Text -split "`n" | Where-Object { $_ -match '^(WIKI|ERRO|AVISO)' } | ForEach-Object { Log "    $_" }
    if ($wk.Code -ne 0) { Log "AVISO: a AI Wiki tem problemas (veja acima); a build continua" "Yellow" }
}

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

$built = @()
foreach ($t in $targets) {
    Log "--- Exportando $($t.Id) ---" "Cyan"
    $distDir = Join-Path $root "dist\$($t.DistSub)"
    if (Test-Path $distDir) { Remove-Item $distDir -Recurse -Force }
    New-Item -ItemType Directory -Force $distDir | Out-Null
    $outPath = Join-Path $distDir $t.OutName
    $tplPath = Join-Path $tplDir $t.TemplateRelease
    $exp = Invoke-Tool $Godot @("--headless", "--path", $root, "--export-release", $t.Preset, $outPath) "Exportando ($($t.Preset), release)" 900
    $expErrors = @(Get-ErrorLines $exp.Text | Where-Object { $_ -notmatch 'Attempting to parent and popup a dialog' })
    if ($exp.Code -ne 0 -or ($expErrors.Count -gt 0 -and -not (Test-Path $outPath))) {
        $expErrors | ForEach-Object { Log "    $_" "Red" }
        Fail "Exportação $($t.Id) falhou (código $($exp.Code))"
    }
    if ($expErrors.Count -gt 0) {
        Log "AVISO: $($expErrors.Count) linha(s) ERROR na exportação $($t.Id) (binário gerado; confira o log)" "Yellow"
    }
    if (-not (Test-Path $outPath)) { Fail "Exportação $($t.Id) terminou, mas $outPath não foi criado" }
    $outSize = (Get-Item $outPath).Length
    $tplSize = (Get-Item $tplPath).Length
    $loosePck = Get-ChildItem $distDir -Filter "*.pck" -ErrorAction SilentlyContinue
    if ($loosePck) { Fail "Foi gerado um .pck separado em $($t.DistSub); o PCK deveria estar embutido" }
    if ($outSize -le $tplSize) { Fail "Binário $($t.Id) não é maior que o template; PCK não parece embutido" }
    $sha = (Get-FileHash $outPath -Algorithm SHA256).Hash
    Log ("Binário {0}: {1} ({2:N1} MB; dados: {3:N1} MB)" -f $t.Id, $outPath, ($outSize / 1MB), (($outSize - $tplSize) / 1MB)) "Green"
    [System.IO.File]::WriteAllText((Join-Path $distDir "LICENSES.txt"), $licenses, (New-Object System.Text.UTF8Encoding($false)))

    if ($SkipExeTest) {
        Log "AVISO: teste do binário $($t.Id) pulado (-SkipExeTest)" "Yellow"
    } elseif (-not $t.CanRunOnHost) {
        Log "AVISO: autoteste do binário $($t.Id) pulado (não roda nativamente nesta máquina)" "Yellow"
    } else {
        $sandbox = Join-Path $env:TEMP "CaminhosDaPromessa-exetest-$($t.Id)-$stamp"
        New-Item -ItemType Directory -Force $sandbox | Out-Null
        $sandboxBin = Join-Path $sandbox $t.OutName
        Copy-Item $outPath $sandboxBin
        if ($t.Id -eq "Linux") {
            & chmod +x $sandboxBin 2>$null
        }
        $selfLog = Join-Path $logDir "exe-selftest-$($t.Id)-$stamp.log"
        $st = Invoke-Tool $sandboxBin @("--headless", "--", "--self-test") "Autoteste $($t.Id) (dados, mapa, save)" 120 $sandbox
        Set-Content -Path $selfLog -Value $st.Text -Encoding UTF8
        $st.Text -split "`r?`n" | Where-Object { $_ -match '^\s+(ok|FAIL|info)' } | ForEach-Object { Log "    $_" }
        $stErrors = Get-ErrorLines $st.Text
        if ($st.Code -ne 0 -or $st.Text -notmatch 'AUTOTESTE: OK' -or $stErrors.Count -gt 0) {
            $stErrors | ForEach-Object { Log "    $_" "Red" }
            Fail "Autoteste $($t.Id) falhou (código $($st.Code)); veja $selfLog"
        }
        Log "Autoteste $($t.Id): OK" "Green"

        $bootLog = Join-Path $logDir "exe-boot-headless-$($t.Id)-$stamp.log"
        $bt = Invoke-Tool $sandboxBin @("--headless", "--", "--boot-frames=600") "Inicialização headless $($t.Id) (600 quadros)" 120 $sandbox
        Set-Content -Path $bootLog -Value $bt.Text -Encoding UTF8
        $btErrors = Get-ErrorLines $bt.Text
        if ($bt.Code -ne 0 -or $btErrors.Count -gt 0) {
            $btErrors | ForEach-Object { Log "    $_" "Red" }
            Fail "Binário $($t.Id) apresentou erros ao iniciar; veja $bootLog"
        }
        Log "Inicialização headless $($t.Id): OK" "Green"

        if ($NoRenderTest) {
            Log "AVISO: teste com renderização $($t.Id) pulado (-NoRenderTest)" "Yellow"
        } else {
            $renderLog = Join-Path $logDir "exe-boot-render-$($t.Id)-$stamp.log"
            $rt = Invoke-Tool $sandboxBin @("--", "--boot-frames=240") "Inicialização com janela $($t.Id) (240 quadros)" 120 $sandbox
            Set-Content -Path $renderLog -Value $rt.Text -Encoding UTF8
            $renderer = ($rt.Text -split "`r?`n" | Where-Object { $_ -match '^(OpenGL|Vulkan|D3D12)' } | Select-Object -First 1)
            $rtErrors = Get-ErrorLines $rt.Text
            if ($rt.Code -ne 0 -or $rtErrors.Count -gt 0) {
                $rtErrors | ForEach-Object { Log "    $_" "Red" }
                Fail "Binário $($t.Id) apresentou erros com renderização; veja $renderLog"
            }
            Log "Inicialização com renderização $($t.Id): OK ($renderer)" "Green"
        }
        Remove-Item $sandbox -Recurse -Force -ErrorAction SilentlyContinue
    }

    $finalPath = Join-Path $root $t.OutName
    try {
        Copy-Item $outPath $finalPath -Force
    } catch {
        Fail "Não foi possível substituir $finalPath. O jogo está aberto? Feche-o e rode de novo. ($($_.Exception.Message))"
    }
    if ((Get-FileHash $finalPath -Algorithm SHA256).Hash -ne $sha) { Fail "Cópia de $finalPath ficou diferente da build" }
    $built += @{ Id = $t.Id; Path = $finalPath; Size = $outSize; Sha = $sha }
}

# Remove o nome antigo sem SO, se ainda existir na raiz.
$legacy = Join-Path $root "CaminhosDaPromessa.exe"
if (Test-Path $legacy) {
    try {
        Remove-Item $legacy -Force
        Log "Removido nome antigo da raiz: CaminhosDaPromessa.exe" "Yellow"
    } catch {
        Log "AVISO: não foi possível remover CaminhosDaPromessa.exe antigo (jogo aberto?): $($_.Exception.Message)" "Yellow"
    }
}

$elapsed = (Get-Date) - $started
Log "=== BUILD CONCLUÍDO ===" "Cyan"
foreach ($b in $built) {
    Log ("{0}: {1} ({2:N1} MB) SHA-256 {3}" -f $b.Id, $b.Path, ($b.Size / 1MB), $b.Sha) "Cyan"
}
Log ("Duração: {0:mm\:ss}" -f $elapsed) "Cyan"
Log "Log: $logFile" "Cyan"
Log "Lembrete: testes automáticos não substituem jogar e avaliar a interface." "Yellow"
exit 0
