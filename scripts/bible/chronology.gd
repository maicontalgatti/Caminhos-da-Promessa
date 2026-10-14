@tool
class_name Chronology
extends RefCounted
## Datas históricas sem ano zero: anos negativos são a.C., positivos d.C.
## Um intervalo ("span") é {from, to, precision, certainty}; span nulo
## significa que o jogo não atribui datação.

const CERTAINTIES := ["documented", "approximate", "debated", "unknown"]
const PRECISIONS := ["year", "century"]
const CERTAINTY_LABELS := {
	"documented": "data bem estabelecida",
	"approximate": "data aproximada",
	"debated": "datação debatida",
	"unknown": "cronologia incerta",
}


static func is_valid_year(y: Variant) -> bool:
	return (y is int or y is float) and int(y) != 0 and float(y) == float(int(y))


## Anos decorridos entre dois anos históricos (sem ano zero): de 1 a.C. a 1 d.C. = 1.
static func years_between(a: int, b: int) -> int:
	var d := b - a
	if a < 0 and b > 0:
		d -= 1
	elif a > 0 and b < 0:
		d += 1
	return d


static func century_of(year: int) -> int:
	return int(ceil(absi(year) / 100.0))


static func roman(n: int) -> String:
	var vals := [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1]
	var syms := ["M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I"]
	var out := ""
	for i in vals.size():
		while n >= vals[i]:
			out += syms[i]
			n -= vals[i]
	return out


static func era_suffix(year: int) -> String:
	return "a.C." if year < 0 else "d.C."


static func format_year(year: int) -> String:
	return "%d %s" % [absi(year), era_suffix(year)]


static func format_century(year: int) -> String:
	return "século %s %s" % [roman(century_of(year)), era_suffix(year)]


## Texto para o jogador, sem inventar precisão: "722/721 a.C.", "c. 27–30 d.C.",
## "séculos XII–XI a.C. (aproximado)", "cronologia incerta".
static func format_span(span: Variant) -> String:
	if not (span is Dictionary) or not is_valid_year(span.get("from")) or not is_valid_year(span.get("to")):
		return CERTAINTY_LABELS.unknown
	var a := int(span.from)
	var b := int(span.to)
	var certainty := String(span.get("certainty", "approximate"))
	var text := ""
	if String(span.get("precision", "year")) == "century":
		var ca := century_of(a)
		var cb := century_of(b)
		if ca == cb and (a < 0) == (b < 0):
			text = format_century(a)
		elif (a < 0) == (b < 0):
			text = "séculos %s–%s %s" % [roman(ca), roman(cb), era_suffix(a)]
		else:
			text = "%s – %s" % [format_century(a), format_century(b)]
	else:
		if a == b:
			text = format_year(a)
		elif (a < 0) == (b < 0):
			var sep := "/" if years_between(a, b) == 1 else "–"
			text = "%d%s%d %s" % [absi(a), sep, absi(b), era_suffix(a)]
		else:
			text = "%s – %s" % [format_year(a), format_year(b)]
	match certainty:
		"approximate":
			return "c. %s" % text if String(span.get("precision", "year")) == "year" else "%s (aproximado)" % text
		"debated":
			return "%s (datação debatida)" % text
		"unknown":
			return CERTAINTY_LABELS.unknown
	return text


## Chave de ordenação: ano inicial, ou nulo se não houver datação.
static func sort_year(span: Variant) -> Variant:
	if span is Dictionary and is_valid_year(span.get("from")):
		return int(span.from)
	return null


static func validate_span(owner: String, span: Variant) -> PackedStringArray:
	var out := PackedStringArray()
	if span == null:
		return out
	if not (span is Dictionary):
		out.append("%s: datação inválida" % owner)
		return out
	for k in ["from", "to"]:
		if not is_valid_year(span.get(k)):
			out.append("%s: ano \"%s\" inválido (inteiro diferente de zero)" % [owner, k])
	if out.is_empty() and int(span.from) > int(span.to):
		out.append("%s: intervalo de datas invertido" % owner)
	if not (String(span.get("certainty", "")) in CERTAINTIES):
		out.append("%s: certeza da datação inválida" % owner)
	if not (String(span.get("precision", "year")) in PRECISIONS):
		out.append("%s: precisão da datação inválida" % owner)
	return out
