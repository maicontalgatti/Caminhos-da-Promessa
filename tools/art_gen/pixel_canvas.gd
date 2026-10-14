extends RefCounted
## Tela de pintura pixel a pixel usada pelo gerador de arte provisória.

var img: Image
var w: int
var h: int


func _init(width: int, height: int) -> void:
	w = width
	h = height
	img = Image.create_empty(w, h, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))


func inside(x: int, y: int) -> bool:
	return x >= 0 and y >= 0 and x < w and y < h


func px(x: int, y: int, col: Color) -> void:
	if inside(x, y):
		img.set_pixel(x, y, col)


func get_px(x: int, y: int) -> Color:
	if inside(x, y):
		return img.get_pixel(x, y)
	return Color(0, 0, 0, 0)


func is_solid(x: int, y: int) -> bool:
	return get_px(x, y).a > 0.9


func rect(x: int, y: int, rw: int, rh: int, col: Color) -> void:
	for yy in range(y, y + rh):
		for xx in range(x, x + rw):
			px(xx, yy, col)


func ellipse(cx: float, cy: float, rx: float, ry: float, col: Color, max_y: float = INF) -> void:
	for y in range(floori(cy - ry) - 1, ceili(cy + ry) + 1):
		if y > max_y:
			continue
		for x in range(floori(cx - rx) - 1, ceili(cx + rx) + 1):
			var dx := (x + 0.5 - cx) / rx
			var dy := (y + 0.5 - cy) / ry
			if dx * dx + dy * dy <= 1.0:
				px(x, y, col)


## Pinta apenas pixels já ocupados dentro da elipse (para sombreamento).
func ellipse_on_solid(cx: float, cy: float, rx: float, ry: float, col: Color) -> void:
	for y in range(floori(cy - ry) - 1, ceili(cy + ry) + 1):
		for x in range(floori(cx - rx) - 1, ceili(cx + rx) + 1):
			var dx := (x + 0.5 - cx) / rx
			var dy := (y + 0.5 - cy) / ry
			if dx * dx + dy * dy <= 1.0 and is_solid(x, y):
				px(x, y, col)


func line(x0: int, y0: int, x1: int, y1: int, col: Color) -> void:
	var dx := absi(x1 - x0)
	var dy := -absi(y1 - y0)
	var sx := 1 if x0 < x1 else -1
	var sy := 1 if y0 < y1 else -1
	var err := dx + dy
	while true:
		px(x0, y0, col)
		if x0 == x1 and y0 == y1:
			break
		var e2 := 2 * err
		if e2 >= dy:
			err += dy
			x0 += sx
		if e2 <= dx:
			err += dx
			y0 += sy


## Sombra suave no chão: só ocupa pixels transparentes.
func shadow(cx: float, cy: float, rx: float, ry: float, alpha: float = 0.32) -> void:
	var col := Color(0.17, 0.11, 0.08, alpha)
	for y in range(floori(cy - ry) - 1, ceili(cy + ry) + 1):
		for x in range(floori(cx - rx) - 1, ceili(cx + rx) + 1):
			var dx := (x + 0.5 - cx) / rx
			var dy := (y + 0.5 - cy) / ry
			if dx * dx + dy * dy <= 1.0 and get_px(x, y).a == 0.0:
				px(x, y, col)


## Contorno colorido: escurece a cor do vizinho e mistura com a tinta.
## Nunca usa preto puro, conforme o art bible.
func outline(ink: Color, region: Rect2i = Rect2i(0, 0, 0, 0)) -> void:
	if region.size == Vector2i.ZERO:
		region = Rect2i(0, 0, w, h)
	var src := img.duplicate() as Image
	var dirs := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
	for y in range(region.position.y, region.end.y):
		for x in range(region.position.x, region.end.x):
			if src.get_pixel(x, y).a > 0.5:
				continue
			for d in dirs:
				var nx: int = x + d.x
				var ny: int = y + d.y
				if nx < region.position.x or ny < region.position.y or nx >= region.end.x or ny >= region.end.y:
					continue
				var n := src.get_pixel(nx, ny)
				if n.a > 0.9:
					var o := n.darkened(0.55).lerp(ink, 0.55)
					o.a = 1.0
					img.set_pixel(x, y, o)
					break


## Salpica cores sobre pixels sólidos de uma região (textura).
func speckle(region: Rect2i, colors: Array, density: float, rng: RandomNumberGenerator, only_on: Variant = null) -> void:
	for y in range(region.position.y, region.end.y):
		for x in range(region.position.x, region.end.x):
			if not is_solid(x, y):
				continue
			if only_on != null and not get_px(x, y).is_equal_approx(only_on):
				continue
			if rng.randf() < density:
				px(x, y, colors[rng.randi() % colors.size()])


func blit(other, ox: int, oy: int) -> void:
	img.blend_rect(other.img, Rect2i(0, 0, other.w, other.h), Vector2i(ox, oy))


func flipped_x():
	var copy = get_script().new(w, h)
	copy.img = img.duplicate()
	copy.img.flip_x()
	return copy


func save(path: String) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	var err := img.save_png(path)
	if err != OK:
		push_error("Falha ao salvar %s (%s)" % [path, error_string(err)])
