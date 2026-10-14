class_name ScriptureMap
extends CanvasLayer
## Mapa das Escrituras (tecla M): experiências agrupadas por época. O jogador
## não caminha entre épocas; iniciar uma experiência mostra um cartão de
## passagem narrativa e então a registra (WorldManager.start_experience).
## Experiências em planejamento aparecem, mas não são jogáveis.

signal closed
signal atlas_requested

const STATE_LABELS := {
	"planned": "Em planejamento",
	"locked": "Bloqueada",
	"available": "Disponível",
	"active": "Em andamento",
	"completed": "Explorada",
}

var _columns: HBoxContainer
var _detail_title: Label
var _detail_meta: Label
var _detail_text: Label
var _action: Button
var _passage_box: VBoxContainer
var _main_box: VBoxContainer
var _selected := ""
var _passage_for := ""


func _ready() -> void:
	layer = 37
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_build()


func is_open() -> bool:
	return visible


func open(focus: String = "") -> void:
	if not visible:
		AudioManager.play("map_open")
	visible = true
	get_tree().paused = true
	GameState.block_ui("scripture_map")
	_show_main()
	refresh()
	if focus != "":
		select(focus)


func close() -> void:
	if not visible:
		return
	AudioManager.play("map_close")
	visible = false
	get_tree().paused = false
	GameState.unblock_ui("scripture_map")
	closed.emit()


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("pause") or event.is_action_pressed("places_map"):
		close()
	elif event.is_action_pressed("interact") and _passage_for != "":
		_confirm_passage()
	else:
		return
	get_viewport().set_input_as_handled()


func refresh() -> void:
	for c in _columns.get_children():
		c.queue_free()
	var first := ""
	for era in WorldManager.eras_order:
		var col := VBoxContainer.new()
		col.add_theme_constant_override("separation", 2)
		col.custom_minimum_size.x = 100
		_columns.add_child(col)
		col.add_child(UiStyle.label(String(era.label).to_upper(), 7, UiStyle.BROWN))
		for xid in WorldManager.experience_order:
			var x := WorldManager.experience(xid)
			if String(x.get("era", "")) != String(era.id):
				continue
			var state := WorldManager.experience_state(xid)
			var b := UiStyle.small_button("%s\n%s" % [x.title, STATE_LABELS[state]], 6, true)
			b.toggle_mode = true
			b.alignment = HORIZONTAL_ALIGNMENT_LEFT
			b.custom_minimum_size = Vector2(98, 20)
			b.modulate = Color(1, 1, 1, 0.55) if state in ["planned", "locked"] else Color.WHITE
			b.pressed.connect(select.bind(xid))
			b.focus_entered.connect(select.bind(xid))
			b.set_meta("xid", xid)
			col.add_child(b)
			if first == "" or state in ["available", "active"] and WorldManager.experience_state(first) not in ["available", "active"]:
				first = xid
	select(first if _selected == "" else _selected)


func select(xid: String) -> void:
	_selected = xid
	for col in _columns.get_children():
		for b in col.get_children():
			if b is Button:
				b.button_pressed = b.get_meta("xid", "") == xid
	var x := WorldManager.experience(xid)
	if x.is_empty():
		return
	var state := WorldManager.experience_state(xid)
	_detail_title.text = String(x.title)
	_detail_meta.text = "%s · %s · %s" % [Bible.refs(x.get("references", [])), String(x.get("place", "")), STATE_LABELS[state]]
	var text := String(x.get("summary", ""))
	if state == "locked":
		text += "\n\n" + String(x.get("locked_text", ""))
	_detail_text.text = text
	_action.visible = state in ["available", "active"]
	_action.text = "Iniciar esta experiência" if state == "available" else "Continuar"


func _on_action() -> void:
	var state := WorldManager.experience_state(_selected)
	if state == "available" and WorldManager.experience(_selected).has("passage"):
		_show_passage(_selected)
		return
	_start(_selected)


func _start(xid: String) -> void:
	var err := WorldManager.start_experience(xid)
	if err != "":
		_detail_text.text = err
		AudioManager.play("ui_denied")
		return
	close()


func _show_passage(xid: String) -> void:
	_passage_for = xid
	var p: Dictionary = WorldManager.experience(xid).passage
	for c in _passage_box.get_children():
		c.queue_free()
	_passage_box.add_child(UiStyle.label(String(p.get("title", "")), 9, UiStyle.BROWN))
	_passage_box.add_child(UiStyle.label(String(WorldManager.experience(xid).title) + " · " + Bible.refs(WorldManager.experience(xid).get("references", [])), 7, UiStyle.MUTED))
	for line in p.get("lines", []):
		var l := UiStyle.label(String(line), 7, UiStyle.INK, true)
		l.custom_minimum_size.x = 360
		_passage_box.add_child(l)
	var b := UiStyle.small_button("E: continuar", 7)
	b.pressed.connect(_confirm_passage)
	_passage_box.add_child(b)
	_main_box.visible = false
	_passage_box.visible = true
	AudioManager.play("page_turn")


func _confirm_passage() -> void:
	var xid := _passage_for
	_passage_for = ""
	_show_main()
	_start(xid)


func _show_main() -> void:
	_passage_for = ""
	if _main_box:
		_main_box.visible = true
		_passage_box.visible = false


func _build() -> void:
	var dim := ColorRect.new()
	dim.color = Color(UiStyle.SHADOW, 0.55)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var book := PanelContainer.new()
	book.add_theme_stylebox_override("panel", UiStyle.wood_frame())
	book.custom_minimum_size = Vector2(440, 230)
	center.add_child(book)
	var stack := VBoxContainer.new()
	book.add_child(stack)

	_main_box = VBoxContainer.new()
	_main_box.add_theme_constant_override("separation", 3)
	stack.add_child(_main_box)
	var header := HBoxContainer.new()
	_main_box.add_child(header)
	header.add_child(UiStyle.label("MAPA DAS ESCRITURAS", 8, UiStyle.BROWN))
	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(sp)
	var atlas := UiStyle.small_button("Atlas de lugares", 7)
	atlas.pressed.connect(func(): close(); atlas_requested.emit())
	header.add_child(atlas)
	var close_btn := UiStyle.small_button("Fechar (M)", 7)
	close_btn.pressed.connect(close)
	header.add_child(close_btn)
	_main_box.add_child(HSeparator.new())
	_columns = HBoxContainer.new()
	_columns.add_theme_constant_override("separation", 6)
	_main_box.add_child(_columns)
	_main_box.add_child(HSeparator.new())
	_detail_title = UiStyle.label("", 9, UiStyle.INK)
	_detail_meta = UiStyle.label("", 6, UiStyle.MUTED)
	_detail_text = UiStyle.label("", 7, UiStyle.INK, true)
	_detail_text.custom_minimum_size.x = 420
	for l in [_detail_title, _detail_meta, _detail_text]:
		_main_box.add_child(l)
	_action = UiStyle.small_button("", 7)
	_action.size_flags_horizontal = Control.SIZE_SHRINK_END
	_action.pressed.connect(_on_action)
	_main_box.add_child(_action)
	_main_box.add_child(UiStyle.label("Você não caminha entre épocas: cada experiência é uma passagem narrativa identificada.   M/Esc: fechar", 6, UiStyle.MUTED))

	_passage_box = VBoxContainer.new()
	_passage_box.add_theme_constant_override("separation", 4)
	_passage_box.visible = false
	stack.add_child(_passage_box)
