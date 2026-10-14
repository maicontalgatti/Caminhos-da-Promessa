class_name ExportSelfTest
extends Node
## Autoteste do executável EXPORTADO. Não roda durante o jogo normal.
##   CaminhosDaPromessa.exe --headless -- --self-test
## Templates de exportação ignoram --script, então o SceneRouter instancia
## este nó quando recebe o argumento de usuário --self-test.
## Verifica se os dados JSON foram empacotados e são legíveis, se o mapa
## carrega e se o save funciona em user:// (fora da pasta do jogo).
## Imprime "AUTOTESTE: OK" e sai com código 0, ou "AUTOTESTE: FALHOU" e código 1.

const ARG := "--self-test"
const TEST_SAVE := "user://export_selftest_save.json"

var _failed := 0


static func requested() -> bool:
	return ARG in OS.get_cmdline_user_args()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_run.call_deferred()


func check(cond: bool, label: String) -> void:
	print(("  ok   " if cond else "  FAIL ") + label)
	if not cond:
		_failed += 1


func _run() -> void:
	var tree := get_tree()
	print("AUTOTESTE: Caminhos da Promessa %s (Godot %s)" % [
		ProjectSettings.get_setting("application/config/version", "?"), Engine.get_version_info().string])

	check(OS.has_feature("template"), "rodando a partir de um template de exportação")
	check(OS.has_feature("template_release"), "build em modo release")
	for dir in ["res://data/dialogues", "res://data/characters", "res://data/regions", "res://data/bible",
			"res://data/bible/stories", "res://data/bible/texts", "res://data/quests/canaan", "res://data/story",
			"res://data/quests/dothan", "res://data/items", "res://data/collectibles", "res://data/world"]:
		check(not JsonUtil.list_json(dir).is_empty(), "JSON empacotados em %s" % dir)
	check(Inventory.errors.is_empty() and Inventory.exists("water_skin"), "itens carregados %s" % [Inventory.errors])
	check(Collectibles.errors.is_empty() and Collectibles.set_total("caravan_records") == 5, "colecionáveis carregados %s" % [Collectibles.errors])
	for rid in ["canaan_village", "caravan_road", "dothan"]:
		var scene_path := String(WorldManager.region(rid).get("map_scene", ""))
		check(scene_path != "" and ResourceLoader.exists(scene_path), "região '%s' e mapa empacotados (%s)" % [rid, scene_path])
	check(WorldManager.experience_state("joseph_dothan") == "locked", "Mapa das Escrituras: José em Dotã carregado")
	for qid in ["joseph_dothan_road", "road_supplies", "dothan_families", "caravan_records"]:
		check(QuestManager.db.order.has(qid), "missão '%s' carregada" % qid)
	check(FileAccess.file_exists("res://assets/fonts/OFL.txt") and FileAccess.file_exists("res://assets/fonts/OFL-Lora.txt"), "licenças das fontes embutidas no executável")

	check(GameData.errors.is_empty(), "personagens e regiões sem erros %s" % [GameData.errors])
	check(GameData.characters.size() >= 5, "personagens carregados (%d)" % GameData.characters.size())
	check(not GameData.get_region("canaan_village").is_empty(), "região da aldeia carregada")
	check(GameData.get_portrait("adina") != null, "retrato gerado a partir da folha de sprite")
	check(DialogueManager.db.errors.is_empty(), "diálogos sem erros %s" % [DialogueManager.db.errors])
	check(DialogueManager.db.dialogues.size() >= 15, "diálogos carregados (%d)" % DialogueManager.db.dialogues.size())

	var catalog := BibleCatalog.new()
	catalog.load_all()
	check(catalog.errors.is_empty(), "catálogo bíblico sem erros %s" % [catalog.errors])
	check(catalog.books.size() == 66, "66 livros no catálogo (%d)" % catalog.books.size())
	check(catalog.stories.size() >= 5, "histórias-piloto carregadas (%d)" % catalog.stories.size())
	check(catalog.discoveries.size() >= 10 and catalog.presentations.has("gen_026_wells"), "descobertas e apresentação de Gn 26 carregadas")
	check(catalog.verses_of("Gen 26:18-22").size() == 5, "texto bíblico de Gn 26:18-22 carregado (%s)" % catalog.translation.get("abbrev", "?"))
	check(QuestManager.db.errors.is_empty() and QuestManager.db.order.has("canaan_wells"), "missão dos poços carregada %s" % [QuestManager.db.errors])
	check(GameData.prologues.has("new_game"), "prólogo carregado")
	check(not ResourceLoader.exists("res://scripts/ui/debug_panel.gd"), "painel de debug fora da build pública")
	check(not OS.is_debug_build(), "controles de debug desativados (build release)")
	_check_audio()
	GameState.new_game()
	QuestManager.record_event("prologue_finished", "new_game")
	check(QuestManager.status("canaan_wells") == "active", "missão inicia após o prólogo")
	check(Discoveries.unlock("wells_antiquity") and Discoveries.is_unlocked("wells_antiquity"), "descoberta registrada")

	var map_scene: PackedScene = load(GameState.DEFAULT_MAP)
	check(map_scene != null, "cena da aldeia carregada")
	if map_scene:
		var map := map_scene.instantiate()
		tree.root.add_child(map)
		for i in 5:
			await tree.physics_frame
		check(tree.get_first_node_in_group("player") != null, "jogador instanciado no mapa")
		var interactables := tree.get_nodes_in_group("interactable").size()
		check(interactables >= 20, "objetos interativos (%d)" % interactables)
		map.queue_free()
		await tree.process_frame

	var user_dir := OS.get_user_data_dir()
	var exe_dir := OS.get_executable_path().get_base_dir()
	print("  info user:// = ", user_dir)
	check(not user_dir.begins_with(exe_dir), "user:// fica fora da pasta do executável")
	SaveManager.save_path = TEST_SAVE
	GameState.new_game()
	GameState.set_flag("selftest", true)
	QuestManager.record_event("prologue_finished", "new_game")
	QuestManager.request_hint()
	check(GameState.save_game() == OK, "salvar em user://")
	GameState.new_game()
	check(GameState.load_game() == "" and GameState.get_flag("selftest") == true, "carregar de user://")
	check(QuestManager.hint_level("canaan_wells") == 1, "missão e pistas restauradas do save")
	SaveManager.delete_save()
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	GameState.new_game()

	print("AUTOTESTE: " + ("OK" if _failed == 0 else "FALHOU (%d)" % _failed))
	AudioManager.shutdown()
	await tree.create_timer(0.5).timeout
	for i in 3:
		await tree.process_frame
	tree.quit(0 if _failed == 0 else 1)


## Efeitos sonoros empacotados: manifesto, buses e cada arquivo carregável.
func _check_audio() -> void:
	check(AudioManager.errors.is_empty() and AudioManager.sounds.size() >= 60, "manifesto de áudio carregado (%d sons) %s" % [AudioManager.sounds.size(), AudioManager.errors])
	for bus in AudioManager.BUSES:
		check(AudioServer.get_bus_index(bus) >= 0, "bus de áudio %s" % bus)
	var missing: Array = []
	var total := 0
	for id in AudioManager.sounds:
		for i in AudioManager.files_of(id).size():
			total += 1
			var s := AudioManager.stream(id, i)
			if s == null or s.get_length() <= 0.0:
				missing.append("%s#%d" % [id, i])
	check(missing.is_empty() and total >= 100, "%d arquivos de som empacotados e carregáveis %s" % [total, missing])
	var bed := AudioManager.stream("amb_wind_canaan") as AudioStreamWAV
	check(bed != null and bed.loop_mode != AudioStreamWAV.LOOP_DISABLED, "ambiente contínuo em laço no executável")
	check(AudioManager.play("ui_click") != null, "efeito toca pelo AudioManager")
