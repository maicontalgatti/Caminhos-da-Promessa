extends Node
## Descobertas das Escrituras: registra o que o jogador aprendeu e deriva o
## que ele já conhece (pessoas, lugares, acontecimentos, passagens, livros).
## O registro fica em GameState.discoveries; o conteúdo, em data/bible.

signal discovery_unlocked(id: String)


func unlock(id: String) -> bool:
	var d := Bible.discovery(id)
	if d.is_empty():
		push_warning("Discoveries: descoberta inexistente \"%s\"" % id)
		return false
	if GameState.discoveries.has(id) or not ContentPolicy.is_visible(d):
		return false
	GameState.discoveries[id] = GameState.play_time
	GameState.add_log("discovery", id)
	discovery_unlocked.emit(id)
	QuestManager.record_event("discovery", id)
	return true


func is_unlocked(id: String) -> bool:
	return GameState.discoveries.has(id)


## Descobertas em ordem de registro.
func unlocked_ids() -> Array:
	var ids: Array = GameState.discoveries.keys()
	ids = ids.filter(func(i): return not Bible.discovery(i).is_empty())
	ids.sort_custom(func(a, b): return float(GameState.discoveries[a]) < float(GameState.discoveries[b]))
	return ids


func _related(key: String) -> Array:
	var out: Array = []
	for id in unlocked_ids():
		for x in Bible.discovery(id).get("related", {}).get(key, []):
			if not (x in out):
				out.append(x)
	return out


func known_people() -> Array:
	return _related("people").filter(func(p): return Bible.catalog.people.has(p) and ContentPolicy.is_visible(Bible.catalog.people[p]))


func known_places() -> Array:
	var out := _related("places")
	for region_id in GameData.regions:
		if QuestManager.has_event("region_entered", region_id):
			var pid := String(GameData.regions[region_id].get("context", {}).get("place_id", ""))
			if pid != "" and not (pid in out):
				out.append(pid)
	for qid in GameState.quests:
		var pid := String(QuestManager.db.get_quest(qid).get("place_id", ""))
		if pid != "" and not (pid in out):
			out.append(pid)
	return out.filter(func(p): return Bible.catalog.places.has(p) and ContentPolicy.is_visible(Bible.catalog.places[p]))


func known_events() -> Array:
	return _related("events").filter(func(e): return Bible.catalog.events.has(e))


func known_stories() -> Array:
	var out := _related("stories")
	for pid in Bible.catalog.presentations:
		var sid := String(Bible.catalog.presentations[pid].get("story_id", ""))
		if sid != "" and QuestManager.has_event("presentation_finished", pid) and not (sid in out):
			out.append(sid)
	return out.filter(func(s): return Bible.catalog.stories.has(s) and ContentPolicy.is_visible(Bible.catalog.stories[s]))


## Referências encontradas, agrupadas por livro: {book_id: [{ref, source_title, source_kind, source_id}]}.
func known_references() -> Dictionary:
	var out := {}
	var add := func(r: Variant, title: String, kind: String, sid: String) -> void:
		var book := Bible.catalog.book_of(r)
		if book == "":
			return
		if not out.has(book):
			out[book] = []
		out[book].append({"ref": r, "source_title": title, "source_kind": kind, "source_id": sid})
	for id in unlocked_ids():
		var d := Bible.discovery(id)
		for r in d.get("references", []):
			add.call(r, String(d.title), "discovery", id)
	for sid in known_stories():
		var s: Dictionary = Bible.catalog.stories[sid]
		for r in s.get("references", []):
			add.call(r, String(s.title), "story", sid)
	for qid in GameState.quests:
		var q := QuestManager.db.get_quest(qid)
		for r in q.get("references", []):
			add.call(r, String(q.get("title", qid)), "quest", qid)
	return out


## Moradores fictícios com quem o jogador já falou (flag met_<id>).
func met_characters() -> Array:
	var out: Array = []
	for id in GameData.characters:
		if GameState.get_flag("met_" + id):
			out.append(id)
	return out
