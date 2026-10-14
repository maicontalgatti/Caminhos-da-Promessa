# Pesquisa de missões v04 — ep_008_jose_e_seus_irmaos

- **Autor:** agente `biblical-researcher` (IA). **Status:** `pending_review`. Nada aqui está verificado; tudo exige revisão humana.
- **Texto bíblico:** Bíblia Portuguesa Mundial (BPM, domínio público, eBible.org `porbrbsl`), lido diretamente no arquivo oficial `C:\TEMP\biblia\porbrbsl\porbrbsl_vpl.txt`. Cada versículo citado abaixo foi localizado no arquivo durante esta pesquisa. Paráfrases e notas são texto próprio, separadas da citação; não há citação literal longa neste documento.
- **Formato das referências:** ids de `data/bible/books.json` (`Gen`, `Lev`, `Deut`, `Prov`, `Ruth`, `Acts`, `Gal`, `Jas`).
- **Complemento de:** `research_biblical.md` (ficha geral do episódio). Este arquivo cobre só as duas missões e a caravana.

### Contagem de versículos (conferida no VPL; `verse_counts.json` não cobre a maioria, KI-11)

| Capítulo | Versículos no VPL | Em `verse_counts.json`? | Em `bpm.json`? |
|---|---|---|---|
| `Gen 13` | 18 | não | só `Gen 13:10` |
| `Gen 37` | 36 | sim (36) | `Gen 37:2-36` (ver ficha geral) |
| `Lev 19` | 37 | não | não |
| `Deut 15` | 23 | não | não |
| `Deut 24` | 22 | não | não |
| `Ruth 2` | 23 | não | não |
| `Prov 3` | 35 | não | não |
| `Prov 19` | 29 | não | não |
| `Acts 2` | 47 | não | não |
| `Acts 4` | 37 | não | não |
| `Gal 6` | 18 | não | não |
| `Jas 2` | 26 | não | não |

Qualquer citação literal no jogo fora de `Gen 37:2-36` exige rodar `tools/import_scripture.gd` antes e acrescentar a contagem do capítulo a `verse_counts.json`.

---

## A) Missão principal — "O caminho para Dotã" (`Gen 37:12-17`)

### A.1 Confirmação dos lugares
- **Siquém** aparece em `Gen 37:12` (os irmãos levam o rebanho para lá), `Gen 37:13` (Israel pergunta se eles estão em Siquém) e `Gen 37:14` (José chega a Siquém).
- **Dotã** aparece duas vezes em `Gen 37:17` (o homem ouviu os irmãos dizerem que iriam a Dotã; José os encontra em Dotã).
- **Hebrom** também aparece, como ponto de partida: "vale de Hebrom" (`Gen 37:14`).

### A.2 Apresentação em quadros (5 quadros)

Cada quadro exibe o versículo da BPM resolvido pela referência (até 3 versículos) e, **separada**, uma nota curta do jogo. As notas são sugestões de texto próprio (`historical_context` ou texto de jogo), não paráfrase que substitua o versículo.

| # | Referência | O que o versículo traz (resumo próprio, para conferência) | Nota do jogo sugerida (separada do texto) |
|---|---|---|---|
| 1 | `Gen 37:12` | Os irmãos levam o rebanho do pai para pastar em Siquém. | "Os irmãos estão longe de casa, cuidando do rebanho da família." |
| 2 | `Gen 37:13-14` | Israel propõe enviar José; José responde "Eis-me aqui"; o pai pede que veja se está tudo bem com os irmãos e o rebanho e traga notícias; José sai do vale de Hebrom e chega a Siquém. | "Israel é outro nome de Jacó. José parte de Hebrom com um pedido do pai: trazer notícias." |
| 3 | `Gen 37:15` | Um homem encontra José vagando pelo campo e pergunta o que ele procura. | "O texto não diz quem era esse homem." |
| 4 | `Gen 37:16` | José diz que procura os irmãos e pergunta onde eles estão apascentando. | "José não os encontrou em Siquém e pede ajuda para continuar a busca." |
| 5 | `Gen 37:17` | O homem diz ter ouvido os irmãos falarem em ir a Dotã; José vai atrás deles e os encontra em Dotã. | "O caminho continua de Siquém para Dotã." |

**Nota final (após o quadro 5, texto do jogo):** "O que acontece em Dotã continua em Gênesis 37:18-36, em outro capítulo desta jornada."

Observações para o designer:
- O quadro 5 termina com José encontrando os irmãos; o versículo seguinte (`Gen 37:18`) já é a conspiração. A nota final não deve antecipar nem suavizar o que vem depois.
- "Israel" (`Gen 37:13`) e "Jacó" são a mesma pessoa no texto (ver `Gen 37:1-3`, onde os dois nomes aparecem). A nota do quadro 2 evita confusão do jogador.
- Fusão possível em 4 quadros: juntar 3 e 4 como `Gen 37:15-16`.

### A.3 O que o texto diz × o que NÃO diz

| O texto diz (`Gen 37:12-17`) | O texto NÃO diz |
|---|---|
| Os irmãos foram apascentar o rebanho **do pai** em Siquém (`37:12`). | Por que escolheram Siquém; há quanto tempo estavam fora; quantos irmãos estavam lá. |
| Israel decide enviar José; José responde "Eis-me aqui" (`37:13`). | O que José sentiu ou pensou ao ser enviado. |
| O objetivo: ver se tudo está bem com os irmãos e o rebanho e trazer notícias (`37:14`). | Que José levasse comida, presentes ou recado além das notícias. |
| Partiu do vale de Hebrom e chegou a Siquém (`37:14`). | Distância, duração da viagem, rota exata, se ia acompanhado ou não (o texto simplesmente não menciona acompanhantes). |
| Um "certo homem" o encontrou vagando pelo campo (`37:15`). | **Quem é o homem**: nome, profissão, origem, por que estava ali. Tradições posteriores o identificam de várias formas (inclusive como anjo) — **interpretação**, não usar como fato. |
| O homem pergunta, José responde, o homem informa Dotã porque **ouviu** os irmãos dizerem "Vamos para Dotã" (`37:15-17`). | Que o homem conhecia José ou a família; que tenha acompanhado José. |
| José foi e os encontrou em Dotã (`37:17`). | Por que os irmãos foram a Dotã. O texto dá a entender que pastoreavam lá (a pergunta de `37:16` é sobre onde apascentam e a resposta é Dotã), mas não descreve Dotã. |
| — | Se José vestia a túnica durante a viagem. Só `Gen 37:23` (fora deste trecho) diz que ele a vestia quando chegou aos irmãos. Se o quadro mostrar José, a túnica pode aparecer, mas sem destaque nem comentário. |
| — | A idade exata de José neste momento: `Gen 37:2` dá 17 anos antes, sem dizer quanto tempo passou até `37:12`. |

**Restrições para a missão:**
- **O jogador não pode ser o homem de `Gen 37:15`**, nem falar com José, nem indicar o caminho, nem levar recado entre Hebrom, Siquém e Dotã. O relato já registra quem orientou José; um viajante fictício que fizesse isso reescreveria o texto.
- O jogador não encontra José no caminho, não o acompanha e não avisa os irmãos da chegada dele.
- O caminho do jogador pode **espelhar a geografia** (Siquém → Dotã) como viagem própria, por outros motivos (fictícios), sem cruzar com José.
- Nenhum NPC fictício diz ter visto José, os irmãos ou o homem do campo.

### A.4 Falas de NPCs fictícios (contexto, sem testemunho)

Todas: `classification: historical_context` (costume) dentro de fala de personagem fictício (`plausible_fiction`). Nenhuma menciona José, os filhos de Jacó, Hebrom como origem de alguém, nem o homem do campo. As afirmações de costume são generalizações que o **revisor histórico** deve confirmar (`needs_human_review`).

1. **Pastora de Canaã (fictícia)**
   > "Quando o pasto perto das tendas acaba, os rapazes levam as ovelhas para longe. Às vezes passam muitos dias fora, e quem fica em casa só espera notícias."
   - Base: costume geral de deslocar rebanhos (coerente com `Gen 37:12` e `Gen 37:14`, que mostram irmãos longe e um pai querendo notícias), mas a fala não se refere a eles.

2. **Mercador de estrada (fictício, anônimo; não é ismaelita nem midianita do relato)**
   > "Por esta estrada passam caravanas com cargas de resinas e perfumes, descendo para o Egito. A gente para onde há água e pasto para os animais."
   - Base: `Gen 37:25` mostra uma caravana com especiarias, bálsamo e mirra a caminho do Egito, avistada perto de Dotã. A fala fica no costume genérico; não sugere que ele faça parte daquela caravana nem que compre pessoas.
   - Atenção ao momento: se o jogador o encontra **antes** dos quadros de `Gen 37:18-36`, a fala não pode prenunciar a venda.

3. **Pastor de Dotã (fictício)**
   > "Os campos de Dotã têm bom pasto. Pastores de outros lugares, até de perto de Siquém, às vezes trazem os rebanhos para cá quando o capim fica fraco por lá."
   - Base: o texto mostra rebanhos levados a Siquém e depois a Dotã (`Gen 37:12`, `37:17`). **Risco:** "de perto de Siquém" pode soar como alusão aos irmãos. Versão mais segura, se o revisor preferir: "Pastores de lugares distantes às vezes trazem os rebanhos para cá quando o capim fica fraco." (`needs_human_review`)

Não usar nas falas: "ouvi dizer que…", "vi um rapaz…", "uns irmãos passaram…", qualquer menção a túnica, sonho ou cisterna.

---

## B) Missão secundária fictícia — "Duas famílias, uma decisão"

**Natureza:** totalmente fictícia (`plausible_fiction`), sem relação com o relato de José. Duas famílias fictícias de pastores em Dotã; o jogador divide suprimentos (ajudar uma, ajudar a outra, ou buscar uma solução que permita repartir).

**Regra de uso das referências:** as citações aparecem só como **nota do diário/narrador** depois da decisão, nunca na boca dos NPCs. Os pastores vivem na época patriarcal (datação absoluta `debated`) e não conheciam a Lei de Moisés, os Provérbios nem o Novo Testamento. A nota deve dizer explicitamente que o texto é de época posterior.

### B.1 Referências candidatas (todas localizadas no VPL)

| Ref. | Paráfrase própria | Contexto original | Adequação ao cenário patriarcal |
|---|---|---|---|
| `Lev 19:9-10` (paralelo `Lev 23:22`) | Na colheita, não colher até os cantos do campo nem catar o que caiu; deixar para o pobre e o estrangeiro. | Lei dada pelo SENHOR a Moisés para a congregação de Israel (`Lev 19:1-2`). Época mosaica, **posterior** aos patriarcas. | Média-baixa. Tema certo (deixar parte para o necessitado), mas é lei agrícola (campo, vinha) e a missão é pastoril. Só como nota "mais tarde, a Lei de Israel…". |
| `Deut 15:7-8` (+ `Deut 15:11`) | Se houver um irmão pobre, não fechar a mão; abrir a mão e emprestar o suficiente para o que lhe falta. | Discurso de Moisés a Israel em Moabe, antes de entrar na terra (`Deut 1:1-5`); no capítulo do cancelamento de dívidas a cada sete anos (`Deut 15:1-2`). Posterior aos patriarcas. "Irmão" = membro do povo de Israel. | Média. Fala de necessidade concreta e generosidade, mas está ligada a instituições (ano da remissão, terra dada por Deus) que não existem na cena. Nota de diário com aviso de época. |
| `Deut 24:19` (+ `24:20-22`) | O feixe esquecido no campo fica para o estrangeiro, o órfão e a viúva. | Lei mosaica, discurso de Moisés; o v. 22 liga a prática à memória da escravidão no Egito. Posterior aos patriarcas. | Baixa. Agrícola e dependente da memória do Egito, que na cronologia do jogo **ainda não aconteceu** — risco de anacronismo forte. |
| `Ruth 2:2-3`, `Ruth 2:15-16` | Rute pede para apanhar espigas atrás dos ceifeiros; Boaz manda deixá-la apanhar e até soltar espigas para ela. | Narrativa da época dos juízes (`Ruth 1:1`); exemplo vivido da prática da respiga. Posterior aos patriarcas. | Baixa-média. Bom exemplo de generosidade discreta, mas é colheita de cevada e envolve personagens bíblicos de outra época; serve melhor a outro episódio. |
| `Prov 3:27-28` | Não negar o bem a quem é devido quando se pode fazê-lo; não mandar o próximo voltar amanhã se já se tem o que ele precisa. | Sabedoria em forma de instrução "meu filho" (`Prov 3:1`); livro aberto com "Os provérbios de Salomão" (`Prov 1:1`), com coletâneas posteriores (`Prov 25:1`, homens de Ezequias). Época monárquica ou posterior; autoria e datação dos cap. 1–9 são **debatidas**. | **Alta.** Princípio geral, sem instituições da Lei; casa diretamente com uma decisão sobre suprimentos disponíveis agora. Ainda assim é texto posterior: só no diário. |
| `Prov 19:17` | Quem tem compaixão do pobre empresta ao SENHOR, e ele o recompensará. | Provérbios de Salomão (seção a partir de `Prov 10:1`). Posterior. | Média. **Risco:** a ideia de recompensa pode ser lida como "ajudar para ganhar algo"; não ligar a recompensa material do jogo (regra 12). |
| `Acts 2:44-45` / `Acts 4:32-35` | Os que criam tinham tudo em comum e repartiam conforme a necessidade de cada um; não havia necessitado entre eles. | Narrativa de Lucas sobre a comunidade de crentes em Jerusalém após o Pentecostes, século I (`Acts 1:1`, `Acts 2:41-42`). Ligada à fé em Jesus e ao testemunho dos apóstolos (`Acts 4:33`). Se é descritivo ou modelo normativo é **debatido**. | Baixa. Contexto cristão específico, distância de muitos séculos; aplicar a duas famílias de pastores seria forçar o texto. Não recomendado. |
| `Gal 6:2` | Carregar os fardos uns dos outros, cumprindo a lei de Cristo. | Carta de Paulo às igrejas da Galácia (`Gal 1:1-2`), século I. | Média-baixa. Imagem clara (carregar o fardo do outro) e boa para a solução de repartir, mas "lei de Cristo" é explicitamente cristã e anacrônica na cena. Nota do diário bem identificada. |
| `Jas 2:15-16` | Se alguém está sem roupa e sem comida e você só diz "vá em paz, aqueça-se e coma" sem dar o necessário, de que adianta? | Carta de Tiago "às doze tribos na Dispersão" (`Jas 1:1`), século I; argumento sobre fé sem obras (`Jas 2:17`). | Média. Muito concreto (comida, necessidade do corpo), mas o ponto do autor é fé e obras; usar só o exemplo pode recortar o argumento. Nota do diário com contexto. |
| **Extra:** `Gen 13:5-9` | Os rebanhos de Abrão e Ló eram tantos que a terra não sustentava os dois; houve briga entre os pastores; Abrão propôs que não houvesse briga, "pois somos parentes", e deixou Ló escolher para que lado ir. | Narrativa patriarcal (Gênesis), **mesma época geral** do episódio. Fala de Abrão registrada em `Gen 13:8-9`; só pode aparecer por paráfrase referenciada. Paralelos: `Gen 36:6-7` (Esaú e Jacó se separam porque a terra não sustentava os rebanhos); `Gen 26:20-22` (disputa por poços entre pastores). | **Alta** quanto à época e ao tema (pastores, recursos limitados, evitar contenda). Diferença: a solução de Abrão é **separar-se**, não repartir suprimentos; a nota não deve dizer que o texto "ensina repartir". Os NPCs fictícios não citam nem conhecem a história (mesmo sendo antiga, não sabemos o que pastores de Dotã saberiam). |

### B.2 As 2 melhores
1. **`Prov 3:27-28`** — tema exato da missão (fazer o bem que está ao alcance, sem adiar), linguagem geral, sem instituições da Lei nem conteúdo cristão específico. Nota sugerida: "Séculos depois, um provérbio de Israel diria: não negue o bem a quem precisa quando você pode fazê-lo (Pv 3:27-28)."
2. **`Gen 13:8-9`** (com `Gen 13:5-7` como contexto) — é da época patriarcal e trata exatamente de pastores aparentados que disputam recursos e procuram evitar contenda. Nota sugerida: "Gênesis conta que, quando a terra não sustentava os rebanhos de Abrão e Ló, Abrão procurou evitar a briga entre os pastores (Gn 13:5-9)." Não forçar o texto a ensinar partilha.

Alternativa se o criador quiser uma referência do Novo Testamento: `Jas 2:15-16` (mais concreta que `Gal 6:2`), sempre com nota de época e do argumento original.

### B.3 Cuidados de design
- Nenhum dos três desfechos deve ser "abençoado" por um versículo como se fosse a resposta bíblica correta. A nota do diário oferece reflexão (`devotional_educational`), não veredito. (`needs_human_review`: o criador decide se a solução de repartir é apresentada como preferível.)
- Não associar recompensa material do jogo a um versículo (regra 12), especialmente `Prov 19:17` e `Deut 15:10`.
- Não usar "irmão" das leis (`Deut 15`) para sugerir que as famílias fictícias são israelitas; na época patriarcal "Israel" ainda é o nome de Jacó, não um povo com Lei.
- As famílias fictícias não podem ter ligação com a família de Jacó nem ter visto os irmãos de José.

---

## C) Caravana de `Gen 37:25-28` — contexto para colecionáveis

### C.1 O que o texto diz
- **Quem:** "uma caravana de ismaelitas" (`Gen 37:25`); "mercadores midianitas" passavam (`Gen 37:28`).
- **De onde:** vinha **de Gileade** (`Gen 37:25`).
- **Transporte:** **camelos** (`Gen 37:25`).
- **Mercadorias:** **especiarias, bálsamo e mirra** (`Gen 37:25`). O texto não traz quantidades, preços nem outros produtos.
- **Destino:** **Egito** ("descendo para levá-los ao Egito", `Gen 37:25`; "levaram José para o Egito", `Gen 37:28`).
- **Venda de José:** por **vinte peças de prata** (`Gen 37:28`). Fica fora de qualquer colecionável (ver abaixo).
- Depois: os midianitas vendem José a Potifar no Egito (`Gen 37:36`); `Gen 39:1` diz que Potifar o comprou "das mãos dos ismaelitas".

### C.2 Nota sobre ismaelitas e midianitas
O texto usa os dois nomes no mesmo relato: ismaelitas em `Gen 37:25`, `37:27`, `37:28` e `Gen 39:1`; midianitas em `Gen 37:28` e `37:36`. O texto não explica a relação entre eles. Hipóteses discutidas por estudiosos (termos sobrepostos para mercadores nômades, dois grupos distintos, camadas literárias diferentes) são **debatidas** e não devem ser resolvidas no jogo. Ismael e Midiã aparecem em Gênesis como filhos de Abraão (`Gen 16:15`, `Gen 25:2`; ver ficha geral). Nota de jogo sugerida: "O relato chama os mercadores de ismaelitas e também de midianitas."

Também está em aberto quem tirou José da cisterna em `Gen 37:28` ("eles"); ver ficha geral, riscos. Não importa para os colecionáveis, mas nenhum texto da caravana deve decidir isso.

### C.3 Uso como colecionáveis (sugestões, `historical_context`)
- Pode virar item de exploração ou descoberta: **especiarias, bálsamo, mirra** (como cargas de uma caravana **fictícia** genérica), **Gileade** como região de origem, **rota para o Egito**, **camelo de carga**.
- **Não pode virar item:** a prata da venda, a túnica, a cisterna de José, qualquer coisa "da caravana que levou José" (regra 12 e restrição de não participar da venda).
- Usos de bálsamo e mirra (perfume, remédio, sepultamento etc.), a geografia de Gileade e a rota comercial são **contexto histórico externo ao texto** → `needs_human_review` pelo revisor histórico.
- Camelos na era patriarcal: possível anacronismo discutido por historiadores. O jogo mostra o que o texto diz, sem nota polêmica (`needs_human_review`).

---

## Itens `needs_human_review`
1. Afirmações de costume nas três falas de NPCs (A.4): deslocamento de rebanhos, Dotã como área de pasto, paradas de caravana. Revisor histórico.
2. Fala do pastor de Dotã: usar a versão com "perto de Siquém" ou a versão genérica (risco de alusão aos irmãos).
3. Nota do quadro 2 ("Israel é outro nome de Jacó"): conferir se o diário já explica isso (`Gen 32:28`/`Gen 35:10` não foram conferidos nesta pesquisa).
4. Autoria e datação de `Prov 3` (atribuição salomônica dos cap. 1–9 debatida); como o jogo se refere a ela ("um provérbio de Israel").
5. Uso de `Gen 13:5-9` como nota da missão secundária: a solução de Abrão é separação, não partilha; o criador decide se a analogia serve.
6. Se a missão secundária apresenta a solução de repartir como preferível ou deixa os três desfechos equivalentes.
7. Importar para `bpm.json` e `verse_counts.json` as referências escolhidas (nenhuma das de B está importada, exceto `Gen 13:10`).
8. Ismaelitas × midianitas e o sujeito de `Gen 37:28`: manter formulação neutra.
9. Contexto de bálsamo, mirra, especiarias, Gileade e camelos para os colecionáveis (C.3).

## Fontes consultadas
- `C:\TEMP\biblia\porbrbsl\porbrbsl_vpl.txt` (BPM, domínio público): `Gen 13:5-11`, `Gen 26:20-22`, `Gen 33:18`, `Gen 35:27`, `Gen 36:6-8`, `Gen 37:1-3`, `Gen 37:12-36`, `Gen 39:1`, `Lev 1:1`, `Lev 19:1-2`, `Lev 19:9-10`, `Lev 23:22`, `Deut 1:1-5`, `Deut 15:1-2`, `Deut 15:7-11`, `Deut 24:19-22`, `Ruth 1:1`, `Ruth 2:1-3`, `Ruth 2:7`, `Ruth 2:15-17`, `Prov 1:1`, `Prov 3:1`, `Prov 3:27-28`, `Prov 10:1`, `Prov 19:1`, `Prov 19:17`, `Prov 25:1`, `Acts 1:1`, `Acts 2:41-47`, `Acts 4:32-35`, `Gal 1:1-2`, `Gal 6:2`, `Jas 1:1`, `Jas 2:15-17`; contagem de versículos dos capítulos usados.
- `data/bible/books.json`, `data/bible/verse_counts.json`, `data/bible/texts/bpm.json` (cobertura de importação).
- `production/episodes/ep_008_jose_e_seus_irmaos/research_biblical.md` (ficha geral do episódio).
- `.cursor/agents/biblical-researcher.md`, `docs/ai-wiki/BIBLICAL_RULES.md`, `docs/mission_factory.md`.
- Conhecimento geral do pesquisador (IA) sobre datação, autoria e debates acadêmicos: **não verificado**, marcado como debatido ou `needs_human_review`.
