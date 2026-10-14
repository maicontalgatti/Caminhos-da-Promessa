extends RefCounted
## Ferramentas de síntese para tools/audio/generate_sfx.gd. Trabalha com
## buffers mono PackedFloat32Array a 44,1 kHz e grava WAV PCM 16 bits.
## Nada aqui roda no jogo; só gera arquivos em assets/audio.

const RATE := 44100

var rng := RandomNumberGenerator.new()


func _init(seed_value: int = 1) -> void:
	rng.seed = seed_value


func samples(sec: float) -> int:
	return maxi(int(sec * RATE), 1)


func silence(sec: float) -> PackedFloat32Array:
	var b := PackedFloat32Array()
	b.resize(samples(sec))
	b.fill(0.0)
	return b


# --- Fontes -------------------------------------------------------------------

func white(sec: float) -> PackedFloat32Array:
	var b := silence(sec)
	for i in b.size():
		b[i] = rng.randf_range(-1.0, 1.0)
	return b


## Ruído marrom (integrado): grave, bom para baques e vento.
func brown(sec: float) -> PackedFloat32Array:
	var b := silence(sec)
	var v := 0.0
	for i in b.size():
		v = (v + rng.randf_range(-1.0, 1.0) * 0.06) * 0.995
		b[i] = v * 6.0
	return b


## Ruído rosa (Paul Kellet, versão econômica).
func pink(sec: float) -> PackedFloat32Array:
	var b := silence(sec)
	var b0 := 0.0
	var b1 := 0.0
	var b2 := 0.0
	for i in b.size():
		var w := rng.randf_range(-1.0, 1.0)
		b0 = 0.99765 * b0 + w * 0.0990460
		b1 = 0.96300 * b1 + w * 0.2965164
		b2 = 0.57000 * b2 + w * 1.0526913
		b[i] = (b0 + b1 + b2 + w * 0.1848) * 0.25
	return b


func sine(sec: float, freq: float, phase: float = 0.0) -> PackedFloat32Array:
	var b := silence(sec)
	for i in b.size():
		b[i] = sin(TAU * freq * float(i) / RATE + phase)
	return b


## Senoide com frequência variando de f0 a f1 (curva exponencial).
func chirp(sec: float, f0: float, f1: float, vib_hz: float = 0.0, vib_depth: float = 0.0) -> PackedFloat32Array:
	var b := silence(sec)
	var n := b.size()
	var ph := 0.0
	for i in n:
		var t := float(i) / n
		var f := f0 * pow(f1 / f0, t)
		if vib_hz > 0.0:
			f += sin(TAU * vib_hz * float(i) / RATE) * vib_depth
		ph += TAU * f / RATE
		b[i] = sin(ph)
	return b


## Parciais [[razão, amplitude, decaimento s], ...] sobre a fundamental:
## sinos, cerâmica e bronze.
func partials(sec: float, freq: float, parts: Array, attack: float = 0.002) -> PackedFloat32Array:
	var b := silence(sec)
	var na := maxi(int(attack * RATE), 1)
	for p in parts:
		var f := freq * float(p[0])
		if f >= RATE * 0.45:
			continue
		var amp := float(p[1])
		var k := 1.0 / (float(p[2]) * RATE)
		var ph := rng.randf() * TAU
		for i in b.size():
			var e := exp(-float(i) * k) * minf(1.0, float(i) / na)
			b[i] += sin(TAU * f * float(i) / RATE + ph) * amp * e
	return b


## Corda dedilhada (Karplus-Strong): lira simples.
func pluck(freq: float, sec: float, bright: float = 0.5, decay: float = 0.996) -> PackedFloat32Array:
	var b := silence(sec)
	var period := maxi(int(RATE / freq), 2)
	var dl := PackedFloat32Array()
	dl.resize(period)
	var prev := 0.0
	for i in period:
		var w := rng.randf_range(-1.0, 1.0)
		prev = prev + (w - prev) * clampf(bright, 0.05, 1.0)
		dl[i] = prev
	for i in b.size():
		var j := i % period
		var y := dl[j]
		var nx := dl[(j + 1) % period]
		dl[j] = decay * 0.5 * (y + nx)
		b[i] = y
	biquad(b, "hp", 60.0)
	return b


# --- Envelopes ----------------------------------------------------------------

## Ataque linear e decaimento exponencial (tempo até ~-60 dB = decay * 6.9).
func env(b: PackedFloat32Array, attack: float, decay: float, delay: float = 0.0) -> PackedFloat32Array:
	var na := maxi(int(attack * RATE), 1)
	var nd := int(delay * RATE)
	var k := 1.0 / maxf(decay * RATE, 1.0)
	for i in b.size():
		var t := i - nd
		var e := 0.0
		if t >= 0:
			e = float(t) / na if t < na else exp(-float(t - na) * k)
		b[i] *= e
	return b


## Ataque e liberação lineares com sustentação no meio.
func env_ar(b: PackedFloat32Array, attack: float, release: float) -> PackedFloat32Array:
	var n := b.size()
	var na := maxi(int(attack * RATE), 1)
	var nr := maxi(int(release * RATE), 1)
	for i in n:
		var e := 1.0
		if i < na:
			e = float(i) / na
		if i > n - nr:
			e = minf(e, float(n - i) / nr)
		b[i] *= e * e
	return b


## Envelope de grãos: impulsos aleatórios (densidade por segundo) que decaem
## em poucos ms. Multiplicado por ruído, vira estalos, areia ou papel.
func grains(b: PackedFloat32Array, density: float, grain_decay: float) -> PackedFloat32Array:
	var p := density / RATE
	var k := exp(-1.0 / maxf(grain_decay * RATE, 1.0))
	var e := 0.0
	for i in b.size():
		if rng.randf() < p:
			e = maxf(e, rng.randf_range(0.3, 1.0))
		b[i] *= e
		e *= k
	return b


## Modulação lenta de amplitude (gestos de pano, vento, papel).
func wobble(b: PackedFloat32Array, rate_hz: float, depth: float) -> PackedFloat32Array:
	var ph := rng.randf() * TAU
	var ph2 := rng.randf() * TAU
	for i in b.size():
		var t := float(i) / RATE
		var m := 0.5 + 0.3 * sin(TAU * rate_hz * t + ph) + 0.2 * sin(TAU * rate_hz * 2.7 * t + ph2)
		b[i] *= 1.0 - depth + depth * m
	return b


# --- Filtros ------------------------------------------------------------------

## Biquad RBJ: "lp", "hp", "bp" (ganho 0 dB no pico) ou "peak".
func biquad(b: PackedFloat32Array, kind: String, freq: float, q: float = 0.707, gain_db: float = 0.0) -> PackedFloat32Array:
	freq = clampf(freq, 10.0, RATE * 0.45)
	var w0 := TAU * freq / RATE
	var cw := cos(w0)
	var alpha := sin(w0) / (2.0 * q)
	var b0 := 0.0
	var b1 := 0.0
	var b2 := 0.0
	var a0 := 1.0
	var a1 := 0.0
	var a2 := 0.0
	match kind:
		"lp":
			b0 = (1.0 - cw) * 0.5; b1 = 1.0 - cw; b2 = b0
			a0 = 1.0 + alpha; a1 = -2.0 * cw; a2 = 1.0 - alpha
		"hp":
			b0 = (1.0 + cw) * 0.5; b1 = -(1.0 + cw); b2 = b0
			a0 = 1.0 + alpha; a1 = -2.0 * cw; a2 = 1.0 - alpha
		"bp":
			b0 = alpha; b1 = 0.0; b2 = -alpha
			a0 = 1.0 + alpha; a1 = -2.0 * cw; a2 = 1.0 - alpha
		"peak":
			var A := pow(10.0, gain_db / 40.0)
			b0 = 1.0 + alpha * A; b1 = -2.0 * cw; b2 = 1.0 - alpha * A
			a0 = 1.0 + alpha / A; a1 = -2.0 * cw; a2 = 1.0 - alpha / A
	b0 /= a0; b1 /= a0; b2 /= a0; a1 /= a0; a2 /= a0
	var x1 := 0.0
	var x2 := 0.0
	var y1 := 0.0
	var y2 := 0.0
	for i in b.size():
		var x := b[i]
		var y := b0 * x + b1 * x1 + b2 * x2 - a1 * y1 - a2 * y2
		x2 = x1; x1 = x; y2 = y1; y1 = y
		b[i] = y
	return b


## Passa-baixa de estado variável com corte variando no tempo (Hz por amostra
## via Callable t->Hz, t em 0..1). Usado em vento e varreduras de papel.
func sweep_lp(b: PackedFloat32Array, cutoff: Callable, q: float = 0.7, band: bool = false) -> PackedFloat32Array:
	var low := 0.0
	var bp := 0.0
	var damp := 1.0 / q
	var n := b.size()
	for i in n:
		var fc := clampf(float(cutoff.call(float(i) / n)), 20.0, RATE / 6.5)
		var f := 2.0 * sin(PI * fc / RATE)
		low += f * bp
		var high := b[i] - low - damp * bp
		bp += f * high
		b[i] = bp if band else low
	return b


## Ressonâncias de corpo (madeira, cerâmica): soma de passa-faixas paralelos.
func body(b: PackedFloat32Array, modes: Array) -> PackedFloat32Array:
	var out := PackedFloat32Array()
	out.resize(b.size())
	out.fill(0.0)
	for m in modes:
		var c := b.duplicate()
		biquad(c, "bp", float(m[0]), float(m[1]))
		mix(out, c, 0, float(m[2]))
	return out


# --- Espaço -------------------------------------------------------------------

## Eco simples com realimentação filtrada (poço, cisterna).
func echo(b: PackedFloat32Array, delay: float, feedback: float, tail: float, lp_hz: float = 2500.0) -> PackedFloat32Array:
	var out := pad(b, tail)
	var d := maxi(int(delay * RATE), 1)
	var state := 0.0
	var k := 1.0 - exp(-TAU * lp_hz / RATE)
	for i in range(d, out.size()):
		state += (out[i - d] - state) * k
		out[i] += state * feedback
	return out


## Reverberação de Schroeder (4 pentes + 2 passa-tudo), para caudas suaves.
func reverb(b: PackedFloat32Array, wet: float, room: float = 0.84, tail: float = 0.8, damp: float = 0.3) -> PackedFloat32Array:
	var src := pad(b, tail)
	var n := src.size()
	var wetbuf := PackedFloat32Array()
	wetbuf.resize(n)
	wetbuf.fill(0.0)
	for dly in [1116, 1188, 1277, 1356]:
		var line := PackedFloat32Array()
		line.resize(dly)
		line.fill(0.0)
		var filt := 0.0
		var idx := 0
		for i in n:
			var y := line[idx]
			filt = y * (1.0 - damp) + filt * damp
			line[idx] = src[i] + filt * room
			idx = (idx + 1) % dly
			wetbuf[i] += y * 0.25
	for dly in [556, 441]:
		var line := PackedFloat32Array()
		line.resize(dly)
		line.fill(0.0)
		var idx := 0
		for i in n:
			var bufv := line[idx]
			var y := -wetbuf[i] + bufv
			line[idx] = wetbuf[i] + bufv * 0.5
			idx = (idx + 1) % dly
			wetbuf[i] = y
	for i in n:
		src[i] = src[i] * (1.0 - wet * 0.5) + wetbuf[i] * wet
	return src


# --- Montagem -----------------------------------------------------------------

func pad(b: PackedFloat32Array, extra: float) -> PackedFloat32Array:
	var out := b.duplicate()
	var old := out.size()
	out.resize(old + samples(extra))
	for i in range(old, out.size()):
		out[i] = 0.0
	return out


## Soma src em dst a partir de offset (amostras), estendendo dst se preciso.
func mix(dst: PackedFloat32Array, src: PackedFloat32Array, offset: int, gain: float = 1.0) -> void:
	if offset + src.size() > dst.size():
		var old := dst.size()
		dst.resize(offset + src.size())
		for i in range(old, dst.size()):
			dst[i] = 0.0
	for i in src.size():
		dst[offset + i] += src[i] * gain


func at(sec: float) -> int:
	return int(sec * RATE)


func scale(b: PackedFloat32Array, g: float) -> PackedFloat32Array:
	for i in b.size():
		b[i] *= g
	return b


func peak(b: PackedFloat32Array) -> float:
	var p := 0.0
	for v in b:
		p = maxf(p, absf(v))
	return p


func rms(b: PackedFloat32Array) -> float:
	var s := 0.0
	for v in b:
		s += v * v
	return sqrt(s / maxf(b.size(), 1))


func normalize(b: PackedFloat32Array, target_peak: float = 0.89) -> PackedFloat32Array:
	var p := peak(b)
	if p > 0.000001:
		scale(b, target_peak / p)
	return b


## Normaliza pela energia média (camadas contínuas), limitando o pico.
func normalize_rms(b: PackedFloat32Array, target_rms: float, max_peak: float = 0.89) -> PackedFloat32Array:
	var r := rms(b)
	if r > 0.000001:
		scale(b, target_rms / r)
	var p := peak(b)
	if p > max_peak:
		scale(b, max_peak / p)
	return b


## Rampas curtas nas pontas para não estalar.
func fade(b: PackedFloat32Array, in_ms: float = 1.0, out_ms: float = 8.0) -> PackedFloat32Array:
	var ni := maxi(int(in_ms * RATE / 1000.0), 1)
	var no := maxi(int(out_ms * RATE / 1000.0), 1)
	var n := b.size()
	for i in mini(ni, n):
		b[i] *= float(i) / ni
	for i in mini(no, n):
		b[n - 1 - i] *= float(i) / no
	return b


## Remove silêncio do fim (abaixo de -66 dB) deixando uma pequena margem.
func trim_tail(b: PackedFloat32Array) -> PackedFloat32Array:
	var lim := peak(b) * 0.0005
	var last := b.size() - 1
	while last > 0 and absf(b[last]) < lim:
		last -= 1
	b.resize(mini(b.size(), last + samples(0.01)))
	return b


## Torna o buffer um laço contínuo: o fim é misturado ao começo.
func loopify(b: PackedFloat32Array, xfade: float) -> PackedFloat32Array:
	var nx := samples(xfade)
	var n := b.size() - nx
	var out := PackedFloat32Array()
	out.resize(n)
	for i in n:
		out[i] = b[i]
	for i in nx:
		var t := float(i) / nx
		out[i] = b[i] * sqrt(t) + b[n + i] * sqrt(1.0 - t)
	return out


func save(b: PackedFloat32Array, path: String) -> Error:
	var data := PackedByteArray()
	data.resize(b.size() * 2)
	for i in b.size():
		data.encode_s16(i * 2, int(clampf(b[i], -1.0, 1.0) * 32767.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = RATE
	wav.stereo = false
	wav.data = data
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	return wav.save_to_wav(path)
