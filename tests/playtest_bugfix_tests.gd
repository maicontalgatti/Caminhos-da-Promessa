extends RefCounted
## Regressões dos bugs achados em playtest (branch fix/playtest-bugs-testers):
## roda de Ezer, saída de tendas (pilha de retorno), cena da caravana, ovelha
## sobre a gruta, foice visível, Tamir depois da casa, missão do HUD e nome de Nava.
## Chamado por tests/test_runner.gd, que fornece check() e as esperas.

const GAME_SCENE := "res://scenes/core/game.tscn"
const WELLS_EVENTS := [["prologue_finished", "new_game"], ["custom", "wells_adina_water"], ["dialogue_finished", "well_examine"],
	["custom", "wells_ari_well"], ["custom", "wells_jar_returned"], ["item_collected", "clay_jar"],
	["custom", "wells_trough_full"], ["custom", "wells_adina_thanks"], ["presentation_finished", "gen_026_wells"]]

var r: Node


func _init(runner: Node) -> void:
	r = runner


func check(cond: bool, label: String) -> void:
	r.check(cond, label)


func wait(frames: int) -> void:
	await r._wait_physics(frames)


func _start_game_in(region_id: String, entry_id: String) -> Node:
	WorldManager.travel(region_id, entry_id)
	var game: Node = load(GAME_SCENE).instantiate()
	r.add_child(game)
	await wait(5)
	await r._close_cards(game.get_node("HUD"))
	return game


# --- 1) Roda de Ezer: observar vem primeiro e experimentar exige conhecer Ezer ---------

func test_ezer_wheel_not_automatic() -> void:
	GameState.new_game()
	var d: Dictionary = DialogueManager.db.get_dialogue("ezer_house_wheel")
	var choices: Array = d.nodes.n2.choices
	check(String(choices[0].text) == "Só observar." and not choices[0].has("action"), "roda de Ezer: a primeira escolha é só observar (sem ação de ofício)")
	check(choices.size() == 2 and choices[1].get("action", {}).has("craft"), "roda de Ezer: experimentar é a segunda escolha")
	check(DialogueManager.start("ezer_house_wheel"), "diálogo da roda começa")
	DialogueManager.advance()
	check(DialogueManager.current_choices().size() == 1 and String(DialogueManager.current_choices()[0].text) == "Só observar.", "sem conhecer Ezer, só dá para observar")
	DialogueManager.choose(0)
	check(not DialogueManager.is_active(), "observar encerra o diálogo sem abrir a roda")
	GameState.set_flag("met_ezer", true)
	DialogueManager.start("ezer_house_wheel")
	DialogueManager.advance()
	check(DialogueManager.current_choices().size() == 2, "depois de falar com Ezer, experimentar a roda aparece")
	DialogueManager.choose(0)
	GameState.new_game()


# --- 2) Tendas: sem fala de Canaã fora de Canaã; "@return" volta de onde veio ---------

func test_tent_exit_and_return_stack() -> void:
	for map_path in ["res://scenes/maps/caravan_road.tscn", "res://scenes/maps/dothan.tscn"]:
		var map: Node = (load(map_path) as PackedScene).instantiate()
		var bad := 0
		for it in map.find_children("*", "Interactable", true, false):
			if String(it.dialogue_id) == "tent_examine":
				bad += 1
		check(bad == 0, "%s: nenhuma tenda leva à tenda de Canaã (tent_examine)" % map_path.get_file())
		map.free()
	check(ResourceLoader.exists("res://scenes/environments/tent_plain.tscn"), "tent_plain existe (tenda decorativa)")

	GameState.new_game()
	check(WorldManager.is_interior("canaan_tent") and WorldManager.is_interior("canaan_ezer_house"), "tenda e casa de Ezer são interiores")
	check(not WorldManager.is_interior("canaan_village") and not WorldManager.is_interior("bethlehem_night") and not WorldManager.is_interior("egypt_house"), "aldeia, Belém à noite e casa egípcia não são interiores")
	var flap := WorldManager.find_exit("canaan_tent", "flap_out")
	check(String(flap.get("to", "")) == "@return" and String(flap.get("fallback_to", "")) == "canaan_village", "saída da tenda usa @return com fallback para a aldeia")
	check(String(WorldManager.exit_target(flap)) == "canaan_village", "exit_target de @return vale o fallback")

	# Entrou na tenda vindo do Caminho das Caravanas: sair volta ao Caminho.
	check(WorldManager.travel("caravan_road", "default") == "", "viaja ao Caminho")
	check(WorldManager.travel("canaan_tent", "from_village") == "" and WorldManager.return_stack.size() == 1, "entrar no interior empilha a região anterior")
	var back := WorldManager.resolve_exit(flap)
	check(String(back.region) == "caravan_road" and not WorldManager.entry_point("caravan_road", String(back.entry)).is_empty(), "@return resolve para o Caminho com entrada válida (%s)" % [back])
	check(WorldManager.travel("@return", "from_tent") == "" and WorldManager.current_region_id() == "caravan_road" and WorldManager.return_stack.is_empty(), "viajar para @return volta ao Caminho e esvazia a pilha")

	# Vindo da aldeia: usa a entrada da saída (from_tent / from_ezer_house).
	WorldManager.travel("canaan_village", "default")
	WorldManager.travel("canaan_tent", "from_village")
	var back2 := WorldManager.resolve_exit(flap)
	check(String(back2.region) == "canaan_village" and String(back2.entry) == "from_tent", "da aldeia, @return usa a entrada from_tent")
	WorldManager.travel("canaan_village", "from_tent")
	WorldManager.travel("canaan_ezer_house", "from_village")
	var door := WorldManager.find_exit("canaan_ezer_house", "door_out")
	var back3 := WorldManager.resolve_exit(door)
	check(String(back3.region) == "canaan_village" and String(back3.entry) == "from_ezer_house", "da casa de Ezer, @return usa from_ezer_house")
	# Interior para interior não empilha de novo.
	WorldManager.travel("canaan_tent", "from_village")
	check(WorldManager.return_stack.size() == 1, "interior para interior não duplica a pilha")
	# Pilha vazia (jogo carregado dentro do interior): vale o fallback.
	WorldManager.return_stack.clear()
	var fb := WorldManager.resolve_exit(door)
	check(String(fb.region) == "canaan_village" and String(fb.entry) == "from_ezer_house", "sem pilha, @return usa o fallback_to da saída")
	GameState.new_game()
	check(WorldManager.return_stack.is_empty(), "novo jogo esvazia a pilha de retorno")


# --- 3) Cena da caravana e espera da cena dirigida -----------------------------------

func test_caravan_scene_waits() -> void:
	var db := SceneDatabase.new()
	db.load_dir()
	var sc: Dictionary = db.get_scene("joseph_caravan_departs")
	var steps: Array = sc.get("steps", [])
	var first_wait := -1
	var first_scripture := -1
	for i in steps.size():
		var st: Dictionary = steps[i]
		if first_wait < 0 and String(st.get("type", "")) == "wait" and float(st.get("time", 0.0)) >= 10.0:
			first_wait = i
		if first_scripture < 0 and String(st.get("type", "")) == "caption" and String(st.get("scripture", "")) != "":
			first_scripture = i
	check(first_wait >= 0 and first_scripture > first_wait, "caravana: espera de 10 s ou mais antes das legendas bíblicas (passo %d < %d)" % [first_wait, first_scripture])
	check(SceneDirector.MAX_WAIT > 0.0 and SceneDirector.MAX_WAIT <= 120.0, "espera de cena tem teto")


func test_scene_sleep_advances_while_paused() -> void:
	GameState.new_game()
	GameState.set_flag("prologue_seen", true)
	var game: Node = await _start_game_in("dothan", "default")
	var director: SceneDirector = game.scene_director
	check(director.process_mode == Node.PROCESS_MODE_ALWAYS, "SceneDirector processa mesmo com a árvore pausada")
	# Sem esperar o _sleep direto: se travasse com a árvore pausada, o teste também travaria.
	var done := [false, false]
	var run := func():
		await director._sleep(0.3, director._token, false)
		done[0] = true
	r.get_tree().paused = true
	run.call()
	var guard := 0
	while not done[0] and guard < 240:
		await wait(2)
		guard += 2
	r.get_tree().paused = false
	check(done[0], "_sleep termina mesmo com a árvore pausada (%d quadros)" % guard)
	# Legenda ainda respeita o avanço manual (E), inclusive pausada.
	var run_caption := func():
		await director._sleep(30.0, director._token, true)
		done[1] = true
	r.get_tree().paused = true
	run_caption.call()
	await wait(10)
	check(not done[1], "legenda espera enquanto ninguém avança")
	director._advance = true
	guard = 0
	while not done[1] and guard < 60:
		await wait(2)
		guard += 2
	r.get_tree().paused = false
	check(done[1], "_sleep de legenda termina ao avançar")
	game.queue_free()
	await wait(3)
	GameState.new_game()


# --- 4) Quarto animal do rebanho longe da gruta; texto fala em animais ---------------

func test_fourth_stray_away_from_cave() -> void:
	var night: Dictionary = GameData.regions["bethlehem_night"]
	var sheep := Vector2.ZERO
	var spark := Vector2.ZERO
	for n in night.get("npcs", []):
		if n.id == "bn_stray_sheep_4":
			sheep = Vector2(float(n.x), float(n.y))
	for e in night.get("examinables", []):
		if e.id == "bn_stray_4":
			spark = Vector2(float(e.x), float(e.y))
	var cave := Vector2(904, 664)
	check(sheep != Vector2.ZERO and sheep.distance_to(cave) > 60.0, "quarto animal fora da boca da gruta (%s)" % sheep)
	check(spark != Vector2.ZERO and spark.distance_to(cave) > 60.0 and spark.distance_to(sheep) < 24.0, "brilho do quarto animal acompanha o animal")
	var obj: Dictionary = {}
	for o in QuestManager.db.get_quest("shepherds_night").objectives:
		if o.id == "gather_flock":
			obj = o
	check(String(obj.get("text", "")).contains("4 animais") and not String(obj.get("text", "")).contains("4 ovelhas"), "objetivo fala em 4 animais (uma é cabra)")


# --- 6) Foice: examinável com objeto visível ------------------------------------------

func test_sickle_visible_prop() -> void:
	var fields: Dictionary = GameData.regions["bethlehem_fields"]
	var found := false
	for e in fields.get("examinables", []):
		if e.id == "bf_sickle":
			found = true
			var prop := String(e.get("prop", ""))
			check(prop != "" and ResourceLoader.exists("res://scenes/environments/%s.tscn" % prop), "bf_sickle tem prop visível (%s)" % prop)
	check(found, "bf_sickle existe")
	var packed: PackedScene = load("res://scenes/environments/sickle.tscn")
	var node: Node = packed.instantiate()
	var spr := node.get_node_or_null("Sprite") as Sprite2D
	check(spr != null and spr.texture != null, "sickle.tscn tem sprite")
	node.free()


# --- 7) Fim de cena atualiza o mundo: Tamir acordado aparece ---------------------------

func test_scene_finish_refreshes_world() -> void:
	GameState.new_game()
	GameState.set_flag("prologue_seen", true)
	GameState.set_flag("bn_night", true)
	var game: Node = await _start_game_in("bethlehem_night", "default")
	await wait(3)
	var map: GameMap = game.map
	check(map.find_object("npc", "bn_tamir") == null and map.find_object("npc", "bn_tamir_asleep") != null, "antes da casa: só Tamir dormindo")
	check(game.play_scene("shepherds_at_the_house"), "cena da casa do menino começa")
	await wait(5)
	game.scene_director.skip()
	check(map.find_object("npc", "bn_tamir") != null, "logo ao fim da cena, Tamir acordado já existe (refresh_world)")
	check(map.find_object("npc", "bn_tamir_asleep") == null, "Tamir dormindo some ao fim da cena")
	var guide := map.get_node_or_null("ObjectiveGuide") as ObjectiveGuide
	check(guide != null and (guide.targets().size() > 0 or guide.points().size() > 0 or QuestManager.primary_quest() != "shepherds_night"),
		"o guia de objetivo enxerga o próximo alvo depois da cena")
	game.queue_free()
	await wait(3)
	GameState.new_game()


# --- 8) HUD: missão principal da região vence secundária esquecida ---------------------

func test_primary_quest_prefers_local_main() -> void:
	GameState.new_game()
	QuestManager.start_quest("shepherds_night", true)
	QuestManager.start_quest("sea_camp_water", true)
	check(QuestManager.status("shepherds_night") == "active" and QuestManager.status("sea_camp_water") == "active", "principal de Belém e secundária do mar ativas")
	QuestManager.set_tracked("sea_camp_water")
	check(GameState.tracked_quest == "sea_camp_water", "secundária do mar acompanhada")
	QuestManager.current_region_id = "sea_camp"
	check(QuestManager.primary_quest() == "sea_camp_water", "no acampamento, a acompanhada local continua valendo")
	QuestManager.current_region_id = "bethlehem_night"
	check(QuestManager.primary_quest() == "shepherds_night", "em Belém, a principal local vence a secundária esquecida do mar")
	QuestManager.current_region_id = ""
	GameState.new_game()
	# Iniciar uma experiência limpa a missão acompanhada.
	for e in WELLS_EVENTS:
		QuestManager.record_event(e[0], e[1])
	QuestManager.start_quest("sea_camp_water", true)
	QuestManager.set_tracked("sea_camp_water")
	check(WorldManager.start_experience("joseph_dothan") == "" and GameState.tracked_quest == "", "iniciar experiência limpa a missão acompanhada")
	GameState.new_game()


func test_nava_name() -> void:
	var d: Dictionary = DialogueManager.db.get_dialogue("sea_nava_talk")
	check(String(d.nodes.greet.text).begins_with("Sou Nava."), "Nava se apresenta pelo nome")
	check(GameData.get_character_name("sea_nava") == "Nava", "personagem sea_nava se chama Nava")
