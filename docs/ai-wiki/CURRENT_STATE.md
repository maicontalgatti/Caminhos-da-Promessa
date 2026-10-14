# Estado atual

Resumo do **presente**. Histórico em [CHANGELOG.md](CHANGELOG.md) e [docs/implementation_log.md](../implementation_log.md).

## Identificação
- **Projeto:** Caminhos da Promessa
- **Versão:** 0.5.0 (`project.godot` → `config/version`)
- **Última atualização:** 2026-10-14
- **Commit de referência:** o commit de publicação na branch protegida `main` (hash e verificação no [HANDOFF.md](HANDOFF.md)); anterior: checkpoint `218cb73`
- **Repositório:** público, https://github.com/maicontalgatti/Caminhos-da-Promessa
- **Licenças:** código MIT; arte, sons e textos próprios CC BY 4.0; fontes OFL; texto bíblico BPM em domínio público ([docs/legal/ASSET_LICENSES.md](../legal/ASSET_LICENSES.md))
- **CI:** `.github/workflows/tests.yml` roda suíte, fluxo, validação, fábrica e auditoria de áudio com o Godot oficial no Linux, em todo pull request e push na `main`
- **Fase:** protótipo jogável com três regiões; roadmap fase 5 (catálogo) em andamento e fase 6 (primeiras experiências) com duas experiências jogáveis; parte da fase 4 (inventário, transição entre mapas) entregue na v0.4 — ver [docs/roadmap.md](../roadmap.md)
- **Canal de conteúdo:** `prototype` (`caminhos/content/channel`)
- **Tradução bíblica:** `bpm` — Bíblia Portuguesa Mundial, domínio público, provisória (`caminhos/content/bible_translation`; NVI pedida, depende de permissão — KI-06)

## Funcionalidades concluídas e verificadas
"Verificado" = coberto por teste automatizado executado e aprovado. Última execução em 2026-10-14, no checkpoint da v0.5.0 (build das 15:12; detalhes em [HANDOFF.md](HANDOFF.md); houve falhas intermitentes em builds anteriores, KI-17):
- `tests/test_runner.tscn`: 665/665;
- `tools/audio/audit_audio.gd`: 131 arquivos, 0 problemas;
- `tests/flow_smoke.gd`: 17/17;
- `tools/validate_content.gd`: sem erros de dados;
- `tools/factory.gd -- check`: 0 erros em 78 episódios.
Nenhuma foi validada por sessão de jogo humana ainda.

| Funcionalidade | Onde | Verificação |
|---|---|---|
| Menu inicial (novo, continuar, configurações, créditos, sair, notificações educativas) | `scripts/ui/main_menu.gd` | testes + fluxo |
| Aldeia em Canaã 60×40 tiles, colisões, profundidade, câmera | `scenes/maps/canaan_village.tscn` | testes + capturas |
| Jogador 8 direções com corrida | `scripts/player/player.gd` | testes |
| 4 moradores + 3 ovelhas com comportamento; interação universal | `scripts/npc/`, `scripts/interaction/` | testes |
| Diálogos com escolhas, flags e efeitos | `scripts/dialogue/` | testes |
| Prólogo cinematográfico (pular, rever pela pausa, não repete ao carregar) | `scripts/ui/cinematic.gd` | testes + fluxo |
| Missão "A importância dos poços" (Gênesis 26:18-22), 4 objetivos (Adina, poço, Ezer, relato), pistas em 3 níveis, conclusão retroativa | `data/quests/canaan/canaan_wells.json` | testes |
| Seta de objetivo no mapa (marcador sobre o alvo ou seta na borda) | `scripts/world/objective_guide.gd` | testes + capturas |
| HUD: contexto bíblico, rastreador de objetivo, avisos, cartões de descoberta e de conclusão | `scripts/ui/hud.gd` | testes + capturas |
| Apresentação de Gn 26 em 7 passos com o texto dos versículos e notas do jogo | `scripts/ui/cinematic.gd`, `data/bible/presentations.json` | testes + capturas |
| Texto bíblico importado do arquivo oficial (220 versículos, BPM), citado em apresentação, diário e falas do narrador | `tools/import_scripture.gd`, `data/bible/texts/bpm.json`, `scripts/bible/` | testes + capturas |
| Fonte Lora nos textos de leitura | `assets/ui/theme.tres`, `scripts/ui/ui_style.gd` | capturas |
| Diário em 6 abas (Jornada por categoria com "E: Ler o relato bíblico" ou "Acompanhar no HUD", Escrituras com versículos, Personagens, Lugares, Linha do tempo, Descobertas) | `scripts/ui/journal*.gd` | testes + capturas |
| Catálogo: 66 livros, cronologia (11 épocas, 9 acontecimentos), 14 lugares, 8 pessoas, 16 descobertas, apresentações de Gn 26 e Gn 37:12-17 | `data/bible/` | testes + validador |
| Status de verificação de conteúdo e canal prototype/public; IA não pode ser revisora | `scripts/bible/content_policy.gd` | testes + validador |
| Save v3 com migração da v1 e da v2, gravação segura, salvamento automático ao chegar numa região | `scripts/save/save_manager.gd` | testes |
| Várias regiões na mesma cena: Aldeia em Canaã, Caminho das Caravanas (64×34) e Pastos de Dotã (64×40); saídas com condição, escurecimento, título da região, volta ao mapa anterior | `scripts/world/world_manager.gd`, `game_map.gd`, `data/regions/` | testes + capturas |
| Mapa das Escrituras (M) por épocas, cartão "OUTRO MOMENTO DA HISTÓRIA", experiências planejadas visíveis e não jogáveis; atlas de lugares dentro dele | `scripts/ui/scripture_map.gd`, `data/world/experiences.json` | testes + capturas |
| Bolsa (I) com 12 espaços e essenciais, coleta no mapa sem duplicação, entrega e troca em diálogo | `scripts/items/`, `scripts/ui/inventory_screen.gd` | testes + capturas |
| Colecionáveis em conjuntos e aba "Descobertas" do diário | `scripts/items/collectibles.gd`, `data/collectibles/` | testes + capturas |
| Condições compostas e escolhas com consequência persistente | `scripts/core/conditions.gd`, `dialogue_manager.gd` | testes |
| Categorias de missão (principal, secundária, exploração), missão acompanhada, 15 tipos de objetivo, recompensas uma vez, desfechos por variante | `scripts/quests/` | testes |
| Seta para a saída quando o objetivo está em outra região; HUD com "Você está em" e "Siga para" | `scripts/world/objective_guide.gd`, `scripts/ui/hud.gd` | testes + capturas |
| Missões da v0.4: "O caminho para Dotã" (principal, Gn 37:12-17), "Suprimentos para a viagem", "Duas famílias, uma decisão" (3 desfechos), "Registros da caravana" | `data/quests/dothan/` | testes (fluxos completos, save/load no meio) |
| Efeitos sonoros: `AudioManager` com buses (Master, Music, SFX, UI, Ambience, Voice), prioridade, cooldown e variações; passos por superfície sincronizados com a animação (só com deslocamento real); som automático em todos os botões; interação por material; bolsa, diálogo, missões, descobertas; ambiente por região com troca suave; 131 arquivos procedurais (sem escuta humana, KI-16) | `scripts/core/audio_manager.gd`, `data/audio/sfx.json`, [docs/audio.md](../audio.md) | testes (`tests/audio_tests.gd`) + auditoria + autoteste do exe |
| Volume por bus (Geral, Música, Efeitos, Interface, Ambiente, Vozes), silenciar cada um, som de hover e de texto; em tempo real e salvo; no menu e na pausa | `scripts/core/settings.gd`, `scripts/ui/audio_settings.gd` | testes |
| Exe Windows único com autoteste (`-- --self-test`), que confere também regiões, mapas, itens, colecionáveis, missões da v0.4 e todos os arquivos de som | `tools/build_windows.ps1` | build da v0.5.0 em 2026-10-14 (ver HANDOFF) |

## Implementado, mas sem verificação completa
- Infraestrutura de cenas dirigidas, luz por estado, passagens de saída e destino de experiências (ADR-028; branch `content/four-experiences`, ainda sem commit): suíte 775/775 em 2026-10-14 com dados de teste; sem cena real, sem captura, efeitos não vistos por uma pessoa (KI-20).
- Painel de debug F3 (só build de debug): na v0.2.0 foi conferido que ele carrega via "Testar missão" e que fica **fora** do exe (autoteste); não há teste automatizado das ações dele, e o uso manual não foi verificado.
- Plugin "Editor de missões" (`addons/quest_editor/`): modelo de dados testado; **interface gráfica no editor não testada** com mouse.
- Ajuste de sensação de jogo (velocidade, legibilidade, ritmo): critérios da fase 3 do roadmap ainda **não validados jogando**.

## Em andamento
- Revisão humana do conteúdo bíblico: **72 itens sem aprovação**, nenhum aprovado (contagem de `tools/validate_content.gd` na v0.4.0; inclui as 4 missões novas, 4 descobertas novas e a apresentação de Gn 37). No canal `public`, missões e descobertas não aparecem. O texto bíblico importado (BPM, 220 versículos) também está `pending_review`.
- Revisões de agente do conteúdo da v0.4 (ep_008): auditoria bíblica, pesquisa histórica e QA aplicadas; registro em `production/episodes/ep_008_jose_e_seus_irmaos/review.json`. Nenhum agente aprova conteúdo.
- Fábrica de missões: ep_006 ("A importância dos poços") em `tested`; ep_008 continua em planejamento (só a parte Gn 37:12-17 virou jogo).
- Escolha da tradução definitiva: o criador pediu NVI; falta permissão da Biblica (KI-06, ADR-016).

## Planejado (não implementado)
Dia/noite, clima, música, vozes e sons gravados (os atuais são procedurais); ambiente do Egito; interiores; rotinas de NPC; objetivo de acompanhar NPC (`escort_npc`);
mapas da rota para o Egito, do Egito de José, de Belém/Rute e dos pastores de Belém (aparecem como
"planejadas" no Mapa M); continuação de Gn 37:18-36; personalização do viajante; gamepad; múltiplos saves (KI-13).
Fonte: [docs/roadmap.md](../roadmap.md) e [docs/game_design.md](../game_design.md).

## Problemas conhecidos (resumo)
Nenhum teste de jogo humano (KI-02); conteúdo bíblico sem revisão humana (KI-03);
`build_all.ps1` sobrescreve o mapa (KI-04); tradução bíblica provisória, NVI sem permissão (KI-06); partes da expansão pendentes (KI-13);
afirmações históricas da estrada e de Dotã aguardam revisão humana (KI-14); efeitos sonoros procedurais sem escuta humana (KI-16); falha intermitente da suíte em observação (KI-17); cenas dirigidas sem cena real nem avaliação visual (KI-20). Lista completa em [KNOWN_ISSUES.md](KNOWN_ISSUES.md).

## Próximos passos
1. Repositório público e pronto para colaboração ([CONTRIBUTING.md](../../CONTRIBUTING.md), [START_WITH_AI.md](../../START_WITH_AI.md)). Mudanças entram por pull request revisado.
2. Criador: jogar a v0.5.0 seguindo o roteiro "Manual da v0.4" de [docs/quests.md](../quests.md) (estrada, Dotã, bolsa, Mapa M, escolha das famílias, salvar e carregar) e **ouvir os sons** na ordem de [docs/audio.md](../audio.md#escuta-humana-necessária).
3. Criador: revisar o conteúdo novo e decidir os pontos abertos do `review.json` do ep_008 (Gn 13 na missão das famílias, fibras, hospitalidade, prata pesada).
4. Criador: decidir a tradução (NVI com permissão da Biblica, ou manter uma livre; KI-06).
5. Próximo conteúdo pela fábrica: a continuação de Gn 37:18-36 (precisa de decisão sobre como apresentar a venda de José) ou outra experiência planejada no Mapa M.
