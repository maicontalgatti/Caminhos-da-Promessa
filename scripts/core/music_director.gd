extends Node
## Música temática: escolhe e toca, baixinho, a lista de faixas do momento
## (data/audio/music.json). Filho do AudioManager (`AudioManager.music`), que
## continua sendo o único ponto de entrada do áudio (ADR-026, ADR-029).
##
## Ordem de escolha: cena dirigida > apresentação bíblica / prólogo > tela
## aberta > missão principal em foco > região > menu. Quem abre um momento
## chama `enter_context(dono, chave)` e, ao fechar, `exit_context(dono)`.
## As faixas tocam embaralhadas e sem repetir a anterior, com silêncio entre
## elas; trocas de momento fazem fade; diálogos e marcos abaixam o volume.
## Documentação: docs/audio.md, "Música temática".

signal track_started(track_id: String)
signal cue_changed(cue: String)

const MANIFEST := "res://data/audio/music.json"
const AUDIO_DIR := "res://assets/audio"
const BUS := "Music"
## Intervalo entre reavaliações do momento (s).
const CHECK_INTERVAL := 0.25
const SILENT := 0.0001

var tracks: Dictionary = {}
var cues: Dictionary = {}
var rules: Dictionary = {}
var errors: PackedStringArray = []
## Desligado, não começa faixas novas (os testes usam).
var enabled := true
## Chave do momento atual ("region:canaan_village", "scene:...", "menu"...).
var current_cue := ""
var current_list: Array[String] = []
var current_track := ""
## Faixas iniciadas [{id, cue, t}] (diagnóstico e testes).
var history: Array = []

var _players: Array[AudioStreamPlayer] = []
var _active := 0
var _gain: Array[float] = [0.0, 0.0]
var _gain_target: Array[float] = [0.0, 0.0]
var _gain_rate: Array[float] = [1.0, 1.0]
var _track_db: Array[float] = [0.0, 0.0]
var _duck := 1.0
var _contexts: Array = []
var _event_duck_until := 0
## Momento (msec) de começar a próxima faixa; -1 = nada agendado.
var _next_start := -1
var _bag: Array[String] = []
var _last_played := ""
var _check_t := 0.0
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_rng.randomize()
	load_manifest()
	for i in 2:
		var p := AudioStreamPlayer.new()
		p.name = "Music%d" % i
		p.bus = BUS
		p.volume_db = linear_to_db(SILENT)
		p.finished.connect(_on_player_finished.bind(i))
		add_child(p)
		_players.append(p)
	var am := get_parent()
	if am != null and am.has_signal("played"):
		am.played.connect(_on_sound_played)


func load_manifest() -> void:
	errors.clear()
	var data: Variant = JsonUtil.read_file(MANIFEST)
	if not (data is Dictionary):
		errors.append("manifesto de música ausente ou inválido: " + MANIFEST)
		return
	rules = data
	tracks = {}
	for id in data.get("tracks", {}):
		if not String(id).begins_with("_"):
			tracks[id] = data.tracks[id]
	cues = data.get("cues", {})
	for id in tracks:
		if file_of(String(id)) == "":
			errors.append("faixa %s: arquivo ausente (%s/%s.ogg ou .wav)" % [id, AUDIO_DIR, tracks[id].get("path", id)])
	for key in all_cue_keys():
		for item in raw_cue(key):
			var s := String(item)
			if s.begins_with("theme:"):
				if tracks_with_theme(s.substr(6)).is_empty():
					errors.append("momento %s: nenhuma faixa com o tema \"%s\"" % [key, s.substr(6)])
			elif not tracks.has(s):
				errors.append("momento %s: faixa inexistente \"%s\"" % [key, s])
	for e in errors:
		push_error("MusicDirector: " + e)


func rule(key: String, default: Variant) -> Variant:
	return rules.get(key, default)


## Caminho do arquivo da faixa (.ogg tem preferência sobre .wav), ou "".
func file_of(id: String) -> String:
	var base := "%s/%s" % [AUDIO_DIR, tracks.get(id, {}).get("path", "music/" + id)]
	for ext in [".ogg", ".wav"]:
		if ResourceLoader.exists(base + ext):
			return base + ext
	return ""


func tracks_with_theme(theme: String) -> Array[String]:
	var out: Array[String] = []
	for id in tracks:
		if theme in tracks[id].get("themes", []):
			out.append(String(id))
	return out


# --- Momentos -------------------------------------------------------------------

## Todas as chaves com lista definida ("menu", "region:x", "scene:y"...).
func all_cue_keys() -> Array[String]:
	var out: Array[String] = []
	if cues.has("menu"):
		out.append("menu")
	for group in ["regions", "quests", "contexts", "scenes", "presentations", "prologues"]:
		for k in cues.get(group, {}):
			if not String(k).begins_with("_"):
				out.append("%s:%s" % [_prefix(group), k])
	return out


func _prefix(group: String) -> String:
	return {"regions": "region", "quests": "quest", "contexts": "context", "scenes": "scene",
		"presentations": "presentation", "prologues": "prologue"}[group]


func _group(prefix: String) -> String:
	return {"region": "regions", "quest": "quests", "context": "contexts", "scene": "scenes",
		"presentation": "presentations", "prologue": "prologues"}.get(prefix, "")


func has_cue(key: String) -> bool:
	if key == "menu":
		return cues.has("menu")
	var parts := key.split(":", true, 1)
	if parts.size() < 2:
		return false
	return cues.get(_group(parts[0]), {}).has(parts[1])


## Lista como está no manifesto (com "theme:...").
func raw_cue(key: String) -> Array:
	if key == "menu":
		return cues.get("menu", [])
	var parts := key.split(":", true, 1)
	if parts.size() < 2:
		return []
	var v: Variant = cues.get(_group(parts[0]), {}).get(parts[1], [])
	return v if v is Array else []


## Faixas do momento, com os temas expandidos e sem repetição.
func cue_tracks(key: String) -> Array[String]:
	var out: Array[String] = []
	for item in raw_cue(key):
		var s := String(item)
		var ids: Array[String] = []
		if s.begins_with("theme:"):
			ids = tracks_with_theme(s.substr(6))
		else:
			ids.append(s)
		for id in ids:
			if tracks.has(id) and not (id in out):
				out.append(id)
	return out


## Abre um momento (cena, apresentação, tela). O mais recente vale. O dono é
## lembrado por referência fraca: se sumir sem fechar, o momento cai sozinho.
func enter_context(owner: Object, key: String) -> void:
	exit_context(owner)
	_contexts.append({"owner": weakref(owner), "key": key})
	_reevaluate()


func exit_context(owner: Object) -> void:
	for i in range(_contexts.size() - 1, -1, -1):
		if _contexts[i].owner.get_ref() == owner:
			_contexts.remove_at(i)
	_reevaluate()


func clear_contexts() -> void:
	_contexts.clear()


## Chave do momento que vale agora (ver ordem no topo do arquivo).
func resolve() -> String:
	for i in range(_contexts.size() - 1, -1, -1):
		var c: Dictionary = _contexts[i]
		var o: Object = c.owner.get_ref()
		if o == null or (o is Node and not is_instance_valid(o)):
			_contexts.remove_at(i)
			continue
	# Contexto mais forte primeiro (cena > apresentação/prólogo > tela), e,
	# dentro do mesmo nível, o mais recente.
	for prefix in ["scene", "presentation", "prologue", "context"]:
		for i in range(_contexts.size() - 1, -1, -1):
			var key := String(_contexts[i].key)
			if key.begins_with(prefix + ":") and has_cue(key):
				return key
	if not GameState.in_game:
		return "menu" if has_cue("menu") else ""
	var q := QuestManager.primary_quest()
	if q != "" and has_cue("quest:" + q):
		return "quest:" + q
	var r := String(AudioManager.region_id)
	if r != "" and has_cue("region:" + r):
		return "region:" + r
	return ""


func _reevaluate() -> void:
	if is_inside_tree():
		apply_cue(resolve())


## Troca para o momento `key`. Se a faixa que toca também está na nova lista,
## ela continua; senão sai em fade e a nova começa em seguida.
func apply_cue(key: String) -> void:
	if key == current_cue:
		return
	current_cue = key
	current_list = cue_tracks(key)
	_bag.clear()
	cue_changed.emit(key)
	if current_track != "" and current_track in current_list:
		return
	var was_playing := current_track != ""
	_fade_out_all(float(rule("fade_out", 2.5)))
	current_track = ""
	if current_list.is_empty():
		_next_start = -1
		return
	var gap: Array = rule("first_gap", [0.5, 2.0])
	var wait := float(rule("fade_out", 2.5)) * 0.6 if was_playing else _rng.randf_range(float(gap[0]), float(gap[1]))
	_next_start = Time.get_ticks_msec() + int(wait * 1000.0)


# --- Reprodução -----------------------------------------------------------------

## Próxima faixa da lista: sorteio sem repetir até esgotar ("saco"), e nunca a
## mesma duas vezes seguidas.
func pick_next() -> String:
	if current_list.is_empty():
		return ""
	if _bag.is_empty():
		_bag = current_list.duplicate()
		_bag.shuffle()
		if _bag.size() > 1 and _bag[0] == _last_played:
			_bag.push_back(_bag.pop_front())
	return _bag.pop_front()


func start_track(id: String) -> bool:
	var path := file_of(id)
	if path == "":
		return false
	var s: AudioStream = load(path)
	if s == null:
		return false
	if s is AudioStreamWAV:
		(s as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_DISABLED
	elif "loop" in s:
		s.set("loop", false)
	_fade_out_all(float(rule("fade_out", 2.5)))
	_active = 1 - _active
	var p := _players[_active]
	p.stop()
	p.stream = s
	_track_db[_active] = float(tracks[id].get("volume_db", -14.0))
	_gain[_active] = 0.0
	_fade(_active, 1.0, float(rule("fade_in", 4.0)))
	_update_volumes()
	p.play()
	current_track = id
	_last_played = id
	_next_start = -1
	history.append({"id": id, "cue": current_cue, "t": Time.get_ticks_msec()})
	if history.size() > 40:
		history.pop_front()
	track_started.emit(id)
	return true


func stop_music(fade: float = 0.0) -> void:
	current_track = ""
	_next_start = -1
	if fade <= 0.0:
		for i in 2:
			_players[i].stop()
			_gain[i] = 0.0
			_gain_target[i] = 0.0
		_update_volumes()
	else:
		_fade_out_all(fade)


## Para tudo, esquece o momento e solta os arquivos (sair do jogo, testes).
func reset() -> void:
	stop_music()
	for p in _players:
		p.stream = null
	current_cue = ""
	current_list.clear()
	_bag.clear()
	_contexts.clear()
	_last_played = ""
	_event_duck_until = 0
	_duck = 1.0


func is_playing() -> bool:
	return current_track != "" and _players[_active].playing


func _fade(i: int, target: float, seconds: float) -> void:
	_gain_target[i] = target
	_gain_rate[i] = absf(target - _gain[i]) / maxf(seconds, 0.01)


func _fade_out_all(seconds: float) -> void:
	for i in 2:
		if _players[i].playing:
			_fade(i, 0.0, seconds)


func _on_player_finished(i: int) -> void:
	if i != _active or current_track == "":
		return
	track_finished()


## Fim natural da faixa: silêncio sorteado e a próxima da lista.
func track_finished() -> void:
	current_track = ""
	if current_list.is_empty():
		return
	var gap: Array = rule("playlist_gap", [20.0, 40.0])
	_next_start = Time.get_ticks_msec() + int(_rng.randf_range(float(gap[0]), float(gap[1])) * 1000.0)


# --- Volume ---------------------------------------------------------------------

## Volume relativo pedido agora: diálogo e marcos abaixam a música.
func duck_target() -> float:
	var db := 0.0
	if DialogueManager.is_active():
		db = minf(db, float(rule("duck_db", -6.0)))
	if Time.get_ticks_msec() < _event_duck_until:
		db = minf(db, float(rule("event_duck_db", -8.0)))
	return db_to_linear(db)


func _on_sound_played(id: String) -> void:
	if id in rule("duck_events", []):
		_event_duck_until = Time.get_ticks_msec() + int(float(rule("event_duck_hold", 2.2)) * 1000.0)


func _update_volumes() -> void:
	for i in 2:
		_players[i].volume_db = _track_db[i] + linear_to_db(maxf(_gain[i] * _duck, SILENT))


func _process(delta: float) -> void:
	_check_t -= delta
	if _check_t <= 0.0:
		_check_t = CHECK_INTERVAL
		apply_cue(resolve())
	var want := duck_target()
	var step := delta / maxf(float(rule("duck_fade", 0.6)), 0.01)
	_duck = move_toward(_duck, want, step)
	for i in 2:
		if _gain[i] != _gain_target[i]:
			_gain[i] = move_toward(_gain[i], _gain_target[i], _gain_rate[i] * delta)
			if _gain[i] <= 0.0 and _gain_target[i] <= 0.0 and i != _active:
				_players[i].stop()
			elif _gain[i] <= 0.0 and _gain_target[i] <= 0.0 and current_track == "":
				_players[i].stop()
	_update_volumes()
	if enabled and _next_start >= 0 and Time.get_ticks_msec() >= _next_start:
		var id := pick_next()
		if id == "" or not start_track(id):
			_next_start = -1

