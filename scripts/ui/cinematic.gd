extends CanvasLayer
## Cenas curtas guiadas por dados: o prólogo (data/story/prologues.json) e as
## apresentações de passagens bíblicas (data/bible/presentations.json).
## E/Espaço/clique avança, Esc pula. O controle do jogador fica bloqueado.

signal finished(kind: String, id: String, skipped: bool)

const FADE := 0.45
const PAN_TIME := 1.6
const ADVANCE_COOLDOWN := 0.25

var kind := ""
var content_id := ""
var _steps: Array = []
var _index := -1
var _map: Node = null
var _cam: Camera2D = null
var _cooldown := 0.0
var _busy := false

var _bg: ColorRect
var _title_box: VBoxContainer
var _place_box: VBoxContainer
var _text_panel: PanelContainer
var _text_label: RichTextLabel
var _text_ref: Label
var _objective_panel: PanelContainer
var _objective_box: VBoxContainer
var _slide_panel: PanelContainer
var _slide_box: VBoxContainer
var _hint: Label


func _ready() -> void:
	layer = 40
	visible = false
	_build()


func is_playing() -> bool:
	return visible


func play_prologue(prologue: Dictionary, map: Node) -> void:
	_map = map
	_begin("prologue", String(prologue.get("id", "")), prologue.get("steps", []))
	_bg.color.a = 1.0


func play_presentation(pres: Dictionary) -> void:
	_map = null
	var steps: Array = []
	for s in pres.get("steps", []):
		var st: Dictionary = s.duplicate()
		st["type"] = "slide"
		st["pres_title"] = pres.get("title", "")
		st["classification"] = pres.get("classification", "")
		steps.append(st)
	_begin("presentation", String(pres.get("id", "")), steps)
	_bg.color.a = 0.0
	create_tween().tween_property(_bg, "color:a", 0.6, FADE)


func _begin(k: String, id: String, steps: Array) -> void:
	kind = k
	content_id = id
	_steps = steps
	_index = -1
	visible = true
	GameState.block_ui("cinematic")
	AudioManager.music.enter_context(self, "%s:%s" % [k, id])
	_hide_all()
	_next()


func _process(delta: float) -> void:
	_cooldown = maxf(_cooldown - delta, 0.0)


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		AudioManager.play("menu_close")
		_finish(true)
		return
	var advance := event.is_action_pressed("interact")
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		advance = true
	if advance:
		get_viewport().set_input_as_handled()
		if _cooldown <= 0.0 and not _busy:
			AudioManager.play("page_turn" if kind == "presentation" else "dialogue_advance")
			_next()


func _next() -> void:
	_cooldown = ADVANCE_COOLDOWN
	_index += 1
	if _index >= _steps.size():
		_finish(false)
		return
	_show_step(_steps[_index])


func _show_step(step: Dictionary) -> void:
	var type := String(step.get("type", "text"))
	if step.has("camera"):
		_focus_camera(String(step.camera))
	_hide_all()
	match type:
		"title":
			_show_title(step)
		"reveal":
			_busy = true
			var t := create_tween()
			t.tween_property(_bg, "color:a", 0.0, 1.2)
			t.tween_callback(func():
				_busy = false
				_next())
		"place":
			_show_place(step)
		"text":
			_show_text(step)
		"objective":
			_show_objective(step)
		"slide":
			_show_slide(step)
	_hint.text = "E: continuar   Esc: pular" if kind == "prologue" else "E: continuar   Esc: fechar"
	_hint.visible = type != "reveal"


func _finish(skipped: bool) -> void:
	if not visible:
		return
	visible = false
	_hide_all()
	_release_camera()
	GameState.unblock_ui("cinematic")
	AudioManager.music.exit_context(self)
	finished.emit(kind, content_id, skipped)


# --- Passos ------------------------------------------------------------------

func _hide_all() -> void:
	for n in [_title_box, _place_box, _text_panel, _objective_panel, _slide_panel]:
		n.visible = false


func _fade_in(node: CanvasItem) -> void:
	node.visible = true
	node.modulate.a = 0.0
	create_tween().tween_property(node, "modulate:a", 1.0, FADE)


func _show_title(step: Dictionary) -> void:
	for c in _title_box.get_children():
		c.queue_free()
	_title_box.add_child(UiStyle.outlined(String(step.get("title", "")), 22, UiStyle.GOLD, 6))
	var t := create_tween()
	for line in step.get("lines", []):
		var l := UiStyle.outlined(String(line), 8, UiStyle.PARCHMENT, 3)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.custom_minimum_size.x = 340
		l.modulate.a = 0.0
		_title_box.add_child(l)
		t.tween_property(l, "modulate:a", 1.0, 0.8)
	for c in _title_box.get_children():
		if c is Label:
			c.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_fade_in(_title_box)


func _show_place(step: Dictionary) -> void:
	for c in _place_box.get_children():
		c.queue_free()
	var t := UiStyle.outlined(String(step.get("title", "")), 18, UiStyle.PARCHMENT, 5)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var s := UiStyle.outlined(String(step.get("subtitle", "")), 8, UiStyle.SAND, 3)
	s.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_place_box.add_child(t)
	_place_box.add_child(s)
	_fade_in(_place_box)


func _show_text(step: Dictionary) -> void:
	var lines: Array = step.get("lines", [])
	_text_label.text = "\n".join(PackedStringArray(lines.map(func(l): return String(l))))
	var ref := String(step.get("reference", ""))
	_text_ref.text = "Referência: " + Bible.ref(ref) if ref != "" else ""
	_text_ref.visible = ref != ""
	_text_panel.reset_size()
	_fade_in(_text_panel)


func _show_objective(step: Dictionary) -> void:
	for c in _objective_box.get_children():
		c.queue_free()
	_objective_box.add_child(UiStyle.label(String(step.get("title", "Sua jornada")).to_upper(), 7, UiStyle.BROWN))
	for line in step.get("lines", []):
		_objective_box.add_child(UiStyle.label(String(line), 9, UiStyle.INK, true))
	_objective_panel.reset_size()
	_fade_in(_objective_panel)


func _show_slide(step: Dictionary) -> void:
	for c in _slide_box.get_children():
		c.queue_free()
	var head := HBoxContainer.new()
	head.add_child(UiStyle.label(String(step.get("pres_title", "")).to_upper(), 6, UiStyle.BROWN))
	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(sp)
	if String(step.get("classification", "")) != "":
		head.add_child(UiStyle.classification_tag(String(step.classification)))
	_slide_box.add_child(head)
	var heading := UiStyle.label(String(step.get("heading", "")), 11, UiStyle.INK)
	heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_slide_box.add_child(heading)
	var scripture := String(step.get("scripture", ""))
	var quote := Bible.quote(scripture) if scripture != "" else ""
	if quote != "":
		var q := UiStyle.rich(9)
		q.custom_minimum_size.x = 320
		q.text = quote
		_slide_box.add_child(q)
		var cite := UiStyle.label(Bible.cite(scripture), 6, UiStyle.BROWN)
		cite.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		_slide_box.add_child(cite)
		_slide_box.add_child(UiStyle.label("Nota: " + String(step.get("text", "")), 7, UiStyle.MUTED, true))
	else:
		var ref := String(step.get("reference", ""))
		if ref != "":
			_slide_box.add_child(UiStyle.label(Bible.ref(ref), 7, UiStyle.BROWN))
		_slide_box.add_child(UiStyle.label(String(step.get("text", "")), 8, UiStyle.INK, true))
	if step.get("credit", false) and Bible.credit() != "":
		_slide_box.add_child(UiStyle.label(Bible.credit(), 6, UiStyle.MUTED, true))
	var sp2 := Control.new()
	sp2.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_slide_box.add_child(sp2)
	_slide_box.add_child(UiStyle.label("%d / %d" % [_index + 1, _steps.size()], 6, UiStyle.MUTED))
	_fade_in(_slide_panel)


# --- Câmera ------------------------------------------------------------------

func _focus_camera(target: String) -> void:
	if _map == null or not is_instance_valid(_map):
		return
	var player := get_tree().get_first_node_in_group("player") as Player
	if player == null:
		return
	var pos := player.global_position
	if target != "player":
		var node := _find_target(target)
		if node:
			pos = node.global_position
	if _cam == null:
		_cam = Camera2D.new()
		_cam.name = "CinematicCamera"
		for side in ["limit_left", "limit_top", "limit_right", "limit_bottom"]:
			_cam.set(side, player.camera.get(side))
		_map.add_child(_cam)
		_cam.global_position = pos
		_cam.make_current()
		return
	var t := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(_cam, "global_position", pos, PAN_TIME)


## Alvo por id de diálogo de um Interactable (ex.: "well" -> well_examine).
func _find_target(target: String) -> Node2D:
	var dialogue := "well_examine" if target == "well" else target
	for it in get_tree().get_nodes_in_group("interactable"):
		if (it as Interactable).dialogue_id == dialogue:
			return it
	return null


func _release_camera() -> void:
	if _cam and is_instance_valid(_cam):
		var player := get_tree().get_first_node_in_group("player") as Player
		if player:
			player.camera.make_current()
			player.camera.reset_smoothing()
		_cam.queue_free()
	_cam = null


# --- Construção --------------------------------------------------------------

func _build() -> void:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(root)
	_bg = ColorRect.new()
	_bg.color = Color(UiStyle.SHADOW, 1.0)
	_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_bg)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(center)
	_title_box = VBoxContainer.new()
	_title_box.add_theme_constant_override("separation", 8)
	center.add_child(_title_box)

	_place_box = VBoxContainer.new()
	_place_box.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_place_box.offset_left = -200
	_place_box.offset_right = 200
	_place_box.offset_top = 46
	_place_box.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_place_box.add_theme_constant_override("separation", 2)
	_place_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_place_box)

	_text_panel = PanelContainer.new()
	_text_panel.add_theme_stylebox_override("panel", UiStyle.panel(Color(UiStyle.PARCHMENT, 0.97), UiStyle.BROWN, 1, 5))
	_text_panel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_text_panel.offset_left = -180
	_text_panel.offset_right = 180
	_text_panel.offset_top = -60
	_text_panel.offset_bottom = -20
	_text_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_text_panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	root.add_child(_text_panel)
	var tb := VBoxContainer.new()
	tb.add_theme_constant_override("separation", 3)
	_text_panel.add_child(tb)
	_text_label = UiStyle.rich(9)
	_text_label.custom_minimum_size.x = 348
	tb.add_child(_text_label)
	_text_ref = UiStyle.label("", 7, UiStyle.BROWN)
	tb.add_child(_text_ref)

	var center2 := CenterContainer.new()
	center2.set_anchors_preset(Control.PRESET_FULL_RECT)
	center2.offset_bottom = -110
	center2.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(center2)
	_objective_panel = PanelContainer.new()
	_objective_panel.add_theme_stylebox_override("panel", UiStyle.wood_frame())
	_objective_panel.custom_minimum_size = Vector2(260, 0)
	center2.add_child(_objective_panel)
	_objective_box = VBoxContainer.new()
	_objective_box.add_theme_constant_override("separation", 4)
	_objective_panel.add_child(_objective_box)

	var center3 := CenterContainer.new()
	center3.set_anchors_preset(Control.PRESET_FULL_RECT)
	center3.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(center3)
	_slide_panel = PanelContainer.new()
	_slide_panel.add_theme_stylebox_override("panel", UiStyle.wood_frame())
	_slide_panel.custom_minimum_size = Vector2(340, 150)
	center3.add_child(_slide_panel)
	_slide_box = VBoxContainer.new()
	_slide_box.add_theme_constant_override("separation", 4)
	_slide_panel.add_child(_slide_box)

	_hint = UiStyle.outlined("", 7, UiStyle.PARCHMENT, 3)
	_hint.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_hint.offset_left = -170
	_hint.offset_top = -14
	_hint.offset_right = -6
	_hint.offset_bottom = -3
	_hint.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	root.add_child(_hint)
	_hide_all()
