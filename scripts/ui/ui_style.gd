class_name UiStyle
extends RefCounted
## Paleta e peças de interface compartilhadas (pergaminho, madeira, etiquetas).
## Mantém as novas telas coerentes com o tema em assets/ui/theme.tres.

const INK := Color("#2b1d14")
const BROWN := Color("#8b5a2b")
const WOOD := Color("#5a3a1e")
const GOLD := Color("#c9a227")
const PARCHMENT := Color("#f4e4c1")
const SAND := Color("#ead3a4")
const MUTED := Color("#7a6248")
const SHADOW := Color("#2b1d14")

## Fonte de leitura (textos longos); títulos, botões e etiquetas usam a Pixelify do tema.
const READING_FONT := "res://assets/fonts/Lora-Variable.ttf"
const READING_ITALIC_FONT := "res://assets/fonts/Lora-Italic-Variable.ttf"

const TAG_COLORS := {
	"recorded_event": Color("#7d3324"),
	"historical_context": Color("#4f6b3a"),
	"plausible_fiction": Color("#4a5f7a"),
	"parable_adaptation": Color("#6e4a73"),
	"symbolic_interpretation": Color("#7a5a1f"),
	"devotional_educational": Color("#3a6b6b"),
}


static func panel(bg: Color = PARCHMENT, border: Color = BROWN, border_w := 1, margin := 4) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(border_w)
	s.set_corner_radius_all(2)
	s.content_margin_left = margin + 1
	s.content_margin_right = margin + 1
	s.content_margin_top = margin
	s.content_margin_bottom = margin
	s.anti_aliasing = false
	return s


## Moldura de livro: madeira escura com pergaminho dentro.
static func wood_frame() -> StyleBoxFlat:
	var s := panel(PARCHMENT, WOOD, 3, 6)
	s.shadow_color = Color(0, 0, 0, 0.35)
	s.shadow_size = 2
	s.shadow_offset = Vector2(1, 2)
	return s


static func label(text: String, size := 8, color: Color = INK, wrap := false) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	if wrap:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		reading(l)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


## Aplica a fonte de leitura a um Label (texto corrido).
static func reading(l: Label, italic := false) -> Label:
	l.add_theme_font_override("font", load(READING_ITALIC_FONT if italic else READING_FONT))
	# O espaçamento padrão do Label (3) soma-se ao da Lora e separa demais as linhas.
	l.add_theme_constant_override("line_spacing", 0)
	return l


## Rótulo claro com contorno, para texto sobre o cenário.
static func outlined(text: String, size := 8, color: Color = PARCHMENT, outline := 3) -> Label:
	var l := label(text, size, color)
	l.add_theme_color_override("font_outline_color", SHADOW)
	l.add_theme_constant_override("outline_size", outline)
	return l


static func rich(size := 8) -> RichTextLabel:
	var r := RichTextLabel.new()
	r.bbcode_enabled = true
	r.fit_content = true
	r.scroll_active = false
	r.add_theme_font_size_override("normal_font_size", size)
	r.add_theme_font_size_override("bold_font_size", size)
	r.add_theme_font_size_override("italics_font_size", size)
	r.add_theme_color_override("default_color", INK)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r


static func tag(text: String, color: Color) -> PanelContainer:
	var p := PanelContainer.new()
	var s := panel(color, color.darkened(0.3), 1, 1)
	s.content_margin_left = 3
	s.content_margin_right = 3
	s.content_margin_top = 0
	s.content_margin_bottom = 1
	p.add_theme_stylebox_override("panel", s)
	p.add_child(label(text, 6, PARCHMENT))
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return p


static func classification_tag(classification: String) -> PanelContainer:
	return tag(ContentPolicy.classification_label(classification), TAG_COLORS.get(classification, BROWN))


static func small_button(text: String, size := 6, focusable := false) -> Button:
	var b := Button.new()
	b.text = text
	b.add_theme_font_size_override("font_size", size)
	for st in ["normal", "hover", "pressed", "focus", "disabled"]:
		var base: StyleBox = b.get_theme_stylebox(st)
		if base is StyleBoxFlat:
			var c := (base as StyleBoxFlat).duplicate() as StyleBoxFlat
			c.content_margin_left = 3
			c.content_margin_right = 3
			c.content_margin_top = 0
			c.content_margin_bottom = 1
			b.add_theme_stylebox_override(st, c)
	if not focusable:
		b.focus_mode = Control.FOCUS_NONE
	return b


static func hex(c: Color) -> String:
	return "#" + c.to_html(false)
