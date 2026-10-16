extends CanvasLayer
## Menu de pausa (Esc): continuar, diário, rever a abertura, frequência dos
## avisos educativos, sons e volume, salvar, voltar ao menu, sair.

signal journal_requested
signal prologue_requested

const MAIN_MENU := "res://scenes/ui/main_menu.tscn"

@onready var panel: PanelContainer = $Panel
@onready var resume_btn: Button = $Panel/VBox/Resume
@onready var journal_btn: Button = $Panel/VBox/Journal
@onready var prologue_btn: Button = $Panel/VBox/Prologue
@onready var edu_btn: Button = $Panel/VBox/Edu
@onready var save_btn: Button = $Panel/VBox/Save
@onready var menu_btn: Button = $Panel/VBox/SaveAndMenu
@onready var quit_btn: Button = $Panel/VBox/Quit
@onready var status: Label = $Panel/VBox/Status

var audio_btn: Button
var audio_panel: PanelContainer
var controls_btn: Button
var controls_panel: PanelContainer
var look_btn: Button
var look_panel: PanelContainer
var _look_name: LineEdit
var _look_skin := 1
var _look_skin_label: Label


func _ready() -> void:
	hide()
	resume_btn.pressed.connect(close)
	journal_btn.pressed.connect(func():
		close(false)
		journal_requested.emit())
	prologue_btn.pressed.connect(func():
		close()
		prologue_requested.emit())
	edu_btn.pressed.connect(func():
		Settings.cycle_edu_notifications()
		_refresh_edu())
	save_btn.set_meta("sfx", "")
	save_btn.pressed.connect(_on_save)
	menu_btn.pressed.connect(_on_save_and_menu)
	quit_btn.pressed.connect(_on_quit)
	audio_btn = Button.new()
	audio_btn.name = "Audio"
	audio_btn.text = "Sons e volume"
	$Panel/VBox.add_child(audio_btn)
	$Panel/VBox.move_child(audio_btn, save_btn.get_index())
	audio_btn.pressed.connect(_open_audio)
	controls_btn = Button.new()
	controls_btn.name = "Controls"
	controls_btn.text = "Controles"
	$Panel/VBox.add_child(controls_btn)
	$Panel/VBox.move_child(controls_btn, save_btn.get_index())
	controls_btn.pressed.connect(_open_controls)
	look_btn = Button.new()
	look_btn.name = "Look"
	look_btn.text = "Viajante"
	$Panel/VBox.add_child(look_btn)
	$Panel/VBox.move_child(look_btn, save_btn.get_index())
	look_btn.pressed.connect(_open_look)
	panel.offset_top -= 12
	panel.offset_bottom += 12
	_build_audio_panel()
	_build_controls_panel()
	_build_look_panel()
	_refresh_edu()


func _refresh_edu() -> void:
	edu_btn.text = "Avisos educativos: %s" % Settings.edu_label()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("pause"):
		return
	if visible and audio_panel.visible:
		_close_audio()
	elif visible and controls_panel.visible:
		_close_controls()
	elif visible and look_panel.visible:
		_close_look()
	elif visible:
		close()
	elif not DialogueManager.is_active() and not GameState.is_ui_blocked():
		open()
	else:
		return
	get_viewport().set_input_as_handled()


func open() -> void:
	status.text = ""
	_refresh_edu()
	audio_panel.hide()
	controls_panel.hide()
	look_panel.hide()
	panel.show()
	show()
	get_tree().paused = true
	AudioManager.play("menu_open")
	resume_btn.grab_focus()


func close(sound := true) -> void:
	if sound:
		AudioManager.play("menu_close")
	hide()
	get_tree().paused = false


func _build_audio_panel() -> void:
	audio_panel = PanelContainer.new()
	audio_panel.name = "AudioPanel"
	audio_panel.set_anchors_preset(Control.PRESET_CENTER)
	audio_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	audio_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	audio_panel.custom_minimum_size = Vector2(268, 230)
	audio_panel.offset_left = -134
	audio_panel.offset_right = 134
	audio_panel.offset_top = -115
	audio_panel.offset_bottom = 115
	audio_panel.hide()
	add_child(audio_panel)
	var vb := VBoxContainer.new()
	vb.name = "VBox"
	vb.add_theme_constant_override("separation", 3)
	audio_panel.add_child(vb)
	var title := UiStyle.label("Sons e volume", 11)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(title)
	var scroll := ScrollContainer.new()
	scroll.name = "BodyScroll"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vb.add_child(scroll)
	var settings := AudioSettingsPanel.new()
	settings.name = "Audio"
	scroll.add_child(settings)
	var back := Button.new()
	back.name = "Back"
	back.text = "Voltar"
	back.pressed.connect(_close_audio)
	vb.add_child(back)


func _open_audio() -> void:
	AudioManager.play("menu_open")
	panel.hide()
	audio_panel.show()
	(audio_panel.get_node("VBox/Back") as Button).grab_focus()


func _close_audio() -> void:
	AudioManager.play("menu_close")
	audio_panel.hide()
	panel.show()
	audio_btn.grab_focus()


func _build_controls_panel() -> void:
	controls_panel = PanelContainer.new()
	controls_panel.name = "ControlsPanel"
	controls_panel.set_anchors_preset(Control.PRESET_CENTER)
	controls_panel.offset_left = -150
	controls_panel.offset_right = 150
	controls_panel.offset_top = -100
	controls_panel.offset_bottom = 100
	controls_panel.hide()
	add_child(controls_panel)
	var vb := VBoxContainer.new()
	vb.name = "VBox"
	vb.add_theme_constant_override("separation", 3)
	controls_panel.add_child(vb)
	var title := UiStyle.label("Controles", 11)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(title)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(280, 160)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vb.add_child(scroll)
	var settings := ControlsSettingsPanel.new()
	settings.name = "Controls"
	scroll.add_child(settings)
	var back := Button.new()
	back.name = "Back"
	back.text = "Voltar"
	back.pressed.connect(_close_controls)
	vb.add_child(back)


func _open_controls() -> void:
	AudioManager.play("menu_open")
	panel.hide()
	controls_panel.show()
	(controls_panel.get_node("VBox/Back") as Button).grab_focus()


func _close_controls() -> void:
	AudioManager.play("menu_close")
	controls_panel.hide()
	panel.show()
	controls_btn.grab_focus()


func _build_look_panel() -> void:
	look_panel = PanelContainer.new()
	look_panel.name = "LookPanel"
	look_panel.set_anchors_preset(Control.PRESET_CENTER)
	look_panel.offset_left = -130
	look_panel.offset_right = 130
	look_panel.offset_top = -90
	look_panel.offset_bottom = 90
	look_panel.hide()
	add_child(look_panel)
	var vb := VBoxContainer.new()
	vb.name = "VBox"
	vb.add_theme_constant_override("separation", 4)
	look_panel.add_child(vb)
	vb.add_child(UiStyle.label("Viajante", 11))
	_look_name = LineEdit.new()
	_look_name.max_length = 24
	vb.add_child(_look_name)
	var row := HBoxContainer.new()
	vb.add_child(row)
	var prev := UiStyle.small_button("<", 8)
	prev.pressed.connect(func():
		_look_skin = wrapi(_look_skin - 1, 0, TravelerLook.SKINS.size())
		_look_skin_label.text = String(TravelerLook.SKINS[_look_skin].label))
	row.add_child(prev)
	_look_skin_label = UiStyle.label("", 8, UiStyle.BROWN)
	_look_skin_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_look_skin_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row.add_child(_look_skin_label)
	var next := UiStyle.small_button(">", 8)
	next.pressed.connect(func():
		_look_skin = wrapi(_look_skin + 1, 0, TravelerLook.SKINS.size())
		_look_skin_label.text = String(TravelerLook.SKINS[_look_skin].label))
	row.add_child(next)
	var apply := Button.new()
	apply.name = "Apply"
	apply.text = "Aplicar"
	apply.pressed.connect(_apply_look)
	vb.add_child(apply)
	var back := Button.new()
	back.name = "Back"
	back.text = "Voltar"
	back.pressed.connect(_close_look)
	vb.add_child(back)


func _open_look() -> void:
	TravelerLook.ensure_defaults()
	_look_skin = TravelerLook.skin_index()
	_look_name.text = TravelerLook.display_name()
	_look_skin_label.text = String(TravelerLook.SKINS[_look_skin].label)
	AudioManager.play("menu_open")
	panel.hide()
	look_panel.show()
	_look_name.grab_focus()


func _apply_look() -> void:
	TravelerLook.set_display_name(_look_name.text)
	TravelerLook.set_skin_index(_look_skin)
	AudioManager.play("ui_confirm")
	status.text = "Aparência atualizada."
	_close_look()


func _close_look() -> void:
	AudioManager.play("menu_close")
	look_panel.hide()
	panel.show()
	look_btn.grab_focus()


func _on_save() -> void:
	var err := GameState.save_game()
	status.text = "Jogo salvo." if err == OK else "Não foi possível salvar (%s)." % error_string(err)
	AudioManager.play("save" if err == OK else "ui_denied")


func _on_save_and_menu() -> void:
	if GameState.save_game() != OK:
		status.text = "Não foi possível salvar."
		AudioManager.play("ui_denied")
		return
	SceneRouter.change_scene(MAIN_MENU)


func _on_quit() -> void:
	GameState.save_game()
	SceneRouter.quit_game()
