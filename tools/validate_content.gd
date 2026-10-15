extends SceneTree
## Relatório de conteúdo: erros de dados (falham) e situação de revisão (informativa).
##   godot --headless --path . --script res://tools/validate_content.gd
## Sai com 1 se houver erro de dados; conteúdo aguardando revisão não é erro,
## mas aparece listado porque não pode ir para o canal público.

const MusicRules := preload("res://scripts/core/music_rules.gd")

var _errors := 0


func _initialize() -> void:
	var catalog := BibleCatalog.new()
	catalog.load_all()
	var dialogues := DialogueDatabase.new()
	dialogues.load_dir("res://data/dialogues")
	var errs := PackedStringArray()
	var characters := {}
	for c in JsonUtil.read_collection("res://data/characters", "characters", errs):
		characters[c.id] = c
	var regions := {}
	for r in JsonUtil.read_collection("res://data/regions", "regions", errs):
		regions[r.id] = r
	var quests := QuestDatabase.new()
	quests.load_dir()
	var scenes := SceneDatabase.new()
	scenes.load_dir()

	print("\n== Validação de conteúdo (canal configurado: %s) ==" % ContentPolicy.channel())
	_section("Catálogo bíblico", catalog.errors)
	_section("Diálogos", dialogues.errors)
	_section("Personagens e regiões", errs)
	var qerrs := quests.errors.duplicate()
	for id in quests.order:
		qerrs.append_array(quests.validate_links(quests.get_quest(id), catalog, dialogues.dialogues, characters, regions, scenes.scenes))
	_section("Missões", qerrs)
	var serrs := scenes.errors.duplicate()
	var sounds := SceneDatabase.manifest_sounds()
	for id in scenes.order:
		serrs.append_array(SceneDatabase.validate_links(scenes.get_scene(id), catalog, characters, regions, sounds))
	for d in dialogues.dialogues.values():
		for sid in DialogueDatabase.referenced_scenes(d):
			if not scenes.has_scene(sid):
				serrs.append("diálogo %s: ação pede cena inexistente \"%s\"" % [d.id, sid])
	_section("Cenas dirigidas (%d)" % scenes.order.size(), serrs)
	var werrs := PackedStringArray()
	for rid in regions:
		werrs.append_array(WorldSchema.validate_region(regions[rid]))
	for x in JsonUtil.read_collection("res://data/world", "experiences", werrs):
		werrs.append_array(WorldSchema.validate_experience(x, regions))
	_section("Mundo: luz, passagens e experiências", werrs)
	var music: Variant = JsonUtil.read_file("res://data/audio/music.json", PackedStringArray())
	var prologues: Array = []
	for p in JsonUtil.read_collection("res://data/story", "prologues", PackedStringArray()):
		prologues.append(String(p.get("id", "")))
	var known := {"regions": regions.keys(), "quests": quests.order, "scenes": scenes.order,
		"presentations": catalog.presentations.keys(), "prologues": prologues, "contexts": ["scripture_map"]}
	_section("Música temática", MusicRules.validate_manifest(music, known, Time.get_date_dict_from_system().year)
		if music is Dictionary else PackedStringArray(["data/audio/music.json ausente ou inválido"]))
	_section("Feira: mercadores, vendas e coleta renovável", _market_errors(dialogues, characters, regions))

	print("\n-- Situação de revisão --")
	var groups := {
		"Missões": quests.quests, "Cenas": scenes.scenes, "Descobertas": catalog.discoveries, "Apresentações": catalog.presentations,
		"Histórias": catalog.stories, "Épocas": catalog.eras, "Acontecimentos": catalog.events,
		"Lugares": catalog.places, "Pessoas": catalog.people,
	}
	var not_public := 0
	for g in groups:
		var count := {}
		for s in ContentPolicy.STATUSES:
			count[s] = 0
		for item in groups[g].values():
			count[ContentPolicy.status_of(item)] += 1
			if not ContentPolicy.is_visible(item, "public"):
				not_public += 1
		var parts: Array[String] = []
		for s in ContentPolicy.STATUSES:
			parts.append("%s: %d" % [ContentPolicy.status_label(s), count[s]])
		print("  %-14s %s" % [g, " | ".join(parts)])
	var tid := String(catalog.translation.get("id", ""))
	if tid != "":
		var texts: Variant = JsonUtil.read_file(BibleCatalog.TEXTS_DIR.path_join(tid + ".json"), PackedStringArray())
		var st := ContentPolicy.status_of(texts) if texts is Dictionary else "draft"
		print("  %-14s %s (%s): %d versículos, %s" % ["Texto bíblico", catalog.translation.get("name", tid),
			catalog.translation.get("license", "?"), catalog.scripture.size(), ContentPolicy.status_label(st)])
	print("\n  Itens que ainda NÃO podem ir ao canal público (sem aprovação humana): %d" % not_public)
	for id in quests.order:
		var q := quests.get_quest(id)
		if not ContentPolicy.is_visible(q, "public"):
			print("    missão %s: %s" % [id, ContentPolicy.status_label(ContentPolicy.status_of(q))])
	print("\n== %s ==" % ("SEM ERROS DE DADOS" if _errors == 0 else "%d ERRO(S) DE DADOS" % _errors))
	quit(1 if _errors > 0 else 0)


## Feira (ADR-030): ações {"market": id} apontam para mercadores do catálogo; cada
## mercador é um personagem cuja fala abre a própria feira; itens renováveis
## do mapa existem e são vendáveis.
func _market_errors(dialogues: DialogueDatabase, characters: Dictionary, regions: Dictionary) -> PackedStringArray:
	var out := PackedStringArray()
	var m: Variant = JsonUtil.read_file("res://data/market/market.json", out)
	if not (m is Dictionary):
		out.append("market.json inválido")
		return out
	var items := {}
	for it in JsonUtil.read_collection("res://data/items", "items", out):
		items[it.id] = it
	var merchants := {}
	for mm in m.get("merchants", []):
		merchants[String(mm.get("id", ""))] = mm
	var sales := {}
	for sale in m.get("sales", []):
		sales[String(sale.get("item", ""))] = true
		if not items.has(String(sale.get("item", ""))):
			out.append("venda de item inexistente %s" % sale.get("item"))
	var opened := {}
	for d in dialogues.dialogues.values():
		for mid in DialogueDatabase.referenced_merchants(d):
			opened[mid] = true
			if not merchants.has(mid):
				out.append("diálogo %s: ação pede mercador inexistente \"%s\"" % [d.id, mid])
	for mid in merchants:
		var c: Dictionary = characters.get(mid, {})
		if c.is_empty():
			out.append("mercador %s sem personagem em data/characters" % mid)
		elif not opened.has(mid) or not DialogueDatabase.referenced_merchants(dialogues.dialogues.get(String(c.get("dialogue_id", "")), {})).has(mid):
			out.append("mercador %s: a fala dele não abre a própria feira" % mid)
		if not regions.has(String(merchants[mid].get("region", ""))):
			out.append("mercador %s em região inexistente" % mid)
	for rid in regions:
		for p in regions[rid].get("pickups", []):
			if p.get("renewable", false) and not sales.has(String(p.get("item", ""))):
				out.append("região %s: item renovável %s não é vendável na feira" % [rid, p.get("id")])
	return out


func _section(title: String, list: PackedStringArray) -> void:
	print("\n-- %s: %s --" % [title, "ok" if list.is_empty() else "%d erro(s)" % list.size()])
	for e in list:
		print("  ERRO ", e)
	_errors += list.size()
