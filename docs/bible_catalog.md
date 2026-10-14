# Catálogo Bíblico — Visão e Método

Objetivo: considerar **toda a Bíblia** como fonte de histórias, personagens,
locais, ensinamentos e ambientação, com rastreabilidade de cada referência e
separação clara entre texto bíblico e criação do jogo.

## Abrangência

- Catálogo-base: 66 livros do cânon protestante (`data/bible/books.json`, 1.189 capítulos).
- Arquitetura preparada para outros cânones: o campo `canon` e a lista de livros podem ser estendidos com os deuterocanônicos (Tobias, Judite, 1–2 Macabeus, Sabedoria, Eclesiástico, Baruque e acréscimos a Ester e Daniel) num arquivo separado, sem alterar código.
- Versificação: segue as Bíblias em português (ex.: Joel 3, Malaquias 4). Divergências com o texto hebraico devem ser anotadas na história.

## Tipos de tratamento por natureza literária

| Tratamento | Livros típicos | Como entra no jogo |
|---|---|---|
| `narrative_experience` | Gn, Êx, Nm, Js, Jz, Rt, Sm, Rs, Ed, Ne, Et, Dn 1–6, Jn, Evangelhos, Atos | Experiências exploráveis que acompanham o relato |
| `context_environment` | Lv, Dt, Cr, partes de Êx/Nm | Ambientação: tabernáculo, festas, ofícios, leis do cotidiano, genealogias no diário |
| `music_reflection` | Sl, Ct, Lm, cânticos (Êx 15, Lc 1–2) | Música, momentos de contemplação, textos no diário |
| `wisdom_choices` | Pv, Ec, Jó, Tg | Situações cotidianas e escolhas de diálogo, sem “resposta certa” moralista |
| `prophetic_context` | Is, Jr, Ez, profetas menores | O profeta em seu contexto histórico (reis, impérios, cidades); mensagens citadas, não transformadas em fantasia |
| `letters_communities` | Cartas paulinas e gerais | Exploração das cidades destinatárias (Corinto, Éfeso, Filipos…) e da vida das comunidades |
| `apocalyptic_symbolic` | Ap, Dn 7–12, partes de Ez/Zc | Linguagem visionária sinalizada como simbólica; sem apresentar interpretações controversas como fato |

## Schema de história (`data/bible/stories/*.json`, chave `stories`)

| Campo | Descrição |
|---|---|
| `id` | `livro_capítulo_slug` (ex.: `gen_037_joseph_sold`) |
| `title`, `summary` | Escritos para o jogo (sem copiar traduções protegidas) |
| `references[]` | `{book, chapter_start, verse_start, chapter_end, verse_end}`; `book` = id OSIS de `books.json` |
| `characters[]`, `region` | Pessoas e local |
| `era {label, certainty}` | `certainty`: `approximate`, `approximate_debated`, `unknown` |
| `literary_category` | narrativa, poesia, profecia, evangelho, parábola, carta, apocalíptica… |
| `content_classification` | ver abaixo |
| `possible_interactions[]`, `possible_activities[]` | Ideias de gameplay |
| `narrative_relevance` | `core`, `context`, `teaching`… |
| `design_constraints[]` | Limites de fidelidade (ex.: “o jogador não impede a venda”) |
| `depends_on[]` | Ids de histórias anteriores (cronologia) |
| `used_in[]` | Onde a referência aparece no jogo |
| `verification {status, reviewer, notes}` | `draft`, `pending_review`, `reference_checked`, `approved` |

### Classificação do conteúdo

1. `recorded_event` — acontecimento explicitamente registrado.
2. `historical_context` — contextualização histórica apoiada em pesquisa.
3. `plausible_fiction` — interação fictícia plausível (moradores, viajante).
4. `parable_adaptation` — adaptação de parábola, identificada como tal.
5. `symbolic_interpretation` — interpretação de texto simbólico.
6. `devotional_educational` — conteúdo devocional ou educativo.

### Regras de verificação

Os mesmos status valem para histórias, descobertas, apresentações, épocas, acontecimentos, lugares, pessoas e missões (`scripts/bible/content_policy.gd`):

| Status | Significado | Canal protótipo | Canal público |
|---|---|---|---|
| `draft` (Rascunho) | Em escrita | oculto | oculto |
| `pending_review` (Aguardando verificação) | Escrito ou conferido por IA; precisa de revisão | visível, com aviso | oculto |
| `reference_checked` (Referência conferida) | Uma pessoa conferiu as referências | visível | oculto |
| `approved` (Aprovado) | Uma pessoa aprovou para publicação | visível | visível |

- Nenhuma referência é inventada. Livro, capítulo e versículo são conferidos contra `books.json` e `data/bible/verse_counts.json`; um capítulo citado sem contagem é erro.
- `reference_checked` e `approved` exigem `verification.reviewer` humano. Revisores como "IA", "ChatGPT" ou "agente" são recusados. **Nada pode ser marcado como verificado só porque foi gerado ou conferido por IA.**
- Os testes automáticos verificam:
  - livro existente, capítulo dentro do livro e versículo dentro do capítulo;
  - intervalos não invertidos;
  - classificação e status válidos;
  - revisor humano;
  - dependências e vínculos existentes.
- Datas e locais debatidos (ex.: datação dos patriarcas, rota do Êxodo) são marcados como aproximados ou debatidos, com hipóteses quando houver. Ver a cronologia em [quests.md](quests.md#cronologia-databiblechronologyjson).
- Relatório: `tools/validate_content.gd` (também roda no build do .exe).

## Texto bíblico no jogo

Desde a v0.2.1 o jogo **mostra o texto dos versículos** citados, separado das notas e resumos
próprios. Decisão em [ADR-016](ai-wiki/DECISIONS.md#adr-016--texto-bíblico); situação da licença em KI-06.

- **Tradução ativa:** `caminhos/content/bible_translation` no `project.godot` (hoje `bpm`,
  Bíblia Portuguesa Mundial, domínio público, eBible.org; provisória). A NVI, pedida pelo criador,
  depende de permissão da Biblica.
- **Arquivo:** `data/bible/texts/<id>.json` com `translation` (id, name, abbrev, license, credit,
  source, source_file, retrieved), `verification` e `verses` (`"Gen 26:18": "texto"`).
- **Importação (nunca digitar versículos):** baixe o arquivo VPL oficial da tradução no eBible.org
  e rode
  `Godot --headless --path . --script res://tools/import_scripture.gd -- <arquivo_vpl.txt> <id>`.
  O script procura todas as referências `"Livro C:V[-V]"` nos JSON de `data/`, copia só esses
  versículos e falha (código 1) se faltar algum. Rode de novo sempre que entrarem referências novas;
  o teste "todas as referências ... têm texto" acusa o esquecimento.
- **Onde o texto aparece:** passos de apresentação com `scripture`; diário (livros em Escrituras,
  até 6 versículos por passagem; descobertas, até 4); falas do narrador com `scripture` no nó
  (até 3 versículos). Sem o arquivo ou acima do limite, aparecem só a referência ou o `text` do nó.
- **API:** `Bible.quote(ref, max)` (BBCode com números), `Bible.quote_plain`, `Bible.cite(ref)`
  ("Gênesis 26:18 (BPM)"), `Bible.credit()`; `BibleCatalog.verses_of`, `expand_reference`.
- **Créditos:** menu Créditos e `LICENSES.txt` do build leem o crédito da tradução ativa.
- **Trocar de tradução:** adicionar metadados em `TRANSLATIONS` do importador (ou, no caso de texto
  licenciado sem VPL, um humano monta o JSON no mesmo formato), registrar a licença no ADR-016 e
  mudar a configuração.

## Estado atual

| Item | Situação |
|---|---|
| Lista de livros (66) com capítulos e tratamentos | concluído |
| Histórias-piloto | 7 (6 `pending_review`, 1 `draft`) |
| Descobertas | 12 (`pending_review`) |
| Épocas / acontecimentos / lugares / pessoas | 11 / 9 / 14 / 8 (`pending_review`) |
| Apresentações | 1: Gênesis 26:12-22, os poços de Isaque (`pending_review`) |
| Aprovado por revisão humana | nada ainda |
| Livros com catalogação iniciada | Gênesis, Êxodo, Mateus |
| Demais livros | `not_started` |

## Plano de catalogação

1. **Ondas por bloco**: Pentateuco → Históricos → Evangelhos/Atos → Profetas → Poéticos/Sapienciais → Cartas → Apocalipse.
2. Para cada livro: listar perícopes (unidades narrativas), classificar, ligar a regiões e personagens, marcar oportunidades de gameplay e restrições de fidelidade.
3. Livros sem narrativa adaptável também são catalogados (ambientação, música, sabedoria, cidades das cartas), com `catalog_status` atualizado em `books.json`.
4. Revisão humana em lotes: `reference_checked`, depois `approved`, com o nome do revisor.
5. O diário bíblico do jogo lerá diretamente este catálogo.
