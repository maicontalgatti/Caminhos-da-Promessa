class_name Conditions
extends RefCounted
## Condições orientadas a dados, compartilhadas por diálogos, missões, saídas
## de mapa, NPCs e experiências. Nenhuma regra fica presa no código de um NPC.
##
## Formatos aceitos:
##   null / {}                          -> verdadeiro
##   [c1, c2]  ou {"all": [...]}        -> todas
##   {"any": [...]}                     -> ao menos uma
##   {"not": c}                         -> negação
## Chaves simples (num mesmo dicionário, todas precisam valer):
##   "flag": id  (+ "value": v para comparar)   "not_flag": id
##   "objective": "missão/objetivo" (objetivo atual)
##   "quest_completed": id   "quest_active": id   "quest_started": id
##   "discovery": id   "event": tipo + "id": id (evento já registrado)
##   "has_item": id (+ "count": n)   "lacks_item": id
##   "choice": id + "option": opção (sem "option": escolha ainda não feita)
##   "collectibles": conjunto + "count": n
##   "collectible": id   "region": região atual
## Validação estrutural: ConditionSchema.


static func check(cond: Variant) -> bool:
	if cond == null:
		return true
	if cond is Array:
		for c in cond:
			if not check(c):
				return false
		return true
	if not (cond is Dictionary):
		return false
	var c: Dictionary = cond
	if c.has("all") and not check(c.all if c.all is Array else [c.all]):
		return false
	if c.has("any"):
		var ok := false
		for sub in c.any:
			if check(sub):
				ok = true
				break
		if not ok:
			return false
	if c.has("not") and check(c.not):
		return false
	if c.has("flag"):
		var v: Variant = GameState.get_flag(String(c.flag), null)
		if c.has("value"):
			if v == null or typeof(v) != typeof(c.value) and not (_is_num(v) and _is_num(c.value)):
				return false
			if v != c.value:
				return false
		elif not v:
			return false
	if c.has("not_flag") and GameState.get_flag(String(c.not_flag)):
		return false
	if c.has("objective") and not QuestManager.is_objective_active(String(c.objective)):
		return false
	if c.has("quest_completed") and QuestManager.status(String(c.quest_completed)) != "completed":
		return false
	if c.has("quest_active") and QuestManager.status(String(c.quest_active)) != "active":
		return false
	if c.has("quest_started") and QuestManager.status(String(c.quest_started)) == "":
		return false
	if c.has("discovery") and not Discoveries.is_unlocked(String(c.discovery)):
		return false
	if c.has("event") and not QuestManager.has_event(String(c.event), String(c.get("id", ""))):
		return false
	if c.has("has_item") and Inventory.count(String(c.has_item)) < int(c.get("count", 1)):
		return false
	if c.has("lacks_item") and Inventory.count(String(c.lacks_item)) > 0:
		return false
	if c.has("choice") and GameState.get_flag(choice_flag(String(c.choice)), "") != String(c.get("option", "")):
		return false
	if c.has("collectibles") and Collectibles.found_in_set(String(c.collectibles)) < int(c.get("count", 1)):
		return false
	if c.has("collectible") and not Collectibles.is_found(String(c.collectible)):
		return false
	if c.has("region") and WorldManager.current_region_id() != String(c.region):
		return false
	return true


static func choice_flag(choice_id: String) -> String:
	return "choice:" + choice_id


static func _is_num(v: Variant) -> bool:
	return v is int or v is float

