# Compatibilidade: redireciona para tools/build_export.ps1 (Windows + Linux).
# Preferir: .\tools\build_export.ps1
# Para só Windows: .\tools\build_export.ps1 -Platform Windows
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
& "$PSScriptRoot\build_export.ps1" @PSBoundParameters
exit $LASTEXITCODE
