# Build para Windows e Linux

Gera dois executáveis portáteis na raiz do projeto, com o sistema no nome:

- `CaminhosDaPromessa-Windows.exe` (Windows x86_64)
- `CaminhosDaPromessa-Linux.x86_64` (Linux x86_64)

Os dados e a licença da fonte ficam embutidos (sem `.pck` separado). Para mandar a
alguém, envie **só o arquivo da plataforma dele**.

## Instruções rápidas para quem só vai jogar

Resumo também no [README](../README.md#como-jogar-o-executável-amigos--distribuição).

**Windows:** duplo clique em `CaminhosDaPromessa-Windows.exe`. Se o Windows bloquear, *Mais informações* → *Executar assim mesmo*.

**Linux:** 

```bash
chmod +x CaminhosDaPromessa-Linux.x86_64
./CaminhosDaPromessa-Linux.x86_64
```

Saves ficam em `user://` (AppData no Windows; `~/.local/share/godot/app_userdata/Caminhos da Promessa/` no Linux). Substituir o binário não apaga o progresso.

## Gerar uma nova versão

Dê dois cliques em **`criar_exe_atualizado.bat`**, na raiz do projeto, ou rode:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\build_export.ps1
```

Só uma plataforma:

```powershell
.\tools\build_export.ps1 -Platform Windows
.\tools\build_export.ps1 -Platform Linux
```

`tools/build_windows.ps1` continua existindo e chama o mesmo script (compatibilidade).

1. Atualize `config/version` em `project.godot` (ex.: `0.2.0`). O script copia o número para os metadados do .exe Windows.
2. Rode o script. Código 0 = sucesso; 1 = falha.
3. Os arquivos da raiz só são substituídos se os testes passarem. Montagem em `dist/windows/` e `dist/linux/` (com `LICENSES.txt`).
4. O nome antigo `CaminhosDaPromessa.exe` (sem SO) é removido da raiz quando a build completa.

Etapas:

1. Localiza o Godot e confere a versão.
2. Instala templates de exportação Windows **e** Linux da mesma versão, se faltarem.
3. Reimporta recursos e roda verificações (suíte, fluxo, validação de conteúdo).
4. Verifica a AI Wiki (informativo).
5. Exporta cada plataforma em release.
6. Testa o binário **nativo desta máquina** (no Windows: autoteste/GPU do `.exe`; o Linux é gerado por cross-export e o autoteste dele fica para um PC Linux).
7. Copia os binários para a raiz.

Log completo em `dist/logs/`.

Opções:

| Opção | Efeito |
|---|---|
| `-Platform All\|Windows\|Linux` | Quais builds gerar (padrão: All) |
| `-Godot <caminho>` | Outro executável do Godot (`GODOT_BIN` também serve) |
| `-SkipTests` | Pula os testes do projeto antes de exportar |
| `-SkipExeTest` | Não executa os binários gerados |
| `-NoRenderTest` | Pula o teste com janela |
| `-NoDownload` | Falha em vez de baixar templates ausentes |

## Requisitos

- Godot 4.7.2 (console em `tools/godot/` por padrão; pasta fora do Git).
- Templates 4.7.2 em `%APPDATA%\Godot\export_templates\4.7.2.stable\` (`windows_release_x86_64.exe` e `linux_release.x86_64`).
  `tools/install_export_templates.ps1` baixa o pacote oficial, confere o SHA-512 e extrai Windows + Linux.

## Detalhes

- `data/*.json` entram pelo `include_filter` de `export_presets.cfg`.
- Save em `user://` (não na pasta do jogo).
- Autoteste: `CaminhosDaPromessa-Windows.exe --headless -- --self-test` (ou o binário Linux no Linux).
- Binários não assinados; o Windows SmartScreen pode avisar na primeira execução.
- No Linux, após baixar: `chmod +x CaminhosDaPromessa-Linux.x86_64`.
