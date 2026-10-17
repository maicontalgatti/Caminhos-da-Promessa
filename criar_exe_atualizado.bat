@echo off
rem Gera CaminhosDaPromessa-Windows.exe e CaminhosDaPromessa-Linux.x86_64 nesta pasta.
rem Basta dar dois cliques. Detalhes: docs\build_windows.md
chcp 65001 >nul
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\build_export.ps1" %*
set CODE=%ERRORLEVEL%
echo.
if %CODE%==0 (
    echo Pronto:
    echo   %~dp0CaminhosDaPromessa-Windows.exe
    echo   %~dp0CaminhosDaPromessa-Linux.x86_64
    echo Envie o arquivo certo para cada amigo ^(Windows ou Linux^).
) else (
    echo A build FALHOU. Os binários anteriores foram mantidos. Veja o log em dist\logs.
)
echo.
pause
exit /b %CODE%
