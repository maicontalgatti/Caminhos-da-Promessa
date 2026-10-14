extends Node
## Acesso global ao catálogo bíblico (carregado uma vez ao iniciar).

var catalog := BibleCatalog.new()


func _ready() -> void:
	catalog.load_all()
	for e in catalog.errors:
		push_error("Bible: " + e)


func ref(r: Variant) -> String:
	return catalog.format_reference(r)


func refs(list: Array, short := false) -> String:
	return catalog.format_references(list, short)


## Texto de uma referência com números de versículo em BBCode, ou "" se a
## tradução carregada não tiver todos os versículos ou passar de max_verses.
func quote(r: Variant, max_verses := 0) -> String:
	var vs := catalog.verses_of(r)
	if vs.is_empty() or (max_verses > 0 and vs.size() > max_verses):
		return ""
	var parts: Array[String] = []
	for i in vs.size():
		var v: Dictionary = vs[i]
		var num := "%d:%d" % [v.chapter, v.verse] if i == 0 or v.verse == 1 else str(v.verse)
		parts.append("[font_size=6][color=#8b5a2b]%s[/color][/font_size] %s" % [num, v.text])
	return " ".join(parts)


## Texto puro (sem números), para falas e cartões curtos.
func quote_plain(r: Variant, max_verses := 0) -> String:
	var vs := catalog.verses_of(r)
	if vs.is_empty() or (max_verses > 0 and vs.size() > max_verses):
		return ""
	return " ".join(vs.map(func(v): return String(v.text)))


## Ex.: "Gênesis 26:18 (BPM)".
func cite(r: Variant) -> String:
	var abbrev := String(catalog.translation.get("abbrev", ""))
	return ref(r) + (" (%s)" % abbrev if abbrev != "" else "")


func credit() -> String:
	return String(catalog.translation.get("credit", ""))


func discovery(id: String) -> Dictionary:
	return catalog.discoveries.get(id, {})


func presentation(id: String) -> Dictionary:
	return catalog.presentations.get(id, {})


func era_display(era_id: String) -> String:
	return catalog.era_display(era_id)


func era_label(era_id: String) -> String:
	return catalog.era_label(era_id)


func place_name(place_id: String) -> String:
	return String(catalog.places.get(place_id, {}).get("name", ""))
