# Passagem de bastão (handoff)

Descreve só a **última tarefa**. Histórico em [CHANGELOG.md](CHANGELOG.md) e em [docs/implementation_log.md](../implementation_log.md).

- **Data:** 2026-10-18
- **Responsável:** agente de IA (Cursor), a pedido do criador
- **Versão do projeto:** 0.6.0 (sem versão nova)
- **Branch:** `fix/playtest-bugs-testers`

## Última tarefa
1. Banner de identidade ao continuar o jogo (painel estreito ilegível).
2. Brechas da ronda do aprisco (E mostrava “Observar” na ovelha e não examinava a brecha).

## Resultado
- **Banner:** largura mínima 280 px + labels com autowrap interno; `reset_size()` não colapsa mais a coluna.
- **Brechas:** pontos da ronda fora do curral com prop visível e raio 20; `InteractionDetector` prioriza alvos do objetivo atual (ovelhas não roubam o E).

## Testes
- `test_runner.tscn`: **1885/1885**
- `flow_smoke.gd`: **31/31**
- Autoteste Linux do exe: **AUTOTESTE: OK**

## Builds
- `executaveis/Windows/CaminhosDaPromessa-Windows.exe`
- `executaveis/Linux/CaminhosDaPromessa-Linux.x86_64`

## Git
Branch `fix/playtest-bugs-testers` — abrir/atualizar PR em  
https://github.com/maicontalgatti/Caminhos-da-Promessa/compare/main...fix/playtest-bugs-testers?expand=1

## Próxima ação
Merge do PR; playtest humano das brechas e do Continuar.
