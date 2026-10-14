class_name MapExit
extends Area2D
## Saída de mapa criada a partir de "exits" da região:
## {id, rect: [x, y, w, h], to, entry, label, requires?, locked_text?, passage?}.
## Ao entrar com a saída aberta, viaja; fechada, avisa e empurra o jogador de volta.
## Com "passage" ({title, lines}), mostra antes o cartão "OUTRO MOMENTO DA HISTÓRIA".

const ARM_DELAY := 0.5

var region_id := ""
var exit_id := ""
var data: Dictionary = {}
var rect := Rect2()
var _armed_at := 0.0
var _cooldown := 0.0


func setup(region: String, ex: Dictionary) -> void:
	region_id = region
	data = ex
	exit_id = String(ex.get("id", ""))
	name = "Exit_" + exit_id.to_pascal_case()
	var r: Array = ex.get("rect", [0, 0, 16, 16])
	rect = Rect2(float(r[0]), float(r[1]), float(r[2]), float(r[3]))


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	monitoring = true
	monitorable = false
	position = rect.get_center()
	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	cs.shape = shape
	add_child(cs)
	add_to_group("map_exit")
	_armed_at = Time.get_ticks_msec() / 1000.0 + ARM_DELAY


## Ponto para a seta de objetivo (centro da saída, um pouco acima).
func marker_position() -> Vector2:
	return global_position + Vector2(0, -12)


func label() -> String:
	return String(data.get("label", data.get("to", "")))


func is_open() -> bool:
	return WorldManager.is_exit_open(data)


## Verificado a cada quadro (e não só na entrada): quem já estava dentro
## quando a saída armou também é atendido.
func _physics_process(delta: float) -> void:
	_cooldown = maxf(_cooldown - delta, 0.0)
	if Time.get_ticks_msec() / 1000.0 < _armed_at:
		return
	for body in get_overlapping_bodies():
		if body.is_in_group("player"):
			_on_player_inside(body as Player)
			return


## Direção "para dentro do mapa", usada para afastar o jogador de uma saída fechada.
func _inward() -> Vector2:
	var map := get_parent().get_parent() as GameMap
	var center := Vector2(map.map_size_tiles * map.tile_size) / 2.0 if map else Vector2.ZERO
	var d := center - global_position
	return Vector2(signf(d.x), 0) if rect.size.y >= rect.size.x else Vector2(0, signf(d.y))


func _on_player_inside(body: Player) -> void:
	if body.is_blocked():
		return
	if not is_open():
		if _cooldown <= 0.0:
			get_tree().call_group("hud", "show_toast", String(data.get("locked_text", "Ainda não é hora de seguir por aqui.")))
			_cooldown = 2.0
		body.global_position += _inward() * 10.0
		body.velocity = Vector2.ZERO
		return
	if data.get("passage") is Dictionary:
		body.global_position += _inward() * 10.0
		body.velocity = Vector2.ZERO
		WorldManager.travel_with_passage(String(data.to), String(data.get("entry", "default")), data.passage)
		return
	WorldManager.travel(String(data.to), String(data.get("entry", "default")))
