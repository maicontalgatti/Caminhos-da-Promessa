extends Node
## Capturas da feira do viajante (ADR-030): conversa com o mercador, abas
## "Vender" e "Comprar", e o viajante equipado com o jumento atrás.
## Precisa de GPU/janela:
##   godot --path . res://tools/screenshot/capture_market.tscn [-- --out=pasta/]
## Saída padrão: docs/images/market_*.png.

const OUT := "res://docs/images/"

var out := OUT
var game: Node
var hud: Node


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			out = a.trim_prefix("--out=")
	SaveManager.save_path = "user://screenshot_save_market.json"
	await _settle(10)
	GameState.new_game()
	GameState.set_flag("prologue_seen", true)
	QuestManager.record_event("prologue_finished", "new_game")
	game = load("res://scenes/core/game.tscn").instantiate()
	add_child(game)
	hud = game.get_node("HUD")
	await _settle(60)
	await _close_cards()

	WorldManager.travel("caravan_road", "from_canaan")
	await _settle(150)
	await _close_cards()
	await _settle(200)
	var player := get_tree().get_first_node_in_group("player") as Player
	player.global_position = Vector2(220, 262)
	player.face(Vector2.LEFT)
	player.camera.reset_smoothing()
	await _settle(20)
	_shot("market_merchant.png")

	for it in [["wool_tuft", 4], ["almonds", 3], ["flint_stone", 2], ["wool_cloth", 1]]:
		Inventory.add(String(it[0]), int(it[1]), "pickup")
	await _settle(10)
	game.market_screen.open("ozi")
	await _settle(20)
	_shot("market_sell.png")
	for id in ["wool_tuft", "almonds", "flint_stone", "wool_cloth"]:
		Market.sell_all(id)
	GameState.set_flag("market:silver", Market.silver() + 60)
	game.market_screen.set_tab("buy")
	await _settle(20)
	_shot("market_buy.png")
	for id in ["blue_tunic", "long_headcloth", "walking_staff", "pack_donkey"]:
		Market.buy(id, "ozi")
	await _settle(20)
	_shot("market_buy_owned.png")
	game.market_screen.close()
	await _settle(10)

	Input.action_press("move_right")
	await _settle(70)
	Input.action_release("move_right")
	await _settle(12)
	_shot("market_gear.png")

	SaveManager.delete_save()
	get_tree().quit()


func _close_cards() -> void:
	var guard := 0
	while hud.has_pending_popups() and guard < 30:
		if hud._card_open:
			hud._close_card()
		await _settle(10)
		guard += 1


func _settle(frames: int) -> void:
	await get_tree().create_timer(frames / 60.0).timeout
	await get_tree().process_frame


func _shot(file: String) -> void:
	var img := get_viewport().get_texture().get_image()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out))
	img.save_png(out.path_join(file))
	print("captura: ", file, " ", img.get_size())
