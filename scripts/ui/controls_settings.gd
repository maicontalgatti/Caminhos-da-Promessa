class_name ControlsSettingsPanel
extends VBoxContainer
## Remapeamento de teclas e lembrete do gamepad. Grava em Settings.keybinds.

var _buttons: Dictionary = {}
var _waiting := ""
var _status: Label


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process_unhandled_input(false)
	add_theme_constant_override("separation", 2)
	add_child(UiStyle.label("Teclado (clique e pressione a nova tecla)", 6, UiStyle.MUTED, true))
	for action in InputBindings.REMAPPABLE:
		_add_row(action)
	var reset := Button.new()
	reset.text = "Restaurar teclas padrão"
	reset.set_meta("sfx", "ui_cancel")
	reset.pressed.connect(_reset)
	add_child(reset)
	_status = UiStyle.label("Controle: analógico/D-pad anda · A interage · B/Start pausa · X diário · Y pista · RB bolsa", 6, UiStyle.MUTED, true)
	add_child(_status)


func _add_row(action: String) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	var name_l := UiStyle.label(String(InputBindings.LABELS.get(action, action)), 7)
	name_l.custom_minimum_size.x = 120
	name_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(name_l)
	var btn := Button.new()
	btn.custom_minimum_size.x = 90
	btn.text = InputBindings.action_label(action)
	btn.pressed.connect(_start_listen.bind(action))
	row.add_child(btn)
	add_child(row)
	_buttons[action] = btn


func _start_listen(action: String) -> void:
	_waiting = action
	set_process_unhandled_input(true)
	_buttons[action].text = "..."
	_status.text = "Pressione uma tecla para \"%s\" (Esc cancela)" % InputBindings.LABELS.get(action, action)


func _unhandled_input(event: InputEvent) -> void:
	if _waiting == "" or not (event is InputEventKey) or not event.pressed or event.echo:
		return
	var key := event as InputEventKey
	var code := key.physical_keycode if key.physical_keycode != KEY_NONE else key.keycode
	if code == KEY_ESCAPE:
		_waiting = ""
		set_process_unhandled_input(false)
		_refresh_all()
		_status.text = "Remapeamento cancelado."
		get_viewport().set_input_as_handled()
		return
	Settings.keybinds = InputBindings.set_primary_key(_waiting, code as int, Settings.keybinds)
	Settings.request_save()
	_waiting = ""
	set_process_unhandled_input(false)
	_refresh_all()
	_status.text = "Tecla definida. Controle: analógico/D-pad anda · A interage · Start pausa · X diário · Y pista · RB bolsa"
	get_viewport().set_input_as_handled()


func _reset() -> void:
	Settings.keybinds = {}
	InputBindings.apply({})
	Settings.request_save()
	_refresh_all()
	_status.text = "Teclas padrão restauradas."


func _refresh_all() -> void:
	for action in _buttons:
		_buttons[action].text = InputBindings.action_label(action)
