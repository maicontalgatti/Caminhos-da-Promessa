extends SceneTree
## Relatório de conteúdo: erros de dados (falham) e situação de revisão (informativa).
##   godot --headless --path . --script res://tools/validate_content.gd
## Sai com 1 se houver erro de dados; conteúdo aguardando revisão não é erro,
## mas aparece listado porque não pode ir para o canal público.

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

	print("\n== Validação de conteúdo (canal configurado: %s) ==" % ContentPolicy.channel())
	_section("Catálogo bíblico", catalog.errors)
	_section("Diálogos", dialogues.errors)
	_section("Personagens e regiões", errs)
	var qerrs := quests.errors.duplicate()
	for id in quests.order:
		qerrs.append_array(quests.validate_links(quests.get_quest(id), catalog, dialogues.dialogues, characters, regions))
	_section("Missões", qerrs)

	print("\n-- Situação de revisão --")
	var groups := {
		"Missões": quests.quests, "Descobertas": catalog.discoveries, "Apresentações": catalog.presentations,
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


func _section(title: String, list: PackedStringArray) -> void:
	print("\n-- %s: %s --" % [title, "ok" if list.is_empty() else "%d erro(s)" % list.size()])
	for e in list:
		print("  ERRO ", e)
	_errors += list.size()
