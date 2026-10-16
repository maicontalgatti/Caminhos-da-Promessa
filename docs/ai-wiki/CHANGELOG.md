# Changelog

Resumo por versão/entrega. Detalhes, problemas corrigidos e o que não foi verificado estão em
[docs/implementation_log.md](../implementation_log.md).

## 2026-10-16 — Configurações do menu cabem na janela (sem versão nova)
- Painel com scroll interno (título/voltar fixos); evita título cortado e overflow em 480×270.
- Slider de Vozes em 100%: trilho/rótulo mais largos; pausa → Sons também com scroll.
- Fluxo 31/31, suíte 1823/1823.

## 2026-10-16 — Gn 26 nas viagens + roteiro de playtest (sem versão nova)
- Bebedouro: Gen 26:18 e 26:20 nas 1ª/2ª viagens; Gen 24:20 na 3ª (CR-01).
- `docs/game-design/PLAYTEST_ROTEIRO.md`; KI-02 e TESTING atualizados.
- Suíte 1823/1823, validação OK.

## 2026-10-16 — Checklist Dotã + hubs opcionais (sem versão nova)
- Checklist preenchido: `docs/game-design/checklists/joseph_dothan_road.md`.
- Adina/Malik: perguntas opcionais com Gn 37:15-17 no narrador; trilha crítica inalterada.
- Suíte 1821/1821, validação OK.

## 2026-10-16 — Eco wells_reward + acordo das famílias (sem versão nova)
- Após concluir os poços, Adina/Ezer/Ari ecoam a escolha do queijo (`wells_reward`).
- Microconflito fictício do “acordo da vez” entre Adina e Ari; ficção marcada; sem NPC novo.
- Suíte 1819/1819, fluxo 23/23, wiki OK.

## 2026-10-16 — Conselho crítico + profundidade nos poços (sem versão nova)
- Seis agentes de avaliação crítica; `docs/game-design/` (benchmark, CRITICAL_REVIEW, checklist); ADR-032; gates na fábrica.
- Missão dos poços: perguntas opcionais e consequências leves (flags/decisions), sem padding de NPCs.
- Auditoria: a missão já tinha atividade corporal (3 viagens); o problema era payload bíblico no fim e pouco eco social.

## 2026-10-16 — Build Windows + Linux com SO no nome (sem versão nova)
- `tools/build_export.ps1` gera `CaminhosDaPromessa-Windows.exe` e `CaminhosDaPromessa-Linux.x86_64`.
- Templates de exportação passam a extrair Windows e Linux; preset `Linux` em `export_presets.cfg`.
- `criar_exe_atualizado.bat` e `build_windows.ps1` apontam para o novo script.
- README e `docs/build_windows.md`: instruções de execução para amigos (Windows / Linux, saves, SmartScreen).

## 2026-10-16 — Painéis de Novo jogo centrados (sem versão nova)
- Painéis "escolha o espaço" e "SEU VIAJANTE" usavam `PRESET_CENTER` com grow padrão (direita/baixo) e saíam da janela 480×270: a seta `>` do tom de pele sumia.
- Correção: `_center_menu_panel` com `GROW_DIRECTION_BOTH` e offsets simétricos; setas de pele focáveis. Suíte 1816/1816, fluxo 23/23, exe regenerado.

## 2026-10-16 — Auditoria técnica + exe atualizado (sem versão nova)
- Relatório em [docs/auditoria-tecnica.md](../auditoria-tecnica.md): 12 itens, 4 corrigidos (AUD-01…04).
- **Crítico:** a suíte não apaga mais os saves reais (`SaveManager.slots_dir` → pasta de teste).
- HUD `can_open_screen()`; migração/.bak só apagam após cópia OK; foco na personalização do viajante.
- Build Windows regenera `CaminhosDaPromessa.exe` (AUD-06); `build_windows.ps1` não falha por RID leaks nem ruído de diálogo do Godot headless.
- Suíte 1816/1816, fluxo 19/19, validação, wiki e autoteste do exe OK.

## 2026-10-15 — Ofício da roda + pacote fase 4 (branch `feature/phase4-gameplay`)
- Minijogo na roda de Ezer (`{"craft": "pottery_wheel"}`): tigela `small_clay_bowl` (1×/dia), vendável na feira. Pacote local: interiores, dia/noite, viajante, 3 saves, gamepad, diário busca+álbum, trocas/generosidade.

## 2026-10-15 — Interiores, dia/noite e viajante (sem commit)
- Casa de Ezer e tenda da aldeia (porta/`travel`); ciclo dia/noite (`WorldClock`, fogueiras, rotinas `schedule.night`); personalização nome+pele no novo jogo e na pausa. Antes: 3 saves, gamepad/teclas, diário busca+álbum. Suíte 1800/1800, fluxo 18/18.

## 2026-10-15 — Trocas e generosidade na feira (sem commit)
- Trocas item por item nos diálogos (Adina, Ezer, Yaron, Malik, Ozi, Nefer, Liora). Prata ajuda Talia e Tova (`spend_silver` / `has_silver`). Suíte 1721/1721, fluxo 17/17.

## 2026-10-15 — Ajustes da feira (sem commit)
- Mercadorias coletadas voltam só numa visita seguinte, depois de 5 min de jogo; a espera fica no save. Cada mercador vende peças da sua região e mostra a especialidade. O jumento some durante as cenas dirigidas. Suíte 1711/1711, fluxo 17/17, validação sem erros.

## 2026-10-15 — Saída limpa do jogo (correção da build)
- A build falhava com "1 resources still in use at exit": a música do menu ficava presa ao sair. `SceneRouter.quit_game()` solta o áudio e espera a mixagem antes de sair (janela, menus). Novo argumento `--boot-frames=N` usado pelo teste do exe no lugar de `--quit-after`. Build completa OK (1700/1700, fluxo 17/17).

## 2026-10-15 — Feira do viajante (sem versão nova; trabalho local, sem commit)
- Mercadorias renováveis (`trade`: lã, amêndoas, sílex, ervas, papiro, tâmaras, conchas) em Canaã, estrada, Dotã, Egito, Belém e no acampamento do mar; reaparecem a cada visita.
- Mercadores no mapa: Yaron ganhou "Quero negociar"; novos Ozi (estrada), Nefer (Egito) e Liora (Belém). Ação de diálogo `{"market": id}` abre a feira (abas Vender e Comprar).
- 12 peças em 4 espaços com camadas geradas sobre o jogador e jumentos que o seguem (+15% e +30% de velocidade). Prata pesada abstrata em flags (save v3). ADR-030, KI-23.
- Substitui o protótipo local anterior (feira pela bolsa, desenho por retângulos). Testes 1637/1637, fluxo 17/17, validação, fábrica e áudio sem erros.

## 2026-10-15 — Música temática (sem commit)
- Louvores instrumentais que mudam conforme o momento: `MusicDirector` (filho do `AudioManager`) lê `data/audio/music.json` e escolhe a lista por cena > apresentação/prólogo > Mapa das Escrituras > missão principal > região > menu; séries por tema (`theme:<tema>`), sorteio sem repetir, silêncio de 20–40 s entre faixas, fade nas trocas, volume baixo e redução em diálogos e marcos. ADR-029.
- 9 faixas provisórias geradas por `tools/audio/generate_music.gd` a partir de `tools/audio/scores/`: Old Hundredth, Noite Feliz, Amazing Grace, Hino da Alegria e 5 temas próprios (melodias de memória, sem escuta humana: KI-22). Antioch saiu do catálogo por transcrição insegura.
- `tools/validate_content.gd` confere licença das melodias (domínio público, faixas cantadas, licenciadas) e momentos; autoteste do exe confere as faixas.
- Testes: `tests/music_tests.gd` (49 verificações).

## 2026-10-15 — Missão dos poços com tarefa da água (sem commit)
- "A importância dos poços": Adina pede ajuda logo na primeira conversa; cântaro de Ezer, três viagens entre o poço e o bebedouro, agradecimento com escolha (queijo de ovelha, item novo `sheep_cheese`), devolver o cântaro a Ezer (disputas por poços, Gn 26:20-21), relato de Gn 26:18-22. "Examinar o poço" e "ouvir Ari" deixaram de ser obrigatórios.
- Save: missões gravam `objective_id`; `QuestManager.realign_objectives()` corrige saves antigos quando objetivos mudam.
- Testes 1535/1535 (novos testes de save antigo e de save no meio das viagens), fluxo 17/17, validação, fábrica e áudio sem erros.

## 2026-10-14 — v0.6.0: quatro experiências do Mapa das Escrituras (PR #2)
- Episódios ep_009 ("José no Egito": caravana vista de longe em Dotã, Gn 37:25-28 e 36; casa egípcia como a de Potifar, Gn 39:1-6), ep_016 ("A travessia do mar", Êx 13:17–14:31), ep_025 ("Rute em Belém", Rt 1:19–2:23) e ep_048 ("Os pastores de Belém", Lc 2:8-20), pelo processo da fábrica: pesquisa bíblica e histórica, design, roteiro, revisões independentes (`ok_for_human_review`), integração, QA (`test_report.json`); estados `tested`.
- Regiões novas `egypt_house`, `sea_camp`, `bethlehem_fields`, `bethlehem_night` (arte e mapas pelos geradores de `tools/art_gen`), encosta de observação em Dotã; 13 missões, 5 cenas dirigidas, personagens fictícios, 25 descobertas, 5 apresentações, histórias, itens e colecionáveis; experiências encadeadas no Mapa M; época "Nos dias de Herodes".
- Texto BPM reimportado (327 versículos); `verse_counts` com 11 capítulos novos; certeza da data dos pastores na cronologia passou a "debated".
- Correções da QA: legendas de cena que se sobrepunham (validador agora recusa), fogueira dos pastores concluída por evento próprio, referência de Rute no diário, textos de conclusão apontam a próxima experiência.
- Testes 1482/1482, fluxo 17/17, validação e fábrica sem erros, áudio 0 problemas; exe 0.6.0 com autoteste OK. KI-20 atualizado, KI-21 novo.

## 2026-10-14 — Infraestrutura de cenas dirigidas, luz por estado e experiências com destino (branch `content/four-experiences`)
- Cenas dirigidas por dados (`data/scenes/*.json`): `SceneDatabase`, `SceneDirector`, `SceneActor`, `SceneFx` (brilho, coluna de nuvem/fogo, vento, paredes de água, poeira); ação de diálogo `{"scene": id}`; Esc pula para o estado final; evento `scene_finished`, objetivo `observe_scene`, alvo `scene`; ADR-028.
- Região: `lighting [{if, tint}]` e `exits[].passage`. Experiência: `travel`, `entry_if`, `regions`, `stages`; botão Iniciar/Continuar/Revisitar no Mapa das Escrituras; `isaac_wells` e `joseph_dothan` ganharam destino na aldeia.
- Validador, fábrica e autoteste do exe conhecem cenas; `tests/scene_tests.gd` (suíte 665 → 775). Sem conteúdo de episódio e sem mudança no save.

## 2026-10-14 — Publicação pública e colaboração com IA (documentação e repositório; jogo sem mudanças)
- Auditoria de segurança do histórico completo e auditoria de direitos autorais; inventário em `docs/legal/ASSET_LICENSES.md`.
- Licenças: `LICENSE` (MIT, código) e `LICENSE-ASSETS.md` (CC BY 4.0, arte, sons e textos próprios); ADR-027.
- Novos `START_WITH_AI.md`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md`, `CHANGELOG.md` (raiz), modelos de issue e PR, `.github/workflows/tests.yml` e `.github/dependabot.yml`; `README.md` reescrito para o público.
- Documentação dos agentes atualizada para repositório público; `LICENSES.txt` do build cita as licenças do projeto.

## 2026-10-14 — Checkpoint no GitHub (documentação e repositório; jogo sem mudanças)
- Primeiro commit e envio para o repositório privado `maicontalgatti/Caminhos-da-Promessa` (branch `main`).
- `AGENTS.md` revisto; novos `AI_AGENTS.md` (inventário dos 9 subagentes e 3 regras) e `NEW_AGENT_START_HERE.md`; `GAME_SYSTEMS.md` e `README.md` da raiz atualizados.
- Auditoria de segurança sem achados; `.gitignore` e `.gitattributes` ampliados.
- Testes: teclas simuladas entregues na hora (KI-17); build 665/665.

## 2026-10-14 — v0.5.0: efeitos sonoros
- `AudioManager` (autoload) com buses Master/Music/SFX/UI/Ambience/Voice, limitador, conjunto fixo de players, prioridade, cooldown, variações e marcos coalescidos; manifesto `data/audio/sfx.json`.
- Passos por superfície (terra, grama, pedra) nos quadros de contato da animação, só com deslocamento real; corrida com som próprio.
- Som automático em todos os botões (clique, hover discreto, foco por teclado); diário, páginas, bolsa, Mapa das Escrituras, pausa, salvar, recusas; interação por material; bolsa (coleta, recebido, entregue, descartado, recompensa); diálogo (som de texto opcional); missões, descobertas, coleção, região nova; ambiente de Canaã, da estrada e de Dotã com troca suave e emissores no poço e na cisterna.
- Volume por bus com silenciar, em tempo real e salvo, no menu e na pausa.
- 131 arquivos procedurais (`tools/audio/`), auditados; **sem escuta humana** (KI-16). Guia em [docs/audio.md](../audio.md).
- Testes: 665/665, fluxo 17/17; autoteste do exe confere todos os sons.

## 2026-10-14 — v0.4.0: expansão para RPG de aventura bíblica
- Três regiões (Aldeia em Canaã, Caminho das Caravanas, Pastos de Dotã) com transição, título da região, salvamento automático e volta sem duplicar itens.
- Mapa das Escrituras (M) por épocas, com experiências planejadas visíveis; bolsa (I) com troca; colecionáveis e aba "Descobertas"; condições compostas e escolhas persistentes; categorias de missão e missão acompanhada; seta e "Siga para" quando o objetivo está em outra região.
- Missões: "O caminho para Dotã" (Gn 37:12-17), "Suprimentos para a viagem", "Duas famílias, uma decisão" (3 desfechos), "Registros da caravana".
- Save v3 com migração; validação da fábrica por região; autoteste do exe ampliado.
- Revisões de agente (bíblica, histórica, QA) aplicadas; nada aprovado por IA.
- Testes: 561/561, fluxo 17/17. Pendentes: `escort_npc`, mapas do Egito e de Belém, Gn 37:18-36 (KI-13).

## 2026-10-14 — v0.2.1: orientação na missão, leitura mais suave e texto bíblico
- Seta dourada sobre o alvo do objetivo (ou na borda da tela); objetivos dizem quem e onde; o diário abre o relato com E a qualquer momento; aviso de fim de conteúdo da versão.
- Fonte Lora nos textos de leitura (Pixelify segue em títulos e botões); espaçamento de linhas corrigido.
- Texto dos versículos no jogo: 196 versículos da Bíblia Portuguesa Mundial (domínio público) importados do arquivo oficial por `tools/import_scripture.gd`; apresentação de Gn 26 em 7 passos com versículos e notas; diário e falas do narrador citam o texto; créditos no menu e no `LICENSES.txt`. NVI pendente de permissão (KI-06).
- Testes: 239/239, fluxo 17/17.

## 2026-10-14 — AI Wiki (documentação; jogo sem mudanças)
- `AGENTS.md`, `docs/ai-wiki/` (12 documentos), regras em `.cursor/rules/`, `tools/check_wiki.ps1`.
- Correções de documentação desatualizada: `docs/roadmap.md`, `docs/game_design.md`, `docs/architecture.md`; link para a wiki no `README.md`.
- Verificação da wiki incluída como etapa informativa no build (`tools/build_windows.ps1`).

## 2026-10-14 — v0.2.0: missões, contexto histórico e aprendizado bíblico
- Prólogo, HUD de contexto, pistas, descobertas, apresentação de Gênesis 26, diário em 5 seções.
- Missão "A importância dos poços"; cronologia sem ano zero; 14 lugares, 8 pessoas, 12 descobertas.
- Status de verificação com revisor humano; canais prototype/public; save v2 com migração.
- Editor de missões (plugin), painel F3 de debug, validador de conteúdo.
- Testes: 208/208, fluxo 17/17, exe com autoteste ampliado.

## 2026-10-14 — Exportação Windows (v0.1.0)
- Exe único com PCK embutido, autoteste, `criar_exe_atualizado.bat`, exe copiado para a raiz.

## 2026-10-14 — v0.1.0: fundação jogável (fases 1–3)
- Projeto Godot 4.7.2, arte provisória procedural, aldeia em Canaã, jogador, 4 moradores e 3 ovelhas.
- Diálogos com escolhas e flags, 20 pontos de interação, menu, pausa, save JSON versionado.
- Catálogo inicial: 66 livros e 7 histórias-piloto.
