# Decisões (ADRs)

Registro de decisões arquiteturais. Não reescreva um ADR antigo: para mudar, crie um novo e marque o
anterior como `Substituída por ADR-xxx`.

**Status usados**
- `Adotada`: em vigor e confirmada no código. Quem decidiu está indicado: o criador, ou o agente com aceitação implícita (o criador seguiu o projeto sem objeção).
- `Proposta`: ainda não decidida; não tratar como regra.
- `Substituída`: trocada por um ADR mais novo.

Fontes: [docs/implementation_log.md](../implementation_log.md), [docs/art_bible.md](../art_bible.md), código.

| ID | Título | Status |
|---|---|---|
| ADR-001 | Godot 4.7 + GDScript | Adotada (agente; engine deixada em aberto pelo criador) |
| ADR-002 | Renderer Compatibility | Adotada (agente) |
| ADR-003 | 480×270, `canvas_items` + escala inteira | Adotada (agente; ainda não validada jogando) |
| ADR-004 | Conteúdo orientado a dados em JSON | Adotada (criador pediu orientação a dados) |
| ADR-005 | Arte provisória procedural em GDScript | Adotada (agente) |
| ADR-006 | Mapa gerado por ferramenta e salvo como `.tscn` | Adotada (agente) |
| ADR-007 | Componente único de interação | Adotada (agente) |
| ADR-008 | Save JSON versionado com gravação segura | Adotada (agente) |
| ADR-009 | Fidelidade bíblica: viajante fictício e classificação | Adotada (criador) |
| ADR-010 | Status de verificação com revisor humano e canais | Adotada (criador pediu verificação humana; formato do agente) |
| ADR-011 | Cronologia sem ano zero, com incerteza explícita | Adotada (agente, a partir de exigência do criador) |
| ADR-012 | Missões por eventos registrados como flags | Adotada (agente) |
| ADR-013 | Sistemas novos ao lado dos existentes | Adotada (criador: não reescrever) |
| ADR-014 | Exe único com PCK embutido e autoteste | Adotada (criador pediu exe na raiz) |
| ADR-015 | Ferramentas de debug fora da exportação | Adotada (agente) |
| ADR-016 | Texto bíblico: citações importadas de arquivo oficial; tradução como dado (BPM provisória, NVI pedida) | Adotada (criador pediu trechos; NVI depende de permissão) |
| ADR-017 | AI Wiki como memória do projeto | Adotada (criador) |
| ADR-018 | Fonte de leitura Lora; Pixelify em títulos e botões | Adotada (criador escolheu a Lora) |
| ADR-019 | Seta de objetivo no mundo | Adotada (agente, após relato do criador) |
| ADR-020 | Fábrica de missões: catálogo com gates e subagentes por papel | Adotada (criador) |
| ADR-021 | Várias regiões na mesma cena de jogo (`WorldManager`), com salvamento automático na chegada | Adotada (criador pediu múltiplos mapas; formato do agente) |
| ADR-022 | Condições compostas únicas (`Conditions`) para diálogos, missões, saídas, NPCs e experiências | Adotada (agente) |
| ADR-023 | Inventário por troca, sem moedas; efeitos de diálogo atômicos e recompensas uma única vez | Adotada (criador pediu inventário e troca; formato do agente) |
| ADR-024 | Mapa das Escrituras (M) por épocas; o atlas de lugares fica dentro dele | Adotada (criador pediu o mapa M; formato do agente) |
| ADR-025 | Save v3 com migração da v2 | Adotada (agente) |
| ADR-026 | Áudio central por manifesto, com efeitos procedurais provisórios | Adotada (criador pediu sons; formato do agente) |
| ADR-027 | Repositório público com licença dupla (MIT + CC BY 4.0), PRs revisados e CI sem segredos | Adotada (criador) |

---

### ADR-001 — Godot 4.7 + GDScript
- **Data:** 2026-10-14 · **Status:** Adotada (agente; a engine foi deixada em aberto pelo criador)
- **Problema:** escolher engine para RPG 2D pixel art, desenvolvido com agentes de IA, sem custo de licença.
- **Alternativas:** Godot, Unity, GameMaker, framework web.
- **Decisão:** Godot 4.7.2 portátil em `tools/godot/`, GDScript.
- **Justificativa:** gratuito (MIT), 2D nativo, cenas e dados em texto (bons para diffs e para IA), exporta exe sem instalador, roda headless para testes.
- **Consequências:** Godot não vai para o Git; quem clona precisa baixá-lo (README). Python não está disponível, então todas as ferramentas são GDScript ou PowerShell.

### ADR-002 — Renderer Compatibility
- **Data:** 2026-10-14 · **Status:** Adotada (agente)
- **Problema:** rodar em máquinas modestas e manter a porta aberta para web.
- **Alternativas:** Forward+, Mobile, Compatibility.
- **Decisão:** GL Compatibility (OpenGL 3.3 / WebGL 2).
- **Justificativa:** o jogo 2D não precisa dos recursos do Forward+.
- **Consequências:** efeitos avançados de iluminação 3D indisponíveis (irrelevante para o estilo).

### ADR-003 — Resolução 480×270 com `canvas_items` e escala inteira
- **Data:** 2026-10-14 · **Status:** Adotada (agente; critérios de legibilidade da fase 3 ainda **não validados jogando**)
- **Problema:** pixel art nítida e textos legíveis em várias resoluções.
- **Alternativas:** stretch `viewport` (pixels perfeitos, texto borrado) ou `canvas_items` (texto nítido).
- **Decisão:** base 480×270, janela 1440×810, `canvas_items` + escala inteira, filtro nearest; tiles 16 px; personagens 24×32. Detalhes em [docs/art_bible.md](../art_bible.md).
- **Consequências:** a UI é desenhada para 480×270; qualquer layout novo deve ser conferido em captura.

### ADR-004 — Conteúdo orientado a dados em JSON
- **Data:** 2026-10-14 · **Status:** Adotada
- **Problema:** crescer em histórias, regiões e personagens sem mexer em código.
- **Decisão:** personagens, regiões, diálogos, missões, prólogos e catálogo bíblico em `data/**/*.json`, carregados por autoloads e validados por testes e por `tools/validate_content.gd`.
- **Consequências:** todo campo novo precisa de validação e teste; o editor de missões grava JSON (formatação pode mudar ao salvar).

### ADR-005 — Arte provisória procedural
- **Data:** 2026-10-14 · **Status:** Adotada (agente)
- **Problema:** ter arte coerente sem assets de terceiros e sem licenças a verificar.
- **Decisão:** `tools/art_gen/generate_art.gd` gera os PNGs pixel a pixel a partir das paletas.
- **Consequências:** arte é provisória; substituir por arte final exige manter tamanhos e folhas de sprite (art_bible).

### ADR-006 — Mapa gerado por ferramenta e salvo como `.tscn`
- **Data:** 2026-10-14 · **Status:** Adotada (agente)
- **Decisão:** `tools/art_gen/build_world.gd` produz `scenes/maps/canaan_village.tscn`, editável no editor.
- **Consequências:** **após edições manuais, regenerar apenas com `-PropsOnly`**; caso contrário, as edições se perdem.

### ADR-007 — Componente único de interação
- **Data:** 2026-10-14 · **Status:** Adotada (agente)
- **Decisão:** `Interactable` (tipos TALK, EXAMINE, READ, COLLECT, OPEN, DOOR) + `InteractionDetector` escolhe o alvo por proximidade e direção.
- **Consequências:** novas interações estendem o componente em vez de criar sistemas paralelos; interações emitem o evento `interact` para missões.

### ADR-008 — Save JSON versionado
- **Data:** 2026-10-14 · **Status:** Adotada (agente)
- **Decisão:** `user://savegame.json` com `version`; gravação em `.tmp`, cópia `.bak`, sanitização e migração (`SAVE_VERSION = 2`, v1→v2).
- **Consequências:** mudar o formato exige incrementar a versão, migrar e testar. A chave `"log"` no save corresponde a `GameState.history` (renomeado para não sombrear `log()`).

### ADR-009 — Fidelidade bíblica: viajante fictício e classificação
- **Data:** 2026-10-14 · **Status:** Adotada (pedido do criador)
- **Problema:** ensinar sem distorcer o texto.
- **Decisão:** o jogador é um viajante fictício; acontecimentos são acompanhados, não alterados; todo conteúdo tem uma de 6 classificações. Regras completas em [BIBLICAL_RULES.md](BIBLICAL_RULES.md).
- **Consequências:** limita o tipo de missão (testemunhar, ajudar, investigar; nunca mudar o relato).

### ADR-010 — Status de verificação e canais
- **Data:** 2026-10-14 · **Status:** Adotada
- **Decisão:** status `draft` → `pending_review` → `reference_checked` → `approved`; os dois últimos exigem revisor humano (nomes de IA recusados). Canal `prototype` mostra conteúdo pendente com aviso; `public` só mostra `approved`.
- **Consequências:** hoje nada está aprovado; uma build pública não teria conteúdo bíblico visível.

### ADR-011 — Cronologia sem ano zero, com incerteza explícita
- **Data:** 2026-10-14 · **Status:** Adotada
- **Decisão:** `scripts/bible/chronology.gd`: anos negativos = a.C., sem ano 0; intervalos, séculos e certeza (`documented`, `approximate`, `debated`, `unknown`); período sem data confiável usa `null`.
- **Consequências:** nenhuma data é inventada para épocas debatidas (patriarcas, Êxodo).

### ADR-012 — Missões por eventos registrados como flags
- **Data:** 2026-10-14 · **Status:** Adotada (agente)
- **Decisão:** sistemas emitem `QuestManager.record_event(type, id)`, que grava `ev:<type>:<id>` em `GameState`; objetivos se completam por esses eventos, inclusive retroativamente.
- **Consequências:** o save guarda o histórico de eventos automaticamente; novos tipos de evento entram em `EVENT_TYPES` e na doc de [docs/quests.md](../quests.md).

### ADR-013 — Sistemas novos ao lado dos existentes
- **Data:** 2026-10-14 · **Status:** Adotada (regra do criador: não reescrever o que funciona)
- **Decisão:** na v0.2, `Bible`, `QuestManager` e `Discoveries` foram adicionados como autoloads; diálogo, jogador e mapa só ganharam campos opcionais.
- **Consequências:** preferir extensão a reescrita nas próximas versões.

### ADR-014 — Exe único com PCK embutido e autoteste
- **Data:** 2026-10-14 · **Status:** Adotada (criador pediu o exe na raiz e o `.bat`)
- **Decisão:** preset Windows com PCK embutido; `tools/build_windows.ps1` roda testes, validação, exporta, executa `-- --self-test` e só então copia para `CaminhosDaPromessa.exe` na raiz. Ver [docs/build_windows.md](../build_windows.md).
- **Consequências:** exe fora do Git; build falha se qualquer teste falhar.

### ADR-015 — Ferramentas de debug fora da exportação
- **Data:** 2026-10-14 · **Status:** Adotada (agente)
- **Decisão:** painel F3 só com `OS.is_debug_build()`; `exclude_filter` exclui `tests/*`, `tools/*`, `docs/*`, `addons/*` e `scripts/ui/debug_panel.gd`; o autoteste confirma.
- **Consequências:** código de debug não pode ser dependência do jogo.

### ADR-016 — Texto bíblico
- **Data:** 2026-10-14 (revista no mesmo dia, v0.2.1) · **Status:** Adotada.
- **Problema:** o criador pediu "mais trechos bíblicos ao invés de só citar". Antes, o jogo mostrava só resumos próprios e referências (versão anterior desta decisão). O criador pediu a **NVI**, mas ela é protegida (Biblica) e não há arquivo oficial nem permissão registrada.
- **Alternativas:** digitar a NVI (recusado: direitos autorais e risco de erro de memória); Bíblia Livre (CC BY 4.0 BR, exige crédito); Bíblia Portuguesa Mundial (domínio público); Almeida 1911 (licença da edição não confirmada).
- **Decisão:** a tradução é um **dado**. `tools/import_scripture.gd` copia, do arquivo oficial VPL do eBible.org, só os versículos citados nos JSON de `data/` para `data/bible/texts/<id>.json`, com metadados (nome, licença, crédito, fonte). A configuração `caminhos/content/bible_translation` escolhe o arquivo. Hoje: **`bpm`** (Bíblia Portuguesa Mundial, domínio público), marcada como provisória e `pending_review`. O texto **nunca** é digitado à mão.
- **Consequências:** apresentações (`scripture` por passo), diário e falas do narrador (`scripture` no nó) mostram o versículo; sem o arquivo, voltam a mostrar o resumo e a referência. Créditos no menu e em `LICENSES.txt`. Trocar para a NVI exige: permissão da Biblica registrada aqui, o criador colar os versículos em `data/bible/texts/<id>.json` com id `nvi` (mesmo formato) e mudar a configuração. A BPM é descrita pelos tradutores como rascunho em revisão (KI-06).

### ADR-018 — Fonte de leitura Lora
- **Data:** 2026-10-14 · **Status:** Adotada (o criador escolheu a Lora entre amostras)
- **Problema:** textos longos em Pixelify Sans ficavam "legíveis, mas com dificuldade" (relato do criador).
- **Alternativas:** manter Pixelify, outras fontes pixel, fontes serifadas ou sem serifa (Lora, Nunito, Literata e outras foram comparadas em captura).
- **Decisão:** Lora (SIL OFL 1.1, `assets/fonts/Lora-*.ttf`, licença em `assets/fonts/OFL-Lora.txt`) para `RichTextLabel` (tema) e para `Label` com quebra de linha (`UiStyle.label(..., wrap=true)` → `UiStyle.reading`). Pixelify continua em títulos, botões, etiquetas e dicas de tecla. `line_spacing` do Label zerado nos textos de leitura.
- **Consequências:** o tema é gerado também por `tools/art_gen/build_world.gd`, que foi atualizado para não perder a Lora ao regenerar. Glifos especiais continuam limitados pela Pixelify nos rótulos curtos.

### ADR-019 — Seta de objetivo no mundo
- **Data:** 2026-10-14 · **Status:** Adotada (agente, após o criador relatar que "não tem como saber o que fazer")
- **Problema:** o save do criador mostrou a missão concluída, mas com todas as pistas usadas: o problema era orientação, não um gatilho quebrado.
- **Decisão:** `ObjectiveGuide` (`scripts/world/objective_guide.gd`), criado por `game.gd` em cada mapa, desenha um marcador dourado sobre o alvo do objetivo atual (campo `targets` da missão) ou uma seta na borda da tela quando ele está fora de vista. Some com UI bloqueada, em diálogo e quando o alvo já está em foco (o aviso "E" aparece no lugar). Textos de objetivo passaram a dizer quem/onde; o diário oferece "Ler o relato bíblico" (tecla E) em qualquer momento.
- **Consequências:** todo objetivo precisa de `targets` que existam no mapa (já testado); objetivos sem alvo não mostram seta.

### ADR-017 — AI Wiki como memória do projeto
- **Data:** 2026-10-14 · **Status:** Adotada (pedido do criador)
- **Problema:** continuidade entre chats, modelos e resumos de contexto.
- **Alternativas:** depender do histórico do chat; regras longas do Cursor; documentação neutra no repositório.
- **Decisão:** `AGENTS.md` curto na raiz + `docs/ai-wiki/` em Markdown neutro + regras curtas em `.cursor/rules/` que só apontam para elas; verificação por `tools/check_wiki.ps1`.
- **Consequências:** toda tarefa termina atualizando `HANDOFF.md` (e o que mais a política de manutenção pedir).

### ADR-020 — Fábrica de missões: catálogo com gates e subagentes por papel
- **Data:** 2026-10-14 · **Status:** Adotada (pedido do criador: "EXECUTAR FÁBRICA DE MISSÕES")
- **Problema:** produzir dezenas de episódios (78 propostas) sem inventar texto bíblico, sem publicar conteúdo não revisado e sem quebrar o jogo, com trabalho delegado a vários agentes.
- **Alternativas:** criar missões direto em `data/` (sem rastreio de revisão); planilha externa; EditorPlugin completo; catálogo JSON + linha de comando com gates.
- **Decisão:** `production/` guarda o catálogo (`episodes.json`, gerado do catálogo-semente sem alterar o original) e um pacote por episódio (pesquisas, propostas, `review.json`, manifestos, `test_report.json`). `tools/factory.gd` muda estados só quando os requisitos cumulativos são atendidos; `published` exige pessoa em `review.json` e `verification` aprovada. Papéis em `.cursor/agents/*.md`; propostas ficam no pacote e só o integrador escreve em `data/`. Áudio por manifesto com hash do texto; provedor só com autorização e orçamento. Processo completo em [mission_factory.md](../mission_factory.md).
- **Consequências:** `production/` fica fora do exe. A estimativa de esforço e o mapa de capacidades mostram que a maioria dos 78 episódios precisa de mapa novo e de mecânicas (gatilho de área, inventário) que ainda não existem. Subagentes customizados só são invocáveis por `/nome` em chat novo (KI-10).

### ADR-021 — Várias regiões na mesma cena de jogo
- **Data:** 2026-10-14 (v0.4.0) · **Status:** Adotada (o criador pediu múltiplos mapas com transições e persistência; o formato é do agente)
- **Problema:** o jogo tinha um único mapa. A expansão pede estrada das caravanas e Dotã, ida e volta, e progresso preservado.
- **Alternativas:** trocar a cena inteira por região via `SceneRouter` (recria HUD, diário e diálogo a cada viagem); uma cena gigante; regiões como dados e só o mapa trocado dentro de `game.tscn`.
- **Decisão:** `data/regions/<id>.json` descreve cada região (mapa, entradas, saídas com condição, áreas, NPCs, examináveis, coletáveis, contexto). O autoload `WorldManager` resolve entradas, saídas, rotas (`route_exit`) e coletas por região (`world_key`). `game.gd` escurece a tela, troca só o nó do mapa, mostra o título discreto da região e salva automaticamente ao chegar. `GameMap` instancia em tempo de execução saídas (`MapExit`), áreas (`MapArea`), NPCs, examináveis e coletáveis descritos no JSON. Os mapas novos são gerados por `tools/art_gen/build_regions.gd`, sem alterar `canaan_village.tscn` nem a arte existente.
- **Consequências:** HUD, diário e diálogo sobrevivem às viagens. Missão em outra região mostra a seta para a saída (`ObjectiveGuide`) e "Siga para:" no HUD. Mapas novos precisam de um JSON de região e de alvos reais, conferidos por testes e pela fábrica (`quest_world_errors`).

### ADR-022 — Condições compostas únicas
- **Data:** 2026-10-14 (v0.4.0) · **Status:** Adotada (agente)
- **Problema:** escolhas, saídas, NPCs, experiências e missões precisavam testar flags, itens, escolhas, coleções e missões, sem regra presa no código de cada NPC.
- **Decisão:** `scripts/core/conditions.gd` (`Conditions.check`) avalia `all`/`any`/`not` e chaves simples (`flag`, `has_item`, `choice`, `collectibles`, `quest_*`, `objective`, `event`, `region`...). `ConditionSchema` valida a estrutura sem depender de autoloads (roda na linha de comando da fábrica). `{"choice": id}` sem `option` significa "escolha ainda não feita".
- **Consequências:** toda chave nova entra nos dois arquivos e em [docs/quests.md](../quests.md#condições-e-efeitos).

### ADR-023 — Inventário por troca e efeitos atômicos
- **Data:** 2026-10-14 (v0.4.0) · **Status:** Adotada (o criador pediu inventário e troca; o formato é do agente)
- **Problema:** missões de entregar e receber sem duplicar itens nem recompensas, coerentes com a época dos patriarcas.
- **Decisão:** `data/items/items.json` + autoload `Inventory` (12 espaços na bolsa e compartimento de essenciais que não se descarta); sem moedas cunhadas, ferro comum, vidro ou papel. Efeitos de diálogo: `take` é atômico (tudo ou nada); `give` acontece uma vez por nó/escolha, salvo `repeatable` (troca); `decision {id, option}` registra a escolha (`choice:<id>`) e o evento `choice_made`; `grant_collectible`. Recompensas de missão são dadas uma vez (flag `reward:<id>`). Coletáveis do mapa são marcados por região e não reaparecem.
- **Consequências:** desfechos de missão por `completion.variants` (`if` + título/resumo). Testes cobrem entrega, troca repetível, ausência de duplicação após trocar de mapa e após salvar/carregar.

### ADR-024 — Mapa das Escrituras (M) por épocas
- **Data:** 2026-10-14 (v0.4.0) · **Status:** Adotada (o criador pediu o mapa M organizado por épocas; o formato é do agente)
- **Problema:** escolher experiências bíblicas de épocas diferentes sem sugerir que o viajante envelhece ou que tudo acontece na mesma semana.
- **Decisão:** `data/world/experiences.json` (épocas, experiências, estados planejada/bloqueada/disponível/ativa/concluída, `requires`, `completed_by`). `ScriptureMap` (tecla M) mostra o cartão "OUTRO MOMENTO DA HISTÓRIA" antes de iniciar uma experiência e registra `experience_started`. O atlas de lugares que a tecla M abria antes passou a ser o botão "Atlas de lugares" dentro do mapa. `active_with_quest` só vale para experiências cuja missão começa sozinha.
- **Consequências:** experiências sem mapa ficam `planned` e aparecem como planejadas, sem simular conteúdo.

### ADR-025 — Save v3
- **Data:** 2026-10-14 (v0.4.0) · **Status:** Adotada (agente)
- **Decisão:** `SAVE_VERSION = 3`; novos campos `inventory`, `world` (coletas), `collectibles`, `current_region`. A migração v2→v3 cria os campos vazios e deduz a região do mapa salvo. Substitui a versão citada em ADR-008, que continua valendo no resto.
- **Consequências:** saves v1 e v2 continuam carregando (testado).

### ADR-026 — Áudio central por manifesto, com efeitos procedurais provisórios
- **Data:** 2026-10-14 (v0.5.0) · **Status:** Adotada (o criador pediu efeitos sonoros funcionando; arquitetura e síntese são do agente)
- **Problema:** o jogo não tinha nenhum arquivo de áudio nem buses além do Master; só `Sfx` tocava tons sintetizados em poucos lugares. Não havia gravações, bibliotecas autorizadas nem orçamento para serviços pagos.
- **Decisão:** autoload `AudioManager` com conjunto fixo de players, prioridade, cooldown, variações, substituição de cliques e fila de marcos por quadro; manifesto `data/audio/sfx.json` (sons, superfícies, materiais de interação, itens, ambiente por região); buses Master/Music/SFX/UI/Ambience/Voice com limitador no Master; botões ganham som automaticamente; volumes por bus em `Settings`. Os 131 arquivos são **gerados por código** (`tools/audio/generate_sfx.gd`, sementes fixas) e marcados `source: procedural`; trocá-los por gravações não exige mudar código. `Sfx` virou camada de compatibilidade.
- **Consequências:** todo som precisa de escuta humana antes de ser considerado final; bibliotecas externas (ex.: CC0) só com autorização do criador. Detalhes e inventário em [docs/audio.md](../audio.md).

### ADR-027 — Repositório público com licença dupla, PRs revisados e CI sem segredos
- **Data:** 2026-10-14 (v0.5.0) · **Status:** Adotada (o criador pediu a publicação e escolheu as licenças e a CI)
- **Problema:** abrir o projeto para colaboradores que usam os próprios agentes de IA, sem expor dados privados, sem relicenciar material de terceiros e sem permitir que código de pull requests desconhecidos rode com credenciais.
- **Decisão:**
  - código sob **MIT** ([LICENSE](../../LICENSE)); arte, sons e textos próprios sob **CC BY 4.0** ([LICENSE-ASSETS.md](../../LICENSE-ASSETS.md)); terceiros mantêm a licença original (fontes OFL 1.1, BPM em domínio público), com inventário em [docs/legal/ASSET_LICENSES.md](../legal/ASSET_LICENSES.md);
  - `main` protegida (sem force push nem exclusão; mudanças por pull request);
  - workflow `.github/workflows/tests.yml` com `contents: read`, gatilho `pull_request` (nunca `pull_request_target`), ação fixada por SHA, Godot oficial conferido por SHA-512, sem segredos, sem deploy e sem release automática; Dependabot só para as ações;
  - [START_WITH_AI.md](../../START_WITH_AI.md) como prompt de inicialização independente de ferramenta; [CONTRIBUTING.md](../../CONTRIBUTING.md) exige identificar conteúdo feito com IA e revisão humana do conteúdo bíblico.
- **Consequências:** tudo que for versionado é público, inclusive o histórico; recursos externos só entram com licença registrada; a CI roda no Linux e não cobre o build do exe nem a verificação da wiki (PowerShell).
