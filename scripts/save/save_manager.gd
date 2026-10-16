extends Node
## Gravação e leitura de saves em JSON versionado.
## Não conhece o GameState: recebe e devolve dicionários já validados,
## o que permite testá-lo isoladamente.
##
## Três espaços (`user://save_slot_0..2.json`). O save antigo
## `user://savegame.json` é migrado para o espaço 0 na primeira abertura.
## `slots_dir` muda a pasta dos espaços e do save antigo: os testes usam uma
## pasta própria para nunca tocar nos saves reais do jogador.

const SAVE_VERSION := 3
const ID_PATTERN := "^[a-z0-9_:/\\-]{1,96}$"
const MAX_ITEM_QTY := 999
const QUEST_STATUSES := ["active", "completed"]
const SLOT_COUNT := 3
const LEGACY_PATH := "user://savegame.json"
const DEFAULT_PATH := "user://save_slot_0.json"
const ALLOWED_FLAG_TYPES := [TYPE_BOOL, TYPE_INT, TYPE_FLOAT, TYPE_STRING]

## Caminho usado quando nenhum é informado (os testes trocam por um arquivo próprio).
var save_path := DEFAULT_PATH
## Pasta dos espaços e do save antigo (o jogo usa user://; os testes, outra).
var slots_dir := "user://"
var active_slot := 0


func _ready() -> void:
	migrate_legacy_if_needed()
	active_slot = clampi(int(Settings.save_slot) if Settings else 0, 0, SLOT_COUNT - 1)
	if uses_slots(save_path):
		save_path = slot_path(active_slot)


func slot_path(slot: int) -> String:
	return slots_dir.path_join("save_slot_%d.json" % clampi(slot, 0, SLOT_COUNT - 1))


## Save único das versões antigas, na pasta dos espaços.
func legacy_path() -> String:
	return slots_dir.path_join(LEGACY_PATH.get_file())


## Troca o espaço ativo (gravações e "Continuar" usam este caminho).
func set_active_slot(slot: int) -> void:
	active_slot = clampi(slot, 0, SLOT_COUNT - 1)
	if uses_slots(save_path):
		save_path = slot_path(active_slot)
	if Settings and Settings.save_slot != active_slot:
		Settings.save_slot = active_slot
		Settings.save_settings()


## True quando o caminho atual é um dos espaços (e não um arquivo de teste).
func uses_slots(path: String = "") -> bool:
	path = path if path != "" else save_path
	if path == slot_path(0) or path == legacy_path():
		return true
	for i in SLOT_COUNT:
		if path == slot_path(i):
			return true
	return false


## Move o save único antigo para o espaço 0, se ainda não houver espaços.
## O original só é apagado depois que a cópia deu certo.
func migrate_legacy_if_needed() -> void:
	var legacy := legacy_path()
	if not FileAccess.file_exists(legacy) and not FileAccess.file_exists(legacy + ".bak"):
		return
	for i in SLOT_COUNT:
		if has_save(slot_path(i)):
			return
	var dest := slot_path(0)
	var abs_src := ProjectSettings.globalize_path(legacy)
	var abs_dst := ProjectSettings.globalize_path(dest)
	for ext in ["", ".bak"]:
		if not FileAccess.file_exists(legacy + ext):
			continue
		var err := DirAccess.copy_absolute(abs_src + ext, abs_dst + ext)
		if err != OK:
			push_error("SaveManager: não foi possível copiar o save antigo %s (%s); ele foi mantido" % [legacy + ext, error_string(err)])
			return
		DirAccess.remove_absolute(abs_src + ext)
	if FileAccess.file_exists(legacy + ".tmp"):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(legacy + ".tmp"))


func has_save(path: String = "") -> bool:
	path = _resolve(path)
	return FileAccess.file_exists(path) or FileAccess.file_exists(path + ".bak")


func has_any_save() -> bool:
	if not uses_slots():
		return has_save()
	migrate_legacy_if_needed()
	for i in SLOT_COUNT:
		if has_save(slot_path(i)):
			return true
	return false


func delete_save(path: String = "") -> void:
	path = _resolve(path)
	for p in [path, path + ".bak", path + ".tmp"]:
		if FileAccess.file_exists(p):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(p))


## Resumo de um espaço para a tela de escolha: {empty, saved_at, play_time, region, label}.
func slot_summary(slot: int) -> Dictionary:
	var path := slot_path(slot)
	if not has_save(path):
		return {"empty": true, "slot": slot, "label": "Espaço %d — vazio" % (slot + 1)}
	var result := load_data(path)
	if not result.ok:
		return {"empty": false, "slot": slot, "corrupt": true, "label": "Espaço %d — danificado" % (slot + 1)}
	var g: Dictionary = result.data
	var rid := String(g.get("current_region", ""))
	if rid == "" and GameData:
		for id in GameData.regions:
			if String(GameData.regions[id].get("map_scene", "")) == String(g.get("current_map", "")):
				rid = String(id)
				break
	var place := rid
	if GameData and GameData.regions.has(rid):
		place = String(GameData.regions[rid].get("display_name", rid))
	var mins := int(float(g.get("play_time", 0.0)) / 60.0)
	var time_txt := "%d min" % mins if mins < 60 else "%dh %02d min" % [mins / 60, mins % 60]
	var when := ""
	# saved_at fica no envelope; relemos o arquivo só para a data.
	var raw := _peek_saved_at(path)
	when = raw if raw != "" else ""
	var label := "Espaço %d — %s · %s" % [slot + 1, place if place != "" else "Em viagem", time_txt]
	if when != "":
		label += "\n%s" % when
	return {"empty": false, "slot": slot, "corrupt": false, "play_time": float(g.get("play_time", 0.0)),
		"region": rid, "place": place, "saved_at": when, "label": label}


func _peek_saved_at(path: String) -> String:
	if not FileAccess.file_exists(path):
		path = path + ".bak"
	if not FileAccess.file_exists(path):
		return ""
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(path)) != OK or not (json.data is Dictionary):
		return ""
	return String(json.data.get("saved_at", ""))


## Grava em arquivo temporário e só então substitui o save anterior,
## mantendo uma cópia .bak do save válido mais recente.
func save_data(game_data: Dictionary, path: String = "") -> Error:
	path = _resolve(path)
	var payload := {
		"version": SAVE_VERSION,
		"saved_at": Time.get_datetime_string_from_system(),
		"game": game_data,
	}
	var tmp := path + ".tmp"
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		return FileAccess.get_open_error()
	f.store_string(JSON.stringify(payload, "\t"))
	f.close()
	var abs_path := ProjectSettings.globalize_path(path)
	if FileAccess.file_exists(path):
		# Sem cópia de segurança, o save atual não é apagado (o rename por cima
		# ainda pode falhar sem perder nada).
		if DirAccess.copy_absolute(abs_path, abs_path + ".bak") == OK:
			DirAccess.remove_absolute(abs_path)
	return DirAccess.rename_absolute(ProjectSettings.globalize_path(tmp), abs_path)


## Retorna {ok: bool, data: Dictionary, error: String, used_backup: bool}.
func load_data(path: String = "") -> Dictionary:
	path = _resolve(path)
	var result := _load_file(path)
	if result.ok:
		return result
	var backup := _load_file(path + ".bak")
	if backup.ok:
		backup.used_backup = true
		return backup
	return result


func _resolve(path: String) -> String:
	return path if path != "" else save_path


func _load_file(path: String) -> Dictionary:
	var fail := func(msg: String) -> Dictionary:
		return {"ok": false, "data": {}, "error": msg, "used_backup": false}
	if not FileAccess.file_exists(path):
		return fail.call("Nenhum jogo salvo encontrado.")
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(path)) != OK:
		return fail.call("O arquivo de save está corrompido.")
	var payload: Variant = json.data
	if not (payload is Dictionary):
		return fail.call("Formato de save inválido.")
	var version: Variant = payload.get("version")
	if not (version is float or version is int):
		return fail.call("Save sem versão.")
	if int(version) > SAVE_VERSION:
		return fail.call("Este save foi criado por uma versão mais nova do jogo.")
	var game: Variant = migrate(int(version), payload.get("game"))
	if not (game is Dictionary):
		return fail.call("Save sem dados de jogo.")
	var sanitized := sanitize_game_data(game)
	if not sanitized.ok:
		return fail.call(sanitized.error)
	return {"ok": true, "data": sanitized.data, "error": "", "used_backup": false}


## Ponto único para converter saves antigos ao formato atual.
## v1 -> v2: saves anteriores ao prólogo não reveem a abertura, e a primeira
## missão começa ao carregar (o evento de fim do prólogo é dado como ocorrido).
func migrate(from_version: int, game: Variant) -> Variant:
	if not (game is Dictionary):
		return game
	if from_version < 2:
		var flags: Variant = game.get("flags", {})
		if flags is Dictionary:
			flags["prologue_seen"] = true
			flags["ev:prologue_finished:new_game"] = true
		game["quests"] = {}
		game["discoveries"] = {}
		game["log"] = []
	# v2 -> v3: múltiplos mapas, inventário, coletas, colecionáveis. O progresso
	# existente é mantido; a região é deduzida do mapa salvo ao carregar.
	if from_version < 3:
		for k in ["inventory", "world", "collectibles"]:
			if not (game.get(k) is Dictionary):
				game[k] = {}
		if not (game.get("current_region") is String):
			game["current_region"] = ""
	return game


## Valida tipos e valores; campos ausentes recebem padrões seguros.
static func sanitize_game_data(game: Dictionary) -> Dictionary:
	var out := {}
	var map_path: Variant = game.get("current_map", "")
	if not (map_path is String) or not String(map_path).begins_with("res://"):
		return {"ok": false, "error": "Mapa salvo inválido.", "data": {}}
	out.current_map = map_path

	var pos: Variant = game.get("player_position")
	if pos == null:
		out.player_position = null
	elif pos is Dictionary and _is_finite_number(pos.get("x")) and _is_finite_number(pos.get("y")):
		out.player_position = {"x": float(pos.x), "y": float(pos.y)}
	else:
		return {"ok": false, "error": "Posição do jogador inválida.", "data": {}}

	var facing: Variant = game.get("player_facing", {"x": 0, "y": 1})
	if facing is Dictionary and _is_finite_number(facing.get("x")) and _is_finite_number(facing.get("y")):
		out.player_facing = {"x": float(facing.x), "y": float(facing.y)}
	else:
		out.player_facing = {"x": 0.0, "y": 1.0}

	var flags: Variant = game.get("flags", {})
	if not (flags is Dictionary):
		return {"ok": false, "error": "Progresso (flags) inválido.", "data": {}}
	var clean_flags := {}
	for k in flags:
		if k is String and typeof(flags[k]) in ALLOWED_FLAG_TYPES:
			clean_flags[k] = flags[k]
	out.flags = clean_flags

	var t: Variant = game.get("play_time", 0.0)
	out.play_time = maxf(float(t), 0.0) if _is_finite_number(t) else 0.0
	out.quests = _sanitize_quests(game.get("quests", {}))
	out.discoveries = {}
	var disc: Variant = game.get("discoveries", {})
	if disc is Dictionary:
		for k in disc:
			if k is String and _is_finite_number(disc[k]):
				out.discoveries[k] = float(disc[k])
	out.log = []
	var log_in: Variant = game.get("log", [])
	if log_in is Array:
		for e in log_in:
			if e is Dictionary and e.get("kind") is String and e.get("id") is String:
				out.log.append({"kind": e.kind, "id": e.id, "t": float(e.t) if _is_finite_number(e.get("t")) else 0.0})
	out.current_region = _clean_id(game.get("current_region", ""))
	out.entry_id = _clean_id(game.get("entry_id", ""))
	out.tracked_quest = _clean_id(game.get("tracked_quest", ""))
	out.inventory = {}
	var inv: Variant = game.get("inventory", {})
	if inv is Dictionary:
		for k in inv:
			if _clean_id(k) != "" and _is_finite_number(inv[k]) and int(inv[k]) > 0:
				out.inventory[k] = mini(int(inv[k]), MAX_ITEM_QTY)
	out.world = {}
	var w: Variant = game.get("world", {})
	if w is Dictionary:
		for k in w:
			if _clean_id(k) != "" and typeof(w[k]) in ALLOWED_FLAG_TYPES:
				out.world[k] = w[k]
	out.collectibles = {}
	var col: Variant = game.get("collectibles", {})
	if col is Dictionary:
		for k in col:
			if _clean_id(k) != "" and _is_finite_number(col[k]):
				out.collectibles[k] = float(col[k])
	return {"ok": true, "error": "", "data": out}


## Ids estáveis: minúsculas, dígitos e _:/- ; qualquer outra coisa vira "".
static func _clean_id(v: Variant) -> String:
	if not (v is String):
		return ""
	var re := RegEx.create_from_string(ID_PATTERN)
	return String(v) if re.search(String(v)) != null else ""


## Estado de missões: entradas inválidas são descartadas (a missão volta a não iniciada).
static func _sanitize_quests(q: Variant) -> Dictionary:
	var out := {}
	if not (q is Dictionary):
		return out
	for id in q:
		var s: Variant = q[id]
		if not (id is String) or not (s is Dictionary) or not (s.get("status") in QUEST_STATUSES):
			continue
		if not _is_finite_number(s.get("objective")):
			continue
		var hints := {}
		if s.get("hints") is Dictionary:
			for oid in s.hints:
				if oid is String and _is_finite_number(s.hints[oid]):
					hints[oid] = clampi(int(s.hints[oid]), 0, 3)
		out[id] = {
			"status": s.status,
			"objective": maxi(int(s.objective), 0),
			"hints": hints,
			"started": float(s.get("started", 0.0)) if _is_finite_number(s.get("started")) else 0.0,
			"completed": float(s.get("completed", 0.0)) if _is_finite_number(s.get("completed")) else 0.0,
			"objective_started": float(s.get("objective_started", 0.0)) if _is_finite_number(s.get("objective_started")) else 0.0,

			"objective_id": _clean_id(s.get("objective_id", "")),
		}
	return out


static func _is_finite_number(v: Variant) -> bool:
	return (v is float or v is int) and is_finite(float(v))
