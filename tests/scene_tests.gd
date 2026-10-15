extends RefCounted
## Testes da cena dirigida (SceneDatabase, SceneDirector), da luz por estado,
## das experiências com etapas/entry_if/revisita e das saídas com passagem.
## Chamado por tests/test_runner.gd, que fornece check() e as esperas.
## Cenas de teste em tests/data/scenes (fora de data/ e do exe).

const GAME_SCENE := "res://scenes/core/game.tscn"
const TEST_SCENES := "res://tests/data/scenes"

var r: Node


func _init(runner: Node) -> void:
	r = runner


func check(cond: bool, label: String) -> void:
	r.check(cond, label)


func wait(frames: int) -> void:
	await r._wait_physics(frames)


func _player() -> Player:
	return r.get_tree().get_first_node_in_group("player") as Player


func _start_game_in(region_id: String, entry_id: String) -> Node:
	WorldManager.travel(region_id, entry_id)
	var game: Node = load(GAME_SCENE).instantiate()
	r.add_child(game)
	await wait(5)
	await r._close_cards(game.get_node("HUD"))
	for n in game.find_children("*", "NPC", true, false):
		n.process_mode = Node.PROCESS_MODE_DISABLED
	return game


func _wait_scene(game: Node, max_frames := 600) -> void:
	var guard := 0
	while game.scene_director.is_playing() and guard < max_frames:
		await wait(2)
		guard += 2


func _wait_travel(game: Node, max_frames := 240) -> void:
	var guard := 0
	while guard < 60 and not game.is_traveling():
		await wait(2)
		guard += 1
	guard = 0
	while game.is_traveling() and guard < max_frames:
		await wait(2)
		guard += 1
	await wait(4)


func _close(game: Node) -> void:
	game.queue_free()
	await wait(3)


# --- Dados e validação -------------------------------------------------------------

func _base_scene() -> Dictionary:
	return {"id": "x", "region": "dothan", "title": "x", "classification": "plausible_fiction", "references": ["Gen 26:20"],
		"verification": {"status": "pending_review", "reviewer": ""}, "steps": [{"type": "wait", "time": 1}]}


func test_data() -> void:
	var prod := SceneDatabase.new()
	prod.load_dir()
	check(prod.errors.is_empty(), "cenas de data/scenes sem erros (%d) %s" % [prod.order.size(), prod.errors])
	var db := SceneDatabase.new()
	db.load_dir(TEST_SCENES)
	check(db.errors.is_empty() and db.has_scene("test_scene_full") and db.has_scene("test_scene_long"), "cenas de teste carregam e validam %s" % [db.errors])
	var catalog := Bible.catalog
	var sounds := SceneDatabase.manifest_sounds()
	for sid in db.order:
		var links := SceneDatabase.validate_links(db.get_scene(sid), catalog, GameData.characters, GameData.regions, sounds)
		check(links.is_empty(), "cena %s: vínculos válidos %s" % [sid, links])
	var used := {}
	for st in db.get_scene("test_scene_full").steps:
		used[st.type] = true
		if st.type == "effect":
			used["fx:" + st.effect] = true
	check(SceneDatabase.STEP_TYPES.all(func(t): return used.has(t)), "cena de teste cobre todos os tipos de passo")
	check(SceneDatabase.EFFECTS.all(func(e): return used.has("fx:" + e)), "cena de teste cobre todos os efeitos")

	var ok := _base_scene()
	check(SceneDatabase.validate(ok).is_empty(), "cena mínima válida %s" % [SceneDatabase.validate(ok)])
	var bad := _base_scene()
	bad["on_end"] = {"give": [{"item": "rope"}]}
	check(not SceneDatabase.validate(bad).is_empty(), "validador recusa cena que dá item")
	bad = _base_scene()
	bad.steps = [{"type": "caption", "scripture": "Gen 26:20", "text": "x", "kind": "narration"}]
	check(not SceneDatabase.validate(bad).is_empty(), "validador recusa legenda com texto e referência juntos")
	bad.steps = [{"type": "caption", "text": "x"}]
	check(not SceneDatabase.validate(bad).is_empty(), "validador exige kind na legenda de texto")
	bad.steps = [{"type": "move", "actor": "ninguem", "path": [[0, 0]]}]
	check(not SceneDatabase.validate(bad).is_empty(), "validador recusa mover figurante não criado")
	bad.steps = [{"type": "effect", "effect": "raio", "at": [0, 0]}]
	check(not SceneDatabase.validate(bad).is_empty(), "validador recusa efeito desconhecido")
	bad.steps = [{"type": "effect", "effect": "water_walls", "at": [0, 0]}]
	check(not SceneDatabase.validate(bad).is_empty(), "validador exige params.to em water_walls")
	bad.steps = [{"type": "voar"}]
	check(not SceneDatabase.validate(bad).is_empty(), "validador recusa tipo de passo desconhecido")
	bad.steps = [{"type": "caption", "text": "a", "kind": "context"}, {"type": "sfx", "id": "ui_click"}, {"type": "caption", "scripture": "Gen 26:20", "wait": true}]
	check(not SceneDatabase.validate(bad).is_empty(), "validador recusa legenda substituída antes de ser lida")
	bad.steps = [{"type": "caption", "text": "a", "kind": "context"}, {"type": "wait", "time": 1}, {"type": "caption", "scripture": "Gen 26:20"}]
	check(SceneDatabase.validate(bad).is_empty(), "legenda sem wait seguida de espera é aceita %s" % [SceneDatabase.validate(bad)])
	bad = _base_scene()
	bad.erase("verification")
	check(not SceneDatabase.validate(bad).is_empty(), "validador exige o bloco verification")
	bad = _base_scene()
	bad.steps = [{"type": "actor", "id": "z", "sprite": "personagem_inexistente", "at": [0, 0]}, {"type": "sfx", "id": "som_inexistente"},
		{"type": "caption", "scripture": "Gen 50:26"}]
	bad.region = "lugar_nenhum"
	var links := SceneDatabase.validate_links(bad, catalog, GameData.characters, GameData.regions, sounds)
	check(links.size() == 4, "vínculos: região, sprite, som e versículo sem texto são acusados (%d) %s" % [links.size(), links])

	# Diálogo, missão e fábrica reconhecem cenas.
	check(DialogueDatabase.valid_action({"scene": "x"}) and DialogueDatabase.valid_action({"presentation": "x"}) and not DialogueDatabase.valid_action({"cena": "x"}), "diálogo aceita action {scene: id}")
	var q: Dictionary = QuestManager.db.get_quest("joseph_dothan_road").duplicate(true)
	q.id = "test_observe"
	q.objectives[0]["type"] = "observe_scene"
	q.objectives[0].complete_on = {"event": "scene_finished", "id": "test_scene_full"}
	q.objectives[0].targets = [{"type": "scene", "id": "test_scene_full"}]
	check(QuestDatabase.validate(q).is_empty(), "objetivo observe_scene com scene_finished e alvo scene é válido %s" % [QuestDatabase.validate(q)])
	var qlinks := QuestManager.db.validate_links(q, catalog, DialogueManager.db.dialogues, GameData.characters, GameData.regions, db.scenes)
	check(qlinks.is_empty(), "vínculo com cena de teste existente aceito %s" % [qlinks])
	qlinks = QuestManager.db.validate_links(q, catalog, DialogueManager.db.dialogues, GameData.characters, GameData.regions, {})
	check(qlinks.size() == 2, "vínculo com cena inexistente acusado (alvo e gatilho) %s" % [qlinks])
	var fc := FactoryCatalog.new()
	check(fc.quest_world_errors(q).size() == 2, "fábrica: alvo e gatilho de cena conferidos contra data/scenes")
	check(fc.world_content_errors().is_empty(), "fábrica: cenas, luz, passagens e experiências sem erros %s" % [fc.world_content_errors()])
	check(String(FactoryCatalog.EVENT_SUPPORT.observe_scene.level) == "data_only", "fábrica: observe_scene suportado só com dados")


func test_world_schema() -> void:
	for rid in GameData.regions:
		var errs := WorldSchema.validate_region(GameData.regions[rid])
		check(errs.is_empty(), "região %s: luz e passagens válidas %s" % [rid, errs])
	for xid in WorldManager.experience_order:
		var errs := WorldSchema.validate_experience(WorldManager.experience(xid), GameData.regions)
		check(errs.is_empty(), "experiência %s: destino válido %s" % [xid, errs])
	check(not WorldSchema.validate_lighting("t", [{"if": {"flag": "a"}, "tint": "azul"}]).is_empty(), "lighting com cor inválida é recusado")
	check(not WorldSchema.validate_lighting("t", [{"if": {"bandeira": "a"}, "tint": "#102030"}]).is_empty(), "lighting com condição inválida é recusado")
	check(WorldSchema.validate_lighting("t", [{"if": {"flag": "a"}, "tint": "#102030"}, {"tint": "#ffeedd"}]).is_empty(), "lighting com regra padrão é válido")
	check(not WorldSchema.validate_experience({"id": "b", "travel": {"region": "lugar_nenhum"}}, GameData.regions).is_empty(), "travel para região inexistente é recusado")
	check(not WorldSchema.validate_experience({"id": "b", "travel": {"region": "dothan", "entry_if": [{"if": {"flag": "a"}, "entry": "porta"}]}}, GameData.regions).is_empty(), "entry_if com entrada inexistente é recusado")
	check(not WorldSchema.validate_experience({"id": "b", "stages": [{"id": "s", "travel": {"region": "dothan"}}, {"id": "s", "travel": {"region": "dothan"}}]}, GameData.regions).is_empty(), "etapas com id repetido são recusadas")
	check(not WorldSchema.validate_region({"id": "b", "exits": [{"id": "e", "passage": {"title": ""}}]}).is_empty(), "passagem de saída sem título/linhas é recusada")


# --- Experiências: travel, entry_if, stages, regions -------------------------------

func test_experiences() -> void:
	GameState.new_game()
	check(WorldManager.experience_destination("isaac_wells") == {"region": "canaan_village", "entry": "default"}, "Os poços de Isaque têm destino na aldeia (voltar a Canaã)")
	check(WorldManager.experience_destination("joseph_dothan") == {"region": "canaan_village", "entry": "default"}, "José em Dotã tem destino na aldeia")
	check(WorldManager.experience_regions("joseph_dothan").size() == 3, "José em Dotã abrange aldeia, Caminho e Dotã")
	WorldManager.experiences["test_planned"] = {"id": "test_planned", "era": "judges", "title": "Teste em planejamento", "status": "planned", "references": ["Ruth 2:1-3"]}
	check(WorldManager.experience_destination("test_planned").is_empty() and WorldManager.start_experience("test_planned") != "", "experiência em planejamento continua sem destino e não jogável")
	WorldManager.experiences.erase("test_planned")
	var tr := {"region": "dothan", "entry": "default", "entry_if": [{"if": {"flag": "t_alt"}, "entry": "from_caravan_road"}]}
	check(WorldManager.resolve_travel(tr).entry == "default", "entry_if: sem condição, vale a entrada padrão")
	GameState.set_flag("t_alt", true)
	check(WorldManager.resolve_travel(tr).entry == "from_caravan_road", "entry_if: condição verdadeira escolhe outra entrada")
	GameState.new_game()

	var passage := {"title": "OUTRO MOMENTO DA HISTÓRIA", "lines": ["Primeira passagem."]}
	var stage_passage := {"title": "OUTRO MOMENTO DA HISTÓRIA", "lines": ["Passagem da segunda etapa."]}
	var x := {"id": "test_stages", "era": "patriarchs", "title": "Teste de etapas", "status": "available", "references": ["Gen 26:20"],
		"passage": passage,
		"stages": [
			{"id": "one", "travel": {"region": "caravan_road", "entry": "from_canaan"}},
			{"id": "two", "if": {"flag": "t_stage2"}, "travel": tr, "passage": stage_passage}]}
	check(WorldSchema.validate_experience(x, GameData.regions).is_empty(), "experiência de teste com etapas é válida %s" % [WorldSchema.validate_experience(x, GameData.regions)])
	WorldManager.experiences["test_stages"] = x
	check(WorldManager.experience_stage("test_stages").id == "one", "etapa inicial sem condição")
	check(WorldManager.pending_passage("test_stages") == passage, "primeira vez: cartão da experiência")
	check(WorldManager.start_experience("test_stages") == "" and GameState.current_region == "caravan_road", "iniciar leva à região da etapa atual")
	check(GameState.get_flag(WorldManager.stage_flag("test_stages", "one")) == true, "etapa visitada registrada em flag")
	check(WorldManager.pending_passage("test_stages").is_empty(), "etapa sem passage não mostra cartão")
	GameState.set_flag("t_stage2", true)
	check(WorldManager.experience_stage("test_stages").id == "two", "condição verdadeira avança para a etapa seguinte")
	check(WorldManager.pending_passage("test_stages") == stage_passage, "nova etapa: cartão OUTRO MOMENTO DA HISTÓRIA")
	check(WorldManager.start_experience("test_stages") == "" and GameState.current_region == "dothan" and GameState.entry_id == "default", "continuar leva à região da nova etapa")
	check(WorldManager.pending_passage("test_stages").is_empty(), "cartão da etapa aparece uma vez só")
	check(WorldManager.start_experience("test_stages") == "" and GameState.current_region == "dothan", "já na região da etapa: não viaja de novo")
	GameState.set_flag("t_alt", true)
	GameState.current_region = "caravan_road"
	WorldManager.start_experience("test_stages")
	check(GameState.entry_id == "from_caravan_road", "etapa usa entry_if conforme o progresso")
	WorldManager.experiences.erase("test_stages")

	# Experiência sem etapas: dentro das suas regiões, "Continuar" não viaja.
	GameState.new_game()
	GameState.current_region = "dothan"
	for e in [["prologue_finished", "new_game"], ["custom", "wells_adina_water"], ["dialogue_finished", "well_examine"],
			["custom", "wells_ari_well"], ["custom", "wells_jar_returned"], ["item_collected", "clay_jar"],
			["custom", "wells_trough_full"], ["custom", "wells_adina_thanks"], ["presentation_finished", "gen_026_wells"]]:
		QuestManager.record_event(e[0], e[1])
	check(WorldManager.experience_state("joseph_dothan") == "available", "José em Dotã disponível depois dos poços")
	check(WorldManager.start_experience("joseph_dothan") == "" and GameState.current_region == "dothan", "dentro das regiões da experiência, iniciar não tira o jogador de Dotã")
	check(WorldManager.experience_state("isaac_wells") == "completed" and WorldManager.start_experience("isaac_wells") == "" and GameState.current_region == "canaan_village", "revisitar Os poços de Isaque leva de volta à aldeia")
	GameState.new_game()


# --- Cena dirigida no jogo -----------------------------------------------------------

func test_play_and_skip() -> void:
	GameState.new_game()
	GameState.set_flag("prologue_seen", true)
	var game: Node = await _start_game_in("dothan", "default")
	var director: SceneDirector = game.scene_director
	director.database.load_dir(TEST_SCENES)
	var hud: Node = game.get_node("HUD")
	var finished: Array = []
	director.scene_finished.connect(func(id, skipped): finished.append([id, skipped]))
	var bag_before := GameState.inventory.duplicate()
	check(not game.play_scene("cena_inexistente"), "cena inexistente não toca")

	DialogueManager.action_requested.emit({"scene": "test_scene_full"})
	check(director.is_playing() and director.scene_id == "test_scene_full", "ação de diálogo {scene: id} inicia a cena")
	check(GameState.is_ui_blocked() and _player().is_blocked(), "cena bloqueia a UI e o jogador")
	check(not hud.visible, "HUD escondido durante a cena")
	check(not game.play_scene("test_scene_long"), "outra cena não começa por cima")
	await wait(4)
	r._press("journal")
	await wait(2)
	check(not game.journal.is_open() and not game.get_node("PauseMenu").visible, "diário e pausa (salvar) indisponíveis durante a cena")
	var world: Node = game.map.get_node("World")
	await wait(30)
	check(world.find_children("Actor_*", "SceneActor", false, false).size() == 3, "figurantes criados no mapa (personagem e silhuetas)")
	check(game.map.get_node_or_null("SceneFx") != null and game.map.get_node_or_null("SceneGlow") != null, "efeitos criados (mundo e camada de luz)")
	check(game.map.lighting != null and game.map.lighting_locked, "passo tint controla a luz do mapa")
	await _wait_scene(game)
	await wait(4)
	check(not director.is_playing() and finished == [["test_scene_full", false]], "cena toca até o fim e emite o sinal %s" % [finished])
	check(QuestManager.has_event("scene_finished", "test_scene_full"), "evento scene_finished registrado")
	check(GameState.get_flag("test_scene_flag") == true, "on_end aplica set_flags")
	check(GameState.history.any(func(h): return h.kind == "scene" and h.id == "test_scene_full"), "cena registrada no histórico")
	check(not GameState.is_ui_blocked() and not _player().is_blocked() and hud.visible, "controle e HUD voltam ao jogador")
	check(_player().global_position.distance_to(Vector2(300, 304)) < 1.0, "jogador no estado final (player_to)")
	check(_player().camera.is_current(), "câmera volta ao jogador")
	check(world.find_children("Actor_*", "SceneActor", false, false).is_empty() and game.map.get_node_or_null("SceneFx") == null, "figurantes e efeitos removidos no fim")
	check(GameState.inventory == bag_before, "cena não dá item")
	await wait(80)
	check(not game.map.lighting_locked and game.map.lighting.color.is_equal_approx(Color.WHITE), "luz volta à regra da região (sem lighting = sem tinta)")
	check(not game.play_scene("test_scene_full"), "cena concluída não repete")

	# Esc pula para o estado final.
	check(game.play_scene("test_scene_long"), "cena longa começa")
	await wait(10)
	check(director.is_playing(), "cena longa em andamento")
	r._press("pause")
	await wait(3)
	check(not director.is_playing() and finished.back() == ["test_scene_long", true], "Esc pula a cena")
	check(not game.get_node("PauseMenu").visible, "Esc da cena não abre a pausa")
	check(GameState.get_flag("test_long_flag") == true and QuestManager.has_event("scene_finished", "test_scene_long"), "pular aplica on_end e registra scene_finished")
	check(_player().global_position.distance_to(Vector2(320, 304)) < 1.0, "pular leva o jogador à posição final")
	check(game.map.lighting.color.is_equal_approx(Color.WHITE), "pular desfaz a tinta da cena na hora")
	check(not GameState.is_ui_blocked(), "pular devolve o controle")

	# Salvar, carregar: a cena concluída não volta a tocar.
	check(GameState.save_game() == OK, "salvar depois das cenas")
	await _close(game)
	GameState.new_game()
	check(GameState.load_game() == "", "carregar o save")
	var game2: Node = load(GAME_SCENE).instantiate()
	r.add_child(game2)
	await wait(5)
	game2.scene_director.database.load_dir(TEST_SCENES)
	check(not game2.scene_director.is_playing() and not GameState.is_ui_blocked(), "carregar não reinicia cena")
	check(QuestManager.has_event("scene_finished", "test_scene_full") and not game2.play_scene("test_scene_full"), "depois de carregar, cena concluída não repete")
	await _close(game2)
	GameState.new_game()


# --- Luz por estado -------------------------------------------------------------------

func test_lighting() -> void:
	GameState.new_game()
	GameState.set_flag("prologue_seen", true)
	var reg: Dictionary = GameData.regions["dothan"]
	reg["lighting"] = [{"if": {"flag": "test_night"}, "tint": "#203040"}, {"if": {"flag": "test_dusk"}, "tint": "#e9b98e"}]
	var game: Node = await _start_game_in("dothan", "default")
	var map: GameMap = game.map
	check(map.lighting == null, "sem regra valendo, nenhuma tinta")
	GameState.set_flag("test_dusk", true)
	await wait(70)
	check(map.lighting != null and map.lighting.color.is_equal_approx(Color("#e9b98e")), "flag muda a luz do mapa")
	GameState.set_flag("test_night", true)
	await wait(70)
	check(map.lighting.color.is_equal_approx(Color("#203040")), "primeira regra que vale tem prioridade")
	var db := SceneDatabase.new()
	db.load_dir(TEST_SCENES)
	var sc: Dictionary = db.get_scene("test_scene_long").duplicate(true)
	sc.id = "test_light_scene"
	check(game.scene_director.play_data(sc, map), "cena toca sobre a luz da região")
	await wait(30)
	check(not map.lighting.color.is_equal_approx(Color("#203040")), "tint da cena substitui a luz durante a cena")
	game.scene_director.skip()
	check(map.lighting.color.is_equal_approx(Color("#203040")), "ao terminar, a luz volta à regra da região")
	GameState.set_flag("test_night", false)
	GameState.set_flag("test_dusk", false)
	await wait(70)
	check(map.lighting.color.is_equal_approx(Color.WHITE), "sem regra valendo, a luz volta ao normal")
	await _close(game)
	GameState.new_game()
	GameData.reload()
	check(GameData.errors.is_empty() and not GameData.regions.dothan.has("lighting"), "dados de região restaurados")
	# Luz reavaliada ao entrar: o mapa já nasce com a tinta da regra.
	GameData.regions["dothan"]["lighting"] = [{"if": {"flag": "test_night"}, "tint": "#203040"}]
	GameState.new_game()
	GameState.set_flag("prologue_seen", true)
	GameState.set_flag("test_night", true)
	var game2: Node = await _start_game_in("dothan", "default")
	check(game2.map.lighting != null and game2.map.lighting.color.is_equal_approx(Color("#203040")), "luz avaliada ao entrar na região")
	await _close(game2)
	GameData.reload()
	GameState.new_game()


# --- Mapa das Escrituras e saídas com passagem --------------------------------------

func test_scripture_map_and_passage() -> void:
	GameState.new_game()
	GameState.set_flag("prologue_seen", true)
	for e in [["prologue_finished", "new_game"], ["custom", "wells_adina_water"], ["dialogue_finished", "well_examine"],
			["custom", "wells_ari_well"], ["custom", "wells_jar_returned"], ["item_collected", "clay_jar"],
			["custom", "wells_trough_full"], ["custom", "wells_adina_thanks"], ["presentation_finished", "gen_026_wells"]]:
		QuestManager.record_event(e[0], e[1])
	var game: Node = await _start_game_in("dothan", "default")
	var sm: ScriptureMap = game.scripture_map
	sm.open()
	await wait(2)
	WorldManager.experiences["test_planned"] = {"id": "test_planned", "era": "judges", "title": "Teste em planejamento", "status": "planned", "references": ["Ruth 2:1-3"]}
	sm.select("test_planned")
	check(not sm._action.visible, "experiência em planejamento: sem botão")
	WorldManager.experiences.erase("test_planned")
	sm.select("ruth_bethlehem")
	check(not sm._action.visible, "experiência bloqueada (Rute antes da travessia do mar): sem botão")
	sm.select("isaac_wells")
	check(sm._action.visible and sm._action.text == "Revisitar", "experiência explorada mostra Revisitar")
	sm.select("joseph_dothan")
	check(sm._action.visible and sm._action.text == "Iniciar esta experiência", "experiência disponível mostra Iniciar")
	sm.select("isaac_wells")
	sm._on_action()
	await _wait_travel(game)
	check(not sm.is_open() and game.map.region_id == "canaan_village", "Revisitar viaja de Dotã para a aldeia")
	check(not GameState.is_ui_blocked(), "controle volta depois da viagem")
	await _close(game)

	# Saída com passage: cartão antes de viajar.
	GameState.new_game()
	GameState.set_flag("prologue_seen", true)
	GameData.regions["dothan"]["exits"][0]["passage"] = {"title": "OUTRO MOMENTO DA HISTÓRIA", "lines": ["Teste de passagem por saída."]}
	var game2: Node = await _start_game_in("dothan", "default")
	await wait(40)
	_player().global_position = Vector2(30, 304)
	await wait(2)
	Input.action_press("move_left")
	await wait(30)
	Input.action_release("move_left")
	await wait(2)
	var sm2: ScriptureMap = game2.scripture_map
	check(sm2.is_open() and sm2._passage_box.visible and not game2.is_traveling(), "saída com passage abre o cartão antes de viajar")
	check(game2.map.region_id == "dothan", "sem confirmar, continua em Dotã")
	r._press("interact")
	await _wait_travel(game2)
	check(not sm2.is_open() and game2.map.region_id == "caravan_road", "confirmar o cartão viaja pela saída")
	await _close(game2)
	GameData.reload()
	GameState.new_game()
