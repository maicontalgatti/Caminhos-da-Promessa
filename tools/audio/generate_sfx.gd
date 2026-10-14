extends SceneTree
## Gera os efeitos sonoros procedurais de assets/audio (WAV 16 bits, 44,1 kHz,
## mono). Determinístico: o mesmo código gera os mesmos arquivos.
##   godot --headless --path . --script res://tools/audio/generate_sfx.gd
##   godot --headless --path . --script res://tools/audio/generate_sfx.gd -- ui_click footstep_stone
## Depois rode `godot --headless --path . --import` para o Godot importar.
## Gravações reais podem substituir qualquer arquivo mantendo o nome (ver docs/audio.md).

const Synth := preload("res://tools/audio/synth.gd")
const OUT := "res://assets/audio"

var s: Synth

## [pasta, id, variações, receita, laço?]
var recipes: Array = [
	# Passos
	["footsteps/dirt", "footstep_dirt", 5, _footstep_dirt, false],
	["footsteps/grass", "footstep_grass", 5, _footstep_grass, false],
	["footsteps/stone", "footstep_stone", 5, _footstep_stone, false],
	["footsteps/sand", "footstep_sand", 4, _footstep_sand, false],
	["footsteps/wood", "footstep_wood", 4, _footstep_wood, false],
	["footsteps/water", "footstep_water", 4, _footstep_water, false],
	# Interface
	["ui", "ui_click", 3, _ui_click, false],
	["ui", "ui_hover", 2, _ui_hover, false],
	["ui", "ui_focus", 2, _ui_focus, false],
	["ui", "ui_confirm", 1, _ui_confirm, false],
	["ui", "ui_cancel", 1, _ui_cancel, false],
	["ui", "ui_denied", 1, _ui_denied, false],
	["ui", "menu_open", 1, _menu_open, false],
	["ui", "menu_close", 1, _menu_close, false],
	["ui", "journal_open", 1, _journal_open, false],
	["ui", "journal_close", 1, _journal_close, false],
	["ui", "page_turn", 3, _page_turn, false],
	["ui", "map_open", 1, _map_open, false],
	["ui", "map_close", 1, _map_close, false],
	["ui", "save", 1, _save, false],
	# Diálogos
	["dialogue", "dialogue_open", 2, _dialogue_open, false],
	["dialogue", "dialogue_advance", 3, _dialogue_advance, false],
	["dialogue", "dialogue_choice", 1, _dialogue_choice, false],
	["dialogue", "dialogue_close", 1, _dialogue_close, false],
	["dialogue", "decision", 1, _decision, false],
	["dialogue", "text_blip", 3, _text_blip, false],
	# Interações por material
	["interactions", "interact_wood", 2, _interact_wood, false],
	["interactions", "interact_stone", 2, _interact_stone, false],
	["interactions", "interact_ceramic", 2, _interact_ceramic, false],
	["interactions", "interact_metal", 1, _interact_metal, false],
	["interactions", "interact_cloth", 2, _interact_cloth, false],
	["interactions", "interact_parchment", 2, _interact_parchment, false],
	["interactions", "interact_water_well", 1, _interact_water_well, false],
	["interactions", "interact_water_cistern", 1, _interact_water_cistern, false],
	["interactions", "interact_door", 1, _interact_door, false],
	["interactions", "interact_dirt", 2, _interact_dirt, false],
	["interactions", "interact_fire", 1, _interact_fire, false],
	["interactions", "interact_generic", 2, _interact_generic, false],
	# Bolsa e coleta
	["inventory", "bag_open", 1, _bag_open, false],
	["inventory", "bag_close", 1, _bag_close, false],
	["inventory", "item_pickup", 2, _item_pickup, false],
	["inventory", "item_wood", 2, _item_wood, false],
	["inventory", "item_fiber", 2, _item_fiber, false],
	["inventory", "item_water", 1, _item_water, false],
	["inventory", "item_food", 1, _item_food, false],
	["inventory", "item_cloth", 1, _item_cloth, false],
	["inventory", "item_rope", 1, _item_rope, false],
	["inventory", "item_give", 1, _item_give, false],
	["inventory", "item_receive", 1, _item_receive, false],
	["inventory", "item_discard", 1, _item_discard, false],
	["inventory", "reward", 1, _reward, false],
	["inventory", "collectible", 1, _collectible, false],
	["inventory", "collection_complete", 1, _collection_complete, false],
	# Missões e descobertas
	["quests", "quest_start", 1, _quest_start, false],
	["quests", "objective_update", 1, _objective_update, false],
	["quests", "objective_complete", 1, _objective_complete, false],
	["quests", "quest_complete", 1, _quest_complete, false],
	["quests", "region_new", 1, _region_new, false],
	["quests", "travel", 1, _travel, false],
	["discoveries", "discovery", 1, _discovery, false],
	# Ambiente
	["ambience/canaan", "amb_wind_canaan", 1, _amb_wind_canaan, true],
	["ambience/caravan_road", "amb_wind_road", 1, _amb_wind_road, true],
	["ambience/dothan", "amb_wind_dothan", 1, _amb_wind_dothan, true],
	["ambience/common", "amb_bird", 6, _amb_bird, false],
	["ambience/common", "amb_sheep", 4, _amb_sheep, false],
	["ambience/common", "amb_goat", 2, _amb_goat, false],
	["ambience/canaan", "amb_village_grind", 2, _amb_village_grind, false],
	["ambience/canaan", "amb_village_knock", 2, _amb_village_knock, false],
	["ambience/canaan", "amb_water_well", 1, _amb_water_well, true],
	["ambience/caravan_road", "amb_hooves", 2, _amb_hooves, false],
	["ambience/caravan_road", "amb_bells", 2, _amb_bells, false],
	["ambience/caravan_road", "amb_cargo_creak", 2, _amb_cargo_creak, false],
	["ambience/dothan", "amb_insects", 2, _amb_insects, false],
	["ambience/dothan", "amb_water_cistern", 1, _amb_water_cistern, true],
]


func _init() -> void:
	var only := OS.get_cmdline_user_args()
	var count := 0
	for r in recipes:
		if not only.is_empty() and not (String(r[1]) in only):
			continue
		for v in int(r[2]):
			s = Synth.new(hash(String(r[1])) + v * 7919)
			var b: PackedFloat32Array = (r[3] as Callable).call(v)
			if not bool(r[4]):
				s.biquad(b, "hp", 30.0)
				s.trim_tail(b)
				s.fade(b, 0.5, 6.0)
				s.normalize(b, 0.89)
			var path := "%s/%s/%s_%d.wav" % [OUT, r[0], r[1], v + 1]
			var err := s.save(b, path)
			if err != OK:
				printerr("falhou: %s (%s)" % [path, error_string(err)])
				quit(1)
				return
			count += 1
			print("  %s  %.2fs" % [path, b.size() / float(Synth.RATE)])
	print("== %d arquivo(s) gerado(s) ==" % count)
	quit(0)


# --- Peças reutilizáveis ------------------------------------------------------

func j(x: float, amount: float = 0.12) -> float:
	return x * s.rng.randf_range(1.0 - amount, 1.0 + amount)


func thump(sec: float, lp: float, decay: float) -> PackedFloat32Array:
	var b := s.brown(sec)
	s.biquad(b, "lp", lp)
	s.biquad(b, "hp", 35.0)
	return s.env(b, 0.002, decay)


func click(hp: float, decay: float) -> PackedFloat32Array:
	var b := s.white(decay * 8.0 + 0.01)
	s.biquad(b, "hp", hp)
	return s.env(b, 0.0003, decay)


func tick(freq: float, decay: float) -> PackedFloat32Array:
	return s.env(s.sine(decay * 7.0, freq), 0.0008, decay)


## Papel, palha e pano: ruído granulado com contorno lento.
func rustle(sec: float, density: float, center: float, attack: float, release: float, grain: float = 0.004) -> PackedFloat32Array:
	var b := s.white(sec)
	s.grains(b, density, grain)
	s.wobble(b, 7.0, 0.6)
	s.biquad(b, "bp", center, 0.6)
	s.biquad(b, "hp", 700.0)
	return s.env_ar(b, attack, release)


func swish(sec: float, f_from: float, f_peak: float, f_to: float) -> PackedFloat32Array:
	var b := s.white(sec)
	s.sweep_lp(b, func(t): return lerpf(f_from, f_peak, t / 0.4) if t < 0.4 else lerpf(f_peak, f_to, (t - 0.4) / 0.6), 1.2, true)
	return s.env_ar(b, sec * 0.35, sec * 0.6)


## Batida em madeira: transiente + ressonâncias do corpo.
func knock(f1: float, f2: float, decay: float) -> PackedFloat32Array:
	var exc := s.white(0.25)
	s.env(exc, 0.0004, 0.004)
	var b := s.body(exc, [[f1, 6.0, 1.0], [f2, 7.0, 0.6], [f2 * 2.3, 6.0, 0.25]])
	s.mix(b, thump(0.12, 300.0, decay), 0, 0.5)
	s.mix(b, click(2500.0, 0.002), 0, 0.15)
	return b


## Atrito intermitente (couro, corda, porta): pulsos irregulares filtrados.
func creak(sec: float, rate0: float, rate1: float, f1: float, f2: float) -> PackedFloat32Array:
	var b := s.silence(sec)
	var n := b.size()
	var next := 0
	while next < n:
		var t := float(next) / n
		var rate := lerpf(rate0, rate1, t) * s.rng.randf_range(0.7, 1.3)
		b[next] = s.rng.randf_range(0.5, 1.0)
		next += maxi(int(Synth.RATE / rate), 1)
	var out := s.body(b, [[f1, 9.0, 1.0], [f2, 10.0, 0.6], [f1 * 3.1, 8.0, 0.2]])
	return s.env_ar(out, sec * 0.15, sec * 0.3)


func bubbles(count: int, sec: float, f_lo: float, f_hi: float) -> PackedFloat32Array:
	var b := s.silence(sec)
	for i in count:
		var f := s.rng.randf_range(f_lo, f_hi)
		var d := s.rng.randf_range(0.015, 0.04)
		var c := s.env(s.chirp(d * 4.0, f, f * 1.6), 0.001, d)
		s.mix(b, c, s.at(s.rng.randf_range(0.0, sec * 0.7)), s.rng.randf_range(0.4, 1.0))
	return b


## Lira (kinnor simples): corda dedilhada com um pouco de corpo de madeira.
func lyre(freq: float, sec: float, bright: float = 0.45) -> PackedFloat32Array:
	var b := s.pluck(freq, sec, bright, 0.9965)
	var bod := s.body(b, [[260.0, 2.0, 0.5], [520.0, 3.0, 0.25]])
	s.mix(b, bod, 0, 0.6)
	s.biquad(b, "lp", 5200.0)
	return s.env(b, 0.002, sec * 0.35)


## Acorde sustentado de senoides suaves (fundo de assinaturas musicais).
func pad(freqs: Array, sec: float, attack: float) -> PackedFloat32Array:
	var b := s.silence(sec)
	for f in freqs:
		s.mix(b, s.sine(sec, float(f), s.rng.randf() * TAU), 0, 1.0 / freqs.size())
	return s.env_ar(b, attack, sec * 0.7)


func bell(freq: float, sec: float, amp: float = 1.0) -> PackedFloat32Array:
	return s.scale(s.partials(sec, freq, [[1.0, 1.0, sec * 0.3], [2.0, 0.22, sec * 0.15], [3.01, 0.08, sec * 0.08], [4.2, 0.04, sec * 0.05]], 0.004), amp)


# --- Passos ---------------------------------------------------------------------

func _footstep_dirt(_v: int) -> PackedFloat32Array:
	var b := thump(0.2, j(260.0), j(0.028))
	s.mix(b, thump(0.15, j(380.0), j(0.02)), s.at(j(0.035, 0.3)), 0.45)
	var sc := s.white(0.16)
	s.grains(sc, j(450.0), 0.003)
	s.biquad(sc, "bp", j(1700.0), 0.8)
	s.env(sc, 0.008, j(0.05))
	s.mix(b, sc, s.at(0.01), 0.55)
	s.biquad(b, "lp", 6000.0)
	return b


func _footstep_grass(_v: int) -> PackedFloat32Array:
	var b := thump(0.2, j(200.0), j(0.025))
	s.scale(b, 0.7)
	var r := s.white(0.26)
	s.grains(r, j(1100.0), 0.002)
	s.biquad(r, "hp", j(2600.0))
	s.biquad(r, "lp", 8000.0)
	s.env(r, 0.012, j(0.07))
	s.mix(b, r, s.at(0.005), 0.6)
	return b


func _footstep_stone(_v: int) -> PackedFloat32Array:
	var b := thump(0.15, j(520.0), j(0.02))
	s.mix(b, click(j(1800.0), 0.004), 0, 0.7)
	var tap := s.partials(0.08, j(1150.0), [[1.0, 1.0, 0.012], [2.13, 0.5, 0.008], [3.4, 0.25, 0.005]], 0.0005)
	s.mix(b, tap, 0, 0.25)
	var slap := s.white(0.06)
	s.biquad(slap, "bp", j(1050.0), 1.6)
	s.env(slap, 0.0008, 0.01)
	s.mix(b, slap, s.at(j(0.04, 0.25)), 0.45)
	return b


func _footstep_sand(_v: int) -> PackedFloat32Array:
	var b := thump(0.2, 180.0, j(0.03))
	s.scale(b, 0.5)
	var c := s.white(0.3)
	s.grains(c, j(1600.0), 0.0015)
	s.biquad(c, "bp", j(3400.0), 0.7)
	s.env(c, 0.02, j(0.08))
	s.mix(b, c, 0, 0.7)
	return b


func _footstep_wood(_v: int) -> PackedFloat32Array:
	var b := knock(j(170.0), j(410.0), 0.03)
	s.mix(b, thump(0.1, 400.0, 0.015), s.at(0.035), 0.3)
	s.biquad(b, "lp", 5000.0)
	return b


func _footstep_water(_v: int) -> PackedFloat32Array:
	var b := s.white(0.3)
	s.biquad(b, "bp", j(1200.0), 0.6)
	s.env(b, 0.003, j(0.06))
	s.scale(b, 0.7)
	s.mix(b, bubbles(5, 0.25, 500.0, 1400.0), s.at(0.01), 0.35)
	s.mix(b, thump(0.12, 220.0, 0.02), 0, 0.4)
	s.biquad(b, "lp", 4500.0)
	return b


# --- Interface ------------------------------------------------------------------

func _ui_click(v: int) -> PackedFloat32Array:
	var f: float = [1650.0, 1500.0, 1800.0][v]
	var b := click(2600.0, 0.0025)
	s.scale(b, 0.5)
	s.mix(b, tick(f, 0.012), 0, 0.4)
	s.mix(b, tick(f * 0.5, 0.018), 0, 0.25)
	s.biquad(b, "lp", 7000.0)
	return b


func _ui_hover(v: int) -> PackedFloat32Array:
	var b := tick([2300.0, 2500.0][v], 0.008)
	s.mix(b, click(4000.0, 0.001), 0, 0.2)
	return b


func _ui_focus(v: int) -> PackedFloat32Array:
	var b := tick([1500.0, 1600.0][v], 0.012)
	s.mix(b, tick([750.0, 800.0][v], 0.015), 0, 0.3)
	s.mix(b, click(3000.0, 0.0015), 0, 0.2)
	return b


func _ui_confirm(_v: int) -> PackedFloat32Array:
	var b := lyre(659.3, 0.4, 0.5)
	s.mix(b, lyre(987.8, 0.5, 0.5), s.at(0.07), 0.8)
	return s.reverb(b, 0.15, 0.7, 0.3)


func _ui_cancel(_v: int) -> PackedFloat32Array:
	var b := lyre(440.0, 0.3, 0.3)
	s.mix(b, lyre(329.6, 0.35, 0.3), s.at(0.06), 0.8)
	s.biquad(b, "lp", 2500.0)
	return b


func _ui_denied(_v: int) -> PackedFloat32Array:
	var b := knock(150.0, 330.0, 0.03)
	s.mix(b, knock(140.0, 310.0, 0.03), s.at(0.11), 0.8)
	s.biquad(b, "lp", 1200.0)
	return b


func _menu_open(_v: int) -> PackedFloat32Array:
	var b := rustle(0.32, 260.0, 3000.0, 0.06, 0.2)
	s.mix(b, knock(300.0, 720.0, 0.02), 0, 0.35)
	return b


func _menu_close(_v: int) -> PackedFloat32Array:
	var b := rustle(0.18, 320.0, 2600.0, 0.01, 0.14)
	s.mix(b, knock(260.0, 640.0, 0.02), s.at(0.12), 0.3)
	return b


func _journal_open(_v: int) -> PackedFloat32Array:
	var b := thump(0.15, 180.0, 0.04)
	s.scale(b, 0.6)
	for off in [0.02, 0.11, 0.21]:
		s.mix(b, rustle(0.22, 380.0, j(3200.0), 0.03, 0.15), s.at(off), 0.6)
	return b


func _journal_close(_v: int) -> PackedFloat32Array:
	var b := rustle(0.18, 300.0, 2800.0, 0.02, 0.12)
	s.scale(b, 0.6)
	s.mix(b, thump(0.18, 220.0, 0.05), s.at(0.13), 1.0)
	s.mix(b, click(1500.0, 0.003), s.at(0.13), 0.2)
	return b


func _page_turn(_v: int) -> PackedFloat32Array:
	var sec := j(0.3, 0.15)
	var b := s.white(sec)
	var f0 := j(1200.0)
	var f1 := j(4200.0)
	s.sweep_lp(b, func(t): return lerpf(f0, f1, t), 1.5, true)
	s.env_ar(b, sec * 0.3, sec * 0.55)
	var cr := rustle(sec, 300.0, 3500.0, 0.02, sec * 0.5, 0.003)
	s.mix(b, cr, 0, 0.7)
	return b


func _map_open(_v: int) -> PackedFloat32Array:
	var b := s.white(0.62)
	s.sweep_lp(b, func(t): return lerpf(1400.0, 3600.0, t), 1.3, true)
	s.env_ar(b, 0.2, 0.25)
	s.mix(b, rustle(0.6, 500.0, 3000.0, 0.1, 0.25, 0.003), 0, 0.8)
	s.mix(b, thump(0.15, 160.0, 0.05), s.at(0.48), 0.5)
	return b


func _map_close(_v: int) -> PackedFloat32Array:
	var b := s.white(0.36)
	s.sweep_lp(b, func(t): return lerpf(3600.0, 1400.0, t), 1.3, true)
	s.env_ar(b, 0.05, 0.2)
	s.mix(b, rustle(0.34, 450.0, 2800.0, 0.03, 0.2, 0.003), 0, 0.7)
	s.mix(b, knock(280.0, 680.0, 0.015), s.at(0.3), 0.25)
	return b


func _save(_v: int) -> PackedFloat32Array:
	var b := s.scale(s.env(s.sine(1.0, 392.0), 0.012, 0.18), 0.5)
	s.mix(b, s.env(s.sine(0.9, 587.3), 0.012, 0.16), s.at(0.12), 0.45)
	s.mix(b, lyre(783.99, 0.5, 0.35), s.at(0.12), 0.3)
	return s.reverb(b, 0.25, 0.8, 0.5)


# --- Diálogos -------------------------------------------------------------------

func _dialogue_open(v: int) -> PackedFloat32Array:
	var b := s.scale(s.env(s.sine(0.2, [520.0, 470.0][v]), 0.001, 0.035), 0.5)
	s.mix(b, knock(380.0, 900.0, 0.015), 0, 0.4)
	s.mix(b, swish(0.14, 600.0, 1600.0, 700.0), 0, 0.25)
	return b


func _dialogue_advance(v: int) -> PackedFloat32Array:
	var b := click(3200.0, 0.0015)
	s.scale(b, 0.5)
	s.mix(b, tick([1150.0, 1250.0, 1080.0][v], 0.008), 0, 0.5)
	s.biquad(b, "lp", 6500.0)
	return b


func _dialogue_choice(_v: int) -> PackedFloat32Array:
	var b := lyre(587.3, 0.35, 0.5)
	s.mix(b, click(3000.0, 0.0015), 0, 0.2)
	return b


func _dialogue_close(_v: int) -> PackedFloat32Array:
	var b := s.scale(s.env(s.sine(0.2, 392.0), 0.001, 0.045), 0.5)
	s.mix(b, knock(300.0, 720.0, 0.015), 0, 0.35)
	s.mix(b, swish(0.16, 1400.0, 1000.0, 500.0), 0, 0.2)
	return b


func _decision(_v: int) -> PackedFloat32Array:
	var b := lyre(440.0, 0.9, 0.35)
	s.mix(b, lyre(659.3, 1.0, 0.35), s.at(0.14), 0.85)
	s.mix(b, pad([220.0, 329.6], 1.0, 0.25), 0, 0.15)
	return s.reverb(b, 0.35, 0.84, 0.8)


func _text_blip(v: int) -> PackedFloat32Array:
	return tick([820.0, 880.0, 940.0][v], 0.01)


# --- Interações -----------------------------------------------------------------

func _interact_wood(_v: int) -> PackedFloat32Array:
	var b := knock(j(260.0), j(610.0), 0.03)
	s.mix(b, knock(j(250.0), j(590.0), 0.03), s.at(j(0.13)), 0.75)
	return b


func _interact_stone(_v: int) -> PackedFloat32Array:
	var b := click(2500.0, 0.004)
	s.mix(b, s.partials(0.1, j(1900.0), [[1.0, 1.0, 0.018], [1.63, 0.6, 0.012], [2.47, 0.3, 0.008]], 0.0005), 0, 0.4)
	s.mix(b, thump(0.1, 600.0, 0.015), 0, 0.5)
	var sc := s.white(0.3)
	s.grains(sc, 650.0, 0.003)
	s.biquad(sc, "bp", j(1500.0), 0.9)
	s.env_ar(sc, 0.03, 0.15)
	s.mix(b, sc, s.at(0.07), 0.45)
	return b


func _interact_ceramic(_v: int) -> PackedFloat32Array:
	var f := j(1050.0, 0.08)
	var parts := [[1.0, 1.0, 0.11], [2.32, 0.55, 0.07], [4.25, 0.3, 0.045], [6.63, 0.15, 0.03]]
	var b := s.partials(0.5, f, parts, 0.0005)
	s.mix(b, click(2000.0, 0.002), 0, 0.3)
	s.mix(b, s.partials(0.4, f * 1.06, parts, 0.0005), s.at(0.15), 0.55)
	s.mix(b, click(2000.0, 0.002), s.at(0.15), 0.2)
	s.biquad(b, "lp", 6000.0)
	return s.reverb(b, 0.1, 0.7, 0.25)


func _interact_metal(_v: int) -> PackedFloat32Array:
	var b := s.partials(1.2, 1320.0, [[1.0, 1.0, 0.35], [2.76, 0.5, 0.2], [5.4, 0.25, 0.12], [8.93, 0.1, 0.07]], 0.0005)
	s.mix(b, click(3000.0, 0.002), 0, 0.3)
	return b


func _interact_cloth(_v: int) -> PackedFloat32Array:
	var b := swish(j(0.42), 500.0, j(1800.0), 700.0)
	var g := s.white(0.42)
	s.grains(g, 250.0, 0.006)
	s.biquad(g, "bp", 1400.0, 0.7)
	s.env_ar(g, 0.12, 0.2)
	s.mix(b, g, 0, 0.35)
	return b


func _interact_parchment(_v: int) -> PackedFloat32Array:
	var b := rustle(j(0.4), 420.0, j(3000.0), 0.08, 0.2)
	s.mix(b, rustle(0.25, 300.0, 4000.0, 0.03, 0.15, 0.002), s.at(0.18), 0.6)
	return b


func _water_splash(echo_delay: float, fb: float, low: float) -> PackedFloat32Array:
	var b := s.white(0.4)
	s.biquad(b, "bp", low * 2.2, 0.7)
	s.env(b, 0.003, 0.07)
	s.mix(b, bubbles(9, 0.4, low, low * 2.5), s.at(0.02), 0.6)
	s.mix(b, thump(0.15, 180.0, 0.03), 0, 0.3)
	s.biquad(b, "lp", 4000.0)
	return s.echo(b, echo_delay, fb, 0.9, 1800.0)


func _interact_water_well(_v: int) -> PackedFloat32Array:
	return _water_splash(0.13, 0.45, 320.0)


func _interact_water_cistern(_v: int) -> PackedFloat32Array:
	return s.reverb(_water_splash(0.09, 0.5, 260.0), 0.3, 0.86, 0.9, 0.4)


func _interact_door(_v: int) -> PackedFloat32Array:
	var b := creak(0.55, 22.0, 60.0, 820.0, 1650.0)
	s.mix(b, knock(150.0, 360.0, 0.04), s.at(0.5), 0.6)
	s.biquad(b, "lp", 4000.0)
	return b


func _interact_dirt(_v: int) -> PackedFloat32Array:
	var b := s.white(0.42)
	s.grains(b, j(800.0), 0.002)
	s.biquad(b, "bp", j(2500.0), 0.7)
	s.env_ar(b, 0.05, 0.25)
	s.mix(b, thump(0.12, 200.0, 0.02), 0, 0.3)
	return b


func _interact_fire(_v: int) -> PackedFloat32Array:
	var b := s.white(0.6)
	s.grains(b, 28.0, 0.0015)
	s.biquad(b, "hp", 1800.0)
	var hiss := s.white(0.6)
	s.biquad(hiss, "bp", 3000.0, 0.5)
	s.env_ar(hiss, 0.1, 0.3)
	s.mix(b, hiss, 0, 0.08)
	var ash := rustle(0.35, 300.0, 1600.0, 0.05, 0.2, 0.005)
	s.mix(b, ash, 0, 0.5)
	return b


func _interact_generic(_v: int) -> PackedFloat32Array:
	var b := swish(j(0.22), 600.0, j(1500.0), 700.0)
	s.scale(b, 0.5)
	s.mix(b, knock(j(340.0), j(800.0), 0.015), s.at(0.03), 0.4)
	return b


# --- Bolsa e coleta -------------------------------------------------------------

func _bag_open(_v: int) -> PackedFloat32Array:
	var b := creak(0.3, 35.0, 70.0, 650.0, 1350.0)
	s.scale(b, 0.6)
	s.mix(b, swish(0.3, 600.0, 1400.0, 700.0), s.at(0.05), 0.5)
	s.mix(b, thump(0.12, 200.0, 0.025), 0, 0.3)
	return b


func _bag_close(_v: int) -> PackedFloat32Array:
	var b := swish(0.2, 1200.0, 900.0, 400.0)
	s.scale(b, 0.6)
	s.mix(b, thump(0.15, 200.0, 0.035), s.at(0.12), 0.7)
	s.mix(b, creak(0.12, 40.0, 50.0, 700.0, 1400.0), s.at(0.02), 0.25)
	return b


func _item_pickup(_v: int) -> PackedFloat32Array:
	var b := swish(0.2, 600.0, j(1500.0), 800.0)
	s.scale(b, 0.5)
	s.mix(b, lyre(j(784.0, 0.03), 0.3, 0.4), s.at(0.03), 0.5)
	return b


func _item_wood(_v: int) -> PackedFloat32Array:
	var b := click(1500.0, 0.003)
	s.mix(b, s.body(s.env(s.white(0.1), 0.0003, 0.003), [[j(1200.0), 9.0, 1.0], [j(2100.0), 9.0, 0.6]]), 0, 1.0)
	var second := click(1500.0, 0.003)
	s.mix(second, s.body(s.env(s.white(0.1), 0.0003, 0.003), [[j(1050.0), 9.0, 1.0], [j(1900.0), 9.0, 0.6]]), 0, 1.0)
	s.mix(b, second, s.at(j(0.07)), 0.8)
	return b


func _item_fiber(_v: int) -> PackedFloat32Array:
	var b := s.white(0.28)
	s.grains(b, j(1000.0), 0.002)
	s.biquad(b, "hp", 2500.0)
	s.env_ar(b, 0.015, 0.18)
	return b


func _item_water(_v: int) -> PackedFloat32Array:
	var b := s.brown(0.55)
	s.biquad(b, "lp", 650.0)
	s.biquad(b, "hp", 120.0)
	s.wobble(b, 4.0, 0.9)
	s.env_ar(b, 0.05, 0.3)
	s.mix(b, bubbles(6, 0.5, 300.0, 800.0), s.at(0.05), 0.4)
	return b


func _item_food(_v: int) -> PackedFloat32Array:
	var b := swish(0.22, 700.0, 1300.0, 600.0)
	s.scale(b, 0.5)
	s.mix(b, thump(0.12, 250.0, 0.025), s.at(0.08), 0.6)
	return b


func _item_cloth(_v: int) -> PackedFloat32Array:
	return _interact_cloth(0)


func _item_rope(_v: int) -> PackedFloat32Array:
	var b := s.silence(0.45)
	for off in [0.0, 0.2]:
		var g := s.white(0.2)
		s.grains(g, 320.0, 0.004)
		s.biquad(g, "bp", j(800.0), 2.0)
		s.env_ar(g, 0.05, 0.1)
		s.mix(b, g, s.at(off), 1.0)
	return b


func _item_give(_v: int) -> PackedFloat32Array:
	var b := swish(0.25, 700.0, 1400.0, 600.0)
	s.scale(b, 0.5)
	s.mix(b, thump(0.12, 220.0, 0.03), s.at(0.1), 0.5)
	s.mix(b, lyre(523.3, 0.4, 0.4), s.at(0.12), 0.45)
	s.mix(b, lyre(784.0, 0.45, 0.4), s.at(0.2), 0.4)
	return b


func _item_receive(_v: int) -> PackedFloat32Array:
	var b := swish(0.25, 600.0, 1500.0, 700.0)
	s.scale(b, 0.5)
	s.mix(b, lyre(659.3, 0.4, 0.45), s.at(0.05), 0.45)
	s.mix(b, lyre(987.8, 0.45, 0.45), s.at(0.13), 0.4)
	return b


func _item_discard(_v: int) -> PackedFloat32Array:
	var b := thump(0.2, 250.0, 0.05)
	var g := s.white(0.2)
	s.grains(g, 500.0, 0.002)
	s.biquad(g, "bp", 2000.0, 0.8)
	s.env(g, 0.005, 0.05)
	s.mix(b, g, s.at(0.01), 0.4)
	return b


func _reward(_v: int) -> PackedFloat32Array:
	var b := s.silence(0.1)
	for i in 3:
		s.mix(b, lyre([523.3, 659.3, 784.0][i], 0.7, 0.45), s.at(i * 0.06), 0.6)
	return s.reverb(b, 0.25, 0.8, 0.5)


func _collectible(_v: int) -> PackedFloat32Array:
	var b := s.silence(0.1)
	for i in 3:
		s.mix(b, lyre([1046.5, 1318.5, 1568.0][i], 0.6, 0.65), s.at(i * 0.07), 0.5)
	var shimmer := s.sine(0.7, 3136.0)
	s.wobble(shimmer, 9.0, 0.8)
	s.env_ar(shimmer, 0.15, 0.4)
	s.mix(b, shimmer, s.at(0.1), 0.06)
	return s.reverb(b, 0.3, 0.82, 0.6)


func _collection_complete(_v: int) -> PackedFloat32Array:
	var b := s.silence(0.1)
	var notes := [784.0, 987.8, 1174.7, 1568.0]
	for i in notes.size():
		s.mix(b, lyre(notes[i], 0.8, 0.55), s.at(i * 0.09), 0.5)
	s.mix(b, pad([392.0, 587.3, 784.0], 1.4, 0.3), s.at(0.3), 0.18)
	return s.reverb(b, 0.35, 0.84, 0.8)


# --- Missões e descobertas ------------------------------------------------------

func _quest_start(_v: int) -> PackedFloat32Array:
	var b := lyre(293.7, 1.0, 0.4)
	s.mix(b, lyre(440.0, 1.1, 0.4), s.at(0.16), 0.9)
	s.mix(b, pad([293.7, 440.0], 1.3, 0.25), 0, 0.2)
	return s.reverb(b, 0.35, 0.84, 0.8)


func _objective_update(_v: int) -> PackedFloat32Array:
	return s.reverb(lyre(587.3, 0.5, 0.3), 0.2, 0.75, 0.4)


func _objective_complete(_v: int) -> PackedFloat32Array:
	var b := s.silence(0.1)
	for i in 3:
		s.mix(b, lyre([440.0, 554.4, 659.3][i], 0.8, 0.45), s.at(i * 0.09), 0.65)
	return s.reverb(b, 0.3, 0.82, 0.6)


func _quest_complete(_v: int) -> PackedFloat32Array:
	var b := s.silence(0.1)
	var notes := [293.7, 370.0, 440.0, 587.3]
	for i in notes.size():
		s.mix(b, lyre(notes[i], 1.2, 0.45), s.at(i * 0.14), 0.6)
	s.mix(b, lyre(440.0, 1.6, 0.4), s.at(0.72), 0.5)
	s.mix(b, lyre(587.3, 1.6, 0.4), s.at(0.72), 0.5)
	s.mix(b, pad([146.8, 220.0, 293.7], 2.2, 0.4), s.at(0.1), 0.3)
	return s.reverb(b, 0.4, 0.86, 1.2)


func _region_new(_v: int) -> PackedFloat32Array:
	var w := s.pink(1.8)
	s.sweep_lp(w, func(t): return 300.0 + 900.0 * sin(PI * t), 0.8)
	s.env_ar(w, 0.6, 0.9)
	s.scale(w, 0.6)
	s.mix(w, lyre(220.0, 1.2, 0.35), s.at(0.35), 0.6)
	s.mix(w, lyre(329.6, 1.2, 0.35), s.at(0.55), 0.5)
	return s.reverb(w, 0.35, 0.84, 0.9)


func _travel(_v: int) -> PackedFloat32Array:
	var w := s.pink(0.9)
	s.sweep_lp(w, func(t): return 300.0 + 1100.0 * sin(PI * t), 0.8)
	return s.env_ar(w, 0.35, 0.45)


func _discovery(_v: int) -> PackedFloat32Array:
	var b := bell(880.0, 2.0, 0.8)
	s.mix(b, bell(1318.5, 1.8, 0.45), s.at(0.22), 1.0)
	var hum := s.sine(1.8, 220.0)
	s.env_ar(hum, 0.3, 1.2)
	s.mix(b, hum, 0, 0.12)
	return s.reverb(b, 0.45, 0.87, 1.4, 0.35)


# --- Ambiente: camadas contínuas ------------------------------------------------

func _wind(sec: float, base: float, swing: float, gust_rate: float, rms_target: float, whistle: float) -> PackedFloat32Array:
	var b := s.pink(sec)
	var p1 := s.rng.randf() * TAU
	var p2 := s.rng.randf() * TAU
	var total := sec
	var cutoff := func(t: float) -> float:
		var x := t * total
		return base + swing * (0.5 + 0.35 * sin(TAU * 0.07 * x + p1) + 0.15 * sin(TAU * gust_rate * x + p2))
	s.sweep_lp(b, cutoff, 0.7)
	for i in b.size():
		var x := float(i) / Synth.RATE
		b[i] *= 0.65 + 0.25 * sin(TAU * 0.05 * x + p2) + 0.1 * sin(TAU * gust_rate * 1.3 * x + p1)
	s.biquad(b, "hp", 70.0)
	if whistle > 0.0:
		var wh := s.white(sec)
		s.biquad(wh, "bp", 1800.0, 9.0)
		s.wobble(wh, 0.12, 0.9)
		s.mix(b, wh, 0, whistle)
	b = s.loopify(b, 2.0)
	return s.normalize_rms(b, rms_target, 0.6)


func _amb_wind_canaan(_v: int) -> PackedFloat32Array:
	return _wind(18.0, 320.0, 420.0, 0.23, 0.12, 0.0)


func _amb_wind_road(_v: int) -> PackedFloat32Array:
	return _wind(18.0, 420.0, 900.0, 0.31, 0.14, 0.06)


func _amb_wind_dothan(_v: int) -> PackedFloat32Array:
	return _wind(18.0, 280.0, 320.0, 0.17, 0.11, 0.0)


func _water_loop(sec: float, drip_rate: float, f_lo: float, f_hi: float, echo_delay: float, fb: float) -> PackedFloat32Array:
	var b := s.silence(sec)
	var t := 0.0
	while t < sec - 0.3:
		t += s.rng.randf_range(0.3, 2.0 / drip_rate)
		var f := s.rng.randf_range(f_lo, f_hi)
		var d := s.rng.randf_range(0.02, 0.04)
		s.mix(b, s.env(s.chirp(d * 4.0, f, f * 1.8), 0.001, d), s.at(t), s.rng.randf_range(0.3, 1.0))
	var lap := s.brown(sec)
	s.biquad(lap, "bp", 380.0, 0.8)
	s.wobble(lap, 0.4, 0.8)
	s.mix(b, lap, 0, 0.12)
	b = s.echo(b, echo_delay, fb, 0.0)
	b = s.loopify(s.pad(b, 1.0), 1.0)
	return s.normalize_rms(b, 0.08, 0.6)


func _amb_water_well(_v: int) -> PackedFloat32Array:
	return _water_loop(8.0, 1.6, 900.0, 1700.0, 0.09, 0.45)


func _amb_water_cistern(_v: int) -> PackedFloat32Array:
	return _water_loop(9.0, 1.1, 700.0, 1300.0, 0.12, 0.55)


# --- Ambiente: eventos ocasionais -----------------------------------------------

func _amb_bird(_v: int) -> PackedFloat32Array:
	var b := s.silence(0.1)
	var t := 0.0
	var count := s.rng.randi_range(2, 6)
	var base := s.rng.randf_range(2600.0, 4200.0)
	var up := s.rng.randf() < 0.5
	for i in count:
		var d := s.rng.randf_range(0.04, 0.12)
		var f0 := base * s.rng.randf_range(0.9, 1.1)
		var f1 := f0 * (s.rng.randf_range(1.2, 1.6) if up else s.rng.randf_range(0.6, 0.8))
		var c := s.chirp(d, f0, f1, s.rng.randf_range(20.0, 40.0), s.rng.randf_range(60.0, 200.0))
		for k in c.size():
			c[k] *= sin(PI * float(k) / c.size())
		s.mix(b, c, s.at(t), 1.0)
		t += d + s.rng.randf_range(0.03, 0.12)
	s.biquad(b, "hp", 1500.0)
	s.biquad(b, "lp", 7000.0)
	return s.reverb(b, 0.2, 0.75, 0.4)


## Balido: série harmônica com vibrato e tremor ("bé-é-é") passada por formantes.
func _bleat(f0: float, tremolo: float, sec: float) -> PackedFloat32Array:
	var b := s.silence(sec)
	var n := b.size()
	var ph := 0.0
	var vib_ph := s.rng.randf() * TAU
	for i in n:
		var t := float(i) / Synth.RATE
		var u := float(i) / n
		var f := f0 * (1.0 + 0.04 * sin(TAU * 6.5 * t + vib_ph)) * lerpf(1.0, 0.93, u)
		ph += TAU * f / Synth.RATE
		var v := 0.0
		for k in range(1, 18):
			if f * k > 6000.0:
				break
			v += sin(ph * k) / k
		var trem := 0.55 + 0.45 * absf(sin(PI * tremolo * t))
		b[i] = v * trem
	var out := s.body(b, [[750.0, 4.0, 1.0], [1150.0, 5.0, 0.6], [2500.0, 6.0, 0.25]])
	s.env_ar(out, 0.06, 0.25)
	s.biquad(out, "lp", 3200.0)
	return s.reverb(out, 0.25, 0.78, 0.5)


func _amb_sheep(_v: int) -> PackedFloat32Array:
	return _bleat(s.rng.randf_range(190.0, 260.0), s.rng.randf_range(6.0, 8.5), s.rng.randf_range(0.55, 0.9))


func _amb_goat(_v: int) -> PackedFloat32Array:
	return _bleat(s.rng.randf_range(320.0, 400.0), s.rng.randf_range(10.0, 12.0), s.rng.randf_range(0.45, 0.7))


func _amb_village_grind(_v: int) -> PackedFloat32Array:
	var b := s.silence(0.1)
	for i in 3:
		var g := s.white(0.55)
		s.grains(g, 1200.0, 0.003)
		s.biquad(g, "bp", s.rng.randf_range(550.0, 700.0), 1.0)
		var r := s.brown(0.55)
		s.biquad(r, "lp", 150.0)
		s.mix(g, r, 0, 0.4)
		s.env_ar(g, 0.15, 0.2)
		s.mix(b, g, s.at(i * 0.6), 1.0)
	s.biquad(b, "lp", 2500.0)
	return s.reverb(b, 0.25, 0.78, 0.5)


func _amb_village_knock(_v: int) -> PackedFloat32Array:
	var b := s.silence(0.1)
	var hits := s.rng.randi_range(2, 4)
	for i in hits:
		s.mix(b, knock(s.rng.randf_range(220.0, 260.0), s.rng.randf_range(520.0, 600.0), 0.03), s.at(i * s.rng.randf_range(0.35, 0.5)), 1.0)
	s.biquad(b, "lp", 2200.0)
	return s.reverb(b, 0.4, 0.82, 0.8)


func _amb_hooves(_v: int) -> PackedFloat32Array:
	var sec := 3.2
	var b := s.silence(sec)
	var t := 0.05
	var k := 0
	while t < sec - 0.2:
		var hit := thump(0.12, 520.0, 0.022)
		s.mix(hit, click(2200.0, 0.0025), 0, 0.35)
		s.mix(b, hit, s.at(t), s.rng.randf_range(0.6, 1.0) * (1.0 if k % 2 == 0 else 0.75))
		t += [0.16, 0.24][k % 2] * s.rng.randf_range(0.9, 1.1)
		k += 1
	for i in b.size():
		b[i] *= sin(PI * float(i) / b.size())
	s.biquad(b, "lp", 3500.0)
	return s.reverb(b, 0.2, 0.75, 0.4)


func _amb_bells(_v: int) -> PackedFloat32Array:
	var b := s.silence(0.1)
	var strikes := s.rng.randi_range(4, 8)
	var base := s.rng.randf_range(1800.0, 2400.0)
	var t := 0.0
	for i in strikes:
		var p := s.partials(0.5, base * s.rng.randf_range(0.98, 1.02), [[1.0, 1.0, 0.12], [2.4, 0.5, 0.08], [4.1, 0.25, 0.05], [6.7, 0.1, 0.03]], 0.0005)
		s.mix(b, p, s.at(t), s.rng.randf_range(0.4, 1.0))
		t += s.rng.randf_range(0.12, 0.3)
	s.biquad(b, "lp", 6500.0)
	return s.reverb(b, 0.2, 0.75, 0.4)


func _amb_cargo_creak(_v: int) -> PackedFloat32Array:
	var b := creak(s.rng.randf_range(0.6, 0.9), 18.0, 38.0, s.rng.randf_range(450.0, 600.0), s.rng.randf_range(1000.0, 1250.0))
	s.biquad(b, "lp", 3000.0)
	return s.reverb(b, 0.15, 0.7, 0.3)


func _amb_insects(_v: int) -> PackedFloat32Array:
	var sec := s.rng.randf_range(1.0, 1.8)
	var b := s.white(sec)
	var gate := s.rng.randf_range(18.0, 26.0)
	for i in b.size():
		var t := float(i) / Synth.RATE
		b[i] *= maxf(0.0, sin(TAU * gate * t)) ** 3
	s.biquad(b, "bp", s.rng.randf_range(5000.0, 6500.0), 3.0)
	return s.env_ar(b, 0.2, 0.4)
