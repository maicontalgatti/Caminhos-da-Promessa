class_name Interactable
extends Area2D
## Componente único de interação. NPCs, objetos, placas e portas usam este
## mesmo nó; o comportamento específico vem de dados (dialogue_id, flags)
## ou de quem escuta o sinal `interacted`.

signal interacted(interactor: Node)

enum Kind { TALK, EXAMINE, READ, COLLECT, OPEN, DOOR }

const DEFAULT_PROMPTS := {
	Kind.TALK: "Conversar",
	Kind.EXAMINE: "Examinar",
	Kind.READ: "Ler",
	Kind.COLLECT: "Pegar",
	Kind.OPEN: "Abrir",
	Kind.DOOR: "Porta",
}

@export var kind: Kind = Kind.EXAMINE
@export var dialogue_id: String = ""
## Texto do indicador; vazio usa o padrão do tipo.
@export var prompt_text: String = ""
## Posição do balão de interação em relação a este nó.
@export var prompt_offset: Vector2 = Vector2(0, -20)
@export var set_flag_on_interact: String = ""
@export var enabled := true


func _ready() -> void:
	collision_layer = 1 << 3
	collision_mask = 0
	monitoring = false
	monitorable = true
	add_to_group("interactable")


func get_prompt() -> String:
	return prompt_text if prompt_text != "" else String(DEFAULT_PROMPTS.get(kind, "Interagir"))


func can_interact() -> bool:
	return enabled and not DialogueManager.is_active() and not GameState.is_ui_blocked()


func interact(interactor: Node) -> void:
	if not can_interact():
		return
	if set_flag_on_interact != "":
		GameState.set_flag(set_flag_on_interact, true)
	AudioManager.play_interaction(dialogue_id, String(Kind.keys()[kind]))
	interacted.emit(interactor)
	if dialogue_id != "":
		QuestManager.record_event("interact", dialogue_id)
		DialogueManager.start(dialogue_id)
