class_name InteractionDetector
extends Area2D
## Escolhe o Interactable mais adequado perto do jogador: o mais próximo,
## com preferência para o que está na direção em que o jogador olha.

signal focus_changed(target: Interactable)

const FACING_BONUS := 8.0

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
		if score < best_score:
			best_score = score
			best = it
	if best != focused:
		focused = best
		focus_changed.emit(focused)


func interact_with_focused(interactor: Node) -> bool:
	if focused == null or not is_instance_valid(focused) or not focused.can_interact():
		return false
	focused.interact(interactor)
	return true
