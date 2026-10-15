extends Node
## Configurações do jogador, persistidas em user://settings.cfg.

signal changed

const PATH := "user://settings.cfg"
## Frequência dos avisos educativos: full (cartões + avisos), brief (só avisos
## discretos), minimal (apenas registro no diário).
const EDU_MODES := ["full", "brief", "minimal"]
const EDU_LABELS := {"full": "Completos", "brief": "Discretos", "minimal": "Mínimos"}
## Buses de áudio controlados pelo jogador (default_bus_layout.tres).
const AUDIO_BUSES := ["Master", "Music", "SFX", "UI", "Ambience", "Voice"]
const AUDIO_LABELS := {"Master": "Volume geral", "Music": "Música", "SFX": "Efeitos", "UI": "Interface",
	"Ambience": "Ambiente", "Voice": "Vozes"}
const DEFAULT_VOLUMES := {"Master": 1.0, "Music": 0.8, "SFX": 0.9, "UI": 0.8, "Ambience": 0.8, "Voice": 1.0}

## Os testes trocam o caminho para não tocar nas preferências do jogador.
var path := PATH
var fullscreen := false
var volumes: Dictionary = DEFAULT_VOLUMES.duplicate()
var muted: Dictionary = {}
## Som discreto ao passar o mouse sobre botões.
var ui_hover_sound := true
## Som curto enquanto o texto do diálogo aparece (desligado por padrão).
var text_sound := false
var edu_notifications := "full"
var hud_context_collapsed := false
## Espaço de save ativo (0..SaveManager.SLOT_COUNT-1).
var save_slot := 0
## Teclas remapeadas: ação -> lista de physical_keycode (vazio = padrão).
var keybinds: Dictionary = {}
var master_volume: float:
	get:
		return float(volumes.get("Master", 1.0))
	set(v):
		volumes["Master"] = clampf(v, 0.0, 1.0)

var _save_pending := false


func _ready() -> void:
	load_settings()
	apply()


func reset_defaults() -> void:
	fullscreen = false
	volumes = DEFAULT_VOLUMES.duplicate()
	muted = {}
	ui_hover_sound = true
	text_sound = false
	edu_notifications = "full"
	hud_context_collapsed = false
	save_slot = 0
	keybinds = {}


func load_settings() -> void:
	reset_defaults()
	var cfg := ConfigFile.new()
	if cfg.load(path) != OK:
		return
	fullscreen = bool(cfg.get_value("video", "fullscreen", false))
	save_slot = clampi(int(cfg.get_value("game", "save_slot", 0)), 0, 2)
	keybinds = {}
	if cfg.has_section("input"):
		for action in InputBindings.REMAPPABLE:
			if cfg.has_section_key("input", action):
				var raw: Variant = cfg.get_value("input", action, [])
				if raw is Array and not raw.is_empty():
					keybinds[action] = raw.map(func(k): return int(k))
	# Arquivos de versões anteriores só têm master_volume.
	volumes["Master"] = clampf(float(cfg.get_value("audio", "master_volume", 1.0)), 0.0, 1.0)
	for bus in AUDIO_BUSES:
		var key := "volume_" + String(bus).to_lower()
		if cfg.has_section_key("audio", key):
			volumes[bus] = clampf(float(cfg.get_value("audio", key, DEFAULT_VOLUMES[bus])), 0.0, 1.0)
		muted[bus] = bool(cfg.get_value("audio", "mute_" + String(bus).to_lower(), false))
	ui_hover_sound = bool(cfg.get_value("audio", "ui_hover", true))
	text_sound = bool(cfg.get_value("audio", "text_sound", false))
	var edu := String(cfg.get_value("learning", "notifications", "full"))
	edu_notifications = edu if edu in EDU_MODES else "full"
	hud_context_collapsed = bool(cfg.get_value("hud", "context_collapsed", false))


func save_settings() -> void:
	_save_pending = false
	var cfg := ConfigFile.new()
	cfg.set_value("video", "fullscreen", fullscreen)
	cfg.set_value("audio", "master_volume", master_volume)
	for bus in AUDIO_BUSES:
		cfg.set_value("audio", "volume_" + String(bus).to_lower(), volume(bus))
		cfg.set_value("audio", "mute_" + String(bus).to_lower(), is_muted(bus))
	cfg.set_value("audio", "ui_hover", ui_hover_sound)
	cfg.set_value("audio", "text_sound", text_sound)
	cfg.set_value("learning", "notifications", edu_notifications)
	cfg.set_value("hud", "context_collapsed", hud_context_collapsed)
	cfg.set_value("game", "save_slot", clampi(save_slot, 0, 2))
	for action in InputBindings.REMAPPABLE:
		if keybinds.has(action):
			cfg.set_value("input", action, keybinds[action])
	cfg.save(path)
	changed.emit()


## Grava pouco depois da última mudança (ao arrastar um controle deslizante,
## por exemplo), em vez de gravar a cada valor intermediário.
func request_save() -> void:
	if _save_pending or not is_inside_tree():
		return
	_save_pending = true
	get_tree().create_timer(0.4, true).timeout.connect(func():
		if _save_pending:
			save_settings())


func volume(bus: String) -> float:
	return float(volumes.get(bus, 1.0))


func is_muted(bus: String) -> bool:
	return bool(muted.get(bus, false))


func set_volume(bus: String, v: float) -> void:
	volumes[bus] = clampf(v, 0.0, 1.0)
	apply_audio()
	request_save()


func set_muted(bus: String, on: bool) -> void:
	muted[bus] = on
	apply_audio()
	request_save()


func cycle_edu_notifications() -> void:
	edu_notifications = EDU_MODES[(EDU_MODES.find(edu_notifications) + 1) % EDU_MODES.size()]
	save_settings()


func edu_label() -> String:
	return String(EDU_LABELS[edu_notifications])


func apply() -> void:
	if DisplayServer.get_name() != "headless":
		var mode := DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
		if DisplayServer.window_get_mode() != mode:
			DisplayServer.window_set_mode(mode)
	apply_audio()
	InputBindings.apply(keybinds)


func apply_audio() -> void:
	for bus in AUDIO_BUSES:
		var idx := AudioServer.get_bus_index(bus)
		if idx < 0:
			continue
		var v := volume(bus)
		AudioServer.set_bus_volume_db(idx, linear_to_db(maxf(v, 0.0001)))
		AudioServer.set_bus_mute(idx, is_muted(bus) or v <= 0.001)
