class_name InventoryScreen
extends CanvasLayer
## Bolsa do viajante (tecla I): espaços comuns em grade, compartimento de
## itens essenciais (missão) à parte e detalhes do item selecionado.
## Pausa o jogo enquanto aberta. I/Esc fecha; setas percorrem os espaços.

signal closed

const SLOT := Vector2(26, 26)
const COLUMNS := 6

var _grid: GridContainer
var _essentials: HBoxContainer
var _slots_label: Label
var _icon: TextureRect
var _name: Label
var _meta: Label
var _desc: Label
var _note: Label
var _tag_slot: HBoxContainer
var _use_btn: Button
var _discard_btn: Button
var _feedback: Label
var _selected := ""
var _confirm_discard := false


func _ready() -> void:
	layer = 36
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_build()
	Inventory.changed.connect(func(_i, _d): if visible: refresh())


func is_open() -> bool:
	return visible


func open() -> void:
	if not visible:
		AudioManager.play("bag_open")
	visible = true
	get_tree().paused = true
	GameState.block_ui("inventory")
	_selected = ""
	refresh()


func close() -> void:
	if not visible:
		return
	AudioManager.play("bag_close")
	visible = false
	get_tree().paused = false
	GameState.unblock_ui("inventory")
	closed.emit()


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("pause") or event.is_action_pressed("inventory"):
		close()
		get_viewport().set_input_as_handled()


func refresh() -> void:
	for c in _grid.get_children():
		c.queue_free()
	for c in _essentials.get_children():
		c.queue_free()
	var bag := Inventory.bag_entries()
	var first := ""
	for i in Inventory.BAG_SLOTS:
		var e: Dictionary = bag[i] if i < bag.size() else {}
		_grid.add_child(_slot(e))
		if first == "" and not e.is_empty():
			first = String(e.id)
	var ess := Inventory.essential_entries()
	if ess.is_empty():
		_essentials.add_child(UiStyle.label("Nenhum item de missão.", 6, UiStyle.MUTED))
	for e in ess:
		_essentials.add_child(_slot(e))
		if first == "":
			first = String(e.id)
	_slots_label.text = "Espaços: %d/%d" % [Inventory.slots_used(), Inventory.BAG_SLOTS]
	if _selected == "" or Inventory.count(_selected) <= 0:
		_selected = first
	_show_detail(_selected)


func _slot(e: Dictionary) -> Button:
	var b := Button.new()
	b.custom_minimum_size = SLOT
	b.focus_mode = Control.FOCUS_ALL
	b.add_theme_stylebox_override("normal", UiStyle.panel(UiStyle.SAND, UiStyle.BROWN, 1, 1))
	b.add_theme_stylebox_override("hover", UiStyle.panel(Color("#f6e6c2"), UiStyle.GOLD, 1, 1))
	b.add_theme_stylebox_override("focus", UiStyle.panel(Color("#f6e6c2"), UiStyle.GOLD, 1, 1))
	b.add_theme_stylebox_override("pressed", UiStyle.panel(UiStyle.SAND, UiStyle.GOLD, 1, 1))
	if e.is_empty():
		b.disabled = true
		b.add_theme_stylebox_override("disabled", UiStyle.panel(Color(UiStyle.SAND, 0.5), Color(UiStyle.BROWN, 0.5), 1, 1))
		return b
	var id := String(e.id)
	b.tooltip_text = Inventory.display_name(id)
	var tex := TextureRect.new()
	tex.texture = Inventory.icon(id)
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex.scale = Vector2(2, 2)
	tex.position = Vector2(1, 1)
	tex.size = Vector2(12, 12)
	tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(tex)
	if int(e.qty) > 1:
		var q := UiStyle.outlined(str(e.qty), 6)
		q.position = Vector2(15, 15)
		b.add_child(q)
	b.pressed.connect(_show_detail.bind(id))
	b.focus_entered.connect(_show_detail.bind(id))
	return b


func _show_detail(id: String) -> void:
	_selected = id
	_confirm_discard = false
	_feedback.text = ""
	for c in _tag_slot.get_children():
		c.queue_free()
	if id == "" or not Inventory.exists(id):
		_icon.texture = null
		_name.text = "Bolsa vazia"
		_meta.text = ""
		_desc.text = "Itens coletados pelo caminho, recebidos ou necessários para uma missão aparecem aqui."
		_note.text = ""
		_use_btn.visible = false
		_discard_btn.visible = false
		return
	var it := Inventory.item(id)
	_icon.texture = Inventory.icon(id)
	_name.text = String(it.name)
	var cat := String(Inventory.CATEGORY_LABELS.get(it.category, it.category))
	_meta.text = "%s · quantidade: %d%s" % [cat, Inventory.count(id), " · essencial" if Inventory.is_essential(id) else ""]
	_desc.text = String(it.description)
	_note.text = String(it.get("history_note", ""))
	_tag_slot.add_child(UiStyle.classification_tag(String(it.classification)))
	_use_btn.visible = String(it.get("use_text", "")) != ""
	_discard_btn.visible = Inventory.can_discard(id)
	_discard_btn.text = "Descartar 1"


func _on_use() -> void:
	_feedback.text = String(Inventory.item(_selected).get("use_text", ""))


func _on_discard() -> void:
	if not Inventory.can_discard(_selected):
		AudioManager.play("ui_denied")
		return
	if not _confirm_discard:
		_confirm_discard = true
		_discard_btn.text = "Confirmar descarte"
		_feedback.text = "O item descartado não volta ao mapa."
		return
	Inventory.discard(_selected, 1)
	refresh()


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
	book.custom_minimum_size = Vector2(400, 220)
	center.add_child(book)
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 3)
	book.add_child(root)

	var header := HBoxContainer.new()
	root.add_child(header)
	header.add_child(UiStyle.label("BOLSA DO VIAJANTE", 8, UiStyle.BROWN))
	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(sp)
	_slots_label = UiStyle.label("", 7, UiStyle.MUTED)
	header.add_child(_slots_label)
	var close_btn := UiStyle.small_button("Fechar (I)", 7)
	close_btn.pressed.connect(close)
	header.add_child(close_btn)
	root.add_child(HSeparator.new())

	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 6)
	root.add_child(body)
	var left := VBoxContainer.new()
	left.add_theme_constant_override("separation", 3)
	body.add_child(left)
	_grid = GridContainer.new()
	_grid.columns = COLUMNS
	_grid.add_theme_constant_override("h_separation", 2)
	_grid.add_theme_constant_override("v_separation", 2)
	left.add_child(_grid)
	left.add_child(UiStyle.label("ESSENCIAIS (itens de missão, não ocupam espaço)", 6, UiStyle.BROWN))
	_essentials = HBoxContainer.new()
	_essentials.add_theme_constant_override("separation", 2)
	left.add_child(_essentials)
	body.add_child(VSeparator.new())

	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", 2)
	body.add_child(right)
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 4)
	right.add_child(top)
	_icon = TextureRect.new()
	_icon.custom_minimum_size = Vector2(24, 24)
	_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	top.add_child(_icon)
	var tv := VBoxContainer.new()
	tv.add_theme_constant_override("separation", 0)
	tv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(tv)
	_name = UiStyle.label("", 10, UiStyle.INK)
	_meta = UiStyle.label("", 6, UiStyle.MUTED)
	tv.add_child(_name)
	tv.add_child(_meta)
	_tag_slot = HBoxContainer.new()
	_tag_slot.alignment = BoxContainer.ALIGNMENT_END
	top.add_child(_tag_slot)
	_desc = UiStyle.label("", 7, UiStyle.INK, true)
	_desc.custom_minimum_size.x = 170
	right.add_child(_desc)
	_note = UiStyle.label("", 6, UiStyle.BROWN, true)
	_note.custom_minimum_size.x = 170
	right.add_child(_note)
	var gap := Control.new()
	gap.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(gap)
	_feedback = UiStyle.label("", 6, UiStyle.MUTED, true)
	_feedback.custom_minimum_size.x = 170
	right.add_child(_feedback)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_END
	row.add_theme_constant_override("separation", 3)
	right.add_child(row)
	_use_btn = UiStyle.small_button("Usar", 7)
	_use_btn.pressed.connect(_on_use)
	_discard_btn = UiStyle.small_button("Descartar 1", 7)
	_discard_btn.pressed.connect(_on_discard)
	row.add_child(_use_btn)
	row.add_child(_discard_btn)
	root.add_child(UiStyle.label("I/Esc: fechar   Setas: espaços   Itens de missão não podem ser descartados", 6, UiStyle.MUTED))
