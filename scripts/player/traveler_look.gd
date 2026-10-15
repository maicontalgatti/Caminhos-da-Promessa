class_name TravelerLook
extends RefCounted
## Aparência básica do viajante (nome + tom de pele). Sem arte nova: o tom
## ajusta o modulate do sprite base. Roupas e panos continuam na feira (ADR-030).
## Persistido em flags: traveler:name (String), traveler:skin (int 0..n-1).

const NAME_FLAG := "traveler:name"
const SKIN_FLAG := "traveler:skin"
const DEFAULT_NAME := "Viajante"

## Tons sobrios, próximos do pixel art atual (não caricaturam etnias).
const SKINS := [
	{"id": "warm_light", "label": "Clara quente", "modulate": Color("FFE0C8")},
	{"id": "warm_mid", "label": "Média", "modulate": Color("E0A878")},
	{"id": "warm_deep", "label": "Morena", "modulate": Color("C07848")},
	{"id": "cool_deep", "label": "Escura", "modulate": Color("8A5238")},
]


static func display_name() -> String:
	var n := String(GameState.get_flag(NAME_FLAG, ""))
	return n if n.strip_edges() != "" else DEFAULT_NAME


static func set_display_name(n: String) -> void:
	var t := n.strip_edges()
	if t.length() > 24:
		t = t.substr(0, 24)
	GameState.set_flag(NAME_FLAG, t if t != "" else DEFAULT_NAME)


static func skin_index() -> int:
	return clampi(int(GameState.get_flag(SKIN_FLAG, 1)), 0, SKINS.size() - 1)


static func set_skin_index(i: int) -> void:
	GameState.set_flag(SKIN_FLAG, clampi(i, 0, SKINS.size() - 1))


static func skin_modulate(index: int = -1) -> Color:
	var i := skin_index() if index < 0 else clampi(index, 0, SKINS.size() - 1)
	return SKINS[i].modulate as Color


static func apply_to(sprite: CanvasItem) -> void:
	if sprite == null or not is_instance_valid(sprite):
		return
	sprite.modulate = skin_modulate()


static func ensure_defaults() -> void:
	if String(GameState.get_flag(NAME_FLAG, "")) == "":
		GameState.set_flag(NAME_FLAG, DEFAULT_NAME)
	if GameState.get_flag(SKIN_FLAG, null) == null:
		GameState.set_flag(SKIN_FLAG, 1)
