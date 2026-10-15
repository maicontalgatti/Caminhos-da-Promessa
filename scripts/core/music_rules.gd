extends RefCounted
## Regras do manifesto de música (data/audio/music.json), sem depender dos
## autoloads: usadas por tools/validate_content.gd e pelos testes.

const AUDIO_DIR := "res://assets/audio"

## Erros do manifesto de música: licença das melodias (domínio público só com
## compositor morto há mais de 70 anos, ou sem autor e publicada há mais de
## 120), faixas cantadas sem licença da letra, arquivos e momentos que apontam
## para regiões, missões, cenas ou apresentações inexistentes.
## `known` = {"regions": [...], "quests": [...], "scenes": [...],
## "presentations": [...], "prologues": [...], "contexts": [...]}.
static func validate_manifest(data: Dictionary, known: Dictionary, year: int) -> PackedStringArray:
	var out := PackedStringArray()
	var tr: Dictionary = data.get("tracks", {})
	var themes := {}
	for id in tr:
		if String(id).begins_with("_"):
			continue
		var t: Dictionary = tr[id]
		for th in t.get("themes", []):
			themes[String(th)] = true
		var src := String(t.get("source", ""))
		if not (src in ["public_domain_hymn", "original", "licensed"]):
			out.append("música %s: source \"%s\" desconhecido (public_domain_hymn, original, licensed)" % [id, src])
		if src == "public_domain_hymn":
			var death: Variant = t.get("composer_death")
			if death == null:
				if int(t.get("year", year)) > year - 120:
					out.append("música %s: sem compositor conhecido, precisa ter sido publicada há mais de 120 anos" % id)
			elif year - int(death) <= 70:
				out.append("música %s: compositor morreu há 70 anos ou menos; a melodia ainda pode ser protegida" % id)
		if src == "licensed" and String(t.get("license_record", "")) == "":
			out.append("música %s: licenciada sem license_record (registre em docs/legal/ASSET_LICENSES.md)" % id)
		if bool(t.get("vocal", false)) and String(t.get("lyrics_license", "")) == "":
			out.append("música %s: faixa cantada sem lyrics_license (letras e traduções modernas são protegidas)" % id)
		var base := "%s/%s" % [AUDIO_DIR, t.get("path", "music/" + String(id))]
		if not (ResourceLoader.exists(base + ".ogg") or ResourceLoader.exists(base + ".wav")
				or FileAccess.file_exists(base + ".ogg") or FileAccess.file_exists(base + ".wav")):
			out.append("música %s: arquivo ausente %s(.ogg|.wav)" % [id, base])
	var c: Dictionary = data.get("cues", {})
	var lists := [["menu", c.get("menu", [])]]
	for group in ["regions", "quests", "contexts", "scenes", "presentations", "prologues"]:
		var g: Dictionary = c.get(group, {})
		var valid: Array = known.get(group, [])
		for k in g:
			if String(k).begins_with("_"):
				continue
			if not valid.is_empty() and not (k in valid):
				out.append("música: %s.%s não existe no jogo" % [group, k])
			lists.append(["%s.%s" % [group, k], g[k]])
	for pair in lists:
		if not (pair[1] is Array):
			out.append("música: %s deveria ser uma lista" % pair[0])
			continue
		for item in pair[1]:
			var s := String(item)
			if s.begins_with("theme:"):
				if not themes.has(s.substr(6)):
					out.append("música: %s usa o tema \"%s\", que nenhuma faixa tem" % [pair[0], s.substr(6)])
			elif not tr.has(s):
				out.append("música: %s usa a faixa inexistente \"%s\"" % [pair[0], s])
	return out
