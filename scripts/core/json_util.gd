@tool
class_name JsonUtil
extends RefCounted
## Leitura de arquivos JSON de dados do jogo (data/**).


## Retorna o conteúdo decodificado ou null em caso de erro (mensagem em `errors`).
static func read_file(path: String, errors: PackedStringArray = PackedStringArray()) -> Variant:
	if not FileAccess.file_exists(path):
		errors.append("%s: arquivo não encontrado" % path)
		return null
	var text := FileAccess.get_file_as_string(path)
	var json := JSON.new()
	var err := json.parse(text)
	if err != OK:
		errors.append("%s:%d: JSON inválido (%s)" % [path, json.get_error_line(), json.get_error_message()])
		return null
	return json.data


## Lista os arquivos .json de uma pasta (ordem alfabética).
static func list_json(dir_path: String) -> PackedStringArray:
	var out := PackedStringArray()
	if not DirAccess.dir_exists_absolute(dir_path):
		return out
	var files := DirAccess.get_files_at(dir_path)
	files.sort()
	for f in files:
		if f.ends_with(".json"):
			out.append(dir_path.path_join(f))
	return out


## Como list_json, incluindo subpastas (ex.: data/quests/canaan/*.json).
static func list_json_recursive(dir_path: String) -> PackedStringArray:
	var out := list_json(dir_path)
	if not DirAccess.dir_exists_absolute(dir_path):
		return out
	var dirs := DirAccess.get_directories_at(dir_path)
	dirs.sort()
	for d in dirs:
		out.append_array(list_json_recursive(dir_path.path_join(d)))
	return out


## Lê todos os JSON de uma pasta e junta os arrays sob `key` (ex.: "characters").
static func read_collection(dir_path: String, key: String, errors: PackedStringArray, recursive := false) -> Array:
	var items: Array = []
	for path in (list_json_recursive(dir_path) if recursive else list_json(dir_path)):
		var data: Variant = read_file(path, errors)
		if data == null:
			continue
		if not (data is Dictionary) or not (data.get(key) is Array):
			errors.append("%s: esperado objeto com a lista \"%s\"" % [path, key])
			continue
		for item in data[key]:
			if item is Dictionary and item.get("id") is String:
				item["_source"] = path
				items.append(item)
			else:
				errors.append("%s: item sem \"id\" textual em \"%s\"" % [path, key])
	return items
