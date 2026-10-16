class_name AudioSettingsPanel
extends VBoxContainer
## Controles de áudio (volume por categoria, silenciar, hover e som do texto).
## Aplica em tempo real e grava em Settings. Usado no menu principal e na pausa.

## Som de teste ao ajustar cada categoria (sem som: categoria ainda sem conteúdo).
const PREVIEW := {"Master": "ui_confirm", "SFX": "item_pickup", "UI": "ui_click", "Ambience": "amb_bird"}
const PREVIEW_INTERVAL := 0.25
const EMPTY_NOTE := {"Voice": "sem vozes gravadas"}
const NOTE := {"Music": "hinos e temas instrumentais, baixos, que mudam conforme o momento da história"}

var _sliders := {}
var _values := {}
var _mutes := {}
var _last_preview := {}


func _ready() -> void:
	add_theme_constant_override("separation", 1)
	for bus in Settings.AUDIO_BUSES:
		_add_row(String(bus))
	var hover := CheckBox.new()
	hover.text = "Som ao passar o mouse nos botões"
	hover.add_theme_font_size_override("font_size", 7)
	hover.button_pressed = Settings.ui_hover_sound
	hover.toggled.connect(func(on):
		Settings.ui_hover_sound = on
		Settings.request_save())
	add_child(hover)
	var text := CheckBox.new()
	text.text = "Som discreto do texto nos diálogos"
	text.add_theme_font_size_override("font_size", 7)
	text.button_pressed = Settings.text_sound
	text.toggled.connect(func(on):
		Settings.text_sound = on
		Settings.request_save())
	add_child(text)


func _add_row(bus: String) -> void:
	var row := HBoxContainer.new()
	row.name = "Row" + bus
	row.add_theme_constant_override("separation", 3)
	var l := UiStyle.label(String(Settings.AUDIO_LABELS.get(bus, bus)), 7)
	l.custom_minimum_size.x = 56
	l.clip_text = true
	if EMPTY_NOTE.has(bus) or NOTE.has(bus):
		l.tooltip_text = String(EMPTY_NOTE.get(bus, NOTE.get(bus, "")))
		l.mouse_filter = Control.MOUSE_FILTER_PASS
	row.add_child(l)
	var s := HSlider.new()
	s.name = "Slider"
	s.min_value = 0.0
	s.max_value = 1.0
	s.step = 0.05
	s.custom_minimum_size = Vector2(90, 14)
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	s.value = Settings.volume(bus)
	s.value_changed.connect(_on_volume.bind(bus))
	row.add_child(s)
	var v := UiStyle.label("", 7, UiStyle.MUTED)
	## "100%" precisa de mais que 26 px; senão o trilho encolhe e o botão do slider vaza.
	v.custom_minimum_size.x = 30
	v.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(v)
	var m := CheckBox.new()
	m.name = "Mute"
	m.tooltip_text = "Silenciar " + String(Settings.AUDIO_LABELS.get(bus, bus)).to_lower()
	m.button_pressed = Settings.is_muted(bus)
	m.toggled.connect(_on_mute.bind(bus))
	row.add_child(m)
	add_child(row)
	_sliders[bus] = s
	_values[bus] = v
	_mutes[bus] = m
	_refresh(bus)


func slider(bus: String) -> HSlider:
	return _sliders.get(bus)


func mute_box(bus: String) -> CheckBox:
	return _mutes.get(bus)


func _refresh(bus: String) -> void:
	var label: Label = _values[bus]
	label.text = "mudo" if Settings.is_muted(bus) else "%d%%" % roundi(Settings.volume(bus) * 100.0)


func _on_volume(v: float, bus: String) -> void:
	Settings.set_volume(bus, v)
	_refresh(bus)
	_preview(bus)


func _on_mute(on: bool, bus: String) -> void:
	Settings.set_muted(bus, on)
	_refresh(bus)
	if not on:
		_preview(bus)


func _preview(bus: String) -> void:
	if not PREVIEW.has(bus) or Settings.is_muted(bus):
		return
	var now := Time.get_ticks_msec()
	if now - int(_last_preview.get(bus, -100000)) < int(PREVIEW_INTERVAL * 1000.0):
		return
	_last_preview[bus] = now
	AudioManager.play(String(PREVIEW[bus]))
