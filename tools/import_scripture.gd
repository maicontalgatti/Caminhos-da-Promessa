extends SceneTree
## Importa, de um arquivo oficial de texto bíblico no formato VPL do eBible.org
## ("GEN 26:18 texto"), só os versículos citados nos dados do jogo, e grava
## data/bible/texts/<tradução>.json. O texto nunca é digitado à mão.
##
## Uso: Godot --headless --path . --script res://tools/import_scripture.gd -- <arquivo_vpl.txt> <tradução>
## Traduções conhecidas: ver TRANSLATIONS. Código de saída 1 se faltar algum versículo.

const OUT_DIR := "res://data/bible/texts"
const DATA_DIR := "res://data"
## Códigos de livro dos arquivos VPL do eBible.org (estilo BibleWorks, não USFM:
## SOL, EZE, JOE, NAH, MAR, JOH, PHI, JAM, 1JO...), na ordem do cânon protestante
## (mesma ordem de books.json). Livros deuterocanônicos do arquivo são ignorados.
const VPL_CODES := ["GEN", "EXO", "LEV", "NUM", "DEU", "JOS", "JDG", "RUT", "1SA", "2SA", "1KI", "2KI",
	"1CH", "2CH", "EZR", "NEH", "EST", "JOB", "PSA", "PRO", "ECC", "SOL", "ISA", "JER", "LAM", "EZE",
	"DAN", "HOS", "JOE", "AMO", "OBA", "JON", "MIC", "NAH", "HAB", "ZEP", "HAG", "ZEC", "MAL",
	"MAT", "MAR", "LUK", "JOH", "ACT", "ROM", "1CO", "2CO", "GAL", "EPH", "PHI", "COL", "1TH", "2TH",
	"1TI", "2TI", "TIT", "PHM", "HEB", "JAM", "1PE", "2PE", "1JO", "2JO", "3JO", "JUD", "REV"]
const TRANSLATIONS := {
	"bpm": {
		"id": "bpm",
		"name": "Bíblia Portuguesa Mundial",
		"abbrev": "BPM",
		"license": "Domínio público",
		"credit": "Texto bíblico: Bíblia Portuguesa Mundial (domínio público), eBible.org.",
		"source": "https://ebible.org/find/details.php?id=porbrbsl",
		"source_file": "porbrbsl_vpl.txt",
		"notes": "Tradução em revisão pelos próprios tradutores (rascunho público).",
	},
	"blivre": {
		"id": "blivre",
		"name": "Bíblia Livre",
		"abbrev": "BLIVRE",
		"license": "Creative Commons Atribuição 4.0 Brasil",
		"credit": "Bíblia Livre (BLIVRE), Copyright © Diego Santos, Mario Sérgio e Marco Teles, 2018. Licença CC BY 4.0 Brasil.",
		"source": "https://ebible.org/find/details.php?id=porbr2018",
		"source_file": "porbr2018_vpl.txt",
		"notes": "",
	},
}

var _ref_regex := RegEx.create_from_string("\"([1-3]?[A-Z][a-z]+) (\\d+):(\\d+)(?:-(?:(\\d+):)?(\\d+))?\"")


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() < 2 or not TRANSLATIONS.has(args[1]):
		printerr("Uso: -- <arquivo_vpl.txt> <%s>" % "|".join(TRANSLATIONS.keys()))
		quit(2)
		return
	var catalog := BibleCatalog.new()
	catalog.load_all()
	var wanted := _wanted_verses(catalog)
	var source := read_vpl(args[0], catalog)
	if source.is_empty():
		quit(1)
		return
	var verses := {}
	var missing: Array[String] = []
	for key in wanted:
		if source.has(key):
			verses[key] = source[key]
		else:
			missing.append(key)
	var meta: Dictionary = TRANSLATIONS[args[1]].duplicate()
	meta["retrieved"] = Time.get_date_string_from_system()
	var out := {
		"_comment": "Gerado por tools/import_scripture.gd a partir do arquivo oficial. Não editar à mão: rode o importador de novo quando novas referências entrarem nos dados.",
		"translation": meta,
		"verification": {"status": "pending_review", "reviewer": "", "notes": "Texto copiado automaticamente do arquivo oficial; falta conferência humana da correspondência das referências."},
		"verses": verses,
	}
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	var path := OUT_DIR.path_join(args[1] + ".json")
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string(JSON.stringify(out, "\t", false) + "\n")
	f.close()
	print("versículos gravados: %d em %s" % [verses.size(), path])
	for m in missing:
		printerr("FALTANDO no arquivo de origem: " + m)
	quit(1 if not missing.is_empty() else 0)


## Todas as referências "Livro C:V[-[C:]V]" encontradas nos JSON de data/ (exceto os textos).
func _wanted_verses(catalog: BibleCatalog) -> Array[String]:
	var keys := {}
	for path in JsonUtil.list_json_recursive(DATA_DIR):
		if path.begins_with(OUT_DIR):
			continue
		var text := FileAccess.get_file_as_string(path)
		for m in _ref_regex.search_all(text):
			var book := m.get_string(1)
			if not catalog.books.has(book):
				continue
			for k in catalog.expand_reference(m.get_string(0).trim_prefix("\"").trim_suffix("\"")):
				keys[k] = true
	var out: Array[String] = []
	for b in catalog.book_order:
		var ks: Array = keys.keys().filter(func(k): return String(k).begins_with(b + " "))
		ks.sort_custom(func(a, c): return _order(a) < _order(c))
		for k in ks:
			out.append(String(k))
	return out


static func _order(key: String) -> int:
	var cv := key.split(" ")[-1].split(":")
	return int(cv[0]) * 1000 + int(cv[1])


## "Gen 26:18" -> texto, para todos os livros do cânon presentes no arquivo. Também usado por tools/factory.gd.
static func read_vpl(path: String, catalog: BibleCatalog) -> Dictionary:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		printerr("Não foi possível abrir " + path)
		return {}
	if catalog.book_order.size() != VPL_CODES.size() or catalog.book_order[0] != "Gen" or catalog.book_order[39] != "Matt":
		printerr("books.json fora da ordem canônica esperada; o mapeamento de códigos não é confiável")
		return {}
	var code_to_book := {}
	for i in VPL_CODES.size():
		code_to_book[VPL_CODES[i]] = catalog.book_order[i]
	var out := {}
	var line_re := RegEx.create_from_string("^([1-3A-Z]{3}) (\\d+):(\\d+) (.*)$")
	while not f.eof_reached():
		var m := line_re.search(f.get_line().strip_edges())
		if m and code_to_book.has(m.get_string(1)):
			out["%s %s:%s" % [code_to_book[m.get_string(1)], m.get_string(2), m.get_string(3)]] = m.get_string(4).strip_edges()
	return out
