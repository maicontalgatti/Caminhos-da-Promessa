@tool
class_name BibleCatalog
extends RefCounted
## Catálogo bíblico carregado de data/bible: livros, histórias, descobertas,
## cronologia, lugares, pessoas e apresentações. Valida referências contra a
## lista de livros e a contagem de versículos, e impede que conteúdo não
## revisado seja tratado como verificado. Ver docs/bible_catalog.md.

const BOOKS_PATH := "res://data/bible/books.json"
const STORIES_DIR := "res://data/bible/stories"
const DISCOVERIES_PATH := "res://data/bible/discoveries.json"
const CHRONOLOGY_PATH := "res://data/bible/chronology.json"
const PLACES_PATH := "res://data/bible/places.json"
const PEOPLE_PATH := "res://data/bible/people.json"
const PRESENTATIONS_PATH := "res://data/bible/presentations.json"
const VERSE_COUNTS_PATH := "res://data/bible/verse_counts.json"
## Texto bíblico por tradução: <id>.json gerado por tools/import_scripture.gd.
const TEXTS_DIR := "res://data/bible/texts"
const TRANSLATION_SETTING := "caminhos/content/bible_translation"
const DEFAULT_TRANSLATION := "bpm"

const CLASSIFICATIONS := ContentPolicy.CLASSIFICATIONS
const VERIFICATION_STATUSES := ContentPolicy.STATUSES
const REQUIRED_STORY_FIELDS := ["id", "title", "summary", "references", "characters", "region",
	"era", "literary_category", "content_classification", "possible_interactions",
	"possible_activities", "narrative_relevance", "depends_on", "verification"]
const PRESENTATION_MODES := ["card", "toast"]
const PLACE_IDENTIFICATIONS := {
	"established": "identificação amplamente aceita",
	"probable": "identificação provável",
	"debated": "localização debatida",
	"fictional": "lugar fictício, criado para o jogo",
}

var books: Dictionary = {}
var book_order: Array[String] = []
var stories: Dictionary = {}
var discoveries: Dictionary = {}
var eras: Dictionary = {}
var era_order: Array[String] = []
var events: Dictionary = {}
var places: Dictionary = {}
var people: Dictionary = {}
var presentations: Dictionary = {}
var verse_counts: Dictionary = {}
## Metadados da tradução carregada ({id, name, abbrev, license, credit, ...}); vazio se não houver texto.
var translation: Dictionary = {}
## "Gen 26:18" -> texto do versículo na tradução carregada.
var scripture: Dictionary = {}
var errors := PackedStringArray()

var _ref_regex := RegEx.create_from_string("^\\s*(\\S+)\\s+(\\d+):(\\d+)(?:\\s*-\\s*(?:(\\d+):)?(\\d+))?\\s*$")


func load_all() -> void:
	for d in [books, stories, discoveries, eras, events, places, people, presentations, verse_counts, translation, scripture]:
		d.clear()
	book_order.clear()
	era_order.clear()
	errors.clear()
	var data: Variant = JsonUtil.read_file(BOOKS_PATH, errors)
	if data is Dictionary and data.get("books") is Array:
		for b in data.books:
			books[b.id] = b
			book_order.append(b.id)
	else:
		errors.append("books.json inválido")
		return
	var vc: Variant = JsonUtil.read_file(VERSE_COUNTS_PATH, errors)
	if vc is Dictionary and vc.get("verse_counts") is Dictionary:
		verse_counts = vc.verse_counts
	for s in JsonUtil.read_collection(STORIES_DIR, "stories", errors):
		if stories.has(s.id):
			errors.append("História duplicada: %s" % s.id)
			continue
		stories[s.id] = s
	discoveries = _load_keyed(DISCOVERIES_PATH, "discoveries")
	eras = _load_keyed(CHRONOLOGY_PATH, "eras")
	events = _load_keyed(CHRONOLOGY_PATH, "events")
	places = _load_keyed(PLACES_PATH, "places")
	people = _load_keyed(PEOPLE_PATH, "people")
	presentations = _load_keyed(PRESENTATIONS_PATH, "presentations")
	load_translation(String(ProjectSettings.get_setting(TRANSLATION_SETTING, DEFAULT_TRANSLATION)))
	var ids: Array = eras.keys()
	ids.sort_custom(func(a, b): return int(eras[a].get("order", 0)) < int(eras[b].get("order", 0)))
	for id in ids:
		era_order.append(id)
	for id in stories:
		errors.append_array(validate_story(stories[id]))
	for id in discoveries:
		errors.append_array(validate_discovery(discoveries[id]))
	for id in eras:
		errors.append_array(validate_era(eras[id]))
	for id in events:
		errors.append_array(validate_event(events[id]))
	for id in places:
		errors.append_array(validate_place(places[id]))
	for id in people:
		errors.append_array(validate_person(people[id]))
	for id in presentations:
		errors.append_array(validate_presentation(presentations[id]))


func _load_keyed(path: String, key: String) -> Dictionary:
	var out := {}
	var data: Variant = JsonUtil.read_file(path, errors)
	if not (data is Dictionary) or not (data.get(key) is Array):
		errors.append("%s: esperado objeto com a lista \"%s\"" % [path, key])
		return out
	for item in data[key]:
		if not (item is Dictionary) or not (item.get("id") is String):
			errors.append("%s: item sem \"id\" em \"%s\"" % [path, key])
		elif out.has(item.id):
			errors.append("%s: id duplicado \"%s\"" % [path, item.id])
		else:
			out[item.id] = item
	return out


# --- Referências -------------------------------------------------------------

## Aceita {book, chapter_start, verse_start, chapter_end, verse_end} ou texto
## "Gen 26:18-22", "Gen 26:18", "Gen 39:19-40:23". Retorna {} se ilegível.
func parse_reference(r: Variant) -> Dictionary:
	if r is Dictionary:
		return r
	if not (r is String):
		return {}
	var m := _ref_regex.search(r)
	if m == null:
		return {}
	var cs := int(m.get_string(2))
	var vs := int(m.get_string(3))
	var ce := cs
	var ve := vs
	if m.get_string(5) != "":
		ve = int(m.get_string(5))
		if m.get_string(4) != "":
			ce = int(m.get_string(4))
	return {"book": m.get_string(1), "chapter_start": cs, "verse_start": vs, "chapter_end": ce, "verse_end": ve}


func validate_reference(owner: String, r: Variant) -> PackedStringArray:
	var out := PackedStringArray()
	var ref := parse_reference(r)
	if ref.is_empty():
		return PackedStringArray(["%s: referência ilegível \"%s\"" % [owner, r]])
	var book: Dictionary = books.get(String(ref.get("book", "")), {})
	if book.is_empty():
		out.append("%s: livro desconhecido \"%s\"" % [owner, ref.get("book")])
		return out
	for k in ["chapter_start", "verse_start", "chapter_end", "verse_end"]:
		var v: Variant = ref.get(k)
		if not (v is float or v is int) or int(v) < 1:
			out.append("%s: %s inválido" % [owner, k])
			return out
	var cs := int(ref.chapter_start)
	var ce := int(ref.chapter_end)
	if cs > int(book.chapters) or ce > int(book.chapters):
		out.append("%s: capítulo além do fim de %s (%d)" % [owner, book.name, book.chapters])
		return out
	if ce < cs or (ce == cs and int(ref.verse_end) < int(ref.verse_start)):
		out.append("%s: intervalo de referência invertido" % owner)
	if not verse_counts.is_empty():
		for pair in [[cs, int(ref.verse_start)], [ce, int(ref.verse_end)]]:
			var key := "%s %d" % [ref.book, pair[0]]
			if not verse_counts.has(key):
				out.append("%s: capítulo \"%s\" sem contagem de versículos em verse_counts.json" % [owner, key])
			elif pair[1] > int(verse_counts[key]):
				out.append("%s: %s tem %d versículos (citado %d)" % [owner, key, int(verse_counts[key]), pair[1]])
	return out


func validate_references(owner: String, refs: Variant, allow_empty := false) -> PackedStringArray:
	var out := PackedStringArray()
	if not (refs is Array):
		out.append("%s: referências devem ser uma lista" % owner)
		return out
	if refs.is_empty() and not allow_empty:
		out.append("%s: sem referências bíblicas" % owner)
	for r in refs:
		out.append_array(validate_reference(owner, r))
	return out


## Ex.: "Gênesis 37:12-36" ou "Gênesis 39:19 - 40:23".
func format_reference(r: Variant) -> String:
	return _format(parse_reference(r), "name")


## Ex.: "Gn 26:18-22".
func format_reference_short(r: Variant) -> String:
	return _format(parse_reference(r), "abbrev")


func format_references(refs: Array, short := false) -> String:
	var parts: Array[String] = []
	for r in refs:
		parts.append(format_reference_short(r) if short else format_reference(r))
	return "; ".join(parts)


func _format(r: Dictionary, name_key: String) -> String:
	if r.is_empty():
		return "?"
	var book: Dictionary = books.get(String(r.book), {})
	var name := String(book.get(name_key, book.get("name", r.book)))
	var cs := int(r.chapter_start)
	var ce := int(r.chapter_end)
	if cs == ce:
		if int(r.verse_start) == int(r.verse_end):
			return "%s %d:%d" % [name, cs, int(r.verse_start)]
		return "%s %d:%d-%d" % [name, cs, int(r.verse_start), int(r.verse_end)]
	return "%s %d:%d - %d:%d" % [name, cs, int(r.verse_start), ce, int(r.verse_end)]


func book_of(r: Variant) -> String:
	return String(parse_reference(r).get("book", ""))


## "Gen 26:18-22" -> ["Gen 26:18", ..., "Gen 26:22"]; atravessa capítulos usando verse_counts.
func expand_reference(r: Variant) -> Array[String]:
	var p := parse_reference(r)
	var out: Array[String] = []
	if p.is_empty():
		return out
	var cs := int(p.chapter_start)
	var ce := int(p.chapter_end)
	for c in range(cs, ce + 1):
		var first := int(p.verse_start) if c == cs else 1
		var last := int(p.verse_end) if c == ce else int(verse_counts.get("%s %d" % [p.book, c], 0))
		for v in range(first, last + 1):
			out.append("%s %d:%d" % [p.book, c, v])
	return out


# --- Texto bíblico -------------------------------------------------------------

## Carrega data/bible/texts/<id>.json. Sem arquivo, o jogo mostra só as referências.
func load_translation(id: String) -> void:
	translation.clear()
	scripture.clear()
	var path := TEXTS_DIR.path_join(id + ".json")
	if not FileAccess.file_exists(path):
		errors.append("Texto bíblico da tradução \"%s\" não encontrado em %s" % [id, path])
		return
	var data: Variant = JsonUtil.read_file(path, errors)
	if not (data is Dictionary) or not (data.get("translation") is Dictionary) or not (data.get("verses") is Dictionary):
		errors.append("%s: esperado objeto com \"translation\" e \"verses\"" % path)
		return
	for f in ["id", "name", "abbrev", "license", "credit"]:
		if String(data.translation.get(f, "")).strip_edges() == "":
			errors.append("%s: tradução sem \"%s\"" % [path, f])
	errors.append_array(ContentPolicy.validate_verification("texto bíblico " + id, data))
	translation = data.translation
	scripture = data.verses


## Versículos de uma referência que existem na tradução carregada:
## [{key, chapter, verse, text}]. Vazio se faltar algum (nunca cita pela metade).
func verses_of(r: Variant) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for key in expand_reference(r):
		if not scripture.has(key):
			return [] as Array[Dictionary]
		var cv := key.split(" ")[-1].split(":")
		out.append({"key": key, "chapter": int(cv[0]), "verse": int(cv[1]), "text": String(scripture[key])})
	return out


func _validate_scripture(owner: String, r: Variant) -> PackedStringArray:
	if scripture.is_empty() or verses_of(r).size() > 0:
		return PackedStringArray()
	return PackedStringArray(["%s: texto de \"%s\" ausente em data/bible/texts/%s.json (rode tools/import_scripture.gd)" % [owner, r, translation.get("id", "?")]])


# --- Cronologia --------------------------------------------------------------

func era_label(era_id: String) -> String:
	return String(eras.get(era_id, {}).get("label", ""))


## "Época dos patriarcas — cronologia aproximada e debatida", "Monarquia unida — séculos XI–X a.C. (aproximado)".
func era_display(era_id: String) -> String:
	var e: Dictionary = eras.get(era_id, {})
	if e.is_empty():
		return ""
	var when := String(e.get("display", ""))
	if when == "":
		when = Chronology.format_span(e.get("span"))
	return "%s — %s" % [e.label, when]


func event_date_text(ev: Dictionary) -> String:
	if ev.get("date") == null:
		return "%s — sem datação atribuída" % era_label(String(ev.get("era_id", "")))
	return Chronology.format_span(ev.date)


# --- Validação ---------------------------------------------------------------

func validate_story(s: Dictionary) -> PackedStringArray:
	var out := PackedStringArray()
	var id := String(s.get("id", "?"))
	for f in REQUIRED_STORY_FIELDS:
		if not s.has(f):
			out.append("%s: campo obrigatório ausente \"%s\"" % [id, f])
	if not (s.get("content_classification") in CLASSIFICATIONS):
		out.append("%s: classificação inválida" % id)
	out.append_array(ContentPolicy.validate_verification(id, s))
	out.append_array(validate_references(id, s.get("references")))
	for dep in s.get("depends_on", []):
		if not stories.has(dep):
			out.append("%s: depende de história inexistente \"%s\"" % [id, dep])
	return out


func validate_discovery(d: Dictionary) -> PackedStringArray:
	var id := "descoberta " + String(d.get("id", "?"))
	var out := PackedStringArray()
	for f in ["title", "summary", "bible_note"]:
		if String(d.get(f, "")).strip_edges() == "":
			out.append("%s: campo \"%s\" vazio" % [id, f])
	if not (d.get("classification") in CLASSIFICATIONS):
		out.append("%s: classificação inválida" % id)
	if not (d.get("presentation") in PRESENTATION_MODES):
		out.append("%s: apresentação deve ser card ou toast" % id)
	if not eras.has(String(d.get("era_id", ""))):
		out.append("%s: época inexistente \"%s\"" % [id, d.get("era_id")])
	out.append_array(validate_references(id, d.get("references")))
	var sections: Variant = d.get("sections")
	if not (sections is Array) or sections.is_empty():
		out.append("%s: sem seções para o diário" % id)
	else:
		for sec in sections:
			if not (sec is Dictionary) or not (sec.get("kind") in ContentPolicy.SECTION_KINDS) or String(sec.get("text", "")) == "":
				out.append("%s: seção inválida (kind deve ser um de %s)" % [id, ContentPolicy.SECTION_KINDS.keys()])
	out.append_array(_validate_related(id, d.get("related", {})))
	out.append_array(ContentPolicy.validate_verification(id, d))
	return out


func _validate_related(owner: String, rel: Variant) -> PackedStringArray:
	var out := PackedStringArray()
	if not (rel is Dictionary):
		return PackedStringArray(["%s: \"related\" inválido" % owner])
	var tables := {"people": people, "places": places, "events": events, "stories": stories}
	for key in tables:
		for ref_id in rel.get(key, []):
			if not tables[key].has(ref_id):
				out.append("%s: %s inexistente \"%s\"" % [owner, key, ref_id])
	return out


func validate_era(e: Dictionary) -> PackedStringArray:
	var id := "época " + String(e.get("id", "?"))
	var out := PackedStringArray()
	if String(e.get("label", "")) == "":
		out.append("%s: sem nome" % id)
	if not (e.get("order") is float or e.get("order") is int):
		out.append("%s: sem ordem" % id)
	if not (e.get("certainty") in Chronology.CERTAINTIES):
		out.append("%s: certeza inválida" % id)
	if e.get("span") == null and e.get("certainty") == "documented":
		out.append("%s: época sem datação não pode ser 'documented'" % id)
	out.append_array(Chronology.validate_span(id, e.get("span")))
	for h in e.get("hypotheses", []):
		out.append_array(Chronology.validate_span(id + " (hipótese)", h.get("span")))
		out.append_array(validate_references(id + " (hipótese)", h.get("references", []), true))
	for b in e.get("books", []):
		if not books.has(b):
			out.append("%s: livro desconhecido \"%s\"" % [id, b])
	out.append_array(ContentPolicy.validate_verification(id, e))
	return out


func validate_event(ev: Dictionary) -> PackedStringArray:
	var id := "acontecimento " + String(ev.get("id", "?"))
	var out := PackedStringArray()
	if not eras.has(String(ev.get("era_id", ""))):
		out.append("%s: época inexistente" % id)
	if not (ev.get("classification") in CLASSIFICATIONS):
		out.append("%s: classificação inválida" % id)
	out.append_array(Chronology.validate_span(id, ev.get("date")))
	out.append_array(validate_references(id, ev.get("references"), ev.get("classification") == "historical_context"))
	out.append_array(_validate_related(id, {"people": ev.get("people", []), "places": ev.get("places", [])}))
	if ev.has("story_id") and not stories.has(ev.story_id):
		out.append("%s: história inexistente \"%s\"" % [id, ev.story_id])
	out.append_array(ContentPolicy.validate_verification(id, ev))
	return out


func validate_place(p: Dictionary) -> PackedStringArray:
	var id := "lugar " + String(p.get("id", "?"))
	var out := PackedStringArray()
	if not (p.get("identification") in PLACE_IDENTIFICATIONS):
		out.append("%s: identificação inválida" % id)
	for e in p.get("eras", []):
		if not eras.has(e):
			out.append("%s: época inexistente \"%s\"" % [id, e])
	out.append_array(validate_references(id, p.get("references"), p.get("identification") == "fictional"))
	out.append_array(ContentPolicy.validate_verification(id, p))
	return out


func validate_person(p: Dictionary) -> PackedStringArray:
	var id := "pessoa " + String(p.get("id", "?"))
	var out := PackedStringArray()
	if not eras.has(String(p.get("era_id", ""))):
		out.append("%s: época inexistente" % id)
	out.append_array(validate_references(id, p.get("references")))
	out.append_array(_validate_related(id, {"places": p.get("places", [])}))
	for rel in p.get("relations", []):
		if not people.has(String(rel.get("person", ""))):
			out.append("%s: relação com pessoa inexistente \"%s\"" % [id, rel.get("person")])
	out.append_array(ContentPolicy.validate_verification(id, p))
	return out


func validate_presentation(pr: Dictionary) -> PackedStringArray:
	var id := "apresentação " + String(pr.get("id", "?"))
	var out := PackedStringArray()
	if not (pr.get("classification") in CLASSIFICATIONS):
		out.append("%s: classificação inválida" % id)
	out.append_array(validate_reference(id, pr.get("reference", "")))
	var steps: Variant = pr.get("steps")
	if not (steps is Array) or steps.is_empty():
		out.append("%s: sem passos" % id)
	else:
		for st in steps:
			if String(st.get("heading", "")) == "" or String(st.get("text", "")) == "":
				out.append("%s: passo sem título ou texto" % id)
			if String(st.get("reference", "")) != "":
				out.append_array(validate_reference(id, st.reference))
			if String(st.get("scripture", "")) != "":
				var errs := validate_reference(id, st.scripture)
				out.append_array(errs if not errs.is_empty() else _validate_scripture(id, st.scripture))
	for u in pr.get("unlock", []):
		if not discoveries.has(u):
			out.append("%s: descoberta inexistente \"%s\"" % [id, u])
	if pr.has("story_id") and not stories.has(pr.story_id):
		out.append("%s: história inexistente \"%s\"" % [id, pr.story_id])
	out.append_array(ContentPolicy.validate_verification(id, pr))
	return out


## Publicável = aprovado por uma pessoa. Conteúdo em revisão só aparece no canal de protótipo.
static func is_publishable(item: Dictionary) -> bool:
	return ContentPolicy.status_of(item) == "approved"
