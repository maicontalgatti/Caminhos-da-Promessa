extends RefCounted
## Arte PROVISÓRIA das quatro experiências da v0.5 (José no Egito, a travessia
## do mar, Rute em Belém, os pastores de Belém): atlas de terras, objetos de
## cenário, personagens, animais e ícones de item. Chamado por generate_art.gd
## (`-- --v05-only` gera só isto e as paletas). Mesmo estilo da arte existente:
## contorno colorido (nunca preto puro), sombra suave e cores de art_spec.gd.
##
## Restrições das pesquisas históricas dos episódios: sem ferro, vidro ou
## moedas; sem camelos, galinhas, poço, casas, forno fixo, cercas de madeira ou
## oliveiras no acampamento junto ao mar; casa egípcia genérica, sem símbolos
## reais; Belém sem estrela, estábulo de madeira ou telhado de palha. O anjo
## e a glória são só luz (efeitos de cena), nunca figura desenhada aqui.

const Spec = preload("res://tools/art_gen/art_spec.gd")
const PC = preload("res://tools/art_gen/pixel_canvas.gd")
const INK := Color("#2b1d14")
const ENV := "res://assets/environments/"
const CHARS := "res://assets/characters/"
const ITEMS := "res://assets/items/"

## Objetos novos. origin = pés no PNG; col = colisão relativa aos pés (sem col:
## objeto rente ao chão, sem colisão). Lido por build_regions.gd.
const PROPS := {
	# Egito
	"tree_date_palm": {"origin": Vector2(20, 62), "col": Rect2(-3, -3, 6, 4), "sway": true},
	"tree_sycamore": {"origin": Vector2(28, 53), "col": Rect2(-5, -4, 10, 5), "sway": true},
	"tree_acacia": {"origin": Vector2(26, 44), "col": Rect2(-3, -3, 6, 4), "sway": true},
	"papyrus_reeds": {"origin": Vector2(13, 28), "col": Rect2(-6, -2, 12, 3), "sway": true},
	"mudbrick_wall_h": {"origin": Vector2(8, 29), "col": Rect2(-8, -8, 16, 8)},
	"mudbrick_wall_v": {"origin": Vector2(8, 29), "col": Rect2(-4, -16, 8, 16)},
	"reed_fence_h": {"origin": Vector2(8, 15), "col": Rect2(-8, -5, 16, 4)},
	"reed_fence_v": {"origin": Vector2(8, 15), "col": Rect2(-2, -16, 4, 16)},
	"house_portico": {"origin": Vector2(96, 125), "col": Rect2(-94, -58, 188, 54)},
	"garden_pool": {"origin": Vector2(28, 32), "col": Rect2(-26, -22, 52, 18)},
	"storage_jars": {"origin": Vector2(17, 26), "col": Rect2(-15, -6, 30, 6)},
	"scribe_table": {"origin": Vector2(15, 18), "col": Rect2(-13, -6, 26, 6)},
	"egypt_oven": {"origin": Vector2(11, 22), "col": Rect2(-8, -5, 16, 5)},
	"saddle_quern": {"origin": Vector2(12, 10), "col": Rect2(-10, -4, 20, 4)},
	"floor_loom": {"origin": Vector2(19, 15), "col": Rect2(-17, -9, 34, 8)},
	"granary_silos": {"origin": Vector2(38, 55), "col": Rect2(-36, -20, 72, 18)},
	"flax_bundles": {"origin": Vector2(14, 16), "col": Rect2(-12, -4, 24, 4)},
	"shaduf": {"origin": Vector2(12, 50), "col": Rect2(-3, -3, 6, 4)},
	# Acampamento junto ao mar
	"tamarisk": {"origin": Vector2(17, 40), "col": Rect2(-4, -3, 8, 4), "sway": true},
	"reeds": {"origin": Vector2(11, 20), "col": Rect2(-6, -2, 12, 3), "sway": true},
	"tent_worn": {"origin": Vector2(24, 38), "col": Rect2(-22, -12, 44, 11)},
	"cloth_shelter": {"origin": Vector2(21, 28), "col": Rect2(-19, -9, 38, 8)},
	"bread_stone_fire": {"origin": Vector2(11, 10), "col": Rect2(-9, -4, 18, 4)},
	"skins_tripod": {"origin": Vector2(10, 28), "col": Rect2(-6, -3, 12, 4)},
	"kneading_bundle": {"origin": Vector2(9, 12), "col": Rect2(-7, -4, 14, 4)},
	"rock_crest": {"origin": Vector2(22, 28), "col": Rect2(-20, -9, 40, 9)},
	"dune": {"origin": Vector2(30, 18), "col": Rect2(-26, -6, 52, 6)},
	"firepit_out": {"origin": Vector2(8, 10), "col": Rect2(-6, -4, 12, 4)},
	"crowd_group_a": {"origin": Vector2(28, 38), "col": Rect2(-24, -6, 48, 6)},
	"crowd_group_b": {"origin": Vector2(24, 38), "col": Rect2(-20, -6, 40, 6)},
	# Belém, campos (época dos juízes)
	"house_pillar": {"origin": Vector2(38, 57), "col": Rect2(-36, -20, 72, 18)},
	"stone_bench": {"origin": Vector2(13, 10), "col": Rect2(-11, -4, 22, 4)},
	"pithos": {"origin": Vector2(7, 23), "col": Rect2(-5, -3, 10, 3)},
	"sheaf": {"origin": Vector2(7, 16), "col": Rect2(-4, -2, 8, 3)},
	"branch_shelter": {"origin": Vector2(23, 36), "col": Rect2(-21, -6, 42, 5)},
	"grain_heap": {"origin": Vector2(17, 15), "col": Rect2(-15, -6, 30, 6)},
	"threshing_sledge": {"origin": Vector2(14, 10), "col": Rect2(-12, -4, 24, 4)},
	"winnowing_fork": {"origin": Vector2(13, 8)},
	"village_gate": {"origin": Vector2(32, 55), "col": Rect2(-30, -14, 60, 12)},
	"stone_wall_h": {"origin": Vector2(8, 23), "col": Rect2(-8, -8, 16, 8)},
	"stone_wall_v": {"origin": Vector2(8, 23), "col": Rect2(-4, -16, 8, 16)},
	"terrace_wall": {"origin": Vector2(24, 16), "col": Rect2(-24, -7, 48, 7)},
	# Belém, noite (época de Herodes)
	"house_courtyard": {"origin": Vector2(32, 52), "col": Rect2(-30, -18, 60, 16)},
	"house_on_rock": {"origin": Vector2(64, 80), "col": Rect2(-60, -22, 120, 20)},
	"stone_stairs": {"origin": Vector2(8, 21), "col": Rect2(-6, -6, 12, 6)},
	"rock_shelter": {"origin": Vector2(30, 42), "col": Rect2(-26, -36, 52, 10)},
	"cloak_bed": {"origin": Vector2(13, 9)},
	"oil_lamp_niche": {"origin": Vector2(8, 12), "col": Rect2(-5, -3, 10, 3)},
	"fold_wall_h": {"origin": Vector2(8, 25), "col": Rect2(-8, -8, 16, 8)},
	"fold_wall_v": {"origin": Vector2(8, 25), "col": Rect2(-4, -16, 8, 16)},
	"cave_mouth": {"origin": Vector2(26, 38), "col": Rect2(-24, -16, 48, 14)},
	"thorn_bush": {"origin": Vector2(11, 14), "col": Rect2(-7, -3, 14, 4), "sway": true},
}

## Muros por segmento de 16 px (h = horizontal, v = vertical).
const WALLS := {
	"mudbrick": {"top": "#c9a070", "top_l": "#ddb88a", "face": "#a8794e", "mortar": "#87603e", "light": "#b98a5c", "h": 30, "face_h": 18, "top_rows": 7},
	"stone": {"top": "#cfc4ac", "top_l": "#e0d6c0", "face": "#ab9f86", "mortar": "#7f7360", "light": "#bdb198", "h": 24, "face_h": 12, "top_rows": 5},
	"fold": {"top": "#c4b89e", "top_l": "#d8ccb2", "face": "#a29478", "mortar": "#776a56", "light": "#b4a68a", "h": 26, "face_h": 12, "top_rows": 5},
}

## Pessoas fictícias novas (data/characters na etapa de integração).
const LOOKS := {
	"egypt_ipi": {
		"skin": "#a86f48", "skin_shade": "#86573a",
		"robe": "#efe8d6", "robe_shade": "#cfc6b0", "robe_light": "#fbf6ea", "robe_bottom": 24,
		"sash": "#d8ccb4", "head": "hair", "head_color": "#e8e2d6", "head_shade": "#c8c0b0",
		"band": "#e8e2d6", "hair": "#e8e2d6", "beard": false, "staff": "#795437", "stoop": 1, "feet": "#a08a5e",
	},
	"egypt_meryt": {
		"skin": "#6e4630", "skin_shade": "#563424",
		"robe": "#f2ecdc", "robe_shade": "#d2cab6", "robe_light": "#fbf8ee",
		"sash": "#c8b890", "head": "veil", "head_color": "#1e1612", "head_shade": "#120c0a",
		"band": "#f2ecdc", "hair": "#1e1612", "beard": false, "feet": "#a08a5e",
	},
	"egypt_senbi": {
		"skin": "#8a5a3c", "skin_shade": "#6e4630",
		"robe": "#e8dfc8", "robe_shade": "#c8bea6", "robe_light": "#f2ead6", "robe_bottom": 23,
		"sash": "#c2b48e", "head": "hair", "head_color": "#1e1612", "head_shade": "#120c0a",
		"band": "#1e1612", "hair": "#1e1612", "beard": false, "feet": "#6e4630",
	},
	"sea_tzvi": {
		"skin": "#b07850", "skin_shade": "#8e5e3c",
		"robe": "#d8ccb0", "robe_shade": "#b8ac90", "robe_light": "#e8dcc2",
		"sash": "#795437", "head": "cloth", "head_color": "#d9c8a0", "head_shade": "#b8a880",
		"band": "#8e7a5a", "hair": "#ece6da", "beard": true, "mantle": "#5a3d27", "mantle_edge": "#a08a5e",
		"staff": "#795437", "stoop": 1,
	},
	"sea_shira": {
		"skin": "#c08a60", "skin_shade": "#9c6a45",
		"robe": "#d9c8a0", "robe_shade": "#b8a880", "robe_light": "#e8dab8", "hem": "#9e4a32",
		"sash": "#8e5e36", "head": "veil", "head_color": "#b89a6a", "head_shade": "#977a4e",
		"band": "#9e4a32", "hair": "#2e1d12", "beard": false,
	},
	"sea_beni": {
		"skin": "#c98e62", "skin_shade": "#a8714c",
		"robe": "#e2d6ba", "robe_shade": "#c2b698", "robe_light": "#efe4cc", "robe_bottom": 26,
		"sash": "#a08a5e", "head": "hair", "head_color": "#2b1d14", "head_shade": "#1e140c",
		"band": "#2b1d14", "hair": "#2b1d14", "beard": false, "child": true, "feet": "#a8714c",
	},
	"sea_dror": {
		"skin": "#b9805a", "skin_shade": "#966243",
		"robe": "#7a5634", "robe_shade": "#5e4228", "robe_light": "#946c48", "robe_bottom": 26,
		"sash": "#3d302a", "head": "cloth", "head_color": "#9a9690", "head_shade": "#7a7670",
		"band": "#5a3d27", "hair": "#2b1d14", "beard": true, "mantle": "#e2d6ba",
		"staff": "#795437", "crook": true, "bag": "#6d4420",
	},
	"sea_nava": {
		"skin": "#a8714c", "skin_shade": "#86573a",
		"robe": "#8a96a0", "robe_shade": "#6e7a84", "robe_light": "#a2acb4",
		"sash": "#5a3d27", "head": "veil", "head_color": "#8c8a86", "head_shade": "#6e6c68",
		"band": "#6e6c68", "hair": "#d8d0c0", "beard": false, "mantle": "#6d4420", "stoop": 2,
	},
	"sea_meret": {
		"skin": "#a06a45", "skin_shade": "#7e5134",
		"robe": "#f0e8d4", "robe_shade": "#d0c8b2", "robe_light": "#faf6ea",
		"sash": "#c8b890", "head": "veil", "head_color": "#1e1612", "head_shade": "#120c0a",
		"band": "#1e1612", "hair": "#1e1612", "beard": false, "mantle": "#d8ccb0", "collar": "#3f8f8a", "feet": "#a08a5e",
	},
	"bf_ilan": {
		"skin": "#b07850", "skin_shade": "#8e5e3c",
		"robe": "#e6d9bc", "robe_shade": "#c6b99c", "robe_light": "#f0e6cc", "robe_bottom": 27,
		"sash": "#6d4420", "head": "cloth", "head_color": "#efe4cc", "head_shade": "#cfc4ac",
		"band": "#a08a5e", "hair": "#6d4420", "beard": true,
	},
	"bf_tova": {
		"skin": "#b98a68", "skin_shade": "#96684a",
		"robe": "#8a6a4a", "robe_shade": "#6e543a", "robe_light": "#a08060",
		"sash": "#5a3d27", "head": "veil", "head_color": "#e2d6ba", "head_shade": "#c2b698",
		"band": "#c2b698", "hair": "#d8d0c0", "beard": false, "mantle": "#e2d6ba", "stoop": 2, "basket": "#c9a45c",
	},
	"bf_reaper": {
		"skin": "#a8714c", "skin_shade": "#86573a",
		"robe": "#e8dfc8", "robe_shade": "#c8bea6", "robe_light": "#f2ead6", "robe_bottom": 25,
		"sash": "#a08a5e", "head": "cloth", "head_color": "#d8ccb4", "head_shade": "#b5a98f",
		"band": "#a08a5e", "hair": "#2b1d14", "beard": false, "feet": "#86573a",
	},
	"bn_tamir": {
		"skin": "#a8714c", "skin_shade": "#86573a",
		"robe": "#5e4228", "robe_shade": "#4a3420", "robe_light": "#7a5634",
		"sash": "#3d2a1a", "head": "cloth", "head_color": "#d9c8a0", "head_shade": "#b8a880",
		"band": "#795437", "hair": "#4a4038", "beard": true, "mantle": "#d8d0bc", "mantle_edge": "#795437",
		"staff": "#795437", "crook": true, "bag": "#6d4420",
	},
	"bn_shai": {
		"skin": "#c08a60", "skin_shade": "#9c6a45",
		"robe": "#e8dcc0", "robe_shade": "#c8bca0", "robe_light": "#f2e8d0", "robe_bottom": 26, "clavi": "#795437",
		"sash": "#5a3d27", "head": "hair", "head_color": "#2b1d14", "head_shade": "#1e140c",
		"band": "#2b1d14", "hair": "#2b1d14", "beard": true, "mantle": "#b8946a",
		"staff": "#8b6a44", "bag": "#8b5a2b",
	},
	"bn_rep_shepherd_a": {
		"skin": "#b07850", "skin_shade": "#8e5e3c",
		"robe": "#7a5634", "robe_shade": "#5e4228", "robe_light": "#946c48",
		"sash": "#3d302a", "head": "cloth", "head_color": "#e2d6ba", "head_shade": "#c2b698",
		"band": "#8e7a5a", "hair": "#6d4420", "beard": true, "mantle": "#4a3420",
		"staff": "#795437", "crook": true,
	},
	"bn_rep_shepherd_b": {
		"skin": "#a06a45", "skin_shade": "#7e5134",
		"robe": "#8a8a84", "robe_shade": "#6e6e68", "robe_light": "#a2a29c",
		"sash": "#3d302a", "head": "hair", "head_color": "#1e1612", "head_shade": "#120c0a",
		"band": "#1e1612", "hair": "#1e1612", "beard": true, "mantle": "#e2d6ba", "mantle_edge": "#8a8a84",
		"staff": "#8b6a44", "bag": "#8b5a2b",
	},
	"bn_rep_shepherd_c": {
		"skin": "#c08a60", "skin_shade": "#9c6a45",
		"robe": "#e2d6ba", "robe_shade": "#c2b698", "robe_light": "#efe4cc",
		"sash": "#5a3d27", "head": "cloth", "head_color": "#8b5a2b", "head_shade": "#6d4420",
		"band": "#5a3d27", "hair": "#a0784a", "beard": true, "mantle": "#9e5a46",
		"staff": "#795437", "crook": true, "bag": "#6d4420",
	},
}

## Gente genérica dos grupos que representam a multidão do acampamento.
const CROWD_LOOKS := [
	{"skin": "#b07850", "skin_shade": "#8e5e3c", "robe": "#c8b890", "robe_shade": "#a89870", "robe_light": "#d8caa4",
		"sash": "#795437", "head": "cloth", "head_color": "#8e7a5a", "head_shade": "#6e5c40", "band": "#5a3d27", "hair": "#2b1d14", "beard": true},
	{"skin": "#c08a60", "skin_shade": "#9c6a45", "robe": "#9e7a5a", "robe_shade": "#7e5e44", "robe_light": "#b48e6c",
		"sash": "#5a3d27", "head": "veil", "head_color": "#d8ccb0", "head_shade": "#b8ac90", "band": "#8e5e36", "hair": "#2e1d12", "beard": false},
	{"skin": "#a8714c", "skin_shade": "#86573a", "robe": "#e2d6ba", "robe_shade": "#c2b698", "robe_light": "#efe4cc",
		"sash": "#a08a5e", "head": "hair", "head_color": "#2b1d14", "head_shade": "#1e140c", "band": "#2b1d14", "hair": "#2b1d14", "beard": false, "child": true},
	{"skin": "#9c6a48", "skin_shade": "#7c5236", "robe": "#6e6a60", "robe_shade": "#56524a", "robe_light": "#86827a",
		"sash": "#3d302a", "head": "cloth", "head_color": "#d9c8a0", "head_shade": "#b8a880", "band": "#795437", "hair": "#d8d0c0", "beard": true, "stoop": 1},
]

## Animais (6 quadros x 2 linhas: direita, esquerda), como a ovelha existente.
## body/head: Vector4(cx, cy, rx, ry); tail: Vector4(x0, y0, x1, y1).
const ANIMALS := {
	"egypt_cattle": {"w": 32, "h": 24, "body": Vector4(15, 13, 10, 5), "legs": [7, 9, 20, 22], "leg_len": 8, "leg_w": 2,
		"main": "#f0ead8", "shade": "#cfc6b0", "light": "#fbf8ee", "leg": "#8a7a64", "spot": "#8b5a2b",
		"spots": [Vector4(10, 12, 3, 2.5), Vector4(19, 11, 2.5, 2), Vector4(14, 15, 2, 1.5)],
		"head": Vector4(27, 10, 3, 2.5), "head_color": "#e2dac6", "muzzle": "#c8a890", "horns": "lyre", "horn": "#e8dcc0",
		"tail": Vector4(5, 10, 4, 18), "graze_drop": 4},
	"egypt_donkey": {"w": 28, "h": 22, "body": Vector4(13, 12, 8, 4), "legs": [7, 9, 17, 19], "leg_len": 7, "leg_w": 1,
		"main": "#9a8a7a", "shade": "#7a6c5e", "light": "#b0a292", "leg": "#6e6052", "stripe": "#5e5246",
		"head": Vector4(23, 8, 3, 2), "muzzle": "#e2dccf", "ears": "long_up", "blanket": "#c8b08a",
		"tail": Vector4(5, 10, 4, 16), "graze_drop": 4},
	"donkey": {"w": 28, "h": 22, "body": Vector4(13, 12, 8, 4), "legs": [7, 9, 17, 19], "leg_len": 7, "leg_w": 1,
		"main": "#9a9490", "shade": "#7a7470", "light": "#b4aea8", "leg": "#5e5a56", "stripe": "#4e4a46",
		"head": Vector4(23, 8, 3, 2), "muzzle": "#e2dccf", "ears": "long_up", "baskets": "#c9a45c", "halter": "#c2a878",
		"tail": Vector4(5, 10, 4, 16), "graze_drop": 4},
	"goat": {"w": 24, "h": 20, "body": Vector4(11, 11, 6.5, 3.5), "legs": [6, 8, 14, 16], "leg_len": 5, "leg_w": 1,
		"main": "#3d302a", "shade": "#2b2420", "light": "#5a4a40", "leg": "#2b2420",
		"head": Vector4(19, 8, 2.5, 2), "ears": "droop", "horns": "back", "horn": "#8a7a64", "beard": "#2b2420",
		"tail": Vector4(4, 9, 3, 6), "graze_drop": 3},
	"bn_dog": {"w": 24, "h": 18, "body": Vector4(11, 10, 6, 3), "legs": [6, 8, 14, 16], "leg_len": 5, "leg_w": 1,
		"main": "#d6b482", "shade": "#b8946a", "light": "#e8cc9a", "leg": "#b8946a",
		"head": Vector4(19, 7, 2.5, 2), "muzzle": "#c8a272", "ears": "up",
		"tail": Vector4(5, 8, 3, 3), "graze_drop": 2},
	"egypt_cat": {"w": 20, "h": 14, "body": Vector4(9, 9, 5, 2.5), "legs": [5, 6, 11, 12], "leg_len": 3, "leg_w": 1,
		"main": "#d8b880", "shade": "#b8985e", "light": "#e8cc98", "leg": "#b8985e", "spot": "#a8864e",
		"spots": [Vector4(7, 8, 0.8, 2), Vector4(10, 8, 0.8, 2), Vector4(13, 8, 0.8, 2)],
		"head": Vector4(15, 6, 2.5, 2.2), "ears": "big",
		"tail": Vector4(4, 8, 1, 3), "graze_drop": 1},
}

var gen
var rng := RandomNumberGenerator.new()


func _init(generator) -> void:
	gen = generator


func generate() -> void:
	rng.seed = 5_2026
	gen.rng.seed = 5_2027
	_tiles()
	_props()
	_characters()
	_animals()
	_item_icons()


# ---------------------------------------------------------------- atlas de terras

func _tiles() -> void:
	var a = PC.new(Spec.ATLAS_COLS * 16, Spec.LANDS_ROWS * 16)
	for i in Spec.SAND.size():
		_fill_tile(a, Spec.SAND[i] * 16, Color("#e3bf86"), [Color("#d4ab70"), Color("#eccf9a"), Color("#c9a26c")], 0.14 + i * 0.03)
	for i in Spec.SOIL.size():
		_fill_tile(a, Spec.SOIL[i] * 16, Color("#6a5442"), [Color("#5a4636"), Color("#7a6450"), Color("#4e3c2e")], 0.22)
	for i in Spec.ROCK.size():
		_fill_tile(a, Spec.ROCK[i] * 16, Color("#a08870"), [Color("#8a735e"), Color("#b49c80"), Color("#7a6450")], 0.2)
		var o: Vector2i = Spec.ROCK[i] * 16
		a.line(o.x + 3, o.y + 5 + i, o.x + 7, o.y + 8, Color("#6e5a46"))
		a.line(o.x + 10, o.y + 11 - i, o.x + 13, o.y + 10, Color("#6e5a46"))
	_decor_tiles(a)

	var soil := func(_x: int, _y: int) -> Color:
		var v := rng.randf()
		if v < 0.15:
			return Color("#5a4636")
		elif v < 0.25:
			return Color("#7a6450")
		return Color("#6a5442")
	var water := func(x: int, y: int) -> Color:
		if (x + y * 3) % 11 == 0 and y % 4 == 1:
			return Color("#6cb4cc")
		if rng.randf() < 0.14:
			return Color("#2a6a84")
		return Color("#33809c")
	var floor_p := func(_x: int, _y: int) -> Color:
		var v := rng.randf()
		if v < 0.12:
			return Color("#c8b28c")
		elif v < 0.18:
			return Color("#e6d6b4")
		return Color("#d8c4a0")
	var barley := func(x: int, y: int) -> Color:
		if x % 3 == 0:
			return Color("#b08e3c")
		if y % 6 == 1 or y % 6 == 2:
			return Color("#f0d68a")
		if rng.randf() < 0.1:
			return Color("#c4a24a")
		return Color("#d9b860")
	var stubble := func(x: int, y: int) -> Color:
		if x % 4 == 1 and y % 3 == 0:
			return Color("#9c8450")
		if x % 4 == 1 and y % 3 == 2:
			return Color("#e6d6a6")
		if rng.randf() < 0.1:
			return Color("#bfa672")
		return Color("#cdb682")
	var green := func(_x: int, _y: int) -> Color:
		var v := rng.randf()
		if v < 0.15:
			return Color("#5e7f30")
		elif v < 0.25:
			return Color("#86a04a")
		return Color("#6f8f3c")
	var rock := func(x: int, y: int) -> Color:
		if (x * 7 + y * 3) % 13 == 0:
			return Color("#7a6450")
		var v := rng.randf()
		if v < 0.14:
			return Color("#8a735e")
		elif v < 0.24:
			return Color("#b49c80")
		return Color("#a08870")
	for mask in 16:
		gen._overlay_tile(a, Spec.overlay_coords(Spec.LANDS_OVERLAY_SOIL, mask) * 16, mask, soil, Color("#4e3c2e"), 0.35)
		gen._overlay_tile(a, Spec.overlay_coords(Spec.LANDS_OVERLAY_WATER, mask) * 16, mask, water, Color("#cfe6e2"), 0.25)
		gen._overlay_tile(a, Spec.overlay_coords(Spec.LANDS_OVERLAY_FLOOR, mask) * 16, mask, floor_p, Color("#b8a07a"), 0.2)
		gen._overlay_tile(a, Spec.overlay_coords(Spec.LANDS_OVERLAY_BARLEY, mask) * 16, mask, barley, Color("#9c7e34"), 0.5)
		gen._overlay_tile(a, Spec.overlay_coords(Spec.LANDS_OVERLAY_STUBBLE, mask) * 16, mask, stubble, Color("#b09a68"), 0.4)
		gen._overlay_tile(a, Spec.overlay_coords(Spec.LANDS_OVERLAY_GREEN, mask) * 16, mask, green, Color("#55702c"), 0.45)
		gen._overlay_tile(a, Spec.overlay_coords(Spec.LANDS_OVERLAY_ROCK, mask) * 16, mask, rock, Color("#6e5a46"), 0.3)
	a.save("res://assets/tilesets/lands_tiles.png")


func _fill_tile(a, o: Vector2i, base: Color, specks: Array, density: float) -> void:
	a.rect(o.x, o.y, 16, 16, base)
	a.speckle(Rect2i(o, Vector2i(16, 16)), specks, density, rng)


func _decor_tiles(a) -> void:
	var o: Vector2i = Spec.SAND_RIPPLE * 16
	for k in 3:
		var y := o.y + 3 + k * 5
		var x0 := o.x + rng.randi_range(1, 6)
		for x in range(x0, x0 + 7):
			var dy := 1 if x == x0 or x == x0 + 6 else 0
			a.px(x, y + dy, Color("#cfa468"))
			a.px(x, y + dy - 1, Color("#efd6a6"))
	o = Spec.SHELLS * 16
	for k in 4:
		var x := o.x + rng.randi_range(2, 13)
		var y := o.y + rng.randi_range(2, 13)
		a.px(x, y, Color("#f4ede0"))
		a.px(x + 1, y, Color("#e2d6c4"))
		a.px(x, y + 1, Color(0.17, 0.11, 0.08, 0.3))
	o = Spec.DESERT_TUFT * 16
	for k in 3:
		var x := o.x + rng.randi_range(2, 13)
		var y := o.y + rng.randi_range(5, 14)
		a.px(x, y, Color("#8a7c44"))
		a.px(x - 1, y - 1, Color("#a89a5a"))
		a.px(x + 1, y - 1, Color("#a89a5a"))
		a.px(x - 2, y - 2, Color("#c4b46c"))
		a.px(x + 1, y - 3, Color("#c4b46c"))
	for pair in [[Spec.CROP_ROWS, false], [Spec.CROP_ROWS_B, true]]:
		o = pair[0] * 16
		for row in [2, 7, 12]:
			for x in range(1, 16, 3):
				a.px(o.x + x, o.y + row + 1, Color("#4f6e2a"))
				a.px(o.x + x, o.y + row, Color("#8fae5a") if pair[1] else Color("#86a04a"))
				a.px(o.x + x + 1, o.y + row - 1, Color("#a3b86a"))
				if pair[1] and rng.randf() < 0.35:
					a.px(o.x + x, o.y + row - 1, Color("#7f9fd8"))
	o = Spec.WATER_GLINT * 16
	for k in 3:
		var x := o.x + rng.randi_range(1, 11)
		var y := o.y + rng.randi_range(2, 13)
		a.rect(x, y, 3, 1, Color("#a8d8e4"))
		a.px(x + 1, y, Color("#e8f6f8"))
	o = Spec.STRAW * 16
	for k in 6:
		var x := o.x + rng.randi_range(1, 13)
		var y := o.y + rng.randi_range(2, 13)
		a.px(x, y, Color("#e8d49a"))
		a.px(x + 1, y - 1, Color("#c8b070"))
	o = Spec.LOTUS * 16
	for p in [Vector2(5, 5), Vector2(11, 11)]:
		a.ellipse(o.x + p.x, o.y + p.y, 3, 2, Color("#5e8a3a"))
		a.px(o.x + int(p.x) + 2, o.y + int(p.y), Color("#33809c"))
	a.px(o.x + 5, o.y + 4, Color("#f4f0e0"))
	a.px(o.x + 11, o.y + 10, Color("#7f9fd8"))
	a.px(o.x + 11, o.y + 9, Color("#e8c23a"))


# ---------------------------------------------------------------- objetos

func _props() -> void:
	for kind in WALLS:
		var pre := "%s_wall" % kind
		_wall(kind, true).save(ENV + pre + "_h.png")
		_wall(kind, false).save(ENV + pre + "_v.png")
	_tree_date_palm().save(ENV + "tree_date_palm.png")
	_tree_sycamore().save(ENV + "tree_sycamore.png")
	_tree_acacia().save(ENV + "tree_acacia.png")
	_tamarisk().save(ENV + "tamarisk.png")
	_reeds(26, 30, true).save(ENV + "papyrus_reeds.png")
	_reeds(22, 22, false).save(ENV + "reeds.png")
	_reed_fence(true).save(ENV + "reed_fence_h.png")
	_reed_fence(false).save(ENV + "reed_fence_v.png")
	_house_portico().save(ENV + "house_portico.png")
	_garden_pool().save(ENV + "garden_pool.png")
	_storage_jars().save(ENV + "storage_jars.png")
	_scribe_table().save(ENV + "scribe_table.png")
	_egypt_oven().save(ENV + "egypt_oven.png")
	_saddle_quern().save(ENV + "saddle_quern.png")
	_floor_loom().save(ENV + "floor_loom.png")
	_granary_silos().save(ENV + "granary_silos.png")
	_flax_bundles().save(ENV + "flax_bundles.png")
	_shaduf().save(ENV + "shaduf.png")
	_tent_worn().save(ENV + "tent_worn.png")
	_cloth_shelter().save(ENV + "cloth_shelter.png")
	_bread_stone_fire().save(ENV + "bread_stone_fire.png")
	_skins_tripod().save(ENV + "skins_tripod.png")
	_kneading_bundle().save(ENV + "kneading_bundle.png")
	_rock_crest().save(ENV + "rock_crest.png")
	_dune().save(ENV + "dune.png")
	_firepit_out().save(ENV + "firepit_out.png")
	_crowd_group(true).save(ENV + "crowd_group_a.png")
	_crowd_group(false).save(ENV + "crowd_group_b.png")
	_house_pillar().save(ENV + "house_pillar.png")
	_stone_bench().save(ENV + "stone_bench.png")
	_pithos().save(ENV + "pithos.png")
	_sheaf().save(ENV + "sheaf.png")
	_branch_shelter().save(ENV + "branch_shelter.png")
	_grain_heap().save(ENV + "grain_heap.png")
	_threshing_sledge().save(ENV + "threshing_sledge.png")
	_winnowing_fork().save(ENV + "winnowing_fork.png")
	_village_gate().save(ENV + "village_gate.png")
	_terrace_wall().save(ENV + "terrace_wall.png")
	_house_courtyard().save(ENV + "house_courtyard.png")
	_house_on_rock().save(ENV + "house_on_rock.png")
	_stone_stairs().save(ENV + "stone_stairs.png")
	_rock_shelter().save(ENV + "rock_shelter.png")
	_cloak_bed().save(ENV + "cloak_bed.png")
	_oil_lamp_niche().save(ENV + "oil_lamp_niche.png")
	_cave_mouth().save(ENV + "cave_mouth.png")
	_thorn_bush().save(ENV + "thorn_bush.png")


## Segmento de muro de 16 px. O horizontal mostra o topo e a face; o vertical,
## só a faixa do topo (vista 3/4), alinhada com o topo do horizontal.
func _wall(kind: String, horizontal: bool):
	var p: Dictionary = WALLS[kind]
	var h := int(p.h)
	var face_h := int(p.face_h)
	var top_rows := int(p.top_rows)
	var cv = PC.new(16, h)
	var top_y := h - 1 - face_h - top_rows + 1
	var top_c := Color(String(p.top))
	var top_l := Color(String(p.top_l))
	if horizontal:
		cv.rect(0, top_y, 16, top_rows, top_c)
		cv.rect(0, top_y, 16, 1, top_l)
		cv.speckle(Rect2i(0, top_y, 16, top_rows), [top_l, top_c.darkened(0.08)], 0.12, rng)
		var fy := top_y + top_rows
		if kind == "mudbrick":
			gen._stone_blocks(cv, 0, fy, 16, face_h, Color(String(p.face)), Color(String(p.mortar)), Color(String(p.light)))
		else:
			_dry_stone(cv, Rect2i(0, fy, 16, face_h), Color(String(p.face)), Color(String(p.mortar)), Color(String(p.light)))
		cv.rect(0, h - 2, 16, 1, Color(String(p.mortar)))
	else:
		cv.rect(4, top_y, 8, 16, top_c)
		cv.rect(4, top_y, 1, 16, top_l)
		cv.rect(11, top_y, 1, 16, top_c.darkened(0.15))
		cv.rect(12, top_y + 1, 1, 15, Color(String(p.face)).darkened(0.2))
		cv.speckle(Rect2i(4, top_y, 8, 16), [top_l, top_c.darkened(0.08)], 0.12, rng)
	if kind == "fold":
		var thorn := Color("#6e5a46")
		var thorn_l := Color("#8e7a5e")
		var x0 := 0 if horizontal else 4
		var x1 := 16 if horizontal else 12
		var span := top_rows if horizontal else 16
		for k in 7:
			var x := rng.randi_range(x0, x1 - 1)
			var y := top_y + rng.randi_range(-2, span - 2)
			cv.line(x, y, x + rng.randi_range(-3, 3), y - rng.randi_range(1, 3), thorn)
			cv.px(x, y - 1, thorn_l)
	cv.outline(INK)
	return cv


## Pedra seca: blocos irregulares com junta escura.
func _dry_stone(cv, r: Rect2i, face: Color, mortar: Color, light: Color) -> void:
	cv.rect(r.position.x, r.position.y, r.size.x, r.size.y, mortar)
	var y := r.position.y
	var row := 0
	while y < r.end.y:
		var bh := 3 if row % 2 == 0 else 4
		var x := r.position.x - (2 if row % 2 == 1 else 0)
		while x < r.end.x:
			var bw := rng.randi_range(4, 7)
			var shade := face.darkened(rng.randf_range(0.0, 0.12))
			for yy in range(y, mini(y + bh - 1, r.end.y)):
				for xx in range(maxi(x, r.position.x), mini(x + bw - 1, r.end.x)):
					cv.px(xx, yy, shade)
			cv.rect(maxi(x, r.position.x), y, mini(bw - 1, r.end.x - maxi(x, r.position.x)), 1, light)
			x += bw
		y += bh
		row += 1


func _frond(cv, base: Vector2, d: Vector2, mid: Color, light: Color, dark: Color) -> void:
	var steps := int(d.length())
	for i in steps + 1:
		var t := float(i) / float(maxi(steps, 1))
		var p := base + d * t + Vector2(0, absf(d.x) * 0.45 * t * t)
		var x := roundi(p.x)
		var y := roundi(p.y)
		cv.px(x, y, mid)
		if i > 1 and i % 2 == 0:
			cv.px(x, y + 1, dark)
			cv.px(x, y + 2, dark if t > 0.5 else mid)
			cv.px(x, y - 1, light)


func _tree_date_palm():
	var cv = PC.new(40, 64)
	var trunk := Color("#8a6a48")
	for y in range(18, 62):
		var x := 19 + roundi(sin(y * 0.09) * 2.0)
		cv.rect(x - 1, y, 3, 1, Color("#6e5238") if y % 3 == 0 else trunk)
		cv.px(x - 1, y, Color("#a8865e"))
		cv.px(x + 1, y, Color("#6e5238"))
	var top := Vector2(19 + roundi(sin(18 * 0.09) * 2.0), 16)
	cv.ellipse(top.x - 3, top.y + 5, 2, 2.5, Color("#9c5a2e"))
	cv.ellipse(top.x + 3, top.y + 5, 2, 2.5, Color("#b8733d"))
	for f in [Vector2(-17, 6), Vector2(-14, -2), Vector2(-7, -11), Vector2(0, -13), Vector2(8, -11),
			Vector2(15, -3), Vector2(18, 6), Vector2(-10, 10), Vector2(11, 10)]:
		_frond(cv, top, f, Color("#5e7f3a"), Color("#8fa84e"), Color("#3f5a2e"))
	cv.outline(INK)
	cv.shadow(20, 62, 10, 2.5, 0.3)
	return cv


func _tree_sycamore():
	var cv = PC.new(56, 56)
	for y in range(30, 53):
		var tw := 6 + (2 if y > 48 else 0)
		var x := 25 - (1 if y > 48 else 0)
		cv.rect(x, y, tw, 1, Color("#7a6248"))
		cv.px(x, y, Color("#968068"))
		cv.px(x + tw - 1, y, Color("#5a4636"))
	cv.line(26, 34, 16, 24, Color("#7a6248"))
	cv.line(30, 34, 40, 23, Color("#7a6248"))
	var blobs := [Vector4(28, 22, 18, 11), Vector4(12, 26, 9, 7), Vector4(44, 26, 9, 7),
		Vector4(20, 13, 10, 7), Vector4(36, 13, 10, 7), Vector4(28, 8, 9, 5)]
	gen._blob_canopy(cv, blobs, Color("#3f5a2e"), Color("#5e7f3a"), Color("#86a04a"), Color("#a9bf68"))
	cv.speckle(Rect2i(6, 4, 44, 30), [Color("#c8a060")], 0.02, rng)
	cv.outline(INK)
	cv.shadow(28, 53.5, 16, 3, 0.35)
	return cv


func _tree_acacia():
	var cv = PC.new(52, 46)
	var wood := Color("#6e5238")
	for d in [0, 1]:
		cv.line(25 + d, 44, 25 + d, 28, wood)
		cv.line(25 + d, 30, 15 + d, 18, wood)
		cv.line(25 + d, 31, 36 + d, 17, wood)
	cv.line(26, 35, 40, 24, wood)
	var blobs := [Vector4(26, 15, 22, 6), Vector4(13, 17, 10, 4), Vector4(39, 17, 10, 4), Vector4(26, 10, 14, 4)]
	gen._blob_canopy(cv, blobs, Color("#55642e"), Color("#7a8b3a"), Color("#a3b14b"), Color("#c4c890"))
	cv.outline(INK)
	cv.shadow(26, 44, 12, 2.5, 0.3)
	return cv


func _tamarisk():
	var cv = PC.new(34, 42)
	var wood := Color("#6e5a46")
	cv.line(16, 40, 17, 26, wood)
	cv.line(17, 40, 18, 26, wood)
	cv.line(17, 30, 11, 22, wood)
	cv.line(18, 30, 24, 21, wood)
	var blobs := [Vector4(17, 20, 13, 10), Vector4(9, 24, 6, 6), Vector4(25, 24, 6, 6), Vector4(17, 10, 8, 7)]
	gen._blob_canopy(cv, blobs, Color("#56664e"), Color("#7f8f74"), Color("#a3b094"), Color("#c4ccb4"))
	cv.speckle(Rect2i(3, 3, 28, 28), [Color("#c8a0a8")], 0.02, rng)
	cv.outline(INK)
	cv.shadow(17, 40, 9, 2, 0.3)
	return cv


func _reeds(w: int, h: int, papyrus: bool):
	var cv = PC.new(w, h)
	var stem := Color("#6f8f3c")
	var stem_d := Color("#55702c")
	var n := 7 if papyrus else 8
	for i in n:
		var x := 3 + i * (w - 6) / maxi(n - 1, 1) + rng.randi_range(-1, 1)
		var tx := x + rng.randi_range(-2, 2)
		var ty := rng.randi_range(3, h / 3)
		cv.line(x, h - 2, tx, ty, stem if i % 2 == 0 else stem_d)
		if papyrus:
			for k in range(-3, 4):
				cv.line(tx, ty, tx + k, ty - 3 + absi(k) / 2, Color("#9cb85a"))
		else:
			cv.rect(tx, ty - 3, 1, 4, Color("#8e6a3e"))
			cv.px(tx, ty - 4, Color("#b89a6a"))
	for i in 4:
		var bx := rng.randi_range(2, w - 4)
		cv.line(bx, h - 2, bx + rng.randi_range(-4, 4), h - 8, Color("#86a04a"))
	cv.outline(INK)
	cv.shadow(w / 2.0, h - 1.5, w * 0.4, 1.5)
	return cv


func _reed_fence(horizontal: bool):
	var cv = PC.new(16, 16)
	var a := Color("#c4b06a")
	var b := Color("#a8944e")
	if horizontal:
		for x in 16:
			cv.rect(x, 3 + (x % 2), 1, 12 - (x % 2), a if x % 3 != 0 else b)
		cv.rect(0, 6, 16, 1, Color("#795437"))
		cv.rect(0, 11, 16, 1, Color("#795437"))
	else:
		for x in range(6, 10):
			cv.rect(x, 0, 1, 16, a if x % 2 == 0 else b)
		cv.rect(6, 4, 4, 1, Color("#795437"))
		cv.rect(6, 11, 4, 1, Color("#795437"))
	cv.outline(INK)
	return cv


## Casa genérica de um oficial egípcio: tijolo de barro caiado, teto plano,
## pórtico de colunas de madeira. Sem símbolos reais, pirâmides ou inscrições.
func _house_portico():
	var w := 192
	var cv = PC.new(w, 128)
	var white := Color("#efe6d2")
	var white_sh := Color("#d6caae")
	var base := 125
	# Corpo principal e teto plano visto de cima
	cv.rect(6, 30, w - 12, base - 30, white)
	cv.speckle(Rect2i(6, 30, w - 12, base - 30), [Color("#e2d8c0"), Color("#f6efe0")], 0.08, rng)
	cv.rect(w - 18, 30, 12, base - 30, white_sh)
	cv.rect(6, 8, w - 12, 22, Color("#d8c8a8"))
	for y in range(11, 28, 3):
		for x in range(9, w - 9):
			if rng.randf() < 0.45:
				cv.px(x, y, Color("#c8b690"))
	cv.rect(6, 8, w - 12, 2, Color("#e8dcc0"))
	cv.rect(6, 28, w - 12, 2, Color("#b8a47e"))
	cv.rect(6, 8, 2, 22, Color("#e8dcc0"))
	cv.rect(w - 8, 8, 2, 22, Color("#c4b28c"))
	# Escada para o teto e jarros no terraço
	for i in 4:
		cv.rect(w - 34 + i * 3, 24 - i * 3, 6, 2, Color("#b8a47e"))
	gen._clay_jar(cv, 22, 24, 2.5, Color("#b8734d"))
	gen._clay_jar(cv, 30, 25, 2, Color("#c8b08a"))
	# Base de tijolo
	gen._stone_blocks(cv, 6, base - 12, w - 12, 12, Color("#a8794e"), Color("#87603e"), Color("#b98a5c"))
	# Janelas altas com grade
	for wx in [18, w - 34]:
		cv.rect(wx, 54, 12, 7, Color("#3a2a22"))
		for gx in range(wx + 2, wx + 12, 3):
			cv.rect(gx, 54, 1, 7, Color("#a8865e"))
		cv.rect(wx - 1, 53, 14, 1, Color("#c8b690"))
	# Pórtico: interior sombreado, porta, laje e colunas
	var px0 := 40
	var px1 := w - 40
	cv.rect(px0, 62, px1 - px0, base - 8 - 62, Color("#8a7a64"))
	cv.rect(px0, 62, px1 - px0, 3, Color("#6e604e"))
	var cx := w / 2
	cv.rect(cx - 9, 76, 18, base - 8 - 76, Color("#3a2a22"))
	cv.rect(cx - 11, 73, 22, 3, Color("#795437"))
	cv.rect(px0 - 4, 54, px1 - px0 + 8, 8, Color("#e2d8c0"))
	cv.rect(px0 - 4, 54, px1 - px0 + 8, 1, Color("#f6efe0"))
	cv.rect(px0 - 4, 61, px1 - px0 + 8, 1, Color("#b8a47e"))
	for col_x in [px0 + 8, px0 + 36, px1 - 40, px1 - 12]:
		cv.rect(col_x, 62, 4, base - 8 - 62, Color("#8e5e36"))
		cv.rect(col_x, 62, 1, base - 8 - 62, Color("#a8764a"))
		cv.rect(col_x - 1, 62, 6, 3, Color("#7a8b3a"))
		cv.rect(col_x - 1, base - 10, 6, 2, Color("#c8b690"))
	# Plataforma de entrada
	cv.rect(px0 - 6, base - 8, px1 - px0 + 12, 7, Color("#d6c09a"))
	cv.rect(px0 - 6, base - 8, px1 - px0 + 12, 1, Color("#e6d6b4"))
	cv.rect(px0 - 6, base - 2, px1 - px0 + 12, 1, Color("#b8a07a"))
	cv.outline(INK)
	cv.shadow(cx, base + 1.5, w * 0.5, 3)
	return cv


func _garden_pool():
	var cv = PC.new(56, 36)
	cv.rect(2, 8, 52, 24, Color("#c8b090"))
	cv.rect(2, 8, 52, 2, Color("#dcc8a8"))
	cv.rect(2, 29, 52, 3, Color("#a89070"))
	cv.rect(6, 12, 44, 15, Color("#33809c"))
	cv.rect(6, 12, 44, 2, Color("#2a6a84"))
	cv.speckle(Rect2i(6, 14, 44, 13), [Color("#6cb4cc")], 0.05, rng)
	for p in [Vector2(14, 18), Vector2(24, 22), Vector2(38, 17), Vector2(44, 23)]:
		cv.ellipse(p.x, p.y, 3, 2, Color("#5e8a3a"))
		cv.px(int(p.x) + 2, int(p.y), Color("#33809c"))
	cv.px(14, 17, Color("#7f9fd8"))
	cv.px(15, 17, Color("#9fb8e8"))
	cv.px(38, 16, Color("#f4f0e0"))
	cv.px(38, 15, Color("#e8c23a"))
	cv.outline(INK)
	cv.shadow(28, 32.5, 26, 2)
	return cv


func _tall_jar(cv, cx: float, base_y: float, rx: float, ry: float, body: Color) -> void:
	cv.ellipse(cx, base_y - ry - 1, rx, ry, body.darkened(0.2))
	cv.ellipse(cx - 0.5, base_y - ry - 1.5, rx - 0.5, ry - 0.5, body)
	cv.ellipse_on_solid(cx - rx * 0.4, base_y - ry * 1.3 - 1, rx * 0.3, ry * 0.45, body.lightened(0.2))
	cv.rect(roundi(cx - rx * 0.45), roundi(base_y - ry * 2 - 3), roundi(rx * 0.9), 3, body.darkened(0.1))


func _storage_jars():
	var cv = PC.new(34, 28)
	_tall_jar(cv, 8, 26, 4.5, 8, Color("#b8734d"))
	_tall_jar(cv, 26, 26, 4.5, 8, Color("#a86a44"))
	_tall_jar(cv, 17, 27, 5, 9, Color("#c98e5e"))
	for x in [8, 17, 26]:
		cv.rect(x - 2, 4 if x == 17 else 6, 4, 2, Color("#9c8a72"))
	cv.outline(INK)
	cv.shadow(17, 26.5, 15, 1.5)
	return cv


func _scribe_table():
	var cv = PC.new(30, 20)
	cv.rect(4, 11, 2, 7, Color("#6e4a2c"))
	cv.rect(24, 11, 2, 7, Color("#5a3d27"))
	cv.rect(2, 6, 26, 6, Color("#a8713d"))
	cv.rect(2, 6, 26, 1, Color("#c28a52"))
	cv.rect(2, 11, 26, 1, Color("#8e5e36"))
	cv.rect(5, 4, 9, 3, Color("#efe4c4"))
	cv.ellipse(14, 5.5, 1.5, 1.5, Color("#d8cca8"))
	cv.rect(17, 5, 7, 2, Color("#c8b08a"))
	cv.px(19, 5, Color("#2b1d14"))
	cv.px(21, 5, Color("#a0432f"))
	gen._clay_jar(cv, 26, 7, 1.5, Color("#9c5c3c"))
	cv.outline(INK)
	cv.shadow(15, 18, 12, 1.2)
	return cv


func _egypt_oven():
	var cv = PC.new(22, 24)
	cv.rect(3, 6, 16, 15, Color("#a8713d"))
	cv.rect(3, 6, 2, 15, Color("#c28a52"))
	cv.rect(16, 6, 3, 15, Color("#8e5e36"))
	cv.ellipse(11, 6, 8, 2.5, Color("#c28a52"))
	cv.ellipse(11, 6, 5, 1.5, Color("#3a2a22"))
	cv.ellipse(11, 21, 8, 2, Color("#8e5e36"))
	cv.rect(8, 15, 6, 5, Color("#2b1d14"))
	cv.px(10, 18, Color("#e0702f"))
	cv.px(11, 19, Color("#ffb347"))
	cv.outline(INK)
	cv.shadow(11, 22.5, 9, 1.5)
	return cv


func _saddle_quern():
	var cv = PC.new(24, 12)
	cv.ellipse(12, 7, 10, 3.5, Color("#8a7962"))
	cv.ellipse(12, 6.5, 9.5, 3, Color("#a8987c"))
	cv.ellipse(11, 5, 4, 1.8, Color("#c8b89a"))
	cv.ellipse_on_solid(10, 4.5, 2, 1, Color("#dccdb0"))
	cv.px(17, 6, Color("#f0ead8"))
	cv.px(18, 7, Color("#f0ead8"))
	cv.outline(INK)
	cv.shadow(12, 10, 10, 1.2)
	return cv


func _floor_loom():
	var cv = PC.new(38, 18)
	for x in range(4, 34, 2):
		cv.rect(x, 4, 1, 9, Color("#efe8d6"))
	cv.rect(4, 9, 30, 4, Color("#e2d8c0"))
	cv.rect(4, 10, 30, 1, Color("#d2c8ae"))
	cv.rect(2, 3, 34, 2, Color("#8b5a2b"))
	cv.rect(2, 13, 34, 2, Color("#795437"))
	cv.rect(4, 7, 30, 1, Color("#a07a50"))
	for p in [Vector2i(1, 3), Vector2i(36, 3), Vector2i(1, 13), Vector2i(36, 13)]:
		cv.rect(p.x, p.y - 1, 1, 4, Color("#5a3d27"))
	cv.outline(INK)
	return cv


## Silos de topo abobadado baixo, em fileira; sem grãos transbordando.
func _granary_silos():
	var cv = PC.new(76, 58)
	var brick := Color("#b88a5a")
	var plaster := Color("#d6b48a")
	for i in 3:
		var cx := 14 + i * 24
		var top := 22 if i == 1 else 26
		cv.rect(cx - 10, top, 20, 54 - top, plaster)
		cv.rect(cx - 10, top, 2, 54 - top, Color("#e2c49a"))
		cv.rect(cx + 6, top, 4, 54 - top, brick)
		cv.ellipse(cx, top, 10, 6, plaster)
		cv.ellipse_on_solid(cx - 3, top - 2, 4, 2, Color("#e6cca4"))
		cv.ellipse(cx, top - 3, 2.5, 1.2, Color("#3a2a22"))
		cv.rect(cx - 2, 46, 5, 6, Color("#5a3d27"))
		cv.rect(cx - 2, 46, 5, 1, Color("#795437"))
	cv.rect(2, 52, 72, 3, Color("#a8794e"))
	cv.line(36, 52, 44, 20, Color("#795437"))
	cv.line(40, 52, 48, 20, Color("#795437"))
	for k in range(24, 52, 5):
		var t := float(k - 20) / 32.0
		cv.line(int(lerpf(44, 36, t)), k, int(lerpf(48, 40, t)), k, Color("#97704d"))
	cv.outline(INK)
	cv.shadow(38, 55.5, 36, 2.5)
	return cv


func _flax_bundles():
	var cv = PC.new(28, 18)
	for bx in [5, 14, 23]:
		for k in range(-3, 4):
			cv.line(bx + k / 2, 15, bx + k, 3 + absi(k) / 2, Color("#c8b070") if k % 2 == 0 else Color("#a89050"))
		cv.rect(bx - 2, 9, 4, 1, Color("#795437"))
		cv.px(bx - 1, 2, Color("#8a9a4a"))
		cv.px(bx + 1, 2, Color("#a3b14b"))
	cv.outline(INK)
	cv.shadow(14, 16, 12, 1.3)
	return cv


## Balancim (shaduf) junto ao canal: um só, aceito como possível elemento tardio.
func _shaduf():
	var cv = PC.new(44, 52)
	var wood := Color("#795437")
	cv.rect(11, 16, 3, 34, wood)
	cv.rect(11, 16, 1, 34, Color("#97704d"))
	cv.px(10, 14, wood)
	cv.px(14, 14, wood)
	cv.line(2, 24, 40, 8, Color("#8e6a44"))
	cv.line(2, 25, 40, 9, Color("#6e4a2c"))
	cv.ellipse(4, 25, 3.5, 3.5, Color("#6e5a46"))
	cv.ellipse_on_solid(3, 24, 1.5, 1.5, Color("#8a735e"))
	cv.line(40, 10, 40, 36, Color("#c2a878"))
	cv.ellipse(40, 39, 3, 2.5, Color("#8b5a2b"))
	cv.rect(37, 36, 7, 1, Color("#6d4420"))
	cv.ellipse(12, 50, 5, 1.5, Color("#5e4a3a"))
	cv.outline(INK)
	cv.shadow(12, 50.5, 5, 1.2)
	return cv


func _tent_worn():
	var cv = PC.new(48, 40)
	var goat := Color("#3a2e28")
	var stripe := Color("#4a3c32")
	for y in range(10, 24):
		var t := float(y - 10) / 13.0
		var x0 := roundi(lerpf(8, 2, t))
		var x1 := roundi(lerpf(40, 46, t))
		cv.rect(x0, y, x1 - x0, 1, stripe if (y - 10) % 4 == 0 else goat)
	cv.rect(14, 13, 6, 4, Color("#5b4636"))
	cv.rect(30, 17, 7, 3, Color("#6e5646"))
	cv.rect(8, 24, 32, 13, Color("#241a16"))
	cv.rect(27, 24, 13, 13, Color("#4e3c30"))
	for x in range(3, 46, 3):
		cv.px(x, 23 + (x % 2), goat)
	cv.rect(5, 10, 1, 28, Color("#795437"))
	cv.rect(42, 10, 1, 28, Color("#795437"))
	cv.rect(14, 35, 12, 2, Color("#a08a5e"))
	cv.outline(INK)
	cv.line(2, 23, 0, 37, Color("#c9b48a"))
	cv.line(45, 23, 47, 37, Color("#c9b48a"))
	cv.shadow(24, 38, 22, 2)
	return cv


func _cloth_shelter():
	var cv = PC.new(42, 30)
	cv.rect(4, 6, 1, 22, Color("#795437"))
	cv.rect(37, 6, 1, 22, Color("#795437"))
	cv.rect(5, 17, 32, 10, Color("#3a2e26"))
	cv.ellipse(12, 24, 4, 3, Color("#c2a878"))
	cv.ellipse(28, 24, 5, 3, Color("#9e7a5a"))
	for y in range(6, 18):
		var sag := 1 if y > 12 else 0
		cv.rect(3 + sag, y, 35 - sag * 2, 1, Color("#d8ccb0") if y % 5 != 0 else Color("#c8bca0"))
	cv.rect(3, 14, 35, 1, Color("#8e5e36"))
	cv.rect(3, 17, 35, 1, Color("#b8ac90"))
	cv.outline(INK)
	cv.line(4, 6, 0, 27, Color("#c9b48a"))
	cv.line(37, 6, 41, 27, Color("#c9b48a"))
	cv.shadow(21, 28, 19, 2)
	return cv


func _bread_stone_fire():
	var cv = PC.new(22, 12)
	for i in 7:
		var ang := TAU * i / 7.0
		cv.ellipse(11 + cos(ang) * 7, 7 + sin(ang) * 2.8, 1.8, 1.3, Color("#9c8a72"))
	cv.ellipse(11, 7, 5, 1.8, Color("#3a2a22"))
	cv.px(9, 7, Color("#e0702f"))
	cv.px(13, 6, Color("#ffb347"))
	cv.ellipse(15, 5, 3, 1.4, Color("#a8987c"))
	cv.ellipse(15, 4.5, 2.2, 1, Color("#d6a35c"))
	cv.outline(INK)
	cv.shadow(11, 10.5, 9, 1.2)
	return cv


func _skins_tripod():
	var cv = PC.new(20, 30)
	var wood := Color("#795437")
	cv.line(10, 3, 11, 27, wood.darkened(0.2))
	cv.line(10, 3, 3, 28, wood)
	cv.line(10, 3, 17, 28, wood)
	cv.rect(9, 3, 3, 2, Color("#c2a878"))
	cv.line(10, 5, 10, 9, Color("#c2a878"))
	cv.ellipse(10, 15, 4, 5, Color("#8b5a2b"))
	cv.ellipse(9.5, 14.5, 3, 4, Color("#a8713d"))
	cv.rect(9, 9, 2, 2, Color("#6d4420"))
	cv.outline(INK)
	cv.shadow(10, 28.5, 7, 1.3)
	return cv


## Amassadeira atada no manto (Êx 12:34): trouxa de pano com a borda da gamela.
func _kneading_bundle():
	var cv = PC.new(18, 14)
	cv.ellipse(9, 8, 7.5, 4.5, Color("#a89870"))
	cv.ellipse(8.5, 7.5, 7, 4, Color("#c8b890"))
	cv.ellipse(9, 4, 2.5, 1.5, Color("#a89870"))
	cv.px(8, 3, Color("#d8caa4"))
	cv.line(3, 9, 7, 11, Color("#8e5e36"))
	cv.line(7, 11, 13, 11, Color("#8e5e36"))
	cv.outline(INK)
	cv.shadow(9, 12.5, 7, 1.2)
	return cv


func _rock_lumps(cv, lumps: Array, dark: Color, mid: Color, light: Color) -> void:
	for l in lumps:
		cv.ellipse(l.x + 0.5, l.y + 0.5, l.z, l.w, dark)
	for l in lumps:
		cv.ellipse(l.x - 0.5, l.y - 0.5, l.z - 0.8, l.w - 0.8, mid)
	for l in lumps:
		cv.ellipse_on_solid(l.x - l.z * 0.3, l.y - l.w * 0.35, l.z * 0.45, l.w * 0.3, light)
	cv.speckle(Rect2i(0, 0, cv.w, cv.h), [dark.lightened(0.1), mid.lightened(0.08)], 0.08, rng)


func _rock_crest():
	var cv = PC.new(44, 30)
	_rock_lumps(cv, [Vector4(12, 20, 11, 8), Vector4(25, 15, 12, 12), Vector4(36, 21, 7, 6)],
		Color("#6e5a46"), Color("#92765c"), Color("#b49a7c"))
	cv.line(24, 6, 27, 14, Color("#6e5a46"))
	cv.outline(INK)
	cv.shadow(22, 28, 20, 2)
	return cv


func _dune():
	var cv = PC.new(60, 20)
	cv.ellipse(30, 13, 28, 6, Color("#c9a26c"))
	cv.ellipse(27, 12, 25, 5.5, Color("#e6c48e"))
	cv.ellipse_on_solid(22, 10, 14, 2.5, Color("#f0d8aa"))
	for x in range(12, 40):
		cv.px(x, 8 + roundi(sin(x * 0.2) * 0.8), Color("#f4e0b4"))
	cv.outline(INK)
	return cv


func _firepit_out():
	var cv = PC.new(16, 12)
	for i in 8:
		var ang := TAU * i / 8.0
		cv.ellipse(8 + cos(ang) * 5.5, 7 + sin(ang) * 2.8, 1.6, 1.3, Color("#9c8a72"))
	cv.ellipse(8, 7, 3.5, 1.6, Color("#8a8278"))
	cv.px(7, 7, Color("#3a2a22"))
	cv.px(9, 6, Color("#3a2a22"))
	cv.px(8, 7, Color("#a8a096"))
	cv.outline(INK)
	cv.shadow(8, 10.5, 7, 1.2)
	return cv


## Parte de cima de um quadro de personagem, rebaixada: pessoa sentada.
func _seated(frame, drop: int, robe: Color):
	var cv = PC.new(frame.w, frame.h)
	for y in frame.h - drop:
		for x in frame.w:
			var c: Color = frame.get_px(x, y)
			if c.a > 0.0:
				cv.px(x, y + drop, c)
	cv.ellipse(12, 28, 7, 2.5, robe.darkened(0.1))
	cv.ellipse(12, 27.5, 6, 2, robe)
	return cv


## Grupos de gente que representam a multidão do acampamento (sem rostos em destaque).
func _crowd_group(seated_group: bool):
	var w := 56 if seated_group else 48
	var cv = PC.new(w, 40)
	var l0: Dictionary = CROWD_LOOKS[0]
	var l1: Dictionary = CROWD_LOOKS[1]
	var l2: Dictionary = CROWD_LOOKS[2]
	var l3: Dictionary = CROWD_LOOKS[3]
	if seated_group:
		cv.ellipse(28, 33, 8, 3, Color("#c2a878"))
		cv.ellipse(27.5, 32.5, 7, 2.5, Color("#d8caa4"))
		cv.blit(_seated(gen._character_frame(2, 4, l0), 8, Color(String(l0.robe))), 0, 6)
		cv.blit(_seated(gen._character_frame(1, 5, l1), 8, Color(String(l1.robe))), 32, 6)
		cv.blit(gen._character_frame(0, 4, l2), 16, 8)
	else:
		cv.blit(gen._character_frame(0, 5, l3), 2, 6)
		cv.blit(gen._character_frame(2, 4, l1), 22, 4)
		cv.blit(gen._character_frame(0, 4, l2), 12, 8)
	return cv


## Casa de pilares (época dos juízes): base de pedra, reboco, teto plano.
func _house_pillar():
	var w := 76
	var cv = PC.new(w, 60)
	var base := 57
	cv.rect(2, 16, w - 4, base - 16, Color("#c9a57a"))
	cv.speckle(Rect2i(2, 16, w - 4, base - 16), [Color("#b8925f"), Color("#d6b98e")], 0.1, rng)
	cv.rect(w - 9, 16, 7, base - 16, Color("#b38e62"))
	gen._stone_blocks(cv, 2, base - 14, w - 4, 14, Color("#b8ac90"), Color("#8e826a"), Color("#cdc1a4"))
	cv.rect(2, 3, w - 4, 13, Color("#d9c29a"))
	for y in range(5, 15, 3):
		for x in range(4, w - 4):
			if rng.randf() < 0.5:
				cv.px(x, y, Color("#c7ae84"))
	cv.rect(2, 3, w - 4, 1, Color("#e6d3ae"))
	cv.rect(2, 15, w - 4, 1, Color("#a8875e"))
	for i in 4:
		cv.rect(w - 24 + i * 2, 6, 1, 6, Color("#d8c27a"))
	gen._clay_jar(cv, 10, 13, 2, Color("#c2956a"))
	# Pátio lateral aberto com dois pilares de pedra
	cv.rect(6, 28, 18, base - 30, Color("#5a4a3c"))
	for pxx in [10, 18]:
		cv.rect(pxx, 28, 3, base - 30, Color("#cdc1a4"))
		cv.rect(pxx, 28, 1, base - 30, Color("#e0d6c0"))
	# Porta com verga
	var cx := 46
	cv.rect(cx - 7, 30, 14, 3, Color("#795437"))
	cv.rect(cx - 5, 33, 10, base - 33, Color("#3a2a22"))
	cv.rect(w - 18, 24, 6, 5, Color("#3a2a22"))
	cv.outline(INK)
	cv.shadow(w / 2.0, base + 1.5, w * 0.48, 2.5)
	return cv


func _stone_bench():
	var cv = PC.new(26, 12)
	cv.rect(4, 6, 4, 4, Color("#9c8a72"))
	cv.rect(18, 6, 4, 4, Color("#8a7962"))
	cv.rect(2, 3, 22, 4, Color("#c8bca4"))
	cv.rect(2, 3, 22, 1, Color("#e0d6c0"))
	cv.rect(2, 6, 22, 1, Color("#a89c84"))
	cv.outline(INK)
	cv.shadow(13, 10, 11, 1.2)
	return cv


## Jarro de armazenagem de borda em colarinho (típico do Ferro I).
func _pithos():
	var cv = PC.new(14, 24)
	var body := Color("#c2956a")
	cv.ellipse(7, 15, 5.5, 7.5, body.darkened(0.2))
	cv.ellipse(6.5, 14.5, 5, 7, body)
	cv.ellipse_on_solid(5, 12, 1.8, 3.5, body.lightened(0.18))
	cv.rect(4, 3, 6, 4, body.darkened(0.08))
	cv.rect(3, 7, 8, 1, body.darkened(0.25))
	cv.rect(4, 2, 6, 1, body.lightened(0.15))
	cv.outline(INK)
	cv.shadow(7, 22.5, 5, 1.2)
	return cv


func _sheaf():
	var cv = PC.new(14, 18)
	for k in range(-3, 4):
		cv.line(7 + k / 2, 10, 7 + k, 15, Color("#c8a450") if k % 2 == 0 else Color("#b08e3c"))
	cv.ellipse(7, 6, 4.5, 4, Color("#d9b860"))
	cv.speckle(Rect2i(2, 2, 10, 8), [Color("#f0d68a"), Color("#b08e3c")], 0.3, rng)
	for k in [-4, -2, 2, 4]:
		cv.line(7 + k / 2, 3, 7 + k, 0, Color("#e8d49a"))
	cv.rect(5, 10, 5, 1, Color("#8e6a36"))
	cv.outline(INK)
	cv.shadow(7, 16, 5, 1.2)
	return cv


## Abrigo de ramos para descanso dos ceifeiros (Rt 2:7, hipótese).
func _branch_shelter():
	var cv = PC.new(46, 38)
	cv.shadow(23, 30, 18, 4, 0.35)
	for x in [9, 37]:
		cv.rect(x, 12, 1, 20, Color("#5a3d27"))
	for x in [4, 41]:
		cv.rect(x, 10, 2, 26, Color("#795437"))
	cv.rect(14, 28, 18, 3, Color("#c8b890"))
	cv.rect(14, 28, 18, 1, Color("#d8caa4"))
	var blobs := [Vector4(23, 10, 21, 6), Vector4(10, 11, 8, 4), Vector4(36, 11, 8, 4), Vector4(23, 6, 12, 4)]
	gen._blob_canopy(cv, blobs, Color("#5e6e2a"), Color("#7a8b3a"), Color("#a3b14b"), Color("#c4c890"))
	cv.speckle(Rect2i(2, 2, 42, 14), [Color("#a8864e")], 0.08, rng)
	cv.outline(INK)
	return cv


func _grain_heap():
	var cv = PC.new(34, 18)
	for k in 8:
		var x := rng.randi_range(2, 30)
		cv.line(x, 15, x + rng.randi_range(-3, 3), 13, Color("#e8d49a"))
	cv.ellipse(17, 11, 13, 5.5, Color("#b8963e"))
	cv.ellipse(16.5, 10.5, 12, 5, Color("#d9b860"))
	cv.ellipse_on_solid(13, 8.5, 5, 2, Color("#ecd08a"))
	cv.speckle(Rect2i(4, 5, 26, 11), [Color("#f0e0a8"), Color("#c4a24a")], 0.15, rng)
	cv.outline(INK)
	cv.shadow(17, 15.5, 15, 1.5)
	return cv


## Trenó de debulha: tábua de madeira com lascas de pedra embaixo (sem ferro).
func _threshing_sledge():
	var cv = PC.new(28, 12)
	cv.rect(2, 3, 24, 6, Color("#8e6a44"))
	cv.rect(2, 3, 24, 1, Color("#a8865e"))
	for x in [8, 14, 20]:
		cv.rect(x, 3, 1, 6, Color("#6e4a2c"))
	cv.rect(24, 2, 3, 6, Color("#a8865e"))
	for x in range(3, 24, 3):
		cv.px(x, 9, Color("#e0d6c0"))
	cv.outline(INK)
	cv.shadow(14, 10, 12, 1.2)
	return cv


func _winnowing_fork():
	var cv = PC.new(26, 10)
	cv.line(2, 7, 18, 3, Color("#a07a50"))
	cv.line(2, 8, 18, 4, Color("#795437"))
	for k in [1, 3, 5]:
		cv.line(18, 3 + (k - 3) / 2, 24, k, Color("#a07a50"))
	cv.outline(INK)
	return cv


func _village_gate():
	var cv = PC.new(64, 58)
	for x0 in [0, 46]:
		gen._stone_blocks(cv, x0, 10, 18, 45, Color("#c8bca4"), Color("#8e826a"), Color("#dcd2bc"))
		cv.rect(x0, 8, 18, 3, Color("#e0d6c0"))
	cv.rect(18, 14, 28, 41, Color("#6e4a2c"))
	for x in range(20, 46, 4):
		cv.rect(x, 14, 1, 41, Color("#5a3d27"))
	cv.rect(31, 14, 2, 41, Color("#3a2a22"))
	cv.rect(14, 10, 36, 4, Color("#795437"))
	cv.rect(14, 10, 36, 1, Color("#97704d"))
	cv.outline(INK)
	cv.shadow(32, 55.5, 30, 2)
	return cv


func _terrace_wall():
	var cv = PC.new(48, 18)
	cv.rect(0, 3, 48, 4, Color("#cfc4ac"))
	cv.rect(0, 3, 48, 1, Color("#e0d6c0"))
	_dry_stone(cv, Rect2i(0, 7, 48, 9), Color("#ab9f86"), Color("#7f7360"), Color("#bdb198"))
	cv.speckle(Rect2i(0, 2, 48, 4), [Color("#7a8b3a")], 0.08, rng)
	cv.outline(INK)
	return cv


## Casa da Judeia (séc. I) com pátio murado. Janela em (+8, -28) dos pés.
func _house_courtyard():
	var cv = PC.new(64, 54)
	gen._stone_blocks(cv, 10, 14, 44, 22, Color("#c8b89a"), Color("#9c8c70"), Color("#dccdb0"))
	cv.rect(10, 4, 44, 10, Color("#d9c29a"))
	cv.rect(10, 4, 44, 1, Color("#e6d3ae"))
	cv.rect(10, 13, 44, 1, Color("#a8875e"))
	cv.rect(38, 22, 5, 4, Color("#3a2a22"))
	gen._stone_blocks(cv, 2, 38, 60, 14, Color("#b8ac90"), Color("#8e826a"), Color("#cdc1a4"))
	cv.rect(2, 36, 60, 2, Color("#d0c4a8"))
	cv.rect(27, 38, 10, 14, Color("#4a3a2e"))
	cv.outline(INK)
	cv.shadow(32, 52.5, 30, 2)
	return cv


## Casa de pedra encostada na rocha, com abertura baixa para os animais
## (composição compatível com mais de uma leitura; vista só de fora).
## Porta em (-16, -2) e abertura dos animais em (-48, -2) a partir dos pés.
func _house_on_rock():
	var cv = PC.new(128, 84)
	_rock_lumps(cv, [Vector4(98, 40, 30, 30), Vector4(112, 62, 16, 20), Vector4(70, 26, 30, 16), Vector4(16, 66, 15, 13)],
		Color("#8e7e66"), Color("#b8a88c"), Color("#d0c2a6"))
	cv.ellipse(15, 74, 6, 6, Color("#2a201a"))
	cv.rect(9, 74, 13, 5, Color("#2a201a"))
	cv.ellipse(15, 75, 4, 4, Color("#3a2e26"))
	gen._stone_blocks(cv, 28, 38, 60, 40, Color("#c8b89a"), Color("#9c8c70"), Color("#dccdb0"))
	cv.rect(28, 28, 60, 10, Color("#d9c29a"))
	cv.rect(28, 28, 60, 1, Color("#e6d3ae"))
	cv.rect(28, 37, 60, 1, Color("#a8875e"))
	for x in range(32, 86, 9):
		cv.rect(x, 38, 2, 2, Color("#5a3a22"))
	cv.rect(42, 54, 14, 3, Color("#795437"))
	cv.rect(44, 57, 10, 21, Color("#3a2a22"))
	cv.rect(70, 46, 5, 4, Color("#3a2a22"))
	gen._stone_blocks(cv, 24, 66, 16, 12, Color("#b8ac90"), Color("#8e826a"), Color("#cdc1a4"))
	for i in 5:
		cv.rect(88 + i * 2, 74 - i * 9, 6, 3, Color("#c8bca4"))
	cv.outline(INK)
	cv.shadow(64, 80.5, 60, 2.5)
	return cv


func _stone_stairs():
	var cv = PC.new(16, 22)
	for i in 5:
		var y := 18 - i * 4
		cv.rect(2, y, 12, 4, Color("#ab9f86"))
		cv.rect(2, y, 12, 1, Color("#e0d6c0"))
	cv.outline(INK)
	return cv


func _rock_shelter():
	var cv = PC.new(60, 44)
	_rock_lumps(cv, [Vector4(30, 14, 28, 12), Vector4(10, 26, 9, 14), Vector4(51, 25, 8, 15)],
		Color("#8e7e66"), Color("#b8a88c"), Color("#d0c2a6"))
	cv.rect(12, 22, 36, 18, Color("#3a2e26"))
	cv.ellipse(30, 22, 18, 4, Color("#4a3c30"))
	cv.rect(12, 38, 36, 3, Color("#8a7a62"))
	cv.outline(INK)
	cv.shadow(30, 42, 27, 2)
	return cv


func _cloak_bed():
	var cv = PC.new(26, 12)
	cv.ellipse(13, 7, 12, 4, Color("#c8b070"))
	cv.speckle(Rect2i(1, 3, 24, 8), [Color("#e8d49a")], 0.25, rng)
	cv.rect(5, 3, 16, 6, Color("#d8d0bc"))
	cv.rect(5, 3, 16, 1, Color("#ece6d6"))
	cv.rect(5, 7, 16, 1, Color("#795437"))
	cv.outline(INK)
	return cv


func _oil_lamp_niche():
	var cv = PC.new(16, 14)
	cv.ellipse(8, 9, 7, 3.5, Color("#7a6a56"))
	cv.ellipse(8, 8.5, 6.5, 3, Color("#9c8a72"))
	cv.ellipse(7, 6, 3, 1.6, Color("#b8734d"))
	cv.rect(9, 5, 3, 2, Color("#9c5c3c"))
	cv.px(8, 5, Color("#3a2a22"))
	cv.px(11, 4, Color("#ffd36b"))
	cv.px(11, 3, Color("#ffb347"))
	cv.outline(INK)
	cv.shadow(8, 12, 6, 1)
	return cv


func _cave_mouth():
	var cv = PC.new(52, 40)
	_rock_lumps(cv, [Vector4(26, 20, 24, 17), Vector4(8, 30, 7, 8), Vector4(44, 30, 7, 8)],
		Color("#8e7e66"), Color("#b8a88c"), Color("#d0c2a6"))
	cv.ellipse(26, 28, 12, 9, Color("#2a201a"))
	cv.rect(14, 28, 24, 9, Color("#2a201a"))
	cv.ellipse(26, 30, 8, 6, Color("#3a2e26"))
	cv.outline(INK)
	cv.shadow(26, 38, 24, 2)
	return cv


func _thorn_bush():
	var cv = PC.new(22, 16)
	for k in 9:
		var ang := PI + PI * (k + 0.5) / 9.0
		var ex := 11 + roundi(cos(ang) * 9)
		var ey := 13 + roundi(sin(ang) * 10)
		cv.line(11, 13, ex, ey, Color("#7a7058") if k % 2 == 0 else Color("#9a9070"))
		cv.px(ex, ey, Color("#b8ae8a"))
	cv.speckle(Rect2i(1, 2, 20, 12), [Color("#7a8b3a"), Color("#5e6e2a")], 0.12, rng)
	cv.outline(INK)
	cv.shadow(11, 14, 8, 1.3)
	return cv


# ---------------------------------------------------------------- personagens

func _characters() -> void:
	for id in LOOKS:
		var look: Dictionary = LOOKS[id]
		var sheet = PC.new(24 * 6, 32 * 4)
		for dir in 4:
			for frame in 6:
				sheet.blit(gen._character_frame(dir, frame, look), frame * 24, dir * 32)
		sheet.save(CHARS + "%s.png" % id)
	# Tamir dormindo: 6 quadros (respiração) x 2 linhas (direita, esquerda), 32x16.
	var tamir: Dictionary = LOOKS["bn_tamir"]
	var sleep = PC.new(32 * 6, 16 * 2)
	for frame in 6:
		var f = _sleeper_frame(frame, tamir)
		sleep.blit(f, frame * 32, 0)
		sleep.blit(f.flipped_x(), frame * 32, 16)
	sleep.save(CHARS + "bn_tamir_asleep.png")


func _sleeper_frame(frame: int, look: Dictionary):
	var cv = PC.new(32, 16)
	var breath := 0.5 if frame % 2 == 1 else 0.0
	var mantle := Color(String(look.mantle))
	cv.line(3, 14, 29, 13, Color(String(look.staff)))
	cv.ellipse(17, 10, 11, 3.5 + breath, mantle.darkened(0.15))
	cv.ellipse(16.5, 9.5, 10.5, 3 + breath, mantle)
	cv.rect(8, 9, 18, 1, Color(String(look.mantle_edge)))
	cv.ellipse(6, 9, 3.5, 3, Color(String(look.head_color)))
	cv.ellipse(6.5, 10, 2, 1.8, Color(String(look.skin)))
	cv.px(7, 11, Color(String(look.hair)))
	cv.rect(25, 11, 3, 2, Color("#5a3a22"))
	cv.outline(INK)
	cv.shadow(16, 14, 14, 1.5)
	return cv


# ---------------------------------------------------------------- animais

func _animals() -> void:
	for id in ANIMALS:
		var s: Dictionary = ANIMALS[id]
		_animal_sheet(id, int(s.w), int(s.h), func(frame: int): return _quad_frame(frame, s))
	_animal_sheet("egypt_goose", 18, 16, func(frame: int): return _goose_frame(frame))


func _animal_sheet(id: String, fw: int, fh: int, make: Callable) -> void:
	var sheet = PC.new(fw * 6, fh * 2)
	for frame in 6:
		var f = make.call(frame)
		sheet.blit(f, frame * fw, 0)
		sheet.blit(f.flipped_x(), frame * fw, fh)
	sheet.save(CHARS + "%s.png" % id)


## Quadrúpede genérico no estilo da ovelha: quadros 0-3 andando, 4 parado, 5 pastando.
func _quad_frame(frame: int, s: Dictionary):
	var cv = PC.new(int(s.w), int(s.h))
	var walking := frame < 4
	var bob := 1 if walking and frame % 2 == 1 else 0
	var grazing := frame == 5
	var feet := int(s.h) - 2
	var leg_len := int(s.leg_len)
	var leg_w := int(s.get("leg_w", 1))
	var leg := Color(String(s.leg))
	var legs: Array = s.legs
	for i in legs.size():
		var lift := 0
		if walking and ((frame == 1 and i % 2 == 0) or (frame == 3 and i % 2 == 1)):
			lift = 1
		cv.rect(int(legs[i]), feet - leg_len + 1 - lift, leg_w, leg_len, leg if i % 2 == 0 else leg.darkened(0.2))
	var b: Vector4 = s.body
	var main := Color(String(s.main))
	var shade := Color(String(s.shade))
	var light := Color(String(s.light))
	if s.has("tail"):
		var tl: Vector4 = s.tail
		cv.line(int(tl.x), int(tl.y) + bob, int(tl.z), int(tl.w) + bob, shade)
	cv.ellipse(b.x, b.y + bob, b.z, b.w, shade)
	cv.ellipse(b.x - 0.5, b.y - 0.5 + bob, b.z - 0.5, b.w - 0.5, main)
	cv.ellipse_on_solid(b.x - b.z * 0.3, b.y - b.w * 0.45 + bob, b.z * 0.5, b.w * 0.3, light)
	if s.has("spots"):
		for sp in s.spots:
			cv.ellipse_on_solid(sp.x, sp.y + bob, sp.z, sp.w, Color(String(s.spot)))
	if s.has("stripe"):
		cv.line(int(b.x - b.z * 0.7), int(b.y - b.w) + bob + 1, int(b.x + b.z * 0.6), int(b.y - b.w) + bob + 1, Color(String(s.stripe)))
	if s.has("blanket"):
		cv.rect(int(b.x) - 3, int(b.y - b.w) + bob, 7, int(b.w) + 1, Color(String(s.blanket)))
	if s.has("baskets"):
		var bk := Color(String(s.baskets))
		cv.ellipse(b.x - 1, b.y + 1 + bob, 3.5, 3, bk.darkened(0.2))
		cv.ellipse(b.x - 1.5, b.y + 0.5 + bob, 3, 2.5, bk)
		cv.px(int(b.x) - 2, int(b.y) - 1 + bob, Color("#e8c27a"))
	var hd: Vector4 = s.head
	var hy := hd.y + bob + (float(s.get("graze_drop", 3)) if grazing else 0.0)
	var nx := b.x + b.z * 0.6
	var ny := b.y - b.w * 0.4 + bob
	for d in 2:
		cv.line(int(nx), int(ny) + d, int(hd.x - 1), int(hy) + d, main)
	cv.ellipse(hd.x, hy, hd.z, hd.w, Color(String(s.get("head_color", s.main))))
	if s.has("muzzle"):
		cv.ellipse(hd.x + hd.z * 0.6, hy + 0.5, hd.z * 0.55, hd.w * 0.6, Color(String(s.muzzle)))
	if s.has("halter"):
		cv.line(int(hd.x - 1), int(hy - hd.w), int(hd.x), int(hy + hd.w), Color(String(s.halter)))
	cv.px(int(hd.x), int(hy) - 1, INK)
	var ear_top := int(hy - hd.w)
	match String(s.get("ears", "")):
		"up":
			cv.line(int(hd.x - 1), ear_top, int(hd.x - 1), ear_top - 2, shade)
			cv.line(int(hd.x + 1), ear_top, int(hd.x + 1), ear_top - 2, main)
		"long_up":
			cv.line(int(hd.x - 1), ear_top, int(hd.x - 2), ear_top - 4, shade)
			cv.line(int(hd.x), ear_top, int(hd.x), ear_top - 4, main)
		"droop":
			cv.line(int(hd.x - 1), int(hy) - 1, int(hd.x - 3), int(hy) + 2, shade)
		"big":
			cv.px(int(hd.x - 2), ear_top - 1, main)
			cv.px(int(hd.x - 2), ear_top - 2, main)
			cv.px(int(hd.x + 1), ear_top - 1, main)
			cv.px(int(hd.x + 1), ear_top - 2, main)
	var horn := Color(String(s.get("horn", "#e8dcc0")))
	match String(s.get("horns", "")):
		"lyre":
			for o in [0, 2]:
				cv.line(int(hd.x - 1) + o, ear_top, int(hd.x - 3) + o, ear_top - 3, horn)
				cv.line(int(hd.x - 3) + o, ear_top - 3, int(hd.x - 1) + o, ear_top - 6, horn)
		"back":
			cv.line(int(hd.x), ear_top, int(hd.x - 3), ear_top - 2, horn)
			cv.px(int(hd.x - 4), ear_top - 1, horn)
	if s.has("beard"):
		cv.rect(int(hd.x + 1), int(hy + hd.w), 1, 2, Color(String(s.beard)))
	cv.outline(INK)
	cv.shadow(b.x, feet + 0.5, b.z + 1.0, 1.5)
	return cv


## Ganso doméstico (cinza e castanho), pequeno. Sem galinhas.
func _goose_frame(frame: int):
	var cv = PC.new(18, 16)
	var walking := frame < 4
	var bob := 1 if walking and frame % 2 == 1 else 0
	var grazing := frame == 5
	var foot := Color("#d9853a")
	var step := 1 if walking and frame % 2 == 0 else 0
	cv.rect(7 + step, 12, 1, 3, foot)
	cv.rect(10 - step, 12, 1, 3, foot.darkened(0.15))
	cv.ellipse(8, 9 + bob, 5.5, 3.5, Color("#887a68"))
	cv.ellipse(8, 8.5 + bob, 5, 3, Color("#a89a88"))
	cv.ellipse_on_solid(8, 10.5 + bob, 4, 1.5, Color("#ece6da"))
	cv.line(3, 8 + bob, 5, 7 + bob, Color("#6e604e"))
	var hx := 14
	var hy := (10 if grazing else 3) + bob
	cv.line(12, 7 + bob, hx, hy + 1, Color("#c8bca8"))
	cv.line(12, 8 + bob, hx - 1, hy + 2, Color("#c8bca8"))
	cv.ellipse(hx, hy, 1.8, 1.5, Color("#c8bca8"))
	cv.px(hx + 2, hy, foot)
	cv.px(hx + 2, hy + 1, foot.darkened(0.1))
	cv.px(hx, hy - 1, INK)
	cv.outline(INK)
	cv.shadow(8, 14.5, 5, 1)
	return cv


# ---------------------------------------------------------------- ícones de item

func _item_icons() -> void:
	var cv = PC.new(12, 12)
	# Feixe de cevada
	for x in [3, 4, 5, 6, 7, 8]:
		cv.line(x, 4, x + (1 if x > 5 else -1), 11, Color("#c8a450"))
	cv.ellipse(6, 3, 3.5, 2.5, Color("#d9b860"))
	cv.px(5, 2, Color("#f0d68a"))
	cv.px(7, 3, Color("#f0d68a"))
	cv.rect(3, 7, 6, 1, Color("#8e6a36"))
	cv.outline(INK)
	cv.save(ITEMS + "barley_sheaf.png")
	# Feixe do canto do campo (atado com pano claro)
	cv = PC.new(12, 12)
	for x in [3, 4, 5, 6, 7, 8]:
		cv.line(x, 4, x + (1 if x > 5 else -1), 11, Color("#c8a450"))
	cv.ellipse(6, 3, 3.5, 2.5, Color("#e0c070"))
	cv.px(4, 2, Color("#f0d68a"))
	cv.rect(3, 7, 6, 1, Color("#e2d6ba"))
	cv.px(9, 7, Color("#e2d6ba"))
	cv.outline(INK)
	cv.save(ITEMS + "corner_sheaf.png")
	# Grão de cevada batido, numa trouxa de pano
	cv = PC.new(12, 12)
	cv.ellipse(6, 7, 5, 4, Color("#a89870"))
	cv.ellipse(5.5, 6.5, 4.5, 3.5, Color("#c8b890"))
	cv.ellipse(6, 4, 3, 1.5, Color("#d9b860"))
	cv.px(5, 3, Color("#f0d68a"))
	cv.px(7, 4, Color("#b08e3c"))
	cv.outline(INK)
	cv.save(ITEMS + "tova_grain.png")
	# Saco de cevada (linho)
	cv = PC.new(12, 12)
	cv.ellipse(6, 7, 4.5, 4.5, Color("#c8bea6"))
	cv.ellipse(5.5, 6.5, 4, 4, Color("#e8dfc8"))
	cv.rect(5, 1, 3, 2, Color("#c8bea6"))
	cv.rect(4, 3, 5, 1, Color("#795437"))
	cv.px(6, 5, Color("#d9b860"))
	cv.outline(INK)
	cv.save(ITEMS + "barley_sack.png")
	# Gravetos de mato (feixe amarrado)
	cv = PC.new(12, 12)
	for i in 4:
		cv.line(1 + i, 9 - i, 10, 3 + i, Color("#8e7a5a") if i % 2 == 0 else Color("#a89070"))
	cv.px(10, 3, Color("#b8ae8a"))
	cv.rect(5, 4, 1, 5, Color("#c2a878"))
	cv.outline(INK)
	cv.save(ITEMS + "brushwood.png")
