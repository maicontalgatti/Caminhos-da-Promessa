extends RefCounted
## Paletas oficiais e layout do atlas de tiles.
## Fonte única de verdade para o gerador de arte e para o construtor de mundo.
## Ao alterar valores aqui, atualize também docs/art_bible.md.

const INK := Color("#2b1d14")

const PALETTES := {
	"identidade": {
		"Pergaminho claro": "#f4e4c1",
		"Marrom de escrita": "#2b1d14",
		"Dourado discreto": "#c9a227",
		"Terracota": "#b8734d",
		"Areia clara": "#e8c27a",
		"Azul profundo": "#2f5d9e",
		"Verde oliva": "#7a8b3a",
		"Couro": "#8b5a2b",
		"Pergaminho escuro": "#d9b98a",
	},
	"canaa": {
		"Verde oliva": "#7a8b3a",
		"Verde seco": "#a3b14b",
		"Terra": "#b07a45",
		"Pedra": "#c8b89a",
		"Madeira": "#795437",
		"Grama sombra": "#5e6e2a",
		"Terra sombra": "#8e5e36",
		"Reboco": "#c9a57a",
		"Folha de oliveira": "#a6b47c",
		"Anemona": "#c8372d",
	},
	"egito": {
		"Areia": "#e8c27a",
		"Arenito": "#c2733f",
		"Azul egipcio": "#2f5d9e",
		"Ouro": "#e0b03a",
		"Agua do Nilo": "#3f8f8a",
	},
	"deserto_exodo": {
		"Areia": "#e6b876",
		"Sombra de duna": "#bf8754",
		"Rocha": "#92765c",
		"Azul maritimo": "#1f5f7a",
		"Agua iluminada": "#3a8fb0",
	},
	"galileia_jordao": {
		"Verde": "#6f8f3c",
		"Azul do rio": "#4a9bb5",
		"Pedra": "#9c8a72",
		"Areia": "#d7c29a",
		"Luz suave": "#fff3c4",
	},
}

# Atlas de tiles: 8 colunas x 8 linhas de 16x16.
const TILE := 16
const ATLAS_COLS := 8
const ATLAS_ROWS := 8

const GRASS := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)]
const DRY_GRASS := [Vector2i(4, 0), Vector2i(5, 0)]
const STONE := [Vector2i(6, 0), Vector2i(7, 0)]
const FLOWER_YELLOW := Vector2i(0, 1)
const FLOWER_WHITE := Vector2i(1, 1)
const FLOWER_RED := Vector2i(2, 1)
const PEBBLES := Vector2i(3, 1)
const TUFT_A := Vector2i(4, 1)
const TUFT_B := Vector2i(5, 1)

## Sobreposições com borda irregular (autotile): 16 variações por máscara de
## vizinhos (N=1, E=2, S=4, W=8). Caminho de terra nas linhas 2-3,
## grama seca nas linhas 4-5 e pedra da praça nas linhas 6-7.
const OVERLAY_PATH := 2
const OVERLAY_DRY := 4
const OVERLAY_STONE := 6


static func overlay_coords(base_row: int, mask: int) -> Vector2i:
	return Vector2i(mask % 8, base_row + mask / 8)


static func path_coords(mask: int) -> Vector2i:
	return overlay_coords(OVERLAY_PATH, mask)


static func c(hex: String) -> Color:
	return Color(hex)
