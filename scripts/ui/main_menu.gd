extends Control
## Menu principal: novo jogo, continuar, configurações, créditos e sair.

const GAME_SCENE := "res://scenes/core/game.tscn"

@onready var buttons: VBoxContainer = $Buttons
@onready var new_btn: Button = $Buttons/NewGame
@onready var continue_btn: Button = $Buttons/Continue
@onready var settings_btn: Button = $Buttons/Settings
@onready var credits_btn: Button = $Buttons/Credits
@onready var quit_btn: Button = $Buttons/Quit
@onready var message: Label = $Message
@onready var confirm_panel: PanelContainer = $ConfirmPanel
@onready var settings_panel: PanelContainer = $SettingsPanel
@onready var credits_panel: PanelContainer = $CreditsPanel
@onready var fullscreen_check: CheckButton = $SettingsPanel/VBox/Fullscreen

var audio_settings: AudioSettingsPanel


func _ready() -> void:
	get_tree().paused = false
	GameState.in_game = false
	AudioManager.stop_ambience()
	new_btn.pressed.connect(_on_new_game)
	continue_btn.pressed.connect(_on_continue)
	settings_btn.pressed.connect(_open_panel.bind(settings_panel))
	credits_btn.pressed.connect(_open_panel.bind(credits_panel))
	quit_btn.pressed.connect(get_tree().quit)
	var yes: Button = $ConfirmPanel/VBox/HBox/Yes
	yes.set_meta("sfx", "ui_confirm")
	yes.pressed.connect(_start_new_game)
	var no: Button = $ConfirmPanel/VBox/HBox/No
	no.set_meta("sfx", "ui_cancel")
	no.pressed.connect(_close_panels.bind(false))
	$SettingsPanel/VBox/Back.pressed.connect(_close_panels)
	$CreditsPanel/VBox/Back.pressed.connect(_close_panels)
	fullscreen_check.button_pressed = Settings.fullscreen
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	var vbox := $SettingsPanel/VBox
	audio_settings = AudioSettingsPanel.new()
	audio_settings.name = "Audio"
	vbox.add_child(audio_settings)
	vbox.move_child(audio_settings, $SettingsPanel/VBox/Back.get_index())
	var edu := Button.new()
	edu.name = "Edu"
	edu.text = "Avisos educativos: %s" % Settings.edu_label()
	edu.tooltip_text = "Completos: cartões e avisos. Discretos: só avisos curtos. Mínimos: apenas registro no diário."
	edu.pressed.connect(func():
		Settings.cycle_edu_notifications()
		edu.text = "Avisos educativos: %s" % Settings.edu_label())
	vbox.add_child(edu)
	vbox.move_child(edu, $SettingsPanel/VBox/Back.get_index())
	var credits: Label = $CreditsPanel/VBox/Text
	credits.text = credits.text.replace("protótipo", "protótipo v%s" % ProjectSettings.get_setting("application/config/version", "?"))
	if Bible.credit() != "":
		credits.text += "\n" + Bible.credit()
	continue_btn.disabled = not SaveManager.has_save()
	_close_panels(false)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not buttons.visible:
		_close_panels()
		get_viewport().set_input_as_handled()


func _on_new_game() -> void:
	if SaveManager.has_save():
		_open_panel(confirm_panel)
	else:
		_start_new_game()


func _start_new_game() -> void:
	AudioManager.play("ui_confirm")
	GameState.new_game()
	SceneRouter.change_scene(GAME_SCENE)


func _on_continue() -> void:
	var err := GameState.load_game()
	if err != "":
		message.text = err
		AudioManager.play("ui_denied")
		return
	AudioManager.play("ui_confirm")
	SceneRouter.change_scene(GAME_SCENE)


func _open_panel(panel: PanelContainer) -> void:
	AudioManager.play("menu_open")
	buttons.hide()
	message.text = ""
	for p in [confirm_panel, settings_panel, credits_panel]:
		p.visible = p == panel
	var first := panel.find_children("*", "BaseButton", true, false)
	if not first.is_empty():
		(first[0] as Control).grab_focus()


func _close_panels(sound := true) -> void:
	if sound:
		AudioManager.play("menu_close")
	for p in [confirm_panel, settings_panel, credits_panel]:
		p.hide()
	buttons.show()
	(continue_btn if not continue_btn.disabled else new_btn).grab_focus()


func _on_fullscreen_toggled(on: bool) -> void:
	Settings.fullscreen = on
	Settings.apply()
	Settings.save_settings()
