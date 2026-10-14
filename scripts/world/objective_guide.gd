class_name ObjectiveGuide
extends Node2D
## Indica onde está o alvo do objetivo atual: um marcador que flutua sobre o
## alvo quando ele está na tela e uma seta na borda quando está fora dela.
## Os alvos vêm de "targets" do objetivo (npc -> NPC.character_id; dialogue ->
## Interactable.dialogue_id; examinable, pickup, area, exit -> objetos da
## região). Se o objetivo fica em outra região, aponta para a saída da rota.
## Fica oculto enquanto a interface está bloqueada.

const MARGIN := 12.0
const LIFT := 4.0
const BOB_SPEED := 4.0
const FILL := Color("#c9a227")
const OUTLINE := Color("#2b1d14")

var _targets: Array[Interactable] = []
## alvos sem Interactable (áreas e saídas)
var _points: Array[Node2D] = []
var _time := 0.0


func _ready() -> void:
	z_index = 50
	for s in ["quest_started", "objective_changed", "quest_completed"]:
		QuestManager.connect(s, _on_quest_signal)
	Collectibles.collectible_found.connect(_on_quest_signal)
	refresh.call_deferred()


func _exit_tree() -> void:
	for s in ["quest_started", "objective_changed", "quest_completed"]:
		if QuestManager.is_connected(s, _on_quest_signal):
			QuestManager.disconnect(s, _on_quest_signal)
	if Collectibles.collectible_found.is_connected(_on_quest_signal):
		Collectibles.collectible_found.disconnect(_on_quest_signal)


func _on_quest_signal(_qid: String) -> void:
	refresh()


func refresh() -> void:
	_targets.clear()
	_points.clear()
	var qid := QuestManager.primary_quest()
	if qid == "" or QuestManager.status(qid) != "active":
		queue_redraw()
		return
	var map := get_parent()
	var here := String(map.region_id) if map is GameMap else ""
	var there := QuestManager.objective_region(qid)
	if here != "" and there != "" and there != here:
		_add_point(map, "exit", String(WorldManager.route_exit(here, there).get("id", "")))
		queue_redraw()
		return
	var obj := QuestManager.current_objective(qid)
	var collecting := String(obj.get("complete_on", {}).get("event", "")) in ["collection", "collection_completed", "collectible_found"]
	for t in obj.get("targets", []):
		var type := String(t.get("type", ""))
		var id := String(t.get("id", ""))
		# num objetivo de coleção, o que já foi encontrado deixa de ser destino
		if collecting and Collectibles.is_found(id):
			continue
		var it := find_target(map, type, id)
		if it:
			_targets.append(it)
		elif type == "region" and here != "":
			_add_point(map, "exit", String(WorldManager.route_exit(here, id).get("id", "")))
		else:
			_add_point(map, type, id)
	queue_redraw()


func _add_point(map: Node, type: String, id: String) -> void:
	if map is GameMap and id != "":
		var n := (map as GameMap).find_object(type, id)
		if n:
			_points.append(n)


func targets() -> Array[Interactable]:
	return _targets


## Áreas e saídas indicadas (alvos sem Interactable).
func points() -> Array[Node2D]:
	return _points


static func find_target(map: Node, type: String, id: String) -> Interactable:
	if map == null:
		return null
	if type == "npc":
		for n in map.find_children("*", "NPC", true, false):
			if String(n.character_id) == id:
				return (n as NPC).get_node_or_null("Interactable") as Interactable
	elif type == "dialogue":
		for it in map.find_children("*", "Interactable", true, false):
			if String(it.dialogue_id) == id:
				return it
	elif type in ["examinable", "pickup"] and map is GameMap:
		var n := (map as GameMap).find_object(type, id)
		if n:
			return n.get_node_or_null("Interactable") as Interactable
	return null


func is_showing() -> bool:
	return (not _targets.is_empty() or not _points.is_empty()) and not GameState.is_ui_blocked() and not DialogueManager.is_active()


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	if not is_showing():
		return
	var view := _visible_rect()
	var inner := view.grow(-MARGIN)
	var bob := sin(_time * BOB_SPEED) * 2.0
	var player := get_tree().get_first_node_in_group("player") as Player
	var focused: Interactable = player.detector.focused if player else null
	var anchors: Array[Vector2] = []
	for it in _targets:
		if is_instance_valid(it) and it != focused:
			anchors.append(it.global_position + it.prompt_offset)
	for p in _points:
		if is_instance_valid(p):
			anchors.append(p.call("marker_position") if p.has_method("marker_position") else p.global_position)
	for a in anchors:
		var anchor := to_local(a)
		if inner.has_point(anchor):
			_draw_marker(anchor + Vector2(0, -LIFT + bob))
		else:
			_draw_edge_arrow(inner, anchor, bob)


func _visible_rect() -> Rect2:
	var inv := get_viewport().get_canvas_transform().affine_inverse()
	var size := get_viewport().get_visible_rect().size
	var a := to_local(inv * Vector2.ZERO)
	var b := to_local(inv * size)
	return Rect2(a, b - a).abs()


## Triângulo apontando para baixo (ponta em `tip`), com contorno escuro.
func _draw_marker(tip: Vector2) -> void:
	var pts := PackedVector2Array([tip + Vector2(-5, -6), tip + Vector2(5, -6), tip])
	var out := PackedVector2Array([tip + Vector2(-7, -7), tip + Vector2(7, -7), tip + Vector2(0, 2)])
	draw_colored_polygon(out, OUTLINE)
	draw_colored_polygon(pts, FILL)


func _draw_edge_arrow(inner: Rect2, target: Vector2, bob: float) -> void:
	var center := inner.get_center()
	var dir := (target - center).normalized()
	if dir == Vector2.ZERO:
		return
	var tx := INF if is_zero_approx(dir.x) else ((inner.size.x * 0.5) / absf(dir.x))
	var ty := INF if is_zero_approx(dir.y) else ((inner.size.y * 0.5) / absf(dir.y))
	var pos := center + dir * minf(tx, ty) + dir * (bob * 0.5)
	var side := dir.orthogonal()
	var tip := pos + dir * 5.0
	var base := pos - dir * 4.0
	draw_colored_polygon(PackedVector2Array([tip + dir * 2.0, base + side * 7.0 - dir, base - side * 7.0 - dir]), OUTLINE)
	draw_colored_polygon(PackedVector2Array([tip, base + side * 5.0, base - side * 5.0]), FILL)
