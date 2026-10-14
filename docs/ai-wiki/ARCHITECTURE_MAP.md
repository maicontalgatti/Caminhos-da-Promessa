# Mapa da arquitetura

Mapa de navegação: **qual arquivo** cuida de **qual sistema**. Formatos de dados completos e o diagrama
de dependências estão em [docs/architecture.md](../architecture.md); missões em [docs/quests.md](../quests.md).
Conferido contra o código em 2026-10-14 (assinaturas abaixo copiadas dos scripts).

## Visão geral
- Autoloads (ordem em `project.godot`, importa: cada um pode usar os anteriores):
  `Settings` → `GameData` → `Bible` → `SaveManager` → `GameState` → `DialogueManager` → `QuestManager` → `Discoveries` → `Inventory` → `Collectibles` → `WorldManager` → `SceneRouter` → `AudioManager`.
- Fluxo: `scenes/ui/main_menu.tscn` → `SceneRouter.change_scene()` → `scenes/core/game.tscn` (instancia o mapa da região, HUD, diálogo, pausa, diário, bolsa, Mapa das Escrituras, cinemática e, só em debug, o painel F3). Viagens entre regiões trocam só o mapa dentro de `game.tscn` (ADR-021).
- Autoloads **não** existem no modo `--script` (fábrica, ferramentas): `ConditionSchema`, `QuestDatabase`, `DialogueDatabase` e `FactoryCatalog` não podem usá-los.
- Comunicação por **sinais** e por **flags** em `GameState`. Missões avançam por **eventos** (`QuestManager.record_event(type, id)` grava a flag `ev:<type>:<id>`).

## Sistemas

### Núcleo e estado
- **Arquivos:** `scripts/core/game_state.gd`, `scripts/core/settings.gd`, `scripts/core/scene_router.gd`, `scripts/core/json_util.gd`.
- **Propósito:** flags, registro de progresso, bloqueio de UI, salvar/carregar, troca de cena, configurações em `user://settings.cfg`.
- **Interfaces:** `GameState.set_flag/get_flag`, `block_ui(owner)/unblock_ui(owner)/is_ui_blocked()`, `save_game()`, `load_game()`; sinais `flag_changed`, `before_save`, `state_replaced`. `Settings.changed`, `cycle_edu_notifications()`.
- **Cuidados:** toda UI modal deve chamar `block_ui`/`unblock_ui` com o mesmo dono; flags aceitam só bool/int/float/string (o save rejeita o resto).
- **Condições:** `scripts/core/conditions.gd` (`Conditions.check(cond)`) e `condition_schema.gd` (`ConditionSchema`, validação sem autoloads). Formatos em [docs/quests.md](../quests.md#condições-e-efeitos) (ADR-022).
- **Volumes:** `Settings.volume(bus)/set_volume/set_muted/is_muted`, `ui_hover_sound`, `text_sound`, `request_save()` (grava com atraso); painel reutilizável `scripts/ui/audio_settings.gd` (`AudioSettingsPanel`) no menu e na pausa.

### Áudio
- **Arquivos:** `scripts/core/audio_manager.gd` (autoload `AudioManager`), manifesto `data/audio/sfx.json`, buses em `default_bus_layout.tres`, arquivos em `assets/audio/`; gerador e auditoria em `tools/audio/`; `scripts/core/sfx.gd` só traduz nomes antigos.
- **Interfaces:** `play(id, opts)`, `play_at(id, pos)`, `event(id)` (marcos coalescidos por quadro), `footstep(surface, running)`, `play_interaction(dialogue_id, kind)`, `set_region(region, map)`, `stop_ambience()`, `shutdown()`, `history`/`played_count` (testes); sinal `played(id)`. Botões: metadados `sfx` e `sfx_hover`. Passos: sinal `step` de `CharacterSprite` + `GameMap.surface_at(pos)`. Bolsa: sinal `Inventory.moved(item, delta, source)`.
- **Cuidados:** som novo entra pelo manifesto, não por player solto; ferramentas que encerram o jogo chamam `AudioManager.shutdown()` e esperam ~0,2 s (senão o Godot acusa recursos em uso). Guia completo: [docs/audio.md](../audio.md) (ADR-026).

### Dados do jogo
- **Arquivos:** `scripts/core/game_data.gd`; dados em `data/characters/`, `data/regions/`, `data/story/`.
- **Interfaces:** `GameData.get_character(id)`, `get_character_name(id)`, `get_portrait(id)`, `get_region(id)`, `prologues`, `errors`.
- **Cuidados:** `GameData.errors` precisa ficar vazio (os testes verificam).

### Conteúdo bíblico
- **Arquivos:** `scripts/bible/bible.gd` (autoload `Bible`), `bible_catalog.gd` (`BibleCatalog`), `chronology.gd`, `content_policy.gd` (`ContentPolicy`), `discoveries.gd` (autoload `Discoveries`).
- **Dados:** `data/bible/` — `books.json` (66 livros), `verse_counts.json`, `chronology.json` (11 épocas, 9 acontecimentos), `places.json`, `people.json`, `discoveries.json` (12), `presentations.json`, `stories/pilot.json`, `texts/bpm.json` (texto dos versículos citados, gerado por `tools/import_scripture.gd`).
- **Interfaces:** `Bible.ref()/refs()/discovery()/presentation()/era_display()/place_name()`; texto bíblico: `Bible.quote(ref, max)`, `quote_plain()`, `cite()`, `credit()`, `BibleCatalog.verses_of()`, `expand_reference()`, `translation`, `scripture`; `Discoveries.unlock(id)/is_unlocked(id)` + sinal `discovery_unlocked`; `ContentPolicy.is_visible()`, `status_of()`, `validate_verification()`, `is_ai_reviewer()`, `channel()`.
- **Cuidados:** regras em [BIBLICAL_RULES.md](BIBLICAL_RULES.md). Referência nova exige a contagem de versículos do capítulo em `verse_counts.json` **e** rodar o importador de novo (o teste acusa versículo sem texto). Canal (`caminhos/content/channel`) define o que aparece; tradução (`caminhos/content/bible_translation`) define o arquivo de texto. Detalhes em [docs/bible_catalog.md](../bible_catalog.md#texto-bíblico-no-jogo).

### Missões
- **Arquivos:** `scripts/quests/quest_manager.gd` (autoload), `scripts/quests/quest_database.gd`; dados em `data/quests/<região>/*.json`.
- **Interfaces:** `record_event(type, id)`, `has_event()`, `evaluate()`, `status()`, `current_objective()`, `primary_quest()`, `request_hint()`, `hint_text()`, `get_context()`, `start_quest()`, `reset_quest()`, `complete_quest()`; sinais `quest_started`, `objective_completed`, `objective_changed`, `quest_completed`, `hint_changed`, `event_recorded`, `context_changed`.
- **Quem emite eventos:** `dialogue_manager.gd` (`dialogue_finished`, `custom`), `interactable.gd` (`interact`), `game.gd` (`region_entered`, `prologue_finished`, `presentation_finished`), `discoveries.gd` (`discovery`).
- **Cuidados:** tipos válidos de evento/missão em `quest_database.gd` (`EVENT_TYPES`, `QUEST_TYPES`); objetivos são retroativos (evento já ocorrido conta). Detalhes em quests.md.

### Diálogo
- **Arquivos:** `scripts/dialogue/dialogue_manager.gd` (autoload), `dialogue_database.gd`, `scripts/ui/dialogue_box.gd` + `scenes/ui/dialogue_box.tscn`; dados em `data/dialogues/`.
- **Interfaces:** `DialogueManager.start(id)`, `advance()`, `choose(i)`, `is_active()`; sinais `dialogue_started`, `line_shown`, `dialogue_ended`, `action_requested`.
- **Cuidados:** efeitos de nó de diálogo (`set_flags`, `unlock` → descobertas, `event` → evento `custom` de missão, `action`) são aplicados pelo manager; ao terminar, emite o evento `dialogue_finished`. Nó com `scripture` (ex.: `"Gen 26:20"`) mostra o versículo citado (`DialogueManager.line_text`, até 3 versículos; a caixa comporta cerca de 4 linhas); o `text` do nó é o substituto sem a tradução. Personagens bíblicos não recebem falas inventadas. Voz opcional: `DialogueManager.voice_path(diálogo, nó)` procura `assets/audio/voice/<diálogo>__<nó>.ogg|.wav` e envia em `line.voice`; a `DialogueBox` toca se existir (hoje não há arquivos; KI-12).

### Mundo, jogador, NPCs, interação
- **Arquivos:** `scripts/world/game_map.gd`, `character_sprite.gd`, `objective_guide.gd` (`ObjectiveGuide`: seta do objetivo, criada por `game.gd` dentro do mapa; `targets()`, `is_showing()`, `find_target()`); `scripts/player/player.gd`; `scripts/npc/npc.gd`; `scripts/interaction/interactable.gd`, `interaction_detector.gd`. Cenas: `scenes/maps/canaan_village.tscn`, `scenes/environments/*.tscn`, `scenes/player/player.tscn`, `scenes/npcs/npc.tscn`.
- **Interfaces:** `Interactable` (`kind`, `dialogue_id`, `set_flag_on_interact`, `interact()`, sinal `interacted`); `InteractionDetector.focus_changed`; `Player.is_blocked()`, `face()`; `NPC.character_id`; `GameMap.region_id`, `get_region()`.
- **Cuidados:** `canaan_village.tscn` é **gerado** por `tools/art_gen/build_world.gd`; rodar `tools/build_all.ps1` sem `-PropsOnly` **sobrescreve** o mapa. Arte provisória vem de `tools/art_gen/generate_art.gd`.

### Regiões, viagens e experiências (v0.4)
- **Arquivos:** `scripts/world/world_manager.gd` (autoload `WorldManager`), `map_exit.gd` (`MapExit`), `map_area.gd` (`MapArea`), `game_map.gd` (instancia saídas, áreas, NPCs, examináveis e coletáveis do JSON; `find_object(type, id)`), `scripts/core/game.gd` (`_on_travel_requested`: escurece, troca o mapa, título da região, salvamento automático). Dados: `data/regions/<id>.json` (`canaan`, `caravan_road`, `dothan`), `data/world/experiences.json`. Mapas: `scenes/maps/caravan_road.tscn` e `dothan.tscn`, gerados por `tools/art_gen/build_regions.gd`.
- **Interfaces:** `WorldManager.region(id)`, `current_region_id()`, `exits()`, `is_exit_open()`, `route_exit(de, para)`, `travel(região, entrada)`, `is_picked()/mark_picked()`, `experience_state(id)`, `start_experience(id)`; sinais `travel_requested`, `experience_started`. `ObjectiveGuide.points()` aponta para a saída quando `QuestManager.objective_region(qid)` é outra região.
- **Cuidados:** regenerar os mapas novos só com `build_regions.gd` (não mexe em `canaan_village.tscn`). Cada alvo de missão precisa existir no JSON ou no `.tscn` da sua região (testes e `factory check`).

### Itens e colecionáveis (v0.4)
- **Arquivos:** `scripts/items/inventory.gd` (autoload `Inventory`), `collectibles.gd` (autoload `Collectibles`), `pickup.gd` (coletável no mapa); dados em `data/items/items.json` e `data/collectibles/*.json`; ícones gerados por `tools/art_gen/generate_art.gd`.
- **Interfaces:** `Inventory.add(id, qtd, origem)`, `remove()`, `count()`, `room_for(id, qtd)`, `discard()`, sinal `changed`; `Collectibles.find(id)`, `is_found()`, `found_in_set()`, `set_total()`, sinal `collectible_found`.
- **Cuidados:** itens de missão ficam no compartimento de essenciais e não são descartáveis; nada de moedas cunhadas, ferro comum, vidro ou papel na época dos patriarcas (ADR-023).

### Interface
- **Arquivos (`scripts/ui/`):**
  - `hud.gd` + `scenes/ui/hud.tscn`: contexto ("Você está em"), rastreador com categoria e "Siga para:", avisos, cartões, título da região (`show_region_banner`); sinais `journal_requested`, `inventory_requested`, `scripture_map_requested`; `has_pending_popups()`, `refresh_tracker()`.
  - `cinematic.gd`: prólogo e apresentações; `play_prologue()`, `play_presentation()`, `is_playing()`, sinal `finished(kind, id, skipped)`.
  - `journal.gd` + `journal_content.gd` (`JournalContent`): diário em 6 abas (Jornada por categoria, Escrituras, Personagens, Lugares, Linha do tempo, Descobertas); `open(tab, focus)`, `close()`, sinais `closed`, `presentation_requested`.
  - `inventory_screen.gd`: bolsa (tecla I), camada própria; `open()`, `close()`, sinal `closed`.
  - `scripture_map.gd` (`ScriptureMap`, camada 37): Mapa das Escrituras (tecla M) com épocas e experiências; sinais `closed`, `atlas_requested`.
  - `pause_menu.gd`: sinais `journal_requested`, `prologue_requested`.
  - `main_menu.gd`, `dialogue_box.gd`, `ui_style.gd`.
  - `debug_panel.gd`: só em build de debug.
- **Orquestração:** `scripts/core/game.gd` (liga HUD, diário, cinemática e pausa; `replay_prologue()`, `play_presentation(id)`).
- **Cuidados:** a Pixelify (títulos, botões) não tem ✓ ★ → ◆ ▸ ↑↓; use › • + · « » – — …. Textos de leitura usam Lora (`UiStyle.reading`, tema do `RichTextLabel`; ADR-018). O diário pausa a árvore; a cinemática usa camada 40, o diário 35.

### Save
- **Arquivos:** `scripts/save/save_manager.gd` (autoload), serialização em `game_state.gd`.
- **Interfaces:** `has_save()`, `save_data()`, `load_data()`, `migrate()`, `sanitize_game_data()`; `SAVE_VERSION = 3` (campos `inventory`, `world`, `collectibles`, `current_region`; ADR-025).
- **Cuidados:** gravação em `.tmp`, cópia do anterior em `.bak` e renomeação; qualquer campo novo exige migração e teste em `tests/test_runner.gd`.

### Ferramentas e build
- **Editor de missões:** `addons/quest_editor/` (plugin habilitado em `project.godot`; modelo `QuestEditorModel` testado, interface gráfica não testada com mouse).
- **Validação de conteúdo:** `tools/validate_content.gd`.
- **Texto bíblico:** `tools/import_scripture.gd` (arquivo VPL oficial do eBible.org → `data/bible/texts/<id>.json`; `read_vpl` estático, reaproveitado pela fábrica).
- **Fábrica de missões:** `tools/factory.gd` (linha de comando) + `tools/factory/factory_catalog.gd` (`FactoryCatalog`: catálogo, gates, referências, alvos lidos do `.tscn`, manifesto de áudio); `tools/audio/generate_voice.ps1`; dados de produção em `production/` (fora do exe); papéis em `.cursor/agents/`. Ver [mission_factory.md](../mission_factory.md).
- **Arte e mundo:** `tools/art_gen/` (`generate_art.gd`, `build_world.gd`, `preview.gd`).
- **Capturas:** `tools/screenshot/capture.tscn` (precisa de GPU) → `docs/images/`.
- **Build:** `tools/build_windows.ps1`, `criar_exe_atualizado.bat`, `tools/build_all.ps1`, `tools/install_export_templates.ps1`; autoteste do exe em `scripts/build/export_self_test.gd`.
- **Wiki:** `tools/check_wiki.ps1`.

### Testes
`tests/test_runner.gd` + `tests/test_runner.tscn` (suíte principal; chama `tests/world_tests.gd` para regiões, bolsa, escolhas, missões entre regiões e telas, e `tests/audio_tests.gd` para áudio; falha se esses scripts não compilarem), `tests/flow_smoke.gd` (fluxo pelos menus). Capturas da v0.4: `tools/screenshot/capture_v04.tscn`. Ver [TESTING.md](TESTING.md).
