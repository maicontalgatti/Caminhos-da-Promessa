# Design — ep_025 "Rute em Belém" (experiência `ruth_bethlehem`)

- **Autor:** agente `quest-designer` (IA), 2026-10-14. **Status:** proposta, `pending_review`.
- **Base:** `production/reports/four_experiences_decisions.md` (decisões do ep_025 e especificação da cena dirigida), `research_biblical.md` e `research_historical.md` deste episódio, modelos reais de `data/` (Dotã, Caminho das Caravanas, `road_supplies`, `items.json`, `experiences.json`, `world_manager.gd`).
- **Arquivos desta proposta:** `quest.proposal.json` (3 missões), `region.proposal.json` (região + layout para o gerador), `scenes.proposal.json` (1 cena dirigida), `experience.proposal.json`.
- **Escopo bíblico:** `Ruth 1:19-22` e `Ruth 2:1-23`. Capítulos 3 e 4 ficam fora; a porta da aldeia é só cenário.

## 1. Premissa e papel do jogador
É o começo da colheita da cevada em Belém (Rt 1:22). O viajante fictício chega pela estrada do oeste e oferece ajuda a **Ilan**, um pequeno agricultor fictício da aldeia. Ajudando na ceifa, ele aprende na prática a **lei da respiga**: o canto do campo fica de pé e o que cai fica para quem não tem campo (Lv 19:9-10; Dt 24:19). Do marco de divisa, observa de longe a **parte do campo que era de Boaz** (Rt 2:3), onde uma jovem respiga, Boaz chega de Belém, a refeição do meio-dia acontece e, à tarde, ela volta à cidade com a cevada. Depois lê o relato no diário.

**Papel:** quem **ajuda** (colheita de Ilan, Tova) e quem **observa** (Rute e Boaz, de longe). O jogador nunca entra na cena do relato.

**Restrições (`design_constraints`):**
- O viajante não encontra, não orienta, não alimenta nem dá espigas a Rute; não leva Rute ao campo de Boaz; não fala com Boaz nem com Noemi.
- Rute, Noemi e Boaz **não são NPCs** do mapa: aparecem só como figurantes da cena dirigida, sem falas; as legendas usam o texto oficial por referência ou paráfrase curta identificada.
- O campo do jogador é **fictício** (o de Ilan), separado do de Boaz por marcos de pedra.
- Nada do cap. 3 (eira à noite) nem do cap. 4 (porta, resgate, casamento). A eira aparece só de dia, como lugar de trabalho.
- Sem moedas; o efa nunca recebe número ("um saco cheio", "quase um efa" só na citação).
- Belém sem nada do século I (estrela, manjedoura).

## 2. Missões
### 2.1 Principal — `ruth_gleaning` "A colheita em Belém" (`story_witness`)
Início: conclusão da experiência anterior (`quest_completed joseph_dothan_road`, a alinhar pelo coordenador). Conclui a experiência `ruth_bethlehem`.

| # | id | O jogador… | `complete_on` | Alvo real | Motivo narrativo | Descoberta |
|---|---|---|---|---|---|---|
| 1 | `open_map` | abre o Mapa e inicia "Rute em Belém" | `experience_started ruth_bethlehem` | `ui scripture_map` | passagem entre épocas (cartão) | — (ao entrar: `bethlehem_judges`) |
| 2 | `meet_ilan` | oferece ajuda a Ilan | `custom ruth_ilan_harvest` | `npc ilan` | começo da colheita; a cidade comenta a volta de Noemi (Rt 1:19, como notícia) | `barley_harvest` |
| 3 | `harvest` | junta 4 feixes nas fileiras ceifadas | `inventory barley_sheaf` ×4 | `pickup bf_sheaf_1..6` | trabalho físico, exploração do campo | — |
| 4 | `bring_sheaves` | entrega os feixes; se pegou o canto, devolve | `item_delivered barley_sheaf` | `npc ilan` | **lição jogável do canto do campo**; escolha registrada `ruth_field_corner` (`left`/`returned`) | `gleaning_law` |
| 5 | `watch_field` | observa o campo vizinho (cena dirigida) | `scene_finished ruth_gleaning_meal` | `examinable bf_boundary_view` | Rt 2:3-18 testemunhado de longe | — |
| 6 | `read_story` | lê o relato no diário | `presentation_finished ruth_002_gleaning` | `examinable bf_boundary_view` | texto completo de Rt 1:19-2:23 | `ruth_gleaning` |

Pistas (3 níveis, implícita → direta) estão em `quest.proposal.json`, uma trinca por objetivo.

**Mecânica do canto (objetivos 3–4), só com sistemas existentes:** o campo de Ilan tem 6 feixes (`barley_sheaf`) nas fileiras ceifadas e 2 feixes no **canto sudeste**, ainda de pé (`corner_sheaf`, item próprio). Nada impede o jogador de pegar o canto. Ao entregar, o diálogo de Ilan escolhe o nó por `start_if`:
- tem `corner_sheaf` → Ilan explica Lv 19:9 com calma, pede os feixes do canto de volta (`take`), seta `corner_returned`, `decision ruth_field_corner = returned`; o examinável `bf_corner_returned` (feixes de volta ao canto) aparece por `visible_if`;
- não tem → Ilan nota que o canto ficou de pé, explica a lei, `decision ruth_field_corner = left`.
Os dois caminhos liberam `gleaning_law`; não há punição, só desfechos diferentes na conclusão. Os pickups do canto e das fileiras só existem durante `harvest` (`visible_if`).

**Conclusão:** "Um dia de colheita" — lei da respiga (com a nota de que o livro de Rute não a cita), resumo de Rt 2 e aviso de ficção; variantes por `ruth_field_corner`; `next` diz que Rute 3–4 não fazem parte desta experiência.

### 2.2 Secundária — `tova_gleaning` "O que fica no campo" (`assist`)
Tova, viúva idosa fictícia da aldeia, respiga atrás dos ceifeiros **de Ilan** (não no campo de Boaz). Não tem nora nem relação com Noemi.

| # | id | O jogador… | `complete_on` | Alvo real | Motivo |
|---|---|---|---|---|---|
| 1 | `meet_tova` | conversa com Tova | `custom ruth_tova_hello` | `npc tova` | quem respiga e por quê |
| 2 | `forgotten_sheaf` | acha o feixe esquecido e decide | `choice_made ruth_forgotten_sheaf` | `examinable bf_forgotten_sheaf` | Dt 24:19 sem questionário: 3 opções válidas — deixar (`left`), mostrar a Tova (`told_tova`), perguntar a Ilan (`asked_ilan`) |
| 3 | `beat_ears` | bate as espigas com a vara (recebe `tova_grain`) | `custom ruth_tova_beaten` | `examinable bf_beating_stone` | gesto de Rt 2:17 feito por fictícios |
| 4 | `carry_home` | leva a cevada até a casa dela | `item_delivered tova_grain` | `npc tova_home` | rota pelo mapa até a porta (exploração) |

Descoberta `harvest_meal` (pão, grão tostado, "vinagre" de Rt 2:14) liberada no fim. Recompensa: só a flag `helped_gleaner`. **Pendente de decisão do criador:** ficha bíblica, item 10 (viúva fictícia × Noemi). Alternativa, se for recusada: trocar Tova por um órfão ou um estrangeiro de passagem (grupos de Dt 24:19), mantendo os mesmos objetivos.

### 2.3 Exploração — `bethlehem_harvest_signs` "Sinais da colheita" (`investigation`)
Conjunto de colecionáveis `bethlehem_harvest` (6), no molde de `caravan_records`: `first_sign` (1), `three_signs` (3), `all_signs` (completo). Inicia ao entrar na região.

| Examinável | Conteúdo (colecionável, classificação) |
|---|---|
| `bf_sickle` | Foice de cabo curvo com lâminas de sílex — Ferro I (`historical_context`) |
| `bf_pithos` | Jarro de borda em colarinho, marca das aldeias do planalto (`historical_context`) |
| `bf_parcel_marker` | Marco entre campos, sem cercas; libera `boundary_markers` (Dt 19:14) e liga a Rt 2:3 |
| `bf_threshing_floor` | Eira de dia: chão batido, monte de grãos, trenó de debulha (sem ligação com Rt 3) |
| `bf_shelter` | Abrigo de ramos para descanso — **hipótese** (Rt 2:7 tem texto difícil) |
| `bf_gate` | Porta modesta com bancos de pedra: onde a aldeia se reunia (só cenário; sem Rt 4) |

## 3. Diálogos (ids e conteúdo; o roteirista escreve as falas)
| id | Quem | Conteúdo |
|---|---|---|
| `ilan_talk` | Ilan | **welcome** (`event ruth_ilan_harvest`, `unlock barley_harvest`): colheita da cevada começou, trigo vem depois; pede ajuda com os feixes; comenta, como notícia, que a cidade se agitou com a volta de Noemi e da nora moabita (Rt 1:19, 1:22) — sem opinar sobre elas. **waiting**. **delivery_left** / **delivery_corner** (ver §2.1; `take`, `decision`, `unlock gleaning_law`). **after_scene**: comenta que há quem deixe mais do que a lei pede, sem testemunhar nada que só o texto conta. **asked_ilan** (nó acessível só durante `tova_gleaning/forgotten_sheaf`): pede que o feixe fique no campo (`decision ruth_forgotten_sheaf = asked_ilan`). **idle**. |
| `tova_talk` | Tova | **hello** (`event ruth_tova_hello`): é viúva, respiga nos campos da aldeia, fala de um feixe que ficou para trás. **waiting**. **beat_hint**. |
| `tova_home_talk` | Tova (em casa) | **delivery** (`take tova_grain`): agradece; oferece grão tostado como gesto (sem item), `unlock harvest_meal`. **idle**. |
| `bf_forgotten_sheaf` | narrador | escolha com 3 opções e `decision ruth_forgotten_sheaf` (`left`, `told_tova`, `asked_ilan`; a última encaminha para Ilan). |
| `bf_beating_stone` | narrador | antes do objetivo: só descrição; durante: o viajante bate as espigas, `sfx grain_beat`, `give tova_grain`, `event ruth_tova_beaten`. |
| `bf_boundary_view` | narrador | **first** (objetivo `watch_field`): "Do terebinto dá para ver o campo vizinho…", `action play_scene:ruth_gleaning_meal`. **read** (objetivo `read_story` ou depois): `action {"presentation": "ruth_002_gleaning"}`. **before**: antes de `watch_field`, só descreve o campo vizinho. |
| `bf_corner_returned` | narrador | os feixes do canto ficaram para quem respiga. |
| `bf_reaper_work` | narrador | ceifeiro concentrado no trabalho (diálogo de `bf_reaper`; nenhuma menção a Rute). |
| `bf_sickle`, `bf_pithos`, `bf_parcel_marker`, `bf_threshing_floor`, `bf_shelter`, `bf_gate` | narrador | descrição + `grant_collectible` do mesmo id. `bf_parcel_marker` também `unlock boundary_markers`. |
| `bf_road_west` | narrador | a estrada segue para o oeste; para outro momento da história, abrir o Mapa (M). |

## 4. Cena dirigida `ruth_gleaning_meal` (resumo; passos em `scenes.proposal.json`)
Câmera sai do jogador para o campo de Boaz (sem zoom de aproximação). Figurantes: Rute, Boaz, encarregado, uma serva (sprites pequenos novos). Sequência: Rute respiga atrás dos ceifeiros (legenda `Ruth 2:3`) → Boaz chega pelo caminho da aldeia (`Ruth 2:4`) → paráfrase de 2:5-7 e 2:8-13 → luz de meio-dia, todos ao abrigo (`Ruth 2:14`) → paráfrase de 2:15-16 → luz de tarde, batida de grãos (`Ruth 2:17`) → Rute sobe para a aldeia, paráfrase de 2:18 → luz padrão, câmera volta ao jogador. 60–75 s, pulável com Esc, sem item.

## 5. Apresentação do diário `ruth_002_gleaning` (nova, `recorded_event`)
Passos com `scripture` (texto oficial importado) e nota própria: 1) Volta a Belém `Ruth 1:19`; 2) "Mara" `Ruth 1:20-21`; 3) Começo da colheita `Ruth 1:22`; 4) Boaz `Ruth 2:1`; 5) Ir respigar `Ruth 2:2-3`; 6) A saudação `Ruth 2:4-7`; 7) No campo de Boaz `Ruth 2:8-13`; 8) A refeição `Ruth 2:14`; 9) Espigas deixadas `Ruth 2:15-16`; 10) Até a tarde `Ruth 2:17-18`; 11) Um resgatador `Ruth 2:19-20` (nota: termo explicado em descoberta futura, sem entrar no cap. 4); 12) Até o fim das colheitas `Ruth 2:21-23`; 13) Sobre esta apresentação (crédito; Ilan, Tova e o viajante são fictícios). `unlock: ["ruth_gleaning"]`.

## 6. Descobertas
Novas (a escrever pelo roteirista, classificar e referenciar):
- `bethlehem_judges` (ao entrar, `historical_context`): Belém, aldeia do planalto no tempo dos juízes; sem ano para Rute (`null`); `Ruth 1:1`, `Ruth 1:22`.
- `barley_harvest` (`historical_context`): cevada antes do trigo, foice, feixes, eira; `Ruth 1:22`, `Ruth 2:23`.
- `gleaning_law` (`historical_context` + seção `interpretation`): canto do campo, espigas caídas, feixe esquecido; para pobre, estrangeiro, órfão, viúva; o livro de Rute não cita a lei (ligação do leitor); `Lev 19:9-10`, `Lev 23:22`, `Deut 24:19`.
- `ruth_gleaning` (`recorded_event`, via apresentação): resumo de Rt 1:19-2:23; "por acaso" (2:3) como leitura de providência marcada como interpretação.
- `harvest_meal` (`historical_context`): pão, grão tostado, "vinagre"; `Ruth 2:14`.
Reaproveitada: `boundary_markers`.

## 7. Itens novos (3)
| id | Nome | Categoria | Observação |
|---|---|---|---|
| `barley_sheaf` | Feixe de cevada | `material`, `no_discard`, max 6 | entregue a Ilan |
| `corner_sheaf` | Feixe do canto do campo | `quest`, essential, max 2 | descrição já sugere que o canto "costuma ficar de pé" |
| `tova_grain` | Cevada de Tova | `quest`, essential, max 1 | "um saco de pano cheio", **sem medida numérica** |
Nenhuma moeda, nenhuma recompensa em item nas missões.

## 8. Passagem entre épocas
Cartão "OUTRO MOMENTO DA HISTÓRIA" (rascunho em `experience.proposal.json`): tempo dos juízes, sem ano; Noemi e Rute chegam no começo da colheita (Rt 1:19-22); viajante fictício que não muda o relato; Rute, Noemi e Boaz não conversam com ele. A experiência usa `travel` → `bethlehem_fields/from_scripture_map`. A região não tem saídas; a estrada oeste é um examinável que lembra o Mapa (M).

## 9. Layout do mapa `bethlehem_fields` (64×40 tiles, 16 px = 1024×640 px)
```
 tiles x→ 0        10        20        30        40        50       63
 y0   olival     [casas de pilares]==muro==[PORTA]==muro==[casas] olival
 y5               forno  casa_Tova    praça+bancos   jarros(pithos)
 y7                                     |
 y12                                    +============== caminho ===== [EIRA] (55,12)
 y18 ENTRADA ==== estrada oeste ========+                            terraços
 y21       [ CAMPO DE ILAN (restolho)  ]  o  [ CAMPO DE BOAZ: restolho | cevada em pé ]
           Ilan(18,20) foice jarro        o   ceifeiros   abrigo de ramos (50,22)
 y28       feixes x6   ceifeiro        terebinto+pedra (29,21)=observação
           feixe esquecido (21,29)        o  marcos de divisa (x=28)
 y31                       [CANTO de pé]  o
 y34       Tova (12,33)  pedra de bater (9,35)                         encosta seca
 y39   arbustos                                                         (leste desce)
```
Posições exatas (px) em `region.proposal.json`. Pontos-chave: entrada (24,296); Ilan (296,328); observação `bf_boundary_view` (464,344) sob terebinto; marcos em x=448; canto de pé tiles 23–26 × 31–34; abrigo (800,360); eira (880,196); porta (512,88); casa de Tova / `tova_home` (424,128). Faixa da cena (x 480–896, y 336–576) e caminho até a porta reservados, sem árvores.

**Props visuais** (novo = gerador de arte; reaproveitado = existe em `scenes/environments`):
- Novos: tiles `barley_standing`, `barley_stubble`, `threshing_floor`, `terra_rossa`; props `sheaf` (feixe em pé/deitado), `pithos` (borda em colarinho), `branch_shelter`, `house_pillar` (casa de pilares, teto plano), `village_gate` (portão modesto em muro de pedra seca), `stone_bench`, `grain_heap`, `threshing_sledge`, `winnowing_fork`, ícone de foice de sílex (marcador `sparkle` no chão serve até lá); muretas de terraço.
- Reaproveitados: `boundary_stone`, `rock_big`, `rock_small`, `bush`, `tree_olive`, `tree_oak` (como terebinto/carvalho), `oven`, `jar`, `basket`.
- Personagens: `ilan`, `tova`, `bf_reaper` (com foice de sílex), e só para a cena `ruth_figure`, `boaz_figure`, `bf_overseer`, `bf_servant`.
- Paleta e anacronismos: seguir `research_historical.md` (cevada `#D9C27A`, restolho `#C2AE7E`, terra rossa `#A65A3C`; nada de cercas de madeira, moedas, gadanha, foice de aço, cactos, porcos, galinhas, camelos). Luz diurna `#FFF7E8`.

## 10. O que exige código, dados ou assets (estimativa)
| Item | Tipo | Esforço |
|---|---|---|
| Cena dirigida: `data/scenes`, executor (camera, actor, move, remove, tint, caption, sfx, wait), pular, bloqueio de save, evento `scene_finished`, tipo de objetivo `observe_scene`, efeito `play_scene:` | código novo **compartilhado** com ep_009/016/048 | alto (3–5 dias), uma vez para o lote |
| Região `bethlehem_fields`: layout no `build_regions.gd`, bioma/tiles de Judá | gerador + dados | médio (1–2 dias) |
| Props e sprites listados no §9 | arte gerada | médio-alto (2–3 dias) |
| 3 missões, diálogos, 5 descobertas, 6 colecionáveis, 3 itens, apresentação | só dados | médio (1–2 dias, roteirista + implementador) |
| `verse_counts.json`: `Lev 19` (37), `Lev 23` (44), `Deut 24` (22); importar `Ruth 1:19`–`2:23`, `Lev 19:9-10`, `Lev 23:22`, `Deut 24:19` para `bpm.json` | dados/ferramenta | baixo |
| `people.json`: `ruth`, `naomi`, `boaz` | dados | baixo |
| Mapa das Escrituras: "Revisitar" experiências concluídas com `travel`; `travel` em `isaac_wells`/`joseph_dothan` | código pequeno + dados | baixo (meio dia) |
| NPC sem diálogo próprio (`bf_reaper`): confirmar se o motor exige `dialogue_id` (proposto `bf_reaper_work`) | verificação | baixo |
| `sfx grain_beat` no manifesto de áudio | áudio gerado | baixo |
| Variedade de objetivos: fala → coleta → entrega com escolha → cena → leitura (principal); fala → escolha → interação → rota (secundária) | — | — |

## 11. Divergências e pendências para o coordenador
- `verse_counts.json` **já tem** `Ruth 2` (23); a ficha bíblica dizia que faltava. Faltam de fato `Lev 19`, `Lev 23`, `Deut 24` (e `Ruth 3`/`4`, fora do escopo).
- `start`/`requires` da principal apontam para `joseph_dothan_road` por ser a última experiência jogável hoje; na ordem cronológica do lote deve apontar para a missão que fecha `exodus_sea`.
- A especificação da cena não fixa o nome da chave do tipo do passo; a proposta usa `"type"`.
- Decisão editorial aberta: viúva fictícia (Tova) × Noemi (ficha bíblica, item 10).
- O abrigo de ramos na refeição é hipótese; a cena não afirma que a refeição foi ali (legenda é só o versículo).
