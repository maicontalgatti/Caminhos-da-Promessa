extends Node
## Executa diálogos definidos em JSON e avisa a UI por sinais.
## A UI (DialogueBox) só exibe; a lógica de fluxo fica aqui.

signal dialogue_started(dialogue_id: String)
## line = {speaker_id, speaker_name, text, portrait, choices: [String], voice: caminho ou ""}
signal line_shown(line: Dictionary)
signal dialogue_ended(dialogue_id: String)
## Ação pedida por um nó (ex.: {"presentation": "gen_026_wells"}), executada
## pela cena de jogo depois que o diálogo termina.
signal action_requested(action: Dictionary)

const DIALOGUE_DIR := "res://data/dialogues"
const VOICE_DIR := "res://assets/audio/voice"

var db := DialogueDatabase.new()
var active_id := ""
var _dialogue: Dictionary = {}
var _node: Dictionary = {}
var _node_id := ""
var _choices: Array = []
var _pending_actions: Array = []


func _ready() -> void:
	db.load_dir(DIALOGUE_DIR)
	for e in db.errors:
		push_error("DialogueManager: " + e)


func is_active() -> bool:
	return active_id != ""


func start(dialogue_id: String) -> bool:
	if is_active():
		return false
	if not db.has_dialogue(dialogue_id):
		push_warning("DialogueManager: diálogo inexistente \"%s\"" % dialogue_id)
		return false
	_dialogue = db.get_dialogue(dialogue_id)
	active_id = dialogue_id
	var start_node := String(_dialogue.start)
	for cond in _dialogue.get("start_if", []):
		if _check(cond):
			start_node = String(cond.node)
			break
	dialogue_started.emit(dialogue_id)
	_show(start_node)
	return true


## Avança para o próximo nó (ignorado se houver escolhas pendentes).
func advance() -> void:
	if not is_active() or not _choices.is_empty():
		return
	_show(String(_node.get("next", DialogueDatabase.END)))


func choose(index: int) -> void:
	if not is_active() or index < 0 or index >= _choices.size():
		return
	var ch: Dictionary = _choices[index]
	_apply_flags(ch)
	_apply_effects(ch, "%s/%s#%d" % [active_id, _node_id, index])
	_show(String(ch.get("next", DialogueDatabase.END)))


func current_choices() -> Array:
	return _choices


func _show(node_id: String) -> void:
	var nodes: Dictionary = _dialogue.get("nodes", {})
	if node_id == DialogueDatabase.END or not nodes.has(node_id):
		_end()
		return
	_node = nodes[node_id]
	_node_id = node_id
	_apply_flags(_node)
	_apply_effects(_node, "%s/%s" % [active_id, node_id])
	_choices = []
	for ch in _node.get("choices", []):
		if _check(ch):
			_choices.append(ch)
	var speaker := String(_node.get("speaker", "narrator"))
	var choice_texts: Array[String] = []
	for ch in _choices:
		choice_texts.append(String(ch.text))
	line_shown.emit({
		"speaker_id": speaker,
		"speaker_name": GameData.get_character_name(speaker),
		"text": line_text(_node),
		"portrait": GameData.get_portrait(speaker),
		"choices": choice_texts,
		"voice": voice_path(active_id, node_id),
	})


## Gravação da fala, se existir (nome definido pelo manifesto de áudio da fábrica:
## <diálogo>__<nó>.ogg|.wav). Sem gravação, a fala é só texto.
static func voice_path(dialogue_id: String, node_id: String) -> String:
	for ext in ["ogg", "wav"]:
		var path := "%s/%s__%s.%s" % [VOICE_DIR, dialogue_id, node_id, ext]
		if ResourceLoader.exists(path):
			return path
	return ""


## Nó com "scripture" mostra o texto bíblico citado; sem a tradução carregada,
## mostra o "text" do nó (que deve trazer a referência).
static func line_text(node: Dictionary) -> String:
	var r := String(node.get("scripture", ""))
	var q := Bible.quote_plain(r, 3) if r != "" else ""
	if q == "":
		return String(node.get("text", ""))
	return "[i]%s[/i]\n[font_size=7][color=#8b5a2b]— %s[/color][/font_size]" % [q, Bible.cite(r)]


func _end() -> void:
	var id := active_id
	active_id = ""
	_dialogue = {}
	_node = {}
	_choices = []
	var actions := _pending_actions
	_pending_actions = []
	dialogue_ended.emit(id)
	QuestManager.record_event("dialogue_finished", id)
	for a in actions:
		action_requested.emit(a)


func _apply_flags(entry: Dictionary) -> void:
	for f in entry.get("set_flags", []):
		GameState.set_flag(String(f), true)


## Efeitos de nó ou escolha: "unlock" (descobertas), "event" (evento de
## missão), "action", "take" (o jogador entrega itens; só se tiver todos),
## "give" (o jogador recebe itens; uma vez por nó, salvo "repeatable"),
## "decision" ({id, option}: escolha persistente), "grant_collectible",
## "flags" ({flag: valor}).
func _apply_effects(entry: Dictionary, key: String = "") -> void:
	for d in entry.get("unlock", []):
		Discoveries.unlock(String(d))
	var take: Array = entry.get("take", [])
	if not take.is_empty() and _has_all(take):
		for it in take:
			Inventory.remove(String(it.item), int(it.get("qty", 1)), "deliver")
	var give: Array = entry.get("give", [])
	if not give.is_empty():
		var once := "given:" + key
		if entry.get("repeatable", false) or not GameState.get_flag(once):
			GameState.set_flag(once, true)
			for it in give:
				var n := Inventory.add(String(it.item), int(it.get("qty", 1)), "dialogue", true)
				get_tree().call_group("hud", "show_toast", "Recebido: %d %s" % [n, Inventory.display_name(String(it.item))])
	var dec: Variant = entry.get("decision")
	if dec is Dictionary:
		var cid := String(dec.get("id", ""))
		var opt := String(dec.get("option", ""))
		GameState.set_flag(Conditions.choice_flag(cid), opt)
		GameState.add_log("choice", "%s=%s" % [cid, opt])
		QuestManager.record_event("choice_made", cid)
		QuestManager.record_event("choice_made", "%s:%s" % [cid, opt])
	var col: Variant = entry.get("grant_collectible")
	for c in (col if col is Array else ([col] if col is String else [])):
		Collectibles.find(String(c))
	var fl: Variant = entry.get("flags")
	if fl is Dictionary:
		for f in fl:
			GameState.set_flag(String(f), fl[f])
	if entry.get("event") is String and entry.event != "":
		QuestManager.record_event("custom", entry.event)
	if entry.get("action") is Dictionary:
		_pending_actions.append(entry.action)


func _has_all(items: Array) -> bool:
	for it in items:
		if Inventory.count(String(it.get("item", ""))) < int(it.get("qty", 1)):
			return false
	return true


## Condição de start_if ou de escolha. Escolhas novas usam "if" (ver
## Conditions); as antigas trazem as chaves no próprio objeto.
func _check(cond: Dictionary) -> bool:
	if cond.has("if"):
		return Conditions.check(cond.get("if"))
	var c := cond.duplicate()
	for k in ["node", "text", "next", "set_flags", "unlock", "event", "action", "take", "give",
			"repeatable", "decision", "grant_collectible", "flags"]:
		c.erase(k)
	return Conditions.check(c)
