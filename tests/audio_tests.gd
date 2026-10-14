extends RefCounted
## Testes do áudio: manifesto, arquivos (não silenciosos), buses, regras de
## reprodução, botões, diálogos, bolsa, eventos de jogo, passos por superfície,
## ambiente por região e preferências. Chamado por tests/test_runner.gd.
## Não substituem ouvir: qualidade e mixagem exigem escuta humana (docs/audio.md).

const GAME_SCENE := "res://scenes/core/game.tscn"
const WavInfo := preload("res://tools/audio/wav_info.gd")
const TEST_SETTINGS := "user://test_settings.cfg"

var r: Node


func _init(runner: Node) -> void:
	r = runner


func check(cond: bool, label: String) -> void:
	r.check(cond, label)


func wait(frames: int) -> void:
	await r._wait_physics(frames)


func _reset_rules() -> void:
	AudioManager.stop_all()
	AudioManager.clear_history()
	AudioManager._pending_events.clear()
	AudioManager._last_immediate = -100000
	AudioManager._quiet_until = 0


func _since(id: String, t: int) -> int:
	return AudioManager.played_count(id, t)


# --- Manifesto, arquivos e buses ------------------------------------------------

func test_manifest_and_files() -> void:
	check(AudioManager.errors.is_empty(), "áudio: manifesto sem erros %s" % [AudioManager.errors])
	check(AudioManager.sounds.size() >= 70, "áudio: %d sons no manifesto" % AudioManager.sounds.size())
	for bus in Settings.AUDIO_BUSES:
		check(AudioServer.get_bus_index(bus) >= 0, "áudio: bus %s existe" % bus)
	var master := AudioServer.get_bus_index("Master")
	var has_limiter := false
	for i in AudioServer.get_bus_effect_count(master):
		has_limiter = has_limiter or AudioServer.get_bus_effect(master, i) is AudioEffectHardLimiter
	check(has_limiter, "áudio: limitador no Master contra picos")
	var missing: Array = []
	var silent: Array = []
	var clipped: Array = []
	var unloadable: Array = []
	var files := 0
	for id in AudioManager.sounds:
		for path in AudioManager.files_of(String(id)):
			files += 1
			if not FileAccess.file_exists(path) and not ResourceLoader.exists(path):
				missing.append(path)
				continue
			var s: AudioStream = load(path)
			if s == null or s.get_length() < 0.02:
				unloadable.append(path)
			var info := WavInfo.read(path)
			if not info.ok or info.peak_db < -30.0 or info.rms_db < -50.0:
				silent.append("%s (%s)" % [path.get_file(), info.get("error", "%.1f dB" % info.peak_db)])
			elif info.clipped > 0:
				clipped.append(path.get_file())
	check(missing.is_empty(), "áudio: os %d arquivos do manifesto existem %s" % [files, missing])
	check(unloadable.is_empty(), "áudio: todos carregam como AudioStream com duração %s" % [unloadable])
	check(silent.is_empty(), "áudio: nenhum arquivo silencioso ou vazio %s" % [silent])
	check(clipped.is_empty(), "áudio: nenhum arquivo saturado %s" % [clipped])
	var bad_bus: Array = AudioManager.sounds.keys().filter(func(id): return not (String(AudioManager.sounds[id].get("bus", "")) in AudioManager.BUSES))
	check(bad_bus.is_empty(), "áudio: todo som tem bus válido %s" % [bad_bus])

	var bed: AudioStream = AudioManager.stream("amb_wind_canaan")
	check(bed is AudioStreamWAV and (bed as AudioStreamWAV).loop_mode == AudioStreamWAV.LOOP_FORWARD, "áudio: ambiente contínuo toca em laço")
	check(AudioManager.stream("ui_click", 0) == AudioManager.stream("ui_click", 0), "áudio: arquivo carregado uma vez só (cache)")


func test_mappings() -> void:
	var bad: Array = []
	for did in AudioManager.interactions.get("by_dialogue", {}):
		if not DialogueManager.db.has_dialogue(String(did)):
			bad.append("diálogo %s" % did)
		if not AudioManager.has_sound(AudioManager.interaction_sound(String(did), "EXAMINE")):
			bad.append("som de %s" % did)
	for k in AudioManager.interactions.get("kinds", {}):
		var id := String(AudioManager.interactions.kinds[k])
		if id != "" and not AudioManager.has_sound(id):
			bad.append("tipo %s" % k)
		if not (k in Interactable.Kind.keys()):
			bad.append("tipo desconhecido %s" % k)
	check(bad.is_empty(), "áudio: sons de interação apontam para diálogos e sons existentes %s" % [bad])
	var props: Array = []
	for f in DirAccess.get_files_at("res://scenes/environments"):
		if not f.ends_with(".tscn"):
			continue
		var inst: Node = load("res://scenes/environments/" + f).instantiate()
		for it in inst.find_children("*", "Interactable", true, false):
			var did := String(it.dialogue_id)
			if did != "" and it.kind != Interactable.Kind.TALK and not AudioManager.interactions.by_dialogue.has(did):
				props.append(did)
		inst.free()
	for rid in GameData.regions:
		for e in GameData.regions[rid].get("examinables", []):
			if not AudioManager.interactions.by_dialogue.has(String(e.get("dialogue", ""))):
				props.append(String(e.get("dialogue", "")))
	check(props.is_empty(), "áudio: todo objeto examinável dos mapas tem som de material %s" % [props])
	var items_bad: Array = []
	for id in Inventory.items:
		if not AudioManager.has_sound(AudioManager.item_sound(String(id))):
			items_bad.append(id)
	check(items_bad.is_empty(), "áudio: todo item tem som de coleta %s" % [items_bad])
	for rid in GameData.regions:
		var def: Dictionary = AudioManager.ambience_defs.get(rid, {})
		var ok := AudioManager.has_sound(String(def.get("bed", "")))
		for l in def.get("layers", []):
			for s in l.get("sounds", []):
				ok = ok and AudioManager.has_sound(String(s))
		for e in def.get("emitters", []):
			ok = ok and AudioManager.has_sound(String(e.get("sound", "")))
		check(ok, "áudio: região %s tem ambiente com sons existentes" % rid)
	for surface in AudioManager.surfaces.get("sounds", {}):
		check(AudioManager.has_sound(String(AudioManager.surfaces.sounds[surface])), "áudio: passos em %s" % surface)


# --- Regras de reprodução -------------------------------------------------------

func test_playback_rules() -> void:
	_reset_rules()
	check(AudioManager.play("ui_click") != null, "áudio: toca um clique")
	check(AudioManager.play("ui_click") == null, "áudio: clique repetido no mesmo instante é evitado (cooldown)")
	check(AudioManager.play("som_que_nao_existe") == null, "áudio: id inexistente não quebra")

	_reset_rules()
	var a := AudioManager.play("item_wood")
	AudioManager._last_time.clear()
	var b := AudioManager.play("item_wood")
	AudioManager._last_time.clear()
	var c := AudioManager.play("item_wood")
	check(a != null and b != null and c == null, "áudio: limite de instâncias simultâneas do mesmo som")

	_reset_rules()
	var click := AudioManager.play("ui_click")
	AudioManager.play("menu_open")
	check(click != null and not click.playing, "áudio: abrir menu interrompe o clique do mesmo gesto")

	# Conjunto cheio: som importante rouba a voz de um menos importante; o contrário não.
	_reset_rules()
	var now := Time.get_ticks_msec()
	for p in AudioManager._pool:
		p.stream = AudioManager.stream("amb_wind_canaan")
		p.play()
		AudioManager._voices[p] = {"id": "teste", "priority": 5, "started": now}
	check(AudioManager.play("quest_complete") != null, "áudio: conjunto cheio cede a voz de menor prioridade")
	for p in AudioManager._pool:
		if not p.playing:
			p.play()
		AudioManager._voices[p] = {"id": "teste", "priority": 99, "started": now}
	AudioManager._last_time.clear()
	check(AudioManager.play("ui_hover") == null, "áudio: som irrelevante não interrompe sons importantes")
	check(AudioManager._pool.size() == AudioManager.POOL_SIZE, "áudio: número de players fixo (%d), sem criar um por som" % AudioManager.POOL_SIZE)
	_reset_rules()


func test_events() -> void:
	var was_in_game := GameState.in_game
	GameState.new_game()
	GameState.in_game = true
	_reset_rules()
	var t := Time.get_ticks_msec()
	AudioManager.event("objective_complete")
	AudioManager.event("discovery")
	AudioManager.event("quest_complete")
	await r.get_tree().process_frame
	await r.get_tree().process_frame
	check(_since("quest_complete", t) == 1 and _since("objective_complete", t) == 0 and _since("discovery", t) == 0,
		"áudio: marcos no mesmo instante viram um só som (o mais importante)")

	_reset_rules()
	GameState.new_game()
	t = Time.get_ticks_msec()
	AudioManager.event("quest_start")
	await r.get_tree().process_frame
	check(_since("quest_start", t) == 0, "áudio: eventos logo após carregar/novo jogo não tocam")

	_reset_rules()
	GameState.in_game = false
	AudioManager.event("quest_start")
	await r.get_tree().process_frame
	check(_since("quest_start", t) == 0, "áudio: fora do jogo, eventos de missão não tocam")
	GameState.in_game = true

	# Sinais reais dos sistemas
	_reset_rules()
	t = Time.get_ticks_msec()
	QuestManager.record_event("prologue_finished", "new_game")
	await r.get_tree().process_frame
	check(_since("quest_start", t) == 1, "áudio: missão iniciada toca \"quest_start\"")
	_reset_rules()
	t = Time.get_ticks_msec()
	Discoveries.unlock("wells_antiquity")
	await r.get_tree().process_frame
	check(_since("discovery", t) == 1, "áudio: descoberta bíblica toca som próprio, diferente da recompensa")
	_reset_rules()
	t = Time.get_ticks_msec()
	check(not Discoveries.unlock("wells_antiquity"), "descoberta repetida não registra de novo")
	await r.get_tree().process_frame
	check(_since("discovery", t) == 0, "áudio: descoberta repetida não toca de novo")
	_reset_rules()
	t = Time.get_ticks_msec()
	Inventory.add("barley_bread", 1, "reward", true)
	await r.get_tree().process_frame
	check(_since("reward", t) == 1 and _since("item_receive", t) == 0, "áudio: recompensa toca som próprio")
	Inventory.remove("barley_bread", 1, "deliver")
	_reset_rules()
	t = Time.get_ticks_msec()
	Inventory.add("barley_bread", 1, "reward", true)
	AudioManager.event("quest_complete")
	await r.get_tree().process_frame
	check(_since("quest_complete", t) == 1 and _since("reward", t) == 0, "áudio: recompensa da conclusão não se soma ao som de missão concluída")
	Inventory.remove("barley_bread", 1, "deliver")

	# Bolsa: só toca quando o item realmente entra ou sai.
	_reset_rules()
	t = Time.get_ticks_msec()
	Inventory.add("dry_wood", 1, "pickup")
	check(_since("item_wood", t) == 1, "áudio: coletar lenha toca som de madeira")
	AudioManager._last_time.clear()
	Inventory.add("rope", 1, "dialogue", true)
	check(_since("item_receive", t) == 1, "áudio: receber item de alguém toca \"item_receive\"")
	AudioManager._last_time.clear()
	Inventory.remove("rope", 1, "deliver")
	check(_since("item_give", t) == 1, "áudio: entregar item toca \"item_give\"")
	AudioManager._last_time.clear()
	Inventory.add("rope", 1, "dialogue", true)
	AudioManager._last_time.clear()
	check(Inventory.discard("rope", 1) and _since("item_discard", t) == 1, "áudio: descartar toca som de item no chão")
	AudioManager._last_time.clear()
	var before := AudioManager.history.size()
	check(not Inventory.discard("dry_wood", 1) and AudioManager.history.size() == before, "áudio: descarte recusado (item protegido) não toca som de descarte")
	check(not Inventory.remove("rope", 1, "deliver") and AudioManager.history.size() == before, "áudio: entrega sem o item não toca som")
	var guard := 0
	while Inventory.room_for("wool_cloth", 1) > 0 and guard < 2000:
		Inventory.add("wool_cloth", 1, "reward")
		guard += 1
	AudioManager._last_time.clear()
	before = AudioManager.history.size()
	check(Inventory.add("barley_bread", 1, "pickup") == 0, "bolsa cheia recusa item novo")
	check(AudioManager.history.size() == before, "áudio: coleta recusada não toca som de coleta")
	GameState.new_game()
	GameState.in_game = was_in_game
	_reset_rules()


func test_ui_buttons() -> void:
	_reset_rules()
	var t := Time.get_ticks_msec()
	var b := Button.new()
	b.text = "teste"
	r.add_child(b)
	b.pressed.emit()
	check(_since("ui_click", t) == 1, "áudio: botão criado em código ganha clique sem script próprio")
	var silent := Button.new()
	silent.set_meta("sfx", "")
	r.add_child(silent)
	AudioManager._last_time.clear()
	silent.pressed.emit()
	check(_since("ui_click", t) == 1, "áudio: botão com sfx vazio fica em silêncio")
	var custom := Button.new()
	custom.set_meta("sfx", "dialogue_choice")
	r.add_child(custom)
	custom.pressed.emit()
	check(_since("dialogue_choice", t) == 1, "áudio: botão pode pedir outro som")
	b.disabled = true
	b.mouse_entered.emit()
	check(_since("ui_hover", t) == 0, "áudio: botão desabilitado não faz hover")
	b.disabled = false
	b.mouse_entered.emit()
	check(_since("ui_hover", t) == 1, "áudio: hover discreto em botão habilitado")
	b.mouse_entered.emit()
	check(_since("ui_hover", t) == 1, "áudio: hover não repete em seguida")
	AudioManager._nav_time = -100000
	b.focus_entered.emit()
	check(_since("ui_focus", t) == 0, "áudio: foco dado pelo código (abrir menu) não faz som")
	AudioManager._nav_time = Time.get_ticks_msec()
	b.focus_entered.emit()
	check(_since("ui_focus", t) == 1, "áudio: foco movido pelo teclado faz som leve")
	for n in [b, silent, custom]:
		n.queue_free()
	await r.get_tree().process_frame
	_reset_rules()


func _step_dialogue() -> void:
	var choices := DialogueManager.current_choices()
	if choices.is_empty():
		DialogueManager.advance()
	else:
		DialogueManager.choose(choices.size() - 1)


func _finish_dialogue() -> void:
	var guard := 0
	while DialogueManager.is_active() and guard < 60:
		_step_dialogue()
		guard += 1
	if DialogueManager.is_active():
		DialogueManager._end()


func test_dialogue_and_interaction() -> void:
	GameState.new_game()
	_reset_rules()
	var t := Time.get_ticks_msec()
	check(DialogueManager.start("adina_talk"), "conversa inicia")
	check(_since("dialogue_open", t) == 1 and _since("dialogue_advance", t) == 0, "áudio: abrir conversa toca som discreto (sem som de avanço)")
	DialogueManager.advance()
	check(_since("dialogue_advance", t) == 1, "áudio: avançar fala toca som")
	var guard := 0
	while DialogueManager.is_active() and guard < 30:
		AudioManager._last_time.erase("dialogue_advance")
		_step_dialogue()
		guard += 1
	check(not DialogueManager.is_active() and _since("dialogue_close", t) == 1, "áudio: encerrar conversa toca som")
	_finish_dialogue()

	_reset_rules()
	t = Time.get_ticks_msec()
	var well: Node = load("res://scenes/environments/well.tscn").instantiate()
	r.add_child(well)
	var it: Interactable = well.find_children("*", "Interactable", true, false)[0]
	it.interact(null)
	check(_since("interact_water_well", t) == 1, "áudio: examinar o poço toca água no poço")
	check(_since("dialogue_open", t) == 0, "áudio: objeto examinado não soma o som de conversa")
	_finish_dialogue()
	well.queue_free()
	_reset_rules()
	t = Time.get_ticks_msec()
	check(AudioManager.interaction_sound("pots_examine", "EXAMINE") == "interact_ceramic" and AudioManager.interaction_sound("tent_examine", "EXAMINE") == "interact_cloth"
		and AudioManager.interaction_sound("objeto_novo", "READ") == "interact_parchment" and AudioManager.interaction_sound("objeto_novo", "EXAMINE") == "interact_generic",
		"áudio: material por objeto e padrão por tipo (cerâmica, tecido, pergaminho, genérico)")
	GameState.new_game()
	await r.get_tree().process_frame


# --- Preferências ---------------------------------------------------------------

func test_settings() -> void:
	var old_path := Settings.path
	Settings.path = TEST_SETTINGS
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SETTINGS))
	Settings.load_settings()
	check(Settings.volume("SFX") == Settings.DEFAULT_VOLUMES.SFX and not Settings.is_muted("Master"), "áudio: sem arquivo, valores padrão sem nada silenciado")
	Settings.set_volume("SFX", 0.5)
	Settings.set_volume("Ambience", 0.25)
	Settings.set_muted("Music", true)
	var sfx := AudioServer.get_bus_index("SFX")
	check(absf(AudioServer.get_bus_volume_db(sfx) - linear_to_db(0.5)) < 0.01, "áudio: volume de efeitos aplicado em tempo real (%.1f dB)" % AudioServer.get_bus_volume_db(sfx))
	check(AudioServer.is_bus_mute(AudioServer.get_bus_index("Music")), "áudio: silenciar música aplica no bus")
	Settings.save_settings()
	Settings.reset_defaults()
	Settings.load_settings()
	check(Settings.volume("SFX") == 0.5 and Settings.volume("Ambience") == 0.25 and Settings.is_muted("Music"), "áudio: volumes e silêncio persistem após recarregar")
	Settings.set_volume("Master", 0.0)
	check(AudioServer.is_bus_mute(AudioServer.get_bus_index("Master")), "áudio: volume zero silencia sem distorcer")
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "master_volume", 0.7)
	cfg.save(TEST_SETTINGS)
	Settings.load_settings()
	check(is_equal_approx(Settings.master_volume, 0.7) and Settings.volume("UI") == Settings.DEFAULT_VOLUMES.UI, "áudio: arquivo antigo (só volume geral) é respeitado")

	_reset_rules()
	var panel := AudioSettingsPanel.new()
	r.add_child(panel)
	var t := Time.get_ticks_msec()
	panel.slider("SFX").value = 0.6
	check(is_equal_approx(Settings.volume("SFX"), 0.6), "áudio: controle deslizante de efeitos altera a preferência")
	check(_since("item_pickup", t) == 1, "áudio: ajustar efeitos toca um som de teste")
	AudioManager._last_time.clear()
	panel.slider("SFX").value = 0.65
	panel.slider("SFX").value = 0.7
	check(_since("item_pickup", t) == 1, "áudio: arrastar o controle não dispara sons em excesso")
	panel.mute_box("UI").button_pressed = true
	check(Settings.is_muted("UI") and AudioServer.is_bus_mute(AudioServer.get_bus_index("UI")), "áudio: caixa de silenciar por categoria")
	panel.queue_free()
	await r.get_tree().create_timer(0.5).timeout
	check(FileAccess.file_exists(TEST_SETTINGS), "áudio: preferências gravadas depois do ajuste")

	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SETTINGS))
	Settings.path = old_path
	Settings.load_settings()
	Settings.apply()
	_reset_rules()


# --- No jogo: passos, superfícies e ambiente ------------------------------------

func test_in_game() -> void:
	GameState.new_game()
	GameState.set_flag("prologue_seen", true)
	var game: Node = load(GAME_SCENE).instantiate()
	r.add_child(game)
	await wait(5)
	await r._close_cards(game.get_node("HUD"))
	for n in game.find_children("*", "NPC", true, false):
		n.process_mode = Node.PROCESS_MODE_DISABLED
	var map: GameMap = game.map
	var p := r.get_tree().get_first_node_in_group("player") as Player

	# Superfícies pelas camadas de tiles.
	var plaza := map.get_node("Plaza") as TileMapLayer
	var paths := map.get_node("Paths") as TileMapLayer
	var ground := map.get_node("Ground") as TileMapLayer
	var stone_cell: Vector2i = plaza.get_used_cells()[0]
	var dirt_cell := Vector2i(-1, -1)
	for c in paths.get_used_cells():
		if plaza.get_cell_source_id(c) == -1:
			dirt_cell = c
			break
	var grass_cell := Vector2i(-1, -1)
	for c in ground.get_used_cells():
		if plaza.get_cell_source_id(c) == -1 and paths.get_cell_source_id(c) == -1:
			grass_cell = c
			break
	check(map.surface_at(plaza.to_global(plaza.map_to_local(stone_cell))) == "stone", "áudio: praça de pedra soa como pedra")
	check(map.surface_at(paths.to_global(paths.map_to_local(dirt_cell))) == "dirt", "áudio: caminho soa como terra")
	check(map.surface_at(ground.to_global(ground.map_to_local(grass_cell))) == "grass", "áudio: campo soa como grama")

	# Ambiente da aldeia.
	check(AudioManager.current_bed() == "amb_wind_canaan", "áudio: aldeia liga o vento de Canaã")
	check(map.find_children("Ambience_*", "AudioStreamPlayer2D", true, false).size() == 1, "áudio: água do poço presa ao mapa")
	for l in AudioManager._layers:
		l.next = 0.0
	var t := Time.get_ticks_msec()
	await r.get_tree().process_frame
	await r.get_tree().process_frame
	var amb := AudioManager.history.filter(func(h): return int(h.t) >= t and String(h.id).begins_with("amb_"))
	check(amb.size() >= 1, "áudio: sons ocasionais da aldeia tocam (%s)" % [amb.map(func(h): return h.id)])

	# Passos: andando, parado e contra a parede.
	p.global_position = map.default_spawn()
	await wait(2)
	_reset_rules()
	t = Time.get_ticks_msec()
	Input.action_press("move_left")
	await wait(40)
	Input.action_release("move_left")
	var steps := 0
	for s in ["footstep_dirt", "footstep_grass", "footstep_stone"]:
		steps += _since(s, t)
	check(steps >= 3, "áudio: caminhar produz passos (%d em 40 quadros)" % steps)
	check(steps <= 8, "áudio: passos seguem a animação, não um por quadro (%d)" % steps)
	await wait(15)
	t = Time.get_ticks_msec()
	await wait(40)
	var idle := 0
	for s in ["footstep_dirt", "footstep_grass", "footstep_stone"]:
		idle += _since(s, t)
	check(idle == 0, "áudio: parado, sem passos")
	p.global_position = Vector2(480, 372)
	await wait(2)
	Input.action_press("move_up")
	await wait(50)
	t = Time.get_ticks_msec()
	await wait(40)
	Input.action_release("move_up")
	var wall := 0
	for s in ["footstep_dirt", "footstep_grass", "footstep_stone"]:
		wall += _since(s, t)
	check(wall == 0 and p.real_speed < p.step_min_speed, "áudio: andar contra o poço (parede) não faz passos")
	await wait(10)
	p.global_position = map.default_spawn()
	await wait(2)
	_reset_rules()
	t = Time.get_ticks_msec()
	var mask := p.collision_mask
	p.collision_mask = 0
	Input.action_press("run")
	Input.action_press("move_left")
	var run_start := Time.get_ticks_msec()
	while Time.get_ticks_msec() - run_start < 700:
		await wait(1)
	var running := p.real_speed > p.walk_speed * 1.15
	Input.action_release("move_left")
	Input.action_release("run")
	var run_steps := 0
	for s in ["footstep_dirt", "footstep_grass", "footstep_stone"]:
		run_steps += _since(s, t)
	p.collision_mask = mask
	check(running and run_steps >= 3, "áudio: correr também produz passos (%d)" % run_steps)
	await wait(10)
	game.get_node("Journal").open()
	await wait(2)
	t = Time.get_ticks_msec()
	Input.action_press("move_right")
	await wait(30)
	Input.action_release("move_right")
	game.get_node("Journal").close()
	var paused_steps := 0
	for s in ["footstep_dirt", "footstep_grass", "footstep_stone"]:
		paused_steps += _since(s, t)
	check(paused_steps == 0, "áudio: com o diário aberto, sem passos")
	check(_since("journal_close", t) == 1, "áudio: fechar o diário toca som de livro")

	# Telas
	_reset_rules()
	t = Time.get_ticks_msec()
	game.inventory_screen.open()
	game.inventory_screen.close()
	game.scripture_map.open()
	game.scripture_map.close()
	check(_since("bag_open", t) == 1 and _since("bag_close", t) == 1, "áudio: abrir e fechar a bolsa (couro)")
	check(_since("map_open", t) == 1 and _since("map_close", t) == 1, "áudio: abrir e fechar o Mapa das Escrituras (pergaminho)")
	var pause = game.get_node("PauseMenu")
	pause.open()
	pause._on_save()
	check(_since("menu_open", t) == 1 and _since("save", t) == 1, "áudio: pausa abre com som e salvar confirma")
	pause.close()

	# Troca de região: um único ambiente de fundo, emissores do mapa antigo somem.
	_reset_rules()
	GameState.set_flag("experience:joseph_dothan", true)
	t = Time.get_ticks_msec()
	WorldManager.travel("caravan_road", "from_canaan")
	var started := Time.get_ticks_msec()
	while not game.is_traveling() and Time.get_ticks_msec() - started < 2000:
		await wait(1)
	while game.is_traveling() and Time.get_ticks_msec() - started < 8000:
		await wait(1)
	await wait(4)
	check(not game.is_traveling(), "viagem terminou")
	check(game.map.region_id == "caravan_road" and AudioManager.current_bed() == "amb_wind_road", "áudio: Caminho das Caravanas troca o vento")
	check(_since("travel", t) == 1, "áudio: viagem entre regiões toca transição")
	var marks: int = _since("region_new", t) + _since("quest_start", t) + _since("objective_complete", t)
	check(marks == 1, "áudio: primeira chegada a uma região toca um único marco (região nova ou missão que começa ali) (%d)" % marks)
	check(r.get_tree().get_nodes_in_group("ambience_emitter").filter(func(e): return is_instance_valid(e) and e.is_inside_tree()).size() == 0,
		"áudio: água do poço não continua tocando fora da aldeia")
	await r.get_tree().create_timer(AudioManager.BED_FADE + 0.3).timeout
	var beds_playing := AudioManager._beds.filter(func(b): return b.playing).size()
	check(beds_playing == 1, "áudio: só um ambiente de fundo depois da troca (%d)" % beds_playing)

	game.queue_free()
	await wait(3)
	check(AudioManager.current_bed() == "", "áudio: sair do jogo desliga o ambiente")
	check(not r.get_tree().paused, "teste de áudio não deixa o jogo pausado")
	r.get_tree().paused = false
	GameState.new_game()
	_reset_rules()
