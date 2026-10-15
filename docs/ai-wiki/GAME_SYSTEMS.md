# Sistemas de jogo

Como cada sistema se comporta para o jogador, quanto já foi verificado e onde está a doc detalhada.
Arquivos e interfaces em [ARCHITECTURE_MAP.md](ARCHITECTURE_MAP.md).

| Sistema | Comportamento | Verificação | Doc detalhada |
|---|---|---|---|
| Movimento | 8 direções, Shift corre, colisão e profundidade por Y | automático + capturas | art_bible, architecture |
| Interação | balão "E" + verbo no alvo mais próximo à frente; E ou Espaço | automático | architecture |
| Diálogo | digitação letra a letra, retrato, escolhas, condições, flags, efeitos | automático | game_design, quests |
| NPCs | parado ou passeio; `schedule.night` (home/hidden); lembram conversas por flags | automático | architecture |
| Ciclo dia/noite | 4 fases por `play_time` (8 min ≈ 1 dia); tinta no mapa; fogueiras à noite; condição `day_phase` | automático | art_bible, WorldClock |
| Interiores | porta/tenda → `travel` para mapa pequeno; saída de volta à aldeia | automático | architecture |
| Viajante | nome e tom de pele no novo jogo e na pausa; roupas na feira | automático | TravelerLook, ADR-030 |
| Ofícios | minijogo de timing (`Craft` + `CraftScreen`); 1×/dia na roda de Ezer → tigela vendável | automático | data/crafts, ADR-031 |
| Prólogo | ao iniciar novo jogo; Esc pula; "Rever abertura" na pausa; não repete ao carregar | automático + capturas | quests |
| HUD de contexto | lugar, época, referência ativa, "Você está em" e "Siga para"; Tab recolhe; C contexto | automático + capturas | quests |
| Regiões e viagem | Aldeia em Canaã, Caminho das Caravanas, Pastos de Dotã; saídas com condição, escurecimento, título da região, salvamento automático ao chegar | automático + capturas | architecture, ADR-021 |
| Mapa das Escrituras (M) | experiências por época; cartão "OUTRO MOMENTO DA HISTÓRIA"; botão Iniciar / Continuar / Revisitar leva ao destino (`travel`, `entry_if`, `stages`); planejadas visíveis e não jogáveis; atlas de lugares dentro dele | automático (capturas anteriores ao botão) | ADR-024, ADR-028, quests |
| Cenas dirigidas | o jogador assiste: câmera, figurantes (personagens ou silhuetas), luz, efeitos (brilho, coluna, vento, paredes de água, poeira), legendas bíblicas ou identificadas; Esc pula para o estado final; não repete; nunca dá item | automático (só dados de teste; sem cena real nem captura) | quests, ADR-028 |
| Luz por estado | `lighting` da região (prioridade); senão ciclo dia/noite; `day_cycle: false` fixa interiores | automático | quests, ADR-028, WorldClock |
| Passagem de saída | saída com `passage` mostra o cartão antes de atravessar | automático | quests, ADR-028 |
| Bolsa (I) | 12 espaços + essenciais; coleta no mapa sem duplicar; entregar, receber e trocar em diálogo; descartar (exceto protegidos) | automático + capturas | ADR-023, quests |
| Feira do viajante | mercadores no mapa (Yaron, Ozi, Nefer, Liora): "Quero negociar" abre Vender/Comprar; mercadorias reaparecem numa visita seguinte, depois de 5 min de jogo; cada mercador vende peças da sua região; trocas item por item nos diálogos (sem prata); prata também ajuda Talia e Tova; roupa, cabeça, cajado e jumento no viajante; jumento some nas cenas bíblicas | automático + capturas (sem jogo humano, KI-23) | ADR-030 |
| Colecionáveis | conjuntos (ex.: registros da caravana); aba "Descobertas" do diário | automático + capturas | quests |
| Escolhas | decisões persistentes (`choice:<id>`) com desfechos de missão por variante | automático | quests, ADR-022 |
| Missões e objetivos | principal, secundária e exploração; missão acompanhada; avançam por eventos; objetivos retroativos; H revela 3 pistas progressivas; lembrete após 150 s; seta para a saída quando o alvo está em outra região | automático | quests |
| Descobertas | avisos em 3 níveis configuráveis (Completos, Discretos, Mínimos), cartão e diário | automático + capturas | quests |
| Apresentações | passagem em passos, com referência em cada trecho; pular não conta como concluída | automático + capturas | quests |
| Diário (J) | 7 abas (inclui Álbum da feira) + busca por texto; pausa o jogo | automático + capturas | quests |
| Save | v3; 3 espaços; salvar na pausa; autosave ao fechar e ao chegar numa região; Continuar restaura região, posição, bolsa e progresso | automático + fluxo | architecture, ADR-025 |
| Áudio | passos por superfície, som em todos os botões, interação por material, bolsa, diálogo, marcos de missão, ambiente por região; 6 volumes salvos (menu e pausa). Sons procedurais **sem escuta humana** (KI-16) | automático (não avalia timbre) | [audio.md](../audio.md), ADR-026 |
| Debug (F3) | só no editor/debug: flags, eventos, descobertas, missões | carregamento conferido | quests |

Nenhum sistema foi validado por uma pessoa jogando (KNOWN_ISSUES KI-02).

## Como adicionar uma missão
1. Leia [BIBLICAL_RULES.md](BIBLICAL_RULES.md) e o formato em [docs/quests.md](../quests.md#formato-de-missão-dataquestsregiãojson-chave-quests).
2. Crie `data/quests/<região>/<id>.json` (chave `quests`) à mão, ou use o plugin "Editor de missões" no editor do Godot (modelo de nova missão). `QuestDatabase` carrega automaticamente todos os JSON de `data/quests/` e subpastas; não há registro manual. Id duplicado é erro.
3. Para cada objetivo: `complete_on` com um evento existente; `targets` que existam no mapa; exatamente 3 `hints`.
4. Eventos `custom` precisam ser emitidos por algum nó de diálogo (`"event": "<id>"` em `data/dialogues/*.json`).
5. Referências novas: confira o capítulo em `data/bible/verse_counts.json` (adicione a contagem real se faltar, nunca uma estimativa).
6. `verification.status = "pending_review"` e `reviewer` vazio. O editor cria missões como `draft`, que fica **oculto** até no canal prototype: troque para `pending_review` quando a missão estiver pronta para teste.
7. Rode a validação de conteúdo e a suíte principal ([TESTING.md](TESTING.md)); teste pelo F3 ou "Testar missão".
8. Registre a missão em `CURRENT_STATE.md`, `HANDOFF.md` e `docs/implementation_log.md`.

## Outros acréscimos
Novo morador, objeto interativo ou mapa: ver "Adicionando conteúdo" em [docs/architecture.md](../architecture.md).
