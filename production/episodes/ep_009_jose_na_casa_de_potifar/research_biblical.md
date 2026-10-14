# Ficha bíblica — ep_009_jose_na_casa_de_potifar · "José na casa de Potifar"

- **Episódio:** `ep_009_jose_na_casa_de_potifar` (catálogo: modo `observacao_contextual`; objetivo de aprendizagem "Integridade diante da injustiça"; região "Egito (recriação)"; referência do catálogo `Gen 39:1-23`; objetivos-semente `obj_01` visit_area `egyptian_house`, `obj_02` inspect_object `household_records`, `obj_03` observe_scene `joseph_imprisoned`, todos `placeholder`).
- **Experiência no Mapa das Escrituras:** `joseph_egypt` ("José no Egito", `data/world/experiences.json`, hoje `planned`, referência `Gen 39:1-6`, lugar "Caminho para o Egito · Egito de José").
- **Escopo decidido pelo criador para esta experiência:**
  1. cena **jogável de observação** — o viajante vê **de longe** a caravana que leva José (`Gen 37:25-28`, `Gen 37:36`), sem interferir;
  2. parte principal no Egito: `Gen 39:1-6`.
  - Esta ficha recomenda **deixar `Gen 39:7-23` fora** (seção 8). Isso diverge da referência do catálogo (`Gen 39:1-23`) e do `obj_03` (`joseph_imprisoned`) — ver itens para decisão humana.
- **Autor:** agente `biblical-researcher` (IA). **Status de tudo:** `pending_review`. Nada aqui está verificado nem aprovado; aprovação só humana.
- **Texto bíblico usado:** Bíblia Portuguesa Mundial (BPM, domínio público, eBible.org `porbrbsl`), lida no arquivo oficial `C:\TEMP\biblia\porbrbsl\porbrbsl_vpl.txt` e comparada com `data/bible/texts/bpm.json`. Todos os resumos abaixo são **paráfrase própria**; nenhum versículo deve ser copiado desta ficha para o jogo (citações literais só via `bpm.json`).
- **Reaproveitamento:** `Gen 37` já foi pesquisado em `production/episodes/ep_008_jose_e_seus_irmaos/research_biblical.md` (citado aqui como **[F008 §n]**) e revisado em `ep_008…/review.json` (achados B1–B12, N1–N3, H1–H5). Esta ficha não repete aquela pesquisa; só acrescenta o que a cena da caravana e `Gen 39` exigem.

---

## 1. Referências (conferidas)

Livros `Gen`, `Ps`, `Acts`, `Lev`, `Exod` existem em `data/bible/books.json`. Contagens: `verse_counts.json` traz `Gen 37` = 36, `Gen 39` = 23, `Gen 40` = 23, `Gen 41` = 57, `Gen 42` = 38 — todas batem com o VPL. **Não traz** `Ps 105`, `Acts 7`, `Lev 27`, `Exod 21`, `Gen 43`, `Gen 45`, `Gen 46`, `Gen 16`, `Gen 25` completos (KI-11); contagem no VPL: `Ps 105` = 45, `Acts 7` = 60, `Lev 27` = 34, `Exod 21` = 36 (as demais já constam em F008 §1).

### Trechos centrais

| Ref. | Trecho | VPL oficial | `bpm.json` |
|---|---|---|---|
| `Gen 37:21-22` | Rúben impede a morte e propõe a cisterna | Sim | Sim |
| `Gen 37:25` | Refeição; caravana de ismaelitas de Gileade; camelos com especiarias, bálsamo e mirra rumo ao Egito | Sim | Sim |
| `Gen 37:26-27` | Proposta de Judá | Sim | Sim |
| `Gen 37:28` | Midianitas passam; José tirado da cisterna; vendido aos ismaelitas por vinte peças de prata; levado ao Egito | Sim | Sim |
| `Gen 37:29-30` | Rúben volta e não encontra José | Sim | Sim |
| `Gen 37:36` | Midianitas vendem José a Potifar no Egito | Sim | Sim |
| `Gen 39:1` | Potifar, egípcio, compra José dos ismaelitas | Sim | Sim |
| `Gen 39:2-3` | O SENHOR com José; prosperidade; Potifar percebe | Sim | Sim |
| `Gen 39:4` | Favor; José serve Potifar e é posto como administrador | Sim | Sim |
| `Gen 39:5` | Bênção sobre a casa do egípcio por causa de José, na casa e no campo | Sim | Sim |
| `Gen 39:6` | Potifar deixa tudo com José, exceto a comida; aparência de José | Sim | Sim |
| `Gen 39:7-23` | Esposa de Potifar; acusação; prisão; o SENHOR com José na prisão | Sim | **Não** (`bpm.json` só tem `39:1-6`) |

### Ecos e apoio (fora da cena; só notas, se aprovadas)

| Ref. | Uso possível | VPL | `bpm.json` |
|---|---|---|---|
| `Gen 16:15`, `Gen 25:2`, `Gen 25:12` | Ismael e Midiã como filhos de Abraão (contexto dos nomes) | Sim | Não |
| `Gen 40:3-4`, `Gen 41:12` | "Capitão da guarda" reaparece; José depois chamado "servo do capitão da guarda" | Sim | Não |
| `Gen 40:15` | José, mais tarde, diz que foi "roubado" da terra dos hebreus | Sim | Não |
| `Gen 41:1`, `Gen 41:46` | "Dois anos inteiros"; José com 30 anos diante do Faraó | Sim | Não |
| `Gen 42:21` | Irmãos lembram que José implorou (sem conteúdo da fala) | Sim | Não |
| `Gen 43:32`, `Gen 46:34` | Egípcios não comiam com hebreus; pastores eram abominação para egípcios | Sim | Não |
| `Gen 45:4` | José: "a quem vocês venderam para o Egito" | Sim | Não |
| `Ps 105:17-22` | Releitura poética: José vendido como escravo, grilhões, depois exaltado | Sim | Não |
| `Acts 7:9-10` | Estêvão: os patriarcas, por inveja, venderam José; Deus estava com ele | Sim | Não |
| `Lev 27:5`, `Exod 21:32` | Valores em siclos de prata em leis posteriores (comparação, não explicação) | Sim | Não |

Qualquer citação literal fora de `Gen 37:2-36` e `Gen 39:1-6` exige importar antes (`tools/import_scripture.gd`) e acrescentar o capítulo a `verse_counts.json` se ele faltar.

---

## 2. Resumo do relato, trecho a trecho (paráfrase própria)

### Parte A — A caravana (resumo; detalhes em F008 §2)
- Rúben convence os irmãos a não matar José e a jogá-lo numa cisterna, com a intenção (dita pelo narrador) de devolvê-lo depois ao pai (`Gen 37:21-22`).
- Com José na cisterna vazia, os irmãos sentam-se para comer e veem chegar uma caravana de **ismaelitas** vinda de **Gileade**; os **camelos** levam **especiarias, bálsamo e mirra**, descendo para o Egito (`Gen 37:25`). O texto não diz quantos eram nem quantos animais.
- **Judá** pergunta que proveito haveria em matar o irmão e esconder o sangue e propõe vendê-lo aos ismaelitas, lembrando que é irmão e "carne" deles; os irmãos concordam (`Gen 37:26-27`).
- Passam **mercadores midianitas**; José é tirado da cisterna e vendido aos ismaelitas por **vinte peças de prata**, e os mercadores o levam para o Egito (`Gen 37:28`). O sujeito de "tiraram" é ambíguo (F008 §8).
- **Rúben** volta à cisterna, não encontra José, rasga as roupas e diz aos irmãos que o menino não está lá (`Gen 37:29-30`). O texto dá a entender que ele não presenciou a venda, mas não diz onde estava.
- No Egito, os **midianitas** vendem José a **Potifar**, oficial do Faraó, capitão da guarda (`Gen 37:36`).

### Parte B — Na casa de Potifar (`Gen 39:1-6`)
- José é levado ao Egito; Potifar — oficial do Faraó, capitão da guarda, egípcio — o compra dos **ismaelitas** que o tinham levado (`Gen 39:1`).
- O SENHOR estava com José, e ele prosperou; José estava na casa do seu senhor egípcio (`Gen 39:2`).
- Potifar percebe que o SENHOR estava com José e fazia prosperar o que ele fazia (`Gen 39:3`). O texto não diz **como** Potifar percebeu.
- José ganha o favor de Potifar, passa a servi-lo e é posto como **administrador da casa**, com tudo o que Potifar tinha sob seus cuidados (`Gen 39:4`).
- A partir daí, o SENHOR abençoa a casa do egípcio **por causa de José**, e a bênção alcança o que ele tinha **na casa e no campo** (`Gen 39:5`).
- Potifar deixa tudo nas mãos de José e não se ocupa de nada além da comida que comia (`Gen 39:6a`). O narrador acrescenta que José tinha bela aparência (`Gen 39:6b`) — frase que prepara o trecho seguinte.

### Parte C — O resto do capítulo (fora do escopo recomendado; resumo só para a decisão)
- A esposa de Potifar assedia José repetidamente; ele recusa, dizendo que não trairia a confiança do seu senhor nem pecaria contra Deus (`Gen 39:7-10`).
- Num dia em que não havia outros homens da casa, ela o agarra pela veste; ele foge deixando a veste (`Gen 39:11-12`). Ela o acusa falsamente diante dos servos e de Potifar (`Gen 39:13-18`).
- Potifar se ira e põe José na prisão onde ficavam os presos do rei (`Gen 39:19-20`).
- Na prisão, o SENHOR continua com José; o carcereiro lhe dá responsabilidade sobre os presos, e o que ele faz prospera (`Gen 39:21-23`).

---

## 3. Personagens bíblicos (apenas o que o texto diz) e o que não pode ser inventado

| Personagem | O que o texto registra | Refs. | Não inventar |
|---|---|---|---|
| **José** | Vendido; levado ao Egito; comprado por Potifar; o SENHOR com ele; prospera; serve Potifar; administrador; aparência bela. | `Gen 37:28`, `37:36`; `Gen 39:1-6` | **Nenhuma fala de José em `Gen 37:17-36` nem em `Gen 39:1-6`.** Sem súplicas, choro, orações, pensamentos, idioma aprendido, nome egípcio (só aparece em `Gen 41:45`, fora do escopo), tarefas específicas, conversas com servos. |
| **Rúben** | Impede a morte; propõe a cisterna; volta e não encontra José. | `Gen 37:21-22`, `37:29-30` | Onde estava durante a venda; tentativa de seguir a caravana. |
| **Judá** | Propõe a venda (proveito + parentesco). | `Gen 37:26-27` | Negociação de preço; fala com os mercadores. |
| **Irmãos (coletivo)** | Comem; veem a caravana; concordam; vendem (sujeito debatido). | `Gen 37:25-28` | Falas novas; quem segurou José; quem recebeu a prata; divisão do dinheiro. |
| **Ismaelitas** | Caravana de Gileade rumo ao Egito; compram José; vendem-no a Potifar (`39:1`). | `Gen 37:25-28`, `Gen 39:1` | Nomes, número, maus-tratos, correntes, chicote, falas, motivação. |
| **Midianitas** | Mercadores que passam; vendem José a Potifar (`37:36`). | `Gen 37:28`, `37:36` | Explicação da relação com os ismaelitas. |
| **Potifar** | Oficial do Faraó; capitão da guarda; egípcio; compra José; percebe o SENHOR com ele; confia-lhe a casa; só cuida da própria comida. | `Gen 37:36`; `Gen 39:1-6` | **Nenhuma fala.** Aparência, caráter, religião, família além da esposa (fora do escopo), título além do texto, onde morava, quanto pagou. |
| **Faraó** | Mencionado só como senhor de Potifar. | `Gen 37:36`, `Gen 39:1` | Nome do Faraó, dinastia, aparição. |
| **Esposa de Potifar** | Só em `Gen 39:7-19`. | — | **Fora desta experiência** (seção 8); não aparece nem é aludida. |

**Falas registradas no escopo recomendado:** em `Gen 37:25-30`, só Judá (`37:26-27`) e Rúben (`37:30`). Em `Gen 39:1-6`, **nenhuma fala**. Personagens bíblicos, portanto, não falam na experiência; quando necessário, aparecem por paráfrase identificada com referência, narrada.

---

## 4. Gênero literário
**Narrativa** em prosa (ciclo de José em Gênesis). `Gen 39:1-6` é um **sumário narrativo** de um período sem cenas nem diálogos: o narrador resume tempo e resultado, com comentário teológico explícito ("o SENHOR estava com José", `39:2-3`, `39:5`). Ecos: `Ps 105:17-22` é **poesia** (salmo histórico), não relato paralelo detalhado; `Acts 7:9-10` é **discurso** narrado dentro de narrativa (fala de Estêvão).

---

## 5. Linha do tempo (sem datas)

| Marco | Apoio no texto | `chronology_confidence` |
|---|---|---|
| Época (patriarcal, Egito de um Faraó não nomeado) | Ordem relativa de Gênesis; Faraó sem nome | `debated` — **não atribuir ano nem dinastia** (`null`) |
| Venda em Dotã → chegada ao Egito | `Gen 37:28`, `37:36`, `Gen 39:1`; duração da viagem não informada | ordem `documented`; duração `unknown` |
| Idade de José | 17 anos em `Gen 37:2`; intervalo até `37:12` não informado | `approximate` (~17) |
| Tempo na casa de Potifar | Não informado. Só se sabe que `39:7` começa "depois destas coisas" | `unknown` |
| Até José diante do Faraó | 30 anos em `Gen 41:46`; inclui a prisão e "dois anos inteiros" (`Gen 41:1`) | `approximate` (≈13 anos no total; a divisão casa/prisão é `unknown`) |
| Relação com `Gen 38` (Judá e Tamar), inserido entre 37 e 39 | `Gen 38:1` "naquele tempo" | `debated`; não usar como marcador |

Recomendação: a passagem narrativa ("OUTRO MOMENTO DA HISTÓRIA") deve dizer que o texto **não informa** quanto tempo durou a viagem nem quanto tempo José ficou na casa antes de se tornar administrador.

---

## 6. Três colunas: texto × inferência/hipótese × ficção do jogo

| O que o texto diz | Inferência ou hipótese histórica | O que seria ficção do jogo |
|---|---|---|
| Caravana de **ismaelitas** de Gileade, rumo ao Egito (`Gen 37:25`); **midianitas** passam e depois vendem José a Potifar (`37:28`, `37:36`); Potifar o compra dos **ismaelitas** (`39:1`). | Hipóteses: termos sobrepostos para mercadores nômades; dois grupos envolvidos; costura de tradições literárias — **debatido** (F008 §6). `Gen 16:15` e `Gen 25:2` ligam ambos os nomes a Abraão — dado do texto, mas a relação com a cena não é explicada. | Nada; não resolver no jogo. Nota possível: "o texto usa os dois nomes". Mercadores fictícios **não** são ismaelitas nem midianitas do relato. |
| Camelos carregando especiarias, bálsamo e mirra (`Gen 37:25`). | Uso de camelos na era patriarcal é debatido (ep_008 H1: caravanas fictícias com jumentos; camelos só na caravana do texto). Identificação botânica exata das resinas é debatida. | Na cena de observação, a caravana do relato pode ter camelos porque o texto diz; sem nota histórica tomando partido. Caravanas fictícias continuam com jumentos. |
| Vinte peças de prata (`Gen 37:28`). | Prata pesada, não moeda (ep_008 N2, `Gen 23:16`). `Lev 27:5` fixa depois 20 siclos como avaliação de um jovem de 5 a 20 anos e `Exod 21:32` 30 siclos por um servo — **comparação de leitores**, não explicação do texto. | **Não mostrar** a pesagem nem a entrega da prata; prata não é item. H5 do ep_008 continua aberto. |
| José levado ao Egito (`Gen 37:28`, `39:1`). | `Ps 105:18` fala de grilhões e ferros; `Gen 40:15` José diz que foi "roubado". O momento dos grilhões no salmo não é especificado (viagem? prisão?) — **interpretação**. | Não mostrar correntes, cordas ou maus-tratos na caravana por inferência a partir do salmo. |
| Potifar: oficial do Faraó, capitão da guarda, egípcio (`Gen 39:1`). | O termo hebraico traduzido "oficial" pode também significar "eunuco/cortesão"; "capitão da guarda" tem sentido literal discutido (chefe dos guardas/cozinheiros/executores) — **debatido; conferir léxico**. | Usar só a forma da BPM. Nada sobre função militar, carcerária ou culinária como fato. |
| José "na casa" do senhor; serve Potifar; administrador; tudo em suas mãos (`Gen 39:2-6`). | Grandes casas egípcias tinham administradores, escribas, depósitos, campos — **contexto** (revisor histórico confirma). O texto **não** diz que José escrevia, contava ou fazia registros. | Casa egípcia recriada; servo(a), escriba, cozinheira ou trabalhador do campo **fictícios** falam do cotidiano. `household_records` só como objeto de contexto, **não** como registro feito por José. |
| A bênção do SENHOR alcança a casa e o campo "por causa de José" (`Gen 39:5`). | Leitura teológica do narrador — é texto, mas aplicações devocionais variam (**interpretação** quando aplicada). | Moradores fictícios podem notar que "a casa vai bem desde que o hebreu cuida dela", **sem** atribuir milagre, poder ou recompensa ao jogador (regra 12). |
| Potifar só cuidava da comida que comia (`Gen 39:6a`). | Leituras: literal (pureza alimentar; cf. `Gen 43:32`) ou eufemismo ligado à esposa — **debatido**. | Não explicar no jogo; no máximo cozinha fictícia como ambiente. |
| José de bela aparência (`Gen 39:6b`). | Frase prepara `39:7`. | Não usar como gancho nem descrição de NPC; não destacar. |
| "O SENHOR estava com José" (`39:2-3`, `39:5`, `39:21`, `39:23`); `Acts 7:9-10` retoma. | Ênfase do capítulo no nome divino é observação de comentaristas — **interpretação**. | Reflexão de diário marcada `devotional_educational`, com referência. |

---

## 7. Oportunidades de exploração (viajante fictício, sem alterar o relato)

**Restrição central:** o viajante é **testemunha distante** e **visitante posterior**. Não fala com José, irmãos, Rúben, Judá, mercadores do relato, Potifar ou Faraó; não compra, liberta, acompanha, alimenta nem consola José; não é o informante, o guia ou o escravo que viaja junto.

### Cena 1 — Observação da caravana (jogável, curta)
1. **Ponto de observação** fictício (encosta/pedra alta), longe da cisterna e da roda dos irmãos: a caravana passa **ao longe** pela estrada, rumo ao sul/Egito; José não é destacado em close (silhueta entre o grupo, se aparecer).
2. **Interação permitida:** examinar o horizonte/estrada → texto narrado com paráfrase referenciada de `Gen 37:25`, `37:28` e `37:36`. Botão de seguir/aproximar **não existe**.
3. **Diário:** registro de observação classificado `recorded_event` (para a paráfrase) separado da presença do viajante (`plausible_fiction`, "· personagem fictício").
4. **Ponte com ep_008:** o diário pode lembrar Rúben voltando à cisterna (`37:29-30`) apenas como texto narrado, sem cena.

### Passagem narrativa
5. Transição "OUTRO MOMENTO DA HISTÓRIA" do Dotã para o Egito; o viajante **não viaja com a caravana**. Texto deixa claro que a duração é desconhecida e que o viajante chega depois, por conta própria.

### Cena 2 — Egito, arredores e casa de Potifar (parte principal)
6. **Mercadores fictícios na rota/mercado** (sem nome ismaelita/midianita do relato) falam de especiarias, bálsamo, mirra e do comércio com o Egito (`historical_context`; descoberta `caravans_trade` já existe).
7. **Servo(a) fictício(a) da casa** comenta, como boato e de modo genérico, que "o administrador hebreu" cuida de tudo e que a casa e o campo prosperam (paráfrase de `Gen 39:4-5`), sem nome próprio para José além do que for decidido, sem detalhes inventados da vida dele e sem cena de José presente.
8. **Ambientes:** depósitos, celeiro, campo da casa (`39:5` "na casa e no campo"), cozinha (sem explicar `39:6a`), pátio. Missões fictícias secundárias de ajuda a servos (carregar, organizar jarros) são `plausible_fiction`, sem ligação causal com a prosperidade de José.
9. **Objeto `household_records`:** objeto de contexto (como uma casa egípcia administrava bens), identificado como recriação; **não** "registros de José".
10. **Reflexão (`devotional_educational`):** confiança/integridade ligadas a `Gen 39:2-6` e eco em `Acts 7:9-10`, como reflexão identificada; sem antecipar `39:7-23`.

### `design_constraints` sugeridos (para o designer; todos `pending_review`)
- O viajante não impede, atrasa, facilita, compra, acompanha nem liberta José; nenhuma escolha com efeito sobre José, a venda ou Potifar.
- Personagens bíblicos **sem falas** no episódio; só paráfrase narrada com referência.
- Caravana vista **de longe**; sem cordas, correntes, chicote, ferimentos, choro, gritos ou súplica de José; sem mostrar a retirada da cisterna nem a pesagem/entrega da prata; sem sangue (a túnica/bode é ep_008).
- Ismaelitas e midianitas do relato sem caricatura étnica, sem papel de vilão e sem ligação com povos atuais.
- José, prata, túnica, cisterna e a "bênção" não viram itens, recompensas, colecionáveis ou poderes.
- `Gen 39:7-23` fora da experiência (sem alusão à esposa de Potifar, à acusação ou à prisão); o encerramento só diz que a história de José continua.
- Faraó sem nome; Potifar sem fala, sem retrato de caráter além do texto; nada de "eunuco" nem papel militar inventado.
- Nada de datas, dinastia ou duração; incerteza explícita.
- Moradores e o viajante identificados como fictícios no diário.

---

## 8. Recomendação: `Gen 39:7-23` fora desta experiência
**Recomendação:** fora (a decisão é humana).
1. **Público amplo:** `39:7-18` é um relato de assédio sexual e falsa acusação de agressão sexual. Qualquer adaptação jogável ou cenas em quadros exigem cuidado de classificação etária, e a sobriedade necessária reduziria o relato a eufemismos, com risco de distorcê-lo.
2. **Não alterar o relato:** um viajante na casa durante `39:7-18` ficaria perto demais de uma cena de duas pessoas ("nenhum dos homens da casa estava lá", `39:11`); qualquer presença sugere testemunha, o que o texto exclui.
3. **Falas:** `39:8-9` tem falas de José e `39:14-15`, `39:17-18` falas da esposa; parafraseá-las fielmente envolve conteúdo sexual explícito no próprio texto.
4. **Escopo e coerência:** `39:1-6` fecha uma unidade (chegada → confiança → bênção); `39:7` abre outra com "depois destas coisas". A prisão (`39:20-23`) liga-se naturalmente a `Gen 40` (ep_010 "Os sonhos na prisão") — pode abrir aquele episódio com um resumo cuidadoso decidido pelo criador.
5. **Texto importado:** `bpm.json` só tem `Gen 39:1-6`.

**Consequências para o catálogo (decisão humana):** a referência `Gen 39:1-23` e o `obj_03` `joseph_imprisoned` ("Acompanhar a prisão") não combinam com este escopo; o objetivo de aprendizagem "Integridade diante da injustiça" depende sobretudo de `39:7-23` — com `39:1-6` o tema fica mais perto de "fidelidade/confiança no trabalho e Deus presente na adversidade". Sugere-se revisar o objetivo ou transferir a parte da integridade para ep_010.

---

## 9. Riscos (fáceis de distorcer)
- **Ismaelitas × midianitas:** não "corrigir", não escolher um nome só, não explicar (`37:25`, `37:28`, `37:36`, `39:1`). Se uma paráfrase disser "os mercadores", ela deve vir acompanhada das referências.
- **Quem tirou José da cisterna (`37:28`):** usar formulação neutra (F008 §8).
- **Rúben na venda:** não colocá-lo presente nem ausente explicitamente na cena; o texto só diz que ele voltou depois (`37:29`).
- **Judá:** não vilanizar nem absolver; registrar só a proposta (`37:26-27`).
- **O preço:** "vinte peças de prata" = prata pesada, não moedas; não comparar a valores modernos; `Lev 27:5`/`Exod 21:32` são leis posteriores (comparação apenas, se aprovada).
- **Violência e tráfico:** José é vendido como escravo (`Ps 105:17`; `Gen 45:4`); a cena deve reconhecer isso com sobriedade, sem romantizar a viagem, sem sofrimento dramatizado e sem amenizar ("José foi viajar").
- **Providência:** "o SENHOR estava com José" não torna a venda boa nem a escravidão aceitável; não transformar em "lição" de que sofrer gera prosperidade.
- **Prosperidade:** não vender a bênção como riqueza do jogador ou fórmula; o texto atribui a bênção ao SENHOR "por causa de José" (`39:5`).
- **Potifar e a esposa:** fora do escopo, não usar `39:6b` como gancho; não insinuar o que vem depois.
- **Termos de Potifar:** não introduzir "eunuco" nem "carrasco" (leituras lexicais debatidas).
- **Egito anacrônico:** pirâmides, esfinges, faraó nomeado (Tutancâmon/Ramsés), escrita "egípcia" decorativa como mensagem legível — revisor histórico decide; o texto não dá dinastia.
- **Estereótipos:** egípcios não são cenário exótico nem vilões; ismaelitas/midianitas sem caricatura.
- **Antecipação:** nada sobre sonhos do Faraó, governo do Egito ou nome egípcio de José (`Gen 41`).
- **Nome do jogo × texto:** se a rota tiver nome ("Caminho das Caravanas"), identificar como nome do jogo (ep_008 H3).

---

## 10. Fontes consultadas
- `C:\TEMP\biblia\porbrbsl\porbrbsl_vpl.txt` — Bíblia Portuguesa Mundial (domínio público, eBible.org `porbrbsl`): `Gen 37:1-36`, `Gen 39:1-23`, `Gen 16:15`, `Gen 25:2`, `Gen 25:12`, `Gen 40:3-4`, `Gen 40:15`, `Gen 41:1`, `Gen 41:12`, `Gen 42:21`, `Gen 43:32`, `Gen 45:4`, `Gen 46:34`, `Ps 105:16-22`, `Acts 7:9-10`, `Lev 27:5`, `Exod 21:32`; contagens de `Gen 39`, `Gen 40`, `Ps 105`, `Acts 7`, `Lev 27`, `Exod 21`.
- `data/bible/texts/bpm.json` (mesma tradução, importada): `Gen 37:2-36`, `Gen 39:1-6`.
- `data/bible/books.json`, `data/bible/verse_counts.json`.
- `production/episodes/ep_008_jose_e_seus_irmaos/research_biblical.md` e `review.json` (B7 adiado, H5 aberto, H1/H3/N2 sobre caravanas, nomes e prata).
- `production/catalog/episodes.json` (entrada ep_009), `data/world/experiences.json` (`joseph_egypt`), `data/bible/people.json` (`joseph`).
- `docs/ai-wiki/BIBLICAL_RULES.md`, `docs/mission_factory.md`, `AGENTS.md`.
- Conhecimento geral do pesquisador (IA) sobre léxico hebraico, recepção e contexto egípcio — **não verificado**, marcado como inferência/hipótese. Nenhuma tradução protegida foi citada.

---

## 11. Itens `needs_human_review`
1. **Escopo `Gen 39:7-23`:** confirmar que fica fora; atualizar referência do catálogo/experiência (`Gen 39:1-6` + `Gen 37:25-28`, `37:36`), `obj_03` `joseph_imprisoned` e o objetivo de aprendizagem "Integridade diante da injustiça".
2. **Forma da cena da caravana:** mostrar a caravana partindo (depois da venda) ou incluir a venda de longe? Recomendação: só a caravana se afastando, com a venda narrada por paráfrase.
3. **José visível na caravana?** Silhueta indistinta, ou caravana sem José destacado e só o texto narrado.
4. **Camelos** na caravana do relato (o texto diz camelos) × política do ep_008 (jumentos nas caravanas fictícias) — confirmar com o revisor histórico.
5. **Prata:** H5 (ep_008) continua aberto; decidir se a comparação com `Lev 27:5`/`Exod 21:32` entra como nota ou fica fora (sugestão: fora).
6. **Termos "oficial" e "capitão da guarda":** conferir em léxico hebraico confiável antes de qualquer nota educativa.
7. **Ecos `Ps 105:17-22` e `Acts 7:9-10`:** usar no diário? Exigem importação no `bpm.json` e entrada em `verse_counts.json` (KI-11).
8. **Boato do servo fictício** sobre "o administrador hebreu": aceitável como paráfrase de `Gen 39:4-5` ou arriscado demais por pôr José "em cena" indiretamente?
9. **B7 do ep_008** (Gn 13:5-9 nas referências de missão fictícia) é independente deste episódio; continua adiado.
10. **`chronology_confidence`** do episódio: sugestão `debated` para a época e `unknown` para o tempo na casa de Potifar.
