# Passagem de bastão (handoff)

Descreve só a **última tarefa**. Substitua o conteúdo ao fim de cada tarefa (o histórico fica no
[CHANGELOG.md](CHANGELOG.md) e em [docs/implementation_log.md](../implementation_log.md)).

- **Data:** 2026-10-14
- **Responsável:** agente de IA no Cursor (coordenador), com subagentes da fábrica, a pedido do criador
- **Versão do projeto:** 0.6.0 (`project.godot`)
- **Branch:** `content/four-experiences` → [PR #2](https://github.com/maicontalgatti/Caminhos-da-Promessa/pull/2) para `main`; o criador autorizou merge, exe e release ("pode fazer deploy total")

## Última tarefa
Liberar as quatro experiências planejadas do Mapa das Escrituras, em ordem cronológica e num só PR:
"José no Egito" (ep_009), "A travessia do mar" (ep_016), "Rute em Belém" (ep_025) e "Os pastores de
Belém" (ep_048). Decisões do criador: venda de José como cena observada de longe; acontecimentos
sobrenaturais como cenas dirigidas no mapa, sem controle do jogador.

## Alterações desta tarefa
- **Infraestrutura (ADR-028):** cenas dirigidas (`scripts/world/scene_*.gd`, `data/scenes/`), luz por estado, passagens, destinos e etapas de experiência, botão Revisitar/Continuar.
- **Conteúdo:** regiões `egypt_house`, `sea_camp`, `bethlehem_fields`, `bethlehem_night` (dados, arte e mapas por `tools/art_gen`); encosta `dothan_ridge` em Dotã; missões em `data/quests/{egypt,sea,bethlehem}/`; diálogos, personagens, colecionáveis, 5 cenas, descobertas, apresentações, pessoas, lugares, histórias, itens; `experiences.json` (cadeia e época "Nos dias de Herodes"); `bpm.json` reimportado (327 versículos); `verse_counts.json`; certeza da data dos pastores em `chronology.json` → `debated`.
- **Produção:** pacotes completos em `production/episodes/{ep_009,ep_016,ep_025,ep_048}_*/` (pesquisas, design, propostas, `review.json`, `test_report.json`, `visual_manifest.json`, `audio_manifest.json`); decisões provisórias em `production/reports/four_experiences_decisions.md`; estados `tested` no catálogo.
- **Correções da QA:** legendas sobrepostas (validador novo), fogueira dos pastores, referência de Rute no diário, textos de conclusão.
- **Docs:** CURRENT_STATE, CHANGELOG (wiki e raiz), implementation_log, KNOWN_ISSUES (KI-20 atualizado, KI-21 novo), capturas `docs/images/v06_*.png`.
- `default_bus_layout.tres` modificado pelo `--import` (KI-18): **não** entra no commit.

## Resultado
- As quatro experiências estão jogáveis em cadeia a partir de "José em Dotã": Dotã → casa no Egito → margem do mar → campos de Belém → encosta dos pastores.
- Conteúdo bíblico revisado por agentes (`ok_for_human_review`); nenhum item aprovado por pessoa.

## Testes
| Teste | Resultado |
|---|---|
| `res://tests/test_runner.tscn` | **Realizado e aprovado**: 1482/1482 |
| `res://tests/flow_smoke.gd` | **Realizado e aprovado**: 17/17 |
| `res://tools/validate_content.gd` | **Realizado e aprovado**: sem erros de dados (5 cenas ok) |
| `res://tools/factory.gd -- check` | **Realizado e aprovado**: 0 erros em 78 episódios |
| `res://tools/audio/audit_audio.gd` | **Realizado e aprovado**: 131 arquivos, 0 problemas |
| Build do exe (`tools/build_windows.ps1`) | **Realizado e aprovado**: 0.6.0, 108,9 MB, autoteste OK, inicialização headless e com GPU OK |
| Capturas em janela das 4 regiões e 5 cenas | **Realizado**: `docs/images/v06_*.png` |
| QA de missões (quest-qa) | **Realizado (estático)**: sem bloqueadores; 3 major corrigidos |
| Sessão de jogo humana | **Não executado** (KI-02) |

## Problemas conhecidos (principais)
- KI-21: decisões provisórias e itens `open_for_human` dos quatro `review.json` aguardam o criador.
- KI-20: cenas vistas só em capturas; sem ambiente por estado.
- KI-02, KI-03, KI-14, KI-16, KI-17 continuam.

## Pendências e próximas prioridades
1. Criador: jogar a cadeia inteira na v0.6.0 e assistir às cinco cenas.
2. Criador: revisar o conteúdo bíblico novo (`pending_review`) e as decisões de KI-21.
3. Próximo conteúdo: continuação de José (Gn 39:7-41) ou outra experiência do catálogo.

## Próxima ação
Num chat novo, com qualquer ferramenta de IA: use o prompt de [START_WITH_AI.md](../../START_WITH_AI.md).

## Cuidados
- Cena **nunca** dá item; legenda seguida de outra precisa de `"wait": true` (o validador recusa).
- Objetivo novo não deve concluir por evento que já possa ter ocorrido em outra região (ex.: `item_delivered` de item antigo); use evento `custom` próprio.
- O repositório é **público**: nada de segredos, dados pessoais ou recursos sem licença.
- Rode os comandos do Godot um de cada vez. Para editar, não use `Get-Content`/`Set-Content` do PowerShell.
