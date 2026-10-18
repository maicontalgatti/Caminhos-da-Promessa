# Passagem de bastão (handoff)

Descreve só a **última tarefa**. Histórico em [CHANGELOG.md](CHANGELOG.md) e em [docs/implementation_log.md](../implementation_log.md).

- **Data:** 2026-10-17
- **Responsável:** agente de IA (Cursor), a pedido do criador
- **Versão do projeto:** 0.6.0 (sem versão nova)
- **Branch:** `fix/playtest-bugs-testers`

## Última tarefa
Oito correções dos bugs achados pelos testadores (playtest), com testes, capturas, PR e builds.

## Resultado
1. **Roda de Ezer:** "Só observar." primeiro; craft só com `met_ezer` / wells / `return_jar`.
2. **Saída de tenda:** `tent_plain` em Caminho/Dotã; `@return` + pilha em `WorldManager`; rótulos "Sair da tenda/casa".
3. **Caravana:** `SceneDirector` pause-safe + wait 12 s + teto 120 s.
4. **4º animal:** longe da gruta; texto "4 animais (3 ovelhas e 1 cabra)".
5. **Texturas Belém:** feixe/jarro duplicados removidos.
6. **Foice:** prop `sickle` visível em `bf_sickle`.
7. **Pós-casa do menino:** `GameMap.refresh_world()` no fim da cena; Tamir acordado + objetivo no HUD.
8. **Nava × Tova:** missão acompanhada limpa ao trocar experiência; `primary_quest` prefere principal da região; fala "Sou Nava.".
9. **Interior:** `build_interior.gd` usa chão de terra (path tiles), não grama.

## Testes (Godot 4.7.2 Linux headless)
- `test_runner.tscn`: **1870/1870** (inclui `playtest_bugfix_tests.gd`).
- `flow_smoke.gd`: **31/31**.
- `validate_content.gd`: sem erros.
- Capturas: `docs/images/playtest_fixes_*.png`.
- QA estático (quest-qa): sem bloqueadores.

## Builds (2026-10-18)
- `executaveis/Windows/CaminhosDaPromessa-Windows.exe` (113M) e cópia na raiz.
- `executaveis/Linux/CaminhosDaPromessa-Linux.x86_64` (79M, PCK embutido) e cópia na raiz.
- Autoteste do binário Linux: **AUTOTESTE: OK**.

## Git
- Branch `fix/playtest-bugs-testers` enviada (`4171837`).
- Abrir PR: https://github.com/maicontalgatti/Caminhos-da-Promessa/compare/main...fix/playtest-bugs-testers?expand=1  
  (`gh` sem login nesta máquina; push por SSH ok).

## Pendências
- Abrir/mergear o PR no GitHub (auth do `gh` ausente aqui).
- Playtest humano (KI-02).
- Manifesto de áudio ep_048 desatualizado em 1 fala (sem voz gravada).

## Próxima ação
Abrir o PR pelo link acima, revisar e mergear; distribuir os executáveis novos.
