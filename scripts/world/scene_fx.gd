class_name SceneFx
extends Node2D
## Efeito visual de uma cena dirigida, desenhado por código (sem assets):
##   light_glow  luz suave num ponto ou em vários (radius, radius_from, intensity, color, points + spread, time; ao desligar: rise, time)
##   pillar      coluna de nuvem, de fogo ou nuvem com núcleo de fogo (form, height, width, light_radius, opacity; ligar de novo com time move a coluna)
##   wind        partículas finas soprando de um lado (from, strength, size)
##   water_walls corredor entre duas paredes de água de "at" até params.to, abrindo em open_time (width, wall)
##   dust        poeira distante (radius, density: low, medium, high)
## Luzes (light_glow, pillar) ficam numa camada que a tinta do mapa não escurece.

const GLOW_EFFECTS := ["light_glow", "pillar"]
const WARM := Color("#fff2c8")
const FIRE := Color("#f2a93b")
const CLOUD := Color("#e8e4da")
const WATER := Color("#2f5f86")
const WATER_FACE := Color("#6fa3c8")
const FOAM := Color("#cfe3ee")
const SEABED := Color("#8c7a5b")
const DUST := Color("#b89c74")
const SAND_WIND := Color("#e9dcc0")

static var _glow_tex: Texture2D

var key := ""
var effect := ""
var params: Dictionary = {}
## 0..1: intensidade geral (luzes) ou abertura (água).
var strength := 0.0
var glow_radius := 0.0
var _points: Array[Vector2] = []
var _t := 0.0
var _particles: CPUParticles2D
var _core: Node2D


static func glow_texture() -> Texture2D:
	if _glow_tex == null:
		var g := Gradient.new()
		g.set_color(0, Color(1, 1, 1, 1))
		g.set_color(1, Color(1, 1, 1, 0))
		g.add_point(0.45, Color(1, 1, 1, 0.45))
		var tex := GradientTexture2D.new()
		tex.gradient = g
		tex.fill = GradientTexture2D.FILL_RADIAL
		tex.fill_from = Vector2(0.5, 0.5)
		tex.fill_to = Vector2(1.0, 0.5)
		tex.width = 64
		tex.height = 64
		_glow_tex = tex
	return _glow_tex


static func is_glow(effect_name: String) -> bool:
	return effect_name in GLOW_EFFECTS


static func _vec(v: Variant) -> Vector2:
	return Vector2(float(v[0]), float(v[1]))


static func _color(p: Dictionary, fallback: Color) -> Color:
	return Color(String(p.color)) if p.get("color") is String and Color.html_is_valid(String(p.color)) else fallback


## Liga o efeito. Retorna a duração da animação de entrada (s).
func start(fx_key: String, fx: String, at: Variant, p: Dictionary) -> float:
	key = fx_key
	effect = fx
	params = p
	name = "Fx_" + fx_key.to_pascal_case()
	var dur := float(p.get("time", 0.0))
	match effect:
		"light_glow":
			_setup_points(at)
			glow_radius = float(p.get("radius_from", p.get("radius", 48.0)))
			_additive(self)
			_tween_to({"strength": float(p.get("intensity", 0.8)), "glow_radius": float(p.get("radius", 48.0))}, dur)
		"pillar":
			position = _vec(at)
			if String(p.get("form", "cloud")) == "fire":
				_additive(self)
			elif String(p.get("form", "cloud")) == "cloud_fire":
				_core = Node2D.new()
				_core.name = "Core"
				_additive(_core)
				_core.draw.connect(_draw_fire_core)
				add_child(_core)
			_tween_to({"strength": float(p.get("opacity", 1.0))}, dur if dur > 0.0 else 1.0)
		"water_walls":
			position = _vec(at)
			var d := _vec(p.to) - position
			rotation = d.angle()
			z_index = -5
			dur = float(p.get("open_time", 6.0))
			_tween_to({"strength": 1.0}, dur)
		"wind":
			position = _vec(at)
			z_index = 20
			_particles = _wind_particles(p)
			add_child(_particles)
			strength = 1.0
		"dust":
			position = _vec(at)
			z_index = 15
			_particles = _dust_particles(p)
			add_child(_particles)
			strength = 1.0
	return dur


## Ligar de novo um efeito já aceso: luz muda raio/intensidade, coluna se move.
func update(at: Variant, p: Dictionary) -> float:
	var dur := float(p.get("time", 0.0))
	for k in p:
		params[k] = p[k]
	match effect:
		"light_glow":
			_tween_to({"strength": float(p.get("intensity", strength)), "glow_radius": float(p.get("radius", glow_radius))}, dur)
		"pillar", "wind", "dust":
			if SceneDatabase._is_point(at):
				_tween_to({"position": _vec(at)}, dur)
	return dur


## Desliga com uma saída curta e se remove. Retorna a duração (s).
func stop(p: Dictionary) -> float:
	var dur := float(p.get("time", 1.0 if effect != "water_walls" else 0.0))
	if _particles:
		_particles.emitting = false
		dur = maxf(dur, _particles.lifetime)
	var props := {"strength": 0.0}
	if effect == "light_glow" and p.has("rise"):
		props["position"] = position + Vector2(0, -float(p.rise))
	if effect == "light_glow" and p.has("radius"):
		props["glow_radius"] = float(p.radius)
	var t := _tween_to(props, dur)
	if t:
		t.finished.connect(queue_free)
	else:
		queue_free()
	return dur


func _tween_to(props: Dictionary, dur: float) -> Tween:
	if dur <= 0.0:
		for k in props:
			set(k, props[k])
		queue_redraw()
		return null
	var t := create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	for k in props:
		t.tween_property(self, k, props[k], dur)
	return t


func _additive(node: CanvasItem) -> void:
	var m := CanvasItemMaterial.new()
	m.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	node.material = m


func _setup_points(at: Variant) -> void:
	_points.clear()
	if SceneDatabase._is_point(at):
		var center := _vec(at)
		var n := int(params.get("points", 0))
		if n > 0:
			var spread := _vec(params.get("spread", [160, 80]))
			var rng := RandomNumberGenerator.new()
			rng.seed = hash(key + str(center))
			for i in n:
				_points.append(center + Vector2(rng.randf_range(-0.5, 0.5) * spread.x, rng.randf_range(-0.5, 0.5) * spread.y))
		else:
			_points.append(center)
	else:
		for p in at:
			_points.append(_vec(p))


func _process(delta: float) -> void:
	_t += delta
	if effect in ["pillar", "water_walls"]:
		queue_redraw()
		if _core:
			_core.queue_redraw()
	elif effect == "light_glow" and strength > 0.0:
		queue_redraw()


func _draw() -> void:
	match effect:
		"light_glow":
			_draw_glow()
		"pillar":
			_draw_pillar()
		"water_walls":
			_draw_water()


func _draw_glow() -> void:
	var c := _color(params, WARM)
	var tex := glow_texture()
	for i in _points.size():
		var r := glow_radius * (1.0 + 0.03 * sin(_t * 1.3 + i))
		if r < 0.5:
			continue
		var p := _points[i]
		draw_texture_rect(tex, Rect2(p - Vector2(r, r), Vector2(r, r) * 2.0), false, Color(c, strength))


func _draw_pillar() -> void:
	var h := float(params.get("height", 96.0))
	var w := float(params.get("width", 28.0))
	var form := String(params.get("form", "cloud"))
	var tex := glow_texture()
	var base := FIRE if form == "fire" else CLOUD
	var a := strength * (0.55 if form == "fire" else 0.7)
	var steps := int(h / 10.0) + 2
	for i in steps:
		var y := -h * float(i) / float(steps - 1)
		var sway := sin(_t * 0.7 + i * 0.8) * 2.0
		var ww := w * (0.8 + 0.25 * sin(_t * 0.5 + i * 1.7))
		draw_texture_rect(tex, Rect2(Vector2(sway - ww, y - ww * 0.6), Vector2(ww * 2.0, ww * 1.2)), false, Color(base, a))
	if form == "fire":
		var lr := float(params.get("light_radius", 0.0))
		if lr > 0.0:
			draw_texture_rect(tex, Rect2(Vector2(-lr, -lr * 0.5), Vector2(lr * 2.0, lr)), false, Color(FIRE, strength * 0.35))


func _draw_fire_core() -> void:
	var h := float(params.get("height", 96.0))
	var w := float(params.get("width", 28.0)) * 0.45
	var tex := glow_texture()
	var steps := int(h / 12.0) + 2
	for i in steps:
		var y := -h * float(i) / float(steps - 1)
		var flick := 0.8 + 0.2 * sin(_t * 3.0 + i)
		_core.draw_texture_rect(tex, Rect2(Vector2(-w, y - w * 0.6), Vector2(w * 2.0, w * 1.2)), false, Color(FIRE, strength * 0.5 * flick))
	var lr := float(params.get("light_radius", 0.0))
	if lr > 0.0:
		_core.draw_texture_rect(tex, Rect2(Vector2(-lr, -lr * 0.5), Vector2(lr * 2.0, lr)), false, Color(FIRE, strength * 0.3))


## Corredor no eixo x local (o nó já está girado na direção de "to").
func _draw_water() -> void:
	var length := (_vec(params.to) - position).length()
	var gap := float(params.get("width", 64.0)) * strength
	var wall := float(params.get("wall", 32.0))
	if gap < 0.5:
		return
	draw_rect(Rect2(0, -gap / 2.0, length, gap), Color(SEABED, minf(strength * 1.5, 1.0)))
	for side: float in [-1.0, 1.0]:
		var inner := side * gap / 2.0
		var rect := Rect2(0, inner if side > 0 else inner - wall, length, wall)
		draw_rect(rect, Color(WATER, 0.95))
		draw_rect(Rect2(0, inner if side > 0 else inner - 3.0, length, 3.0), Color(WATER_FACE, 0.9))
		draw_rect(Rect2(0, inner + side * (wall - 1.0) if side > 0 else inner - wall, length, 1.0), Color(FOAM, 0.6))
		var n := int(length / 14.0)
		for i in n:
			var x := fmod(i * 14.0 + _t * 6.0 * side, length)
			if x < 0.0:
				x += length
			var y := inner + side * (6.0 + float(i % 3) * 7.0)
			draw_line(Vector2(x, y), Vector2(minf(x + 5.0, length), y), Color(WATER_FACE, 0.5), 1.0)


func _wind_particles(p: Dictionary) -> CPUParticles2D:
	var s := clampf(float(p.get("strength", 0.6)), 0.05, 1.0)
	var size := _vec(p.get("size", [520, 320]))
	var dirs := {"east": Vector2.LEFT, "west": Vector2.RIGHT, "north": Vector2.DOWN, "south": Vector2.UP}
	var dir: Vector2 = dirs.get(String(p.get("from", "east")), Vector2.LEFT)
	var cp := CPUParticles2D.new()
	cp.amount = int(12 + 48 * s)
	cp.lifetime = 2.4
	cp.preprocess = 2.4
	cp.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	cp.emission_rect_extents = size / 2.0
	cp.direction = dir
	cp.spread = 6.0
	cp.gravity = Vector2.ZERO
	cp.initial_velocity_min = 50.0 + 60.0 * s
	cp.initial_velocity_max = 80.0 + 90.0 * s
	cp.scale_amount_min = 1.0
	cp.scale_amount_max = 2.0
	cp.color = Color(SAND_WIND, 0.35)
	return cp


func _dust_particles(p: Dictionary) -> CPUParticles2D:
	var amounts := {"low": 12, "medium": 24, "high": 40}
	var cp := CPUParticles2D.new()
	cp.amount = int(amounts.get(String(p.get("density", "low")), 12))
	cp.lifetime = 3.0
	cp.preprocess = 3.0
	cp.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	cp.emission_sphere_radius = float(p.get("radius", 40.0))
	cp.direction = Vector2(0, -1)
	cp.spread = 50.0
	cp.gravity = Vector2(4, -3)
	cp.initial_velocity_min = 3.0
	cp.initial_velocity_max = 9.0
	cp.scale_amount_min = 2.0
	cp.scale_amount_max = 4.0
	cp.color = Color(_color(p, DUST), 0.4)
	return cp
