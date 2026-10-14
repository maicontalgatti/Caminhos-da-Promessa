# Ficha bíblica — ep_008_jose_e_seus_irmaos · "José e seus irmãos"

- **Episódio:** `ep_008_jose_e_seus_irmaos` (entrada em `production/catalog/episodes.json`: modo `observacao_contextual`; objetivo de aprendizagem "Inveja, sofrimento e trajetória de José"; região "Região de Dotã (recriação)"; `estimate.new_map_needed: true`).
- **Objetivos-semente do catálogo:** `obj_01` visit_area `dothan_fields` ("Conhecer os campos de pastoreio"); `obj_02` inspect_object `trade_caravan` ("Investigar comércio e caravanas"); `obj_03` observe_scene `joseph_sold` ("Acompanhar o relato sem libertar José ou mudar a venda"). Todos com `target_state: placeholder`.
- **Trecho central:** `Gen 37:12-36`. **Contexto anterior:** `Gen 37:1-11`. **Ecos posteriores:** `Gen 39:1`, `Gen 42:21-22`, `Gen 45:4-8`, `Gen 50:15-20`.
- **Autor:** agente `biblical-researcher` (IA). **Status:** `pending_review` — nada aqui está verificado; exige revisão humana.
- **Texto bíblico usado:** Bíblia Portuguesa Mundial (domínio público, eBible.org `porbrbsl`). Lido diretamente do arquivo oficial `C:\TEMP\biblia\porbrbsl\porbrbsl_vpl.txt` e comparado com `data/bible/texts/bpm.json` (que já contém `Gen 37:2-36`, `Gen 39:1-6`). Todos os resumos abaixo são paráfrase própria, não citação.
- **Independência:** montada a partir do texto bíblico. Dados já existentes no jogo (`gen_037_joseph_sold` em `data/bible/stories/pilot.json`, evento `joseph_sold` em `chronology.json`, descoberta `caravans_trade`, fala do NPC Yaron sobre caravanas) foram consultados só para apontar sobreposição e riscos, não como fonte do relato.

---

## 1. Referências (conferidas)

Livro `Gen` existe em `data/bible/books.json` (50 capítulos). `data/bible/verse_counts.json` traz `Gen 25` = 34, `Gen 33` = 20, `Gen 35` = 29, `Gen 37` = 36, `Gen 39` = 23, `Gen 41` = 57. **Não traz** `Gen 16`, `Gen 30`, `Gen 34`, `Gen 42`, `Gen 45`, `Gen 50` (KI-11); para esses, a contagem foi feita no arquivo VPL oficial: `Gen 16` = 16, `Gen 30` = 43, `Gen 34` = 31, `Gen 42` = 38, `Gen 45` = 28, `Gen 50` = 26. Para `Gen 37` o VPL também tem 36 versículos (bate com `verse_counts.json`).

| Ref. | Trecho | No VPL oficial? | Em `bpm.json`? |
|---|---|---|---|
| `Gen 37:1-4` | Jacó em Canaã; José com 17 anos; mau relatório; amor preferencial; túnica; ódio dos irmãos | Sim | `37:1` **não**; `37:2-4` sim |
| `Gen 37:5-11` | Os dois sonhos; repreensão do pai; inveja | Sim | Sim |
| `Gen 37:12-17` | Envio de José de Hebrom a Siquém; o homem no campo; Dotã | Sim | Sim |
| `Gen 37:18-22` | Conspiração; "o sonhador"; intervenção de Rúben | Sim | Sim |
| `Gen 37:23-24` | Túnica arrancada; cisterna vazia | Sim | Sim |
| `Gen 37:25-28` | Refeição; caravana de ismaelitas; proposta de Judá; venda por vinte peças de prata | Sim | Sim |
| `Gen 37:29-30` | Rúben volta à cisterna e rasga as roupas | Sim | Sim |
| `Gen 37:31-35` | Túnica no sangue de um bode; Jacó reconhece e lamenta | Sim | Sim |
| `Gen 37:36` | Midianitas vendem José a Potifar no Egito | Sim | Sim |
| `Gen 39:1` | Potifar compra José "dos ismaelitas" | Sim | Sim |
| `Gen 42:21-22` | Irmãos, anos depois, reconhecem culpa; Rúben lembra que avisou | Sim | **Não** |
| `Gen 45:4-8` | José se revela; "Deus me enviou adiante de vocês" | Sim | **Não** |
| `Gen 50:15-20` | Pedido de perdão; "vocês planejaram o mal… Deus o planejou para o bem" | Sim | **Não** |
| `Gen 30:22-24` | Nascimento de José, filho de Raquel | Sim | **Não** |
| `Gen 35:16-19` | Nascimento de Benjamim e morte de Raquel | Sim | **Não** |
| `Gen 35:22-26` | Os doze filhos de Jacó e suas mães | Sim | **Não** |
| `Gen 33:18-19`, `Gen 34:25`, `Gen 34:30` | Jacó em Siquém; violência de Simeão e Levi na cidade | Sim | `33:18` sim; o resto **não** |
| `Gen 41:46` | José com 30 anos diante do Faraó | Sim | **Não** |
| `Gen 16:15`, `Gen 25:1-2`, `Gen 25:12` | Ismael, filho de Abraão e Agar; Midiã, filho de Abraão e Quetura | Sim | **Não** |

Qualquer citação literal de versículo no jogo fora de `Gen 37:2-36` e `Gen 39:1-6` exige importar o texto antes (`tools/import_scripture.gd`). `Gen 37:1` também precisa ser importado se for citado.

---

## 2. Resumo do relato, trecho a trecho (paráfrase própria)

### `Gen 37:1-11` — Contexto: preferência, túnica e sonhos
- Jacó morava em Canaã, onde o pai tinha vivido como estrangeiro (`Gen 37:1`).
- José, com dezessete anos, pastoreava com os irmãos, especialmente os filhos de Bila e Zilpa, e levava ao pai um relatório ruim sobre eles (`Gen 37:2`).
- Israel (Jacó) amava José mais que os outros filhos por ser filho da velhice e fez para ele uma "túnica de muitas cores" (`Gen 37:3`). Os irmãos perceberam, odiaram José e não conseguiam falar com ele em paz (`Gen 37:4`).
- José contou dois sonhos: feixes que se curvavam ao seu feixe; sol, lua e onze estrelas que se curvavam a ele (`Gen 37:5-9`). Os irmãos o odiaram ainda mais (`Gen 37:5`, `37:8`); o pai o repreendeu, mas "guardou o assunto" (`Gen 37:10-11`). O texto nomeia a reação dos irmãos como **inveja** (`Gen 37:11`).

### `Gen 37:12-17` — O envio e a busca
- Os irmãos levaram o rebanho do pai a Siquém (`Gen 37:12`).
- Israel enviou José do vale de Hebrom para ver se estava tudo bem com os irmãos e o rebanho e trazer notícias; José respondeu "Eis-me aqui" (`Gen 37:13-14`).
- Em Siquém, um homem não identificado encontrou José vagando pelo campo, perguntou o que ele procurava e contou ter ouvido os irmãos dizerem que iam a Dotã (`Gen 37:15-17`).
- José foi atrás deles e os encontrou em Dotã (`Gen 37:17`).

### `Gen 37:18-22` — A conspiração e Rúben
- Os irmãos o viram de longe e, antes que chegasse, tramaram matá-lo (`Gen 37:18`).
- Chamaram-no de "o sonhador" e combinaram matá-lo, jogá-lo numa cisterna e dizer que um animal feroz o devorara, "para ver o que será dos sonhos dele" (`Gen 37:19-20`).
- Rúben interveio para não tirarem a vida dele: propôs jogá-lo numa cisterna no deserto sem derramar sangue; o narrador explica que a intenção de Rúben era livrá-lo e devolvê-lo ao pai (`Gen 37:21-22`).

### `Gen 37:23-24` — A túnica e a cisterna
- Quando José chegou, tiraram dele a túnica de muitas cores, o pegaram e o jogaram na cisterna (`Gen 37:23-24`).
- A cisterna estava vazia, sem água (`Gen 37:24`).

### `Gen 37:25-28` — A caravana e a venda
- Os irmãos se sentaram para comer e viram uma caravana de ismaelitas vindo de Gileade, com camelos carregados de especiarias, bálsamo e mirra, a caminho do Egito (`Gen 37:25`).
- Judá perguntou que proveito haveria em matar o irmão e esconder o sangue, e propôs vendê-lo aos ismaelitas, "pois ele é nosso irmão, nossa carne"; os irmãos concordaram (`Gen 37:26-27`).
- Passaram mercadores midianitas; José foi tirado da cisterna e vendido aos ismaelitas por **vinte peças de prata**, e os mercadores o levaram ao Egito (`Gen 37:28`). O texto usa "eles" para quem tirou José da cisterna, sem especificar o sujeito (ver riscos).

### `Gen 37:29-30` — Rúben volta
- Rúben voltou à cisterna, não encontrou José e rasgou as roupas (`Gen 37:29`). Disse aos irmãos que o menino não estava lá e perguntou "e eu, para onde irei?" (`Gen 37:30`). O texto sugere que Rúben não estava presente na venda, mas não diz onde ele estava.

### `Gen 37:31-35` — O engano e o luto de Jacó
- Mataram um bode, mergulharam a túnica no sangue e a levaram ao pai, pedindo que verificasse se era a túnica do filho (`Gen 37:31-32`).
- Jacó a reconheceu e concluiu que um animal feroz tinha despedaçado José (`Gen 37:33`). Os irmãos não afirmam isso diretamente; Jacó tira a conclusão a partir da túnica.
- Jacó rasgou as roupas, pôs pano de saco e chorou o filho por muitos dias; filhos e filhas tentaram consolá-lo, mas ele recusou, dizendo que desceria ao Seol de luto pelo filho (`Gen 37:34-35`).

### `Gen 37:36` e `Gen 39:1` — Destino de José
- Os midianitas venderam José no Egito a Potifar, oficial do Faraó e capitão da guarda (`Gen 37:36`). `Gen 39:1` diz que Potifar o comprou "dos ismaelitas" que o tinham levado.

### Ecos posteriores (fora do escopo jogável; só para a "trajetória" do objetivo de aprendizagem)
- Anos depois, no Egito, os irmãos dizem entre si que são culpados, pois viram a angústia de José quando ele lhes implorou e não quiseram ouvir; Rúben lembra que os avisou (`Gen 42:21-22`). **Só aqui** o texto registra que José implorou — o capítulo 37 não registra nenhuma fala de José na cisterna.
- José, ao se revelar, diz que foi Deus quem o enviou adiante para preservar vidas (`Gen 45:4-8`), e mais tarde que eles planejaram o mal, mas Deus o planejou para o bem (`Gen 50:19-20`). São leituras do próprio texto bíblico, feitas por José **depois** dos fatos; não pertencem à cena de Dotã.

---

## 3. Personagens bíblicos (apenas o que o texto diz)

| Personagem | O que o texto registra | Refs. |
|---|---|---|
| **José** | Filho de Raquel (`Gen 30:22-24`, `35:24`); 17 anos; pastoreia; leva mau relatório; recebe a túnica; conta os sonhos; enviado pelo pai; procura os irmãos; jogado na cisterna; vendido; levado ao Egito. | `Gen 37:2-28`, `37:36` |
| **Jacó / Israel** | Ama José mais que os outros; faz a túnica; repreende José pelo segundo sonho mas guarda o assunto; envia José; reconhece a túnica; luto prolongado; recusa consolo. | `Gen 37:3`, `37:10-14`, `37:33-35` |
| **Rúben** | Primogênito (`Gen 35:23`); impede a morte, propõe a cisterna com intenção de devolver José ao pai; volta e não o encontra; rasga as roupas. | `Gen 37:21-22`, `37:29-30`; `Gen 42:22` |
| **Judá** | Propõe vender José em vez de matá-lo, argumentando lucro e parentesco. | `Gen 37:26-27` |
| **Os irmãos (coletivo)** | Odeiam e invejam José; conspiram matá-lo; tiram a túnica; jogam na cisterna; comem; vendem (sujeito debatido); enganam o pai com a túnica ensanguentada. O texto não distingue individualmente os demais. | `Gen 37:4-11`, `37:18-20`, `37:23-28`, `37:31-32` |
| **Filhos de Bila e Zilpa** | Dã, Naftali, Gade, Aser (`Gen 35:25-26`); José pastoreava com eles e levou relatório ruim. | `Gen 37:2` |
| **"Um certo homem"** | Anônimo; encontra José vagando no campo de Siquém e indica Dotã. | `Gen 37:15-17` |
| **Ismaelitas** | Caravana vinda de Gileade com especiarias, bálsamo e mirra rumo ao Egito; compram José; levam-no ao Egito; vendem-no a Potifar (`Gen 39:1`). | `Gen 37:25-28`, `Gen 39:1` |
| **Midianitas** | "Mercadores midianitas" passam; vendem José a Potifar (`Gen 37:36`). Relação com os ismaelitas não explicada. | `Gen 37:28`, `37:36` |
| **Potifar** | Oficial do Faraó, capitão da guarda; compra José no Egito. | `Gen 37:36`, `Gen 39:1` |
| **Filhos e filhas de Jacó** | Tentam consolar o pai. | `Gen 37:35` |

**Falas registradas no trecho central (`Gen 37:12-36`):**
- Israel a José: pergunta sobre os irmãos em Siquém, envio e pedido de notícias (`37:13-14`); José: "Eis-me aqui" (`37:13`).
- O homem: "O que você está procurando?" e a informação sobre Dotã (`37:15`, `37:17`); José: que procura os irmãos (`37:16`).
- Irmãos entre si: "lá vem o sonhador" e o plano de morte e mentira (`37:19-20`).
- Rúben: não tirar a vida, não derramar sangue, jogar na cisterna (`37:21-22`); "o menino não está mais lá; e eu, para onde irei?" (`37:30`).
- Judá: proposta da venda (`37:26-27`).
- Irmãos ao pai: "Encontramos isto…" (`37:32`).
- Jacó: reconhecimento da túnica (`37:33`) e "descerei ao Seol até o meu filho, lamentando" (`37:35`).

**José não fala nada entre `37:17` e `37:36`.** Qualquer súplica, grito ou fala dele na cisterna ou na venda seria invenção (a súplica só é mencionada retrospectivamente em `Gen 42:21`, sem conteúdo).

---

## 4. Gênero literário
**Narrativa** (narrativa patriarcal em prosa, início do ciclo de José; `Gen 37:2` abre com "Esta é a história das gerações de Jacó"). Contém relatos de **sonhos** (`Gen 37:5-10`), que o próprio texto não interpreta além da reação dos personagens. Não é parábola nem texto apocalíptico; os sonhos não devem ser tratados como visões simbólicas a decifrar no jogo.

---

## 5. Linha do tempo

| Marco | O que se apoia no texto | `chronology_confidence` |
|---|---|---|
| Período patriarcal (Abraão → Isaque → Jacó → José) | Ordem relativa de Gênesis; `data/bible/chronology.json` já não atribui anos | `debated` (datação absoluta debatida; **não atribuir ano**) |
| Idade de José na venda | 17 anos em `Gen 37:2`; o texto não diz quanto tempo passou entre `37:2` e `37:12` | `approximate` (idade ~17, intervalo desconhecido) |
| Do envio à venda | Sequência Hebrom → Siquém → Dotã → cisterna → refeição → venda (`Gen 37:14-28`) | `documented` (ordem relativa); duração `unknown` |
| Luto de Jacó | "muitos dias" (`Gen 37:34`) | `unknown` (sem número) |
| Até José diante do Faraó | 30 anos em `Gen 41:46` → cerca de 13 anos depois da idade de `37:2` | `approximate` (cálculo a partir de duas idades do texto) |
| Relação com `Gen 38` (Judá) | `Gen 38:1` diz "naquele tempo"; encaixe cronológico discutido | `debated` |
| Ano absoluto | Nenhum | usar `null` |

---

## 6. Três colunas: texto × inferência × ficção do jogo

| O que o texto diz | Inferência ou hipótese histórica | O que seria ficção do jogo |
|---|---|---|
| Irmãos levam o rebanho a Siquém e depois a Dotã (`Gen 37:12`, `37:17`). | Pastores de família se deslocavam longe de casa em busca de pasto e água (contexto geral, `historical_context`). Distância Hebrom–Siquém–Dotã: conferir no `research_historical.md`. | Pastores fictícios num campo de pastagem recriado, comentando rotas de pasto. |
| "Um certo homem" encontra José no campo (`Gen 37:15-17`). | Identidade do homem não dada; tradições judaicas posteriores o identificaram de formas diversas — **interpretação**, não usar. | **Não** transformar o jogador nesse homem nem dar nome a ele. |
| Cisterna vazia, sem água, "no deserto" (`Gen 37:22`, `37:24`). | Cisternas escavadas guardavam água da chuva e podiam ficar secas no verão (contexto; o jogo já tem descoberta sobre poços/cisternas). | Cisterna **fictícia** seca para inspeção, longe da cena; nunca a cisterna de José como objeto manipulável. |
| Túnica "de muitas cores" (`Gen 37:3`, `37:23`, `37:32`). | A expressão hebraica é de sentido incerto (túnica longa, com mangas, ornamentada ou colorida) — **debatido**, depende de léxico. | Representação visual sóbria; evitar transformá-la em item/colecionável ou cosmético do jogador. |
| Caravana de ismaelitas de Gileade com especiarias, bálsamo e mirra rumo ao Egito (`Gen 37:25`). | Rotas de comércio entre Transjordânia e Egito; uso de camelos na era patriarcal é discutido por historiadores (possível anacronismo) — **debatido**. | Caravana **fictícia** de comerciantes num ponto de parada; NPC fictício explica mercadorias (já existe descoberta `caravans_trade`). |
| Ismaelitas e midianitas aparecem alternadamente (`Gen 37:25-28`, `37:36`, `Gen 39:1`). | Hipóteses: termos sobrepostos para mercadores nômades; dois grupos; fontes literárias distintas — **debatido**. Ismael e Midiã são ambos filhos de Abraão no texto (`Gen 16:15`, `Gen 25:2`). | Nada; não resolver a questão no jogo. Mencionar só como nota "o texto usa os dois nomes". |
| Vendido por vinte peças de prata (`Gen 37:28`). | Valor comparável a preços de escravos em textos antigos — **hipótese**, conferir em fonte acadêmica. | Nenhuma mecânica de preço, troca ou compra envolvendo José. |
| Irmãos mancham a túnica com sangue de bode; Jacó conclui que um animal o matou (`Gen 37:31-33`). | Leituras literárias notam o tema do engano com roupa/cabrito que retorna em outros relatos de Jacó — **interpretação**. | Nada no jogo; no máximo nota educativa identificada. |
| Jacó rasga as roupas, pano de saco, recusa consolo (`Gen 37:34-35`). | Rasgar roupas e vestir pano de saco eram gestos de luto (contexto). | Moradores fictícios que "ouviram falar" do luto, com sobriedade. |
| Irmãos, anos depois, admitem culpa (`Gen 42:21-22`); José vê a mão de Deus (`Gen 45:5-8`, `Gen 50:20`). | Leitura de providência é do próprio texto, mas aplicações devocionais variam — **interpretação**. | Reflexão no diário marcada como reflexão (`devotional_educational`), com referência e sem antecipar a cena. |

---

## 7. Oportunidades de exploração (viajante fictício, sem alterar o relato)

**Restrição central:** o jogador **não impede, não atrasa, não facilita e não participa** da venda; não fala com José na cisterna, não leva recado a Jacó, não é o "homem" de `Gen 37:15`, não encontra nem guarda a túnica, não negocia com a caravana sobre José. A cena da venda só é **observada** (de longe, em apresentação/quadros) ou **contada** por terceiros fictícios.

1. **Campos de pastoreio (`dothan_fields`):** explorar pastagens, rebanhos, cercados de pedra, cisternas fictícias; NPC pastor fictício fala de distâncias percorridas por pastores (`historical_context`).
2. **Parada de caravana (`trade_caravan`):** inspecionar fardos de especiarias, bálsamo, mirra, camelos/jumentos; mercador **fictício e anônimo** (não ismaelita nem midianita do relato) explica comércio rumo ao Egito; liga a `Gen 37:25` como nota.
3. **Observação à distância (`joseph_sold`):** apresentação em quadros com paráfrase referenciada de `Gen 37:18-28`, narrada (não dialogada pelo jogador), com aviso de que o viajante apenas observa. Alternativa mais segura: o viajante chega **depois** e só ouve o relato da caravana partindo.
4. **Pistas de trajetória:** diário com a sequência Hebrom → Siquém → Dotã → Egito (mapa simples), e eco "anos depois" (`Gen 42:21-22`, `Gen 45:5`) como nota de continuidade para ep_009.
5. **Reflexão sobre inveja:** pergunta de diário (fictícia, identificada) ligando `Gen 37:4`, `37:11`, `37:19-20` ao tema; sem moralizar além do texto.
6. **Ponte com a aldeia atual:** o NPC Yaron já menciona caravanas e `Gen 37:25`; pode servir de gancho de partida (ver estimativa).

**Restrições de design sugeridas (`design_constraints`):** as já registradas em `pilot.json` ("O jogador não impede a venda nem resgata José"; "Falas de José e dos irmãos devem se apoiar no texto") + José sem falas em Dotã; nenhum NPC fictício presente na cisterna; prata, túnica e cisterna não viram itens; nenhuma escolha do jogador com resultado sobre José.

---

## 8. Riscos (fáceis de distorcer)
- **Violência e público infantil:** o texto inclui plano de assassinato, agressão (arrancar túnica, jogar na cisterna), tráfico de pessoa e sangue de animal. Tratar com sobriedade, sem mostrar violência explícita nem sofrimento dramatizado de José; sem humor.
- **Falas inventadas de José:** o capítulo 37 não registra súplica nem fala de José após `37:16`. Não criar gritos ou pedidos de socorro na cisterna (a súplica de `Gen 42:21` é lembrança dos irmãos, sem conteúdo).
- **Culpa coletiva e nuances:** não tratar "os irmãos" como bloco homogêneo de vilões: Rúben tenta salvar (`37:21-22`, `37:29-30`), Judá evita a morte mas propõe a venda por proveito (`37:26-27`). Também não absolver: o texto registra ódio, inveja e engano. Evitar extrapolar culpa para "as tribos" ou para o povo de Israel.
- **Quem tirou José da cisterna (`Gen 37:28`):** o "eles" é ambíguo (irmãos ou midianitas); há leituras em que os midianitas o tiram sem os irmãos verem. **Debatido** — paráfrases do jogo não devem decidir isso; preferir formulação neutra.
- **Ismaelitas × midianitas:** o texto usa os dois nomes (`37:25`, `37:28`, `37:36`, `39:1`). Não "corrigir" o texto, não escolher um só, não inventar explicação.
- **Estereótipos étnicos:** ismaelitas e midianitas são só mercadores no relato; não retratá-los como cruéis, traiçoeiros ou exóticos, e **não** ligar a povos árabes/muçulmanos atuais. Visual e falas de comerciantes fictícios sem caricatura.
- **A túnica:** "muitas cores" é a leitura da BPM, mas o termo hebraico é incerto; evitar afirmar "colorida" como fato em textos educativos sem nota; não transformar em símbolo de privilégio do jogador, item, skin ou recompensa (regra 12).
- **Favoritismo de Jacó:** o texto registra o amor preferencial e a túnica sem comentário moral explícito; não acusar nem defender Jacó além do texto.
- **Sonhos:** não interpretar os sonhos como profecia já cumprida no ep_008; o cumprimento aparece só em capítulos posteriores (`Gen 42` em diante, fora do escopo). Nota: `Gen 37:10` menciona "sua mãe", mas `Gen 35:19` registra a morte de Raquel antes — questão interpretativa conhecida; não resolver no jogo.
- **Providência como justificativa:** `Gen 45:5-8` e `Gen 50:20` não tornam a venda boa nem justificam o tráfico; apresentar como leitura posterior de José, não como lição na cena.
- **Siquém:** a região carrega `Gen 34` (violência de Simeão e Levi); não misturar com o episódio nem sugerir motivo não dito para a ida a Siquém.
- **Camelos:** possível anacronismo discutido; se a caravana tiver camelos (o texto diz que tinha, `37:25`), não acrescentar notas históricas contrárias ou favoráveis como fato.
- **Dado já existente no jogo:** `data/bible/places.json` afirma "Identificado com Tell Dothan" e Siquém "Identificada com Tell Balata" sem marcar confiança — conferir com o revisor histórico.
- **Confusão com `Gen 39`:** a chegada à casa de Potifar é do ep_009; o ep_008 termina com a caravana partindo e o luto de Jacó.

---

## 9. Fontes consultadas
- `C:\TEMP\biblia\porbrbsl\porbrbsl_vpl.txt` — Bíblia Portuguesa Mundial (domínio público, eBible.org `porbrbsl`), arquivo oficial completo: `Gen 37:1-36`, `Gen 16:15`, `Gen 25:1-2`, `Gen 25:12-13`, `Gen 25:18`, `Gen 30:22-24`, `Gen 33:18-19`, `Gen 34:25`, `Gen 34:30`, `Gen 35:16-19`, `Gen 35:22-29`, `Gen 38:1`, `Gen 39:1-2`, `Gen 41:46`, `Gen 42:20-24`, `Gen 45:4-8`, `Gen 50:15-20`; contagens de versículos por capítulo.
- `data/bible/texts/bpm.json` — mesma tradução (importada): confere `Gen 37:2-36`, `Gen 39:1-6`.
- `data/bible/verse_counts.json`, `data/bible/books.json` — validação de referências.
- `docs/ai-wiki/BIBLICAL_RULES.md`, `docs/mission_factory.md` — regras e mapa de capacidades.
- `production/catalog/episodes.json` — entrada do episódio.
- Dados do jogo consultados para sobreposição: `data/bible/stories/pilot.json` (`gen_037_joseph_sold`), `data/bible/chronology.json` (`joseph_sold`), `data/bible/places.json` (`shechem`, `dothan`), `data/bible/people.json` (`joseph`, `jacob`), `data/bible/discoveries.json` (`caravans_trade`), `data/dialogues/canaan_village.json` (Yaron), `scripts/core/game.gd`, `scripts/quests/quest_database.gd`.
- Conhecimento geral do pesquisador (IA) para contexto histórico, lexical e de recepção — **não verificado**, marcado como inferência/hipótese. Nenhuma tradução protegida foi citada.

---

## 10. Itens `needs_human_review`
1. Importar para `bpm.json` (se forem citados literalmente): `Gen 37:1`, `Gen 42:21-22`, `Gen 45:4-8`, `Gen 50:15-20`, `Gen 30:22-24`, `Gen 35:16-26`, `Gen 41:46`. Adicionar `Gen 42`, `Gen 45`, `Gen 50`, `Gen 30`, `Gen 16`, `Gen 34` a `verse_counts.json` se forem usados (KI-11).
2. Sentido da expressão traduzida "túnica de muitas cores" — conferir em léxico hebraico confiável antes de qualquer nota educativa.
3. Ismaelitas × midianitas e o sujeito de "eles puxaram" em `Gen 37:28` — decidir como o jogo parafraseia (sugestão: neutro, sem resolver).
4. `Gen 37:10` ("sua mãe") × morte de Raquel em `Gen 35:19` — decidir se o jogo menciona (sugestão: não, ep_008 começa em `37:12`).
5. Camelos na caravana (`37:25`) e possível anacronismo — decisão conjunta com o revisor histórico; o jogo mostra o que o texto diz, sem nota polêmica.
6. Valor de "vinte peças de prata" em comparação com outros textos antigos — só usar com fonte acadêmica.
7. Identificação de Dotã (Tell Dothan) e Siquém (Tell Balata) em `places.json` afirmada sem confiança — marcar `approximate`/`debated` conforme revisor histórico.
8. Nível de violência aceitável para o público do jogo e se a cena da venda é **mostrada** (apresentação) ou só **relatada** depois — decisão do criador.
9. Se `Gen 42:21-22`, `Gen 45:5-8` e `Gen 50:20` entram no ep_008 (como nota "anos depois") ou ficam para episódios posteriores.
10. `chronology_confidence` do catálogo está `not_established`; sugestão: `debated` para a época e `approximate` para a idade de José (17 anos).

---

## 11. Estimativa de produção

### Mapa
- **`canaan_village` não serve como Dotã.** É uma aldeia fictícia; o relato acontece em campos de pastoreio abertos perto de Dotã, longe de Hebrom (onde mora Jacó, `Gen 37:14`) e de Siquém. Pôr a cisterna, os irmãos ou a caravana dentro da aldeia criaria geografia falsa.
- **Recomendação:** mapa novo **pequeno** `dothan_fields` (pastagem aberta + trecho de estrada de caravana + cisterna fictícia seca + rebanho), com `region_id` próprio e região em `data/regions/`. Pode **reaproveitar quase todos os assets de ambiente** existentes (`rock_big/small`, `bush`, `tree_olive/oak`, `fence_*`, `tent`, `sacks`, `jar`, `pots`, `firepit`, `boundary_stone`, `well` como base para cisterna).
- **Alternativa de menor custo:** manter o jogador em `canaan_village`, com a parte de Dotã só em apresentação em quadros e o gancho pelo NPC Yaron (caravanas). Cumpre `obj_02`/`obj_03` sem mapa novo, mas perde `obj_01` (visit_area) e a sensação de lugar.

### Mecânicas (pelo mapa de capacidades de `docs/mission_factory.md`)
| Objetivo-semente | Situação | Observação |
|---|---|---|
| `obj_01` visit_area `dothan_fields` | Parcial com mapa novo | `scripts/core/game.gd` já registra `region_entered` ao carregar um mapa com `region_id`; com mapa novo, "chegar aos campos" vira só dados. Sub-áreas dentro do mapa (ex.: aproximar da cisterna) exigiriam gatilho de área (Area2D) — não existe. |
| `obj_02` inspect_object `trade_caravan` | Já funciona (dados) | `Interactable` com `dialogue_id` + `dialogue_finished`; NPC mercador fictício via `talk_npc`. |
| `obj_03` observe_scene `joseph_sold` | Parcial | Apresentação em quadros (`presentation_finished`) funciona; cena dirigida no mapa (atores se movendo) não existe e **não é recomendada** pelo risco de sugerir presença do jogador. |
| Travessia entre mapas | A conferir | Verificar com o integrador se já existe transição aldeia ↔ outro mapa (só `canaan_village` existe hoje). |
| Reflexão de diário | Parcial | Descoberta/flag; sem tela de reflexão escrita. |

### Assets novos
- Personagens: pastores fictícios (podem reaproveitar `npc.tscn` com variação), mercador fictício de caravana; **sem** sprites jogáveis de José/irmãos no mapa (aparecem só em quadros da apresentação, se aprovada).
- Animais: camelos (e/ou jumentos) carregados; rebanho de ovelhas/cabras (conferir se já existem sprites).
- Objetos: fardos/sacos de especiarias e resinas, cisterna seca com boca de pedra, cercado de pastagem, trecho de estrada.
- Quadros de apresentação (3–5): campo de Dotã visto de longe; caravana na estrada; túnica levada a Jacó / luto de Jacó — sóbrios, sem violência explícita, sem mostrar a agressão na cisterna em detalhe.
- Tile/terreno de pastagem mais seca e aberta (variação dos tiles atuais).
- Áudio: nenhum provedor autorizado; seguir só com texto.

**Dificuldade estimada:** alta com mapa novo (mapa + assets + transição), média sem mapa novo (só dados + apresentação), coerente com `estimate.difficulty: high` do catálogo.
