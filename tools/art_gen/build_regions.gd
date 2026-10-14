extends SceneTree
## Constrói os mapas das regiões novas (v0.4) com os mesmos tiles, autotile e
## objetos de cenário da aldeia. NÃO toca em canaan_village.tscn nem nos
## objetos existentes (scenes/environments); só cria os objetos novos listados
## em NEW_PROPS e os mapas de LAYOUTS.
##
## As posições de entradas, saídas, áreas, NPCs, examináveis e itens vêm de
## data/regions/<região>.json e ficam reservadas: nenhuma árvore ou pedra é
## gerada em cima delas. NPCs, examináveis e itens são montados em tempo de
## jogo pelo GameMap (podem depender de condições).
##
## Uso (depois de generate_art.gd e de `godot --headless --import`):
##   godot --headless --path . --script res://tools/art_gen/build_regions.gd [-- caravan_road dothan]

const Spec = preload("res://tools/art_gen/art_spec.gd")
const T := 16
const ENV_SCENE := "res://scenes/environments/%s.tscn"

## Objetos de cenário novos (mesmo formato de build_world.PROPS).
const NEW_PROPS := {
	"cistern": {"origin": Vector2(16, 19), "col": Rect2(-12, -10, 24, 9)},
}

## Colisão dos objetos existentes usados aqui (copiada de build_world.PROPS).
const PROP_COLS := {
	"tree_olive": Rect2(-5, -4, 10, 5), "tree_oak": Rect2(-4, -4, 8, 5), "bush": Rect2(-6, -3, 12, 4),
	"rock_big": Rect2(-8, -5, 16, 6), "rock_small": Rect2(-4, -3, 8, 4), "tent": Rect2(-22, -12, 44, 11),
	"firepit": Rect2(-6, -4, 12, 4), "sacks": Rect2(-7, -4, 14, 4), "basket": Rect2(-5, -3, 10, 3),
	"jar": Rect2(-3, -3, 6, 3), "firewood": Rect2(-7, -3, 14, 3), "fence_h": Rect2(-8, -5, 16, 4),
	"fence_v": Rect2(-2, -16, 4, 16), "cistern": Rect2(-12, -10, 24, 9), "boundary_stone": Rect2(-4, -4, 8, 4),
}

const LAYOUTS := {
	"caravan_road": {
		"scene": "res://scenes/maps/caravan_road.tscn", "node": "CaravanRoad", "size": [64, 34], "seed": 3101,
		"paths": [[0, 16, 21, 17], [20, 12, 21, 17], [20, 12, 44, 13], [43, 12, 44, 19], [43, 18, 63, 19]],
		"dry_threshold": 0.15, "edge_trees": 0.5, "scatter": 70, "flowers": 0.06,
		"props": [["tent", 400, 262], ["firepit", 452, 268], ["sacks", 362, 262], ["basket", 374, 274],
			["jar", 432, 274], ["firewood", 470, 252],
			["rock_big", 480, 150], ["rock_big", 506, 158], ["rock_small", 528, 146], ["rock_big", 610, 120],
			["rock_small", 300, 330], ["rock_big", 820, 210], ["rock_small", 840, 222]],
		"free_trees": [[90, 200], [160, 360], [260, 120], [540, 300], [620, 280], [760, 120], [900, 400], [960, 200], [700, 420], [380, 400]],
		"fences": [],
		"tint": Color(1.0, 0.97, 0.9),
	},
	"dothan": {
		"scene": "res://scenes/maps/dothan.tscn", "node": "Dothan", "size": [64, 40], "seed": 3202,
		"paths": [[0, 18, 24, 19], [23, 8, 24, 19], [12, 7, 36, 8], [24, 14, 47, 15]],
		"dry_threshold": 0.05, "edge_trees": 0.35, "scatter": 55, "flowers": 0.09,
		"props": [["tent", 250, 104], ["tent", 480, 104], ["firepit", 470, 176], ["sacks", 214, 110],
			["basket", 290, 112], ["jar", 520, 110], ["jar", 526, 113], ["firewood", 440, 112], ["sacks", 508, 176]],
		"free_trees": [[120, 420], [200, 560], [700, 120], [860, 160], [900, 520], [760, 560], [330, 520], [600, 600]],
		# curral: x0, y0, x1, y1 (tiles), porteira entre gx0 e gx1 no lado norte
		"fences": [[30, 22, 40, 30, 34, 35]],
		"tint": Color(1.0, 0.98, 0.92),
	},
}

var rng := RandomNumberGenerator.new()
var _blocked: Array[Rect2] = []
var _path_cells := {}
var _w := 0
var _h := 0
var _prop_scenes := {}


func _initialize() -> void:
	_build_new_props()
	var only := OS.get_cmdline_user_args()
	var ts: TileSet = load("res://assets/tilesets/canaan_tileset.tres")
	for id in LAYOUTS:
		if only.is_empty() or id in only:
			_build_map(id, LAYOUTS[id], ts)
	print("build_regions: concluido")
	quit()


# ---------------------------------------------------------------- objetos novos

func _build_new_props() -> void:
	for id in NEW_PROPS:
		var def: Dictionary = NEW_PROPS[id]
		var root := StaticBody2D.new()
		root.name = id.to_pascal_case()
		root.collision_layer = 1
		root.collision_mask = 0
		var spr := Sprite2D.new()
		spr.name = "Sprite"
		spr.texture = load("res://assets/environments/%s.png" % id)
		spr.centered = false
		spr.offset = -def.origin
		_own(root, root, spr)
		var r: Rect2 = def.col
		var cs := CollisionShape2D.new()
		cs.name = "Collision"
		var shape := RectangleShape2D.new()
		shape.size = r.size
		cs.shape = shape
		cs.position = r.position + r.size / 2.0
		_own(root, root, cs)
		var packed := PackedScene.new()
		packed.pack(root)
		_save(packed, ENV_SCENE % id)
		root.free()


func _scene(id: String) -> PackedScene:
	if not _prop_scenes.has(id):
		_prop_scenes[id] = load(ENV_SCENE % id)
	return _prop_scenes[id]


# ---------------------------------------------------------------- mapa

func _build_map(region_id: String, L: Dictionary, ts: TileSet) -> void:
	rng.seed = int(L.seed)
	_w = int(L.size[0])
	_h = int(L.size[1])
	_blocked.clear()
	_path_cells.clear()
	for r in L.paths:
		for y in range(int(r[1]), int(r[3]) + 1):
			for x in range(int(r[0]), int(r[2]) + 1):
				_path_cells[Vector2i(x, y)] = true

	var root := Node2D.new()
	root.name = String(L.node)
	root.set_script(load("res://scripts/world/game_map.gd"))
	root.set("region_id", region_id)
	root.set("map_size_tiles", Vector2i(_w, _h))
	var ground := _layer(root, "Ground", ts, -12)
	var patches := _layer(root, "DryGrass", ts, -11)
	var paths := _layer(root, "Paths", ts, -9)
	var decor := _layer(root, "Decor", ts, -8)
	var world := Node2D.new()
	world.name = "World"
	world.y_sort_enabled = true
	_own(root, root, world)

	_reserve_from_region(region_id)
	_paint(L, ground, patches, paths, decor)

	var region: Dictionary = _region_data(region_id)
	var spawn := Marker2D.new()
	spawn.name = "PlayerSpawn"
	var e: Dictionary = region.get("entries", {}).get("default", {"x": 32, "y": 32})
	spawn.position = Vector2(float(e.x), float(e.y))
	_own(root, world, spawn)
	var player: Node2D = load("res://scenes/player/player.tscn").instantiate()
	player.position = spawn.position
	_own(root, world, player)

	for p in L.props:
		_prop(root, world, String(p[0]), Vector2(float(p[1]), float(p[2])))
	for f in L.fences:
		_fence(root, world, f)
	_nature(root, world, L)
	_add_bounds(root)
	var mod := CanvasModulate.new()
	mod.name = "DaylightTint"
	mod.color = L.tint
	_own(root, root, mod)

	var packed := PackedScene.new()
	packed.pack(root)
	_save(packed, String(L.scene))
	root.free()
	print("build_regions: %s (%dx%d)" % [region_id, _w, _h])


func _region_data(region_id: String) -> Dictionary:
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/regions/%s.json" % region_id))
	if data is Dictionary:
		for r in data.get("regions", []):
			if r.get("id") == region_id:
				return r
	push_error("build_regions: região %s não encontrada em data/regions" % region_id)
	return {}


## Reserva o espaço de tudo o que a região posiciona por dados.
func _reserve_from_region(region_id: String) -> void:
	var r := _region_data(region_id)
	for e in r.get("entries", {}).values():
		_block(Rect2(float(e.x) - 20, float(e.y) - 24, 40, 36))
	for key in ["exits", "areas"]:
		for a in r.get(key, []):
			if key == "exits":
				_block(Rect2(float(a.rect[0]) - 8, float(a.rect[1]) - 8, float(a.rect[2]) + 40, float(a.rect[3]) + 16))
	for key in ["npcs", "examinables", "pickups"]:
		for d in r.get(key, []):
			_block(Rect2(float(d.x) - 16, float(d.y) - 20, 32, 28))


func _layer(root: Node, layer_name: String, ts: TileSet, z: int) -> TileMapLayer:
	var l := TileMapLayer.new()
	l.name = layer_name
	l.tile_set = ts
	l.z_index = z
	_own(root, root, l)
	return l


func _mask(c: Vector2i, has: Callable) -> int:
	var mask := 0
	if c.y == 0 or has.call(c + Vector2i.UP): mask |= 1
	if c.x == _w - 1 or has.call(c + Vector2i.RIGHT): mask |= 2
	if c.y == _h - 1 or has.call(c + Vector2i.DOWN): mask |= 4
	if c.x == 0 or has.call(c + Vector2i.LEFT): mask |= 8
	return mask


func _paint(L: Dictionary, ground: TileMapLayer, patches: TileMapLayer, paths: TileMapLayer, decor: TileMapLayer) -> void:
	var noise := FastNoiseLite.new()
	noise.seed = int(L.seed)
	noise.frequency = 0.07
	var dry := {}
	for y in _h:
		for x in _w:
			var c := Vector2i(x, y)
			if noise.get_noise_2d(x, y) > float(L.dry_threshold) and not _path_cells.has(c):
				dry[c] = true
	var has_dry := func(c: Vector2i) -> bool: return dry.has(c)
	var has_path := func(c: Vector2i) -> bool: return _path_cells.has(c)
	var flowers := float(L.flowers)
	for y in _h:
		for x in _w:
			var c := Vector2i(x, y)
			var r := rng.randf()
			var gi := 0 if r < 0.55 else (1 if r < 0.75 else (2 if r < 0.9 else 3))
			ground.set_cell(c, 0, Spec.GRASS[gi])
			if dry.has(c):
				patches.set_cell(c, 0, Spec.overlay_coords(Spec.OVERLAY_DRY, _mask(c, has_dry)))
			if _path_cells.has(c):
				paths.set_cell(c, 0, Spec.path_coords(_mask(c, has_path)))
				continue
			var near_path := false
			for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				if _path_cells.has(c + d):
					near_path = true
			var roll := rng.randf()
			if near_path and roll < 0.3:
				decor.set_cell(c, 0, Spec.PEBBLES)
			elif roll < flowers * 0.5:
				decor.set_cell(c, 0, Spec.FLOWER_YELLOW)
			elif roll < flowers * 0.8:
				decor.set_cell(c, 0, Spec.FLOWER_WHITE)
			elif roll < flowers:
				decor.set_cell(c, 0, Spec.FLOWER_RED)
			elif roll < flowers + 0.08:
				decor.set_cell(c, 0, Spec.TUFT_A if roll < flowers + 0.04 else Spec.TUFT_B)


func _prop(root: Node, world: Node, id: String, pos: Vector2) -> Node2D:
	var inst: Node2D = _scene(id).instantiate()
	inst.position = pos
	_own(root, world, inst)
	var r: Rect2 = PROP_COLS.get(id, Rect2(-6, -4, 12, 4))
	_block(Rect2(pos + r.position, r.size).grow(6))
	return inst


func _fence(root: Node, world: Node, f: Array) -> void:
	var x0 := int(f[0])
	var y0 := int(f[1])
	var x1 := int(f[2])
	var y1 := int(f[3])
	for x in range(x0, x1 + 1):
		if x < int(f[4]) or x > int(f[5]):
			_prop(root, world, "fence_h", Vector2(x * T + 8, y0 * T + 15))
		_prop(root, world, "fence_h", Vector2(x * T + 8, y1 * T + 15))
	for y in range(y0 + 1, y1):
		_prop(root, world, "fence_v", Vector2(x0 * T + 8, y * T + 15))
		_prop(root, world, "fence_v", Vector2(x1 * T + 8, y * T + 15))
	_block(Rect2(x0 * T, y0 * T, (x1 - x0 + 1) * T, (y1 - y0 + 1) * T))


func _nature(root: Node, world: Node, L: Dictionary) -> void:
	var edge_p := float(L.edge_trees)
	for y in _h:
		for x in _w:
			var edge := mini(mini(x, y), mini(_w - 1 - x, _h - 1 - y))
			if edge > 2 or rng.randf() > edge_p:
				continue
			var id := "tree_oak" if rng.randf() < 0.5 else "tree_olive"
			_try_place(root, world, id, Vector2(x * T + 8 + rng.randi_range(-5, 5), y * T + 14 + rng.randi_range(-4, 4)), 2)
	for p in L.free_trees:
		_try_place(root, world, "tree_olive" if rng.randf() < 0.6 else "tree_oak", Vector2(float(p[0]), float(p[1])), 1)
	for i in int(L.scatter):
		var pos := Vector2(rng.randf_range(40, _w * T - 40), rng.randf_range(40, _h * T - 30))
		var roll := rng.randf()
		_try_place(root, world, "bush" if roll < 0.5 else ("rock_small" if roll < 0.8 else "rock_big"), pos, 1)


func _try_place(root: Node, world: Node, id: String, pos: Vector2, path_margin: int) -> void:
	var r: Rect2 = PROP_COLS.get(id, Rect2(-6, -4, 12, 4))
	var foot := Rect2(pos + r.position, r.size).grow(4)
	for b in _blocked:
		if b.intersects(foot):
			return
	var cell := Vector2i(int(pos.x) / T, int(pos.y) / T)
	for dy in range(-path_margin - 1, path_margin + 2):
		for dx in range(-path_margin - 1, path_margin + 2):
			if _path_cells.has(cell + Vector2i(dx, dy)) and absi(dy) <= path_margin + (1 if dy > 0 else 0):
				return
	if pos.x < 8 or pos.y < 20 or pos.x > _w * T - 8 or pos.y > _h * T:
		return
	_prop(root, world, id, pos)
	if id.begins_with("tree"):
		_block(Rect2(pos - Vector2(14, 30), Vector2(28, 34)))


func _block(r: Rect2) -> void:
	_blocked.append(r)


func _add_bounds(root: Node) -> void:
	var body := StaticBody2D.new()
	body.name = "Bounds"
	body.collision_layer = 1
	_own(root, root, body)
	var w := _w * T
	var h := _h * T
	var rects := [Rect2(-16, 0, 16, h), Rect2(w, 0, 16, h), Rect2(0, -16, w, 16 + 8), Rect2(0, h - 2, w, 16)]
	var i := 0
	for r in rects:
		var cs := CollisionShape2D.new()
		cs.name = "Edge%d" % i
		var shape := RectangleShape2D.new()
		shape.size = r.size
		cs.shape = shape
		cs.position = r.position + r.size / 2.0
		_own(root, body, cs)
		i += 1


func _own(root: Node, parent: Node, child: Node) -> void:
	parent.add_child(child)
	child.owner = root


func _save(res: Resource, path: String) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	var err := ResourceSaver.save(res, path)
	if err != OK:
		push_error("build_regions: falha ao salvar %s (%s)" % [path, error_string(err)])
