# Problemas conhecidos, riscos e divergências

Cada item tem um ID estável. Ao resolver, mova para "Resolvidos" com data e como foi resolvido.
Severidade: **alta** (risco de perda ou de conteúdo errado), **média** (afeta qualidade ou fluxo), **baixa** (cosmético ou incômodo).

## Abertos

### KI-02 — Nenhum teste jogando por uma pessoa (alta)
- **Situação:** v0.1 e v0.2 foram verificadas por testes automatizados, simulação de entrada e capturas, mas ninguém jogou com teclado. Critérios de saída da fase 3 em [docs/roadmap.md](../roadmap.md) continuam desmarcados.
- **Ação:** seguir o roteiro manual de [docs/quests.md](../quests.md) e registrar os ajustes.

### KI-03 — Conteúdo bíblico sem revisão humana (alta)
- **Situação:** 63 itens sem aprovação: 62 em `pending_review` (61 do catálogo mais a missão) e 1 história em `draft`; nada `approved`. Detalhamento em [CURRENT_STATE.md](CURRENT_STATE.md). Referências foram conferidas pelo agente de IA, o que **não** conta como verificação.
- **Consequência:** no canal `public`, a missão, as descobertas e a cronologia não aparecem.
- **Ação:** revisão pelo criador seguindo [docs/bible_catalog.md](../bible_catalog.md).

### KI-04 — `tools/build_all.ps1` sobrescreve o mapa (média)
- **Situação:** sem `-PropsOnly`, o script regenera `scenes/maps/canaan_village.tscn` e apaga edições manuais (ADR-006). Ele também não roda `tools/validate_content.gd` (só `build_windows.ps1` roda).
- **Ação:** usar `-PropsOnly` depois de qualquer edição manual do mapa.

### KI-05 — Interface do editor de missões não testada com mouse (média)
- **Situação:** só o carregamento do plugin e a lógica (`QuestEditorModel`) foram testados. Ao salvar, o editor regrava o JSON com `JSON.stringify` e tabulação, o que muda a formatação (objetos curtos de uma linha passam a ocupar várias linhas).
- **Ação:** testar no editor gráfico; revisar o diff do JSON depois de salvar pelo editor.

### KI-06 — Tradução bíblica provisória; NVI pedida sem permissão (média)
- **Situação:** desde a v0.2.1 o jogo cita 196 versículos da **Bíblia Portuguesa Mundial** (domínio público, eBible.org, arquivo `porbrbsl_vpl.txt`), importados por `tools/import_scripture.gd` e marcados `pending_review`. Os próprios tradutores descrevem a BPM como rascunho em revisão. O criador pediu a **NVI**, protegida pela Biblica; não há permissão nem arquivo oficial registrados (ADR-016).
- **Ação:** o criador decide entre obter permissão da Biblica (e então colar os versículos em `data/bible/texts/<id>.json` com id `nvi`, mesmo formato, e mudar `caminhos/content/bible_translation`) ou manter uma tradução livre. A Bíblia Livre (CC BY 4.0 BR) já tem metadados no importador. Um humano deve conferir a correspondência das referências antes de aprovar o texto. Não digitar versículos de memória.

### KI-07 — Capturas antigas em `docs/images/` (baixa)
- **Situação:** `village_start.png`, `village_pen.png`, `village_houses.png`, `interaction_prompt.png` e `dialogue_choices.png` são da v0.1 (HUD antigo) e não são mais geradas por `tools/screenshot/capture.gd`. A aba "Lugares" do diário não tem captura.
- **Ação:** decidir se ficam como histórico ou se são substituídas.

### KI-08 — Recursos planejados ausentes (baixa, esperado)
Sem áudio gravado: efeitos e ambiente existem desde a v0.5, mas são procedurais (KI-16); música provisória gerada por código (KI-22); sem voz (KI-12). Dia/noite, interiores (Ezer/tenda), gamepad/teclas e 3 saves existem no trabalho local sem commit. Inventário, gatilho de área e várias regiões existem desde a v0.4. Arte provisória (inclusive a dos mapas e ícones novos). O exe não é assinado e só foi testado nesta máquina.

### KI-09 — Lista das regras bíblicas a conferir (baixa)
- **Situação:** [BIBLICAL_RULES.md](BIBLICAL_RULES.md) foi escrito a partir das regras já registradas no projeto (PROMPT MESTRE, bible_catalog, content_policy). A lista original de 12 regras do pedido de criação da wiki não estava disponível literalmente no histórico consultado.
- **Ação:** o criador confere se as 12 regras correspondem ao que pediu.

### KI-10 — Subagentes customizados não selecionáveis dentro da sessão (média)
- **Situação:** `.cursor/agents/*.md` segue o formato documentado do Cursor, mas na sessão que criou a fábrica a ferramenta de delegação só aceitava tipos embutidos. O coordenador lançou agentes `generalPurpose` instruídos a obedecer ao arquivo do papel; `readonly: true` virou instrução, não bloqueio técnico.
- **Atualização 2026-10-14 (checkpoint):** na sessão do checkpoint, os 9 papéis apareceram na lista de tipos da ferramenta de delegação do Cursor, ou seja, o Cursor carregou os arquivos. Ainda não foi feita uma execução com o tipo próprio para confirmar que `readonly` vira bloqueio técnico.
- **Ação:** na próxima revisão, lançar um revisor pelo tipo próprio e conferir que ele não consegue editar; até lá o coordenador confere com `git status` que revisores não alteraram arquivos.

### KI-11 — Contagem de versículos parcial (baixa)
- **Situação:** `data/bible/verse_counts.json` cobre só alguns capítulos; referências fora deles não são conferidas pelo validador do jogo. A fábrica contorna com `factory check-refs <vpl>`, que confere contra o arquivo oficial (78/78 ok em 2026-10-14), mas esse arquivo fica fora do repositório (`C:\TEMP\biblia\...`).
- **Ação:** gerar `verse_counts.json` completo a partir do arquivo oficial quando for conveniente.

### KI-12 — Voz não autorizada; teste só com voz do Windows (baixa)
- **Situação:** nenhum provedor de TTS configurado, autorizado ou com orçamento. O jogo segue só com texto; o manifesto de áudio do piloto lista as falas `pending`. O script tem um modo de teste técnico com a voz SAPI do Windows (grava só fora do projeto), mas ele **não foi executado**, porque o pedido condiciona testes de voz a provedor autorizado; a licença dessas vozes para distribuição não foi confirmada. Godot não exporta Ogg e não há ffmpeg instalado.
- **Ação:** o criador decide provedor, licença comercial e orçamento (ver [mission_factory.md](../mission_factory.md#áudio)).

### KI-13 — Partes da expansão v0.4 mantidas pendentes (média, esperado)
- **Situação:** não foram construídos: o objetivo `escort_npc` (está na lista de tipos, sem eventos; o validador recusa); os mapas da rota para o Egito, do Egito de José, de Belém/Rute e dos pastores de Belém (as experiências aparecem como "planejadas" no Mapa M); a continuação de Gn 37:18-36 (a conclusão de "O caminho para Dotã" diz que está em planejamento). O conteúdo novo (4 missões, 4 descobertas, 1 apresentação, colecionáveis) está `pending_review`, sem revisão humana.
- **Ação:** produzir pela fábrica ([mission_factory.md](../mission_factory.md)), um episódio por vez.

### KI-14 — Afirmações históricas da estrada e de Dotã aguardam revisão (média)
- **Situação:** as descobertas `dothan_valley`, `ancient_travel` e `caravans_trade`, os colecionáveis e o cenário da estrada se apoiam em pesquisa de agente feita de memória (fontes arqueológicas "a confirmar"). Os relatórios estão em `production/episodes/ep_008_jose_e_seus_irmaos/research_historical.md` e `research_historical_maps.md`; os alertas foram aplicados (jumentos, sem moedas nem ferro, nome da estrada identificado como do jogo, cisterna afastada do relato). Os achados e o estado de cada um estão em `review.json`.
- **Ação:** revisão humana, com conferência das fontes citadas e das decisões abertas (fibras, hospitalidade como costume, Gn 13 na missão das famílias, prata pesada perto da cena da venda).

### KI-15 — "Reiniciar" missão (painel F3) não refaz entregas de diálogo (baixa, só debug)
- **Situação:** `QuestManager.reset_quest` apaga os eventos dos objetivos, mas não as flags `given:<diálogo>/<nó>` (itens dados uma vez) nem o evento de início. Em `road_supplies` e `dothan_families`, o odre e o cesto não são dados de novo e a missão das famílias recomeça na hora, sem cesto (achado Q5 do QA do ep_008).
- **Ação:** para testar de novo, usar "Novo jogo". Se o reinício for necessário, limpar também as flags `given:` dos diálogos ligados à missão.

### KI-16 — Efeitos sonoros procedurais sem escuta humana (média)
- **Situação:** os 131 arquivos de `assets/audio/` foram gerados por código (v0.5.0, ADR-026). Os testes conferem existência, nível, saturação e quando cada som toca ou não toca, mas **ninguém ouviu os sons**. Os mais artificiais são ovelhas, cabras e pássaros. Passos de areia, madeira e água e o som de metal existem, mas os mapas atuais não têm essas superfícies nem objetos de metal. O bus Music não tem conteúdo e não há ambiente para o Egito (mapa ainda não existe).
- **Ação:** o criador ouve na ordem de [docs/audio.md](../audio.md#escuta-humana-necessária) e decide se troca algum som por gravação ou por biblioteca livre (ex.: CC0); nenhuma biblioteca foi baixada sem autorização. Não rodar o gerador sobre sons já trocados por gravação.

### KI-17 — Falha intermitente da suíte dentro do build (baixa, em observação)
- **Situação:** em 2026-10-14, uma execução do build (14:48) teve 11 falhas encadeadas nos testes de gameplay ("J fecha o diário", "jogador anda para a esquerda (480 -> 480)"...), com sintoma de jogo pausado. Não se repetiu em três execuções avulsas nem no build seguinte (665/0). Hipótese: o teste de áudio esperava a viagem entre regiões por número de quadros e, em headless, podia liberar o jogo no meio da transição. A espera passou a ser por tempo real e o teste agora falha (e despausa) se deixar o jogo pausado.
- **Segunda ocorrência (checkpoint, 15:11):** build com 4 falhas ("H revela a primeira pista", "Tab expande o painel de contexto", "J abre o diário e pausa", "Tab troca a seção do diário"), sem jogo pausado. Causa provável identificada no código de teste: `_press` enfileirava a tecla com `Input.parse_input_event` e esperava 2 quadros de física; com a máquina ocupada, o Godot roda quadros de física de recuperação na mesma iteração, antes de processar a fila de entrada, e a verificação acontecia antes de a tecla chegar. Correção só nos testes: `Input.flush_buffered_events()` logo após enfileirar (`tests/test_runner.gd` e `tests/flow_smoke.gd`); todos os receptores do jogo reagem ao evento, não a consulta por quadro. Depois disso: build 665/0.
- **Situação atual:** em observação, **não declarado resolvido**: duas hipóteses tratadas, sem prova de que eram as únicas causas.
- **Ação:** se voltar a acontecer, ver qual teste anterior deixou `get_tree().paused` ligado (mensagem "teste de áudio não deixa o jogo pausado"), se alguma tecla simulada ainda depende da fila, e o log completo em `dist/logs/`.

### KI-18 — Godot reescreve o cabeçalho de `default_bus_layout.tres` num clone novo (baixa)
- **Situação:** no clone limpo do checkpoint, o primeiro `--import` trocou `load_steps=2 format=3` por `format=3 uid="uid://..."` no cabeçalho do arquivo. É cosmético e o jogo funciona igual, mas o arquivo aparece modificado no `git status` do clone.
- **Ação:** se incomodar, versionar o cabeçalho com `uid` gerado por um clone (o mesmo `uid` passa a valer em todas as máquinas). Não commitar sem conferir que só o cabeçalho mudou.

### KI-19 — Histórico público cita o nome de outra conta do GitHub da máquina do criador (baixa)
- **Situação:** o `HANDOFF.md` dos commits `218cb73` e `7243bcd` menciona o nome de uma segunda conta do `gh` configurada na máquina do criador. Não é credencial nem segredo (nomes de conta do GitHub são públicos); foi removido da versão atual antes da publicação.
- **Ação:** apagar do histórico exigiria reescrevê-lo e fazer force push, o que só pode ser feito com autorização explícita do criador. Até lá, nada a fazer.

### KI-20 — Cenas dirigidas vistas só em capturas automáticas (média)
- **Situação:** as cinco cenas reais da v0.6 (`data/scenes/`) rodaram até o fim numa captura em janela com GPU (`tools/screenshot/capture_v06.tscn`, quadros em `docs/images/v06_*.png`), mas **nenhuma pessoa** as assistiu jogando. Silhuetas e efeitos são desenhados por código (arte provisória). Chaves desconhecidas dentro de passos ou `params` são **ignoradas** sem aviso. Não há efeitos nem sons de ambiente contínuos por estado da região: os campos `_ambient_effects_proposed` e `_ambient_sfx_proposed` de `sea_camp.json` e `bethlehem_night.json` são só registro da proposta. Legendas sem `"wait": true` seguidas de outra legenda agora são recusadas pelo validador.
- **Ação:** o criador assiste às cenas no jogo; implementar ambiente por estado se for desejado.

### KI-24 — Interiores com piso de grama e paredes invisíveis (baixa)
- **Situação:** a tenda e a casa de Ezer (`build_interior.gd`) usam tiles de grama no piso; as paredes são só colisão, sem desenho. Visto em captura na auditoria de 2026-10-16 (AUD-05 em [docs/auditoria-tecnica.md](../auditoria-tecnica.md)).
- **Ação:** o criador decide o visual; proposta: terra batida no piso e pedra na borda, regenerando as cenas com `build_interior.gd`.

### KI-25 — No controle, B não fecha telas (baixa)
- **Situação:** telas fecham pela ação `pause` (Start/Back, Esc); B só atende os menus do Godot (`ui_cancel`). AUD-09 da auditoria.
- **Ação:** o criador decide se B também fecha bolsa, diário, mapa, feira e ofícios.

### KI-26 — Referência de 11 etapas da missão dos poços não implementada (baixa)
- **Situação:** uma referência de design cita Adina, poço, Ari, Davi, Noam, Eitan, Sara, anciã, ancião, chefe de poços e viajante. O jogo tem 6 objetivos (Adina, cântaro, três viagens, agradecimento, devolver o cântaro a Ezer, relato), e os outros personagens não existem. AUD-07 da auditoria.
- **Ação:** o criador decide se a referência é um plano futuro.

### KI-23 — Feira do viajante sem revisão humana nem teste de equilíbrio (média)
- **Situação:** a feira (ADR-030) foi verificada por testes automáticos e capturas, mas ninguém jogou. Preços, valores de venda, quantidade de mercadorias por região e o tempo de volta das mercadorias (`renew_seconds`, 300 s de jogo, desde 2026-10-15) podem estar fáceis ou lentos demais; a divisão dos estoques por mercador, as trocas item por item e os valores de ajuda com prata (Talia 3, Tova 2) também não foram jogados. Conteúdo novo sem revisão humana: linhas de especialidade dos mercadores, falas de troca e de generosidade, mercadores fictícios Ozi, Nefer e Liora (falas e nomes), fala nova de Yaron com nota sobre Gn 23:16 (prata pesada), nota de Gn 43:11 nas amêndoas, descrições das peças (tingimento azul caro, linho egípcio, manto de pelo de cabra) e das mercadorias. A palavra "prata" pode soar próxima da venda de José (ponto já aberto no `review.json` do ep_008). Arte das camadas, dos mercadores e dos ícones é provisória.
- **Ação:** jogar um trecho em cada região com mercador, ajustar `data/market/market.json`; o criador revisa as falas e notas e decide o nome da medida de troca.

### KI-21 — Decisões provisórias das quatro experiências aguardam o criador (média)
- **Situação:** José no Egito (ep_009), A travessia do mar (ep_016), Rute em Belém (ep_025) e Os pastores de Belém (ep_048) seguem decisões do coordenador registradas em [`production/reports/four_experiences_decisions.md`](../../production/reports/four_experiences_decisions.md) (escopo de cada relato, casa egípcia genérica, morte dos egípcios só narrada, anjo só como luz etc.). Os vereditos dos agentes são `ok_for_human_review`, não aprovação. `production/pilot.json` previa escolta na travessia; o jogo seguiu a decisão do criador (só observar). Os objetivos de aprendizagem do catálogo (ex.: ep_009 "Integridade diante da injustiça", Gn 39:1-23) não batem com o escopo implementado.
- **Ação:** o criador confere as decisões e os itens `open_for_human` de cada `review.json`; ajustar catálogo e `pilot.json` conforme a decisão.

### KI-22 — Música temática sem escuta humana; melodias dos hinos transcritas de memória (média)
- **Situação:** as 9 faixas de `assets/audio/music/` são arranjos procedurais (`tools/audio/generate_music.gd`). As melodias de Old Hundredth, Noite Feliz, Amazing Grace e Hino da Alegria (`tools/audio/scores/`) foram escritas de memória por um agente de IA; podem ter notas ou ritmos errados. A escolha de hino por momento (`data/audio/music.json`) também é proposta do agente (`pending_review`). Testes conferem arquivos, níveis, regras de licença e quando cada faixa toca, não a qualidade.
- **Ação:** o criador (ou um músico) ouve cada faixa no jogo e compara com um hinário; corrige a partitura e roda o gerador, ou troca por gravação (`.ogg`, docs/audio.md). Ajustar volumes e intervalo entre faixas depois de jogar.

## Divergências documentação × código encontradas na auditoria de 2026-10-14
| Onde | Divergência | Situação |
|---|---|---|
| `docs/roadmap.md` | Fases 4–6 com status anterior à v0.2 (fase 6 "pendente", fase 4 "próxima") | Corrigido em 2026-10-14 |
| `docs/game_design.md` | Tabela de mecânicas dizia que diário e missões eram futuros | Corrigido em 2026-10-14 |
| `docs/architecture.md` | Formato de região sem o campo `context` (v0.2) | Corrigido em 2026-10-14 |
| `docs/implementation_log.md` (entrada v0.1) | Cita status antigos de verificação (anteriores aos 4 status atuais) | Mantido: é histórico; status atuais em bible_catalog.md |

## Resolvidos

### KI-01 — Repositório Git sem commits (resolvido em 2026-10-14)
- **Situação:** o branch `master` não tinha nenhum commit nem remoto; não havia como desfazer alterações ou recuperar arquivos.
- **Solução:** a pedido do criador, foi feito o commit de checkpoint `218cb73` na branch `main` e o envio ao repositório privado `maicontalgatti/Caminhos-da-Promessa`, conferido pela API e por clone limpo (HANDOFF). Commits futuros continuam só com pedido do criador.

### KI-R1 — Suíte aprovada com script de testes que não compilava (resolvido em 2026-10-14)
- **Situação:** durante a v0.4, erros de parse em `tests/world_tests.gd` faziam o runner pular esses testes e ainda assim terminar em "0 falharam".
- **Solução:** `tests/test_runner.gd` confere se `world_tests.gd` compila e registra falha se não compilar; os erros de parse foram corrigidos.

### KI-R2 — Ligadura "fi" da Pixelify parecia "A" (resolvido em 2026-10-14)
- **Situação:** em rótulos com a fonte pixel, "fibras" aparecia como "Abras" (vista na captura do coletável).
- **Solução:** o tema usa a Pixelify por uma `FontVariation` com a ligadura `liga` desligada (`assets/ui/theme.tres` e o gerador `tools/art_gen/build_world.gd`).
