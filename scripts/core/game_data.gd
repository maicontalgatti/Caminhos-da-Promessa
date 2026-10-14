extends Node
## Dados estáticos carregados de data/: personagens e regiões.
## Novos personagens/regiões são adicionados apenas por JSON.

const CHARACTERS_DIR := "res://data/characters"
const REGIONS_DIR := "res://data/regions"
const STORY_DIR := "res://data/story"
const PORTRAIT_HEIGHT := 22

var characters: Dictionary = {}
var regions: Dictionary = {}
var prologues: Dictionary = {}
var errors := PackedStringArray()
var _portraits: Dictionary = {}


func _ready() -> void:
	reload()


func reload() -> void:
	characters.clear()
	regions.clear()
	prologues.clear()
	errors.clear()
	_portraits.clear()
	for c in JsonUtil.read_collection(CHARACTERS_DIR, "characters", errors):
		characters[c.id] = c
	for r in JsonUtil.read_collection(REGIONS_DIR, "regions", errors):
		regions[r.id] = r
	for p in JsonUtil.read_collection(STORY_DIR, "prologues", errors):
		prologues[p.id] = p
	for e in errors:
		push_error("GameData: " + e)


func get_character(id: String) -> Dictionary:
	return characters.get(id, {})


func get_character_name(id: String) -> String:
	match id:
		"", "narrator":
			return ""
		"player":
			return "Você"
	var c := get_character(id)
	return String(c.get("display_name", id))


## Retrato recortado da folha de sprites (quadro parado, olhando para baixo).
func get_portrait(id: String) -> Texture2D:
	if _portraits.has(id):
		return _portraits[id]
	var c := get_character(id)
	var sprite: Dictionary = c.get("sprite", {})
	var portrait: Texture2D = null
	var sheet_path := String(sprite.get("sheet", ""))
	if sprite.get("portrait", true) and sheet_path != "" and ResourceLoader.exists(sheet_path):
		var sheet: Texture2D = load(sheet_path)
		var fw := sheet.get_width() / int(sprite.get("hframes", 6))
		var atlas := AtlasTexture.new()
		atlas.atlas = sheet
		atlas.region = Rect2(fw * int(sprite.get("idle_start", 4)), 0, fw, PORTRAIT_HEIGHT)
		portrait = atlas
	_portraits[id] = portrait
	return portrait


func get_region(id: String) -> Dictionary:
	return regions.get(id, {})
