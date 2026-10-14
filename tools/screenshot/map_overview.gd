extends Node
## Renderiza cada mapa de região inteiro (com NPCs, examináveis e itens do
## estado inicial) em docs/images/map_<região>.png, para revisão visual.
## Precisa de GPU/janela (não roda em --headless):
##   godot --path . res://tools/screenshot/map_overview.tscn
## Opcional: só algumas regiões e outra pasta de saída (não sobrescreve docs/images):
##   godot --path . res://tools/screenshot/map_overview.tscn -- egypt_house --out=user://maps/

const OUT := "res://docs/images/"


func _ready() -> void:
	SaveManager.save_path = "user://overview_save.json"
	GameState.new_game()
	var out := OUT
	var only: Array[String] = []
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			out = a.trim_prefix("--out=")
		else:
			only.append(a)
	for rid in GameData.regions:
		if not only.is_empty() and not (String(rid) in only):
			continue
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
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out))
		img.save_png(out.path_join("map_%s.png" % rid))
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
	# Posições ainda pendentes (campo "_stage_b" das regiões novas): pontos amarelos.
	var pending: Dictionary = r.get("_stage_b", {})
	for key in ["npcs", "examinables", "pickups"]:
		for d in pending.get(key, []):
			var dot := ColorRect.new()
			dot.color = Color(1.0, 0.85, 0.1)
			dot.size = Vector2(4, 4)
			dot.position = Vector2(float(d.x) - 2, float(d.y) - 2)
			dot.z_index = 100
			map.add_child(dot)
