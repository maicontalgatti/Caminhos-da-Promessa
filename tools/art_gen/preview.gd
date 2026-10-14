extends SceneTree
## Monta uma prancha ampliada (x3) com todos os assets gerados, para revisão
## visual e para a documentação (docs/images/asset_preview.png).
##   godot --headless --path . --script res://tools/art_gen/preview.gd

const SCALE := 3


func _init() -> void:
	var files: Array[String] = []
	for dir in ["res://assets/characters", "res://assets/environments", "res://assets/tilesets", "res://assets/ui"]:
		for f in DirAccess.get_files_at(dir):
			if f.ends_with(".png") and f != "menu_bg.png":
				files.append(dir + "/" + f)
	var sheet := Image.create_empty(1400, 1300, false, Image.FORMAT_RGBA8)
	sheet.fill(Color("#3a2f28"))
	var x := 8
	var y := 8
	var row_h := 0
	for path in files:
		var img := Image.load_from_file(ProjectSettings.globalize_path(path))
		img.resize(img.get_width() * SCALE, img.get_height() * SCALE, Image.INTERPOLATE_NEAREST)
		if x + img.get_width() > sheet.get_width() - 8:
			x = 8
			y += row_h + 8
			row_h = 0
		sheet.blend_rect(img, Rect2i(Vector2i.ZERO, img.get_size()), Vector2i(x, y))
		x += img.get_width() + 8
		row_h = maxi(row_h, img.get_height())
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://docs/images"))
	sheet.save_png("res://docs/images/asset_preview.png")
	print("preview: ", files.size(), " assets")
	quit()
