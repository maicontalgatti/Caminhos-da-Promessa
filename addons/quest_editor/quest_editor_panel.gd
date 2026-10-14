@tool
extends VBoxContainer
## Interface do editor de missões (aba "Missões" no painel inferior).

var model := QuestEditorModel.new()
var _current := ""

var _search: LineEdit
var _f_book: OptionButton
var _f_region: OptionButton
var _f_era: OptionButton
var _f_status: OptionButton
var _list: ItemList
var _tabs: TabContainer
var _summary: RichTextLabel
var _code: CodeEdit
var _dlg_select: OptionButton
var _dlg_code: CodeEdit
var _status_opt: OptionButton
var _reviewer: LineEdit
var _insert_opt: OptionButton
var _msg: Label


func _ready() -> void:
	size_flags_vertical = SIZE_EXPAND_FILL
	custom_minimum_size = Vector2(0, 280)
	_build()
	_reload()


# --- Construção --------------------------------------------------------------

func _build() -> void:
	var bar := HBoxContainer.new()
	add_child(bar)
	_search = LineEdit.new()
	_search.placeholder_text = "Buscar por id, título ou referência"
	_search.custom_minimum_size.x = 220
	_search.text_changed.connect(func(_t): _refresh_list())
	bar.add_child(_search)
	_f_book = _filter(bar, "Livro")
	_f_region = _filter(bar, "Região")
	_f_era = _filter(bar, "Época")
	_f_status = _filter(bar, "Status")
	_button(bar, "Recarregar", _reload)
	_button(bar, "Nova missão", _new_quest)

	var split := HSplitContainer.new()
	split.size_flags_vertical = SIZE_EXPAND_FILL
	add_child(split)
	_list = ItemList.new()
	_list.custom_minimum_size.x = 240
	_list.item_selected.connect(func(i): _select(String(_list.get_item_metadata(i))))
	split.add_child(_list)

	var right := VBoxContainer.new()
	right.size_flags_horizontal = SIZE_EXPAND_FILL
	split.add_child(right)
	var tools := HBoxContainer.new()
	right.add_child(tools)
	_button(tools, "Validar", _validate_current)
	_button(tools, "Salvar", _save_current)
	_button(tools, "Testar missão", _test_current)
	tools.add_child(VSeparator.new())
	tools.add_child(_lbl("Status:"))
	_status_opt = OptionButton.new()
	for s in ContentPolicy.STATUSES:
		_status_opt.add_item(ContentPolicy.status_label(s))
		_status_opt.set_item_metadata(_status_opt.item_count - 1, s)
	tools.add_child(_status_opt)
	_reviewer = LineEdit.new()
	_reviewer.placeholder_text = "Revisor humano"
	_reviewer.custom_minimum_size.x = 140
	tools.add_child(_reviewer)
	_button(tools, "Aplicar status", _apply_status)
	tools.add_child(VSeparator.new())
	_insert_opt = OptionButton.new()
	_insert_opt.custom_minimum_size.x = 200
	tools.add_child(_insert_opt)
	_button(tools, "Inserir", _insert)

	_tabs = TabContainer.new()
	_tabs.size_flags_vertical = SIZE_EXPAND_FILL
	right.add_child(_tabs)
	_summary = RichTextLabel.new()
	_summary.name = "Resumo"
	_summary.bbcode_enabled = true
	_summary.selection_enabled = true
	_tabs.add_child(_summary)
	_code = _code_edit("JSON da missão")
	_tabs.add_child(_code)
	var dlg_box := VBoxContainer.new()
	dlg_box.name = "Diálogos"
	_tabs.add_child(dlg_box)
	var dlg_bar := HBoxContainer.new()
	dlg_box.add_child(dlg_bar)
	_dlg_select = OptionButton.new()
	_dlg_select.custom_minimum_size.x = 220
	_dlg_select.item_selected.connect(func(_i): _show_dialogue())
	dlg_bar.add_child(_dlg_select)
	_button(dlg_bar, "Validar diálogo", _validate_dialogue)
	_button(dlg_bar, "Salvar diálogo", _save_dialogue)
	_dlg_code = _code_edit("JSON do diálogo")
	_dlg_code.size_flags_vertical = SIZE_EXPAND_FILL
	dlg_box.add_child(_dlg_code)

	_msg = _lbl("")
	add_child(_msg)


func _filter(parent: Control, label: String) -> OptionButton:
	var o := OptionButton.new()
	o.tooltip_text = label
	o.item_selected.connect(func(_i): _refresh_list())
	parent.add_child(o)
	return o


func _button(parent: Control, text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.pressed.connect(cb)
	parent.add_child(b)
	return b


func _lbl(text: String) -> Label:
	var l := Label.new()
	l.text = text
	return l


func _code_edit(name_: String) -> CodeEdit:
	var c := CodeEdit.new()
	c.name = name_
	c.gutters_draw_line_numbers = true
	c.indent_use_spaces = false
	c.auto_brace_completion_enabled = true
	c.size_flags_vertical = SIZE_EXPAND_FILL
	return c


func _fill(o: OptionButton, all_label: String, values: Array, labels: Dictionary = {}) -> void:
	var prev := String(o.get_item_metadata(o.selected)) if o.item_count > 0 and o.selected >= 0 else ""
	o.clear()
	o.add_item(all_label)
	o.set_item_metadata(0, "")
	for v in values:
		o.add_item(String(labels.get(v, v)))
		o.set_item_metadata(o.item_count - 1, v)
		if v == prev:
			o.select(o.item_count - 1)


func _meta(o: OptionButton) -> String:
	return String(o.get_item_metadata(o.selected)) if o.selected >= 0 else ""


# --- Dados -------------------------------------------------------------------

func _reload() -> void:
	model.reload()
	var books: Array = []
	var regions: Array = []
	var eras: Array = []
	for id in model.order:
		var q: Dictionary = model.quests[id]
		for b in model.books_of(q):
			if not (b in books):
				books.append(b)
		if not (q.get("region") in regions):
			regions.append(q.get("region"))
		if not (q.get("era_id") in eras):
			eras.append(q.get("era_id"))
	var book_names := {}
	for b in books:
		book_names[b] = model.catalog.books.get(b, {}).get("name", b)
	var era_names := {}
	for e in model.catalog.eras:
		era_names[e] = model.catalog.era_label(e)
	_fill(_f_book, "Todos os livros", books, book_names)
	_fill(_f_region, "Todas as regiões", regions)
	_fill(_f_era, "Todas as épocas", eras, era_names)
	_fill(_f_status, "Todos os status", ContentPolicy.STATUSES, ContentPolicy.STATUS_LABELS)
	_insert_opt.clear()
	var add_ins := func(label: String, snippet: String):
		_insert_opt.add_item(label)
		_insert_opt.set_item_metadata(_insert_opt.item_count - 1, snippet)
	add_ins.call("Modelo: objetivo", QuestEditorModel.to_json(QuestEditorModel.objective_template("novo_objetivo")))
	add_ins.call("Modelo: referência", "\"Gen 1:1\"")
	add_ins.call("Modelo: alvo NPC", JSON.stringify({"type": "npc", "id": ""}))
	for c in model.characters:
		add_ins.call("Personagem: %s" % c, "\"%s\"" % c)
	for p in model.catalog.people:
		add_ins.call("Pessoa bíblica: %s" % p, "\"%s\"" % p)
	for d in model.catalog.discoveries:
		add_ins.call("Descoberta: %s" % d, "\"%s\"" % d)
	for p in model.catalog.presentations:
		add_ins.call("Apresentação: %s" % p, "\"%s\"" % p)
	for d in model.dialogues.dialogues:
		add_ins.call("Diálogo: %s" % d, "\"%s\"" % d)
	_dlg_select.clear()
	for d in model.dialogues.dialogues:
		_dlg_select.add_item(d)
	_refresh_list()
	if not model.load_errors.is_empty():
		_say("Erros ao carregar: %s" % "; ".join(model.load_errors), true)
	else:
		_say("%d missões carregadas." % model.order.size())


func _refresh_list() -> void:
	_list.clear()
	for id in model.filter(_search.text, _meta(_f_book), _meta(_f_region), _meta(_f_era), _meta(_f_status)):
		var q: Dictionary = model.quests[id]
		var errs := model.validate(q)
		var text := "%s  [%s]%s" % [q.get("title", id), ContentPolicy.status_label(ContentPolicy.status_of(q)), "  (!)" if not errs.is_empty() else ""]
		_list.add_item(text)
		_list.set_item_metadata(_list.item_count - 1, id)
		_list.set_item_tooltip(_list.item_count - 1, "%s\n%s" % [id, model.catalog.format_references(q.get("references", []))])
		if id == _current:
			_list.select(_list.item_count - 1)


func _select(id: String) -> void:
	_current = id
	var q: Dictionary = model.quests.get(id, {})
	_code.text = QuestEditorModel.to_json(q)
	var st := ContentPolicy.status_of(q)
	_status_opt.select(ContentPolicy.STATUSES.find(st))
	_reviewer.text = String(q.get("verification", {}).get("reviewer", ""))
	_show_summary(q)
	var linked := ""
	for o in q.get("objectives", []):
		for t in o.get("targets", []):
			if t.get("type") == "dialogue":
				linked = t.id
			elif t.get("type") == "npc":
				linked = String(model.characters.get(t.id, {}).get("dialogue_id", linked))
			if linked != "":
				break
		if linked != "":
			break
	for i in _dlg_select.item_count:
		if _dlg_select.get_item_text(i) == linked:
			_dlg_select.select(i)
	_show_dialogue()


func _show_summary(q: Dictionary) -> void:
	var c := model.catalog
	var t := "[b]%s[/b]  (%s)\n" % [q.get("title", "?"), q.get("id", "?")]
	t += "%s · %s · tipo %s\n" % [ContentPolicy.classification_label(String(q.get("classification", ""))), c.era_display(String(q.get("era_id", ""))), q.get("type", "")]
	t += "Região: %s · Lugar: %s\n" % [q.get("region", ""), c.places.get(q.get("place_id", ""), {}).get("name", q.get("place_id", ""))]
	t += "Referências: %s\n" % c.format_references(q.get("references", []))
	var ver: Dictionary = q.get("verification", {})
	t += "Status: %s · revisor: %s\n" % [ContentPolicy.status_label(ContentPolicy.status_of(q)), ver.get("reviewer", "") if String(ver.get("reviewer", "")) != "" else "(nenhum)"]
	t += "Início: %s:%s · pré-requisitos: %s\n" % [q.get("start", {}).get("event"), q.get("start", {}).get("id"), q.get("prerequisites", {})]
	t += "Pessoas bíblicas: %s · fictícios: %s\n\n" % [", ".join(q.get("people", [])), ", ".join(q.get("fictional_characters", []))]
	var i := 1
	for o in q.get("objectives", []):
		t += "[b]%d. %s[/b]  [color=gray](%s)[/color]\n" % [i, o.get("text", ""), o.get("id", "")]
		t += "   conclui em %s:%s · alvos %s\n" % [o.get("complete_on", {}).get("event"), o.get("complete_on", {}).get("id"), o.get("targets", [])]
		var h := 1
		for hint in o.get("hints", []):
			t += "   pista %d: %s\n" % [h, hint]
			h += 1
		i += 1
	t += "\nDescobertas: %s\n" % ", ".join(q.get("discoveries", []))
	var errs := model.validate(q)
	if errs.is_empty():
		t += "\n[color=green]Sem erros de validação.[/color]"
	else:
		t += "\n[color=#e06060]Problemas:[/color]\n"
		for e in errs:
			t += "• %s\n" % e
	if ContentPolicy.needs_review_marker(q):
		t += "\n[color=#c0a040]Conteúdo ainda não conferido por uma pessoa: não aparece no canal público.[/color]"
	_summary.text = t


func _parse_code() -> Dictionary:
	var json := JSON.new()
	if json.parse(_code.text) != OK:
		_say("JSON inválido na linha %d: %s" % [json.get_error_line(), json.get_error_message()], true)
		return {}
	if not (json.data is Dictionary):
		_say("A missão deve ser um objeto JSON.", true)
		return {}
	var q: Dictionary = json.data
	q["_source"] = model.quests.get(_current, {}).get("_source", "")
	return q


func _validate_current() -> void:
	var q := _parse_code()
	if q.is_empty():
		return
	_show_summary(q)
	_tabs.current_tab = 0
	var errs := model.validate(q)
	_say("Sem erros." if errs.is_empty() else "%d problema(s); veja o resumo." % errs.size(), not errs.is_empty())


func _save_current() -> void:
	var q := _parse_code()
	if q.is_empty():
		return
	var structural := QuestDatabase.validate(q)
	if not structural.is_empty():
		_show_summary(q)
		_tabs.current_tab = 0
		_say("Não salvo: corrija os erros estruturais primeiro.", true)
		return
	if q.id != _current and model.quests.has(q.id):
		_say("Já existe uma missão com o id \"%s\"." % q.id, true)
		return
	var err := model.save_quest(q)
	if err != OK:
		_say("Erro ao salvar: %s" % error_string(err), true)
		return
	_current = q.id
	EditorInterface.get_resource_filesystem().scan()
	_refresh_list()
	_select(_current)
	var links := model.validate(q)
	_say("Salvo em %s.%s" % [q._source, "" if links.is_empty() else " Atenção: %d problema(s) de vínculo." % links.size()], not links.is_empty())


func _apply_status() -> void:
	var q := _parse_code()
	if q.is_empty():
		return
	var errs := QuestEditorModel.set_status(q, _meta_status(), _reviewer.text)
	if not errs.is_empty():
		_say("; ".join(errs), true)
		return
	_code.text = QuestEditorModel.to_json(q)
	_say("Status alterado no texto; clique em Salvar para gravar.")


func _meta_status() -> String:
	return String(_status_opt.get_item_metadata(_status_opt.selected))


func _insert() -> void:
	if _insert_opt.selected < 0:
		return
	var target := _dlg_code if _tabs.current_tab == 2 else _code
	if _tabs.current_tab == 0:
		_tabs.current_tab = 1
	target.insert_text_at_caret(String(_insert_opt.get_item_metadata(_insert_opt.selected)))
	target.grab_focus()


func _new_quest() -> void:
	var n := 1
	while model.quests.has("nova_missao_%d" % n):
		n += 1
	var base: Dictionary = model.quests.get(_current, {})
	var q := QuestEditorModel.new_quest_template("nova_missao_%d" % n, String(base.get("region", "canaan_village")),
		String(base.get("place_id", "canaan")), String(base.get("era_id", "patriarchs")))
	_current = ""
	_code.text = QuestEditorModel.to_json(q)
	_show_summary(q)
	_tabs.current_tab = 1
	_say("Modelo criado como rascunho. Edite o JSON e clique em Salvar (vai para data/quests/<região>/<id>.json).")


func _test_current() -> void:
	if _current == "":
		_say("Selecione e salve uma missão antes de testar.", true)
		return
	if QuestEditorModel.write_debug_boot(_current) != OK:
		_say("Não foi possível preparar o teste.", true)
		return
	EditorInterface.play_main_scene()
	_say("Jogo iniciado com \"%s\" ativa (F3 abre o painel de debug)." % _current)


func _show_dialogue() -> void:
	if _dlg_select.selected < 0:
		return
	var d := model.dialogues.get_dialogue(_dlg_select.get_item_text(_dlg_select.selected))
	_dlg_code.text = QuestEditorModel.to_json(d)


func _parse_dialogue() -> Dictionary:
	var json := JSON.new()
	if json.parse(_dlg_code.text) != OK or not (json.data is Dictionary):
		_say("JSON de diálogo inválido (linha %d)." % json.get_error_line(), true)
		return {}
	var d: Dictionary = json.data
	d["_source"] = model.dialogues.get_dialogue(String(d.get("id", ""))).get("_source", "")
	return d


func _validate_dialogue() -> void:
	var d := _parse_dialogue()
	if d.is_empty():
		return
	var errs := DialogueDatabase.validate(d)
	_say("Diálogo sem erros." if errs.is_empty() else "; ".join(errs), not errs.is_empty())


func _save_dialogue() -> void:
	var d := _parse_dialogue()
	if d.is_empty():
		return
	var errs := DialogueDatabase.validate(d)
	if not errs.is_empty():
		_say("Não salvo: " + "; ".join(errs), true)
		return
	var err := model.save_dialogue(d)
	_say("Diálogo salvo." if err == OK else "Erro ao salvar: %s" % error_string(err), err != OK)
	if err == OK:
		model.dialogues.load_dir(QuestEditorModel.DIALOGUE_DIR)


func _say(text: String, warn := false) -> void:
	_msg.text = text
	_msg.add_theme_color_override("font_color", Color(0.9, 0.45, 0.4) if warn else Color(0.7, 0.85, 0.7))
