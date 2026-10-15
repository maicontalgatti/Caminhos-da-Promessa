extends Node
## Áudio centralizado. Os sistemas pedem sons por id (data/audio/sfx.json);
## aqui ficam o cache dos arquivos, os buses, o conjunto limitado de players,
## as regras contra repetição (cooldown, instâncias, prioridade), os sons
## automáticos de botões, os eventos de jogo e o ambiente por região.
## Documentação: docs/audio.md.

signal played(id: String)

const MANIFEST := "res://data/audio/sfx.json"
const AUDIO_DIR := "res://assets/audio"
const BUSES := ["Music", "SFX", "UI", "Ambience", "Voice"]
const POOL_SIZE := 14
const POOL_2D_SIZE := 6
## Sons de interface que outro som "substitui" se começaram há menos que isto.
const SUPERSEDE_WINDOW := 0.09
## Navegação por teclado recente: só então foco de botão faz som.
const NAV_WINDOW := 0.2
## Eventos de jogo logo depois de carregar/novo jogo não tocam.
const QUIET_AFTER_LOAD := 0.6
const BED_FADE := 1.4
const HISTORY_SIZE := 80
const MusicDirector := preload("res://scripts/core/music_director.gd")

var sounds: Dictionary = {}
var surfaces: Dictionary = {}
var interactions: Dictionary = {}
var item_sounds: Dictionary = {}
var ambience_defs: Dictionary = {}
var errors: PackedStringArray = []
## Últimos sons tocados [{id, t}] (diagnóstico e testes).
var history: Array = []
var region_id := ""
## Música temática (scripts/core/music_director.gd, data/audio/music.json).
var music: Node

var _streams: Dictionary = {}
var _last_variant: Dictionary = {}
var _last_time: Dictionary = {}
var _pool: Array[AudioStreamPlayer] = []
var _pool_2d: Array[AudioStreamPlayer2D] = []
## player -> {id, priority, started}
var _voices: Dictionary = {}
var _pending_events: Array = []
var _quiet_until := 0
var _nav_time := -100000
var _last_immediate := -100000
var _dialogue_lines := 0
var _interaction_frame := -1
var _beds: Array[AudioStreamPlayer] = []
var _bed_index := 0
var _bed_id := ""
var _layers: Array = []
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_rng.randomize()
	_ensure_buses()
	load_manifest()
	for i in POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.name = "Sfx%d" % i
		add_child(p)
		_pool.append(p)
	for i in POOL_2D_SIZE:
		var p2 := AudioStreamPlayer2D.new()
		p2.name = "Sfx2D%d" % i
		add_child(p2)
		_pool_2d.append(p2)
	for i in 2:
		var b := AudioStreamPlayer.new()
		b.name = "Bed%d" % i
		b.bus = "Ambience"
		add_child(b)
		_beds.append(b)
	music = MusicDirector.new()
	music.name = "Music"
	add_child(music)
	Settings.apply()
	get_tree().node_added.connect(_on_node_added)
	_hook_existing(get_tree().root)
	QuestManager.quest_started.connect(func(_q): event("quest_start"))
	QuestManager.objective_completed.connect(func(_q, _o): event("objective_complete"))
	QuestManager.quest_completed.connect(func(_q): event("quest_complete"))
	QuestManager.event_recorded.connect(_on_quest_event)
	Discoveries.discovery_unlocked.connect(func(_d): event("discovery"))
	Collectibles.collectible_found.connect(func(_c): event("collectible"))
	Inventory.moved.connect(_on_item_moved)
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.line_shown.connect(_on_line_shown)
	DialogueManager.dialogue_ended.connect(func(_id): play("dialogue_close"))
	GameState.state_replaced.connect(quiet_for.bind(QUIET_AFTER_LOAD))


func _ensure_buses() -> void:
	for bus in BUSES:
		if AudioServer.get_bus_index(bus) >= 0:
			continue
		AudioServer.add_bus()
		var idx := AudioServer.bus_count - 1
		AudioServer.set_bus_name(idx, bus)
		AudioServer.set_bus_send(idx, "Master")


func load_manifest() -> void:
	errors.clear()
	var data: Variant = JsonUtil.read_file(MANIFEST)
	if not (data is Dictionary):
		errors.append("manifesto de áudio ausente ou inválido: " + MANIFEST)
		return
	sounds = data.get("sounds", {})
	surfaces = data.get("surfaces", {})
	interactions = data.get("interactions", {})
	item_sounds = data.get("items", {})
	ambience_defs = data.get("ambience", {})
	for id in sounds:
		var d: Dictionary = sounds[id]
		if not (String(d.get("bus", "SFX")) in BUSES):
			errors.append("som %s: bus inválido \"%s\"" % [id, d.get("bus")])
		for path in files_of(String(id)):
			if not ResourceLoader.exists(path):
				errors.append("som %s: arquivo ausente %s" % [id, path])
	for e in errors:
		push_error("AudioManager: " + e)


## Caminhos dos arquivos de um som (variações _1.._n).
func files_of(id: String) -> PackedStringArray:
	var out := PackedStringArray()
	var d: Dictionary = sounds.get(id, {})
	for i in maxi(int(d.get("variants", 1)), 1):
		out.append("%s/%s_%d.wav" % [AUDIO_DIR, d.get("path", id), i + 1])
	return out


func has_sound(id: String) -> bool:
	return sounds.has(id)


## Stream de uma variação, carregado uma única vez.
func stream(id: String, variant: int = 0) -> AudioStream:
	var files := files_of(id)
	if files.is_empty():
		return null
	var path := files[clampi(variant, 0, files.size() - 1)]
	if _streams.has(path):
		return _streams[path]
	var s: AudioStream = load(path) if ResourceLoader.exists(path) else null
	if s != null and sounds.get(id, {}).get("loop", false):
		_make_loop(s)
	_streams[path] = s
	return s


func _make_loop(s: AudioStream) -> void:
	if s is AudioStreamWAV:
		var w := s as AudioStreamWAV
		w.loop_mode = AudioStreamWAV.LOOP_FORWARD
		w.loop_begin = 0
		w.loop_end = int(w.get_length() * w.mix_rate)


# --- Reprodução -----------------------------------------------------------------

## Toca um som não posicional. opts: pitch_scale (multiplica), volume_db (soma).
## Retorna o player usado, ou null se o som foi evitado (cooldown, limite,
## prioridade) ou não existe.
func play(id: String, opts: Dictionary = {}) -> AudioStreamPlayer:
	var d := _prepare(id)
	if d.is_empty():
		return null
	var p := _acquire(_pool, int(d.get("priority", 50))) as AudioStreamPlayer
	if p == null:
		return null
	_start(p, id, d, opts)
	return p


## Toca um som posicionado no mundo 2D (atenua com a distância da câmera).
func play_at(id: String, pos: Vector2, opts: Dictionary = {}) -> AudioStreamPlayer2D:
	var d := _prepare(id)
	if d.is_empty():
		return null
	var p := _acquire(_pool_2d, int(d.get("priority", 50))) as AudioStreamPlayer2D
	if p == null:
		return null
	p.global_position = pos
	p.max_distance = float(opts.get("max_distance", 420.0))
	p.attenuation = 1.6
	_start(p, id, d, opts)
	return p


func _prepare(id: String) -> Dictionary:
	if not sounds.has(id):
		push_warning("AudioManager: som inexistente \"%s\"" % id)
		return {}
	var d: Dictionary = sounds[id]
	var now := Time.get_ticks_msec()
	if now - int(_last_time.get(id, -100000)) < int(float(d.get("cooldown", 0.03)) * 1000.0):
		return {}
	var limit := int(d.get("max", 2))
	var active := 0
	for p in _voices:
		if is_instance_valid(p) and p.playing and _voices[p].id == id:
			active += 1
	if active >= limit:
		return {}
	return d


func _acquire(pool: Array, priority: int) -> Node:
	var victim: Node = null
	var victim_prio := priority + 1
	var victim_start := 0
	for p in pool:
		if not p.playing:
			return p
		var info: Dictionary = _voices.get(p, {})
		var pr := int(info.get("priority", 0))
		var st := int(info.get("started", 0))
		if pr < victim_prio or (pr == victim_prio and st < victim_start):
			victim = p
			victim_prio = pr
			victim_start = st
	if victim != null and victim_prio <= priority:
		victim.stop()
		return victim
	return null


func _start(p: Node, id: String, d: Dictionary, opts: Dictionary) -> void:
	var n := maxi(int(d.get("variants", 1)), 1)
	var v := _rng.randi_range(0, n - 1)
	if n > 1 and v == int(_last_variant.get(id, -1)):
		v = (v + 1 + _rng.randi_range(0, n - 2)) % n
	var s := stream(id, v)
	if s == null:
		return
	_last_variant[id] = v
	for other in d.get("supersedes", []):
		_stop_recent(String(other))
	var pitch_var := float(d.get("pitch", 0.0))
	var jitter := float(d.get("jitter_db", 0.0))
	p.stream = s
	p.bus = String(d.get("bus", "SFX"))
	p.volume_db = float(d.get("volume_db", 0.0)) + float(opts.get("volume_db", 0.0)) + _rng.randf_range(-jitter, jitter)
	p.pitch_scale = maxf(0.05, float(opts.get("pitch_scale", 1.0)) * (1.0 + _rng.randf_range(-pitch_var, pitch_var)))
	p.play()
	var now := Time.get_ticks_msec()
	_voices[p] = {"id": id, "priority": int(d.get("priority", 50)), "started": now}
	_last_time[id] = now
	history.append({"id": id, "t": now})
	if history.size() > HISTORY_SIZE:
		history.pop_front()
	played.emit(id)


func _stop_recent(id: String) -> void:
	var now := Time.get_ticks_msec()
	for p in _voices:
		var info: Dictionary = _voices[p]
		if is_instance_valid(p) and p.playing and info.id == id and now - int(info.started) <= int(SUPERSEDE_WINDOW * 1000.0):
			p.stop()


func stop_all() -> void:
	for p in _voices:
		if is_instance_valid(p):
			p.stop()


func _exit_tree() -> void:
	shutdown()


## Para tudo e solta o cache. O servidor de áudio libera as reproduções no
## próximo ciclo de mixagem; quem encerra o jogo deve esperar um instante.
func shutdown() -> void:
	stop_all()
	if music != null:
		music.reset()
	_layers.clear()
	_bed_id = ""
	for group: Array in [_pool, _pool_2d, _beds]:
		for p in group:
			p.stop()
			p.stream = null
	if is_inside_tree():
		for e in get_tree().get_nodes_in_group("ambience_emitter"):
			e.stop()
	_streams.clear()


## Quantas vezes um som tocou desde `since_msec` (diagnóstico e testes).
func played_count(id: String, since_msec: int = 0) -> int:
	return history.filter(func(h): return h.id == id and int(h.t) >= since_msec).size()


func played_recently(id: String, window: float) -> bool:
	return Time.get_ticks_msec() - int(_last_time.get(id, -100000)) <= int(window * 1000.0)


func clear_history() -> void:
	history.clear()
	_last_time.clear()


# --- Atalhos usados pelos sistemas ----------------------------------------------

func footstep(surface: String, running: bool) -> void:
	var map: Dictionary = surfaces.get("sounds", {})
	var id := String(map.get(surface, map.get(String(surfaces.get("default", "dirt")), "")))
	if id == "":
		return
	var opts := {}
	if running:
		var run: Dictionary = surfaces.get("run", {})
		opts = {"pitch_scale": float(run.get("pitch_scale", 1.07)), "volume_db": float(run.get("volume_db", 2.0))}
	play(id, opts)


## Som de um objeto examinado, pelo diálogo ou pelo tipo do Interactable.
func interaction_sound(dialogue_id: String, kind_name: String) -> String:
	var by: Dictionary = interactions.get("by_dialogue", {})
	if by.has(dialogue_id):
		return String(by[dialogue_id])
	return String(interactions.get("kinds", {}).get(kind_name, "interact_generic"))


func play_interaction(dialogue_id: String, kind_name: String) -> void:
	var id := interaction_sound(dialogue_id, kind_name)
	if id == "":
		return
	if play(id) != null and id != "dialogue_open":
		_interaction_frame = Engine.get_process_frames()
		_last_immediate = Time.get_ticks_msec()


func item_sound(item_id: String) -> String:
	return String(item_sounds.get(item_id, "item_pickup"))


func _on_item_moved(item_id: String, delta: int, source: String) -> void:
	if _is_quiet():
		return
	if delta > 0 and source == "reward":
		event("reward")
		return
	var id := ""
	if delta > 0:
		id = item_sound(item_id) if source == "pickup" else "item_receive"
	else:
		match source:
			"deliver": id = "item_give"
			"discard": id = "item_discard"
	if id != "" and play(id) != null:
		_last_immediate = Time.get_ticks_msec()


# --- Eventos de jogo ------------------------------------------------------------

## Marco de jogo (missão, descoberta, colecionável...). Vários no mesmo
## quadro viram um só: toca o de maior prioridade. Fora do jogo ou logo
## depois de carregar, nada toca.
func event(id: String) -> void:
	if _is_quiet() or not sounds.has(id):
		return
	if _pending_events.is_empty():
		_flush_events.call_deferred()
	_pending_events.append(id)


func _flush_events() -> void:
	if _pending_events.is_empty():
		return
	var best := ""
	for id in _pending_events:
		if best == "" or int(sounds[id].get("priority", 0)) > int(sounds[best].get("priority", 0)):
			best = id
	_pending_events.clear()
	if Time.get_ticks_msec() - _last_immediate < 150:
		get_tree().create_timer(0.18, true).timeout.connect(play.bind(best))
	else:
		play(best)


func quiet_for(seconds: float) -> void:
	_quiet_until = Time.get_ticks_msec() + int(seconds * 1000.0)
	_pending_events.clear()


func _is_quiet() -> bool:
	return not GameState.in_game or Time.get_ticks_msec() < _quiet_until


func _on_quest_event(type: String, id: String) -> void:
	match type:
		"collection_completed": event("collection_complete")
		"choice_made":
			if not id.contains(":"):
				event("decision")


func _on_dialogue_started(_id: String) -> void:
	_dialogue_lines = 0
	if _interaction_frame != Engine.get_process_frames():
		play("dialogue_open")


func _on_line_shown(_line: Dictionary) -> void:
	_dialogue_lines += 1
	if _dialogue_lines <= 1:
		return
	if played_recently("dialogue_choice", 0.15) or played_recently("decision", 0.15):
		return
	play("dialogue_advance")


# --- Interface automática -------------------------------------------------------

## Todo botão ganha som sem script próprio. Metadados opcionais no botão:
## "sfx" (id do clique; "" silencia) e "sfx_hover" (false desliga o hover).
func _on_node_added(node: Node) -> void:
	if node is BaseButton:
		_hook_button(node as BaseButton)


func _hook_existing(node: Node) -> void:
	if node is BaseButton:
		_hook_button(node as BaseButton)
	for c in node.get_children():
		_hook_existing(c)


func _hook_button(b: BaseButton) -> void:
	if b.has_meta("_sfx_hooked"):
		return
	b.set_meta("_sfx_hooked", true)
	b.pressed.connect(_on_button_pressed.bind(b))
	b.mouse_entered.connect(_on_button_hover.bind(b))
	b.focus_entered.connect(_on_button_focus.bind(b))


func _on_button_pressed(b: BaseButton) -> void:
	var id := String(b.get_meta("sfx", "ui_click"))
	if id != "":
		play(id)


func _on_button_hover(b: BaseButton) -> void:
	if b.disabled or not Settings.ui_hover_sound or not b.get_meta("sfx_hover", true):
		return
	play("ui_hover")


func _on_button_focus(b: BaseButton) -> void:
	if b.disabled or Time.get_ticks_msec() - _nav_time > int(NAV_WINDOW * 1000.0):
		return
	play("ui_focus")


func _input(ev: InputEvent) -> void:
	if not (ev is InputEventKey or ev is InputEventJoypadButton or ev is InputEventJoypadMotion):
		return
	for a in ["ui_up", "ui_down", "ui_left", "ui_right", "ui_focus_next", "ui_focus_prev"]:
		if ev.is_action_pressed(a, true):
			_nav_time = Time.get_ticks_msec()
			return


# --- Ambiente -------------------------------------------------------------------

## Liga o ambiente da região: laço de fundo (troca com fade, nunca dois ao
## mesmo tempo), sons ocasionais em volta do ouvinte e emissores presos ao
## mapa (filhos de `map`, liberados junto com ele).
func set_region(new_region: String, map: Node = null) -> void:
	region_id = new_region
	var def: Dictionary = ambience_defs.get(new_region, {})
	_set_bed(String(def.get("bed", "")))
	_layers.clear()
	var now := Time.get_ticks_msec() / 1000.0
	for l in def.get("layers", []):
		var iv: Array = l.get("interval", [10.0, 20.0])
		_layers.append({"def": l, "next": now + _rng.randf_range(2.0, float(iv[0]))})
	if map != null:
		for e in def.get("emitters", []):
			_add_emitter(map, e)


func stop_ambience() -> void:
	region_id = ""
	_layers.clear()
	_set_bed("")


func current_bed() -> String:
	return _bed_id


func _set_bed(id: String) -> void:
	if id == _bed_id:
		return
	_bed_id = id
	var old := _beds[_bed_index]
	if old.playing:
		var t := create_tween()
		t.tween_property(old, "volume_db", -60.0, BED_FADE)
		t.tween_callback(old.stop)
	if id == "" or not sounds.has(id):
		return
	_bed_index = 1 - _bed_index
	var p := _beds[_bed_index]
	var target := float(sounds[id].get("volume_db", -10.0))
	p.stream = stream(id)
	p.bus = String(sounds[id].get("bus", "Ambience"))
	p.volume_db = -60.0
	p.play(_rng.randf_range(0.0, maxf(p.stream.get_length() - 1.0, 0.0)) if p.stream else 0.0)
	create_tween().tween_property(p, "volume_db", target, BED_FADE)
	history.append({"id": id, "t": Time.get_ticks_msec()})


func _add_emitter(map: Node, e: Dictionary) -> void:
	var id := String(e.get("sound", ""))
	if not sounds.has(id):
		return
	var p := AudioStreamPlayer2D.new()
	p.name = "Ambience_" + id
	p.stream = stream(id)
	p.bus = String(sounds[id].get("bus", "Ambience"))
	p.volume_db = float(sounds[id].get("volume_db", -8.0))
	p.max_distance = float(e.get("max_distance", 150.0))
	p.attenuation = 1.4
	p.position = Vector2(float(e.get("x", 0)), float(e.get("y", 0)))
	p.autoplay = true
	p.add_to_group("ambience_emitter")
	map.add_child(p)


func _process(_delta: float) -> void:
	if _layers.is_empty():
		return
	var now := Time.get_ticks_msec() / 1000.0
	for l in _layers:
		if now < float(l.next):
			continue
		var d: Dictionary = l.def
		var iv: Array = d.get("interval", [10.0, 20.0])
		l.next = now + _rng.randf_range(float(iv[0]), float(iv[1]))
		if get_tree().paused:
			continue
		var options: Array = d.get("sounds", [])
		if options.is_empty():
			continue
		var id := String(options[_rng.randi_range(0, options.size() - 1)])
		var cam := get_viewport().get_camera_2d()
		if cam == null:
			play(id)
			continue
		var spread := float(d.get("spread", 220.0))
		var offset := Vector2(_rng.randf_range(-spread, spread), _rng.randf_range(-spread * 0.6, spread * 0.6))
		play_at(id, cam.get_screen_center_position() + offset, {"max_distance": spread * 2.2})
