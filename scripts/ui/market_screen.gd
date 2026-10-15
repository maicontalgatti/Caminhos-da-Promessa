class_name MarketScreen
extends CanvasLayer
## Feira do mercador (ADR-030), aberta pela ação de diálogo {"market": id}.
## Aba "Vender": mercadorias e itens comuns da bolsa trocados por prata.
## Aba "Comprar": roupas, panos de cabeça, cajados e animais de transporte;
## a peça comprada é equipada e aparece no viajante. Pausa o jogo; Esc fecha.

signal closed

const TABS := ["sell", "buy"]

var merchant_id := ""
var tab := "sell"
var _title: Label
var _silver: Label
var _list: VBoxContainer
var _scroll: ScrollContainer
var _feedback: Label
var _tab_buttons: Dictionary = {}


func _ready() -> void:
	layer = 38
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_build()
	Market.changed.connect(func(): if visible: refresh())
	Inventory.changed.connect(func(_i, _d): if visible: refresh())


func is_open() -> bool:
	return visible


func open(merchant: String, start_tab: String = "sell") -> void:
	merchant_id = merchant
	tab = start_tab if start_tab in TABS else "sell"
	if Market.sellable_entries().is_empty() and start_tab == "sell":
		tab = "buy"
	if not visible:
		AudioManager.play("bag_open")
	visible = true
	get_tree().paused = true
	GameState.block_ui("market")
	var m := Market.merchant(merchant_id)
	_title.text = String(m.get("title", "Feira do viajante")).to_upper()
	_feedback.text = ""
	refresh()
	_focus_first.call_deferred()


func close() -> void:
	if not visible:
		return
	AudioManager.play("bag_close")
	visible = false
	get_tree().paused = false
	GameState.unblock_ui("market")
	closed.emit()


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("pause") or event.is_action_pressed("inventory"):
		close()
		get_viewport().set_input_as_handled()


func set_tab(t: String) -> void:
	if t in TABS and t != tab:
		tab = t
		_feedback.text = ""
		refresh()
		_focus_first.call_deferred()


func refresh() -> void:
	_silver.text = "Prata: %d" % Market.silver()
	for t in _tab_buttons:
		(_tab_buttons[t] as Button).modulate = Color.WHITE if t == tab else Color(1, 1, 1, 0.55)
	for c in _list.get_children():
		_list.remove_child(c)
		c.queue_free()
	if tab == "sell":
		_fill_sell()
	else:
		_fill_buy()


func _fill_sell() -> void:
	var entries := Market.sellable_entries()
	if entries.is_empty():
		_list.add_child(UiStyle.label("Nada para vender. Recolha mercadorias pelo caminho (lã, amêndoas, sílex, tâmaras...): elas reaparecem quando você volta a uma região.", 6, UiStyle.MUTED, true))
		return
	for e in entries:
		var id := String(e.id)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 4)
		var icon := TextureRect.new()
		icon.texture = Inventory.icon(id)
		icon.custom_minimum_size = Vector2(12, 12)
		icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		row.add_child(icon)
		var lbl := UiStyle.label("%s ×%d" % [Inventory.display_name(id), int(e.qty)], 7, UiStyle.INK)
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(lbl)
		row.add_child(UiStyle.label("%d cada" % int(e.value), 6, UiStyle.MUTED))
		var one := UiStyle.small_button("Vender 1", 6, true)
		one.pressed.connect(_sell.bind(id, false))
		row.add_child(one)
		if int(e.qty) > 1:
			var all := UiStyle.small_button("Vender tudo", 6, true)
			all.pressed.connect(_sell.bind(id, true))
			row.add_child(all)
		_list.add_child(row)


func _fill_buy() -> void:
	var ids := Market.goods_for(merchant_id)
	for slot in ["clothing", "head", "staff", "transport"]:
		var in_slot := ids.filter(func(i): return String(Market.goods[i].slot) == slot)
		if in_slot.is_empty():
			continue
		var head := UiStyle.label(String(Market.SLOT_LABELS[slot]).to_upper(), 6, UiStyle.BROWN)
		_list.add_child(head)
		for id in in_slot:
			_list.add_child(_good_row(String(id)))


func _good_row(id: String) -> Control:
	var g: Dictionary = Market.goods[id]
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	var text := VBoxContainer.new()
	text.add_theme_constant_override("separation", 0)
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var title := String(g.name)
	if float(g.get("speed", 1.0)) > 1.0:
		title += " (+%d%% de velocidade)" % roundi((float(g.speed) - 1.0) * 100.0)
	text.add_child(UiStyle.label(title, 7, UiStyle.INK))
	text.add_child(UiStyle.label(String(g.get("description", "")), 6, UiStyle.MUTED, true))
	row.add_child(text)
	var btn: Button
	var slot := String(g.slot)
	if not Market.owned(id):
		btn = UiStyle.small_button("Comprar · %d" % int(g.price), 6, true)
		btn.pressed.connect(_buy.bind(id))
		if Market.silver() < int(g.price):
			btn.modulate = Color(1, 1, 1, 0.6)
	elif Market.equipped(slot) == id:
		btn = UiStyle.small_button("Tirar", 6, true)
		btn.pressed.connect(_unequip.bind(id))
	else:
		btn = UiStyle.small_button("Usar", 6, true)
		btn.pressed.connect(_equip.bind(id))
	btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(btn)
	return row


func _equip(id: String) -> void:
	if Market.equip(id):
		AudioManager.play("item_cloth")
		_feedback.text = "Agora você usa: %s." % Market.goods[id].name


func _unequip(id: String) -> void:
	if Market.unequip(String(Market.goods[id].slot)):
		AudioManager.play("item_cloth")
		_feedback.text = "%s guardado na bolsa." % Market.goods[id].name


func _sell(id: String, all: bool) -> void:
	var got := Market.sell_all(id) if all else (int(Market.sales.get(id, 0)) if Market.sell(id) else 0)
	if got > 0:
		AudioManager.play("item_give")
		_feedback.text = "Você recebeu %d de prata por %s." % [got, Inventory.display_name(id).to_lower()]
	else:
		AudioManager.play("ui_denied")
		_feedback.text = "Este item não pode ser vendido."
	_focus_first.call_deferred()


func _buy(id: String) -> void:
	var g: Dictionary = Market.goods[id]
	if Market.buy(id, merchant_id):
		AudioManager.play("item_receive")
		_feedback.text = "%s é seu. Já está com você!" % g.name
	else:
		AudioManager.play("ui_denied")
		_feedback.text = "Falta prata: %s custa %d e você tem %d." % [g.name, int(g.price), Market.silver()]


func _focus_first() -> void:
	if not visible:
		return
	for b in _list.find_children("*", "Button", true, false):
		if (b as Button).focus_mode != Control.FOCUS_NONE and not b.is_queued_for_deletion():
			(b as Button).grab_focus()
			return


func _build() -> void:
	var dim := ColorRect.new()
	dim.color = Color(UiStyle.SHADOW, 0.55)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UiStyle.wood_frame())
	panel.custom_minimum_size = Vector2(400, 232)
	center.add_child(panel)
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 3)
	panel.add_child(root)
	var header := HBoxContainer.new()
	root.add_child(header)
	_title = UiStyle.label("FEIRA DO VIAJANTE", 8, UiStyle.BROWN)
	header.add_child(_title)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer)
	_silver = UiStyle.label("", 7, UiStyle.BROWN)
	header.add_child(_silver)
	var back := UiStyle.small_button("Fechar (Esc)", 7)
	back.pressed.connect(close)
	header.add_child(back)
	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 4)
	root.add_child(tabs)
	for t in TABS:
		var b := UiStyle.small_button("Vender" if t == "sell" else "Comprar", 7)
		b.pressed.connect(set_tab.bind(t))
		tabs.add_child(b)
		_tab_buttons[t] = b
	root.add_child(HSeparator.new())
	_scroll = ScrollContainer.new()
	_scroll.custom_minimum_size = Vector2(392, 150)
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.follow_focus = true
	root.add_child(_scroll)
	_list = VBoxContainer.new()
	_list.add_theme_constant_override("separation", 3)
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll.add_child(_list)
	_feedback = UiStyle.label("", 6, UiStyle.INK, true)
	root.add_child(_feedback)
	root.add_child(UiStyle.label("A prata é pesada na balança: medida de troca do jogo, não moeda cunhada. Valores não são preços históricos.", 6, UiStyle.MUTED, true))
