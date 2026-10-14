extends Node
## Estado da partida em andamento: mapa atual, posição do jogador, flags,
## missões, descobertas e o registro de acontecimentos. É a única fonte de
## dados salvos; QuestManager e Discoveries só aplicam regras sobre ele.

signal flag_changed(flag: String, value: Variant)
## Emitido antes de salvar, para que o mundo grave sua posição/estado.
signal before_save
## Emitido após new_game() e load_game(), para a UI se atualizar.
signal state_replaced

const DEFAULT_MAP := "res://scenes/maps/canaan_village.tscn"
const LOG_LIMIT := 200

var current_map: String = DEFAULT_MAP
## Região (id estável de data/regions) do mapa atual; "" = deduzir do mapa.
var current_region: String = ""
## Ponto de entrada nomeado a usar no próximo carregamento de mapa ("" = posição salva ou spawn).
var entry_id: String = ""
## Vector2.INF significa "usar o ponto de spawn do mapa".
var player_position: Vector2 = Vector2.INF
var player_facing: Vector2 = Vector2.DOWN
var flags: Dictionary = {}
## id da missão -> {status, objective, hints: {objetivo: nível}, started, completed, objective_started}
var quests: Dictionary = {}
## id da descoberta -> tempo de jogo em que foi registrada
var discoveries: Dictionary = {}
## id do item -> quantidade (itens de missão ficam no compartimento à parte, mas no mesmo registro)
var inventory: Dictionary = {}
## Estado persistente de objetos do mundo por id estável ("região/objeto" -> valor), ex.: itens já coletados.
var world: Dictionary = {}
## id do colecionável -> tempo de jogo em que foi encontrado
var collectibles: Dictionary = {}
## Missão escolhida para acompanhar no HUD ("" = automática).
var tracked_quest: String = ""
## Acontecimentos presenciados: [{kind, id, t}]
var history: Array = []
var play_time: float = 0.0
var in_game := false

## Telas que bloqueiam o controle do jogador (prólogo, cartões, diário...).
var _ui_blockers: Dictionary = {}


func _process(delta: float) -> void:
	if in_game and not get_tree().paused:
		play_time += delta


func new_game() -> void:
	current_map = DEFAULT_MAP
	current_region = ""
	entry_id = ""
	player_position = Vector2.INF
	player_facing = Vector2.DOWN
	flags = {}
	quests = {}
	discoveries = {}
	inventory = {}
	world = {}
	collectibles = {}
	tracked_quest = ""
	history = []
	play_time = 0.0
	_ui_blockers.clear()
	state_replaced.emit()


func set_flag(flag: String, value: Variant = true) -> void:
	if flags.get(flag) == value:
		return
	flags[flag] = value
	flag_changed.emit(flag, value)


func get_flag(flag: String, default: Variant = false) -> Variant:
	return flags.get(flag, default)


func add_log(kind: String, id: String) -> void:
	history.append({"kind": kind, "id": id, "t": snappedf(play_time, 0.1)})
	if history.size() > LOG_LIMIT:
		history = history.slice(history.size() - LOG_LIMIT)


func block_ui(owner: String) -> void:
	_ui_blockers[owner] = true


func unblock_ui(owner: String) -> void:
	_ui_blockers.erase(owner)


func is_ui_blocked() -> bool:
	return not _ui_blockers.is_empty()


func to_dict() -> Dictionary:
	var pos: Variant = null
	if player_position.is_finite():
		pos = {"x": player_position.x, "y": player_position.y}
	return {
		"current_map": current_map,
		"current_region": current_region,
		"entry_id": entry_id,
		"player_position": pos,
		"player_facing": {"x": player_facing.x, "y": player_facing.y},
		"flags": flags.duplicate(true),
		"quests": quests.duplicate(true),
		"discoveries": discoveries.duplicate(true),
		"inventory": inventory.duplicate(true),
		"world": world.duplicate(true),
		"collectibles": collectibles.duplicate(true),
		"tracked_quest": tracked_quest,
		"log": history.duplicate(true),
		"play_time": play_time,
	}


## Espera dados já validados por SaveManager.sanitize_game_data().
func from_dict(d: Dictionary) -> void:
	current_map = d.current_map
	current_region = String(d.get("current_region", ""))
	entry_id = String(d.get("entry_id", ""))
	var pos: Variant = d.get("player_position")
	player_position = Vector2(pos.x, pos.y) if pos is Dictionary else Vector2.INF
	var f: Dictionary = d.get("player_facing", {"x": 0.0, "y": 1.0})
	player_facing = Vector2(f.x, f.y)
	flags = d.get("flags", {}).duplicate(true)
	quests = d.get("quests", {}).duplicate(true)
	discoveries = d.get("discoveries", {}).duplicate(true)
	inventory = d.get("inventory", {}).duplicate(true)
	world = d.get("world", {}).duplicate(true)
	collectibles = d.get("collectibles", {}).duplicate(true)
	tracked_quest = String(d.get("tracked_quest", ""))
	history = d.get("log", []).duplicate(true)
	play_time = float(d.get("play_time", 0.0))
	_ui_blockers.clear()
	state_replaced.emit()


func save_game() -> Error:
	before_save.emit()
	var err := SaveManager.save_data(to_dict())
	if err != OK:
		push_error("GameState: falha ao salvar (%s)" % error_string(err))
	return err


## Retorna "" em caso de sucesso ou a mensagem de erro.
func load_game() -> String:
	var result := SaveManager.load_data()
	if not result.ok:
		return result.error
	from_dict(result.data)
	return ""
