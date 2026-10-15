class_name GearCompanion
extends Node2D
## Animal de transporte comprado na feira: segue o viajante pelo rastro, um
## pouco atrás, sem colisão (nunca bloqueia o caminho). Puramente visual; o
## efeito de jogo é o multiplicador de velocidade em Market.speed_multiplier().

const GAP := 20.0
const TELEPORT := 160.0
const MAX_TRAIL := 64

var player: Node2D
var sprite: CharacterSprite
var _trail: Array[Vector2] = []
var _sheet := {}
var _facing := Vector2.RIGHT


func setup(target: Node2D, sheet: Dictionary) -> void:
	player = target
	_sheet = sheet


func _ready() -> void:
	add_to_group("gear_companion")
	sprite = CharacterSprite.new()
	sprite.name = "Sprite"
	add_child(sprite)
	var tex: Texture2D = load(String(_sheet.get("sheet", "")))
	sprite.configure(tex, int(_sheet.get("hframes", 6)), int(_sheet.get("vframes", 2)), int(_sheet.get("directions", 2)))
	if is_instance_valid(player):
		global_position = player.global_position + Vector2(-GAP, 2)


func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		queue_free()
		return
	var p := player.global_position
	if _trail.is_empty() or _trail[-1].distance_to(p) > 2.0:
		_trail.append(p)
		if _trail.size() > MAX_TRAIL:
			_trail.pop_front()
	if global_position.distance_to(p) > TELEPORT:
		global_position = p + Vector2(-GAP, 2)
		_trail.clear()
	var target := global_position
	# Ponto do rastro a GAP px do jogador, medido ao longo do caminho.
	var acc := 0.0
	for i in range(_trail.size() - 1, 0, -1):
		acc += _trail[i].distance_to(_trail[i - 1])
		if acc >= GAP:
			target = _trail[i - 1]
			break
	var before := global_position
	if global_position.distance_to(p) > GAP:
		global_position = global_position.move_toward(target, maxf(global_position.distance_to(target) * 8.0, 30.0) * delta)
	var vel := (global_position - before) / maxf(delta, 0.0001)
	if vel.length() > 4.0:
		_facing = vel
	sprite.update_animation(vel, _facing, clampf(vel.length() / 72.0, 0.5, 1.6), delta)
