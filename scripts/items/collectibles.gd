extends Node
## Colecionáveis ("Minhas descobertas"): registros culturais, geográficos, de
## conhecimento bíblico, objetos contextualizados e segredos de mapa.
## Definidos em data/collectibles (chaves "collectibles" e "sets"); os
## encontrados ficam em GameState.collectibles. Nem todo colecionável é um
## artefato autêntico: a classificação de cada um diz o que é.

signal collectible_found(id: String)

const DIR := "res://data/collectibles"
const CATEGORIES := ["cultural", "geographic", "biblical", "object", "secret"]
const CATEGORY_LABELS := {
	"cultural": "Registro cultural",
	"geographic": "Registro geográfico",
	"biblical": "Conhecimento bíblico",
	"object": "Objeto contextualizado",
	"secret": "Segredo do mapa",
}

var entries: Dictionary = {}
var order: Array[String] = []
var sets: Dictionary = {}
var errors := PackedStringArray()


func _ready() -> void:
	reload()


func reload() -> void:
	entries.clear()
	order.clear()
	sets.clear()
	errors.clear()
	for c in JsonUtil.read_collection(DIR, "collectibles", errors):
		var problems := validate_entry(c)
		if not problems.is_empty():
			errors.append_array(problems)
			continue
		entries[c.id] = c
		order.append(String(c.id))
	for s in JsonUtil.read_collection(DIR, "sets", errors):
		sets[s.id] = s
	for e in errors:
		push_error("Collectibles: " + e)


static func validate_entry(c: Dictionary) -> PackedStringArray:
	var out := PackedStringArray()
	var id := "colecionável " + String(c.get("id", "?"))
	for f in ["id", "title", "category", "region", "summary", "classification"]:
		if String(c.get(f, "")).strip_edges() == "":
			out.append("%s: campo obrigatório ausente \"%s\"" % [id, f])
	if not (c.get("category") in CATEGORIES):
		out.append("%s: categoria inválida" % id)
	if not (c.get("classification") in ContentPolicy.CLASSIFICATIONS):
		out.append("%s: classificação inválida" % id)
	return out


func entry(id: String) -> Dictionary:
	return entries.get(id, {})


func is_found(id: String) -> bool:
	return GameState.collectibles.has(id)


## Registra o colecionável uma única vez. Retorna true só na primeira vez.
func find(id: String) -> bool:
	if not entries.has(id) or is_found(id):
		return false
	GameState.collectibles[id] = GameState.play_time
	GameState.add_log("collectible", id)
	collectible_found.emit(id)
	QuestManager.record_event("collectible_found", id)
	var set_id := String(entry(id).get("set", ""))
	if set_id != "" and found_in_set(set_id) >= set_total(set_id):
		QuestManager.record_event("collection_completed", set_id)
	return true


func in_set(set_id: String) -> Array:
	return order.filter(func(i): return String(entries[i].get("set", "")) == set_id)


func found_in_set(set_id: String) -> int:
	return in_set(set_id).filter(func(i): return is_found(i)).size()


func set_total(set_id: String) -> int:
	return in_set(set_id).size()


func in_region(region_id: String) -> Array:
	return order.filter(func(i): return String(entries[i].get("region", "")) == region_id)


func found_in_region(region_id: String) -> int:
	return in_region(region_id).filter(func(i): return is_found(i)).size()
