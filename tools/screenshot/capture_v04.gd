extends Node
## Capturas das telas da v0.4 (regiões, bolsa, Mapa das Escrituras, escolhas,
## Minhas descobertas) em docs/images/v04_*.png. Precisa de GPU/janela:
##   godot --path . res://tools/screenshot/capture_v04.tscn

const OUT := "res://docs/images/"

var game: Node
var hud: Node


func _ready() -> void:
	SaveManager.save_path = "user://screenshot_save_v04.json"
	await _settle(10)
	GameState.new_game()
	GameState.set_flag("prologue_seen", true)
	for e in [["prologue_finished", "new_game"], ["custom", "wells_adina_water"], ["dialogue_finished", "well_examine"],
			["custom", "wells_ari_well"], ["custom", "wells_ezer_disputes"], ["presentation_finished", "gen_026_wells"]]:
		QuestManager.record_event(e[0], e[1])
	game = load("res://scenes/core/game.tscn").instantiate()
	add_child(game)
	hud = game.get_node("HUD")
	await _settle(60)
	await _close_cards()

	game.scripture_map.open()
	game.scripture_map.select("joseph_dothan")
	await _settle(20)
	_shot("v04_scripture_map.png")
	game.scripture_map._on_action()
	await _settle(20)
	_shot("v04_passage_card.png")
	game.scripture_map._confirm_passage()
	await _settle(20)

	WorldManager.travel("caravan_road", "from_canaan")
	await _settle(150)
	_shot("v04_region_banner.png")
	await _close_cards()
	var player := get_tree().get_first_node_in_group("player") as Player
	player.global_position = Vector2(120, 250)
	player.camera.reset_smoothing()
	await _settle(330)
	_shot("v04_pickup_prompt.png")
	Inventory.add("plant_fiber", 3, "pickup")
	Inventory.add("dry_wood", 2, "pickup")
	Inventory.add("barley_bread", 2, "reward")
	Inventory.add("provisions_basket", 1, "dialogue")
	game.inventory_screen.open()
	await _settle(20)
	_shot("v04_inventory.png")
	game.inventory_screen.close()
	Inventory.remove("provisions_basket", 1, "deliver")
	await _settle(10)

	player.global_position = Vector2(446, 256)
	player.camera.reset_smoothing()
	await _settle(30)
	DialogueManager.start("malik_talk")
	while DialogueManager.is_active() and DialogueManager.current_choices().is_empty():
		DialogueManager.advance()
	await _settle(60)
	_shot("v04_dialogue_malik.png")
	DialogueManager.choose(DialogueManager.current_choices().size() - 1)
	while DialogueManager.is_active():
		DialogueManager.advance()
	await _settle(20)
	await _close_cards()

	for c in ["cr_jar", "cr_marker", "cr_tracks"]:
		Collectibles.find(c)
	await _settle(20)
	await _close_cards()
	var journal = game.get_node("Journal")
	journal.open("journey")
	await _settle(20)
	_shot("v04_journal_categories.png")
	journal.show_tab("discoveries")
	await _settle(20)
	_shot("v04_my_discoveries.png")
	journal.close()

	WorldManager.travel("dothan", "from_caravan_road")
	await _settle(150)
	await _close_cards()
	player = get_tree().get_first_node_in_group("player") as Player
	player.global_position = Vector2(440, 180)
	player.camera.reset_smoothing()
	await _settle(30)
	_shot("v04_dothan.png")
	DialogueManager.start("rafi_talk")
	while DialogueManager.is_active():
		DialogueManager.advance()
	DialogueManager.start("talia_talk")
	while DialogueManager.is_active():
		DialogueManager.advance()
	DialogueManager.start("oren_talk")
	while DialogueManager.is_active():
		DialogueManager.advance()
	Inventory.add("water_skin", 1, "reward")
	await _close_cards()
	DialogueManager.start("oren_talk")
	while DialogueManager.is_active() and DialogueManager.current_choices().is_empty():
		DialogueManager.advance()
	await _settle(360)
	_shot("v04_families_choice.png")
	DialogueManager.choose(DialogueManager.current_choices().size() - 1)
	while DialogueManager.is_active():
		DialogueManager.advance()

	SaveManager.delete_save()
	get_tree().quit()


func _close_cards() -> void:
	var guard := 0
	while hud.has_pending_popups() and guard < 30:
		if hud._card_open:
			hud._close_card()
		await _settle(10)
		guard += 1


func _settle(frames: int) -> void:
	await get_tree().create_timer(frames / 60.0).timeout
	await get_tree().process_frame


func _shot(file: String) -> void:
	var img := get_viewport().get_texture().get_image()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	img.save_png(OUT + file)
	print("captura: ", file, " ", img.get_size())
