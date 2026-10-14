class_name SceneActor
extends Node2D
## Figurante temporário de uma cena dirigida: um personagem de data/characters
## (folha de sprite) ou uma silhueta desenhada por código ("silhouette_<tipo>",
## com tipo deduzido do nome: family, camel, donkey, flock, sheep, goat, child,
## youth, elder, staff, merchant; o resto vira uma pessoa). Sem colisão nem
## interação: só aparece, anda e posa.

const FACING_VECTORS := {"down": Vector2.DOWN, "up": Vector2.UP, "left": Vector2.LEFT, "right": Vector2.RIGHT}
const SILHOUETTE_COLOR := Color(0.17, 0.13, 0.11, 0.92)
const KINDS := ["family", "camel", "donkey", "flock", "sheep", "goat", "child", "youth", "elder", "staff", "merchant"]

var actor_id := ""
var sprite_id := ""
var kind := "person"
var facing := Vector2.DOWN
var pose := "stand"
var color := SILHOUETTE_COLOR
var _sprite: CharacterSprite
var _last_pos := Vector2.ZERO
var _velocity := Vector2.ZERO


func setup(id: String, sprite: String, at: Vector2, facing_name: String, pose_name: String) -> void:
	actor_id = id
	sprite_id = sprite
	name = "Actor_" + id.to_pascal_case()
	position = at
	_last_pos = at
	set_facing(facing_name)
	if SceneDatabase.is_silhouette(sprite):
		kind = "person"
		for k in KINDS:
			if sprite.contains(k):
				kind = k
				break
	else:
		var spr: Dictionary = GameData.get_character(sprite).get("sprite", {})
		var sheet := String(spr.get("sheet", ""))
		if ResourceLoader.exists(sheet):
			_sprite = CharacterSprite.new()
			_sprite.name = "Sprite"
			add_child(_sprite)
			_sprite.configure(load(sheet), int(spr.get("hframes", 6)), int(spr.get("vframes", 4)), int(spr.get("directions", 4)))
	set_pose(pose_name)


func is_silhouette() -> bool:
	return _sprite == null


func set_facing(facing_name: String) -> void:
	if facing_name != "":
		facing = FACING_VECTORS.get(facing_name, facing)
	queue_redraw()


func set_pose(pose_name: String) -> void:
	pose = pose_name if pose_name != "" else "stand"
	if _sprite:
		match pose:
			"sit":
				_sprite.scale = Vector2(1.0, 0.72)
			"kneel":
				_sprite.scale = Vector2(1.0, 0.82)
			"bow", "fear":
				_sprite.scale = Vector2(1.0, 0.9)
			_:
				_sprite.scale = Vector2.ONE
	queue_redraw()


## Caminha pelos pontos com velocidade constante (px/s). Retorna o tween e a duração.
func walk(path: Array, speed: float) -> Array:
	var t := create_tween()
	var from := position
	var total := 0.0
	for p in path:
		var to := Vector2(float(p[0]), float(p[1]))
		var d := from.distance_to(to) / maxf(speed, 1.0)
		t.tween_property(self, "position", to, maxf(d, 0.01))
		total += d
		from = to
	return [t, total]


func _process(delta: float) -> void:
	_velocity = (position - _last_pos) / maxf(delta, 0.0001)
	_last_pos = position
	if _velocity.length() > 2.0:
		facing = _velocity.normalized()
		if is_silhouette():
			queue_redraw()
	if _sprite:
		_sprite.update_animation(_velocity, facing, 1.0, delta)


# --- Silhuetas --------------------------------------------------------------------

func _draw() -> void:
	if not is_silhouette():
		return
	var flip := -1.0 if facing.x < -0.1 else 1.0
	match kind:
		"family":
			_person(Vector2(-5, 0), 1.0, flip)
			_person(Vector2(5, 1), 0.95, flip)
			_person(Vector2(0, 3), 0.65, flip)
		"camel":
			_camel(flip)
		"donkey":
			_donkey(flip)
		"flock":
			for p in [Vector2(-7, 0), Vector2(0, -2), Vector2(6, 1), Vector2(-2, 4), Vector2(9, 5)]:
				_sheep(p, flip)
		"sheep", "goat":
			_sheep(Vector2.ZERO, flip)
		"child":
			_person(Vector2.ZERO, 0.65, flip)
		"youth":
			_person(Vector2.ZERO, 0.85, flip)
		"elder", "staff":
			_person(Vector2.ZERO, 1.0, flip, true)
		"merchant":
			draw_rect(Rect2(-5 * flip - (2 if flip > 0 else 0), -11, 3, 6), color.darkened(0.15))
			_person(Vector2.ZERO, 1.0, flip, true)
		_:
			_person(Vector2.ZERO, 1.0, flip)


func _person(at: Vector2, s: float, flip: float, staff := false) -> void:
	var h := 11.0
	var lean := 0.0
	match pose:
		"sit":
			h = 6.0
		"kneel":
			h = 8.0
		"fear":
			h = 9.0
		"bow":
			h = 9.0
			lean = 2.0
	var body := PackedVector2Array([at + Vector2(-3.5, 0) * s, at + Vector2(3.5, 0) * s,
		at + Vector2(2.5 + lean * flip, -h) * s, at + Vector2(-2.5 + lean * flip, -h) * s])
	draw_colored_polygon(body, color)
	draw_circle(at + Vector2(lean * 1.5 * flip, -h - 2.5) * s, 2.5 * s, color)
	if staff:
		draw_line(at + Vector2(4.5 * flip, -h - 4) * s, at + Vector2(4.5 * flip, 0) * s, color, 1.0)
	if pose == "hand_out":
		draw_line(at + Vector2(1.5 * flip, -h + 2) * s, at + Vector2(8 * flip, -h - 1) * s, color, 1.5)
	elif pose == "fear":
		draw_line(at + Vector2(-2, -h + 1) * s, at + Vector2(-3, -h - 4) * s, color, 1.0)
		draw_line(at + Vector2(2, -h + 1) * s, at + Vector2(3, -h - 4) * s, color, 1.0)


func _camel(flip: float) -> void:
	draw_rect(Rect2(-9, -13, 18, 6), color)
	draw_colored_polygon(PackedVector2Array([Vector2(-4, -13), Vector2(4, -13), Vector2(0, -17)]), color)
	draw_line(Vector2(8 * flip, -11), Vector2(11 * flip, -18), color, 2.0)
	draw_rect(Rect2(Vector2(10 * flip - (0 if flip > 0 else 4), -20), Vector2(4, 3)), color)
	for x in [-7.0, -4.0, 4.0, 7.0]:
		draw_line(Vector2(x, -7), Vector2(x, 0), color, 1.0)


func _donkey(flip: float) -> void:
	draw_rect(Rect2(-6, -8, 12, 5), color)
	draw_line(Vector2(5 * flip, -7), Vector2(7 * flip, -12), color, 2.0)
	draw_rect(Rect2(Vector2(6 * flip - (0 if flip > 0 else 3), -13), Vector2(3, 2)), color)
	draw_line(Vector2(7 * flip, -13), Vector2(7 * flip, -15), color, 1.0)
	for x in [-5.0, -3.0, 3.0, 5.0]:
		draw_line(Vector2(x, -3), Vector2(x, 0), color, 1.0)


func _sheep(at: Vector2, flip: float) -> void:
	draw_rect(Rect2(at + Vector2(-3, -5), Vector2(6, 3)), color)
	draw_rect(Rect2(at + Vector2(3 * flip - (0 if flip > 0 else 2), -6), Vector2(2, 2)), color)
	draw_line(at + Vector2(-2, -2), at + Vector2(-2, 0), color, 1.0)
	draw_line(at + Vector2(2, -2), at + Vector2(2, 0), color, 1.0)
