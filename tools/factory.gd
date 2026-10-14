extends SceneTree
## Fábrica de missões — linha de comando. Ver docs/mission_factory.md.
##   $g = ".\tools\godot\Godot_v4.7.2-stable_win64_console.exe"
##   & $g --headless --path . --script res://tools/factory.gd -- <comando> [args]
## Comandos:
##   import-seed                      cria/atualiza production/catalog/episodes.json (preserva estados)
##   list [chave=valor ...]           filtros: status, book, testament, narrative_mode, region,
##                                    difficulty, mechanics, support, event, quest=yes|no
##   show <id>                        ficha do episódio, arquivos do pacote e o que falta
##   pending                          o que cada episódio em produção precisa para avançar
##   check [id]                       gates, pacote, missão vinculada e alvos reais no mapa
##   check-refs <arquivo_vpl> [id]    confere as referências contra o texto bíblico oficial
##   targets <região>                 NPCs e interações que existem de fato no mapa
##   select [n]                       candidatos para o próximo lote
##   new <id>                         cria o esqueleto do pacote do episódio
##   link <id> quest=<id> [dialogues=a,b] [presentations=a] [discoveries=a]
##   audio-manifest <id>              gera/atualiza o manifesto de áudio do pacote
##   set-status <id> <estado> <por> [nota]   muda o estado passando pelos gates
##   report                           escreve production/catalog/STATUS.md

const ImportScripture := preload("res://tools/import_scripture.gd")
const STATUS_MD := "res://production/catalog/STATUS.md"

var fc: FactoryCatalog


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	if args.is_empty():
		print(_usage())
		quit(1)
		return
	fc = FactoryCatalog.new()
	var cmd := args[0]
	var rest := args.slice(1)
	if cmd != "import-seed" and not fc.load_episodes():
		for e in fc.errors:
			printerr(e)
		quit(1)
		return
	var code := 0
	match cmd:
		"import-seed": code = _import_seed()
		"list": code = _list(rest)
		"show": code = _show(rest)
		"pending": code = _pending()
		"check": code = _check(rest)
		"check-refs": code = _check_refs(rest)
		"targets": code = _targets(rest)
		"select": code = _select(rest)
		"new": code = _new(rest)
		"link": code = _link(rest)
		"audio-manifest": code = _audio_manifest(rest)
		"set-status": code = _set_status(rest)
		"report": code = _report()
		_:
			printerr("comando desconhecido: %s" % cmd)
			print(_usage())
			code = 1
	quit(code)


func _usage() -> String:
	var src := FileAccess.get_file_as_string("res://tools/factory.gd")
	var out := PackedStringArray()
	for line in src.split("\n"):
		if not line.begins_with("##"):
			break
		out.append(line.trim_prefix("##"))
	return "\n".join(out)


func _save() -> int:
	var err := fc.save_episodes()
	if err != OK:
		printerr("não foi possível gravar %s (%s)" % [FactoryCatalog.EPISODES_PATH, error_string(err)])
		return 1
	return 0


func _find(rest: Array) -> Dictionary:
	if rest.is_empty():
		printerr("informe o id do episódio")
		return {}
	var ep: Dictionary = fc.by_id.get(rest[0], {})
	if ep.is_empty():
		printerr("episódio \"%s\" não existe" % rest[0])
	return ep


func _kv(rest: Array) -> Dictionary:
	var out := {}
	for a in rest:
		var i := String(a).find("=")
		if i > 0:
			out[String(a).left(i)] = String(a).substr(i + 1)
	return out


# --- comandos ------------------------------------------------------------------------

func _import_seed() -> int:
	var n := fc.import_seed()
	for e in fc.errors:
		printerr(e)
	if n == 0:
		return 1
	var bad := 0
	for ep in fc.episodes:
		if not ep.reference_parse_errors.is_empty():
			bad += 1
			print("  aviso %s: %s (%s)" % [ep.id, ep.reference_parse_errors, ep.reference_raw])
	print("%d episódios em %s (%d com referência ilegível)" % [n, FactoryCatalog.EPISODES_PATH, bad])
	print("estados: %s" % fc.status_counts())
	return _save()


func _list(rest: Array) -> int:
	var eps := fc.filter(_kv(rest))
	for ep in eps:
		var q := String(ep.get("game", {}).get("quest_id", ""))
		print("%-40s %-28s %-12s %-10s %s%s" % [ep.id, ep.status, ep.estimate.mechanics, ep.estimate.difficulty,
			ep.reference_raw if ep.book == "" else "%s %s" % [ep.book_name, ep.reference_raw],
			"  [jogo: %s]" % q if q != "" else ""])
	print("%d episódio(s)" % eps.size())
	return 0


func _show(rest: Array) -> int:
	var ep := _find(rest)
	if ep.is_empty():
		return 1
	print("%s — %s" % [ep.id, ep.title])
	print("  estado: %s (%s)" % [ep.status, FactoryCatalog.STATUS_LABELS.get(ep.status, "?")])
	print("  referência: %s %s -> %s %s" % [ep.book_name, ep.reference_raw, ep.references, ep.chapter_ranges])
	print("  modo: %s | contexto: %s | região no jogo: %s" % [ep.narrative_mode, ep.region_or_context, ep.region if ep.region != "" else "(nenhuma)"])
	print("  objetivo de aprendizagem: %s" % ep.learning_goal)
	print("  estimativa: %s" % ep.estimate)
	print("  conferência de referências: %s" % ep.reference_check)
	print("  objetivos-semente (alvos ainda são marcadores, não elementos do mapa):")
	for o in ep.seed_objectives:
		print("    - [%s] %s -> %s: %s" % [o.support, o.event_type, o.target_id, o.description])
	var game: Dictionary = ep.get("game", {})
	if not game.is_empty():
		print("  no jogo: %s" % game)
		for f in _game_files(game):
			print("    %s" % f)
	print("  pacote: %s" % ep.package)
	var dir := fc.package_path(ep)
	if DirAccess.dir_exists_absolute(dir):
		for f in DirAccess.get_files_at(dir):
			print("    %s" % dir.trim_prefix("res://").path_join(f))
	var next := _next_status(ep)
	if next != "":
		print("  para chegar a \"%s\":" % next)
		var errs := fc.gate_errors(ep, next)
		for e in errs:
			print("    - %s" % e)
		if errs.is_empty():
			print("    (requisitos atendidos; falta só o set-status)")
	print("  histórico:")
	for h in ep.status_history:
		print("    %s %s por %s — %s" % [h.date, h.status, h.by, h.get("note", "")])
	return 0


func _game_files(game: Dictionary) -> PackedStringArray:
	var out := PackedStringArray()
	var needles := {"res://data/quests": [game.get("quest_id", "")], "res://data/dialogues": game.get("dialogues", []),
		"res://data/bible": game.get("presentations", []) + game.get("discoveries", [])}
	for dir in needles:
		for id in needles[dir]:
			if String(id) == "":
				continue
			for f in _grep_files(dir, "\"%s\"" % id):
				if not out.has(f):
					out.append(f)
	return out


func _grep_files(dir: String, needle: String) -> PackedStringArray:
	var out := PackedStringArray()
	for sub in DirAccess.get_directories_at(dir):
		out.append_array(_grep_files(dir.path_join(sub), needle))
	for f in DirAccess.get_files_at(dir):
		var path := dir.path_join(f)
		if f.ends_with(".json") and FileAccess.get_file_as_string(path).contains(needle) and not out.has(path):
			out.append(path.trim_prefix("res://"))
	return out


func _next_status(ep: Dictionary) -> String:
	var i := FactoryCatalog.STATUSES.find(ep.status)
	if ep.status in ["blocked", "published"] or i < 0:
		return ""
	return FactoryCatalog.STATUSES[i + 1]


func _pending() -> int:
	var any := false
	for ep in fc.episodes:
		if ep.status == "idea" and DirAccess.dir_exists_absolute(fc.package_path(ep)) == false:
			continue
		any = true
		var next := _next_status(ep)
		print("%s [%s] -> %s" % [ep.id, ep.status, next if next != "" else "(fim)"])
		if next != "":
			for e in fc.gate_errors(ep, next):
				print("    - %s" % e)
	var c := fc.status_counts()
	print("" if any else "nenhum episódio em produção")
	print("demais: %d apenas ideia (sem pacote). Estados: %s" % [c.idea, c])
	return 0


func _check(rest: Array) -> int:
	var bad := 0
	var eps: Array = fc.episodes if rest.is_empty() else [_find(rest)]
	if eps.has({}):
		return 1
	var audit := fc.audit()
	for e in audit:
		if rest.is_empty() or String(e).begins_with(String(rest[0]) + " "):
			print("ERRO " + e)
			bad += 1
	for ep in eps:
		if String(ep.get("game", {}).get("quest_id", "")) == "":
			continue
		for e in fc.implementation_errors(ep):
			print("aviso %s (implementação): %s" % [ep.id, e])
		var am := fc.read_package_json(ep, "audio_manifest.json")
		if not am.is_empty():
			var fresh := fc.audio_manifest(ep)
			var old := {}
			for l in am.lines:
				old[l.line_id] = l.hash
			var changed := 0
			for l in fresh.lines:
				if old.get(l.line_id, "") != l.hash:
					changed += 1
			if changed > 0 or am.lines.size() != fresh.lines.size():
				print("aviso %s: audio_manifest desatualizado (%d fala(s) mudaram) — rode audio-manifest" % [ep.id, changed])
	print("check: %d erro(s) em %d episódio(s)" % [bad, eps.size()])
	return 1 if bad > 0 else 0


func _check_refs(rest: Array) -> int:
	if rest.is_empty():
		printerr("uso: check-refs <arquivo_vpl> [id]")
		return 1
	var source := {}
	if rest[0] != "-":
		if not FileAccess.file_exists(rest[0]):
			printerr("arquivo não encontrado: %s" % rest[0])
			return 1
		source = ImportScripture.read_vpl(rest[0], fc.catalog)
	var eps: Array = fc.episodes if rest.size() < 2 else [_find(rest.slice(1))]
	var counts := {"ok": 0, "ok_with_notes": 0, "errors": 0, "count_unknown": 0}
	for ep in eps:
		if ep.is_empty():
			return 1
		var r := fc.check_references(ep, source)
		ep.reference_check = r
		counts[r.status] += 1
		if r.status != "ok":
			var detail: Array = r.problems
			if detail.is_empty():
				detail = r.count_unknown if not r.count_unknown.is_empty() else r.notes
			print("%s (%s %s): %s %s" % [ep.id, ep.book_name, ep.reference_raw, r.status, detail])
	print("referências (%s): %s" % ["texto oficial" if not source.is_empty() else "verse_counts.json", counts])
	return _save() if counts.errors == 0 else max(_save(), 1)


func _targets(rest: Array) -> int:
	if rest.is_empty():
		printerr("uso: targets <região>")
		return 1
	var t := fc.region_targets(rest[0])
	if t.error != "":
		printerr(t.error)
		return 1
	print("mapa: %s" % t.map_scene)
	print("NPCs (target type \"npc\"):")
	for id in t.npc:
		print("  %-20s %s" % [id, t.npc[id]])
	print("interações (target type \"dialogue\"):")
	for id in t.dialogue:
		print("  %-20s %s" % [id, t.dialogue[id]])
	return 0


func _select(rest: Array) -> int:
	var n := int(rest[0]) if not rest.is_empty() else 5
	for c in fc.candidates(n):
		print("%-40s pontos %d  dificuldade %-6s  %s" % [c.id, c.score, c.difficulty, c.why])
	print("(sugestão automática; a escolha do lote é humana)")
	return 0


func _new(rest: Array) -> int:
	var ep := _find(rest)
	if ep.is_empty():
		return 1
	var dir := fc.package_path(ep)
	DirAccess.make_dir_recursive_absolute(dir)
	var today := Time.get_date_string_from_system()
	var files := {
		"manifest.json": {
			"episode": ep.id, "title": ep.title, "references": ep.references, "chapter_ranges": ep.chapter_ranges,
			"narrative_mode": ep.narrative_mode, "region": ep.region, "created": today,
			"gates": {"0_selection": "done", "1_research": "pending", "2_design": "pending", "3_review": "pending",
				"4_implementation": "pending", "5_audio": "pending", "6_qa": "pending", "7_publication": "pending"},
			"agents": [], "costs": [],
		},
		"review.json": {
			"episode": ep.id,
			"biblical": {"verdict": "pending", "reviewer_agent": "", "date": ""},
			"historical": {"verdict": "pending", "reviewer_agent": "", "date": ""},
			"findings": [],
			"human": {"approved_by": "", "date": "", "notes": ""},
			"_comment": "Veredito de agente nunca é 'verified'. Só uma pessoa preenche human.approved_by.",
		},
		"test_report.json": {"episode": ep.id, "overall": "not_run", "runs": []},
		"visual_manifest.json": {"episode": ep.id, "reuse": [], "gaps": [], "environment": [], "generator": [], "map_inventory": []},
	}
	var created := PackedStringArray()
	for f in files:
		var path := dir.path_join(f)
		if FileAccess.file_exists(path):
			continue
		var fa := FileAccess.open(path, FileAccess.WRITE)
		fa.store_string(JSON.stringify(files[f], "\t", false) + "\n")
		created.append(f)
	print("pacote %s: criados %s (existentes preservados)" % [dir.trim_prefix("res://"), created])
	return 0


func _link(rest: Array) -> int:
	var ep := _find(rest)
	if ep.is_empty():
		return 1
	var kv := _kv(rest.slice(1))
	if not kv.has("quest"):
		printerr("uso: link <id> quest=<quest_id> [dialogues=a,b] [presentations=a] [discoveries=a]")
		return 1
	var qdb := QuestDatabase.new()
	qdb.load_dir()
	if qdb.get_quest(kv.quest).is_empty():
		printerr("missão \"%s\" não existe em data/quests" % kv.quest)
		return 1
	var game := {"quest_id": kv.quest}
	for k in ["dialogues", "presentations", "discoveries"]:
		game[k] = Array(String(kv.get(k, "")).split(",", false))
	ep.game = game
	print("%s vinculado a %s" % [ep.id, game])
	return _save()


func _audio_manifest(rest: Array) -> int:
	var ep := _find(rest)
	if ep.is_empty():
		return 1
	if ep.get("game", {}).is_empty():
		printerr("episódio sem conteúdo no jogo (use link)")
		return 1
	var m := fc.audio_manifest(ep)
	for e in fc.errors:
		printerr(e)
	DirAccess.make_dir_recursive_absolute(fc.package_path(ep))
	var path := fc.package_path(ep, "audio_manifest.json")
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string(JSON.stringify(m, "\t", false) + "\n")
	var by_status := {}
	for l in m.lines:
		by_status[l.status] = int(by_status.get(l.status, 0)) + 1
	print("%s: %d falas, %d caracteres, estados %s" % [path.trim_prefix("res://"), m.lines.size(), m.total_characters, by_status])
	return 0


func _set_status(rest: Array) -> int:
	if rest.size() < 3:
		printerr("uso: set-status <id> <estado> <por> [nota]")
		return 1
	var note := " ".join(rest.slice(3))
	var errs := fc.set_status(rest[0], rest[1], rest[2], note)
	if not errs.is_empty():
		print("gate recusou \"%s\" para %s:" % [rest[1], rest[0]])
		for e in errs:
			print("  - %s" % e)
		return 1
	print("%s -> %s" % [rest[0], rest[1]])
	return _save()


func _report() -> int:
	var c := fc.status_counts()
	var md := PackedStringArray()
	md.append("# Estado do catálogo de missões")
	md.append("")
	md.append("Gerado por `tools/factory.gd report` em %s. Não edite à mão." % Time.get_date_string_from_system())
	md.append("Fonte: `production/catalog/episodes.json`. Processo: [`docs/mission_factory.md`](../../docs/mission_factory.md).")
	md.append("")
	md.append("| Estado | Episódios |")
	md.append("|---|---|")
	for s in FactoryCatalog.STATUSES:
		md.append("| %s | %d |" % [FactoryCatalog.STATUS_LABELS[s], c[s]])
	md.append("")
	md.append("## Em produção")
	md.append("")
	var any := false
	for ep in fc.episodes:
		if ep.status == "idea" and not DirAccess.dir_exists_absolute(fc.package_path(ep)):
			continue
		any = true
		var next := _next_status(ep)
		var errs := fc.gate_errors(ep, next) if next != "" else PackedStringArray()
		md.append("- **%s** — %s (%s %s): %s. Próximo: %s%s" % [ep.id, ep.title, ep.book_name, ep.reference_raw,
			FactoryCatalog.STATUS_LABELS[ep.status], next if next != "" else "—",
			"" if errs.is_empty() else "; falta: " + "; ".join(errs)])
	if not any:
		md.append("Nenhum.")
	md.append("")
	md.append("## Catálogo completo")
	md.append("")
	md.append("| Id | Título | Referência | Estado | Mecânica | Dificuldade |")
	md.append("|---|---|---|---|---|---|")
	for ep in fc.episodes:
		md.append("| %s | %s | %s %s | %s | %s | %s |" % [ep.id, ep.title, ep.book_name, ep.reference_raw,
			FactoryCatalog.STATUS_LABELS[ep.status], ep.estimate.mechanics, ep.estimate.difficulty])
	var f := FileAccess.open(STATUS_MD, FileAccess.WRITE)
	f.store_string("\n".join(md) + "\n")
	print("%s escrito (%d episódios)" % [STATUS_MD, fc.episodes.size()])
	return 0
