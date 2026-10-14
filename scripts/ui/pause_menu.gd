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
	panel.offset_top -= 8
	panel.offset_bottom += 8
	_build_audio_panel()
	_refresh_edu()


func _refresh_edu() -> void:
	edu_btn.text = "Avisos educativos: %s" % Settings.edu_label()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("pause"):
		return
	if visible and audio_panel.visible:
		_close_audio()
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
	audio_panel.offset_left = -125
	audio_panel.offset_right = 125
	audio_panel.offset_top = -78
	audio_panel.offset_bottom = 78
	audio_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	audio_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	audio_panel.hide()
	add_child(audio_panel)
	var vb := VBoxContainer.new()
	vb.name = "VBox"
	vb.add_theme_constant_override("separation", 3)
	audio_panel.add_child(vb)
	var title := UiStyle.label("Sons e volume", 11)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(title)
	var settings := AudioSettingsPanel.new()
	settings.name = "Audio"
	vb.add_child(settings)
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
	get_tree().quit()
