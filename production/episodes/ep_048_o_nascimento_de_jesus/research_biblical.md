# Ficha bíblica — ep_048_o_nascimento_de_jesus · "O nascimento de Jesus"

- **Episódio:** `ep_048_o_nascimento_de_jesus` (entrada em `production/catalog/episodes.json`). Modo narrativo `observacao_contextual`; objetivo de aprendizagem "Nascimento de Jesus e anúncio aos pastores"; região "Belém (recriação)"; referência do catálogo `Luke 2:1-20`.
- **Recorte de jogo (decisão do criador, 2026-10-14):** experiência "Os pastores de Belém". Centro: `Luke 2:8-20`; contexto: `Luke 2:1-7`. O viajante fictício passa a noite com pastores **fictícios** nos campos perto de Belém; o anúncio do anjo e a multidão celestial são uma **cena visual dirigida** (luz no campo) que o jogador só assiste, acompanhada do texto bíblico citado; depois os pastores do relato vão a Belém (`Luke 2:15-16`) e o viajante acompanha de longe/ao redor.
- **Autor:** agente `biblical-researcher` (IA). **Status:** `pending_review` — nada aqui está verificado; exige revisão humana (regra 10).
- **Texto bíblico usado:** Bíblia Portuguesa Mundial (BPM, domínio público, eBible `porbrbsl`), lida no arquivo oficial `C:\TEMP\biblia\porbrbsl\porbrbsl_vpl.txt` (formato VPL) e conferida contra `data/bible/texts/bpm.json`. Os resumos abaixo são **texto próprio**, não citação; palavras entre aspas são termos da BPM, usados só para identificar o trecho. Esta ficha não fornece versículos para o jogo: a citação, quando houver, vem de `bpm.json` (regra 9).

---

## 1. Referências (conferidas contra o VPL e `data/bible/verse_counts.json`)

Ids de livro usados (todos existem em `data/bible/books.json`): `Luke`, `Matt`, `Mark`, `John`, `Mic`, `1Sam`.

**Contagens:**

| Capítulo | VPL (BPM) | `verse_counts.json` |
|---|---|---|
| `Luke 1` | 80 | 80 (bate) |
| `Luke 2` | 52 | 52 (bate) |
| `Luke 3` | 38 | 38 (bate) |
| `Luke 10` | 42 | 42 (bate) |
| `Matt 2` | 23 | 23 (bate) |
| `1Sam 16` | 23 | 23 (bate) |
| `1Sam 17` | 58 | 58 (bate) |
| `Luke 22` | 71 | **falta** |
| `Mark 14` | 72 | **falta** |
| `John 7` | 53 | **falta** |
| `Mic 5` | 15 | **falta** |

As referências cruzadas cujo capítulo falta em `verse_counts.json` (`Luke 22`, `Mark 14`, `John 7`, `Mic 5`) **só podem entrar em dados do jogo depois** que o capítulo for acrescentado (via importador), senão os testes recusam. Para este episódio elas são opcionais.

**Versículos já presentes em `bpm.json`:** `Luke 2:4`, `Luke 2:8` a `Luke 2:20` (todos os versículos centrais). **Ausentes:** `Luke 2:1-3`, `Luke 2:5-7` (contexto) e todas as referências cruzadas, exceto `Luke 1:26` e `Luke 4:16`. Se o design quiser citar `Luke 2:1-7`, o importador precisa trazer esses versículos.

### Trechos centrais

| Ref. | Trecho | No VPL | Em `bpm.json` |
|---|---|---|---|
| `Luke 2:1-3` | Decreto de César Augusto; "primeiro recenseamento" quando Quirino governava a Síria; cada um à sua cidade | Sim | Não |
| `Luke 2:4-5` | José sobe de Nazaré (Galileia) a Belém (Judeia), "cidade de Davi", com Maria, prometida e grávida | Sim | Só `2:4` |
| `Luke 2:6-7` | Nascimento do primogênito; faixas de pano; manjedoura; "não havia lugar para eles na hospedaria" | Sim | Não |
| `Luke 2:8` | Pastores na mesma região, no campo, vigiando o rebanho à noite | Sim | Sim |
| `Luke 2:9` | Anjo do Senhor aparece; a glória do Senhor brilha ao redor; ficam aterrorizados | Sim | Sim |
| `Luke 2:10-12` | Mensagem do anjo: não temer; boa notícia de grande alegria para todo o povo; hoje nasceu na cidade de Davi um Salvador, Cristo o Senhor; o sinal (bebê em faixas, numa manjedoura) | Sim | Sim |
| `Luke 2:13-14` | De repente, multidão do exército celestial com o anjo, louvando a Deus e dizendo "Glória a Deus…" | Sim | Sim |
| `Luke 2:15` | Os anjos se afastam rumo ao céu; os pastores combinam ir a Belém ver o que o Senhor lhes deu a conhecer | Sim | Sim |
| `Luke 2:16` | Vão apressadamente; encontram Maria, José e o bebê na manjedoura | Sim | Sim |
| `Luke 2:17-18` | Contam o que lhes fora dito sobre o menino; todos que ouvem ficam admirados | Sim | Sim |
| `Luke 2:19` | Maria guardava todas essas palavras, meditando no coração | Sim | Sim |
| `Luke 2:20` | Os pastores voltam glorificando e louvando a Deus, tudo como lhes fora dito | Sim | Sim |

### Referências cruzadas (só contexto; não obrigatórias)

| Ref. | Para quê |
|---|---|
| `Luke 1:5` | "Nos dias de Herodes, rei da Judeia" — moldura temporal do próprio Lucas |
| `Luke 1:31-32` | Anúncio a Maria: o nome Jesus; "trono de Davi" (liga a "cidade de Davi") |
| `Luke 2:21` | Oito dias depois: circuncisão e nome Jesus (fora do recorte; útil para não antecipar o nome dado) |
| `Luke 2:51` | Segunda vez que Lucas diz que Maria guardava as coisas no coração |
| `Luke 3:1` | Datação de Lucas pelo 15º ano de Tibério (início da pregação de João, não o nascimento) |
| `Luke 3:23` | Jesus "tinha cerca de trinta anos" ao começar (aproximado no próprio texto) |
| `Luke 10:34` | Outra "hospedaria" em Lucas (parábola do samaritano) — comparação de termos, ver §6 |
| `Luke 22:11`, `Mark 14:14` | "Aposento/sala de hóspedes" — comparação de termos, ver §6 (capítulos faltam em `verse_counts`) |
| `Matt 2:1`, `Matt 2:11` | Mateus: nascimento em Belém "nos dias do rei Herodes"; os magos entram "na casa" (episódio `ep_047`, não misturar) |
| `1Sam 16:11`, `1Sam 17:15` | Davi apascentava ovelhas em Belém — ligação "cidade de Davi"/pastoreio |
| `Mic 5:2` | Profecia sobre Belém Efrata (numeração da BPM/portuguesa; no texto hebraico é 5:1). Capítulo falta em `verse_counts` |
| `John 7:42` | Debate popular: o Cristo viria "de Belém, a aldeia onde Davi viveu" (capítulo falta em `verse_counts`) |

---

## 2. Resumo do relato, trecho a trecho (paráfrase própria)

### Contexto — a viagem e o nascimento (`Luke 2:1-7`)
- Naquele tempo saiu de César Augusto uma ordem para recensear "todo o mundo" (`Luke 2:1`).
- Lucas diz que foi o primeiro recenseamento, no tempo em que Quirino governava a Síria (`Luke 2:2`).
- Cada pessoa ia se registrar na sua própria cidade (`Luke 2:3`).
- José, por ser da casa e família de Davi, subiu de Nazaré, na Galileia, para Belém, na Judeia, chamada "cidade de Davi" (`Luke 2:4`).
- Foi registrar-se com Maria, que estava prometida em casamento a ele e grávida (`Luke 2:5`).
- Enquanto estavam em Belém, chegou o tempo do parto (`Luke 2:6`). O texto **não** diz que o parto foi na noite da chegada.
- Maria deu à luz o filho primogênito, envolveu-o em faixas de pano e o deitou numa manjedoura, porque não havia lugar para eles na "hospedaria" (`Luke 2:7`). O texto não fala de estábulo, gruta, animais nem de alguém que os recusou.

### O anúncio nos campos (`Luke 2:8-14`)
- Na mesma região havia pastores que ficavam no campo e vigiavam o rebanho durante a noite (`Luke 2:8`). O número de pastores não é dito; os nomes também não.
- Um anjo do Senhor apareceu a eles, a glória do Senhor brilhou ao redor deles e eles tiveram muito medo (`Luke 2:9`). A única descrição visual é a glória/luz **ao redor dos pastores**; o anjo não é descrito.
- O anjo disse que não temessem: trazia boa notícia de grande alegria, que seria para todo o povo (`Luke 2:10`).
- Anunciou que naquele dia, na cidade de Davi, tinha nascido para eles um Salvador, que é Cristo, o Senhor (`Luke 2:11`).
- Deu-lhes um sinal: encontrariam um bebê envolto em faixas de pano, deitado numa manjedoura (`Luke 2:12`).
- De repente, uma multidão do exército celestial apareceu junto com o anjo, louvando a Deus (`Luke 2:13`).
- O louvor dá glória a Deus nas alturas e anuncia paz na terra (`Luke 2:14`; ver variante textual em §7). O texto diz "louvando… e dizendo", **não** "cantando".

### A ida a Belém (`Luke 2:15-16`)
- Quando os anjos se afastaram rumo ao céu, os pastores combinaram entre si ir a Belém ver o que tinha acontecido e que o Senhor lhes fizera saber (`Luke 2:15`). A fala é coletiva ("disseram uns aos outros"), sem orador individual.
- Foram depressa e encontraram Maria, José e o bebê deitado na manjedoura (`Luke 2:16`). O texto não diz se deixaram o rebanho nem com quem.

### Depois do encontro (`Luke 2:17-20`)
- Ao vê-lo, contaram o que lhes fora dito a respeito do menino (`Luke 2:17`). O texto não diz a quem exatamente, nem onde, além de "todos" os que ouviram.
- Todos os que ouviram ficaram admirados com o que os pastores contavam (`Luke 2:18`).
- Maria guardava todas essas coisas e meditava nelas no coração (`Luke 2:19`). Nenhuma fala de Maria é registrada.
- Os pastores voltaram glorificando e louvando a Deus por tudo o que tinham ouvido e visto, exatamente como lhes fora dito (`Luke 2:20`).

---

## 3. Personagens bíblicos e o que o texto diz de cada um

| Personagem | O que o texto diz | O que o texto **não** diz |
|---|---|---|
| **César Augusto** | Emitiu o decreto de recenseamento (`Luke 2:1`) | Não aparece em cena |
| **Quirino** | Governava a Síria no tempo do "primeiro recenseamento" (`Luke 2:2`) | Data exata (debatida, §5) |
| **José** | Da casa e família de Davi; subiu de Nazaré a Belém com Maria (`Luke 2:4-5`); estava lá quando os pastores chegaram (`Luke 2:16`) | **Nenhuma fala** neste trecho; nenhuma reação descrita |
| **Maria** | Prometida a José, grávida (`Luke 2:5`); deu à luz, envolveu o bebê em faixas, deitou-o na manjedoura (`Luke 2:7`); estava lá quando os pastores chegaram (`Luke 2:16`); guardava e meditava no coração (`Luke 2:19`) | **Nenhuma fala** neste trecho; sentimentos além de "guardava… meditando" não descritos |
| **O bebê (Jesus)** | Primogênito, em faixas, na manjedoura (`Luke 2:7`, `Luke 2:12`, `Luke 2:16`); anunciado como Salvador, Cristo o Senhor (`Luke 2:11`). O nome Jesus é dado ao oitavo dia (`Luke 2:21`; anunciado antes em `Luke 1:31`) | Aparência, choro etc. |
| **Os pastores** | Na região, no campo, vigiando o rebanho à noite (`Luke 2:8`); ficaram aterrorizados (`Luke 2:9`); combinaram ir a Belém (`Luke 2:15`); foram depressa e encontraram (`Luke 2:16`); contaram o que ouviram (`Luke 2:17`); voltaram glorificando e louvando (`Luke 2:20`) | Quantos, nomes, idades, se havia jovens, se deixaram alguém com o rebanho, o que levaram |
| **O anjo do Senhor** | Apareceu; falou a mensagem de `Luke 2:10-12` | Nome (não é chamado de Gabriel aqui; Gabriel aparece em `Luke 1`), aparência, asas, roupa, posição (no ar/no chão) |
| **Multidão do exército celestial** | Apareceu de repente com o anjo; louvava a Deus e dizia `Luke 2:14` (`Luke 2:13-14`); depois "os anjos" se afastaram rumo ao céu (`Luke 2:15`) | Número, forma, canto, instrumentos |
| **"Todos os que ouviram"** | Ficaram admirados (`Luke 2:18`) | Quem eram |

**Falas registradas no trecho (únicas):** o anjo (`Luke 2:10-12`), a multidão celestial (`Luke 2:14`) e os pastores em coro (`Luke 2:15`). Mais nenhuma. Os pastores bíblicos "contaram" (`Luke 2:17`), mas o conteúdo só é resumido ("o que lhes havia sido dito a respeito daquele menino").

---

## 4. Gênero literário

**Narrativa** (evangelho, prosa narrativa histórica-teológica), com **anúncio angélico** e uma breve **aclamação/louvor** (`Luke 2:14`). Não é visão nem sonho: o texto apresenta a aparição como acontecimento aos pastores acordados, no campo. Lucas apresenta sua obra como relato ordenado de acontecimentos (`Luke 1:1-4`, prólogo; existe no VPL, ausente de `bpm.json`).

Classificações sugeridas (regra 5): anúncio, ida a Belém e reações → `recorded_event`; recenseamento, pastoreio, manjedoura, casas de Belém → `historical_context`; viajante, pastores fictícios, moradores → `plausible_fiction`; a forma visual do anjo e da luz → representação artística dentro de cena `recorded_event` (ver §8); leituras teológicas ("por que pastores?") → `symbolic_interpretation` ou `devotional_educational`.

---

## 5. Linha do tempo

- **Época:** Judeia sob domínio romano, nos dias de Herodes, rei da Judeia (`Luke 1:5`; também `Matt 2:1`) e de César Augusto (`Luke 2:1`). Era em `data/bible/chronology.json`: `roman_judea`.
- **chronology_confidence do período (domínio romano, Augusto, Herodes):** `documented`.
- **Ano do nascimento:** `debated`. Não usar número no jogo (`null`). Contexto para a revisão histórica, **não para texto do jogo sem revisão**: a morte de Herodes é tradicionalmente situada por volta de 4 a.C. (ela própria discutida), e Josefo registra um censo sob Quirino na Judeia geralmente datado de 6 d.C.; conciliar isso com `Luke 2:2` é uma questão debatida, com várias propostas (tradução de "primeiro" como "anterior", um censo anterior, outro mandato/cargo de Quirino, erro ou aproximação de Lucas). Confirmar com o `historical-reviewer`.
- **Dia/mês/estação:** `unknown`. O texto não dá data. 25 de dezembro é tradição litúrgica posterior; a presença de pastores no campo à noite **não** prova estação (argumentos "não podia ser inverno" ou "era primavera" são inferências debatidas). Não mostrar neve, frio extremo nem calendário.
- **Hora:** "durante a noite" (`Luke 2:8`) para o anúncio; o texto diz "hoje" nasceu (`Luke 2:11`), ligando o nascimento ao mesmo dia do anúncio. A hora do parto não é dada.
- **Duração da cena:** a ida foi "apressadamente" (`Luke 2:16`) — sugere a mesma noite, mas o texto não fixa horas. `approximate`.
- **Idade de Jesus em relação aos magos (`Matt 2`):** fora deste episódio; não fundir as cenas (§7).

---

## 6. Três colunas: texto × inferência/hipótese × ficção do jogo

| O que o texto diz | Inferência ou hipótese histórica | O que seria ficção do jogo |
|---|---|---|
| Decreto de Augusto; primeiro recenseamento quando Quirino governava a Síria (`Luke 2:1-2`) | Data e forma do censo **debatidas** (§5); registro por cidade de origem familiar é discutido entre historiadores | Moradores fictícios comentando a viagem de registro, filas, escribas — sem afirmar datas |
| José sobe de Nazaré a Belém com Maria grávida (`Luke 2:4-5`) | Distância e rota aproximadas (vários dias de viagem); meio de transporte não dito | Burrinho de Maria **não** está no texto; se aparecer, é ficção/tradição e não deve ser mostrado como fato |
| Não havia lugar "na hospedaria" (`Luke 2:7`) | Termo grego *katalyma*: a BPM traduz "hospedaria", mas Lucas usa a mesma palavra para "aposento de hóspedes" (`Luke 22:11`; cf. `Mark 14:14`), enquanto a hospedaria comercial da parábola (`Luke 10:34`) é outra palavra (*pandocheion*). Leitura "quarto de hóspedes de uma casa de família" × "pousada/abrigo de viajantes" é **debatida** | **Não** criar estalajadeiro que recusa o casal (não está no texto). Ambientação neutra: casa/abrigo com área de animais, sem afirmar qual leitura é a certa |
| Bebê deitado numa manjedoura (`Luke 2:7`, `2:12`, `2:16`) | Manjedoura = cocho de alimentar animais; em casas simples da região os animais podiam ficar num nível/área da própria casa (hipótese); tradição da gruta de Belém é posterior (séc. II em diante) | Mostrar uma manjedoura (de pedra ou madeira — material **não** dito) sem afirmar estábulo, gruta, boi e jumento como texto |
| Pastores no campo, vigiando o rebanho à noite (`Luke 2:8`) | Pastoreio noturno com abrigo/curral, fogueira, revezamento de vigília; ovelhas e cabras comuns na região (contexto, `historical_context`). Ligação Belém–pastoreio–Davi (`1Sam 16:11`, `1Sam 17:15`) | Os pastores **fictícios** com quem o viajante passa a noite: nomes, falas, tarefas, fogueira, cão, lanterna |
| Anjo aparece; glória do Senhor brilha ao redor deles; medo (`Luke 2:9`) | — | A forma da luz na tela é **representação**; aparência do anjo, se mostrada, é representação artística, não fato |
| Mensagem do anjo (`Luke 2:10-12`) | Títulos "Salvador", "Cristo", "Senhor" e "cidade de Davi" ligam a expectativa messiânica davídica (`Luke 1:32`; `Mic 5:2`; `John 7:42`) — leitura teológica | O texto da mensagem só aparece **citado da BPM** com referência, nunca reescrito como fala livre |
| Multidão do exército celestial louvando (`Luke 2:13-14`) | "Exército celestial" = hoste/multidão de anjos (expressão bíblica); variante textual em `2:14` (§7) | Representação visual/sonora da multidão (luzes, coro **sem letra inventada**); o texto não diz "cantaram" |
| Anjos se afastam; pastores combinam ir a Belém (`Luke 2:15`) | — | Pastores fictícios que **ficam** com o rebanho, permitindo ao viajante observar a partida — ficção identificada |
| Foram depressa e encontraram Maria, José e o bebê (`Luke 2:16`) | Como acharam o lugar não é dito (o sinal era a manjedoura) | Viajante segue de longe; vê de fora/à distância; **não** entra para conduzir, não ajuda a achar o lugar |
| Contaram; todos se admiraram (`Luke 2:17-18`) | Quem ouviu: moradores de Belém? Não especificado | Moradores fictícios reagem ao que **ouviram dos pastores**, com falas próprias sem citar o anúncio como se o tivessem visto |
| Maria guardava e meditava (`Luke 2:19`) | Lucas repete a nota em `Luke 2:51`; muitos leem como indicação de Maria como fonte/testemunha (hipótese) | **Nenhuma** fala, pensamento em balão ou narração interna de Maria |
| Voltaram glorificando e louvando (`Luke 2:20`) | — | Pastores fictícios ouvem o relato no retorno; o diário do viajante resume com referência |

---

## 7. Riscos (pontos fáceis de distorcer)

1. **Falas inventadas.** Maria, José e o bebê não falam neste trecho. O anjo e a multidão só têm as falas de `Luke 2:10-12` e `Luke 2:14`; os pastores, a combinação coletiva de `Luke 2:15`. Qualquer outra "fala" deles é proibida (regra 3); resumos devem vir marcados como paráfrase com referência.
2. **Fundir Lucas e Mateus.** Estrela, magos, presentes e a "casa" são de `Matt 2:1-12` (`ep_047`). Não colocar estrela sobre a manjedoura nem magos com os pastores. A luz do campo é a **glória do Senhor ao redor dos pastores**, não uma estrela.
3. **Presépio tradicional como fato:** estábulo, gruta, boi e jumento, burrinho da viagem, estalajadeiro mau, porta fechada — nada disso está no texto. Se usados, marcar como tradição/representação.
4. **"Os anjos cantaram."** O texto diz "louvando… e dizendo". Evitar "canto dos anjos" em texto educativo; música de fundo é aceitável como trilha, sem letra atribuída aos anjos.
5. **Aparência do anjo.** Sem asas, auréola, roupa branca ou espada descritas aqui. Gabriel não é nomeado neste trecho.
6. **Três/dois pastores, pastor menino, pastor velho.** Número e idades não são ditos; o "pastorzinho" é invenção de tradição popular. Se o jogo mostrar pastores bíblicos, o número exibido é representação.
7. **Data e estação.** Não dizer "25 de dezembro", "inverno", "ano 1" (não existe ano zero; o ano é debatido). Não afirmar "os pastores não ficariam no campo no inverno, logo…".
8. **Quirino.** Não afirmar que Lucas errou nem que a questão está resolvida; é `debated`.
9. **Variante em `Luke 2:14`.** Manuscritos diferem ("boa vontade para com os homens" × "aos homens de boa vontade"/"a quem ele favorece"). A BPM segue a primeira forma; não construir explicação doutrinária sobre uma das formas sem nota.
10. **Desprezo dos pastores.** A afirmação comum de que pastores eram "excluídos/impuros/sem valor como testemunhas" vem de fontes rabínicas posteriores e é discutida; não apresentar como fato — no máximo como interpretação.
11. **O viajante como testemunha registrada.** A presença do jogador nunca é apresentada como parte do relato (regra 4); ele não está entre os pastores do texto, não "recebe" o anúncio e não leva a notícia.
12. **Reverência (regra 12).** A glória, o anúncio e o encontro não dão item, poder, moeda, XP ou "colecionável"; nada de humor com o anjo, o medo dos pastores ou a manjedoura. Não transformar a luz em "efeito especial" que o jogador aciona.
13. **"Hoje nasceu" × hora do parto.** Não mostrar o parto; o jogo não deve ter cena do nascimento em si.
14. **Teologia denominacional.** "Por que pastores?", "Jesus como Bom Pastor/Cordeiro", "pastores do templo criando cordeiros para sacrifício" (tradição ligada à "torre do rebanho"/Migdal Éder de `Mic 4:8` — versículo existe no VPL, mas `Mic 4` falta em `verse_counts.json`, e a ligação com Belém é tradição posterior) são **interpretações**, não texto (regra 8).

---

## 8. A cena visual dirigida: o que pode mostrar sem acrescentar ao texto

Sequência possível, em ordem do texto, jogador sem controle (só assiste), com a citação BPM e a referência na tela:

1. **Noite no campo, rebanho, vigília** (`Luke 2:8`) — ambientação; pastores presentes.
2. **Luz ao redor dos pastores** (`Luke 2:9`) — a única descrição visual do texto é a glória do Senhor brilhando **ao redor deles**. Pode-se representar como claridade intensa no campo. Uma figura central para "o anjo do Senhor" é aceitável **só como representação** (sem asas/rosto definidos como fato; preferência por forma luminosa/silhueta), com nota "representação artística" no diário ou na apresentação.
3. **Medo** (`Luke 2:9`) — pastores recuam/se cobrem/se prostram (gesto genérico; o texto diz só "aterrorizados").
4. **Mensagem** (`Luke 2:10-12`) — texto citado da BPM; sem dublagem livre. Se houver locução, deve ler **exatamente** a citação (manifesto de áudio com referência).
5. **Multidão** (`Luke 2:13-14`) — "de repente": muitas luzes/figuras luminosas no céu junto ao anjo; citação de `Luke 2:14`. Sem letra cantada inventada.
6. **Afastamento** (`Luke 2:15`) — luzes sobem/se afastam; a claridade some.
7. **Decisão dos pastores** (`Luke 2:15`) — citação da fala coletiva; partida apressada (`Luke 2:16`).

**Não pode:** acrescentar falas, nome do anjo, estrela, número de anjos afirmado, efeito que pareça poder do jogador, recompensa ao fim da cena, reação/fala do viajante dentro da citação. O viajante e os pastores fictícios devem estar visivelmente **à margem** (em volta, atrás), sem receber o anúncio no lugar dos pastores do relato.

**Belém:** a chegada dos pastores e o encontro (`Luke 2:16`) vistos de fora/à distância (porta, pátio, luz de lamparina), sem o jogador entrar nem interagir com Maria, José ou o bebê. `Luke 2:17-20` podem ser mostrados pelo que os moradores fictícios ouvem e pelo retorno dos pastores louvando.

---

## 9. Oportunidades de exploração (viajante fictício, sem alterar o relato)

- **Vigília com pastores fictícios** (`plausible_fiction` + `historical_context`): ajudar a recolher o rebanho no curral/abrigo, manter o fogo, contar ovelhas, ouvir sobre turnos de vigia, predadores e cuidado do rebanho. Ligação com Davi pastor em Belém (`1Sam 16:11`, `1Sam 17:15`).
- **Belém cheia por causa do registro** (`Luke 2:1-3`): moradores e viajantes fictícios comentam a ordem do imperador e a falta de lugar nas casas — sem datas e sem estalajadeiro vilão.
- **Objetos de contexto para inspecionar:** manjedoura/cocho (material como representação), faixas de pano (costume de envolver o recém-nascido, `historical_context`), lamparina de barro, cajado, odre, curral de pedra.
- **Depois da cena:** pastores fictícios que ficaram no campo ouvem, na volta, o que os pastores do relato contam (`Luke 2:17-18`, `Luke 2:20`); moradores fictícios "admirados" (`Luke 2:18`) com falas próprias.
- **Diário:** descobertas separando "o que o texto diz" (com referência), "contexto" (pastoreio, *katalyma*, recenseamento — com certeza `debated` onde couber) e "criação do jogo".
- **Reflexão** (`devotional_educational`, opcional): perguntas abertas ("o que os pastores fizeram com o que ouviram?" → `Luke 2:17`, `Luke 2:20`; "o que Maria fez?" → `Luke 2:19`) sem impor leitura denominacional.

---

## 10. Fontes consultadas

- **Texto bíblico:** Bíblia Portuguesa Mundial (domínio público), arquivo oficial `C:\TEMP\biblia\porbrbsl\porbrbsl_vpl.txt` (eBible `porbrbsl`), capítulos `Luke 1-3`, `Luke 10`, `Luke 22`, `Mark 14`, `John 7`, `Matt 2`, `1Sam 16-17`, `Mic 5`; e `data/bible/texts/bpm.json` (mesma tradução, `verification.status = pending_review`). Nenhuma tradução protegida consultada ou citada.
- **Dados do projeto:** `data/bible/books.json`, `data/bible/verse_counts.json`, `data/bible/chronology.json` (era `roman_judea`), `production/catalog/episodes.json`, `production/episodes/ep_048_o_nascimento_de_jesus/manifest.json`.
- **Conhecimento geral de estudos bíblicos (não conferido em fonte nesta sessão; marcar para revisão):** termos gregos *katalyma*/*pandocheion*; variante textual de `Luke 2:14`; questão do censo de Quirino (Josefo); tradição da gruta (séc. II); origem litúrgica de 25 de dezembro; tradição rabínica sobre pastores. Tudo isso é contexto a ser confirmado pelo `historical-reviewer` e pela revisão humana antes de virar texto do jogo.

---

## 11. Dúvidas para revisão humana

1. **Mostrar uma figura para o anjo** ou só luz? Se houver figura, qual estilo (silhueta luminosa sem asas?) e como rotular "representação artística".
2. **Número de pastores bíblicos na cena** (o texto não diz): aceitar um número como representação, com nota?
3. **Ambientação da manjedoura:** casa com área de animais (leitura *katalyma* = quarto de hóspedes) × abrigo/pátio de pousada × gruta tradicional. Qual adotar, e com que nota de `debated`?
4. **Locução** de `Luke 2:10-14`: permitida lendo literalmente a BPM, que é rascunho em revisão pelos tradutores? Ou só texto na tela?
5. **Importar** `Luke 2:1-3` e `Luke 2:5-7` para `bpm.json` (contexto) e acrescentar `Mic 5`, `John 7`, `Luke 22`, `Mark 14` em `verse_counts.json`, se o design quiser essas referências.
6. **Nota sobre a variante de `Luke 2:14`:** incluir no diário ou omitir?
7. **Até onde o viajante se aproxima em Belém** (`Luke 2:16`): porta/pátio à distância, ou nem isso?
