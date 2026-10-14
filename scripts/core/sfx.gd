class_name Sfx
extends RefCounted
## Compatibilidade: os nomes curtos da v0.4 (pickup, deliver, collectible,
## travel, denied) agora tocam os sons do AudioManager (data/audio/sfx.json).
## Código novo deve chamar AudioManager.play(id) diretamente.

const LEGACY := {"pickup": "item_pickup", "deliver": "item_give", "collectible": "collectible",
	"travel": "travel", "denied": "ui_denied"}


static func play(owner: Node, kind: String) -> void:
	if owner == null or not owner.is_inside_tree():
		return
	var am := owner.get_tree().root.get_node_or_null("AudioManager")
	if am != null:
		am.play(String(LEGACY.get(kind, kind)))
