extends Node
## Missões orientadas a dados (data/quests). Sistemas do jogo registram
## eventos (record_event) e as missões avançam quando o gatilho do objetivo
## atual já ocorreu. O estado fica em GameState.quests e é salvo com a partida.
##
## Eventos registrados viram flags "ev:<tipo>:<id>", o que permite completar
## um objetivo que o jogador já cumpriu antes de ele se tornar o atual.

signal quest_started(quest_id: String)
signal objective_completed(quest_id: String, objective_id: String)
signal objective_changed(quest_id: String)
signal quest_completed(quest_id: String)
signal hint_changed(quest_id: String)
signal event_recorded(type: String, id: String)
signal context_changed

const DEBUG_BOOT_PATH := "user://debug_boot.json"
const GAME_SCENE := "res://scenes/core/game.tscn"

var db := QuestDatabase.new()
## Região do mapa carregado (definida pela cena de jogo).
var current_region_id := ""
var _evaluating := false


func _ready() -> void:
	db.load_dir()
	for e in db.errors:
		push_error("QuestManager: " + e)
	GameState.state_replaced.connect(func():
		realign_objectives()
		context_changed.emit())
	if OS.is_debug_build() and FileAccess.file_exists(DEBUG_BOOT_PATH):
		_debug_boot.call_deferred()


static func event_flag(type: String, id: String) -> String:
	return "ev:%s:%s" % [type, id]


func has_event(type: String, id: String) -> bool:
	return GameState.get_flag(event_flag(type, id)) == true


func record_event(type: String, id: String) -> void:
	if type == "" or id == "":
		return
	GameState.set_flag(event_flag(type, id), true)
	if type == "region_entered":
		current_region_id = id
		context_changed.emit()
	event_recorded.emit(type, id)
	evaluate()


## Inicia missões cujas condições foram cumpridas e avança objetivos já satisfeitos.
func evaluate() -> void:
	if _evaluating:
		return
	_evaluating = true
	var changed := true
	var guard := 0
	while changed and guard < 64:
		changed = false
		guard += 1
		for id in db.order:
			match status(id):
				"":
					if _can_start(id):
						_start(id)
						changed = true
				"active":
					var obj := current_objective(id)
					if obj.is_empty():
						_complete(id)
						changed = true
					elif _trigger_met(obj.get("complete_on", {})):
						_advance(id)
						changed = true
	_evaluating = false


# --- Consulta ----------------------------------------------------------------

func status(quest_id: String) -> String:
	return String(GameState.quests.get(quest_id, {}).get("status", ""))


func is_quest_visible(quest_id: String) -> bool:
	var q := db.get_quest(quest_id)
	return not q.is_empty() and ContentPolicy.is_visible(q)


func current_objective_index(quest_id: String) -> int:
	return int(GameState.quests.get(quest_id, {}).get("objective", 0))


func current_objective(quest_id: String) -> Dictionary:
	if status(quest_id) != "active":
		return {}
	var objs: Array = db.get_quest(quest_id).get("objectives", [])
	var i := current_objective_index(quest_id)
	return objs[i] if i < objs.size() else {}


## "done", "current" ou "locked".
func objective_state(quest_id: String, index: int) -> String:
	match status(quest_id):
		"completed":
			return "done"
		"active":
			var cur := current_objective_index(quest_id)
			return "done" if index < cur else ("current" if index == cur else "locked")
	return "locked"


## Aceita "missão/objetivo"; usado pelas condições de diálogo.
func is_objective_active(path: String) -> bool:
	var parts := path.split("/")
	if parts.size() != 2:
		return false
	return String(current_objective(parts[0]).get("id", "")) == parts[1]


func active_quests() -> Array[String]:
	var out: Array[String] = []
	for id in db.order:
		if status(id) == "active":
			out.append(id)
	out.sort_custom(func(a, b): return float(GameState.quests[a].started) > float(GameState.quests[b].started))
	return out


func completed_quests() -> Array[String]:
	var out: Array[String] = []
	for id in db.order:
		if status(id) == "completed":
			out.append(id)
	return out


## Missão mostrada no HUD: a acompanhada pelo jogador (se o objetivo dela é
## da região atual); uma principal ativa da região atual; a acompanhada de outra
## região; qualquer principal ativa mais recente; senão qualquer ativa mais recente.
## Assim uma missão secundária esquecida em outra região não rouba o HUD.
func primary_quest() -> String:
	var act := active_quests()
	if act.is_empty():
		return ""
	var here := _here()
	var tracked := GameState.tracked_quest in act
	if tracked and (here == "" or _quest_region(GameState.tracked_quest) == here):
		return GameState.tracked_quest
	if here != "":
		for qid in act:
			if category(qid) == "main" and _quest_region(qid) == here:
				return qid
	if tracked:
		return GameState.tracked_quest
	for qid in act:
		if category(qid) == "main":
			return qid
	return act[0]


## Região do objetivo atual; vazia, vale a região da missão.
func _quest_region(quest_id: String) -> String:
	var rid := objective_region(quest_id)
	return rid if rid != "" else String(db.get_quest(quest_id).get("region", ""))


func _here() -> String:
	if current_region_id != "":
		return current_region_id
	return WorldManager.current_region_id()


func category(quest_id: String) -> String:
	return String(db.get_quest(quest_id).get("category", "main"))


## Conclusão da missão. "variants" ([{if, title?, summary?, next?}]) trocam
## os campos pela primeira variante cuja condição vale (desfechos de escolhas).
func completion(quest_id: String) -> Dictionary:
	var comp: Dictionary = db.get_quest(quest_id).get("completion", {}).duplicate()
	for v in comp.get("variants", []):
		if v is Dictionary and Conditions.check(v.get("if")):
			for k in ["title", "summary", "next"]:
				if v.has(k):
					comp[k] = v[k]
			break
	return comp


## Escolhe a missão acompanhada no HUD ("" volta ao automático).
func set_tracked(quest_id: String) -> void:
	GameState.tracked_quest = quest_id if status(quest_id) == "active" else ""
	objective_changed.emit(quest_id)
	context_changed.emit()


## Região onde fica o objetivo atual ("" = qualquer/mesma da missão).
func objective_region(quest_id: String) -> String:
	var obj := current_objective(quest_id)
	for t in obj.get("targets", []):
		if t.get("type") == "region":
			return String(t.id)
		if String(t.get("region", "")) != "":
			return String(t.region)
	return String(obj.get("region", db.get_quest(quest_id).get("region", "")))


func hint_level(quest_id: String) -> int:
	var obj := current_objective(quest_id)
	if obj.is_empty():
		return 0
	return int(GameState.quests[quest_id].get("hints", {}).get(obj.id, 0))


## Revela a próxima dica do objetivo atual (até 3). Retorna o novo nível.
func request_hint(quest_id: String = "") -> int:
	if quest_id == "":
		quest_id = primary_quest()
	var obj := current_objective(quest_id)
	if obj.is_empty():
		return 0
	var hints: Dictionary = GameState.quests[quest_id].get("hints", {})
	var lvl := mini(int(hints.get(obj.id, 0)) + 1, QuestDatabase.HINT_LEVELS)
	hints[obj.id] = lvl
	GameState.quests[quest_id]["hints"] = hints
	hint_changed.emit(quest_id)
	return lvl


func hint_text(quest_id: String, level: int = -1) -> String:
	var obj := current_objective(quest_id)
	if level < 0:
		level = hint_level(quest_id)
	if obj.is_empty() or level <= 0:
		return ""
	return String(obj.hints[level - 1])


func seconds_on_objective(quest_id: String) -> float:
	return GameState.play_time - float(GameState.quests.get(quest_id, {}).get("objective_started", GameState.play_time))


## Contexto bíblico ativo para o HUD: a experiência em andamento ou, se não
## houver, a referência principal da região (identificada como tal).
func get_context() -> Dictionary:
	var qid := primary_quest()
	if qid != "":
		var q := db.get_quest(qid)
		return {"source": "quest", "quest_id": qid, "title": q.title, "place_id": q.place_id,
			"era_id": q.era_id, "references": q.references, "theme": q.get("theme", q.title)}
	var region := GameData.get_region(current_region_id)
	var ctx: Dictionary = region.get("context", {})
	if ctx.is_empty():
		return {}
	return {"source": "region", "quest_id": "", "title": String(region.get("display_name", "")),
		"place_id": ctx.get("place_id", ""), "era_id": ctx.get("era_id", ""),
		"references": ctx.get("references", []), "theme": ctx.get("theme", "")}


# --- Controle (também usado pelo painel de debug) ----------------------------

func start_quest(quest_id: String, force := false) -> bool:
	if db.get_quest(quest_id).is_empty() or status(quest_id) != "":
		return false
	if not force and not _can_start(quest_id):
		return false
	_start(quest_id)
	evaluate()
	return true


## Volta a missão ao estado "não iniciada" e esquece os eventos dos seus objetivos.
func reset_quest(quest_id: String) -> void:
	var q := db.get_quest(quest_id)
	GameState.quests.erase(quest_id)
	for o in q.get("objectives", []):
		var t: Dictionary = o.get("complete_on", {})
		if not (t.get("event") in QuestDatabase.STATE_EVENTS):
			GameState.flags.erase(event_flag(String(t.get("event", "")), String(t.get("id", ""))))
	GameState.flags.erase(event_flag("quest_completed", quest_id))
	objective_changed.emit(quest_id)
	context_changed.emit()


func advance_objective(quest_id: String) -> void:
	if status(quest_id) == "active":
		_advance(quest_id)
		evaluate()


func complete_quest(quest_id: String) -> void:
	if status(quest_id) == "":
		_start(quest_id)
	while status(quest_id) == "active":
		_advance(quest_id)
	evaluate()


func can_start(quest_id: String) -> bool:
	return _can_start(quest_id)


## Pré-requisitos não cumpridos, em texto (para depuração).
func missing_requirements(quest_id: String) -> PackedStringArray:
	var out := PackedStringArray()
	var q := db.get_quest(quest_id)
	if not ContentPolicy.is_visible(q):
		out.append("conteúdo em rascunho (não visível no canal %s)" % ContentPolicy.channel())
	var t: Dictionary = q.get("start", {})
	if not _trigger_met(t):
		out.append("gatilho de início: %s:%s" % [t.get("event"), t.get("id")])
	for pre in q.get("prerequisites", {}).get("quests_completed", []):
		if status(pre) != "completed":
			out.append("concluir a missão %s" % pre)
	for f in q.get("prerequisites", {}).get("flags", []):
		if not GameState.get_flag(f):
			out.append("flag %s" % f)
	return out


## Mantém o progresso quando a lista de objetivos de uma missão muda entre
## versões. O save guarda o índice do objetivo atual e também
## o id dele (desde a mudança da missão dos poços): se o id ainda existe, o índice é corrigido para a posição nova.
## Saves sem id só são realinhados quando o histórico registra um objetivo que
## não existe mais; aí o jogador volta ao primeiro objetivo atual ainda não
## registrado no histórico (os já cumpridos avançam de novo por evaluate()).
func realign_objectives() -> void:
	for qid in GameState.quests:
		var s: Dictionary = GameState.quests[qid]
		if String(s.get("status", "")) != "active":
			continue
		var q := db.get_quest(String(qid))
		if q.is_empty():
			continue
		var ids: Array = []
		for o in q.get("objectives", []):
			ids.append(String(o.id))
		var oid := String(s.get("objective_id", ""))
		if oid != "" and ids.has(oid):
			s.objective = ids.find(oid)
			continue
		var logged := {}
		var stale := false
		for e in GameState.history:
			if e is Dictionary and String(e.get("kind", "")) == "objective":
				var parts := String(e.get("id", "")).split("/")
				if parts.size() == 2 and parts[0] == String(qid):
					logged[parts[1]] = true
					stale = stale or not ids.has(parts[1])
		if oid == "" and not stale:
			s.objective_id = _objective_id_at(String(qid), int(s.get("objective", 0)))
			continue
		var i := 0
		while i < ids.size() and logged.has(ids[i]):
			i += 1
		s.objective = i
		s.objective_id = _objective_id_at(String(qid), i)


func _objective_id_at(quest_id: String, index: int) -> String:
	var objs: Array = db.get_quest(quest_id).get("objectives", [])
	return String(objs[index].id) if index >= 0 and index < objs.size() else ""


# --- Interno -----------------------------------------------------------------

func _can_start(quest_id: String) -> bool:
	return missing_requirements(quest_id).is_empty()


func _trigger_met(t: Dictionary) -> bool:
	var id := String(t.get("id", ""))
	match String(t.get("event", "")):
		"flag":
			return GameState.get_flag(id) == true
		"inventory":
			return Inventory.count(id) >= int(t.get("count", 1))
		"collection":
			return Collectibles.found_in_set(id) >= int(t.get("count", 1))
		"condition":
			return Conditions.check(t.get("condition"))
	return has_event(String(t.get("event", "")), id)


func _start(quest_id: String) -> void:
	GameState.quests[quest_id] = {"status": "active", "objective": 0, "hints": {},
		"started": GameState.play_time, "completed": 0.0, "objective_started": GameState.play_time,
		"objective_id": _objective_id_at(quest_id, 0)}
	GameState.add_log("quest_started", quest_id)
	quest_started.emit(quest_id)
	objective_changed.emit(quest_id)
	context_changed.emit()


func _advance(quest_id: String) -> void:
	var obj := current_objective(quest_id)
	var s: Dictionary = GameState.quests[quest_id]
	s.objective = int(s.objective) + 1
	s.objective_started = GameState.play_time
	s.objective_id = _objective_id_at(quest_id, int(s.objective))
	if not obj.is_empty():
		GameState.add_log("objective", "%s/%s" % [quest_id, obj.id])
		for d in obj.get("unlock", []):
			Discoveries.unlock(d)
		objective_completed.emit(quest_id, String(obj.id))
	if int(s.objective) >= db.get_quest(quest_id).objectives.size():
		_complete(quest_id)
	else:
		objective_changed.emit(quest_id)


func _complete(quest_id: String) -> void:
	var s: Dictionary = GameState.quests[quest_id]
	if s.status == "completed":
		return
	s.status = "completed"
	s.completed = GameState.play_time
	if GameState.tracked_quest == quest_id:
		GameState.tracked_quest = ""
	GameState.add_log("quest_completed", quest_id)
	GameState.set_flag(event_flag("quest_completed", quest_id), true)
	for d in db.get_quest(quest_id).get("completion", {}).get("unlock", []):
		Discoveries.unlock(d)
	_grant_rewards(quest_id)
	quest_completed.emit(quest_id)
	objective_changed.emit(quest_id)
	context_changed.emit()


## Recompensas da missão: entregues uma única vez (flag reward:<id>), mesmo
## que a missão seja concluída de novo por ferramenta de depuração.
func _grant_rewards(quest_id: String) -> void:
	var flag := "reward:" + quest_id
	if GameState.get_flag(flag):
		return
	GameState.set_flag(flag, true)
	var r: Dictionary = db.get_quest(quest_id).get("rewards", {})
	for it in r.get("items", []):
		Inventory.add(String(it.item), int(it.get("qty", 1)), "reward", true)
	for f in r.get("flags", []):
		GameState.set_flag(String(f), true)
	for c in r.get("collectibles", []):
		Collectibles.find(String(c))


## Ferramenta do editor "Testar missão": começa um jogo novo já com a missão ativa.
func _debug_boot() -> void:
	var data: Variant = JsonUtil.read_file(DEBUG_BOOT_PATH)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(DEBUG_BOOT_PATH))
	if not (data is Dictionary):
		return
	GameState.new_game()
	GameState.set_flag("prologue_seen", true)
	var qid := String(data.get("start_quest", ""))
	if qid != "":
		start_quest(qid, true)
	SceneRouter.change_scene(GAME_SCENE)
