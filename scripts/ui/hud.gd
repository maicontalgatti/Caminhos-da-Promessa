extends CanvasLayer
## HUD de exploração: contexto bíblico (canto superior esquerdo, recolhível),
## "Sua jornada" com pistas progressivas (canto superior direito), avisos
## discretos de descoberta, cartões contextuais e o banner de lugar/época.
## Janelas maiores esperam o fim de diálogos e cenas para não se sobrepor.

signal journal_requested(tab: String, focus: String)
signal inventory_requested
signal scripture_map_requested

const TOAST_TIME := 3.6
## Depois deste tempo no mesmo objetivo sem pedir pistas, "H: pista" pulsa.
const NUDGE_AFTER := 150.0
const FREE_EXPLORE_TIME := 14.0

@onready var location: PanelContainer = $Location
@onready var title: Label = $Location/VBox/Title
@onready var subtitle: Label = $Location/VBox/Subtitle
@onready var refs_label: Label = $Location/VBox/Refs
@onready var controls: Label = $Controls

var _ctx_panel: PanelContainer
var _ctx_full: VBoxContainer
var _ctx_era: Label
var _ctx_ref: Label
var _ctx_theme: Label
var _ctx_source: Label
var _ctx_short: Label
var _journal_btn: Button

var _tracker: PanelContainer
var _tr_title: Label
var _tr_text: Label
var _tr_detail: Label
var _tr_hint: Label
var _tr_help: Label

var _toasts: VBoxContainer
var _card_root: Control
var _card_box: VBoxContainer
var _card_focus := ""

var _queue: Array = []
var _card_open := false
var _unseen := 0
var _free_explore_left := 0.0
var _time := 0.0


func _ready() -> void:
	add_to_group("hud")
	location.modulate.a = 0.0
	var t := create_tween()
	t.tween_interval(12.0)
	t.tween_property(controls, "modulate:a", 0.0, 2.0)
	_build_context_panel()
	_build_tracker()
	_build_toasts()
	_build_card_layer()
	QuestManager.context_changed.connect(refresh_context)
	QuestManager.objective_changed.connect(func(_q): refresh_tracker())
	QuestManager.hint_changed.connect(func(_q): refresh_tracker())
	QuestManager.quest_started.connect(_on_quest_started)
	QuestManager.quest_completed.connect(_on_quest_completed)
	Discoveries.discovery_unlocked.connect(_on_discovery)
	refresh_context()
	refresh_tracker()


func _process(delta: float) -> void:
	_time += delta
	_process_queue()
	var qid := QuestManager.primary_quest()
	if qid != "" and QuestManager.hint_level(qid) == 0 and QuestManager.seconds_on_objective(qid) > NUDGE_AFTER:
		_tr_help.modulate = Color(1, 1, 1, 0.55 + 0.45 * sin(_time * 4.0))
		_tr_help.add_theme_color_override("font_color", UiStyle.BROWN)
	else:
		_tr_help.modulate = Color.WHITE
		_tr_help.add_theme_color_override("font_color", UiStyle.MUTED)
	if _free_explore_left > 0.0:
		_free_explore_left -= delta
		if _free_explore_left <= 0.0 and QuestManager.primary_quest() == "":
			create_tween().tween_property(_tracker, "modulate:a", 0.0, 1.0)


## Atalhos e botões do HUD só abrem telas com o jogo livre: nunca por cima de
## um diálogo, de um cartão, de outra tela ou durante a troca de região.
func can_open_screen() -> bool:
	return visible and not _card_open and not GameState.is_ui_blocked() and not DialogueManager.is_active() and not get_tree().paused


func _unhandled_input(event: InputEvent) -> void:
	if not can_open_screen():
		return
	if event.is_action_pressed("hint"):
		if QuestManager.primary_quest() != "":
			QuestManager.request_hint()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("toggle_hud"):
		Settings.hud_context_collapsed = not Settings.hud_context_collapsed
		Settings.save_settings()
		refresh_context()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("journal"):
		_open_journal("journey", "")
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("bible_context"):
		_open_journal("scriptures", _context_focus())
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("places_map"):
		scripture_map_requested.emit()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("inventory"):
		inventory_requested.emit()
		get_viewport().set_input_as_handled()


func _input(event: InputEvent) -> void:
	if not _card_open:
		return
	var close := event.is_action_pressed("interact") or event.is_action_pressed("pause")
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		close = true
	if event.is_action_pressed("journal"):
		var focus := _card_focus
		_close_card()
		_open_journal("scriptures" if focus.begins_with("disc:") else "journey", focus)
		get_viewport().set_input_as_handled()
	elif close:
		_close_card()
		get_viewport().set_input_as_handled()


# --- Painel de contexto bíblico ---------------------------------------------

func _build_context_panel() -> void:
	_ctx_panel = PanelContainer.new()
	_ctx_panel.name = "ContextPanel"
	_ctx_panel.add_theme_stylebox_override("panel", UiStyle.panel(Color(UiStyle.PARCHMENT, 0.94), UiStyle.BROWN, 1, 3))
	_ctx_panel.position = Vector2(4, 4)
	_ctx_panel.custom_minimum_size = Vector2(172, 0)
	_ctx_panel.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(_ctx_panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 0)
	_ctx_panel.add_child(box)
	_ctx_short = UiStyle.label("", 6, UiStyle.BROWN)
	box.add_child(_ctx_short)
	_ctx_full = VBoxContainer.new()
	_ctx_full.add_theme_constant_override("separation", 0)
	box.add_child(_ctx_full)
	_ctx_era = UiStyle.label("", 6, UiStyle.BROWN, true)
	_ctx_ref = UiStyle.label("", 8, UiStyle.INK, true)
	_ctx_theme = UiStyle.label("", 6, UiStyle.MUTED, true)
	_ctx_source = UiStyle.label("", 6, UiStyle.MUTED)
	for l in [_ctx_era, _ctx_ref, _ctx_theme, _ctx_source]:
		l.custom_minimum_size.x = 164
		_ctx_full.add_child(l)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 2)
	_ctx_full.add_child(row)
	var b_ctx := UiStyle.small_button("C contexto")
	b_ctx.tooltip_text = "Abrir o contexto bíblico no diário"
	b_ctx.pressed.connect(func(): if can_open_screen(): _open_journal("scriptures", _context_focus()))
	var b_map := UiStyle.small_button("M mapa")
	b_map.tooltip_text = "Mapa das Escrituras (o atlas de lugares fica dentro dele e no diário)"
	b_map.pressed.connect(func(): if can_open_screen(): scripture_map_requested.emit())
	_journal_btn = UiStyle.small_button("J diário")
	_journal_btn.tooltip_text = "Abrir o diário"
	_journal_btn.pressed.connect(func(): if can_open_screen(): _open_journal("journey", ""))
	var b_inv := UiStyle.small_button("I bolsa")
	b_inv.tooltip_text = "Abrir a bolsa (inventário)"
	b_inv.pressed.connect(func(): if can_open_screen(): inventory_requested.emit())
	for b in [b_ctx, b_map, _journal_btn, b_inv]:
		row.add_child(b)


func refresh_context() -> void:
	var ctx := QuestManager.get_context()
	_ctx_panel.visible = not ctx.is_empty()
	if ctx.is_empty():
		return
	var place := Bible.place_name(String(ctx.place_id))
	if place == "":
		place = String(ctx.title)
	var era := Bible.era_label(String(ctx.era_id))
	_ctx_era.text = ("%s — %s" % [place, era]).to_upper()
	_ctx_ref.text = Bible.refs(ctx.references)
	_ctx_theme.text = "“%s”" % ctx.theme if String(ctx.theme) != "" else ""
	_ctx_theme.visible = _ctx_theme.text != ""
	_ctx_source.text = "Experiência ativa: %s" % ctx.title if ctx.source == "quest" else "Referência principal da região"
	var here := String(GameData.get_region(WorldManager.current_region_id()).get("display_name", ""))
	if here != "":
		_ctx_source.text += "\nVocê está em: %s" % here
	_ctx_short.text = "%s · %s   [Tab]" % [place.to_upper(), Bible.refs(ctx.references, true)]
	var collapsed := Settings.hud_context_collapsed
	_ctx_full.visible = not collapsed
	_ctx_short.visible = collapsed
	_update_journal_btn()
	_ctx_panel.reset_size()


func _context_focus() -> String:
	var refs: Array = QuestManager.get_context().get("references", [])
	return "book:" + Bible.catalog.book_of(refs[0]) if not refs.is_empty() else ""


func _update_journal_btn() -> void:
	_journal_btn.text = "J diário •" if _unseen > 0 else "J diário"


func _open_journal(tab: String, focus: String) -> void:
	_unseen = 0
	_update_journal_btn()
	journal_requested.emit(tab, focus)


# --- Sua jornada -------------------------------------------------------------

func _build_tracker() -> void:
	_tracker = PanelContainer.new()
	_tracker.name = "Tracker"
	_tracker.add_theme_stylebox_override("panel", UiStyle.panel(Color(UiStyle.PARCHMENT, 0.94), UiStyle.BROWN, 1, 3))
	_tracker.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_tracker.offset_left = -158
	_tracker.offset_right = -4
	_tracker.offset_top = 4
	_tracker.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_tracker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_tracker)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 1)
	_tracker.add_child(box)
	_tr_title = UiStyle.label("SUA JORNADA", 6, UiStyle.BROWN)
	_tr_text = UiStyle.label("", 7, UiStyle.INK, true)
	_tr_detail = UiStyle.label("", 6, UiStyle.MUTED, true)
	_tr_hint = UiStyle.label("", 6, UiStyle.BROWN, true)
	_tr_help = UiStyle.label("H: pedir pista", 6, UiStyle.MUTED)
	for l in [_tr_title, _tr_text, _tr_detail, _tr_hint, _tr_help]:
		l.custom_minimum_size.x = 146
		box.add_child(l)


func refresh_tracker() -> void:
	var qid := QuestManager.primary_quest()
	if qid == "":
		if _free_explore_left <= 0.0:
			_tracker.visible = false
		return
	_tracker.visible = true
	_tracker.modulate.a = 1.0
	var obj := QuestManager.current_objective(qid)
	var q := QuestManager.db.get_quest(qid)
	var cat := QuestManager.category(qid)
	_tr_title.text = "%s · %s" % ["SUA JORNADA" if cat == "main" else String(QuestDatabase.CATEGORY_LABELS.get(cat, cat)).to_upper(), String(q.title).to_upper()]
	_tr_text.text = "› " + String(obj.get("text", ""))
	_tr_detail.text = String(obj.get("detail", ""))
	var route := objective_route(qid)
	if route != "":
		_tr_detail.text = "Siga para: " + route
	_tr_detail.visible = _tr_detail.text != ""
	var lvl := QuestManager.hint_level(qid)
	_tr_hint.visible = lvl > 0
	_tr_hint.text = "Pista %d/3: %s" % [lvl, QuestManager.hint_text(qid)] if lvl > 0 else ""
	_tr_help.text = "H: outra pista" if lvl in [1, 2] else ("Todas as pistas reveladas" if lvl >= 3 else "H: pedir pista")
	_tracker.reset_size()


## Rótulo da saída a seguir quando o objetivo fica em outra região ("" se aqui).
func objective_route(qid: String) -> String:
	var here := WorldManager.current_region_id()
	var there := QuestManager.objective_region(qid)
	if here == "" or there == "" or here == there:
		return ""
	var ex := WorldManager.route_exit(here, there)
	return String(ex.get("label", GameData.get_region(there).get("display_name", there)))


func _show_free_explore() -> void:
	_tracker.visible = true
	_tracker.modulate.a = 1.0
	_tr_title.text = "SUA JORNADA"
	_tr_text.text = "› Exploração livre"
	_tr_detail.text = "Converse e examine: ainda há muito para descobrir."
	_tr_detail.visible = true
	_tr_hint.visible = false
	_tr_help.text = "J: diário"
	_free_explore_left = FREE_EXPLORE_TIME
	_tracker.reset_size()


func _on_quest_started(qid: String) -> void:
	refresh_tracker()
	_tracker.modulate.a = 0.0
	create_tween().tween_property(_tracker, "modulate:a", 1.0, 0.6)
	if not GameState.is_ui_blocked():
		_queue.append({"kind": "toast", "text": "Nova jornada: %s" % QuestManager.db.get_quest(qid).title})


func _on_quest_completed(qid: String) -> void:
	_queue.append({"kind": "completion", "quest_id": qid})
	_show_free_explore()


# --- Avisos e cartões --------------------------------------------------------

func _on_discovery(id: String) -> void:
	_unseen += 1
	_update_journal_btn()
	var d := Bible.discovery(id)
	match Settings.edu_notifications:
		"full":
			if d.get("presentation") == "card":
				_queue.append({"kind": "discovery_card", "id": id})
			else:
				_queue.append({"kind": "toast", "text": "Descoberta registrada: %s" % d.title})
		"brief":
			_queue.append({"kind": "toast", "text": "Descoberta registrada: %s" % d.title})


func _build_toasts() -> void:
	_toasts = VBoxContainer.new()
	_toasts.name = "Toasts"
	_toasts.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_toasts.offset_left = -196
	_toasts.offset_right = -4
	_toasts.offset_top = -40
	_toasts.offset_bottom = -18
	_toasts.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_toasts.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_toasts.alignment = BoxContainer.ALIGNMENT_END
	_toasts.add_theme_constant_override("separation", 2)
	_toasts.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_toasts)


func show_toast(text: String) -> void:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", UiStyle.panel(Color(UiStyle.PARCHMENT, 0.96), UiStyle.GOLD, 1, 2))
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	p.add_child(row)
	row.add_child(UiStyle.label("•", 7, UiStyle.GOLD))
	row.add_child(UiStyle.label(text, 7, UiStyle.INK))
	row.add_child(UiStyle.label("J", 6, UiStyle.MUTED))
	_toasts.add_child(p)
	p.modulate.a = 0.0
	var t := create_tween()
	t.tween_property(p, "modulate:a", 1.0, 0.3)
	t.tween_interval(TOAST_TIME)
	t.tween_property(p, "modulate:a", 0.0, 0.6)
	t.tween_callback(p.queue_free)


func _build_card_layer() -> void:
	_card_root = Control.new()
	_card_root.name = "Cards"
	_card_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_card_root.mouse_filter = Control.MOUSE_FILTER_STOP
	_card_root.visible = false
	add_child(_card_root)
	var dim := ColorRect.new()
	dim.color = Color(UiStyle.SHADOW, 0.35)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card_root.add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card_root.add_child(center)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UiStyle.wood_frame())
	panel.custom_minimum_size = Vector2(300, 0)
	center.add_child(panel)
	_card_box = VBoxContainer.new()
	_card_box.add_theme_constant_override("separation", 3)
	panel.add_child(_card_box)


func _can_show_popup() -> bool:
	return visible and not DialogueManager.is_active() and not GameState.is_ui_blocked() and not get_tree().paused


func _process_queue() -> void:
	if _queue.is_empty() or _card_open or not _can_show_popup():
		return
	var item: Dictionary = _queue.pop_front()
	match String(item.kind):
		"toast":
			show_toast(String(item.text))
		"discovery_card":
			_show_discovery_card(String(item.id))
		"completion":
			if Settings.edu_notifications == "minimal":
				show_toast("História explorada: %s" % QuestManager.db.get_quest(item.quest_id).title)
			else:
				_show_completion_card(String(item.quest_id))


func has_pending_popups() -> bool:
	return _card_open or not _queue.is_empty()


func _clear_card() -> void:
	for c in _card_box.get_children():
		c.queue_free()


func _open_card(focus: String) -> void:
	_card_focus = focus
	_card_open = true
	_card_root.visible = true
	_card_root.modulate.a = 0.0
	create_tween().tween_property(_card_root, "modulate:a", 1.0, 0.25)
	GameState.block_ui("hud_card")


func _close_card() -> void:
	_card_open = false
	_card_root.visible = false
	GameState.unblock_ui("hud_card")


func _card_header(kind_text: String, classification: String) -> void:
	var row := HBoxContainer.new()
	row.add_child(UiStyle.label(kind_text, 7, UiStyle.BROWN))
	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(sp)
	if classification != "":
		row.add_child(UiStyle.classification_tag(classification))
	_card_box.add_child(row)


func _card_footer(text: String) -> void:
	var sep := HSeparator.new()
	_card_box.add_child(sep)
	_card_box.add_child(UiStyle.label(text, 6, UiStyle.MUTED))


func _show_discovery_card(id: String) -> void:
	var d := Bible.discovery(id)
	_clear_card()
	_card_header("DESCOBERTA", String(d.classification))
	_card_box.add_child(UiStyle.label(String(d.title).to_upper(), 10, UiStyle.INK, true))
	_card_box.add_child(UiStyle.label(String(d.summary), 7, UiStyle.INK, true))
	var bible := UiStyle.rich(7)
	bible.text = "[color=%s]Na Bíblia:[/color] %s" % [UiStyle.hex(UiStyle.BROWN), d.bible_note]
	_card_box.add_child(bible)
	_card_box.add_child(UiStyle.label("Referências: " + Bible.refs(d.references), 6, UiStyle.MUTED, true))
	if ContentPolicy.needs_review_marker(d):
		_card_box.add_child(UiStyle.label("Conteúdo aguardando revisão humana.", 6, UiStyle.MUTED))
	_card_footer("Registrado no diário   ·   E: continuar   J: ver no diário")
	_open_card("disc:" + id)


func _show_completion_card(qid: String) -> void:
	var q := QuestManager.db.get_quest(qid)
	var comp := QuestManager.completion(qid)
	_clear_card()
	_card_header(String(comp.get("title", "História explorada")).to_upper(), "")
	_card_box.add_child(UiStyle.label(Bible.refs(comp.get("references", q.references)), 11, UiStyle.INK))
	_card_box.add_child(UiStyle.label(String(q.title), 7, UiStyle.MUTED))
	for line in comp.get("summary", []):
		_card_box.add_child(UiStyle.label("• " + String(line), 7, UiStyle.INK, true))
	if String(comp.get("next", "")) != "":
		_card_box.add_child(UiStyle.label(String(comp.next), 6, UiStyle.BROWN, true))
	_card_footer("E: continuar   J: abrir a jornada no diário")
	_open_card("quest:" + qid)


# --- Identidade de lugar e época ---------------------------------------------

## Banner ao entrar no jogo ou numa nova experiência: lugar, época e referências.
func show_identity(ctx: Dictionary) -> void:
	if ctx.is_empty():
		return
	var place := Bible.place_name(String(ctx.place_id))
	title.text = place if place != "" else String(ctx.title)
	subtitle.text = Bible.era_display(String(ctx.era_id))
	var suffix := "" if ctx.source == "quest" else " (referência principal da região)"
	refs_label.text = "Referências: %s%s" % [Bible.refs(ctx.references), suffix]
	location.reset_size()
	var t := create_tween()
	t.tween_interval(0.6)
	t.tween_property(location, "modulate:a", 1.0, 0.8)
	t.tween_interval(4.5)
	t.tween_property(location, "modulate:a", 0.0, 1.2)


## Título discreto ao chegar a uma região: "CAMINHO DAS CARAVANAS / Região de Canaã".
func show_region_banner(region: Dictionary) -> void:
	if region.is_empty():
		return
	title.text = String(region.get("display_name", "")).to_upper()
	var area := String(region.get("area_label", region.get("subtitle", "")))
	subtitle.text = "%s · %s" % [area, WorldClock.phase_label()] if area != "" else WorldClock.phase_label()
	var era := Bible.era_label(String(region.get("context", {}).get("era_id", "")))
	refs_label.text = era
	location.reset_size()
	var t := create_tween()
	location.modulate.a = 0.0
	t.tween_interval(0.2)
	t.tween_property(location, "modulate:a", 1.0, 0.6)
	t.tween_interval(3.0)
	t.tween_property(location, "modulate:a", 0.0, 1.0)


## Mantido para compatibilidade com mapas que só informam a região.
func show_location(region: Dictionary) -> void:
	if region.is_empty():
		return
	show_identity(QuestManager.get_context())
