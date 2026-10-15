class_name WorldClock
extends RefCounted
## Horário do dia derivado de GameState.play_time (sem campo novo no save).
## Um dia de jogo = DAY_LENGTH segundos reais. Fases: morning, day, evening, night.
## Cores alinhadas a docs/art_bible.md (manhã dourada → meio-dia → tarde → noite).

const DAY_LENGTH := 480.0  # 8 min reais ≈ 1 dia

const PHASES := ["morning", "day", "evening", "night"]
const PHASE_LABELS := {
	"morning": "Manhã",
	"day": "Dia",
	"evening": "Tarde",
	"night": "Noite",
}
## Fração do dia em que cada fase começa (ordem: morning → … → night).
const PHASE_START := {
	"morning": 0.0,
	"day": 0.20,
	"evening": 0.55,
	"night": 0.75,
}
const TINTS := {
	"morning": Color("FFE6B8"),
	"day": Color("FFFFFF"),
	"evening": Color("F0B878"),
	"night": Color("5A6496"),
}


static func day_progress(play_time: float = -1.0) -> float:
	var t := GameState.play_time if play_time < 0.0 else play_time
	if DAY_LENGTH <= 0.0:
		return 0.0
	return fposmod(t, DAY_LENGTH) / DAY_LENGTH


static func phase(play_time: float = -1.0) -> String:
	var p := day_progress(play_time)
	var current := "morning"
	for id in PHASES:
		if p + 0.0001 >= float(PHASE_START[id]):
			current = id
	return current


static func phase_label(id: String = "") -> String:
	var pid := id if id != "" else phase()
	return String(PHASE_LABELS.get(pid, pid))


static func tint(play_time: float = -1.0) -> Color:
	return TINTS.get(phase(play_time), Color.WHITE) as Color


static func is_night(play_time: float = -1.0) -> bool:
	return phase(play_time) == "night"


## Atualiza a flag `day_phase` quando a fase muda (dispara luz e visible_if).
static func sync_flag() -> String:
	var p := phase()
	if String(GameState.get_flag("day_phase", "")) != p:
		GameState.set_flag("day_phase", p)
	return p
