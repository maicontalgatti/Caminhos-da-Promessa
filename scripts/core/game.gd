extends Node
## Cena de jogo: carrega o mapa atual do GameState e hospeda a UI de jogo
## (HUD, diálogos, diário, cenas guiadas e, só em builds de debug, o painel F3).

const PROLOGUE_ID := "new_game"
const DEBUG_PANEL := "res://scripts/ui/debug_panel.gd"

@onready var map_container: Node2D = $MapContainer
@onready var hud = $HUD
@onready var journal = $Journal
@onready var cinematic = $Cinematic
@onready var pause_menu = $PauseMenu

var map: GameMap
var inventory_screen: InventoryScreen
var scripture_map: ScriptureMap
var _replaying_prologue := false
var _traveling := false


func _ready() -> void:
	_load_map(GameState.current_map)
	GameState.in_game = true
	if OS.is_debug_build() and ResourceLoader.exists(DEBUG_PANEL):
		var panel := CanvasLayer.new()
		panel.set_script(load(DEBUG_PANEL))
		panel.name = "DebugPanel"
		add_child(panel)

	inventory_screen = InventoryScreen.new()
	inventory_screen.name = "Inventory"
	add_child(inventory_screen)
	scripture_map = ScriptureMap.new()
	scripture_map.name = "ScriptureMap"
	add_child(scripture_map)
	hud.inventory_requested.connect(func(): inventory_screen.open())
	hud.scripture_map_requested.connect(func(): scripture_map.open())
	scripture_map.atlas_requested.connect(func(): journal.open("places", "place:" + String(QuestManager.get_context().get("place_id", ""))))
	hud.journal_requested.connect(func(tab, focus): journal.open(tab, focus))
	pause_menu.journal_requested.connect(func(): journal.open("journey"))
	pause_menu.prologue_requested.connect(replay_prologue)
	journal.presentation_requested.connect(play_presentation)
	cinematic.finished.connect(_on_cinematic_finished)
	DialogueManager.action_requested.connect(_on_dialogue_action)
	WorldManager.travel_requested.connect(_on_travel_requested)

	_enter_region()
	if not GameState.get_flag("prologue_seen") and GameData.prologues.has(PROLOGUE_ID):
		_play_prologue()
	else:
		QuestManager.evaluate()
		hud.show_identity(QuestManager.get_context())


func _exit_tree() -> void:
	GameState.in_game = false
	GameState.unblock_ui("travel")
	AudioManager.stop_ambience()
	if DialogueManager.action_requested.is_connected(_on_dialogue_action):
		DialogueManager.action_requested.disconnect(_on_dialogue_action)
	if WorldManager.travel_requested.is_connected(_on_travel_requested):
		WorldManager.travel_requested.disconnect(_on_travel_requested)


func _load_map(path: String) -> void:
	if not ResourceLoader.exists(path):
		push_warning("Game: mapa salvo \"%s\" não existe; usando o padrão" % path)
		path = GameState.DEFAULT_MAP
		GameState.player_position = Vector2.INF
		GameState.current_region = ""
	map = (load(path) as PackedScene).instantiate()
	map_container.add_child(map)
	var guide := ObjectiveGuide.new()
	guide.name = "ObjectiveGuide"
	map.add_child(guide)


func is_traveling() -> bool:
	return _traveling


## Troca de região sem sair da cena de jogo: escurece, troca o mapa, mostra o
## título discreto da região e salva automaticamente ao chegar.
func _on_travel_requested(_region_id: String, _entry_id: String) -> void:
	if _traveling:
		return
	_traveling = true
	GameState.block_ui("travel")
	AudioManager.play("travel")
	await SceneRouter.fade_out()
	var old := map
	map_container.remove_child(old)
	old.queue_free()
	_load_map(GameState.current_map)
	_enter_region()
	await get_tree().physics_frame
	hud.refresh_context()
	hud.refresh_tracker()
	hud.show_region_banner(map.get_region())
	await SceneRouter.fade_in()
	GameState.unblock_ui("travel")
	_traveling = false
	QuestManager.evaluate()
	if GameState.in_game:
		GameState.save_game()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST and GameState.in_game:
		GameState.save_game()


func _enter_region() -> void:
	var region := map.get_region()
	var rid := String(map.region_id)
	QuestManager.current_region_id = rid
	AudioManager.set_region(rid, map)
	if rid == "":
		return
	if _traveling and not QuestManager.has_event("region_entered", rid):
		AudioManager.event("region_new")
	QuestManager.record_event("region_entered", rid)
	for d in region.get("context", {}).get("discoveries_on_enter", []):
		Discoveries.unlock(d)


func _play_prologue() -> void:
	hud.visible = false
	cinematic.play_prologue(GameData.prologues[PROLOGUE_ID], map)


func replay_prologue() -> void:
	if cinematic.is_playing() or not GameData.prologues.has(PROLOGUE_ID):
		return
	_replaying_prologue = true
	_play_prologue()


func play_presentation(id: String) -> void:
	var pres := Bible.presentation(id)
	if pres.is_empty() or cinematic.is_playing():
		return
	hud.visible = false
	cinematic.play_presentation(pres)


func _on_dialogue_action(action: Dictionary) -> void:
	if action.has("presentation"):
		play_presentation(String(action.presentation))


func _on_cinematic_finished(kind: String, id: String, skipped: bool) -> void:
	hud.visible = true
	match kind:
		"prologue":
			if not _replaying_prologue:
				GameState.set_flag("prologue_seen", true)
				QuestManager.record_event("prologue_finished", id)
			_replaying_prologue = false
			hud.refresh_context()
		"presentation":
			# Fechar antes do fim não conta como leitura; o objetivo continua aberto.
			if skipped or QuestManager.has_event("presentation_finished", id):
				return
			GameState.add_log("presentation", id)
			for d in Bible.presentation(id).get("unlock", []):
				Discoveries.unlock(d)
			QuestManager.record_event("presentation_finished", id)
