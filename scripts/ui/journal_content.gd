class_name JournalContent
extends RefCounted
## Monta as seções do diário a partir do estado salvo e do catálogo bíblico.
## Cada seção é uma lista de entradas {id, title, subtitle, tag, text (BBCode),
## action?, header?}. Entradas com header = true são títulos de grupo, não
## selecionáveis. Separado da interface para poder ser testado sem a tela.

const TABS := ["journey", "scriptures", "characters", "places", "timeline", "discoveries"]
const TAB_LABELS := {
	"journey": "Minha jornada",
	"scriptures": "Escrituras",
	"characters": "Personagens",
	"places": "Lugares",
	"timeline": "Linha do tempo",
	"discoveries": "Descobertas",
}
const JOURNEY_GROUPS := [["main", "História principal"], ["side", "Secundárias"], ["exploration", "Exploração"]]
const LOG_SHOWN := 25


static func build(tab: String) -> Array:
	match tab:
		"journey":
			return journey()
		"scriptures":
			return scriptures()
		"characters":
			return characters()
		"places":
			return places()
		"timeline":
			return timeline()
		"discoveries":
			return my_discoveries()
	return []


static func _header(id: String, title: String) -> Dictionary:
	return {"id": "header:" + id, "title": title.to_upper(), "subtitle": "", "tag": "", "text": "", "header": true}


# --- Formatação --------------------------------------------------------------

static func _c(color: Color, text: String) -> String:
	return "[color=%s]%s[/color]" % [UiStyle.hex(color), text]


static func _h(text: String) -> String:
	return "[font_size=11]%s[/font_size]\n" % _c(UiStyle.INK, text)


static func _sub(text: String) -> String:
	return _c(UiStyle.BROWN, text.to_upper()) + "\n"


static func _muted(text: String) -> String:
	return _c(UiStyle.MUTED, text)


static func _refs_line(refs: Array) -> String:
	if refs.is_empty():
		return ""
	return _c(UiStyle.BROWN, "Referências: ") + Bible.refs(refs) + "\n"


## Trecho bíblico recuado, com a referência e a tradução; "" se longo demais ou ausente.
static func _quote(r: Variant, max_verses := 6) -> String:
	var q := Bible.quote(r, max_verses)
	if q == "":
		return ""
	return "[indent][i]%s[/i]\n%s[/indent]\n" % [q, _muted("— " + Bible.cite(r))]


static func _review(item: Dictionary) -> String:
	if not ContentPolicy.needs_review_marker(item):
		return ""
	return "\n" + _muted("Status do conteúdo: %s." % ContentPolicy.status_label(ContentPolicy.status_of(item))) + "\n"


static func _names(ids: Array, table: Dictionary, key := "name") -> String:
	var out: Array[String] = []
	for id in ids:
		if table.has(id):
			out.append(String(table[id].get(key, id)))
	return ", ".join(out)


# --- Minha jornada -----------------------------------------------------------

static func journey() -> Array:
	var out: Array = []
	var active := QuestManager.active_quests()
	for g in JOURNEY_GROUPS:
		var group := active.filter(func(q): return QuestManager.category(q) == g[0])
		if group.is_empty():
			continue
		out.append(_header(g[0], g[1]))
		for qid in group:
			out.append(quest_entry(qid))
	var done := QuestManager.completed_quests()
	if not done.is_empty():
		out.append(_header("completed", "Concluídas"))
		for qid in done:
			out.append(quest_entry(qid))
	if out.is_empty():
		out.append({"id": "journey:none", "title": "Nenhuma jornada ainda", "subtitle": "", "tag": "",
			"text": _h("Sua jornada começa na aldeia") + "Converse com os moradores e examine o que encontrar. As experiências iniciadas aparecem aqui."})
	out.append(log_entry())
	return out


static func quest_entry(qid: String) -> Dictionary:
	var q := QuestManager.db.get_quest(qid)
	var done := QuestManager.status(qid) == "completed"
	var t := _h(String(q.title))
	t += _sub("%s · %s" % [Bible.place_name(String(q.place_id)), Bible.era_label(String(q.era_id))])
	t += _refs_line(q.references)
	t += _muted(String(q.get("intro", ""))) + "\n\n"
	var objs: Array = q.get("objectives", [])
	for i in objs.size():
		var o: Dictionary = objs[i]
		match QuestManager.objective_state(qid, i):
			"done":
				t += _c(UiStyle.MUTED, "+ %s" % o.text) + "\n"
				if String(o.get("log", "")) != "":
					t += "   " + _muted(String(o.log)) + "\n"
			"current":
				t += _c(UiStyle.INK, "› %s" % o.text) + "\n"
				var lvl := QuestManager.hint_level(qid)
				for h in lvl:
					t += "   " + _c(UiStyle.BROWN, "Pista %d: %s" % [h + 1, o.hints[h]]) + "\n"
			_:
				t += _muted("· ...") + "\n"
	if done:
		var comp := QuestManager.completion(qid)
		t += "\n" + _c(UiStyle.BROWN, String(comp.get("title", "História explorada")).to_upper()) + "\n"
		for line in comp.get("summary", []):
			t += "• %s\n" % line
		if String(comp.get("next", "")) != "":
			t += _muted(String(comp.next)) + "\n"
	var fic: Array = q.get("fictional_characters", [])
	if not fic.is_empty():
		t += "\n" + _muted("Personagens criados para o jogo: %s." % _names(fic, GameData.characters, "display_name"))
	t += _review(q)
	var cat := QuestManager.category(qid)
	var tracked := GameState.tracked_quest == qid
	var sub := "Concluída" if done else ("Acompanhada no HUD" if tracked else "Em andamento")
	var entry := {"id": "quest:" + qid, "title": String(q.title), "subtitle": "%s · %s" % [QuestDatabase.CATEGORY_LABELS.get(cat, cat), sub],
		"tag": String(q.get("classification", "")), "text": t}
	for p in Bible.catalog.presentations:
		if Bible.catalog.presentations[p].get("reference") in q.references:
			var label := "Rever o relato" if QuestManager.has_event("presentation_finished", p) else "Ler o relato bíblico"
			entry["action"] = {"label": label, "presentation": p}
	if not entry.has("action") and not done:
		entry["action"] = {"label": "Deixar de acompanhar", "track": ""} if tracked else {"label": "Acompanhar no HUD", "track": qid}
	return entry


static func log_entry() -> Dictionary:
	var t := _h("Registro da viagem")
	var items: Array = GameState.history.slice(maxi(GameState.history.size() - LOG_SHOWN, 0))
	items.reverse()
	if items.is_empty():
		t += _muted("Nada registrado ainda.")
	for e in items:
		var line := log_line(e)
		if line != "":
			t += "• %s\n" % line
	return {"id": "journey:log", "title": "Registro da viagem", "subtitle": "%d registros" % GameState.history.size(), "tag": "", "text": t}


static func log_line(e: Dictionary) -> String:
	var id := String(e.get("id", ""))
	match String(e.get("kind", "")):
		"quest_started":
			return "Nova jornada: %s" % QuestManager.db.get_quest(id).get("title", id)
		"quest_completed":
			return "História explorada: %s" % QuestManager.db.get_quest(id).get("title", id)
		"objective":
			var parts := id.split("/")
			if parts.size() == 2:
				var i := QuestManager.db.objective_index(parts[0], parts[1])
				if i >= 0:
					return "Concluído: %s" % QuestManager.db.get_quest(parts[0]).objectives[i].text
		"discovery":
			return "Descoberta: %s" % Bible.discovery(id).get("title", id)
		"presentation":
			return "Leitura: %s" % Bible.presentation(id).get("title", id)
		"travel":
			return "Viagem: %s" % GameData.get_region(id.split("/")[0]).get("display_name", id)
		"experience":
			return "Mapa das Escrituras: %s" % WorldManager.experience(id).get("title", id)
		"collectible":
			return "Registro: %s" % Collectibles.entry(id).get("title", id)
		"choice":
			return "Decisão registrada"
	return ""


# --- Minhas descobertas (colecionáveis) --------------------------------------

static func my_discoveries() -> Array:
	var out: Array = []
	var t := _h("Minhas descobertas")
	t += _muted("Registros culturais, geográficos e bíblicos, objetos e segredos encontrados nas regiões. Nem todo registro é um objeto autêntico: a classificação de cada um diz o que ele é.") + "\n\n"
	var found_total := 0
	var regions: Array[String] = []
	for id in Collectibles.order:
		var rid := String(Collectibles.entry(id).region)
		if not (rid in regions):
			regions.append(rid)
		if Collectibles.is_found(id):
			found_total += 1
	for rid in regions:
		t += _sub("%s: %d de %d" % [GameData.get_region(rid).get("display_name", rid), Collectibles.found_in_region(rid), Collectibles.in_region(rid).size()])
		for sid in Collectibles.sets:
			var s: Dictionary = Collectibles.sets[sid]
			if String(s.get("region", "")) == rid:
				t += "   %s: %d/%d\n" % [String(s.get("title", sid)), Collectibles.found_in_set(sid), Collectibles.set_total(sid)]
	out.append({"id": "collect:summary", "title": "Progresso", "subtitle": "%d de %d" % [found_total, Collectibles.order.size()], "tag": "", "text": t})
	for cat in Collectibles.CATEGORIES:
		var ids := Collectibles.order.filter(func(i): return Collectibles.is_found(i) and String(Collectibles.entry(i).category) == cat)
		if ids.is_empty():
			continue
		out.append(_header(cat, Collectibles.CATEGORY_LABELS[cat]))
		for id in ids:
			out.append(collectible_entry(id))
	return out


static func collectible_entry(id: String) -> Dictionary:
	var c := Collectibles.entry(id)
	var t := _h(String(c.title))
	t += _sub("%s · %s" % [Collectibles.CATEGORY_LABELS.get(c.category, c.category), GameData.get_region(String(c.region)).get("display_name", c.region)])
	t += _refs_line(c.get("references", []))
	t += String(c.summary) + "\n"
	var sid := String(c.get("set", ""))
	if sid != "":
		t += "\n" + _muted("Coleção \"%s\": %d de %d." % [Collectibles.sets.get(sid, {}).get("title", sid), Collectibles.found_in_set(sid), Collectibles.set_total(sid)])
	return {"id": "collect:" + id, "title": String(c.title), "subtitle": String(Collectibles.CATEGORY_LABELS.get(c.category, "")), "tag": String(c.classification), "text": t}


# --- Escrituras --------------------------------------------------------------

static func scriptures() -> Array:
	var out: Array = []
	var refs := Discoveries.known_references()
	for b in Bible.catalog.book_order:
		if refs.has(b):
			out.append(book_entry(b, refs[b]))
	var ids := Discoveries.unlocked_ids()
	ids.reverse()
	for id in ids:
		out.append(discovery_entry(id))
	if out.is_empty():
		out.append({"id": "scriptures:none", "title": "Nada registrado", "subtitle": "", "tag": "",
			"text": _h("Escrituras") + "As passagens e descobertas que você encontrar ficam guardadas aqui para consulta."})
	return out


static func book_entry(book_id: String, items: Array) -> Dictionary:
	var book: Dictionary = Bible.catalog.books.get(book_id, {})
	var t := _h(String(book.get("name", book_id)))
	t += _sub("%s · %s" % ["Antigo Testamento" if book.get("testament") == "AT" else "Novo Testamento", book.get("group", "")])
	t += _muted("Passagens que você encontrou neste livro:") + "\n"
	var seen := {}
	for it in items:
		var key := "%s|%s" % [Bible.ref(it.ref), it.source_title]
		if seen.has(key):
			continue
		seen[key] = true
		t += "• %s  %s\n" % [_c(UiStyle.BROWN, Bible.ref(it.ref)), _muted("(%s)" % it.source_title)]
		t += _quote(it.ref)
	t += "\n" + _muted("Leia o capítulo inteiro numa Bíblia para conhecer o contexto completo.")
	if Bible.credit() != "":
		t += "\n" + _muted(Bible.credit())
	var count := seen.size()
	return {"id": "book:" + book_id, "title": "Livro: %s (%d)" % [book.get("name", book_id), count],
		"subtitle": "%d passagem%s" % [count, "" if count == 1 else "s"], "tag": "", "text": t}


static func discovery_entry(id: String) -> Dictionary:
	var d := Bible.discovery(id)
	var t := _h(String(d.title))
	t += _sub("%s · %s" % [ContentPolicy.classification_label(String(d.classification)), Bible.era_label(String(d.era_id))])
	t += String(d.summary) + "\n\n"
	t += _c(UiStyle.BROWN, "Na Bíblia: ") + String(d.bible_note) + "\n"
	t += _refs_line(d.references)
	for r in d.references.slice(0, 2):
		t += _quote(r, 4)
	for sec in d.get("sections", []):
		var label := String(ContentPolicy.SECTION_KINDS.get(sec.kind, sec.kind))
		var head := label if String(sec.get("title", "")) == "" else "%s — %s" % [label, sec.title]
		t += "\n" + _c(UiStyle.BROWN, head.to_upper()) + "\n" + String(sec.text) + "\n"
	var rel: Dictionary = d.get("related", {})
	var rel_lines: Array[String] = []
	if not rel.get("people", []).is_empty():
		rel_lines.append("Pessoas: " + _names(rel.people, Bible.catalog.people))
	if not rel.get("places", []).is_empty():
		rel_lines.append("Lugares: " + _names(rel.places, Bible.catalog.places))
	if not rel.get("events", []).is_empty():
		rel_lines.append("Acontecimentos: " + _names(rel.events, Bible.catalog.events, "title"))
	if not rel_lines.is_empty():
		t += "\n" + _muted("\n".join(rel_lines)) + "\n"
	t += _review(d)
	return {"id": "disc:" + id, "title": String(d.title), "subtitle": Bible.refs(d.references, true),
		"tag": String(d.classification), "text": t}


# --- Personagens -------------------------------------------------------------

static func characters() -> Array:
	var out: Array = []
	for pid in Discoveries.known_people():
		out.append(person_entry(pid))
	for cid in Discoveries.met_characters():
		var c: Dictionary = GameData.characters[cid]
		if String(c.get("kind", "person")) != "person":
			continue
		var t := _h(String(c.display_name))
		t += _sub("%s · personagem fictício" % c.get("role", ""))
		t += String(c.get("description", "")) + "\n\n"
		t += _muted("Criado para o jogo. Não aparece na Bíblia; ajuda a mostrar como era a vida cotidiana na época.")
		out.append({"id": "char:" + cid, "title": String(c.display_name), "subtitle": "Fictício · " + String(c.get("role", "")),
			"tag": "plausible_fiction", "text": t})
	if out.is_empty():
		out.append({"id": "characters:none", "title": "Ninguém ainda", "subtitle": "", "tag": "",
			"text": _h("Personagens") + "Pessoas das Escrituras e moradores que você conhecer aparecem aqui. Os moradores criados para o jogo são identificados como fictícios."})
	return out


static func person_entry(pid: String) -> Dictionary:
	var p: Dictionary = Bible.catalog.people[pid]
	var t := _h(String(p.name))
	t += _sub("Personagem bíblico · %s" % Bible.era_label(String(p.era_id)))
	t += String(p.get("summary", "")) + "\n"
	t += _refs_line(p.get("references", []))
	var rels: Array[String] = []
	for r in p.get("relations", []):
		rels.append("%s (%s)" % [Bible.catalog.people.get(r.person, {}).get("name", r.person), r.label])
	if not rels.is_empty():
		t += "\n" + _c(UiStyle.BROWN, "RELAÇÕES") + "\n" + ", ".join(rels) + "\n"
	var moments: Array = p.get("moments", [])
	if not moments.is_empty():
		t += "\n" + _c(UiStyle.BROWN, "MOMENTOS") + "\n"
		for m in moments:
			t += "• %s\n" % m
	if not p.get("places", []).is_empty():
		t += "\n" + _muted("Lugares: " + _names(p.places, Bible.catalog.places)) + "\n"
	t += _review(p)
	return {"id": "person:" + pid, "title": String(p.name), "subtitle": "Bíblico", "tag": "recorded_event", "text": t}


# --- Lugares -----------------------------------------------------------------

static func places() -> Array:
	var out: Array = []
	for pid in Discoveries.known_places():
		out.append(place_entry(pid))
	if out.is_empty():
		out.append({"id": "places:none", "title": "Nenhum lugar", "subtitle": "", "tag": "",
			"text": _h("Lugares") + "Os lugares visitados ou citados nas descobertas aparecem aqui."})
	return out


static func place_entry(pid: String) -> Dictionary:
	var p: Dictionary = Bible.catalog.places[pid]
	var ident := String(BibleCatalog.PLACE_IDENTIFICATIONS.get(p.get("identification", ""), ""))
	var t := _h(String(p.name))
	t += _sub("%s · %s" % [p.get("kind", ""), ident])
	t += String(p.get("description", "")) + "\n"
	t += _refs_line(p.get("references", []))
	var eras: Array[String] = []
	for e in p.get("eras", []):
		eras.append(Bible.era_label(e))
	if not eras.is_empty():
		t += "\n" + _muted("Épocas: " + ", ".join(eras)) + "\n"
	if p.get("identification") in ["probable", "debated"]:
		t += _muted("A localização exata deste lugar não é certa; o jogo indica a identificação mais citada.") + "\n"
	t += _review(p)
	return {"id": "place:" + pid, "title": String(p.name), "subtitle": ident, "tag": "", "text": t}


# --- Linha do tempo ----------------------------------------------------------

static func timeline() -> Array:
	var out: Array = []
	out.append({"id": "timeline:about", "title": "Como ler as datas", "subtitle": "a.C. e d.C.", "tag": "",
		"text": _h("Como ler as datas")
		+ "• a.C. = antes de Cristo; d.C. = depois de Cristo. Não existe ano zero: depois de 1 a.C. vem 1 d.C.\n"
		+ "• Antes de Cristo, os números diminuem com o tempo: 722 a.C. vem antes de 587 a.C.\n"
		+ "• \"c.\" indica data aproximada. Séculos aparecem em algarismos romanos.\n"
		+ "• Muitos relatos bíblicos não têm data no calendário atual. Nesses casos o jogo mostra a época, sem inventar um ano, e explica quando a datação é debatida.\n"
		+ "• Marcos com datas bem documentadas aparecem como referência."})
	var known_events := Discoveries.known_events()
	for era_id in Bible.catalog.era_order:
		var e: Dictionary = Bible.catalog.eras[era_id]
		if not ContentPolicy.is_visible(e):
			continue
		out.append(era_entry(era_id, known_events))
	return out


static func era_entry(era_id: String, known_events: Array) -> Dictionary:
	var e: Dictionary = Bible.catalog.eras[era_id]
	var when := String(e.get("display", ""))
	if when == "":
		when = Chronology.format_span(e.get("span"))
	var t := _h(String(e.label))
	t += _sub(when)
	t += String(e.get("description", "")) + "\n"
	for h in e.get("hypotheses", []):
		t += "\n" + _c(UiStyle.BROWN, "HIPÓTESE: %s" % String(h.label).to_upper()) + " " + _muted(Chronology.format_span(h.span)) + "\n"
		t += String(h.get("basis", "")) + "\n"
	var evs: Array = []
	for ev_id in Bible.catalog.events:
		var ev: Dictionary = Bible.catalog.events[ev_id]
		if ev.era_id == era_id and (ev_id in known_events or ev.get("anchor", false)) and ContentPolicy.is_visible(ev):
			evs.append(ev)
	evs.sort_custom(func(a, b): return _event_key(a) < _event_key(b))
	if not evs.is_empty():
		t += "\n" + _c(UiStyle.BROWN, "ACONTECIMENTOS") + "\n"
		for ev in evs:
			var mark := "Marco" if ev.get("anchor", false) and not (ev.id in known_events) else "Descoberto"
			var when_ev := "sem datação atribuída" if ev.get("date") == null else Chronology.format_span(ev.date)
			t += "• %s — %s  %s\n" % [_c(UiStyle.INK, String(ev.title)), when_ev, _muted("(%s · %s)" % [mark, Bible.refs(ev.get("references", []), true)])]
	var quests: Array[String] = []
	for qid in GameState.quests:
		if QuestManager.db.get_quest(qid).get("era_id") == era_id:
			quests.append(String(QuestManager.db.get_quest(qid).title))
	if not quests.is_empty():
		t += "\n" + _muted("Suas experiências nesta época: " + ", ".join(quests)) + "\n"
	var books: Array[String] = []
	for b in e.get("books", []):
		books.append(String(Bible.catalog.books.get(b, {}).get("name", b)))
	if not books.is_empty():
		t += "\n" + _muted("Livros relacionados: " + ", ".join(books)) + "\n"
	t += _review(e)
	var here := "" if quests.is_empty() else "Você esteve aqui"
	return {"id": "era:" + era_id, "title": String(e.label), "subtitle": here if here != "" else when, "tag": "", "text": t}


static func _event_key(ev: Dictionary) -> float:
	var y: Variant = Chronology.sort_year(ev.get("date"))
	if y != null:
		return float(y) + float(ev.get("sequence", 0)) * 0.001
	return -100000.0 + float(ev.get("sequence", 0))
