extends Node
## Bolsa do viajante. Itens definidos em data/items (chave "items"); as
## quantidades ficam em GameState.inventory e são salvas com a partida.
##
## Capacidade simples: BAG_SLOTS espaços para itens comuns (cada pilha ocupa
## um espaço). Itens de missão (essential) ficam num compartimento à parte,
## sem limite, e não podem ser descartados pelo jogador.
## Eventos de missão: item_collected (coleta no mapa), item_received (dado
## por alguém), item_delivered (entregue a alguém).

signal changed(item_id: String, delta: int)
## Mesmo momento de `changed`, com a origem (pickup, dialogue, reward, deliver,
## discard ou ""): usado pelo AudioManager para escolher o som.
signal moved(item_id: String, delta: int, source: String)

const ITEMS_DIR := "res://data/items"
const BAG_SLOTS := 12
const CATEGORIES := ["material", "common", "supply", "trade", "quest", "collectible"]
const CATEGORY_LABELS := {
	"material": "Materiais",
	"common": "Objetos comuns",
	"supply": "Suprimentos",
	"trade": "Mercadorias",
	"quest": "Itens de missão",
	"collectible": "Colecionáveis",
}
const SOURCE_EVENTS := {"pickup": "item_collected", "reward": "item_received", "dialogue": "item_received",
	"deliver": "item_delivered"}

var items: Dictionary = {}
var order: Array[String] = []
var errors := PackedStringArray()


func _ready() -> void:
	reload()


func reload() -> void:
	items.clear()
	order.clear()
	errors.clear()
	for it in JsonUtil.read_collection(ITEMS_DIR, "items", errors):
		var problems := validate_item(it)
		if not problems.is_empty():
			errors.append_array(problems)
			continue
		items[it.id] = it
		order.append(String(it.id))
	for e in errors:
		push_error("Inventory: " + e)


static func validate_item(it: Dictionary) -> PackedStringArray:
	var out := PackedStringArray()
	var id := "item " + String(it.get("id", "?"))
	for f in ["id", "name", "category", "description", "classification"]:
		if String(it.get(f, "")).strip_edges() == "":
			out.append("%s: campo obrigatório ausente \"%s\"" % [id, f])
	if not (it.get("category") in CATEGORIES):
		out.append("%s: categoria inválida (use %s)" % [id, CATEGORIES])
	if not (it.get("classification") in ContentPolicy.CLASSIFICATIONS):
		out.append("%s: classificação inválida" % id)
	if int(it.get("max_stack", 1)) < 1:
		out.append("%s: max_stack deve ser >= 1" % id)
	var icon := String(it.get("icon", ""))
	if icon != "" and not ResourceLoader.exists(icon):
		out.append("%s: ícone inexistente %s" % [id, icon])
	return out


# --- Consulta ----------------------------------------------------------------

func item(id: String) -> Dictionary:
	return items.get(id, {})


func exists(id: String) -> bool:
	return items.has(id)


func display_name(id: String) -> String:
	return String(item(id).get("name", id))


func icon(id: String) -> Texture2D:
	var path := String(item(id).get("icon", ""))
	return load(path) if path != "" and ResourceLoader.exists(path) else null


func count(id: String) -> int:
	return int(GameState.inventory.get(id, 0))


func is_essential(id: String) -> bool:
	var it := item(id)
	return bool(it.get("essential", it.get("category") == "quest"))


func max_stack(id: String) -> int:
	return maxi(int(item(id).get("max_stack", 1)), 1)


func _slots_for(id: String, qty: int) -> int:
	return 0 if qty <= 0 else ceili(float(qty) / max_stack(id))


func slots_used() -> int:
	var n := 0
	for id in GameState.inventory:
		if not is_essential(id):
			n += _slots_for(id, int(GameState.inventory[id]))
	return n


## Quantas unidades cabem agora (itens de missão sempre cabem).
func room_for(id: String, qty: int) -> int:
	if not exists(id) or qty <= 0:
		return 0
	if is_essential(id):
		return qty
	var have := count(id)
	var free_slots := BAG_SLOTS - slots_used() + _slots_for(id, have)
	return clampi(free_slots * max_stack(id) - have, 0, qty)


## Entradas para a interface: [{id, qty}] separadas por compartimento.
func bag_entries() -> Array:
	return _entries(false)


func essential_entries() -> Array:
	return _entries(true)


func _entries(essential: bool) -> Array:
	var out: Array = []
	for id in order:
		if count(id) > 0 and is_essential(id) == essential:
			var left := count(id)
			if essential:
				out.append({"id": id, "qty": left})
				continue
			while left > 0:
				var q := mini(left, max_stack(id))
				out.append({"id": id, "qty": q})
				left -= q
	return out


# --- Alteração ---------------------------------------------------------------

## Adiciona até `qty` unidades; retorna quantas entraram (0 se a bolsa estiver cheia).
## force: recompensas entram mesmo acima da capacidade (nunca se perdem).
func add(id: String, qty: int = 1, source: String = "reward", force := false) -> int:
	if not exists(id):
		push_warning("Inventory: item inexistente \"%s\"" % id)
		return 0
	var n := qty if force else room_for(id, qty)
	if n <= 0:
		return 0
	GameState.inventory[id] = count(id) + n
	GameState.add_log("item", id)
	changed.emit(id, n)
	moved.emit(id, n, source)
	var ev := String(SOURCE_EVENTS.get(source, "item_received"))
	QuestManager.record_event(ev, id)
	QuestManager.evaluate()
	return n


## Remove `qty` unidades se houver o suficiente. source "deliver" registra a entrega.
func remove(id: String, qty: int = 1, source: String = "") -> bool:
	if qty <= 0 or count(id) < qty:
		return false
	var left := count(id) - qty
	if left > 0:
		GameState.inventory[id] = left
	else:
		GameState.inventory.erase(id)
	changed.emit(id, -qty)
	moved.emit(id, -qty, source)
	if SOURCE_EVENTS.has(source):
		QuestManager.record_event(String(SOURCE_EVENTS[source]), id)
	QuestManager.evaluate()
	return true


## Descarte pelo jogador: itens de missão e colecionáveis nunca são destruídos.
func can_discard(id: String) -> bool:
	return exists(id) and not is_essential(id) and item(id).get("category") != "collectible" and not item(id).get("no_discard", false)


func discard(id: String, qty: int = 1) -> bool:
	if not can_discard(id):
		return false
	return remove(id, qty, "discard")
