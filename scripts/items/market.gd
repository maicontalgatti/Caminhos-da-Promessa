extends Node
## Feira do viajante (ADR-030): o jogador troca mercadorias e outros itens comuns
## por prata pesada (medida abstrata, sem moedas cunhadas) e compra peças de
## roupa, panos de cabeça, cajados e animais de transporte com os mercadores
## fictícios de data/market/market.json. A feira abre pela ação de diálogo
## {"market": id_do_mercador}.
##
## Saldo, posse e equipamento ficam em flags escalares do GameState
## ("market:silver", "market:owned:<id>", "market:equipped:<slot>"), por isso
## o save v3 continua compatível sem migração.

signal changed

const PATH := "res://data/market/market.json"
const MAX_SILVER := 999999
## Ordem também é a de desenho das camadas sobre o jogador.
const SLOTS := ["clothing", "staff", "head", "transport"]
const SLOT_LABELS := {"clothing": "Roupa", "head": "Cabeça", "staff": "Cajado", "transport": "Locomoção"}

var merchants: Dictionary = {}
var sales: Dictionary = {}
var goods: Dictionary = {}
var order: Array[String] = []
## Tempo de jogo (s) até uma mercadoria coletada voltar ao chão.
var renew_seconds := 300.0
var errors := PackedStringArray()


func _ready() -> void:
	reload()


func reload() -> void:
	merchants.clear()
	sales.clear()
	goods.clear()
	order.clear()
	errors.clear()
	var d: Variant = JsonUtil.read_file(PATH)
	if not (d is Dictionary):
		errors.append("Feira: catálogo inválido")
		return
	renew_seconds = float(d.get("renew_seconds", 300))
	if renew_seconds < 0.0:
		errors.append("Feira: renew_seconds negativo")
		renew_seconds = 300.0
	for m in d.get("merchants", []):
		if not (m is Dictionary) or String(m.get("id", "")) == "" or String(m.get("name", "")) == "":
			errors.append("Feira: mercador inválido %s" % [m])
			continue
		if merchants.has(String(m.id)):
			errors.append("Feira: mercador duplicado %s" % m.id)
			continue
		merchants[String(m.id)] = m
	for sale in d.get("sales", []):
		if not (sale is Dictionary) or not Inventory.exists(String(sale.get("item", ""))) or int(sale.get("value", 0)) <= 0:
			errors.append("Feira: venda inválida %s" % [sale])
			continue
		var id := String(sale.item)
		if sales.has(id) or not Inventory.can_discard(id):
			errors.append("Feira: item protegido ou duplicado %s" % id)
			continue
		sales[id] = int(sale.value)
	for good in d.get("goods", []):
		var problems := _validate_good(good)
		if not problems.is_empty():
			errors.append_array(problems)
			continue
		goods[String(good.id)] = good
		order.append(String(good.id))
	for e in errors:
		push_error(e)


func _validate_good(good: Variant) -> PackedStringArray:
	var out := PackedStringArray()
	if not (good is Dictionary):
		return PackedStringArray(["Feira: produto inválido %s" % [good]])
	var id := String(good.get("id", ""))
	if id == "" or String(good.get("name", "")) == "" or not (good.get("slot") in SLOTS) or int(good.get("price", 0)) <= 0:
		out.append("Feira: produto inválido %s" % [good])
		return out
	if goods.has(id):
		out.append("Feira: produto duplicado %s" % id)
	var layer := String(good.get("layer", ""))
	if layer != "" and not ResourceLoader.exists(layer):
		out.append("Feira: camada inexistente %s (%s)" % [layer, id])
	var comp: Variant = good.get("companion")
	if comp != null and not (comp is Dictionary and ResourceLoader.exists(String(comp.get("sheet", "")))):
		out.append("Feira: companheiro inválido em %s" % id)
	if float(good.get("speed", 1.0)) < 1.0 or float(good.get("speed", 1.0)) > 1.5:
		out.append("Feira: velocidade fora de 1.0-1.5 em %s" % id)
	for m in good.get("sold_by", []):
		if not merchants.has(String(m)):
			out.append("Feira: mercador inexistente %s em %s" % [m, id])
	return out


# --- Consulta ----------------------------------------------------------------

func merchant(id: String) -> Dictionary:
	return merchants.get(id, {})


func silver() -> int:
	return clampi(int(GameState.get_flag("market:silver", 0)), 0, MAX_SILVER)


func owned(id: String) -> bool:
	return goods.has(id) and GameState.get_flag("market:owned:" + id, false) == true


func equipped(slot: String) -> String:
	if not slot in SLOTS:
		return ""
	var id := String(GameState.get_flag("market:equipped:" + slot, ""))
	return id if owned(id) else ""


## O mercador vende esta peça? (sold_by vazio = todos; merchant "" = qualquer um)
func sells(merchant_id: String, id: String) -> bool:
	if not goods.has(id):
		return false
	var by: Array = goods[id].get("sold_by", [])
	return merchant_id == "" or by.is_empty() or merchant_id in by


## Peças à venda com um mercador, mais as que o jogador já tem (para equipar).
func goods_for(merchant_id: String) -> Array[String]:
	var out: Array[String] = []
	for id in order:
		if sells(merchant_id, id) or owned(id):
			out.append(id)
	return out


## Itens da bolsa que a feira compra: [{id, qty, value}].
func sellable_entries() -> Array:
	var out: Array = []
	for id in Inventory.order:
		if sales.has(id) and Inventory.count(id) > 0 and Inventory.can_discard(id):
			out.append({"id": id, "qty": Inventory.count(id), "value": int(sales[id])})
	return out


func speed_multiplier() -> float:
	var id := equipped("transport")
	return float(goods[id].get("speed", 1.0)) if id != "" else 1.0


## Camadas a desenhar sobre o jogador, na ordem de SLOTS.
func layer_paths() -> Array[String]:
	var out: Array[String] = []
	for slot in SLOTS:
		var id := equipped(slot)
		if id != "" and String(goods[id].get("layer", "")) != "":
			out.append(String(goods[id].layer))
	return out


## Animal que segue o jogador ({} sem transporte equipado).
func companion() -> Dictionary:
	var id := equipped("transport")
	var c: Variant = goods[id].get("companion") if id != "" else null
	return c if c is Dictionary else {}


# --- Alteração ---------------------------------------------------------------

func _add_silver(n: int) -> void:
	GameState.set_flag("market:silver", clampi(silver() + n, 0, MAX_SILVER))


## Gasta prata (ajuda a personagens, etc.). Retorna false se faltar.
func spend(n: int) -> bool:
	if n <= 0 or silver() < n:
		return false
	_add_silver(-n)
	GameState.add_log("spend_silver", str(n))
	changed.emit()
	return true


func sell(id: String) -> bool:
	if not sales.has(id) or not Inventory.can_discard(id) or Inventory.count(id) < 1 or silver() > MAX_SILVER - int(sales[id]):
		return false
	if not Inventory.remove(id, 1, "market"):
		return false
	_add_silver(int(sales[id]))
	GameState.add_log("market_sell", id)
	changed.emit()
	return true


## Vende todas as unidades; retorna a prata recebida.
func sell_all(id: String) -> int:
	var got := 0
	while Inventory.count(id) > 0 and sell(id):
		got += int(sales[id])
	return got


func buy(id: String, merchant_id: String = "") -> bool:
	if not goods.has(id) or owned(id) or not sells(merchant_id, id) or silver() < int(goods[id].price):
		return false
	_add_silver(-int(goods[id].price))
	GameState.set_flag("market:owned:" + id, true)
	GameState.add_log("market_buy", id)
	equip(id)
	changed.emit()
	return true


func equip(id: String) -> bool:
	if not owned(id):
		return false
	GameState.set_flag("market:equipped:" + String(goods[id].slot), id)
	changed.emit()
	return true


func unequip(slot: String) -> bool:
	if not slot in SLOTS or equipped(slot) == "":
		return false
	GameState.set_flag("market:equipped:" + slot, "")
	changed.emit()
	return true
