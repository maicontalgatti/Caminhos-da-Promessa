extends SceneTree
## Gera as faixas instrumentais de assets/audio/music (WAV 16 bits, 22,05 kHz,
## mono) a partir das partituras de tools/audio/scores/<faixa>.json.
## Determinístico: o mesmo código e as mesmas partituras geram os mesmos
## arquivos. Catálogo e uso no jogo: data/audio/music.json (docs/audio.md,
## "Música temática"; ADR-029).
##   godot --headless --path . --script res://tools/audio/generate_music.gd
##   godot --headless --path . --script res://tools/audio/generate_music.gd -- silent_night orig_nile
## Depois rode `godot --headless --path . --import`.
##
## Partitura de hino: melody [[nota MIDI, tempos]...] e chords [[cifra, tempos]...]
## (a soma dos tempos tem de bater). Tema próprio: generate {root, mode,
## progression} e a melodia é composta por regras. Campos comuns: bpm, lead
## ("lyre" | "flute"), drum (padrão de "x" e "." por pulso), arp_step (tempos
## entre notas do arpejo e pulsos do tamboril), intro_beats.
## Timbres: lira (corda dedilhada), flauta (senoide com sopro e vibrato),
## bordão grave e tamboril. Gravações reais substituem os arquivos (ver doc).

const Synth := preload("res://tools/audio/synth.gd")
const OUT := "res://assets/audio/music"
const SCORES := "res://tools/audio/scores"
const OUT_RATE := 22050
const OUTRO := 6.0

## Escalas (semitons a partir da tônica).
const MODES := {
	"major": [0, 2, 4, 5, 7, 9, 11],
	"dorian": [0, 2, 3, 5, 7, 9, 10],
	"aeolian": [0, 2, 3, 5, 7, 8, 10],
	"phrygian": [0, 1, 3, 5, 7, 8, 10],
	"mixolydian": [0, 2, 4, 5, 7, 9, 10],
}
const PITCH := {"C": 0, "D": 2, "E": 4, "F": 5, "G": 7, "A": 9, "B": 11}

var s: Synth


func _init() -> void:
	var only := OS.get_cmdline_user_args()
	var count := 0
	for file in DirAccess.get_files_at(SCORES):
		if not file.ends_with(".json"):
			continue
		var id := file.get_basename()
		if not only.is_empty() and not (id in only):
			continue
		var score: Variant = JSON.parse_string(FileAccess.get_file_as_string("%s/%s" % [SCORES, file]))
		if not (score is Dictionary):
			printerr("partitura inválida: " + file)
			quit(1)
			return
		var problem := check_score(score)
		if problem != "":
			printerr("%s: %s" % [file, problem])
			quit(1)
			return
		s = Synth.new(hash(id))
		var out := downsample(render(score))
		var path := "%s/%s.wav" % [OUT, id]
		var err := save(out, path)
		if err != OK:
			printerr("falhou: %s (%s)" % [path, error_string(err)])
			quit(1)
			return
		count += 1
		print("  %s  %.1fs" % [path, out.size() / float(OUT_RATE)])
	print("== %d faixa(s) gerada(s) ==" % count)
	quit(0)


## "" se a partitura está coerente; senão, o problema.
func check_score(score: Dictionary) -> String:
	if score.has("generate"):
		var g: Dictionary = score.generate
		return "" if MODES.has(String(g.get("mode", ""))) else "modo desconhecido"
	var a := 0.0
	var b := 0.0
	for n in score.get("melody", []):
		a += float(n[1])
	for c in score.get("chords", []):
		b += float(c[1])
		if chord_root(String(c[0])) < 0:
			return "cifra desconhecida " + String(c[0])
	if a <= 0.0 or absf(a - b) > 0.001:
		return "melodia (%.2f tempos) e cifras (%.2f) não batem" % [a, b]
	return ""


# --- Harmonia --------------------------------------------------------------------

func midi_hz(m: float) -> float:
	return 440.0 * pow(2.0, (m - 69.0) / 12.0)


## Classe de altura da cifra ("G", "F#", "Bb", "Em"...), ou -1.
func chord_root(sym: String) -> int:
	if sym == "" or not PITCH.has(sym[0]):
		return -1
	var pc := int(PITCH[sym[0]])
	if sym.length() > 1 and sym[1] == "#":
		pc += 1
	elif sym.length() > 1 and sym[1] == "b":
		pc -= 1
	return posmod(pc, 12)


## Notas do arpejo [fundamental, quinta, terça acima, quinta] na região grave.
func chord_tones(sym: String) -> Array:
	var root := 48 + chord_root(sym)
	var third := 3 if sym.ends_with("m") else 4
	return [root, root + 7, root + 12 + third, root + 7]


func degree(g: Dictionary, deg: int, octave: int = 0) -> int:
	var scale: Array = MODES[g.mode]
	var o := floori(deg / 7.0)
	var idx := deg - o * 7
	return int(g.root) + 12 * (o + octave) + int(scale[idx])


# --- Temas próprios --------------------------------------------------------------

## Frase de 4 compassos por graus conjuntos, saltos raros, que termina na
## tônica (final) ou na dominante.
func make_phrase(g: Dictionary, chords: Array, final: bool) -> Array:
	var out := []
	var cur := s.rng.randi_range(2, 4)
	var rhythms: Array = [[2, 1, 1], [1, 1, 2], [1, 1, 1, 1], [3, 1], [2, 2]]
	var steps: Array = [-1, 1, -1, 1, 2, -2, 0]
	for bar in 4:
		var chord := int(chords[bar % chords.size()])
		var rhythm: Array = rhythms[s.rng.randi_range(0, rhythms.size() - 1)]
		if bar == 3:
			rhythm = [2, 2] if s.rng.randf() < 0.5 else [1, 3]
		for i in rhythm.size():
			if bar == 3 and i == rhythm.size() - 1:
				cur = 7 if final else 4
			elif i == 0:
				var best := cur
				var dist := 99
				for t: int in [chord, chord + 2, chord + 4, chord + 7]:
					if absi(t - cur) < dist:
						dist = absi(t - cur)
						best = t
				cur = best
			else:
				var step: int = steps[s.rng.randi_range(0, steps.size() - 1)]
				cur = clampi(cur + step, 0, 9)
			out.append([degree(g, cur, 0), float(rhythm[i])])
	return out


## Pergunta e resposta (A A'): curto de propósito; o jogo põe silêncio entre
## as repetições, então a faixa não cansa nem pesa no executável.
func generated(score: Dictionary) -> Dictionary:
	var g: Dictionary = score.generate
	var prog: Array = g.progression
	var mel := make_phrase(g, prog, false) + make_phrase(g, prog, true)
	var chords := []
	for bar in 8:
		var deg := int(prog[bar % prog.size()])
		chords.append([degree(g, deg, -1), degree(g, deg + 4, -1), degree(g, deg + 2, 0), degree(g, deg + 4, -1), 4.0])
	return {"melody": mel, "chords": chords}


# --- Arranjo ---------------------------------------------------------------------

func render(score: Dictionary) -> PackedFloat32Array:
	var beat := 60.0 / float(score.get("bpm", 72))
	var arp_step := float(score.get("arp_step", 1.0))
	var lead := String(score.get("lead", "lyre"))
	var mel: Array
	## Cada acorde: [t1, t2, t3, t4, tempos].
	var chords: Array = []
	if score.has("generate"):
		var gen := generated(score)
		mel = gen.melody
		chords = gen.chords
	else:
		mel = score.melody
		for c in score.chords:
			chords.append(chord_tones(String(c[0])) + [float(c[1])])
	var total := 0.0
	for n in mel:
		total += float(n[1])
	var intro := float(score.get("intro_beats", 4)) * beat
	var sec := intro + total * beat + OUTRO
	var mixb := s.silence(sec)

	# Bordão: tônica e quinta graves do primeiro acorde, respirando devagar.
	var drone_hz := midi_hz(float(chords[0][0]) - 12.0)
	var drone := s.silence(sec)
	s.mix(drone, s.sine(sec, drone_hz), 0, 0.6)
	s.mix(drone, s.sine(sec, drone_hz * 1.5, 1.3), 0, 0.3)
	s.mix(drone, s.sine(sec, drone_hz * 2.003, 0.7), 0, 0.12)
	s.wobble(drone, 0.07, 0.35)
	s.env_ar(drone, 4.0, 5.0)
	s.mix(mixb, drone, 0, 0.2)

	# Lira de acompanhamento: na introdução repete o primeiro acorde; depois
	# segue as cifras, uma nota do arpejo a cada arp_step tempos.
	var t := 0.0
	var k := 0
	while t < intro - 0.001:
		s.mix(mixb, lyre(midi_hz(float(chords[0][k % 4])), beat * arp_step * 3.0, 0.35), s.at(t), (0.5 if k % 4 == 0 else 0.32) * 0.5)
		t += beat * arp_step
		k += 1
	var pos := 0.0
	for c in chords:
		var len := float(c[4])
		var b := 0.0
		k = 0
		while b < len - 0.001:
			var vel := 0.5 if k == 0 else 0.32
			s.mix(mixb, lyre(midi_hz(float(c[k % 4])), beat * arp_step * 3.0, 0.35), s.at(intro + (pos + b) * beat), vel * 0.5)
			b += arp_step
			k += 1
		pos += len
	# Acorde final soando no fim.
	var last: Array = chords[chords.size() - 1]
	for i in 3:
		s.mix(mixb, lyre(midi_hz(float(last[i])), 4.0, 0.3), s.at(intro + total * beat + i * 0.06), 0.22)

	# Melodia.
	t = intro
	for n in mel:
		var dur := float(n[1]) * beat
		var m := float(n[0])
		if lead == "flute" and m < 64.0:
			m += 12.0
		var note := flute(midi_hz(m), dur) if lead == "flute" else lyre(midi_hz(m), maxf(dur * 1.8, 1.2), 0.5)
		s.mix(mixb, note, s.at(t), 0.42 if lead == "flute" else 0.55)
		t += dur

	# Tamboril: "x" batida, "." nada, a cada arp_step tempos, só com a melodia.
	var pattern := String(score.get("drum", ""))
	if pattern != "":
		var i := 0
		var bt := 0.0
		while bt < total - 0.001:
			if pattern[i % pattern.length()] == "x":
				var accent := i % pattern.length() == 0
				s.mix(mixb, frame_drum(accent), s.at(intro + bt * beat), 0.35 if accent else 0.22)
			bt += arp_step
			i += 1

	s.biquad(mixb, "hp", 40.0)
	mixb = s.reverb(mixb, 0.28, 0.82, 1.5, 0.35)
	s.env_ar(mixb, 2.0, 5.0)
	s.normalize_rms(mixb, 0.11, 0.7)
	return mixb


# --- Timbres --------------------------------------------------------------------

## Lira (kinnor simples): corda dedilhada com corpo de madeira.
func lyre(freq: float, sec: float, bright: float = 0.45) -> PackedFloat32Array:
	var b := s.pluck(freq, sec, bright, 0.9975)
	var bod := s.body(b, [[260.0, 2.0, 0.5], [520.0, 3.0, 0.25]])
	s.mix(b, bod, 0, 0.6)
	s.biquad(b, "lp", 4200.0)
	return s.env(b, 0.003, sec * 0.3)


## Flauta de cana: fundamental com um pouco de 2º e 3º harmônicos, vibrato
## que entra devagar e sopro filtrado.
func flute(freq: float, sec: float) -> PackedFloat32Array:
	var b := s.chirp(sec, freq, freq, 4.8, freq * 0.006)
	s.mix(b, s.sine(sec, freq * 2.0, 0.4), 0, 0.18)
	s.mix(b, s.sine(sec, freq * 3.0, 1.1), 0, 0.06)
	var breath := s.pink(sec)
	s.biquad(breath, "bp", freq * 1.5, 1.2)
	s.mix(b, breath, 0, 0.12)
	s.env_ar(b, minf(0.08, sec * 0.3), minf(0.25, sec * 0.5))
	return b


## Tamboril (tof): baque grave curto com um toque de pele.
func frame_drum(accent: bool) -> PackedFloat32Array:
	var b := s.brown(0.5)
	s.biquad(b, "lp", 180.0 if accent else 260.0)
	s.env(b, 0.002, 0.07 if accent else 0.045)
	var skin := s.white(0.08)
	s.biquad(skin, "bp", 900.0, 0.8)
	s.env(skin, 0.001, 0.01)
	s.mix(b, skin, 0, 0.25)
	return b


# --- Saída ----------------------------------------------------------------------

## 44,1 kHz -> 22,05 kHz: passa-baixa e uma amostra a cada duas.
func downsample(b: PackedFloat32Array) -> PackedFloat32Array:
	s.biquad(b, "lp", 9000.0)
	s.biquad(b, "lp", 9000.0)
	var out := PackedFloat32Array()
	out.resize(b.size() / 2)
	for i in out.size():
		out[i] = b[i * 2]
	return out


func save(b: PackedFloat32Array, path: String) -> Error:
	var data := PackedByteArray()
	data.resize(b.size() * 2)
	for i in b.size():
		data.encode_s16(i * 2, int(clampf(b[i], -1.0, 1.0) * 32767.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = OUT_RATE
	wav.stereo = false
	wav.data = data
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	return wav.save_to_wav(path)
