# Fábrica de missões bíblicas

Processo e ferramentas para transformar uma proposta do catálogo em missão jogável, revisada e
rastreável. A especificação original está em `PROMPT_CURSOR_FABRICA_DE_MISSOES_BIBLICAS.md` (raiz);
regras bíblicas em [`ai-wiki/BIBLICAL_RULES.md`](ai-wiki/BIBLICAL_RULES.md); decisão em ADR-020
([`ai-wiki/DECISIONS.md`](ai-wiki/DECISIONS.md)).

## Onde fica cada coisa

| O quê | Onde |
|---|---|
| Catálogo-semente (78 propostas, cópia fiel do arquivo do usuário) | `production/catalog/seed_catalog_v0.1.json` |
| Catálogo de produção (estado editorial de cada episódio) | `production/catalog/episodes.json` |
| Relatório legível do catálogo (gerado) | `production/catalog/STATUS.md` |
| Pacote de cada episódio | `production/episodes/<id>/` |
| Perfis de voz | `production/audio/voice_profiles.json` |
| Registro de execuções, agentes e custos | `production/reports/factory_log.md` |
| Lógica do catálogo e gates | `tools/factory/factory_catalog.gd` (`FactoryCatalog`) |
| Linha de comando | `tools/factory.gd` |
| Geração de voz | `tools/audio/generate_voice.ps1` |
| Papéis dos subagentes | `.cursor/agents/*.md` |

`production/` não entra no executável (`exclude_filter` em `export_presets.cfg`). Conteúdo só vai para o
jogo quando o integrador copia para `data/`.

## Linha de comando

```powershell
$g = ".\tools\godot\Godot_v4.7.2-stable_win64_console.exe"
$f = "--headless","--path",".","--script","res://tools/factory.gd","--"
& $g @f list status=idea region=canaan_village   # filtros: status, book, testament, narrative_mode,
                                                  # region, difficulty, mechanics, support, event, quest=yes|no
& $g @f show ep_006_a_importancia_dos_pocos       # ficha, arquivos ligados, o que falta para o próximo estado
& $g @f pending                                   # episódios em produção e o que bloqueia cada um
& $g @f check                                     # gates, missão vinculada, alvos reais, áudio desatualizado
& $g @f check-refs C:\caminho\porbrbsl_vpl.txt    # referências contra o texto bíblico oficial
& $g @f targets canaan_village                    # NPCs e interações que existem de fato no mapa
& $g @f select 5                                  # candidatos ao próximo lote (sugestão; a escolha é humana)
& $g @f new <id>                                  # esqueleto do pacote (não sobrescreve nada)
& $g @f link <id> quest=<q> dialogues=a,b presentations=p discoveries=d
& $g @f audio-manifest <id>
& $g @f set-status <id> <estado> "<quem>" "<nota>"
& $g @f report                                    # reescreve production/catalog/STATUS.md
& $g @f import-seed                               # reimporta o catálogo-semente preservando estados
```

`targets` lê o `.tscn` como texto (os scripts do mapa dependem dos autoloads); o teste
`_test_factory` confirma que o resultado é igual ao do mapa instanciado.

## Estados e gates

Estados: `idea` → `researched` → `designed` → `awaiting_biblical_review` → `awaiting_historical_review`
→ `approved_for_implementation` → `implemented` → `tested` → `published`; `blocked` a qualquer momento
(exige nota). Não existe "concluído" booleano. `set-status` só aceita um estado se **todos** os requisitos
até ele forem atendidos; `check` acusa episódios cujo estado atual deixou de cumprir os gates.

| Estado | Exige (cumulativo) |
|---|---|
| researched | `research_biblical.md` e `research_historical.md` |
| designed | `design.md`, `manifest.json` e `quest.proposal.json` (ou missão do jogo vinculada) |
| awaiting_biblical_review | `dialogues.proposal.json` e `discoveries.proposal.json` (ou missão vinculada) |
| awaiting_historical_review | `review.json` com veredito bíblico registrado |
| approved_for_implementation | vereditos bíblico **e** histórico `ok_for_human_review`, nenhum achado `critical` em aberto |
| implemented | missão em `data/quests` válida, alvos existentes no mapa, texto bíblico importado, manifestos de áudio e visual |
| tested | `test_report.json` com `overall: "passed"` |
| published | `verification.status = approved` na missão com revisor humano e `review.json` → `human.approved_by` (nome de IA é recusado) |

Agentes nunca escrevem "verificado": o veredito máximo de um agente é `ok_for_human_review`.

## Pipeline e agentes

| Gate | Agente (`.cursor/agents/`) | Entrega | Escreve? |
|---|---|---|---|
| 0 seleção | coordenador (`factory select`) + pessoa | episódio escolhido, `factory new` | — |
| 1 pesquisa | `biblical-researcher`, `historical-reviewer` (em paralelo) | `research_biblical.md`, `research_historical.md` | pesquisador sim; revisor devolve texto, o coordenador salva |
| 2 desenho | `quest-designer` → `dialogue-writer` | `design.md`, `quest.proposal.json`, `dialogues.proposal.json`, `discoveries.proposal.json` | só no pacote |
| 3 revisão | `biblical-verifier` e `historical-reviewer` (em paralelo, somente leitura) | achados com severidade → `review.json` | não |
| 4 assets e implementação | `visual-asset-producer`, `godot-implementer` (**um só integrador**) | `visual_manifest.json`; `data/`, cenas | integrador sim |
| 5 áudio | `audio-producer` | `audio_manifest.json` (emoção, pronúncia, duração) | só manifesto |
| 6 QA | `quest-qa` (somente leitura) + suíte | `test_report.json` | não |
| 7 publicação | pessoa | `human.approved_by` | — |

Regras de coordenação: no máximo 2–3 agentes em paralelo; pesquisa e revisão podem ser paralelas;
**nunca** dois agentes editando `data/`, `scenes/` ou `scripts/` ao mesmo tempo; propostas ficam no
pacote até o integrador aplicar. Serviços pagos e lotes grandes exigem autorização do usuário.

### Limitação dos subagentes no Cursor (ver KI-10)

Os arquivos `.cursor/agents/*.md` seguem o formato documentado (frontmatter `name`, `description`,
`model`, `readonly`) e podem ser chamados como `/nome` num chat novo. Dentro de uma sessão já aberta,
a ferramenta de delegação aceita apenas tipos embutidos; o coordenador então lança um agente
`generalPurpose` instruído a ler e obedecer ao arquivo do papel. O efeito prático é o mesmo (contexto
próprio, entrega no pacote), mas o `readonly` vira instrução, não bloqueio técnico — por isso o
coordenador confere que revisores não alteraram arquivos.

## Mapa de capacidades (o que o motor já faz)

Eventos do motor: `QuestDatabase.EVENT_TYPES` em `scripts/quests/quest_database.gd`; tipos de objetivo
em `OBJECTIVE_TYPES` (ver [quests.md](quests.md)). Alvos: `npc`, `dialogue`, `examinable`, `pickup`, `area`,
`exit`, `region` e `ui`, conferidos por região (`.tscn` + JSON da região) pelos testes e pela fábrica.

Desde a v0.4, `implementation_errors` chama `FactoryCatalog.quest_world_errors(missão)`, que confere: a
região de cada alvo (a do objetivo ou a da missão); se a região existe (senão a missão fica em
planejamento); itens citados, conjuntos de colecionáveis e itens de recompensa; e se cada escolha usada nas
variantes de conclusão é produzida por algum `decision` de diálogo.

| Tipo de objetivo no catálogo | Situação | Como fazer hoje |
|---|---|---|
| talk_npc | já funciona (só dados) | evento `custom` num nó de diálogo do NPC, ou `dialogue_finished` |
| inspect_object | já funciona (só dados) | `Interactable` com `dialogue_id` + `dialogue_finished` |
| observe_scene | parcial | apresentação em quadros (`presentation_finished`); cena dirigida no mapa não existe |
| journal_reflection | parcial | descoberta/flag; não há tela de reflexão escrita |
| help_npc | parcial | escolha em diálogo com `decision`, `give`/`take` de itens e desfechos por `completion.variants`; acompanhar NPC (`escort_npc`) não existe |
| assemble_clues | parcial | vários eventos + flag ou conjunto de colecionáveis; não há interface de pistas |
| visit_area | já funciona (só dados) | `areas` no JSON da região → evento `location_reached` |
| organize | não existe | falta mecânica de organizar/quebra-cabeça |
| collect_item | já funciona (só dados) | `pickups` no JSON da região + gatilho `inventory`/`condition` |

Mapas: `canaan_village`, `caravan_road` e `dothan`. Episódios em outros lugares precisam de mapa novo
(estimativa em `estimate.new_map_needed`; mapas novos por `tools/art_gen/build_regions.gd`). Os alvos do catálogo-semente são marcadores (`target_state: placeholder`)
até o designer ligá-los a elementos reais.

## Referências

`check-refs <vpl>` confere livro, capítulo e cada versículo contra o arquivo oficial (mesmo leitor de
`tools/import_scripture.gd`). Sem arquivo (`check-refs -`), usa `data/bible/verse_counts.json`, que cobre
só alguns capítulos (KI-11). Versículo ausente no meio de um trecho vira nota de variante textual (ex.:
Atos 8:37 não consta na BPM), não erro. O resultado fica em `reference_check` de cada episódio.

## Áudio

- **Interface neutra:** o manifesto descreve falas; o provedor é trocável. Estado atual: nenhum provedor
  autorizado → todas as falas `pending` e o jogo segue só com texto (legendas são o próprio diálogo).
- **Manifesto** (`factory audio-manifest <id>`): uma linha por nó de diálogo vinculado e por passo de
  apresentação; `line_id` estável `<diálogo>/<nó>`; texto exatamente igual ao exibido (citação bíblica
  resolvida até 3 versículos, como em `DialogueManager.line_text`); `hash` = SHA-256 de texto + idioma +
  perfil de voz; arquivo `assets/audio/voice/<diálogo>__<nó>.ogg`. Regerar preserva emoção/pronúncia e
  marca `stale` o áudio cujo texto mudou. Falas do jogador são `text_only`.
- **No jogo:** `DialogueManager.voice_path` procura `<diálogo>__<nó>.ogg|.wav`; a `DialogueBox` toca se
  existir e para ao avançar. Apresentações ainda não tocam voz.
- **Geração:** `tools/audio/generate_voice.ps1 -Episode <id> -DryRun` conta falas e caracteres.
  `-Provider sapi -OutDir C:\TEMP\...` é **teste técnico** com a voz do Windows, gravado fora do projeto
  (o script recusa gravar dentro dele); não é asset do jogo. Provedor pago (`elevenlabs`) não está
  implementado: exige decisão humana de provedor, licença comercial e orçamento, além de `-ApproveBudget`.
  Chaves só por variável de ambiente, nunca em arquivo.
- Godot não exporta Ogg; um provedor que entregue WAV/MP3 precisa de conversão (ffmpeg não está
  instalado) ou importação WAV com compressão QOA.

## Custos

Nada pago foi usado. O uso de modelo dos subagentes não é exposto pelo Cursor por agente; o registro em
`production/reports/factory_log.md` anota "não mensurado" em vez de estimar.
