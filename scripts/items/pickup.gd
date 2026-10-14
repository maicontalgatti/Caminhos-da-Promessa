class_name Pickup
extends Node2D
## Item no chão definido em "pickups" da região: {id, item, qty?, x, y,
## visible_if?}. "E — Coletar" adiciona à bolsa, marca o objeto como coletado
## (por id estável, salvo com a partida) e avisa a missão. Com a bolsa cheia,
## o item fica no chão.

var region_id := ""
var pickup_id := ""
var item_id := ""
var qty := 1
var interactable: Interactable
var _taken := false


func setup(region: String, d: Dictionary) -> void:
	region_id = region
	pickup_id = String(d.get("id", ""))
	item_id = String(d.get("item", ""))
	qty = maxi(int(d.get("qty", 1)), 1)
	var left: Variant = GameState.world.get(WorldManager.world_key(region, pickup_id))
	if left is int or left is float:
		qty = clampi(int(left), 1, qty)
	name = "Pickup_" + pickup_id.to_pascal_case()


func _ready() -> void:
	add_to_group("pickup")
	var spr := Sprite2D.new()
	spr.name = "Icon"
	spr.texture = Inventory.icon(item_id)
	spr.offset = Vector2(0, -6)
	add_child(spr)
	add_child(sparkle())
	interactable = Interactable.new()
	interactable.name = "Interactable"
	interactable.kind = Interactable.Kind.COLLECT
	interactable.prompt_text = "Coletar %s" % Inventory.display_name(item_id).to_lower()
	interactable.position = Vector2(0, -4)
	interactable.prompt_offset = Vector2(0, -14)
	var cs := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 10.0
	cs.shape = circle
	interactable.add_child(cs)
	add_child(interactable)
	interactable.interacted.connect(_on_interacted)


static func sparkle() -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.name = "Sparkle"
	p.position = Vector2(0, -6)
	p.amount = 3
	p.lifetime = 1.4
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(5, 2)
	p.direction = Vector2(0, -1)
	p.gravity = Vector2(0, -4)
	p.initial_velocity_min = 0.0
	p.initial_velocity_max = 2.0
	var grad := Gradient.new()
	grad.set_color(0, Color("#fff3c4"))
	grad.set_color(1, Color(0.79, 0.64, 0.15, 0.0))
	p.color_ramp = grad
	return p


## Coleta; retorna quantas unidades entraram na bolsa.
func collect() -> int:
	if _taken or WorldManager.is_picked(region_id, pickup_id):
		return 0
	var n := Inventory.add(item_id, qty, "pickup")
	if n <= 0:
		get_tree().call_group("hud", "show_toast", "Bolsa cheia: libere espaço para levar %s." % Inventory.display_name(item_id).to_lower())
		AudioManager.play("ui_denied")
		return 0
	if n < qty:
		qty -= n
		GameState.world[WorldManager.world_key(region_id, pickup_id)] = qty
		get_tree().call_group("hud", "show_toast", "+%d %s (bolsa cheia; o resto ficou no chão)" % [n, Inventory.display_name(item_id)])
		return n
	_taken = true
	interactable.enabled = false
	WorldManager.mark_picked(region_id, pickup_id)
	get_tree().call_group("hud", "show_toast", "+%d %s" % [n, Inventory.display_name(item_id)])
	var t := create_tween()
	t.set_parallel(true)
	t.tween_property(self, "position:y", position.y - 10, 0.35)
	t.tween_property(self, "modulate:a", 0.0, 0.35)
	t.chain().tween_callback(queue_free)
	return n


func _on_interacted(_by: Node) -> void:
	collect()
