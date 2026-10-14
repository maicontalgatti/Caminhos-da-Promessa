extends Node
## Mundo com múltiplas regiões. Cada região (data/regions) declara seu mapa,
## pontos de entrada, saídas (com condições), áreas, NPCs, objetos examináveis
## e itens no chão. Este nó resolve viagens, rotas e o "Mapa das Escrituras"
## (experiências por época, em data/world/experiences.json).
##
## A troca visual do mapa é feita pela cena de jogo (sinal travel_requested);
## o estado (região, entrada) é atualizado aqui, então funciona também sem tela.

signal travel_requested(region_id: String, entry_id: String)
signal experience_started(experience_id: String)

const EXPERIENCES_DIR := "res://data/world"
const FACINGS := {"down": Vector2.DOWN, "up": Vector2.UP, "left": Vector2.LEFT, "right": Vector2.RIGHT}

var experiences: Dictionary = {}
var experience_order: Array[String] = []
var eras_order: Array = []
var errors := PackedStringArray()


func _ready() -> void:
	reload()


func reload() -> void:
	experiences.clear()
	experience_order.clear()
	errors.clear()
	for e in JsonUtil.read_collection(EXPERIENCES_DIR, "experiences", errors):
		experiences[e.id] = e
		experience_order.append(String(e.id))
	eras_order = []
	for e in JsonUtil.read_collection(EXPERIENCES_DIR, "eras", errors):
		eras_order.append(e)
	for e in errors:
		push_error("WorldManager: " + e)


# --- Regiões -----------------------------------------------------------------

func region(id: String) -> Dictionary:
	return GameData.get_region(id)


func current_region_id() -> String:
	if GameState.current_region != "":
		return GameState.current_region
	return region_for_map(GameState.current_map)


func region_for_map(path: String) -> String:
	for id in GameData.regions:
		if String(GameData.regions[id].get("map_scene", "")) == path:
			return id
	return ""


## {position: Vector2, facing: Vector2} do ponto de entrada; {} se não existir.
func entry_point(region_id: String, entry_id: String) -> Dictionary:
	var e: Variant = region(region_id).get("entries", {}).get(entry_id)
	if not (e is Dictionary):
		return {}
	return {"position": Vector2(float(e.x), float(e.y)), "facing": FACINGS.get(String(e.get("facing", "down")), Vector2.DOWN)}


func exits(region_id: String) -> Array:
	return region(region_id).get("exits", [])


func find_exit(region_id: String, exit_id: String) -> Dictionary:
	for ex in exits(region_id):
		if String(ex.get("id", "")) == exit_id:
			return ex
	return {}


func is_exit_open(ex: Dictionary) -> bool:
	return Conditions.check(ex.get("requires"))


func is_region_unlocked(region_id: String) -> bool:
	return GameState.get_flag("region_unlocked:" + region_id) == true


## Primeira saída do caminho mais curto entre duas regiões (busca em largura).
func route_exit(from_id: String, to_id: String) -> Dictionary:
	if from_id == to_id or from_id == "" or to_id == "":
		return {}
	var first := {}
	var seen := {from_id: true}
	var queue: Array = [from_id]
	while not queue.is_empty():
		var cur: String = queue.pop_front()
		for ex in exits(cur):
			var nxt := String(ex.get("to", ""))
			if nxt == "" or seen.has(nxt):
				continue
			seen[nxt] = true
			first[nxt] = ex if cur == from_id else first[cur]
			if nxt == to_id:
				return first[nxt]
			queue.append(nxt)
	return {}


## Viaja para uma região por um ponto de entrada nomeado. Retorna "" ou o erro.
func travel(region_id: String, entry_id: String) -> String:
	var r := region(region_id)
	if r.is_empty():
		return "região inexistente: %s" % region_id
	var scene := String(r.get("map_scene", ""))
	if not ResourceLoader.exists(scene):
		return "mapa inexistente: %s" % scene
	if entry_point(region_id, entry_id).is_empty():
		return "entrada inexistente: %s/%s" % [region_id, entry_id]
	if not is_region_unlocked(region_id):
		GameState.set_flag("region_unlocked:" + region_id, true)
		QuestManager.record_event("region_unlocked", region_id)
	GameState.current_region = region_id
	GameState.current_map = scene
	GameState.entry_id = entry_id
	GameState.player_position = Vector2.INF
	GameState.add_log("travel", region_id)
	travel_requested.emit(region_id, entry_id)
	return ""


# --- Estado persistente de objetos -------------------------------------------

func world_key(region_id: String, object_id: String) -> String:
	return "%s/%s" % [region_id, object_id]


func is_picked(region_id: String, object_id: String) -> bool:
	return GameState.world.get(world_key(region_id, object_id), false) == true


func mark_picked(region_id: String, object_id: String) -> void:
	GameState.world[world_key(region_id, object_id)] = true


# --- Mapa das Escrituras ------------------------------------------------------

func experience(id: String) -> Dictionary:
	return experiences.get(id, {})


## "planned" (em planejamento, não jogável), "locked", "available", "active" ou "completed".
func experience_state(id: String) -> String:
	var e := experience(id)
	if e.is_empty() or String(e.get("status", "")) == "planned":
		return "planned"
	var done_quest := String(e.get("completed_by", ""))
	if done_quest != "" and QuestManager.status(done_quest) == "completed":
		return "completed"
	if GameState.get_flag("experience:" + id) == true:
		return "active"
	if e.get("active_with_quest", false) and done_quest != "" and QuestManager.status(done_quest) == "active":
		return "active"
	return "available" if Conditions.check(e.get("requires")) else "locked"


## Inicia uma experiência disponível: registra o evento e, se ela define um
## destino, leva o jogador até lá. Retorna "" ou o motivo da recusa.
func start_experience(id: String) -> String:
	var state := experience_state(id)
	if state == "planned":
		return "Esta experiência ainda está em planejamento."
	if state == "locked":
		return String(experience(id).get("locked_text", "Ainda não disponível."))
	var e := experience(id)
	if GameState.get_flag("experience:" + id) != true:
		GameState.set_flag("experience:" + id, true)
		GameState.add_log("experience", id)
		QuestManager.record_event("experience_started", id)
		experience_started.emit(id)
	var dest: Variant = e.get("travel")
	if dest is Dictionary and String(dest.get("region", "")) != current_region_id():
		return travel(String(dest.region), String(dest.get("entry", "default")))
	return ""
