# Ficha bíblica — ep_016_a_travessia_do_mar · "A travessia do mar"

- **Episódio:** `ep_016_a_travessia_do_mar` (entrada em `production/catalog/episodes.json`: modo `observacao_contextual`; objetivo de aprendizagem "Libertação e travessia"; contexto "Caminho do Êxodo (representação)"; `region` vazio; `estimate.new_map_needed: true`, `difficulty: high`).
- **Objetivos-semente do catálogo:** `obj_01` visit_area `shore_encampment` ("Explorar o acampamento"); `obj_02` talk_npc `fictional_traveler_exodus` ("Conhecer o contexto do deslocamento", `data_only`); `obj_03` observe_scene `sea_parted` ("Acompanhar a abertura do mar atribuída a Deus", `partial`). Todos `target_state: placeholder`.
- **Decisão do criador (entrada desta ficha):** o viajante fictício vive o **antes** e o **depois** no acampamento junto ao mar; o milagre aparece como **cena visual dirigida no mapa** (o mar se abrindo, o povo atravessando) que o jogador **apenas assiste**, sem controlar nem causar nada; o texto bíblico citado acompanha a cena.
- **Trecho central:** `Exod 14:1-31`. **Contexto anterior:** `Exod 13:17-22` (rota e coluna de nuvem/fogo), `Exod 12:37-38` (quem saiu: povo, crianças, multidão mista, rebanhos). **Consequência (só referência, ver §1.3):** `Exod 15:1-21` (cântico de Moisés e de Miriã). **Paralelos internos:** `Num 33:5-8` (itinerário), `Heb 11:29` (eco no NT). **Ligação com episódios de José:** `Exod 13:19` ↔ `Gen 50:24-25` (os ossos de José).
- **Autor:** agente `biblical-researcher` (IA). **Status:** `pending_review` — nada aqui está verificado; exige revisão humana.
- **Texto bíblico usado:** Bíblia Portuguesa Mundial (BPM, domínio público, eBible.org `porbrbsl`), lida no arquivo oficial `C:\TEMP\biblia\porbrbsl\porbrbsl_vpl.txt` (linhas `EXO 12`–`15`, `NUM 33`, `GEN 50`, `HEB 11`, `1KI 6`) e comparada com `data/bible/texts/bpm.json`, que hoje só contém `Exod 14:21` e `Exod 14:22` deste episódio. Os resumos abaixo são **paráfrase própria**; palavras curtas entre aspas são marcadores da BPM para a revisão, **não** citação para o jogo.
- **Dados existentes consultados (só para apontar sobreposição):** `data/bible/stories/pilot.json` (`exod_014_red_sea`), `data/world/experiences.json` (`exodus_sea`).

---

## 1. Referências (conferidas)

Livro `Exod` existe em `data/bible/books.json` (40 capítulos). `data/bible/verse_counts.json` traz `Exod 14` = 31 (bate com o VPL oficial). **Não traz** `Exod 12`, `Exod 13`, `Exod 15`, `Num 33`, `Gen 50` (mesma lacuna da KI-11); contagens no VPL oficial: `Exod 12` = 51, `Exod 13` = 22, `Exod 15` = 27, `Num 33` = 56, `Gen 50` = 26. `Heb 11` = 40 e `1Kgs 6` = 38 já estão no arquivo.

### 1.1 Referências por trecho

| Ref. | Trecho | No VPL oficial? | Em `bpm.json`? |
|---|---|---|---|
| `Exod 12:37-38` | Saída de Ramessés a Sucote; homens a pé, crianças, multidão mista, ovelhas, bois, muitos animais | Sim | **Não** |
| `Exod 13:17-18` | Deus não guia pelo caminho dos filisteus; rodeio pelo deserto, "perto do Mar Vermelho" (BPM) | Sim | **Não** |
| `Exod 13:19` | Moisés leva os ossos de José | Sim | **Não** |
| `Exod 13:20` | De Sucote a Etã, na beira do deserto | Sim | **Não** |
| `Exod 13:21-22` | O SENHOR vai adiante: coluna de nuvem de dia, de fogo de noite; não se afastam do povo | Sim | **Não** |
| `Exod 14:1-4` | Ordem de voltar e acampar junto ao mar (Pi-Hairote, Migdol, Baal-Zefom); propósito anunciado | Sim | **Não** |
| `Exod 14:5-9` | Faraó muda de ideia e persegue com carros e exército; alcança o acampamento junto ao mar | Sim | **Não** |
| `Exod 14:10-12` | Medo do povo; clamor ao SENHOR; queixa contra Moisés | Sim | **Não** |
| `Exod 14:13-14` | Moisés: não temer, ficar firme, ver a salvação do SENHOR | Sim | **Não** |
| `Exod 14:15-18` | O SENHOR manda marchar; Moisés deve levantar a vara e estender a mão | Sim | **Não** |
| `Exod 14:19-20` | Anjo de Deus e coluna de nuvem passam para trás, entre os acampamentos, a noite toda | Sim | **Não** |
| `Exod 14:21` | Moisés estende a mão; vento oriental forte a noite toda; terra seca; águas divididas | Sim | **Sim** |
| `Exod 14:22` | Israel entra em terra seca; águas como muro à direita e à esquerda | Sim | **Sim** |
| `Exod 14:23-25` | Egípcios entram atrás; vigília da manhã; confusão; rodas dos carros | Sim | **Não** |
| `Exod 14:26-28` | Moisés estende a mão; o mar volta ao amanhecer; o exército que entrou é coberto | Sim | **Não** |
| `Exod 14:29` | Israel caminhou em terra seca; águas como muro (repetição de 14:22) | Sim | **Não** |
| `Exod 14:30-31` | O SENHOR salva Israel; Israel vê os egípcios mortos na praia; o povo teme e crê | Sim | **Não** |
| `Exod 15:1-18` | Cântico de Moisés e dos filhos de Israel | Sim | **Não** |
| `Exod 15:19` | Resumo em prosa da travessia | Sim | **Não** |
| `Exod 15:20-21` | Miriã, a profetisa, com tamborim; as mulheres dançam; refrão | Sim | **Não** |
| `Num 33:5-8` | Itinerário: Ramessés, Sucote, Etã, Pi-Hairote, travessia, Mara | Sim | **Não** |
| `Gen 50:24-25` | José faz jurar que levarão seus ossos | Sim | **Não** |
| `Heb 11:29` | "Pela fé" passaram o mar como em terra seca | Sim | **Não** |
| `1Kgs 6:1` | "480º ano" após a saída do Egito (base de um dos modelos de datação) | Sim | **Não** |

Qualquer citação literal no jogo além de `Exod 14:21-22` exige importar o texto antes (`tools/import_scripture.gd`) e, para `Exod 13`/`15`, acrescentar os capítulos a `verse_counts.json`.

### 1.2 Recorte recomendado para a cena dirigida
- **Núcleo citado durante a cena:** `Exod 14:19-20`, `14:21`, `14:22` (os dois últimos já importados), `14:29` opcional como fecho.
- **Antes (acampamento):** `Exod 13:21-22`, `14:9-10`, `14:13-14` (paráfrase de Moisés, ver §3).
- **Depois (acampamento do outro lado):** `Exod 14:30-31`.
- **Fora da cena (não mostrar):** `Exod 14:23-28` em detalhe; ver §8.

### 1.3 Avaliação: `Exod 15:1-21` entra?
Recomendação: **só como referência e eco**, não como cena nem como letra cantada.
- O cântico (`15:1-18`) é **poesia** com imagens próprias ("sopro das tuas narinas", águas "como um monte", "a terra os engoliu" em `15:12`) que **não** devem ser misturadas à descrição narrativa da cena (risco de acrescentar detalhes ao cap. 14).
- É conteúdo de louvor centrado na derrota dos egípcios (`15:1`, `15:4-5`, `15:10`); musicá-lo ou exibi-lo inteiro aumenta o peso da morte para público amplo.
- `15:20-21` (Miriã e as mulheres com tamborins) é um ótimo **ponto de gratidão no "depois"**: moradores fictícios podem estar **ouvindo à distância** sons de tamborins e cânticos, com nota "o texto registra que Miriã e as mulheres cantaram e dançaram (`Exod 15:20-21`)". Miriã não fala além do refrão registrado; não inventar letra.
- Cantar o refrão com voz/melodia é decisão do criador (ver §10).

---

## 2. Resumo do relato, trecho a trecho (paráfrase própria)

### Contexto: `Exod 12:37-38` — quem saiu
- Os israelitas viajam de Ramessés a Sucote, um número muito grande de homens a pé, **além das crianças** (`Exod 12:37`).
- Com eles sobe também uma **multidão mista**, com ovelhas, bois e muitíssimos animais (`Exod 12:38`).

### Contexto: `Exod 13:17-22` — a rota e a coluna
- Quando o Faraó deixa o povo ir, Deus não os guia pelo caminho mais curto, o da terra dos filisteus, para que o povo não desanime diante de guerra e volte ao Egito (`Exod 13:17`).
- Deus os faz rodear pelo caminho do deserto, em direção ao mar (a BPM traduz "Mar Vermelho", ver §6); os israelitas saem "armados" ou em ordem — termo de tradução discutida (`Exod 13:18`).
- Moisés leva os ossos de José, cumprindo o juramento (`Exod 13:19`; `Gen 50:25`).
- Partem de Sucote e acampam em Etã, na beira do deserto (`Exod 13:20`).
- O SENHOR vai adiante deles: de dia numa coluna de nuvem para guiar, de noite numa coluna de fogo para iluminar, de modo que possam andar dia e noite; as colunas não se afastam do povo (`Exod 13:21-22`).

### `Exod 14:1-4` — O acampamento junto ao mar
- O SENHOR manda Moisés dizer ao povo que volte e acampe diante de Pi-Hairote, entre Migdol e o mar, diante de Baal-Zefom, junto ao mar (`Exod 14:1-2`).
- O SENHOR anuncia o que o Faraó vai pensar (que estão perdidos, presos pelo deserto), que endurecerá o coração do Faraó, que ele os perseguirá e que o SENHOR será glorificado e os egípcios saberão que ele é o SENHOR. O povo obedece (`Exod 14:3-4`).

### `Exod 14:5-9` — A perseguição
- Contam ao rei do Egito que o povo fugiu; ele e seus servos mudam de ideia por terem perdido os que os serviam (`Exod 14:5`).
- O Faraó prepara seu carro e leva o exército: seiscentos carros escolhidos e todos os carros do Egito, com oficiais (`Exod 14:6-7`).
- O SENHOR endurece o coração do Faraó, que persegue os israelitas, que tinham saído "com mão erguida" (`Exod 14:8`).
- Os egípcios — cavalos, carros, cavaleiros e exército — os alcançam acampados junto ao mar, perto de Pi-Hairote (`Exod 14:9`).

### `Exod 14:10-14` — Medo e palavra de Moisés
- Ao verem os egípcios chegando, os israelitas ficam com muito medo e clamam ao SENHOR (`Exod 14:10`).
- Queixam-se a Moisés: perguntam se ele os trouxe para morrer no deserto e dizem que teria sido melhor continuar servindo aos egípcios (`Exod 14:11-12`).
- Moisés diz ao povo que não tenha medo, que fique firme e veja a salvação que o SENHOR fará naquele dia; que os egípcios vistos naquele dia não seriam vistos de novo; que o SENHOR lutaria por eles e eles ficariam quietos (`Exod 14:13-14`).

### `Exod 14:15-18` — A ordem
- O SENHOR pergunta a Moisés por que clama e manda dizer ao povo que marche (`Exod 14:15`).
- Manda Moisés levantar a vara, estender a mão sobre o mar e dividi-lo, para que o povo entre em terra seca (`Exod 14:16`).
- Repete que endurecerá o coração dos egípcios, que entrarão atrás, e que será glorificado sobre o Faraó e seu exército (`Exod 14:17-18`).

### `Exod 14:19-20` — A nuvem entre os acampamentos
- O anjo de Deus, que ia à frente do acampamento de Israel, passa para trás; a coluna de nuvem também sai da frente e se coloca atrás (`Exod 14:19`).
- Ela fica entre o acampamento do Egito e o de Israel; havia nuvem e escuridão, e ela iluminava a noite; um não se aproxima do outro a noite toda (`Exod 14:20`). **Nota:** a frase sobre escuridão/luz é de tradução e interpretação discutidas (para quem era escuridão e para quem luz o texto não detalha); não decidir na arte além do que o texto diz.

### `Exod 14:21-22` — A abertura do mar
- Moisés estende a mão sobre o mar; o **SENHOR** faz o mar recuar com um **forte vento oriental durante toda a noite**, torna o mar em terra seca, e as águas se dividem (`Exod 14:21`).
- Os israelitas entram pelo meio do mar em terra seca; as águas são **como um muro** à direita e à esquerda (`Exod 14:22`).

### `Exod 14:23-25` — Os egípcios entram
- Os egípcios perseguem e entram atrás até o meio do mar, com cavalos, carros e cavaleiros (`Exod 14:23`).
- Na vigília da manhã, o SENHOR olha para o exército egípcio a partir da coluna de fogo e de nuvem e lança o exército em confusão (`Exod 14:24`).
- Faz as rodas dos carros saírem (ou emperrarem — tradução discutida) e eles conduzem com dificuldade; os egípcios dizem que vão fugir, porque o SENHOR luta por Israel (`Exod 14:25`).

### `Exod 14:26-28` — As águas voltam
- O SENHOR manda Moisés estender a mão para que as águas voltem sobre os egípcios (`Exod 14:26`).
- Moisés estende a mão; ao amanhecer o mar volta à sua força; os egípcios fogem de encontro a ele, e o SENHOR os lança no meio do mar (`Exod 14:27`).
- As águas cobrem carros, cavaleiros e todo o exército que tinha entrado atrás; não sobra nenhum deles (`Exod 14:28`).

### `Exod 14:29-31` — O resultado
- Os israelitas tinham caminhado em terra seca pelo meio do mar, com as águas como muro dos dois lados (`Exod 14:29`).
- Assim o SENHOR salva Israel naquele dia; Israel vê os egípcios mortos na praia (`Exod 14:30`).
- Israel vê a grande obra do SENHOR; o povo teme ao SENHOR e crê no SENHOR e em Moisés, seu servo (`Exod 14:31`).

### Consequência (só referência): `Exod 15:1-21`
- Moisés e os israelitas cantam ao SENHOR um cântico de vitória (`Exod 15:1-18`); um resumo em prosa repete a travessia (`Exod 15:19`); Miriã, a profetisa, irmã de Arão, pega um tamborim, as mulheres saem atrás dela com tamborins e danças, e ela entoa o refrão (`Exod 15:20-21`).

---

## 3. Personagens bíblicos (apenas o que o texto diz)

| Personagem | O que o texto registra | Refs. |
|---|---|---|
| **O SENHOR / Deus** | Guia na coluna; dá as ordens; endurece o coração do Faraó; faz o mar recuar pelo vento; confunde o exército; salva Israel. **Agente do milagre no texto.** | `Exod 13:17-18`, `13:21-22`; `14:1-4`, `14:15-18`, `14:21`, `14:24-25`, `14:27`, `14:30` |
| **Anjo de Deus** | Ia à frente do acampamento e passa para trás (`14:19`). Sem descrição física nem fala. | `Exod 14:19` |
| **Moisés** | Leva os ossos de José; transmite as ordens; fala ao povo (`14:13-14`); estende a mão sobre o mar duas vezes (`14:21`, `14:27`); o povo crê nele (`14:31`); canta (`15:1`). O texto menciona a **vara** na ordem (`14:16`), mas na execução diz só que "estendeu a mão" (`14:21`, `14:27`). | `Exod 13:19`; `14:1`, `14:11-16`, `14:21`, `14:26-27`, `14:31`; `15:1` |
| **Faraó / rei do Egito** | **Não é nomeado.** Muda de ideia com seus servos; prepara o carro; leva o exército; persegue; seu coração é endurecido pelo SENHOR. O texto **não** diz que o Faraó entrou no mar nem que morreu (ver §8). | `Exod 14:3-10`, `14:17-18`, `14:23`, `14:28` |
| **Servos do Faraó** | Mudam de ideia junto com ele (`14:5`). | `Exod 14:5` |
| **Exército egípcio** | 600 carros escolhidos e todos os carros do Egito, oficiais, cavalos, cavaleiros; entram atrás; confusão; querem fugir; são cobertos pelas águas; vistos mortos na praia. | `Exod 14:6-9`, `14:23-28`, `14:30` |
| **Os filhos de Israel / o povo** | Acampam; têm muito medo; clamam; queixam-se a Moisés; marcham; atravessam em terra seca; veem; temem ao SENHOR e creem. | `Exod 14:2`, `14:10-12`, `14:22`, `14:29-31` |
| **Multidão mista; crianças; rebanhos** | Saíram com Israel (`12:37-38`). **Não são mencionados de novo em `Exod 14`** — a presença deles no acampamento é inferência a partir de `12:37-38`. | `Exod 12:37-38` |
| **Miriã** | "A profetisa, irmã de Arão"; pega um tamborim; as mulheres a seguem; entoa o refrão. Só em `15:20-21`. | `Exod 15:20-21` |
| **Arão** | Só citado como irmão de Miriã (`15:20`); **não age em `Exod 14`**. Não pôr Arão na cena. | `Exod 15:20` |
| **José** | Só seus ossos (`13:19`). | `Exod 13:19`; `Gen 50:25` |

**Falas registradas (discurso direto) no trecho, para paráfrase identificada:**
- O SENHOR a Moisés: `14:2-4`, `14:15-18`, `14:26`.
- O Faraó (fala **prevista** pelo SENHOR, não pronunciada em cena): `14:3`.
- Faraó e servos: "o que fizemos, deixando Israel ir" (`14:5`).
- O povo a Moisés: queixa (`14:11-12`).
- Moisés ao povo: "não tenham medo… o SENHOR lutará por vocês" (`14:13-14`).
- Os egípcios entre si: "fujamos… o SENHOR luta por eles" (`14:25`).
- Moisés e o povo: cântico (`15:1-18`); Miriã: refrão (`15:21`).

**Regra de uso:** Moisés e o Faraó **nunca** recebem fala livre. Se aparecerem, é por paráfrase marcada com referência (ex.: "Moisés diz ao povo que não tenha medo e veja a salvação do SENHOR — Êx 14:13-14") ou por citação literal da BPM importada. **Sem falas no texto:** anjo, servos (exceto `14:5` coletivo), crianças, idosos, multidão mista, Arão.

---

## 4. Gênero literário
**Narrativa** em prosa (`Exod 13:17–14:31`) com relato de **milagre/teofania** (coluna de nuvem e fogo, anjo, abertura do mar), seguida de **poesia** hínica (`Exod 15:1-18`, cântico de vitória) e uma moldura narrativa curta com Miriã (`15:19-21`). A prosa e a poesia descrevem o mesmo evento com linguagem diferente: o jogo deve basear a cena **na prosa do cap. 14** e não importar imagens poéticas do cap. 15 como se fossem descrição literal. Não é parábola nem apocalíptico.

---

## 5. Linha do tempo

| Marco | Apoio no texto | `chronology_confidence` |
|---|---|---|
| Época do Êxodo (data absoluta) | A Bíblia não dá ano civil; `1Kgs 6:1` ("480º ano" até o templo) sustenta um modelo de data mais antiga; outros estudiosos propõem data mais recente (ligada a `Exod 1:11`, Ramsés) ou questionam a historicidade/escala. | `debated` — **não dar ano, século nem nome de Faraó**; usar `null` |
| Saída de Ramessés → Sucote → Etã → junto ao mar | Ordem do texto (`Exod 12:37`, `13:20`, `14:2`; `Num 33:5-7`) | `documented` (ordem relativa) |
| Tempo entre a saída e a travessia | Não informado com precisão; o texto só dá as etapas | `unknown` (não dizer "três dias", "uma semana" etc.) |
| A noite da travessia | Coluna entre os acampamentos "a noite toda" (`14:20`); vento "a noite toda" (`14:21`) | `documented` (relativo: uma noite) |
| Confusão dos egípcios | "Vigília da manhã" (`14:24`) | `documented` (relativo) |
| Volta das águas | "Ao amanhecer" (`14:27`) | `documented` (relativo) |
| Depois: cântico; três dias até Mara | `Exod 15:1`, `15:22-23`; `Num 33:8` | `documented` (relativo; fora do escopo) |

**Sugestão para o catálogo:** trocar `chronology_confidence: not_established` por `debated` (época), com marcos internos `documented` (uma noite; vigília da manhã; amanhecer). `pilot.json` usa `certainty: approximate_debated` — alinhar com o vocabulário oficial (`debated`).

---

## 6. Três colunas: texto × inferência/hipótese × ficção do jogo

| O que o texto diz | Inferência ou hipótese histórica | O que seria ficção do jogo |
|---|---|---|
| O mar é chamado, em hebraico, *yam suf*; a BPM traduz "Mar Vermelho" (`Exod 13:18`; `15:4`, `15:22`); em `Exod 14` diz só "o mar". | **Localização debatida.** *Yam suf* é entendido por muitos como "mar de juncos/caniços"; outros mantêm o Mar Vermelho (golfo de Suez ou de Ácaba); há propostas de lagos ao norte (lagos Amargos, lago Timsah, região do lago Menzalé/Sirbonis). Nenhuma é consenso. | O mapa mostra **"junto ao mar"** sem nomear golfo nem lago; placa/diário: "localização debatida". Nenhum marco geográfico moderno. |
| Acampam diante de Pi-Hairote, entre Migdol e o mar, diante de Baal-Zefom (`14:2`, `14:9`; `Num 33:7`). | Identificação desses lugares é **incerta/debatida**; Migdol pode significar "torre/fortaleza"; Baal-Zefom é nome ligado a um deus cananeu. | Os nomes podem aparecer como **ditos pelo texto**, sem ponto exato no mapa; nada de torre ou templo identificado como "o Migdol". |
| Deus evita o caminho dos filisteus por causa de guerra (`13:17`). | Rota costeira com fortificações egípcias é contexto discutido; o termo "filisteus" pode ser anacrônico em relação à época (debate). | Morador fictício comenta que "não seguimos pelo caminho da costa", sem explicar estratégia além do texto. |
| Coluna de nuvem de dia, de fogo de noite (`13:21-22`); passa para trás entre os acampamentos (`14:19-20`). | Leituras naturalistas (fogo de sinalização de caravana etc.) são **interpretações**, não fato. | Coluna representada com sobriedade (nuvem densa/luz), sem "rosto", sem partículas de "magia". O jogador não interage com ela. |
| Vento oriental forte a noite toda; mar recua; terra seca; águas como muro (`14:21-22`). | Explicações naturalistas (vento, maré, tsunami) e leituras puramente sobrenaturais são **interpretações**; o texto atribui o evento ao SENHOR **usando** o vento. "Muro" pode ser leitura literal ou figurada — **debatido**. | Cena: vento soprando durante uma noite, água recuando, terra seca, água elevada dos dois lados. **Não** acrescentar peixes visíveis nas paredes, raios, luzes no céu, chão de lama, duração em horas, largura do caminho. |
| Moisés estende a mão (`14:21`, `14:27`); a ordem inclui levantar a vara (`14:16`). | Se a vara aparece no gesto é detalhe de representação. | Moisés visto **de longe**, gesto de estender a mão (vara opcional, coerente com `14:16`); sem fala, sem efeito saindo da mão (o texto não descreve). |
| 600 carros escolhidos e todos os carros do Egito (`14:7`). | Números e tipo de carro de guerra são contexto histórico discutido. | Carros só como silhueta distante/poeira no horizonte no "antes". |
| Rodas dos carros saem/emperram (`14:25`). | Tradução discutida (arrancou × travou). | **Não mostrar** em cena. |
| Ao amanhecer o mar volta; o exército é coberto; não sobra nenhum (`14:27-28`); Israel vê os mortos na praia (`14:30`). | — | **Não mostrar** corpos nem afogamento; ver §8. |
| Número de pessoas: ~600 mil homens a pé, além das crianças (`12:37`). | O tamanho é **debatido** (leituras de *'elef* como "mil" ou "clã/unidade"). | O jogo mostra "um povo numeroso" sem dar número; nenhum contador de pessoas. |
| Multidão mista com ovelhas, bois e muitos animais (`12:38`). | Composição da multidão mista não é detalhada. | Famílias, crianças, idosos, pastores e rebanhos **fictícios** no acampamento, marcados `plausible_fiction`. |
| O povo teve medo, clamou, se queixou (`14:10-12`); depois temeu e creu (`14:31`). | — | Moradores fictícios expressam medo, espera e depois gratidão, **sem** dizer o que o texto não diz (ex.: não citar falas como se fossem de pessoas reais). |
| Miriã e as mulheres com tamborins e danças (`15:20-21`). | Uso de tamborins/danças em celebração é contexto plausível. | Sons distantes de tamborim no acampamento "depois"; mulheres fictícias juntando-se ao canto — sem letra inventada. |
| Ossos de José levados (`13:19`). | — | Possível descoberta de diário ligando a `Gen 50:25`; **não** pôr o caixão/ossos como objeto interativo. |

---

## 7. Como a cena dirigida pode representar o texto (sem acrescentar e com reverência)

### 7.1 Princípios
1. **Agente é Deus; mediador visível é Moisés; o viajante é espectador.** Legenda/narração sempre atribui a abertura ao SENHOR (`14:21`). O viajante não toca em nada, não aperta botão de "abrir", não tem contagem regressiva nem QTE. A câmera pode ser retirada do controle do jogador durante a cena (sem input além de pular/avançar texto, se o criador permitir).
2. **Só elementos do texto, na ordem do texto:** (a) coluna de nuvem passa para trás e fica entre os acampamentos, noite (`14:19-20`); (b) Moisés estende a mão sobre o mar (`14:21`); (c) vento oriental forte, noite inteira — passagem de tempo sugerida (`14:21`); (d) mar recua, terra seca, águas divididas (`14:21`); (e) o povo entra em terra seca, águas como muro à direita e à esquerda (`14:22`).
3. **Texto citado acompanha, não é reescrito:** usar a BPM importada para `14:21` e `14:22` (já em `bpm.json`); se `14:19-20` e `14:29-31` forem citados, importar antes. Paráfrases do jogo ficam visivelmente separadas da citação (classificação `recorded_event` para a citação; a encenação visual é representação — sugerir nota "representação artística do relato").
4. **Sem detalhes ausentes:** nada de peixes, relâmpagos, voz audível do céu, brilho na mão de Moisés, número de horas, largura do caminho, pegadas mágicas, música triunfal com letra. Música instrumental sóbria, vento e água como sons.
5. **Sem "efeito de magia genérica"** (já em `design_constraints` do `pilot.json`): evitar partículas brilhantes, aura, círculos. Vento visível por movimento de água, areia, roupas e tendas.
6. **Duração e ritmo contemplativos;** sem humor, sem conquista/achievement com nome jocoso; o término **não** dá item, XP, poder nem colecionável (regra 12). Uma entrada de diário/descoberta educativa é aceitável como registro, não como prêmio.
7. **O viajante atravessa?** A decisão do criador é que ele "apenas assiste". Se o acampamento "depois" fica do outro lado, a passagem do viajante pode ser **implícita** (corte de cena) ou ele aparece no meio do povo **sem controle**; o diário nunca diz que o viajante foi registrado no relato (regra 4).

### 7.2 Onde a cena termina
Recomendação: **terminar a cena com o povo atravessando** (`14:22`, ecoado em `14:29`) e cortar para o amanhecer no acampamento do outro lado, com `14:30-31` como texto de transição (salvação, o povo teme ao SENHOR e crê). Os egípcios entrando (`14:23-25`) e a volta das águas (`14:26-28`) **não precisam ser encenados**; podem ser informados por narração curta referenciada (ver §8).

---

## 8. Como tratar a morte dos egípcios (público amplo)

O texto é claro: as águas voltam e cobrem o exército que entrou, não sobra nenhum (`14:27-28`), e Israel vê os egípcios mortos na praia (`14:30`). **Não omitir o fato** (seria alterar o relato), mas **não dramatizar**:
- **Sem imagem de afogamento, corpos, gritos, cavalos se debatendo** ou câmera no fundo do mar.
- **Narração sóbria e referenciada**, por exemplo (sugestão de abordagem, não texto final): "O texto relata que as águas voltaram ao amanhecer e cobriram o exército que havia entrado no mar (Êx 14:27-28)." Para `14:30`, preferir resumir como "Assim o SENHOR salvou Israel naquele dia (Êx 14:30)", e, se a segunda metade do versículo for citada, fazê-lo por texto, sem ilustração.
- **Sem celebração da morte** por moradores fictícios (nada de zombaria ou "bem feito"). A gratidão deles é pela **libertação** e pela vida, com espaço para o temor (`14:31`: "o povo temeu ao SENHOR").
- **Não generalizar** "os egípcios" como povo mau: o texto fala do exército que perseguiu (`14:28`). Não insinuar que todos os egípcios morreram.
- **Não afirmar que o Faraó morreu**: `Exod 14` não diz isso (diz que o exército e os carros "de Faraó" foram cobertos). `Exod 15:4` fala dos carros e do exército de Faraó lançados no mar; a morte do próprio rei é **interpretação debatida** — não afirmar.
- **Endurecimento do coração (`14:4`, `14:8`, `14:17`)** é tema teológico com várias leituras (soberania divina × responsabilidade humana); se aparecer, apresentar como **o que o texto diz**, sem explicação doutrinária, e nunca como justificativa de crueldade.
- Considerar faixa etária/opção de pular a narração do desfecho (decisão do criador).

---

## 9. Oportunidades de exploração (viajante fictício, sem alterar o relato)

**Restrição central:** o viajante **não** guia o povo, não sugere a rota, não acalma o povo no lugar de Moisés, não segura a coluna, não ajuda a "abrir" nem a "segurar" o mar, não combate egípcios, não salva ninguém das águas, não escolta grupos como mecânica de missão. **Atenção:** `pilot.json` lista "Ajudar famílias a se organizarem na travessia" e "Escolta de grupos do povo" — conflita com a decisão do criador; sugerir revisão para atividades **antes** e **depois** apenas (ver §10).

### Antes (acampamento junto ao mar — `shore_encampment`)
1. **Famílias fictícias** arrumando tendas, cuidando do fogo, contando aos filhos por que saíram (eco de `Exod 13:8`, `13:14`: pais explicando aos filhos — usar como referência, não como fala literal).
2. **Crianças** fazendo perguntas simples ("por que a nuvem anda na frente?") respondidas por adultos fictícios **sem explicar o milagre além do texto** (`13:21-22`).
3. **Idosos** lembrando a vida de servidão (contexto de `Exod 1:11`, `14:12`) e o medo de voltar; um idoso fictício pode mencionar os ossos de José (`13:19`, `Gen 50:25`).
4. **Pastores e rebanhos** (`12:38`): ovelhas e bois; o viajante pode ajudar a juntar animais dispersos **como atividade cotidiana**, sem ligação com o resultado do milagre.
5. **Multidão mista** (`12:38`): um morador fictício de origem não israelita, identificado como tal, que decidiu seguir o povo — sem inventar fatos sobre a multidão (`plausible_fiction`).
6. **Medo e espera** (`14:10-12`): ao surgir poeira/carros no horizonte, moradores fictícios expressam medo; alguns repetem, **como queixa geral parafraseada**, que teria sido melhor ficar no Egito (`14:12` como referência). Depois a notícia, **identificada como resumo**, de que Moisés disse para não temer (`14:13-14`).
7. **A coluna à noite** entre os acampamentos (`14:19-20`): observar de longe; o viajante não se aproxima.

### Depois (amanhecer do outro lado)
8. **Gratidão** de famílias fictícias; crianças abraçando pais; pastores contando os animais; tudo sem afirmar números.
9. **Temor e fé** (`14:31`): moradores fictícios silenciosos, olhando para o mar; reflexão de diário sobre medo × confiança (`devotional_educational`).
10. **Cântico ao longe** (`15:1`, `15:20-21`): sons de tamborins; nota de diário referenciada.
11. **Descobertas de contexto** (após revisor histórico): vida em acampamento nômade, tendas, rebanhos, a rota pelo deserto, "*yam suf* e o debate sobre a localização" (`historical_context` + `symbolic_interpretation`/interpretações separadas).
12. **Gancho** para `ep_017_o_mana_no_deserto`: partida para o deserto (`Exod 15:22`), sem antecipar Mara.

**Restrições de design sugeridas (`design_constraints`):** Faraó sem nome; Moisés e Faraó sem falas livres; Arão fora da cena; o jogador não causa, acelera, controla nem é necessário para o milagre; sem combate; nada da cena vira item/poder/colecionável; morte dos egípcios só narrada, sem imagem; local do mar sem identificação; sem ano.

---

## 10. Riscos (fáceis de distorcer)
- **Afirmar local** ("golfo de Suez", "Ácaba", "lagos Amargos", "Nuweiba") ou usar "mar de juncos" como fato: ambos debatidos. A BPM diz "Mar Vermelho" em `13:18`/`15:4`; se o jogo citar a BPM, explicar no diário que o termo hebraico é discutido.
- **Afirmar data ou Faraó** (Ramsés II, Tutmés III, Amenófis II etc.): debatido. Nenhum nome, cartucho ou estátua identificável.
- **Hollywood**: paredes de água com peixes, abertura instantânea com estrondo, Moisés gritando uma frase famosa, Faraó gritando na praia — nada disso está no texto. O texto fala de **vento a noite toda** (processo, não instantâneo).
- **Falas inventadas**: "Deixe meu povo ir" é de outro contexto (`Exod 5`, `7`–`10`); não colocar em `Exod 14`. Moisés não tem outra fala no cap. 14 além de `14:13-14`.
- **Vara mágica**: a vara aparece na ordem (`14:16`); o poder é atribuído ao SENHOR (`14:21`). Não mostrar a vara emitindo energia nem como objeto colecionável ("a vara de Moisés" não vira item).
- **Anjo**: não dar forma humana alada, nome ou fala; o texto só diz que se moveu (`14:19`).
- **Coluna**: não personificar; não fazer o jogador "seguir a luz" como mecânica de waypoint (seria transformar teofania em ferramenta do jogador).
- **Morte dos egípcios**: nem omitir, nem dramatizar, nem celebrar; não afirmar a morte do Faraó (ver §8).
- **Número do povo** (`12:37`): não mostrar "600.000" como fato inquestionável sem nota; não fazer contador.
- **Antecipar Mara, maná ou Sinai** neste episódio.
- **Arão e Miriã**: Arão não age em `Exod 14`; Miriã só em `15:20-21`.
- **Explicações naturalistas ou doutrinárias** apresentadas como fato (de qualquer lado): sempre como interpretação.
- **Conflito com dados existentes**: `pilot.json` (`possible_activities`: "Escolta de grupos do povo"; `possible_interactions`: "Ajudar famílias a se organizarem na travessia") e `experiences.json` (`Exod 14:21-22`) — o primeiro conflita com "apenas assiste".

---

## 11. Fontes consultadas
- `C:\TEMP\biblia\porbrbsl\porbrbsl_vpl.txt` — Bíblia Portuguesa Mundial (domínio público, eBible.org `porbrbsl`): `Exod 12:37-42`, `Exod 12:51`, `Exod 13:1-22`, `Exod 14:1-31`, `Exod 15:1-27`, `Num 33:5-10`, `Gen 50:24-25`, `Heb 11:29`, `1Kgs 6:1`, `Exod 1:11`; contagens de `Exod 12`, `13`, `15`, `Num 33`.
- `data/bible/texts/bpm.json` — mesma tradução importada: confere `Exod 14:21`, `Exod 14:22`, `Exod 1:11`.
- `data/bible/verse_counts.json`, `data/bible/books.json` — validação.
- `docs/ai-wiki/BIBLICAL_RULES.md`, `docs/mission_factory.md` (mapa de capacidades: `observe_scene` só em quadros; cena dirigida no mapa não existe), `AGENTS.md`.
- `production/catalog/episodes.json`, `production/episodes/ep_016_a_travessia_do_mar/manifest.json`; `production/episodes/ep_011_jose_e_o_tempo_de_fartura/research_biblical.md` (modelo).
- `data/bible/stories/pilot.json` (`exod_014_red_sea`), `data/world/experiences.json` (`exodus_sea`).
- Conhecimento geral do pesquisador (IA) sobre *yam suf*, propostas de localização, modelos de datação do Êxodo, leitura de *'elef*, traduções discutidas de `13:18`, `14:20`, `14:25` — **não verificado**, marcado como inferência/hipótese. Nenhuma tradução protegida foi citada.

---

## 12. Itens `needs_human_review`
1. **Importar para `bpm.json`** os versículos que serão citados além de `14:21-22` (sugestão: `14:13-14`, `14:19-20`, `14:29-31`, `13:21-22`; `15:20-21` se usado) e acrescentar `Exod 12` (51), `Exod 13` (22), `Exod 15` (27) a `verse_counts.json` (KI-11).
2. **Cena dirigida no mapa não existe** (`observe_scene` só em quadros). Decidir: implementar a cena (código novo) ou começar com quadros + mapa.
3. **Termo para o mar** no jogo: "o mar" (texto de `Exod 14`) × "Mar Vermelho" (BPM) × menção a "mar de juncos" no diário. Sugestão: "o mar" na cena; nota de debate no diário.
4. **Até onde a cena vai**: só abertura e travessia (recomendado) ou também a volta das águas (sem imagens de morte).
5. **Redação do desfecho** (`14:27-28`, `14:30`) e se há opção de pular/aviso para crianças.
6. **Vara visível** no gesto de Moisés (`14:16`) ou só a mão (`14:21`).
7. **Moisés visível** (de longe, sem rosto detalhado) ou só sugerido.
8. **`Exod 15`**: só referência/eco sonoro (recomendado) × refrão cantado × cântico completo.
9. **O viajante atravessa?** Corte de cena × presença passiva no meio do povo.
10. **Revisar `pilot.json`** (`possible_activities`/`possible_interactions` de escolta e organização "na travessia") à luz da decisão do criador.
11. **Número do povo** (`12:37`): citar com nota ou não citar.
12. `chronology_confidence` do catálogo `not_established` → sugerir `debated`; alinhar `approximate_debated` do `pilot.json`.
13. Revisor histórico: acampamento, tendas, rebanhos, carros egípcios (só silhueta), lugares de `14:2`.
