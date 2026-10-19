@tool
class_name WorldSchema
extends RefCounted
## Validação, sem autoloads, dos campos de mundo que não são de missão:
## "lighting" e "passage" de saídas nas regiões; "travel" (com "entry_if"),
## "stages", "regions" e "passage" nas experiências (data/world/experiences.json).
## Usado pelos testes, por tools/validate_content.gd e pela fábrica.


static func validate_passage(owner: String, p: Variant) -> PackedStringArray:
	if not (p is Dictionary):
		return PackedStringArray(["%s: \"passage\" deve ser um objeto {title, lines}" % owner])
	var out := PackedStringArray()
	if String(p.get("title", "")).strip_edges() == "":
		out.append("%s: passage sem \"title\"" % owner)
	var lines: Variant = p.get("lines")
	if not (lines is Array) or lines.is_empty():
		out.append("%s: passage sem \"lines\"" % owner)
	else:
		for l in lines:
			if not (l is String) or l.strip_edges() == "":
				out.append("%s: passage com linha vazia" % owner)
	return out


static func validate_lighting(owner: String, lighting: Variant) -> PackedStringArray:
	if lighting == null:
		return PackedStringArray()
	if not (lighting is Array):
		return PackedStringArray(["%s: \"lighting\" deve ser uma lista de {if, tint}" % owner])
	var out := PackedStringArray()
	for rule in lighting:
		if not (rule is Dictionary) or not (rule.get("tint") is String) or not Color.html_is_valid(String(rule.tint)):
			out.append("%s: regra de lighting precisa de \"tint\": \"#rrggbb\"" % owner)
			continue
		out.append_array(ConditionSchema.validate(rule.get("if"), owner + " (lighting)"))
	return out


static func validate_region(r: Dictionary) -> PackedStringArray:
	var rid := "região " + String(r.get("id", "?"))
	var out := validate_lighting(rid, r.get("lighting"))
	for ex in r.get("exits", []):
		if ex is Dictionary and String(ex.get("to", "")) == "@return" and String(ex.get("fallback_to", "")) == "":
			out.append("%s/%s: saída \"@return\" precisa de \"fallback_to\"" % [rid, ex.get("id", "?")])
		if ex is Dictionary and ex.has("passage"):
			out.append_array(validate_passage("%s/%s" % [rid, ex.get("id", "?")], ex.passage))
	return out


static func _entry_exists(regions: Dictionary, region_id: String, entry_id: String) -> bool:
	var e: Variant = regions.get(region_id, {}).get("entries", {}).get(entry_id)
	return e is Dictionary


## {region, entry, entry_if?}: região e entradas existentes, condições válidas.
static func validate_travel(owner: String, t: Variant, regions: Dictionary) -> PackedStringArray:
	if not (t is Dictionary):
		return PackedStringArray(["%s: \"travel\" deve ser {region, entry}" % owner])
	var out := PackedStringArray()
	var rid := String(t.get("region", ""))
	if not regions.has(rid):
		out.append("%s: travel leva a região inexistente \"%s\"" % [owner, rid])
		return out
	if not _entry_exists(regions, rid, String(t.get("entry", "default"))):
		out.append("%s: entrada inexistente \"%s/%s\"" % [owner, rid, t.get("entry", "default")])
	var alts: Variant = t.get("entry_if", [])
	if not (alts is Array):
		out.append("%s: \"entry_if\" deve ser uma lista de {if, entry}" % owner)
		return out
	for a in alts:
		if not (a is Dictionary) or not a.has("if") or String(a.get("entry", "")) == "":
			out.append("%s: item de entry_if precisa de \"if\" e \"entry\"" % owner)
			continue
		out.append_array(ConditionSchema.validate(a["if"], owner + " (entry_if)"))
		if not _entry_exists(regions, rid, String(a.entry)):
			out.append("%s: entry_if aponta para entrada inexistente \"%s/%s\"" % [owner, rid, a.entry])
	return out


static func validate_experience(x: Dictionary, regions: Dictionary) -> PackedStringArray:
	var xid := "experiência " + String(x.get("id", "?"))
	var out := PackedStringArray()
	if x.has("passage"):
		out.append_array(validate_passage(xid, x.passage))
	if x.has("requires"):
		out.append_array(ConditionSchema.validate(x.requires, xid + " (requires)"))
	if x.has("travel"):
		out.append_array(validate_travel(xid, x.travel, regions))
	if x.has("regions"):
		if not (x.regions is Array):
			out.append("%s: \"regions\" deve ser uma lista de regiões" % xid)
		else:
			for rid in x.regions:
				if not regions.has(String(rid)):
					out.append("%s: regions cita região inexistente \"%s\"" % [xid, rid])
	if x.has("stages"):
		var stages: Variant = x.stages
		if not (stages is Array) or stages.is_empty():
			out.append("%s: \"stages\" deve ser uma lista não vazia" % xid)
			return out
		var seen := {}
		for st in stages:
			if not (st is Dictionary) or String(st.get("id", "")) == "" or seen.has(st.get("id")):
				out.append("%s: etapa sem id ou com id repetido" % xid)
				continue
			seen[st.id] = true
			var sid := "%s/%s" % [xid, st.id]
			if not st.has("travel"):
				out.append("%s: etapa sem \"travel\"" % sid)
			else:
				out.append_array(validate_travel(sid, st.travel, regions))
			if st.has("if"):
				out.append_array(ConditionSchema.validate(st["if"], sid))
			if st.has("passage"):
				out.append_array(validate_passage(sid, st.passage))
	return out
