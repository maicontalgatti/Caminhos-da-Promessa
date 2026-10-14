@tool
class_name ContentPolicy
extends RefCounted
## Classificação do conteúdo e fluxo de verificação antes da publicação.
## Canal "prototype": mostra tudo que não é rascunho, marcando o que aguarda revisão.
## Canal "public": só conteúdo aprovado por uma pessoa.

const CHANNEL_SETTING := "caminhos/content/channel"

const STATUSES := ["draft", "pending_review", "reference_checked", "approved"]
const STATUS_LABELS := {
	"draft": "Rascunho",
	"pending_review": "Aguardando verificação",
	"reference_checked": "Referência conferida",
	"approved": "Aprovado para publicação",
}
## Status que exigem um revisor humano registrado.
const HUMAN_STATUSES := ["reference_checked", "approved"]
const AI_REVIEWERS := ["ia", "ai", "agente", "agent", "gpt", "claude", "llm", "gemini", "copilot", "openai", "anthropic", "cursor"]

const CLASSIFICATIONS := [
	"recorded_event",          # 1. relato bíblico
	"historical_context",      # 2. contexto histórico
	"plausible_fiction",       # 3. interação fictícia
	"parable_adaptation",      # 4. adaptação de parábola
	"symbolic_interpretation", # 5. interpretação
	"devotional_educational",  # 6. conteúdo devocional ou educativo
]
const CLASSIFICATION_LABELS := {
	"recorded_event": "Relato bíblico",
	"historical_context": "Contexto histórico",
	"plausible_fiction": "Interação fictícia",
	"parable_adaptation": "Adaptação de parábola",
	"symbolic_interpretation": "Interpretação",
	"devotional_educational": "Conteúdo devocional",
}
## Tipos de afirmação dentro de um texto educativo.
const SECTION_KINDS := {
	"biblical_text": "O que o texto diz",
	"historical": "Contexto histórico",
	"chronology": "Cronologia",
	"interpretation": "Interpretações",
	"fiction": "Criação do jogo",
}


static func channel() -> String:
	return String(ProjectSettings.get_setting(CHANNEL_SETTING, "prototype"))


static func status_of(item: Dictionary) -> String:
	var ver: Variant = item.get("verification", {})
	return String(ver.get("status", "draft")) if ver is Dictionary else "draft"


static func is_visible(item: Dictionary, in_channel: String = "") -> bool:
	var ch := in_channel if in_channel != "" else channel()
	var st := status_of(item)
	if ch == "public":
		return st == "approved"
	return st != "draft"


static func needs_review_marker(item: Dictionary) -> bool:
	return not (status_of(item) in HUMAN_STATUSES)


static func classification_label(c: String) -> String:
	return String(CLASSIFICATION_LABELS.get(c, c))


static func status_label(s: String) -> String:
	return String(STATUS_LABELS.get(s, s))


## Erros do bloco "verification": status válido e revisor humano quando exigido.
static func validate_verification(owner: String, item: Dictionary) -> PackedStringArray:
	var out := PackedStringArray()
	var ver: Variant = item.get("verification")
	if not (ver is Dictionary):
		out.append("%s: sem bloco \"verification\"" % owner)
		return out
	var st := String(ver.get("status", ""))
	if not (st in STATUSES):
		out.append("%s: status de verificação inválido \"%s\"" % [owner, st])
	elif st in HUMAN_STATUSES:
		var reviewer := String(ver.get("reviewer", "")).strip_edges()
		if reviewer == "":
			out.append("%s: status \"%s\" exige um revisor humano (verification.reviewer)" % [owner, st])
		elif is_ai_reviewer(reviewer):
			out.append("%s: conteúdo conferido apenas por IA não pode ser marcado como \"%s\"" % [owner, st])
	return out


## Palavras isoladas ("IA", "agente") ou nomes de modelos/serviços em qualquer posição.
static func is_ai_reviewer(reviewer: String) -> bool:
	var low := reviewer.to_lower()
	for token in AI_REVIEWERS:
		if low.contains(token) and token.length() >= 3 and not (token in ["agent", "agente"]):
			return true
	var words := RegEx.create_from_string("[^\\p{L}\\p{N}]+").sub(low, " ", true).split(" ", false)
	for w in words:
		if w in AI_REVIEWERS:
			return true
	return false
