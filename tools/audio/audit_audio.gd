extends SceneTree
## Lê os WAV de assets/audio e mostra duração, pico, nível médio (RMS),
## amostras saturadas e desvio DC. Sinaliza arquivo silencioso ou estourado.
##   godot --headless --path . --script res://tools/audio/audit_audio.gd

const ROOT := "res://assets/audio"
const WavInfo := preload("res://tools/audio/wav_info.gd")


func _init() -> void:
	var files: Array[String] = []
	_collect(ROOT, files)
	files.sort()
	var problems := 0
	for f in files:
		var info := WavInfo.read(f)
		if not info.ok:
			printerr("ERRO  %s: %s" % [f, info.error])
			problems += 1
			continue
		var flag := ""
		if info.peak_db < -40.0:
			flag = "  << SILENCIOSO"
		elif info.clipped > 0:
			flag = "  << SATURADO (%d)" % info.clipped
		elif absf(info.dc) > 0.02:
			flag = "  << DC %.3f" % info.dc
		if flag != "":
			problems += 1
		print("%-64s %5.2fs  pico %6.1f dB  rms %6.1f dB%s" % [f.trim_prefix(ROOT + "/"), info.seconds, info.peak_db, info.rms_db, flag])
	print("== %d arquivo(s), %d problema(s) ==" % [files.size(), problems])
	quit(1 if problems > 0 else 0)


func _collect(dir: String, out: Array[String]) -> void:
	for f in DirAccess.get_files_at(dir):
		if f.ends_with(".wav"):
			out.append(dir + "/" + f)
	for d in DirAccess.get_directories_at(dir):
		_collect(dir + "/" + d, out)
