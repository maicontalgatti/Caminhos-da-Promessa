# Design — ep_048 "Os pastores de Belém" (experiência `shepherds_bethlehem`, época `first_century`)

- **Autor:** agente `quest-designer` (IA), 2026-10-14. **Status:** proposta, `pending_review`; nada verificado.
- **Base:** `production/reports/four_experiences_decisions.md` (decisões do ep_048, encadeamento, infraestrutura e
  especificação da cena dirigida), `research_biblical.md` e `research_historical.md` deste episódio, designs irmãos
  (ep_016, ep_025) e dados reais (`data/regions/dothan.json`, `data/quests/dothan/*.json`, `data/world/experiences.json`,
  `data/items/items.json`, `scripts/quests/quest_database.gd`, `scripts/core/conditions.gd`).
- **Arquivos do pacote:** `quest.proposal.json` (1 principal + 2 secundárias), `region.proposal.json` (região nova
  `bethlehem_night`), `scenes.proposal.json` (2 cenas dirigidas), `experience.proposal.json`.
- **Escopo bíblico:** centro `Luke 2:8-20`; contexto `Luke 2:1-7` só em paráfrase (cartão de passagem e diário).
  Todos os versículos citados na tela (`Luke 2:8` a `Luke 2:20`) **já existem** em `data/bible/texts/bpm.json`.
- Falas **não** estão escritas: cada diálogo traz id, nós e conteúdo esperado (§8). O roteirista escreve.

---

## 1. Premissa e papel do jogador

Ao **entardecer**, o viajante fictício chega aos campos na encosta a leste de Belém. Conhece **Tamir**, pastor
fictício mais velho, e **Shai**, jovem adulto que trabalha com ele. Ajuda no fim do dia: **recolher ovelhas
desgarradas no aprisco** de pedra seca, **trazer lenha** para a fogueira do posto de vigia e, já de **noite**,
**assumir o primeiro turno da vigília** enquanto Tamir dorme.

Junto ao portão do aprisco, a uns 200 px do posto, **três pastores do relato** (representação: o texto não diz
quantos eram) vigiam o próprio rebanho em volta de outra fogueira. Do posto, à margem, o viajante **assiste** à cena
dirigida do anúncio: **só luz** ao redor deles (Lc 2:9), legendas de Lc 2:9, 2:10-12 e 2:13-14 pelo texto oficial,
as luzes se afastam e os pastores **combinam ir a Belém** (Lc 2:15, paráfrase identificada) e sobem depressa.

O viajante **segue de longe** pelo caminho da encosta até um ponto de observação abaixo da **casa de pedra
encostada na rocha** (com área de animais), vista **só de fora**. Segunda cena dirigida: os pastores chegam à porta
e entram no pátio (Lc 2:16 citado); o tempo passa; saem e descem **louvando a Deus** (Lc 2:20 citado). O viajante
volta à fogueira; Tamir, acordado, ouviu dos vizinhos o que eles contavam (Lc 2:17-18, paráfrase identificada).

**Papel:** quem **ajuda** (Tamir, Shai) e quem **observa** (os pastores do relato, de longe). Nunca entra no relato.

### Restrições (aplicadas em todos os arquivos)
- **Anjo: só luz.** Nenhuma figura, asa, auréola, rosto ou silhueta. Multidão celestial = muitas luzes pequenas e
  sóbrias no céu, sem forma. O texto "louvando… e dizendo": nada de "canto dos anjos" em legenda ou descoberta.
- **Pastores do relato:** 3 figurantes, rótulo "representação; o texto não diz quantos". Sem nomes, sem idades
  marcadas (nenhum "pastorzinho"), **sem falas livres**: só a citação de 2:15 em paráfrase identificada (coletiva,
  sem orador individual). Como NPCs, examinar dá só uma descrição do narrador.
- **O viajante não recebe o anúncio:** fica no posto, fora do círculo de luz; não vai com os pastores, não os guia,
  não ajuda a achar a casa, não leva notícia. Tamir **dorme** durante o anúncio e Shai só vê os vizinhos partirem:
  nenhum fictício "testemunha a glória" (risco 11 da ficha bíblica).
- **Belém e a casa vistas de fora:** sem cena do parto, sem interior, sem Maria, José ou o bebê em tela, sem falas
  ou pensamentos deles. A escada da casa é cenário (colisão) com uma explicação no examinável.
- **Sem presépio tradicional:** sem estrela, magos, neve, pinheiro, estábulo de madeira, boi e jumento junto à
  manjedoura, estalajadeiro. *Katalyma* marcado como **debatido** no diário.
- **Datação:** nenhum ano exibido; estação neutra (sem neve, sem flores, sem colheita). Lua sem fase afirmada.
- **Regra 12:** nada da cena vira item, ponto, poder, moeda ou colecionável. Recompensas só em flags.
- **Só texto (sem voz)** nas cenas e nos diálogos dos pastores do relato.

---

## 2. Passagem entre épocas
Cartão "OUTRO MOMENTO DA HISTÓRIA" (rascunho em `experience.proposal.json`): (1) muitos séculos depois de Rute, Belém,
"cidade de Davi" (Lc 2:4), é uma aldeia da Judeia sob Roma, nos dias de Herodes (Lc 1:5) e de Augusto (Lc 2:1); sem
ano; (2) paráfrase de Lc 2:1-7 (registro, viagem de José e Maria, nascimento, manjedoura) e chegada ao entardecer;
(3) ficção identificada (viajante, Tamir, Shai; pastores do relato como representação; ninguém do relato conversa).
Destino: `travel: {region: bethlehem_night, entry: from_scripture_map}`. Requisito: `quest_completed: ruth_gleaning`.

---

## 3. Estados do mapa e luz (`lighting` por flags)

| Estado | Condição (primeira que valer) | `tint` | O que muda |
|---|---|---|---|
| **Noite** | `flag bn_night` | `#5A6496` | fogueiras acesas (luz quente), poucas janelas de Belém com lamparina (`#E9A955`), ovelhas dentro do aprisco, Tamir dormindo até a volta dos pastores |
| **Entardecer** (padrão) | — | `#E9B98E` | ovelhas espalhadas, fogueiras apagadas, Shai na encosta |

- `bn_night`: posto pelo nó de entrega da lenha de Tamir (objetivo `kindle_fire`).
- `bn_watch_begun`: posto no nó de vigília, **antes** do `play_scene` (esconde os NPCs dos pastores do relato, que a
  cena recria como figurantes).
- `ev:scene_finished:shepherds_announcement` e `ev:scene_finished:shepherds_at_the_house`: flags automáticas de evento.
- A luz da glória e a penumbra da casa são `tint`/`effect` **dentro das cenas**, não estados persistentes.
- Exige o campo `lighting` da região (infraestrutura nº 4 do relatório do lote): `[{if, tint}]`, avaliado ao entrar
  e em `flag_changed`. Efeitos e sons ambientes por estado: `ambient_effects_proposed` / `ambient_sfx_proposed`.

Visibilidade dos pastores do relato (`bn_rep_a/b/c`): antes da vigília (`not_flag bn_watch_begun`) no fogo do
portão; entre as cenas, ausentes; depois de `shepherds_at_the_house`, de volta ao fogo do portão.

---

## 4. Missão principal — `shepherds_night` "Uma noite nos campos de Belém" (`story_witness`, `main`)

Início: `experience_started shepherds_bethlehem` (mesmo padrão do ep_016; sem objetivo `open_map`). Bloqueio na
experiência (`requires ruth_gleaning`). Conclui a experiência.

| # | id | O jogador… | `complete_on` | Alvo real | Motivo narrativo | Descoberta |
|---|---|---|---|---|---|---|
| 1 | `meet_tamir` | fala com o pastor no posto de vigia | `custom bn_tamir_hello` | npc `tamir` | chegada ao entardecer; o rebanho precisa entrar antes da noite | `night_shepherding` (e `bethlehem_first_century` ao entrar) |
| 2 | `gather_flock` | conduz 4 ovelhas desgarradas ao aprisco | `condition` todas as flags `bn_stray_1..4` | examináveis `bn_stray_1..4` | exploração da encosta (terraços, rochas, boca de gruta) | — |
| 3 | `kindle_fire` | junta 3 lenhas secas e entrega a Tamir | `item_delivered dry_wood` | pickups `bn_wood_1..4`; npc `tamir` | o fogo da noite; lenha escassa (arbustos espinhosos); **anoitece** (`bn_night`) | — |
| 4 | `night_watch` | assume a vigília no posto | `scene_finished shepherds_announcement` | examinável `bn_watch_stone` | turno de vigília enquanto Tamir dorme; cena do anúncio (Lc 2:8-15) | `glory_around_shepherds` (fim da cena) |
| 5 | `follow_shepherds` | sobe o caminho e observa a casa de longe | `scene_finished shepherds_at_the_house` | examinável `bn_house_view` | rota pelo mapa; Lc 2:16 e 2:20 vistos de fora | `manger_katalyma` (fim da cena) |
| 6 | `return_to_fire` | volta e conversa com Tamir, acordado | `custom bn_tamir_after` | npc `tamir` | o que os vizinhos contaram (2:17-18); leitura opcional do relato | `shepherds_told` |

**Variedade:** conversa → exploração com condição → coleta + entrega → cena dirigida → rota + cena → conversa.
Pistas (implícita → intermediária → direta) e `log` de cada objetivo estão em `quest.proposal.json`.

**Mecânicas (todas existentes):** examinável com `set_flags` + gatilho `condition` (padrão de `sea_camp_flock`,
ep_016); `pickup` + `take` com `item_delivered` (padrão de `bread_fire`/`bring_sheaves`); `visible_if` por objetivo,
flag e evento; `action` de diálogo para cena e apresentação. Novos só os já previstos para o lote: `scene_finished`,
`observe_scene`, `lighting`.

**Proteção contra trava:** nada fica inacessível. Os pickups de lenha só aparecem durante `kindle_fire` (4 para 3
necessárias). Se o jogador já tiver `dry_wood` de Dotã, ele conta (a entrega tira 3). A ovelha conduzida some do
campo e aparece dentro do aprisco (NPC com `visible_if`). Se o jogo for fechado no meio da cena, `bn_watch_begun` já
está posta e a pedra de vigília repete o gatilho (a cena recria os figurantes).

### Conclusão (cartão)
- Título: **"O que eles ouviram e viram"** (sem tom de vitória).
- Resumo: (1) Lucas 2:8-14 relata que a glória do Senhor brilhou ao redor de pastores que vigiavam à noite e que um
  anjo anunciou o nascimento, em Belém, de um Salvador; uma multidão do exército celestial louvava a Deus.
  (2) Os pastores foram depressa a Belém, encontraram Maria, José e o bebê na manjedoura, contaram o que tinham
  ouvido e voltaram glorificando e louvando a Deus (Lucas 2:15-20). (3) O viajante, Tamir, Shai e o rebanho deles
  são criações do jogo; o número de pastores, a forma da luz e a casa são representação.
- Sem variantes (nenhuma escolha muda o desfecho). `next`: Lucas 2:21 continua com o oitavo dia; fora desta experiência.
- Recompensa: só a flag `kept_night_watch`.

---

## 5. Missões secundárias (curtas)

### 5.1 `bn_fold_round` — "A ronda do aprisco" (Shai, `assist`)
Início: `custom bn_shai_round` (nó noturno de Shai; só existe com `bn_night`). A vigília "de verdade": dar a volta
no muro antes de dormir. Pode ser feita antes ou depois do anúncio (nada fecha).

| id | Texto | `complete_on` | Alvos |
|---|---|---|---|
| `walk_round` | Dê a volta no aprisco: a brecha no muro, os espinhos caídos e o barulho nas rochas. | `condition` flags `bn_round_gap`, `bn_round_thorns`, `bn_round_noise` | examináveis `bn_round_gap`, `bn_round_thorns`, `bn_round_noise` |
| `report_shai` | Conte a Shai o que encontrou. | `custom bn_shai_round_done` | npc `bn_shai` (instância noturna) |

Conteúdo: brecha → recolocar uma pedra solta; espinhos → repor galhos no topo do muro; barulho → um chacal se afasta
ao ver o fogo (sem combate). Shai lembra, como "o que se conta em Belém", que Davi pastoreava ali e defendia o
rebanho (1Sm 16:11; 17:15; 17:34-35) — referência, sem citar fala de Davi. Descoberta `david_shepherd_bethlehem`.
Recompensa: flag `helped_fold_round`.

### 5.2 `bethlehem_night_signs` — "Sinais da vigília" (`investigation`, exploração)
Coleção `bethlehem_night` (5), molde de `caravan_records`/`bethlehem_harvest_signs`: `first_sign` (1),
`three_signs` (3), `all_signs` (completo). Inicia ao entrar na região.

| Examinável | Conteúdo (`historical_context`) |
|---|---|
| `bn_staff` | cajado longo e vara curta de pastor (contexto; sem citar Sl 23, ausente de `verse_counts`) |
| `bn_sling` | funda de couro e pedras lisas (1Sm 17:40) |
| `bn_cloak_bed` | manto grosso de lã estendido como cobertor da noite |
| `bn_oil_lamp` | lamparina de barro "herodiana" num nicho da rocha (séc. I, Judeia) |
| `bn_terraces` | terraços de pedra seca junto à entrada (substitui `bn_herodium_view`: Heródio fora, decisão do coordenador) |

---

## 6. Cenas dirigidas (resumo; passos em `scenes.proposal.json`)

### 6.1 `shepherds_announcement` (Lc 2:8-15), ~70–90 s, pulável
Gatilho: escolha "Ficar de vigia" no nó `watch` do diálogo `bn_watch_stone` (objetivo `night_watch`) → `set_flags
bn_watch_begun` e `action play_scene:shepherds_announcement`.
1. Jogador reposicionado no posto, olhando o aprisco; câmera ao portão (zoom 0,9). Figurantes `rep_a/b/c` sentados
   ao fogo. Legenda de contexto: "Representação: o texto não diz quantos pastores eram." Legenda `Luke 2:8`.
2. `light_glow` cresce **ao redor dos três**, no chão (branco-dourado `#FFF8E0`, raio até ~140 px, sem partículas),
   `tint` clareia. Legenda `Luke 2:9`. Pose de medo (recuam, cobrem o rosto). Contexto: "O jogo mostra só a luz: o
   texto não descreve a aparência do anjo."
3. Legendas `Luke 2:10`, `Luke 2:11`, `Luke 2:12` (texto oficial, uma de cada vez).
4. "De repente": muitas luzes pequenas e sóbrias no céu acima do campo. Legendas `Luke 2:13`, `Luke 2:14`.
5. As luzes sobem e se apagam; a glória diminui; volta o `tint` de noite.
6. Pose de pé; legenda **paráfrase identificada** de 2:15 (os pastores combinam entre si ir a Belém ver o que o
   Senhor lhes fez saber). Os três sobem o caminho **depressa** até sair de cena (remove).
7. Câmera volta ao jogador. Fim: `scene_finished`, `on_end.unlock glory_around_shepherds`.
Sem som de coro com letra; trilha instrumental baixa permitida; fogo e vento leve.

### 6.2 `shepherds_at_the_house` (Lc 2:16-20), ~50–60 s, pulável
Gatilho: escolha "Observar daqui" no nó `follow` de `bn_house_view` (objetivo `follow_shepherds`).
1. Câmera à casa encostada na rocha (sem aproximar além de zoom 1,0). Contexto: "Representação: casa de pedra com
   área de animais. Onde exatamente o bebê estava e o sentido de 'hospedaria' são debatidos."
2. Figurantes sobem os últimos degraus até a porta do pátio; brilho fraco de lamparina na porta; entram (remove).
   Legenda `Luke 2:16`. Nenhum interior, nenhuma figura de Maria, José ou do bebê.
3. Espera (sem acender janelas vizinhas: o texto não diz quem ouviu — revisão V13). Legenda **narração** curta: depois
   de ver, contaram o que lhes fora dito sobre o menino, e todos os que ouviram se admiraram (paráfrase, Lucas 2:17-18).
4. Os três saem e descem o caminho passando pelo jogador, sem interagir. Legenda `Luke 2:20`.
5. Remove ao sair de vista; câmera ao jogador. Fim: `scene_finished`, `on_end.unlock manger_katalyma`.
`Luke 2:19` (Maria) fica só no diário (apresentação), sem imagem nem narração interna.

---

## 7. Personagens (data/characters/bethlehem_night.json)

| id | Papel | Classificação | Notas |
|---|---|---|---|
| `tamir` | pastor mais velho, dono do rebanho | `plausible_fiction` | NPC `tamir` (entardecer e depois da volta); personagem `tamir_asleep` (deitado, manto sobre o corpo; mesmo diálogo `bn_tamir_talk`) no NPC `tamir_asleep` durante a noite |
| `bn_shai` | jovem adulto que trabalha com Tamir | `plausible_fiction` | NPC `bn_shai_dusk` (entardecer, encosta), NPC `bn_shai` (noite, muro do aprisco) |
| `bn_rep_shepherd_a/b/c` | os pastores do relato | `recorded_event` (representação) | túnica e manto de lã, cajado; sem traço de idade marcada; diálogo só de narrador `bn_rep_shepherds` |
| `sheep`, `goat` | rebanho misto, cauda gorda | contexto | `sheep` existe; `goat` proposto também no ep_016 |
| `bn_dog` | cão de pastor | `plausible_fiction` | opcional de arte; sem diálogo |
| figurantes das cenas | `shepherd_rep_figure` (3 variações, poses `sit`, `fear`, `stand`) | — | sprites pequenos; mesmos visuais dos NPCs `bn_rep_*` |

Nomes conferidos: `tamir` e `shai` não colidem com outros pacotes; não têm homônimo bíblico de destaque.

---

## 8. Diálogos (ids e conteúdo; o roteirista escreve as falas)

| id | Dono | Nós (`start_if`) | Conteúdo | Efeitos |
|---|---|---|---|---|
| `bn_tamir_talk` | `tamir`, `tamir_asleep` | `after` (evento `scene_finished shepherds_at_the_house`) · `asleep` (flag `bn_night`) · `deliver` (objetivo `kindle_fire` + `has_item dry_wood` 3) · `wood_waiting` (objetivo `kindle_fire`) · `flock_waiting` (objetivo `gather_flock`) · `hello` | **hello:** o dia acaba, quatro ovelhas se afastaram, o aprisco de pedra e espinhos guarda o rebanho à noite; os vizinhos do portão vigiam o rebanho deles. **deliver:** acende o fogo; combina turnos: ele dorme primeiro, o viajante fica de vigia no posto. **asleep:** narrador: Tamir dorme enrolado no manto. **after:** acordou quando os vizinhos passaram de volta louvando a Deus; eles contavam o que lhes fora dito sobre um menino em Belém (2:17-18, 2:20 como **o que ouviu**, paráfrase com referência); Tamir se admira, não afirma ter visto nada; escolha "Ler o relato (Lucas 2:8-20)" / "Agora não" | hello: `event bn_tamir_hello`, `unlock night_shepherding`. deliver: `take dry_wood x3`, `set_flags bn_night`. after: `event bn_tamir_after`, `unlock shepherds_told`; escolha → `action {"presentation": "luke_002_shepherds"}` |
| `bn_shai_talk` | `bn_shai_dusk`, `bn_shai` | `after_scene` (evento `scene_finished shepherds_announcement`) · `round_done` (objetivo `report_shai`) · `round` (flag `bn_night`) · `hello` | **hello:** ajuda com as ovelhas, onde costumam se esconder (rochas, gruta). **round:** pede a ronda do muro. **round_done:** agradece; lembra Davi pastor em Belém (1Sm 16:11; 17:15; 17:34-35). **after_scene:** viu os vizinhos subirem depressa para Belém e não sabe por quê; não descreve luz nem anjo | round: `event bn_shai_round`. round_done: `event bn_shai_round_done`, `unlock david_shepherd_bethlehem` |
| `bn_rep_shepherds` | `bn_rep_shepherd_a/b/c` | `returned` (evento `scene_finished shepherds_at_the_house`) · `default` | narrador: **default** — três pastores vigiam o próprio rebanho junto ao fogo do portão (representação; o texto não diz quantos eram nem seus nomes). **returned** — de volta ao fogo; Lucas 2:20 por referência. **Nenhuma fala** deles | — |
| `bn_stray_1..4` | examináveis | `default` · `done` | narrador: balido entre as pedras / na boca da gruta / entre arbustos; o viajante conduz a ovelha ao aprisco | `set_flags bn_stray_N`; o 1º também `unlock sheep_goats` (reaproveitada) |
| `bn_watch_stone` | examinável | `after` (evento `scene_finished shepherds_announcement`) · `watch` (objetivo `night_watch`) · `default` | **default:** daqui se vê o aprisco; à noite alguém fica acordado. **watch:** noite, fogo baixo, o rebanho deitado; escolha "Ficar de vigia" / "Ainda não". **after:** o fogo do portão está sozinho; o caminho sobe para Belém | watch/escolha: `set_flags bn_watch_begun`, `action play_scene:shepherds_announcement` |
| `bn_house_view` | examinável | `after` (evento `scene_finished shepherds_at_the_house`) · `follow` (objetivo `follow_shepherds`) · `default` | **default:** a casa encostada na rocha, porta baixa, abertura lateral para animais (hipótese). **follow:** os pastores subiram à frente; escolha "Observar daqui" / "Ainda não". **after:** a luz da porta continua acesa; o que aconteceu lá dentro está em Lucas 2:16-19 | follow/escolha: `action play_scene:shepherds_at_the_house` |
| `bn_house_stairs` | examinável | — | a escada estreita sobe para as casas; o viajante fica embaixo: o que aconteceu lá, o texto conta (Lc 2:16) | — |
| `bn_round_gap`, `bn_round_thorns`, `bn_round_noise` | examináveis | `default` · `done` | brecha (recolocar pedra), espinhos (repor galhos), barulho (chacal se afasta do fogo) | `set_flags` do mesmo id |
| `bn_staff`, `bn_sling`, `bn_cloak_bed`, `bn_oil_lamp`, `bn_herodium_view` | examináveis | — | descrição + `grant_collectible` do mesmo id | `bn_oil_lamp` também `unlock bethlehem_first_century` (se ainda não tiver) |
| `bn_west_path` | examinável | — | o caminho segue para outras aldeias; para outro momento da história, abrir o Mapa (M) | — |

---

## 9. Apresentação do diário `luke_002_shepherds` (nova, `recorded_event`)
Passos com `scripture` (texto oficial) e nota própria: 1) Contexto Lc 2:1-7 (**só nota em paráfrase**; 2:1-3 e 2:5-7
não estão em `bpm.json`); 2) Pastores no campo `Luke 2:8`; 3) A glória `Luke 2:9`; 4) A mensagem `Luke 2:10-12`;
5) A multidão `Luke 2:13-14` (nota: "louvando e dizendo"; variante de 2:14 conforme decisão humana); 6) A decisão
`Luke 2:15`; 7) Em Belém `Luke 2:16`; 8) Contaram `Luke 2:17-18`; 9) Maria guardava `Luke 2:19` (sem comentário de
sentimento); 10) A volta `Luke 2:20`; 11) Sobre esta apresentação (o viajante, Tamir e Shai são fictícios; a luz e
os três pastores são representação; crédito BPM). `unlock: ["shepherds_told"]`.

## 10. Descobertas
Novas (o roteirista escreve; classificação e referências propostas):
- `bethlehem_first_century` (ao entrar, `historical_context`): aldeia da Judeia sob Herodes e Augusto; casas de pátio
  com teto plano; "cidade de Davi"; **sem ano** (seção `chronology`: data debatida). `Luke 1:5`, `Luke 2:1-4`, `1Sam 16:11`.
- `night_shepherding` (`historical_context`): aprisco de pedra seca com espinhos, abertura única, fogueira, turnos,
  predadores, rebanho misto de cauda gorda. `Luke 2:8`, `1Sam 17:34-35`. Seção `interpretation`: a tese dos "pastores
  desprezados" é de fontes posteriores e discutida.
- `glory_around_shepherds` (`recorded_event`): resumo de Lc 2:9-14; seção `fiction`: o jogo mostra só luz, o anjo
  não é descrito; seção `biblical_text`: "louvando e dizendo", não "cantando"; Gabriel não é nomeado aqui.
- `manger_katalyma` (`historical_context` + `interpretation`, **debatido**): manjedoura = cocho; três leituras
  (quarto de hóspedes de uma casa, abrigo de viajantes, gruta — tradição do séc. II); boi e jumento são tradição.
  `Luke 2:7`, `Luke 2:12`, `Luke 10:34`. ("Sala de hóspedes" citada sem referência — referência a importar: Lc 22:11 só depois de `Luke 22` entrar em `verse_counts.json`.)
- `shepherds_told` (`recorded_event`, via Tamir/apresentação): Lc 2:15-20; Maria guardava (2:19), sem fala.
- `david_shepherd_bethlehem` (`recorded_event` + `historical`): Davi pastor em Belém. `1Sam 16:11`, `1Sam 17:15`, `1Sam 17:34-35`.
Reaproveitada: `sheep_goats`.

## 11. Layout do mapa `bethlehem_night` (64×48 tiles, 16 px = 1024×768 px)
```
 tiles x→ 0         10        20        30        40        50       63
 y0   [crista de Belém: casas de pátio, teto plano, poucas janelas]  rocha  · (sem Heródio)
 y7    oliveiras          terraços          CASA NA ROCHA (45,8) porta (44,9) / escada (46,11)=colisão
 y12  ============ muro de terraço (colisão) ============ ponto de observação bn_house_view (39,14)
 y15                                 caminho em zigue-zague ↓
 y24 ENTRADA (2,26)                           \
 y27        [POSTO DE VIGIA] abrigo na rocha (18,28), fogo (19,30), Tamir; pedra de vigília (21,28)
 y31                         \       fogo do portão (32,33) + 3 pastores
 y35   ovelha (10,37)         [  APRISCO  ] (27–37, 35–40)   ovelha (47,32)  rochas/gruta
 y44   arbustos espinhosos  ovelha (22,45)                    ovelha (55,42)    encosta desce a leste
```
Posições exatas em `region.proposal.json`. Distância posto → círculo da glória ≈ 200 px (o viajante fica fora da
luz). Ponto de observação → porta da casa ≈ 130 px. Faixas reservadas sem árvore/pedra: caminho dos figurantes
(portão → casa), círculo da glória (raio 140 px no portão), entrada, todos os alvos.

**Props** (novo = gerador de arte; reaproveitado = já existe): novos `sheepfold_stone` (aprisco de pedra seca com
espinhos e abertura), `rock_shelter` (saliência de rocha), `house_courtyard_rock` (casa de pedra com pátio, encostada
na rocha, abertura lateral de animais), `house_courtyard` (casas de Belém, teto plano), `terrace_wall`, `cave_mouth`,
`thorn_bush`, `cloak_bed`, `oil_lamp_niche`, `herodium_silhouette` (opcional); reaproveitados `firepit`, `firewood`,
`rock_big`, `rock_small`, `tree_olive`, `tree_oak` (terebinto), `bush`, `sheep`. Ícones dos colecionáveis: marcador
`sparkle` até a arte existir. Paleta noturna e anacronismos: `research_historical.md` (sem *Opuntia*, eucalipto,
pinheiro, cerca de madeira, lanterna de metal, estrela, cúpulas).

## 12. O que exige código, dados ou assets (estimativa, 1 pessoa/agente)
| Item | Tipo | Esforço |
|---|---|---|
| Cena dirigida + `scene_finished` + `observe_scene` + `play_scene` | compartilhado do lote | já contado no ep_016/025 |
| Efeito `light_glow` com raio animado (`radius_from/to`, `time`) e vários pontos (`points`, `rise`) para a multidão de luzes | código pequeno (extensão do efeito) | 0,5 dia |
| Extensões do lote usadas aqui: passo `player` (reposicionar), `pose` em `actor`, `on_end` (`set_flags`/`unlock`) | compartilhado | já contado |
| `lighting` por estado + `ambient_effects`/`ambient_sfx` | compartilhado (ep_016) | já contado |
| Região `bethlehem_night` no `build_regions.gd`, bioma `judah_hills` com paleta noturna | gerador + dados | médio, 1–2 dias |
| Arte: props do §11, 5 personagens (tamir, shai, 3 pastores do relato em 3 poses), cabra, cão (opcional) | arte gerada | médio-alto, 2 dias |
| 3 missões, ~12 diálogos, 6 descobertas, 5 colecionáveis, apresentação, 2 cenas | só dados | médio, 1–2 dias |
| Sons: grilos/noite, fogo, balido distante, vento leve (sem coro com letra) | áudio | baixo |
| Nenhum item novo (`dry_wood` reaproveitado) | — | — |
**Total do episódio:** ~4–6 dias, sem contar a infraestrutura comum do lote.

## 13. Divergências e pendências para o coordenador
1. `data/bible/chronology.json` (`shepherds_bethlehem`): −6 a −4 `approximate` × ficha (`debated`, sem ano) → KNOWN_ISSUES (já previsto no relatório do lote). O jogo não exibe ano.
2. A entrada atual em `experiences.json` cita `Luke 2:8-12`; a proposta amplia para `Luke 2:8-20`.
3. `Luke 22`, `Mark 14`, `John 7`, `John 10`, `Mic 5`, `Ps 23` faltam em `verse_counts.json`: o design **não** os usa em dados.
4. Colisão de ids entre pacotes irmãos: `ilan` está nos designs do ep_016 e do ep_025 (personagens diferentes). Este pacote não usa `ilan`.
5. Formato do `action` de cena: a especificação usa a string `play_scene:<id>`; o motor hoje só aceita `action` como dicionário (`{"presentation": id}`) — implementar `{"scene": id}` como equivalente (mesma nota do ep_016).
6. Decisões do coordenador (2026-10-14): nota curta da variante de `Luke 2:14` só no diário; Heródio fora; cão opcional; Tamir só repete, em paráfrase identificada, o que Lc 2:17-18 permite ("Tamir é fictício; Lucas 2:17-18 não diz quem ouviu").
8. Revisões H01–H04 e V09–V16 aplicadas (2026-10-14): subtítulo "Nos dias do rei Herodes (data debatida)" (nada de "Século I" sozinho); "Judeia governada por Herodes, rei aliado de Roma"; falas sem pontos cardeais; aprisco "segundo relatos de pastores da região (costume posterior)"; logs da missão reescritos; certeza `debated` sem ano; cena da casa sem luzes de vizinhos; alvo de `report_shai` = NPC `bn_shai`. A etiqueta da época "Século I" em `data/world/experiences.json` (`first_century`) fica fora deste pacote.
7. Revisita: depois de concluída, o mapa fica em estado de noite (flag `bn_night` persiste); sem `entry_if`.
