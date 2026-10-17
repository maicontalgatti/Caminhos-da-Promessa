extends SceneTree
## Teste de fluxo real pelos menus (troca de cenas via SceneRouter):
## menu -> Novo jogo -> pausa -> Salvar e voltar -> Continuar.
##   godot --headless --path . --script res://tests/flow_smoke.gd
## Autoloads são acessados por caminho porque este script compila antes deles.

var _failed := 0
var _passed := 0


func _initialize() -> void:
	_run.call_deferred()


func check(cond: bool, label: String) -> void:
	if cond:
		_passed += 1
		print("  ok   ", label)
	else:
		_failed += 1
		printerr("  FAIL ", label)


func _wait(seconds: float) -> void:
	await create_timer(seconds, true).timeout


func _press_action(action: String) -> void:
	for pressed in [true, false]:
		var ev := InputEventAction.new()
		ev.action = action
		ev.pressed = pressed
		Input.parse_input_event(ev)
		Input.flush_buffered_events()
		await process_frame


func _run() -> void:
	var save_manager: Node = root.get_node("SaveManager")
	save_manager.save_path = "user://flow_test_save.json"
	save_manager.delete_save()
	print("\n[fluxo de menus]")

	change_scene_to_file("res://scenes/ui/main_menu.tscn")
	await _wait(0.3)
	check(current_scene.name == "MainMenu", "menu principal abre")
	check(current_scene.get_node("Buttons/Continue").disabled, "Continuar desabilitado sem save")

	current_scene.get_node("Buttons/Settings").pressed.emit()
	await _wait(0.3)
	var settings: PanelContainer = current_scene.get_node("SettingsPanel")
	check(settings.visible, "Configurações abre o painel")
	var settings_rect: Rect2 = settings.get_global_rect()
	var menu_vp: Vector2 = settings.get_viewport_rect().size
	check(settings_rect.position.x >= -1.0 and settings_rect.end.x <= menu_vp.x + 1.0, "painel de Configurações cabe na largura")
	check(settings_rect.position.y >= -1.0 and settings_rect.end.y <= menu_vp.y + 1.0, "painel de Configurações cabe na altura")
	var settings_title: Label = settings.get_node("VBox/Title")
	var title_rect: Rect2 = settings_title.get_global_rect()
	check(title_rect.position.y >= settings_rect.position.y - 1.0, "título Configurações visível dentro do painel")
	check(settings.get_node_or_null("VBox/BodyScroll") != null, "Configurações usa rolagem interna")
	var voice_slider: HSlider = null
	for n in settings.find_children("*", "HSlider", true, false):
		if String(n.get_parent().name).ends_with("Voice"):
			voice_slider = n
			break
	check(voice_slider != null, "slider de Vozes existe")
	if voice_slider:
		voice_slider.value = 1.0
		await _wait(0.05)
		var track: Rect2 = voice_slider.get_global_rect()
		check(track.size.x >= 80.0, "slider de Vozes tem trilho largo o bastante em 100%%")
	settings.get_node("VBox/Back").pressed.emit()
	await _wait(0.2)
	check(not settings.visible, "Voltar fecha Configurações")

	current_scene.get_node("Buttons/NewGame").pressed.emit()
	await _wait(0.4)
	var look: PanelContainer = current_scene.get_node_or_null("LookPanel")
	check(look != null and look.visible, "Novo jogo abre a personalização do viajante")
	var focus_owner := root.get_viewport().gui_get_focus_owner()
	check(focus_owner != null and look.is_ancestor_of(focus_owner), "personalização abre com foco (teclado e controle)")
	var look_rect: Rect2 = look.get_global_rect()
	var vp_size: Vector2 = look.get_viewport_rect().size
	check(look_rect.position.x >= 0.0 and look_rect.end.x <= vp_size.x + 1.0, "painel do viajante cabe na largura")
	check(look_rect.position.y >= 0.0 and look_rect.end.y <= vp_size.y + 1.0, "painel do viajante cabe na altura")
	check(absf(look_rect.get_center().x - vp_size.x * 0.5) < 24.0, "painel do viajante centrado")
	var next_skin: Button = null
	for b in look.find_children("*", "Button", true, false):
		if String(b.text) == ">":
			next_skin = b
			break
	check(next_skin != null and next_skin.visible and next_skin.get_global_rect().end.x <= vp_size.x + 1.0, "seta de tom de pele visível")
	for b in look.find_children("*", "Button", true, false):
		if String(b.text).begins_with("Começar"):
			b.pressed.emit()
			break
	await _wait(1.2)
	check(current_scene.name == "Game", "Novo jogo abre a aldeia")
	check(get_first_node_in_group("player") != null, "jogador presente")
	var cine: CanvasLayer = current_scene.get_node("Cinematic")
	var pause_menu: CanvasLayer = current_scene.get_node("PauseMenu")
	check(cine.visible, "Novo jogo mostra o prólogo")

	await _press_action("pause")
	check(not cine.visible and not pause_menu.visible, "Esc pula o prólogo sem abrir a pausa")
	var qm: Node = root.get_node("QuestManager")
	check(qm.status("canaan_wells") == "active", "missão dos poços ativa")

	await _press_action("pause")
	check(pause_menu.visible and paused, "Esc abre a pausa e pausa o jogo")

	pause_menu.get_node("Panel/VBox/Journal").pressed.emit()
	await _wait(0.2)
	var journal: CanvasLayer = current_scene.get_node("Journal")
	check(journal.visible and paused and not pause_menu.visible, "Diário abre pela pausa")
	await _press_action("journal")
	check(not journal.visible and not paused, "J fecha o diário")
	await _press_action("pause")
	check(pause_menu.visible, "pausa reabre")

	pause_menu.get_node("Panel/VBox/SaveAndMenu").pressed.emit()
	await _wait(1.2)
	check(current_scene.name == "MainMenu" and not paused, "Salvar e voltar retorna ao menu")
	check(save_manager.has_save(), "save gravado")
	check(not current_scene.get_node("Buttons/Continue").disabled, "Continuar habilitado com save")

	current_scene.get_node("Buttons/Continue").pressed.emit()
	await _wait(1.2)
	check(current_scene.name == "Game", "Continuar volta ao jogo")
	check(not current_scene.get_node("Cinematic").visible, "Continuar não repete o prólogo")
	check(root.get_node("QuestManager").status("canaan_wells") == "active", "missão continua ativa após carregar")

	save_manager.delete_save()
	save_manager.save_path = save_manager.DEFAULT_PATH
	print("\n==== %d passaram, %d falharam ====" % [_passed, _failed])
	root.get_node("AudioManager").shutdown()
	await create_timer(0.2).timeout
	quit(1 if _failed > 0 else 0)
