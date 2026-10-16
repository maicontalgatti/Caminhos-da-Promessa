# Passagem de bastão (handoff)

Descreve só a **última tarefa**. Histórico em [CHANGELOG.md](CHANGELOG.md) e em [docs/implementation_log.md](../implementation_log.md).

- **Data:** 2026-10-16
- **Responsável:** agente de IA (Cursor), a pedido do criador
- **Versão do projeto:** 0.6.0 (`project.godot`; sem versão nova)
- **Estado do Git:** alterações locais (build dual; painel Novo jogo pode estar na mesma árvore).

## Última tarefa
Exportação gera Windows e Linux, com o SO no nome do arquivo.

## Resultado
- Saídas na raiz: `CaminhosDaPromessa-Windows.exe` e `CaminhosDaPromessa-Linux.x86_64`.
- `tools/build_export.ps1`; wrappers `build_windows.ps1` e `criar_exe_atualizado.bat`.
- Templates Windows + Linux; preset `Linux` em `export_presets.cfg`.
- Nome antigo `CaminhosDaPromessa.exe` removido da raiz após build ok.

## Testes
- Suíte **1816/1816**, fluxo **23/23**, wiki OK.
- Autoteste + headless + GPU do **Windows**: OK.
- Linux: exportado (78,4 MB); autoteste pulado nesta máquina (cross-export).
- Build completa OK (~1m38s além do download de templates na primeira vez).

## Pendências
- Merge do PR quando aprovado.
- Amigo no Linux: `chmod +x` (também no README).

## Próxima ação
Revisar o PR; distribuir os binários com o link do README (seção “Como jogar o executável”).

## Cuidados
- Filtros de ERROR da suíte no PowerShell: preferir padrões sem acento (`copiar o save antigo`).
- Nenhuma IA aprova conteúdo bíblico.
