# Passagem de bastão (handoff)

Descreve só a **última tarefa**. Histórico em [CHANGELOG.md](CHANGELOG.md) e em [docs/implementation_log.md](../implementation_log.md).

- **Data:** 2026-10-16
- **Responsável:** agente de IA (Cursor), a pedido do criador (correções da auditoria: Claude/Cowork)
- **Versão do projeto:** 0.6.0 (`project.godot`; sem versão nova)
- **Estado do Git:** branch `feature/audit-fixes-and-build` a partir de `main` `0e79269`.

## Última tarefa
Commitar correções da auditoria técnica, gerar o exe novo e abrir/mesclar PR.

## Resultado
- Relatório: [docs/auditoria-tecnica.md](../auditoria-tecnica.md) (AUD-01…04 corrigidos).
- `SaveManager.slots_dir` isola testes dos saves reais; HUD `can_open_screen()`; migração/.bak só apagam após cópia OK; foco na personalização do viajante.
- `tools/build_windows.ps1`: suíte passa com "0 falharam" mesmo com RID leaks / `push_error` esperado; exportação headless ignora ruído de diálogo do Godot.
- **Exe:** `CaminhosDaPromessa.exe` regenerado na raiz (AUD-06); fora do Git (`.gitignore`).

## Testes
- Suíte **1816/1816**, fluxo **19/19**, `validate_content` sem erros, `check_wiki` OK.
- Build Windows completa: autoteste do exe OK, headless e com GPU OK.
- Não executado: jogo humano (KI-02).

## Pendências
- Conferir se os saves do criador ainda existem (AUD-01 antes da correção).
- Decisões: interiores (KI-24), botão B (KI-25), 11 etapas dos poços (KI-26).

## Próxima ação
Criador: jogar o exe novo; checklist em [docs/auditoria-tecnica.md](../auditoria-tecnica.md#checklist-manual-5-minutos).

## Cuidados
- Testes nunca devem usar `SaveManager.slot_path()` sem antes trocar `SaveManager.slots_dir`.
- Telas do HUD: `HUD.can_open_screen()`.
- Nenhuma IA aprova conteúdo bíblico.
