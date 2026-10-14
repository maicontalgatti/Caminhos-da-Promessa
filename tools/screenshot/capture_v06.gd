extends Node
## Capturas da v0.6 (quatro experiências): mapas inteiros com a luz de cada
## estado, a visão de jogo em cada estado e quadros das cenas dirigidas.
## Precisa de GPU/janela:
##   godot --path . res://tools/screenshot/capture_v06.tscn [-- --out=pasta/]
## Saída padrão: docs/images/v06_*.png.

const OUT := "res://docs/images/"
## Intervalo (s de cena) entre quadros das cenas dirigidas e aceleração.
const SCENE_STEP := 6.0
const SPEED := 3.0

## Missão acompanhada no HUD em cada região (senão aparece a de Canaã do jogo novo).
const QUEST_OF := {
	"egypt_house": "joseph_potiphar_house",
	"sea_camp": "exodus_sea_crossing",
	"bethlehem_fields": "ruth_gleaning",
	"bethlehem_night": "shepherds_night",
}

## [região, entrada, flags, eventos [tipo, id], posição do jogador, nome].
const STATES := [
	["egypt_house", "default", [], [], Vector2(448, 330), "egypt_house"],
	["sea_camp", "arrival", [], [], Vector2(560, 860), "sea_camp_afternoon"],
	["sea_camp", "arrival", ["sea_chariots_seen"], [], Vector2(560, 860), "sea_camp_dusk"],
	["sea_camp", "arrival", ["sea_night"], [], Vector2(720, 700), "sea_camp_night"],
	["bethlehem_fields", "default", [], [], Vector2(600, 420), "bethlehem_fields"],
	["bethlehem_night", "default", [], [], Vector2(400, 480), "bethlehem_night_dusk"],
	["bethlehem_night", "default", ["bn_night"], [], Vector2(400, 480), "bethlehem_night_night"],
]

## [região, entrada, flags antes, cena, nome].
const SCENES := [
	["dothan", "default", [], "joseph_caravan_departs", "scene_caravan"],
	["sea_camp", "arrival", ["sea_chariots_seen", "sea_night"], "exodus_sea_crossing", "scene_sea"],
	["bethlehem_fields", "default", [], "ruth_gleaning_meal", "scene_ruth"],
	["bethlehem_night", "default", ["bn_night"], "shepherds_announcement", "scene_announcement"],
	["bethlehem_night", "default", ["bn_night"], "shepherds_at_the_house", "scene_house"],
]

var out := OUT
var game: Node
var hud: Node


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			out = a.trim_prefix("--out=")
	SaveManager.save_path = "user://screenshot_save_v06.json"
	await _settle(10)
	GameState.new_game()
	GameState.set_flag("prologue_seen", true)
	QuestManager.record_event("prologue_finished", "new_game")
	game = load("res://scenes/core/game.tscn").instantiate()
	add_child(game)
	hud = game.get_node("HUD")
	await _settle(60)
	await _close_cards()

	for s in STATES:
		await _state(s)
	# Amanhecer no mar: depois da travessia, na margem norte.
	QuestManager.record_event("scene_finished", "exodus_sea_crossing")
	await _state(["sea_camp", "far_shore_dawn", [], [], Vector2(512, 236), "sea_camp_dawn"])
	GameState.new_game()
	GameState.set_flag("prologue_seen", true)

	Engine.time_scale = SPEED
	for s in SCENES:
		await _scene(s)
	Engine.time_scale = 1.0

	SaveManager.delete_save()
	get_tree().quit()


func _state(s: Array) -> void:
	for f in s[2]:
		GameState.set_flag(String(f), true)
	for e in s[3]:
		QuestManager.record_event(String(e[0]), String(e[1]))
	await _travel(String(s[0]), String(s[1]), s[4])
	game.map.refresh_lighting(0.0)
	await _settle(20)
	_shot("v06_%s.png" % s[5])
	await _full_map(String(s[0]), "v06_map_%s.png" % s[5])


func _scene(s: Array) -> void:
	for f in s[2]:
		GameState.set_flag(String(f), true)
	await _travel(String(s[0]), String(s[1]), Vector2.ZERO)
	if not game.play_scene(String(s[3])):
		print("captura: cena %s não tocou" % s[3])
		return
	var n := 0
	while game.scene_director.is_playing() and n < 40:
		await get_tree().create_timer(SCENE_STEP).timeout
		if game.scene_director.is_playing():
			n += 1
			_shot("v06_%s_%02d.png" % [s[4], n])
	await _settle(30)
	await _close_cards()


func _travel(region: String, entry: String, pos: Vector2) -> void:
	WorldManager.travel(region, entry)
	await _settle(150)
	await _close_cards()
	var qid := String(QUEST_OF.get(region, ""))
	if qid != "":
		QuestManager.start_quest(qid, true)
		QuestManager.set_tracked(qid)
		await _close_cards()
	# O banner da região leva ~4,8 s para sumir.
	await _settle(200)
	var player := get_tree().get_first_node_in_group("player") as Player
	if player != null and pos != Vector2.ZERO:
		player.global_position = pos
		player.camera.reset_smoothing()
	await _settle(30)


## O mapa inteiro, com a luz e os NPCs do estado atual, num SubViewport.
func _full_map(region: String, file: String) -> void:
	var r: Dictionary = GameData.regions[region]
	var vp := SubViewport.new()
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	vp.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	add_child(vp)
	var map: GameMap = load(String(r.map_scene)).instantiate()
	vp.size = map.map_size_tiles * map.tile_size
	vp.add_child(map)
	for p in map.find_children("*", "Player", true, false):
		p.camera.enabled = false
	await _settle(12)
	_save(vp.get_texture().get_image(), file)
	vp.queue_free()
	await get_tree().process_frame


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
	_save(get_viewport().get_texture().get_image(), file)


func _save(img: Image, file: String) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out))
	img.save_png(out.path_join(file))
	print("captura: ", file, " ", img.get_size())
