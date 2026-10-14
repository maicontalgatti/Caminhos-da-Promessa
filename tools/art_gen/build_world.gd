extends SceneTree
## Constrói recursos derivados da arte gerada:
##  - assets/ui/theme.tres (tema da interface)
##  - assets/tilesets/canaan_tileset.tres
##  - scenes/environments/*.tscn (objetos de cenário reutilizáveis)
##  - scenes/maps/canaan_village.tscn (aldeia do protótipo)
##
## Uso (depois de generate_art.gd e de `godot --headless --import`):
##   godot --headless --path . --script res://tools/art_gen/build_world.gd
##
## ATENÇÃO: regenerar sobrescreve canaan_village.tscn. Depois que o mapa
## passar a ser editado à mão no editor, use apenas a opção --props-only.

const Spec = preload("res://tools/art_gen/art_spec.gd")

const MAP_W := 60
const MAP_H := 40
const T := 16
const ENV_TEX := "res://assets/environments/%s.png"
const ENV_SCENE := "res://scenes/environments/%s.tscn"

## Definição dos objetos de cenário. origin = pixel dos "pés" no PNG.
## col = retângulo de colisão relativo aos pés. inter = Interactable opcional.
const PROPS := {
	"tree_olive": {"origin": Vector2(24, 53), "col": Rect2(-5, -4, 10, 5), "sway": true},
	"tree_oak": {"origin": Vector2(20, 49), "col": Rect2(-4, -4, 8, 5), "sway": true},
	"bush": {"origin": Vector2(10, 14), "col": Rect2(-6, -3, 12, 4), "sway": true},
	"rock_big": {"origin": Vector2(11, 15), "col": Rect2(-8, -5, 16, 6)},
	"rock_small": {"origin": Vector2(6, 8), "col": Rect2(-4, -3, 8, 4)},
	"well": {"origin": Vector2(16, 29), "col": Rect2(-11, -9, 22, 10),
		"inter": {"kind": 1, "dialogue": "well_examine", "center": Vector2(0, -8), "radius": 16, "prompt_offset": Vector2(0, -36)}},
	"fence_h": {"origin": Vector2(8, 15), "col": Rect2(-8, -5, 16, 4)},
	"fence_v": {"origin": Vector2(8, 15), "col": Rect2(-2, -16, 4, 16)},
	"house_small": {"origin": Vector2(32, 81), "col": Rect2(-30, -26, 60, 26),
		"inter": {"kind": 5, "dialogue": "house_door", "center": Vector2(0, -4), "radius": 10, "prompt_offset": Vector2(0, -34)}},
	"house_wide": {"origin": Vector2(40, 81), "col": Rect2(-38, -26, 76, 26),
		"inter": {"kind": 5, "dialogue": "house_door", "center": Vector2(0, -4), "radius": 10, "prompt_offset": Vector2(0, -34)}},
	"tent": {"origin": Vector2(24, 38), "col": Rect2(-22, -12, 44, 11),
		"inter": {"kind": 1, "dialogue": "tent_examine", "center": Vector2(0, -2), "radius": 14, "prompt_offset": Vector2(0, -40)}},
	"stall_produce": {"origin": Vector2(22, 38), "col": Rect2(-20, -11, 40, 10),
		"inter": {"kind": 1, "dialogue": "stall_produce_examine", "center": Vector2(4, -2), "radius": 12, "prompt_offset": Vector2(4, -40)}},
	"stall_textiles": {"origin": Vector2(22, 38), "col": Rect2(-20, -11, 40, 10),
		"inter": {"kind": 1, "dialogue": "stall_textiles_examine", "center": Vector2(0, -2), "radius": 12, "prompt_offset": Vector2(0, -40)}},
	"oven": {"origin": Vector2(10, 16), "col": Rect2(-7, -5, 14, 5), "particles": "smoke",
		"inter": {"kind": 1, "dialogue": "oven_examine", "center": Vector2(0, -6), "radius": 12, "prompt_offset": Vector2(0, -22)}},
	"jar": {"origin": Vector2(5, 15), "col": Rect2(-3, -3, 6, 3)},
	"pots": {"origin": Vector2(13, 15), "col": Rect2(-11, -4, 22, 4),
		"inter": {"kind": 1, "dialogue": "pots_examine", "center": Vector2(0, -6), "radius": 12, "prompt_offset": Vector2(0, -20)}},
	"basket": {"origin": Vector2(7, 9), "col": Rect2(-5, -3, 10, 3)},
	"sacks": {"origin": Vector2(9, 12), "col": Rect2(-7, -4, 14, 4)},
	"firewood": {"origin": Vector2(8, 9), "col": Rect2(-7, -3, 14, 3)},
	"firepit": {"origin": Vector2(8, 10), "col": Rect2(-6, -4, 12, 4), "particles": "fire",
		"inter": {"kind": 1, "dialogue": "firepit_examine", "center": Vector2(0, -4), "radius": 12, "prompt_offset": Vector2(0, -16)}},
	"boundary_stone": {"origin": Vector2(6, 17), "col": Rect2(-4, -4, 8, 4),
		"inter": {"kind": 1, "dialogue": "boundary_stone", "center": Vector2(0, -6), "radius": 12, "prompt_offset": Vector2(0, -24)}},
	"journal": {"origin": Vector2(8, 11), "col": Rect2(-6, -4, 12, 4), "particles": "sparkle",
		"inter": {"kind": 2, "dialogue": "journal_intro", "center": Vector2(0, -4), "radius": 12, "prompt_offset": Vector2(0, -16), "prompt": "Ler diário"}},
}

var rng := RandomNumberGenerator.new()
var sway_material: ShaderMaterial
var prop_scenes := {}


## _initialize (e não _init): os autoloads só existem a partir daqui, e os
## scripts do jogo dependem deles para compilar.
func _initialize() -> void:
	rng.seed = 40_2026
	var props_only := "--props-only" in OS.get_cmdline_user_args()
	_build_theme()
	var ts := _build_tileset()
	_build_props()
	if not props_only:
		_build_village(ts)
	print("build_world: concluido")
	quit()


# ---------------------------------------------------------------- tema

func _build_theme() -> void:
	var ink := Color("#2b1d14")
	var theme := Theme.new()
	# A ligadura "fi" da Pixelify Sans parece um "A" em 9 px ("fibras" vira "Abras").
	var pixel := FontVariation.new()
	pixel.base_font = load("res://assets/fonts/PixelifySans-Variable.ttf")
	pixel.opentype_features = {TextServerManager.get_primary_interface().name_to_tag("liga"): 0}
	theme.default_font = pixel
	theme.default_font_size = 9
	var lora: FontFile = load("res://assets/fonts/Lora-Variable.ttf")
	var lora_bold := FontVariation.new()
	lora_bold.base_font = lora
	lora_bold.variation_opentype = {TextServerManager.get_primary_interface().name_to_tag("wght"): 700}
	theme.set_font("normal_font", "RichTextLabel", lora)
	theme.set_font("bold_font", "RichTextLabel", lora_bold)
	theme.set_font("italics_font", "RichTextLabel", load("res://assets/fonts/Lora-Italic-Variable.ttf"))

	var panel := StyleBoxTexture.new()
	panel.texture = load("res://assets/ui/panel_parchment.png")
	for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		panel.set_texture_margin(side, 7)
		panel.set_content_margin(side, 8)
	panel.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_TILE_FIT
	panel.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_TILE_FIT
	theme.set_stylebox("panel", "PanelContainer", panel)
	theme.set_stylebox("panel", "Panel", panel)

	var normal := _flat(Color("#ead3a4"), Color("#8b5a2b"))
	var hover := _flat(Color("#f6e6c2"), Color("#c9a227"))
	var pressed := _flat(Color("#d9b98a"), Color("#8b5a2b"))
	var disabled := _flat(Color("#d8ccb4"), Color("#b8a888"))
	var focus := StyleBoxFlat.new()
	focus.draw_center = false
	focus.set_border_width_all(1)
	focus.border_color = Color("#c9a227")
	focus.set_corner_radius_all(2)
	for t in ["Button", "CheckButton"]:
		theme.set_stylebox("normal", t, normal)
		theme.set_stylebox("hover", t, hover)
		theme.set_stylebox("pressed", t, pressed)
		theme.set_stylebox("disabled", t, disabled)
		theme.set_stylebox("focus", t, focus)
		theme.set_color("font_color", t, ink)
		theme.set_color("font_hover_color", t, ink)
		theme.set_color("font_pressed_color", t, ink)
		theme.set_color("font_focus_color", t, ink)
		theme.set_color("font_hover_pressed_color", t, ink)
		theme.set_color("font_disabled_color", t, Color("#8c7b66"))
	theme.set_color("font_color", "Label", ink)
	theme.set_color("default_color", "RichTextLabel", ink)
	theme.set_font_size("normal_font_size", "RichTextLabel", 9)
	_save(theme, "res://assets/ui/theme.tres")


func _flat(bg: Color, border: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(1)
	s.set_corner_radius_all(2)
	s.content_margin_left = 6
	s.content_margin_right = 6
	s.content_margin_top = 2
	s.content_margin_bottom = 3
	return s


# ---------------------------------------------------------------- tileset

func _build_tileset() -> TileSet:
	var ts := TileSet.new()
	ts.tile_size = Vector2i(T, T)
	var src := TileSetAtlasSource.new()
	src.texture = load("res://assets/tilesets/canaan_tiles.png")
	src.texture_region_size = Vector2i(T, T)
	for y in Spec.ATLAS_ROWS:
		for x in Spec.ATLAS_COLS:
			src.create_tile(Vector2i(x, y))
	ts.add_source(src, 0)
	_save(ts, "res://assets/tilesets/canaan_tileset.tres")
	return load("res://assets/tilesets/canaan_tileset.tres")


# ---------------------------------------------------------------- objetos

func _build_props() -> void:
	sway_material = ShaderMaterial.new()
	sway_material.shader = load("res://assets/shaders/sway.gdshader")
	_save(sway_material, "res://assets/shaders/sway_material.tres")
	sway_material = load("res://assets/shaders/sway_material.tres")
	var interactable_script := load("res://scripts/interaction/interactable.gd")

	for id in PROPS:
		var def: Dictionary = PROPS[id]
		var root := StaticBody2D.new()
		root.name = id.to_pascal_case()
		root.collision_layer = 1
		root.collision_mask = 0

		var spr := Sprite2D.new()
		spr.name = "Sprite"
		spr.texture = load(ENV_TEX % id)
		spr.centered = false
		spr.offset = -def.origin
		if def.get("sway", false):
			spr.material = sway_material
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

		if def.has("inter"):
			var it: Dictionary = def.inter
			var area := Area2D.new()
			area.name = "Interactable"
			area.set_script(interactable_script)
			area.position = it.center
			area.set("kind", it.kind)
			area.set("dialogue_id", it.dialogue)
			area.set("prompt_offset", it.prompt_offset - it.center)
			area.set("prompt_text", it.get("prompt", ""))
			_own(root, root, area)
			var acs := CollisionShape2D.new()
			acs.name = "Shape"
			var circle := CircleShape2D.new()
			circle.radius = it.radius
			acs.shape = circle
			_own(root, area, acs)

		if def.has("particles"):
			_own(root, root, _particles(def.particles))

		var packed := PackedScene.new()
		packed.pack(root)
		var path: String = ENV_SCENE % id
		_save(packed, path)
		prop_scenes[id] = load(path)
		root.free()


func _particles(kind: String) -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.name = "Particles"
	var grad := Gradient.new()
	match kind:
		"smoke":
			p.position = Vector2(0, -12)
			p.amount = 5
			p.lifetime = 3.0
			p.direction = Vector2(0, -1)
			p.spread = 12.0
			p.gravity = Vector2(2, -5)
			p.initial_velocity_min = 4.0
			p.initial_velocity_max = 7.0
			p.scale_amount_min = 1.0
			p.scale_amount_max = 2.0
			grad.set_color(0, Color(0.86, 0.82, 0.76, 0.7))
			grad.set_color(1, Color(0.86, 0.82, 0.76, 0.0))
		"fire":
			p.position = Vector2(0, -5)
			p.amount = 8
			p.lifetime = 0.6
			p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
			p.emission_rect_extents = Vector2(2.5, 0.5)
			p.direction = Vector2(0, -1)
			p.spread = 20.0
			p.gravity = Vector2(0, -18)
			p.initial_velocity_min = 3.0
			p.initial_velocity_max = 7.0
			grad.set_color(0, Color("#ffd36b"))
			grad.set_color(1, Color(0.88, 0.44, 0.18, 0.0))
		"sparkle":
			p.position = Vector2(0, -6)
			p.amount = 3
			p.lifetime = 1.4
			p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
			p.emission_rect_extents = Vector2(5, 2)
			p.direction = Vector2(0, -1)
			p.gravity = Vector2(0, -4)
			p.initial_velocity_min = 0.0
			p.initial_velocity_max = 2.0
			grad.set_color(0, Color("#fff3c4"))
			grad.set_color(1, Color(0.79, 0.64, 0.15, 0.0))
	p.color_ramp = grad
	return p


# ---------------------------------------------------------------- aldeia

var _blocked: Array[Rect2] = []
var _path_cells := {}
var _plaza_cells := {}


func _build_village(ts: TileSet) -> void:
	var root := Node2D.new()
	root.name = "CanaanVillage"
	root.set_script(load("res://scripts/world/game_map.gd"))
	root.set("region_id", "canaan_village")
	root.set("map_size_tiles", Vector2i(MAP_W, MAP_H))

	var ground := _layer(root, "Ground", ts, -12)
	var patches := _layer(root, "DryGrass", ts, -11)
	var plaza := _layer(root, "Plaza", ts, -10)
	var paths := _layer(root, "Paths", ts, -9)
	var decor := _layer(root, "Decor", ts, -8)

	var world := Node2D.new()
	world.name = "World"
	world.y_sort_enabled = true
	_own(root, root, world)

	_layout_paths()
	_paint_ground(ground, patches, plaza, paths, decor)

	var spawn := Marker2D.new()
	spawn.name = "PlayerSpawn"
	spawn.position = Vector2(480, 388)
	_own(root, world, spawn)

	var player: Node2D = load("res://scenes/player/player.tscn").instantiate()
	player.position = spawn.position
	_own(root, world, player)
	_block(Rect2(spawn.position - Vector2(24, 24), Vector2(48, 40)))

	_place_structures(root, world)
	_place_npcs(root, world)
	_place_nature(root, world)
	_add_bounds(root)

	var mod := CanvasModulate.new()
	mod.name = "DaylightTint"
	mod.color = Color(1.0, 0.97, 0.91)
	_own(root, root, mod)

	var packed := PackedScene.new()
	packed.pack(root)
	_save(packed, "res://scenes/maps/canaan_village.tscn")
	root.free()


func _layer(root: Node, layer_name: String, ts: TileSet, z: int) -> TileMapLayer:
	var l := TileMapLayer.new()
	l.name = layer_name
	l.tile_set = ts
	l.z_index = z
	_own(root, root, l)
	return l


func _add_path_rect(x0: int, y0: int, x1: int, y1: int) -> void:
	for y in range(y0, y1 + 1):
		for x in range(x0, x1 + 1):
			_path_cells[Vector2i(x, y)] = true


func _layout_paths() -> void:
	var center := Vector2(30.0, 21.0)
	for y in MAP_H:
		for x in MAP_W:
			if Vector2(x + 0.5, y + 0.5).distance_to(center) <= 3.9:
				_plaza_cells[Vector2i(x, y)] = true
	_add_path_rect(0, 20, 26, 21)     # estrada oeste
	_add_path_rect(33, 20, 59, 21)    # estrada leste
	_add_path_rect(29, 10, 30, 17)    # viela norte
	_add_path_rect(15, 10, 45, 11)    # rua das casas
	_add_path_rect(29, 24, 30, 29)    # caminho do curral
	_add_path_rect(47, 14, 48, 19)    # acesso à casa leste
	_add_path_rect(12, 22, 13, 24)    # acesso à tenda


func _is_walkway(c: Vector2i) -> bool:
	return _path_cells.has(c) or _plaza_cells.has(c)


## Máscara de vizinhos (N=1, E=2, S=4, W=8); a borda do mapa conta como vizinho.
func _mask(c: Vector2i, has: Callable) -> int:
	var mask := 0
	if c.y == 0 or has.call(c + Vector2i.UP): mask |= 1
	if c.x == MAP_W - 1 or has.call(c + Vector2i.RIGHT): mask |= 2
	if c.y == MAP_H - 1 or has.call(c + Vector2i.DOWN): mask |= 4
	if c.x == 0 or has.call(c + Vector2i.LEFT): mask |= 8
	return mask


func _paint_ground(ground: TileMapLayer, patches: TileMapLayer, plaza: TileMapLayer, paths: TileMapLayer, decor: TileMapLayer) -> void:
	var noise := FastNoiseLite.new()
	noise.seed = 11
	noise.frequency = 0.07
	var dry := {}
	for y in MAP_H:
		for x in MAP_W:
			var c := Vector2i(x, y)
			if noise.get_noise_2d(x, y) > 0.3 and not _is_walkway(c):
				dry[c] = true
	var has_dry := func(c: Vector2i) -> bool: return dry.has(c)
	var has_walkway := func(c: Vector2i) -> bool: return _is_walkway(c)
	for y in MAP_H:
		for x in MAP_W:
			var c := Vector2i(x, y)
			var r := rng.randf()
			var gi := 0 if r < 0.55 else (1 if r < 0.75 else (2 if r < 0.9 else 3))
			ground.set_cell(c, 0, Spec.GRASS[gi])
			if dry.has(c):
				patches.set_cell(c, 0, Spec.overlay_coords(Spec.OVERLAY_DRY, _mask(c, has_dry)))
			if _plaza_cells.has(c):
				plaza.set_cell(c, 0, Spec.overlay_coords(Spec.OVERLAY_STONE, _mask(c, has_walkway)))
				continue
			if _path_cells.has(c):
				paths.set_cell(c, 0, Spec.path_coords(_mask(c, has_walkway)))
				continue
			var near_path := false
			for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				if _is_walkway(c + d):
					near_path = true
			var roll := rng.randf()
			if near_path and roll < 0.25:
				decor.set_cell(c, 0, Spec.PEBBLES)
			elif roll < 0.05:
				decor.set_cell(c, 0, Spec.FLOWER_YELLOW)
			elif roll < 0.08:
				decor.set_cell(c, 0, Spec.FLOWER_WHITE)
			elif roll < 0.10 or (x < 18 and y > 28 and roll < 0.2):
				decor.set_cell(c, 0, Spec.FLOWER_RED)
			elif roll < 0.18:
				decor.set_cell(c, 0, Spec.TUFT_A if roll < 0.14 else Spec.TUFT_B)


func _prop(root: Node, world: Node, id: String, pos: Vector2) -> Node2D:
	var inst: Node2D = prop_scenes[id].instantiate()
	inst.position = pos
	_own(root, world, inst)
	var def: Dictionary = PROPS[id]
	var r: Rect2 = def.get("col", Rect2(-6, -4, 12, 4))
	_block(Rect2(pos + r.position, r.size).grow(6))
	return inst


func _place_structures(root: Node, world: Node) -> void:
	_prop(root, world, "well", Vector2(480, 344))
	_prop(root, world, "journal", Vector2(516, 388))

	_prop(root, world, "house_small", Vector2(336, 152))
	_prop(root, world, "house_wide", Vector2(608, 152))
	_prop(root, world, "house_small", Vector2(768, 216))
	_prop(root, world, "oven", Vector2(384, 150))
	_prop(root, world, "sacks", Vector2(292, 156))
	_prop(root, world, "pots", Vector2(668, 156))
	_prop(root, world, "jar", Vector2(556, 154))
	_prop(root, world, "jar", Vector2(796, 222))
	_prop(root, world, "basket", Vector2(740, 222))

	_prop(root, world, "tent", Vector2(200, 400))
	_prop(root, world, "firepit", Vector2(244, 404))
	_prop(root, world, "firewood", Vector2(164, 404))
	_prop(root, world, "basket", Vector2(232, 418))

	_prop(root, world, "stall_produce", Vector2(408, 392))
	_prop(root, world, "stall_textiles", Vector2(560, 392))
	_prop(root, world, "jar", Vector2(436, 398))
	_prop(root, world, "jar", Vector2(442, 401))
	_prop(root, world, "sacks", Vector2(588, 398))

	_prop(root, world, "boundary_stone", Vector2(40, 312))
	_prop(root, world, "boundary_stone", Vector2(920, 312))

	# Curral (x 25..35, y 30..37) com porteira aberta no norte (x 29..30).
	for x in range(25, 36):
		if x != 29 and x != 30:
			_prop(root, world, "fence_h", Vector2(x * T + 8, 30 * T + 15))
		_prop(root, world, "fence_h", Vector2(x * T + 8, 37 * T + 15))
	for y in range(31, 37):
		_prop(root, world, "fence_v", Vector2(25 * T + 8, y * T + 15))
		_prop(root, world, "fence_v", Vector2(35 * T + 8, y * T + 15))
	_block(Rect2(25 * T, 30 * T, 11 * T, 8 * T))


func _place_npcs(root: Node, world: Node) -> void:
	var npc_scene: PackedScene = load("res://scenes/npcs/npc.tscn")
	var npcs := [
		["Adina", "adina", Vector2(520, 468)],
		["Ezer", "ezer", Vector2(690, 178)],
		["Yaron", "yaron", Vector2(372, 390)],
		["Ari", "ari", Vector2(440, 372)],
		["Sheep1", "sheep", Vector2(440, 528)],
		["Sheep2", "sheep", Vector2(496, 556)],
		["Sheep3", "sheep", Vector2(536, 516)],
	]
	for n in npcs:
		var inst: Node2D = npc_scene.instantiate()
		inst.name = n[0]
		inst.position = n[2]
		inst.set("character_id", n[1])
		_own(root, world, inst)


func _place_nature(root: Node, world: Node) -> void:
	# Olival a nordeste, em fileiras.
	for gx in range(47, 58, 3):
		for gy in range(3, 10, 3):
			var p := Vector2(gx * T + 8 + rng.randi_range(-4, 4), gy * T + 12 + rng.randi_range(-3, 3))
			_try_place(root, world, "tree_olive", p, 0)
	# Cinturão de árvores nas bordas do mapa.
	for y in MAP_H:
		for x in MAP_W:
			var edge := mini(mini(x, y), mini(MAP_W - 1 - x, MAP_H - 1 - y))
			if edge > 2 or rng.randf() > 0.45:
				continue
			var id := "tree_oak" if rng.randf() < 0.55 else "tree_olive"
			var p2 := Vector2(x * T + 8 + rng.randi_range(-5, 5), y * T + 14 + rng.randi_range(-4, 4))
			_try_place(root, world, id, p2, 2)
	# Árvores soltas, arbustos e pedras.
	var free_trees := [Vector2(120, 136), Vector2(212, 240), Vector2(96, 470), Vector2(700, 470),
		Vector2(836, 380), Vector2(268, 560), Vector2(650, 600), Vector2(150, 300), Vector2(860, 520)]
	for p3 in free_trees:
		_try_place(root, world, "tree_olive" if rng.randf() < 0.6 else "tree_oak", p3, 1)
	for i in 60:
		var p4 := Vector2(rng.randf_range(40, MAP_W * T - 40), rng.randf_range(40, MAP_H * T - 30))
		var roll := rng.randf()
		var id2 := "bush" if roll < 0.5 else ("rock_small" if roll < 0.8 else "rock_big")
		_try_place(root, world, id2, p4, 1)


func _try_place(root: Node, world: Node, id: String, pos: Vector2, path_margin: int) -> void:
	var def: Dictionary = PROPS[id]
	var r: Rect2 = def.get("col", Rect2(-6, -4, 12, 4))
	var foot := Rect2(pos + r.position, r.size).grow(4)
	for b in _blocked:
		if b.intersects(foot):
			return
	var cell := Vector2i(int(pos.x) / T, int(pos.y) / T)
	for dy in range(-path_margin - 1, path_margin + 2):
		for dx in range(-path_margin - 1, path_margin + 2):
			if _is_walkway(cell + Vector2i(dx, dy)) and absi(dy) <= path_margin + (1 if dy > 0 else 0):
				return
	if pos.x < 8 or pos.y < 20 or pos.x > MAP_W * T - 8 or pos.y > MAP_H * T:
		return
	_prop(root, world, id, pos)
	# Copa alta: evita outra árvore colada logo acima/abaixo.
	if id.begins_with("tree"):
		_block(Rect2(pos - Vector2(14, 30), Vector2(28, 34)))


func _block(r: Rect2) -> void:
	_blocked.append(r)


func _add_bounds(root: Node) -> void:
	var body := StaticBody2D.new()
	body.name = "Bounds"
	body.collision_layer = 1
	_own(root, root, body)
	var w := MAP_W * T
	var h := MAP_H * T
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


# ---------------------------------------------------------------- utilidades

func _own(root: Node, parent: Node, child: Node) -> void:
	parent.add_child(child)
	child.owner = root


func _save(res: Resource, path: String) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	var err := ResourceSaver.save(res, path)
	if err != OK:
		push_error("build_world: falha ao salvar %s (%s)" % [path, error_string(err)])
