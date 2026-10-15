extends Node
## Ofícios / minijogos (data/crafts). Sem autoload de tela: só dados e regras.
## A UI é CraftScreen; a ação de diálogo é {"craft": id}.

const CRAFTS_PATH := "res://data/crafts/crafts.json"

var recipes: Dictionary = {}
var errors := PackedStringArray()


func _ready() -> void:
	reload()


func reload() -> void:
	recipes.clear()
	errors.clear()
	var data: Variant = JsonUtil.read_file(CRAFTS_PATH, errors)
	if not (data is Dictionary):
		return
	for c in data.get("crafts", []):
		if not (c is Dictionary) or String(c.get("id", "")) == "":
			errors.append("ofício sem id")
			continue
		var id := String(c.id)
		if recipes.has(id):
			errors.append("ofício duplicado: %s" % id)
			continue
		recipes[id] = c
	for e in errors:
		push_error("Craft: " + e)


func has_craft(id: String) -> bool:
	return recipes.has(id)


func recipe(id: String) -> Dictionary:
	return recipes.get(id, {})


func day_key(craft_id: String) -> String:
	var day := int(floor(GameState.play_time / WorldClock.DAY_LENGTH))
	return "craft_done:%s:%d" % [craft_id, day]


func is_done_today(craft_id: String) -> bool:
	var r := recipe(craft_id)
	if r.is_empty():
		return true
	if not bool(r.get("once_per_day", false)):
		return false
	return GameState.get_flag(day_key(craft_id), false) == true


func can_start(craft_id: String) -> String:
	var r := recipe(craft_id)
	if r.is_empty():
		return "ofício inexistente"
	if is_done_today(craft_id):
		return String(r.get("busy_text", "Já feito hoje."))
	for it in r.get("cost", []):
		if Inventory.count(String(it.get("item", ""))) < int(it.get("qty", 1)):
			return "Falta %s." % Inventory.display_name(String(it.item))
	return ""


## Aplica custo, recompensa e marca o dia. Chamar só após o minijogo bem-sucedido.
func complete(craft_id: String) -> String:
	var err := can_start(craft_id)
	if err != "":
		return err
	var r := recipe(craft_id)
	for it in r.get("cost", []):
		Inventory.remove(String(it.item), int(it.get("qty", 1)), "craft")
	for it in r.get("give", []):
		var n := Inventory.add(String(it.item), int(it.get("qty", 1)), "craft", true)
		if n > 0:
			get_tree().call_group("hud", "show_toast", "Recebido: %d %s" % [n, Inventory.display_name(String(it.item))])
	for d in r.get("unlock", []):
		Discoveries.unlock(String(d))
	if bool(r.get("once_per_day", false)):
		GameState.set_flag(day_key(craft_id), true)
	QuestManager.record_event("craft_finished", craft_id)
	AudioManager.play("item_pickup")
	return ""
