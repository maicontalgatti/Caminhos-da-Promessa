class_name FactoryCatalog
extends RefCounted
## Catálogo de produção da fábrica de missões (production/catalog/episodes.json).
## Importa o catálogo-semente, normaliza referências, estima o esforço, liga
## episódios às missões reais do jogo e controla os estados editoriais por gates.
## Usado por tools/factory.gd (linha de comando) e pelos testes. Ver docs/mission_factory.md.

const SEED_PATH := "res://production/catalog/seed_catalog_v0.1.json"
const EPISODES_PATH := "res://production/catalog/episodes.json"
const EPISODES_DIR := "res://production/episodes"

const STATUSES := ["idea", "researched", "designed", "awaiting_biblical_review",
	"awaiting_historical_review", "approved_for_implementation", "implemented", "tested", "published", "blocked"]
const STATUS_LABELS := {
	"idea": "apenas ideia",
	"researched": "pesquisado",
	"designed": "desenhado",
	"awaiting_biblical_review": "aguardando revisão bíblica",
	"awaiting_historical_review": "aguardando revisão histórica",
	"approved_for_implementation": "aprovado para implementação",
	"implemented": "implementado",
	"tested": "testado",
	"published": "publicado",
	"blocked": "bloqueado",
}
## Arquivos do pacote exigidos a partir de cada estado (cumulativo).
const GATE_FILES := {
	"researched": ["research_biblical.md", "research_historical.md"],
	"designed": ["design.md", "manifest.json"],
	"awaiting_biblical_review": [],
	"awaiting_historical_review": ["review.json"],
	"approved_for_implementation": [],
	"implemented": ["audio_manifest.json", "visual_manifest.json"],
	"tested": ["test_report.json"],
	"published": [],
}
const REVIEW_OK := "ok_for_human_review"
const VERDICTS := ["pending", "blocked", "needs_changes", REVIEW_OK]
const SEVERITIES := ["critical", "major", "minor", "info"]

## Como cada tipo de evento do catálogo-semente se traduz no motor atual.
const EVENT_SUPPORT := {
	"talk_npc": {"level": "data_only", "engine": "evento custom num nó de diálogo, ou dialogue_finished"},
	"inspect_object": {"level": "data_only", "engine": "Interactable com dialogue_id + dialogue_finished/interact"},
	"observe_scene": {"level": "partial", "engine": "presentation_finished (apresentação em quadros); cena dirigida no mapa exige código"},
	"journal_reflection": {"level": "partial", "engine": "descoberta ou flag; não há tela de reflexão"},
	"help_npc": {"level": "partial", "engine": "escolha de diálogo com evento custom; ajuda física exige código"},
	"assemble_clues": {"level": "partial", "engine": "vários eventos + flag; não há interface de pistas"},
	"visit_area": {"level": "data_only", "engine": "área da região (areas) -> location_reached; outra região -> region_entered"},
	"organize": {"level": "needs_code", "engine": "falta mecânica de organizar/quebra-cabeça"},
	"collect_item": {"level": "data_only", "engine": "itens no chão (pickups) + gatilho inventory/condition; entrega com take/give no diálogo"},
}
const SUPPORT_ORDER := ["data_only", "partial", "needs_code", "unknown"]
## Contexto do catálogo -> região que existe no jogo.
const REGION_HINTS := {"Canaã — aldeia fictícia": "canaan_village", "Caminhos de Canaã": "canaan_village"}

var catalog := BibleCatalog.new()
var episodes: Array = []
var by_id: Dictionary = {}
var errors := PackedStringArray()
var _regions: Dictionary = {}
var _items: Dictionary = {}
var _collectible_sets: Dictionary = {}
var _book_by_name: Dictionary = {}


func _init() -> void:
	catalog.load_all()
	for id in catalog.books:
		_book_by_name[String(catalog.books[id].name)] = id
	var errs := PackedStringArray()
	for r in JsonUtil.read_collection("res://data/regions", "regions", errs):
		_regions[r.id] = r
	for it in JsonUtil.read_collection("res://data/items", "items", errs):
		_items[it.id] = it
	for s in JsonUtil.read_collection("res://data/collectibles", "sets", errs):
		_collectible_sets[s.id] = s


func load_episodes() -> bool:
	episodes.clear()
	by_id.clear()
	errors.clear()
	if not FileAccess.file_exists(EPISODES_PATH):
		errors.append("%s não existe (rode: factory import-seed)" % EPISODES_PATH)
		return false
	var data: Variant = JsonUtil.read_file(EPISODES_PATH, errors)
	if not (data is Dictionary) or not (data.get("episodes") is Array):
		errors.append("%s: esperado objeto com \"episodes\"" % EPISODES_PATH)
		return false
	for ep in data.episodes:
		episodes.append(ep)
		by_id[ep.id] = ep
	return true


func save_episodes() -> Error:
	var out := {
		"_comment": "Catálogo de produção da fábrica de missões. Gerado por tools/factory.gd a partir do catálogo-semente; o campo status só muda por 'factory set-status' (gates). Nada aqui é conteúdo publicado.",
		"seed": SEED_PATH,
		"statuses": STATUSES,
		"episodes": episodes,
	}
	var f := FileAccess.open(EPISODES_PATH, FileAccess.WRITE)
	if f == null:
		return FileAccess.get_open_error()
	f.store_string(JSON.stringify(out, "\t", false) + "\n")
	return OK


# --- Importação do catálogo-semente --------------------------------------------

## Cria ou atualiza episodes.json. Campos editoriais (status, histórico, vínculo
## com o jogo, conferência de referências) de episódios já existentes são preservados.
func import_seed(seed_path := SEED_PATH) -> int:
	var seed: Variant = JsonUtil.read_file(seed_path, errors)
	if not (seed is Dictionary) or not (seed.get("items") is Array):
		errors.append("%s: catálogo-semente inválido" % seed_path)
		return 0
	if FileAccess.file_exists(EPISODES_PATH):
		load_episodes()
	var today := Time.get_date_string_from_system()
	var out: Array = []
	for item in seed.items:
		var prev: Dictionary = by_id.get(item.id, {})
		var ep := episode_from_seed(item)
		if prev.is_empty():
			ep["status"] = "idea"
			ep["status_history"] = [{"status": "idea", "date": today, "by": "factory import-seed", "note": "Importado do catálogo-semente; não implementado nem validado."}]
			ep["game"] = {}
			ep["reference_check"] = {"status": "not_checked"}
		else:
			for k in ["status", "status_history", "game", "reference_check", "notes"]:
				if prev.has(k):
					ep[k] = prev[k]
		out.append(ep)
	episodes = out
	by_id.clear()
	for ep in episodes:
		by_id[ep.id] = ep
	return episodes.size()


func episode_from_seed(item: Dictionary) -> Dictionary:
	var book_name := String(item.get("book", ""))
	var book := String(_book_by_name.get(book_name, ""))
	var norm := normalize_reference(book, String(item.get("reference", "")))
	var objs: Array = []
	for o in item.get("objectives", []):
		var et := String(o.get("event_type", ""))
		objs.append({
			"id": o.get("id", ""), "event_type": et, "target_id": o.get("target_id", ""),
			"description": o.get("description", ""), "target_state": "placeholder",
			"support": EVENT_SUPPORT.get(et, {}).get("level", "unknown"),
		})
	var ctx := String(item.get("region_or_context", ""))
	var ep := {
		"id": item.id,
		"title": item.get("title", ""),
		"testament": item.get("testament", ""),
		"book_name": book_name,
		"book": book,
		"reference_raw": item.get("reference", ""),
		"references": norm.references,
		"chapter_ranges": norm.chapter_ranges,
		"reference_parse_errors": norm.errors,
		"narrative_mode": item.get("narrative_mode", ""),
		"learning_goal": item.get("learning_goal", ""),
		"region_or_context": ctx,
		"region": REGION_HINTS.get(ctx, ""),
		"seed_objectives": objs,
		"chronology_confidence": item.get("chronology", "not_established"),
		"source_validation": item.get("source_validation", "pending_independent_review"),
		"package": EPISODES_DIR.trim_prefix("res://").path_join(String(item.id)),
	}
	ep["estimate"] = estimate(ep)
	return ep


## "26:18–22" -> ["Gen 26:18-22"]; "1–2" -> intervalo de capítulos; "1–2; 38–42" -> dois intervalos.
func normalize_reference(book: String, raw: String) -> Dictionary:
	var out := {"references": [], "chapter_ranges": [], "errors": []}
	if book == "" or not catalog.books.has(book):
		out.errors.append("livro desconhecido")
		return out
	var full := RegEx.create_from_string("^(\\d+):(\\d+)(?:-(?:(\\d+):)?(\\d+))?$")
	var chap := RegEx.create_from_string("^(\\d+)(?:-(\\d+))?$")
	for part in raw.replace("–", "-").replace("—", "-").replace(" ", "").split(";", false):
		var m := full.search(part)
		if m:
			out.references.append("%s %s" % [book, part])
			continue
		m = chap.search(part)
		if m:
			var a := int(m.get_string(1))
			var b := int(m.get_string(2)) if m.get_string(2) != "" else a
			out.chapter_ranges.append({"book": book, "from": a, "to": b})
			continue
		out.errors.append("referência ilegível \"%s\"" % part)
	return out


## Esforço estimado pelo que já existe (região, tipos de evento). Não é decisão editorial.
func estimate(ep: Dictionary) -> Dictionary:
	var worst := "data_only"
	var needs: Array[String] = []
	for o in ep.seed_objectives:
		var lvl := String(o.support)
		if SUPPORT_ORDER.find(lvl) > SUPPORT_ORDER.find(worst):
			worst = lvl
		if lvl != "data_only" and not needs.has(String(o.event_type)):
			needs.append(String(o.event_type))
	var region_exists := String(ep.region) != "" and _regions.has(ep.region)
	var difficulty := "low"
	if not region_exists and worst == "needs_code":
		difficulty = "high"
	elif not region_exists or worst == "needs_code":
		difficulty = "medium"
	return {"mechanics": worst, "events_needing_work": needs, "region_exists": region_exists,
		"new_map_needed": not region_exists, "difficulty": difficulty}


# --- Referências ------------------------------------------------------------------

## Confere livro, capítulo e versículos: contra verse_counts.json e, se `source`
## (versículos do arquivo oficial, ver import_scripture.read_vpl) for dado, contra o texto.
func check_references(ep: Dictionary, source: Dictionary = {}) -> Dictionary:
	var problems: Array = []
	var notes: Array = []
	var unknown_counts: Array = []
	for e in ep.get("reference_parse_errors", []):
		problems.append(e)
	for r in ep.references:
		var p := catalog.parse_reference(r)
		if p.is_empty():
			problems.append("ilegível: " + String(r))
			continue
		var book: Dictionary = catalog.books[p.book]
		if int(p.chapter_end) > int(book.chapters):
			problems.append("%s: capítulo além de %d" % [r, book.chapters])
			continue
		if not source.is_empty():
			var missing: Array[String] = []
			for c in range(int(p.chapter_start), int(p.chapter_end) + 1):
				var first := int(p.verse_start) if c == int(p.chapter_start) else 1
				var last := int(p.verse_end) if c == int(p.chapter_end) else _last_verse(source, p.book, c)
				for v in range(first, last + 1):
					var key := "%s %d:%d" % [p.book, c, v]
					if source.has(key):
						continue
					if v < _last_verse(source, p.book, c):
						notes.append("%s não consta nesta tradução (provável variante textual; o trecho existe)" % key)
					else:
						missing.append(key)
			if not missing.is_empty():
				problems.append("%s: versículos ausentes no texto oficial %s" % [r, missing])
		else:
			for err in catalog.validate_reference(ep.id, r):
				if err.contains("sem contagem"):
					unknown_counts.append(r)
				else:
					problems.append(err)
	for cr in ep.chapter_ranges:
		var book: Dictionary = catalog.books.get(cr.book, {})
		if int(cr.to) > int(book.get("chapters", 0)) or int(cr.from) < 1 or int(cr.to) < int(cr.from):
			problems.append("capítulos %s %d-%d fora de %s (%d)" % [cr.book, cr.from, cr.to, book.get("name", "?"), book.get("chapters", 0)])
		elif not source.is_empty():
			for c in range(int(cr.from), int(cr.to) + 1):
				if not source.has("%s %d:1" % [cr.book, c]):
					problems.append("%s %d ausente no texto oficial" % [cr.book, c])
	var status := "ok"
	if not problems.is_empty():
		status = "errors"
	elif not unknown_counts.is_empty():
		status = "count_unknown"
	elif not notes.is_empty():
		status = "ok_with_notes"
	return {"status": status, "problems": problems, "notes": notes, "count_unknown": unknown_counts,
		"source": "texto oficial" if not source.is_empty() else "verse_counts.json",
		"date": Time.get_date_string_from_system()}


static func _last_verse(source: Dictionary, book: String, chapter: int) -> int:
	var last := 1
	var gap := 0
	var v := 1
	while gap < 4:
		v += 1
		if source.has("%s %d:%d" % [book, chapter, v]):
			last = v
			gap = 0
		else:
			gap += 1
	return last


# --- Alvos reais no mapa ------------------------------------------------------------

## Alvos que existem de fato na região: NPCs e interações da cena do mapa mais
## o que data/regions declara (NPCs, examináveis, itens no chão, áreas, saídas).
func region_targets(region_id: String) -> Dictionary:
	var out := {"npc": {}, "dialogue": {}, "examinable": {}, "pickup": {}, "area": {}, "exit": {}, "map_scene": "", "error": ""}
	var region: Dictionary = _regions.get(region_id, {})
	if region.is_empty():
		out.error = "região \"%s\" não existe em data/regions" % region_id
		return out
	out.map_scene = String(region.get("map_scene", ""))
	if not FileAccess.file_exists(out.map_scene):
		out.error = "cena do mapa não encontrada: %s" % out.map_scene
		return out
	var props := {}
	scan_scene(out.map_scene, "", props, 0)
	for path in props:
		var p: Dictionary = props[path]
		if p.has("character_id"):
			out.npc[p.character_id] = path
		if p.has("dialogue_id") and p.dialogue_id != "":
			out.dialogue[p.dialogue_id] = path
	for n in region.get("npcs", []):
		out.npc[String(n.get("character", n.id))] = "data:npcs/" + String(n.id)
	for e in region.get("examinables", []):
		out.examinable[String(e.id)] = "data:examinables/" + String(e.id)
		if String(e.get("dialogue", "")) != "":
			out.dialogue[String(e.dialogue)] = "data:examinables/" + String(e.id)
	for k in [["pickups", "pickup"], ["areas", "area"], ["exits", "exit"]]:
		for d in region.get(k[0], []):
			out[k[1]][String(d.id)] = "data:%s/%s" % [k[0], d.id]
	return out


## Lê o .tscn como texto (sem carregar scripts, que dependem dos autoloads) e junta
## character_id/dialogue_id por caminho de nó, seguindo cenas instanciadas e sobrescritas.
static func scan_scene(path: String, prefix: String, props: Dictionary, depth: int) -> void:
	if depth > 6:
		return
	var ext := {}
	var current := ""
	var header := RegEx.create_from_string("^\\[node name=\"([^\"]+)\"(.*)\\]")
	var attr := RegEx.create_from_string("(parent|instance)=(?:\"([^\"]*)\"|ExtResource\\(\"([^\"]+)\"\\))")
	var res := RegEx.create_from_string("^\\[ext_resource [^\\]]*path=\"([^\"]+)\"[^\\]]*id=\"([^\"]+)\"")
	var prop := RegEx.create_from_string("^(character_id|dialogue_id) = \"([^\"]*)\"")
	for line in FileAccess.get_file_as_string(path).split("\n"):
		var m := res.search(line)
		if m:
			ext[m.get_string(2)] = m.get_string(1)
			continue
		m = header.search(line)
		if m:
			var parent := "-"
			var instance := ""
			for a in attr.search_all(m.get_string(2)):
				if a.get_string(1) == "parent":
					parent = a.get_string(2)
				else:
					instance = String(ext.get(a.get_string(3), ""))
			if parent == "-":
				current = prefix
			elif parent == ".":
				current = prefix.path_join(m.get_string(1)) if prefix != "" else m.get_string(1)
			else:
				var base := prefix.path_join(parent) if prefix != "" else parent
				current = base.path_join(m.get_string(1))
			if instance.ends_with(".tscn"):
				scan_scene(instance, current, props, depth + 1)
			continue
		m = prop.search(line)
		if m:
			if not props.has(current):
				props[current] = {}
			props[current][m.get_string(1)] = m.get_string(2)


# --- Gates ------------------------------------------------------------------------

func package_path(ep: Dictionary, file := "") -> String:
	var dir := "res://" + String(ep.package)
	return dir if file == "" else dir.path_join(file)


func read_package_json(ep: Dictionary, file: String) -> Dictionary:
	var path := package_path(ep, file)
	if not FileAccess.file_exists(path):
		return {}
	var data: Variant = JsonUtil.read_file(path, PackedStringArray())
	return data if data is Dictionary else {}


## Tudo o que impede o episódio de estar no estado `status` (requisitos cumulativos).
func gate_errors(ep: Dictionary, status: String) -> PackedStringArray:
	var out := PackedStringArray()
	if not (status in STATUSES):
		return PackedStringArray(["estado inválido \"%s\"" % status])
	if status == "blocked" or status == "idea":
		return out
	var upto := STATUSES.find(status)
	for i in range(1, upto + 1):
		for f in GATE_FILES.get(STATUSES[i], []):
			var path := package_path(ep, f)
			if not FileAccess.file_exists(path) or FileAccess.get_file_as_string(path).strip_edges() == "":
				out.append("falta %s (exigido a partir de \"%s\")" % [path.trim_prefix("res://"), STATUSES[i]])
	var game: Dictionary = ep.get("game", {})
	var has_quest := String(game.get("quest_id", "")) != ""
	if upto >= STATUSES.find("designed"):
		if not has_quest and not FileAccess.file_exists(package_path(ep, "quest.proposal.json")):
			out.append("sem quest.proposal.json nem missão do jogo vinculada")
	if upto >= STATUSES.find("awaiting_biblical_review") and not has_quest:
		for f in ["dialogues.proposal.json", "discoveries.proposal.json"]:
			if not FileAccess.file_exists(package_path(ep, f)):
				out.append("falta %s (conteúdo para revisão)" % f)
	if upto >= STATUSES.find("awaiting_historical_review"):
		var rev := read_package_json(ep, "review.json")
		if String(rev.get("biblical", {}).get("verdict", "pending")) == "pending":
			out.append("review.json: revisão bíblica ainda não registrada")
	if upto >= STATUSES.find("approved_for_implementation"):
		out.append_array(review_errors(read_package_json(ep, "review.json")))
	if upto >= STATUSES.find("implemented"):
		out.append_array(implementation_errors(ep))
	if upto >= STATUSES.find("tested"):
		var rep := read_package_json(ep, "test_report.json")
		if String(rep.get("overall", "")) != "passed":
			out.append("test_report.json: overall deve ser \"passed\" (está \"%s\")" % rep.get("overall", ""))
	if upto >= STATUSES.find("published"):
		var q := QuestDatabase.new()
		q.load_dir()
		var quest := q.get_quest(String(game.get("quest_id", "")))
		if ContentPolicy.status_of(quest) != "approved":
			out.append("missão sem aprovação humana (verification.status = approved com revisor)")
		var human: Dictionary = read_package_json(ep, "review.json").get("human", {})
		var who := String(human.get("approved_by", ""))
		if who == "" or ContentPolicy.is_ai_reviewer(who):
			out.append("review.json: human.approved_by precisa ser uma pessoa")
	return out


func review_errors(rev: Dictionary) -> PackedStringArray:
	var out := PackedStringArray()
	if rev.is_empty():
		return PackedStringArray(["review.json ausente ou inválido"])
	for part in ["biblical", "historical"]:
		var v := String(rev.get(part, {}).get("verdict", "pending"))
		if v != REVIEW_OK:
			out.append("review.json: %s.verdict = \"%s\" (precisa \"%s\")" % [part, v, REVIEW_OK])
	for f in rev.get("findings", []):
		if String(f.get("severity", "")) == "critical" and String(f.get("status", "open")) != "resolved":
			out.append("achado crítico em aberto: %s" % f.get("id", "?"))
	return out


func implementation_errors(ep: Dictionary) -> PackedStringArray:
	var out := PackedStringArray()
	var qid := String(ep.get("game", {}).get("quest_id", ""))
	if qid == "":
		return PackedStringArray(["nenhuma missão do jogo vinculada (game.quest_id)"])
	var qdb := QuestDatabase.new()
	qdb.load_dir()
	var q := qdb.get_quest(qid)
	if q.is_empty():
		return PackedStringArray(["missão \"%s\" não existe em data/quests" % qid])
	out.append_array(QuestDatabase.validate(q))
	out.append_array(quest_world_errors(q))
	for r in q.references:
		if catalog.verses_of(r).is_empty() and not catalog.scripture.is_empty():
			out.append("%s: sem texto bíblico importado para %s" % [qid, r])
	return out


## Vínculos da missão com o mundo: alvos na região certa (mapas futuros não
## contam), itens, conjuntos de colecionáveis e escolhas que levam a um desfecho.
func quest_world_errors(q: Dictionary) -> PackedStringArray:
	var out := PackedStringArray()
	var qid := String(q.get("id", "?"))
	var cache := {}
	for o in q.get("objectives", []):
		for t in o.get("targets", []):
			var type := String(t.get("type", ""))
			if type == "ui":
				continue
			if type == "region":
				if not _regions.has(t.id):
					out.append("%s/%s: região \"%s\" ainda não existe (missão fica em planejamento)" % [qid, o.id, t.id])
				continue
			var rid := String(t.get("region", o.get("region", q.get("region", ""))))
			if not cache.has(rid):
				cache[rid] = region_targets(rid)
			var rt: Dictionary = cache[rid]
			if rt.error != "":
				out.append("%s/%s: %s" % [qid, o.id, rt.error])
			elif not rt.get(type, {}).has(t.id):
				out.append("%s/%s: alvo %s \"%s\" não existe na região %s" % [qid, o.id, type, t.id, rid])
		var trig: Dictionary = o.get("complete_on", {})
		match String(trig.get("event", "")):
			"region_entered", "region_unlocked":
				if not _regions.has(trig.id):
					out.append("%s/%s: região \"%s\" não existe" % [qid, o.id, trig.id])
			"inventory", "item_collected", "item_received", "item_delivered":
				if not _items.has(trig.id):
					out.append("%s/%s: item \"%s\" não existe" % [qid, o.id, trig.id])
			"collection", "collection_completed":
				if not _collectible_sets.has(trig.id):
					out.append("%s/%s: conjunto de colecionáveis \"%s\" não existe" % [qid, o.id, trig.id])
	for r in q.get("rewards", {}).get("items", []):
		if not _items.has(String(r.get("item", ""))):
			out.append("%s: recompensa cita item inexistente \"%s\"" % [qid, r.get("item", "")])
	var decisions := _dialogue_decisions()
	for v in q.get("completion", {}).get("variants", []):
		var c: Variant = v.get("if")
		if c is Dictionary and c.has("choice") and c.has("option"):
			if not decisions.has("%s=%s" % [c.choice, c.option]):
				out.append("%s: desfecho \"%s=%s\" não é produzido por nenhuma escolha de diálogo" % [qid, c.choice, c.option])
	return out


func _dialogue_decisions() -> Dictionary:
	var out := {}
	var db := DialogueDatabase.new()
	db.load_dir("res://data/dialogues")
	for d in db.dialogues.values():
		for n in d.get("nodes", {}).values():
			for e in [n] + Array(n.get("choices", [])):
				var dec: Variant = e.get("decision")
				if dec is Dictionary:
					out["%s=%s" % [dec.get("id", ""), dec.get("option", "")]] = true
	return out


func set_status(id: String, status: String, by: String, note: String) -> PackedStringArray:
	var ep: Dictionary = by_id.get(id, {})
	if ep.is_empty():
		return PackedStringArray(["episódio \"%s\" não existe" % id])
	if status == "blocked" and note.strip_edges() == "":
		return PackedStringArray(["bloquear exige uma nota com o motivo"])
	var errs := gate_errors(ep, status)
	if not errs.is_empty():
		return errs
	ep.status = status
	ep.status_history.append({"status": status, "date": Time.get_date_string_from_system(), "by": by, "note": note})
	return PackedStringArray()


## Inconsistências do catálogo: estados inválidos ou episódios cujo estado atual não passa nos gates.
func audit() -> PackedStringArray:
	var out := PackedStringArray()
	var ids := {}
	for ep in episodes:
		if ids.has(ep.id):
			out.append("id duplicado: %s" % ep.id)
		ids[ep.id] = true
		if not (String(ep.get("status", "")) in STATUSES):
			out.append("%s: estado inválido \"%s\"" % [ep.id, ep.get("status")])
			continue
		for e in gate_errors(ep, ep.status):
			out.append("%s (%s): %s" % [ep.id, ep.status, e])
	return out


# --- Áudio ------------------------------------------------------------------------

const VOICE_PROFILES_PATH := "res://production/audio/voice_profiles.json"
const VOICE_DIR := "res://assets/audio/voice"
const AUDIO_LANG := "pt-BR"
## Igual a DialogueManager.line_text: acima disso a fala mostra o "text" do nó.
const DIALOGUE_MAX_VERSES := 3

## Falas do episódio (diálogos e passos de apresentação ligados em game.*), com id
## estável "<diálogo>/<nó>" e hash de texto + idioma + perfil de voz. Preserva o
## trabalho do manifesto anterior quando o hash não mudou; se mudou, o áudio fica "stale".
func audio_manifest(ep: Dictionary) -> Dictionary:
	var game: Dictionary = ep.get("game", {})
	var dialogues := DialogueDatabase.new()
	dialogues.load_dir("res://data/dialogues")
	var profiles: Dictionary = {}
	var pdata: Variant = JsonUtil.read_file(VOICE_PROFILES_PATH, PackedStringArray()) if FileAccess.file_exists(VOICE_PROFILES_PATH) else {}
	if pdata is Dictionary:
		profiles = pdata.get("profiles", {})
	var prev := {}
	for l in read_package_json(ep, "audio_manifest.json").get("lines", []):
		prev[l.line_id] = l
	var lines: Array = []
	var chars := 0
	for did in game.get("dialogues", []):
		var d: Dictionary = dialogues.dialogues.get(did, {})
		if d.is_empty():
			errors.append("diálogo \"%s\" não existe" % did)
			continue
		for node_id in d.nodes:
			var n: Dictionary = d.nodes[node_id]
			var speaker := String(n.get("speaker", "narrator"))
			var kind := "narration" if speaker == "narrator" else "fictional_dialogue"
			var text := _plain(String(n.text))
			var scripture := String(n.get("scripture", ""))
			var vs: Array = catalog.verses_of(scripture) if scripture != "" else []
			if not vs.is_empty() and vs.size() <= DIALOGUE_MAX_VERSES:
				kind = "scripture"
				text = " ".join(vs.map(func(v): return String(v.text)))
			else:
				scripture = ""
			lines.append(_audio_line("%s/%s" % [did, node_id], speaker, kind, text, scripture, profiles, prev))
	for pid in game.get("presentations", []):
		var pr: Dictionary = catalog.presentations.get(pid, {})
		var steps: Array = pr.get("steps", [])
		for i in steps.size():
			var st: Dictionary = steps[i]
			var scripture := String(st.get("scripture", ""))
			if scripture != "" and not catalog.verses_of(scripture).is_empty():
				var t := " ".join(catalog.verses_of(scripture).map(func(v): return String(v.text)))
				lines.append(_audio_line("%s/%d_scripture" % [pid, i + 1], "narrator", "scripture", t, scripture, profiles, prev))
			lines.append(_audio_line("%s/%d_note" % [pid, i + 1], "narrator", "narration", _plain(String(st.get("text", ""))), "", profiles, prev))
	for l in lines:
		chars += String(l.text).length()
	return {
		"_comment": "Gerado por tools/factory.gd audio-manifest. Não edite text/line_id/hash à mão: mude o texto no jogo e gere de novo. emotion, pronunciation e target_seconds são do audio-producer.",
		"episode": ep.id,
		"language": AUDIO_LANG,
		"generated": Time.get_date_string_from_system(),
		"provider": "none",
		"budget_approved": false,
		"subtitles": "sempre: a caixa de diálogo mostra o texto de toda fala",
		"total_characters": chars,
		"lines": lines,
	}


func _audio_line(line_id: String, speaker: String, kind: String, text: String, scripture: String, profiles: Dictionary, prev: Dictionary) -> Dictionary:
	var profile := String(profiles.get(speaker, {}).get("profile_id", speaker))
	var hash := ("%s|%s|%s|v1" % [text, AUDIO_LANG, profile]).sha256_text()
	var file := VOICE_DIR.path_join(line_id.replace("/", "__") + ".ogg")
	var line := {"line_id": line_id, "speaker": speaker, "voice_profile": profile, "kind": kind,
		"text": text, "hash": hash, "file": file, "status": "pending",
		"emotion": "", "pronunciation": {}, "target_seconds": snappedf(text.length() / 14.0, 0.5),
		"rights": {"provider": "", "commercial_license": "pending", "real_person_voice": false}}
	if scripture != "":
		line["scripture"] = scripture
		line["translation"] = String(catalog.translation.get("id", ""))
	if not bool(profiles.get(speaker, {}).get("voiced", true)):
		line.status = "text_only"
		return line
	var old: Dictionary = prev.get(line_id, {})
	if not old.is_empty():
		for k in ["emotion", "pronunciation", "target_seconds"]:
			if old.has(k) and str(old[k]) != "" and str(old[k]) != "{}":
				line[k] = old[k]
		if String(old.get("hash", "")) == hash:
			line.status = old.get("status", "pending")
			line.rights = old.get("rights", line.rights)
		elif String(old.get("status", "")) == "generated":
			line.status = "stale"
	return line


static func _plain(bbcode: String) -> String:
	return RegEx.create_from_string("\\[[^\\]]*\\]").sub(bbcode, "", true).strip_edges()


# --- Seleção e relatório -------------------------------------------------------------

## Candidatos para o próximo lote: região existente, mecânicas já suportadas, livros com contexto pronto.
func candidates(limit := 5) -> Array:
	var scored: Array = []
	for ep in episodes:
		if String(ep.status) != "idea":
			continue
		var s := 0
		var why: Array[String] = []
		if ep.estimate.region_exists:
			s += 4
			why.append("região já existe")
		match String(ep.estimate.mechanics):
			"data_only":
				s += 3
				why.append("só dados")
			"partial":
				s += 1
				why.append("mecânica parcial")
		var era_ready: bool = ep.book == "Gen"
		if era_ready:
			s += 1
			why.append("época dos patriarcas já catalogada")
		scored.append({"id": ep.id, "score": s, "why": ", ".join(why), "difficulty": ep.estimate.difficulty})
	scored.sort_custom(func(a, b): return a.score > b.score or (a.score == b.score and a.id < b.id))
	return scored.slice(0, limit)


func filter(criteria: Dictionary) -> Array:
	var out: Array = []
	for ep in episodes:
		var ok := true
		for k in criteria:
			var want := String(criteria[k]).to_lower()
			var have := ""
			match k:
				"difficulty", "mechanics":
					have = String(ep.estimate.get(k, ""))
				"support":
					have = ",".join(ep.seed_objectives.map(func(o): return String(o.support)))
					ok = ok and have.contains(want)
					continue
				"event":
					have = ",".join(ep.seed_objectives.map(func(o): return String(o.event_type)))
					ok = ok and have.contains(want)
					continue
				"quest":
					have = "yes" if String(ep.get("game", {}).get("quest_id", "")) != "" else "no"
				_:
					have = String(ep.get(k, ""))
			ok = ok and have.to_lower() == want
		if ok:
			out.append(ep)
	return out


func status_counts() -> Dictionary:
	var c := {}
	for s in STATUSES:
		c[s] = 0
	for ep in episodes:
		c[ep.status] = int(c.get(ep.status, 0)) + 1
	return c
