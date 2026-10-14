# Agentes de IA do projeto

Inventário dos agentes e regras versionados em `.cursor/`. O processo de produção (gates, pacotes de
episódio, linha de comando) está em [docs/mission_factory.md](../mission_factory.md); aqui fica só **quem é
cada agente** e em que estado está. Conferido contra os arquivos em 2026-10-14.

## Como funcionam
- **Subagentes:** `.cursor/agents/<nome>.md`. Cada arquivo tem frontmatter `name`, `description`, `model: inherit`
  e, nos revisores, `readonly: true`; o corpo traz as instruções do papel. Nenhum declara ferramentas: herdam as
  do agente que os chama (leitura, busca, terminal, edição). Não têm credenciais nem dependem de configuração local.
- **Coordenador:** o agente principal da conversa. Ele escolhe o episódio, delega, junta as entregas no pacote
  `production/episodes/<id>/` e é o único que roda a fábrica (`tools/factory.gd`) e integra.
- **Delegar:** num chat do Cursor, peça "use o subagente `biblical-researcher` para o ep_XXX" ou chame `/biblical-researcher`.
  Em 2026-10-14 os 9 papéis apareceram como tipos selecionáveis na ferramenta de delegação do Cursor. Em sessões
  anteriores (KI-10) só os tipos embutidos eram aceitos, e o coordenador lançava `generalPurpose` com a instrução de
  obedecer ao arquivo do papel; nesse modo `readonly` é só instrução.
- **Invocar outros agentes:** nenhum subagente delega. Só o coordenador chama agentes.
- **Regras sempre ativas ou por arquivo:** `.cursor/rules/*.mdc` (tabela no fim).
- **Outras ferramentas de IA** (Claude Code, Codex, Copilot, Gemini, Aider etc.): o ponto de entrada é o mesmo
  [`AGENTS.md`](../../AGENTS.md), e o prompt de partida é [START_WITH_AI.md](../../START_WITH_AI.md). Sem suporte a
  subagentes, use os arquivos de `.cursor/agents/` como checklist do papel e faça as etapas em sequência.

## Subagentes
Status: **usado** = já entregou trabalho real registrado em `production/reports/factory_log.md` ou em `review.json`;
**configurado** = arquivo pronto, nunca executado de verdade.

| Agente | Responsabilidade | Entradas | Saídas (escreve) | Limitações | Status |
|---|---|---|---|---|---|
| `biblical-researcher` | ficha bíblica do episódio: referências, personagens, gênero, linha do tempo com incerteza, texto × hipótese × ficção | `AGENTS.md`, BIBLICAL_RULES, `production/catalog/episodes.json`, `data/bible/` | só `research_biblical.md` do pacote | não escreve cenas nem dados; não marca nada como verificado | usado (ep_006, ep_008, ep_011, ep_025) |
| `historical-reviewer` | pesquisa de contexto ou revisão de anacronismos, geografia, costumes, cronologia | BIBLICAL_RULES, `data/bible/chronology.json`, `places.json`, `docs/art_bible.md` | nenhum arquivo (somente leitura); devolve relatório ou achados, o coordenador salva | fontes "a confirmar" quando não tem certeza | usado (ep_006, ep_008) |
| `quest-designer` | proposta jogável: objetivos, eventos, alvos reais, 3 pistas, conclusão | `docs/quests.md`, GAME_SYSTEMS, pesquisas, `tools/factory.gd -- targets` | `design.md`, `quest.proposal.json` | não muda o relato; alvos inexistentes marcados `pending_target` | usado (ep_006) |
| `dialogue-writer` | falas, escolhas, descobertas, pistas e textos de UI | BIBLICAL_RULES, diálogos e descobertas existentes, design | `dialogues.proposal.json`, `discoveries.proposal.json` | nunca escreve texto de versículo (usa `scripture`); personagem bíblico sem fala inventada | usado (ep_006) |
| `biblical-verifier` | auditoria bíblica independente de tudo o que foi escrito | arquivos indicados + `data/bible/texts/*.json` | nenhum arquivo (somente leitura); achados e veredito | veredito máximo `ok_for_human_review`; nunca aprova | usado (ep_006; ep_008 com rechecagem N1–N3) |
| `visual-asset-producer` | inventário de arte e lacunas visuais | `docs/art_bible.md`, `assets/`, cenas | `visual_manifest.json` | não edita cenas nem `tools/art_gen/`; gera arte só com gerador autorizado (nenhum configurado) | usado (ep_006) |
| `godot-implementer` | integra pacote aprovado ao jogo e pequenas infraestruturas | DEVELOPMENT_RULES, ARCHITECTURE_MAP, `docs/quests.md`, pacote aprovado | `data/`, `scenes/`, `scripts/` | um implementador por vez; roda a suíte e informa resultados | configurado (até agora o coordenador integrou diretamente) |
| `audio-producer` | manifesto de locução (vozes, emoção, pronúncia, duração) | `production/audio/voice_profiles.json`, `audio_manifest.json` do episódio | só esses dois manifestos | gera voz só via `tools/audio/generate_voice.ps1` com provedor autorizado e orçamento (nenhum existe, KI-12); **não** cuida dos efeitos sonoros (ver [docs/audio.md](../audio.md)) | configurado |
| `quest-qa` | QA de missão: dados, alvos, alcance, save/load, regressões | missão, diálogos, mapa, TESTING | nenhum arquivo (somente leitura); tabela de verificações e defeitos | nunca chama automação de teste manual | usado (ep_008; terminal bloqueado na ocasião, análise estática) |

Dependências comuns: o Godot portátil em `tools/godot/` (fora do Git) para quem roda testes; a AI Wiki;
os arquivos do pacote do episódio. Nenhum agente usa serviço pago ou API externa.

## Regras do Cursor
| Arquivo | Quando vale | Conteúdo |
|---|---|---|
| `.cursor/rules/00-continuidade.mdc` | sempre | ler `AGENTS.md` → wiki → estado → handoff; doc orienta, código verifica; nada de Git destrutivo; atualizar HANDOFF e rodar `tools/check_wiki.ps1` ao encerrar |
| `.cursor/rules/codigo-godot.mdc` | arquivos `.gd`, `.tscn`, `project.godot`, `export_presets.cfg` | não reescrever sistemas; tipos explícitos ao ler `Dictionary`; `block_ui`; save versionado; mapa da aldeia gerado |
| `.cursor/rules/conteudo-biblico.mdc` | `data/**/*.json` | BIBLICAL_RULES; versículos só pelo importador; IA deixa `pending_review` |

## Planejado (não existe)
Nenhum outro agente está definido ou planejado. Um papel novo entra como arquivo em `.cursor/agents/`, no
mesmo formato, e é registrado nesta tabela.
