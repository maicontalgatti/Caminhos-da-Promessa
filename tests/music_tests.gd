extends RefCounted
## Testes da música temática (scripts/core/music_director.gd,
## data/audio/music.json): manifesto e licenças, escolha do momento, troca de
## faixas, embaralhamento, abaixar em diálogo e marcos, ganchos das telas.
## Chamado por tests/test_runner.gd. Não substituem ouvir (KI-22).

const MusicRules := preload("res://scripts/core/music_rules.gd")
const WavInfo := preload("res://tools/audio/wav_info.gd")
const GAME_SCENE := "res://scenes/core/game.tscn"

var r: Node
var m: Node


func _init(runner: Node) -> void:
	r = runner
	m = AudioManager.music


func check(cond: bool, label: String) -> void:
	r.check(cond, label)


func wait(frames: int) -> void:
	await r._wait_physics(frames)


func _known() -> Dictionary:
	var prologues: Array = []
	for p in JsonUtil.read_collection("res://data/story", "prologues", PackedStringArray()):
		prologues.append(String(p.get("id", "")))
	var regions: Array = []
	for rg in JsonUtil.read_collection("res://data/regions", "regions", PackedStringArray()):
		regions.append(String(rg.id))
	var scenes := SceneDatabase.new()
	scenes.load_dir()
	return {"regions": regions, "quests": QuestManager.db.order, "scenes": scenes.order,
		"presentations": Bible.catalog.presentations.keys(), "prologues": prologues, "contexts": ["scripture_map"]}


# --- Manifesto ------------------------------------------------------------------

func test_manifest() -> void:
	check(m != null and m.get_parent() == AudioManager, "música: diretor de música é filho do AudioManager")
	check(m.errors.is_empty(), "música: manifesto sem erros %s" % [m.errors])
	check(m.tracks.size() >= 9, "música: %d faixas no catálogo" % m.tracks.size())
	var data: Dictionary = JsonUtil.read_file(m.MANIFEST)
	var errs := MusicRules.validate_manifest(data, _known(), Time.get_date_dict_from_system().year)
	check(errs.is_empty(), "música: regras de licença e momentos ok %s" % [errs])
	var bad: Array = []
	for id in m.tracks:
		var path: String = m.file_of(String(id))
		var s: AudioStream = load(path) if path != "" else null
		if s == null:
			bad.append(id)
			continue
		if path.ends_with(".wav"):
			var info := WavInfo.read(path)
			if not info.ok or info.peak_db < -30.0 or info.clipped > 0 or info.seconds < 15.0:
				bad.append("%s %s" % [id, info])
	check(bad.is_empty(), "música: toda faixa carrega, tem som, não satura e dura mais de 15 s %s" % [bad])
	var vocal: Array = m.tracks.keys().filter(func(id): return bool(m.tracks[id].get("vocal", false)))
	check(vocal.is_empty(), "música: nenhuma faixa cantada sem licença (todas instrumentais por enquanto)")
	for p in m._players:
		check(p.bus == "Music", "música: player %s no bus Music" % p.name)


func test_rules_reject() -> void:
	var known := {"regions": ["canaan_village"], "quests": ["q1"], "scenes": [], "presentations": [], "prologues": [], "contexts": ["scripture_map"]}
	var good := {"tracks": {"a": {"source": "public_domain_hymn", "composer_death": 1863, "year": 1818, "path": "music/silent_night", "themes": ["paz"]}},
		"cues": {"menu": ["a"], "regions": {"canaan_village": ["theme:paz"]}}}
	check(MusicRules.validate_manifest(good, known, 2026).is_empty(), "música: hino de 1818 com tema e região válidos passa %s" % [MusicRules.validate_manifest(good, known, 2026)])
	var recent := good.duplicate(true)
	recent.tracks.a.composer_death = 1990
	check(MusicRules.validate_manifest(recent, known, 2026).size() == 1, "música: compositor morto em 1990 é recusado (melodia protegida)")
	var anon := good.duplicate(true)
	anon.tracks.a.composer_death = null
	anon.tracks.a.year = 1950
	check(MusicRules.validate_manifest(anon, known, 2026).size() == 1, "música: melodia anônima de 1950 é recusada")
	var vocal := good.duplicate(true)
	vocal.tracks.a.vocal = true
	check(MusicRules.validate_manifest(vocal, known, 2026).size() == 1, "música: faixa cantada sem licença da letra é recusada")
	var modern := good.duplicate(true)
	modern.tracks.a.source = "streaming"
	check(MusicRules.validate_manifest(modern, known, 2026).size() >= 1, "música: origem desconhecida é recusada")
	var lic := good.duplicate(true)
	lic.tracks.a.source = "licensed"
	check(MusicRules.validate_manifest(lic, known, 2026).size() == 1, "música: louvor licenciado exige registro da licença")
	var cues := good.duplicate(true)
	cues.cues.regions["nowhere"] = ["b"]
	cues.cues.regions["canaan_village"] = ["theme:nada"]
	check(MusicRules.validate_manifest(cues, known, 2026).size() == 3, "música: região, faixa e tema inexistentes são apontados")


# --- Escolha do momento ---------------------------------------------------------

func test_resolution() -> void:
	m.reset()
	var was_in_game: bool = GameState.in_game
	GameState.in_game = false
	check(m.resolve() == "menu", "música: fora do jogo toca o tema do menu")
	GameState.new_game()
	GameState.in_game = true
	var old_region: String = AudioManager.region_id
	AudioManager.region_id = "caravan_road"
	check(QuestManager.primary_quest() == "", "música: jogo novo sem missão ativa")
	check(m.resolve() == "region:caravan_road", "música: sem missão, vale a região")
	QuestManager.start_quest("canaan_wells", true)
	check(QuestManager.primary_quest() == "canaan_wells" and m.resolve() == "quest:canaan_wells", "música: missão principal em foco troca a lista da região")
	QuestManager.start_quest("road_supplies", true)
	QuestManager.set_tracked("road_supplies")
	check(m.resolve() == "region:caravan_road", "música: missão secundária acompanhada segue a região")
	QuestManager.set_tracked("")
	var screen := Node.new()
	var scene := Node.new()
	m.enter_context(screen, "context:scripture_map")
	check(m.resolve() == "context:scripture_map", "música: Mapa das Escrituras aberto troca o tema")
	m.enter_context(scene, "scene:exodus_sea_crossing")
	check(m.resolve() == "scene:exodus_sea_crossing", "música: cena dirigida vence a tela aberta")
	m.exit_context(scene)
	check(m.resolve() == "context:scripture_map", "música: fim da cena volta ao momento anterior")
	var undefined := Node.new()
	m.enter_context(undefined, "scene:sem_trilha")
	check(m.resolve() == "context:scripture_map", "música: momento sem lista no manifesto mantém o anterior")
	m.exit_context(undefined)
	undefined.free()
	screen.free()
	check(not m.resolve().begins_with("context:"), "música: dono liberado sem fechar não prende o tema")
	scene.free()
	m.clear_contexts()
	var pres := Node.new()
	m.enter_context(pres, "presentation:gen_026_wells")
	check(m.resolve() == "presentation:gen_026_wells", "música: apresentação bíblica tem trilha própria")
	m.exit_context(pres)
	pres.free()
	AudioManager.region_id = old_region
	GameState.in_game = was_in_game
	m.reset()


func test_themes_and_shuffle() -> void:
	m.reset()
	var t: Array[String] = m.cue_tracks("quest:canaan_wells")
	check(t.has("old_hundredth") and t.size() >= 2, "música: 'theme:' acrescenta faixas do tema à lista %s" % [t])
	var uniq := {}
	for id in t:
		uniq[id] = true
	check(uniq.size() == t.size(), "música: lista sem faixas repetidas")
	m.current_list = ["old_hundredth", "ode_to_joy", "amazing_grace"] as Array[String]
	var prev := ""
	var repeats := 0
	var seen := {}
	for i in 30:
		var id: String = m.pick_next()
		m._last_played = id
		seen[id] = true
		if id == prev:
			repeats += 1
		prev = id
	check(repeats == 0, "música: nunca a mesma faixa duas vezes seguidas")
	check(seen.size() == 3, "música: todas as faixas da lista aparecem")
	m.reset()


# --- Reprodução -----------------------------------------------------------------

func test_playback() -> void:
	m.reset()
	m.enabled = false
	m.apply_cue("region:canaan_village")
	check(m.current_list.size() >= 1 and m._next_start >= 0, "música: novo momento agenda a primeira faixa")
	var first: String = m.current_list[0]
	check(m.start_track(first), "música: faixa começa (%s)" % first)
	check(m.current_track == first and m._players[m._active].playing, "música: player toca a faixa")
	check(m._players[m._active].volume_db < -10.0, "música: começa em fade, bem baixa (%.1f dB)" % m._players[m._active].volume_db)
	var tdb: float = float(m.tracks[first].get("volume_db", 0.0))
	check(tdb <= -12.0, "música: volume da faixa abaixo do normal (%.1f dB)" % tdb)
	# Momento cuja lista contém a faixa atual: ela continua.
	var keep_key := ""
	for key in m.all_cue_keys():
		if key != "region:canaan_village" and first in m.cue_tracks(key):
			keep_key = key
			break
	if keep_key != "":
		m.apply_cue(keep_key)
		check(m.current_track == first, "música: troca de momento mantém a faixa que também serve (%s)" % keep_key)
	# Momento sem a faixa: sai em fade e agenda outra.
	var other_key := ""
	for key in m.all_cue_keys():
		if not (first in m.cue_tracks(key)) and not m.cue_tracks(key).is_empty():
			other_key = key
			break
	m.apply_cue(other_key)
	check(m.current_track == "" and m._gain_target[m._active] == 0.0 and m._next_start >= 0,
		"música: momento diferente faz fade e agenda a nova faixa (%s)" % other_key)
	# Fim natural: silêncio antes da próxima.
	m.start_track(m.pick_next())
	var before := Time.get_ticks_msec()
	m.track_finished()
	var gap: Array = m.rule("playlist_gap", [20, 40])
	check(m._next_start - before >= int(float(gap[0]) * 1000.0) - 5, "música: silêncio de %s s entre faixas" % [gap])
	# Lista vazia: silêncio.
	m.current_cue = "region:canaan_village"
	m.apply_cue("")
	check(m.current_list.is_empty() and m._next_start == -1, "música: sem momento, silêncio")
	m.enabled = true
	m.reset()


func test_ducking() -> void:
	m.reset()
	check(is_equal_approx(m.duck_target(), 1.0), "música: sem diálogo nem marco, volume cheio")
	m._on_sound_played("quest_complete")
	check(m.duck_target() < 0.5, "música: conclusão de missão abaixa a música")
	m._on_sound_played("ui_click")
	m._event_duck_until = 0
	check(is_equal_approx(m.duck_target(), 1.0), "música: clique de interface não abaixa")
	DialogueManager.start(String(DialogueManager.db.dialogues.keys()[0]))
	check(DialogueManager.is_active() and m.duck_target() < 0.6, "música: diálogo aberto abaixa a música")
	if DialogueManager.is_active():
		var g := 0
		while DialogueManager.is_active() and g < 40:
			DialogueManager.advance()
			g += 1
	m.reset()


func test_screens_in_game() -> void:
	m.reset()
	GameState.new_game()
	GameState.set_flag("prologue_seen", true)
	var game: Node = load(GAME_SCENE).instantiate()
	r.add_child(game)
	await wait(5)
	await r._close_cards(game.get_node("HUD"))
	await wait(12)
	var world_cue: String = m.current_cue
	check(world_cue.begins_with("region:") or world_cue.begins_with("quest:"), "música: no jogo, tema da região ou missão (%s)" % world_cue)
	var sm := game.find_children("*", "", true, false).filter(func(n): return n.has_method("open_passage"))
	if not sm.is_empty():
		sm[0].open()
		await wait(2)
		check(m.current_cue == "context:scripture_map", "música: abrir o Mapa das Escrituras troca o tema")
		sm[0].close()
		await wait(2)
		check(m.current_cue == world_cue, "música: fechar o mapa volta ao tema do mundo")
	else:
		check(false, "música: Mapa das Escrituras encontrado no jogo")
	game.play_presentation("gen_026_wells")
	await wait(2)
	check(m.current_cue == "presentation:gen_026_wells", "música: apresentação de Gn 26 toca o hino dela")
	var cine := game.find_children("*", "", true, false).filter(func(n): return n.has_method("play_presentation") and n != game)
	if not cine.is_empty():
		cine[0]._finish(true)
	await wait(2)
	check(m.current_cue == world_cue, "música: fechar a apresentação volta ao tema do mundo")
	game.queue_free()
	await wait(3)
	m.reset()
