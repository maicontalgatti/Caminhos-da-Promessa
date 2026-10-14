extends CanvasLayer
## Troca de cenas com transição em fade.

const FADE_TIME := 0.3

var _rect: ColorRect
var _busy := false


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	_rect = ColorRect.new()
	_rect.color = Color("#2b1d14")
	_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rect.modulate.a = 0.0
	add_child(_rect)
	if ExportSelfTest.requested():
		get_tree().root.add_child.call_deferred(ExportSelfTest.new())


func is_busy() -> bool:
	return _busy


## Escurece a tela (usado também na troca de região dentro da cena de jogo).
func fade_out(time: float = FADE_TIME) -> void:
	_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	var t := create_tween()
	t.tween_property(_rect, "modulate:a", 1.0, time)
	await t.finished


func fade_in(time: float = FADE_TIME) -> void:
	var t := create_tween()
	t.tween_property(_rect, "modulate:a", 0.0, time)
	await t.finished
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE


func change_scene(path: String) -> void:
	if _busy:
		return
	_busy = true
	_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	var t := create_tween()
	t.tween_property(_rect, "modulate:a", 1.0, FADE_TIME)
	await t.finished
	get_tree().paused = false
	var err := get_tree().change_scene_to_file(path)
	if err != OK:
		push_error("SceneRouter: não foi possível abrir %s (%s)" % [path, error_string(err)])
	await get_tree().process_frame
	await get_tree().process_frame
	var t2 := create_tween()
	t2.tween_property(_rect, "modulate:a", 0.0, FADE_TIME)
	await t2.finished
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_busy = false
