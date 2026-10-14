extends CanvasLayer
## Diário do viajante: Minha jornada, Escrituras, Personagens, Lugares e Linha
## do tempo. Pausa o jogo enquanto aberto. Conteúdo montado por JournalContent.
## J/Esc fecha, Tab troca de seção, setas percorrem a lista.

signal closed
signal presentation_requested(presentation_id: String)

var tab := "journey"
var _entries: Array = []
var _selected := -1
var _tab_buttons := {}
var _list: VBoxContainer
var _list_scroll: ScrollContainer
var _detail: RichTextLabel
var _detail_scroll: ScrollContainer
var _tag_slot: HBoxContainer
var _action_btn: Button


func _ready() -> void:
	layer = 35
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_build()


func is_open() -> bool:
	return visible


func open(new_tab: String = "journey", focus: String = "") -> void:
	if not (new_tab in JournalContent.TABS):
		new_tab = "journey"
	if not visible:
		AudioManager.play("journal_open")
	visible = true
	get_tree().paused = true
	GameState.block_ui("journal")
	show_tab(new_tab, focus)


func close() -> void:
	if not visible:
		return
	AudioManager.play("journal_close")
	visible = false
	get_tree().paused = false
	GameState.unblock_ui("journal")
	closed.emit()


func show_tab(new_tab: String, focus: String = "") -> void:
	if visible and new_tab != tab and not AudioManager.played_recently("journal_open", 0.1):
		AudioManager.play("page_turn")
	tab = new_tab
	for t in _tab_buttons:
		_tab_buttons[t].button_pressed = t == tab
	_entries = JournalContent.build(tab)
	for c in _list.get_children():
		_list.remove_child(c)
		c.queue_free()
	for i in _entries.size():
		var e: Dictionary = _entries[i]
		if e.get("header", false):
			var h := UiStyle.label(String(e.title), 6, UiStyle.BROWN)
			h.custom_minimum_size = Vector2(130, 11)
			_list.add_child(h)
			continue
		var b := UiStyle.small_button(String(e.title), 7, true)
		b.toggle_mode = true
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		b.custom_minimum_size = Vector2(130, 13)
		b.tooltip_text = String(e.get("subtitle", ""))
		b.pressed.connect(select.bind(i))
		b.focus_entered.connect(select.bind(i))
		_list.add_child(b)
	var idx := -1
	for i in _entries.size():
		if String(_entries[i].id) == focus or (idx < 0 and not _entries[i].get("header", false)):
			idx = i
	if idx < 0:
		return
	select(idx)
	(_list.get_child(idx) as Button).grab_focus.call_deferred()


func select(i: int) -> void:
	if i < 0 or i >= _entries.size() or _entries[i].get("header", false):
		return
	_selected = i
	for j in _list.get_child_count():
		var b := _list.get_child(j) as Button
		if b:
			b.button_pressed = j == i
	var e: Dictionary = _entries[i]
	_detail.text = String(e.text)
	for c in _tag_slot.get_children():
		c.queue_free()
	if String(e.get("tag", "")) != "":
		_tag_slot.add_child(UiStyle.classification_tag(String(e.tag)))
	var action: Dictionary = e.get("action", {})
	_action_btn.visible = not action.is_empty()
	_action_btn.text = "E: " + String(action.get("label", ""))
	_detail_scroll.scroll_vertical = 0


func selected_entry() -> Dictionary:
	return _entries[_selected] if _selected >= 0 and _selected < _entries.size() else {}


## Em _input para que Tab troque a seção em vez de mover o foco entre botões.
func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("pause") or event.is_action_pressed("journal"):
		close()
	elif event.is_action_pressed("toggle_hud"):
		var i := JournalContent.TABS.find(tab)
		var step := -1 if (event is InputEventKey and event.shift_pressed) else 1
		show_tab(JournalContent.TABS[wrapi(i + step, 0, JournalContent.TABS.size())])
	elif event.is_action_pressed("bible_context"):
		show_tab("scriptures")
	elif event.is_action_pressed("places_map"):
		show_tab("places")
	elif event.is_action_pressed("interact") and not selected_entry().get("action", {}).is_empty():
		_on_action()
	else:
		return
	get_viewport().set_input_as_handled()


func _on_action() -> void:
	var action: Dictionary = selected_entry().get("action", {})
	if action.has("presentation"):
		close()
		presentation_requested.emit(String(action.presentation))
	elif action.has("track"):
		var focus := String(selected_entry().id)
		QuestManager.set_tracked(String(action.track))
		AudioManager.play("objective_update")
		show_tab(tab, focus)


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
	book.custom_minimum_size = Vector2(456, 250)
	center.add_child(book)
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 3)
	book.add_child(root)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 2)
	root.add_child(header)
	header.add_child(UiStyle.label("DIÁRIO", 8, UiStyle.BROWN))
	var gap := Control.new()
	gap.custom_minimum_size.x = 4
	header.add_child(gap)
	for t in JournalContent.TABS:
		var b := UiStyle.small_button(JournalContent.TAB_LABELS[t], 7)
		b.toggle_mode = true
		b.set_meta("sfx", "")
		b.pressed.connect(show_tab.bind(t))
		header.add_child(b)
		_tab_buttons[t] = b
	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(sp)
	var close_btn := UiStyle.small_button("Fechar (J)", 7)
	close_btn.pressed.connect(close)
	header.add_child(close_btn)
	root.add_child(HSeparator.new())

	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 6)
	root.add_child(body)
	_list_scroll = ScrollContainer.new()
	_list_scroll.custom_minimum_size = Vector2(136, 0)
	_list_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(_list_scroll)
	_list = VBoxContainer.new()
	_list.add_theme_constant_override("separation", 1)
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list_scroll.add_child(_list)
	body.add_child(VSeparator.new())

	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", 2)
	body.add_child(right)
	_tag_slot = HBoxContainer.new()
	_tag_slot.alignment = BoxContainer.ALIGNMENT_END
	_tag_slot.custom_minimum_size.y = 9
	right.add_child(_tag_slot)
	_detail_scroll = ScrollContainer.new()
	_detail_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_detail_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	right.add_child(_detail_scroll)
	_detail = UiStyle.rich(8)
	_detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_detail_scroll.add_child(_detail)
	_action_btn = UiStyle.small_button("", 7)
	_action_btn.size_flags_horizontal = Control.SIZE_SHRINK_END
	_action_btn.pressed.connect(_on_action)
	right.add_child(_action_btn)

	root.add_child(UiStyle.label("Tab: seção   Setas: lista   J/Esc: fechar", 6, UiStyle.MUTED))
