# Passagem de bastão (handoff)

Descreve só a **última tarefa**. Substitua o conteúdo ao fim de cada tarefa (o histórico fica no
[CHANGELOG.md](CHANGELOG.md) e em [docs/implementation_log.md](../implementation_log.md)).

- **Data:** 2026-10-14
- **Responsável:** agente de IA no Cursor (único implementador nesta sessão), a pedido do criador
- **Versão do projeto:** 0.5.0 (`project.godot`)
- **Branch:** `content/four-experiences` — **sem commit** (o criador pediu para não commitar nem trocar de branch)

Infraestrutura reutilizável para os próximos episódios. Nenhum conteúdo de episódio (região, missão,
diálogo, mapa) foi criado; os sistemas antigos continuam como estavam (ADR-013).

## Última tarefa
Construir: cena dirigida por dados (`SceneDirector` + `data/scenes`), suporte em missões e fábrica,
experiências com destino (`travel`, `entry_if`, `stages`, `passage`, botão Revisitar no Mapa M), luz por
estado nas regiões, testes e documentação (ADR-028).

## Alterações desta tarefa
- **Novos:** `scripts/world/scene_database.gd`, `scene_director.gd`, `scene_actor.gd`, `scene_fx.gd`, `world_schema.gd` (+ `.uid`); `tests/scene_tests.gd`; `tests/data/scenes/test_scenes.json`.
- **Alterados:** `scripts/core/game.gd`, `scripts/world/game_map.gd`, `world_manager.gd`, `map_exit.gd`, `scripts/ui/scripture_map.gd`, `scripts/quests/quest_database.gd`, `scripts/dialogue/dialogue_database.gd`, `dialogue_manager.gd` (comentário), `tools/factory.gd`, `tools/factory/factory_catalog.gd`, `tools/validate_content.gd`, `scripts/build/export_self_test.gd`, `tests/test_runner.gd`, `data/world/experiences.json`.
- **Docs:** `docs/quests.md` (formato completo para autores), `docs/architecture.md`, [ARCHITECTURE_MAP.md](ARCHITECTURE_MAP.md), [GAME_SYSTEMS.md](GAME_SYSTEMS.md), ADR-028 em [DECISIONS.md](DECISIONS.md), KI-20 em [KNOWN_ISSUES.md](KNOWN_ISSUES.md), CHANGELOG, CURRENT_STATE, implementation_log.
- `default_bus_layout.tres` aparece modificado: cabeçalho reescrito pelo `--import` (KI-18), não pela tarefa.
- Arquivos não rastreados em `production/` são de outros agentes; não foram tocados.

## Resultado
- Infraestrutura completa e coberta por testes automatizados (110 verificações novas), sem regressão nas antigas.
- `data/scenes/` criada vazia (só `.gitkeep`): é onde entram as cenas reais.
- `isaac_wells` e `joseph_dothan` ganharam o botão Revisitar/Continuar de volta a Canaã.

## Testes
| Teste | Resultado |
|---|---|
| `--import` | **Realizado**: classes novas registradas, sem erros |
| `res://tests/test_runner.tscn` | **Realizado e aprovado**: 775/775 (antes 665) |
| `res://tests/flow_smoke.gd` | **Realizado e aprovado**: 17/17 |
| `res://tools/validate_content.gd` | **Realizado e aprovado**: sem erros de dados ("Cenas dirigidas (0): ok"; "Mundo: luz, passagens e experiências: ok") |
| `res://tools/factory.gd -- check` | **Realizado e aprovado**: 0 erros em 78 episódios |
| Autoteste `-- --self-test` pelo Godot do editor | **Realizado**: "cenas dirigidas de data/scenes carregadas" e "diretor de cenas dirigidas compilado" ok; 4 falhas esperadas fora de exe release (template, modo release, painel e controles de debug) |
| Build do exe (`criar_exe_atualizado.bat`) | **Não executado** |
| `tools/audio/audit_audio.gd` | **Não executado** (áudio não mudou) |
| Avaliação visual dos efeitos, capturas, sessão humana | **Não executado** (KI-20, KI-02) |

## Problemas conhecidos (principais)
- KI-20: efeitos e silhuetas nunca vistos rodando; propostas de `production/` usam `"type": "player"` e chaves de `on_end` que não existem; chaves desconhecidas em passos e `params` são ignoradas sem aviso.
- KI-02, KI-03, KI-14, KI-16, KI-17 continuam.

## Pendências e próximas prioridades
1. **Criador:** revisar o diff e decidir o commit/PR da branch `content/four-experiences`.
2. Abrir o jogo com uma cena de teste copiada para `data/scenes/` (ou a primeira cena real) e conferir os efeitos com os olhos.
3. Integrar episódios ajustando as propostas ao formato de [docs/quests.md](../quests.md#cenas-dirigidas-datascenesjson-chave-scenes--adr-028).
4. Gerar o exe e conferir o autoteste num build release.

## Próxima ação
Num chat novo, com qualquer ferramenta de IA: use o prompt de [START_WITH_AI.md](../../START_WITH_AI.md).

## Cuidados
- Cena **nunca** dá item: `give`, `items`, `rewards`, `reward`, `grant_collectible`, `score`, `xp`, `power` são recusados.
- Tinta de cena é temporária (`GameMap.lighting_locked`); no fim vale a regra `lighting` da região.
- O repositório é **público**: nada de segredos, dados pessoais ou recursos sem licença.
- Em headless, testes com animação medem por tempo; tecla simulada exige `Input.flush_buffered_events()`.
- Autoloads não existem em `--script`. Depois de criar um `class_name`, rode `--import`.
- Rode os comandos do Godot um de cada vez. Para editar, não use `Get-Content`/`Set-Content` do PowerShell.
