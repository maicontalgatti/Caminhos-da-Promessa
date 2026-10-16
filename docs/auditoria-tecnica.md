# Auditoria técnica — Caminhos da Promessa

- **Data:** 2026-10-16
- **Responsável:** agente de IA (Claude, Cowork), a pedido do criador
- **Commit auditado:** `0e79269` (branch `main`, árvore limpa ao iniciar; 1288 arquivos versionados)
- **Ambiente de execução:** Godot **4.7.2-stable oficial para Linux** (o mesmo da CI, SHA-512 conferido), numa cópia do projeto; renderização com `xvfb` + OpenGL 3 (Mesa) para capturas. O PC do criador (Windows) foi usado só para ler e gravar arquivos.
- **Branch de auditoria:** não criada. No PC do criador o Git não consegue apagar os próprios arquivos `.lock` sem uma permissão de exclusão mais ampla; trocar de branch poderia deixar o repositório travado. As mudanças ficaram como diff não commitado sobre `main` (`git diff` mostra tudo).

Legenda: **[VERIFICADO POR TESTE]** · **[VERIFICADO POR INSPEÇÃO]** · **[CORRIGIDO E RETESTADO]** · **[TESTE MANUAL PENDENTE]** · **[NÃO VERIFICADO]** · **[BLOQUEADO]**

## 1. Resumo executivo

O projeto está em bom estado técnico: os 94 scripts compilam, as 100 cenas instanciam, todos os caminhos `res://`, ids de som e ações de entrada citados no código existem, e a suíte original passava inteira (1808/1808). A auditoria encontrou **12 itens**: 4 defeitos corrigidos (1 crítico), 5 pendências que dependem do criador ou do Windows, e 3 achados informativos sem correção necessária.

- **Crítico corrigido:** a suíte de testes **apagava os três espaços de save reais** do jogador (o jogo, o editor e os testes usam a mesma pasta `user://`). Quem rodou `criar_exe_atualizado.bat` ou a suíte no PC depois do pacote fase 4 pode ter perdido saves (AUD-01).
- **Outros corrigidos:** botões do HUD abriam telas por cima de diálogos e da troca de região (AUD-02); a migração do save antigo e o `.bak` podiam apagar o original quando a cópia falhava (AUD-03); a personalização do viajante abria sem foco para teclado e controle (AUD-04).
- **Riscos que continuam:** ninguém jogou o jogo (KI-02); interiores com piso de grama e paredes invisíveis (AUD-05); a sequência de 11 etapas da missão dos poços, usada como referência de design, não existe no jogo (AUD-07). O `.exe` da raiz foi regenerado nesta entrega (AUD-06).

## 2. Arquitetura real (confirmada nos arquivos)

- **Cena inicial:** `scenes/ui/main_menu.tscn`; jogo em `scenes/core/game.tscn` (`scripts/core/game.gd`), que hospeda mapa, HUD, diálogo, diário, bolsa, feira, ofícios, Mapa das Escrituras, cenas dirigidas e pausa.
- **15 autoloads** (ordem do `project.godot`): Settings, GameData, Bible, SaveManager, GameState, DialogueManager, QuestManager, Discoveries, Inventory, Market, Craft, Collectibles, WorldManager, SceneRouter, AudioManager (com `MusicDirector` como filho). Não foi feita análise formal de dependências circulares; a inicialização roda sem erro de carga [VERIFICADO POR TESTE].
- **Estado:** `GameState` (flags, missões, bolsa, mundo, tempo); bloqueio de interface por dono (`block_ui`/`unblock_ui`) mais `get_tree().paused` nas telas.
- **Dados:** `data/` em JSON (regiões, personagens, diálogos, missões, itens, feira, ofícios, áudio, música, Bíblia); validados por `tools/validate_content.gd`, pela fábrica e pelos testes.
- **Mapas:** 9 regiões (7 exteriores, 2 interiores), um mapa por cena; troca de região dentro da cena de jogo com escurecimento e autosave.
- **Save:** JSON v3, três espaços, `.tmp` + `.bak`, sanitização de tipos e migração v1→v2→v3.
- **Áudio:** 6 buses (Master com limitador −0,5 dB, Music, SFX, UI, Ambience, Voice), 140 WAV (131 efeitos + 9 músicas), 74 ids no `sfx.json`.
- **Fragilidades relevantes:** cada tela pausa e despausa a árvore por conta própria (funciona porque só uma abre por vez, ver AUD-02); interiores são gerados por ferramenta (`build_interior.gd`) e a mudança visual exige regenerar a cena.

## 3. Problemas encontrados

| ID | Gravidade | Onde | Situação |
|---|---|---|---|
| AUD-01 | **P0** | `tests/test_runner.gd` `_test_save_slots`; `scripts/save/save_manager.gd` | [CORRIGIDO E RETESTADO] |
| AUD-02 | P2 | `scripts/ui/hud.gd` (botões C, M, J, I) | [CORRIGIDO E RETESTADO] |
| AUD-03 | P2 | `scripts/save/save_manager.gd` `migrate_legacy_if_needed`, `save_data` | [CORRIGIDO E RETESTADO] |
| AUD-04 | P2 | `scripts/ui/main_menu.gd` `_open_panel` | [CORRIGIDO E RETESTADO] |
| AUD-05 | P3 | `scenes/maps/canaan_tent.tscn`, `canaan_ezer_house.tscn`, `tools/art_gen/build_interior.gd` | pendente (decisão visual) |
| AUD-06 | P3 | `CaminhosDaPromessa.exe` (raiz) | [CORRIGIDO] regenerado em 2026-10-16 (Windows, autoteste OK) |
| AUD-07 | P3 | missão `canaan_wells` × referência de design de 11 etapas | pendente (decisão de design) |
| AUD-08 | P3 | `docs/ai-wiki/CURRENT_STATE.md`, `HANDOFF.md` | atualizado |
| AUD-09 | P3 | `scripts/core/input_bindings.gd` | pendente (sugestão) |
| AUD-10 | info | vazamentos relatados ao sair com `--quit-after` | sem correção (não é defeito) |
| AUD-11 | info | `GameMap._on_state_changed` | sem otimização (medido, desnecessária) |
| AUD-12 | info | menção a Ezequias/obras futuras | não encontrada |

### AUD-01 — A suíte de testes apagava os saves reais (P0)
- **Descrição:** `_test_save_slots` usava `SaveManager.slot_path(i)`, que aponta para `user://save_slot_0..2.json`, os mesmos arquivos do jogo; apagava os três no início e no fim, e também o save antigo `user://savegame.json`.
- **Evidência:** com três saves "reais" plantados em `user://`, uma execução normal da suíte terminou com os três apagados (`md5sum`: "No such file"); fluxo, validação, fábrica e auditoria de áudio não tocaram neles. `tools/build_windows.ps1` roda a suíte, então todo build no PC do criador apagava os saves.
- **Causa raiz:** o teste isolava `save_path` e `settings.cfg`, mas os espaços têm caminho fixo, que o isolamento não alcançava.
- **Correção:** `SaveManager.slots_dir` (padrão `user://`, o jogo não muda) e `legacy_path()`; o teste usa `user://test_save_slots/`, confere que nenhum caminho de teste está fora dessa pasta e restaura o padrão. Save e formato não mudaram.
- **Resultado:** suíte 1816/1816 com os três saves plantados intactos (`md5sum` OK).

### AUD-02 — Botões do HUD abriam telas por cima de diálogos e viagens (P2)
- **Descrição:** as teclas I, J, M e C respeitavam diálogo, cartões, telas e viagem; os botões clicáveis "I bolsa", "J diário", "M mapa" e "C contexto" emitiam sem checar nada.
- **Evidência:** teste de casos extremos: com um diálogo ativo, os quatro botões abriram Bolsa, Mapa e Diário por cima; "M mapa" abriu durante a troca de região. Do Mapa das Escrituras dava para iniciar outra experiência, e do diário uma apresentação, no meio da conversa.
- **Correção:** `HUD.can_open_screen()` (a mesma regra das teclas) usada pelas teclas e pelos quatro botões.
- **Resultado:** os testes novos falham no código original e passam no corrigido; com o jogo livre, o botão continua abrindo a bolsa.

### AUD-03 — Save antigo e `.bak` apagados mesmo com a cópia falhando (P2)
- **Descrição:** `migrate_legacy_if_needed` copiava `savegame.json` para o espaço 0 e apagava o original sem conferir o resultado da cópia. `save_data` fazia o mesmo com o `.bak`.
- **Evidência:** no código original, com o destino impossível de gravar, o save antigo sumiu e o espaço 0 não foi criado (`legacy_exists=false slot0_is_file=false`).
- **Correção:** o original só é apagado se a cópia der `OK`; senão, fica e o erro vai para o log.
- **Resultado:** teste novo "cópia que falha não apaga o save antigo" passa.

### AUD-04 — Personalização do viajante abria sem foco (P2)
- **Descrição:** `_open_panel` tentava focar o primeiro botão do painel; na personalização era um botão só de mouse ("<"), e nada ficava selecionado. Aviso no console: "This control can't grab focus".
- **Impacto:** quem joga com teclado ou controle (suporte adicionado na fase 4) abria "Novo jogo" sem nada selecionado.
- **Correção:** foca o primeiro botão ou campo de texto que aceita foco (o nome do viajante).
- **Resultado:** verificação nova em `flow_smoke.gd` (falha no original, passa agora); o aviso sumiu.

### AUD-05 — Interiores com piso de grama e paredes invisíveis (P3, pendente)
- **Evidência:** capturas em janela da tenda e da casa de Ezer: piso todo de grama, sem paredes desenhadas; as colisões existem (bordas de 2 tiles) mas não aparecem. A câmera centraliza a sala corretamente.
- **Causa:** `build_interior.gd` pinta `Vector2i(0,0)` e `(1,0)` do atlas de Canaã, que são grama.
- **Por que não foi corrigido:** muda a aparência de cenas aprovadas e exige regenerar as cenas; precisa da decisão do criador. **Proposta:** piso de terra batida (tile central do caminho, `Spec.path_coords(15)`) e borda de pedra (`Spec.STONE`) sobre as paredes; na tenda, piso de terra e borda de tecido quando houver tile próprio.

### AUD-06 — O `.exe` da raiz não corresponde ao código (P3, corrigido)
- **Evidência anterior:** `CaminhosDaPromessa.exe` de 15/10 16:24; o commit da fase 4 é das 17:18. O executável não continha ofícios, dia/noite nem interiores.
- **Correção:** regenerado em 2026-10-16 no Windows (`tools/build_windows.ps1` / suite + export); autoteste headless e com GPU OK. O `.exe` continua fora do Git (`.gitignore`).

### AUD-07 — Referência de design da missão dos poços × implementação (P3, pendente)
- **Referência recebida:** 11 etapas (Adina, poço, Ari, Davi, Noam, Eitan, Sara, anciã, ancião, chefe de poços, viajante).
- **Implementado (confirmado no código e jogado):** 6 objetivos: Adina pede ajuda → pegar o cântaro de Ezer → 3 viagens poço ↔ bebedouro → agradecer Adina (queijo, escolha) → devolver o cântaro a Ezer → ler Gn 26:18-22 no diário. Ari é opcional. Davi, Noam, Eitan, Sara, anciã, ancião, chefe de poços e viajante **não existem** em Canaã (o único Davi do jogo é o rei, citado por Shai em Belém).
- **Ação:** o criador decide se a referência é um plano futuro; nada foi criado nesta auditoria.

### AUD-08 — Documentação de estado desatualizada (P3, atualizado)
- `CURRENT_STATE.md` citava suíte 1535/1535 e fluxo 17/17; o `HANDOFF.md` dizia branch `feature/phase4-gameplay`, que já foi mesclada na `main`. Atualizados com os números desta auditoria.

### AUD-09 — No controle, o botão B não fecha telas (P3, pendente)
- **Inspeção:** as telas fecham com a ação `pause` (Start/Back no controle, Esc no teclado); `ui_cancel` (B) só serve aos menus do Godot. Quem joga com controle espera B para voltar.
- **Por que não foi corrigido:** muda os controles; sugestão para o criador.

### AUD-10 — Vazamentos ao sair à força (informativo)
- `--quit-after` encerra o motor com a música do menu tocando e relata 2 objetos e 1 recurso presos. O caminho normal de saída (`SceneRouter.quit_game`, botão Sair e fechar a janela) desliga o áudio e espera o ciclo de mixagem. Os vazamentos maiores no fim da suíte são dos próprios testes. Sem correção.

### AUD-11 — Atualização do mapa a cada flag (informativo)
- Cada mudança de flag agenda `_refresh_conditional`, a luz e as fogueiras. **Medido:** 75 µs por atualização; uma conversa típica muda 2 flags. Coalescer as chamadas não traria ganho perceptível; nada alterado.

### AUD-12 — Ezequias e acontecimentos futuros (informativo)
- Nenhuma menção a Ezequias, Siloé ou obras posteriores nos dados e na documentação; nada a corrigir.

## 4. Melhorias implementadas

| Arquivo | Mudança | Motivo |
|---|---|---|
| `scripts/save/save_manager.gd` | `slots_dir`, `legacy_path()`; apaga o original só após cópia `OK` (migração e `.bak`) | AUD-01, AUD-03 |
| `scripts/ui/hud.gd` | `can_open_screen()` para teclas e botões | AUD-02 |
| `scripts/ui/main_menu.gd` | foco no primeiro controle focável do painel | AUD-04 |
| `tests/test_runner.gd` | espaços de teste em `user://test_save_slots/`; testes de pasta isolada, de restauração e de cópia que falha | AUD-01, AUD-03 |
| `tests/world_tests.gd` | botões do HUD durante diálogo e viagem; botão com o jogo livre | AUD-02 |
| `tests/flow_smoke.gd` | foco na personalização | AUD-04 |

Nenhum asset, mapa, diálogo, missão ou texto bíblico foi alterado. O formato do save não mudou (`SAVE_VERSION` 3).

## 5. Testes

| Teste | Ambiente | Antes | Depois | Situação |
|---|---|---|---|---|
| `tests/test_runner.tscn` | Godot 4.7.2 Linux headless | 1808/1808 | **1816/1816** | [VERIFICADO POR TESTE] |
| `tests/flow_smoke.gd` | idem | 18/18 (1 aviso de foco) | **19/19** (sem aviso) | [VERIFICADO POR TESTE] |
| `tools/validate_content.gd` | idem | sem erros | sem erros | [VERIFICADO POR TESTE] |
| `tools/factory.gd -- check` | idem | 0 erros / 78 episódios | idem | [VERIFICADO POR TESTE] |
| `tools/audio/audit_audio.gd` | idem | 140 arquivos, 0 problemas | idem | [VERIFICADO POR TESTE] |
| Integridade (script da auditoria) | idem | 94 scripts e 100 cenas carregam; caminhos, sons e ações existem | idem | [VERIFICADO POR TESTE] |
| Boot do jogo (`--quit-after 600`) | idem | sem erros de script | idem | [VERIFICADO POR TESTE] |
| Saves reais plantados + suíte | idem | **3 apagados** | **3 intactos** | [CORRIGIDO E RETESTADO] |
| Casos extremos (script da auditoria) | idem | 4 falhas reais (AUD-02, AUD-04) | 70 ok | [VERIFICADO POR TESTE] |
| Missão dos poços jogada, save/load em cada objetivo (script da auditoria) | idem | 64/64 | 64/64 | [VERIFICADO POR TESTE] |
| Capturas de interiores | xvfb + OpenGL 3 | piso de grama | — | [VERIFICADO POR INSPEÇÃO] (AUD-05) |
| `tools/check_wiki.ps1` | — | — | — | **[NÃO VERIFICADO]**: sem PowerShell; checagem equivalente de links e seções feita em Python |
| Build do exe + autoteste | — | — | — | **[BLOQUEADO]**: só no Windows (`criar_exe_atualizado.bat`) |
| Jogo por uma pessoa | — | — | — | **[TESTE MANUAL PENDENTE]** (KI-02) |

Casos extremos cobertos e aprovados: E apertado 6 vezes perto de um NPC (um diálogo só); Esc durante diálogo (não abre a pausa); pausar e retomar 20 vezes; I/J/M/H com a pausa aberta (nada abre); diário pela pausa e Esc (controle volta); I, J e M abrem e Esc fecha sem abrir a pausa; feira com E repetido (não reinicia a conversa) e Esc (controle volta); andar contra a borda do mapa (jogador fica dentro e a câmera limitada ao mapa); dois pedidos de viagem seguidos (mapa e estado na mesma região); ambiente sonoro trocado ao mudar de região, sem som do mapa antigo tocando.

Missão dos poços (64 verificações): fora de ordem antes e durante a missão (cântaro, bebedouro, poço e diário não avançam nada); cada um dos 6 objetivos em ordem; salvar e carregar em todos, inclusive no meio das viagens com o cântaro cheio; seta sempre num alvo existente e ativo; queijo dado uma vez só; apresentação fechada antes do fim não conclui; descoberta "Os poços de Isaque"; nada muda depois da conclusão.

Os scripts da auditoria (integridade, casos extremos, missão dos poços) rodaram só na cópia de trabalho e não fazem parte do projeto; o que vale como regressão permanente foi para a suíte oficial.

## 6. Regressões

Depois das correções rodaram de novo: suíte, fluxo, validação, fábrica, auditoria de áudio, integridade, casos extremos, missão dos poços e boot. Sistemas tocados e conferidos: saves (três espaços, migração, `.bak`, sanitização: testes existentes passaram), HUD (teclas, cartões, pistas), menu principal (fluxo completo), bolsa, diário e Mapa das Escrituras. Nenhuma regressão encontrada.

## 7. Pendências

- **[TESTE MANUAL PENDENTE]** jogar do começo ao fim (KI-02), em especial: personalização com teclado e controle; botões do HUD com mouse durante conversas; interiores; música e sons (KI-16, KI-22); feira (KI-23).
- Decisões do criador: interiores (AUD-05), referência de 11 etapas dos poços (AUD-07), botão B do controle (AUD-09).
- **Saves possivelmente perdidos:** se a suíte rodou no PC depois do pacote fase 4 e antes desta correção, os espaços de save podem ter sido apagados (AUD-01). Não há como recuperar daqui.
- Revisão humana do conteúdo bíblico continua pendente (KI-03, KI-21, KI-22, KI-23); a auditoria conferiu a missão dos poços e a cronologia e não achou erro, mas IA não aprova conteúdo.

### Checklist manual (5 minutos)
1. Menu → Novo jogo: o nome do viajante já vem selecionado; com o controle, desça até "Começar".
2. Converse com Adina e, no meio da fala, clique em "I bolsa", "M mapa" e "J diário": nada deve abrir. Ao terminar a conversa, os botões voltam a funcionar.
3. Entre na tenda e na casa de Ezer: confira paredes e piso (AUD-05).
4. Salve no espaço 1, saia e carregue: posição, bolsa e missão iguais.
5. Pausa → Sons e volume: mude a música, saia do jogo, abra de novo: o volume ficou salvo.

## 8. Próximos passos (por prioridade)

1. Jogar o checklist acima e uma passada pelas seis experiências (KI-02); conferir se os saves ainda existem.
2. Decidir os interiores (AUD-05) e o botão B (AUD-09); são mudanças pequenas.
3. Decidir se a referência de 11 etapas da missão dos poços vira conteúdo novo (AUD-07).
4. Revisão humana do conteúdo bíblico pendente (KI-03).
