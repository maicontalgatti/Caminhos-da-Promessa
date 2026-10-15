extends RefCounted
## Arte PROVISÓRIA da feira do viajante: ícones das mercadorias, os
## mercadores fictícios e as camadas de equipamento do jogador.
## Chamado por generate_art.gd (`-- --market-only` gera só isto); não altera
## nenhum PNG anterior.
##
## Camadas de equipamento: cada peça é desenhada com o mesmo gerador de
## personagens (look do jogador + a peça) e comparada pixel a pixel com o
## jogador sem a peça; só os pixels diferentes ficam no PNG. Assim a camada
## acompanha exatamente os 6×4 quadros de assets/characters/player.png.
##
## Restrições: sem moedas, ferro, vidro ou camelos; tecidos e cores possíveis
## na Idade do Bronze (lã crua, linho, tingimentos caros). Ver docs/art_bible.md.

const PC = preload("res://tools/art_gen/pixel_canvas.gd")
const INK := Color("#2b1d14")
const CHARS := "res://assets/characters/"
const ITEMS := "res://assets/items/"
const GEAR := "res://assets/gear/"

## Mudanças no look do jogador por peça (chaves do gerador de personagens).
const GEAR_LOOKS := {
	# Roupa
	"travel_cloak": {"mantle": "#7a5236", "mantle_edge": "#5a3a22"},
	"shepherd_mantle": {"mantle": "#5e4a38", "mantle_edge": "#c2a878"},
	"blue_tunic": {"robe": "#3e6f9f", "robe_shade": "#2f5a84", "robe_light": "#5a88b4"},
	"linen_tunic": {"robe": "#efe8d6", "robe_shade": "#cfc6b0", "robe_light": "#fbf6ea", "sash": "#c8b890"},
	# Cabeça
	"head_band": {"band": "#9e3f32"},
	"dyed_headcloth": {"head_color": "#b8734d", "head_shade": "#95593a", "band": "#5a3d27"},
	"long_headcloth": {"head": "veil", "head_color": "#efe4cc", "head_shade": "#cdbd98", "band": "#8e7a5a"},
	# Cajado
	"walking_staff": {"staff": "#8b5a2b"},
	"shepherd_crook": {"staff": "#6b4423", "crook": true},
	"oak_staff": {"staff": "#4e3424"},
}

## Mercadores fictícios (data/characters). Yaron já existe em Canaã.
const MERCHANT_LOOKS := {
	"ozi": {
		"skin": "#a8714c", "skin_shade": "#86573a",
		"robe": "#5a6e8a", "robe_shade": "#46566e", "robe_light": "#74889f",
		"sash": "#c9a227", "head": "cloth", "head_color": "#e0d0a8", "head_shade": "#bdad88",
		"band": "#9e3f32", "hair": "#2b1d14", "beard": true, "bag": "#8b5a2b",
	},
	"nefer": {
		"skin": "#7a4e34", "skin_shade": "#5e3a26",
		"robe": "#f2ecdc", "robe_shade": "#d2cab6", "robe_light": "#fbf8ee",
		"sash": "#3f7f9c", "head": "veil", "head_color": "#1e1612", "head_shade": "#120c0a",
		"band": "#3f7f9c", "hair": "#1e1612", "beard": false, "feet": "#a08a5e", "basket": "#c9a45c",
	},
	"liora": {
		"skin": "#c08a60", "skin_shade": "#9c6a45",
		"robe": "#8e6a9e", "robe_shade": "#6f5280", "robe_light": "#a888b6",
		"sash": "#d8ccb4", "head": "veil", "head_color": "#d9b98a", "head_shade": "#b8986a",
		"band": "#7a8b3a", "hair": "#2e1d12", "beard": false, "basket": "#9c7a3e",
	},
}

var gen  # generate_art.gd (SceneTree): fornece _character_frame e LOOKS
var rng := RandomNumberGenerator.new()


func _init(generator) -> void:
	gen = generator


func generate() -> void:
	rng.seed = 6_2026
	_merchants()
	_gear_layers()
	_trade_icons()


func _sheet(look: Dictionary):
	var sheet = PC.new(24 * 6, 32 * 4)
	for dir in 4:
		for frame in 6:
			sheet.blit(gen._character_frame(dir, frame, look), frame * 24, dir * 32)
	return sheet


func _merchants() -> void:
	for id in MERCHANT_LOOKS:
		_sheet(MERCHANT_LOOKS[id]).save(CHARS + "%s.png" % id)


func _gear_layers() -> void:
	var base_look: Dictionary = gen.LOOKS["player"]
	var base = _sheet(base_look)
	for id in GEAR_LOOKS:
		var look := base_look.duplicate()
		look.merge(GEAR_LOOKS[id], true)
		var dressed = _sheet(look)
		var layer = PC.new(base.w, base.h)
		for y in base.h:
			for x in base.w:
				var c: Color = dressed.get_px(x, y)
				if c.a > 0.0 and not c.is_equal_approx(base.get_px(x, y)):
					layer.px(x, y, c)
		layer.save(GEAR + "%s.png" % id)


func _icon():
	return PC.new(12, 12)


func _trade_icons() -> void:
	# Tufo de lã crua preso num espinho
	var cv = _icon()
	cv.ellipse(6, 7, 4.5, 3.2, Color("#d8ccb4"))
	cv.ellipse(4.5, 6, 2.2, 2, Color("#efe4cc"))
	cv.ellipse(8, 7.5, 2, 1.8, Color("#c2b496"))
	cv.line(1, 10, 4, 7, Color("#6e5639"))
	cv.outline(INK)
	cv.save(ITEMS + "wool_tuft.png")
	# Amêndoas
	cv = _icon()
	for p in [Vector2(4, 7), Vector2(7.5, 6), Vector2(6, 9)]:
		cv.ellipse(p.x, p.y, 2.6, 1.7, Color("#a8713d"))
		cv.px(int(p.x) - 1, int(p.y) - 1, Color("#c9925a"))
	cv.outline(INK)
	cv.save(ITEMS + "almonds.png")
	# Lasca de sílex
	cv = _icon()
	for y in range(2, 11):
		var hw: int = (1 + int((y - 2) / 2.0)) if y < 7 else (1 + (10 - y))
		cv.rect(6 - hw, y, hw * 2, 1, Color("#8a8478"))
	cv.line(5, 3, 3, 8, Color("#b4ae9e"))
	cv.px(7, 6, Color("#5e5a52"))
	cv.outline(INK)
	cv.save(ITEMS + "flint_stone.png")
	# Ervas silvestres amarradas
	cv = _icon()
	for i in 5:
		var x := 3 + i * 1.5
		cv.line(int(x), 2 + (i % 2), 6, 10, Color("#6f8a3a") if i % 2 == 0 else Color("#8fa34b"))
		cv.px(int(x), 2 + (i % 2), Color("#c9d27a"))
	cv.rect(4, 8, 4, 1, Color("#c2a878"))
	cv.outline(INK)
	cv.save(ITEMS + "wild_herbs.png")
	# Hastes de papiro
	cv = _icon()
	for i in 3:
		cv.line(3 + i * 2, 11, 4 + i * 2, 4, Color("#7f9a3a"))
	for i in 3:
		cv.ellipse(4 + i * 2, 3, 1.6, 1.2, Color("#a3b14b"))
	cv.rect(3, 8, 6, 1, Color("#795437"))
	cv.outline(INK)
	cv.save(ITEMS + "papyrus_stalks.png")
	# Tâmaras
	cv = _icon()
	cv.line(6, 1, 6, 4, Color("#8b5a2b"))
	for p in [Vector2(4, 6), Vector2(8, 6), Vector2(6, 8.5), Vector2(4.5, 9.5), Vector2(8, 9.5)]:
		cv.ellipse(p.x, p.y, 1.6, 2.1, Color("#8e4a2a"))
		cv.px(int(p.x) - 1, int(p.y) - 1, Color("#b8693e"))
	cv.outline(INK)
	cv.save(ITEMS + "dates.png")
	# Concha
	cv = _icon()
	cv.ellipse(6, 6.5, 4.5, 4, Color("#e8d6c0"))
	for i in 4:
		cv.line(6, 10, 3 + i * 2, 3, Color("#c9a88a"))
	cv.rect(5, 9, 2, 2, Color("#d8c0a4"))
	cv.outline(INK)
	cv.save(ITEMS + "sea_shell.png")
