extends CanvasLayer
## Troca de cenas com transição em fade e encerramento do jogo.

const FADE_TIME := 0.3
## O servidor de áudio só libera as reproduções paradas no ciclo de mixagem
## seguinte; sair antes disso deixa recursos presos e erro no console.
const QUIT_AUDIO_DRAIN := 0.2
## Argumento de usuário que encerra o jogo após N quadros pelo caminho normal
## (teste de inicialização da build; `--quit-after` do motor sai sem esperar).
const BOOT_FRAMES_ARG := "--boot-frames="

var _rect: ColorRect
var _busy := false
var _quitting := false
var _boot_frames := -1


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().auto_accept_quit = false
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with(BOOT_FRAMES_ARG):
			_boot_frames = int(arg.substr(BOOT_FRAMES_ARG.length()))
	set_process(_boot_frames > 0)
	_rect = ColorRect.new()
	_rect.color = Color("#2b1d14")
	_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rect.modulate.a = 0.0
	add_child(_rect)
	if ExportSelfTest.requested():
		get_tree().root.add_child.call_deferred(ExportSelfTest.new())


func _process(_delta: float) -> void:
	if Engine.get_process_frames() >= _boot_frames:
		set_process(false)
		quit_game()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		quit_game()


## Encerra o jogo soltando o áudio antes (fechar a janela, "Sair" do menu).
## Quem precisa salvar faz isso antes de chamar.
func quit_game(code: int = 0) -> void:
	if _quitting:
		return
	_quitting = true
	AudioManager.shutdown()
	await get_tree().create_timer(QUIT_AUDIO_DRAIN, true, false, true).timeout
	get_tree().quit(code)


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
