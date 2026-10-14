# Build para Windows

Gera um executável único e portátil, `CaminhosDaPromessa.exe`, na raiz do
projeto. Os dados e a licença da fonte ficam embutidos no .exe, sem `.pck`
separado. Para mandar a alguém, basta esse arquivo.

## Gerar uma nova versão

Dê dois cliques em **`criar_exe_atualizado.bat`**, na raiz do projeto, ou rode:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\build_windows.ps1
```

1. Atualize `config/version` em `project.godot` (ex.: `0.2.0`). O script copia o número para os metadados do .exe.
2. Rode o script. Ele retorna o código 0 em caso de sucesso e 1 em caso de falha.
3. O `CaminhosDaPromessa.exe` da raiz só é substituído se todos os testes passarem. Se a build falhar ou o jogo estiver aberto, o anterior é mantido.
   A montagem acontece em `dist/windows/`, onde também fica o `LICENSES.txt`.

Etapas do script:

1. Localiza o Godot e confere a versão.
2. Instala os templates de exportação da mesma versão, se faltarem.
3. Reimporta os recursos e roda as verificações:
   - testes do projeto (`tests/test_runner.tscn`);
   - teste de fluxo de menus (`tests/flow_smoke.gd`);
   - validação de conteúdo (`tools/validate_content.gd`).
4. Verifica a AI Wiki com `tools/check_wiki.ps1`. É uma etapa informativa: um problema na documentação gera aviso e a build continua.
5. Exporta em modo release.
6. Testa uma cópia do .exe numa pasta temporária, longe do projeto:
   - autoteste de dados, mapa e save;
   - inicialização headless;
   - inicialização com janela.
7. Copia o .exe para a raiz. Se o jogo estiver aberto, a cópia falha e o exe anterior é mantido; o novo continua em `dist/windows/`.

O log completo fica em `dist/logs/`.

Opções:

| Opção | Efeito |
|---|---|
| `-Godot <caminho>` | Usa outro executável do Godot (também aceita a variável `GODOT_BIN`) |
| `-SkipTests` | Pula os testes do projeto antes de exportar |
| `-SkipExeTest` | Pula os testes do executável exportado |
| `-NoRenderTest` | Pula o teste com janela (máquinas sem GPU ou sem sessão gráfica) |
| `-NoDownload` | Falha em vez de baixar os templates ausentes |

## Requisitos

- Godot 4.7.2 (o console `tools/godot/Godot_v4.7.2-stable_win64_console.exe` é usado por padrão; a pasta não é versionada).
- Templates de exportação 4.7.2 em `%APPDATA%\Godot\export_templates\4.7.2.stable\`.
  O script `tools/install_export_templates.ps1` baixa o pacote oficial, confere o SHA-512 e extrai só os arquivos de Windows.
  Ao atualizar o Godot, os templates precisam ser da mesma versão.

## Detalhes

- Os arquivos `data/*.json` não são recursos importados. Por isso entram pelo filtro `include_filter` do preset em `export_presets.cfg`, que é versionado.
- O save fica em `user://` (`%APPDATA%\Godot\app_userdata\Caminhos da Promessa\`), e não na pasta do jogo. Assim o .exe funciona em qualquer pasta, inclusive somente leitura.
- Autoteste manual de um executável: `CaminhosDaPromessa.exe --headless -- --self-test`. A saída termina em `AUTOTESTE: OK` (código 0) ou `AUTOTESTE: FALHOU` (código 1).
  Os templates ignoram `--script`, por isso o teste é ativado por esse argumento e roda a partir de `scripts/build/export_self_test.gd`.
- O executável não é assinado digitalmente. O Windows SmartScreen pode avisar na primeira execução.
- Os testes automáticos verificam inicialização, dados e save. Eles não substituem jogar e avaliar a interface.
