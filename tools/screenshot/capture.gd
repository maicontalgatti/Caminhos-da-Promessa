extends Node
## Abre o jogo com renderização real e salva capturas em docs/images/.
## Não roda em --headless (precisa de GPU/janela):
##   godot --path . res://tools/screenshot/capture.tscn

const OUT := "res://docs/images/"

var game: Node
var player: Player


func _ready() -> void:
	SaveManager.save_path = "user://screenshot_save.json"
	var edu_before := Settings.edu_notifications
	Settings.edu_notifications = "full"
	await _settle(10)

	var menu: Node = load("res://scenes/ui/main_menu.tscn").instantiate()
	add_child(menu)
	await _settle(20)
	_shot("menu.png")
	menu.queue_free()

	GameState.new_game()
	game = load("res://scenes/core/game.tscn").instantiate()
	add_child(game)
	var cine = game.get_node("Cinematic")
	await _settle(150)
	_shot("prologue_title.png")
	cine._next()
	await _settle(180)
	_shot("prologue_place.png")
	cine._next()
	cine._next()
	await _settle(150)
	_shot("prologue_text_ref.png")
	cine._next()
	cine._next()
	await _settle(150)
	_shot("prologue_objective.png")
	cine._next()
	await _settle(40)

	player = get_tree().get_first_node_in_group("player") as Player
	var hud = game.get_node("HUD")
	await _settle(200)
	_shot("hud_context_objective.png")
	QuestManager.request_hint()
	QuestManager.request_hint()
	await _settle(20)
	_shot("hud_hints.png")
	_goto(Vector2(470, 400))
	await _settle(40)
	_shot("objective_marker.png")

	_goto(Vector2(540, 470))
	DialogueManager.start("adina_talk")
	await _settle(30)
	while DialogueManager.is_active() and DialogueManager.current_choices().is_empty():
		DialogueManager.advance()
		await _settle(60)
	_shot("dialogue_adina_water.png")
	DialogueManager.choose(2)
	DialogueManager.advance()
	await _settle(60)
	_shot("discovery_card.png")
	hud._close_card()
	await _settle(30)

	Discoveries.unlock("bread_ovens")
	await _settle(30)
	_shot("discovery_toast.png")

	var journal = game.get_node("Journal")
	journal.open("scriptures", "disc:shepherding_water")
	await _settle(20)
	_shot("journal_scriptures.png")
	journal.show_tab("journey")
	await _settle(10)
	_shot("journal_journey.png")
	journal.show_tab("characters", "char:adina")
	await _settle(10)
	_shot("journal_characters.png")
	journal.show_tab("timeline", "era:patriarchs")
	await _settle(10)
	_shot("journal_timeline.png")
	journal.show_tab("scriptures", "book:Gen")
	await _settle(10)
	_shot("journal_scripture_text.png")
	journal.close()
	await _settle(10)

	DialogueManager.start("yaron_talk")
	while DialogueManager.is_active() and DialogueManager.current_choices().is_empty():
		DialogueManager.advance()
	DialogueManager.choose(0)
	DialogueManager.advance()
	DialogueManager.advance()
	await _settle(480)
	_shot("dialogue_scripture.png")
	var g3 := 0
	while DialogueManager.is_active() and g3 < 10:
		if not DialogueManager.current_choices().is_empty():
			DialogueManager.choose(2)
		else:
			DialogueManager.advance()
		g3 += 1
	await _settle(10)

	QuestManager.record_event("dialogue_finished", "well_examine")
	QuestManager.record_event("custom", "wells_ari_well")
	QuestManager.record_event("custom", "wells_ezer_disputes")
	await _settle(10)
	while hud.has_pending_popups():
		if hud._card_open:
			hud._close_card()
		await _settle(10)
	game.play_presentation("gen_026_wells")
	await _settle(30)
	cine._next()
	cine._next()
	await _settle(40)
	_shot("presentation_slide.png")
	for i in 10:
		if cine.is_playing():
			cine._next()
	await _settle(60)
	var guard := 0
	while not (hud._card_open and String(hud._card_focus).begins_with("quest:")) and guard < 30:
		if hud._card_open:
			hud._close_card()
		await _settle(10)
		guard += 1
	await _settle(20)
	_shot("completion_card.png")
	hud._close_card()
	Settings.hud_context_collapsed = true
	hud.refresh_context()
	await _settle(30)
	_shot("hud_collapsed_free.png")
	Settings.hud_context_collapsed = false
	Settings.edu_notifications = edu_before

	if game.has_node("DebugPanel"):
		var dbg = game.get_node("DebugPanel")
		dbg._root.visible = true
		dbg._refresh()
		await _settle(10)
		_shot("debug_panel.png")

	SaveManager.delete_save()
	get_tree().quit()


func _goto(pos: Vector2) -> void:
	player.global_position = pos
	player.camera.reset_smoothing()


## Espera em tempo real (as animações usam tempo, não quadros).
func _settle(frames: int) -> void:
	await get_tree().create_timer(frames / 60.0).timeout
	await get_tree().process_frame


func _shot(file: String) -> void:
	var img := get_viewport().get_texture().get_image()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	img.save_png(OUT + file)
	print("captura: ", file, " ", img.get_size())
