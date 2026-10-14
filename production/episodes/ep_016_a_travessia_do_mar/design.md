# Design — ep_016 "A travessia do mar" (experiência `exodus_sea`, época `exodus`)

- **Autor:** agente `quest-designer` (IA). **Status:** `pending_review` — proposta; nada verificado.
- **Base:** `research_biblical.md`, `research_historical.md` (este pacote) e `production/reports/four_experiences_decisions.md`
  (decisões do criador e provisórias do coordenador; especificação da cena dirigida).
- **Arquivos do pacote:** `quest.proposal.json` (1 principal + 2 secundárias), `region.proposal.json` (região nova
  `sea_camp`), `scenes.proposal.json` (cena `exodus_sea_crossing`), `experience.proposal.json` (entrada `exodus_sea`).
- Falas **não** estão escritas: cada diálogo traz id, nós principais e conteúdo esperado (§9). O roteirista escreve.
- **Revisão (2026-10-14, changes_required aplicado):** ids de personagens com prefixo `sea_` e Ilan renomeado para
  **Dror** (`sea_dror`); tamborins fora da cena e do som ambiente, ficando só no diálogo do amanhecer de Shira (E16-01);
  experiência e missão principal exigem `joseph_potiphar_house` (E16-07); textos ao jogador sem pontos cardeais reais
  (H05); grafia "Ramessés" (BPM, Êx 12:37). Ação de cena: `"action": {"scene": "exodus_sea_crossing"}`.

---

## 1. Premissa e papel do jogador

À tarde, o viajante fictício chega a um **acampamento junto ao mar** (local debatido, sem nome de golfo ou lago).
Conhece três famílias fictícias e ajuda em tarefas cotidianas plausíveis: **galhos para o fogo do pão sem
fermento** (Êx 12:34, 39), **animais desgarrados** (Êx 12:38) e **água doce para os odres**. Do alto de uma
elevação vê a **poeira dos carros** no horizonte (Êx 14:9-10). Ao anoitecer junta-se às famílias na beira da água e
**assiste** à cena dirigida (Êx 14:19-22). Corte. **Amanhecer na outra margem**, Êx 14:30-31 citado e uma pausa
em silêncio. Depois, no diálogo com Shira, tamborins ouvidos ao longe (Êx 15:20-21, só referência).

- O viajante **observa e ajuda no cotidiano**; não guia, não escolta, não acalma o povo no lugar de Moisés, não
  segura a coluna, não "abre" nada, não atravessa jogando. A travessia é um corte.
- Agente do milagre no texto: **o SENHOR** (Êx 14:21). Moisés: figura distante com a vara (14:16), mão estendida
  (14:21), sem falas livres. Faraó: sem nome, nunca em cena.
- Nada da cena vira item, ponto, poder ou colecionável (regra 12). Descobertas são registro no diário.

### Decisões aplicadas (do relatório do lote)
| Tema | Aplicação |
|---|---|
| Sobrenatural = cena dirigida no mapa | `scenes.proposal.json`, só assistida, pulável (Esc) |
| Cena cobre 14:19-22 e termina com o povo do outro lado | passos 1–6 da cena; amanhecer com 14:30-31 citado |
| Morte dos egípcios (14:27-28) | só uma legenda de narração curta com referência, na tela escura do corte; sem imagem, sem celebração; não afirma que o faraó morreu |
| Moisés | silhueta distante com vara; gesto de mão estendida; sem falas; 14:13-14 só como paráfrase identificada (na fala de Tzvi, "o que se conta entre as tendas") |
| Nome do mar | "o mar" em todo o jogo; *yam suf* só na descoberta `yam_suf_debate` |
| Êx 15 | fora da cena; tamborins só como narração no diálogo do amanhecer de Shira, com referência (E16-01) |
| Escolta (`pilot.json`) | **divergência**: o jogo segue o criador (sem escolta). Registrar em KNOWN_ISSUES (coordenador) |
| Aviso de conteúdo | não necessário; cena pulável |

---

## 2. Passagem entre épocas (cartão "OUTRO MOMENTO DA HISTÓRIA")

Mesmo mecanismo de `joseph_dothan` (`passage` em `data/world/experiences.json`). Três parágrafos (texto final na
`experience.proposal.json`, revisável pelo roteirista):
1. **Salto:** dos dias de José (Gênesis 37–50) para a saída do Egito (Êxodo 12–14). Êxodo 1:6-8 diz que José e
   toda aquela geração morreram e que surgiu um novo rei que não conhecera José. **Sem número de anos** (Êx 12:40 e
   a datação são debatidos — não citar no cartão).
2. **O que o jogador fará:** uma tarde num acampamento junto ao mar; o lugar exato é debatido; o viajante não guia
   nem muda nada; à noite acompanhará de longe o que Êxodo 14 relata.
3. **Ficção identificada:** o viajante, as famílias e o acampamento são criados para o jogo.

Destino: `travel: {region: sea_camp, entry: arrival}`; se a travessia já aconteceu, entrada `far_shore_dawn`
(campo novo `entry_if`, §12). Requisito: `quest_completed: joseph_potiphar_house` (missão principal do ep_009,
encadeamento pela ordem do lote; revisão E16-07).

---

## 3. Estados do mapa (flags e condições)

Um único mapa; o estado vem de condições já suportadas (`flag`, `not_flag`, `event`+`id`). Os NPCs de cada
estado são instâncias separadas com `visible_if` (padrão `_shore`, `_dawn`).

| Estado | Condição (primeira que valer) | Luz (`CanvasModulate`, proposta) | O que muda |
|---|---|---|---|
| **Amanhecer** (depois) | `{"event": "scene_finished", "id": "exodus_sea_crossing"}` | `#FFE6CC` | margem norte com famílias; margem sul vazia (inacessível); mar calmo (sem tamborins no som ambiente; E16-01) |
| **Noite** | `flag sea_night` e não amanhecer | `#5A6490` | famílias reunidas na beira da água; fogueiras acesas; coluna de **fogo** à frente (sobre a água) |
| **Entardecer** | `flag sea_chariots_seen` | `#F2C8A0` | poeira dos carros no vão do lado do Egito; Tzvi vai para a beira da água |
| **Tarde** (padrão) | — | `#FFF2DC` | acampamento ativo; coluna de **nuvem** à frente |

- `sea_chariots_seen`: posto pelo diálogo `sea_dust_view` (objetivo 4).
- `sea_night`: posto pelo nó noturno de `sea_tzvi_talk` (objetivo 5), **antes** da escolha que inicia a cena. Se o
  jogador recusar ("Ainda não"), o mapa fica à noite e ele pode andar (salvar é permitido fora da cena).
- Amanhecer: a flag automática `ev:scene_finished:exodus_sea_crossing` (todo evento vira flag). Sem código extra.
- **Luz e efeitos persistentes por estado exigem código pequeno** (§12): `lighting` e `ambient_effects` na região.

Abreviações usadas no JSON da região (o JSON traz as condições completas):
`PRE_NIGHT` = `{"not_flag": "sea_night"}`; `NIGHT` = `{"all": [{"flag": "sea_night"}, {"not": DAWN}]}`;
`DAWN` = `{"event": "scene_finished", "id": "exodus_sea_crossing"}`.

---

## 4. Layout do mapa `sea_camp`

**Tamanho:** 64 × 72 tiles de 16 px = **1024 × 1152 px**. Um mapa com **duas margens e o corredor entre elas**,
orientado na vertical (recomendação do revisor histórico: o povo caminha "para cima", e as paredes de água ficam à
**esquerda e à direita**, como em Êx 14:22, sem tampar os personagens na vista 3/4).

```
 y(tile) 0  ┌────────────────────────────────────────────────────────────────┐
            │ dunas baixas e crista de rocha (fecha o mapa)                  │  0–5
            │   abrigos sendo erguidos · jumento · rebanho · famílias (DAWN) │  6–14
            │ ~~~~~~~~~~~~~~ praia norte (entrada far_shore_dawn) ~~~~~~~~~~~ │ 15–17
       18   │≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈║    ║≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈│
            │≈≈≈ MAR (sólido; juncos na água rasa)    ║ ↑↑ ║ corredor só na cena ≈≈│ 18–41
            │≈≈≈≈≈≈≈≈≈≈≈≈≈ coluna "à frente" (35,35) ≈║    ║≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈│  (cols 28–35)
       42   │ praia sul · Moisés (cena) em (32,42) · beira da água (42–55,42–44)  │ 42–44
            │ tendas/abrigos · Shira (O) · fogueira central · Dror + rebanho (L)  │ 45–63
            │ Nava + tripé de odres · Meret · tamareiras e fonte (L) · chegada SE │
       64   │ vão do vale (cols 6–13)  elevação/mirante (18–23)   cristas e dunas │ 64–71
       71   └────────────────────────────────────────────────────────────────┘
```

### Faixas
| Faixa | Tiles (linhas) | px (y) | Conteúdo |
|---|---|---|---|
| Crista norte | 0–5 | 0–95 | dunas baixas e rocha (sem penhascos, sem montanhas) |
| Planície norte | 6–14 | 96–239 | acampamento do amanhecer (só DAWN) |
| Praia norte | 15–17 | 240–287 | areia úmida; entrada `far_shore_dawn` (512, 236) |
| Mar | 18–41 | 288–671 | água profunda **com colisão sempre**; água rasa com juncos nas linhas 18–19 e 40–41 |
| Corredor (visual) | colunas 28–35 | x 448–575 | paredes nas colunas 28–29 e 34–35; chão seco 30–33 (64 px). Só existe durante a cena (`water_walls`); o jogador nunca anda nele |
| Praia sul | 42–44 | 672–719 | beira da água; ponto de reunião noturno |
| Acampamento | 45–63 | 720–1023 | tendas, abrigos, fogueiras, rebanhos |
| Borda sul | 64–71 | 1024–1151 | cristas baixas e dunas; **um único vão** (colunas 6–13, x 96–223) por onde se vê a poeira; mirante nas colunas 18–23 |

A colisão contínua do mar isola as margens: antes da cena o jogador só anda no sul; depois, só no norte. Não há
saídas a pé (o jogador não caminha entre épocas): entra e sai pelo Mapa das Escrituras (§12, retorno).

### Posições (px) — áreas
| id | rect `[x, y, w, h]` | Uso |
|---|---|---|
| `shore_encampment` | `[400, 800, 256, 128]` | objetivo 1 (centro do acampamento, fogueira central) |
| `south_lookout` | `[288, 976, 96, 64]` | rótulo "Elevação junto às cristas" (apoio ao objetivo 4; dá `location_reached`) |
| `shore_gathering` | `[672, 672, 224, 48]` | beira da água onde as famílias se reúnem à noite |
| `far_shore` | `[384, 192, 256, 80]` | margem do outro lado (amanhecer) |

### Posições (px) — NPCs por estado
| Personagem | Tarde/Entardecer (`PRE_NIGHT`) | Noite (`NIGHT`) | Amanhecer (`DAWN`) |
|---|---|---|---|
| Tzvi (idoso) | `tzvi` (560, 836) — só enquanto `not_flag sea_chariots_seen` | `tzvi_shore` (720, 690) — a partir do entardecer | `tzvi_dawn` (600, 204) |
| Shira (mãe, pão) | `shira` (300, 804) | `shira_shore` (770, 700) | `shira_dawn` (448, 184) |
| Beni (criança) | `beni` (334, 836) | `beni_shore` (790, 712) | `beni_dawn` (472, 200) |
| Dror (pastor) | `sea_dror` (760, 806) | `sea_dror_shore` (840, 694) | `sea_dror_dawn` (760, 150) |
| Nava (avó, água) | `nava` (636, 958) | `nava_shore` (690, 704) | `nava_dawn` (300, 150) |
| Meret (multidão mista) | `meret` (452, 930) | — | `meret_dawn` (380, 128) |
| Rebanho | ovelhas/cabras (720–820, 860–910); jumento (850, 880) | — (fora de vista) | ovelhas/cabras (740–820, 120–160); jumento (840, 170) |
| Desgarrados devolvidos | `stray_back_1..3` no rebanho, `visible_if` da flag de cada um | — | — |

Moisés **não** é NPC do mapa: aparece só como figurante da cena (silhueta em (512, 684), na boca do corredor, a
~200 px do ponto de reunião).

### Examináveis e itens
| id | Posição | Prop | Estado | Diálogo / função |
|---|---|---|---|---|
| `sea_dust_view` | (328, 996) | `rock_big` | PRE_NIGHT | "Observar o horizonte" → poeira dos carros; `sea_chariots_seen`; descoberta `sea_pursuit` |
| `sea_bundle` | (282, 816) | novo `kneading_bundle` (provisório `sacks`) | PRE_NIGHT | trouxa com a amassadeira (Êx 12:34) → `unleavened_bread_road` |
| `sea_shelter` | (180, 780) | novo `cloth_shelter` (provisório `tent`) | PRE_NIGHT | abrigos leves; Sucote = "cabanas" (hipótese) |
| `sea_reeds` | (980, 700) | novo `reeds` | PRE_NIGHT | juncos na água rasa → `yam_suf_debate` |
| `sea_seep` | (936, 860) | marcador `sparkle` junto às tamareiras | PRE_NIGHT | "Encher os odres" (missão de Nava) |
| `sea_stray_1` | (120, 1000) | `sparkle` | PRE_NIGHT + missão ativa + flag ausente | "Seguir o balido" (entre rochas, oeste) |
| `sea_stray_2` | (470, 1008) | `sparkle` | idem | atrás da crista, sul |
| `sea_stray_3` | (990, 760) | `sparkle` | idem | entre os juncos, leste |
| `sea_far_view` | (512, 268) | `boundary_stone` | DAWN | "Olhar o mar" → apresentação `exod_014_sea` (leitura opcional) |
| `brushwood_1..3` (pickups) | (160, 900), (560, 1000), (880, 1010) | item novo `brushwood` | PRE_NIGHT | galhos secos de arbusto (objetivo 3) |

### Props visuais (decoração, `build_regions.gd`)
- **Sul:** tendas de pelo de cabra (variante gasta) em (260, 776), (470, 772), (700, 770), (620, 940), (820, 780);
  6–8 abrigos de pano sobre varas, inclinados; fogueira central (528, 848); fogueira pequena com **pedra de assar**
  (320, 812); fogueira (780, 832); tripé com odres (620, 952); jarros e tigelas sem colarinho; trouxas de manto;
  tamargueiras espalhadas; 2 tamareiras (920, 840) e (960, 880) junto à fonte; juncos na água rasa (leste e oeste);
  cristas baixas e dunas na borda sul.
- **Norte (DAWN):** 3 abrigos sendo erguidos (420, 120), (560, 110), (700, 130); trouxas no chão; 1 fogueira
  apagada com fumaça; jumento com cestos; rebanho.
- **Fundo (parallax):** silhuetas de tendas sumindo a leste e oeste (escala do povo sem contador); faixa de poeira
  com 3–5 carros de 8–10 px no vão sul, **só no entardecer**.
- **Evitar** (revisor histórico): camelos, galinhas, cavaleiros montados, poço, casas, forno fixo, cercas de madeira,
  oliveiras, barcos, pirâmides, lua cheia, estandartes, ferro, moedas.

---

## 5. Missão principal — `exodus_sea_crossing` "A travessia do mar" (`story_witness`, `main`)

Início: `experience_started:exodus_sea` (a viagem acontece no mesmo passo). Sem pré-requisito na missão; o
bloqueio fica na experiência (`requires`). Variedade: área → conversa de contexto → coleta + entrega → exploração
com pista ambiental → cena dirigida → conversa ao amanhecer.

| # | id | Texto | `complete_on` | Alvos | Motivo narrativo | Descoberta |
|---|---|---|---|---|---|---|
| 1 | `shore_encampment` | Explore o acampamento junto ao mar. | `location_reached:shore_encampment` | área `shore_encampment` | chegar e ver a escala: tendas sumindo ao longe, rebanhos, famílias (Êx 12:37-38) | — |
| 2 | `camp_elder` | Converse com Tzvi, o mais velho junto à fogueira. | `custom:sea_tzvi_context` | npc `tzvi` | contexto do deslocamento: rodeio pelo deserto (13:17-18), coluna à frente (13:21-22), ossos de José (13:19) | `exodus_departure`, `pillar_cloud_fire`, `joseph_bones` |
| 3 | `bread_fire` | Ajude Shira com o fogo do pão. | `custom:sea_shira_bread` (nó que tira 2 `brushwood`) | npc `shira`; pickup `brushwood_1` | massa sem fermento, amassadeira embrulhada no manto (12:34, 39); lenha escassa na costa | `unleavened_bread_road` |
| 4 | `watch_dust` | Suba a elevação junto às cristas e observe o horizonte. | `discovery:sea_pursuit` | examinável `sea_dust_view` | a poeira dos carros (14:9-10); medo do povo (14:10-12) | `sea_pursuit` |
| 5 | `sea_parted` | Ao anoitecer, junte-se às famílias na beira da água. | `scene_finished:exodus_sea_crossing` **(evento novo)** | npc `tzvi_shore` | a noite: coluna entre os acampamentos, vento, águas como muro (14:19-22) — assistida | `sea_crossing` (na cena), `fear_and_trust` |
| 6 | `dawn_shore` | Ao amanhecer, procure a família de Shira. | `custom:sea_shira_dawn` | npc `shira_dawn` | depois: silêncio, temor e fé (14:30-31); Shira escuta tamborins ao longe (15:20-21, só no diálogo) | `miriam_song` |

### Pistas (implícita → intermediária → direta) e log
1. `shore_encampment` — "Muita gente parou aqui antes do anoitecer." / "As tendas se concentram ao redor de uma
   fogueira no meio do acampamento." / "Da chegada, siga entre as tendas até a fogueira grande, no meio do acampamento."
   Log: "Você chegou a um acampamento junto ao mar: tendas, rebanhos e famílias até onde a vista alcança."
2. `camp_elder` — "Os mais velhos costumam saber de onde o povo veio." / "Um homem idoso está sentado junto à
   fogueira central." / "Converse com Tzvi, ao lado da fogueira no centro do acampamento."
   Log: "Tzvi contou que saíram do Egito e que uma coluna de nuvem vai adiante do povo."
3. `bread_fire` — "Há massa para assar e pouco com que fazer fogo." / "Shira, junto à pedra de assar, precisa de
   galhos secos; há arbustos secos pelo acampamento." / "Pegue dois feixes de galhos secos e leve a Shira, na
   fogueira pequena com a pedra de assar."
   Log: "Você levou galhos a Shira, e o pão sem fermento foi assado na pedra quente."
4. `watch_dust` — "Alguém comentou ter visto algo estranho do lado do Egito." / "Há uma elevação junto às cristas,
   na borda do acampamento oposta ao mar, de onde se vê o caminho por onde o povo veio." / "Suba a elevação junto às
   cristas e examine a rocha para observar o horizonte."
   Log: "Do alto, você viu uma faixa de poeira no horizonte, vindo do lado do Egito."
5. `sea_parted` — "As famílias não ficam nas tendas esta noite." / "Tzvi foi para a beira da água, na frente do
   acampamento." / "Converse com Tzvi na beira da água e escolha ficar com as famílias."
   Log: "Naquela noite, você acompanhou de longe o que Êxodo 14:19-22 relata."
6. `dawn_shore` — "Do outro lado, as famílias recomeçam o dia." / "Shira e Beni estão perto dos abrigos novos, ao
   lado da praia." / "Converse com Shira, entre os abrigos novos, perto de onde você amanheceu."
   Log: "Ao amanhecer, do outro lado do mar, as famílias olhavam a água em silêncio. Ao longe, tamborins."

### Conclusão (cartão)
- Título: **"Do outro lado do mar"** (sem tom de vitória).
- Resumo (3 pontos): (1) Êxodo 14:21-22 relata que o SENHOR fez o mar recuar com um forte vento oriental durante a
  noite toda e que Israel passou em terra seca, com as águas como muro dos dois lados. (2) O texto também relata que
  as águas voltaram ao amanhecer sobre o exército que tinha entrado atrás (14:27-28) e que o povo temeu ao SENHOR e
  creu (14:30-31). (3) As famílias e o acampamento são criações do jogo; o lugar exato do mar e a data são debatidos.
- `next`: "A caminhada pelo deserto continua a partir de Êxodo 15:22. Essa parte está em planejamento."
- Sem recompensa (regra 12).

---

## 6. Missões secundárias (curtas, opcionais)

### `sea_camp_flock` — "Animais desgarrados" (Dror, `assist`)
Início: `custom:sea_dror_flock` (Dror pede ajuda). Referência de contexto: Êx 12:38 (rebanhos saíram com o povo).
| id | Texto | `complete_on` | Alvos |
|---|---|---|---|
| `find_strays` | Encontre os três animais que se afastaram do rebanho. | `condition` `sea_strays_found`: todas as flags `sea_stray_1..3` **ou** amanhecer | examináveis `sea_stray_1..3` |
| `return_dror` | Conte a Dror. | `custom:sea_dror_after` | npc `sea_dror`, npc `sea_dror_dawn` |

Pistas `find_strays`: "Ovelhas fogem do vento para lugares abrigados." / "Escute perto das pedras grandes, atrás da
crista junto à elevação e entre os juncos da beira." / "Procure os brilhos: nas pedras grandes, atrás da crista junto
à elevação e nos juncos perto das tamareiras."
**Proteção contra trava:** depois da cena a margem do acampamento fica inacessível; por isso `find_strays` também se completa no
amanhecer e o desfecho muda por variante (achados pelo jogador × "os vizinhos trouxeram os que faltavam").

### `sea_camp_water` — "Água para a tenda de Nava" (Nava, `assist`)
Início: `custom:sea_nava_water`. A água do mar é salgada; uma fonte salobra junto às tamareiras é ficção plausível.
| id | Texto | `complete_on` | Alvos |
|---|---|---|---|
| `fill_skins` | Encha os odres de Nava na fonte junto às tamareiras. | `condition` `sea_skins_filled`: `item_received:full_water_skins` **ou** amanhecer | examinável `sea_seep` |
| `deliver_water` | Leve os odres a Nava. | `custom:sea_nava_water_done` | npc `nava`, npc `nava_dawn` |

Pistas `fill_skins`: "Onde há palmeiras, costuma haver água por perto." / "Duas tamareiras crescem na ponta do
acampamento, perto dos juncos." / "Vá às tamareiras, além do rebanho, e use a fonte entre elas." Variante por `flag sea_water_delivered`.
O nó do amanhecer de Nava emite `sea_nava_water_done` mesmo sem odres (desfecho "outra família dividiu a água").

O nó noturno de Tzvi avisa (narrador, sem bloquear) se alguma secundária estiver ativa: "depois desta noite o
acampamento não ficará aqui".

---

## 7. Cena dirigida `exodus_sea_crossing` (resumo; dados em `scenes.proposal.json`)

**Gatilho:** escolha "Ficar com as famílias e observar" no nó noturno de `sea_tzvi_talk` (nó `watch`) →
`"action": {"scene": "exodus_sea_crossing"}`. Ao terminar ou pular: evento
`scene_finished:exodus_sea_crossing`.

| Bloco | Passos | Texto na tela |
|---|---|---|
| A. Noite na beira | câmera recua (zoom 0,8) sobre a praia; coluna de fogo à frente, sobre a água | — |
| B. A coluna passa para trás (14:19-20) | `pillar` desloca de (560, 560) para (180, 1010), entre o acampamento e o vão sul; lado sul escurece; poeira some | `Exod 14:19`, `Exod 14:20` (importar) |
| C. Moisés estende a mão (14:21a) | figurante silhueta com vara em (512, 684), pose de mão estendida; **nenhum efeito sai da mão** | `Exod 14:21` (importado) |
| D. Vento a noite toda (14:21b) | `wind` de leste (partículas para oeste, panos e chamas inclinados); 3 fusões de tempo (tint) | narração: "O vento oriental sopra a noite inteira." |
| E. Águas divididas, terra seca (14:21c-22) | `water_walls` abre em 3 etapas de (512, 672) a (512, 288); chão seco | `Exod 14:22` (importado) |
| F. O povo atravessa | 8 figurantes (famílias, idoso, criança, jumento, rebanho) sobem o corredor, devagar, em levas; câmera acompanha | contexto: "(Representação do jogo: o texto não diz quantos eram nem quanto tempo levou.)" |
| G. Corte | tela escura; figurantes e efeitos removidos | narração curta: as águas voltaram ao amanhecer e cobriram o exército que tinha entrado atrás (Êx 14:27-28) — **só texto** |
| H. Amanhecer do outro lado | jogador reposicionado em (512, 236), olhando o mar; luz de amanhecer | `Exod 14:30`, `Exod 14:31` (importar); pausa sóbria em silêncio, só o mar. **Sem tamborins na cena** (E16-01) |

Regras: pulável (Esc → estado final: jogador na margem norte, luz de amanhecer, efeitos desligados, evento
emitido); UI e salvamento bloqueados durante a cena; ao carregar, não repete (a condição `DAWN` já vale). Música
instrumental sóbria, vento e água; sem peixes, raios, aura, estrondo, voz do céu, lua cheia, carros no mar.

---

## 8. Personagens (todos fictícios, `plausible_fiction`; nomes sem homônimo bíblico de destaque)

| id | Papel | Notas |
|---|---|---|
| `tzvi` | idoso, avô de uma família | conta de onde vieram; lembra a servidão (contexto Êx 1:11); à noite, resume como "o que se conta entre as tendas" a palavra de Moisés (Êx 14:13-14, paráfrase identificada) |
| `shira` | mãe; família do pão | amassadeira embrulhada no manto (12:34); pão sem fermento (12:39) |
| `beni` | menino, filho de Shira | pergunta por que a nuvem vai na frente (13:21-22); a resposta não explica o milagre além do texto |
| `sea_dror` (Dror; antes "Ilan") | pastor | rebanho de ovelhas, cabras e um jumento (12:38) |
| `nava` | avó; família da água | medo ao ver a poeira (14:10-12 como sentimento geral, referência, sem citar como fala real) |
| `meret` | mulher em linho de estilo egípcio | ilustra a "multidão mista" (12:38) **sem** afirmar origem; ficção identificada (decisão humana pendente) |
| figurantes da cena | silhuetas | `silhouette_moses_staff` (pose `hand_out`), famílias, idoso, criança, jumento, rebanho |

Bíblicos citados: **Moisés** (`moses`, só silhueta na cena), **Miriã** (`miriam`, só referência 15:20-21), José
(ossos, 13:19). `people.json` hoje não tem `moses` nem `miriam` (ver §12).

---

## 9. Diálogos (ids e conteúdo; o roteirista escreve as falas)

| id | Dono | Nós / `start_if` | Conteúdo | Efeitos |
|---|---|---|---|---|
| `sea_tzvi_talk` | tzvi, tzvi_shore, tzvi_dawn | `dawn` (DAWN) · `night` (flag `sea_chariots_seen`) · `again` (`met_tzvi`) · `greet` | **greet:** de onde vieram (Ramessés→Sucote→Etã, 12:37, 13:20, sem datas); o caminho mais curto evitado (13:17-18, sem estratégia além do texto); a coluna à frente (13:21-22); os ossos de José (13:19; Gn 50:25) como "o que se sabe". **night:** medo do povo; paráfrase identificada de 14:13-14; aviso das secundárias abertas; escolha "Ficar com as famílias e observar" / "Ainda não". **dawn:** silêncio, "o povo temeu ao SENHOR e creu" como referência (14:31), sem celebrar | greet: `set_flags met_tzvi`, `event sea_tzvi_context`, `unlock exodus_departure, pillar_cloud_fire, joseph_bones`. night: `set_flags sea_night` (no 1º nó); escolha → `action {"scene": "exodus_sea_crossing"}`, `unlock fear_and_trust` |
| `sea_shira_talk` | shira, shira_shore, shira_dawn | `dawn` · `deliver` (`has_item brushwood` count 2 e objetivo `bread_fire`) · `waiting` · `greet` | pede galhos; massa ainda sem fermento, saíram às pressas (12:34, 39); entrega; à noite cuida das crianças; **dawn:** olha o mar; ao longe, entre as tendas, ouvem-se tamborins e Shira só escuta (o narrador cita 15:20-21) | greet: `event sea_shira_bread_ask`; deliver: `take brushwood x2`, `event sea_shira_bread`, `unlock unleavened_bread_road`; dawn: `event sea_shira_dawn`, `unlock miriam_song` |
| `sea_beni_talk` | beni, beni_shore, beni_dawn | por estado | pergunta sobre a nuvem/fogo; à noite, com medo do vento; ao amanhecer, quieto | — |
| `sea_dror_talk` | sea_dror, sea_dror_shore, sea_dror_dawn | `after_found` / `after_neighbors` (objetivo `return_dror` + flags) · `waiting` · `greet` | animais que fogem do vento; pede ajuda; desfechos | greet: `event sea_dror_flock`; after: `event sea_dror_after` |
| `sea_nava_talk` | nava, nava_shore, nava_dawn | `deliver` (`has_item full_water_skins`) · `dawn_no_water` · `waiting` · `greet` | odres vazios, mar salgado; medo da poeira (14:10-12, sentimento); entrega | greet: `event sea_nava_water`; deliver: `take full_water_skins`, `set_flags sea_water_delivered`, `event sea_nava_water_done`; dawn_no_water: `event sea_nava_water_done` |
| `sea_meret_talk` | meret, meret_dawn | por estado | seguiu o povo; não detalha origem (12:38); ao amanhecer, gratidão pela vida | `unlock exodus_departure` |
| `sea_dust_view` | examinável | — | narrador: faixa de poeira, pontos escuros, um reflexo; o texto diz que os egípcios alcançaram o acampamento junto ao mar (14:9-10); faraó sem nome | `set_flags sea_chariots_seen`, `unlock sea_pursuit` |
| `sea_bundle` | examinável | — | trouxa de manto com amassadeira (12:34) | `unlock unleavened_bread_road` |
| `sea_shelter` | examinável | — | abrigos leves; "Sucote" ligado a cabanas (hipótese, Lv 23:42-43) | — |
| `sea_reeds` | examinável | — | juncos na água rasa; o nome hebraico do mar e o local são debatidos | `unlock yam_suf_debate` |
| `sea_seep` | examinável | `fill` (objetivo `fill_skins` ativo) · `default` | água salobra mas bebível junto às tamareiras (ficção) | fill: `give full_water_skins x1` |
| `sea_stray_1..3` | examináveis | — | balido; o animal volta ao rebanho | `set_flags sea_stray_N` |
| `sea_far_view` | examinável | — | o mar calmo ao amanhecer; abrir o diário | `action {"presentation": "exod_014_sea"}` |

**Apresentação `exod_014_sea`** (leitura opcional, também pelo diário; não é objetivo): 14:1-2 (acampar junto ao
mar), 14:9-10, 14:13-14, 14:19-20, 14:21, 14:22, 14:27-28 (só texto), 14:30-31, nota sobre 15:20-21, nota final
(ficção identificada, local e data debatidos, crédito da tradução). `unlock: ["sea_crossing"]`.

---

## 10. Descobertas novas (`data/bible/discoveries.json`)

| id | Título provisório | Classificação | Referências | Liberada por |
|---|---|---|---|---|
| `exodus_departure` | Quem saiu do Egito | `recorded_event` + seções `historical`/`interpretation` (número debatido, *'elef*) | Exod 12:37-38 | Tzvi, Meret |
| `pillar_cloud_fire` | A coluna de nuvem e de fogo | `recorded_event` | Exod 13:21-22; 14:19-20 | Tzvi |
| `joseph_bones` | Os ossos de José | `recorded_event` (liga ep_008/009) | Exod 13:19; Gen 50:24-25 | Tzvi |
| `unleavened_bread_road` | Pão sem fermento na estrada | `historical_context` | Exod 12:34, 39 | Shira, trouxa |
| `sea_pursuit` | Os carros do Egito | `recorded_event` + `historical` (carro leve, 2 cavalos; faraó sem nome; sem data) | Exod 14:5-10 | `sea_dust_view` |
| `yam_suf_debate` | Que mar era esse? | `historical_context` + `interpretation` (juncos × Mar Vermelho × lagos; nenhuma consensual) | Exod 13:18; 15:4 | `sea_reeds` |
| `sea_crossing` | A travessia do mar | `recorded_event` | Exod 14:19-22, 29 | fim da cena / apresentação |
| `fear_and_trust` | Medo e confiança | `devotional_educational` | Exod 14:10-14, 31 | Tzvi (noite) |
| `miriam_song` | O cântico e os tamborins | `recorded_event` (só referência, sem letra) | Exod 15:1, 20-21 | Shira (amanhecer) |

---

## 11. Mapeamento com o catálogo-semente
| Semente | Aqui |
|---|---|
| `obj_01` visit_area `shore_encampment` | objetivo `shore_encampment` (área real com o mesmo id) |
| `obj_02` talk_npc `fictional_traveler_exodus` | objetivo `camp_elder`, NPC `tzvi` |
| `obj_03` observe_scene `sea_parted` | objetivo `sea_parted`, cena `exodus_sea_crossing`, evento `scene_finished` |

---

## 12. O que exige trabalho novo (estimativas para 1 pessoa/agente)

### Código
| Item | Esforço | Observação |
|---|---|---|
| Cena dirigida (leitor de `data/scenes`, passos, Esc, bloqueio de UI/save, evento `scene_finished`, tipo `observe_scene`, `action {"scene": id}`) | alto, 2–3 dias | compartilhado com ep_048 e ep_009; ADR |
| Efeitos `pillar` (com `move` de/para e `shade_behind`), `wind`, `water_walls` (abertura em etapas, corredor vertical), `dust`, `light_glow` | médio-alto, 1–2 dias | `water_walls` é o mais caro |
| Extensões propostas à especificação: passo `player` (reposicionar jogador), `pose` em `actor`, `final_state` para o Esc | baixo, 0,5 dia | ver `scenes.proposal.json` |
| Luz e efeitos/sons por estado na região (`lighting`, `ambient_effects`, `ambient_sfx` com `if`) | baixo-médio, 0,5 dia | reavaliar em `flag_changed` (como `visible_if`) |
| `travel.entry_if` na experiência | baixo, 1–2 h | reentrada depois da travessia |
| Retorno de `sea_camp` | dados | acrescentar `travel` a `isaac_wells` (→ `canaan_village`) e `joseph_dothan` (→ `dothan`); `start_experience` já viaja para experiências concluídas |

### Dados (só JSON)
- Região `sea_camp` (`data/regions/sea_camp.json`), personagens (`data/characters/sea_camp.json`: tzvi, shira,
  beni, dror, nava, meret com prefixo `sea_`, goat, donkey + silhuetas), ~15 diálogos, 3 missões, 9 descobertas, apresentação
  `exod_014_sea`, cena `data/scenes/exodus_sea_crossing.json`.
- Itens novos: `brushwood` (galhos secos de arbusto, `max_stack` ≥ 3) e `full_water_skins` (odres cheios de Nava,
  item de missão). Não reaproveitar `water_skin` (max_stack 1; o jogador pode já ter um de Dotã).
- Lugar novo `exodus_sea` em `places.json`: "O mar (localização debatida)", `identification: debated`, sem
  coordenadas. Pessoas novas `moses` e `miriam` em `people.json`.
- `verse_counts.json`: acrescentar `Exod 12` (51), `Exod 13` (22), `Exod 15` (27), `Gen 50` (26) (KI-11).
- Importar para `bpm.json`: Exod 1:6-8, 12:34, 12:37-39, 13:17-22, 14:1-2, 14:9-14, 14:19-20, 14:27-31, 15:20-21,
  Gen 50:24-25 (14:21-22 já existem).
- Sons novos no manifesto: vento forte contínuo, mar/ondas calmas, fogueira. Sem som de tamborins (E16-01: ficam só
  como narração no diálogo do amanhecer).

### Arte (`visual-asset-producer`; detalhes no revisor histórico)
- Bioma novo "costa desértica": areia seca/úmida (autotile), água rasa animada, mar, **terra seca do leito**, **muro
  de água** (topo/face/base, esquerda/direita, animado).
- Props: tamargueira, juncos, tamareira, abrigo de pano, tenda gasta, fogueira pequena com pedra de assar, tripé de
  odres, trouxa com amassadeira, crista rochosa baixa, dunas. Sprites: 6 moradores, cabra, jumento com cestos,
  silhuetas da cena (Moisés com vara em 2 poses, famílias, rebanho), carros de fundo (8–10 px).
- Esforço: alto, 2–3 dias (mapa por `build_regions.gd` + gerador de arte).

**Total estimado do episódio:** 6–9 dias, dos quais ~3 são infraestrutura reutilizável (cena dirigida e efeitos).

---

## 13. Pendências para revisão humana
1. **Coluna no amanhecer**: proposta = discreta, longe, à frente (Êx 13:22: não se afastava). Alternativa: omitir.
2. **Meret** (roupa de linho egípcia, multidão mista) como ficção identificada.
3. **Altura das paredes** (4 tiles de face, > adulto) e **largura do corredor** (4 tiles): convenção de jogo.
4. Citar **14:30 inteiro** (inclui "viu os egípcios mortos na praia") como texto, sem imagem — proposta atual; ou
   citar só 14:30a e 14:31.
5. ~~Requisito da experiência~~ resolvido na revisão (E16-07): `joseph_potiphar_house`.
6. Desfecho automático das secundárias no amanhecer (evita trava; muda só a ficção).
7. `pilot.json` (escolta/organizar "na travessia") diverge da decisão do criador → KNOWN_ISSUES.
8. Pré-requisitos bíblicos: importações BPM e `verse_counts` antes de qualquer citação além de 14:21-22.
