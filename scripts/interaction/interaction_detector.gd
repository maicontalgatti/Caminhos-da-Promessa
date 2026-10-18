class_name InteractionDetector
extends Area2D
## Escolhe o Interactable mais adequado perto do jogador: o mais próximo,
## com preferência para o que está na direção em que o jogador olha e,
## sobretudo, para alvos do objetivo atual (evita ovelhas “roubarem” o E
## de uma brecha ou feixe da missão).

signal focus_changed(target: Interactable)

const FACING_BONUS := 8.0
const QUEST_BONUS := 48.0

var facing := Vector2.DOWN
var focused: Interactable = null


func _physics_process(_delta: float) -> void:
	var best: Interactable = null
	var best_score := INF
	for area in get_overlapping_areas():
		var it := area as Interactable
		if it == null or not it.enabled:
			continue
		var to := it.global_position - global_position
		var score := to.length()
		if to.length() > 0.01 and to.normalized().dot(facing) > 0.3:
			score -= FACING_BONUS
		if _is_quest_target(it):
			score -= QUEST_BONUS
		if score < best_score:
			best_score = score
			best = it
	if best != focused:
		focused = best
		focus_changed.emit(focused)


## true se este Interactable é um alvo do objetivo da missão mostrada no HUD.
func _is_quest_target(it: Interactable) -> bool:
	var qid := QuestManager.primary_quest()
	if qid == "" or not is_instance_valid(it):
		return false
	var obj := QuestManager.current_objective(qid)
	for t in obj.get("targets", []):
		if not (t is Dictionary):
			continue
		var type := String(t.get("type", ""))
		var id := String(t.get("id", ""))
		if id == "":
			continue
		match type:
			"examinable", "dialogue", "pickup":
				if it.dialogue_id == id:
					return true
			"npc":
				var host := it.get_parent()
				if host != null and host.get("character_id") == id:
					return true
	return false



func interact_with_focused(interactor: Node) -> bool:
	if focused == null or not is_instance_valid(focused) or not focused.can_interact():
		return false
	focused.interact(interactor)
	return true
