# Ficha bíblica — ep_025_rute_noemi_e_boaz · "Rute, Noemi e Boaz"

- **Episódio:** `ep_025_rute_noemi_e_boaz` (entrada em `production/catalog/episodes.json`). Modo narrativo `ficcao_contextual`; objetivo de aprendizagem "Lealdade, acolhimento e provisão"; região "Belém (recriação)"; objetivos-semente: `talk_npc fictional_harvester` (costumes da colheita), `collect_item demonstration_ears` (recolhimento didático em área fictícia), `observe_scene ruth_boaz` (principais encontros do relato).
- **Trecho central:** `Ruth 1:1-22`, `Ruth 2:1-23`, `Ruth 3:1-18`, `Ruth 4:1-22` (o livro inteiro, 85 versículos).
- **Autor:** agente `biblical-researcher` (IA). **Status:** `pending_review` — nada aqui está verificado; exige revisão humana.
- **Texto bíblico usado:** Bíblia Portuguesa Mundial (domínio público, eBible `porbrbsl`), lida diretamente do arquivo oficial `C:\TEMP\biblia\porbrbsl\porbrbsl_vpl.txt` (formato VPL). `data/bible/texts/bpm.json` contém hoje **apenas** `Ruth 1:1` do livro de Rute e nenhum dos versículos de lei usados aqui. Todos os resumos abaixo são texto próprio, não citação; as poucas palavras entre aspas são termos da BPM.
- **Independência:** ficha montada só a partir do texto bíblico; não há missão, diálogo ou descoberta de Rute no jogo hoje.

---

## 1. Referências (conferidas contra o arquivo VPL e `data/bible/verse_counts.json`)

Ids de livro existentes em `data/bible/books.json`: `Ruth`, `Lev`, `Deut`, `Judg`, `Gen`, `1Sam`, `1Chr`, `Matt`.

**Contagens no arquivo VPL (BPM):** `Ruth 1` = 22, `Ruth 2` = 23, `Ruth 3` = 18, `Ruth 4` = 22; `Lev 19` = 37; `Lev 23` = 44; `Lev 25` = 55; `Deut 23` = 25; `Deut 24` = 22; `Deut 25` = 19; `Judg 21` = 25; `Gen 19` = 38; `Gen 38` = 30; `1Sam 16` = 23; `1Chr 2` = 55; `Matt 1` = 25.

**Lacuna em `verse_counts.json`:** só constam `Ruth 1` (22, bate com o VPL) e `1Sam 16` (23, bate). **Faltam** `Ruth 2`, `Ruth 3`, `Ruth 4`, `Lev 19`, `Lev 23`, `Lev 25`, `Deut 23`, `Deut 24`, `Deut 25`, `Judg 21`, `Gen 19`, `Gen 38`, `1Chr 2`, `Matt 1` (ver KI-11; precisa ser acrescentado por quem implementar, com as contagens acima, antes de qualquer dado usar essas referências).

| Ref. | Trecho | No VPL? | Em `bpm.json`? |
|---|---|---|---|
| `Ruth 1:1-5` | Fome; família de Elimeleque vai a Moabe; mortes | Sim | Só `1:1` |
| `Ruth 1:6-18` | Volta; Noemi despede as noras; Orfa volta; Rute fica | Sim | Não |
| `Ruth 1:19-22` | Chegada a Belém; "Mara"; início da colheita da cevada | Sim | Não |
| `Ruth 2:1-7` | Boaz apresentado; Rute vai respigar; chega ao campo de Boaz | Sim | Não |
| `Ruth 2:8-16` | Boaz fala com Rute, a protege e a alimenta; ordens aos jovens | Sim | Não |
| `Ruth 2:17-23` | Um efa de cevada; Noemi identifica Boaz como resgatador; até o fim das colheitas | Sim | Não |
| `Ruth 3:1-5` | Plano de Noemi (eira, à noite) | Sim | Não |
| `Ruth 3:6-15` | Rute na eira; pedido a Boaz; resgatador mais próximo; seis medidas | Sim | Não |
| `Ruth 3:16-18` | Rute conta a Noemi; "espere" | Sim | Não |
| `Ruth 4:1-12` | Porta da cidade; dez líderes; recusa do resgatador; sandália; testemunhas e bênção | Sim | Não |
| `Ruth 4:13-17` | Casamento; nascimento de Obede; as mulheres e Noemi | Sim | Não |
| `Ruth 4:18-22` | Genealogia de Perez a Davi | Sim | Não |
| `Lev 19:9-10` | Lei: não colher os cantos nem as espigas caídas; deixar ao pobre e ao estrangeiro | Sim | Não |
| `Lev 23:22` | Mesma lei, repetida no calendário das festas | Sim | Não |
| `Deut 24:19-22` | Feixe esquecido, oliveira, vinha: para estrangeiro, órfão e viúva; lembrança do Egito | Sim | Não |
| `Lev 25:25` | Parente mais próximo resgata a terra vendida pelo irmão empobrecido | Sim | Não |
| `Deut 25:5-10` | Dever de cunhado (levirato); recusa diante dos anciãos na porta; sandália | Sim | Não |
| `Gen 38:8` | Judá manda Onã cumprir o dever de cunhado (contexto de Tamar/Perez, citado em `Ruth 4:12`) | Sim | Não |
| `Gen 19:36-37` | Origem de Moabe segundo Gênesis | Sim | Não |
| `Deut 23:3` | Moabita não entra na assembleia do SENHOR | Sim | Não |
| `Judg 21:25` | "Naqueles dias não havia rei em Israel" (moldura do período) | Sim | Não |
| `1Chr 2:9-15` | Genealogia paralela Hezrom → Davi | Sim | Não |
| `Matt 1:5` | Boaz gerou Obede "de Rute" | Sim | Não |
| `1Sam 16:1` | Jessé, "o belemita" | Sim | Sim |

---

## 2. Resumo do relato, trecho a trecho (paráfrase própria)

### Capítulo 1 — Da fome em Belém à volta com Rute
- No tempo em que os juízes governavam houve fome; um homem de Belém de Judá foi morar em Moabe com a mulher e os dois filhos (`Ruth 1:1`).
- Os nomes: Elimeleque, a mulher Noemi e os filhos Malom e Quiliom, chamados "efrateus" de Belém (`Ruth 1:2`).
- Elimeleque morreu; os filhos casaram com moabitas, Orfa e Rute; viveram ali cerca de dez anos; depois os dois filhos também morreram (`Ruth 1:3-5`). O texto não diz qual filho casou com qual mulher neste ponto; `Ruth 4:10` informa que Rute era viúva de Malom.
- Noemi soube que o SENHOR tinha dado pão ao seu povo e partiu com as noras rumo a Judá (`Ruth 1:6-7`).
- No caminho, Noemi pediu que cada uma voltasse à casa da mãe, desejou que o SENHOR as tratasse com bondade e lhes desse descanso num novo casamento; elas choraram e disseram que iriam com ela (`Ruth 1:8-10`).
- Noemi insistiu: não tinha mais filhos para lhes dar como maridos e sentia que a mão do SENHOR se voltara contra ela (`Ruth 1:11-13`).
- Orfa beijou a sogra e voltou; Rute se agarrou a ela (`Ruth 1:14`). Noemi lembrou que Orfa voltara ao seu povo e ao seu deus (`Ruth 1:15`).
- Rute declarou que iria aonde Noemi fosse, que o povo e o Deus de Noemi seriam os seus, e jurou pelo SENHOR que só a morte as separaria (`Ruth 1:16-17`). Noemi parou de insistir (`Ruth 1:18`).
- Em Belém a cidade se agitou e as mulheres perguntaram se aquela era Noemi; ela pediu para ser chamada "Mara", dizendo que saíra cheia e voltara vazia por ação do Todo-Poderoso (`Ruth 1:19-21`).
- Chegaram no começo da colheita da cevada (`Ruth 1:22`).

### Capítulo 2 — A respiga no campo de Boaz
- O narrador apresenta Boaz: parente do marido de Noemi, da família de Elimeleque, homem muito rico (`Ruth 2:1`).
- Rute pediu a Noemi para ir respigar atrás de quem a tratasse com favor; Noemi consentiu (`Ruth 2:2`).
- Ela respigou atrás dos ceifeiros e, "por acaso", estava na parte do campo que era de Boaz (`Ruth 2:3`).
- Boaz chegou de Belém, saudou os ceifeiros em nome do SENHOR e eles responderam com uma bênção (`Ruth 2:4`).
- Ele perguntou ao encarregado quem era a jovem; o encarregado explicou que era a moabita que voltara com Noemi, que pedira para respigar entre os feixes e trabalhava desde a manhã, com pouco descanso (`Ruth 2:5-7`).
- Boaz disse a Rute que ficasse no campo dele, perto das servas, que ordenara aos jovens que não a tocassem e que bebesse da água deles (`Ruth 2:8-9`).
- Rute se prostrou e perguntou por que era favorecida sendo estrangeira (`Ruth 2:10`). Boaz respondeu que soubera de tudo o que ela fizera pela sogra e de como deixara pai, mãe e terra; desejou que o SENHOR, "sob cujas asas" ela buscara refúgio, a recompensasse (`Ruth 2:11-12`). Rute agradeceu o consolo (`Ruth 2:13`).
- Na refeição, Boaz a chamou para comer pão e grão tostado; ela comeu, ficou satisfeita e sobrou (`Ruth 2:14`).
- Boaz mandou os jovens deixarem-na respigar até entre os feixes e até deixar cair espigas para ela, sem repreendê-la (`Ruth 2:15-16`).
- Até a tarde ela respigou, debulhou e obteve quase um efa de cevada; levou-o à cidade e deu a Noemi também a sobra da refeição (`Ruth 2:17-18`).
- Noemi perguntou onde ela trabalhara, abençoou quem a ajudara e, ao ouvir o nome Boaz, disse que ele era parente próximo, "um dos nossos resgatadores" (`Ruth 2:19-20`).
- Rute contou que Boaz a mandara ficar até o fim da colheita; Noemi aprovou que ela ficasse com as servas dele (`Ruth 2:21-22`).
- Rute respigou até o fim da colheita da cevada e do trigo e continuou morando com a sogra (`Ruth 2:23`).

### Capítulo 3 — A noite na eira
- Noemi disse querer buscar um "lar seguro" para Rute; lembrou que Boaz, parente, joeiraria a cevada na eira naquela noite (`Ruth 3:1-2`).
- Instruiu Rute a se banhar, perfumar e vestir as melhores roupas, descer à eira sem se revelar até ele terminar de comer e beber, notar onde ele se deitasse, descobrir-lhe os pés e deitar-se; ele diria o que fazer (`Ruth 3:3-4`). Rute aceitou e fez como a sogra mandou (`Ruth 3:5-6`).
- Boaz, depois de comer e beber, deitou-se junto ao monte de grãos; Rute se aproximou em silêncio, descobriu-lhe os pés e se deitou (`Ruth 3:7`).
- À meia-noite ele se assustou, viu uma mulher a seus pés e perguntou quem era; ela se identificou e pediu que ele estendesse sobre ela a aba da capa, "pois o senhor é um resgatador" (`Ruth 3:8-9`).
- Boaz a abençoou, disse que essa lealdade era maior que a primeira, pois ela não fora atrás de homens jovens; disse que faria o que ela pedisse e que todos sabiam que ela era "mulher virtuosa" (`Ruth 3:10-11`).
- Avisou que havia um resgatador mais próximo; de manhã, se esse quisesse resgatar, que o fizesse; senão, ele mesmo o faria, jurando pelo SENHOR (`Ruth 3:12-13`).
- Ela ficou até de manhã e saiu antes que alguém pudesse ser reconhecido, porque Boaz não queria que se soubesse que uma mulher viera à eira (`Ruth 3:14`).
- Boaz pôs seis medidas de cevada no manto dela e foi para a cidade (`Ruth 3:15`). Rute contou tudo a Noemi e repetiu que ele não queria que ela voltasse de mãos vazias (`Ruth 3:16-17`).
- Noemi disse que esperasse, pois o homem resolveria o assunto naquele mesmo dia (`Ruth 3:18`).

### Capítulo 4 — A porta da cidade e a genealogia
- Boaz sentou-se à porta da cidade; o resgatador passou e foi chamado a sentar; Boaz reuniu dez líderes da cidade (`Ruth 4:1-2`). O resgatador não é nomeado.
- Boaz expôs que Noemi vendia a terra de Elimeleque e ofereceu o resgate, primeiro ao parente mais próximo, depois a si mesmo; o homem disse que resgataria (`Ruth 4:3-4`).
- Boaz acrescentou que, ao comprar o campo, ele também "compraria de Rute", a viúva, para manter o nome do falecido sobre a herança (`Ruth 4:5`). O resgatador desistiu para não prejudicar a própria herança e cedeu o direito a Boaz (`Ruth 4:6`).
- O narrador explica um costume "antigo" em Israel: para confirmar resgate ou troca, um homem tirava a sandália e a dava ao outro; o resgatador disse a Boaz que comprasse e tirou a sandália (`Ruth 4:7-8`).
- Boaz tomou os líderes e o povo como testemunhas de que comprara tudo o que fora de Elimeleque, Quiliom e Malom, e de que tomava Rute, viúva de Malom, por mulher, para que o nome do falecido não desaparecesse (`Ruth 4:9-10`).
- O povo e os líderes confirmaram como testemunhas e abençoaram a casa de Boaz lembrando Raquel e Lia, e a casa de Perez, filho de Tamar e Judá (`Ruth 4:11-12`).
- Boaz casou com Rute; o SENHOR lhe concedeu conceber e ela teve um filho (`Ruth 4:13`).
- As mulheres bendisseram o SENHOR por não deixar Noemi sem resgatador e disseram que a nora, que a ama, valia mais que sete filhos (`Ruth 4:14-15`). Noemi tomou o menino no colo e cuidou dele (`Ruth 4:16`).
- As vizinhas o chamaram Obede e disseram "nasceu um filho a Noemi"; o narrador diz que ele foi pai de Jessé, pai de Davi (`Ruth 4:17`).
- Genealogia: Perez, Hezrom, Rão, Aminadabe, Naassom, Salmom, Boaz, Obede, Jessé, Davi (`Ruth 4:18-22`).

---

## 3. Personagens bíblicos (apenas o que o texto diz)

| Personagem | O que o texto registra | Refs. |
|---|---|---|
| **Rute** | Moabita, viúva de Malom; fica com a sogra e declara fidelidade a ela, ao povo e ao Deus dela; respiga para sustentar a casa; pede a Boaz que a cubra com a capa por ser resgatador; chamada "mulher virtuosa"; casa com Boaz e é mãe de Obede. Aparece em `Matt 1:5`. | `Ruth 1:4`, `1:14-18`, `2:2-23`, `3:5-17`, `4:10`, `4:13-15`; `Matt 1:5` |
| **Noemi** | De Belém; perde marido e filhos em Moabe; volta; pede para ser chamada Mara; envia Rute a respigar; reconhece Boaz como resgatador; planeja a ida à eira; vende a terra de Elimeleque; cuida de Obede. | `Ruth 1:2-22`, `2:2`, `2:19-22`, `3:1-4`, `3:18`, `4:3`, `4:14-17` |
| **Boaz** | Parente de Elimeleque, homem muito rico; saúda os ceifeiros em nome do SENHOR; protege e alimenta Rute; é resgatador, mas não o mais próximo; resolve o caso na porta diante de testemunhas; casa com Rute; filho de Salmom, pai de Obede. | `Ruth 2:1-23`, `3:7-15`, `4:1-13`, `4:21`; `1Chr 2:11-12`; `Matt 1:5` |
| **Orfa** | Moabita, nora de Noemi; inicialmente quer ir com ela; depois beija a sogra e volta "ao seu povo e ao seu deus". O texto não a censura. | `Ruth 1:4`, `1:10`, `1:14-15` |
| **Elimeleque** | Marido de Noemi; leva a família a Moabe; morre lá; sua terra é resgatada. | `Ruth 1:1-3`, `4:3`, `4:9` |
| **Malom e Quiliom** | Filhos de Elimeleque e Noemi; casam com moabitas; morrem. Rute era viúva de Malom. | `Ruth 1:2-5`, `4:9-10` |
| **O resgatador mais próximo** | Anônimo; aceita resgatar a terra, desiste ao saber da parte de Rute; cede o direito e tira a sandália. | `Ruth 3:12-13`, `4:1-8` |
| **Servo encarregado dos ceifeiros** | Anônimo; informa Boaz sobre Rute. | `Ruth 2:5-7` |
| **Ceifeiros, jovens e servas de Boaz** | Anônimos; respondem à saudação; recebem ordens sobre Rute. | `Ruth 2:4`, `2:8-9`, `2:15-16`, `2:21-23` |
| **Mulheres de Belém / vizinhas** | Perguntam por Noemi na chegada; bendizem o SENHOR no nascimento; dão o nome a Obede. | `Ruth 1:19`, `4:14-17` |
| **Dez líderes (anciãos) e o povo na porta** | Testemunhas; abençoam Boaz e a casa dele. | `Ruth 4:2`, `4:9-12` |
| **Obede** | Filho de Boaz e Rute; pai de Jessé, avô de Davi. | `Ruth 4:13-17`, `4:21-22` |
| **O SENHOR** | Não fala no livro. É mencionado em bênçãos, juramentos e na narração: dá pão ao povo (`1:6`) e concede a gravidez de Rute (`4:13`). | `Ruth 1:6`, `1:8-9`, `2:4`, `2:12`, `2:20`, `3:10`, `3:13`, `4:11-14` |

**Falas registradas (todas no texto; qualquer outra seria invenção):**
- Noemi: `1:8-9`, `1:11-13`, `1:15`, `1:20-21`, `2:2b`, `2:19-20`, `2:22`, `3:1-4`, `3:16`, `3:18`.
- Rute: `1:16-17`, `2:2a`, `2:10`, `2:13`, `2:19b`, `2:21`, `3:5`, `3:9`, `3:17`; com Orfa, em coro, `1:10`. Rute não fala no capítulo 4.
- Boaz: `2:4a`, `2:5`, `2:8-9`, `2:11-12`, `2:14`, `2:15-16`, `3:9a`, `3:10-13`, `3:14b` (citado), `3:15`, `4:1-5`, `4:9-10`.
- Orfa: só a fala coletiva de `1:10`.
- Outros: ceifeiros `2:4b`; encarregado `2:6-7`; resgatador `4:4b`, `4:6`, `4:8`; mulheres `1:19`, `4:14-15`, `4:17`; povo e líderes `4:11-12`.

---

## 4. Gênero literário
**Narrativa** em prosa, curta e de enredo fechado (crise → retorno → encontro → resolução legal → nascimento), com **diálogos extensos**, **bênçãos e juramentos** (`1:8-9`, `1:17`, `2:12`, `3:10`, `3:13`, `4:11-12`, `4:14`), uma **nota explicativa do narrador** sobre costume antigo (`4:7`) e uma **genealogia** final (`4:18-22`). Não é parábola nem texto simbólico (a leitura tipológica de Boaz como figura de redenção é **interpretação**, não gênero do texto).

---

## 5. Linha do tempo

| Marco | O que se apoia no texto | `chronology_confidence` |
|---|---|---|
| Período dos juízes | `Ruth 1:1` ("nos dias em que os juízes julgavam"); o jogo já tem `judges` em `data/bible/chronology.json` com `Ruth` em `books` e certeza `approximate` | `documented` como período relativo; datas absolutas do período `approximate`/`debated` — **não atribuir ano à história de Rute** (`null`) |
| Em qual momento do período dos juízes | O texto não diz qual juiz nem em que década | `unknown` |
| Estada em Moabe | "Cerca de dez anos" (`Ruth 1:4`) | `documented` (número aproximado no próprio texto) |
| Chegada a Belém | Começo da colheita da cevada (`Ruth 1:22`) | `documented` (estação relativa); mês exato `approximate` (primavera no calendário agrícola de Canaã — contexto histórico, não dito no texto) |
| Duração da respiga | Até o fim da colheita da cevada e do trigo (`Ruth 2:23`) | `documented` (relativa); semanas exatas `unknown` |
| Eira e porta da cidade | Noite da joeira (`3:2`) e o dia seguinte (`3:18`, `4:1`) | `documented` (sequência relativa) |
| Distância até Davi | Obede → Jessé → Davi (`4:17`, `4:22`); paralelo `1Chr 2:12-15` | `documented` (sequência); se a genealogia é completa ou seletiva é `debated` |
| Ano absoluto | Nenhum | `null` |

---

## 6. Três colunas: texto × inferência × ficção do jogo

| O que o texto diz | Inferência ou hipótese histórica | O que seria ficção do jogo |
|---|---|---|
| Fome levou a família a Moabe; "dez anos" (`Ruth 1:1-4`). | Migração por fome entre regiões vizinhas era comum (contexto geral). | Morador fictício de Belém que lembra "os anos de fome", sem citar a família como amigo íntimo. |
| Rute declara fidelidade à sogra, ao povo e ao Deus dela (`Ruth 1:16-17`). | Leituras como "conversão" de Rute são **interpretação**; o texto registra a declaração, não um rito. | Nada: a cena pertence a Rute e Noemi; no máximo, uma apresentação em quadros com paráfrase referenciada. |
| Noemi chega "vazia" e pede o nome Mara (`Ruth 1:20-21`). | Viúva sem filhos homens ficava vulnerável economicamente (contexto social, `historical_context`). | Moradoras fictícias comentando a chegada **depois** do fato, como relato. |
| Lei: deixar cantos, espigas caídas e feixes esquecidos ao pobre, ao estrangeiro, ao órfão e à viúva (`Lev 19:9-10`, `Lev 23:22`, `Deut 24:19-22`). | Rute, estrangeira e viúva, se encaixa nos grupos protegidos — **ligação feita pelo leitor**; o livro de Rute não cita essas leis. | Ceifeiro fictício explicando o costume da respiga num campo fictício; demonstração didática. |
| Rute chega "por acaso" ao campo de Boaz (`Ruth 2:3`). | Muitos leem o "acaso" como providência discreta — **interpretação** (`devotional_educational`). | Reflexão do viajante no diário, marcada como reflexão. |
| Boaz manda deixar espigas cair de propósito (`Ruth 2:15-16`). | Generosidade além da exigência legal (inferência a partir da comparação com `Lev 19:9`). | Ceifeiro fictício de outro campo comentando que "há quem deixe mais do que a lei pede" — sem nomear Boaz como testemunha direta. |
| Quase um efa de cevada (`Ruth 2:17`). | O volume de um efa é estimado por estudiosos (valores variam) — **conferir em fonte**. | Medida demonstrativa no cesto didático, sem cifra exata. |
| Noemi chama Boaz de "resgatador" (`Ruth 2:20`, `3:9`, `3:12`). | Resgate de terra pelo parente próximo (`Lev 25:25`) e dever de cunhado (`Deut 25:5-10`) são as leis próximas; Rute combina elementos de ambas sem ser idêntica a nenhuma (inferência comparativa — ver Riscos). | Placa/diário educativo sobre "resgatador" com refs., classificado `historical_context`. |
| Noite na eira; pedido de Rute; segredo (`Ruth 3:1-14`). | Sentido do gesto "descobrir os pés" e de "estender a aba da capa" é **debatido** (pedido de proteção/casamento é leitura comum). | **Nenhuma** presença do jogador. A eira de dia, fora do episódio, pode ser cenário de joeira com trabalhadores fictícios. |
| Sandália e testemunhas na porta (`Ruth 4:1-11`). | Porta da cidade como lugar de julgamentos e negócios (contexto, também em `Deut 25:7`). O próprio narrador diz que o costume era "antigo" (`4:7`). | Morador fictício no mercado fala do costume da porta em geral; o jogador pode ver a porta vazia ou movimentada antes/depois, nunca votar ou testemunhar. |
| Obede, pai de Jessé, pai de Davi (`Ruth 4:17-22`). | O livro liga a história à monarquia; o propósito exato da genealogia é discutido. | Mural/diário de genealogia com refs. e ponte para o episódio de Davi. |

---

## 7. Oportunidades de exploração (viajante fictício, sem alterar o relato)
1. **Costumes da colheita (obj_01):** conversa com um ceifeiro fictício (`fictional_harvester`) sobre foice, feixes, cantos do campo, espigas caídas, cevada antes do trigo — `historical_context` com refs. de `Lev 19:9-10` e `Deut 24:19`.
2. **Recolhimento didático (obj_02):** num **campo fictício** (não o de Boaz), o viajante, como estrangeiro de passagem, aprende a respigar atrás de ceifeiros fictícios; as espigas recolhidas vão para uma **viúva fictícia** da vizinhança (não para Noemi), reforçando "provisão" sem tocar o relato. Classificação `plausible_fiction` + nota `historical_context`. As espigas não são recompensa nem item de poder (regra 12).
3. **Encontros do relato (obj_03):** `observe_scene ruth_boaz` como **apresentação em quadros** com paráfrase referenciada: (a) chegada a Belém (`1:19-22`), (b) Rute no campo e o diálogo com Boaz (`2:8-13`), (c) a porta da cidade (`4:1-11`), (d) nascimento de Obede (`4:13-17`). A eira (`3`) pode ser **resumida em texto**, sem quadro visual íntimo.
4. **Belém como lugar:** casas, poço, eira (de dia, trabalho de joeira), porta da cidade com bancos e anciãos fictícios em outros assuntos; mulheres fictícias que comentam a volta de Noemi como notícia já ocorrida.
5. **Diário:** "Quem é um resgatador?" (`Lev 25:25`, `Deut 25:5-10`, `Ruth 4:1-10`), "Moabe" (`Gen 19:37`, `Ruth 1:4`), "De Rute a Davi" (`Ruth 4:17-22`, `1Chr 2:9-15`, `Matt 1:5`).
6. **Ponte com outros episódios:** Davi de Belém (`1Sam 16:1`) já existe no catálogo de dados; Tamar/Perez (`Gen 38`, citado em `Ruth 4:12`) só como menção.

**Restrições de design sugeridas (`design_constraints`):**
- O jogador **não** é quem acolhe Rute, não a orienta a ir ao campo de Boaz, não a apresenta a Boaz e não lhe dá espigas ou comida no lugar de Boaz.
- O jogador **não** vai à eira na noite de `Ruth 3`, não sabe do encontro e não o comenta (o texto registra que Boaz quis segredo, `3:14`).
- O jogador **não** está entre os dez líderes, não é testemunha registrada, não convence o resgatador nem interfere no resgate (`4:1-11`).
- Rute, Noemi e Boaz não recebem falas além das registradas, sempre como paráfrase com referência; nada de diálogo livre deles com o viajante.
- O campo de respiga do jogador é fictício e identificado como tal.

---

## 8. Riscos (fáceis de distorcer)
- **Romantização de `Ruth 3`:** não tratar a eira como cena de romance ou sedução, nem como insinuação sexual; o texto é reticente e enfatiza "lealdade" (`3:10`), "resgatador" (`3:9`, `3:12-13`) e reputação (`3:11`, `3:14`). Também não "limpar" o texto afirmando o contrário do que ele diz. O sentido de "descobrir os pés" é debatido — não afirmar nenhuma leitura como fato. Público inclui crianças: preferir resumo textual sóbrio.
- **Romance moderno entre Rute e Boaz:** o texto não descreve sentimentos amorosos entre eles; a palavra "ama" aparece para Rute em relação a **Noemi** (`4:15`). Evitar "história de amor" como chave principal.
- **Moabitas:** não tratar Orfa como vilã (o texto não a condena) nem os moabitas como caricatura. Há tensão entre `Deut 23:3` (moabita excluído da assembleia) e Rute na linhagem de Davi; harmonizações existem — **interpretação**, não resolver no jogo. A origem de Moabe em `Gen 19:36-37` é tema adulto; se mencionado, com sobriedade.
- **Costumes legais:** Boaz **não é cunhado** de Rute; o caso não segue exatamente `Deut 25:5-10` (lá a viúva tira a sandália do cunhado que recusa e cospe; em `Ruth 4:7-8` o próprio resgatador tira a sandália como sinal de transação). Não apresentar Rute 4 como aplicação literal do levirato nem afirmar como funcionava em detalhe o resgate "naquele tempo".
- **`Ruth 4:5` ("comprar de Rute"):** a BPM diz que o campo seria comprado também "de Rute"; há variação textual/de tradução neste versículo (memória do pesquisador — `needs_human_review`). Não construir explicação jurídica em cima de uma única forma.
- **"Comprou Rute" (`4:10`):** a linguagem de aquisição pode soar como venda de pessoa; explicar como fórmula legal ligada à herança, sem anacronismo, e sem minimizar.
- **Genealogia de Davi:** `Ruth 4:18-22` e `1Chr 2:9-15` concordam na sequência, mas com grafia diferente (Salmom/Salma); `Matt 1:5` acrescenta Raabe como mãe de Boaz — dado que **não está em Rute**. Não afirmar que a genealogia é completa (pode ser seletiva — `debated`). Não apresentar ligações messiânicas como conteúdo do livro de Rute; se mencionadas, citar `Matt 1:5` e marcar como leitura do NT.
- **Atribuir falas trocadas:** "nasceu um filho a Noemi" é das vizinhas (`4:17`), não de Noemi; "melhor do que sete filhos" é das mulheres (`4:15`); a bênção de Raquel e Lia é do povo e dos líderes (`4:11`), não de Boaz.
- **"Por acaso" (`2:3`):** não transformar em milagre nem em ação do jogador.
- **Espigas como recompensa:** a provisão no texto é atribuída ao SENHOR (`1:6`) e à generosidade de Boaz; no jogo, coleta não pode virar moeda, poder ou item colecionável sagrado.
- **Belém:** cidade de Davi e de Jesus — evitar elementos anacrônicos do NT (estrela, manjedoura) no cenário de Rute.
- **"Homem muito rico" (`2:1`):** outras traduções vertem com sentido de valor/força; nuance lexical a conferir.

---

## 9. Fontes consultadas
- Bíblia Portuguesa Mundial (domínio público), eBible `porbrbsl`, arquivo `C:\TEMP\biblia\porbrbsl\porbrbsl_vpl.txt`: `Ruth 1-4` integral; `Lev 19:9-10`, `Lev 23:22`, `Lev 25:25`, `Deut 23:3`, `Deut 24:19-22`, `Deut 25:5-10`, `Gen 19:36-37`, `Gen 38:8`, `Judg 21:25`, `1Sam 16:1`, `1Chr 2:9-15`, `Matt 1:5`.
- `data/bible/texts/bpm.json` (mesma tradução; contém só `Ruth 1:1` e `1Sam 16:1` dos trechos acima).
- `data/bible/books.json`, `data/bible/verse_counts.json` — ids de livro e validação (lacunas listadas na seção 1).
- `data/bible/chronology.json` (período `judges`), `data/bible/places.json` (`bethlehem`).
- `docs/ai-wiki/BIBLICAL_RULES.md`, `docs/mission_factory.md`, `production/catalog/episodes.json`.
- Conhecimento geral do pesquisador (IA) para contexto histórico, lexical e de variantes — **não verificado**, marcado como inferência/hipótese. Nenhuma tradução protegida foi citada.

---

## 10. Itens `needs_human_review`
1. Acrescentar a `data/bible/verse_counts.json` os capítulos `Ruth 2` (23), `Ruth 3` (18), `Ruth 4` (22) e os de lei/genealogia que forem usados (contagens na seção 1), e importar para `bpm.json` os versículos citados — tarefa de implementação, não desta ficha.
2. `Ruth 4:5`: possível variação textual ("de Rute" × "Rute"); conferir em fonte acadêmica antes de qualquer texto explicativo.
3. Sentido de "descobrir os pés" (`3:4`, `3:7`) e "estender a aba da capa" (`3:9`): decidir com o criador como o jogo resume a cena (sugestão: resumo textual sóbrio, sem quadro visual íntimo).
4. Relação entre `Ruth 4` e as leis de `Lev 25:25` e `Deut 25:5-10`: confirmar a formulação educativa com revisor humano.
5. Tensão `Deut 23:3` × Rute na linhagem de Davi: decidir se o jogo menciona (sugestão: não, ou como questão em aberto).
6. Volume de um efa (`2:17`) e das "seis medidas" (`3:15`, unidade não especificada no texto) — conferir em fonte; preferir não dar números.
7. Nuance de "homem muito rico" (`2:1`) e "mulher virtuosa" (`3:11`) — mesma família de palavras no hebraico, segundo memória do pesquisador; conferir em léxico.
8. Genealogia seletiva ou completa; grafia Salmom/Salma; Raabe (`Matt 1:5`) — decidir o que o diário mostra.
9. Estação da colheita da cevada e do trigo (mês aproximado) e localização da eira e dos campos em relação à cidade — `historical_context`, conferir.
10. Se a "viúva fictícia" do recolhimento didático é aceitável ou se espelha demais Noemi — decisão editorial.

---

## 11. Estimativa de produção

**Mapa novo — "Belém (recriação)"** (`estimate.new_map_needed: true`; hoje só existe `canaan_village`):
- Núcleo da cidade com casas (reaproveitar `house_small`, `house_wide`, `oven`, `jar`, `pots`, `well`).
- **Porta da cidade** com bancos de pedra e espaço para reunião (novo).
- **Campos de cevada** (e trigo) em faixas, com ceifeiros fictícios; um campo fictício separado e sinalizado para o recolhimento didático.
- **Eira** (área plana batida, monte de grãos, ferramentas de joeira) — visitável só de dia, sem ligação à noite de `Ruth 3`.
- Caminho de chegada (de Moabe) pode ser só borda do mapa.

**Mecânicas (mapa de capacidades em `docs/mission_factory.md`):**
| Objetivo-semente | Situação no motor | O que falta |
|---|---|---|
| `talk_npc fictional_harvester` | já funciona (só dados) | nada além de NPC, diálogo e evento `custom`/`dialogue_finished` |
| `collect_item demonstration_ears` | **não existe** (falta inventário) | mínimo: alvos de coleta no campo (Interactable repetível que some ao recolher) + contador/flag por objetivo, e entrega à viúva fictícia; inventário completo não é necessário. Alternativa só com dados: N `inspect_object` em espigas + `help_npc` na entrega (pior experiência). A confirmar pelo designer/implementador se o QuestManager aceita contagem. |
| `observe_scene ruth_boaz` | parcial | usar apresentação em quadros (`presentation_finished`); cena dirigida no mapa não existe e **não é recomendada** aqui |
| (sugerido) visitar porta/eira | **não existe** (`visit_area`) | gatilho de área (Area2D → evento) ou substituir por `inspect_object` |

**Assets novos (estimativa, para o `visual-asset-producer` confirmar):**
- Tiles: campo de cevada (em pé, ceifado), restolho, chão batido de eira, muro/portão de cidade.
- Objetos: feixes, espigas caídas (alvo de coleta), foice, cesto de respiga (pode reaproveitar `basket`), monte de grãos, forquilha/pá de joeira, bancos da porta, vasilhas de água (`jar`).
- Personagens fictícios: ceifeiros, ceifeiras/servas, viúva fictícia, anciãos/moradores (variações de sprites existentes).
- Apresentação: ilustrações para os quadros de Rute, Noemi, Boaz, a porta e o nascimento (personagens bíblicos só em quadros, não como NPCs livres no mapa).
- Dificuldade geral: **alta** (mapa novo + mecânica de coleta), coerente com o catálogo.
