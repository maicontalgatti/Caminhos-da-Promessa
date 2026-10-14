@tool
class_name QuestDatabase
extends RefCounted
## Missões definidas em data/quests/**/*.json (chave "quests").
## Nenhuma missão exige GDScript próprio: objetivos avançam por eventos
## registrados pelo QuestManager. Formato em docs/quests.md.

const QUEST_DIR := "res://data/quests"
const EVENT_TYPES := ["dialogue_finished", "custom", "presentation_finished", "discovery",
	"interact", "region_entered", "prologue_finished", "quest_completed", "flag",
	"item_collected", "item_received", "item_delivered", "choice_made", "experience_started",
	"location_reached", "collectible_found", "collection_completed", "region_unlocked", "scene_finished",
	# gatilhos de estado (reavaliados sempre): quantidade na bolsa, progresso de coleção, condição composta
	"inventory", "collection", "condition"]
const STATE_EVENTS := ["inventory", "collection", "condition", "flag"]
## alvo "region" aponta para outra região; os demais podem trazer "region" quando estão fora do mapa da missão.
## "ui" é uma tela do jogo (ex.: scripture_map), sem posição no mapa; "scene" é uma
## cena dirigida de data/scenes (também sem posição: aponte junto o que a dispara).
const TARGET_TYPES := ["npc", "dialogue", "region", "area", "pickup", "examinable", "exit", "ui", "scene"]
const UI_TARGETS := ["scripture_map", "inventory", "journal"]
const QUEST_TYPES := ["context_exploration", "story_witness", "assist", "investigation", "journey"]
const CATEGORIES := ["main", "side", "exploration"]
const CATEGORY_LABELS := {"main": "História principal", "side": "Secundária", "exploration": "Exploração"}
## Tipos de objetivo reutilizáveis (campo opcional "type" do objetivo) e os
## eventos que podem concluí-los. Lista vazia = ainda não suportado.
const OBJECTIVE_TYPES := {
	"talk_to_npc": ["custom", "dialogue_finished"],
	"inspect_object": ["interact", "dialogue_finished", "custom"],
	"visit_region": ["region_entered"],
	"reach_location": ["location_reached"],
	"collect_item": ["inventory", "item_collected", "condition"],
	"deliver_item": ["item_delivered", "custom"],
	"give_item": ["item_delivered", "custom"],
	"receive_item": ["item_received"],
	"make_choice": ["choice_made"],
	"escort_npc": [],
	"wait_for_event": ["custom", "quest_completed", "flag", "condition", "experience_started"],
	"discover_information": ["discovery", "collectible_found", "collection", "collection_completed"],
	"complete_dialogue": ["dialogue_finished"],
	"interact_with_object": ["interact", "custom"],
	"unlock_region": ["region_unlocked"],
	"read_scripture": ["presentation_finished"],
	"observe_scene": ["scene_finished", "presentation_finished"],
}
const REQUIRED_FIELDS := ["id", "title", "description", "type", "classification", "region", "place_id",
	"era_id", "references", "intro", "start", "prerequisites", "objectives", "discoveries", "completion", "verification"]
const HINT_LEVELS := 3

var quests: Dictionary = {}
var order: Array[String] = []
var errors := PackedStringArray()


func load_dir(dir_path: String = QUEST_DIR) -> void:
	quests.clear()
	order.clear()
	errors.clear()
	for q in JsonUtil.read_collection(dir_path, "quests", errors, true):
		if quests.has(q.id):
			errors.append("Missão duplicada: %s" % q.id)
			continue
		var problems := validate(q)
		if problems.is_empty():
			quests[q.id] = q
			order.append(q.id)
		else:
			errors.append_array(problems)


func get_quest(id: String) -> Dictionary:
	return quests.get(id, {})


func objective_index(quest_id: String, objective_id: String) -> int:
	var objs: Array = get_quest(quest_id).get("objectives", [])
	for i in objs.size():
		if String(objs[i].get("id", "")) == objective_id:
			return i
	return -1


## Validação estrutural (sem depender de outros bancos de dados).
static func validate(q: Dictionary) -> PackedStringArray:
	var out := PackedStringArray()
	var id := "missão " + String(q.get("id", "?"))
	for f in REQUIRED_FIELDS:
		if not q.has(f):
			out.append("%s: campo obrigatório ausente \"%s\"" % [id, f])
	if not out.is_empty():
		return out
	if not (q.type in QUEST_TYPES):
		out.append("%s: tipo inválido \"%s\" (use %s)" % [id, q.type, QUEST_TYPES])
	if not (q.classification in ContentPolicy.CLASSIFICATIONS):
		out.append("%s: classificação inválida" % id)
	if not (String(q.get("category", "main")) in CATEGORIES):
		out.append("%s: categoria inválida \"%s\" (use %s)" % [id, q.get("category"), CATEGORIES])
	out.append_array(_validate_trigger(id + " (início)", q.start))
	var rewards: Variant = q.get("rewards", {})
	if not (rewards is Dictionary):
		out.append("%s: \"rewards\" deve ser um objeto" % id)
	else:
		for r in rewards.get("items", []):
			if not (r is Dictionary) or String(r.get("item", "")) == "" or int(r.get("qty", 1)) < 1:
				out.append("%s: recompensa de item inválida" % id)
	var objs: Variant = q.objectives
	if not (objs is Array) or objs.is_empty():
		out.append("%s: sem objetivos" % id)
		return out
	var seen := {}
	for o in objs:
		var oid := "%s/%s" % [id, o.get("id", "?")]
		if not (o.get("id") is String) or seen.has(o.id):
			out.append("%s: objetivo sem id ou duplicado" % oid)
			continue
		seen[o.id] = true
		if String(o.get("text", "")).strip_edges() == "":
			out.append("%s: objetivo sem texto" % oid)
		out.append_array(_validate_trigger(oid, o.get("complete_on")))
		if o.has("type"):
			var allowed: Variant = OBJECTIVE_TYPES.get(String(o.type))
			if allowed == null:
				out.append("%s: tipo de objetivo desconhecido \"%s\"" % [oid, o.type])
			elif allowed.is_empty():
				out.append("%s: tipo de objetivo \"%s\" ainda não é suportado pelo motor" % [oid, o.type])
			elif o.get("complete_on") is Dictionary and not (o.complete_on.get("event") in allowed):
				out.append("%s: \"%s\" não se conclui com o evento \"%s\" (use %s)" % [oid, o.type, o.complete_on.get("event"), allowed])
		var hints: Variant = o.get("hints")
		if not (hints is Array) or hints.size() != HINT_LEVELS:
			out.append("%s: são necessárias %d dicas (indireta, contextual, objetiva)" % [oid, HINT_LEVELS])
		else:
			for h in hints:
				if not (h is String) or h.strip_edges() == "":
					out.append("%s: dica vazia" % oid)
		var targets: Variant = o.get("targets")
		if not (targets is Array) or targets.is_empty():
			out.append("%s: objetivo sem alvos (as dicas precisam apontar para algo que existe)" % oid)
		else:
			for t in targets:
				if not (t is Dictionary) or not (t.get("type") in TARGET_TYPES) or String(t.get("id", "")) == "":
					out.append("%s: alvo inválido" % oid)
				elif t.type == "ui" and not (t.id in UI_TARGETS):
					out.append("%s: tela inexistente \"%s\" (use %s)" % [oid, t.id, UI_TARGETS])
	var comp: Variant = q.completion
	if not (comp is Dictionary) or not (comp.get("summary") is Array):
		out.append("%s: conclusão sem resumo" % id)
	else:
		for v in comp.get("variants", []):
			if not (v is Dictionary) or not v.has("if"):
				out.append("%s: variante de conclusão sem \"if\"" % id)
			else:
				out.append_array(ConditionSchema.validate(v["if"], id + " (variante de conclusão)"))
	out.append_array(ContentPolicy.validate_verification(id, q))
	return out


static func _validate_trigger(owner: String, t: Variant) -> PackedStringArray:
	if not (t is Dictionary) or not (t.get("event") in EVENT_TYPES) or String(t.get("id", "")) == "":
		return PackedStringArray(["%s: gatilho inválido (event deve ser um de %s, com id)" % [owner, EVENT_TYPES]])
	if t.event in ["inventory", "collection"] and int(t.get("count", 1)) < 1:
		return PackedStringArray(["%s: \"count\" deve ser >= 1" % owner])
	if t.event == "condition":
		if not t.has("condition"):
			return PackedStringArray(["%s: gatilho \"condition\" sem \"condition\"" % owner])
		return ConditionSchema.validate(t.condition, owner)
	return PackedStringArray()


## Confere vínculos com outros dados: referências, épocas, lugares, descobertas,
## apresentações, personagens e diálogos citados em alvos e gatilhos; com
## `scenes` (id -> cena), também as cenas dirigidas.
func validate_links(q: Dictionary, catalog: BibleCatalog, dialogues: Dictionary, characters: Dictionary, regions: Dictionary, scenes: Variant = null) -> PackedStringArray:
	var id := "missão " + String(q.get("id", "?"))
	var out := PackedStringArray()
	out.append_array(catalog.validate_references(id, q.get("references", [])))
	out.append_array(catalog.validate_references(id + " (conclusão)", q.get("completion", {}).get("references", []), true))
	if not catalog.eras.has(String(q.get("era_id", ""))):
		out.append("%s: época inexistente \"%s\"" % [id, q.get("era_id")])
	if not catalog.places.has(String(q.get("place_id", ""))):
		out.append("%s: lugar inexistente \"%s\"" % [id, q.get("place_id")])
	if not regions.has(String(q.get("region", ""))):
		out.append("%s: região inexistente \"%s\"" % [id, q.get("region")])
	for d in q.get("discoveries", []) + q.get("completion", {}).get("unlock", []):
		if not catalog.discoveries.has(d):
			out.append("%s: descoberta inexistente \"%s\"" % [id, d])
	for p in q.get("people", []):
		if not catalog.people.has(p):
			out.append("%s: pessoa bíblica inexistente \"%s\"" % [id, p])
	for c in q.get("fictional_characters", []):
		if not characters.has(c):
			out.append("%s: personagem inexistente \"%s\"" % [id, c])
	for pre in q.get("prerequisites", {}).get("quests_completed", []):
		if not quests.has(pre):
			out.append("%s: pré-requisito inexistente \"%s\"" % [id, pre])
	for o in q.get("objectives", []):
		var oid := "%s/%s" % [id, o.get("id", "?")]
		for t in o.get("targets", []):
			if t.type == "npc" and not characters.has(t.id):
				out.append("%s: alvo NPC inexistente \"%s\"" % [oid, t.id])
			elif t.type == "dialogue" and not dialogues.has(t.id):
				out.append("%s: alvo de diálogo inexistente \"%s\"" % [oid, t.id])
			elif t.type == "scene" and scenes is Dictionary and not scenes.has(t.id):
				out.append("%s: alvo de cena inexistente \"%s\"" % [oid, t.id])
		var trig: Dictionary = o.get("complete_on", {})
		match String(trig.get("event", "")):
			"scene_finished":
				if scenes is Dictionary and not scenes.has(trig.id):
					out.append("%s: gatilho cita cena inexistente \"%s\"" % [oid, trig.id])
			"dialogue_finished", "interact":
				if not dialogues.has(trig.id):
					out.append("%s: gatilho cita diálogo inexistente \"%s\"" % [oid, trig.id])
			"presentation_finished":
				if not catalog.presentations.has(trig.id):
					out.append("%s: gatilho cita apresentação inexistente \"%s\"" % [oid, trig.id])
			"discovery":
				if not catalog.discoveries.has(trig.id):
					out.append("%s: gatilho cita descoberta inexistente \"%s\"" % [oid, trig.id])
			"custom":
				if not _custom_event_exists(dialogues, String(trig.id)):
					out.append("%s: nenhum diálogo emite o evento \"%s\"" % [oid, trig.id])
	return out


static func _custom_event_exists(dialogues: Dictionary, event_id: String) -> bool:
	for d in dialogues.values():
		for n in d.get("nodes", {}).values():
			if String(n.get("event", "")) == event_id:
				return true
	return false
