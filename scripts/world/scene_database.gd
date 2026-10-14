@tool
class_name SceneDatabase
extends RefCounted
## Cenas dirigidas de data/scenes/*.json (chave "scenes"): o jogador assiste a
## uma sequência de passos no mapa (câmera, figurantes, luz, efeitos, legendas)
## e o controle volta no fim. Quem toca é o SceneDirector; aqui só há leitura e
## validação, sem autoloads (roda nos testes, em tools/validate_content.gd e na
## fábrica). Formato completo em docs/quests.md ("Cenas dirigidas").

const SCENES_DIR := "res://data/scenes"
const STEP_TYPES := ["camera", "actor", "move", "remove", "pose", "tint", "effect", "caption", "sfx", "wait", "player_to"]
const EFFECTS := ["light_glow", "pillar", "wind", "water_walls", "dust"]
const CAPTION_KINDS := ["narration", "context", "fiction"]
const FACINGS := ["down", "up", "left", "right"]
const POSES := ["stand", "sit", "kneel", "bow", "fear", "hand_out"]
const ON_END_KEYS := ["set_flags", "unlock", "player_to", "_comment"]
## Chaves que dariam item, ponto ou poder: proibidas em qualquer lugar da cena (regra 12).
const FORBIDDEN_KEYS := ["give", "items", "rewards", "reward", "grant_collectible", "score", "xp", "power"]
const REQUIRED_FIELDS := ["id", "region", "title", "classification", "references", "verification", "steps"]
const SILHOUETTE_PREFIX := "silhouette"

var scenes: Dictionary = {}
var order: Array[String] = []
var errors := PackedStringArray()


func load_dir(dir_path: String = SCENES_DIR) -> void:
	scenes.clear()
	order.clear()
	errors.clear()
	for s in JsonUtil.read_collection(dir_path, "scenes", errors):
		if scenes.has(s.id):
			errors.append("Cena duplicada: %s" % s.id)
			continue
		var problems := validate(s)
		if problems.is_empty():
			scenes[s.id] = s
			order.append(String(s.id))
		else:
			errors.append_array(problems)


func has_scene(id: String) -> bool:
	return scenes.has(id)


func get_scene(id: String) -> Dictionary:
	return scenes.get(id, {})


## Ids das cenas em data/scenes (para quem valida vínculos fora do jogo).
static func ids_in(dir_path: String = SCENES_DIR) -> Dictionary:
	var out := {}
	for s in JsonUtil.read_collection(dir_path, "scenes", PackedStringArray()):
		out[String(s.id)] = s
	return out


static func is_silhouette(sprite: String) -> bool:
	return sprite.begins_with(SILHOUETTE_PREFIX)


## Duração (s) de uma legenda: "time" explícito ou proporcional ao texto.
static func caption_time(step: Dictionary, text_length: int) -> float:
	if step.has("time"):
		return maxf(float(step.time), 0.5)
	return clampf(2.5 + text_length * 0.045, 3.0, 12.0)


## Validação estrutural (sem depender de outros dados).
static func validate(s: Dictionary) -> PackedStringArray:
	var out := PackedStringArray()
	var id := "cena " + String(s.get("id", "?"))
	for f in REQUIRED_FIELDS:
		if not s.has(f):
			out.append("%s: campo obrigatório ausente \"%s\"" % [id, f])
	if not out.is_empty():
		return out
	if not (s.classification in ContentPolicy.CLASSIFICATIONS):
		out.append("%s: classificação inválida \"%s\"" % [id, s.classification])
	if not (s.references is Array):
		out.append("%s: \"references\" deve ser uma lista" % id)
	if s.has("skippable") and not (s.skippable is bool):
		out.append("%s: \"skippable\" deve ser true/false" % id)
	if s.has("repeatable") and not (s.repeatable is bool):
		out.append("%s: \"repeatable\" deve ser true/false" % id)
	out.append_array(_forbidden(id, s))
	out.append_array(ContentPolicy.validate_verification(id, s))
	var steps: Variant = s.steps
	if not (steps is Array) or steps.is_empty():
		out.append("%s: sem passos (\"steps\")" % id)
		return out
	var actors := {}
	for i in steps.size():
		out.append_array(_validate_step("%s, passo %d" % [id, i + 1], steps[i], actors))
	var on_end: Variant = s.get("on_end", {})
	if not (on_end is Dictionary):
		out.append("%s: \"on_end\" deve ser um objeto" % id)
	else:
		for k in on_end:
			if not (k in ON_END_KEYS):
				out.append("%s: on_end com chave desconhecida \"%s\" (use %s)" % [id, k, ON_END_KEYS])
		for k in ["set_flags", "unlock"]:
			if on_end.has(k) and not _is_id_list(on_end[k]):
				out.append("%s: on_end.%s deve ser uma lista de ids" % [id, k])
		if on_end.has("player_to"):
			out.append_array(_validate_player_to(id + " (on_end.player_to)", on_end.player_to))
	return out


static func _forbidden(owner: String, v: Variant) -> PackedStringArray:
	var out := PackedStringArray()
	if v is Dictionary:
		for k in v:
			if k in FORBIDDEN_KEYS:
				out.append("%s: \"%s\" não é permitido; cena nunca dá item, ponto ou poder" % [owner, k])
			else:
				out.append_array(_forbidden(owner, v[k]))
	elif v is Array:
		for x in v:
			out.append_array(_forbidden(owner, x))
	return out


static func _is_point(v: Variant) -> bool:
	return v is Array and v.size() == 2 and (v[0] is float or v[0] is int) and (v[1] is float or v[1] is int)


static func _is_points(v: Variant) -> bool:
	if not (v is Array) or v.is_empty():
		return false
	for p in v:
		if not _is_point(p):
			return false
	return true


static func _is_id_list(v: Variant) -> bool:
	if not (v is Array):
		return false
	for x in v:
		if not (x is String) or x == "":
			return false
	return true


static func _is_num(v: Variant) -> bool:
	return v is float or v is int


static func _validate_player_to(owner: String, p: Variant) -> PackedStringArray:
	if not (p is Dictionary) or not _is_point(p.get("at")):
		return PackedStringArray(["%s: \"at\" deve ser [x, y]" % owner])
	if p.has("facing") and not (p.facing in FACINGS):
		return PackedStringArray(["%s: facing inválido \"%s\" (use %s)" % [owner, p.facing, FACINGS]])
	return PackedStringArray()


static func _validate_step(owner: String, st: Variant, actors: Dictionary) -> PackedStringArray:
	var out := PackedStringArray()
	if not (st is Dictionary):
		return PackedStringArray(["%s: passo deve ser um objeto" % owner])
	var type := String(st.get("type", ""))
	if not (type in STEP_TYPES):
		return PackedStringArray(["%s: tipo de passo inválido \"%s\" (use %s)" % [owner, type, STEP_TYPES]])
	owner += " (%s)" % type
	if st.has("wait") and not (st.wait is bool):
		out.append("%s: \"wait\" deve ser true/false" % owner)
	for k in ["time", "speed", "zoom"]:
		if st.has(k) and (not _is_num(st[k]) or float(st[k]) < 0.0):
			out.append("%s: \"%s\" deve ser um número >= 0" % [owner, k])
	if st.has("facing") and not (st.facing in FACINGS):
		out.append("%s: facing inválido \"%s\" (use %s)" % [owner, st.facing, FACINGS])
	if st.has("pose") and not (st.pose in POSES):
		out.append("%s: pose inválida \"%s\" (use %s)" % [owner, st.pose, POSES])
	match type:
		"camera":
			if st.has("follow"):
				if st.follow != "player":
					out.append("%s: \"follow\" só aceita \"player\"" % owner)
			elif not _is_point(st.get("to")):
				out.append("%s: precisa de \"to\": [x, y] ou \"follow\": \"player\"" % owner)
			if st.has("zoom") and float(st.zoom) <= 0.0:
				out.append("%s: \"zoom\" deve ser > 0" % owner)
		"actor":
			var aid := String(st.get("id", ""))
			if aid == "":
				out.append("%s: figurante sem \"id\"" % owner)
			if String(st.get("sprite", "")) == "":
				out.append("%s: figurante sem \"sprite\" (personagem de data/characters ou silhouette_*)" % owner)
			if not _is_point(st.get("at")):
				out.append("%s: \"at\" deve ser [x, y]" % owner)
			actors[aid] = true
		"move":
			if not actors.has(String(st.get("actor", ""))):
				out.append("%s: figurante \"%s\" não foi criado antes" % [owner, st.get("actor", "")])
			if not _is_points(st.get("path")):
				out.append("%s: \"path\" deve ser uma lista de [x, y]" % owner)
			if st.has("speed") and float(st.speed) <= 0.0:
				out.append("%s: \"speed\" deve ser > 0" % owner)
		"remove":
			var rid := String(st.get("actor", ""))
			if rid != "*" and not actors.has(rid):
				out.append("%s: figurante \"%s\" não foi criado antes" % [owner, rid])
			actors.erase(rid)
		"pose":
			if not actors.has(String(st.get("actor", ""))):
				out.append("%s: figurante \"%s\" não foi criado antes" % [owner, st.get("actor", "")])
			if not st.has("pose"):
				out.append("%s: sem \"pose\" (use %s)" % [owner, POSES])
		"tint":
			if not (st.get("color") is String and Color.html_is_valid(String(st.color))):
				out.append("%s: \"color\" deve ser \"#rrggbb\"" % owner)
		"effect":
			out.append_array(_validate_effect(owner, st))
		"caption":
			var has_ref: bool = st.get("scripture") is String and String(st.scripture) != ""
			var has_text: bool = st.get("text") is String and String(st.text).strip_edges() != ""
			if has_ref == has_text:
				out.append("%s: use \"scripture\" (referência) ou \"text\" + \"kind\", um dos dois" % owner)
			elif has_text and not (st.get("kind") in CAPTION_KINDS):
				out.append("%s: legenda de texto precisa de \"kind\" (%s)" % [owner, CAPTION_KINDS])
		"sfx":
			if String(st.get("id", "")) == "":
				out.append("%s: sem \"id\" do som" % owner)
		"wait":
			if not st.has("time"):
				out.append("%s: sem \"time\"" % owner)
		"player_to":
			out.append_array(_validate_player_to(owner, st))
	return out


static func _validate_effect(owner: String, st: Dictionary) -> PackedStringArray:
	var out := PackedStringArray()
	var eff := String(st.get("effect", ""))
	if not (eff in EFFECTS):
		return PackedStringArray(["%s: efeito inválido \"%s\" (use %s)" % [owner, eff, EFFECTS]])
	var on: Variant = st.get("on", true)
	if not (on is bool):
		out.append("%s: \"on\" deve ser true/false" % owner)
	var params: Variant = st.get("params", {})
	if not (params is Dictionary):
		out.append("%s: \"params\" deve ser um objeto" % owner)
		return out
	if on == false:
		return out
	var at: Variant = st.get("at")
	if eff == "light_glow":
		if not (_is_point(at) or _is_points(at)):
			out.append("%s: \"at\" deve ser [x, y] ou uma lista de pontos" % owner)
	elif not _is_point(at):
		out.append("%s: \"at\" deve ser [x, y]" % owner)
	if eff == "water_walls" and not _is_point(params.get("to")):
		out.append("%s: water_walls precisa de params.to: [x, y] (fim do corredor)" % owner)
	for k in ["radius", "radius_from", "intensity", "height", "width", "wall", "open_time", "strength", "points", "rise", "opacity"]:
		if params.has(k) and (not _is_num(params[k]) or float(params[k]) < 0.0):
			out.append("%s: params.%s deve ser um número >= 0" % [owner, k])
	if params.has("color") and not (params.color is String and Color.html_is_valid(String(params.color))):
		out.append("%s: params.color deve ser \"#rrggbb\"" % owner)
	if params.has("spread") and not _is_point(params.spread):
		out.append("%s: params.spread deve ser [largura, altura]" % owner)
	if eff == "wind" and params.has("from") and not (params.from in ["east", "west", "north", "south"]):
		out.append("%s: params.from deve ser east, west, north ou south" % owner)
	if eff == "pillar" and params.has("form") and not (params.form in ["cloud", "fire", "cloud_fire"]):
		out.append("%s: params.form deve ser cloud, fire ou cloud_fire" % owner)
	return out


## Vínculos com outros dados: região, referências, texto bíblico das legendas,
## personagens dos figurantes, sons, flags e descobertas.
static func validate_links(s: Dictionary, catalog: BibleCatalog, characters: Dictionary, regions: Dictionary, sounds: Dictionary) -> PackedStringArray:
	var id := "cena " + String(s.get("id", "?"))
	var out := PackedStringArray()
	if not regions.has(String(s.get("region", ""))):
		out.append("%s: região inexistente \"%s\"" % [id, s.get("region")])
	out.append_array(catalog.validate_references(id, s.get("references", [])))
	for st in s.get("steps", []):
		match String(st.get("type", "")):
			"caption":
				var ref := String(st.get("scripture", ""))
				if ref != "":
					var errs := catalog.validate_reference(id + " (legenda)", ref)
					for e in errs:
						if not out.has(e):
							out.append(e)
					if errs.is_empty() and not catalog.scripture.is_empty() and catalog.verses_of(ref).is_empty():
						out.append("%s: legenda cita \"%s\" sem texto importado (rode tools/import_scripture.gd)" % [id, ref])
			"actor":
				var sprite := String(st.get("sprite", ""))
				if not is_silhouette(sprite) and not characters.has(sprite):
					out.append("%s: figurante \"%s\" usa sprite inexistente \"%s\" (personagem de data/characters ou silhouette_*)" % [id, st.get("id", ""), sprite])
			"sfx":
				if not sounds.has(String(st.get("id", ""))):
					out.append("%s: som \"%s\" não existe em data/audio/sfx.json" % [id, st.get("id", "")])
	for d in s.get("on_end", {}).get("unlock", []):
		if not catalog.discoveries.has(d):
			out.append("%s: on_end.unlock cita descoberta inexistente \"%s\"" % [id, d])
	return out


## Sons do manifesto (data/audio/sfx.json), lidos sem o AudioManager.
static func manifest_sounds(path: String = "res://data/audio/sfx.json") -> Dictionary:
	var data: Variant = JsonUtil.read_file(path, PackedStringArray())
	if data is Dictionary and data.get("sounds") is Dictionary:
		return data.sounds
	return {}
