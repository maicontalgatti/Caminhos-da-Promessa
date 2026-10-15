@tool
class_name DialogueDatabase
extends RefCounted
## Carrega e valida diálogos de data/dialogues/*.json.
##
## Formato de cada diálogo:
## {
##   "id": "adina_talk",
##   "start": "greet",
##   "start_if": [{"objective": "canaan_wells/meet_adina", "node": "water"}, {"flag": "met_adina", "node": "again"}],
##   "nodes": {
##     "greet": {"speaker": "adina", "text": "...", "next": "n2", "set_flags": ["met_adina"]},
##     "n2": {"speaker": "adina", "text": "...", "choices": [{"text": "...", "next": "end"}]},
##     "n3": {"speaker": "adina", "text": "...", "unlock": ["shepherding_water"], "event": "wells_adina_water"}
##   }
## }
## "next": "end" (ou ausente) encerra o diálogo. "action": {"presentation": id}
## (apresentação em quadros), {"scene": id} (cena dirigida de data/scenes) ou
## {"market": id} (feira do mercador, data/market) é executada quando o diálogo termina.

const END := "end"

var dialogues: Dictionary = {}
var errors := PackedStringArray()


func load_dir(dir_path: String) -> void:
	for d in JsonUtil.read_collection(dir_path, "dialogues", errors):
		if dialogues.has(d.id):
			errors.append("Diálogo duplicado: %s" % d.id)
			continue
		var problems := validate(d)
		if problems.is_empty():
			dialogues[d.id] = d
		else:
			errors.append_array(problems)


func has_dialogue(id: String) -> bool:
	return dialogues.has(id)


func get_dialogue(id: String) -> Dictionary:
	return dialogues.get(id, {})


## Efeitos com itens e escolhas (a existência dos itens é conferida nos testes).
static func validate_effects(e: Dictionary, owner: String) -> PackedStringArray:
	var out := PackedStringArray()
	for k in ["give", "take"]:
		if not e.has(k):
			continue
		if not (e[k] is Array):
			out.append("%s: \"%s\" deve ser uma lista de {item, qty}" % [owner, k])
			continue
		for it in e[k]:
			if not (it is Dictionary) or String(it.get("item", "")) == "" or int(it.get("qty", 1)) < 1:
				out.append("%s: \"%s\" com item inválido" % [owner, k])
	if e.has("decision"):
		var dec: Variant = e.decision
		if not (dec is Dictionary) or String(dec.get("id", "")) == "" or String(dec.get("option", "")) == "":
			out.append("%s: \"decision\" deve ser {id, option}" % owner)
	if e.has("flags") and not (e.flags is Dictionary):
		out.append("%s: \"flags\" deve ser {flag: valor}" % owner)
	return out


## Itens citados em efeitos e condições de um diálogo.
static func referenced_items(d: Dictionary) -> Array:
	var out: Array = []
	for n in d.get("nodes", {}).values():
		var entries: Array = [n]
		entries.append_array(n.get("choices", []))
		for e in entries:
			for k in ["give", "take"]:
				for it in e.get(k, []):
					out.append(String(it.get("item", "")))
			if e.has("if"):
				out.append_array(ConditionSchema.referenced(e.get("if"), ["has_item", "lacks_item"]))
	return out


static func valid_action(a: Variant) -> bool:
	return a is Dictionary and a.size() == 1 and (a.get("presentation") is String or a.get("scene") is String
		or a.get("market") is String)


## Ids de mercadores pedidos por ações de nós ({"market": id}).
static func referenced_merchants(d: Dictionary) -> Array:
	var out: Array = []
	for n in d.get("nodes", {}).values():
		if not (n is Dictionary):
			continue
		for e in [n] + Array(n.get("choices", [])):
			if e is Dictionary and e.get("action") is Dictionary and e.action.get("market") is String:
				out.append(String(e.action.market))
	return out


## Ids de cenas dirigidas pedidas por ações de nós ({"scene": id}).
static func referenced_scenes(d: Dictionary) -> Array:
	var out: Array = []
	for n in d.get("nodes", {}).values():
		if not (n is Dictionary):
			continue
		for e in [n] + Array(n.get("choices", [])):
			if e is Dictionary and e.get("action") is Dictionary and e.action.get("scene") is String:
				out.append(String(e.action.scene))
	return out


static func validate(d: Dictionary) -> PackedStringArray:
	var out := PackedStringArray()
	var id := String(d.get("id", "?"))
	var nodes: Variant = d.get("nodes")
	if not (nodes is Dictionary) or nodes.is_empty():
		out.append("%s: sem \"nodes\"" % id)
		return out
	var start := String(d.get("start", ""))
	if not nodes.has(start):
		out.append("%s: nó inicial \"%s\" não existe" % [id, start])
	for cond in d.get("start_if", []):
		if not (cond is Dictionary) or not nodes.has(String(cond.get("node", ""))):
			out.append("%s: start_if aponta para nó inexistente" % id)
		elif cond.has("if"):
			out.append_array(ConditionSchema.validate(cond.get("if"), id + " (start_if)"))
	for node_id in nodes:
		var n: Variant = nodes[node_id]
		if not (n is Dictionary) or not (n.get("text") is String) or String(n.text).strip_edges() == "":
			out.append("%s/%s: nó sem texto" % [id, node_id])
			continue
		var next := String(n.get("next", END))
		if next != END and not nodes.has(next):
			out.append("%s/%s: next \"%s\" não existe" % [id, node_id, next])
		if n.has("unlock") and not (n.unlock is Array):
			out.append("%s/%s: \"unlock\" deve ser uma lista de descobertas" % [id, node_id])
		if n.has("event") and not (n.event is String):
			out.append("%s/%s: \"event\" deve ser texto" % [id, node_id])
		if n.has("scripture") and not (n.scripture is String):
			out.append("%s/%s: \"scripture\" deve ser uma referência (ex.: \"Gen 26:20\")" % [id, node_id])
		if n.has("action") and not valid_action(n.action):
			out.append("%s/%s: \"action\" deve ser {\"presentation\": id}, {\"scene\": id} ou {\"market\": id}" % [id, node_id])
		out.append_array(validate_effects(n, "%s/%s" % [id, node_id]))
		for ch in n.get("choices", []):
			if not (ch is Dictionary) or not (ch.get("text") is String):
				out.append("%s/%s: escolha inválida" % [id, node_id])
				continue
			out.append_array(validate_effects(ch, "%s/%s (escolha)" % [id, node_id]))
			if ch.has("action") and not valid_action(ch.action):
				out.append("%s/%s (escolha): \"action\" deve ser {\"presentation\": id}, {\"scene\": id} ou {\"market\": id}" % [id, node_id])
			if ch.has("if"):
				out.append_array(ConditionSchema.validate(ch.get("if"), "%s/%s (escolha)" % [id, node_id]))
			var ch_next := String(ch.get("next", END))
			if ch_next != END and not nodes.has(ch_next):
				out.append("%s/%s: escolha aponta para \"%s\" inexistente" % [id, node_id, ch_next])
	return out
