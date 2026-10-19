extends Node
## Capturas das correções de playtest: casa de Ezer sem a roda abrindo sozinha,
## saída de tenda de volta ao Caminho, foice visível em Belém e Belém à noite
## depois da casa do menino (Tamir acordado + rastreador).
## Precisa de GPU/janela:
##   godot --path . res://tools/screenshot/capture_playtest_fixes.tscn [-- --out=pasta/]
## Saída padrão: docs/images/playtest_fixes_*.png.

const OUT := "res://docs/images/"
const SPEED := 3.0

var out := OUT
var game: Node
var hud: Node


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			out = a.trim_prefix("--out=")
	SaveManager.save_path = "user://screenshot_save_playtest.json"
	await _settle(10)
	GameState.new_game()
	GameState.set_flag("prologue_seen", true)
	QuestManager.record_event("prologue_finished", "new_game")
	game = load("res://scenes/core/game.tscn").instantiate()
	add_child(game)
	hud = game.get_node("HUD")
	await _settle(60)
	await _close_cards()

	# 1) Casa de Ezer: entrar não abre a roda; a tela é só o interior.
	await _travel("canaan_village", "default", Vector2.ZERO)
	await _travel("canaan_ezer_house", "from_village", Vector2.ZERO)
	var craft_open: bool = game.craft_screen.visible if game.craft_screen != null else false
	print("captura: roda aberta ao entrar na casa de Ezer = ", craft_open)
	_shot("playtest_fixes_ezer_house.png")

	# 2) Tenda do Caminho das Caravanas: decoração; sair do interior volta ao Caminho.
	await _travel("caravan_road", "default", Vector2(400, 300))
	_shot("playtest_fixes_tent_road.png")
	await _travel("canaan_tent", "from_village", Vector2.ZERO)
	await _travel("@return", "from_tent", Vector2.ZERO)
	print("captura: região depois de sair da tenda = ", WorldManager.current_region_id())
	_shot("playtest_fixes_tent_exit_returns.png")

	# 3) Belém, colheita: foice visível.
	QuestManager.start_quest("bethlehem_harvest_signs", true)
	await _travel("bethlehem_fields", "default", Vector2(232, 372))
	_shot("playtest_fixes_bethlehem_sickle.png")

	# 4) Belém à noite, depois da casa do menino.
	GameState.set_flag("bn_night", true)
	await _travel("bethlehem_night", "default", Vector2.ZERO)
	QuestManager.start_quest("shepherds_night", true)
	QuestManager.set_tracked("shepherds_night")
	var guard := 0
	while String(QuestManager.current_objective("shepherds_night").get("id", "")) != "follow_shepherds" and guard < 12:
		QuestManager.advance_objective("shepherds_night")
		guard += 1
	Engine.time_scale = SPEED
	if game.play_scene("shepherds_at_the_house"):
		guard = 0
		while game.scene_director.is_playing() and guard < 80:
			await get_tree().create_timer(2.0).timeout
			guard += 1
	Engine.time_scale = 1.0
	await _settle(30)
	await _close_cards()
	var player := get_tree().get_first_node_in_group("player") as Player
	if player != null:
		player.global_position = Vector2(330, 500)
		player.camera.reset_smoothing()
	await _settle(60)
	await _close_cards()
	print("captura: Tamir acordado existe = ", game.map.find_object("npc", "bn_tamir") != null)
	_shot("playtest_fixes_shepherds_after_house.png")

	SaveManager.delete_save()
	get_tree().quit()


func _travel(region: String, entry: String, pos: Vector2) -> void:
	WorldManager.travel(region, entry)
	await _settle(150)
	await _close_cards()
	# O banner da região leva ~4,8 s para sumir.
	await _settle(200)
	var player := get_tree().get_first_node_in_group("player") as Player
	if player != null and pos != Vector2.ZERO:
		player.global_position = pos
		player.camera.reset_smoothing()
	await _settle(30)


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
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out))
	var img := get_viewport().get_texture().get_image()
	img.save_png(out.path_join(file))
	print("captura: ", file, " ", img.get_size())
