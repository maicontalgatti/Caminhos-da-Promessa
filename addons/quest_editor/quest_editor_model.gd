@tool
class_name QuestEditorModel
extends RefCounted
## Lógica do editor de missões, separada da interface para poder ser testada:
## carrega missões (inclusive inválidas), filtra, valida, salva no arquivo de
## origem e cria missões novas a partir de um modelo.

const QUEST_DIR := QuestDatabase.QUEST_DIR
const DIALOGUE_DIR := "res://data/dialogues"
const DEBUG_BOOT_PATH := "user://debug_boot.json"

var quests: Dictionary = {}
var order: Array[String] = []
var catalog := BibleCatalog.new()
var dialogues := DialogueDatabase.new()
var characters: Dictionary = {}
var regions: Dictionary = {}
var load_errors := PackedStringArray()
var _db := QuestDatabase.new()


func reload() -> void:
	load_errors.clear()
	catalog.load_all()
	dialogues.load_dir(DIALOGUE_DIR)
	characters.clear()
	regions.clear()
	for c in JsonUtil.read_collection("res://data/characters", "characters", load_errors):
		characters[c.id] = c
	for r in JsonUtil.read_collection("res://data/regions", "regions", load_errors):
		regions[r.id] = r
	quests.clear()
	order.clear()
	for q in JsonUtil.read_collection(QUEST_DIR, "quests", load_errors, true):
		quests[q.id] = q
		order.append(q.id)
	_db.quests = quests


## Erros estruturais e de vínculo (referências, alvos, eventos, conteúdo).
func validate(q: Dictionary) -> PackedStringArray:
	var out := QuestDatabase.validate(q)
	if out.is_empty():
		out.append_array(_db.validate_links(q, catalog, dialogues.dialogues, characters, regions))
	return out


func books_of(q: Dictionary) -> Array:
	var out: Array = []
	for r in q.get("references", []):
		var b := catalog.book_of(r)
		if b != "" and not (b in out):
			out.append(b)
	return out


## Filtros vazios ("") não restringem. `text` procura em id, título e referências.
func filter(text: String, book: String, region: String, era: String, status: String) -> Array[String]:
	var out: Array[String] = []
	var needle := text.strip_edges().to_lower()
	for id in order:
		var q: Dictionary = quests[id]
		if book != "" and not (book in books_of(q)):
			continue
		if region != "" and String(q.get("region", "")) != region:
			continue
		if era != "" and String(q.get("era_id", "")) != era:
			continue
		if status != "" and ContentPolicy.status_of(q) != status:
			continue
		if needle != "":
			var hay := ("%s %s %s" % [id, q.get("title", ""), catalog.format_references(q.get("references", []))]).to_lower()
			if hay.find(needle) < 0:
				continue
		out.append(id)
	return out


static func clean(item: Dictionary) -> Dictionary:
	var c := item.duplicate(true)
	c.erase("_source")
	return c


static func to_json(item: Dictionary) -> String:
	return JSON.stringify(clean(item), "\t", false)


## Substitui (ou acrescenta) o item `id` na lista `key` do arquivo e grava.
static func write_item(path: String, key: String, item: Dictionary) -> Error:
	var data: Variant = {}
	if FileAccess.file_exists(path):
		data = JsonUtil.read_file(path)
		if not (data is Dictionary):
			return ERR_PARSE_ERROR
	if not (data.get(key) is Array):
		data[key] = []
	var list: Array = data[key]
	var clean_item := clean(item)
	var replaced := false
	for i in list.size():
		if list[i] is Dictionary and list[i].get("id") == clean_item.id:
			list[i] = clean_item
			replaced = true
	if not replaced:
		list.append(clean_item)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		return FileAccess.get_open_error()
	f.store_string(JSON.stringify(data, "\t", false) + "\n")
	f.close()
	return OK


## Salva a missão no arquivo de onde veio (ou em data/quests/<região>/<id>.json).
func save_quest(q: Dictionary) -> Error:
	var path := String(q.get("_source", ""))
	if path == "":
		path = QUEST_DIR.path_join(String(q.get("region", "misc"))).path_join("%s.json" % q.id)
		q["_source"] = path
	var err := write_item(path, "quests", q)
	if err == OK:
		if not quests.has(q.id):
			order.append(q.id)
		quests[q.id] = q
	return err


func save_dialogue(d: Dictionary) -> Error:
	var path := String(d.get("_source", ""))
	if path == "":
		path = DIALOGUE_DIR.path_join("%s.json" % d.id)
	return write_item(path, "dialogues", d)


## Altera o status de verificação; retorna erros (ex.: revisor ausente ou IA).
static func set_status(q: Dictionary, status: String, reviewer: String) -> PackedStringArray:
	var ver: Dictionary = q.get("verification", {}) if q.get("verification") is Dictionary else {}
	var trial := {"verification": {"status": status, "reviewer": reviewer.strip_edges(), "notes": ver.get("notes", "")}}
	var errs := ContentPolicy.validate_verification(String(q.get("id", "?")), trial)
	if errs.is_empty():
		q["verification"] = trial.verification
	return errs


static func new_quest_template(id: String, region: String, place_id: String, era_id: String) -> Dictionary:
	return {
		"id": id,
		"title": "Nova missão",
		"description": "",
		"type": "context_exploration",
		"classification": "plausible_fiction",
		"region": region,
		"place_id": place_id,
		"era_id": era_id,
		"references": [],
		"theme": "",
		"people": [],
		"fictional_characters": [],
		"intro": "",
		"start": {"event": "quest_completed", "id": "canaan_wells"},
		"prerequisites": {"quests_completed": [], "flags": []},
		"objectives": [objective_template("obj1")],
		"discoveries": [],
		"completion": {"title": "História explorada", "references": [], "summary": [], "unlock": [], "next": ""},
		"verification": {"status": "draft", "reviewer": "", "notes": "Criada no editor de missões."},
	}


static func objective_template(id: String) -> Dictionary:
	return {
		"id": id,
		"text": "Descreva o objetivo.",
		"detail": "",
		"complete_on": {"event": "custom", "id": "definir_evento"},
		"targets": [{"type": "npc", "id": "definir_personagem"}],
		"hints": ["Pista indireta.", "Pista contextual.", "Pista objetiva."],
		"log": "",
	}


## "Testar missão": o jogo (build de debug) lê este arquivo ao iniciar,
## começa um jogo novo e ativa a missão (QuestManager._debug_boot).
static func write_debug_boot(quest_id: String) -> Error:
	var f := FileAccess.open(DEBUG_BOOT_PATH, FileAccess.WRITE)
	if f == null:
		return FileAccess.get_open_error()
	f.store_string(JSON.stringify({"start_quest": quest_id}))
	f.close()
	return OK
