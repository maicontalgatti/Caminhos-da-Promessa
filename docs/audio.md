# Efeitos sonoros

Como o áudio do jogo funciona, como adicionar ou trocar sons e o inventário atual (v0.5.0).
Decisão de arquitetura: ADR-026 em [DECISIONS.md](ai-wiki/DECISIONS.md).

## Visão geral
- **Um só ponto de entrada:** o autoload `AudioManager` (`scripts/core/audio_manager.gd`). O código pede sons
  **por id** (`AudioManager.play("ui_click")`); arquivos, volumes e regras ficam no manifesto
  `data/audio/sfx.json`.
- **Buses** (`default_bus_layout.tres`): Master → Music, SFX, UI, Ambience, Voice. O Master tem um limitador
  (teto -0,5 dB) contra picos. A Música tem o diretor de música temática (seção abaixo); a Voz ainda não tem conteúdo.
- **Todos os 131 arquivos atuais são procedurais**, gerados por `tools/audio/generate_sfx.gd` (síntese em
  GDScript, sem amostras de terceiros e sem serviços pagos). São provisórios: **precisam de escuta humana**
  (ver abaixo) e podem ser trocados por gravações com o mesmo nome de arquivo, sem mexer no código.
- `scripts/core/sfx.gd` (`Sfx.play`) ficou como compatibilidade: traduz os nomes antigos e chama o `AudioManager`.

## Regras de reprodução (no `AudioManager`)
| Regra | Como funciona |
|---|---|
| Conjunto fixo de players | 14 não posicionais + 6 posicionais (`AudioStreamPlayer2D`) + 2 para o ambiente de fundo; nenhum player é criado por som |
| Prioridade | conjunto cheio: o som novo rouba a voz de menor prioridade (a mais antiga); som menos importante que todos os que tocam é descartado |
| Cooldown | tempo mínimo entre duas reproduções do mesmo id (evita clique duplo, hover repetido, passos acumulados) |
| Instâncias | `max` simultâneas do mesmo id |
| Variações | sorteia um arquivo `_1.._n` sem repetir o anterior; pitch e volume variam (`pitch`, `jitter_db`) |
| Substituição | `supersedes`: abrir menu, confirmar etc. interrompem o clique do mesmo gesto (até 90 ms) |
| Marcos | missão iniciada/concluída, objetivo, descoberta, coleção, decisão, recompensa e região nova passam por `event()`: no mesmo quadro vira **um** som (o de maior prioridade); logo após um som imediato (coleta, interação) espera 0,18 s para não embolar |
| Silêncio ao carregar | 0,6 s sem marcos após novo jogo/carregar (sem "fanfarra" de missões restauradas) e nenhum marco fora do jogo |
| Cache | cada arquivo é carregado uma vez; `shutdown()` para tudo e solta o cache ao sair |

## Onde cada som é disparado
| Sistema | Gatilho | Arquivo |
|---|---|---|
| Passos | quadros de contato da animação (0 e 2), só com deslocamento real ≥ 18 px/s e sem diálogo/tela aberta; corrida soma pitch e volume | `scripts/world/character_sprite.gd` (sinal `step`), `scripts/player/player.gd` |
| Superfície | camadas de TileMapLayer, de cima para baixo (`surfaces.layers`), consultadas só no passo | `scripts/world/game_map.gd` (`surface_at`) |
| Botões | todo `BaseButton` que entra na árvore ganha clique, hover (só habilitado) e foco por teclado, sem script próprio | `AudioManager._hook_button` |
| Telas | diário, páginas, bolsa, Mapa das Escrituras, pausa, menu, salvar, recusas | `scripts/ui/*.gd` |
| Interação | material pelo diálogo do objeto (`interactions.by_dialogue`) ou pelo tipo do Interactable (`kinds`); conversa usa `dialogue_open` | `scripts/interaction/interactable.gd` |
| Bolsa | sinal `Inventory.moved(item, delta, source)`: coleta (som do item), recebido, entregue, descartado, recompensa; nada toca se o item não entrou/saiu | `scripts/items/inventory.gd` |
| Diálogo | abrir, avançar (a partir da 2ª fala), escolha, decisão, fechar; som de texto opcional (desligado por padrão, nunca junto de voz gravada) | `scripts/ui/dialogue_box.gd` |
| Missões e descobertas | sinais do `QuestManager`, `Discoveries`, `Collectibles` | `AudioManager._ready` |
| Ambiente | `set_region` ao entrar numa região: troca o laço de fundo com fade (1,4 s), agenda camadas ocasionais em volta da câmera e cria emissores presos ao mapa (poço, cisterna), que somem com o mapa | `scripts/core/game.gd`, `AudioManager.set_region` |
| Configurações | volume por bus (0–100 %, em tempo real), silenciar cada bus, hover e som de texto; salvo em `user://settings.cfg` com atraso de 0,4 s | `scripts/core/settings.gd`, `scripts/ui/audio_settings.gd` |

Os controles de volume estão no menu inicial (Configurações) e na pausa ("Sons e volume"). Ao arrastar um controle,
toca um som de teste daquele bus (no máximo a cada 0,25 s).

## Como adicionar ou trocar um som
1. **Trocar por gravação:** salve o WAV (44,1 kHz, 16 bits, mono para efeitos) com o **mesmo nome**
   (`assets/audio/<path>_<n>.wav`) e mude `source` para a origem (ex.: `"gravado"`, `"Kenney CC0"`). Registre a
   licença. Rode o editor ou `--import` para reimportar.
2. **Som novo:** crie a entrada em `sounds` do manifesto:
   ```json
   "interact_basket": {"path": "interactions/interact_basket", "variants": 2, "bus": "SFX",
     "volume_db": -12.0, "pitch": 0.04, "cooldown": 0.2, "max": 1, "priority": 45, "source": "gravado"}
   ```
   e coloque os arquivos `interact_basket_1.wav` e `interact_basket_2.wav` em `assets/audio/interactions/`.
3. **Ligar ao jogo, de preferência por dados:**
   - objeto examinável: `interactions.by_dialogue` (`"basket_examine": "interact_basket"`);
   - item: `items` (`"item_id": "som"`);
   - superfície de passos: nova camada em `surfaces.layers` (ou `"surface_layers"` no JSON da região) e o som em `surfaces.sounds`;
   - ambiente de região: bloco em `ambience` (`bed`, `layers`, `emitters`).
   - Em último caso, no código: `AudioManager.play("id")`, `play_at("id", posição)` ou `event("id")` para marcos.
4. **Botão com som diferente:** `button.set_meta("sfx", "ui_confirm")`; `""` deixa o botão mudo (quando a própria tela
   já toca um som), `set_meta("sfx_hover", false)` desliga o hover.
5. Rode os testes: `tests/audio_tests.gd` confere que todo arquivo do manifesto existe, carrega, não está silencioso
   nem saturado, que todo examinável dos mapas e todo item têm som e que cada região tem ambiente.

### Campos do manifesto
`path`, `variants`, `bus` (Music, SFX, UI, Ambience, Voice), `volume_db`, `pitch` (± fração), `jitter_db` (± dB),
`cooldown` (s), `max`, `priority` (0–100), `supersedes` (ids), `loop` (laço contínuo, ajustado em tempo de execução),
`source` e `status` (texto livre para pendências).

### Gerador procedural
```powershell
$g = ".\tools\godot\Godot_v4.7.2-stable_win64_console.exe"
& $g --headless --path . --script res://tools/audio/generate_sfx.gd                 # todos (~14 s)
& $g --headless --path . --script res://tools/audio/generate_sfx.gd -- ui_click save # só alguns ids
& $g --headless --path . --import
& $g --headless --path . --script res://tools/audio/audit_audio.gd                  # pico, RMS, saturação, DC
```
Receitas em `tools/audio/generate_sfx.gd` (sementes fixas por id: o resultado é reproduzível); biblioteca de DSP em
`tools/audio/synth.gd`. **Atenção:** o gerador sobrescreve os arquivos dos ids pedidos — não rode sobre um som que
já foi trocado por gravação. `tools/` fica fora do exe.

## Inventário (v0.5.0)
Todos: origem **procedural**, WAV 16 bits 44,1 kHz mono, auditados por `audit_audio.gd` (0 problemas: nenhum
silencioso, saturado ou com DC). "Ligado" = disparado pelo jogo e coberto por teste automatizado.

| Categoria | Ids (variações) | Estado |
|---|---|---|
| Passos | `footstep_dirt` (5), `footstep_grass` (5), `footstep_stone` (5) | ligado: terra (caminhos), grama (campo), pedra (praça da aldeia) |
| Passos | `footstep_sand` (4), `footstep_wood` (4), `footstep_water` (4) | pronto, **sem superfície nos mapas atuais** (nenhuma camada de areia, madeira ou água rasa) |
| Interface | `ui_click` (3), `ui_hover` (2), `ui_focus` (2), `ui_confirm`, `ui_cancel`, `ui_denied`, `menu_open`, `menu_close`, `save` | ligado |
| Diário e mapa | `journal_open`, `journal_close`, `page_turn` (3), `map_open`, `map_close` | ligado |
| Diálogo | `dialogue_open` (2), `dialogue_advance` (3), `dialogue_choice`, `dialogue_close`, `decision` | ligado |
| Diálogo | `text_blip` (3) | ligado, **desligado por padrão** (opção "Som do texto") |
| Interação | `interact_wood` (2), `interact_stone` (2), `interact_ceramic` (2), `interact_cloth` (2), `interact_parchment` (2), `interact_water_well`, `interact_water_cistern`, `interact_door`, `interact_dirt` (2), `interact_fire`, `interact_generic` (2) | ligado |
| Interação | `interact_metal` | pronto, **sem objeto de metal nos mapas** (coerente com a época: sem ferro na estrada) |
| Bolsa | `bag_open`, `bag_close`, `item_pickup` (2), `item_wood` (2), `item_fiber` (2), `item_water`, `item_food`, `item_cloth`, `item_rope`, `item_give`, `item_receive`, `item_discard`, `reward`, `collectible`, `collection_complete` | ligado |
| Missões | `quest_start`, `objective_update` (acompanhar missão no diário), `objective_complete`, `quest_complete` (pequena assinatura de lira), `region_new`, `travel` | ligado |
| Descobertas | `discovery` (sino suave e contemplativo, distinto da recompensa) | ligado |
| Ambiente Canaã | `amb_wind_canaan` (laço 16 s), `amb_water_well` (emissor no poço), `amb_village_grind` (2), `amb_village_knock` (2) + comuns | ligado |
| Ambiente estrada | `amb_wind_road` (laço), `amb_hooves` (2), `amb_bells` (2), `amb_cargo_creak` (2) + pássaros | ligado |
| Ambiente Dotã | `amb_wind_dothan` (laço), `amb_water_cistern` (emissor na cisterna), `amb_insects` (2) + rebanho e pássaros | ligado |
| Ambiente comum | `amb_bird` (6), `amb_sheep` (4), `amb_goat` (2) | ligado |

## Música temática
Louvores instrumentais que mudam conforme o momento da história, **baixos** e com silêncio entre as faixas.
Decisão: ADR-029 em [DECISIONS.md](ai-wiki/DECISIONS.md). Licenças: [ASSET_LICENSES.md](legal/ASSET_LICENSES.md#música).

- **Código:** `scripts/core/music_director.gd`, criado como filho do `AudioManager` (`AudioManager.music`); o
  `AudioManager` continua sendo o único ponto de entrada. Regras do manifesto sem autoloads em
  `scripts/core/music_rules.gd` (validador e testes).
- **Dados:** `data/audio/music.json`: `tracks` (catálogo, com compositor, ano, licença e `themes`) e `cues`
  (que lista toca em cada momento).
- **Ordem de escolha do momento:** cena dirigida (`cues.scenes`) > apresentação bíblica ou prólogo
  (`presentations`, `prologues`) > tela aberta (`contexts`, hoje só `scripture_map`) > missão principal em foco
  (`quests`, por `QuestManager.primary_quest()`) > região (`regions`) > `menu` fora do jogo. Momento sem entrada
  segue o nível seguinte; lista vazia `[]` é silêncio de propósito.
- **Séries por tema:** um item `"theme:graça"` na lista puxa todas as faixas cujo `themes` contém "graça".
- **Reprodução:** sorteio sem repetir a anterior; silêncio de `playlist_gap` (20–40 s) entre faixas; troca de
  momento com fade (`fade_out` 2,5 s, `fade_in` 4 s); se a faixa atual também está na lista nova, ela continua.
  Volume da faixa `volume_db` (−14 a −15 dB) no bus Music (controle "Música" nas configurações).
- **Abaixar (ducking):** diálogo aberto `duck_db` (−6 dB); marcos (`duck_events`: missão, descoberta, recompensa,
  região nova) `event_duck_db` (−8 dB) por `event_duck_hold` s.
- **Ganchos:** `enter_context(dono, chave)` / `exit_context(dono)` em `cinematic.gd` (apresentação e prólogo),
  `scripture_map.gd` (mapa e cartão de passagem) e `scene_director.gd` (cenas). O dono é guardado por referência
  fraca: se for liberado sem fechar, o momento cai sozinho.

### Faixas atuais (provisórias)
Geradas por `tools/audio/generate_music.gd` a partir das partituras em `tools/audio/scores/` (WAV mono 22,05 kHz,
lira + flauta + bordão + tamboril). Hinos: Old Hundredth, Noite Feliz, Amazing Grace, Hino da Alegria. Temas
próprios: `orig_dothan_lament`, `orig_sea_night`, `orig_sea_crossing`, `orig_harvest`, `orig_nile`.
**As melodias dos hinos foram transcritas de memória por IA e nada foi ouvido por uma pessoa (KI-22).**

```powershell
& $g --headless --path . --script res://tools/audio/generate_music.gd               # todas (~1 min)
& $g --headless --path . --script res://tools/audio/generate_music.gd -- silent_night # só uma
& $g --headless --path . --import
```

### Trocar por gravação ou acrescentar louvor
1. Salve o arquivo como `assets/audio/<path>.ogg` (o `.ogg` tem preferência sobre o `.wav` de mesmo nome), atualize
   `source`, `license` e o crédito em `music.json` e registre a linha em `ASSET_LICENSES.md`.
2. `source`: `public_domain_hymn` (compositor morto há mais de 70 anos, ou anônimo publicado há mais de 120),
   `original` (composição cedida ao projeto) ou `licensed` (exige `license_record`). Faixa cantada (`vocal: true`)
   exige `lyrics_license`: letras e traduções modernas são protegidas.
3. **Louvores comerciais** (gravações e canções atuais) só com licença de sincronização da editora e da gravadora;
   a licença de igreja (CCLI) não cobre jogos. Nunca baixar de YouTube/streaming.
4. Rode `tools/validate_content.gd` e os testes (`tests/music_tests.gd`).

## Escuta humana necessária
Nenhum som foi ouvido por uma pessoa: os testes conferem existência, nível, saturação, quando cada som toca e
quando **não** toca, mas não o timbre. Prioridade de escuta, do mais exposto ao menos:
1. **Passos** (terra, grama, pedra; andando e correndo) — tocam o tempo todo; conferir se não cansam e se o volume combina.
2. **Clique, hover e foco** — o hover deve ser quase imperceptível; se incomodar, há a opção "Som ao passar o mouse".
3. **Vento de cada região e a água do poço/cisterna** — conferir se o laço não "pula" na emenda e se o vento não soa como chiado.
4. **Ovelhas, cabras e pássaros** — os mais artificiais da síntese; candidatos naturais a troca por gravação.
5. **Marcos** (`quest_complete`, `discovery`, `collection_complete`) — conferir se são discretos e distintos entre si.
6. Abrir diário/bolsa/mapa, interações por material, sons da caravana.

## Pendências
- Música: faixas provisórias geradas por código; conferir de ouvido as melodias dos hinos e trocar por
  gravações quando houver (KI-22). Vozes (bus Voice; KI-12).
- Ambiente do Egito e das regiões planejadas: entra quando os mapas existirem (bloco `ambience` da região).
- Superfícies de areia, madeira e água: os sons existem; faltam camadas nos mapas.
- Possível troca dos procedurais por gravações ou bibliotecas livres (ex.: pacotes CC0) — **depende de autorização do criador**; nenhuma biblioteca foi baixada.
