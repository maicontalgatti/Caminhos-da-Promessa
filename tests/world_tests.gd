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
			var to := WorldManager.exit_target(ex)
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


func test_day_cycle() -> void:
	GameState.new_game()
	check(WorldClock.phase(0.0) == "morning", "jogo começa de manhã")
	check(WorldClock.phase(WorldClock.DAY_LENGTH * 0.3) == "day", "meio da manhã vira dia")
	check(WorldClock.phase(WorldClock.DAY_LENGTH * 0.6) == "evening", "fim da tarde")
	check(WorldClock.phase(WorldClock.DAY_LENGTH * 0.9) == "night", "noite")
	check(WorldClock.is_night(WorldClock.DAY_LENGTH * 0.9), "is_night na noite")
	check(Conditions.check({"day_phase": "morning"}), "condição day_phase manhã")
	GameState.play_time = WorldClock.DAY_LENGTH * 0.9
	WorldClock.sync_flag()
	check(String(GameState.get_flag("day_phase", "")) == "night", "flag day_phase sincroniza")
	check(Conditions.check({"day_phase": "night"}) and not Conditions.check({"day_phase": "day"}), "condição day_phase noite")
	check(not ConditionSchema.validate({"day_phase": "madrugada"}, "t").is_empty(), "fase inválida é recusada")
	GameState.set_flag("prologue_seen", true)
	var game: Node = await _start_game()
	for n in game.find_children("*", "NPC", true, false):
		n.process_mode = Node.PROCESS_MODE_DISABLED
	await r._close_cards(game.get_node("HUD"))
	check(game.map.lighting_tint() == WorldClock.tint(), "aldeia usa tinta do ciclo")
	GameState.play_time = WorldClock.DAY_LENGTH * 0.9
	WorldClock.sync_flag()
	await wait(4)
	check(game.map.lighting.color.is_equal_approx(WorldClock.TINTS.night), "noite escurece a aldeia")
	var lit := 0
	for n in game.map.find_children("*", "PointLight2D", true, false):
		if n.name == "NightLight" and n.enabled:
			lit += 1
	check(lit >= 1, "fogueira acende luz à noite (%d)" % lit)
	check(WorldManager.travel("canaan_ezer_house", "from_village") == "", "entrar no interior")
	await _wait_travel(game)
	check(game.map.lighting_tint() == Color("#E8DCC8"), "interior ignora o ciclo (luz fixa)")
	game.queue_free()
	await wait(3)
	GameState.new_game()


func test_interiors() -> void:
	GameState.new_game()
	GameState.set_flag("prologue_seen", true)
	check(GameData.regions.has("canaan_ezer_house") and GameData.regions.has("canaan_tent"), "regiões de interior carregadas")
	check(ResourceLoader.exists("res://scenes/maps/canaan_ezer_house.tscn") and ResourceLoader.exists("res://scenes/maps/canaan_tent.tscn"), "mapas de interior existem")
	check(DialogueDatabase.valid_action({"travel": {"region": "canaan_ezer_house", "entry": "from_village"}}), "ação travel é válida")
	check(not DialogueDatabase.valid_action({"travel": {"region": "", "entry": "x"}}), "travel sem região é recusado")
	var travels := DialogueDatabase.referenced_travels(DialogueManager.db.dialogues.get("ezer_house_door", {}))
	check(travels.size() == 1 and String(travels[0].get("region", "")) == "canaan_ezer_house", "porta de Ezer pede viagem ao interior")
	var game: Node = await _start_game()
	for n in game.find_children("*", "NPC", true, false):
		n.process_mode = Node.PROCESS_MODE_DISABLED
	await r._close_cards(game.get_node("HUD"))
	var wired := false
	for it in game.map.find_children("*", "Interactable", true, false):
		if String(it.dialogue_id) == "ezer_house_door":
			wired = true
			break
	check(wired, "porta da casa de Ezer ligada no mapa da aldeia")
	check(WorldManager.travel("canaan_ezer_house", "from_village") == "", "entrar na casa de Ezer")
	await _wait_travel(game)
	check(game.map.region_id == "canaan_ezer_house", "mapa da casa de Ezer carregado")
	check(Discoveries.is_unlocked("pottery_jars"), "entrar na casa desbloqueia pottery_jars")
	check(WorldManager.travel("canaan_village", "from_ezer_house") == "", "sair da casa para a aldeia")
	await _wait_travel(game)
	check(game.map.region_id == "canaan_village" and _player().global_position.distance_to(Vector2(768, 232)) < 2.0, "volta perto da casa de Ezer")
	check(WorldManager.travel("canaan_tent", "from_village") == "", "entrar na tenda")
	await _wait_travel(game)
	check(game.map.region_id == "canaan_tent", "mapa da tenda carregado")
	_player().global_position = Vector2(128, 155)
	await wait(2)
	Input.action_press("move_down")
	await _wait_travel(game)
	Input.action_release("move_down")
	check(game.map.region_id == "canaan_village" and _player().global_position.distance_to(Vector2(200, 420)) < 24.0, "sair da tenda volta à aldeia")
	game.queue_free()
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
	test_market()


func test_market() -> void:
	check(Market.errors.is_empty(), "feira sem erros %s" % [Market.errors])
	check(not Market.sales.has("provisions_basket") and not Market.sales.has("plant_fiber"), "feira não compra item de missão nem material protegido")
	GameState.new_game()
	Inventory.add("wool_cloth", 3, "reward")
	check(Market.sell("wool_cloth") and Market.silver() == 7 and Inventory.count("wool_cloth") == 2, "venda troca item por prata")
	check(not Market.buy("walking_staff"), "compra exige prata suficiente")
	check(Market.sell("wool_cloth") and Market.buy("walking_staff"), "compra o cajado")
	check(Market.owned("walking_staff") and Market.equipped("staff") == "walking_staff" and Market.silver() == 4, "cajado comprado é equipado")
	check(not Market.buy("walking_staff") and Market.unequip("staff") and Market.equip("walking_staff"), "não recompra e permite reequipar")
	var saved := GameState.to_dict()
	var clean := SaveManager.sanitize_game_data(saved)
	GameState.new_game()
	GameState.from_dict(clean.data)
	check(Market.silver() == 4 and Market.equipped("staff") == "walking_staff", "prata e equipamento sobrevivem ao save")
	GameState.new_game()

	# Catálogo: mercadores, mercadorias renováveis e peças por espaço.
	check(Market.merchants.size() == 4 and ["yaron", "ozi", "nefer", "liora"].all(func(m): return Market.merchants.has(m)), "feira: quatro mercadores")
	for id in ["wool_tuft", "almonds", "flint_stone", "wild_herbs", "papyrus_stalks", "dates", "sea_shell"]:
		check(Inventory.item(id).get("category") == "trade" and Market.sales.has(id), "mercadoria %s existe e é vendável" % id)
	check(not Market.sales.has("clay_jar") and not Market.sales.has("barley_sheaf"), "feira não compra cântaro nem feixes de missão")
	for slot in Market.SLOTS:
		check(Market.order.any(func(g): return String(Market.goods[g].slot) == slot), "há peça para o espaço %s" % slot)

	# Vender tudo, restrição por mercador, equipar, velocidade e camadas.
	Inventory.add("wool_tuft", 5, "pickup")
	Inventory.add("dates", 2, "pickup")
	check(Market.sell_all("wool_tuft") == 5 and Inventory.count("wool_tuft") == 0 and Market.silver() == 5, "vender tudo: 5 tufos = 5 de prata")
	check(Market.sellable_entries().size() == 1 and Market.sellable_entries()[0].id == "dates", "lista de venda mostra só o que a feira compra")
	check(Market.sell_all("dates") == 4 and Market.sell_all("dates") == 0, "sem itens, vender tudo não rende nada")
	GameState.set_flag("market:silver", 200)
	check(not Market.goods_for("yaron").has("linen_tunic") and Market.goods_for("nefer").has("linen_tunic"), "túnica de linho só com Nefer")
	check(not Market.buy("linen_tunic", "yaron") and Market.buy("linen_tunic", "nefer"), "comprar exige um mercador que venda a peça")
	check(Market.goods_for("yaron").has("linen_tunic"), "peça já comprada aparece com qualquer mercador para usar")
	for mid in Market.merchants:
		check(Market.order.any(func(g): return mid in Market.goods[g].get("sold_by", [])) and String(Market.merchant(mid).get("specialty", "")) != "", "mercador %s tem estoque e especialidade próprios" % mid)
	check(Market.sells("liora", "shepherd_mantle") and not Market.sells("nefer", "shepherd_mantle") and Market.sells("ozi", "blue_tunic") and not Market.sells("yaron", "blue_tunic"), "estoques regionais: manto de pastor em Belém, túnica azul com as caravanas")
	check(Market.renew_seconds > 0.0, "mercadorias têm tempo para reaparecer")
	check(Market.speed_multiplier() == 1.0 and Market.companion().is_empty(), "sem transporte: velocidade normal")
	check(Market.buy("pack_donkey", "yaron") and is_equal_approx(Market.speed_multiplier(), 1.15), "jumento de carga: +15% de velocidade")
	check(String(Market.companion().get("sheet", "")).ends_with("donkey.png"), "jumento segue o viajante")
	check(Market.buy("riding_donkey", "ozi") and Market.equipped("transport") == "riding_donkey" and Market.owned("pack_donkey"), "comprar outro animal troca o equipado e mantém o antigo")
	check(Market.buy("head_band") and Market.buy("oak_staff", "liora"), "comprar faixa e bordão")
	check(Market.layer_paths() == ["res://assets/gear/linen_tunic.png", "res://assets/gear/oak_staff.png", "res://assets/gear/head_band.png"], "camadas na ordem roupa, cajado, cabeça %s" % [Market.layer_paths()])
	check(Market.layer_paths().all(func(p): return ResourceLoader.exists(p)), "camadas existem")
	GameState.set_flag("market:equipped:staff", "peca_inexistente")
	check(Market.equipped("staff") == "", "equipamento que o jogador não tem é ignorado")
	GameState.set_flag("market:silver", 5)
	check(not Market.buy("blue_tunic") and Market.silver() == 5, "compra recusada não gasta prata")
	check(DialogueDatabase.valid_action({"market": "ozi"}) and not DialogueDatabase.valid_action({"market": 3}), "ação de diálogo {market: id}")
	# Prata para ajudar e trocas item por item (sem abrir a feira).
	GameState.set_flag("market:silver", 0)
	check(not Market.spend(1) and Market.silver() == 0, "gastar prata exige saldo")
	GameState.set_flag("market:silver", 5)
	check(Market.spend(3) and Market.silver() == 2, "gastar prata baixa o saldo")
	check(Conditions.check({"has_silver": 2}) and not Conditions.check({"has_silver": 3}), "condição has_silver")
	check(ConditionSchema.validate({"has_silver": 3}, "t").is_empty(), "has_silver é condição válida")
	check(DialogueDatabase.validate_effects({"spend_silver": 0}, "t").size() == 1, "spend_silver inválido é rejeitado")
	GameState.new_game()
	Inventory.add("wool_tuft", 2, "pickup")
	Inventory.add("flint_stone", 1, "pickup")
	_talk("adina_talk", ["Trocar 2 tufos"])
	check(Inventory.count("wool_tuft") == 0 and Inventory.count("sheep_cheese") == 1, "Adina troca lã por queijo sem prata")
	_talk("ezer_talk", ["Trocar 1 sílex"])
	check(Inventory.count("flint_stone") == 0 and Inventory.count("barley_bread") == 1, "Ezer troca sílex por pão sem prata")
	GameState.set_flag("market:silver", 5)
	GameState.set_flag("heard_talia", true)
	GameState.set_flag("talia_needs_food", true)
	var talia := _talk("talia_talk", ["Deixar 3 de prata"])
	check(Market.silver() == 2 and GameState.get_flag("talia_helped") == true, "Talia aceita prata como ajuda")
	check(talia.any(func(t): return String(t).contains("Prata pesada")), "fala de agradecimento pela prata")
	check(Discoveries.is_unlocked("sharing_in_need"), "ajudar com prata desbloqueia compartilhar na necessidade")
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
			["custom", "wells_ari_well"], ["custom", "wells_jar_returned"], ["item_collected", "clay_jar"],
			["custom", "wells_trough_full"], ["custom", "wells_adina_thanks"], ["presentation_finished", "gen_026_wells"]]:
		QuestManager.record_event(e[0], e[1])


func test_quests_across_regions() -> void:
	GameState.new_game()
	check(WorldManager.experience_state("joseph_dothan") == "locked", "José em Dotã bloqueado antes dos poços")
	check(WorldManager.start_experience("joseph_dothan") != "", "experiência bloqueada não inicia")
	WorldManager.experiences["test_planned"] = {"id": "test_planned", "era": "judges", "title": "Teste em planejamento", "status": "planned", "references": ["Ruth 2:1-3"]}
	check(WorldManager.experience_state("test_planned") == "planned" and WorldManager.start_experience("test_planned") != "", "experiência em planejamento não é jogável")
	WorldManager.experiences.erase("test_planned")
	check(WorldManager.experience_state("ruth_bethlehem") == "locked" and WorldManager.start_experience("ruth_bethlehem") != "", "Rute em Belém bloqueada antes da travessia do mar")
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

	# Botões do HUD (mouse) seguem a mesma regra das teclas: nada abre por
	# cima de um diálogo nem durante a troca de região.
	var hud_buttons: Array = []
	for b in game.get_node("HUD").find_children("*", "Button", true, false):
		if String(b.text).begins_with("I bolsa") or String(b.text).begins_with("M mapa") or String(b.text).begins_with("J diário") or String(b.text).begins_with("C contexto"):
			hud_buttons.append(b)
	check(hud_buttons.size() == 4, "quatro botões de tela no HUD")
	DialogueManager.start("malik_talk")
	for b in hud_buttons:
		b.pressed.emit()
	await wait(2)
	check(not game.inventory_screen.is_open() and not game.scripture_map.is_open() and not game.journal.visible and not r.get_tree().paused,
		"botões do HUD não abrem telas durante um diálogo")
	while DialogueManager.is_active():
		if DialogueManager.current_choices().is_empty():
			DialogueManager.advance()
		else:
			DialogueManager.choose(DialogueManager.current_choices().size() - 1)
	await wait(3)
	await r._close_cards(game.get_node("HUD"))
	GameState.block_ui("travel")
	for b in hud_buttons:
		b.pressed.emit()
	await wait(2)
	check(not game.inventory_screen.is_open() and not game.scripture_map.is_open() and not game.journal.visible, "botões do HUD não abrem telas durante a viagem")
	GameState.unblock_ui("travel")
	var bag_btn: Button = hud_buttons.filter(func(b): return String(b.text).begins_with("I bolsa"))[0]
	bag_btn.pressed.emit()
	await wait(2)
	check(game.inventory_screen.is_open(), "com o jogo livre, o botão da bolsa abre a bolsa")
	game.inventory_screen.close()
	await wait(2)

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


## Mercador no mapa, coleta renovável, feira pela fala e aparência do viajante.
func test_market_in_game() -> void:
	GameState.new_game()
	GameState.set_flag("prologue_seen", true)
	GameState.set_flag("experience:joseph_dothan", true)
	WorldManager.travel("caravan_road", "from_canaan")
	var game: Node = await _start_game()
	await r._close_cards(game.get_node("HUD"))
	check(game.map.find_object("npc", "ozi") != null, "Ozi está no Caminho das Caravanas")
	var pk: Pickup = game.map.find_object("pickup", "tr_cr_flint_1")
	check(pk != null and pk.renewable, "sílex renovável no chão")
	if pk == null:
		game.queue_free()
		await wait(3)
		return
	check(pk.collect() == 1 and pk.collect() == 0, "coletar o renovável rende um item só por visita")
	await wait(3)
	var renew_key := WorldManager.renew_key("caravan_road", "tr_cr_flint_1")
	check(Inventory.count("flint_stone") == 1 and not GameState.world.has(WorldManager.world_key("caravan_road", "tr_cr_flint_1")), "renovável não fica marcado como coletado para sempre")
	check(float(GameState.world.get(renew_key, -1.0)) > GameState.play_time, "momento de volta do renovável fica no save")
	check(game.map.find_object("pickup", "tr_cr_flint_1") == null, "renovável some depois de coletado")
	WorldManager.travel("dothan", "from_caravan_road")
	await _wait_travel(game)
	WorldManager.travel("caravan_road", "from_dothan")
	await _wait_travel(game)
	check(game.map.find_object("pickup", "tr_cr_flint_1") == null, "voltar logo à região não traz o renovável de volta")
	GameState.play_time = float(GameState.world[renew_key]) + 1.0
	game.map._refresh_conditional()
	await wait(2)
	check(game.map.find_object("pickup", "tr_cr_flint_1") == null, "passado o tempo, não aparece no meio da mesma visita")
	WorldManager.travel("dothan", "from_caravan_road")
	await _wait_travel(game)
	WorldManager.travel("caravan_road", "from_dothan")
	await _wait_travel(game)
	pk = game.map.find_object("pickup", "tr_cr_flint_1")
	check(pk != null, "passado o tempo, voltar à região faz o renovável reaparecer")
	if pk:
		pk.collect()
	check(Inventory.count("flint_stone") == 2, "segunda visita rende mais um sílex")

	# Falar com Ozi e escolher "negociar" abre a feira dele.
	_talk("ozi_talk", ["negociar"])
	await wait(3)
	check(game.market_screen.is_open() and game.market_screen.merchant_id == "ozi" and r.get_tree().paused, "\"Quero negociar\" abre a feira de Ozi e pausa")
	check(game.market_screen.tab == "sell", "feira abre na aba Vender quando há o que vender")
	game.market_screen._sell("flint_stone", true)
	check(Market.silver() == 4 and Inventory.count("flint_stone") == 0, "vender tudo pela tela: 4 de prata")
	GameState.set_flag("market:silver", 100)
	game.market_screen.set_tab("buy")
	game.market_screen._buy("pack_donkey")
	game.market_screen._buy("walking_staff")
	game.market_screen._buy("travel_cloak")
	check(Market.equipped("transport") == "pack_donkey" and Market.equipped("staff") == "walking_staff", "comprar pela tela equipa")
	r._press("pause")
	await wait(3)
	check(not game.market_screen.is_open() and not r.get_tree().paused and not game.get_node("PauseMenu").visible, "Esc fecha a feira sem abrir a pausa")
	await wait(3)
	var p := _player()
	check(p.gear.layers.size() == 2 and p.gear.layers.all(func(l): return l.hframes == p.sprite.hframes and l.offset == p.sprite.offset), "duas camadas sobre o viajante, alinhadas à folha")
	check(r.get_tree().get_nodes_in_group("gear_companion").size() == 1, "jumento acompanha o viajante")
	check(is_equal_approx(p.speed_multiplier(), 1.15), "viajante anda mais rápido com o jumento")
	await _walk("move_left", 20)
	check(p.gear.layers.all(func(l): return l.frame == p.sprite.frame), "camadas acompanham o quadro da animação")
	check(game.map.region_id == "caravan_road", "ainda no Caminho das Caravanas")
	var donkey: Node2D = r.get_tree().get_first_node_in_group("gear_companion")
	GameState.block_ui(SceneDirector.BLOCKER)
	await wait(2)
	check(donkey != null and not donkey.visible, "jumento some durante a cena dirigida")
	GameState.unblock_ui(SceneDirector.BLOCKER)
	await wait(2)
	check(donkey != null and donkey.visible and donkey.global_position.distance_to(p.global_position) < 40.0, "jumento volta atrás do viajante depois da cena")
	Market.unequip("transport")
	await wait(3)
	check(r.get_tree().get_nodes_in_group("gear_companion").is_empty() and p.speed_multiplier() == 1.0, "tirar o jumento: some e a velocidade volta")
	Market.equip("pack_donkey")

	# Save e load: prata, posse e equipamento; renováveis voltam.
	check(GameState.save_game() == OK, "salvar com equipamento")
	game.queue_free()
	await wait(3)
	GameState.new_game()
	check(GameState.load_game() == "", "carregar o save")
	var game2: Node = await _start_game()
	await wait(3)
	check(Market.owned("travel_cloak") and Market.equipped("transport") == "pack_donkey" and Market.silver() == 52, "prata e equipamento preservados (%d)" % Market.silver())
	check(_player().gear.layers.size() == 2 and r.get_tree().get_nodes_in_group("gear_companion").size() == 1, "aparência restaurada ao carregar")
	check(game2.map.find_object("pickup", "tr_cr_flint_1") == null, "renovável coletado continua esperando depois de carregar")
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
