class_name CharacterSprite
extends Sprite2D
## Anima folhas de sprite no padrão do art bible:
## colunas 0..walk_frames-1 = andar, idle_start.. = parado;
## linhas = direções (4 direções: baixo, esquerda, direita, cima;
## 2 direções: direita, esquerda).

@export var directions := 4
@export var walk_frames := 4
@export var idle_start := 4
@export var idle_frames := 2
@export var walk_fps := 8.0
@export var idle_fps := 1.5
## Quadros da caminhada em que um pé toca o chão (sinal `step`).
@export var contact_frames: Array[int] = [0, 2]

## Pé no chão durante a caminhada; quem escuta decide se toca o passo.
signal step

var _time := 0.0
var _last_horizontal := 1.0
var _last_col := -1


## Ajusta a folha e posiciona os pés do personagem na origem do nó.
func configure(sheet: Texture2D, h: int, v: int, dirs: int) -> void:
	texture = sheet
	hframes = h
	vframes = v
	directions = dirs
	centered = false
	var fw := sheet.get_width() / h
	var fh := sheet.get_height() / v
	offset = Vector2(-fw / 2, -fh + 1)


func update_animation(velocity: Vector2, facing: Vector2, speed_ratio: float, delta: float) -> void:
	_time += delta
	var row := _row_for(facing)
	var col: int
	if velocity.length() > 4.0:
		col = int(_time * walk_fps * maxf(speed_ratio, 0.5)) % walk_frames
		if col != _last_col and col in contact_frames:
			step.emit()
	else:
		col = idle_start + int(_time * idle_fps) % idle_frames
	_last_col = col
	frame = row * hframes + col


func _row_for(facing: Vector2) -> int:
	if absf(facing.x) > 0.01:
		_last_horizontal = signf(facing.x)
	if directions == 2:
		return 0 if _last_horizontal > 0 else 1
	if absf(facing.x) >= absf(facing.y):
		return 2 if facing.x > 0 else 1
	return 0 if facing.y > 0 else 3
