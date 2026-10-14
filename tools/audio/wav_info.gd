extends RefCounted
## Leitura mínima de WAV PCM 16 bits (o formato gerado por generate_sfx.gd e
## o recomendado para gravações): duração, pico, RMS, saturação e DC.
## Usado pelo auditor de áudio e pelos testes.


static func read(path: String) -> Dictionary:
	var out := {"ok": false, "error": "", "seconds": 0.0, "peak_db": -120.0, "rms_db": -120.0, "clipped": 0, "dc": 0.0, "rate": 0, "channels": 0}
	var bytes := FileAccess.get_file_as_bytes(path)
	if bytes.size() < 44 or bytes.slice(0, 4).get_string_from_ascii() != "RIFF" or bytes.slice(8, 12).get_string_from_ascii() != "WAVE":
		out.error = "não é um WAV RIFF"
		return out
	var pos := 12
	var bits := 0
	var data_start := -1
	var data_len := 0
	while pos + 8 <= bytes.size():
		var id := bytes.slice(pos, pos + 4).get_string_from_ascii()
		var size := bytes.decode_u32(pos + 4)
		if id == "fmt ":
			out.channels = bytes.decode_u16(pos + 10)
			out.rate = bytes.decode_u32(pos + 12)
			bits = bytes.decode_u16(pos + 22)
		elif id == "data":
			data_start = pos + 8
			data_len = mini(size, bytes.size() - data_start)
			break
		pos += 8 + size + (size % 2)
	if bits != 16 or data_start < 0 or int(out.rate) <= 0:
		out.error = "esperado PCM 16 bits (bits=%d)" % bits
		return out
	var n := data_len / 2
	var peak := 0.0
	var sum := 0.0
	var sq := 0.0
	var clipped := 0
	for i in n:
		var v := bytes.decode_s16(data_start + i * 2) / 32768.0
		var a := absf(v)
		peak = maxf(peak, a)
		if a >= 0.999:
			clipped += 1
		sum += v
		sq += v * v
	out.ok = true
	out.seconds = float(n) / maxi(int(out.channels), 1) / int(out.rate)
	out.peak_db = linear_to_db(maxf(peak, 0.000001))
	out.rms_db = linear_to_db(maxf(sqrt(sq / maxf(n, 1)), 0.000001))
	out.clipped = clipped
	out.dc = sum / maxf(n, 1)
	return out
