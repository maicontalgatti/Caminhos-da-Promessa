class_name InputBindings
extends RefCounted
## Ações jogáveis: teclado (remapeável) + gamepad padrão.
## Aplicado por Settings; o painel Controles grava as teclas escolhidas.

const REMAPPABLE: Array[String] = [
	"move_left", "move_right", "move_up", "move_down", "run",
	"interact", "pause", "hint", "journal", "bible_context", "places_map",
	"inventory", "toggle_hud",
]

const LABELS := {
	"move_left": "Andar à esquerda",
	"move_right": "Andar à direita",
	"move_up": "Andar para cima",
	"move_down": "Andar para baixo",
	"run": "Correr",
	"interact": "Interagir",
	"pause": "Pausa / voltar",
	"hint": "Pista (H)",
	"journal": "Diário",
	"bible_context": "Contexto (C)",
	"places_map": "Mapa das Escrituras",
	"inventory": "Bolsa",
	"toggle_hud": "Recolher HUD",
}

## Teclas padrão (physical_keycode). A segunda é seta, quando houver.
const DEFAULT_KEYS := {
	"move_left": [KEY_A, KEY_LEFT],
	"move_right": [KEY_D, KEY_RIGHT],
	"move_up": [KEY_W, KEY_UP],
	"move_down": [KEY_S, KEY_DOWN],
	"run": [KEY_SHIFT],
	"interact": [KEY_E, KEY_SPACE],
	"pause": [KEY_ESCAPE],
	"hint": [KEY_H],
	"journal": [KEY_J],
	"bible_context": [KEY_C],
	"places_map": [KEY_M],
	"inventory": [KEY_I],
	"toggle_hud": [KEY_TAB],
}


## Aplica teclas (customizadas ou padrão) e liga o gamepad.
static func apply(custom: Dictionary = {}) -> void:
	for action in REMAPPABLE:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		InputMap.action_erase_events(action)
		var keys: Array = custom.get(action, DEFAULT_KEYS.get(action, []))
		if keys.is_empty():
			keys = DEFAULT_KEYS.get(action, [])
		for code in keys:
			_add_key(action, int(code))
		_add_gamepad(action)
	_bind_ui_gamepad()


static func defaults() -> Dictionary:
	return DEFAULT_KEYS.duplicate(true)


static func key_label(code: int) -> String:
	if code == KEY_ESCAPE:
		return "Esc"
	if code == KEY_SPACE:
		return "Espaço"
	if code == KEY_TAB:
		return "Tab"
	if code == KEY_SHIFT:
		return "Shift"
	if code == KEY_LEFT:
		return "←"
	if code == KEY_RIGHT:
		return "→"
	if code == KEY_UP:
		return "↑"
	if code == KEY_DOWN:
		return "↓"
	var name := OS.get_keycode_string(code)
	return name if name != "" else ("#%d" % code)


static func action_label(action: String) -> String:
	var parts: PackedStringArray = []
	for e in InputMap.action_get_events(action):
		if e is InputEventKey:
			var code := (e as InputEventKey).physical_keycode
			if code == 0:
				code = (e as InputEventKey).keycode
			parts.append(key_label(code))
	return ", ".join(parts) if not parts.is_empty() else "—"


static func set_primary_key(action: String, code: int, custom: Dictionary) -> Dictionary:
	var out := custom.duplicate(true)
	if not action in REMAPPABLE or code == 0:
		return out
	# Remove a tecla de outras ações.
	for a in REMAPPABLE:
		var keys: Array = out.get(a, DEFAULT_KEYS.get(a, [])).duplicate()
		keys = keys.filter(func(k): return int(k) != code)
		if a == action:
			# Mantém a segunda tecla padrão (seta) se existir e for diferente.
			var keep: Array = []
			for def in DEFAULT_KEYS.get(action, []):
				if int(def) != code and int(def) in keys:
					keep.append(int(def))
			keys = [code] + keep
		out[a] = keys
	if not out.has(action) or (out[action] as Array).is_empty():
		out[action] = [code]
	apply(out)
	return out


static func _add_key(action: String, code: int) -> void:
	if code == 0:
		return
	var e := InputEventKey.new()
	e.physical_keycode = code as Key
	InputMap.action_add_event(action, e)


static func _add_joy_button(action: String, button: JoyButton) -> void:
	var e := InputEventJoypadButton.new()
	e.button_index = button
	InputMap.action_add_event(action, e)


static func _add_joy_axis(action: String, axis: JoyAxis, value: float) -> void:
	var e := InputEventJoypadMotion.new()
	e.axis = axis
	e.axis_value = value
	InputMap.action_add_event(action, e)


static func _add_gamepad(action: String) -> void:
	match action:
		"move_left":
			_add_joy_axis(action, JOY_AXIS_LEFT_X, -1.0)
			_add_joy_button(action, JOY_BUTTON_DPAD_LEFT)
		"move_right":
			_add_joy_axis(action, JOY_AXIS_LEFT_X, 1.0)
			_add_joy_button(action, JOY_BUTTON_DPAD_RIGHT)
		"move_up":
			_add_joy_axis(action, JOY_AXIS_LEFT_Y, -1.0)
			_add_joy_button(action, JOY_BUTTON_DPAD_UP)
		"move_down":
			_add_joy_axis(action, JOY_AXIS_LEFT_Y, 1.0)
			_add_joy_button(action, JOY_BUTTON_DPAD_DOWN)
		"run":
			_add_joy_button(action, JOY_BUTTON_LEFT_SHOULDER)
			_add_joy_axis(action, JOY_AXIS_TRIGGER_LEFT, 1.0)
		"interact":
			_add_joy_button(action, JOY_BUTTON_A)
		"pause":
			_add_joy_button(action, JOY_BUTTON_START)
			_add_joy_button(action, JOY_BUTTON_BACK)
		"hint":
			_add_joy_button(action, JOY_BUTTON_Y)
		"journal":
			_add_joy_button(action, JOY_BUTTON_X)
		"bible_context":
			_add_joy_button(action, JOY_BUTTON_RIGHT_STICK)
		"places_map":
			_add_joy_button(action, JOY_BUTTON_LEFT_STICK)
		"inventory":
			_add_joy_button(action, JOY_BUTTON_RIGHT_SHOULDER)
		"toggle_hud":
			_add_joy_button(action, JOY_BUTTON_MISC1)


static func _bind_ui_gamepad() -> void:
	## Menus: A confirma, B cancela, D-pad e analógico navegam.
	_ensure_ui("ui_accept", JOY_BUTTON_A)
	_ensure_ui("ui_cancel", JOY_BUTTON_B)
	_ensure_ui("ui_left", JOY_BUTTON_DPAD_LEFT, JOY_AXIS_LEFT_X, -1.0)
	_ensure_ui("ui_right", JOY_BUTTON_DPAD_RIGHT, JOY_AXIS_LEFT_X, 1.0)
	_ensure_ui("ui_up", JOY_BUTTON_DPAD_UP, JOY_AXIS_LEFT_Y, -1.0)
	_ensure_ui("ui_down", JOY_BUTTON_DPAD_DOWN, JOY_AXIS_LEFT_Y, 1.0)


static func _ensure_ui(action: String, button: JoyButton, axis: JoyAxis = JOY_AXIS_INVALID, axis_value := 0.0) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var has_btn := false
	var has_axis := axis == JOY_AXIS_INVALID
	for e in InputMap.action_get_events(action):
		if e is InputEventJoypadButton and (e as InputEventJoypadButton).button_index == button:
			has_btn = true
		if axis != JOY_AXIS_INVALID and e is InputEventJoypadMotion \
				and (e as InputEventJoypadMotion).axis == axis \
				and signf((e as InputEventJoypadMotion).axis_value) == signf(axis_value):
			has_axis = true
	if not has_btn:
		_add_joy_button(action, button)
	if not has_axis and axis != JOY_AXIS_INVALID:
		_add_joy_axis(action, axis, axis_value)
