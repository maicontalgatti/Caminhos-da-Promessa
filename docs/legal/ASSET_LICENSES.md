# Inventário de licenças e origem dos recursos

Auditoria feita em 2026-10-14 (v0.5.0), antes da publicação do repositório. Toda contribuição que
adicionar arte, som, fonte, texto bíblico ou outro recurso externo **deve** acrescentar uma linha aqui
([CONTRIBUTING.md](../../CONTRIBUTING.md#recursos-externos)).

Categorias:
- **Próprio:** criado para o projeto (por código do repositório, pelo criador ou por colaboradores).
- **Terceiros, compatível:** licença permite redistribuição no repositório.
- **Terceiros, restritivo:** exige permissão ou impede redistribuição. **Nenhum no momento.**
- **Origem desconhecida:** não pode ser publicado. **Nenhum no momento.**

## Resumo
| Caminho | Conteúdo | Origem | Categoria | Licença | Verificação |
|---|---|---|---|---|---|
| `scripts/`, `scenes/`, `tests/`, `tools/`, `addons/quest_editor/`, `*.gd`, `*.tscn`, `*.ps1`, `*.bat`, `project.godot`, `export_presets.cfg`, `default_bus_layout.tres` | Código, cenas e configuração | Escrito para o projeto | Próprio | MIT | Verificado: sem cabeçalhos ou trechos de terceiros encontrados |
| `assets/characters/` (38 PNG) | Sprites de personagens | Gerado por `tools/art_gen/` | Próprio | CC BY 4.0 | Verificado: cada arquivo tem gerador correspondente |
| `assets/environments/` (23 PNG) | Cenário e objetos | Gerado por `tools/art_gen/` | Próprio | CC BY 4.0 | Verificado |
| `assets/items/` (22 PNG) | Ícones de itens | Gerado por `tools/art_gen/` | Próprio | CC BY 4.0 | Verificado |
| `assets/gear/` (10 PNG) | Camadas de roupa, pano de cabeça e cajado do viajante (feira, ADR-030) | Gerado por `tools/art_gen/art_market.gd` a partir de `player.png` | Próprio | CC BY 4.0 | Verificado: cada arquivo tem gerador correspondente |
| `assets/tilesets/`, `assets/ui/`, `assets/palettes/` | Tiles, interface, paletas | Gerado por `tools/art_gen/` | Próprio | CC BY 4.0 | Verificado |
| `assets/shaders/` | Shader e material | Escrito para o projeto | Próprio | MIT | Verificado |
| `assets/audio/` (131 WAV, fora `music/`) | Efeitos e ambiente | Síntese procedural (`tools/audio/generate_sfx.gd`, `synth.gd`), sementes fixas; `source: procedural` em `data/audio/sfx.json` | Próprio | CC BY 4.0 | Verificado: nenhum arquivo externo; sem metadados embutidos |
| `assets/audio/music/` (9 WAV) | Música instrumental | Síntese procedural (`tools/audio/generate_music.gd`) a partir de partituras em `tools/audio/scores/`; catálogo em `data/audio/music.json` | Próprio (arranjos e temas originais); melodias de hinos em domínio público | Arranjos e temas originais: CC BY 4.0. Melodias: domínio público (ver "Música") | Verificado: nenhuma gravação externa; datas dos compositores conferidas em `music.json`. **Melodias transcritas de memória, pendentes de escuta humana** (KI-22) |
| `docs/images/` (68 PNG) | Capturas de tela | `tools/screenshot/` e capturas antigas da v0.1 (KI-04) | Próprio | CC BY 4.0 | Verificado: todas mostram o próprio jogo; sem metadados embutidos |
| `assets/fonts/PixelifySans-Variable.ttf` | Fonte | The Pixelify Sans Project Authors | Terceiros, compatível | SIL OFL 1.1 (`assets/fonts/OFL.txt`) | Verificado: aviso de copyright presente; fonte não modificada |
| `assets/fonts/Lora-Variable.ttf`, `Lora-Italic-Variable.ttf` | Fonte | The Lora Project Authors | Terceiros, compatível | SIL OFL 1.1 (`assets/fonts/OFL-Lora.txt`); nome reservado "Lora" | Verificado: fonte não modificada |
| `data/bible/texts/bpm.json` | Trechos bíblicos usados no jogo | Bíblia Portuguesa Mundial, eBible.org, importada por `tools/import_scripture.gd` | Terceiros, compatível | Domínio público (declarado pela fonte) | Licença verificada na fonte; **correspondência das referências pendente de revisão humana** (`pending_review`). Os tradutores a descrevem como rascunho (KI-06) |
| `data/` (demais JSON) | Diálogos, missões, descobertas, personagens, lugares, itens, regiões, áudio | Escrito para o projeto (com apoio de agentes de IA) | Próprio | CC BY 4.0 (textos) | Licença verificada; conteúdo bíblico e histórico **sem revisão humana** (KI-03, KI-14) |
| `docs/`, `production/`, `AGENTS.md`, `START_WITH_AI.md`, `.cursor/agents/`, `.cursor/rules/` | Documentação, pesquisa, definições de agentes | Escrito para o projeto (com apoio de agentes de IA) | Próprio | CC BY 4.0 | Verificado: pesquisa cita obras por referência, sem cópia de trechos longos |
| `PROMPT_CURSOR_FABRICA_DE_MISSOES_BIBLICAS.md`, `Caminhos_da_Promessa_catalogo_missoes.json` | Planejamento | Escrito pelo criador | Próprio | CC BY 4.0 | Verificado |

## Não incluído no repositório
- **Godot Engine 4.7.2** (MIT): baixado à parte em `tools/godot/` (fora do Git).
- **Templates de exportação**: instalados no perfil do usuário.
- **Executável do jogo** (`CaminhosDaPromessa.exe`, `dist/`, `build/`): fora do Git. Uma distribuição do
  exe deve levar junto as licenças do Godot (MIT e componentes de terceiros), das fontes (OFL) e o
  crédito do texto bíblico.

## Música
- Só entram melodias de hinos cujo compositor morreu há mais de 70 anos (ou, sem compositor conhecido,
  publicadas há mais de 120 anos). A regra é conferida por `tools/validate_content.gd`.
- Hinos usados: *Old Hundredth* (Louis Bourgeois, 1551), *Hino da Alegria* (Beethoven, 1824), *Amazing Grace*
  / New Britain (melodia tradicional, 1829) e *Noite Feliz* (Franz Gruber, 1818).
- Só a **melodia** é usada. **Letras e arranjos modernos** (inclusive traduções recentes das letras) podem ser
  protegidos e não entram sem licença. Gravações de terceiros (YouTube, streaming, CDs) nunca entram.
- Ficaram de fora nesta versão, por não ser possível transcrever a melodia com segurança: *Castelo Forte*,
  *Rocha Eterna*, *Cwm Rhondda*, *Bringing in the Sheaves*, *Adeste Fideles* e *Antioch* (ADR-029).
- Louvores comerciais (canções e gravações atuais) exigem licença de sincronização da editora e da gravadora;
  a licença CCLI das igrejas não cobre jogos. Entram só com permissão escrita e `source: licensed` + `license_record`.
- Os temas `orig_*` foram compostos para o projeto (CC BY 4.0).

## Traduções bíblicas
- Só a Bíblia Portuguesa Mundial está no repositório. **Traduções modernas (NVI, ARA, NAA, NTLH, NVT etc.)
  são protegidas por direitos autorais** e não podem ser adicionadas sem licença escrita do detentor (KI-06).
- Referências (ex.: "Gênesis 37:12-17") não são texto bíblico e podem aparecer livremente.

## Pendências
- Revisão humana da correspondência das referências da BPM e do conteúdo bíblico e histórico (KI-03, KI-06, KI-14).
- Sons e arte são provisórios. Substituições por gravações ou bibliotecas externas exigem autorização do
  criador e uma linha nova nesta tabela, com licença e link da fonte.
