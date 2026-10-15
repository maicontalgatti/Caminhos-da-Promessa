extends SceneTree
## Gera mapas pequenos de interior (casa de Ezer, tenda da aldeia).
## Uso: godot --headless --path . --script res://tools/art_gen/build_interior.gd
##      godot --headless --path . --script res://tools/art_gen/build_interior.gd -- tent

const TILESET := "res://assets/tilesets/canaan_tileset.tres"
const PLAYER := "res://scenes/player/player.tscn"
const MAP_SCRIPT := "res://scripts/world/game_map.gd"
const T := 16

const SPECS := {
	"ezer": {
		"out": "res://scenes/maps/canaan_ezer_house.tscn",
		"name": "CanaanEzerHouse",
		"region_id": "canaan_ezer_house",
		"w": 20, "h": 14,
		"props": [
			["jar", Vector2(80, 96)], ["jar", Vector2(100, 100)],
			["pots", Vector2(220, 88)], ["basket", Vector2(160, 120)],
			["firewood", Vector2(200, 140)],
		],
		"spawn": Vector2(160, 180),
	},
	"tent": {
		"out": "res://scenes/maps/canaan_tent.tscn",
		"name": "CanaanTent",
		"region_id": "canaan_tent",
		"w": 16, "h": 12,
		"props": [
			["sacks", Vector2(80, 80)], ["basket", Vector2(140, 100)],
			["firewood", Vector2(180, 120)],
		],
		"spawn": Vector2(128, 140),
	},
}


func _initialize() -> void:
	if not ResourceLoader.exists(TILESET):
		push_error("build_interior: tileset ausente; rode generate_art + build_world primeiro")
		quit(1)
		return
	var args := OS.get_cmdline_user_args()
	var keys: Array = ["ezer", "tent"] if args.is_empty() else []
	for a in args:
		var k := a.trim_prefix("--").to_lower()
		if SPECS.has(k):
			keys.append(k)
	if keys.is_empty():
		push_error("build_interior: use ezer, tent ou sem args (os dois)")
		quit(1)
		return
	var ok := true
	for k in keys:
		if not _build(SPECS[k]):
			ok = false
	quit(0 if ok else 1)


func _build(spec: Dictionary) -> bool:
	var W: int = int(spec.w)
	var H: int = int(spec.h)
	var root := Node2D.new()
	root.name = String(spec.name)
	root.set_script(load(MAP_SCRIPT))
	root.set("region_id", String(spec.region_id))
	root.set("map_size_tiles", Vector2i(W, H))
	root.set("tile_size", T)

	var ground := TileMapLayer.new()
	ground.name = "Ground"
	ground.tile_set = load(TILESET)
	root.add_child(ground)
	var floors := TileMapLayer.new()
	floors.name = "Floors"
	floors.tile_set = load(TILESET)
	root.add_child(floors)

	for y in H:
		for x in W:
			ground.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
	for y in range(2, H - 2):
		for x in range(2, W - 2):
			floors.set_cell(Vector2i(x, y), 0, Vector2i(1, 0))

	var world := Node2D.new()
	world.name = "World"
	root.add_child(world)

	_wall(world, Rect2(0, 0, W * T, 2 * T))
	_wall(world, Rect2(0, 0, 2 * T, H * T))
	_wall(world, Rect2((W - 2) * T, 0, 2 * T, H * T))
	# Sul com abertura no meio (porta).
	var gap_x := int(W / 2) - 1
	_wall(world, Rect2(2 * T, (H - 2) * T, (gap_x - 2) * T, 2 * T))
	_wall(world, Rect2((gap_x + 2) * T, (H - 2) * T, (W - 2 - gap_x - 2) * T, 2 * T))

	for prop in spec.props:
		var path := "res://scenes/environments/%s.tscn" % prop[0]
		if ResourceLoader.exists(path):
			var n: Node2D = load(path).instantiate()
			n.position = prop[1]
			for it in n.find_children("*", "Interactable", true, false):
				it.get_parent().remove_child(it)
				it.free()
			world.add_child(n)

	var spawn_pos: Vector2 = spec.spawn
	var spawn := Marker2D.new()
	spawn.name = "PlayerSpawn"
	spawn.position = spawn_pos
	world.add_child(spawn)
	var player: Node = load(PLAYER).instantiate()
	player.name = "Player"
	player.position = spawn_pos
	world.add_child(player)

	var packed := PackedScene.new()
	_set_owner_recursive(root, root)
	packed.pack(root)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://scenes/maps"))
	var out := String(spec.out)
	var err := ResourceSaver.save(packed, out)
	print("build_interior: %s (%s)" % [out, error_string(err) if err != OK else "ok"])
	root.free()
	return err == OK


func _wall(parent: Node2D, rect: Rect2) -> void:
	if rect.size.x <= 0 or rect.size.y <= 0:
		return
	var body := StaticBody2D.new()
	body.position = rect.position
	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	cs.shape = shape
	cs.position = rect.size * 0.5
	body.add_child(cs)
	parent.add_child(body)


func _set_owner_recursive(node: Node, owner: Node) -> void:
	if node != owner:
		node.owner = owner
	for c in node.get_children():
		_set_owner_recursive(c, owner)
