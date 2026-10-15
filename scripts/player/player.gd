class_name Player
extends CharacterBody2D
## Personagem do jogador: movimento em 8 direções, corrida opcional,
## animação em 4 direções, interação universal e a aparência comprada na feira
## (PlayerGear).

@export var walk_speed := 72.0
@export var run_speed := 118.0
@export var acceleration := 900.0
@export var friction := 1200.0
## Abaixo desta velocidade real (px/s) não há passo: parado ou contra parede.
@export var step_min_speed := 18.0

var facing := Vector2.DOWN
## Velocidade efetivamente percorrida no último quadro de física.
var real_speed := 0.0
var _interact_cooldown := 0.0
var gear: PlayerGear

@onready var sprite: CharacterSprite = $Sprite
@onready var detector: InteractionDetector = $InteractionDetector
@onready var camera: Camera2D = $Camera2D
@onready var prompt: Node2D = $InteractPrompt
@onready var prompt_label: Label = $InteractPrompt/Label


func _ready() -> void:
	add_to_group("player")
	GameState.before_save.connect(_on_before_save)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	detector.focus_changed.connect(_on_focus_changed)
	sprite.step.connect(_on_step)
	prompt.hide()
	gear = PlayerGear.new(self)
	add_child(gear)
	GameState.state_replaced.connect(_apply_look)
	GameState.flag_changed.connect(_on_look_flag)
	_apply_look()


func _physics_process(delta: float) -> void:
	_interact_cooldown = maxf(_interact_cooldown - delta, 0.0)
	var input := Vector2.ZERO
	if not is_blocked():
		input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var running := Input.is_action_pressed("run")
	var speed := (run_speed if running else walk_speed) * speed_multiplier()
	var rate := acceleration if input != Vector2.ZERO else friction
	velocity = velocity.move_toward(input * speed, rate * delta)
	var before := global_position
	move_and_slide()
	real_speed = global_position.distance_to(before) / maxf(delta, 0.0001)
	if input != Vector2.ZERO:
		facing = input.normalized()
		detector.facing = facing
	sprite.update_animation(velocity, facing, velocity.length() / walk_speed, delta)
	_update_prompt()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and not is_blocked() and _interact_cooldown <= 0.0:
		if detector.interact_with_focused(self):
			get_viewport().set_input_as_handled()


func is_blocked() -> bool:
	return DialogueManager.is_active() or GameState.is_ui_blocked()


## Animal de transporte comprado na feira deixa a caminhada mais rápida.
func speed_multiplier() -> float:
	return Market.speed_multiplier()


func face(direction: Vector2) -> void:
	if direction.length() > 0.01:
		facing = direction.normalized()
		detector.facing = facing


func _update_prompt() -> void:
	var target := detector.focused
	var has_target := target != null and is_instance_valid(target) and not is_blocked()
	prompt.visible = has_target
	if has_target:
		var bob := roundf(sin(Time.get_ticks_msec() / 220.0))
		prompt.global_position = (target.global_position + target.prompt_offset + Vector2(0, bob)).round()


func _on_focus_changed(target: Interactable) -> void:
	if target != null:
		prompt_label.text = target.get_prompt()


## Passo sincronizado com a animação, só com deslocamento real.
func _on_step() -> void:
	if real_speed < step_min_speed or is_blocked():
		return
	var map := get_tree().get_first_node_in_group("game_map") as GameMap
	var surface := map.surface_at(global_position) if map else ""
	AudioManager.footstep(surface, real_speed > walk_speed * 1.15)


func _on_dialogue_ended(_id: String) -> void:
	_interact_cooldown = 0.2


func _on_look_flag(flag: String, _value: Variant) -> void:
	if flag == TravelerLook.SKIN_FLAG or flag == TravelerLook.NAME_FLAG:
		_apply_look()


func _apply_look() -> void:
	TravelerLook.apply_to(sprite)


func _on_before_save() -> void:
	GameState.player_position = global_position
	GameState.player_facing = facing
