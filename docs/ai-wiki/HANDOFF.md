# Passagem de bastão (handoff)

Descreve só a **última tarefa**. Histórico em [CHANGELOG.md](CHANGELOG.md) e em [docs/implementation_log.md](../implementation_log.md).

- **Data:** 2026-10-16
- **Responsável:** agente de IA (Cursor), a pedido do criador
- **Versão do projeto:** 0.6.0 (`project.godot`; sem versão nova)
- **Estado do Git:** branch `main` com alterações locais (painel Novo jogo); ainda sem commit.

## Última tarefa
Corrigir Novo jogo bugado (painéis cortados na borda direita).

## Resultado
- Causa: `SlotsPanel` e `LookPanel` com `PRESET_CENTER` e grow `END` → cresciam para a direita/baixo e cortavam a seta `>` do tom de pele.
- Correção em `scripts/ui/main_menu.gd`: `_center_menu_panel` (`GROW_DIRECTION_BOTH` + offsets ±largura/2); setas `<`/`>` focáveis.
- Fluxo de menus com asserts de retângulo centrado e seta visível.

## Testes
- Suíte **1816/1816**, fluxo **23/23**, wiki OK, build Windows + autoteste do exe OK.
- Não executado: jogo humano além do reporte do criador.

## Pendências
- Commit/PR das alterações locais quando o criador pedir.
- Checklist manual e decisões KI-24…26.

## Próxima ação
Criador: fechar o exe antigo, abrir o novo na raiz e confirmar Novo jogo (espaços + viajante centrados, seta `>` visível).

## Cuidados
- Painéis criados em código no menu: sempre `GROW_DIRECTION_BOTH` (ou offsets simétricos como em `pause_menu.gd`).
- Nenhuma IA aprova conteúdo bíblico.
