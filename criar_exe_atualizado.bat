@echo off
rem Gera CaminhosDaPromessa.exe atualizado nesta pasta (substitui o anterior).
rem Basta dar dois cliques. Detalhes: docs\build_windows.md
chcp 65001 >nul
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\build_windows.ps1" %*
set CODE=%ERRORLEVEL%
echo.
if %CODE%==0 (
    echo Pronto: %~dp0CaminhosDaPromessa.exe
    echo Para mandar a um amigo, envie apenas esse arquivo.
) else (
    echo A build FALHOU. O exe anterior foi mantido. Veja o log em dist\logs.
)
echo.
pause
exit /b %CODE%
