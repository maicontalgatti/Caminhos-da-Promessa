extends Node
## Testes automatizados do protótipo (rodam com os autoloads ativos).
##   godot --headless --path . res://tests/test_runner.tscn
## Sai com código 0 se tudo passar, 1 caso contrário.

const TEST_SAVE := "user://test_savegame.json"
const TEST_SETTINGS := "user://test_runner_settings.cfg"
const GAME_SCENE := "res://scenes/core/game.tscn"

var _passed := 0
var _failed := 0


func _ready() -> void:
	SaveManager.save_path = TEST_SAVE
	SaveManager.delete_save()
	Settings.path = TEST_SETTINGS
	await _run_all()
	SaveManager.delete_save()
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SETTINGS))
	Settings.path = Settings.PATH
	print("\n==== %d passaram, %d falharam ====" % [_passed, _failed])
	AudioManager.shutdown()
	await get_tree().create_timer(0.2).timeout
	get_tree().quit(1 if _failed > 0 else 0)


func check(cond: bool, label: String) -> void:
	if cond:
		_passed += 1
		print("  ok   ", label)
	else:
		_failed += 1
		printerr("  FAIL ", label)


func _run_all() -> void:
	print("\n[entrada]")
	_test_input_map()
	print("\n[dados]")
	_test_game_data()
	_test_dialogues()
	_test_prop_scenes()
	_test_bible_catalog()
	print("\n[cronologia e referências]")
	_test_chronology()
	_test_references()
	_test_scripture()
	_test_content_policy()
	print("\n[missões]")
	_test_quest_data()
	_test_quest_targets_in_map()
	_test_quest_flow()
	_test_old_save_wells()
	_test_wells_water_save_load()
	_test_journal_content()
	_test_quest_editor_model()
	print("\n[fábrica de missões]")
	_test_factory()
	print("\n[save]")
	_test_save_manager()
	_test_save_slots()
	_test_input_bindings()
	_test_traveler_look()
	_test_craft()
	_test_save_v2()
	print("\n[mundo: regiões, viagem e save v3]")
	var wt_script: GDScript = load("res://tests/world_tests.gd")
	check(wt_script != null and wt_script.can_instantiate(), "tests/world_tests.gd compila")
	if wt_script == null or not wt_script.can_instantiate():
		return
	var wt = wt_script.new(self)
	wt.test_region_data()
	await wt.test_entries_free()
	wt.test_save_v3_migration()
	wt.test_inventory()
	wt.test_supplies_quest()
	wt.test_supplies_resume()
	wt.test_families_outcomes()
	wt.test_quests_across_regions()
	wt.test_main_quest_flow()
	await wt.test_travel()
	await wt.test_day_cycle()
	await wt.test_interiors()
	await wt.test_pickups_and_screens()
	await wt.test_market_in_game()
	print("\n[cenas dirigidas, luz por estado e experiências]")
	var st_script: GDScript = load("res://tests/scene_tests.gd")
	check(st_script != null and st_script.can_instantiate(), "tests/scene_tests.gd compila")
	if st_script != null and st_script.can_instantiate():
		var st = st_script.new(self)
		st.test_data()
		st.test_world_schema()
		st.test_experiences()
		await st.test_play_and_skip()
		await st.test_lighting()
		await st.test_scripture_map_and_passage()
	print("\n[experiências: José no Egito, Mar, Rute, Pastores]")
	var xt_script: GDScript = load("res://tests/experience_content_tests.gd")
	check(xt_script != null and xt_script.can_instantiate(), "tests/experience_content_tests.gd compila")
	if xt_script != null and xt_script.can_instantiate():
		var xt = xt_script.new(self)
		xt.test_experiences_available_and_chained()
		xt.test_quests_and_links()
		xt.test_scenes()
		xt.test_region_targets()
	print("\n[áudio]")
	var at_script: GDScript = load("res://tests/audio_tests.gd")
	check(at_script != null and at_script.can_instantiate(), "tests/audio_tests.gd compila")
	if at_script != null and at_script.can_instantiate():
		var at = at_script.new(self)
		at.test_manifest_and_files()
		at.test_mappings()
		at.test_playback_rules()
		await at.test_events()
		await at.test_ui_buttons()
		await at.test_dialogue_and_interaction()
		await at.test_settings()
		await at.test_in_game()
	print("\n[música temática]")
	var mt_script: GDScript = load("res://tests/music_tests.gd")
	check(mt_script != null and mt_script.can_instantiate(), "tests/music_tests.gd compila")
	if mt_script != null and mt_script.can_instantiate():
		var mt = mt_script.new(self)
		mt.test_manifest()
		mt.test_rules_reject()
		mt.test_resolution()
		mt.test_themes_and_shuffle()
		mt.test_playback()
		mt.test_ducking()
		await mt.test_screens_in_game()
	print("\n[gameplay]")
	await _test_gameplay()
	print("\n[menu]")
	await _test_main_menu()


func _test_input_map() -> void:
	for action in ["move_left", "move_right", "move_up", "move_down", "run", "interact", "pause"]:
		check(InputMap.has_action(action) and not InputMap.action_get_events(action).is_empty(),
			"ação de entrada '%s' configurada" % action)


func _test_game_data() -> void:
	check(GameData.errors.is_empty(), "GameData carregado sem erros %s" % [GameData.errors])
	check(GameData.characters.size() >= 5, "personagens carregados (%d)" % GameData.characters.size())
	for id in GameData.characters:
		var c: Dictionary = GameData.characters[id]
		check(DialogueManager.db.has_dialogue(String(c.get("dialogue_id", ""))), "diálogo de '%s' existe" % id)
		check(ResourceLoader.exists(String(c.sprite.sheet)), "folha de sprite de '%s' existe" % id)
	check(not GameData.get_region("canaan_village").is_empty(), "região canaan_village existe")


func _test_dialogues() -> void:
	check(DialogueManager.db.errors.is_empty(), "diálogos válidos %s" % [DialogueManager.db.errors])
	var bad := DialogueDatabase.validate({"id": "x", "start": "a", "nodes": {"a": {"text": "oi", "next": "zz"}}})
	check(not bad.is_empty(), "validador detecta 'next' inexistente")


func _test_prop_scenes() -> void:
	for f in DirAccess.get_files_at("res://scenes/environments"):
		if not f.ends_with(".tscn"):
			continue
		var inst: Node = load("res://scenes/environments/" + f).instantiate()
		for it in inst.find_children("*", "Interactable", true, false):
			var did := String(it.dialogue_id)
			check(did == "" or DialogueManager.db.has_dialogue(did), "%s: diálogo '%s' existe" % [f, did])
		inst.free()


func _test_bible_catalog() -> void:
	var cat := BibleCatalog.new()
	cat.load_all()
	check(cat.errors.is_empty(), "catálogo bíblico sem erros %s" % [cat.errors])
	check(cat.books.size() == 66, "66 livros no catálogo-base (%d)" % cat.books.size())
	var total := 0
	for id in cat.books:
		total += int(cat.books[id].chapters)
	check(total == 1189, "total de capítulos = 1189 (%d)" % total)
	check(cat.stories.size() >= 5, "histórias-piloto carregadas")
	check(cat.format_reference({"book": "Gen", "chapter_start": 37, "verse_start": 12, "chapter_end": 37, "verse_end": 36}) == "Gênesis 37:12-36", "formatação de referência")
	check(not BibleCatalog.is_publishable(cat.stories.get("luke_010_good_samaritan", {})), "história 'pending' não é publicável")
	var bad := cat.validate_reference("t", {"book": "Ruth", "chapter_start": 5, "verse_start": 1, "chapter_end": 5, "verse_end": 2})
	check(not bad.is_empty(), "detecta capítulo inexistente (Rute 5)")


func _test_chronology() -> void:
	check(not Chronology.is_valid_year(0), "ano zero não existe")
	check(Chronology.years_between(-1, 1) == 1, "de 1 a.C. a 1 d.C. passa 1 ano")
	check(Chronology.years_between(-722, -587) == 135, "de 722 a.C. a 587 a.C. passam 135 anos")
	check(Chronology.format_span({"from": -722, "to": -721, "precision": "year", "certainty": "documented"}) == "722/721 a.C.", "ano com dupla possibilidade")
	check(Chronology.format_span({"from": 27, "to": 30, "precision": "year", "certainty": "approximate"}) == "c. 27–30 d.C.", "intervalo aproximado d.C.")
	check(Chronology.format_century(-1000) == "século X a.C." and Chronology.format_century(-1001) == "século XI a.C.", "séculos a.C.")
	check(Chronology.format_span(null) == "cronologia incerta", "sem datação não inventa ano")
	check(not Chronology.validate_span("t", {"from": 0, "to": 10, "precision": "year", "certainty": "approximate"}).is_empty(), "intervalo com ano zero é rejeitado")
	var cat := Bible.catalog
	check(cat.eras.patriarchs.span == null and cat.eras.patriarchs.certainty == "debated", "época dos patriarcas sem ano atribuído")
	for id in cat.events:
		var ev: Dictionary = cat.events[id]
		if ev.era_id == "patriarchs":
			check(ev.date == null, "acontecimento patriarcal '%s' sem data inventada" % id)
	var last := -1
	for era_id in cat.era_order:
		check(int(cat.eras[era_id].order) > last, "épocas em ordem (%s)" % era_id)
		last = int(cat.eras[era_id].order)


func _test_references() -> void:
	var cat := Bible.catalog
	check(cat.validate_reference("t", "Gen 26:18-22").is_empty(), "Gn 26:18-22 válida")
	check(not cat.validate_reference("t", "Gen 26:40").is_empty(), "versículo além do fim do capítulo é rejeitado")
	check(not cat.validate_reference("t", "Xyz 1:1").is_empty(), "livro inexistente é rejeitado")
	check(not cat.validate_reference("t", "Gen 26:22-18").is_empty(), "intervalo invertido é rejeitado")
	check(cat.format_reference("Gen 39:19-40:23") == "Gênesis 39:19 - 40:23", "referência entre capítulos")
	check(cat.format_reference_short("Gen 26:18-22") == "Gn 26:18-22", "referência abreviada")
	for pid in cat.presentations:
		for st in cat.presentations[pid].steps:
			check(String(st.text).length() < 600, "apresentação %s: trecho curto, sem transcrição longa" % pid)


## Texto bíblico importado do arquivo oficial (data/bible/texts), nunca digitado.
func _test_scripture() -> void:
	var cat := Bible.catalog
	var tid := String(ProjectSettings.get_setting(BibleCatalog.TRANSLATION_SETTING, ""))
	check(tid != "" and cat.translation.get("id") == tid, "tradução configurada carregada (%s)" % tid)
	for f in ["name", "abbrev", "license", "credit", "source"]:
		check(String(cat.translation.get(f, "")) != "", "tradução tem \"%s\"" % f)
	var vs := cat.verses_of("Gen 26:18-22")
	check(vs.size() == 5 and vs[0].key == "Gen 26:18" and vs[4].verse == 22, "Gn 26:18-22 tem 5 versículos")
	if tid == "bpm":
		check(String(vs[0].text).begins_with("Isaque cavou novamente os poços"), "Gn 26:18 confere com o arquivo de origem")
	var n39 := int(cat.verse_counts["Gen 39"])
	check(cat.expand_reference("Gen 39:19-40:2").size() == n39 - 18 + 2, "expansão atravessa capítulos")
	check(cat.verses_of("Gen 1:1").is_empty() and Bible.quote("Gen 1:1") == "", "versículo não importado não é citado")
	check(Bible.quote("Gen 26:19-20").contains("26:19") and Bible.quote("Gen 26:19-20").contains("]20[/color]"), "citação numera os versículos")
	check(Bible.quote("Gen 26:12-22", 6) == "", "citação respeita o limite de versículos")
	check(Bible.cite("Gen 26:20").ends_with("(%s)" % cat.translation.abbrev), "citação indica a tradução")
	var missing: Array[String] = []
	for pid in cat.presentations:
		for st in cat.presentations[pid].steps:
			if String(st.get("scripture", "")) != "" and cat.verses_of(st.scripture).is_empty():
				missing.append(String(st.scripture))
	for d in cat.discoveries.values():
		for r in d.references:
			if cat.verses_of(r).is_empty():
				missing.append(String(r))
	for qid in QuestManager.db.order:
		for r in QuestManager.db.get_quest(qid).references:
			if cat.verses_of(r).is_empty():
				missing.append(String(r))
	check(missing.is_empty(), "todas as referências de apresentações, descobertas e missões têm texto %s" % [missing])
	var quoted := 0
	for d in DialogueManager.db.dialogues.values():
		for n in d.nodes.values():
			if n.has("scripture"):
				quoted += 1
				var line := DialogueManager.line_text(n)
				if cat.verses_of(n.scripture).size() > 3:
					check(line == String(n.text), "fala com trecho longo (%s) mostra a nota própria" % n.scripture)
				else:
					check(line != String(n.text) and line.contains(cat.verses_of(n.scripture)[0].text), "fala cita %s" % n.scripture)
	check(quoted >= 3, "diálogos citam trechos bíblicos (%d)" % quoted)
	check(DialogueManager.line_text({"scripture": "Gen 1:1", "text": "(Gênesis 1:1)"}) == "(Gênesis 1:1)", "sem o texto, a fala mostra a referência")


func _test_content_policy() -> void:
	check(not ContentPolicy.validate_verification("t", {"verification": {"status": "approved", "reviewer": "IA"}}).is_empty(), "IA não pode aprovar conteúdo")
	check(not ContentPolicy.validate_verification("t", {"verification": {"status": "reference_checked", "reviewer": ""}}).is_empty(), "referência conferida exige revisor")
	check(ContentPolicy.validate_verification("t", {"verification": {"status": "approved", "reviewer": "Maria Souza"}}).is_empty(), "aprovação com revisor humano")
	var pending := {"verification": {"status": "pending_review"}}
	check(ContentPolicy.is_visible(pending, "prototype") and not ContentPolicy.is_visible(pending, "public"), "conteúdo em revisão só no protótipo")
	check(not ContentPolicy.is_visible({"verification": {"status": "draft"}}, "prototype"), "rascunho nunca aparece")
	var ai_marked := 0
	for d in Bible.catalog.discoveries.values():
		if ContentPolicy.status_of(d) in ContentPolicy.HUMAN_STATUSES:
			ai_marked += 1
	check(ai_marked == 0, "nenhuma descoberta marcada como verificada sem revisor")


func _test_quest_data() -> void:
	var db: QuestDatabase = QuestManager.db
	check(db.errors.is_empty(), "missões válidas %s" % [db.errors])
	check(db.order.has("canaan_wells"), "missão-piloto carregada")
	for id in db.order:
		var errs := db.validate_links(db.get_quest(id), Bible.catalog, DialogueManager.db.dialogues, GameData.characters, GameData.regions)
		check(errs.is_empty(), "vínculos da missão %s %s" % [id, errs])
	var q: Dictionary = db.get_quest("canaan_wells").duplicate(true)
	q.objectives[0].hints = ["só uma"]
	check(not QuestDatabase.validate(q).is_empty(), "validador exige 3 níveis de pista")
	var q2: Dictionary = db.get_quest("canaan_wells").duplicate(true)
	q2.objectives[0].targets = [{"type": "npc", "id": "fantasma"}]
	check(not db.validate_links(q2, Bible.catalog, DialogueManager.db.dialogues, GameData.characters, GameData.regions).is_empty(), "validador detecta alvo inexistente")
	var q3: Dictionary = db.get_quest("canaan_wells").duplicate(true)
	q3.objectives[0].complete_on = {"event": "custom", "id": "evento_que_ninguem_emite"}
	check(not db.validate_links(q3, Bible.catalog, DialogueManager.db.dialogues, GameData.characters, GameData.regions).is_empty(), "validador detecta evento que nenhum diálogo emite")


## Pistas e alvos nunca apontam para algo que não existe no mapa.
func _test_factory() -> void:
	var fc := FactoryCatalog.new()
	check(fc.load_episodes(), "fábrica: production/catalog/episodes.json carrega")
	check(fc.episodes.size() == 78, "fábrica: 78 episódios no catálogo (%d)" % fc.episodes.size())
	check(fc.by_id.size() == fc.episodes.size(), "fábrica: ids únicos")
	var counts := fc.status_counts()
	check(counts.size() == FactoryCatalog.STATUSES.size(), "fábrica: só estados válidos %s" % [counts.keys()])
	check(int(counts.published) == 0, "fábrica: nenhum episódio publicado sem aprovação humana")
	var audit := fc.audit()
	check(audit.is_empty(), "fábrica: estado de cada episódio passa nos gates %s" % [audit])
	for ep in fc.episodes:
		if ep.reference_parse_errors.size() > 0 or (ep.references.is_empty() and ep.chapter_ranges.is_empty()):
			check(false, "fábrica: %s tem referência legível" % ep.id)
	var norm := fc.normalize_reference("Gen", "26:18–22")
	check(norm.references == ["Gen 26:18-22"], "fábrica: normaliza 26:18–22")
	norm = fc.normalize_reference("Ruth", "1–4")
	check(norm.chapter_ranges.size() == 1 and norm.chapter_ranges[0].to == 4, "fábrica: capítulos inteiros (Rute 1–4)")
	norm = fc.normalize_reference("Gen", "1–2; 38–42")
	check(norm.chapter_ranges.size() == 2, "fábrica: dois intervalos separados por ';'")

	# Os alvos lidos do .tscn em texto (CLI, sem autoloads) batem com o mapa instanciado.
	var t := fc.region_targets("canaan_village")
	var map: Node = load(GameState.DEFAULT_MAP).instantiate()
	var npcs := {}
	for n in map.find_children("*", "NPC", true, false):
		npcs[String(n.character_id)] = true
	var dialogs := {}
	for it in map.find_children("*", "Interactable", true, false):
		if String(it.dialogue_id) != "":
			dialogs[String(it.dialogue_id)] = true
	map.free()
	for e in GameData.get_region("canaan_village").get("examinables", []):
		dialogs[String(e.get("dialogue", ""))] = true
	check(t.error == "" and t.npc.keys().size() == npcs.size() and npcs.keys().all(func(k): return t.npc.has(k)),
		"fábrica: NPCs do mapa lidos do .tscn = instanciados %s" % [t.npc.keys()])
	check(t.dialogue.keys().size() == dialogs.size() and dialogs.keys().all(func(k): return t.dialogue.has(k)),
		"fábrica: interações do mapa lidas do .tscn = instanciadas %s" % [t.dialogue.keys()])

	# Gates
	var idea: Dictionary = fc.episodes.filter(func(e): return e.status == "idea" and not DirAccess.dir_exists_absolute(fc.package_path(e)))[0]
	check(not fc.gate_errors(idea, "researched").is_empty(), "fábrica: gate recusa 'researched' sem pesquisas")
	check(not fc.set_status(idea.id, "blocked", "teste", "").is_empty(), "fábrica: bloquear exige motivo")
	check(not fc.gate_errors(idea, "published").is_empty(), "fábrica: gate recusa 'published' sem revisão humana")
	check(not fc.gate_errors(idea, "pronto").is_empty(), "fábrica: estado desconhecido é recusado")
	var rev := {"biblical": {"verdict": "ok_for_human_review"}, "historical": {"verdict": "ok_for_human_review"},
		"findings": [{"id": "F1", "severity": "critical", "status": "open"}]}
	check(not fc.review_errors(rev).is_empty(), "fábrica: achado crítico em aberto bloqueia aprovação")
	rev.findings[0].status = "resolved"
	check(fc.review_errors(rev).is_empty(), "fábrica: revisões ok e crítico resolvido liberam aprovação")

	# Piloto ligado à missão real e manifesto de áudio estável
	var pilot: Dictionary = fc.by_id.get("ep_006_a_importancia_dos_pocos", {})
	check(String(pilot.get("game", {}).get("quest_id", "")) == "canaan_wells", "fábrica: piloto ep_006 ligado a canaan_wells")
	check(fc.implementation_errors(pilot).is_empty(), "fábrica: missão do piloto válida, alvos no mapa %s" % [fc.implementation_errors(pilot)])
	var a1 := fc.audio_manifest(pilot)
	var a2 := fc.audio_manifest(pilot)
	check(a1.lines.size() > 0 and a1.lines.map(func(l): return l.hash) == a2.lines.map(func(l): return l.hash),
		"fábrica: manifesto de áudio com hash estável (%d falas)" % a1.lines.size())
	var ids := {}
	for l in a1.lines:
		ids[l.line_id] = true
	var nodes := 0
	for did in pilot.game.dialogues:
		for nid in DialogueManager.db.dialogues[did].nodes:
			nodes += 1
			if not ids.has("%s/%s" % [did, nid]):
				check(false, "fábrica: fala %s/%s no manifesto de áudio" % [did, nid])
	check(nodes > 0, "fábrica: todas as %d falas dos diálogos do piloto estão no manifesto" % nodes)
	var sample: Dictionary = a1.lines[0]
	var parts := String(sample.line_id).split("/")
	check(String(sample.file) == "%s/%s__%s.ogg" % [DialogueManager.VOICE_DIR, parts[0], parts[1]],
		"fábrica: arquivo de voz segue o nome que o jogo procura")
	check(DialogueManager.voice_path(parts[0], parts[1]) == "", "jogo: sem gravação, a fala fica só em texto")


## Saves antigos guardam só o índice do objetivo. Depois da v0.6.0 a missão dos poços
## perdeu "examinar o poço", "ouvir Ari" e "conversar com Ezer" (virou "devolver
## o cântaro"); o histórico do save realinha o progresso (realign_objectives).
func _test_old_save_wells() -> void:
	var qid := "canaan_wells"
	var load_with := func(objective: int, logged: Array, objective_id: String) -> void:
		GameState.new_game()
		var d := GameState.to_dict()
		d.flags[QuestManager.event_flag("prologue_finished", "new_game")] = true
		for e in [["custom", "wells_adina_water"], ["dialogue_finished", "well_examine"], ["custom", "wells_ari_well"], ["custom", "wells_ezer_disputes"]]:
			if logged.size() > 3 or e[1] != "wells_ezer_disputes":
				d.flags[QuestManager.event_flag(e[0], e[1])] = true
		var st := {"status": "active", "objective": objective, "hints": {}, "started": 0.0, "completed": 0.0, "objective_started": 0.0}
		if objective_id != "":
			st["objective_id"] = objective_id
		d.quests = {qid: st}
		d.log = logged.map(func(o): return {"kind": "objective", "id": qid + "/" + o, "t": 0.0})
		var clean := SaveManager.sanitize_game_data(d)
		GameState.from_dict(clean.data)
		QuestManager.evaluate()
	load_with.call(4, ["meet_adina", "examine_well", "listen_ari", "talk_ezer"], "")
	check(QuestManager.current_objective(qid).get("id") == "take_jar", "save da v0.6.0 parado no relato passa pela tarefa da água")
	check(String(GameState.quests[qid].get("objective_id")) == "take_jar", "realinhamento grava o id do objetivo")
	for e in [["item_collected", "clay_jar"], ["custom", "wells_trough_full"], ["custom", "wells_adina_thanks"], ["custom", "wells_jar_returned"]]:
		QuestManager.record_event(e[0], e[1])
	check(QuestManager.current_objective(qid).get("id") == "read_story", "depois da água e do cântaro, o save antigo volta ao relato")
	load_with.call(2, ["meet_adina", "examine_well"], "")
	check(QuestManager.current_objective(qid).get("id") == "take_jar", "save da v0.6.0 parado em Ari vai ao cântaro, não ao bebedouro")
	load_with.call(1, ["meet_adina"], "")
	check(QuestManager.current_objective(qid).get("id") == "take_jar" and int(GameState.quests[qid].objective) == 1, "save sem objetivo removido no histórico mantém o índice")
	load_with.call(0, ["meet_adina", "take_jar"], "water_trough")
	check(QuestManager.current_objective(qid).get("id") == "water_trough", "id salvo do objetivo prevalece sobre o índice")
	GameState.new_game()


## Salvar e carregar no meio das viagens de água; recusar a recompensa de Adina.
func _test_wells_water_save_load() -> void:
	var qid := "canaan_wells"
	var run := func(did: String, pick: int) -> void:
		DialogueManager.start(did)
		var g := 0
		while DialogueManager.is_active() and g < 20:
			if DialogueManager.current_choices().is_empty():
				DialogueManager.advance()
			else:
				DialogueManager.choose(pick)
			g += 1
	var roundtrip := func() -> void:
		var clean := SaveManager.sanitize_game_data(GameState.to_dict())
		GameState.new_game()
		GameState.from_dict(clean.data)
		QuestManager.evaluate()
	GameState.new_game()
	QuestManager.current_region_id = "canaan_village"
	QuestManager.record_event("prologue_finished", "new_game")
	QuestManager.record_event("custom", "wells_adina_water")
	Inventory.add("clay_jar", 1, "pickup")
	run.call("well_examine", 0)
	run.call("canaan_trough", 0)
	run.call("well_examine", 0)
	check(GameState.get_flag("wells_trough_1") == true and Inventory.count("clay_jar_full") == 1, "uma viagem feita e o cântaro cheio de novo")
	roundtrip.call()
	check(QuestManager.current_objective(qid).get("id") == "water_trough", "carregar no meio das viagens mantém o objetivo")
	check(Inventory.count("clay_jar_full") == 1 and Inventory.count("clay_jar") == 0, "carregar mantém o cântaro cheio")
	check(GameState.get_flag("wells_trough_1") == true and not GameState.get_flag("wells_trough_2"), "carregar mantém o nível do bebedouro")
	run.call("canaan_trough", 0)
	run.call("well_examine", 0)
	run.call("canaan_trough", 0)
	check(GameState.get_flag("wells_trough_full") == true and QuestManager.current_objective(qid).get("id") == "thank_adina", "duas viagens depois de carregar enchem o bebedouro")
	run.call("adina_talk", 1)
	check(Inventory.count("sheep_cheese") == 0 and Inventory.count("clay_jar") == 1, "recusar a recompensa: sem queijo, cântaro ainda com o jogador")
	check(QuestManager.current_objective(qid).get("id") == "return_jar", "recusar também agradece e segue para Ezer")
	roundtrip.call()
	check(QuestManager.current_objective(qid).get("id") == "return_jar" and Inventory.count("clay_jar") == 1, "carregar antes de devolver o cântaro")
	run.call("ezer_talk", 0)
	check(Inventory.count("clay_jar") == 0 and QuestManager.current_objective(qid).get("id") == "read_story", "Ezer recebe o cântaro; falta o relato")
	GameState.new_game()


## Cada alvo existe na região onde o objetivo acontece: conteúdo fixo da cena
## (.tscn) mais o que a região declara em data/regions.
func _test_quest_targets_in_map() -> void:
	var found := {}
	for rid in GameData.regions:
		var r: Dictionary = GameData.regions[rid]
		var s := {"npc": {}, "dialogue": {}, "examinable": {}, "pickup": {}, "area": {}, "exit": {}}
		var map: Node = load(String(r.map_scene)).instantiate()
		for n in map.find_children("*", "NPC", true, false):
			s.npc[String(n.character_id)] = true
		for it in map.find_children("*", "Interactable", true, false):
			s.dialogue[String(it.dialogue_id)] = true
		map.free()
		for n in r.get("npcs", []):
			s.npc[String(n.get("character", n.id))] = true
		for e in r.get("examinables", []):
			s.examinable[String(e.id)] = true
			s.dialogue[String(e.get("dialogue", ""))] = true
		for p in r.get("pickups", []):
			s.pickup[String(p.id)] = true
		for a in r.get("areas", []):
			s.area[String(a.id)] = true
		for x in r.get("exits", []):
			s.exit[String(x.id)] = true
		found[rid] = s
	for id in QuestManager.db.order:
		var q := QuestManager.db.get_quest(id)
		for o in q.objectives:
			for t in o.targets:
				var rid := String(t.get("region", o.get("region", q.region)))
				var ok: bool
				match String(t.type):
					"ui": ok = t.id in QuestDatabase.UI_TARGETS
					"region": ok = GameData.regions.has(t.id)
					"scene": ok = SceneDatabase.ids_in().has(t.id)
					_: ok = found.has(rid) and found[rid].get(t.type, {}).has(t.id)
				check(ok, "%s/%s: alvo %s '%s' existe na região %s" % [id, o.id, t.type, t.id, rid])


func _test_quest_flow() -> void:
	GameState.new_game()
	QuestManager.current_region_id = "canaan_village"
	var qid := "canaan_wells"
	check(QuestManager.status(qid) == "", "missão não começa antes do prólogo")
	check(QuestManager.get_context().source == "region", "sem missão, contexto vem da região")
	# Feito fora de ordem, antes de a missão existir:
	QuestManager.record_event("custom", "wells_ari_well")
	QuestManager.record_event("prologue_finished", "new_game")
	check(QuestManager.status(qid) == "active", "fim do prólogo inicia a missão")
	check(QuestManager.current_objective(qid).id == "meet_adina", "primeiro objetivo: Adina")
	var ctx := QuestManager.get_context()
	check(ctx.source == "quest" and ctx.references == ["Gen 26:18-22"], "contexto ativo mostra Gn 26:18-22")
	check(QuestManager.hint_level(qid) == 0 and QuestManager.hint_text(qid) == "", "pistas começam ocultas")
	for i in 4:
		QuestManager.request_hint()
	check(QuestManager.hint_level(qid) == 3, "pistas param no nível 3")
	check(QuestManager.hint_text(qid, 1) == QuestManager.current_objective(qid).hints[0], "pista 1 é a mais sutil")

	# Diálogo condicionado ao objetivo: Adina pede ajuda com o bebedouro.
	check(DialogueManager.start("adina_talk"), "conversa com Adina inicia")
	var adina_lines: Array = []
	var guard := 0
	while DialogueManager.is_active() and DialogueManager.current_choices().is_empty() and guard < 10:
		adina_lines.append(String(DialogueManager._node.get("text", "")))
		DialogueManager.advance()
		guard += 1
	check(adina_lines.size() == 3 and String(adina_lines[2]).contains("ajudaria"), "Adina pede ajuda para encher o bebedouro")
	check(DialogueManager.current_choices().size() == 3, "o jogador responde ao pedido de Adina")
	DialogueManager.choose(0)
	while DialogueManager.is_active():
		DialogueManager.advance()
	check(Discoveries.is_unlocked("shepherding_water"), "descoberta liberada pelo diálogo")
	check(QuestManager.current_objective(qid).id == "take_jar", "pedido de Adina leva direto ao cântaro")
	check(QuestManager.hint_level(qid) == 0, "pistas zeram no novo objetivo")
	check(DialogueManager.start("ari_talk"), "conversa com Ari inicia")
	var ari_nodes: Array = []
	while DialogueManager.is_active():
		ari_nodes.append(DialogueManager._node.get("text", ""))
		DialogueManager.advance()
	check(ari_nodes.size() == 4 and String(ari_nodes[0]).contains("história"), "com a missão ativa, Ari conta a lembrança do poço (%d falas)" % ari_nodes.size())
	check(QuestManager.current_objective(qid).id == "take_jar", "Ari é opcional: não muda o objetivo")
	check(DialogueManager.start("ezer_talk") and String(DialogueManager._node.get("text", "")).contains("cântaro"), "Ezer indica o cântaro para o bebedouro")
	while DialogueManager.is_active():
		DialogueManager.advance()

	# Tarefa da água: cântaro, três viagens entre o poço e o bebedouro, Adina.
	var run := func(did: String) -> void:
		DialogueManager.start(did)
		var g := 0
		while DialogueManager.is_active() and g < 20:
			DialogueManager.advance()
			g += 1
	Inventory.add("clay_jar", 1, "pickup")
	check(QuestManager.current_objective(qid).id == "water_trough", "pegar o cântaro avança para o bebedouro")
	run.call("canaan_trough")
	check(Inventory.count("clay_jar") == 1 and not GameState.get_flag("wells_trough_1"), "cântaro vazio não enche o bebedouro")
	for trip in 3:
		run.call("well_examine")
		check(Inventory.count("clay_jar_full") == 1 and Inventory.count("clay_jar") == 0, "viagem %d: o poço enche o cântaro" % (trip + 1))
		run.call("well_examine")
		check(Inventory.count("clay_jar_full") == 1, "viagem %d: cântaro cheio não é enchido de novo" % (trip + 1))
		run.call("canaan_trough")
		check(Inventory.count("clay_jar_full") == 0 and Inventory.count("clay_jar") == 1, "viagem %d: a água vai para o bebedouro" % (trip + 1))
	check(GameState.get_flag("wells_trough_full") == true, "três viagens enchem o bebedouro")
	check(QuestManager.current_objective(qid).id == "thank_adina", "bebedouro cheio: falar com Adina")
	run.call("well_examine")
	check(Inventory.count("clay_jar_full") == 0, "com o bebedouro cheio, o poço não enche mais o cântaro")
	var wool_before := Inventory.count("wool_cloth")
	DialogueManager.start("adina_talk")
	var ga := 0
	while DialogueManager.is_active() and ga < 20:
		if DialogueManager.current_choices().is_empty():
			DialogueManager.advance()
		else:
			check(DialogueManager.current_choices().size() == 2, "Adina oferece o queijo, que pode ser recusado")
			DialogueManager.choose(0)
		ga += 1
	check(Inventory.count("sheep_cheese") == 1 and Inventory.count("clay_jar") == 1 and Inventory.count("wool_cloth") == wool_before, "Adina dá o queijo; o cântaro fica para devolver a Ezer")
	check(QuestManager.current_objective(qid).id == "return_jar", "depois do agradecimento: devolver o cântaro")
	run.call("adina_talk")
	check(Inventory.count("sheep_cheese") == 1, "a recompensa de Adina não se repete")
	run.call("ezer_talk")
	check(Inventory.count("clay_jar") == 0 and Discoveries.is_unlocked("pottery_jars"), "Ezer recebe o cântaro e fala das disputas por poços")
	check(QuestManager.current_objective(qid).id == "read_story", "depois do cântaro: o relato")
	check(DialogueManager.start("journal_intro"), "diário de viagem abre")
	var actions: Array = []
	var cb := func(a): actions.append(a)
	DialogueManager.action_requested.connect(cb)
	while DialogueManager.is_active():
		DialogueManager.advance()
	DialogueManager.action_requested.disconnect(cb)
	check(actions.size() == 1 and actions[0].get("presentation") == "gen_026_wells", "diário pede a apresentação de Gn 26")
	QuestManager.record_event("presentation_finished", "gen_026_wells")
	check(QuestManager.status(qid) == "completed", "apresentação conclui a missão")
	check(QuestManager.status("joseph_dothan_road") == "active", "concluir os poços inicia \"O caminho para Dotã\"")
	check(QuestManager.get_context().references == ["Gen 37:12-17"], "contexto passa à missão principal seguinte")
	check(not Discoveries.unlock("shepherding_water"), "descoberta não é registrada duas vezes")
	var kinds := GameState.history.map(func(e): return e.kind)
	check(kinds.has("quest_started") and kinds.has("quest_completed") and kinds.has("discovery"), "histórico registra a jornada")
	QuestManager.reset_quest(qid)
	check(QuestManager.status(qid) == "" and not QuestManager.has_event("custom", "wells_adina_water"), "reiniciar missão limpa progresso e eventos")
	GameState.new_game()


func _test_journal_content() -> void:
	GameState.new_game()
	QuestManager.current_region_id = "canaan_village"
	QuestManager.record_event("region_entered", "canaan_village")
	QuestManager.record_event("prologue_finished", "new_game")
	Discoveries.unlock("isaac_wells")
	Discoveries.unlock("shepherding_water")
	GameState.set_flag("met_adina", true)
	for tab in JournalContent.TABS:
		var entries := JournalContent.build(tab)
		check(not entries.is_empty(), "diário: seção %s tem entradas" % tab)
		for e in entries:
			if String(e.text).find("[color") >= 0 and String(e.text).count("[color") != String(e.text).count("[/color]"):
				check(false, "diário: BBCode balanceado em %s" % e.id)
	var ids := JournalContent.build("scriptures").map(func(e): return e.id)
	check(ids.has("book:Gen") and ids.has("disc:isaac_wells"), "Escrituras listam Gênesis e a descoberta")
	var gen: Array = JournalContent.build("scriptures").filter(func(e): return e.id == "book:Gen")
	check(String(gen[0].text).contains("Isaque cavou") and String(gen[0].text).contains(Bible.credit()), "Escrituras mostram o texto bíblico e o crédito da tradução")
	var qe := JournalContent.quest_entry("canaan_wells")
	check(qe.get("action", {}).get("label") == "Ler o relato bíblico" and qe.action.presentation == "gen_026_wells", "diário oferece ler o relato antes de chegar ao objetivo")
	QuestManager.record_event("presentation_finished", "gen_026_wells")
	check(JournalContent.quest_entry("canaan_wells").action.label == "Rever o relato", "depois de ler, o diário oferece rever")
	var chars := JournalContent.build("characters")
	var adina: Array = chars.filter(func(e): return e.id == "char:adina")
	check(adina.size() == 1 and String(adina[0].subtitle).begins_with("Fictício") and String(adina[0].text).contains("Não aparece na Bíblia"), "Adina aparece marcada como fictícia")
	check(chars.any(func(e): return e.id == "person:isaac"), "Isaque aparece como personagem bíblico")
	var places := JournalContent.build("places")
	var gerar: Array = places.filter(func(e): return e.id == "place:gerar")
	check(gerar.size() == 1 and String(gerar[0].subtitle).contains("provável"), "Gerar indica identificação provável")
	var village: Array = places.filter(func(e): return e.id == "place:canaan")
	check(village.size() == 1, "região visitada aparece em Lugares")
	var timeline := JournalContent.build("timeline")
	var patri: Array = timeline.filter(func(e): return e.id == "era:patriarchs")
	check(patri.size() == 1 and String(patri[0].text).contains("Isaque reabre"), "linha do tempo mostra o acontecimento descoberto")
	check(String(patri[0].text).find(" a.C.") < 0 or String(patri[0].text).contains("milênio"), "época patriarcal sem ano exato")
	var album := JournalContent.build("album")
	check(album.any(func(e): return e.id == "album:gear_empty"), "álbum vazio sem peças compradas")
	GameState.set_flag("market:owned:walking_staff", true)
	GameState.set_flag("market:equipped:staff", "walking_staff")
	Inventory.add("wool_tuft", 1, "pickup")
	album = JournalContent.build("album")
	check(album.any(func(e): return e.id == "gear:walking_staff") and album.any(func(e): return e.id == "trade:wool_tuft"), "álbum lista peça e mercadoria")
	var hits := JournalContent.search("poços")
	check(hits.any(func(e): return String(e.get("id", "")).contains("canaan_wells") or String(e.get("title", "")).to_lower().contains("poço")), "busca encontra a missão dos poços")
	check(JournalContent.search("xyzabc123").any(func(e): return e.id == "search:none"), "busca sem resultado avisa")
	GameState.new_game()


func _test_quest_editor_model() -> void:
	var m := QuestEditorModel.new()
	m.reload()
	check(m.load_errors.is_empty() and m.order.has("canaan_wells"), "editor: missões carregadas")
	check(m.validate(m.quests.canaan_wells).is_empty(), "editor: missão-piloto valida")
	check(m.filter("", "Gen", "", "", "").has("canaan_wells"), "editor: filtro por livro")
	check(m.filter("", "Rev", "", "", "").is_empty(), "editor: filtro por livro exclui")
	check(m.filter("poços", "", "canaan_village", "patriarchs", "pending_review").has("canaan_wells"), "editor: busca + região + época + status")
	check(m.filter("26:18", "", "", "", "").has("canaan_wells"), "editor: busca por referência")
	var q: Dictionary = m.quests.canaan_wells.duplicate(true)
	for ai in ["IA", "ChatGPT", "Revisado pela IA", "Claude 4", "agente"]:
		check(not QuestEditorModel.set_status(q, "approved", ai).is_empty(), "editor: revisor \"%s\" é recusado" % ai)
	for human in ["Maria Souza", "Rafael", "Diana"]:
		check(not ContentPolicy.is_ai_reviewer(human), "nome humano \"%s\" não é confundido com IA" % human)
	check(not QuestEditorModel.set_status(q, "reference_checked", "").is_empty(), "editor: status humano exige revisor")
	check(QuestEditorModel.set_status(q, "reference_checked", "Ana Lima").is_empty() and q.verification.reviewer == "Ana Lima", "editor: status com revisor humano")
	var tpl := QuestEditorModel.new_quest_template("teste_editor", "canaan_village", "canaan", "patriarchs")
	check(QuestDatabase.validate(tpl).is_empty(), "editor: modelo de missão nova é estruturalmente válido")
	check(ContentPolicy.status_of(tpl) == "draft", "editor: missão nova nasce como rascunho")
	check(not m.validate(tpl).is_empty(), "editor: marcadores do modelo aparecem como pendências de vínculo")
	var path := "user://test_quest_editor.json"
	check(QuestEditorModel.write_item(path, "quests", tpl) == OK, "editor: grava missão")
	tpl.title = "Alterada"
	QuestEditorModel.write_item(path, "quests", tpl)
	var back: Variant = JsonUtil.read_file(path)
	check(back is Dictionary and back.quests.size() == 1 and back.quests[0].title == "Alterada" and not back.quests[0].has("_source"), "editor: regravar substitui pelo id, sem campos internos")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _test_save_v2() -> void:
	GameState.new_game()
	QuestManager.record_event("prologue_finished", "new_game")
	QuestManager.request_hint()
	Discoveries.unlock("wells_antiquity")
	var d := GameState.to_dict()
	var s := SaveManager.sanitize_game_data(JSON.parse_string(JSON.stringify(d)))
	check(s.ok, "save v2 válido")
	GameState.new_game()
	GameState.from_dict(s.data)
	check(QuestManager.status("canaan_wells") == "active" and QuestManager.hint_level("canaan_wells") == 1, "missão e pistas persistem")
	check(Discoveries.is_unlocked("wells_antiquity"), "descobertas persistem")
	check(GameState.history.size() >= 2, "histórico persiste")
	var bad := SaveManager.sanitize_game_data({"current_map": GameState.DEFAULT_MAP, "quests": {"x": {"status": "hack", "objective": -3}}, "discoveries": {"a": "b"}})
	check(bad.ok and not bad.data.quests.has("x") and bad.data.discoveries.is_empty(), "save v2 descarta missões e descobertas inválidas")
	var v1: Dictionary = SaveManager.migrate(1, {"current_map": GameState.DEFAULT_MAP, "flags": {"read_journal": true}, "play_time": 50.0})
	var m := SaveManager.sanitize_game_data(v1)
	check(m.ok and m.data.flags.get("prologue_seen") == true and m.data.flags.get("read_journal") == true, "save v1 migra sem rever a abertura")
	GameState.new_game()
	GameState.from_dict(m.data)
	QuestManager.evaluate()
	check(QuestManager.status("canaan_wells") == "active", "save v1 recebe a missão-piloto ao carregar")
	GameState.new_game()


func _test_save_manager() -> void:
	var data := {"current_map": GameState.DEFAULT_MAP, "player_position": {"x": 10.5, "y": 20.0},
		"player_facing": {"x": 1, "y": 0}, "flags": {"a": true, "n": 3, "bad": [1, 2]}, "play_time": 12.0}
	check(SaveManager.save_data(data) == OK, "salvar")
	var r := SaveManager.load_data()
	check(r.ok and r.data.player_position.x == 10.5, "carregar mantém a posição")
	check(r.ok and r.data.flags.has("a") and not r.data.flags.has("bad"), "flags de tipo inválido são descartadas")

	SaveManager.save_data(data)  # cria .bak válido
	var f := FileAccess.open(TEST_SAVE, FileAccess.WRITE)
	f.store_string("{ isso não é json")
	f.close()
	r = SaveManager.load_data()
	check(r.ok and r.used_backup, "save corrompido recupera pelo .bak")

	var f2 := FileAccess.open(TEST_SAVE + ".bak", FileAccess.WRITE)
	f2.store_string("[]")
	f2.close()
	r = SaveManager.load_data()
	check(not r.ok and r.error != "", "save e backup corrompidos retornam erro amigável")

	var f3 := FileAccess.open(TEST_SAVE, FileAccess.WRITE)
	f3.store_string(JSON.stringify({"version": 999, "game": data}))
	f3.close()
	r = SaveManager.load_data()
	check(not r.ok, "save de versão futura é recusado")

	check(not SaveManager.sanitize_game_data({"current_map": "C:/x.tscn"}).ok, "mapa fora de res:// é recusado")
	check(not SaveManager.sanitize_game_data({"current_map": "res://a.tscn", "player_position": {"x": "a"}}).ok, "posição inválida é recusada")
	SaveManager.delete_save()


func _test_save_slots() -> void:
	var prev := SaveManager.save_path
	var paths: Array[String] = []
	for i in SaveManager.SLOT_COUNT:
		paths.append(SaveManager.slot_path(i))
		SaveManager.delete_save(paths[i])
	SaveManager.save_path = paths[0]
	check(SaveManager.uses_slots() and SaveManager.SLOT_COUNT == 3, "três espaços de save")
	check(not SaveManager.has_any_save() and SaveManager.slot_summary(0).empty, "espaços começam vazios")
	var data := {"current_map": GameState.DEFAULT_MAP, "player_position": {"x": 1.0, "y": 2.0},
		"flags": {"prologue_seen": true}, "play_time": 125.0, "current_region": "canaan_village",
		"inventory": {}, "world": {}, "collectibles": {}, "quests": {}, "discoveries": {}, "log": []}
	check(SaveManager.save_data(data, paths[0]) == OK, "grava no espaço 0")
	check(SaveManager.save_data(data, paths[2]) == OK, "grava no espaço 2")
	check(SaveManager.has_any_save() and SaveManager.has_save(paths[0]) and not SaveManager.has_save(paths[1]), "há saves nos espaços 0 e 2")
	var s0 := SaveManager.slot_summary(0)
	check(not s0.empty and String(s0.place).contains("Canaã") and s0.play_time == 125.0, "resumo do espaço mostra região e tempo")
	SaveManager.set_active_slot(2)
	check(SaveManager.active_slot == 2 and SaveManager.save_path == paths[2], "espaço ativo muda o caminho")
	SaveManager.set_active_slot(0)
	# Migração do save legado.
	SaveManager.delete_save(paths[0])
	SaveManager.delete_save(paths[2])
	var legacy := SaveManager.LEGACY_PATH
	SaveManager.delete_save(legacy)
	check(SaveManager.save_data(data, legacy) == OK, "grava save legado")
	SaveManager.migrate_legacy_if_needed()
	check(SaveManager.has_save(paths[0]) and not FileAccess.file_exists(legacy), "legado migra para o espaço 0")
	for p in paths:
		SaveManager.delete_save(p)
	SaveManager.save_path = prev
	SaveManager.set_active_slot(0)


func _test_input_bindings() -> void:
	InputBindings.apply({})
	check(InputMap.has_action("interact") and InputMap.action_get_events("interact").size() >= 3, "interagir tem teclado e gamepad")
	var has_joy := false
	for e in InputMap.action_get_events("move_left"):
		if e is InputEventJoypadMotion or e is InputEventJoypadButton:
			has_joy = true
	check(has_joy, "movimento tem entrada de controle")
	var custom := InputBindings.set_primary_key("journal", KEY_K, {})
	check(custom.has("journal") and int(custom.journal[0]) == KEY_K, "remapeia o diário para K")
	var has_k := false
	for e in InputMap.action_get_events("journal"):
		if e is InputEventKey and (e as InputEventKey).physical_keycode == KEY_K:
			has_k = true
	check(has_k, "InputMap recebe a tecla remapeada")
	InputBindings.apply({})
	Settings.keybinds = {}


func _test_traveler_look() -> void:
	GameState.new_game()
	TravelerLook.ensure_defaults()
	check(TravelerLook.display_name() == TravelerLook.DEFAULT_NAME, "nome padrão do viajante")
	TravelerLook.set_display_name("  Noa  ")
	check(TravelerLook.display_name() == "Noa", "nome do viajante é guardado")
	TravelerLook.set_skin_index(3)
	check(TravelerLook.skin_index() == 3 and TravelerLook.skin_modulate() == TravelerLook.SKINS[3].modulate, "tom de pele escolhido")
	GameState.new_game()


func _test_craft() -> void:
	check(Craft.errors.is_empty() and Craft.has_craft("pottery_wheel"), "ofício pottery_wheel carregado %s" % [Craft.errors])
	check(DialogueDatabase.valid_action({"craft": "pottery_wheel"}), "ação craft é válida")
	GameState.new_game()
	check(Craft.can_start("pottery_wheel") == "", "roda disponível no primeiro dia")
	check(Craft.complete("pottery_wheel") == "" and Inventory.count("small_clay_bowl") == 1, "minijogo concede tigela")
	check(Craft.can_start("pottery_wheel") != "", "roda só uma vez por dia")
	check(QuestManager.has_event("craft_finished", "pottery_wheel"), "evento craft_finished registrado")
	check(Market.sales.has("small_clay_bowl"), "tigela é vendável na feira")
	GameState.new_game()


func _wait_physics(frames: int) -> void:
	for i in frames:
		await get_tree().physics_frame


func _press(action: String) -> void:
	var ev := InputEventAction.new()
	ev.action = action
	ev.pressed = true
	Input.parse_input_event(ev)
	var up := InputEventAction.new()
	up.action = action
	up.pressed = false
	Input.parse_input_event(up)
	Input.flush_buffered_events()


## Fecha os cartões do HUD em sequência; retorna os focos vistos.
func _close_cards(hud: Node) -> Array:
	var seen: Array = []
	var guard := 0
	while hud.has_pending_popups() and guard < 20:
		await _wait_physics(3)
		if hud._card_open:
			seen.append(hud._card_focus)
			_press("interact")
			await _wait_physics(3)
		guard += 1
	return seen


func _test_gameplay() -> void:
	GameState.new_game()
	var game: Node = load(GAME_SCENE).instantiate()
	add_child(game)
	await _wait_physics(5)
	var player := get_tree().get_first_node_in_group("player") as Player
	check(player != null, "jogador existe no mapa")
	if player == null:
		game.queue_free()
		return
	var spawn: Vector2 = game.get_node("MapContainer/CanaanVillage/World/PlayerSpawn").global_position
	check(player.global_position.distance_to(spawn) < 1.0, "jogador começa no ponto de spawn")
	check(get_tree().get_nodes_in_group("interactable").size() >= 5, "há objetos interativos no mapa (%d)" % get_tree().get_nodes_in_group("interactable").size())

	# Prólogo: aparece no jogo novo, bloqueia o controle e pode ser pulado com Esc.
	var cine = game.get_node("Cinematic")
	check(cine.is_playing() and cine.kind == "prologue", "novo jogo começa pelo prólogo")
	check(GameState.is_ui_blocked() and player.is_blocked(), "prólogo bloqueia o jogador")
	check(QuestManager.status("canaan_wells") == "", "missão espera o fim do prólogo")
	await get_tree().create_timer(0.4).timeout
	_press("interact")
	await _wait_physics(20)
	check(cine.is_playing() and cine._index >= 1, "E avança o prólogo")
	_press("pause")
	await _wait_physics(3)
	check(not cine.is_playing() and not GameState.is_ui_blocked(), "Esc pula o prólogo")
	check(GameState.get_flag("prologue_seen") == true, "prólogo marcado como visto")
	check(QuestManager.status("canaan_wells") == "active", "missão dos poços começa após o prólogo")
	check(not game.get_node("PauseMenu").visible, "Esc do prólogo não abre a pausa")
	var hud = game.get_node("HUD")
	check(hud.visible and hud._ctx_panel.visible and hud._ctx_ref.text == "Gênesis 26:18-22", "painel de contexto mostra Gn 26:18-22")
	check(hud._tracker.visible and hud._tr_text.text.contains("Converse com Adina"), "\"Sua jornada\" mostra o objetivo")
	var guide: ObjectiveGuide = game.get_node("MapContainer/CanaanVillage/ObjectiveGuide")
	await _wait_physics(2)
	var gt := guide.targets()
	check(gt.size() == 1 and gt[0].get_parent() is NPC and gt[0].get_parent().character_id == "adina", "seta do objetivo aponta para Adina")
	check(guide.is_showing(), "seta do objetivo visível fora de diálogos e menus")
	_press("hint")
	await _wait_physics(2)
	check(QuestManager.hint_level("canaan_wells") == 1 and hud._tr_hint.text.begins_with("Pista 1/3"), "H revela a primeira pista")
	_press("toggle_hud")
	await _wait_physics(2)
	check(not hud._ctx_full.visible and hud._ctx_short.visible, "Tab recolhe o painel de contexto")
	_press("toggle_hud")
	await _wait_physics(2)
	check(hud._ctx_full.visible, "Tab expande o painel de contexto")
	var journal = game.get_node("Journal")
	_press("journal")
	await _wait_physics(2)
	check(journal.is_open() and get_tree().paused, "J abre o diário e pausa")
	_press("toggle_hud")
	await _wait_physics(2)
	check(journal.tab == "scriptures", "Tab troca a seção do diário")
	_press("journal")
	await _wait_physics(2)
	check(not journal.is_open() and not get_tree().paused, "J fecha o diário")
	journal.open("journey", "quest:canaan_wells")
	await _wait_physics(2)
	_press("interact")
	await _wait_physics(3)
	check(not journal.is_open() and cine.is_playing() and cine.kind == "presentation", "E no diário abre o relato bíblico")
	var shown: Array = cine._slide_box.find_children("*", "RichTextLabel", true, false)
	check(not shown.is_empty() and String(shown[0].text).contains("Isaque semeou"), "apresentação mostra o texto do versículo")
	check(not guide.is_showing(), "seta some durante a apresentação")
	_press("pause")
	await _wait_physics(3)
	check(not cine.is_playing() and QuestManager.status("canaan_wells") == "active", "fechar o relato pelo diário não conclui a missão")
	await _wait_physics(120)
	if hud._card_open:
		_press("interact")
		await _wait_physics(2)
	check(not GameState.is_ui_blocked(), "nenhum cartão preso na tela")
	# Moradores que passeiam (Ari) podem estar no caminho depois do prólogo: pausados durante os testes de movimento.
	var npcs := game.find_children("*", "NPC", true, false)
	for n in npcs:
		n.process_mode = Node.PROCESS_MODE_DISABLED
	player.global_position = spawn
	await _wait_physics(2)

	var start := player.global_position
	Input.action_press("move_left")
	await _wait_physics(30)
	Input.action_release("move_left")
	await _wait_physics(10)
	check(player.global_position.x < start.x - 10, "jogador anda para a esquerda (%.1f -> %.1f)" % [start.x, player.global_position.x])

	Input.action_press("move_right")
	Input.action_press("move_down")
	await _wait_physics(20)
	var diag_speed := player.velocity.length()
	Input.action_release("move_right")
	Input.action_release("move_down")
	check(diag_speed <= player.walk_speed + 0.5, "velocidade diagonal normalizada (%.1f)" % diag_speed)
	await _wait_physics(15)

	# Colisão: tentar atravessar o poço a partir do sul.
	player.global_position = Vector2(480, 372)
	await _wait_physics(2)
	Input.action_press("move_up")
	await _wait_physics(60)
	Input.action_release("move_up")
	check(player.global_position.y > 344, "colisão impede atravessar o poço (y=%.1f)" % player.global_position.y)
	await _wait_physics(10)
	for n in npcs:
		n.process_mode = Node.PROCESS_MODE_INHERIT

	# Interação com o diário de viagem.
	player.global_position = Vector2(500, 392)
	player.face(Vector2.RIGHT)
	await _wait_physics(5)
	var focused := player.detector.focused
	check(focused != null and focused.dialogue_id == "journal_intro", "diário entra em foco ao se aproximar")
	var ev := InputEventAction.new()
	ev.action = "interact"
	ev.pressed = true
	Input.parse_input_event(ev)
	Input.flush_buffered_events()
	await _wait_physics(2)
	var ev_up := InputEventAction.new()
	ev_up.action = "interact"
	ev_up.pressed = false
	Input.parse_input_event(ev_up)
	check(DialogueManager.is_active(), "tecla de interação abre o diálogo")
	var guard := 0
	while DialogueManager.is_active() and guard < 20:
		DialogueManager.advance()
		guard += 1
	check(not DialogueManager.is_active(), "diálogo termina ao avançar")
	check(GameState.get_flag("read_journal") == true, "flag 'read_journal' registrada")

	# Diálogo com escolhas.
	check(DialogueManager.start("adina_talk"), "diálogo com escolhas inicia")
	var g2 := 0
	while DialogueManager.current_choices().is_empty() and g2 < 10:
		DialogueManager.advance()
		g2 += 1
	check(DialogueManager.current_choices().size() == 3, "escolhas exibidas")
	DialogueManager.choose(2)
	DialogueManager.advance()
	check(not DialogueManager.is_active() and GameState.get_flag("met_adina"), "escolha encerra e marca flag")

	# Salvar, sair e voltar.
	player.global_position = Vector2(300, 330)
	check(GameState.save_game() == OK, "salvar a partida")
	game.queue_free()
	await _wait_physics(3)
	GameState.new_game()
	check(GameState.get_flag("read_journal") == false, "novo estado limpo antes de carregar")
	check(GameState.load_game() == "", "carregar a partida")
	check(GameState.get_flag("read_journal") == true, "progresso restaurado após carregar")
	var game2: Node = load(GAME_SCENE).instantiate()
	add_child(game2)
	await _wait_physics(5)
	var p2 := get_tree().get_first_node_in_group("player") as Player
	check(p2 != null and p2.global_position.distance_to(Vector2(300, 330)) < 1.0, "jogador volta à posição salva")
	var npc_count := 0
	for n in game2.find_children("*", "NPC", true, false):
		if not (n as NPC).data.is_empty():
			npc_count += 1
	check(npc_count >= 7, "NPCs e animais configurados por dados (%d)" % npc_count)

	# Carregar não repete o prólogo; a missão segue até a apresentação e o cartão final.
	var cine2 = game2.get_node("Cinematic")
	var hud2 = game2.get_node("HUD")
	check(not cine2.is_playing(), "carregar não repete o prólogo")
	check(QuestManager.current_objective("canaan_wells").get("id") == "take_jar", "objetivo restaurado após carregar")
	QuestManager.record_event("custom", "wells_jar_returned")
	QuestManager.record_event("item_collected", "clay_jar")
	QuestManager.record_event("custom", "wells_trough_full")
	QuestManager.record_event("custom", "wells_adina_thanks")
	check(QuestManager.current_objective("canaan_wells").get("id") == "read_story", "objetivo final: o relato")
	await _close_cards(hud2)
	var guide2: ObjectiveGuide = game2.get_node("MapContainer/CanaanVillage/ObjectiveGuide")
	await _wait_physics(2)
	check(guide2.targets().size() == 1 and guide2.targets()[0].dialogue_id == "journal_intro", "seta aponta para o diário de viagem")
	DialogueManager.start("journal_intro")
	while DialogueManager.is_active():
		DialogueManager.advance()
	await _wait_physics(2)
	check(cine2.is_playing() and cine2.kind == "presentation", "diário abre a apresentação de Gn 26:18-22")
	_press("pause")
	await _wait_physics(2)
	check(not cine2.is_playing() and QuestManager.status("canaan_wells") == "active", "fechar a apresentação antes do fim não conclui")
	DialogueManager.start("journal_intro")
	while DialogueManager.is_active():
		DialogueManager.advance()
	await _wait_physics(2)
	var steps := 0
	while cine2.is_playing() and steps < 20:
		cine2._next()
		steps += 1
	check(steps == Bible.presentation("gen_026_wells").steps.size(), "apresentação percorre os %d passos" % steps)
	check(QuestManager.status("canaan_wells") == "completed", "missão concluída após a apresentação")
	check(Discoveries.is_unlocked("isaac_wells"), "descoberta 'Os poços de Isaque' registrada")
	check(guide2.targets().is_empty(), "sem missão ativa, a seta some")
	var saw := await _close_cards(hud2)
	check(saw.has("quest:canaan_wells"), "cartão \"História explorada\" exibido (%s)" % [saw])
	check(not GameState.is_ui_blocked(), "controle volta ao jogador")
	game2.queue_free()
	await _wait_physics(3)


func _test_main_menu() -> void:
	var menu: Control = load("res://scenes/ui/main_menu.tscn").instantiate()
	add_child(menu)
	await get_tree().process_frame
	check(menu.get_node("Buttons/NewGame") is Button, "menu principal monta os botões")
	menu.queue_free()
	await get_tree().process_frame
