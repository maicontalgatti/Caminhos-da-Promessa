class_name PlayerGear
extends Node
## Aparência comprada na feira (ADR-030): camadas de roupa, cajado e pano de
## cabeça desenhadas sobre o sprite do jogador, quadro a quadro (os PNGs de
## assets/gear têm a mesma grade 6×4 de player.png), e o animal de transporte
## que segue o viajante. Reage a Market.changed e a uma partida carregada.

var player: Player
var layers: Array[Sprite2D] = []
var companion: GearCompanion
var _layer_paths: Array[String] = []
var _companion_sheet := ""


func _init(owner_player: Player) -> void:
	player = owner_player
	name = "Gear"


func _ready() -> void:
	Market.changed.connect(refresh)
	GameState.state_replaced.connect(refresh)
	refresh.call_deferred()


func _exit_tree() -> void:
	if companion and is_instance_valid(companion):
		companion.queue_free()


func refresh() -> void:
	if not is_instance_valid(player):
		return
	_refresh_layers()
	_refresh_companion()


func _refresh_layers() -> void:
	var paths := Market.layer_paths()
	if paths == _layer_paths:
		return
	_layer_paths = paths
	for l in layers:
		l.queue_free()
	layers.clear()
	var base := player.sprite
	for p in paths:
		var s := Sprite2D.new()
		s.name = "Layer_" + p.get_file().get_basename()
		s.texture = load(p)
		s.hframes = base.hframes
		s.vframes = base.vframes
		s.centered = base.centered
		s.offset = base.offset
		s.frame = base.frame
		base.add_child(s)
		layers.append(s)


func _refresh_companion() -> void:
	var c := Market.companion()
	var sheet := String(c.get("sheet", ""))
	if sheet == _companion_sheet and (sheet == "" or (companion and is_instance_valid(companion))):
		return
	_companion_sheet = sheet
	if companion and is_instance_valid(companion):
		companion.queue_free()
	companion = null
	if sheet == "" or player.get_parent() == null:
		return
	companion = GearCompanion.new()
	companion.name = "GearCompanion"
	companion.setup(player, c)
	player.get_parent().add_child.call_deferred(companion)


func _process(_delta: float) -> void:
	if layers.is_empty() or not is_instance_valid(player):
		return
	var f := player.sprite.frame
	for l in layers:
		l.frame = f
