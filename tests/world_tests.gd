extends RefCounted
## Testes de múltiplos mapas, inventário, coleta e colecionáveis (v0.4).
## Chamado por tests/test_runner.gd, que fornece check() e as esperas.

const GAME_SCENE := "res://scenes/core/game.tscn"

var r: Node


func _init(runner: Node) -> void:
	r = runner


func check(cond: bool, label: String) -> void:
	r.check(cond, label)


func wait(frames: int) -> void:
	await r._wait_physics(frames)


# --- Dados das regiões ---------------------------------------------------------

func test_region_data() -> void:
	check(WorldManager.errors.is_empty(), "experiências do Mapa das Escrituras sem erros %s" % [WorldManager.errors])
	for rid in GameData.regions:
		var reg: Dictionary = GameData.regions[rid]
		var scene := String(reg.get("map_scene", ""))
		check(ResourceLoader.exists(scene), "%s: mapa existe (%s)" % [rid, scene])
		var entries: Dictionary = reg.get("entries", {})
		check(entries.has("default"), "%s: tem entrada padrão" % rid)
		for ex in reg.get("exits", []):
			var to := String(ex.get("to", ""))
			check(GameData.regions.has(to), "%s/%s: saída leva a região existente (%s)" % [rid, ex.id, to])
			check(not WorldManager.entry_point(to, String(ex.get("entry", ""))).is_empty(), "%s/%s: entrada de destino existe" % [rid, ex.id])
			check(ConditionSchema.validate(ex.get("requires"), "%s/%s" % [rid, ex.id]).is_empty(), "%s/%s: condição válida" % [rid, ex.id])
			var rect := Rect2(float(ex.rect[0]), float(ex.rect[1]), float(ex.rect[2]), float(ex.rect[3]))
			for eid in entries:
				var e: Dictionary = entries[eid]
				check(not rect.grow(6).has_point(Vector2(float(e.x), float(e.y))), "%s: entrada '%s' fora da saída '%s' (sem viagem em laço)" % [rid, eid, ex.id])
		for d in reg.get("npcs", []):
			check(GameData.characters.has(String(d.get("character", d.id))), "%s: NPC '%s' existe em data/characters" % [rid, d.id])
		for d in reg.get("examinables", []):
			check(DialogueManager.db.has_dialogue(String(d.get("dialogue", ""))), "%s: examinável '%s' tem diálogo" % [rid, d.id])
			check(ConditionSchema.validate(d.get("visible_if"), rid).is_empty(), "%s: condição de '%s' válida" % [rid, d.id])
		for d in reg.get("pickups", []):
			check(Inventory.exists(String(d.get("item", ""))), "%s: item do chão '%s' existe" % [rid, d.id])
	# Validação da fábrica: alvos, itens, conjuntos e desfechos de todas as missões.
	var fc := FactoryCatalog.new()
	for qid in QuestManager.db.order:
		var errs := fc.quest_world_errors(QuestManager.db.get_quest(qid))
		check(errs.is_empty(), "fábrica: missão %s ligada ao mundo %s" % [qid, errs])
	var future: Dictionary = QuestManager.db.get_quest("joseph_dothan_road").duplicate(true)
	future.objectives[6].targets = [{"type": "region", "id": "egypt_joseph"}]
	future.objectives[6].complete_on = {"event": "region_entered", "id": "egypt_joseph"}
	check(fc.quest_world_errors(future).size() == 2, "fábrica: missão que depende de mapa futuro fica em planejamento")
	var bad_choice: Dictionary = QuestManager.db.get_quest("dothan_families").duplicate(true)
	bad_choice.completion.variants[0]["if"] = {"choice": "dothan_families", "option": "ninguem"}
	check(not fc.quest_world_errors(bad_choice).is_empty(), "fábrica: desfecho sem escolha correspondente é recusado")
	# A rota da aldeia até Dotã passa pelo Caminho das Caravanas.
	check(String(WorldManager.route_exit("canaan_village", "dothan").get("to", "")) == "caravan_road", "rota aldeia -> Dotã começa pela saída leste")
	check(String(WorldManager.route_exit("dothan", "canaan_village").get("to", "")) == "caravan_road", "rota Dotã -> aldeia volta pelo Caminho")


## Cada entrada fica em lugar livre (sem colisão) no mapa real.
func test_entries_free() -> void:
	for rid in GameData.regions:
		var reg: Dictionary = GameData.regions[rid]
		var map: GameMap = load(String(reg.map_scene)).instantiate()
		r.add_child(map)
		await wait(3)
		for eid in reg.get("entries", {}):
			var e: Dictionary = reg.entries[eid]
			check(map.is_position_free(Vector2(float(e.x), float(e.y))), "%s: entrada '%s' não fica dentro de colisão" % [rid, eid])
		for d in reg.get("pickups", []):
			check(map.is_position_free(Vector2(float(d.x), float(d.y)) + Vector2(0, 10)) or map.is_position_free(Vector2(float(d.x), float(d.y)) + Vector2(0, -10)), "%s: item '%s' alcançável" % [rid, d.id])
		map.queue_free()
		await wait(2)


# --- Viagem entre regiões ------------------------------------------------------

func _start_game() -> Node:
	var game: Node = load(GAME_SCENE).instantiate()
	r.add_child(game)
	await wait(5)
	return game


func _player() -> Player:
	return r.get_tree().get_first_node_in_group("player") as Player


func _wait_travel(game: Node, max_frames := 240) -> void:
	var guard := 0
	while guard < 60:
		if game.is_traveling():
			break
		await wait(2)
		guard += 1
	guard = 0
	while game.is_traveling() and guard < max_frames:
		await wait(2)
		guard += 1
	await wait(4)


func _walk(action: String, frames: int) -> void:
	Input.action_press(action)
	await wait(frames)
	Input.action_release(action)


func test_travel() -> void:
	GameState.new_game()
	GameState.set_flag("prologue_seen", true)
	var game: Node = await _start_game()
	check(game.map.region_id == "canaan_village" and GameState.current_region == "canaan_village", "jogo começa na aldeia (região registrada)")
	for n in game.find_children("*", "NPC", true, false):
		n.process_mode = Node.PROCESS_MODE_DISABLED
	await r._close_cards(game.get_node("HUD"))

	# Saída fechada: avisa, empurra de volta e não viaja.
	var p := _player()
	p.global_position = Vector2(920, 336)
	await wait(2)
	await _walk("move_right", 40)
	await wait(10)
	check(not game.is_traveling() and game.map.region_id == "canaan_village", "saída leste fechada antes da experiência")
	check(p.global_position.x < 946, "jogador é empurrado de volta da saída fechada (x=%.1f)" % p.global_position.x)

	# Experiência iniciada: a saída abre e a viagem acontece andando.
	GameState.set_flag("experience:joseph_dothan", true)
	p.global_position = Vector2(920, 336)
	await wait(2)
	Input.action_press("move_right")
	await _wait_travel(game)
	Input.action_release("move_right")
	await wait(4)
	check(game.map.region_id == "caravan_road", "andar pela saída leste leva ao Caminho das Caravanas")
	check(GameState.current_region == "caravan_road" and GameState.current_map == "res://scenes/maps/caravan_road.tscn", "região e mapa atual atualizados")
	p = _player()
	check(p != null and p.global_position.distance_to(Vector2(24, 272)) < 24.0, "chega pela entrada 'from_canaan' (%s)" % [p.global_position if p else "sem jogador"])
	check(QuestManager.has_event("region_entered", "caravan_road") and WorldManager.is_region_unlocked("caravan_road"), "evento de região e desbloqueio registrados")
	check(not GameState.is_ui_blocked(), "controle volta ao jogador depois da transição")
	check(game.get_node("HUD").title.text == "CAMINHO DAS CARAVANAS", "título discreto da região exibido")
	check(SaveManager.has_save(), "salvamento automático ao chegar")

	# Segue para Dotã e volta, sempre pelos pontos de entrada.
	check(WorldManager.travel("dothan", "from_caravan_road") == "", "viagem para Dotã aceita")
	await _wait_travel(game)
	check(game.map.region_id == "dothan" and _player().global_position.distance_to(Vector2(24, 304)) < 2.0, "chega em Dotã pela entrada oeste")
	p = _player()
	for n in game.find_children("*", "NPC", true, false):
		n.process_mode = Node.PROCESS_MODE_DISABLED
	p.global_position = Vector2(30, 304)
	await wait(2)
	Input.action_press("move_left")
	await _wait_travel(game)
	Input.action_release("move_left")
	check(game.map.region_id == "caravan_road" and _player().global_position.distance_to(Vector2(1000, 304)) < 24.0, "voltar de Dotã chega ao leste do Caminho")
	check(WorldManager.travel("canaan_village", "from_caravan_road") == "", "voltar para a aldeia aceito")
	await _wait_travel(game)
	check(game.map.region_id == "canaan_village" and _player().global_position.distance_to(Vector2(912, 336)) < 2.0, "volta à aldeia pela entrada leste")
	check(WorldManager.travel("lugar_nenhum", "x") != "", "viagem para região inexistente é recusada")
	check(WorldManager.travel("dothan", "porta_inexistente") != "", "entrada inexistente é recusada")

	# Salvar em Dotã, fechar, carregar: mesma região e posição.
	WorldManager.travel("dothan", "from_caravan_road")
	await _wait_travel(game)
	_player().global_position = Vector2(300, 304)
	check(GameState.save_game() == OK, "salvar em Dotã")
	game.queue_free()
	await wait(3)
	GameState.new_game()
	check(GameState.load_game() == "", "carregar o save de Dotã")
	check(GameState.current_region == "dothan", "região salva restaurada")
	var game2: Node = await _start_game()
	check(game2.map.region_id == "dothan" and _player().global_position.distance_to(Vector2(300, 304)) < 1.0, "carregar abre Dotã na posição salva")
	game2.queue_free()
	await wait(3)

	# Posição salva dentro de colisão vai para a entrada padrão.
	GameState.new_game()
	GameState.set_flag("prologue_seen", true)
	GameState.current_map = "res://scenes/maps/canaan_village.tscn"
	GameState.player_position = Vector2(480, 340)  # dentro do poço
	var game3: Node = await _start_game()
	await wait(4)
	check(_player().global_position.distance_to(Vector2(480, 388)) < 1.0, "posição salva inválida volta à entrada padrão")
	game3.queue_free()
	await wait(3)
	GameState.new_game()


# --- Inventário ------------------------------------------------------------------

func test_inventory() -> void:
	check(Inventory.errors.is_empty(), "itens sem erros %s" % [Inventory.errors])
	check(Collectibles.errors.is_empty(), "colecionáveis sem erros %s" % [Collectibles.errors])
	for id in Inventory.order:
		check(Inventory.icon(id) != null, "item '%s' tem ícone" % id)
	for sid in Collectibles.sets:
		check(Collectibles.set_total(sid) > 0, "conjunto '%s' tem colecionáveis" % sid)
	GameState.new_game()
	check(Inventory.add("plant_fiber", 25, "pickup") == 25 and Inventory.count("plant_fiber") == 25, "itens se acumulam")
	check(Inventory.slots_used() == 3, "pilhas de até 10 ocupam 3 espaços (%d)" % Inventory.slots_used())
	check(QuestManager.has_event("item_collected", "plant_fiber"), "coleta registra o evento item_collected")
	check(not Inventory.remove("plant_fiber", 30, "deliver") and Inventory.count("plant_fiber") == 25, "não remove mais do que existe")
	check(Inventory.remove("plant_fiber", 5, "deliver") and Inventory.count("plant_fiber") == 20, "remove parte da pilha")
	check(Inventory.add("water_skin", 10, "reward") == 10 and Inventory.slots_used() == Inventory.BAG_SLOTS, "bolsa cheia (%d/%d)" % [Inventory.slots_used(), Inventory.BAG_SLOTS])
	check(Inventory.add("dry_wood", 1, "pickup") == 0 and Inventory.room_for("dry_wood", 1) == 0, "bolsa cheia recusa item novo")
	check(Inventory.add("provisions_basket", 1, "dialogue") == 1 and Inventory.is_essential("provisions_basket"), "item de missão entra mesmo com a bolsa cheia")
	check(not Inventory.can_discard("provisions_basket") and not Inventory.discard("provisions_basket"), "item de missão não pode ser descartado")
	check(Inventory.discard("water_skin") and Inventory.count("water_skin") == 9, "item comum pode ser descartado")
	check(Inventory.add("item_inexistente", 1) == 0, "item inexistente é recusado")
	GameState.new_game()


func _talk(id: String, picks: Array = []) -> Array:
	var texts: Array = []
	if not DialogueManager.start(id):
		return texts
	var guard := 0
	while DialogueManager.is_active() and guard < 40:
		guard += 1
		texts.append(String(DialogueManager._node.get("text", "")))
		var ch := DialogueManager.current_choices()
		if ch.is_empty():
			DialogueManager.advance()
			continue
		var idx := -1
		if not picks.is_empty():
			var want := String(picks.pop_front())
			for i in ch.size():
				if String(ch[i].text).contains(want):
					idx = i
		if idx < 0:
			idx = ch.size() - 1
		DialogueManager.choose(idx)
	return texts


func _choices_of(id: String) -> Array:
	DialogueManager.start(id)
	var guard := 0
	while DialogueManager.is_active() and DialogueManager.current_choices().is_empty() and guard < 20:
		DialogueManager.advance()
		guard += 1
	var out := DialogueManager.current_choices().map(func(c): return String(c.text))
	if DialogueManager.is_active():
		DialogueManager.choose(DialogueManager.current_choices().size() - 1)
		while DialogueManager.is_active():
			DialogueManager.advance()
	return out


func test_supplies_quest() -> void:
	GameState.new_game()
	var qid := "road_supplies"
	_talk("malik_talk", ["Você precisa"])
	check(QuestManager.status(qid) == "active" and QuestManager.current_objective(qid).id == "find_resources", "pedido de Malik inicia \"Suprimentos para a viagem\"")
	check(QuestManager.has_event("custom", "road_malik_news"), "conversa com Malik registra as notícias da estrada")
	Inventory.add("plant_fiber", 1, "pickup")
	Inventory.add("dry_wood", 1, "pickup")
	check(QuestManager.current_objective(qid).id == "collect", "dois tipos de recurso encontrados")
	Inventory.add("plant_fiber", 2, "pickup")
	Inventory.add("dry_wood", 1, "pickup")
	check(QuestManager.current_objective(qid).id == "deliver", "quantidades completas pedem a entrega")
	_talk("malik_talk", ["Não, obrigado"])
	check(Inventory.count("plant_fiber") == 0 and Inventory.count("dry_wood") == 0, "entrega retira fibra e lenha da bolsa")
	check(Inventory.count("water_skin") == 1 and Inventory.count("dried_figs") == 2, "troca: odre e figos secos recebidos")
	check(QuestManager.status(qid) == "completed", "missão concluída depois do conselho de viagem")
	check(GameState.get_flag("merchant_trust") == true and GameState.get_flag("accepted_reward") == false, "flags merchant_trust e accepted_reward registradas")
	check(Collectibles.is_found("road_hospitality") and Discoveries.is_unlocked("ancient_travel"), "recusar a recompensa extra rende um registro e a descoberta")
	check(String(QuestManager.completion(qid).next).contains("recusou"), "conclusão mostra o desfecho escolhido")
	QuestManager._grant_rewards(qid)
	check(Inventory.count("wool_cloth") == 0 and Inventory.count("water_skin") == 1, "recompensas não se repetem")
	_talk("malik_talk")
	check(Inventory.count("water_skin") == 1 and Inventory.count("dried_figs") == 2, "conversar de novo não entrega a troca outra vez")
	Inventory.add("dry_wood", 2, "pickup")
	check(not _choices_of("malik_talk").any(func(t): return t.contains("Trocar")), "troca de odre oculta enquanto há odre na bolsa")
	Inventory.discard("water_skin")
	_talk("malik_talk", ["Trocar"])
	check(Inventory.count("water_skin") == 1 and Inventory.count("dry_wood") == 0, "escambo: 2 lenhas por um odre")
	check(not Inventory.can_discard("plant_fiber") and not Inventory.can_discard("dry_wood"), "materiais da missão não podem ser descartados")
	GameState.new_game()


## Salvar no meio da cadeia de Malik (ex.: janela fechada) não trava a missão.
func test_supplies_resume() -> void:
	var qid := "road_supplies"
	for stop_at in ["reward", "extra"]:
		GameState.new_game()
		_talk("malik_talk", ["Você precisa"])
		Inventory.add("plant_fiber", 3, "pickup")
		Inventory.add("dry_wood", 2, "pickup")
		DialogueManager.start("malik_talk")
		if stop_at == "extra":
			while DialogueManager.is_active() and DialogueManager.current_choices().is_empty():
				DialogueManager.advance()
		check(Inventory.count("plant_fiber") == 0, "[%s] entrega já retirou a fibra" % stop_at)
		GameState.save_game()
		DialogueManager._end()
		GameState.new_game()
		GameState.load_game()
		_talk("malik_talk", ["Aceitar"])
		check(QuestManager.status(qid) == "completed", "[%s] missão conclui depois de carregar (%s)" % [stop_at, QuestManager.current_objective(qid).get("id", "")])
		check(Inventory.count("water_skin") == 1 and Inventory.count("wool_cloth") == 1, "[%s] odre e pano entregues uma vez" % stop_at)
	GameState.new_game()
	_talk("malik_talk", ["Você precisa"])
	check(_choices_of("malik_talk").any(func(t): return t.contains("juntando")), "lembrete aparece enquanto se juntam os recursos")
	GameState.new_game()


func _families_until_decision() -> void:
	GameState.new_game()
	_talk("rafi_talk")
	_talk("talia_talk")
	_talk("oren_talk")


func test_families_outcomes() -> void:
	var qid := "dothan_families"
	_families_until_decision()
	check(QuestManager.status(qid) == "active" and Inventory.count("provisions_basket") == 1, "Rafi entrega o cesto e inicia a missão")
	check(QuestManager.current_objective(qid).id == "decide", "depois de ouvir as duas famílias, falta decidir")
	check(not _choices_of("oren_talk").any(func(t): return t.contains("odre")), "sem odre, não há como repartir")

	# Desfecho 1: o cesto para Talia, mantido depois de salvar e carregar.
	_talk("talia_talk", ["Entregar o cesto"])
	check(GameState.get_flag(Conditions.choice_flag(qid)) == "talia" and Inventory.count("provisions_basket") == 0, "cesto entregue à família de Talia")
	check(QuestManager.current_objective(qid).id == "return_rafi", "entrega conclui a decisão e a entrega")
	check(GameState.save_game() == OK, "salvar depois da escolha")
	GameState.new_game()
	check(GameState.load_game() == "" and GameState.get_flag(Conditions.choice_flag(qid)) == "talia", "escolha preservada depois de carregar")
	_talk("rafi_talk")
	check(QuestManager.status(qid) == "completed" and String(QuestManager.completion(qid).summary[0]).contains("Talia"), "conclusão do desfecho Talia")
	check(GameState.get_flag("family_received_supplies") == true and GameState.get_flag("helped_shepherd") == true, "flags do desfecho registradas")
	check(_talk("talia_talk")[0].contains("ainda falam do cesto"), "Talia lembra da ajuda depois")

	# Desfecho 2: o cesto para Oren, também atravessando save/load.
	_families_until_decision()
	_talk("oren_talk", ["Entregar o cesto"])
	GameState.save_game()
	GameState.new_game()
	GameState.load_game()
	check(GameState.get_flag(Conditions.choice_flag(qid)) == "oren", "escolha Oren preservada depois de carregar")
	_talk("rafi_talk")
	check(QuestManager.status(qid) == "completed" and String(QuestManager.completion(qid).summary[0]).contains("Oren"), "conclusão do desfecho Oren")

	# Desfecho 3: repartir (odre para Oren, cesto para Talia), atravessando save/load.
	_families_until_decision()
	Inventory.add("water_skin", 1, "reward")
	_talk("oren_talk", ["odre"])
	check(GameState.get_flag(Conditions.choice_flag(qid)) == "shared" and Inventory.count("water_skin") == 0 and Inventory.count("provisions_basket") == 1, "odre para Oren, cesto ainda na bolsa")
	check(QuestManager.current_objective(qid).id == "deliver", "falta levar o cesto a Talia")
	GameState.save_game()
	GameState.new_game()
	GameState.load_game()
	check(Inventory.count("provisions_basket") == 1 and QuestManager.current_objective(qid).id == "deliver", "estado da divisão preservado depois de carregar")
	check(_talk("rafi_talk")[0].contains("vai para Talia"), "Rafi lembra de levar o cesto a Talia (não pergunta de novo pelas famílias)")
	_talk("talia_talk")
	_talk("rafi_talk")
	check(QuestManager.status(qid) == "completed" and String(QuestManager.completion(qid).summary[0]).contains("odre"), "conclusão do desfecho repartido")
	check(Discoveries.is_unlocked("sharing_in_need"), "nota do diário liberada no fim")
	GameState.new_game()


func _complete_wells() -> void:
	for e in [["prologue_finished", "new_game"], ["custom", "wells_adina_water"], ["dialogue_finished", "well_examine"],
			["custom", "wells_ari_well"], ["custom", "wells_ezer_disputes"], ["presentation_finished", "gen_026_wells"]]:
		QuestManager.record_event(e[0], e[1])


func test_quests_across_regions() -> void:
	GameState.new_game()
	check(WorldManager.experience_state("joseph_dothan") == "locked", "José em Dotã bloqueado antes dos poços")
	check(WorldManager.start_experience("joseph_dothan") != "", "experiência bloqueada não inicia")
	check(WorldManager.experience_state("ruth_bethlehem") == "planned" and WorldManager.start_experience("ruth_bethlehem") != "", "experiência em planejamento não é jogável")
	_complete_wells()
	check(QuestManager.status("canaan_wells") == "completed" and WorldManager.experience_state("isaac_wells") == "completed", "poços concluídos")
	var main := "joseph_dothan_road"
	check(QuestManager.status(main) == "active" and QuestManager.current_objective(main).id == "open_map", "missão principal começa pedindo o Mapa das Escrituras")
	QuestManager.record_event("region_entered", "caravan_road")
	check(QuestManager.status("caravan_records") == "active", "entrar no Caminho inicia \"Registros da caravana\"")
	check(QuestManager.primary_quest() == main, "HUD prioriza a missão principal")
	check(Collectibles.find("cr_jar") and not Collectibles.find("cr_jar"), "colecionável registrado uma única vez")
	check(QuestManager.current_objective("caravan_records").id == "three_records", "exploração avança com o primeiro registro")
	check(QuestManager.current_objective(main).id == "open_map", "missão principal não avança com a exploração")
	check(WorldManager.start_experience("joseph_dothan") == "" and WorldManager.experience_state("joseph_dothan") == "active", "Mapa das Escrituras inicia José em Dotã")
	check(QuestManager.current_objective(main).get("id") == "adina_context", "experiência iniciada avança a principal (%s)" % QuestManager.current_objective(main).get("id"))
	check(QuestManager.current_objective("caravan_records").id == "three_records", "exploração não avança com a principal")
	QuestManager.set_tracked("caravan_records")
	check(QuestManager.primary_quest() == "caravan_records", "missão de exploração pode ser acompanhada")
	for c in ["cr_marker", "cr_tracks", "cr_campfire", "cr_bundle"]:
		Collectibles.find(c)
	check(QuestManager.status("caravan_records") == "completed" and Inventory.count("rope") == 1, "registros completos concluem a exploração com a recompensa")
	check(QuestManager.primary_quest() == main and GameState.tracked_quest == "", "ao concluir, o HUD volta à principal")
	var entries := JournalContent.build("journey")
	var headers := entries.filter(func(e): return e.get("header", false)).map(func(e): return e.title)
	check(headers.has("HISTÓRIA PRINCIPAL") and headers.has("CONCLUÍDAS"), "diário agrupa jornadas por categoria %s" % [headers])
	var disc := JournalContent.build("discoveries")
	check(String(disc[0].text).contains("Registros da caravana: 5/5"), "Minhas descobertas mostra o progresso da coleção")
	GameState.new_game()


func test_main_quest_flow() -> void:
	GameState.new_game()
	_complete_wells()
	var q := "joseph_dothan_road"
	WorldManager.start_experience("joseph_dothan")
	check(_talk("adina_talk")[0].contains("pasto perto das tendas"), "Adina fala dos pastos distantes")
	check(QuestManager.current_objective(q).id == "village_exit", "depois de Adina: saída leste")
	QuestManager.record_event("location_reached", "canaan_east_gate")
	QuestManager.record_event("region_entered", "caravan_road")
	QuestManager.record_event("location_reached", "caravan_lookout")
	check(QuestManager.current_objective(q).id == "meet_traveler", "na estrada: falar com o mercador")
	var malik := _talk("malik_talk")
	check(malik.any(func(t): return t.contains("Egito")) and not malik.any(func(t): return t.contains("José")), "Malik fala de caravanas sem citar José")
	QuestManager.record_event("region_entered", "dothan")
	check(QuestManager.current_objective(q).id == "overlook", "em Dotã: observar o vale")
	var actions: Array = []
	var cb := func(a): actions.append(a)
	DialogueManager.action_requested.connect(cb)
	_talk("dothan_overlook")
	DialogueManager.action_requested.disconnect(cb)
	check(Discoveries.is_unlocked("dothan_valley") and Collectibles.is_found("dothan_overlook"), "mirante libera a descoberta e o registro")
	check(actions.size() == 1 and actions[0].get("presentation") == "gen_037_search", "mirante abre o relato de Gn 37:12-17")
	check(QuestManager.current_objective(q).id == "read_story", "relato fechado antes do fim: falta lê-lo")
	actions.clear()
	DialogueManager.action_requested.connect(cb)
	_talk("dothan_overlook")
	DialogueManager.action_requested.disconnect(cb)
	check(actions.size() == 1 and actions[0].get("presentation") == "gen_037_search", "examinar o mirante de novo reabre o relato")
	QuestManager.record_event("presentation_finished", "gen_037_search")
	check(QuestManager.status(q) == "completed" and WorldManager.experience_state("joseph_dothan") == "completed", "relato lido conclui a missão e a experiência")
	check(_talk("rafi_talk")[1].contains("lugares distantes"), "Rafi usa a versão genérica da fala (sem alusão a Siquém)")
	GameState.new_game()


## Coleta no mapa real: sem duplicar ao trocar de mapa, salvar e carregar.
func test_pickups_and_screens() -> void:
	GameState.new_game()
	GameState.set_flag("prologue_seen", true)
	GameState.set_flag("experience:joseph_dothan", true)
	WorldManager.travel("caravan_road", "from_canaan")
	var game: Node = await _start_game()
	await r._close_cards(game.get_node("HUD"))
	check(game.map.region_id == "caravan_road", "jogo carregado no Caminho das Caravanas")
	var pk: Pickup = game.map.find_object("pickup", "fiber_1")
	check(pk != null, "item 'fiber_1' está no chão")
	if pk == null:
		game.queue_free()
		await wait(3)
		return
	check(pk.interactable.prompt_text.contains("Coletar"), "prompt \"Coletar\" no item")
	check(pk.collect() == 1 and pk.collect() == 0, "coletar duas vezes rende um item só")
	await wait(3)
	check(Inventory.count("plant_fiber") == 1 and WorldManager.is_picked("caravan_road", "fiber_1"), "item na bolsa e marcado como coletado")
	check(game.map.find_object("pickup", "fiber_1") == null, "item some do chão")
	WorldManager.travel("dothan", "from_caravan_road")
	await _wait_travel(game)
	WorldManager.travel("caravan_road", "from_dothan")
	await _wait_travel(game)
	check(game.map.find_object("pickup", "fiber_1") == null and game.map.find_object("pickup", "fiber_2") != null, "voltar ao mapa não recria o item coletado")
	check(Inventory.count("plant_fiber") == 1, "trocar de mapa não duplica o item")

	# Guia e HUD apontam para a saída quando o objetivo está em outra região.
	GameState.quests["joseph_dothan_road"] = {"status": "active", "objective": 1, "objective_started": 0.0, "started": 0.0, "hints": {}}
	var guide: ObjectiveGuide = game.map.get_node("ObjectiveGuide")
	guide.refresh()
	game.get_node("HUD").refresh_tracker()
	check(guide.points().size() == 1 and guide.points()[0] is MapExit and guide.points()[0].exit_id == "west_village", "seta aponta para a saída rumo à aldeia")
	check(game.get_node("HUD")._tr_detail.text.begins_with("Siga para: Aldeia"), "HUD mostra para onde seguir")
	GameState.quests.erase("joseph_dothan_road")

	# Num objetivo de coleção, a seta deixa de marcar o registro já encontrado.
	GameState.quests["caravan_records"] = {"status": "active", "objective": 1, "objective_started": 0.0, "started": 0.0, "hints": {}}
	QuestManager.set_tracked("caravan_records")
	guide.refresh()
	var before := guide.targets().size()
	Collectibles.find("cr_tracks")
	check(before == 5 and guide.targets().size() == 4 and guide.targets().all(func(t): return String(t.dialogue_id) != "cr_tracks"), "seta ignora o registro encontrado (%d -> %d)" % [before, guide.targets().size()])
	QuestManager.set_tracked("")
	GameState.quests.erase("caravan_records")

	# Teclas I e M.
	r._press("inventory")
	await wait(2)
	check(game.inventory_screen.is_open() and r.get_tree().paused, "I abre a bolsa e pausa")
	r._press("inventory")
	await wait(2)
	check(not game.inventory_screen.is_open() and not r.get_tree().paused, "I fecha a bolsa")
	r._press("places_map")
	await wait(2)
	check(game.scripture_map.is_open(), "M abre o Mapa das Escrituras")
	r._press("pause")
	await wait(2)
	check(not game.scripture_map.is_open() and not r.get_tree().paused and not game.get_node("PauseMenu").visible, "Esc fecha o Mapa das Escrituras sem abrir a pausa")

	# Salvar, fechar e carregar: inventário e itens coletados preservados.
	check(GameState.save_game() == OK, "salvar com item coletado")
	game.queue_free()
	await wait(3)
	GameState.new_game()
	check(GameState.load_game() == "", "carregar o save")
	var game2: Node = await _start_game()
	check(Inventory.count("plant_fiber") == 1, "inventário preservado depois de carregar")
	check(game2.map.find_object("pickup", "fiber_1") == null and game2.map.find_object("pickup", "fiber_2") != null, "item coletado continua fora do chão depois de carregar")
	game2.queue_free()
	await wait(3)
	GameState.new_game()


func test_save_v3_migration() -> void:
	var v2 := {"current_map": GameState.DEFAULT_MAP, "player_position": {"x": 300, "y": 330}, "flags": {"prologue_seen": true, "ev:prologue_finished:new_game": true},
		"quests": {"canaan_wells": {"status": "active", "objective": 2}}, "discoveries": {"land_of_canaan": 3.0}, "play_time": 99.0}
	var m: Variant = SaveManager.migrate(2, v2.duplicate(true))
	var s := SaveManager.sanitize_game_data(m)
	check(s.ok and s.data.inventory.is_empty() and s.data.world.is_empty() and s.data.collectibles.is_empty(), "save v2 migra para v3 com inventário e mundo vazios")
	check(s.ok and s.data.quests.canaan_wells.objective == 2 and s.data.discoveries.has("land_of_canaan"), "migração v2 -> v3 preserva missões e descobertas")
	GameState.new_game()
	GameState.from_dict(s.data)
	check(WorldManager.current_region_id() == "canaan_village", "região deduzida do mapa de um save v2")
	var bad := SaveManager.sanitize_game_data({"current_map": GameState.DEFAULT_MAP, "inventory": {"plant_fiber": 3, "x y": 2, "rope": -1, "dry_wood": "a"},
		"world": {"caravan_road/fiber_1": true, "BAD KEY": true}, "current_region": "../hack"})
	check(bad.ok and bad.data.inventory.size() == 1 and bad.data.world.size() == 1 and bad.data.current_region == "", "save v3 descarta itens, chaves e regiões inválidas")
	GameState.new_game()
