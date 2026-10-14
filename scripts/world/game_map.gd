class_name GameMap
extends Node2D
## Base de todo mapa explorável. Posiciona o jogador (entrada nomeada, save
## ou spawn), limita a câmera ao tamanho do mapa e monta, a partir dos dados
## da região (data/regions), as saídas, áreas, NPCs, objetos examináveis e
## itens no chão. Assim um mapa novo não exige script próprio.

const NPC_SCENE := "res://scenes/npcs/npc.tscn"
const ENV_SCENE := "res://scenes/environments/%s.tscn"
const SPAWN_CLEARANCE := Rect2(-5, -6, 10, 7)

@export var region_id: String = ""
@export var map_size_tiles := Vector2i(60, 40)
@export var tile_size := 16

var _runtime: Node2D
var _world: Node2D
## [[TileMapLayer, superfície], ...] de cima para baixo (passos).
var _surface_layers: Array = []
## id do objeto condicional -> nó instanciado (ou null quando a condição não vale)
var _conditional: Dictionary = {}


func _ready() -> void:
	add_to_group("game_map")
	var player := get_tree().get_first_node_in_group("player") as Player
	if player == null:
		push_error("GameMap: nenhum Player no mapa")
		return
	_world = get_node_or_null("World") as Node2D
	if _world == null:
		_world = self
	if region_id != "":
		GameState.current_region = region_id
	var entry := WorldManager.entry_point(region_id, GameState.entry_id) if GameState.entry_id != "" else {}
	var restored := false
	if not entry.is_empty():
		player.global_position = entry.position
		player.face(entry.facing)
	elif GameState.player_position.is_finite() and GameState.current_map == scene_file_path:
		player.global_position = GameState.player_position
		player.face(GameState.player_facing)
		restored = true
	else:
		player.global_position = default_spawn()
	GameState.entry_id = ""
	if scene_file_path != "":
		GameState.current_map = scene_file_path
	var cam := player.camera
	cam.limit_left = 0
	cam.limit_top = 0
	cam.limit_right = map_size_tiles.x * tile_size
	cam.limit_bottom = map_size_tiles.y * tile_size
	cam.reset_smoothing()
	_build_runtime()
	GameState.flag_changed.connect(_on_state_changed)
	Inventory.changed.connect(_on_state_changed)
	if restored:
		_ensure_valid_position.call_deferred(player)


func _exit_tree() -> void:
	if GameState.flag_changed.is_connected(_on_state_changed):
		GameState.flag_changed.disconnect(_on_state_changed)
	if Inventory.changed.is_connected(_on_state_changed):
		Inventory.changed.disconnect(_on_state_changed)


func get_region() -> Dictionary:
	return GameData.get_region(region_id)


## Superfície sob uma posição global, pela primeira camada de tiles (de cima
## para baixo) que tem tile ali. A região pode declarar "surface_layers";
## senão vale data/audio/sfx.json. Consultado só a cada passo.
func surface_at(pos: Vector2) -> String:
	if _surface_layers.is_empty():
		var defs: Array = get_region().get("surface_layers", AudioManager.surfaces.get("layers", []))
		for d in defs:
			var layer := get_node_or_null(String(d[0])) as TileMapLayer
			if layer:
				_surface_layers.append([layer, String(d[1])])
		if _surface_layers.is_empty():
			_surface_layers.append([null, ""])
	for entry in _surface_layers:
		var layer := entry[0] as TileMapLayer
		if layer and layer.get_cell_source_id(layer.local_to_map(layer.to_local(pos))) != -1:
			return String(entry[1])
	return String(AudioManager.surfaces.get("default", "dirt"))


func default_spawn() -> Vector2:
	var e := WorldManager.entry_point(region_id, "default")
	if not e.is_empty():
		return e.position
	var spawn := get_node_or_null("World/PlayerSpawn") as Node2D
	return spawn.global_position if spawn else Vector2(map_size_tiles * tile_size) / 2.0


## Posição salva dentro de uma parede (mapa alterado entre versões, por
## exemplo) leva o jogador ao ponto de entrada padrão.
func _ensure_valid_position(player: Player) -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	if not is_instance_valid(player):
		return
	if not is_position_free(player.global_position):
		push_warning("GameMap: posição salva bloqueada em %s; usando a entrada padrão" % player.global_position)
		player.global_position = default_spawn()


func is_position_free(pos: Vector2) -> bool:
	var space := get_world_2d().direct_space_state
	var q := PhysicsShapeQueryParameters2D.new()
	var shape := RectangleShape2D.new()
	shape.size = SPAWN_CLEARANCE.size
	q.shape = shape
	q.transform = Transform2D(0.0, pos + SPAWN_CLEARANCE.get_center())
	q.collision_mask = 1
	var outside := pos.x < 0 or pos.y < 0 or pos.x > map_size_tiles.x * tile_size or pos.y > map_size_tiles.y * tile_size
	return not outside and space.intersect_shape(q, 1).is_empty()


# --- Objetos definidos pela região -------------------------------------------

func _build_runtime() -> void:
	_runtime = Node2D.new()
	_runtime.name = "Runtime"
	add_child(_runtime)
	var r := get_region()
	for ex in r.get("exits", []):
		var node := MapExit.new()
		node.setup(region_id, ex)
		_runtime.add_child(node)
	for a in r.get("areas", []):
		var area := MapArea.new()
		area.setup(region_id, a)
		_runtime.add_child(area)
	_refresh_conditional()


func _spawn_defs() -> Array:
	var out: Array = []
	var r := get_region()
	for kind in ["npcs", "examinables", "pickups"]:
		for d in r.get(kind, []):
			out.append({"kind": kind, "def": d})
	return out


## Cria ou remove NPCs, examináveis e itens conforme as condições (visible_if)
## e o estado salvo (itens já coletados não voltam).
func _refresh_conditional() -> void:
	for s in _spawn_defs():
		var d: Dictionary = s.def
		var key := "%s:%s" % [s.kind, d.get("id", "")]
		var want := Conditions.check(d.get("visible_if"))
		if s.kind == "pickups" and WorldManager.is_picked(region_id, String(d.id)):
			want = false
		var cur: Variant = _conditional.get(key)
		var alive: bool = cur != null and is_instance_valid(cur) and not (cur as Node).is_queued_for_deletion()
		if want and not alive:
			_conditional[key] = _spawn(String(s.kind), d)
		elif not want and alive:
			(cur as Node).queue_free()
			_conditional[key] = null


func _spawn(kind: String, d: Dictionary) -> Node2D:
	var pos := Vector2(float(d.x), float(d.y))
	match kind:
		"npcs":
			var npc: Node2D = load(NPC_SCENE).instantiate()
			npc.name = String(d.id).to_pascal_case()
			npc.position = pos
			npc.set("character_id", String(d.get("character", d.id)))
			_world.add_child(npc)
			return npc
		"pickups":
			var p := Pickup.new()
			p.setup(region_id, d)
			p.position = pos
			_world.add_child(p)
			return p
		_:
			return _spawn_examinable(d, pos)


func _spawn_examinable(d: Dictionary, pos: Vector2) -> Node2D:
	var root: Node2D
	var prop := String(d.get("prop", ""))
	if prop != "" and ResourceLoader.exists(ENV_SCENE % prop):
		root = load(ENV_SCENE % prop).instantiate()
		for old in root.find_children("*", "Interactable", true, false):
			old.get_parent().remove_child(old)
			old.free()
	else:
		root = Node2D.new()
	root.name = "Ex_" + String(d.id).to_pascal_case()
	root.position = pos
	var it := Interactable.new()
	it.name = "Interactable"
	it.kind = Interactable.Kind.READ if d.get("kind") == "read" else Interactable.Kind.EXAMINE
	it.dialogue_id = String(d.get("dialogue", ""))
	it.prompt_text = String(d.get("prompt", ""))
	var center := Vector2(0, float(d.get("center_y", -4)))
	it.position = center
	it.prompt_offset = Vector2(0, float(d.get("prompt_y", -18))) - center
	var cs := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = float(d.get("radius", 12))
	cs.shape = circle
	it.add_child(cs)
	root.add_child(it)
	if d.get("marker", "") == "sparkle":
		root.add_child(Pickup.sparkle())
	_world.add_child(root)
	return root


## Objeto criado a partir dos dados da região, por tipo de alvo de missão
## (npc, examinable, pickup, area, exit). null se não existe ou já sumiu.
func find_object(type: String, id: String) -> Node2D:
	var node: Variant = null
	match type:
		"npc": node = _conditional.get("npcs:" + id)
		"examinable": node = _conditional.get("examinables:" + id)
		"pickup": node = _conditional.get("pickups:" + id)
		"area": node = _runtime.get_node_or_null("Area_" + id.to_pascal_case()) if _runtime else null
		"exit": node = _runtime.get_node_or_null("Exit_" + id.to_pascal_case()) if _runtime else null
	if node == null or not is_instance_valid(node) or (node as Node).is_queued_for_deletion():
		return null
	return node as Node2D


func _on_state_changed(_a: Variant = null, _b: Variant = null) -> void:
	_refresh_conditional.call_deferred()
