# Histórico de implementação

## 2026-10-14 — v0.1.0: fundação jogável (Fases 1–3)

### Auditoria inicial
- Pasta do projeto vazia: nenhum arquivo a preservar. Repositório git inicializado.
- Godot não instalado: baixado o executável oficial portátil **Godot 4.7.2-stable** em `tools/godot/` (fora do git).
- Python indisponível (apenas o atalho da Microsoft Store): todas as ferramentas foram escritas em GDScript.
- Fonte **Pixelify Sans** baixada do repositório oficial `google/fonts` com a licença OFL (`assets/fonts/OFL.txt`).

### Decisões técnicas
- **Stretch `canvas_items` + escala inteira** (em vez de `viewport`): arte nítida com filtro nearest e textos sem borrão em qualquer escala.
- **Renderer Compatibility**: roda em hardware modesto e permite exportar para web no futuro.
- **Arte provisória procedural** (`tools/art_gen/`): gera PNGs pixel a pixel a partir das paletas; contorno colorido automático e sombras de chão. Sem assets de terceiros.
- **Mapa gerado por ferramenta** (`build_world.gd`) e salvo como `.tscn` comum, portanto editável no editor. Após edições manuais, regenerar apenas com `-PropsOnly`.
- **Autotile próprio** (16 máscaras) para terra, grama seca e pedra: bordas orgânicas sem depender de terrains configurados à mão.
- **Interação por componente único** (`Interactable`) + seleção por proximidade/direção (`InteractionDetector`).
- **Dados separados da lógica**: personagens, regiões, diálogos e catálogo bíblico em JSON, todos validados por testes.
- **Save** JSON versionado com escrita atômica, `.bak`, sanitização e mensagens amigáveis; o caminho é configurável para os testes não tocarem o save real.

### Problemas encontrados e corrigidos
- Em `--script`, os autoloads não existem durante `_init()`, e os scripts do jogo falhavam ao compilar. Correção: o construtor passou a usar `_initialize()`.
- Na primeira captura, as manchas de grama seca e a praça apareciam como blocos quadrados. Correção: viraram camadas autotile com bordas irregulares.
- As casas tinham a porta mais baixa que um personagem. Correção: a fachada passou a ter 84 px de altura, com porta de 26 px.
- Os pássaros do fundo do menu encostavam no subtítulo, e o subtítulo da região quebrava linha. Correção: os pássaros foram reposicionados e o painel ficou mais largo.

### O que funciona (verificado)
- Menu principal: novo jogo (com confirmação se já houver save), continuar, configurações (tela cheia e volume, persistidos), créditos e sair.
- Aldeia de 60×40 tiles: praça com poço, mercado com 2 bancas, 3 casas, tenda com fogueira, forno com fumaça, curral com 3 ovelhas, olival, cinturão de árvores, pedras, arbustos e flores.
- Movimento em 8 direções com velocidade diagonal normalizada, corrida (Shift), aceleração e atrito, animação em 4 direções, câmera suave limitada ao mapa.
- Colisão com cenário, NPCs e bordas do mapa. Profundidade por ordenação Y.
- 4 moradores (passeio ou parado) e 3 ovelhas, todos configurados por JSON. O NPC se vira para o jogador ao conversar.
- 20 pontos de interação com balão "E" e verbo contextual.
- Diálogos com digitação letra a letra, retrato, escolhas, condições e flags (os moradores lembram que já conversaram).
- Pausa (Esc): continuar, salvar, salvar e voltar ao menu, salvar e sair. Fechar a janela salva automaticamente.
- Continuar restaura mapa, posição, direção e flags.

### Testes executados
- `tests/test_runner.tscn`: **68/68** verificações (entrada, dados, diálogos, cenas de objetos, catálogo bíblico, save, gameplay simulado e menu).
- `tests/flow_smoke.gd`: **9/9** verificações do fluxo real pelos menus (menu → novo jogo → pausa → salvar e voltar → continuar).
- O jogo foi aberto com renderização real (OpenGL 3.3, NVIDIA Quadro P2200) sem erros. O editor também abriu em modo headless sem erros nem avisos.
- Capturas de tela reais estão em `docs/images/`.

### O que NÃO foi testado
- **Sensação de jogo jogando de verdade**, com teclado e por uma pessoa: ritmo do movimento, conforto da câmera e legibilidade em monitores diferentes. Os testes simulam a entrada, mas não substituem uma sessão de jogo.
- Tela cheia e escalas diferentes de 3×.
- Gamepad (ainda não mapeado).
- Exportação: feita depois, ver a entrada seguinte.

### Provisório / pendências
- Toda a arte, exceto a fonte, é provisória (lista no art bible, seção 10).
- Sem áudio (nenhum asset de licença verificada foi incluído).
- Iluminação fixa (sem dia/noite).
- Os interiores das casas e as outras regiões ainda não existem; as portas e os marcos de pedra avisam isso.
- Catálogo bíblico: base dos 66 livros e 7 histórias-piloto. As referências marcadas como `ai_checked` precisam de revisão humana.
- Pontos históricos que pedem pesquisa adicional: vestuário exato da Idade do Bronze em Canaã (cores e cortes) e presença de mercados com bancas em aldeias pequenas (liberdade criativa assumida).

### Próxima atividade recomendada
Uma sessão de jogo do criador para validar escala, movimento e legibilidade.
Depois, Fase 4: transição para o interior de uma casa, ciclo dia/noite, som
ambiente e o primeiro uso de inventário (ver `roadmap.md`).

## 2026-10-14 — Exportação Windows (v0.1.0)

### O que foi feito
- `export_presets.cfg` (versionado): preset `Windows Desktop`, x86_64, release, PCK embutido, filtro `data/*.json`, ícone do projeto e metadados de versão.
- `tools/install_export_templates.ps1`: baixa os templates oficiais 4.7.2, confere o SHA-512 e extrai só os de Windows.
- `tools/build_windows.ps1`: pipeline completo (versão, templates, importação, testes, exportação, testes do .exe e log). Guia em `build_windows.md`.
- `scripts/build/export_self_test.gd`: autoteste ativado por `-- --self-test`. O `SceneRouter` só o instancia com esse argumento; o jogo normal não muda.
- `.gitignore`: `dist/` ignorado; `export_presets.cfg` deixou de ser ignorado. `tools/godot/.gdignore` impede o Godot de importar o próprio binário.

### Problemas encontrados e corrigidos
- O template release ignora `--script` (abria o menu e nunca encerrava). O autoteste passou a ser um nó ativado por argumento de usuário.
- `--log-file` gerou arquivo vazio no template. O build agora captura o stdout do .exe.
- Scripts `.ps1` com acentos precisam de UTF-8 com BOM no PowerShell 5.1.

### Verificado (build de 14/10/2026)
- Godot 4.7.2.stable.official.ed1daf0bf, com templates da mesma versão.
- Importação sem erros; testes do projeto 68/68 e de fluxo 9/9.
- `dist/windows/CaminhosDaPromessa.exe`: 104,5 MB (template de 104,2 MB e 0,3 MB de dados), sem `.pck` separado, com ícone do jogo e versão 0.1.0.0.
- Cópia isolada em `%TEMP%`, com os 22 itens do autoteste OK: os JSON de todas as pastas de `data/`, 5 personagens, 15 diálogos, 66 livros, 7 histórias, mapa com jogador e 20 interativos, e save/load em `user://` fora da pasta do .exe.
- Inicialização headless (600 quadros) e com janela (OpenGL 3.3, Quadro P2200) sem erros; código de saída 0.
- O script retorna o código 1 quando falha (testado com um caminho de Godot inválido).

### Ajuste: .exe na raiz
- O build copia o .exe para `CaminhosDaPromessa.exe` na raiz, só depois de todos os testes passarem. O atalho é `criar_exe_atualizado.bat`.
- `assets/fonts/OFL.txt` passou a ser embutido no .exe, que sozinho cumpre a licença da fonte; o autoteste confere isso.
- Verificado: build pelo .bat OK (23 itens do autoteste). Com o jogo aberto, o build falha com mensagem clara e o .exe anterior fica intacto.

### Não verificado
- Jogar o .exe exportado manualmente (interface, tela cheia, sensação).
- Execução em outra máquina, em Windows sem GPU dedicada ou com antivírus/SmartScreen; o .exe não é assinado.

## 2026-10-14 — v0.2.0: missões, contexto histórico e aprendizado bíblico

### Auditoria (Fase A)
- O que já existia e foi preservado:
  - movimento, colisão, mapa e arte;
  - diálogos por JSON com flags;
  - save versionado com `.bak`;
  - catálogo com 66 livros e 7 histórias;
  - export Windows.
- O que faltava:
  - objetivo e guia ao jogador (só havia flags soltas);
  - contexto bíblico visível durante o jogo;
  - diário;
  - cronologia;
  - registro de aprendizado.
- Decisão: sistemas novos ao lado dos existentes (autoloads `Bible`, `QuestManager`, `Discoveries`), sem reescrever diálogo, jogador ou mapa. Os diálogos só ganharam campos opcionais (`unlock`, `event`, `action`).

### O que foi feito
- **Fase B, prólogo** (`cinematic.gd`, `data/story/prologues.json`):
  - título, revelação do cenário com câmera no poço, cartão de lugar e época, contexto de Gn 26 e objetivo;
  - pode ser pulado com Esc e revisto pela pausa;
  - não repete ao carregar; saves v1 migram como "já visto".
- **Fase C, HUD** (`hud.gd`, `ui_style.gd`):
  - painel de contexto recolhível (Tab);
  - "Sua jornada" com 3 pistas por objetivo (H) e lembrete após 150 s;
  - avisos discretos, cartões de descoberta e o cartão "História explorada";
  - banner de lugar, época e referência;
  - fila que espera diálogos e cenas.
- **Fase D, descobertas**: 12 descobertas com seções tipadas, vínculos e verificação, e 3 níveis de aviso configuráveis.
- **Fase E, missões**: `QuestDatabase` e `QuestManager` por eventos (9 tipos), com objetivos retroativos e controle para debug. Missão-piloto "A importância dos poços" com Adina, poço, Ezer e a apresentação de Gn 26:12-22 em 6 passos.
- **Fase F, diário** (`journal.gd`, `journal_content.gd`): Minha jornada, Escrituras, Personagens (fictícios marcados), Lugares (identificação provável ou debatida) e Linha do tempo.
- **Fase G, ferramentas**:
  - editor de missões (plugin `addons/quest_editor`);
  - painel F3 só em debug, excluído da exportação;
  - `tools/validate_content.gd`, integrado ao build;
  - "Testar missão" via `user://debug_boot.json`.
- **Fase H, cronologia**:
  - `Chronology` sem ano zero e com intervalos, séculos e certezas;
  - 11 épocas (patriarcas e Êxodo sem ano, com hipóteses);
  - 9 acontecimentos, entre eles marcos documentados como 722/721 a.C., 587/586 a.C., 539 a.C. e 70 d.C.;
  - 14 lugares e 8 pessoas.
- **Qualidade do conteúdo**:
  - status `draft`, `pending_review`, `reference_checked` e `approved`, com revisor humano obrigatório e nomes de IA recusados;
  - canal `prototype` ou `public`;
  - `verse_counts.json` para conferir versículos.

### Problemas encontrados e corrigidos
- A fonte Pixelify Sans não tem ✓ ★ ▸ → ◆. A interface usa só `›`, `•`, `+` e `·` (glifos testados).
- O nome `log` no GameState sombreava a função global `log()`. Virou `history`, e a chave do save continua `"log"`.
- 2 Reis 25:11 não cita a Babilônia pelo nome. A referência do lugar passou para 2 Reis 24:15.
- O Tab do diário era consumido pela navegação de foco do Godot. O diário passou a tratar as teclas em `_input`.
- Capturas tiradas no meio das animações: o script de captura passou a esperar em tempo real.
- Texto do prólogo cortado na borda inferior e cartão de objetivo cobrindo o jogador: posições ajustadas e conferidas em captura.
- Teste de movimento falhava porque Ari (que passeia) parava ao lado do jogador depois do prólogo. Os NPCs ficam pausados durante esse teste; não era defeito do jogo.

### Verificado (automático, 14/10/2026)
- `test_runner`: **208/208**. Cobre:
  - cronologia e ano zero;
  - referências e contagem de versículos;
  - regra de revisor;
  - validação e vínculos das missões;
  - alvos existentes no mapa;
  - fluxo completo da missão por diálogos reais;
  - pistas;
  - diário em todas as seções;
  - editor (filtros, status, gravação);
  - save v2 e migração v1;
  - prólogo, HUD, diário e apresentação dentro da cena de jogo.
- `flow_smoke`: **17/17**. Novo jogo, prólogo pulado com Esc sem abrir a pausa, missão ativa, diário pela pausa, salvar, Continuar sem repetir o prólogo.
- `validate_content`: sem erros de dados. 63 itens ainda sem aprovação humana, todos `pending_review`, e 1 história `draft`.
- Editor do Godot em modo headless carrega o plugin sem erros. "Testar missão" conferido: o jogo de debug consome o arquivo, abre a aldeia com a missão ativa e carrega o painel F3.
- `criar_exe_atualizado` (build v0.2.0) OK. O autoteste do .exe passou a conferir:
  - missão, prólogo e descobertas empacotados;
  - painel de debug ausente e build sem modo debug;
  - missão e pistas restauradas do save.
- 18 capturas renderizadas (GPU real) em `docs/images/` e conferidas visualmente.

### Não verificado
- **Não houve playtest manual com teclado**. As interações foram simuladas por eventos de entrada nos testes e por chamadas diretas nas capturas. O roteiro manual está em `quests.md`.
- Usabilidade do editor de missões com mouse no editor gráfico: só o carregamento foi testado, além da lógica em `QuestEditorModel`.
- **Revisão humana do conteúdo bíblico e histórico**: tudo continua "Aguardando verificação". A conferência das referências foi feita pelo agente de IA e não vale como verificação.

### Próxima atividade recomendada
1. Jogar o roteiro manual de `quests.md` e ajustar o ritmo (tempo do lembrete, quantidade de cartões).
2. Revisão humana das 12 descobertas, da apresentação de Gn 26 e da cronologia, registrando o revisor.
3. Segunda missão ligada a esta (`start: quest_completed:canaan_wells`), por exemplo pastoreio e o relato de José em Dotã (Gn 37:12-17), sem misturar épocas.

## 2026-10-14 — AI Wiki: memória e continuidade para agentes de IA

### Auditoria
- Não havia `AGENTS.md`, regras do Cursor nem documentação de continuidade.
- O repositório Git não tem commits nem remoto; todos os arquivos estão não rastreados (registrado como KI-01).
- Documentação desatualizada em relação à v0.2: `roadmap.md` (fases 4–6), `game_design.md` (diário e missões como futuros) e `architecture.md` (região sem `context`). As três foram corrigidas.

### O que foi feito
- `AGENTS.md` na raiz: ponto de entrada curto com a instrução obrigatória de consultar a wiki.
- `docs/ai-wiki/`: índice com leitura progressiva e o procedimento de recuperação de contexto, além de visão geral, estado atual, mapa da arquitetura, sistemas de jogo, regras bíblicas, regras de desenvolvimento, 17 ADRs, problemas conhecidos, testes, handoff e changelog. Tudo foi conferido contra o código.
- `.cursor/rules/`: uma regra sempre ativa que aponta para `AGENTS.md`, e duas por arquivo (dados narrativos e código Godot) que apontam para as regras da wiki.
- `tools/check_wiki.ps1`, sem dependências. Verifica:
  - arquivos obrigatórios;
  - links relativos;
  - caminhos citados;
  - campos do estado e do handoff;
  - a versão contra `project.godot`;
  - aviso de desatualização por data.

  Também roda como etapa informativa de `tools/build_windows.ps1`.
- Nenhum script, cena, sprite, missão ou diálogo do jogo foi alterado.

### Verificado
- `check_wiki.ps1`: OK. O teste negativo com documento temporário detectou link quebrado, caminho inexistente, seção ausente, versão divergente e data desatualizada; também ignorou blocos de código, padrões com curinga e caminhos do `.gitignore`.
- Testes do jogo depois da tarefa: `test_runner` 208/208, `flow_smoke` 17/17 e validação sem erros de dados.
- Build com a nova etapa: todas as etapas foram aprovadas, inclusive a da wiki, até a inicialização com renderização. A cópia final para a raiz falhou porque o exe estava aberto; o anterior foi mantido.
- Teste de recuperação: um agente sem contexto, lendo só a documentação, respondeu às 12 perguntas. As lacunas que apontou foram corrigidas:
  - handoff incompleto;
  - conta dos 63 itens;
  - status `draft` do editor;
  - etapas do build.

### Não verificado
- O carregamento automático de `AGENTS.md` e de `.cursor/rules` num chat novo do Cursor (não observável de dentro da sessão que os criou).
- A recuperação por outro modelo. Foi feito só o teste de perguntas e respostas usando a própria documentação.

## 2026-10-14 — v0.2.1: orientação na missão, leitura mais suave e texto bíblico

### Pedido do criador
"Na missão inicial não tem como saber o que fazer, tudo foi testado mas não avança"; o texto está
legível mas com dificuldade e precisa ser levemente mais suave; colocar mais trechos bíblicos em vez
de só citar as referências. Escolhas do criador: fonte Lora; tradução NVI.

### Diagnóstico
- O save do criador mostrava a missão **concluída** (Adina, poço, Ezer, relato), mas com as 3 pistas
  usadas no último objetivo. O gatilho funcionava; faltava orientação, e depois da conclusão nada
  indicava que a versão tinha acabado.
- A Pixelify em corpo pequeno é áspera por desenho; ajustes de hinting e subpixel quase não mudaram
  a leitura. Além disso, o `line_spacing` padrão do Label (3) separava demais as linhas da Lora.
- A NVI é protegida (Biblica) e não havia arquivo oficial nem permissão. Decisão (ADR-016): sistema
  independente de tradução, abastecido agora pela Bíblia Portuguesa Mundial (domínio público).

### O que foi feito
- **Orientação:** `scripts/world/objective_guide.gd` (marcador e seta de borda, criado em `game.gd`);
  textos dos objetivos com quem e onde (`data/quests/canaan/canaan_wells.json`); linha no prólogo
  sobre a seta e o H; diário com "E: Ler o relato bíblico" antes do objetivo e "Rever o relato" depois;
  mensagem de fim de conteúdo no cartão de conclusão.
- **Fonte:** Lora variável (regular e itálico) com OFL; tema do `RichTextLabel` e
  `UiStyle.reading` para Labels com quebra; gerador do tema (`build_world.gd`) atualizado; licença
  embutida no exe e em `LICENSES.txt`.
- **Texto bíblico:** `tools/import_scripture.gd` (VPL do eBible.org; os códigos de livro desses
  arquivos não são USFM, ex. `MAR`, `JOH`, `NAH`, e o script confere a ordem de `books.json`);
  `data/bible/texts/bpm.json` com 196 versículos; `BibleCatalog.load_translation/verses_of/expand_reference`;
  `Bible.quote/quote_plain/cite/credit`; campo `scripture` em passos de apresentação (validado) e em
  nós de diálogo; apresentação de Gn 26 reorganizada em 7 passos (versículos + notas próprias);
  diário cita as passagens; três falas do narrador citam Gn 25:27, 26:20 e 37:25; créditos no menu;
  validador mostra o status do texto; autoteste do exe confere o texto e as licenças.
- Versão 0.2.1.

### Verificado
- `test_runner` 239/239 (31 novos), `flow_smoke` 17/17, validação sem erros de dados.
- Comparação do texto importado com o arquivo de origem (Gn 26:18, Nm 1:1, Mc 1:14, Jo 4:5).
- Capturas conferidas: apresentação com versículo, seta sobre Adina, fala com citação, diário com
  texto e crédito, prólogo, HUD com espaçamento corrigido.

### Não verificado
- Sessão de jogo humana (KI-02).
- Correspondência das referências do texto BPM conferida por uma pessoa (o texto está `pending_review`).

## 2026-10-14 — v0.4.0: expansão para RPG de aventura bíblica (várias regiões, bolsa, Mapa das Escrituras)

### Pedido do criador
"Expandir profissionalmente a estrutura que já existe", sem recriar o jogo: vários mapas com transição
e persistência, Mapa das Escrituras por épocas (M), estrada das caravanas e Dotã, categorias de missão,
diário por categoria com "Minhas descobertas", bolsa (I) com troca, colecionáveis, flags e condições
compostas, novos tipos de objetivo, HUD com região, época, referência e objetivo, save completo com
migração, validação da fábrica, quatro missões-piloto, testes, build e documentação. O que não couber
no ciclo fica explicitamente pendente.

### O que foi feito
- **Mundo:** `WorldManager` (autoload), regiões em `data/regions/`, `MapExit`/`MapArea`, `GameMap`
  instancia saídas, áreas, NPCs, examináveis e coletáveis do JSON; viagem dentro de `game.tscn` com
  escurecimento, título da região e salvamento automático (ADR-021). Mapas novos `caravan_road.tscn`
  e `dothan.tscn` gerados por `tools/art_gen/build_regions.gd`, sem tocar no mapa da aldeia.
- **Condições:** `Conditions` + `ConditionSchema` (ADR-022), usadas por diálogos, missões, saídas, NPCs e experiências.
- **Bolsa e colecionáveis:** `Inventory`, `Collectibles`, `Pickup`, `InventoryScreen` (I), ícones gerados,
  sons sintetizados (`Sfx`); efeitos de diálogo `give`/`take`/`repeatable`/`decision`/`grant_collectible`/`flags` (ADR-023).
- **Missões:** categorias, missão acompanhada, `OBJECTIVE_TYPES`, gatilhos de estado (`inventory`,
  `collection`, `condition`), alvos `examinable`/`pickup`/`area`/`exit`/`region`/`ui`, `rewards` uma vez,
  `completion.variants`, `objective_region` e seta para a saída.
- **Mapa das Escrituras:** `ScriptureMap` (M) + `data/world/experiences.json`; atlas de lugares dentro dele (ADR-024).
- **Diário:** Jornada agrupada por categoria, aba "Descobertas", registro de viagens, decisões e colecionáveis.
- **Save v3** com migração (ADR-025).
- **Conteúdo (ep_008, Gn 37:12-17):** "O caminho para Dotã" (principal), "Suprimentos para a viagem",
  "Duas famílias, uma decisão" (3 desfechos persistentes), "Registros da caravana"; 4 descobertas,
  apresentação `gen_037_search`, 8 colecionáveis, 4 personagens fictícios; texto BPM com 220 versículos.
- **Fábrica:** `FactoryCatalog.quest_world_errors` (alvos por região, itens, conjuntos, escolhas das
  variantes); ep_006 recheck histórico e status `tested`.
- **Revisões de agente aplicadas:** auditoria bíblica (B1–B12), pesquisas históricas (missões e mapas)
  e QA (Q1–Q6); registro em `production/episodes/ep_008_jose_e_seus_irmaos/review.json`.
- **Correções:** ligadura "fi" da Pixelify desligada no tema ("fibras" aparecia como "Abras"); o
  runner falha se `tests/world_tests.gd` não compilar (antes dava falso "0 falharam").
- **Autoteste do exe** ampliado para regiões, mapas, itens, colecionáveis e as missões novas.
- Versão 0.4.0.

### Problemas encontrados e corrigidos
- `ConditionSchema` recusava `choice` sem `option` e descartava diálogos; agora significa "escolha ainda não feita".
- Experiência "ativa por causa da missão" impedia registrar `experience_started`; regra restrita a `active_with_quest`.
- QA: salvar no meio da cadeia de Malik travava a missão; material descartável podia travar a entrega;
  a pedra de Dotã não reabria o relato; Rafi perguntava pelas famílias depois da decisão; a seta marcava
  registros já encontrados. Todos corrigidos com testes.

### Verificado
- `test_runner` 561/561, `flow_smoke` 17/17, validação sem erros de dados, `factory check` 0 erros.
- Build Windows com autoteste ampliado (ver HANDOFF).
- Capturas `tools/screenshot/capture_v04.tscn` (10 telas) conferidas visualmente.

### Não verificado / pendente
- Sessão de jogo humana (KI-02); revisão humana do conteúdo (72 itens).
- Rechecagem bíblica das correções em andamento no fim da sessão (ver HANDOFF).
- Não construídos: `escort_npc`, mapas do Egito e de Belém, continuação de Gn 37:18-36 (KI-13).

## 2026-10-14 — v0.5.0: efeitos sonoros

### Auditoria inicial
- O projeto não tinha nenhum arquivo de áudio nem buses além do Master. `Sfx` gerava tons em memória para
  coleta, entrega, colecionável, viagem e recusa. O volume do usuário estava em 1,0, então nada estava
  silenciado por engano: a causa da falta de som era não haver sons.

### Entregue
- **`AudioManager`** (`scripts/core/audio_manager.gd`, autoload depois do `SceneRouter`):
  - conjunto fixo de 14 players, mais 6 posicionais e 2 para o ambiente;
  - prioridade com roubo de voz, cooldown, limite de instâncias, variações sem repetição, pitch/volume aleatórios;
  - `supersedes` para o clique do mesmo gesto;
  - fila de marcos por quadro, silêncio de 0,6 s ao carregar, nada fora do jogo;
  - ambiente por região com troca de 1,4 s, camadas ocasionais e emissores presos ao mapa;
  - `shutdown()`.
- **Manifesto** `data/audio/sfx.json`: 74 ids, superfícies, materiais por diálogo/tipo, itens, ambiente.
- **Buses** em `default_bus_layout.tres`, com limitador no Master.
- **Passos:** sinal `step` em `CharacterSprite` (quadros 0 e 2), `Player._on_step` com velocidade real
  mínima, `GameMap.surface_at` pelas camadas de tiles (cache da lista de camadas).
- **Ligações:**
  - `Inventory.moved(item, delta, source)`, e o `Sfx` antigo de coleta/entrega removido de `pickup.gd` e `dialogue_manager.gd`;
  - `Interactable.interact` → `play_interaction`;
  - diário, bolsa, Mapa das Escrituras, pausa, menu inicial, cinemática e caixa de diálogo (som de texto opcional; bus Voice);
  - `game.gd` (viagem, região nova, ambiente).
- **Configurações:** `Settings` com volume e silenciar por bus, hover e som de texto, compatível com o arquivo
  antigo (`master_volume`), gravação com atraso. Painel `AudioSettingsPanel` no menu (substitui o controle
  único de volume e o aviso "Áudio ... chegam em versões futuras") e na pausa ("Sons e volume").
- **Arquivos:**
  - 131 WAV gerados por `tools/audio/generate_sfx.gd`, com a biblioteca `tools/audio/synth.gd` (filtros, Karplus-Strong, reverberação, laços com emenda);
  - auditoria `tools/audio/audit_audio.gd` e leitor `tools/audio/wav_info.gd`.
- **Testes:**
  - `tests/audio_tests.gd`, chamado pelo runner, que agora usa um arquivo de configurações próprio;
  - autoteste do exe confere manifesto, buses, os 131 arquivos e o laço do ambiente.
- **Documentação:** `docs/audio.md`; ADR-026; KI-16 e KI-17.
- Versão 0.5.0.

### Problemas encontrados e corrigidos
- DC em `amb_village_grind_1` (-0,049): passa-altas de 30 Hz em todos os sons curtos.
- Recursos de áudio "ainda em uso" ao sair (testes, fluxo e exe): `shutdown()` para players, emissores e cache, e quem encerra espera um instante.
- Testes que mediam por quadros em headless (passos de corrida, viagem) passaram a medir por tempo real. Na corrida, o jogador batia num objeto a 48 px.
- Sons do manifesto sem uso: `reward` (recompensa, coalescida com missão concluída), `objective_update` (acompanhar missão no diário), `ui_cancel` ("Não" na confirmação de novo jogo).

### Verificado
- `test_runner` 665/665 (três execuções seguidas e dentro do build); `flow_smoke` 17/17; validação sem erros
  de dados; `factory check` 0 erros; auditoria de áudio 131 arquivos, 0 problemas; build completo com
  autoteste; autoteste repetido 10 vezes no exe exportado sem recurso preso.

### Não verificado / pendente
- **Escuta humana de todos os sons** (KI-16). Nenhum teste avalia timbre.
- Música, vozes, ambiente do Egito, superfícies de areia/madeira/água nos mapas, objetos de metal.
- Uma execução do build com falha intermitente de gameplay, não reproduzida (KI-17).

## 2026-10-14 — Checkpoint no GitHub e memória dos agentes

### Entregue
- Auditoria do projeto contra o código: 3 mapas, 3 regiões, 5 missões, 8 itens, 13 autoloads, 131 WAV, 78 episódios no catálogo, 9 subagentes e 3 regras do Cursor.
- Memória:
  - `AGENTS.md` revisto;
  - `docs/ai-wiki/AI_AGENTS.md` e `docs/ai-wiki/NEW_AGENT_START_HERE.md` criados;
  - `GAME_SYSTEMS.md`, `README.md` (raiz e wiki), `CURRENT_STATE.md`, `HANDOFF.md`, `TESTING.md` e `KNOWN_ISSUES.md` atualizados.
- Segurança: varredura dos 748 arquivos versionáveis sem segredos nem dados pessoais. `.gitignore` ampliado (Cursor/MCP particulares, `.env`, chaves, logs, temporários); `.gitattributes` com binários de áudio.
- Testes: `Input.flush_buffered_events()` nas teclas simuladas (KI-17).
- Git: identidade local (nome do criador e e-mail noreply do GitHub), branch `main`, credenciais pelo `gh` só neste repositório, repositório privado criado pelo `gh`.

### Verificado
- Build 15:12: 665/665, fluxo 17/17, validação, wiki, export, autoteste, boots.
- `factory check` 0 erros; auditoria de áudio 0 problemas; 50 JSON válidos.

### Não verificado / pendente
- Build das 15:11 reprovado (4 falhas intermitentes, KI-17 em observação).
- Escuta humana dos sons (KI-16) e sessão de jogo (KI-02).

## 2026-10-14 — Publicação pública e colaboração com IA

### Entregue
- Auditoria de segurança dos 753 blobs do histórico (padrões de tokens, chaves, credenciais em URL, entropia, hexadecimais longos, metadados de PNG e WAV, dados pessoais): sem achados.
- Auditoria de direitos autorais: arte e sons gerados por código do projeto; capturas do próprio jogo; fontes OFL 1.1; texto bíblico BPM em domínio público; nenhum recurso restritivo ou de origem desconhecida. Inventário em `docs/legal/ASSET_LICENSES.md`.
- Licenças escolhidas pelo criador: `LICENSE` (MIT) e `LICENSE-ASSETS.md` (CC BY 4.0); ADR-027.
- `README.md` público; `START_WITH_AI.md`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md`, `CHANGELOG.md` na raiz; modelos de issue e PR; `.github/workflows/tests.yml` (Godot oficial conferido por SHA-512, `contents: read`, sem segredos) e `.github/dependabot.yml`.
- Documentação dos agentes atualizada para repositório público.

### Verificado
- Suíte 665/665, fluxo 17/17, validação sem erros, fábrica 0 erros, auditoria de áudio 0 problemas, wiki OK, links dos novos documentos.

### Não verificado / pendente
- Build do exe não refeito (nada do exe mudou). Resultado do workflow e da publicação no HANDOFF.

## 2026-10-14 — Infraestrutura: cenas dirigidas, luz por estado, experiências com destino (ADR-028)

### Entregue
- `scripts/world/scene_database.gd`, `scene_director.gd`, `scene_actor.gd`, `scene_fx.gd`, `world_schema.gd` (novos); integração em `game.gd`, `game_map.gd` (luz), `world_manager.gd` (destino, etapas, passagens), `map_exit.gd`, `scripture_map.gd` (botão e cartão de passagem), `quest_database.gd`, `dialogue_database.gd`, fábrica, `validate_content.gd`, `export_self_test.gd`.
- `data/world/experiences.json`: `travel` em `isaac_wells` e `joseph_dothan` (e `regions` em `joseph_dothan`). Nenhum conteúdo de episódio, nenhum campo novo no save.
- `tests/scene_tests.gd` + `tests/data/scenes/test_scenes.json` (fora da exportação).

### Problemas corrigidos durante a tarefa
- A chave proibida `points` (recompensa) colidia com `params.points` do `light_glow`: virou `score`.
- Erro de referência repetido pelo catálogo (início e fim do intervalo) agora aparece uma vez só nas cenas.

### Verificado
- Suíte 775/775, fluxo 17/17, validação sem erros, fábrica 0 erros em 78 episódios; autoteste (`-- --self-test`) rodado pelo editor: checagens de cenas aprovadas (as 4 falhas são as esperadas fora de um exe release).

### Não verificado / pendente
- Exe não gerado; efeitos sem avaliação visual nem captura; propostas de `production/` divergem do formato (KI-20).
