@tool
class_name ConditionSchema
extends RefCounted
## Validação estrutural das condições (ver Conditions). Sem dependência de
## autoloads, para rodar também nas ferramentas de linha de comando e no editor.

const KEYS := ["flag", "value", "not_flag", "objective", "quest_completed", "quest_active", "quest_started",
	"discovery", "event", "id", "has_item", "count", "lacks_item", "choice", "option",
	"collectibles", "collectible", "region", "all", "any", "not",
	# chaves de quem usa a condição (não são avaliadas)
	"node", "text", "next", "set_flags", "locked_text"]


static func validate(cond: Variant, owner: String) -> PackedStringArray:
	var out := PackedStringArray()
	if cond == null:
		return out
	if cond is Array:
		for c in cond:
			out.append_array(validate(c, owner))
		return out
	if not (cond is Dictionary):
		out.append("%s: condição deve ser um objeto ou lista" % owner)
		return out
	for k in cond:
		if not (k in KEYS):
			out.append("%s: chave de condição desconhecida \"%s\"" % [owner, k])
	if cond.has("all"):
		out.append_array(validate(cond.all, owner))
	if cond.has("any"):
		if not (cond.any is Array):
			out.append("%s: \"any\" deve ser uma lista" % owner)
		else:
			out.append_array(validate(cond.any, owner))
	if cond.has("not"):
		out.append_array(validate(cond.not, owner))
	if cond.has("choice") and not (cond.choice is String and String(cond.choice) != ""):
		out.append("%s: condição \"choice\" exige o id da escolha" % owner)
	return out


## Valores citados por uma chave (ex.: "has_item"), percorrendo all/any/not.
static func referenced(cond: Variant, keys: Array) -> Array:
	var out: Array = []
	if cond is Array:
		for c in cond:
			out.append_array(referenced(c, keys))
	elif cond is Dictionary:
		for k in keys:
			if cond.has(k):
				out.append(String(cond[k]))
		for k in ["all", "any"]:
			if cond.has(k):
				out.append_array(referenced(cond[k], keys))
		if cond.has("not"):
			out.append_array(referenced(cond.not, keys))
	return out
