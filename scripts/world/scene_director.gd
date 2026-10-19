class_name SceneDirector
extends Node
## Toca cenas dirigidas (data/scenes, ver SceneDatabase) no mapa atual: o
## jogador assiste e o controle volta no fim. Bloqueia a UI (sem salvar, sem
## menus), Esc pula direto para o estado final e, ao terminar ou pular, aplica
## "on_end" (flags, descobertas, posição do jogador), registra o evento de
## missão scene_finished e emite `scene_finished`. Nunca dá item.

signal scene_started(scene_id: String)
signal scene_finished(scene_id: String, skipped: bool)

const BLOCKER := "scene"
const CAPTION_LAYER := 39
const GLOW_LAYER := 1
const LIGHT_RETURN := 1.2
## Teto de uma espera (s): nenhuma cena fica presa para sempre.
const MAX_WAIT := 120.0
const KIND_LABELS := {"narration": "Narração", "context": "Contexto", "fiction": "Ficção do jogo", "scripture": "Texto bíblico"}
const KIND_COLORS := {"narration": UiStyle.BROWN, "context": UiStyle.MUTED, "fiction": UiStyle.WOOD, "scripture": UiStyle.GOLD}

var database := SceneDatabase.new()
var scene_id := ""
var _scene: Dictionary = {}
var _playing := false
var _token := 0
var _map: GameMap
var _cam: Camera2D
var _fx_root: Node2D
var _glow_layer: CanvasLayer
var _actors: Dictionary = {}
var _effects: Dictionary = {}
var _tweens: Array[Tween] = []
var _loops: Array = []
var _caption_wait := false
var _advance := false
var _caption_until := 0.0
var _clock := 0.0

var _ui: CanvasLayer
var _caption_panel: PanelContainer
var _caption_tag: HBoxContainer
var _caption_text: RichTextLabel
var _caption_ref: Label
var _hint: Label


func _ready() -> void:
	# A cena segue rodando mesmo se algo pausar a árvore (diário, janela sem foco).
	process_mode = Node.PROCESS_MODE_ALWAYS
	database.load_dir()
	for e in database.errors:
		push_error("SceneDirector: " + e)
	_build_ui()


func is_playing() -> bool:
	return _playing


## "" se a cena pode tocar agora neste mapa; senão o motivo.
func refusal(scene: Dictionary, map: GameMap) -> String:
	if _playing:
		return "outra cena em andamento"
	if scene.is_empty():
		return "cena inexistente"
	if map == null or not is_instance_valid(map):
		return "sem mapa"
	if String(scene.get("region", "")) != String(map.region_id):
		return "cena de outra região (%s)" % scene.get("region", "")
	if not ContentPolicy.is_visible(scene):
		return "cena em rascunho"
	if not scene.get("repeatable", false) and QuestManager.has_event("scene_finished", String(scene.id)):
		return "cena já vista"
	return ""


func play(id: String, map: GameMap) -> bool:
	if not database.has_scene(id):
		push_warning("SceneDirector: cena \"%s\" não tocada: cena inexistente" % id)
		return false
	return play_data(database.get_scene(id), map)


func play_data(scene: Dictionary, map: GameMap) -> bool:
	var why := refusal(scene, map)
	if why != "":
		push_warning("SceneDirector: cena \"%s\" não tocada: %s" % [scene.get("id", "?"), why])
		return false
	_scene = scene
	scene_id = String(scene.id)
	_map = map
	_playing = true
	_token += 1
	_clock = 0.0
	GameState.block_ui(BLOCKER)
	_fx_root = Node2D.new()
	_fx_root.name = "SceneFx"
	_map.add_child(_fx_root)
	_glow_layer = CanvasLayer.new()
	_glow_layer.name = "SceneGlow"
	_glow_layer.layer = GLOW_LAYER
	_glow_layer.follow_viewport_enabled = true
	_map.add_child(_glow_layer)
	_ui.visible = true
	_hint.text = "%s   E: avançar legenda%s" % [String(scene.get("title", "")), "   Esc: pular" if scene.get("skippable", true) else ""]
	_hide_caption()
	AudioManager.music.enter_context(self, "scene:" + scene_id)
	scene_started.emit(scene_id)
	_run(_token)
	return true


## Encerra já, aplicando o estado final (o mesmo de pular com Esc).
func skip() -> void:
	_finish(true)


func _input(event: InputEvent) -> void:
	if not _playing:
		return
	if event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		if _scene.get("skippable", true):
			AudioManager.play("menu_close")
			skip()
	elif event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		if _caption_panel.visible:
			_advance = true


func _process(delta: float) -> void:
	if not _playing:
		return
	_clock += delta
	if _caption_panel.visible and not _caption_wait and _clock >= _caption_until:
		_hide_caption()


# --- Execução --------------------------------------------------------------------

func _run(token: int) -> void:
	var steps: Array = _scene.get("steps", [])
	for st in steps:
		if token != _token:
			return
		var type := String(st.get("type", ""))
		var dur := _exec(st)
		if type == "wait" or st.get("wait", false):
			await _sleep(dur, token, type == "caption")
			if type == "caption" and token == _token:
				_hide_caption()
	if token == _token:
		_finish(false)


func _sleep(seconds: float, token: int, caption: bool) -> void:
	_advance = false
	_caption_wait = caption
	var left := clampf(seconds, 0.0, MAX_WAIT)
	while left > 0.0 and token == _token:
		await get_tree().process_frame
		left -= get_process_delta_time()
		if caption and _advance:
			break
	_caption_wait = false
	_advance = false


## Executa um passo e devolve sua duração (s), usada quando "wait" é true.
func _exec(st: Dictionary) -> float:
	match String(st.get("type", "")):
		"camera":
			return _camera(st)
		"actor":
			_actor(st)
		"move":
			var a: SceneActor = _actors.get(String(st.get("actor", "")))
			if a:
				var r: Array = a.walk(st.get("path", []), float(st.get("speed", 30.0)))
				_tweens.append(r[0])
				return float(r[1])
		"remove":
			_remove(String(st.get("actor", "")))
		"pose":
			var a: SceneActor = _actors.get(String(st.get("actor", "")))
			if a:
				a.set_pose(String(st.get("pose", "stand")))
				if st.has("facing"):
					a.set_facing(String(st.facing))
		"tint":
			_map.lighting_locked = true
			_map.set_tint(Color(String(st.color)), float(st.get("time", 0.0)))
			return float(st.get("time", 0.0))
		"effect":
			return _effect(st)
		"caption":
			return _caption(st)
		"sfx":
			var p := AudioManager.play(String(st.get("id", "")))
			if p and AudioManager.sounds.get(String(st.id), {}).get("loop", false):
				_loops.append(p)
		"wait":
			return float(st.get("time", 0.0))
		"player_to":
			_place_player(st)
	return 0.0


func _player() -> Player:
	return get_tree().get_first_node_in_group("player") as Player


func _camera(st: Dictionary) -> float:
	var player := _player()
	if player == null:
		return 0.0
	var time := float(st.get("time", 1.0))
	var base_zoom := player.camera.zoom
	if _cam == null or not is_instance_valid(_cam):
		_cam = Camera2D.new()
		_cam.name = "SceneCamera"
		for side in ["limit_left", "limit_top", "limit_right", "limit_bottom"]:
			_cam.set(side, player.camera.get(side))
		_map.add_child(_cam)
		_cam.global_position = player.camera.get_screen_center_position()
		_cam.zoom = base_zoom
		_cam.make_current()
	var follow := String(st.get("follow", "")) == "player"
	var target := player.global_position if follow else Vector2(float(st.to[0]), float(st.to[1]))
	var zoom := base_zoom * float(st.get("zoom", 1.0 if follow else _cam.zoom.x / base_zoom.x))
	if time <= 0.0:
		_cam.global_position = target
		_cam.zoom = zoom
		if follow:
			_release_camera()
		return 0.0
	var t := create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(_cam, "global_position", target, time)
	t.tween_property(_cam, "zoom", zoom, time)
	if follow:
		t.chain().tween_callback(_release_camera)
	_tweens.append(t)
	return time


func _release_camera() -> void:
	if _cam and is_instance_valid(_cam):
		var player := _player()
		if player:
			player.camera.make_current()
			player.camera.reset_smoothing()
		_cam.queue_free()
	_cam = null


func _actor(st: Dictionary) -> void:
	var id := String(st.get("id", ""))
	var at := Vector2(float(st.at[0]), float(st.at[1]))
	var a: SceneActor = _actors.get(id)
	if a and is_instance_valid(a) and a.sprite_id == String(st.get("sprite", "")):
		a.position = at
		a.set_facing(String(st.get("facing", "")))
		a.set_pose(String(st.get("pose", a.pose)))
		return
	_remove(id)
	a = SceneActor.new()
	a.process_mode = Node.PROCESS_MODE_ALWAYS
	a.setup(id, String(st.get("sprite", "")), at, String(st.get("facing", "down")), String(st.get("pose", "stand")))
	var world := _map.get_node_or_null("World")
	(world if world else _map).add_child(a)
	_actors[id] = a


func _remove(id: String) -> void:
	var ids: Array = _actors.keys() if id == "*" else [id]
	for k in ids:
		var a: Variant = _actors.get(k)
		if a != null and is_instance_valid(a):
			(a as Node).queue_free()
		_actors.erase(k)


func _effect(st: Dictionary) -> float:
	var eff := String(st.get("effect", ""))
	var p: Dictionary = st.get("params", {})
	var key := String(st.get("id", p.get("id", eff)))
	var cur: Variant = _effects.get(key)
	var alive: bool = cur != null and is_instance_valid(cur) and not (cur as Node).is_queued_for_deletion()
	if st.get("on", true) == false:
		_effects.erase(key)
		return (cur as SceneFx).stop(p) if alive else 0.0
	if alive:
		return (cur as SceneFx).update(st.get("at"), p)
	var fx := SceneFx.new()
	fx.process_mode = Node.PROCESS_MODE_ALWAYS
	(_glow_layer if SceneFx.is_glow(eff) else _fx_root).add_child(fx)
	_effects[key] = fx
	return fx.start(key, eff, st.get("at"), p)


func _place_player(p: Dictionary) -> void:
	var player := _player()
	if player == null:
		return
	player.global_position = Vector2(float(p.at[0]), float(p.at[1]))
	player.velocity = Vector2.ZERO
	if p.has("facing"):
		player.face(SceneActor.FACING_VECTORS.get(String(p.facing), Vector2.DOWN))
	if _cam == null:
		player.camera.reset_smoothing()


## Posição final do jogador: on_end.player_to ou o último passo player_to.
func _final_player() -> Dictionary:
	var end: Dictionary = _scene.get("on_end", {})
	if end.get("player_to") is Dictionary:
		return end.player_to
	var last := {}
	for st in _scene.get("steps", []):
		if String(st.get("type", "")) == "player_to":
			last = st
	return last


func _finish(skipped: bool) -> void:
	if not _playing:
		return
	_playing = false
	_token += 1
	for t in _tweens:
		if t and t.is_valid():
			t.kill()
	_tweens.clear()
	_remove("*")
	for k in _effects:
		var fx: Variant = _effects[k]
		if fx != null and is_instance_valid(fx):
			(fx as Node).queue_free()
	_effects.clear()
	for p in _loops:
		if is_instance_valid(p):
			(p as AudioStreamPlayer).stop()
	_loops.clear()
	_hide_caption()
	_ui.visible = false
	var final_pos := _final_player()
	if not final_pos.is_empty():
		_place_player(final_pos)
	_release_camera()
	if is_instance_valid(_fx_root):
		_fx_root.queue_free()
	if is_instance_valid(_glow_layer):
		_glow_layer.queue_free()
	var id := scene_id
	var end: Dictionary = _scene.get("on_end", {})
	for f in end.get("set_flags", []):
		GameState.set_flag(String(f), true)
	for d in end.get("unlock", []):
		Discoveries.unlock(String(d))
	GameState.add_log("scene", id)
	GameState.unblock_ui(BLOCKER)
	AudioManager.music.exit_context(self)
	if is_instance_valid(_map):
		_map.lighting_locked = false
	QuestManager.record_event("scene_finished", id)
	if is_instance_valid(_map):
		_map.refresh_world()
		_map.refresh_lighting(0.0 if skipped else LIGHT_RETURN)
	scene_id = ""
	_scene = {}
	scene_finished.emit(id, skipped)


# --- Legendas ---------------------------------------------------------------------

func _caption(st: Dictionary) -> float:
	for c in _caption_tag.get_children():
		c.queue_free()
	var ref := String(st.get("scripture", ""))
	var kind := "scripture" if ref != "" else String(st.get("kind", "narration"))
	_caption_tag.add_child(UiStyle.tag(KIND_LABELS.get(kind, kind), KIND_COLORS.get(kind, UiStyle.BROWN)))
	var length := 0
	if ref != "":
		var quote := Bible.quote(ref)
		if quote != "":
			_caption_text.text = quote
			length = Bible.quote_plain(ref).length()
		else:
			_caption_text.text = "[i]%s[/i] (texto bíblico indisponível nesta tradução)" % Bible.ref(ref)
			length = 40
		_caption_ref.text = Bible.cite(ref)
		_caption_ref.visible = true
	else:
		_caption_text.text = String(st.get("text", ""))
		length = _caption_text.text.length()
		_caption_ref.visible = false
	var dur := SceneDatabase.caption_time(st, length)
	_caption_until = _clock + dur
	_caption_panel.visible = true
	_caption_panel.reset_size()
	return dur


func _hide_caption() -> void:
	if _caption_panel:
		_caption_panel.visible = false


func _build_ui() -> void:
	_ui = CanvasLayer.new()
	_ui.name = "SceneUI"
	_ui.layer = CAPTION_LAYER
	_ui.visible = false
	add_child(_ui)
	_caption_panel = PanelContainer.new()
	_caption_panel.add_theme_stylebox_override("panel", UiStyle.panel(Color(UiStyle.PARCHMENT, 0.96), UiStyle.BROWN, 1, 5))
	_caption_panel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_caption_panel.offset_left = -190
	_caption_panel.offset_right = 190
	_caption_panel.offset_top = -64
	_caption_panel.offset_bottom = -18
	_caption_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_caption_panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_caption_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui.add_child(_caption_panel)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 2)
	_caption_panel.add_child(vb)
	_caption_tag = HBoxContainer.new()
	vb.add_child(_caption_tag)
	_caption_text = UiStyle.rich(9)
	_caption_text.custom_minimum_size.x = 368
	vb.add_child(_caption_text)
	_caption_ref = UiStyle.label("", 6, UiStyle.BROWN)
	_caption_ref.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	vb.add_child(_caption_ref)
	_hint = UiStyle.outlined("", 6, UiStyle.PARCHMENT, 3)
	_hint.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_hint.offset_left = -300
	_hint.offset_top = -13
	_hint.offset_right = -6
	_hint.offset_bottom = -3
	_hint.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_ui.add_child(_hint)
	_caption_panel.visible = false
