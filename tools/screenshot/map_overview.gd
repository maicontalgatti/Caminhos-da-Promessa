extends Node
## Renderiza cada mapa de região inteiro (com NPCs, examináveis e itens do
## estado inicial) em docs/images/map_<região>.png, para revisão visual.
## Precisa de GPU/janela (não roda em --headless):
##   godot --path . res://tools/screenshot/map_overview.tscn

const OUT := "res://docs/images/"


func _ready() -> void:
	SaveManager.save_path = "user://overview_save.json"
	GameState.new_game()
	for rid in GameData.regions:
		var r: Dictionary = GameData.regions[rid]
		var scene := String(r.get("map_scene", ""))
		if not ResourceLoader.exists(scene):
			continue
		GameState.new_game()
		var vp := SubViewport.new()
		vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		vp.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
		add_child(vp)
		var map: GameMap = load(scene).instantiate()
		vp.size = map.map_size_tiles * map.tile_size
		vp.add_child(map)
		for p in map.find_children("*", "Player", true, false):
			p.camera.enabled = false
		_draw_markers(map, r)
		for i in 12:
			await get_tree().process_frame
		var img := vp.get_texture().get_image()
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
		img.save_png(OUT + "map_%s.png" % rid)
		print("map_overview: %s %s" % [rid, img.get_size()])
		vp.queue_free()
		await get_tree().process_frame
	get_tree().quit()


## Contorno das saídas (vermelho) e áreas (azul) para conferência.
func _draw_markers(map: Node2D, r: Dictionary) -> void:
	for key in ["exits", "areas"]:
		for a in r.get(key, []):
			var rect := ReferenceRect.new()
			rect.border_color = Color(0.85, 0.15, 0.1) if key == "exits" else Color(0.15, 0.35, 0.85)
			rect.border_width = 1.0
			rect.editor_only = false
			rect.position = Vector2(float(a.rect[0]), float(a.rect[1]))
			rect.size = Vector2(float(a.rect[2]), float(a.rect[3]))
			rect.z_index = 100
			map.add_child(rect)
