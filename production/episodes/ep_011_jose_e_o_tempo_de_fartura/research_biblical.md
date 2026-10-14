# Ficha bíblica — ep_011_jose_e_o_tempo_de_fartura · "José e o tempo de fartura"

- **Episódio:** `ep_011_jose_e_o_tempo_de_fartura` (entrada em `production/catalog/episodes.json`: modo `ficcao_contextual`; objetivo de aprendizagem "Prudência, administração e preparação"; contexto "Egito — armazéns"; `region` vazio; `estimate.new_map_needed: true`, `difficulty: high`).
- **Objetivos-semente do catálogo:** `obj_01` inspect_object `grain_store` ("Conhecer armazenagem de grãos", `data_only`); `obj_02` organize `supplies_demo` ("Organizar um estoque fictício de demonstração", `needs_code`); `obj_03` observe_scene `joseph_governor` ("Conhecer a ascensão de José no relato", `partial`). Todos com `target_state: placeholder`.
- **Trecho central:** `Gen 41:1-57`. **Contexto anterior:** `Gen 40:1-23` (copeiro e padeiro), `Gen 39:20-23` (José na prisão). **Consequência (gancho, fora do escopo):** `Gen 42:1-6`. **Ecos posteriores:** `Gen 45:6`, `Gen 45:11`, `Gen 46:20`, `Gen 47:13-26`, `Gen 48:5`.
- **Coerência com o ep_008:** o ep_008 termina com José levado ao Egito (`Gen 37:36`, `Gen 39:1`). Esta ficha não repete a venda; menciona `Gen 37:2` só para a conta de idade. A chegada dos irmãos (`Gen 42` em diante) pertence ao `ep_012_a_reconciliacao_da_familia`; aqui fica só como gancho.
- **Autor:** agente `biblical-researcher` (IA). **Status:** `pending_review` — nada aqui está verificado; exige revisão humana.
- **Texto bíblico usado:** Bíblia Portuguesa Mundial (domínio público, eBible.org `porbrbsl`), lido diretamente do arquivo oficial `C:\TEMP\biblia\porbrbsl\porbrbsl_vpl.txt` e comparado com `data/bible/texts/bpm.json` (que hoje só contém `Gen 41:39-41` deste capítulo). Todos os resumos abaixo são paráfrase própria; trechos entre aspas são palavras curtas da BPM usadas como marcador, não citação para o jogo.
- **Independência:** montada a partir do texto bíblico. Dados existentes no jogo (`joseph` em `data/bible/people.json`, `egypt` em `places.json`, `Exod 1:11` em `bpm.json`) foram consultados só para apontar sobreposição e riscos.

---

## 1. Referências (conferidas)

Livro `Gen` existe em `data/bible/books.json`. `data/bible/verse_counts.json` traz `Gen 37` = 36, `Gen 39` = 23, `Gen 40` = 23, `Gen 41` = 57; no VPL oficial as mesmas contagens batem (39 = 23, 40 = 23, 41 = 57). **Não traz** `Gen 42`, `Gen 45`, `Gen 46`, `Gen 47`, `Gen 48`, `Gen 50` (KI-11); contagem no VPL oficial: `Gen 42` = 38, `Gen 45` = 28, `Gen 46` = 34, `Gen 47` = 31, `Gen 48` = 22, `Gen 50` = 26.

| Ref. | Trecho | No VPL oficial? | Em `bpm.json`? |
|---|---|---|---|
| `Gen 39:20-23` | José na prisão; o carcereiro lhe entrega a responsabilidade | Sim | **Não** |
| `Gen 40:1-23` | Copeiro e padeiro presos; sonhos; interpretações; copeiro esquece José | Sim | **Não** |
| `Gen 41:1-7` | Os dois sonhos do Faraó (vacas; espigas) | Sim | **Não** |
| `Gen 41:8` | Magos e sábios não interpretam | Sim | **Não** |
| `Gen 41:9-13` | O copeiro se lembra de José | Sim | **Não** |
| `Gen 41:14-16` | José trazido da prisão; "Isso não está em mim" | Sim | **Não** |
| `Gen 41:17-24` | O Faraó reconta os sonhos | Sim | **Não** |
| `Gen 41:25-32` | José explica: um só sonho; sete anos de fartura, sete de fome | Sim | **Não** |
| `Gen 41:33-36` | José propõe homem prudente, supervisores, quinta parte, reserva | Sim | **Não** |
| `Gen 41:37-44` | Faraó aprova; põe José sobre o Egito; anel, linho, corrente, carro | Sim | `41:39-41` sim; resto **não** |
| `Gen 41:45-46` | Novo nome; casamento com Asenate; 30 anos; percorre o Egito | Sim | **Não** |
| `Gen 41:47-49` | Anos de fartura; cereal guardado nas cidades, incontável | Sim | **Não** |
| `Gen 41:50-52` | Nascimento de Manassés e Efraim e explicação dos nomes | Sim | **Não** |
| `Gen 41:53-57` | Fim da fartura; fome; José abre os armazéns e vende; todos os países vêm | Sim | **Não** |
| `Gen 42:1-6` | Jacó envia dez filhos ao Egito; José "governador" vende ao povo | Sim | **Não** |
| `Gen 37:2` | José com 17 anos | Sim | Sim |
| `Gen 45:6`, `Gen 45:11` | Dois anos de fome passados; restam cinco | Sim | **Não** |
| `Gen 46:20` | Manassés e Efraim, filhos de Asenate, filha de Potífera | Sim | **Não** |
| `Gen 47:13-26` | Política de José durante a fome (dinheiro, gado, terras; quinta parte) | Sim | **Não** |
| `Gen 48:5` | Jacó adota Efraim e Manassés | Sim | **Não** |
| `Exod 1:11` | Cidades-armazéns Pitom e Ramsés (outro período) | Sim | Sim |

Qualquer citação literal no jogo fora de `Gen 41:39-41` exige importar o texto antes (`tools/import_scripture.gd`) e acrescentar ao `verse_counts.json` os capítulos que faltam.

---

## 2. Resumo do relato, trecho a trecho (paráfrase própria)

### Contexto: `Gen 39:20-23` e `Gen 40:1-23` — a prisão e o copeiro
- José está na prisão onde ficavam os presos do rei; o SENHOR está com ele, e o carcereiro lhe confia os outros presos e tudo o que se fazia ali (`Gen 39:20-23`).
- O copeiro e o padeiro do rei ofendem o seu senhor e são postos sob custódia na casa do capitão da guarda, na mesma prisão; o capitão os designa a José (`Gen 40:1-4`).
- Cada um tem um sonho na mesma noite. José nota a tristeza deles e pergunta; eles dizem não haver intérprete, e José responde que as interpretações pertencem a Deus (`Gen 40:5-8`).
- José interpreta: o copeiro será restaurado em três dias; o padeiro será executado em três dias. José pede ao copeiro que se lembre dele e o mencione ao Faraó, dizendo que foi tirado à força da terra dos hebreus e nada fez para ser preso (`Gen 40:9-19`).
- No terceiro dia, aniversário do Faraó, tudo acontece como José disse; mas o copeiro se esquece de José (`Gen 40:20-23`).

### `Gen 41:1-8` — Os sonhos do Faraó
- Depois de "dois anos inteiros", o Faraó sonha que está junto ao rio: sete vacas bonitas e gordas sobem do rio e pastam; depois sobem sete vacas feias e magras, que comem as gordas; ele acorda (`Gen 41:1-4`).
- Volta a dormir e sonha com sete espigas cheias numa só haste, seguidas de sete espigas magras, secas pelo vento leste, que engolem as boas (`Gen 41:5-7`).
- De manhã, perturbado, chama os magos e sábios do Egito; ninguém consegue interpretar (`Gen 41:8`).

### `Gen 41:9-13` — O copeiro se lembra
- O chefe dos copeiros diz ao Faraó que se lembra de suas faltas e conta a prisão, os sonhos e o jovem hebreu, servo do capitão da guarda, que os interpretou corretamente (`Gen 41:9-13`).

### `Gen 41:14-24` — José diante do Faraó
- O Faraó manda chamar José; tiram-no às pressas do calabouço; ele se barbeia, troca de roupa e se apresenta (`Gen 41:14`).
- O Faraó diz ter ouvido que José interpreta sonhos; José responde que isso não está nele, mas que Deus dará ao Faraó uma resposta de paz (`Gen 41:15-16`).
- O Faraó reconta os dois sonhos, acrescentando que as vacas magras continuaram feias depois de comer as gordas e que os magos não souberam explicar (`Gen 41:17-24`).

### `Gen 41:25-32` — A explicação
- José diz que os dois sonhos são um só e que Deus mostrou ao Faraó o que vai fazer (`Gen 41:25`, `41:28`).
- Vacas boas e espigas boas são sete anos; vacas magras e espigas secas são sete anos de fome (`Gen 41:26-27`).
- Virão sete anos de grande fartura em todo o Egito, seguidos de sete anos de fome tão grave que a fartura será esquecida (`Gen 41:29-31`).
- O sonho repetido indica que a coisa está decidida por Deus e acontecerá em breve (`Gen 41:32`).

### `Gen 41:33-36` — A proposta de José
- José sugere que o Faraó procure um homem prudente e sábio e o ponha sobre o Egito; que nomeie supervisores; que recolha a quinta parte da colheita nos anos de fartura (`Gen 41:33-34`).
- Que se junte o alimento e se guarde cereal nas cidades, sob a autoridade do Faraó, como reserva para os anos de fome, para que a terra não pereça (`Gen 41:35-36`).

### `Gen 41:37-46` — A elevação de José
- O plano agrada ao Faraó e aos seus servos; o Faraó pergunta se haveria outro homem "em quem está o Espírito de Deus" (`Gen 41:37-38`).
- Diz a José que, como Deus lhe mostrou tudo, ninguém é tão prudente e sábio; põe José sobre a sua casa e sobre todo o povo; só no trono o Faraó será maior (`Gen 41:39-41`).
- Dá a José o seu anel de selar, roupas de linho fino e uma corrente de ouro; faz José andar no segundo carro; gritam diante dele "Dobrem os joelhos!" (`Gen 41:42-43`).
- O Faraó declara que sem José ninguém levantará mão ou pé no Egito (`Gen 41:44`).
- O Faraó dá a José o nome Zafenate-Paneia e lhe dá por esposa Asenate, filha de Potífera, sacerdote de Om (`Gen 41:45`).
- José tinha trinta anos quando se apresentou ao Faraó; sai e percorre toda a terra do Egito (`Gen 41:45-46`).

### `Gen 41:47-49` — Os anos de fartura
- A terra produz em abundância durante sete anos (`Gen 41:47`).
- José ajunta o alimento e o guarda nas cidades; cada cidade recebe o alimento dos campos ao redor dela (`Gen 41:48`).
- O cereal é tanto, "como a areia do mar", que José para de contar (`Gen 41:49`).

### `Gen 41:50-52` — Os filhos de José
- Antes da fome, Asenate dá a José dois filhos (`Gen 41:50`).
- José chama o primeiro de Manassés, explicando que Deus o fez esquecer todo o seu sofrimento e toda a casa de seu pai (`Gen 41:51`), e o segundo de Efraim, porque Deus o fez frutífero na terra da sua aflição (`Gen 41:52`).

### `Gen 41:53-57` — A fome
- Os sete anos de fartura terminam e começam os de fome, como José dissera; há fome em todas as terras, mas no Egito há pão (`Gen 41:53-54`).
- Quando o Egito sente fome, o povo clama ao Faraó, que manda todos irem a José e fazerem o que ele disser (`Gen 41:55`).
- José abre os armazéns e **vende** aos egípcios; todos os países vêm ao Egito comprar cereal de José (`Gen 41:56-57`).

### Gancho: `Gen 42:1-6` (fora do escopo jogável; pertence ao ep_012)
- Jacó sabe que há cereal no Egito e envia dez filhos para comprar, retendo Benjamim (`Gen 42:1-4`). Eles chegam entre os que vinham comprar, por causa da fome em Canaã (`Gen 42:5`). José, governador da terra e responsável pela venda, recebe os irmãos, que se prostram diante dele (`Gen 42:6`).

---

## 3. Personagens bíblicos (apenas o que o texto diz)

| Personagem | O que o texto registra | Refs. |
|---|---|---|
| **José** | Na prisão com responsabilidade dada pelo carcereiro; interpreta sonhos atribuindo a interpretação a Deus; trazido ao Faraó; explica os sonhos; propõe o plano; elevado sobre o Egito; recebe nome egípcio e esposa; 30 anos; percorre o Egito; armazena cereal; pai de Manassés e Efraim; abre armazéns e vende cereal. | `Gen 39:20-23`; `Gen 40:6-15`; `Gen 41:14-57` |
| **O Faraó** | **Não é nomeado no texto.** Sonha duas vezes; fica perturbado; chama magos e sábios; manda chamar José; aprova o plano; atribui a José o Espírito de Deus; dá a José autoridade, anel, linho, corrente, carro, nome e esposa; manda o povo ir a José. | `Gen 41:1-8`, `41:14-24`, `41:37-45`, `41:55` |
| **Chefe dos copeiros** | Sem nome. Preso com o padeiro; restaurado ao cargo; esquece José por dois anos; depois o lembra diante do Faraó. | `Gen 40:1-23`; `Gen 41:9-13` |
| **Chefe dos padeiros** | Sem nome. Preso; sonho interpretado; executado. Só no contexto. | `Gen 40:16-22`; `Gen 41:10-13` |
| **Magos e sábios do Egito** | Chamados; não conseguem interpretar. Sem falas. | `Gen 41:8`, `41:24` |
| **Capitão da guarda** | Em cuja casa fica a prisão; designa os presos a José; José é chamado "servo do capitão da guarda". O texto de `Gen 40–41` **não diz o nome**; `Gen 39:1` chama Potifar de capitão da guarda (identificação plausível, mas inferência). | `Gen 40:3-4`; `Gen 41:10`, `41:12` |
| **Servos do Faraó** | Aprovam o plano junto com o Faraó. | `Gen 41:37-38` |
| **Asenate** | Filha de Potífera, sacerdote de Om; dada a José por esposa pelo Faraó; mãe de Manassés e Efraim. Nenhuma fala, nenhuma descrição pessoal. | `Gen 41:45`, `41:50`; `Gen 46:20` |
| **Potífera** | Sacerdote de Om; pai de Asenate. Só o nome e a função. **Não confundir com Potifar** (`Gen 39:1`). | `Gen 41:45`, `41:50` |
| **Manassés** | Primogênito de José e Asenate, nascido antes da fome; nome explicado por José. | `Gen 41:50-51`; `Gen 48:5` |
| **Efraim** | Segundo filho, nascido antes da fome; nome explicado por José. | `Gen 41:50`, `41:52`; `Gen 48:5` |
| **Povo do Egito / "todos os países"** | Clamam ao Faraó por pão; vão a José comprar cereal; estrangeiros vêm comprar. | `Gen 41:55-57` |
| **Jacó e os irmãos** | Só no gancho de `Gen 42:1-6`. | `Gen 42:1-6` |

**Falas registradas no trecho central (`Gen 41:1-57`):**
- Chefe dos copeiros ao Faraó: lembrança das faltas, da prisão e do jovem hebreu intérprete (`41:9-13`).
- Faraó a José: ouviu que José interpreta sonhos (`41:15`); reconto dos sonhos (`41:17-24`); "ninguém tão prudente e sábio como você" e a nomeação (`41:39-41`); "Eu sou o Faraó…" (`41:44`).
- José ao Faraó: "Isso não está em mim; Deus dará ao Faraó uma resposta de paz" (`41:16`); explicação e proposta (`41:25-36`).
- Faraó aos servos: pergunta sobre homem "em quem está o Espírito de Deus" (`41:38`).
- Clamor diante de José: "Dobrem os joelhos!" (`41:43`; quem grita não é identificado).
- José ao dar os nomes aos filhos (`41:51-52`).
- Faraó aos egípcios: "Vão a José. O que ele lhes disser, façam." (`41:55`).

**Sem falas no trecho:** Asenate, Potífera, Manassés, Efraim, magos, o povo (o clamor de `41:55` é narrado, sem discurso direto). Qualquer fala desses personagens seria invenção.

---

## 4. Gênero literário
**Narrativa** em prosa (ciclo de José em Gênesis) com **relatos de sonhos e sua interpretação** dentro do próprio texto (`Gen 40:5-19`, `Gen 41:1-32`). A interpretação é dada pelo texto e atribuída a Deus por José (`Gen 40:8`, `Gen 41:16`, `41:25`, `41:28`, `41:32`). O jogo não deve reinterpretar nem expandir o simbolismo dos sonhos (vacas, espigas, vento leste) além do que José explica. Inclui também elementos de relato administrativo (supervisores, quinta parte, armazenamento por cidade) e uma etiologia de nomes (`41:51-52`). Não é parábola, profecia literária nem apocalíptico.

---

## 5. Linha do tempo

| Marco | O que se apoia no texto | `chronology_confidence` |
|---|---|---|
| Período patriarcal / José no Egito | Ordem relativa de Gênesis; `data/bible/chronology.json` não atribui anos ao período patriarcal | `debated` (datação absoluta debatida; **não atribuir ano nem dinastia**) |
| Prisão → sonhos do Faraó | "Dois anos inteiros" depois de o copeiro esquecer José (`Gen 41:1`, após `Gen 40:23`) | `documented` (intervalo relativo do texto) |
| Tempo total na prisão | Não informado; "muitos dias" em `Gen 40:4` | `unknown` |
| Idade de José diante do Faraó | 30 anos (`Gen 41:46`) | `documented` (dado do texto) |
| Do sonho de `Gen 37:2` (17 anos) até `Gen 41:46` | ~13 anos, cálculo a partir de duas idades do texto | `approximate` |
| Anos de fartura | Sete (`Gen 41:29`, `41:47`, `41:53`) | `documented` (duração relativa) |
| Nascimento de Manassés e Efraim | "Antes que chegasse o ano da fome" (`Gen 41:50`); ano exato não dado | `approximate` (dentro dos 7 anos de fartura) |
| Anos de fome | Sete (`Gen 41:30`, `41:54`); `Gen 45:6` situa a revelação aos irmãos após dois anos de fome | `documented` (relativo) |
| Ida dos irmãos ao Egito | Durante a fome (`Gen 42:1-5`); ano exato da fome não dado | `approximate` |
| Ano absoluto | Nenhum | usar `null` |

Sugestão para o catálogo: trocar `chronology_confidence: not_established` por `debated` (época) com marcos internos `documented` (2 anos, 30 anos, 7+7 anos).

---

## 6. Três colunas: texto × inferência × ficção do jogo

| O que o texto diz | Inferência ou hipótese histórica | O que seria ficção do jogo |
|---|---|---|
| O Faraó não tem nome (`Gen 41` inteiro). | Propostas de identificação (dinastias do Médio Império, período hicso, outras) são **debatidas**; nenhuma é consenso. | Nenhuma identificação. O jogo diz só "o Faraó". Nada de nome, cartucho ou estátua com nome de rei. |
| Sonho "junto ao rio" com vacas que sobem dele (`Gen 41:1-3`). | O rio é naturalmente entendido como o Nilo; a BPM diz só "rio" — inferência segura, mas conferir com o revisor. Cheia anual do Nilo como base da fertilidade (contexto). | Moradores fictícios falando da cheia do rio, da lama fértil, do capim do brejo. |
| Magos e sábios não interpretam (`Gen 41:8`, `41:24`). | Existência de especialistas em sonhos e escrita no Egito (contexto; ver `research_historical.md`). | Nenhum mago fictício "rival"; evitar caricatura de religião egípcia. |
| Quinta parte da colheita nos anos de fartura (`Gen 41:34`). | Tributação em cereal por administração central é plausível (contexto); a porcentagem vem do texto, não de fonte egípcia. | Escriba fictício explicando, em geral, que parte da colheita ia para os armazéns. Não dizer que o escriba trabalha "para José" com detalhes inventados. |
| Cereal guardado nas cidades, o de cada campo na cidade próxima (`Gen 41:35`, `41:48`). | Celeiros egípcios (silos, depósitos) existiram em várias épocas — **confirmar com o revisor histórico**; a forma exata dos armazéns de José não é descrita. | Armazém fictício (`grain_store`) com sacos, jarros e silos baixos em estilo plausível; placa/diário "recriação". |
| Cereal incontável, "como a areia do mar"; José para de contar (`Gen 41:49`). | Hipérbole narrativa comum; registro escrito de grãos por escribas é contexto plausível. | Tabuletas/papiros de contagem como cenário; o jogador **não** completa a contagem de José. |
| Anel de selar, linho fino, corrente de ouro, segundo carro, "Dobrem os joelhos!" (`Gen 41:42-43`). | Sentido do termo traduzido "Dobrem os joelhos" é **debatido** (palavra de origem incerta). Uso de carros no Egito tem datação histórica discutida — **debatido**, não comentar como fato. | Só em quadros de apresentação, sóbrios; anel, corrente e carro **não** viram itens, prêmios ou cosméticos. |
| Nome Zafenate-Paneia (`Gen 41:45`). | Significado do nome egípcio é **debatido** (várias propostas). | Mostrar o nome como o texto dá, sem tradução afirmada. |
| Asenate, filha de Potífera, sacerdote de Om (`Gen 41:45`). | Om é comumente identificada com Heliópolis (inferência a conferir em `places.json`/revisor). Tradições judaicas posteriores (ex.: obra "José e Asenate") elaboram a história de Asenate — **interpretação/tradição**, não usar como fato. | Nenhuma cena fictícia de casamento, romance ou falas de Asenate. |
| Nomes de Manassés e Efraim com explicação de José (`Gen 41:51-52`). | Os nomes fazem jogo de palavras em hebraico (esquecer; ser frutífero) — nota lexical a conferir. | Possível descoberta/diário identificada como "o texto explica os nomes"; sem cena inventada. |
| Fome em todas as terras; no Egito havia pão (`Gen 41:54`). | Fomes regionais ligadas a cheias fracas do Nilo e secas no Levante são contexto plausível. | Viajantes estrangeiros fictícios chegando para comprar (sem identificá-los como os irmãos de José). |
| José abre os armazéns e **vende** (`Gen 41:56-57`). | Pagamento em prata/metal pesado ou troca; **não havia moedas cunhadas** no período patriarcal (contexto, conferir). `Gen 47:13-26` mostra efeitos posteriores (dinheiro, gado, terras) — leitura ética **debatida**. | Fila fictícia de compradores; nenhuma mecânica de lucro ou comércio do jogador com o cereal de José. |
| — (texto de outro período) `Exod 1:11` cidades-armazéns Pitom e Ramsés, construídas pelos israelitas oprimidos. | Período e contexto diferentes. | **Não** misturar com os armazéns de José; não usar Pitom/Ramsés no ep_011. |

---

## 7. Oportunidades de exploração (viajante fictício, sem alterar o relato)

**Restrição central:** o viajante **não interpreta os sonhos, não aconselha o Faraó, não sugere o plano da quinta parte, não é nomeado supervisor, não lembra o copeiro de José e não participa da elevação de José**. Nada que o jogador faça causa, acelera ou garante a fartura, a fome ou o sucesso do armazenamento. A elevação de José é só **observada** (apresentação em quadros com paráfrase referenciada) ou **contada** por moradores fictícios.

1. **Armazém de cereal (`grain_store`, `inspect_object`):** inspecionar silos, sacos, jarros, rampas, selos de barro; trabalhador/escriba fictício explica como o cereal dos campos próximos era guardado na cidade (`Gen 41:48` como nota; `historical_context` para o resto).
2. **Estoque de demonstração (`supplies_demo`, `organize`):** o viajante ajuda um trabalhador **fictício** a arrumar um depósito pequeno e **separado** dos armazéns do relato (separar cereal de semente, tampar jarros contra umidade e pragas, empilhar sacos). É prática cotidiana (`plausible_fiction`), não parte do plano de José, e não gera recompensa ligada a "bênção" ou "sabedoria".
3. **Registro de grãos:** escriba fictício mostra uma tabuleta/papiro de contagem; liga a `Gen 41:49` (o cereal ficou incontável) sem pôr o jogador para "fechar a conta".
4. **Cotidiano egípcio à beira do rio:** cheia, capim do brejo, vacas pastando, campos de cevada/trigo (espécies a confirmar com o revisor histórico); ponte visual com os sonhos sem reinterpretá-los.
5. **Ascensão de José (`joseph_governor`, `observe_scene`):** apresentação em quadros com `Gen 41:14-16`, `41:25-36` (resumidos), `41:39-41` (já importado), `41:42-46`, `41:47-49`, `41:53-57`. Narrador, nunca o viajante, apresenta os fatos.
6. **Diário de reflexão (`devotional_educational`):** "Prudência e preparação" a partir de `Gen 41:33-36`, com a ressalva do próprio texto de que José atribui a revelação a Deus (`41:16`, `41:25`, `41:28`).
7. **Gancho para o ep_012:** moradores fictícios comentam que estrangeiros de Canaã também vêm comprar cereal (`Gen 41:57`, `Gen 42:5`), sem mostrar ainda os irmãos.

**Restrições de design sugeridas (`design_constraints`):** Faraó sem nome; José só fala por paráfrase referenciada de `41:16`, `41:25-36`, `41:51-52`; Asenate, Potífera e os filhos sem falas; nenhum NPC fictício presente na sala do trono; o jogador não influencia os sonhos, a interpretação nem a nomeação; anel/corrente/carro/cereal de José não viram itens; o estoque de demonstração é fictício e separado dos armazéns do relato.

---

## 8. Riscos (fáceis de distorcer)
- **Identificar o Faraó ou a dinastia como fato:** o texto não nomeia o rei. Qualquer nome (ou datação por dinastia) é hipótese debatida; não pôr em texto, arte, cartucho ou hieróglifo legível.
- **Anacronismos egípcios:** pirâmides de Gizé como cenário central ou, pior, como "celeiros de José" (lenda medieval, não usar); moedas; ferro; deuses e templos de épocas muito diferentes misturados; camelos em excesso; carros com detalhes de época específica. Coordenar com `research_historical.md`; marcar a cidade como "recriação".
- **Confundir com Êxodo:** os armazéns de José não são as cidades-armazéns de Pitom e Ramsés (`Exod 1:11`), feitas sob opressão em outro período.
- **Transformar sabedoria em mecânica de recompensa:** a prudência de José é apresentada pelo texto como dada por Deus (`41:16`, `41:38-39`). Não converter em "pontos de sabedoria", poder do jogador ou loot; não sugerir que organizar o estoque "faz" o jogador sábio como José. Também evitar "evangelho da prosperidade" (fartura como prêmio por bom comportamento).
- **O jogador como conselheiro:** não deixar escolhas de diálogo em que o viajante sugere ao Faraó, a José ou a supervisores o plano de armazenamento ou a quinta parte.
- **Interpretação dos sonhos:** só a do texto (sete anos de fartura e de fome). Não acrescentar significados para as vacas, espigas ou vento leste; não transformar interpretação de sonhos em minijogo ou habilidade do jogador.
- **Mudança de nome de José (`41:45`):** o texto registra o nome sem comentário moral. Não apresentar como "perda de identidade" nem como "assimilação aprovada"; não afirmar o significado do nome.
- **Casamento com Asenate (`41:45`):** o texto não comenta religião, conversão nem sentimentos. Não inventar romance, cerimônia, falas ou conversão; não julgar o casamento (debates teológicos posteriores são interpretação). Não confundir **Potífera** (sacerdote de Om) com **Potifar** (capitão da guarda, `Gen 39`).
- **Religião egípcia:** "sacerdote de Om" e "magos" não devem ser ridicularizados nem detalhados com rituais inventados (regra 12 de reverência vale como sobriedade também aqui).
- **"Espírito de Deus" na boca do Faraó (`41:38`):** é fala do Faraó registrada; não transformar em afirmação teológica sobre a fé do Faraó.
- **Venda do cereal e `Gen 47:13-26`:** o texto diz que José **vendia** (`41:56`); não mudar para "distribuía de graça". A política posterior (compra de gado, terras e pessoas para o Faraó) tem leituras éticas debatidas; não apresentar José como modelo administrativo sem ressalvas, e não antecipar `Gen 47` no ep_011.
- **"Governador":** o termo aparece em `Gen 42:6`; em `Gen 41` o texto descreve a função ("sobre a minha casa", "sobre toda a terra"). `people.json` usa "Governador do Egito (Gn 41:39-41)" — aceitável como resumo, mas citar `Gen 42:6` se o título for usado literalmente.
- **Nomes dos filhos (`41:51`):** "esquecer a casa de meu pai" não deve virar afirmação de que José rejeitou a família; o texto só registra a explicação do nome.
- **Gancho do ep_012:** não mostrar os irmãos se prostrando (`Gen 42:6`) como cumprimento dos sonhos de `Gen 37` no ep_011; essa ligação pertence ao episódio seguinte e é feita pelo próprio texto em `Gen 42:9`.

---

## 9. Fontes consultadas
- `C:\TEMP\biblia\porbrbsl\porbrbsl_vpl.txt` — Bíblia Portuguesa Mundial (domínio público, eBible.org `porbrbsl`), arquivo oficial completo: `Gen 39:20-23`, `Gen 40:1-23`, `Gen 41:1-57`, `Gen 42:1-6`, `Gen 42:9`, `Gen 37:2`, `Gen 39:1`, `Gen 39:6`, `Gen 45:6`, `Gen 45:11`, `Gen 46:20`, `Gen 47:13-26`, `Gen 48:5`, `Gen 50:22-23`; contagens de versículos de `Gen 39`, `40`, `41`, `42`, `45`, `46`, `47`, `48`, `50`.
- `data/bible/texts/bpm.json` — mesma tradução (importada): confere `Gen 41:39-41`, `Gen 37:2`, `Gen 39:1`, `Exod 1:11`.
- `data/bible/verse_counts.json`, `data/bible/books.json` — validação de referências.
- `docs/ai-wiki/BIBLICAL_RULES.md`, `docs/mission_factory.md`, `.cursor/agents/biblical-researcher.md` — regras, papel e mapa de capacidades.
- `production/catalog/episodes.json` — entrada do episódio; `production/episodes/ep_008_jose_e_seus_irmaos/research_biblical.md` — modelo e coerência.
- Dados do jogo consultados para sobreposição: `data/bible/people.json` (`joseph`), `data/bible/places.json` (`egypt`), `data/bible/discoveries.json` (`caravans_trade`).
- Conhecimento geral do pesquisador (IA) para contexto histórico, lexical e de recepção (identificação do Faraó, Om/Heliópolis, "José e Asenate", lenda das pirâmides como celeiros, significado de Zafenate-Paneia e de "Dobrem os joelhos") — **não verificado**, marcado como inferência/hipótese. Nenhuma tradução protegida foi citada.

---

## 10. Itens `needs_human_review`
1. Importar para `bpm.json` (se citados literalmente): `Gen 41:1-38`, `Gen 41:42-57`, `Gen 40:8`, `Gen 42:1-6` (se usado como gancho). Acrescentar `Gen 42` (38), `Gen 45` (28), `Gen 46` (34), `Gen 47` (31), `Gen 48` (22) a `verse_counts.json` se forem referenciados (KI-11).
2. "Rio" em `Gen 41:1` como Nilo — confirmar se o jogo pode dizer "Nilo" em texto educativo (inferência, não texto da BPM).
3. Om = Heliópolis — confirmar com o revisor histórico e decidir se entra em `places.json` (com `identification` adequada).
4. Significado de "Zafenate-Paneia" e do grito "Dobrem os joelhos" (`41:43`) — não afirmar sem léxico confiável; sugestão: não traduzir no jogo.
5. Identificação do capitão da guarda de `Gen 40–41` com Potifar — sugestão: não afirmar.
6. Como tratar o casamento com a filha de um sacerdote egípcio e o novo nome — decisão do criador sobre o nível de detalhe (sugestão: só registrar o que o texto diz, em quadro ou diário).
7. Se `Gen 47:13-26` aparece em algum episódio e como (leituras éticas debatidas); sugestão: fora do ep_011.
8. Forma e escala dos armazéns, espécies de cereal, sistema de pagamento (prata pesada × troca) — revisor histórico.
9. Se o estoque de demonstração (`organize`) é aceitável teologicamente como atividade cotidiana fictícia, sem ligação com o êxito do plano de José — decisão do criador.
10. `chronology_confidence` do catálogo está `not_established`; sugestão: `debated` para a época, com marcos relativos `documented`.
11. Se a elevação de José é mostrada em quadros (Faraó visível, sem nome) ou só narrada por moradores — decisão do criador.

---

## 11. Estimativa de produção

### Mapa
- **`canaan_village` não serve.** O relato é no Egito; pôr armazéns egípcios na aldeia de Canaã criaria geografia falsa.
- **Recomendação:** mapa novo **pequeno** de cidade egípcia recriada (ex.: `egypt_granary_town`): rua com casas de tijolo de barro, pátio de armazém com silos/depósitos, área de escribas, borda de campo/canal ou margem de rio. `region_id` próprio e região em `data/regions/`. O palácio do Faraó **não** precisa ser mapa jogável (aparece só em quadros). O mapa pode ser reaproveitado pelo `ep_012` (mercado de cereal, `grain_market`), o que dilui o custo.
- **Transição entre mapas:** só `canaan_village` existe; conferir com o integrador como o viajante chega ao Egito (apresentação de viagem + troca de mapa).

### Paleta e arte egípcia
- Paleta nova: tijolo de barro e areia ocre, calcário claro, verde de papiro/junco, azul do rio, linho branco nas roupas, toques de faiança azul-esverdeada. Os tiles atuais de Canaã (oliveiras, pedra, colinas) servem pouco.
- Tilesets: chão de terra batida, parede de tijolo cru, margem de rio com junco, campo de cereal maduro.
- Objetos: silos/depósitos de cereal, sacos, jarros grandes com tampa, cestos, selos de barro, mesa de escriba com papiros/tabuletas, balança simples, rampa/escada de silo.
- Personagens: trabalhadores, escriba e compradores estrangeiros **fictícios**, com roupas de linho; **sem** sprite jogável de José ou do Faraó no mapa.
- Quadros de apresentação (5–7): Faraó perturbado pelos sonhos; José barbeado diante do Faraó; elevação (anel/linho/corrente), sem rosto ou nome que identifique o rei; cidades guardando cereal; armazéns abertos na fome com filas de compradores.
- Evitar: pirâmides de Gizé dominando o cenário, hieróglifos legíveis inventados, deuses específicos sem orientação do revisor.

### Mecânicas (pelo mapa de capacidades de `docs/mission_factory.md`)
| Objetivo-semente | Situação | Observação |
|---|---|---|
| `obj_01` inspect_object `grain_store` | Já funciona (só dados) | `Interactable` com `dialogue_id` + `dialogue_finished`; precisa do mapa novo para existir o alvo. |
| `obj_02` organize `supplies_demo` | Não existe | Falta mecânica de organizar/quebra-cabeça. **Aproximação só com dados:** 3–4 `Interactable` (sacos, jarros, cestos) cada um com diálogo de escolha "onde guardar" emitindo `custom`, mais flag de conclusão — funciona como `help_npc` parcial. Mecânica real de arrastar/ordenar exige código. |
| `obj_03` observe_scene `joseph_governor` | Parcial | Apresentação em quadros (`presentation_finished`) funciona; cena dirigida no mapa não existe e **não é recomendada**. |
| visit_area (se o designer quiser "chegar ao armazém") | Não existe | Falta gatilho de área (Area2D → `region_entered`/`custom`); entrar no mapa novo com `region_id` já gera `region_entered`. |
| collect_item | Não existe | Sem inventário; **não necessário** — e não se deve "coletar" cereal de José. |
| Reflexão de diário | Parcial | Descoberta/flag; sem tela de reflexão escrita. |

### O que pode ser feito só com dados (sem código novo)
- Importar o texto de `Gen 41` (e `Gen 40:8`, `Gen 42:1-6` se necessário) para `bpm.json` e atualizar `verse_counts.json`.
- História em `data/bible/stories/` (ex.: `gen_041_joseph_governor`) com `design_constraints`; evento em `chronology.json` (sem ano); pessoas `asenath`, `potiphera`, `manasseh`, `ephraim` em `people.json` (todas `pending_review`); lugar `on` em `places.json` com identificação marcada.
- Descobertas: armazenagem de cereal, escribas e registro, cheia do rio e agricultura, fome regional (todas `historical_context`, após o revisor histórico).
- Apresentação em quadros `joseph_governor` (texto pronto; arte pode começar com placeholder).
- Diálogos de moradores fictícios e a versão "organize por diálogo" do `obj_02`.
- **Não dá para tornar jogável sem o mapa novo** (alvos `grain_store`/`supplies_demo` precisam existir em cena).

**Dificuldade estimada:** alta (mapa novo + paleta egípcia + quadros), coerente com `estimate.difficulty: high`; cai para média se o `obj_02` usar a aproximação por diálogos e o mapa for compartilhado com o ep_012.
