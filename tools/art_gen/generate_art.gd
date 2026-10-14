extends SceneTree
## Gera a arte PROVISÓRIA do protótipo, pixel a pixel, a partir das paletas
## em art_spec.gd. Nenhum asset de terceiros é usado.
##
## Uso (na raiz do projeto):
##   godot --headless --path . --script res://tools/art_gen/generate_art.gd
## Depois rode `godot --headless --path . --import` e o build_world.gd.
##
## Todos os PNGs gerados aqui estão listados em docs/art_bible.md como
## "provisórios" e devem ser substituídos por sprites desenhados à mão.

const Spec = preload("res://tools/art_gen/art_spec.gd")
const PC = preload("res://tools/art_gen/pixel_canvas.gd")

const INK := Color("#2b1d14")

var rng := RandomNumberGenerator.new()


func _init() -> void:
	if "--v04-only" in OS.get_cmdline_user_args():
		_v04_art()
		print("generate_art: concluido (v0.4)")
		quit()
		return
	if "--v05-only" in OS.get_cmdline_user_args():
		_palettes()
		_v05_art()
		print("generate_art: concluido (v0.5)")
		quit()
		return
	rng.seed = 7_2026
	_palettes()
	_tiles()
	_characters()
	_sheep()
	_props()
	_ui()
	_menu_background()
	_v04_art()
	_v05_art()
	print("generate_art: concluido")
	quit()


## v0.5: terras, objetos, personagens e ícones das quatro experiências
## (Egito, mar, campos e noite de Belém). Sempre por último, com sementes próprias.
func _v05_art() -> void:
	var lands = load("res://tools/art_gen/art_lands.gd").new(self)
	lands.generate()


# ---------------------------------------------------------------- v0.4: regiões novas
# Sempre por último e com semente própria: não altera nenhum PNG anterior.

const NEW_LOOKS := {
	"malik": {
		"skin": "#b07850", "skin_shade": "#8e5e3c",
		"robe": "#b8864a", "robe_shade": "#946a36", "robe_light": "#cfa066",
		"sash": "#2f5d9e", "head": "cloth", "head_color": "#e2d2ad", "head_shade": "#bfae88",
		"band": "#795437", "hair": "#2b1d14", "beard": true,
	},
	"rafi": {
		"skin": "#a06a45", "skin_shade": "#7e5134",
		"robe": "#8e7a5a", "robe_shade": "#6f5f44", "robe_light": "#a8946f",
		"sash": "#5a3d27", "head": "cloth", "head_color": "#d8ccb4", "head_shade": "#b5a98f",
		"band": "#5a3d27", "hair": "#cfc6b4", "beard": true,
	},
	"talia": {
		"skin": "#c08a60", "skin_shade": "#9c6a45",
		"robe": "#9e5a3f", "robe_shade": "#7e4530", "robe_light": "#b87458",
		"sash": "#7a8b3a", "head": "veil", "head_color": "#d9b98a", "head_shade": "#b8986a",
		"band": "#7a8b3a", "hair": "#2e1d12", "beard": false,
	},
	"oren": {
		"skin": "#b9805a", "skin_shade": "#966243",
		"robe": "#6e7f4a", "robe_shade": "#566339", "robe_light": "#87985f",
		"sash": "#b8734d", "head": "cloth", "head_color": "#8b5a2b", "head_shade": "#6d4420",
		"band": "#2b1d14", "hair": "#2b1d14", "beard": true,
	},
}


func _v04_art() -> void:
	rng.seed = 4_2026
	for id in NEW_LOOKS:
		var look: Dictionary = NEW_LOOKS[id]
		var sheet := PC.new(24 * 6, 32 * 4)
		for dir in 4:
			for frame in 6:
				sheet.blit(_character_frame(dir, frame, look), frame * 24, dir * 32)
		sheet.save("res://assets/characters/%s.png" % id)
	_cistern().save("res://assets/environments/cistern.png")
	_item_icons()


## Cisterna escavada na rocha: anel de pedras baixo em volta de uma abertura escura.
func _cistern():
	var cv = PC.new(32, 22)
	cv.ellipse(16, 13, 14, 7, Color("#7a6a56"))
	cv.ellipse(16, 12, 13, 6, Color("#a8987c"))
	for i in 10:
		var ang := TAU * i / 10.0
		cv.ellipse(16 + cos(ang) * 11, 12 + sin(ang) * 4.6, 2.4, 1.8, Color("#b9a886") if i % 2 == 0 else Color("#9c8a72"))
	cv.ellipse(16, 12, 7.5, 3.2, Color("#3a2a22"))
	cv.ellipse(16, 12.6, 6, 2.2, Color("#24180f"))
	cv.speckle(Rect2i(0, 4, 32, 16), [Color("#7a8b3a")], 0.05, rng)
	cv.outline(INK)
	cv.shadow(16, 19.5, 14, 2)
	return cv


func _icon_canvas():
	return PC.new(12, 12)


func _item_icons() -> void:
	var dir := "res://assets/items/"
	var cv = _icon_canvas()
	# Fibras vegetais: feixe amarrado
	for x in [3, 4, 5, 6, 7, 8]:
		cv.line(x, 1 + (x % 2), x + (1 if x > 5 else -1), 10, Color("#a3b14b") if x % 2 == 0 else Color("#c8c070"))
	cv.rect(2, 6, 8, 1, Color("#795437"))
	cv.outline(INK)
	cv.save(dir + "plant_fiber.png")
	# Lenha seca: três gravetos
	cv = _icon_canvas()
	for i in 3:
		cv.line(1, 8 - i * 2 + i, 10, 4 - i + i * 2, Color("#795437"))
		cv.px(1, 8 - i * 2 + i, Color("#c9a06c"))
	cv.outline(INK)
	cv.save(dir + "dry_wood.png")
	# Odre de couro
	cv = _icon_canvas()
	cv.ellipse(6, 7, 4, 3.5, Color("#8b5a2b"))
	cv.ellipse(5.5, 6.5, 3, 2.5, Color("#a8713d"))
	cv.rect(8, 2, 2, 3, Color("#6d4420"))
	cv.rect(8, 1, 2, 1, Color("#c9b48a"))
	cv.outline(INK)
	cv.save(dir + "water_skin.png")
	# Corda enrolada
	cv = _icon_canvas()
	cv.ellipse(6, 6, 4.5, 4.5, Color("#c2a878"))
	cv.ellipse(6, 6, 2.5, 2.5, Color(0, 0, 0, 0))
	for i in 6:
		var ang := TAU * i / 6.0
		cv.px(roundi(6 + cos(ang) * 3.5), roundi(6 + sin(ang) * 3.5), Color("#8e7a5a"))
	cv.outline(INK)
	cv.save(dir + "rope.png")
	# Pão de cevada (redondo, achatado)
	cv = _icon_canvas()
	cv.ellipse(6, 7, 5, 3.5, Color("#a8713d"))
	cv.ellipse(5.5, 6.5, 4.2, 2.8, Color("#d6a35c"))
	cv.px(4, 6, Color("#e8c27a"))
	cv.px(7, 7, Color("#8e5e36"))
	cv.outline(INK)
	cv.save(dir + "barley_bread.png")
	# Figos secos
	cv = _icon_canvas()
	for p in [Vector2(4, 7), Vector2(8, 7), Vector2(6, 4)]:
		cv.ellipse(p.x, p.y, 2.4, 2.2, Color("#6e4a5e"))
		cv.px(int(p.x) - 1, int(p.y) - 1, Color("#9c7088"))
	cv.outline(INK)
	cv.save(dir + "dried_figs.png")
	# Cesto de provisões (item de missão)
	cv = _icon_canvas()
	cv.ellipse(6, 8, 5, 3, Color("#9c7a3e"))
	cv.ellipse(6, 7, 4.5, 2, Color("#c9a45c"))
	cv.ellipse(4.5, 5.5, 1.8, 1.5, Color("#d6a35c"))
	cv.ellipse(7.5, 5.5, 1.6, 1.4, Color("#6e4a5e"))
	cv.line(2, 6, 6, 2, Color("#795437"))
	cv.line(6, 2, 10, 6, Color("#795437"))
	cv.outline(INK)
	cv.save(dir + "provisions_basket.png")
	# Tecido de lã dobrado
	cv = _icon_canvas()
	cv.rect(2, 4, 8, 6, Color("#d8ccb4"))
	cv.rect(2, 4, 8, 1, Color("#efe4cc"))
	cv.rect(2, 7, 8, 1, Color("#9e5a3f"))
	cv.outline(INK)
	cv.save(dir + "wool_cloth.png")


# ---------------------------------------------------------------- paletas

func _palettes() -> void:
	var dir := "res://assets/palettes"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
	var max_cols := 0
	for pal_name in Spec.PALETTES:
		max_cols = maxi(max_cols, Spec.PALETTES[pal_name].size())
	var swatch := PC.new(max_cols * 12, Spec.PALETTES.size() * 12)
	var row := 0
	for pal_name in Spec.PALETTES:
		var pal: Dictionary = Spec.PALETTES[pal_name]
		var gpl := "GIMP Palette\nName: Caminhos da Promessa - %s\nColumns: 8\n#\n" % pal_name
		var col := 0
		for color_name in pal:
			var colr := Color(pal[color_name])
			gpl += "%3d %3d %3d\t%s\n" % [int(colr.r8), int(colr.g8), int(colr.b8), color_name]
			swatch.rect(col * 12, row * 12, 12, 12, colr)
			col += 1
		var f := FileAccess.open("%s/%s.gpl" % [dir, pal_name], FileAccess.WRITE)
		f.store_string(gpl)
		f.close()
		row += 1
	swatch.save(dir + "/palettes.png")


# ---------------------------------------------------------------- tiles

func _tiles() -> void:
	var atlas := PC.new(Spec.ATLAS_COLS * 16, Spec.ATLAS_ROWS * 16)

	for i in Spec.GRASS.size():
		_grass_tile(atlas, Spec.GRASS[i] * 16, Color("#7a8b3a"),
			[Color("#6a7a30"), Color("#8c9d45")], i)
	for i in Spec.DRY_GRASS.size():
		_grass_tile(atlas, Spec.DRY_GRASS[i] * 16, Color("#9fa84a"),
			[Color("#8c963e"), Color("#b5b85e"), Color("#c4b46c")], 10 + i)
	for i in Spec.STONE.size():
		_stone_tile(atlas, Spec.STONE[i] * 16, i)

	_flower_tile(atlas, Spec.FLOWER_YELLOW * 16, Color("#e8c23a"), Color("#fff3c4"))
	_flower_tile(atlas, Spec.FLOWER_WHITE * 16, Color("#f4f0e0"), Color("#e8c23a"))
	_flower_tile(atlas, Spec.FLOWER_RED * 16, Color("#c8372d"), Color("#2b1d14"))
	_pebble_tile(atlas, Spec.PEBBLES * 16)
	_tuft_tile(atlas, Spec.TUFT_A * 16, 3)
	_tuft_tile(atlas, Spec.TUFT_B * 16, 5)

	var dirt_painter := func(_x: int, _y: int) -> Color:
		var r := rng.randf()
		if r < 0.14:
			return Color("#9a6638")
		elif r < 0.24:
			return Color("#c48e58")
		elif r < 0.27:
			return Color("#c8b89a")
		return Color("#b07a45")
	var dry_painter := func(_x: int, _y: int) -> Color:
		var r := rng.randf()
		if r < 0.12:
			return Color("#8c963e")
		elif r < 0.22:
			return Color("#b5b85e")
		elif r < 0.26:
			return Color("#c4b46c")
		return Color("#9fa84a")
	var stone_src := PC.new(16, 16)
	_stone_tile(stone_src, Vector2i.ZERO, 0)
	var stone_painter := func(x: int, y: int) -> Color:
		return stone_src.get_px(x, y)

	for mask in 16:
		_overlay_tile(atlas, Spec.overlay_coords(Spec.OVERLAY_PATH, mask) * 16, mask, dirt_painter, Color("#8e5e36"), 0.35)
		_overlay_tile(atlas, Spec.overlay_coords(Spec.OVERLAY_DRY, mask) * 16, mask, dry_painter, Color("#8c963e"), 0.5)
		_overlay_tile(atlas, Spec.overlay_coords(Spec.OVERLAY_STONE, mask) * 16, mask, stone_painter, Color("#a3937a"), 0.2)

	atlas.save("res://assets/tilesets/canaan_tiles.png")


func _grass_tile(a, o: Vector2i, base: Color, specks: Array, variant: int) -> void:
	a.rect(o.x, o.y, 16, 16, base)
	a.speckle(Rect2i(o, Vector2i(16, 16)), specks, 0.22, rng)
	var blades := 2 + variant % 3
	for b in blades:
		var x := o.x + rng.randi_range(1, 14)
		var y := o.y + rng.randi_range(2, 14)
		a.px(x, y, Color("#5e6e2a"))
		a.px(x, y - 1, Color("#5e6e2a"))
		a.px(x + 1, y - 1, Color("#a3b14b"))


func _stone_tile(a, o: Vector2i, variant: int) -> void:
	var base := Color("#c8b89a")
	var mortar := Color("#a3937a")
	var light := Color("#dccdb0")
	a.rect(o.x, o.y, 16, 16, base)
	var split_y := 7 if variant == 0 else 9
	var top_x := 6 if variant == 0 else 10
	var bot_x := 11 if variant == 0 else 4
	for x in 16:
		a.px(o.x + x, o.y + split_y, mortar)
		a.px(o.x + x, o.y + 15, mortar)
	for y in range(0, split_y):
		a.px(o.x + top_x, o.y + y, mortar)
	for y in range(split_y, 16):
		a.px(o.x + bot_x, o.y + y, mortar)
	for x in 16:
		if x != top_x:
			a.px(o.x + x, o.y, light)
		if x != bot_x:
			a.px(o.x + x, o.y + split_y + 1, light)
	a.speckle(Rect2i(o, Vector2i(16, 16)), [Color("#b8a888"), Color("#d4c6a8")], 0.12, rng, base)


func _flower_tile(a, o: Vector2i, petal: Color, center: Color) -> void:
	var spots := [Vector2i(3, 4), Vector2i(10, 3), Vector2i(6, 10), Vector2i(12, 11)]
	for s in spots:
		var p: Vector2i = o + s + Vector2i(rng.randi_range(-1, 1), rng.randi_range(-1, 1))
		a.px(p.x, p.y + 2, Color("#5e6e2a"))
		a.px(p.x - 1, p.y + 1, Color("#6a7a30"))
		a.px(p.x, p.y - 1, petal)
		a.px(p.x - 1, p.y, petal)
		a.px(p.x + 1, p.y, petal)
		a.px(p.x, p.y + 1, petal)
		a.px(p.x, p.y, center)


func _pebble_tile(a, o: Vector2i) -> void:
	for i in 5:
		var x := o.x + rng.randi_range(2, 13)
		var y := o.y + rng.randi_range(2, 13)
		a.px(x, y, Color("#c8b89a"))
		a.px(x + 1, y, Color("#b3a284"))
		a.px(x, y + 1, Color(0.17, 0.11, 0.08, 0.35))


func _tuft_tile(a, o: Vector2i, count: int) -> void:
	for i in count:
		var x := o.x + rng.randi_range(2, 13)
		var y := o.y + rng.randi_range(4, 14)
		a.px(x, y, Color("#4f5e24"))
		a.px(x - 1, y - 1, Color("#5e6e2a"))
		a.px(x + 1, y - 1, Color("#5e6e2a"))
		a.px(x - 1, y - 2, Color("#8c9d45"))
		a.px(x + 1, y - 3, Color("#a3b14b"))


## Sobreposição com bordas irregulares (caminho, grama seca, pedra). Cantos são
## preenchidos quando os dois vizinhos ortogonais existem, para áreas largas
## ficarem contínuas. `painter(x, y)` devolve a cor de cada pixel interno.
func _overlay_tile(a, o: Vector2i, mask: int, painter: Callable, edge_color: Color, erosion: float) -> void:
	var n := mask & 1 != 0
	var e := mask & 2 != 0
	var s := mask & 4 != 0
	var wv := mask & 8 != 0
	var solid := []
	for y in 16:
		var row := []
		for x in 16:
			var in_x := x >= 3 and x <= 12
			var in_y := y >= 3 and y <= 12
			var on := in_x and in_y
			on = on or (n and y < 3 and in_x) or (s and y > 12 and in_x)
			on = on or (e and x > 12 and in_y) or (wv and x < 3 and in_y)
			on = on or (n and e and x > 12 and y < 3) or (n and wv and x < 3 and y < 3)
			on = on or (s and e and x > 12 and y > 12) or (s and wv and x < 3 and y > 12)
			row.append(on)
		solid.append(row)
	# Arredonda cantos externos.
	var corners := [
		[Vector2i(3, 3), not n and not wv], [Vector2i(12, 3), not n and not e],
		[Vector2i(3, 12), not s and not wv], [Vector2i(12, 12), not s and not e]]
	for cdef in corners:
		if cdef[1]:
			var p: Vector2i = cdef[0]
			solid[p.y][p.x] = false
	# Erosão aleatória nas bordas reais.
	var eroded := solid.duplicate(true)
	for y in 16:
		for x in 16:
			if solid[y][x] and _path_edge(solid, x, y) and rng.randf() < erosion:
				eroded[y][x] = false
	for y in 16:
		for x in 16:
			if eroded[y][x]:
				var col: Color = painter.call(x, y)
				if _path_edge(eroded, x, y):
					col = edge_color
				a.px(o.x + x, o.y + y, col)


func _path_edge(grid: Array, x: int, y: int) -> bool:
	for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var nx: int = x + d.x
		var ny: int = y + d.y
		if nx < 0 or ny < 0 or nx > 15 or ny > 15:
			continue
		if not grid[ny][nx]:
			return true
	return false


# ---------------------------------------------------------------- personagens

const LOOKS := {
	"player": {
		"skin": "#c98e62", "skin_shade": "#a8714c",
		"robe": "#8a6f4e", "robe_shade": "#6e5639", "robe_light": "#a48a66",
		"sash": "#2f5d9e", "head": "cloth", "head_color": "#e2d2ad", "head_shade": "#bfae88",
		"band": "#8b5a2b", "hair": "#3b2618", "beard": false,
	},
	"adina": {
		"skin": "#b9805a", "skin_shade": "#966243",
		"robe": "#6f7f9e", "robe_shade": "#55617e", "robe_light": "#8796b2",
		"sash": "#c9a227", "head": "veil", "head_color": "#b8734d", "head_shade": "#95593a",
		"band": "#c9a227", "hair": "#2e1d12", "beard": false,
	},
	"ezer": {
		"skin": "#a8714c", "skin_shade": "#86573a",
		"robe": "#c2a878", "robe_shade": "#a08a5e", "robe_light": "#d6c096",
		"sash": "#795437", "head": "cloth", "head_color": "#8b5a2b", "head_shade": "#6d4420",
		"band": "#2b1d14", "hair": "#d8d0c0", "beard": true,
	},
	"yaron": {
		"skin": "#c08a60", "skin_shade": "#9c6a45",
		"robe": "#9e3f32", "robe_shade": "#7c3026", "robe_light": "#b85a4a",
		"sash": "#e0b03a", "head": "cloth", "head_color": "#f0e2c0", "head_shade": "#cdbd98",
		"band": "#2f5d9e", "hair": "#2b1d14", "beard": true,
	},
	"ari": {
		"skin": "#c98e62", "skin_shade": "#a8714c",
		"robe": "#a3b14b", "robe_shade": "#7f8b38", "robe_light": "#bcc86a",
		"sash": "#b8734d", "head": "hair", "head_color": "#3b2618", "head_shade": "#2b1a10",
		"band": "#3b2618", "hair": "#3b2618", "beard": false, "child": true,
	},
}


func _characters() -> void:
	for id in LOOKS:
		var look: Dictionary = LOOKS[id]
		var sheet := PC.new(24 * 6, 32 * 4)
		for dir in 4:
			for frame in 6:
				var f = _character_frame(dir, frame, look)
				sheet.blit(f, frame * 24, dir * 32)
		sheet.save("res://assets/characters/%s.png" % id)


## dir: 0 baixo, 1 esquerda, 2 direita, 3 cima. Quadros 0-3 andar, 4-5 parado.
func _character_frame(dir: int, frame: int, look: Dictionary):
	if dir == 1:
		return _character_frame(2, frame, look).flipped_x()
	var cv = PC.new(24, 32)
	var child: bool = look.get("child", false)
	var walking := frame < 4
	var bob := 0
	var step := 0
	if walking:
		bob = 1 if frame % 2 == 1 else 0
		step = [0, -1, 0, 1][frame]
	else:
		bob = 1 if frame == 5 else 0

	var skin := Color(look.skin)
	var skin_sh := Color(look.skin_shade)
	var robe := Color(look.robe)
	var robe_sh := Color(look.robe_shade)
	var robe_li := Color(look.robe_light)
	var sash := Color(look.sash)
	var head_c := Color(look.head_color)
	var head_sh := Color(look.head_shade)
	var band := Color(look.band)
	var hair := Color(look.hair)
	var sandal := Color(String(look.get("feet", "#5a3a22")))
	# Campos opcionais (v0.5): ausentes, o quadro sai idêntico ao de antes.
	var stoop := int(look.get("stoop", 0))

	var cx := 12
	var top := (18 if child else 13) + stoop
	var head_cy := (13 if child else 8) + stoop
	var head_r := 4.5 if child else 5.0
	var hw_top := 3.0 if child else 4.0
	var hw_bot := 4.5 if child else 6.0
	var side := dir == 2
	if side:
		hw_top -= 0.5
		hw_bot -= 1.0

	# Pés
	if side:
		cv.rect(cx - 2 + step * 2, 29, 4, 2, sandal)
		cv.rect(cx - 2 - step * 2, 29, 3, 2, sandal.darkened(0.2))
	else:
		var lf := 29 + (1 if step == -1 else 0) - (1 if step == 1 else 0)
		var rf := 29 + (1 if step == 1 else 0) - (1 if step == -1 else 0)
		cv.rect(cx - 4, lf, 3, 2, sandal)
		cv.rect(cx + 1, rf, 3, 2, sandal)

	# Túnica (robe_bottom < 29: saiote ou túnica curta, com as pernas à mostra)
	var robe_bottom := int(look.get("robe_bottom", 29))
	if robe_bottom < 29:
		if side:
			cv.rect(cx - 1 + step, robe_bottom, 2, 29 - robe_bottom, skin)
			cv.rect(cx - 1 - step, robe_bottom, 2, 29 - robe_bottom, skin_sh)
		else:
			cv.rect(cx - 3, robe_bottom, 2, 29 - robe_bottom, skin)
			cv.rect(cx + 1, robe_bottom, 2, 29 - robe_bottom, skin_sh)
	for y in range(top + bob, robe_bottom):
		var t := float(y - top - bob) / float(robe_bottom - top - bob)
		var hw := roundi(lerpf(hw_top, hw_bot, t))
		cv.rect(cx - hw, y, hw * 2, 1, robe)
		cv.px(cx - hw, y, robe_li)
		cv.px(cx + hw - 1, y, robe_sh)
		cv.px(cx + hw - 2, y, robe_sh)
	cv.rect(cx - roundi(hw_bot) + 1, robe_bottom - 1, roundi(hw_bot) * 2 - 2, 1, robe_sh)
	if look.has("hem"):
		cv.rect(cx - roundi(hw_bot) + 1, robe_bottom - 2, roundi(hw_bot) * 2 - 2, 1, Color(String(look.hem)))
	if look.has("clavi") and dir != 3 and not side:
		for x in [cx - 2, cx + 1]:
			cv.rect(x, top + bob, 1, robe_bottom - top - bob - 1, Color(String(look.clavi)))
	var sash_y := top + bob + (4 if child else 6)
	var sash_hw := roundi(lerpf(hw_top, hw_bot, float(sash_y - top - bob) / float(robe_bottom - top - bob)))
	cv.rect(cx - sash_hw, sash_y, sash_hw * 2, 1, sash)
	if not side:
		cv.px(cx + 1, sash_y + 1, sash)
	if look.has("mantle"):
		var mc := Color(String(look.mantle))
		var rows := 4 if child else 6
		for y in range(top + bob, top + bob + rows):
			var mhw := roundi(lerpf(hw_top, hw_bot, float(y - top - bob) / float(robe_bottom - top - bob))) + 1
			cv.rect(cx - mhw, y, mhw * 2, 1, mc)
			cv.px(cx + mhw - 1, y, mc.darkened(0.2))
		var edge_c := Color(String(look.get("mantle_edge", ""))) if look.has("mantle_edge") else mc.darkened(0.25)
		var ehw := roundi(lerpf(hw_top, hw_bot, float(rows - 1) / float(robe_bottom - top - bob))) + 1
		cv.rect(cx - ehw, top + bob + rows - 1, ehw * 2, 1, edge_c)
	if look.has("collar") and dir == 0:
		cv.rect(cx - 3, top + bob, 6, 1, Color(String(look.collar)))
		cv.rect(cx - 2, top + bob + 1, 4, 1, Color(String(look.collar)).darkened(0.15))
	if look.has("bag") and dir != 3:
		var bag_c := Color(String(look.bag))
		if side:
			cv.rect(cx - 4, top + bob + 7, 3, 3, bag_c)
		else:
			cv.line(cx - 3, top + bob, cx + 3, top + bob + 7, bag_c.darkened(0.2))
			cv.rect(cx + 3, top + bob + 7, 3, 3, bag_c)

	# Braços
	var arm_len := 5 if child else 7
	if side:
		var ax := cx - 1 + step
		cv.rect(ax, top + 1 + bob, 2, arm_len, robe_sh)
		cv.rect(ax, top + 1 + bob + arm_len - 1, 2, 2, skin)
	else:
		var lx := cx - roundi(hw_top) - 2
		var rx := cx + roundi(hw_top)
		cv.rect(lx, top + 1 + bob + step, 2, arm_len, robe_li if dir == 0 else robe)
		cv.rect(lx, top + bob + arm_len + step, 2, 2, skin)
		cv.rect(rx, top + 1 + bob - step, 2, arm_len, robe_sh)
		cv.rect(rx, top + bob + arm_len - step, 2, 2, skin_sh)

	if look.has("basket") and dir != 3:
		var bk := Color(String(look.basket))
		var bx := cx - 5 if side else cx + roundi(hw_top) + 2
		cv.ellipse(bx, top + bob + 11, 3, 2.2, bk.darkened(0.2))
		cv.ellipse(bx - 0.5, top + bob + 10.5, 2.5, 1.6, bk)
		cv.px(bx - 1, top + bob + 9, Color("#e8c27a"))
		cv.px(bx + 1, top + bob + 9, Color("#d9b860"))
	if look.has("staff"):
		var wood := Color(String(look.staff))
		var sx := cx + 4 if side else (cx - roundi(hw_top) - 3 if dir == 3 else cx + roundi(hw_top) + 2)
		var sy0 := head_cy + bob - 4
		cv.rect(sx, sy0, 1, 30 - sy0, wood)
		cv.px(sx, sy0, wood.lightened(0.25))
		if look.get("crook", false):
			cv.px(sx + 1, sy0 - 1, wood)
			cv.px(sx + 2, sy0, wood)
			cv.px(sx + 2, sy0 + 1, wood)

	# Cabeça
	var hy := head_cy + bob
	var hrx := head_r - (0.5 if side else 0.0)
	cv.ellipse(cx, hy, hrx, head_r, skin)
	for y in range(hy - 6, hy + 6):
		for x in range(cx + 2, cx + 7):
			if cv.get_px(x, y).is_equal_approx(skin) and x >= cx + 3:
				cv.px(x, y, skin_sh)

	if dir == 0:
		cv.px(cx - 2, hy + 1, INK)
		cv.px(cx + 1, hy + 1, INK)
		if child:
			cv.px(cx - 3, hy + 2, Color("#d9876a"))
			cv.px(cx + 2, hy + 2, Color("#d9876a"))
	elif side:
		cv.px(cx + 2, hy + 1, INK)
		cv.px(cx + 4, hy + 2, skin_sh)

	if look.beard and dir != 3:
		if side:
			cv.rect(cx, hy + 3, 4, 2, hair)
			cv.rect(cx + 1, hy + 5, 2, 1, hair)
		else:
			cv.rect(cx - 3, hy + 3, 6, 2, hair)
			cv.rect(cx - 2, hy + 5, 4, 1, hair)

	_headwear(cv, look.head, dir, cx, hy, head_r, head_c, head_sh, band)

	cv.outline(INK)
	cv.shadow(cx, 30.5, 6.5 if not child else 5.0, 1.8)
	return cv


func _headwear(cv, kind: String, dir: int, cx: int, hy: int, r: float, col: Color, sh: Color, band: Color) -> void:
	var side := dir == 2
	match kind:
		"cloth", "veil":
			var drape := 8 if kind == "cloth" else 12
			var dw := 2 if kind == "cloth" else 3
			if dir == 3:
				cv.ellipse(cx, hy, r + 1.0, r + 0.5, col)
				cv.rect(cx - roundi(r) - 1, hy, roundi(r) * 2 + 2, drape - 2, col)
				cv.rect(cx + roundi(r) - 1, hy, 2, drape - 2, sh)
				cv.rect(cx - roundi(r), hy - 2, roundi(r) * 2, 1, band)
			elif side:
				cv.ellipse(cx - 0.5, hy - 1, r + 0.5, r - 0.5, col, hy - 1)
				cv.rect(cx - roundi(r), hy - 1, dw + 2, drape, col)
				cv.rect(cx - roundi(r) + dw + 1, hy - 1, 1, drape, sh)
				cv.rect(cx - roundi(r), hy - 3, roundi(r) * 2, 1, band)
			else:
				cv.ellipse(cx, hy - 1, r + 1.0, r - 0.5, col, hy - 1 - (1 if kind == "veil" else 0))
				cv.rect(cx - roundi(r) - 1, hy - 1, dw, drape, col)
				cv.rect(cx + roundi(r) + 1 - dw, hy - 1, dw, drape, sh)
				cv.rect(cx - roundi(r), hy - 3, roundi(r) * 2, 1, band)
		"hair":
			if dir == 3:
				cv.ellipse(cx, hy, r + 0.5, r + 0.3, col)
			elif side:
				cv.ellipse(cx - 0.5, hy - 1, r + 0.5, r - 0.5, col, hy - 1)
				cv.rect(cx - roundi(r), hy - 1, 3, 4, col)
			else:
				cv.ellipse(cx, hy - 1, r + 0.5, r - 0.5, col, hy - 1)
				cv.rect(cx - roundi(r), hy - 1, 1, 3, col)
				cv.rect(cx + roundi(r) - 1, hy - 1, 1, 3, sh)


# ---------------------------------------------------------------- ovelha

func _sheep() -> void:
	var sheet := PC.new(24 * 6, 20 * 2)
	for frame in 6:
		var f = _sheep_frame(frame)
		sheet.blit(f, frame * 24, 0)
		sheet.blit(f.flipped_x(), frame * 24, 20)
	sheet.save("res://assets/characters/sheep.png")


func _sheep_frame(frame: int):
	var cv = PC.new(24, 20)
	var walking := frame < 4
	var bob := 1 if walking and frame % 2 == 1 else 0
	var grazing := frame == 5
	var leg := Color("#4a3a30")
	var lift_a := 1 if walking and frame == 1 else 0
	var lift_b := 1 if walking and frame == 3 else 0
	cv.rect(7, 15 - lift_a, 1, 3, leg)
	cv.rect(15, 15 - lift_a, 1, 3, leg)
	cv.rect(9, 15 - lift_b, 1, 3, leg.darkened(0.2))
	cv.rect(17, 15 - lift_b, 1, 3, leg.darkened(0.2))
	var wool := Color("#ede3cf")
	var wool_sh := Color("#cfc2a8")
	cv.ellipse(12, 11 + bob, 8, 5, wool_sh)
	cv.ellipse(11.5, 10.5 + bob, 7.5, 4.5, wool)
	for bump in [Vector2(7, 7), Vector2(11, 6), Vector2(15, 7)]:
		cv.ellipse(bump.x, bump.y + bob, 2.5, 2, wool)
	cv.speckle(Rect2i(3, 4, 18, 12), [Color("#f8f1e2"), wool_sh], 0.12, rng)
	cv.px(4, 10 + bob, wool_sh)
	var head_y := 12 if grazing else 9
	var face := Color("#5a4a3e")
	cv.ellipse(19, head_y + bob, 3, 2.5, face)
	cv.px(17, head_y - 2 + bob, face.darkened(0.2))
	cv.px(20, head_y - 1 + bob, Color("#e8dcc4"))
	cv.outline(INK)
	cv.shadow(12, 18.5, 8, 1.5)
	return cv


# ---------------------------------------------------------------- cenário

func _props() -> void:
	var dir := "res://assets/environments/"
	_tree(true).save(dir + "tree_olive.png")
	_tree(false).save(dir + "tree_oak.png")
	_bush().save(dir + "bush.png")
	_rock(22, 16).save(dir + "rock_big.png")
	_rock(12, 9).save(dir + "rock_small.png")
	_well().save(dir + "well.png")
	_fence(true).save(dir + "fence_h.png")
	_fence(false).save(dir + "fence_v.png")
	_house(64, 1).save(dir + "house_small.png")
	_house(80, 2).save(dir + "house_wide.png")
	_tent().save(dir + "tent.png")
	_stall(true).save(dir + "stall_produce.png")
	_stall(false).save(dir + "stall_textiles.png")
	_oven().save(dir + "oven.png")
	_jar().save(dir + "jar.png")
	_pots().save(dir + "pots.png")
	_basket().save(dir + "basket.png")
	_sacks().save(dir + "sacks.png")
	_firewood().save(dir + "firewood.png")
	_firepit().save(dir + "firepit.png")
	_boundary_stone().save(dir + "boundary_stone.png")
	_journal().save(dir + "journal.png")


func _blob_canopy(cv, blobs: Array, dark: Color, mid: Color, light: Color, high: Color) -> void:
	for b in blobs:
		cv.ellipse(b.x + 1, b.y + 1, b.z, b.w, dark)
	for b in blobs:
		cv.ellipse(b.x, b.y, b.z - 0.5, b.w - 0.5, mid)
	for b in blobs:
		cv.ellipse_on_solid(b.x - 2, b.y - 2, b.z * 0.55, b.w * 0.5, light)
	var bounds := Rect2i(0, 0, cv.w, cv.h)
	cv.speckle(bounds, [high], 0.08, rng, light)
	cv.speckle(bounds, [dark], 0.07, rng, mid)
	cv.speckle(bounds, [light], 0.05, rng, mid)


func _tree(olive: bool):
	var w := 48 if olive else 40
	var h := 56 if olive else 52
	var cv = PC.new(w, h)
	var cx := w / 2
	var wood := Color("#795437")
	var wood_d := Color("#5a3d27")
	var wood_l := Color("#97704d")
	var trunk_top := 34 if olive else 32
	for y in range(trunk_top, h - 2):
		var tw := 4 + (2 if y > h - 7 else 0)
		var x := cx - 2 + (roundi(sin(y * 0.45) * 1.5) if olive else 0) - (1 if y > h - 7 else 0)
		cv.rect(x, y, tw, 1, wood)
		cv.px(x, y, wood_l)
		cv.px(x + tw - 1, y, wood_d)
	cv.line(cx - 1, trunk_top + 4, cx - 7, trunk_top - 4, wood)
	cv.line(cx + 1, trunk_top + 4, cx + 7, trunk_top - 5, wood)
	if olive:
		var blobs := [Vector4(24, 22, 14, 10), Vector4(13, 26, 8, 6), Vector4(35, 26, 8, 6),
			Vector4(17, 15, 8, 6), Vector4(31, 14, 9, 6), Vector4(24, 10, 8, 5)]
		_blob_canopy(cv, blobs, Color("#556339"), Color("#7f8f55"), Color("#a6b47c"), Color("#cbd5a6"))
		cv.speckle(Rect2i(4, 4, 40, 30), [Color("#3d3a4a")], 0.012, rng)
	else:
		var blobs2 := [Vector4(20, 20, 14, 12), Vector4(11, 24, 7, 6), Vector4(29, 24, 7, 6),
			Vector4(15, 12, 8, 6), Vector4(26, 12, 8, 6)]
		_blob_canopy(cv, blobs2, Color("#3f5a2e"), Color("#5e7f3a"), Color("#86a04a"), Color("#a9bf68"))
	cv.outline(INK)
	cv.shadow(cx, h - 2.5, 13 if olive else 11, 3, 0.35)
	return cv


func _bush():
	var cv = PC.new(20, 16)
	_blob_canopy(cv, [Vector4(10, 9, 8, 5.5), Vector4(6, 8, 4, 4), Vector4(14, 8, 4, 4)],
		Color("#4a6630"), Color("#6a8a3c"), Color("#8fa84e"), Color("#b3c46e"))
	cv.speckle(Rect2i(2, 3, 16, 10), [Color("#b03a2e")], 0.03, rng)
	cv.outline(INK)
	cv.shadow(10, 14.5, 8, 1.5)
	return cv


func _rock(w: int, h: int):
	var cv = PC.new(w, h)
	var cx := w / 2.0
	var cy := h * 0.55
	cv.ellipse(cx + 0.5, cy + 0.5, w * 0.44, h * 0.38, Color("#7a6a56"))
	cv.ellipse(cx - 0.5, cy - 0.5, w * 0.4, h * 0.33, Color("#9c8a72"))
	cv.ellipse_on_solid(cx - w * 0.15, cy - h * 0.15, w * 0.22, h * 0.15, Color("#c8b89a"))
	cv.speckle(Rect2i(0, 0, w, h), [Color("#8a7962"), Color("#b0a088")], 0.1, rng)
	if w > 16:
		cv.line(int(cx + 2), int(cy - 3), int(cx + 4), int(cy + 1), Color("#6e5f4c"))
		cv.speckle(Rect2i(0, 0, w, 6), [Color("#7a8b3a")], 0.08, rng)
	cv.outline(INK)
	cv.shadow(cx, h - 1.5, w * 0.42, 1.5)
	return cv


func _stone_blocks(cv, x0: int, y0: int, bw: int, bh: int, base: Color, mortar: Color, light: Color) -> void:
	cv.rect(x0, y0, bw, bh, base)
	var row := 0
	for y in range(y0, y0 + bh, 4):
		for x in range(x0, x0 + bw):
			cv.px(x, y, mortar)
			if y + 1 < y0 + bh:
				cv.px(x, y + 1, light)
		var off := 2 if row % 2 == 0 else 6
		for x in range(x0 + off, x0 + bw, 8):
			for yy in range(y, mini(y + 4, y0 + bh)):
				cv.px(x, yy, mortar)
		row += 1


func _well():
	var cv = PC.new(32, 32)
	var wood := Color("#795437")
	_stone_blocks(cv, 5, 14, 22, 12, Color("#b9a886"), Color("#8e7e62"), Color("#cbbb98"))
	cv.ellipse(16, 25, 11, 3, Color("#a89676"))
	for y in range(14, 27):
		for x in range(22, 27):
			if cv.is_solid(x, y):
				cv.px(x, y, cv.get_px(x, y).darkened(0.12))
	cv.ellipse(16, 14, 11, 4.5, Color("#d6c7a6"))
	cv.ellipse(16, 14, 8, 2.8, Color("#2a4a5a"))
	cv.px(13, 13, Color("#6fa8c0"))
	cv.px(14, 13, Color("#6fa8c0"))
	cv.rect(5, 2, 2, 13, wood)
	cv.rect(25, 2, 2, 13, wood.darkened(0.15))
	cv.rect(4, 1, 24, 2, Color("#97704d"))
	cv.line(16, 3, 16, 9, Color("#c9b48a"))
	cv.rect(14, 9, 4, 3, Color("#5a3d27"))
	cv.outline(INK)
	cv.shadow(16, 28.5, 13, 2.5)
	return cv


func _fence(horizontal: bool):
	var cv = PC.new(16, 16)
	var wood := Color("#795437")
	var light := Color("#97704d")
	var dark := Color("#5a3d27")
	if horizontal:
		cv.rect(0, 6, 16, 2, light)
		cv.rect(0, 11, 16, 2, light)
		cv.rect(0, 7, 16, 1, wood)
		cv.rect(0, 12, 16, 1, wood)
		cv.rect(1, 4, 2, 12, wood)
		cv.px(1, 4, light)
		cv.rect(2, 5, 1, 11, dark)
	else:
		cv.rect(7, 0, 2, 16, light)
		cv.rect(8, 0, 1, 16, wood)
		cv.rect(6, 2, 4, 5, wood)
		cv.rect(6, 10, 4, 5, wood)
		cv.rect(9, 2, 1, 5, dark)
		cv.rect(9, 10, 1, 5, dark)
	cv.outline(INK)
	return cv


## Fachada alta o bastante para a porta (26 px) ficar acima da cabeça
## de um personagem de 32 px. Pés (origem) em y = 81.
func _house(w: int, windows: int):
	var h := 84
	var cv = PC.new(w, h)
	var cx := w / 2
	var plaster := Color("#c9a57a")
	var plaster_sh := Color("#b38e62")
	var base := 81
	cv.rect(2, 22, w - 4, base - 22, plaster)
	cv.speckle(Rect2i(2, 22, w - 4, base - 22), [Color("#b8925f"), Color("#d6b98e")], 0.1, rng)
	for y in range(22, base):
		for x in range(w - 8, w - 2):
			cv.px(x, y, plaster_sh)
	_stone_blocks(cv, 2, base - 7, w - 4, 7, Color("#a89676"), Color("#86765c"), Color("#bcab8a"))
	# Telhado plano de vigas, galhos e barro, visto de cima (3/4).
	cv.rect(2, 6, w - 4, 16, Color("#d9c29a"))
	for y in range(8, 20, 3):
		for x in range(4, w - 4):
			if rng.randf() < 0.55:
				cv.px(x, y, Color("#c7ae84"))
	cv.rect(2, 6, w - 4, 2, Color("#e6d3ae"))
	cv.rect(2, 6, 2, 16, Color("#e6d3ae"))
	cv.rect(w - 4, 6, 2, 16, Color("#cdb68c"))
	cv.rect(2, 20, w - 4, 2, Color("#a8875e"))
	for x in range(5, w - 5, 7):
		cv.rect(x, 22, 2, 2, Color("#5a3a22"))
	# Objetos no telhado
	cv.ellipse(10, 12, 2.5, 3, Color("#b8734d"))
	cv.px(9, 10, Color("#d49a6c"))
	cv.ellipse(14, 13, 2, 2.5, Color("#9c5c3c"))
	for i in 5:
		cv.rect(w - 22 + i * 2, 10, 1, 6, Color("#d8c27a"))
	# Porta com verga de madeira
	var door_top := base - 26
	cv.rect(cx - 8, door_top - 3, 16, 3, Color("#795437"))
	cv.rect(cx - 6, door_top, 12, 26, Color("#5a3a22"))
	for x in range(cx - 4, cx + 6, 3):
		cv.rect(x, door_top, 1, 26, Color("#6e4a2c"))
	cv.rect(cx - 7, base - 1, 14, 2, Color("#a89676"))
	# Janelas pequenas e altas
	var win_xs := [cx + 14] if windows == 1 else [cx - 24, cx + 17]
	for wx in win_xs:
		cv.rect(wx, 36, 7, 6, Color("#3a2a22"))
		cv.rect(wx + 3, 36, 1, 6, Color("#795437"))
		cv.rect(wx - 1, 35, 9, 1, Color("#795437"))
	cv.outline(INK)
	cv.shadow(cx, base + 1.5, w * 0.5, 2.5)
	return cv


func _tent():
	var cv = PC.new(48, 40)
	var goat := Color("#3d302a")
	var stripe := Color("#55443a")
	for y in range(8, 23):
		var t := float(y - 8) / 14.0
		var x0 := roundi(lerpf(7, 2, t))
		var x1 := roundi(lerpf(41, 46, t))
		cv.rect(x0, y, x1 - x0, 1, stripe if (y - 8) % 4 == 0 else goat)
	cv.rect(8, 23, 32, 14, Color("#241a16"))
	cv.rect(26, 23, 14, 14, Color("#5b4636"))
	for y in range(23, 37, 3):
		cv.rect(26, y, 14, 1, Color("#6e5646"))
	cv.rect(5, 8, 1, 30, Color("#795437"))
	cv.rect(42, 8, 1, 30, Color("#795437"))
	cv.rect(14, 36, 12, 2, Color("#a0432f"))
	cv.rect(16, 36, 2, 2, Color("#c9a227"))
	cv.outline(INK)
	cv.line(2, 22, 0, 37, Color("#c9b48a"))
	cv.line(45, 22, 47, 37, Color("#c9b48a"))
	cv.shadow(24, 38, 22, 2)
	return cv


func _stall(produce: bool):
	var cv = PC.new(44, 40)
	var wood := Color("#795437")
	cv.rect(3, 10, 2, 27, wood)
	cv.rect(39, 10, 2, 27, wood.darkened(0.15))
	var a := Color("#b8734d") if produce else Color("#2f5d9e")
	var b := Color("#f4e4c1")
	for x in range(1, 43):
		var colr := a if (x / 4) % 2 == 0 else b
		cv.rect(x, 5, 1, 8, colr)
		if x % 4 != 3:
			cv.px(x, 13, colr)
	cv.rect(1, 5, 42, 1, Color("#e6d3ae"))
	cv.rect(2, 26, 40, 4, Color("#a07448"))
	cv.rect(2, 30, 40, 7, wood)
	cv.rect(2, 33, 40, 1, Color("#5a3d27"))
	if produce:
		for i in 5:
			cv.ellipse(7 + i * 3, 24, 2, 2, Color("#b03a2e"))
			cv.px(6 + i * 3, 23, Color("#e07a62"))
		for i in 4:
			cv.ellipse(23 + i * 3, 25, 1.6, 1.6, Color("#5a3a5a"))
		cv.ellipse(36, 25, 4, 2, Color("#b8734d"))
		for i in 4:
			cv.px(34 + i, 24, Color("#4f5e24"))
	else:
		cv.rect(6, 20, 9, 6, Color("#2f5d9e"))
		cv.rect(6, 22, 9, 1, Color("#244a80"))
		cv.rect(17, 21, 9, 5, Color("#c9a227"))
		cv.rect(28, 19, 10, 7, Color("#a0432f"))
		cv.rect(28, 21, 10, 1, Color("#7c3026"))
	cv.outline(INK)
	cv.shadow(22, 38, 20, 2)
	return cv


func _oven():
	var cv = PC.new(20, 18)
	cv.ellipse(10, 10, 8, 6.5, Color("#8e5e36"))
	cv.ellipse(9.5, 9.5, 7.5, 6, Color("#b07a45"))
	cv.ellipse_on_solid(7.5, 7, 4, 3, Color("#c8925e"))
	cv.ellipse(10, 4.5, 2.5, 1.2, Color("#5a3d27"))
	cv.ellipse(10, 12.5, 3, 2, Color("#2b1d14"))
	cv.px(9, 13, Color("#e0702f"))
	cv.px(10, 13, Color("#ffb347"))
	cv.outline(INK)
	cv.shadow(10, 16.5, 8, 1.5)
	return cv


func _clay_jar(cv, cx: float, base_y: float, r: float, body: Color) -> void:
	cv.ellipse(cx, base_y - r - 1, r, r + 0.5, body.darkened(0.2))
	cv.ellipse(cx - 0.5, base_y - r - 1.5, r - 0.5, r, body)
	cv.ellipse_on_solid(cx - r * 0.4, base_y - r * 1.4 - 1, r * 0.35, r * 0.4, body.lightened(0.2))
	cv.rect(roundi(cx - r * 0.45), roundi(base_y - r * 2 - 3), roundi(r * 0.9), 2, body.darkened(0.1))
	cv.rect(roundi(cx - r * 0.6), roundi(base_y - r * 2 - 4), roundi(r * 1.2), 1, body.lightened(0.1))


func _jar():
	var cv = PC.new(10, 16)
	_clay_jar(cv, 5, 15, 4, Color("#b8734d"))
	cv.outline(INK)
	cv.shadow(5, 14.5, 4, 1.2)
	return cv


func _pots():
	var cv = PC.new(26, 16)
	_clay_jar(cv, 6, 15, 4, Color("#b8734d"))
	_clay_jar(cv, 14, 15, 3, Color("#c8b08a"))
	_clay_jar(cv, 20.5, 15, 3.5, Color("#9c5c3c"))
	cv.outline(INK)
	cv.shadow(13, 14.5, 12, 1.5)
	return cv


func _basket():
	var cv = PC.new(14, 10)
	cv.ellipse(7, 6, 6, 3.5, Color("#9c7a3e"))
	cv.ellipse(7, 5, 5.5, 2.5, Color("#c9a45c"))
	for x in range(2, 12, 2):
		cv.px(x, 7, Color("#9c7a3e"))
	cv.ellipse(7, 4, 4, 1.5, Color("#e8c27a"))
	cv.outline(INK)
	cv.shadow(7, 9, 6, 1)
	return cv


func _sacks():
	var cv = PC.new(18, 13)
	cv.ellipse(6, 7, 5, 5, Color("#a89068"))
	cv.ellipse(5.5, 6.5, 4.5, 4.5, Color("#c2a878"))
	cv.ellipse(12, 8, 4.5, 4, Color("#a89068"))
	cv.ellipse(11.5, 7.5, 4, 3.5, Color("#c2a878"))
	cv.px(6, 2, Color("#795437"))
	cv.px(12, 4, Color("#795437"))
	cv.speckle(Rect2i(0, 0, 18, 13), [Color("#b39b6c")], 0.15, rng)
	cv.outline(INK)
	cv.shadow(9, 12, 8, 1)
	return cv


func _firewood():
	var cv = PC.new(16, 10)
	for i in 3:
		cv.rect(1, 6 - i * 2, 14, 2, Color("#795437"))
		cv.px(1, 6 - i * 2, Color("#c9a06c"))
		cv.px(14, 7 - i * 2, Color("#5a3d27"))
	cv.outline(INK)
	cv.shadow(8, 9, 7, 1)
	return cv


func _firepit():
	var cv = PC.new(16, 12)
	for i in 8:
		var ang := TAU * i / 8.0
		cv.ellipse(8 + cos(ang) * 5.5, 7 + sin(ang) * 2.8, 1.6, 1.3, Color("#9c8a72"))
	cv.ellipse(8, 7, 3.5, 1.6, Color("#3a2a22"))
	cv.px(7, 7, Color("#e0702f"))
	cv.px(9, 6, Color("#ffb347"))
	cv.px(8, 5, Color("#ffd36b"))
	cv.outline(INK)
	cv.shadow(8, 10.5, 7, 1.2)
	return cv


func _boundary_stone():
	var cv = PC.new(12, 18)
	cv.ellipse(6.5, 10, 4.5, 7.5, Color("#7a6a56"))
	cv.ellipse(6, 9.5, 4, 7, Color("#9c8a72"))
	cv.ellipse_on_solid(4.5, 6, 2, 3, Color("#b8a88c"))
	cv.speckle(Rect2i(0, 10, 12, 8), [Color("#7a8b3a")], 0.12, rng)
	cv.outline(INK)
	cv.shadow(6, 16.5, 5, 1.3)
	return cv


func _journal():
	var cv = PC.new(16, 12)
	cv.ellipse(8, 8, 7, 3.5, Color("#7a6a56"))
	cv.ellipse(7.5, 7.5, 6.5, 3, Color("#9c8a72"))
	cv.rect(3, 4, 10, 3, Color("#f4e4c1"))
	cv.rect(3, 6, 10, 1, Color("#d9b98a"))
	cv.rect(2, 4, 1, 3, Color("#b89a6a"))
	cv.rect(13, 4, 1, 3, Color("#b89a6a"))
	cv.rect(7, 4, 1, 3, Color("#a0432f"))
	cv.outline(INK)
	cv.shadow(8, 11, 7, 1)
	return cv


# ---------------------------------------------------------------- UI

func _ui() -> void:
	var dir := "res://assets/ui/"
	# Painel de pergaminho (9-patch, margem 7)
	var p = PC.new(24, 24)
	p.rect(1, 1, 22, 22, Color("#f4e4c1"))
	p.speckle(Rect2i(3, 3, 18, 18), [Color("#eedbb4")], 0.12, rng)
	for i in 24:
		for j in [0, 23]:
			if i > 0 and i < 23:
				p.px(i, j, INK)
				p.px(j, i, INK)
	for i in range(1, 23):
		p.px(i, 1, Color("#8b5a2b"))
		p.px(i, 22, Color("#8b5a2b"))
		p.px(1, i, Color("#8b5a2b"))
		p.px(22, i, Color("#8b5a2b"))
	for i in range(2, 22):
		p.px(i, 2, Color("#d9b98a"))
		p.px(i, 21, Color("#d9b98a"))
		p.px(2, i, Color("#d9b98a"))
		p.px(21, i, Color("#d9b98a"))
	for q in [Vector2i(3, 3), Vector2i(20, 3), Vector2i(3, 20), Vector2i(20, 20)]:
		p.px(q.x, q.y, Color("#c9a227"))
	p.save(dir + "panel_parchment.png")

	# Balão de interação com a tecla "E"
	var b = PC.new(11, 12)
	b.rect(1, 0, 9, 10, Color("#f4e4c1"))
	b.rect(0, 1, 11, 8, Color("#f4e4c1"))
	b.px(5, 10, Color("#f4e4c1"))
	for y in range(2, 8):
		b.px(4, y, INK)
	for x in range(4, 7):
		b.px(x, 2, INK)
		b.px(x, 7, INK)
	b.px(5, 4, INK)
	b.px(5, 5, INK)
	b.outline(Color("#8b5a2b"))
	b.save(dir + "prompt_bubble.png")

	# Seta "continuar"
	var arrow = PC.new(7, 5)
	for y in 4:
		for x in range(y, 7 - y):
			arrow.px(x, y, Color("#c9a227"))
	arrow.outline(INK)
	arrow.save(dir + "next_arrow.png")

	# Ícone do projeto
	var icon = PC.new(64, 64)
	icon.ellipse(32, 32, 30, 30, Color("#8b5a2b"))
	icon.ellipse(32, 32, 28, 28, Color("#f4e4c1"))
	icon.ellipse(32, 32, 26, 26, Color("#e9d3a6"))
	icon.blit(_tree(true), 8, 4)
	icon.save(dir + "icon.png")


func _menu_background() -> void:
	var w := 480
	var h := 270
	var cv = PC.new(w, h)
	var top := Color("#6f93b3")
	var mid := Color("#e3b98a")
	var horizon := Color("#f4d9a6")
	for y in h:
		var t := float(y) / 170.0
		var colr := top.lerp(mid, clampf(t * 1.4, 0, 1))
		if t > 0.7:
			colr = mid.lerp(horizon, clampf((t - 0.7) / 0.3, 0, 1))
		# Faixas discretas para manter a leitura pixelada (sem degradê suave).
		colr = Color(snappedf(colr.r, 1.0 / 24.0), snappedf(colr.g, 1.0 / 24.0), snappedf(colr.b, 1.0 / 24.0))
		cv.rect(0, y, w, 1, colr)
	cv.ellipse(360, 150, 26, 26, Color("#ffe6a8"))
	cv.ellipse(360, 150, 18, 18, Color("#fff3c4"))
	var layers := [
		[150.0, 10.0, 0.012, Color("#c4a882")],
		[175.0, 14.0, 0.018, Color("#9c9468")],
		[205.0, 12.0, 0.025, Color("#6f7a45")],
		[235.0, 8.0, 0.03, Color("#55603a")],
	]
	var li := 0
	for layer in layers:
		var base_y: float = layer[0]
		var amp: float = layer[1]
		var freq: float = layer[2]
		for x in w:
			var hy := base_y + sin(x * freq + li * 1.7) * amp + sin(x * freq * 2.7 + li) * amp * 0.35
			cv.rect(x, int(hy), 1, h - int(hy), layer[3])
		li += 1
	# Caminho serpenteando
	for y in range(210, h):
		var t := float(y - 210) / float(h - 210)
		var cxp := 240 + sin(t * 3.0) * 30
		var half := lerpf(2, 26, t)
		cv.rect(int(cxp - half), y, int(half * 2), 1, Color("#b07a45"))
	# Oliveiras e tendas em silhueta
	for tx in [40, 95, 400, 440]:
		var tree = _tree(true)
		cv.blit(tree, tx - 24, 198 - 50 + (tx % 7))
	for tx in [112, 176]:
		var tent = _tent()
		cv.blit(tent, tx, 190)
	# Pássaros
	for bpos in [Vector2i(52, 34), Vector2i(64, 40), Vector2i(418, 78)]:
		cv.px(bpos.x - 1, bpos.y - 1, INK)
		cv.px(bpos.x, bpos.y, INK)
		cv.px(bpos.x + 1, bpos.y, INK)
		cv.px(bpos.x + 2, bpos.y - 1, INK)
	cv.save("res://assets/ui/menu_bg.png")
