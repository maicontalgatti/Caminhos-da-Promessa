class_name NPC
extends CharacterBody2D
## Personagem não jogável configurado por data/characters/*.json.
## Comportamentos atuais: "idle" (parado, olha em volta) e "wander"
## (passeia num raio ao redor de casa). Rotinas por horário virão depois.

@export var character_id: String = ""

var data: Dictionary = {}
var behavior := "idle"
var speed := 26.0
var wander_radius := 40.0
var facing := Vector2.DOWN
var home := Vector2.ZERO

var _rng := RandomNumberGenerator.new()
var _target := Vector2.ZERO
var _wait := 0.0
var _walking := false
var _stuck_time := 0.0
var _talking := false

@onready var sprite: CharacterSprite = $Sprite
@onready var interactable: Interactable = $Interactable


func _ready() -> void:
	home = global_position
	_rng.seed = hash(character_id + str(global_position))
	_wait = _rng.randf_range(0.5, 2.5)
	data = GameData.get_character(character_id)
	if data.is_empty():
		push_warning("NPC: personagem \"%s\" não encontrado em data/characters" % character_id)
		return
	var spr: Dictionary = data.get("sprite", {})
	var sheet_path := String(spr.get("sheet", ""))
	if ResourceLoader.exists(sheet_path):
		sprite.configure(load(sheet_path), int(spr.get("hframes", 6)), int(spr.get("vframes", 4)), int(spr.get("directions", 4)))
	var beh: Dictionary = data.get("behavior", {})
	behavior = String(beh.get("type", "idle"))
	speed = float(beh.get("speed", speed))
	wander_radius = float(beh.get("wander_radius", wander_radius))
	facing = Vector2(beh.get("facing_x", 0.0), beh.get("facing_y", 1.0))
	interactable.dialogue_id = String(data.get("dialogue_id", ""))
	interactable.kind = Interactable.Kind.TALK if data.get("kind", "person") == "person" else Interactable.Kind.EXAMINE
	interactable.prompt_text = String(data.get("prompt", ""))
	interactable.interacted.connect(_on_interacted)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)


func _physics_process(delta: float) -> void:
	if _talking:
		velocity = Vector2.ZERO
	else:
		match behavior:
			"wander":
				_wander(delta)
			_:
				_idle(delta)
	move_and_slide()
	sprite.update_animation(velocity, facing, velocity.length() / maxf(speed, 1.0), delta)


func _idle(delta: float) -> void:
	velocity = Vector2.ZERO
	_wait -= delta
	if _wait <= 0.0:
		_wait = _rng.randf_range(2.5, 6.0)
		var dirs := [Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT, Vector2.DOWN]
		facing = dirs[_rng.randi() % dirs.size()]


func _wander(delta: float) -> void:
	if not _walking:
		velocity = velocity.move_toward(Vector2.ZERO, 400 * delta)
		_wait -= delta
		if _wait <= 0.0:
			var angle := _rng.randf() * TAU
			_target = home + Vector2.from_angle(angle) * _rng.randf_range(wander_radius * 0.3, wander_radius)
			_walking = true
			_stuck_time = 0.0
		return
	var to := _target - global_position
	if to.length() < 3.0 or _stuck_time > 1.2:
		_walking = false
		_wait = _rng.randf_range(1.5, 4.5)
		return
	velocity = to.normalized() * speed
	facing = to.normalized()
	if get_real_velocity().length() < speed * 0.3:
		_stuck_time += delta
	else:
		_stuck_time = 0.0


func _on_interacted(interactor: Node) -> void:
	_talking = true
	_walking = false
	if interactor is Node2D:
		var dir := (interactor as Node2D).global_position - global_position
		facing = dir.normalized()
		if interactor.has_method("face"):
			interactor.face(-dir)


func _on_dialogue_ended(_id: String) -> void:
	if _talking:
		_talking = false
		_wait = _rng.randf_range(1.0, 2.0)
