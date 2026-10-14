# Design — ep_009 "José no Egito" (experiência `joseph_egypt`)

- **Autor:** agente `quest-designer` (IA). **Status:** `pending_review` (nada aprovado; aprovação só humana).
- **Base:** `production/reports/four_experiences_decisions.md` (decisões do criador + provisórias do coordenador + especificação da cena dirigida), `research_biblical.md` (**[FB §n]**) e `research_historical.md` (**[FH §n]**) deste episódio; modelos reais `data/regions/dothan.json`, `data/quests/dothan/*.json`, `data/world/experiences.json`, `scripts/world/world_manager.gd`, `scripts/quests/quest_database.gd`, `scenes/maps/dothan.tscn`, `tools/art_gen/build_regions.gd`.
- **Escopo bíblico:** `Gen 37:25-28`, `Gen 37:36` (caravana vista de longe) + `Gen 39:1-6` (casa de Potifar). `Gen 39:7-23` fica **fora** (vai para ep_010) [FB §8].
- **Pacote:** `quest.proposal.json` (4 missões), `region.proposal.json` (`egypt_house` + delta de `dothan`), `scenes.proposal.json` (cena dirigida + 2 apresentações), `experience.proposal.json` (entrada de `experiences.json`).
- **Nada em `data/`, `scenes/` ou `scripts/` foi alterado.**

---

## 1. Premissa e papel do jogador

O viajante fictício abre o Mapa das Escrituras em "José no Egito". Volta a Dotã, **sobe a uma encosta a oeste do vale** e, de longe, vê uma caravana de camelos atravessar a borda sul do vale rumo ao oeste. Não se aproxima, não segue e não interfere: assiste a uma **cena dirigida** com as legendas do texto bíblico (`Gen 37:25`, `37:28`, `37:36`). Depois, um cartão "OUTRO MOMENTO DA HISTÓRIA" o leva, **sem viajar com a caravana**, a uma propriedade egípcia recriada: a casa de um oficial do Faraó. Ali ele conversa com servos fictícios, conhece o pátio, o depósito, o celeiro e o campo, examina os registros da casa (objeto de contexto) e lê `Gen 39:1-6` no diário. José e Potifar **nunca aparecem e não falam** no Egito; a presença de José nessa parte é só texto bíblico citado.

**Papel:** testemunha distante (Dotã) e visitante posterior (Egito). Não compra, não liberta, não acompanha, não consola, não informa ninguém. As ajudas aos servos (secundária) são ficção sem ligação causal com a prosperidade da casa (`Gen 39:5` é atribuída ao SENHOR "por causa de José", nunca ao jogador; regra 12).

**Objetivo de aprendizagem proposto** (o do catálogo, "Integridade diante da injustiça", depende de `39:7-23`, fora do escopo [FB §8]): *"Deus presente com José na adversidade: vendido longe de casa, José serve com fidelidade numa casa estrangeira"*. Decisão humana.

---

## 2. Visão geral das missões

| # | Id | Título | Região | Categoria | Tipo | Início | Objetivos |
|---|---|---|---|---|---|---|---|
| 1 | `joseph_caravan_watch` | A caravana para o Egito | `dothan` | main | `story_witness` | `experience_started:joseph_egypt` | 3 |
| 2 | `joseph_potiphar_house` | A casa do oficial egípcio | `egypt_house` | main | `context_exploration` | `quest_completed:joseph_caravan_watch` | 6 |
| 3 | `egypt_granary_sacks` | Sacos para o celeiro | `egypt_house` | side | `assist` | `custom:egypt_senbi_harvest` | 4 |
| 4 | `egypt_house_life` | A vida na casa egípcia | `egypt_house` | exploration | `investigation` | `region_entered:egypt_house` | 2 |

A experiência `joseph_egypt` é concluída por `joseph_potiphar_house` (`completed_by`). As missões 3 e 4 são opcionais.

**Variedade (sequência real do jogador):** rota/subida (área) → cena dirigida → leitura → passagem → chegada → conversa → exploração de área → objeto de contexto → comparação ambiental "casa e campo" (dois examináveis) → leitura. Secundária: conversa → coleta → entrega → retorno. Nunca três diálogos seguidos; nenhum questionário.

---

## 3. Parte 1 — Dotã: `joseph_caravan_watch`

**Premissa:** o mesmo vale de Dotã de ep_008, outro momento do mesmo capítulo (`Gen 37:25`). A cena é vista de uma encosta nova, longe da cisterna (790,240) e das tendas dos pastores fictícios. A cisterna do mapa continua sendo "cisterna comum, não a do relato".

### Objetivos

| # | Id | Texto | `complete_on` | Alvo (existe?) |
|---|---|---|---|---|
| 1 | `climb_ridge` | Suba à encosta alta a oeste do vale. | `location_reached:dothan_ridge` | área `dothan_ridge` — **nova, via JSON** (delta de `dothan.json`) |
| 2 | `watch_caravan` | Observe a estrada do vale. | `scene_finished:joseph_caravan_departs` | examinável `dothan_ridge_view` — **novo, via JSON**; evento `scene_finished` **depende da cena dirigida** (`pending_target`) |
| 3 | `read_caravan_story` | Leia no diário o relato de Gênesis 37:25-36. | `presentation_finished:gen_037_caravan` | examinável `dothan_ridge_view` (de novo) ou diário (J) |

**Pistas (3 níveis)**

- `climb_ridge`: "De um lugar alto se vê o vale inteiro." · "Há uma encosta ao norte da entrada oeste de Dotã, acima da pedra do mirante." · "Da entrada oeste, caminhe para o norte até a pedra grande na encosta."
- `watch_caravan`: "Algo se move ao longe, na borda do vale." · "Da pedra grande da encosta se vê a borda sul do vale." · "Examine a pedra grande na encosta (E) e observe até o fim. Esc pula a cena."
- `read_caravan_story`: "O diário guarda o relato desse dia." · "Examine de novo a pedra grande, ou abra o diário (J) e escolha \"Ler o relato bíblico\"." · "Abra o diário (J), vá à missão \"A caravana para o Egito\" e leia o relato até o fim."

**Logs:** subida ("Da encosta, você vê o vale inteiro e a borda sul, por onde passa uma estrada."); cena ("De longe, você viu uma caravana com camelos carregados atravessar o vale para o oeste. Você não se aproximou."); leitura ("Você leu Gênesis 37:25-28 e 37:36: José foi vendido e levado para o Egito.").

**Motivo narrativo:** testemunhar de longe, com sobriedade, o momento em que José é levado; nenhuma ação do jogador muda isso. **Descobertas:** `caravan_to_egypt` (nova, no fim da cena) e `caravans_trade` (existe).

### Diálogos (ids; o roteirista escreve)

| Id | Onde | Precisa cobrir | Efeitos |
|---|---|---|---|
| `dothan_ridge_view` | examinável `dothan_ridge_view` | `start_if`: (a) objetivo `watch_caravan` ativo → narração curta ("Do alto, a borda sul do vale…") e `"action": "play_scene:joseph_caravan_departs"`; (b) objetivo `read_caravan_story` → "Você abre o diário de viagem…" + `action: {"presentation": "gen_037_caravan"}`; (c) depois → descrição do vale vazio, sem repetir a cena (narração neutra, sem caravana). | `play_scene`, `presentation`; nada de item |

### Cena dirigida `joseph_caravan_departs` (resumo; JSON em `scenes.proposal.json`)

1. Câmera sai do jogador e vai devagar à borda sul (`[560, 560]`, zoom 0.7).
2. Poeira ao longe no leste (`dust`), som `amb_hooves` + `amb_cargo_creak`.
3. Entram pela borda leste (x≈1060, y≈585) **5 dromedários** com fardos sobre manta, **3 mercadores a pé** com cajado e **1 jovem em silhueta** entre os mercadores (José, decisão do criador): pequeno, sem destaque, sem corda, corrente ou chicote, sem câmera próxima, sem rótulo.
4. Legendas: `Gen 37:25` (texto oficial) → `Gen 37:28` → nota de contexto: "O relato chama os mercadores de ismaelitas e de midianitas. O jogo não escolhe entre as leituras." → `Gen 37:36`.
5. A caravana segue para o oeste e sai pela borda sudoeste (x≈−60). Poeira some.
6. Legenda de ficção identificada: "Você ficou na encosta. O viajante é um personagem do jogo e não muda o que o relato conta."
7. Câmera volta ao jogador. Evento `scene_finished:joseph_caravan_departs`; libera a descoberta `caravan_to_egypt`.

**Não mostrar:** a roda dos irmãos, a cisterna do relato, a retirada de José, a prata (pesagem/entrega), Rúben, Judá, sangue, túnica. Duração-alvo: 45–60 s; pulável (Esc vai ao estado final).

**Rota da caravana:** borda sul, `y≈585`, entre a fileira de árvores da borda (`y≥603`) e as árvores soltas em (330,520), (417,545), (760,560). Distância ao ponto de observação (112,150): ~430 px (≈27 tiles). A caravana **não usa** a trilha do mapa (que passa pela cisterna e pela entrada do jogador). Conferir sobreposição visual com as árvores (750,484), (760,560), (932,579), (29,573): os figurantes não colidem, mas podem ficar atrás de copas (y-sort).

### Apresentação `gen_037_caravan` (JSON em `scenes.proposal.json`)

Passos: `Gen 37:25` · `Gen 37:26-27` (proposta de Judá; só o texto, sem julgamento) · `Gen 37:28` (nota: "peças de prata pesadas, não moedas"; sujeito de "tiraram" ambíguo) · `Gen 37:36` · nota final (37:18-24 e 37:29-35 resumidos com referência, como paráfrase do jogo; Rúben volta e não encontra José; crédito; o viajante, Rafi, Talia, Oren e Malik são fictícios). Libera só `caravan_to_egypt` (idempotente: a cena também a libera).

### Conclusão

- **Título:** "A caravana se afastou". **Referências:** `Gen 37:25-28`, `Gen 37:36`.
- **Resumo (3 pontos):** caravanas levavam resinas de Gileade ao Egito (`37:25`); José foi vendido por vinte peças de prata e levado ao Egito (`37:28`); o texto chama os mercadores de ismaelitas e de midianitas, e o jogo não resolve essa alternância.
- **Next:** "O relato continua no Egito, em Gênesis 39. Abra o Mapa das Escrituras (M), escolha \"José no Egito\" e \"Continuar\": é outro momento da história, e o viajante não viaja com a caravana."

---

## 4. Passagem entre épocas

Há **duas** passagens, ambas no cartão "OUTRO MOMENTO DA HISTÓRIA" do Mapa das Escrituras (`scripts/ui/scripture_map.gd`):

1. **Entrada na experiência** (`passage`, já suportado): de `Gen 37:17` (fim de ep_008) para `Gen 37:25` — mesmo dia, mesmo vale; o viajante volta a Dotã por conta própria. Destino: `dothan/default`.
2. **Dotã → Egito** (`stages[1].passage`, **código novo**): depois de `joseph_caravan_watch`. Texto deve dizer: (a) o viajante não seguiu a caravana; (b) o texto **não informa** quanto durou a viagem nem quanto tempo José ficou na casa antes de ser posto como administrador; (c) a casa visitada é uma recriação de uma propriedade egípcia, sem cidade, Faraó ou dinastia identificados; (d) `Gen 39:7-23` fica para outro capítulo — **sem** mencionar o conteúdo (só "a história de José continua em Gênesis 39-41"). Destino: `egypt_house/from_passage`.

**Por que código novo:** hoje `start_experience` aceita um único `travel`, e o botão "Continuar" de uma experiência ativa só leva a esse destino. A proposta é um campo opcional `stages` (lista; vale o último estágio cuja condição `if` é verdadeira), cada um com `travel` e, opcionalmente, `passage` (mostrada uma vez por estágio, flag `experience_stage:<xid>:<stage>`). Retrocompatível: experiências sem `stages` seguem como hoje.

**Volta do Egito (código novo, pequeno):** saída `west_road` de `egypt_house` com `"passage"` (cartão antes de viajar) para `dothan/default`. Sem esse campo, o jogador ainda pode usar a saída, mas sem o cartão — inaceitável pela regra "não se caminha entre épocas"; por isso a saída é marcada `pending_target` até o campo existir. Alternativa equivalente: botão "Revisitar" para experiências concluídas no Mapa das Escrituras.

---

## 5. Parte 2 — Egito: `joseph_potiphar_house` (principal)

**Premissa:** uma propriedade egípcia recriada, "Casa de um oficial egípcio", no Egito de José. O texto não diz em que cidade ficava [FH §2.2]. O viajante chega como estrangeiro de passagem (como em Canaã), é recebido pelo porteiro e circula pelos espaços de trabalho.

### Personagens fictícios (novos em `data/characters/egypt_house.json`)

| Id | Nome | Papel | Onde | Observação |
|---|---|---|---|---|
| `ipi` | Ipi | Porteiro idoso | fora do portão sul (436,470) | recebe o viajante; fala da casa e do dono **só com o que o texto diz** (oficial do Faraó, capitão da guarda) |
| `meryt` | Meryt | Despenseira (guarda os jarros e as rações) | porta do depósito (600,280) | fala de rações, selos e medidas (*hekat*) |
| `senbi` | Senbi | Lavrador | eira (780,392) | fala do campo, das estações, da colheita; dá a secundária |
| animais | `cattle` ×2, `donkey` ×1, `goose` ×3, `cat` ×1 | ambiente | curral, pátio, tanque, celeiro | sem camelos, cavalos ou galinhas [FH §6] |

Nomes egípcios plausíveis, **a conferir pelo revisor histórico**. Nenhum servo é hebreu/semita nesta versão, para não sugerir companheiro de José (o Papiro Brooklyn permitiria; decisão humana).

### Objetivos

| # | Id | Texto | `complete_on` | Alvo |
|---|---|---|---|---|
| 1 | `arrive_egypt` | Abra o Mapa das Escrituras e siga para o Egito de José. | `region_entered:egypt_house` | `ui:scripture_map` |
| 2 | `meet_porter` | Fale com o porteiro da propriedade. | `custom:egypt_ipi_welcome` | npc `ipi` |
| 3 | `enter_courtyard` | Entre no pátio da casa. | `location_reached:eh_courtyard` | área `eh_courtyard` |
| 4 | `household_records` | Examine a mesa do escriba, junto ao depósito. | `dialogue_finished:eh_records` | examinável `eh_records` |
| 5 | `house_and_field` | Veja a casa e o campo: o celeiro e o campo irrigado. | `condition:eh_house_and_field` (`all` de `event dialogue_finished eh_granary` + `event dialogue_finished eh_field`) | examináveis `eh_granary`, `eh_field` |
| 6 | `read_potiphar_story` | Leia no diário o relato de Gênesis 39:1-6. | `presentation_finished:gen_039_potiphar` | examinável `eh_journal` (diário de viagem junto ao tanque) |

**Pistas**

- `arrive_egypt`: "O relato continua em outro lugar." · "O Mapa das Escrituras abre com M; \"José no Egito\" tem uma nova etapa." · "Pressione M, escolha \"José no Egito\" e \"Continuar\"."
- `meet_porter`: "Grandes casas tinham quem cuidasse da entrada." · "O porteiro fica do lado de fora do portão, no muro sul." · "Siga a estrada até o portão sul e converse com Ipi."
- `enter_courtyard`: "A vida da casa acontece ao ar livre." · "O pátio fica logo depois do portão, diante do pórtico de colunas." · "Atravesse o portão sul e caminhe até o centro do pátio."
- `household_records`: "Uma casa grande precisa contar o que entra e o que sai." · "Perto do depósito de jarros há uma mesa com papiro e paleta." · "Examine a mesa do escriba, a leste do pátio, junto à porta do depósito."
- `house_and_field`: "Gênesis 39:5 fala da casa e do campo." · "Os celeiros ficam a leste do muro; o campo, ao sul, junto ao canal." · "Examine os silos a leste e depois a beira do campo, ao sul da estrada."
- `read_potiphar_story`: "O diário guarda o relato desta casa." · "O diário de viagem está sobre um banco, junto ao tanque do jardim." · "Examine o diário junto ao tanque (noroeste do muro) ou abra J e escolha \"Ler o relato bíblico\"."

**Logs, motivo e descobertas**

| Objetivo | Log (resumo) | Motivo narrativo | Descoberta |
|---|---|---|---|
| `arrive_egypt` | Você chegou a uma propriedade egípcia, outro momento da história. | situar | — (região: `egypt_black_land` no `discoveries_on_enter`) |
| `meet_porter` | Ipi contou que a casa pertence a um oficial do Faraó. | apresentar a casa sem pôr Potifar em cena | — |
| `enter_courtyard` | O pátio é o lugar do trabalho diário: moagem, cestos, jarros. | exploração livre | — |
| `household_records` | Na mesa do escriba, papiro, paleta e jarros selados mostram como a casa controlava seus bens. | contexto de `39:4` ("administrador") sem atribuir registros a José | `egyptian_household` (nova, `historical_context`) |
| `house_and_field` | Celeiro e campo: a riqueza da casa vinha da terra irrigada. | ancorar "na casa e no campo" (`39:5`) no espaço | `nile_agriculture` (nova, `historical_context`) |
| `read_potiphar_story` | Você leu Gênesis 39:1-6: o SENHOR estava com José, e Potifar lhe confiou a casa. | relato bíblico em primeiro plano | `joseph_steward` (nova, `recorded_event`) |

### Diálogos (ids; o roteirista escreve)

| Id | Fala de | Precisa cobrir | Eventos/efeitos |
|---|---|---|---|
| `ipi_talk` | Ipi | Boas-vindas ao estrangeiro; a casa pertence a "um oficial do Faraó, capitão da guarda" (só o texto, `39:1`); trabalho de servos e lavradores; sem descrever Potifar. **Ponto pendente (FB §11.8):** versão A diz que "a casa tem um administrador, um jovem estrangeiro" — paráfrase de `39:4`; versão B não menciona administrador. Escrever as duas; a humana decide. | `custom:egypt_ipi_welcome` |
| `meryt_talk` | Meryt | Rações, jarros selados com argila, medida de grão; a casa anda bem ("nunca faltou grão") **sem** atribuir causa; nada sobre a comida de Potifar (`39:6a`). Ramo da secundária (entrega dos sacos). | `custom:egypt_meryt_storeroom`; entrega: `take barley_sack ×3` → `custom:egypt_meryt_sacks` |
| `senbi_talk` | Senbi | Estações (cheia, semeadura, colheita), canal, cevada e linho; pede ajuda com os sacos; volta. | `custom:egypt_senbi_harvest`, `custom:egypt_senbi_thanks` |
| `eh_records` | narrador | Papiro, prancheta, paleta com tinta preta e vermelha, jarros com selo; "registros como estes existiam em grandes casas"; **não** são de José; escrita ilegível. | `unlock: egyptian_household` |
| `eh_granary` | narrador | Silos de tijolo de barro com topo em cúpula; grão guardado para o ano; gatos contra ratos. | — |
| `eh_field` | narrador | Campo em faixas com diques, canal, linho e cevada; "terra negra" × deserto ao longe. | `unlock: nile_agriculture` |
| `eh_journal` | narrador | Abre o diário: `action: {"presentation": "gen_039_potiphar"}`. Depois de lido: "Rever o relato". | — |
| `eh_pool`, `eh_oven`, `eh_loom`, `eh_jars`, `eh_shaduf` | narrador | 1–2 falas de contexto cada; `grant_collectible` do próprio id. `eh_shaduf` cita a incerteza (atestado no Reino Novo). | `grant_collectible` |

### Apresentação `gen_039_potiphar`

Passos: `Gen 39:1` (nota: o texto não diz a cidade nem o Faraó; "oficial" e "capitão da guarda" na forma da tradução) · `Gen 39:2-3` (nota: o texto não diz como Potifar percebeu) · `Gen 39:4` · `Gen 39:5` (nota: a bênção é atribuída ao SENHOR, "por causa de José") · `Gen 39:6` (nota curta: o texto não explica a frase sobre a comida; **sem** comentar a aparência de José) · nota final (o capítulo continua em `39:7-23`, contado em outro capítulo desta jornada — sem resumir; crédito; servos e casa são recriações). Todos os versículos estão em `bpm.json`. Libera `joseph_steward`.

### Conclusão

- **Título:** "Uma casa no Egito". **Referências:** `Gen 37:36`, `Gen 39:1-6`.
- **Resumo:** José foi comprado por Potifar, oficial do Faraó (`39:1`); o SENHOR estava com José, e Potifar lhe confiou tudo o que tinha, na casa e no campo (`39:2-6`); o texto não diz em que cidade ficava a casa nem quanto tempo se passou.
- **Next:** "A história de José continua em Gênesis 39-41. Essa parte está em planejamento." (sem antecipar acusação ou prisão).

---

## 6. Secundária `egypt_granary_sacks` — "Sacos para o celeiro"

Senbi colheu cevada e precisa levar sacos da eira ao depósito antes do fim do dia; Meryt confere a entrega. Ficção identificada, sem relação com José nem com a "bênção" (`39:5`).

| # | Id | Texto | `complete_on` | Alvo |
|---|---|---|---|---|
| 1 | `talk_senbi` | Ouça o pedido de Senbi, na eira. | `custom:egypt_senbi_harvest` | npc `senbi` |
| 2 | `gather_sacks` | Recolha 3 sacos de cevada na eira. | `inventory:barley_sack` count 3 | pickups `eh_sack_1..3` |
| 3 | `deliver_meryt` | Entregue os sacos a Meryt, no depósito. | `item_delivered:barley_sack` | npc `meryt` |
| 4 | `back_to_senbi` | Conte a Senbi que os sacos chegaram. | `custom:egypt_senbi_thanks` | npc `senbi` |

Pistas e logs no JSON. **Item novo:** `barley_sack` ("Saco de cevada", categoria `quest`, `max_stack` 3). **Recompensa:** só flag `helped_egypt_harvest` (nenhum item de valor; nada de prata). **Início:** a missão começa pelo evento do diálogo (como `dothan_families`), então o primeiro objetivo é retroativo.

---

## 7. Exploração `egypt_house_life` — "A vida na casa egípcia"

Conjunto de colecionáveis `egypt_house_life` (5): `eh_pool` (tanque com lótus), `eh_oven` (forno e moldes de pão), `eh_loom` (tear horizontal e feixes de linho), `eh_jars` (jarros selados), `eh_shaduf` (balancim do canal, hipótese). Objetivos: `first_life` (`collection:egypt_house_life` count 1) e `all_life` (`collection_completed:egypt_house_life`). Recompensa: nenhuma (ou flag). Classificação `historical_context`.

---

## 8. Mapa novo `egypt_house` — layout

- **Tamanho:** 64 × 40 tiles de 16 px = **1024 × 640 px** (igual a Dotã). Gerado por `tools/art_gen/build_regions.gd` (novo `LAYOUTS.egypt_house`) com **tileset novo** `egypt_tileset` (terra preta úmida, terra batida, areia "terra vermelha", água de canal, diques). Paleta [FH §10].
- **Display:** "Casa de um oficial egípcio" · área "Egito de José" · subtítulo "Época dos patriarcas (datação aproximada e debatida)" · bioma `egito` (novo).

```
 x→ 0    8    16   24   32   40   48   56   63 (tiles)
y0  ~~~~~~~~ deserto claro ("terra vermelha") ~~~~~~~~~~~~
y4  +=========== muro de recinto ============+   silos ■■■■
y8  | jardim+tanque | casa + pórtico | depós.|   (celeiro)
y16 |   (diário)    |   colunas      | escriba   ...........
y19 | cozinha/forno |     PÁTIO      |       |   eira  curral
y27 +======== portão sul (22-25) ===========+        gado
y30 ======= estrada de terra (entrada oeste) =====
y29-36            campos em faixas c/ diques (cevada, linho)
y37-39 ~~~~~~~~ canal com papiro ~~~~~ shaduf ~~~~~~~~~~~~~
```

### Zonas (pixels; retângulo = x, y, largura, altura)

| Zona | Retângulo (px) | Tiles | Conteúdo |
|---|---|---|---|
| Borda de deserto | 0, 0, 1024, 64 | y 0–3 | areia rosada, poucas acácias/tamargueiras |
| Muro de recinto | 64, 64 → 656, 448 | x 4–41, y 4–28 | tijolo de barro, topo reto; **portão** no muro sul em x 352–416 (tiles 22–25) com batentes de pedra |
| Jardim com tanque | 96, 96, 208, 176 | x 6–18, y 6–16 | tanque retangular (216,200) com lótus; 4 sicômoros/tamareiras; banco com o diário |
| Casa principal + pórtico | 336, 96, 224, 160 | x 21–34, y 6–15 | bloco de teto plano sobre plataforma; 4 colunas de madeira pintadas na frente (y≈256); **não entrável** |
| Depósito + escriba | 576, 96, 80, 176 | x 36–40, y 6–16 | fileiras de jarros selados; mesa do escriba na porta |
| Cozinha/padaria | 96, 304, 176, 128 | x 6–16, y 19–26 | forno cilíndrico, moldes de pão, moinho de sela |
| Pátio | 320, 272, 272, 144 | x 20–36, y 17–25 | terra batida, cestos, sacos, gansos; tear sob toldo à oeste |
| Celeiros | 704, 96, 240, 160 | x 44–58, y 6–15 | 4 silos de cúpula em fileira + escada; mureta baixa; gato |
| Eira | 736, 336, 128, 96 | x 46–53, y 21–26 | círculo de debulha, pá de joeirar, palha |
| Curral | 896, 288, 112, 144 | x 56–62, y 18–26 | cercado de vara e esteira; gado de chifres longos, burro |
| Estrada | 0, 480, 400, 32 + 352, 448, 64, 32 | y 30–31, x 0–24; x 22–25, y 28–29 | terra batida da borda oeste até o portão |
| Campos | 448, 464, 576, 128 | x 28–63, y 29–36 | faixas de cevada (dourada) e linho (verde/azul) com diques |
| Canal | 0, 592, 1024, 48 | y 37–39 | água verde-azulada, papiro e juncos; shaduf em (720,600) |

### Elementos de dados (posições reservadas; nada de árvore/pedra gerada em cima)

| Tipo | Id | Posição (px) | Prop | Nota |
|---|---|---|---|---|
| entrada | `default`, `from_passage` | (40, 496) → direita | — | estrada oeste |
| saída | `west_road` | rect 0, 476, 12, 40 | — | volta a Dotã **com cartão de passagem** (código novo) |
| área | `eh_courtyard` | rect 320, 272, 272, 144 | — | objetivo 3 |
| área | `eh_gate` | rect 352, 432, 64, 48 | — | reserva (portão; sem objetivo) |
| npc | `ipi` | (436, 470) | — | fora do portão |
| npc | `meryt` | (600, 280) | — | porta do depósito |
| npc | `senbi` | (780, 392) | — | eira |
| npc | `cattle_1`, `cattle_2` | (930, 340), (968, 392) | — | curral |
| npc | `donkey_1` | (920, 410) | — | curral |
| npc | `goose_1..3` | (200, 236), (240, 228), (420, 360) | — | tanque e pátio |
| npc | `cat_1` | (760, 240) | — | celeiro |
| examinável | `eh_records` | (640, 232) | `scribe_table` (novo) | objetivo 4 |
| examinável | `eh_granary` | (800, 210) | `granary_silos` (novo) | objetivo 5 |
| examinável | `eh_field` | (640, 470) | `flax_bundles` (novo) | objetivo 5; beira do campo |
| examinável | `eh_journal` | (264, 232) | `journal` (existe) | `kind: read`; objetivo 6 |
| examinável | `eh_pool` | (216, 200) | `garden_pool` (novo) | colecionável |
| examinável | `eh_oven` | (176, 352) | `egypt_oven` (novo; o `oven` de Canaã não serve) | colecionável |
| examinável | `eh_loom` | (360, 392) | `floor_loom` (novo) | colecionável |
| examinável | `eh_jars` | (608, 160) | `storage_jars` (novo) | colecionável |
| examinável | `eh_shaduf` | (720, 600) | `shaduf` (novo) | colecionável |
| pickup | `eh_sack_1..3` | (764, 372), (804, 404), (840, 366) | item `barley_sack` | `visible_if` objetivo `egypt_granary_sacks/gather_sacks` |

### Delta de `dothan.json` (só dados; `dothan.tscn` não muda)

| Tipo | Id | Posição | Observação |
|---|---|---|---|
| área | `dothan_ridge` | rect 64, 112, 96, 80 (tiles 4–9, 7–11) | livre de árvores (mais próximas: (24,140), (39,106), (123,203)) |
| examinável | `dothan_ridge_view` | (112, 150), prop `rock_big` | `visible_if: {"flag": "experience:joseph_egypt"}`; prompt "Observar a estrada do vale" |

Distância da pedra do mirante existente (140,262): 115 px — distintos e sem sobreposição. A "elevação" é sugerida pelo texto e pela câmera; não há tile de relevo no mapa (limitação aceita; um prop `ridge_ledge` pode vir depois).

---

## 9. Descobertas propostas (novas em `data/bible/discoveries.json`)

| Id | Classificação | Conteúdo | Refs |
|---|---|---|---|
| `caravan_to_egypt` | `recorded_event` | Caravana de Gileade ao Egito; José vendido por vinte peças de prata (prata pesada); alternância ismaelitas/midianitas sem solução; seção `historical`: camelos citados pelo texto, uso no período **debatido** | `Gen 37:25-28`, `Gen 37:36` |
| `egyptian_household` | `historical_context` | Grandes casas: superintendente, escribas, despenseiros, registros de grão e rações; papiro, paleta, selos; seção `fiction`: a mesa do jogo é recriação, não registros de José | `Gen 39:4` (só como ligação) |
| `nile_agriculture` | `historical_context` | Terra negra × terra vermelha, três estações, cevada, emmer, linho, canais e diques; shaduf como hipótese | `Gen 39:5` (só como ligação) |
| `joseph_steward` | `recorded_event` | Paráfrase de `39:1-6`; "o texto não diz como Potifar percebeu" nem quanto tempo passou; seção `interpretation` (devocional, identificada): Deus presente com José longe de casa, sem tornar a venda boa | `Gen 39:1-6` |
| `egypt_black_land` | `historical_context` | Entrada na região: Egito como faixa fértil no deserto; sem cidade nomeada | — |

Colecionáveis novos: conjunto `egypt_house_life` (5 itens acima), `historical_context`, referências vazias.

---

## 10. Props visuais (lista para `visual-asset-producer`)

**Dotã (cena):** `silhouette_camel` (dromedário com fardos sobre manta, sem sela de armação, 4 direções ou só lateral), `silhouette_merchant` (túnica longa de lã, cajado, a pé), `silhouette_youth` (jovem pequeno, sem amarras), efeito `dust` (partículas). Reaproveita `rock_big`.

**Egito — novos:** tileset `egypt_tileset` (terra preta, terra batida, areia rosada, água de canal, borda de dique, papiro) · `enclosure_wall` (segmentos h/v + portão com batentes de pedra) · `house_portico` (casa de teto plano com 4 colunas de madeira pintadas, capitel de papiro fechado) · `garden_pool` · `tree_sycamore` · `tree_date_palm` · `tree_acacia` · `granary_silos` (4 silos de cúpula + escada) · `storage_jars` · `scribe_table` (papiro, prancheta, paleta, pincéis, estojo) · `egypt_oven` (forno cilíndrico + moldes de pão em cone) · `saddle_quern` · `floor_loom` · `flax_bundles` · `threshing_floor` (eira + pá de joeirar + palha) · `reed_fence` (curral) · `shaduf` · `papyrus_reeds` · `grain_sacks` (sacos de linho) · ícone `barley_sack`.
**Personagens:** `ipi`, `meryt`, `senbi` (linho branco, saiote/vestido, pele em três tons morenos [FH §5]); animais `cattle`, `donkey`, `goose`, `cat`.
**Evitar** [FH §9]: pirâmide, esfinge, obelisco, símbolos reais, hieróglifo legível, vidro, ferro, moedas, galinhas, camelos ou cavalos no Egito, roda d'água, colunas gregas, chicote.

---

## 11. O que exige código novo (estimativas)

| Item | Onde | Esforço |
|---|---|---|
| **Cena dirigida** (`data/scenes/*.json`, efeito `play_scene:<id>`, evento `scene_finished`, objetivo `observe_scene` com `scene_finished`, figurantes, câmera, legendas, `dust`, pular com Esc, bloqueio de save) | spec comum do lote; já planejada | 2–3 dias (compartilhado com ep_016/ep_048) |
| `stages` em experiências (vários destinos + passagem por estágio) | `world_manager.gd`, `scripture_map.gd`, validador | 0,5 dia |
| `passage` em saídas de mapa (cartão antes de `travel`) | `map_exit.gd` + reaproveitar a UI do cartão | 0,5 dia |
| Bioma/tileset `egito` + `LAYOUTS.egypt_house` no gerador + props novos | `tools/art_gen/*` | 2–3 dias (arte procedural) |
| Sprites de 3 servos + 4 animais + 3 silhuetas | gerador de arte | 1 dia |
| Dados: 4 missões, 2 regiões, ~12 diálogos, 2 apresentações, 5 descobertas, 1 conjunto (5 colecionáveis), 1 item, personagens | `data/` | 1 dia (roteirista + implementador) |
| Ambiente sonoro do Egito (`amb_wind_egypt`, `amb_geese`, `amb_water_canal`) | `tools/audio/generate_sfx.gd`, manifesto | 0,5 dia |
| Testes (alvos existem, save/load no meio da cena, cena não repete, saída com passagem) | `tests/` | 0,5–1 dia |

Nada exige novo tipo de objetivo além de `observe_scene` (já previsto na spec).

---

## 12. Riscos e pontos para decisão humana

1. **Silhueta de José** na caravana (decisão do criador): manter distante, sem destaque; QA deve conferir em 1280×720 que não há "close".
2. **Boato do administrador** (FB §11.8): versão A/B do diálogo de Ipi; recomendação do designer: **B** (sem mencionar o administrador), deixando `39:4` só no relato lido.
3. **Volta do Egito** depende do campo `passage` em saídas (ou "Revisitar"); sem isso o jogador ficaria preso no Egito — bloqueio de implementação.
4. **Objetivo de aprendizagem** e referência do catálogo (`Gen 39:1-23`, `obj_03 joseph_imprisoned`) divergem do escopo; registrar em `KNOWN_ISSUES` e atualizar o catálogo.
5. **Shaduf** e **nomes egípcios** dos servos: revisor histórico confirma.
6. **Apresentação `gen_037_caravan`:** inclui `Gen 37:26-27` (Judá) além das decisões (`37:25-28` cobre). Nota final resume `37:18-24` e `37:29-35` como paráfrase com referência — verificador bíblico confere.
7. **Escala:** a "elevação" de Dotã é só narrativa; se o criador quiser relevo visível, exige editar `dothan.tscn` (fora do escopo pedido).
8. **Cena e save:** a cena bloqueia o save; ao carregar com `watch_caravan` ativo, a cena pode ser vista de novo pelo examinável; depois de `scene_finished`, o `start_if` do diálogo não a repete.
