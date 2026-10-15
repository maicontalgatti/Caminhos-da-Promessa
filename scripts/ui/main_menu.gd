extends Control
## Menu principal: novo jogo, continuar (espaços de save), configurações, créditos e sair.

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
var slots_panel: PanelContainer
var _slots_list: VBoxContainer
var _slots_title: Label
## "load" = continuar; "new" = escolher espaço para partida nova.
var _slots_mode := "load"
var _pending_new_slot := -1
var look_panel: PanelContainer
var _look_name: LineEdit
var _look_skin := 1
var _look_skin_label: Label


func _ready() -> void:
	get_tree().paused = false
	GameState.in_game = false
	AudioManager.stop_ambience()
	SaveManager.migrate_legacy_if_needed()
	new_btn.pressed.connect(_on_new_game)
	continue_btn.pressed.connect(_on_continue)
	settings_btn.pressed.connect(_open_panel.bind(settings_panel))
	credits_btn.pressed.connect(_open_panel.bind(credits_panel))
	quit_btn.pressed.connect(SceneRouter.quit_game.bind(0))
	var yes: Button = $ConfirmPanel/VBox/HBox/Yes
	yes.set_meta("sfx", "ui_confirm")
	yes.pressed.connect(_confirm_new_or_overwrite)
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
	var controls_scroll := ScrollContainer.new()
	controls_scroll.name = "ControlsScroll"
	controls_scroll.custom_minimum_size = Vector2(0, 120)
	var controls := ControlsSettingsPanel.new()
	controls.name = "Controls"
	controls_scroll.add_child(controls)
	vbox.add_child(controls_scroll)
	vbox.move_child(controls_scroll, $SettingsPanel/VBox/Back.get_index())
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
	_build_slots_panel()
	_build_look_panel()
	_refresh_continue()
	_close_panels(false)


func _build_slots_panel() -> void:
	slots_panel = PanelContainer.new()
	slots_panel.name = "SlotsPanel"
	slots_panel.visible = false
	slots_panel.set_anchors_preset(Control.PRESET_CENTER)
	slots_panel.custom_minimum_size = Vector2(280, 0)
	slots_panel.add_theme_stylebox_override("panel", UiStyle.wood_frame())
	add_child(slots_panel)
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 4)
	slots_panel.add_child(root)
	_slots_title = UiStyle.label("JOGOS SALVOS", 8, UiStyle.BROWN)
	_slots_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(_slots_title)
	_slots_list = VBoxContainer.new()
	_slots_list.add_theme_constant_override("separation", 4)
	root.add_child(_slots_list)
	var back := Button.new()
	back.text = "Voltar"
	back.set_meta("sfx", "ui_cancel")
	back.pressed.connect(_close_panels)
	root.add_child(back)


func _refresh_continue() -> void:
	continue_btn.disabled = not SaveManager.has_any_save()
	continue_btn.text = "Continuar" if continue_btn.disabled or _occupied_count() == 1 else "Jogos salvos"


func _occupied_count() -> int:
	var n := 0
	for i in SaveManager.SLOT_COUNT:
		if SaveManager.has_save(SaveManager.slot_path(i)):
			n += 1
	return n


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not buttons.visible:
		_close_panels()
		get_viewport().set_input_as_handled()


func _on_new_game() -> void:
	if not SaveManager.uses_slots():
		_pending_new_slot = -1
		_start_new_game()
		return
	_slots_mode = "new"
	_open_slots()


func _on_continue() -> void:
	if not SaveManager.has_any_save():
		message.text = "Nenhum jogo salvo."
		AudioManager.play("ui_denied")
		return
	if not SaveManager.uses_slots():
		_load_current()
		return
	if _occupied_count() == 1:
		for i in SaveManager.SLOT_COUNT:
			if SaveManager.has_save(SaveManager.slot_path(i)):
				_load_slot(i)
				return
	_slots_mode = "load"
	_open_slots()


func _open_slots() -> void:
	_slots_title.text = "NOVO JOGO — ESCOLHA O ESPAÇO" if _slots_mode == "new" else "JOGOS SALVOS"
	_fill_slots()
	_open_panel(slots_panel)


func _fill_slots() -> void:
	for c in _slots_list.get_children():
		c.queue_free()
	for i in SaveManager.SLOT_COUNT:
		var info := SaveManager.slot_summary(i)
		var row := VBoxContainer.new()
		row.add_theme_constant_override("separation", 2)
		var desc := UiStyle.label(String(info.label), 6, UiStyle.INK, true)
		row.add_child(desc)
		var actions := HBoxContainer.new()
		actions.add_theme_constant_override("separation", 3)
		if _slots_mode == "new":
			var use := Button.new()
			use.text = "Usar este espaço" if info.get("empty", true) else "Substituir"
			use.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			use.pressed.connect(_pick_new_slot.bind(i, bool(info.get("empty", true))))
			actions.add_child(use)
		else:
			var load_btn := Button.new()
			load_btn.text = "Continuar"
			load_btn.disabled = bool(info.get("empty", true)) or bool(info.get("corrupt", false))
			load_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			load_btn.pressed.connect(_load_slot.bind(i))
			actions.add_child(load_btn)
			var erase := Button.new()
			erase.text = "Apagar"
			erase.disabled = bool(info.get("empty", true))
			erase.set_meta("sfx", "ui_cancel")
			erase.pressed.connect(_erase_slot.bind(i))
			actions.add_child(erase)
		row.add_child(actions)
		_slots_list.add_child(row)


func _pick_new_slot(slot: int, empty: bool) -> void:
	_pending_new_slot = slot
	if empty:
		_start_new_game()
	else:
		var label: Label = $ConfirmPanel/VBox/Label
		if label:
			label.text = "O espaço %d já tem um jogo. Substituir?" % (slot + 1)
		_open_panel(confirm_panel)


func _confirm_new_or_overwrite() -> void:
	if _pending_new_slot < 0:
		_start_new_game()
		return
	SaveManager.delete_save(SaveManager.slot_path(_pending_new_slot))
	_start_new_game()


func _start_new_game() -> void:
	AudioManager.play("ui_confirm")
	if _pending_new_slot >= 0 and SaveManager.uses_slots():
		SaveManager.set_active_slot(_pending_new_slot)
	_pending_new_slot = -1
	GameState.new_game()
	TravelerLook.ensure_defaults()
	_look_skin = TravelerLook.skin_index()
	_look_name.text = TravelerLook.display_name()
	_refresh_look_skin()
	_open_panel(look_panel)


func _build_look_panel() -> void:
	look_panel = PanelContainer.new()
	look_panel.name = "LookPanel"
	look_panel.visible = false
	look_panel.set_anchors_preset(Control.PRESET_CENTER)
	look_panel.custom_minimum_size = Vector2(280, 0)
	look_panel.add_theme_stylebox_override("panel", UiStyle.wood_frame())
	add_child(look_panel)
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 6)
	look_panel.add_child(root)
	root.add_child(UiStyle.label("SEU VIAJANTE", 8, UiStyle.BROWN))
	root.add_child(UiStyle.label("Nome (ficção do jogo)", 7, UiStyle.MUTED))
	_look_name = LineEdit.new()
	_look_name.max_length = 24
	_look_name.placeholder_text = TravelerLook.DEFAULT_NAME
	root.add_child(_look_name)
	root.add_child(UiStyle.label("Tom de pele", 7, UiStyle.MUTED))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	root.add_child(row)
	var prev := UiStyle.small_button("<", 8)
	prev.pressed.connect(func():
		_look_skin = wrapi(_look_skin - 1, 0, TravelerLook.SKINS.size())
		_refresh_look_skin())
	row.add_child(prev)
	_look_skin_label = UiStyle.label("", 8, UiStyle.BROWN)
	_look_skin_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_look_skin_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row.add_child(_look_skin_label)
	var next := UiStyle.small_button(">", 8)
	next.pressed.connect(func():
		_look_skin = wrapi(_look_skin + 1, 0, TravelerLook.SKINS.size())
		_refresh_look_skin())
	row.add_child(next)
	root.add_child(UiStyle.label("Roupas e panos se compram na feira da aldeia.", 6, UiStyle.MUTED))
	var go := Button.new()
	go.text = "Começar a jornada"
	go.set_meta("sfx", "ui_confirm")
	go.pressed.connect(_confirm_look_and_start)
	root.add_child(go)
	var back := Button.new()
	back.text = "Voltar"
	back.set_meta("sfx", "ui_cancel")
	back.pressed.connect(_close_panels)
	root.add_child(back)
	_refresh_look_skin()


func _refresh_look_skin() -> void:
	if _look_skin_label == null:
		return
	_look_skin_label.text = String(TravelerLook.SKINS[_look_skin].label)


func _confirm_look_and_start() -> void:
	TravelerLook.set_display_name(_look_name.text)
	TravelerLook.set_skin_index(_look_skin)
	AudioManager.play("ui_confirm")
	SceneRouter.change_scene(GAME_SCENE)


func _load_slot(slot: int) -> void:
	SaveManager.set_active_slot(slot)
	_load_current()


func _load_current() -> void:
	var err := GameState.load_game()
	if err != "":
		message.text = err
		AudioManager.play("ui_denied")
		_refresh_continue()
		return
	AudioManager.play("ui_confirm")
	SceneRouter.change_scene(GAME_SCENE)


func _erase_slot(slot: int) -> void:
	SaveManager.delete_save(SaveManager.slot_path(slot))
	AudioManager.play("ui_cancel")
	_fill_slots()
	_refresh_continue()
	if not SaveManager.has_any_save():
		_close_panels()


func _open_panel(panel: PanelContainer) -> void:
	AudioManager.play("menu_open")
	buttons.hide()
	message.text = ""
	for p in [confirm_panel, settings_panel, credits_panel, slots_panel, look_panel]:
		p.visible = p == panel
	var first := panel.find_children("*", "BaseButton", true, false)
	if not first.is_empty():
		(first[0] as Control).grab_focus()


func _close_panels(sound := true) -> void:
	if sound:
		AudioManager.play("menu_close")
	for p in [confirm_panel, settings_panel, credits_panel, slots_panel, look_panel]:
		p.hide()
	buttons.show()
	_refresh_continue()
	_pending_new_slot = -1
	var label: Label = $ConfirmPanel/VBox/Label
	if label:
		label.text = "Já existe um jogo salvo. Começar de novo apaga o progresso."
	(continue_btn if not continue_btn.disabled else new_btn).grab_focus()


func _on_fullscreen_toggled(on: bool) -> void:
	Settings.fullscreen = on
	Settings.apply()
	Settings.save_settings()
