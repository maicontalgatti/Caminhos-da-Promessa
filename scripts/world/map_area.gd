class_name MapArea
extends Area2D
## Área nomeada de uma região ({id, rect: [x, y, w, h], label?}). Quando o
## jogador entra, registra o evento de missão "location_reached" com o id.

var region_id := ""
var area_id := ""
var data: Dictionary = {}
var rect := Rect2()


func setup(region: String, a: Dictionary) -> void:
	region_id = region
	data = a
	area_id = String(a.get("id", ""))
	name = "Area_" + area_id.to_pascal_case()
	var r: Array = a.get("rect", [0, 0, 16, 16])
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
	add_to_group("map_area")
	body_entered.connect(_on_body_entered)


func marker_position() -> Vector2:
	return global_position + Vector2(0, -8)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		QuestManager.record_event("location_reached", area_id)
