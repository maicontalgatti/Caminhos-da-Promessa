extends CanvasLayer
## Caixa de diálogo em pergaminho: texto letra a letra, avanço manual,
## escolhas e retrato opcional. Toda a lógica de fluxo fica no DialogueManager.

const CHARS_PER_SECOND := 48.0

@onready var panel: PanelContainer = $Panel
@onready var portrait: TextureRect = $Panel/HBox/Portrait
@onready var name_label: Label = $Panel/HBox/VBox/Name
@onready var text_label: RichTextLabel = $Panel/HBox/VBox/Text
@onready var choices_box: VBoxContainer = $Panel/HBox/VBox/Choices
@onready var next_icon: TextureRect = $Panel/HBox/VBox/Next

var _typing := false
var _shown_chars := 0.0
var _choices: Array = []
var _voice := AudioStreamPlayer.new()


func _ready() -> void:
	_voice.bus = "Voice"
	add_child(_voice)
	panel.hide()
	DialogueManager.line_shown.connect(_on_line_shown)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	var t := create_tween().set_loops()
	t.tween_property(next_icon, "position:y", 1.0, 0.4).as_relative()
	t.tween_property(next_icon, "position:y", -1.0, 0.4).as_relative()


func _on_line_shown(line: Dictionary) -> void:
	panel.show()
	var speaker_name := String(line.speaker_name)
	name_label.text = speaker_name
	name_label.visible = speaker_name != ""
	portrait.texture = line.portrait
	portrait.visible = line.portrait != null
	text_label.text = String(line.text)
	text_label.visible_characters = 0
	_shown_chars = 0.0
	_typing = true
	_choices = line.choices
	for c in choices_box.get_children():
		c.queue_free()
	choices_box.hide()
	next_icon.modulate.a = 0.0
	_voice.stop()
	var voice := String(line.get("voice", ""))
	if voice != "":
		_voice.stream = load(voice)
		_voice.play()


func _process(delta: float) -> void:
	if not _typing:
		return
	var before := int(_shown_chars)
	_shown_chars += CHARS_PER_SECOND * delta
	text_label.visible_characters = int(_shown_chars)
	if Settings.text_sound and not _voice.playing and int(_shown_chars) / 3 > before / 3:
		AudioManager.play("text_blip")
	if int(_shown_chars) >= text_label.get_total_character_count():
		_finish_typing()


func _finish_typing() -> void:
	_typing = false
	text_label.visible_characters = -1
	if _choices.is_empty():
		next_icon.modulate.a = 1.0
		return
	choices_box.show()
	for i in _choices.size():
		var b := Button.new()
		b.text = "› " + String(_choices[i])
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.set_meta("sfx", "dialogue_choice")
		b.pressed.connect(DialogueManager.choose.bind(i))
		choices_box.add_child(b)
	(choices_box.get_child(0) as Button).grab_focus.call_deferred()


func _input(event: InputEvent) -> void:
	if not panel.visible:
		return
	var advance := event.is_action_pressed("interact")
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		advance = _typing or _choices.is_empty()
	if not advance:
		return
	get_viewport().set_input_as_handled()
	if _typing:
		_finish_typing()
	elif not _choices.is_empty():
		var focused := get_viewport().gui_get_focus_owner() as Button
		if focused and focused.get_parent() == choices_box:
			focused.pressed.emit()
	else:
		DialogueManager.advance()


func _on_dialogue_ended(_id: String) -> void:
	_voice.stop()
	panel.hide()
	_typing = false
	_choices = []
