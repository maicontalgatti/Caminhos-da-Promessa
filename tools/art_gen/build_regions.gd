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
##
## Mapas v0.5 (LAYOUTS com "tileset": "lands"): usam lands_tileset.tres (fonte 0
## = atlas de Canaã, fonte 1 = atlas de terras), camadas de sobreposição por
## retângulo/disco ("overlays"), muros por segmento ("walls", "lines"), colisões
## fixas ("solids", em pixels) e árvores/objetos sem sorteio de espécie. Os NPCs,
## examináveis e itens ainda sem diálogo/personagem ficam em "_stage_b" da
## região e também são reservados.

const Spec = preload("res://tools/art_gen/art_spec.gd")
const Lands = preload("res://tools/art_gen/art_lands.gd")
const T := 16
const ENV_SCENE := "res://scenes/environments/%s.tscn"
const LANDS_TILESET := "res://assets/tilesets/lands_tileset.tres"
## Decorações do atlas de terras (fonte 1); as demais vêm do atlas de Canaã.
const LANDS_DECOR := ["SAND_RIPPLE", "SHELLS", "DESERT_TUFT", "CROP_ROWS", "CROP_ROWS_B", "WATER_GLINT", "STRAW", "LOTUS"]

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

## Objetos existentes que ganham uma cópia sem interação ("<id>_plain").
const PLAIN_PROPS := ["boundary_stone"]

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
	# --- v0.5: quatro experiências ---------------------------------------------
	"egypt_house": {
		"scene": "res://scenes/maps/egypt_house.tscn", "node": "EgyptHouse", "size": [64, 40], "seed": 901,
		"tileset": "lands", "ground": "sand",
		"ground_decor": [["SAND_RIPPLE", 0.07], ["DESERT_TUFT", 0.04]],
		"overlays": [
			{"layer": "Soil", "kind": "soil", "rects": [[0, 4, 63, 39]], "decor": [["TUFT_A", 0.03], ["PEBBLES", 0.02]]},
			{"layer": "Floors", "kind": "floor", "rects": [[5, 5, 40, 26], [43, 6, 58, 15]], "discs": [[50, 24, 3.6]], "decor": [["STRAW", 0.04]]},
			{"layer": "Green", "kind": "green", "rects": [[6, 6, 18, 16]], "decor": [["FLOWER_WHITE", 0.05], ["FLOWER_YELLOW", 0.04], ["TUFT_B", 0.06]]},
			{"layer": "Green", "kind": "green", "rects": [[27, 31, 63, 36], [0, 33, 24, 36]], "decor": [["CROP_ROWS", 0.45], ["CROP_ROWS_B", 0.3]]},
			{"layer": "Water", "kind": "water", "rects": [[0, 37, 63, 39]], "decor": [["WATER_GLINT", 0.12], ["LOTUS", 0.04]]},
		],
		"paths": [[0, 30, 25, 31], [22, 26, 25, 29], [26, 28, 45, 29], [44, 16, 45, 29], [17, 20, 19, 21]],
		"solids": [[0, 604, 1024, 36]],
		"walls": [
			{"rect": [4, 4, 41, 27], "prefix": "mudbrick_wall", "gates": {"S": [22, 25]}, "block_inside": false},
			{"rect": [56, 18, 62, 26], "prefix": "reed_fence", "gates": {"W": [21, 23]}},
		],
		"props": [["house_portico", 448, 240], ["storage_jars", 632, 128], ["saddle_quern", 216, 384], ["sacks", 520, 392],
			["basket", 548, 372], ["jar", 120, 330], ["pots", 236, 326], ["firewood", 148, 344],
			["flax_bundles", 560, 500], ["flax_bundles", 880, 520],
			["papyrus_reeds", 120, 604], ["papyrus_reeds", 300, 610], ["papyrus_reeds", 460, 608], ["papyrus_reeds", 940, 606]],
		"trees": [["tree_sycamore", 136, 120], ["tree_sycamore", 296, 120], ["tree_date_palm", 136, 256], ["tree_date_palm", 296, 264],
			["tree_acacia", 760, 24], ["tree_acacia", 980, 40], ["tree_date_palm", 690, 96], ["tree_date_palm", 40, 470],
			["tree_date_palm", 990, 470], ["tree_date_palm", 200, 560], ["tree_date_palm", 620, 570]],
		"scatter": {"count": 10, "ids": ["rock_small"]},
		"tint": Color(1.0, 0.97, 0.88),
	},
	"sea_camp": {
		"scene": "res://scenes/maps/sea_camp.tscn", "node": "SeaCamp", "size": [64, 72], "seed": 1601,
		"tileset": "lands", "ground": "sand",
		"ground_decor": [["SAND_RIPPLE", 0.07], ["DESERT_TUFT", 0.03], ["SHELLS", 0.015]],
		"overlays": [
			{"layer": "Rock", "kind": "rock", "rects": [[0, 0, 63, 5], [0, 64, 5, 71], [14, 64, 63, 71]], "decor": [["PEBBLES", 0.05]]},
			{"layer": "Green", "kind": "green", "discs": [[58, 54, 2.8]], "decor": [["TUFT_A", 0.2]]},
			{"layer": "Water", "kind": "water", "rects": [[0, 18, 63, 41]], "decor": [["WATER_GLINT", 0.1]]},
		],
		"paths": [],
		"solids": [[0, 0, 1024, 90], [0, 292, 1024, 376], [0, 1028, 1024, 124]],
		"props": [["tent_worn", 260, 776], ["tent_worn", 470, 772], ["tent_worn", 700, 770], ["tent_worn", 620, 940], ["tent_worn", 820, 780],
			["tent_worn", 60, 980],
			["cloth_shelter", 380, 760], ["cloth_shelter", 560, 760], ["cloth_shelter", 900, 790], ["cloth_shelter", 220, 940], ["cloth_shelter", 520, 960],
			["firepit", 528, 848], ["bread_stone_fire", 320, 812], ["firepit", 780, 832],
			["skins_tripod", 620, 952], ["jar", 640, 944], ["jar", 300, 790], ["sacks", 860, 900],
			["crowd_group_a", 180, 860], ["crowd_group_a", 440, 872], ["crowd_group_b", 240, 1000], ["crowd_group_b", 700, 992],
			["reeds", 940, 690], ["reeds", 80, 690], ["reeds", 120, 300], ["reeds", 900, 300],
			["rock_crest", 300, 1060], ["rock_crest", 620, 1080], ["dune", 820, 1080], ["rock_big", 100, 1010], ["rock_crest", 460, 1030],
			["cloth_shelter", 420, 120], ["cloth_shelter", 560, 110], ["cloth_shelter", 700, 130], ["sacks", 470, 150], ["firepit_out", 560, 140],
			["dune", 200, 40], ["rock_crest", 640, 30], ["dune", 900, 50]],
		"trees": [["tamarisk", 120, 760], ["tamarisk", 400, 900], ["tamarisk", 980, 960], ["tamarisk", 60, 900],
			["tree_date_palm", 920, 840], ["tree_date_palm", 960, 880]],
		"scatter": {"count": 26, "ids": ["rock_small", "thorn_bush"]},
		"reserve": [[480, 672, 80, 140], [384, 192, 256, 80]],
	},
	"bethlehem_fields": {
		"scene": "res://scenes/maps/bethlehem_fields.tscn", "node": "BethlehemFields", "size": [64, 40], "seed": 2501,
		"tileset": "lands", "ground": "grass", "dry_threshold": 0.1,
		"ground_decor": [["FLOWER_YELLOW", 0.02], ["FLOWER_WHITE", 0.015], ["FLOWER_RED", 0.01], ["TUFT_A", 0.04], ["TUFT_B", 0.04]],
		"overlays": [
			{"layer": "Village", "kind": "floor", "rects": [[0, 0, 63, 5]]},
			{"layer": "Stubble", "kind": "stubble", "rects": [[6, 21, 26, 34], [30, 21, 43, 36]], "minus": [[23, 31, 26, 34]], "decor": [["STRAW", 0.18]]},
			{"layer": "Barley", "kind": "barley", "rects": [[23, 31, 26, 34], [44, 21, 56, 36]]},
			{"layer": "Plaza", "kind": "stone", "rects": [[29, 6, 35, 7]]},
			{"layer": "Threshing", "kind": "floor", "discs": [[55, 12, 3.2]], "decor": [["STRAW", 0.3]]},
		],
		"paths": [[0, 18, 32, 19], [31, 7, 32, 19], [32, 12, 52, 13]],
		"solids": [[0, 0, 1024, 84]],
		"lines": [[0, 5, 29, 5, "stone_wall"], [34, 5, 63, 5, "stone_wall"],
			[58, 16, 63, 16, "stone_wall"], [58, 26, 63, 26, "stone_wall"], [58, 34, 63, 34, "stone_wall"]],
		"props": [["house_pillar", 120, 60], ["house_pillar", 220, 52], ["house_pillar", 360, 64], ["house_pillar", 440, 56],
			["house_pillar", 600, 60], ["house_pillar", 680, 72], ["house_pillar", 820, 58], ["house_pillar", 930, 66],
			["stone_bench", 488, 104], ["stone_bench", 536, 104], ["oven", 400, 104], ["pithos", 636, 108],
			["jar", 112, 332], ["basket", 128, 336], ["sheaf", 300, 344], ["sheaf", 316, 348],
			["jar", 828, 372], ["jar", 836, 376], ["sheaf", 560, 380], ["sheaf", 640, 470], ["sheaf", 720, 380],
			["threshing_sledge", 912, 212], ["winnowing_fork", 852, 204],
			["rock_big", 960, 300], ["rock_small", 976, 420], ["rock_big", 940, 520], ["bush", 980, 560], ["bush", 40, 600],
			["boundary_stone_plain", 448, 360], ["boundary_stone_plain", 448, 520], ["boundary_stone_plain", 448, 584]],
		"trees": [["tree_olive", 80, 120], ["tree_olive", 140, 180], ["tree_olive", 760, 120], ["tree_olive", 840, 140],
			["tree_oak", 420, 250], ["tree_oak", 900, 600], ["tree_olive", 60, 420], ["tree_olive", 980, 250], ["tree_olive", 600, 610]],
		"edge": {"p": 0.25, "ids": ["tree_olive", "tree_oak"], "sides": "WSE"},
		"scatter": {"count": 30, "ids": ["bush", "rock_small", "rock_big"]},
		"reserve": [[480, 336, 416, 240], [496, 104, 32, 256], [96, 336, 336, 224], [480, 336, 432, 256]],
		"tint": Color(1.0, 0.98, 0.92),
	},
	"bethlehem_night": {
		"scene": "res://scenes/maps/bethlehem_night.tscn", "node": "BethlehemNight", "size": [64, 48], "seed": 4801,
		"tileset": "lands", "ground": "grass", "dry_threshold": -0.15,
		"ground_decor": [["TUFT_A", 0.06], ["TUFT_B", 0.05], ["FLOWER_WHITE", 0.01], ["PEBBLES", 0.03]],
		"overlays": [
			{"layer": "Rock", "kind": "rock", "rects": [[0, 0, 63, 11]], "discs": [[58, 41, 4.5], [8, 44, 3.0], [46, 30, 2.2]], "decor": [["PEBBLES", 0.05]]},
			{"layer": "Village", "kind": "floor", "rects": [[2, 1, 40, 4]]},
			{"layer": "Fold", "kind": "floor", "rects": [[28, 36, 36, 39]], "decor": [["STRAW", 0.25]]},
		],
		"paths": [[1, 26, 12, 27], [11, 23, 12, 27], [11, 23, 32, 24], [31, 15, 32, 34], [31, 15, 40, 16]],
		"solids": [[0, 0, 1024, 200]],
		"walls": [{"rect": [27, 35, 37, 40], "prefix": "fold_wall", "gates": {"N": [32, 32]}}],
		"lines": [[0, 12, 45, 12, "stone_wall"], [47, 12, 63, 12, "stone_wall"]],
		"props": [["house_courtyard", 96, 56], ["house_courtyard", 192, 40], ["house_courtyard", 296, 60], ["house_courtyard", 400, 44],
			["house_courtyard", 504, 64], ["house_courtyard", 600, 48], ["tree_olive", 152, 168], ["tree_olive", 440, 160],
			["house_on_rock", 728, 156], ["stone_stairs", 744, 207], ["rock_crest", 900, 120], ["rock_crest", 980, 170],
			["rock_shelter", 296, 456], ["firepit_out", 312, 488], ["firewood", 328, 480], ["firepit_out", 520, 536],
			["cave_mouth", 904, 664], ["rock_big", 776, 504], ["rock_small", 744, 528], ["rock_big", 720, 736], ["rock_small", 960, 600],
			["thorn_bush", 200, 552], ["thorn_bush", 360, 744], ["thorn_bush", 648, 728], ["thorn_bush", 840, 472], ["thorn_bush", 424, 376],
			["bush", 96, 700], ["terrace_wall", 96, 584], ["terrace_wall", 128, 640]],
		"trees": [["tree_oak", 120, 520], ["tree_olive", 80, 600]],
		"edge": {"p": 0.2, "ids": ["tree_olive", "tree_oak"], "sides": "WSE"},
		"scatter": {"count": 40, "ids": ["rock_small", "rock_big", "thorn_bush"]},
		"reserve": [[380, 396, 280, 280], [480, 140, 280, 400], [232, 424, 128, 96]],
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
	var lands_ts: TileSet = null
	for id in LAYOUTS:
		if only.is_empty() or id in only:
			var L: Dictionary = LAYOUTS[id]
			if L.get("tileset", "canaan") == "lands":
				if lands_ts == null:
					lands_ts = _build_lands_tileset()
				_build_map_v05(id, L, lands_ts)
			else:
				_build_map(id, L, ts)
	print("build_regions: concluido")
	quit()


# ---------------------------------------------------------------- objetos novos

func _build_new_props() -> void:
	var defs := NEW_PROPS.duplicate()
	defs.merge(Lands.PROPS)
	var sway: Material = load("res://assets/shaders/sway_material.tres")
	for id in defs:
		var def: Dictionary = defs[id]
		if _prop_unchanged(id, def):
			continue
		var root := StaticBody2D.new()
		root.name = id.to_pascal_case()
		root.collision_layer = 1
		root.collision_mask = 0
		var spr := Sprite2D.new()
		spr.name = "Sprite"
		spr.texture = load("res://assets/environments/%s.png" % id)
		spr.centered = false
		spr.offset = -def.origin
		if def.get("sway", false):
			spr.material = sway
		_own(root, root, spr)
		if def.has("col"):
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
	for id in PLAIN_PROPS:
		_build_plain(id)


## Cena do objeto já salva com a mesma textura, origem, balanço e colisão:
## não regrava (evita trocar os unique_id do .tscn a cada execução).
func _prop_unchanged(id: String, def: Dictionary) -> bool:
	var path := ENV_SCENE % id
	if not ResourceLoader.exists(path):
		return false
	var root: Node = load(path).instantiate()
	var same := false
	var spr := root.get_node_or_null("Sprite") as Sprite2D
	if spr != null and spr.texture != null:
		same = spr.texture.resource_path == "res://assets/environments/%s.png" % id \
			and spr.offset == -Vector2(def.origin) and (spr.material != null) == bool(def.get("sway", false))
		var cs := root.get_node_or_null("Collision") as CollisionShape2D
		if def.has("col"):
			var r: Rect2 = def.col
			same = same and cs != null and cs.shape is RectangleShape2D \
				and (cs.shape as RectangleShape2D).size == r.size and cs.position == r.position + r.size / 2.0
		else:
			same = same and cs == null
	root.free()
	return same


## Cópia "<id>_plain" de um objeto existente sem o Interactable embutido (a fala
## original é de Canaã e não serve como decoração em outra região).
func _build_plain(id: String) -> void:
	var path := ENV_SCENE % (id + "_plain")
	if ResourceLoader.exists(path):
		return
	var root: Node = load(ENV_SCENE % id).instantiate()
	root.scene_file_path = ""
	for old in root.find_children("*", "Interactable", true, false):
		old.get_parent().remove_child(old)
		old.free()
	var packed := PackedScene.new()
	packed.pack(root)
	_save(packed, path)
	root.free()


## Colisão de um objeto (existente ou novo) para reservar espaço no mapa.
func _col(id: String) -> Rect2:
	id = id.trim_suffix("_plain")
	if PROP_COLS.has(id):
		return PROP_COLS[id]
	var def: Dictionary = Lands.PROPS.get(id, {})
	return def.get("col", Rect2(-6, -4, 12, 4))


## Fonte 0 = atlas de Canaã (mesmas coordenadas de canaan_tileset), fonte 1 = terras.
func _build_lands_tileset() -> TileSet:
	var ts := TileSet.new()
	ts.tile_size = Vector2i(T, T)
	for src_def in [[0, "res://assets/tilesets/canaan_tiles.png", Spec.ATLAS_ROWS], [Spec.LANDS_SOURCE, "res://assets/tilesets/lands_tiles.png", Spec.LANDS_ROWS]]:
		var src := TileSetAtlasSource.new()
		src.texture = load(String(src_def[1]))
		src.texture_region_size = Vector2i(T, T)
		for y in int(src_def[2]):
			for x in Spec.ATLAS_COLS:
				src.create_tile(Vector2i(x, y))
		ts.add_source(src, int(src_def[0]))
	_save(ts, LANDS_TILESET)
	return load(LANDS_TILESET)


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


# ---------------------------------------------------------------- mapa v0.5

func _build_map_v05(region_id: String, L: Dictionary, ts: TileSet) -> void:
	rng.seed = int(L.seed)
	_w = int(L.size[0])
	_h = int(L.size[1])
	_blocked.clear()
	_path_cells.clear()
	for r in L.paths:
		for y in range(mini(int(r[1]), int(r[3])), maxi(int(r[1]), int(r[3])) + 1):
			for x in range(mini(int(r[0]), int(r[2])), maxi(int(r[0]), int(r[2])) + 1):
				_path_cells[Vector2i(x, y)] = true

	var root := Node2D.new()
	root.name = String(L.node)
	root.set_script(load("res://scripts/world/game_map.gd"))
	root.set("region_id", region_id)
	root.set("map_size_tiles", Vector2i(_w, _h))
	var ground := _layer(root, "Ground", ts, -20)
	_paint_v05(root, L, ground, ts)
	var world := Node2D.new()
	world.name = "World"
	world.y_sort_enabled = true
	_own(root, root, world)

	_reserve_from_region(region_id)
	for r in L.get("reserve", []):
		_block(Rect2(float(r[0]), float(r[1]), float(r[2]), float(r[3])))
	_solids(root, L.get("solids", []))

	var region: Dictionary = _region_data(region_id)
	var spawn := Marker2D.new()
	spawn.name = "PlayerSpawn"
	var e: Dictionary = region.get("entries", {}).get("default", {"x": 32, "y": 32})
	spawn.position = Vector2(float(e.x), float(e.y))
	_own(root, world, spawn)
	var player: Node2D = load("res://scenes/player/player.tscn").instantiate()
	player.position = spawn.position
	_own(root, world, player)

	for p in L.get("props", []):
		_prop(root, world, String(p[0]), Vector2(float(p[1]), float(p[2])))
	for t in L.get("trees", []):
		_try_place(root, world, String(t[0]), Vector2(float(t[1]), float(t[2])), 0)
	for wdef in L.get("walls", []):
		_wall_rect(root, world, wdef)
	for ln in L.get("lines", []):
		_wall_line(root, world, ln)
	_nature_v05(root, world, L)
	_add_bounds(root)
	if L.has("tint"):
		var mod := CanvasModulate.new()
		mod.name = "DaylightTint"
		mod.color = L.tint
		_own(root, root, mod)

	var packed := PackedScene.new()
	packed.pack(root)
	_save(packed, String(L.scene))
	root.free()
	print("build_regions: %s (%dx%d, v0.5)" % [region_id, _w, _h])


## [fonte, linha-base] da sobreposição autotile de cada tipo de terreno.
func _overlay_kind(kind: String) -> Array:
	match kind:
		"soil": return [Spec.LANDS_SOURCE, Spec.LANDS_OVERLAY_SOIL]
		"water": return [Spec.LANDS_SOURCE, Spec.LANDS_OVERLAY_WATER]
		"floor": return [Spec.LANDS_SOURCE, Spec.LANDS_OVERLAY_FLOOR]
		"barley": return [Spec.LANDS_SOURCE, Spec.LANDS_OVERLAY_BARLEY]
		"stubble": return [Spec.LANDS_SOURCE, Spec.LANDS_OVERLAY_STUBBLE]
		"green": return [Spec.LANDS_SOURCE, Spec.LANDS_OVERLAY_GREEN]
		"rock": return [Spec.LANDS_SOURCE, Spec.LANDS_OVERLAY_ROCK]
		"dry": return [0, Spec.OVERLAY_DRY]
		"stone": return [0, Spec.OVERLAY_STONE]
		"path": return [0, Spec.OVERLAY_PATH]
	push_error("build_regions: tipo de sobreposição desconhecido: %s" % kind)
	return [0, Spec.OVERLAY_DRY]


## [fonte, coordenada] de um tile simples pelo nome da constante em art_spec.gd.
func _tile_ref(tile_name: String) -> Array:
	var spec_script: Script = load("res://tools/art_gen/art_spec.gd")
	var consts: Dictionary = spec_script.get_script_constant_map()
	if not consts.has(tile_name):
		push_error("build_regions: tile desconhecido: %s" % tile_name)
		return [0, Spec.PEBBLES]
	return [Spec.LANDS_SOURCE if tile_name in LANDS_DECOR else 0, consts[tile_name]]


func _overlay_cells(o: Dictionary) -> Dictionary:
	var cells := {}
	for r in o.get("rects", []):
		for y in range(maxi(int(r[1]), 0), mini(int(r[3]), _h - 1) + 1):
			for x in range(maxi(int(r[0]), 0), mini(int(r[2]), _w - 1) + 1):
				cells[Vector2i(x, y)] = true
	for d in o.get("discs", []):
		var cx := float(d[0])
		var cy := float(d[1])
		var rad := float(d[2])
		for y in range(maxi(int(cy - rad) - 1, 0), mini(int(cy + rad) + 1, _h - 1) + 1):
			for x in range(maxi(int(cx - rad) - 1, 0), mini(int(cx + rad) + 1, _w - 1) + 1):
				if (x - cx) * (x - cx) + (y - cy) * (y - cy) <= rad * rad:
					cells[Vector2i(x, y)] = true
	for r in o.get("minus", []):
		for y in range(int(r[1]), int(r[3]) + 1):
			for x in range(int(r[0]), int(r[2]) + 1):
				cells.erase(Vector2i(x, y))
	return cells


func _pick_decor(list: Array) -> Array:
	var roll := rng.randf()
	var acc := 0.0
	for entry in list:
		acc += float(entry[1])
		if roll < acc:
			return _tile_ref(String(entry[0]))
	return []


func _paint_v05(root: Node, L: Dictionary, ground: TileMapLayer, ts: TileSet) -> void:
	var sand: bool = L.get("ground", "grass") == "sand"
	for y in _h:
		for x in _w:
			var r := rng.randf()
			var gi := 0 if r < 0.55 else (1 if r < 0.75 else (2 if r < 0.9 else 3))
			if sand:
				ground.set_cell(Vector2i(x, y), Spec.LANDS_SOURCE, Spec.SAND[gi])
			else:
				ground.set_cell(Vector2i(x, y), 0, Spec.GRASS[gi])
	if not sand and L.has("dry_threshold"):
		var noise := FastNoiseLite.new()
		noise.seed = int(L.seed)
		noise.frequency = 0.07
		var dry := {}
		for y in _h:
			for x in _w:
				if noise.get_noise_2d(x, y) > float(L.dry_threshold) and not _path_cells.has(Vector2i(x, y)):
					dry[Vector2i(x, y)] = true
		var has_dry := func(c: Vector2i) -> bool: return dry.has(c)
		var dry_layer := _layer(root, "DryGrass", ts, -19)
		for c in dry:
			dry_layer.set_cell(c, 0, Spec.overlay_coords(Spec.OVERLAY_DRY, _mask(c, has_dry)))

	# Camadas nomeadas (várias entradas podem compartilhar a mesma camada).
	var layer_order: Array[String] = []
	var layer_cells := {}
	var layer_kind := {}
	var top_decor := {}
	for o in L.get("overlays", []):
		var lname := String(o.layer)
		if not layer_cells.has(lname):
			layer_order.append(lname)
			layer_cells[lname] = {}
			layer_kind[lname] = String(o.kind)
		var cells := _overlay_cells(o)
		layer_cells[lname].merge(cells, true)
		for c in cells:
			top_decor[c] = o.get("decor", [])
	var z := -18
	for lname in layer_order:
		var kind: Array = _overlay_kind(String(layer_kind[lname]))
		var cells: Dictionary = layer_cells[lname]
		var has_cell := func(c: Vector2i) -> bool: return cells.has(c)
		var layer := _layer(root, lname, ts, z)
		z += 1
		for c in cells:
			layer.set_cell(c, int(kind[0]), Spec.overlay_coords(int(kind[1]), _mask(c, has_cell)))

	var paths := _layer(root, "Paths", ts, -10)
	var has_path := func(c: Vector2i) -> bool: return _path_cells.has(c)
	for c in _path_cells:
		if c.x >= 0 and c.y >= 0 and c.x < _w and c.y < _h:
			paths.set_cell(c, 0, Spec.path_coords(_mask(c, has_path)))

	var decor := _layer(root, "Decor", ts, -9)
	var ground_decor: Array = L.get("ground_decor", [])
	for y in _h:
		for x in _w:
			var c := Vector2i(x, y)
			if _path_cells.has(c):
				continue
			var near_path := false
			for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				if _path_cells.has(c + d):
					near_path = true
			if near_path and not top_decor.has(c) and rng.randf() < 0.25:
				decor.set_cell(c, 0, Spec.PEBBLES)
				continue
			var t := _pick_decor(top_decor.get(c, ground_decor))
			if not t.is_empty():
				decor.set_cell(c, int(t[0]), t[1])


## Colisões fixas em pixels (falésia, mar, rio, fileira de casas).
func _solids(root: Node, rects: Array) -> void:
	if rects.is_empty():
		return
	var body := StaticBody2D.new()
	body.name = "Solids"
	body.collision_layer = 1
	_own(root, root, body)
	var i := 0
	for r in rects:
		var rect := Rect2(float(r[0]), float(r[1]), float(r[2]), float(r[3]))
		var cs := CollisionShape2D.new()
		cs.name = "Solid%d" % i
		var shape := RectangleShape2D.new()
		shape.size = rect.size
		cs.shape = shape
		cs.position = rect.position + rect.size / 2.0
		_own(root, body, cs)
		_block(rect)
		i += 1


## Muro retangular em tiles [x0, y0, x1, y1] (inclusivo) com aberturas por lado.
func _wall_rect(root: Node, world: Node, wdef: Dictionary) -> void:
	var r: Array = wdef.rect
	var x0 := int(r[0])
	var y0 := int(r[1])
	var x1 := int(r[2])
	var y1 := int(r[3])
	var prefix := String(wdef.prefix)
	var gates: Dictionary = wdef.get("gates", {})
	var gap := func(side: String, v: int) -> bool:
		if not gates.has(side):
			return false
		var g: Array = gates[side]
		return v >= int(g[0]) and v <= int(g[1])
	for x in range(x0, x1 + 1):
		if not gap.call("N", x):
			_prop(root, world, prefix + "_h", Vector2(x * T + 8, y0 * T + 15))
		if not gap.call("S", x):
			_prop(root, world, prefix + "_h", Vector2(x * T + 8, y1 * T + 15))
	for y in range(y0 + 1, y1):
		if not gap.call("W", y):
			_prop(root, world, prefix + "_v", Vector2(x0 * T + 8, y * T + 15))
		if not gap.call("E", y):
			_prop(root, world, prefix + "_v", Vector2(x1 * T + 8, y * T + 15))
	if wdef.get("block_inside", true):
		_block(Rect2(x0 * T, y0 * T, (x1 - x0 + 1) * T, (y1 - y0 + 1) * T))


## Muro em linha reta [x0, y0, x1, y1, prefixo] (horizontal ou vertical, em tiles).
func _wall_line(root: Node, world: Node, ln: Array) -> void:
	var x0 := int(ln[0])
	var y0 := int(ln[1])
	var x1 := int(ln[2])
	var y1 := int(ln[3])
	var prefix := String(ln[4])
	if y0 == y1:
		for x in range(mini(x0, x1), maxi(x0, x1) + 1):
			_prop(root, world, prefix + "_h", Vector2(x * T + 8, y0 * T + 15))
	else:
		for y in range(mini(y0, y1), maxi(y0, y1) + 1):
			_prop(root, world, prefix + "_v", Vector2(x0 * T + 8, y * T + 15))


func _nature_v05(root: Node, world: Node, L: Dictionary) -> void:
	var edge: Dictionary = L.get("edge", {})
	if not edge.is_empty():
		var sides := String(edge.sides)
		var ids: Array = edge.ids
		for y in _h:
			for x in _w:
				var dist := 99
				if "W" in sides: dist = mini(dist, x)
				if "E" in sides: dist = mini(dist, _w - 1 - x)
				if "S" in sides: dist = mini(dist, _h - 1 - y)
				if "N" in sides: dist = mini(dist, y)
				if dist > 2 or rng.randf() > float(edge.p):
					continue
				var id := String(ids[rng.randi() % ids.size()])
				_try_place(root, world, id, Vector2(x * T + 8 + rng.randi_range(-5, 5), y * T + 14 + rng.randi_range(-4, 4)), 2)
	var scatter: Dictionary = L.get("scatter", {})
	if not scatter.is_empty():
		var ids: Array = scatter.ids
		for i in int(scatter.count):
			var pos := Vector2(rng.randf_range(40, _w * T - 40), rng.randf_range(40, _h * T - 30))
			_try_place(root, world, String(ids[rng.randi() % ids.size()]), pos, 1)


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
	var stage_b: Dictionary = r.get("_stage_b", {})
	for key in ["npcs", "examinables", "pickups"]:
		for d in r.get(key, []) + stage_b.get(key, []):
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
	var r := _col(id)
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
	var r := _col(id)
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
	if id.begins_with("tree") or id == "tamarisk":
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
