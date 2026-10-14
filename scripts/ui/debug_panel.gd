extends CanvasLayer
## Painel de depuração de missões (F3). Só é criado em builds de debug
## (game.gd verifica OS.is_debug_build()) e o arquivo é excluído da exportação.

const TELEPORT_OFFSET := Vector2(0, 18)

var _quests: OptionButton
var _info: RichTextLabel
var _event_edit: LineEdit
var _root: PanelContainer


func _ready() -> void:
	layer = 60
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build()
	_root.visible = false
	QuestManager.event_recorded.connect(func(_t, _i): _refresh())
	QuestManager.objective_changed.connect(func(_q): _refresh())


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_panel"):
		_root.visible = not _root.visible
		if _root.visible:
			_refresh()
		get_viewport().set_input_as_handled()


func _qid() -> String:
	return String(_quests.get_item_metadata(_quests.selected)) if _quests.item_count > 0 else ""


func _build() -> void:
	_root = PanelContainer.new()
	_root.add_theme_stylebox_override("panel", UiStyle.panel(Color(0.08, 0.07, 0.06, 0.92), UiStyle.GOLD, 1, 3))
	_root.position = Vector2(4, 40)
	_root.custom_minimum_size = Vector2(250, 220)
	add_child(_root)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 2)
	_root.add_child(box)
	box.add_child(UiStyle.label("DEBUG DE MISSÕES (F3)", 7, UiStyle.GOLD))
	_quests = OptionButton.new()
	_quests.add_theme_font_size_override("font_size", 7)
	_quests.focus_mode = Control.FOCUS_NONE
	for id in QuestManager.db.order:
		_quests.add_item(String(QuestManager.db.get_quest(id).get("title", id)))
		_quests.set_item_metadata(_quests.item_count - 1, id)
	_quests.item_selected.connect(func(_i): _refresh())
	box.add_child(_quests)
	var row1 := HBoxContainer.new()
	box.add_child(row1)
	var row2 := HBoxContainer.new()
	box.add_child(row2)
	_btn(row1, "Iniciar", func(): QuestManager.start_quest(_qid(), true))
	_btn(row1, "Reiniciar", func(): QuestManager.reset_quest(_qid()))
	_btn(row1, "Avançar", func(): QuestManager.advance_objective(_qid()))
	_btn(row1, "Concluir", func(): QuestManager.complete_quest(_qid()))
	_btn(row2, "Pista +1", func(): QuestManager.request_hint(_qid()))
	_btn(row2, "Ir ao alvo", _teleport)
	_btn(row2, "Liberar descobertas", func():
		for d in Bible.catalog.discoveries:
			Discoveries.unlock(d))
	var row3 := HBoxContainer.new()
	box.add_child(row3)
	_event_edit = LineEdit.new()
	_event_edit.placeholder_text = "tipo:id (ex.: custom:wells_adina_water)"
	_event_edit.add_theme_font_size_override("font_size", 7)
	_event_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_event_edit.text_submitted.connect(func(_t): _simulate())
	row3.add_child(_event_edit)
	_btn(row3, "Simular", _simulate)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(240, 140)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	_info = UiStyle.rich(7)
	_info.add_theme_color_override("default_color", UiStyle.PARCHMENT)
	_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_info)


func _btn(parent: Control, text: String, cb: Callable) -> void:
	var b := UiStyle.small_button(text, 7)
	b.pressed.connect(func():
		cb.call()
		_refresh())
	parent.add_child(b)


func _simulate() -> void:
	var parts := _event_edit.text.strip_edges().split(":", true, 1)
	if parts.size() == 2 and parts[0] in QuestDatabase.EVENT_TYPES:
		QuestManager.record_event(parts[0], parts[1])
		_event_edit.text = ""
	else:
		_event_edit.text = "formato: tipo:id; tipos: " + ", ".join(QuestDatabase.EVENT_TYPES)


func _teleport() -> void:
	var obj := QuestManager.current_objective(_qid())
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if obj.is_empty() or player == null:
		return
	for t in obj.get("targets", []):
		var node := _find_target(t)
		if node:
			player.global_position = node.global_position + TELEPORT_OFFSET
			return


func _find_target(t: Dictionary) -> Node2D:
	for n in get_tree().get_nodes_in_group("interactable"):
		var it := n as Interactable
		if t.get("type") == "npc" and it.get_parent() is NPC and (it.get_parent() as NPC).character_id == t.get("id"):
			return it.get_parent()
		if t.get("type") in ["object", "dialogue"] and it.dialogue_id == t.get("id"):
			return it
	return null


func _refresh() -> void:
	if not _root.visible:
		return
	var qid := _qid()
	var q := QuestManager.db.get_quest(qid)
	var t := "[b]%s[/b]  status: %s  canal: %s\n" % [qid, QuestManager.status(qid) if QuestManager.status(qid) != "" else "não iniciada", ContentPolicy.channel()]
	t += "Referências: %s\n" % Bible.refs(q.get("references", []))
	t += "Conteúdo: %s\n" % ContentPolicy.status_label(ContentPolicy.status_of(q))
	var start: Dictionary = q.get("start", {})
	t += "Início: %s:%s\n" % [start.get("event"), start.get("id")]
	var missing := QuestManager.missing_requirements(qid)
	if QuestManager.status(qid) == "" and not missing.is_empty():
		t += "[color=#e0a060]Falta: %s[/color]\n" % ", ".join(missing)
	var objs: Array = q.get("objectives", [])
	for i in objs.size():
		var o: Dictionary = objs[i]
		var st := QuestManager.objective_state(qid, i)
		var mark: String = {"done": "+", "current": "›", "locked": "·"}[st]
		var trig: Dictionary = o.get("complete_on", {})
		var seen := QuestManager.has_event(String(trig.get("event")), String(trig.get("id")))
		t += "%s %s  [color=#a0a0a0](%s:%s%s)[/color]\n" % [mark, o.id, trig.get("event"), trig.get("id"), " ok" if seen else ""]
	if QuestManager.status(qid) == "active":
		t += "Pista: %d/3   tempo no objetivo: %ds\n" % [QuestManager.hint_level(qid), int(QuestManager.seconds_on_objective(qid))]
	t += "\nDescobertas: %d/%d\n" % [GameState.discoveries.size(), Bible.catalog.discoveries.size()]
	t += "\n[b]Eventos registrados[/b]\n"
	var evs: Array = []
	for f in GameState.flags:
		if String(f).begins_with("ev:"):
			evs.append(String(f).substr(3))
	t += ", ".join(evs) + "\n"
	t += "\n[b]Histórico recente[/b]\n"
	var hist: Array = GameState.history.slice(maxi(GameState.history.size() - 8, 0))
	hist.reverse()
	for h in hist:
		t += "%s %s\n" % [h.kind, h.id]
	_info.text = t
