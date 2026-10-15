extends Node
## Mundo com múltiplas regiões. Cada região (data/regions) declara seu mapa,
## pontos de entrada, saídas (com condições), áreas, NPCs, objetos examináveis
## e itens no chão. Este nó resolve viagens, rotas e o "Mapa das Escrituras"
## (experiências por época, em data/world/experiences.json, com destino
## "travel"/"entry_if", etapas "stages" e cartões "passage").
##
## A troca visual do mapa é feita pela cena de jogo (sinal travel_requested);
## o estado (região, entrada) é atualizado aqui, então funciona também sem tela.

signal travel_requested(region_id: String, entry_id: String)
signal experience_started(experience_id: String)
## Saída com "passage": a cena de jogo mostra o cartão e então chama travel().
signal passage_requested(passage: Dictionary, region_id: String, entry_id: String)

const EXPERIENCES_DIR := "res://data/world"
const FACINGS := {"down": Vector2.DOWN, "up": Vector2.UP, "left": Vector2.LEFT, "right": Vector2.RIGHT}

var experiences: Dictionary = {}
var experience_order: Array[String] = []
var eras_order: Array = []
var errors := PackedStringArray()
## Tempo de jogo em que a visita atual à região começou (viagem ou partida
## carregada). Um renovável só volta se o seu momento de volta (renew_key, no
## save) já tinha passado nesse instante: nunca surge no meio de uma visita.
var _visit_started := 0.0


func _ready() -> void:
	reload()
	GameState.state_replaced.connect(func(): _visit_started = GameState.play_time)


func reload() -> void:
	experiences.clear()
	experience_order.clear()
	errors.clear()
	for e in JsonUtil.read_collection(EXPERIENCES_DIR, "experiences", errors):
		experiences[e.id] = e
		experience_order.append(String(e.id))
	eras_order = []
	for e in JsonUtil.read_collection(EXPERIENCES_DIR, "eras", errors):
		eras_order.append(e)
	for e in errors:
		push_error("WorldManager: " + e)


# --- Regiões -----------------------------------------------------------------

func region(id: String) -> Dictionary:
	return GameData.get_region(id)


func current_region_id() -> String:
	if GameState.current_region != "":
		return GameState.current_region
	return region_for_map(GameState.current_map)


func region_for_map(path: String) -> String:
	for id in GameData.regions:
		if String(GameData.regions[id].get("map_scene", "")) == path:
			return id
	return ""


## {position: Vector2, facing: Vector2} do ponto de entrada; {} se não existir.
func entry_point(region_id: String, entry_id: String) -> Dictionary:
	var e: Variant = region(region_id).get("entries", {}).get(entry_id)
	if not (e is Dictionary):
		return {}
	return {"position": Vector2(float(e.x), float(e.y)), "facing": FACINGS.get(String(e.get("facing", "down")), Vector2.DOWN)}


func exits(region_id: String) -> Array:
	return region(region_id).get("exits", [])


func find_exit(region_id: String, exit_id: String) -> Dictionary:
	for ex in exits(region_id):
		if String(ex.get("id", "")) == exit_id:
			return ex
	return {}


func is_exit_open(ex: Dictionary) -> bool:
	return Conditions.check(ex.get("requires"))


func is_region_unlocked(region_id: String) -> bool:
	return GameState.get_flag("region_unlocked:" + region_id) == true


## Primeira saída do caminho mais curto entre duas regiões (busca em largura).
func route_exit(from_id: String, to_id: String) -> Dictionary:
	if from_id == to_id or from_id == "" or to_id == "":
		return {}
	var first := {}
	var seen := {from_id: true}
	var queue: Array = [from_id]
	while not queue.is_empty():
		var cur: String = queue.pop_front()
		for ex in exits(cur):
			var nxt := String(ex.get("to", ""))
			if nxt == "" or seen.has(nxt):
				continue
			seen[nxt] = true
			first[nxt] = ex if cur == from_id else first[cur]
			if nxt == to_id:
				return first[nxt]
			queue.append(nxt)
	return {}


## Viaja para uma região por um ponto de entrada nomeado. Retorna "" ou o erro.
func travel(region_id: String, entry_id: String) -> String:
	var r := region(region_id)
	if r.is_empty():
		return "região inexistente: %s" % region_id
	var scene := String(r.get("map_scene", ""))
	if not ResourceLoader.exists(scene):
		return "mapa inexistente: %s" % scene
	if entry_point(region_id, entry_id).is_empty():
		return "entrada inexistente: %s/%s" % [region_id, entry_id]
	if not is_region_unlocked(region_id):
		GameState.set_flag("region_unlocked:" + region_id, true)
		QuestManager.record_event("region_unlocked", region_id)
	_visit_started = GameState.play_time
	GameState.current_region = region_id
	GameState.current_map = scene
	GameState.entry_id = entry_id
	GameState.player_position = Vector2.INF
	GameState.add_log("travel", region_id)
	travel_requested.emit(region_id, entry_id)
	return ""


## Viagem precedida de um cartão de passagem ({title, lines}); sem tela de jogo, viaja direto.
func travel_with_passage(region_id: String, entry_id: String, passage: Dictionary) -> String:
	if passage.is_empty() or passage_requested.get_connections().is_empty():
		return travel(region_id, entry_id)
	passage_requested.emit(passage, region_id, entry_id)
	return ""


# --- Estado persistente de objetos -------------------------------------------

func world_key(region_id: String, object_id: String) -> String:
	return "%s/%s" % [region_id, object_id]


func is_picked(region_id: String, object_id: String) -> bool:
	return GameState.world.get(world_key(region_id, object_id), false) == true


func mark_picked(region_id: String, object_id: String) -> void:
	GameState.world[world_key(region_id, object_id)] = true


func renew_key(region_id: String, object_id: String) -> String:
	return "renew/" + world_key(region_id, object_id)


## Renovável coletado que ainda não pode voltar nesta visita.
func is_renewing(region_id: String, object_id: String) -> bool:
	var at: Variant = GameState.world.get(renew_key(region_id, object_id))
	return (at is float or at is int) and float(at) > _visit_started


## Marca a coleta de um renovável: some e volta numa visita que comece depois
## de `seconds` de jogo.
func mark_renewing(region_id: String, object_id: String, seconds: float) -> void:
	GameState.world[renew_key(region_id, object_id)] = maxf(GameState.play_time + seconds, _visit_started + 0.001)


# --- Mapa das Escrituras ------------------------------------------------------

func experience(id: String) -> Dictionary:
	return experiences.get(id, {})


## "planned" (em planejamento, não jogável), "locked", "available", "active" ou "completed".
func experience_state(id: String) -> String:
	var e := experience(id)
	if e.is_empty() or String(e.get("status", "")) == "planned":
		return "planned"
	var done_quest := String(e.get("completed_by", ""))
	if done_quest != "" and QuestManager.status(done_quest) == "completed":
		return "completed"
	if GameState.get_flag("experience:" + id) == true:
		return "active"
	if e.get("active_with_quest", false) and done_quest != "" and QuestManager.status(done_quest) == "active":
		return "active"
	return "available" if Conditions.check(e.get("requires")) else "locked"


## {region, entry} de um "travel": a primeira entrada de "entry_if" cuja
## condição vale, senão "entry" (padrão "default"). {} sem região.
func resolve_travel(t: Variant) -> Dictionary:
	if not (t is Dictionary) or String(t.get("region", "")) == "":
		return {}
	var entry := String(t.get("entry", "default"))
	for alt in t.get("entry_if", []):
		if alt is Dictionary and Conditions.check(alt.get("if")):
			entry = String(alt.get("entry", entry))
			break
	return {"region": String(t.region), "entry": entry}


## Etapa atual de uma experiência com "stages": a última cuja condição "if"
## vale (etapa sem "if" sempre vale). {} sem etapas.
func experience_stage(id: String) -> Dictionary:
	var cur := {}
	for st in experience(id).get("stages", []):
		if st is Dictionary and Conditions.check(st.get("if")):
			cur = st
	return cur


static func stage_flag(xid: String, stage_id: String) -> String:
	return "experience_stage:%s:%s" % [xid, stage_id]


## Destino ao iniciar, continuar ou revisitar: travel da etapa atual ou da experiência.
func experience_destination(id: String) -> Dictionary:
	var st := experience_stage(id)
	if not st.is_empty():
		return resolve_travel(st.get("travel"))
	return resolve_travel(experience(id).get("travel"))


## Regiões que fazem parte da experiência ("regions"; padrão: as de travel e das etapas).
func experience_regions(id: String) -> Array:
	var x := experience(id)
	if x.get("regions") is Array:
		return x.regions
	var travels: Array = [x.get("travel")]
	for st in x.get("stages", []):
		if st is Dictionary:
			travels.append(st.get("travel"))
	var out: Array = []
	for t in travels:
		if t is Dictionary and not out.has(String(t.get("region", ""))):
			out.append(String(t.get("region", "")))
	return out


## Se iniciar a experiência agora leva a outra região (destino diferente da atual).
func _needs_travel(id: String, dest: Dictionary) -> bool:
	if dest.is_empty():
		return false
	if not experience_stage(id).is_empty():
		return String(dest.region) != current_region_id()
	return not (current_region_id() in experience_regions(id))


## Cartão a mostrar antes de iniciar/continuar: a "passage" da experiência na
## primeira vez, ou a da etapa atual ainda não vista quando a viagem acontece.
func pending_passage(id: String) -> Dictionary:
	var x := experience(id)
	var state := experience_state(id)
	if state == "available" and x.get("passage") is Dictionary and GameState.get_flag("experience:" + id) != true:
		return x.passage
	if state in ["planned", "locked"]:
		return {}
	var st := experience_stage(id)
	if st.get("passage") is Dictionary and GameState.get_flag(stage_flag(id, String(st.get("id", "")))) != true \
			and _needs_travel(id, experience_destination(id)):
		return st.passage
	return {}


## Inicia (ou continua, ou revisita) uma experiência: registra o evento e, se
## ela define um destino fora das suas regiões, leva o jogador até lá.
## Retorna "" ou o motivo da recusa.
func start_experience(id: String) -> String:
	var state := experience_state(id)
	if state == "planned":
		return "Esta experiência ainda está em planejamento."
	if state == "locked":
		return String(experience(id).get("locked_text", "Ainda não disponível."))
	if GameState.get_flag("experience:" + id) != true:
		GameState.set_flag("experience:" + id, true)
		GameState.add_log("experience", id)
		QuestManager.record_event("experience_started", id)
		experience_started.emit(id)
	var dest := experience_destination(id)
	if not _needs_travel(id, dest):
		return ""
	var st := experience_stage(id)
	if not st.is_empty():
		GameState.set_flag(stage_flag(id, String(st.get("id", ""))), true)
	return travel(String(dest.region), String(dest.entry))
