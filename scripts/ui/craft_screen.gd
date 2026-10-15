class_name CraftScreen
extends CanvasLayer
## Minijogo de ofício: acertar a faixa com E (interact) hits_needed vezes.
## Aberto por {"craft": id} no fim do diálogo.

signal closed

var craft_id := ""
var _recipe: Dictionary = {}
var _hits := 0
var _marker := 0.0
var _dir := 1.0
var _zone_center := 0.55
var _zone_half := 0.12
var _feedback: Label
var _title: Label
var _hint: Label
var _bar: ColorRect
var _zone: ColorRect
var _cursor: ColorRect
var _hits_label: Label


func _ready() -> void:
	layer = 38
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_build()


func is_open() -> bool:
	return visible


func open(id: String) -> void:
	craft_id = id
	_recipe = Craft.recipe(id)
	var busy := Craft.can_start(id)
	if _recipe.is_empty():
		push_warning("CraftScreen: ofício inexistente %s" % id)
		return
	if busy != "":
		get_tree().call_group("hud", "show_toast", busy)
		return
	_hits = 0
	_marker = 0.0
	_dir = 1.0
	_zone_center = 0.45 + randf() * 0.2
	_title.text = String(_recipe.get("title", "Ofício")).to_upper()
	_hint.text = String(_recipe.get("hint", ""))
	_feedback.text = String(_recipe.get("subtitle", ""))
	_hits_label.text = "Acertos: 0 / %d" % int(_recipe.get("hits_needed", 3))
	visible = true
	get_tree().paused = true
	GameState.block_ui("craft")
	AudioManager.play("ui_confirm")
	_layout_bar()


func close() -> void:
	if not visible:
		return
	visible = false
	get_tree().paused = false
	GameState.unblock_ui("craft")
	closed.emit()


func _build() -> void:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(root)
	var dim := ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0, 0, 0, 0.45)
	root.add_child(dim)
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(300, 0)
	panel.add_theme_stylebox_override("panel", UiStyle.wood_frame())
	root.add_child(panel)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 6)
	panel.add_child(vb)
	_title = UiStyle.label("OFÍCIO", 9, UiStyle.BROWN)
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(_title)
	_feedback = UiStyle.label("", 7, UiStyle.MUTED)
	_feedback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(_feedback)
	_hint = UiStyle.label("", 6, UiStyle.MUTED)
	_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(_hint)
	var bar_wrap := Control.new()
	bar_wrap.custom_minimum_size = Vector2(260, 22)
	vb.add_child(bar_wrap)
	_bar = ColorRect.new()
	_bar.color = Color("3A2A1A")
	_bar.set_anchors_preset(Control.PRESET_FULL_RECT)
	bar_wrap.add_child(_bar)
	_zone = ColorRect.new()
	_zone.color = Color("C8A878")
	bar_wrap.add_child(_zone)
	_cursor = ColorRect.new()
	_cursor.color = Color("F4E6C8")
	_cursor.custom_minimum_size = Vector2(4, 22)
	bar_wrap.add_child(_cursor)
	_hits_label = UiStyle.label("Acertos: 0", 7, UiStyle.BROWN)
	_hits_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(_hits_label)
	var cancel := Button.new()
	cancel.text = "Desistir"
	cancel.set_meta("sfx", "ui_cancel")
	cancel.pressed.connect(close)
	vb.add_child(cancel)


func _layout_bar() -> void:
	var w := 260.0
	_zone.position = Vector2((_zone_center - _zone_half) * w, 0)
	_zone.size = Vector2(_zone_half * 2.0 * w, 22)
	_cursor.position = Vector2(_marker * w - 2.0, 0)
	_cursor.size = Vector2(4, 22)


func _process(delta: float) -> void:
	if not visible:
		return
	_marker += _dir * delta * 0.85
	if _marker >= 1.0:
		_marker = 1.0
		_dir = -1.0
	elif _marker <= 0.0:
		_marker = 0.0
		_dir = 1.0
	_layout_bar()


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("pause"):
		close()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("interact"):
		_try_hit()
		get_viewport().set_input_as_handled()


func _try_hit() -> void:
	var need := int(_recipe.get("hits_needed", 3))
	if absf(_marker - _zone_center) <= _zone_half:
		_hits += 1
		_hits_label.text = "Acertos: %d / %d" % [_hits, need]
		AudioManager.play("interact_ceramic")
		_zone_center = 0.35 + randf() * 0.35
		if _hits >= need:
			var err := Craft.complete(craft_id)
			_feedback.text = String(_recipe.get("done_text", "Pronto.")) if err == "" else err
			close()
	else:
		_feedback.text = "O barro escorregou. Tente de novo."
		AudioManager.play("ui_denied")
