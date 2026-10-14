# Passagem de bastão (handoff)

Descreve só a **última tarefa**. Substitua o conteúdo ao fim de cada tarefa (o histórico fica no
[CHANGELOG.md](CHANGELOG.md) e em [docs/implementation_log.md](../implementation_log.md)).

- **Data:** 2026-10-14 (checkpoint)
- **Responsável:** agente de IA no Cursor, a pedido do criador
- **Versão do projeto:** 0.5.0 (`project.godot`)

Checkpoint de continuidade preparado para armazenamento no GitHub, com documentação destinada à recuperação de contexto por futuros agentes de inteligência artificial.

## Última tarefa
"CHECKPOINT OFICIAL, MEMÓRIA DOS AGENTES E PUBLICAÇÃO NO GITHUB":
- auditar o projeto e atualizar a memória dos agentes;
- auditoria de segurança, `.gitignore` e validação completa;
- primeiro commit e envio a um repositório **privado** da conta do criador.

O gameplay e os sons não foram alterados.

## Objetivo
Qualquer agente deve conseguir clonar o repositório e continuar sem conhecer conversas anteriores.

## Estado do desenvolvimento (conferido no código)
**Prontas e cobertas por testes automatizados** (detalhe em [CURRENT_STATE.md](CURRENT_STATE.md)):
- Movimento e interação: personagem em 8 direções com corrida; NPCs (4 moradores e 3 ovelhas na aldeia, mais os da estrada e de Dotã); interação universal.
- Narrativa: diálogos com escolhas, condições e efeitos; prólogo; escolhas persistentes com desfechos.
- Missões: `QuestManager` com categorias, pistas, missão acompanhada e 15 tipos de objetivo.
- Mundo: 3 mapas com transição (`scenes/maps/`: `canaan_village.tscn`, `caravan_road.tscn`, `dothan.tscn`); Mapa das Escrituras.
- Itens: bolsa com 8 itens (`data/items/items.json`); colecionáveis (registros da caravana).
- Diário e descobertas: diário em 6 abas; descobertas bíblicas.
- Save v3 com migração.
- Áudio: `AudioManager` com 6 buses e 131 WAV procedurais ([docs/audio.md](../audio.md)).
- Fábrica de missões: 78 episódios no catálogo, `tools/factory.gd`.
- Build: exe Windows com autoteste.

**Missões jogáveis** (5, em `data/quests/`):
- "A importância dos poços" (Gn 26:18-22);
- "O caminho para Dotã" (Gn 37:12-17);
- "Suprimentos para a viagem";
- "Duas famílias, uma decisão";
- "Registros da caravana".

Todas estão `pending_review`, sem revisão humana.

**Planejadas** (aparecem no Mapa das Escrituras sem conteúdo jogável):
- Egito de José; travessia do mar; Rute em Belém; pastores de Belém;
- a continuação de Gn 37:18-36;
- os demais episódios do catálogo da fábrica (`production/catalog/`).

**Parciais ou sem verificação:**
- painel F3 e editor de missões sem teste manual;
- `escort_npc` não implementado (KI-13);
- sons sem escuta humana (KI-16);
- música e vozes inexistentes (KI-12).

**Agentes** ([AI_AGENTS.md](AI_AGENTS.md)): 9 subagentes em `.cursor/agents/` e 3 regras em `.cursor/rules/`.
- Usados de verdade: 7 (registrados em `production/reports/factory_log.md` e `review.json`).
- Apenas configurados: `godot-implementer` e `audio-producer`.

## Alterações desta tarefa
- **Memória:**
  - `AGENTS.md` reescrito (convenções, link para o guia inicial);
  - novos `docs/ai-wiki/AI_AGENTS.md` (inventário) e `docs/ai-wiki/NEW_AGENT_START_HERE.md` (16 perguntas);
  - `GAME_SYSTEMS.md` atualizado (regiões, Mapa M, bolsa, colecionáveis, escolhas, áudio);
  - índice da wiki, `CURRENT_STATE.md`, `TESTING.md`, `KNOWN_ISSUES.md` (KI-10 e KI-17 atualizados), `CHANGELOG.md`, `docs/implementation_log.md`;
  - `README.md` da raiz (estava na v0.2.1).
- **Repositório:** `.gitignore` (arquivos particulares do Cursor e de MCP, `.env`, chaves, logs, temporários) e `.gitattributes` (áudio e executáveis como binários, `.bat`/`.ps1` com CRLF).
- **Testes (sem mudar o jogo):** `tests/test_runner.gd` e `tests/flow_smoke.gd` entregam as teclas simuladas na hora (`Input.flush_buffered_events()`), depois de uma falha intermitente (KI-17).

## Resultado
- **Memória:** documentação atualizada a partir do código.
- **Segurança:** auditoria sem achados.
- **Testes:** validação completa aprovada depois da correção dos testes de tecla.
- **Repositório:** commit e envio ao repositório privado; confirmação no registro complementar abaixo.
- **Fora do escopo:** nada de gameplay nem de som foi alterado.

## Auditoria de segurança
- **Arquivos verificados:** os 748 arquivos que seriam versionados, procurando tokens (GitHub, OpenAI, AWS, Google, Slack), chaves privadas, atribuições de senha, token ou segredo, arquivos `.env`/`.pem`/`.key`, configuração de MCP, logs, backups, saves, e-mails e caminhos pessoais.
- **Resultado:** **nenhum segredo nem dado pessoal encontrado**. As poucas ocorrências eram falsos positivos ("amplamente", "AudioStreamPlayer").
- **Histórico Git:** não havia (repositório sem commits).
- **Fora do Git:** `.godot/`, `dist/`, `build/`, o exe da raiz e o Godot portátil (`tools/godot/`).
- **Tamanho:** cerca de 21 MB, nenhum arquivo acima de 2 MB. Git LFS não é necessário. Os 131 WAV são versionados, porque o jogo precisa deles depois de clonar.

## Testes
| Teste | Resultado |
|---|---|
| Build `tools/build_windows.ps1` (15:11) | **Realizado e reprovado**: 661/665; 4 falhas de gameplay por tecla simulada que chegava tarde (KI-17) |
| Build `tools/build_windows.ps1` (15:12, depois da correção dos testes) | **Realizado e aprovado**: suíte 665/665, fluxo 17/17, validação sem erros de dados, wiki OK, export, autoteste no exe, boot headless e com GPU. SHA-256 do exe igual ao da v0.5.0 (`05A53CB3…D038D`), como esperado: os testes não entram no exe |
| `tools/factory.gd -- check` | **Realizado e aprovado**: 0 erros em 78 episódios |
| `tools/audio/audit_audio.gd` | **Realizado e aprovado**: 131 arquivos, 0 problemas |
| JSON (`data/`, `production/`, catálogo) | **Realizado e aprovado**: 50 arquivos, todos válidos |
| `tools/check_wiki.ps1` | **Realizado e aprovado**: 29 documentos, 0 erros, 0 avisos |
| Clone limpo do GitHub e testes na cópia | **Realizado e aprovado**: 665/665, fluxo 17/17, validação e auditoria (detalhes no registro complementar) |
| Escuta humana dos sons, sessão de jogo humana | **Não executado** (KI-16, KI-02) |

## Problemas conhecidos (principais)
- KI-02: nenhum teste jogando.
- KI-03 e KI-14: conteúdo bíblico e histórico sem revisão humana.
- KI-06: tradução provisória.
- KI-13: partes da expansão pendentes.
- KI-16: sons sem escuta humana; o refinamento sonoro fica para uma etapa futura e os 131 sons **não** foram alterados neste checkpoint.
- KI-17: falha intermitente da suíte, em observação.

## Pendências e próximas prioridades
1. **Criador:** jogar a v0.5.0 pelo roteiro de [docs/quests.md](../quests.md) e ouvir os sons na ordem de [docs/audio.md](../audio.md#escuta-humana-necessária).
2. **Criador:** revisar o conteúdo (KI-03, KI-14), decidir B7/H5 do ep_008 e a tradução (KI-06).
3. Refinamento sonoro depois da escuta (trocar sons por gravações ou bibliotecas livres só com autorização).
4. Próximo conteúdo pela fábrica: Gn 37:18-36 ou outra experiência planejada.

## Próxima ação
Num chat novo: "Leia `AGENTS.md` e `docs/ai-wiki/HANDOFF.md` e continue a partir do último checkpoint", dizendo a tarefa desejada.

## Cuidados
- O repositório no GitHub é **privado**: não mude a visibilidade nem faça force push.
- O `gh` desta máquina tem duas contas: a ativa é `maicontalgatti`, a outra é `ampla-dev` (`gh auth switch` troca entre elas). Neste repositório, o Git usa o `gh` como gerenciador de credenciais (configuração local), para não enviar com a conta errada. Fora dele, o gerenciador global está com `ampla-dev`: para clonar este repositório privado, use `gh repo clone maicontalgatti/Caminhos-da-Promessa`.
- Não rode `tools/audio/generate_sfx.gd` sobre sons já trocados por gravação.
- Ferramentas que encerram o jogo chamam `AudioManager.shutdown()` e esperam um instante.
- Em headless, testes com animação, fade ou cooldown medem por tempo; tecla simulada exige `Input.flush_buffered_events()`.
- Autoloads não existem em `--script`. Depois de criar um `class_name`, rode `--import`.
- Rode os comandos do Godot um de cada vez. Para editar, não use `Get-Content`/`Set-Content` do PowerShell.

## Registro complementar (depois do commit)
Preenchido num segundo commit, porque o hash do commit não pode constar nele mesmo.
- **Repositório:** https://github.com/maicontalgatti/Caminhos-da-Promessa
  - conta `maicontalgatti` (nome no GitHub: Maicon Talgatti);
  - visibilidade **PRIVATE**, conferida pela API antes e depois do envio.
- **Commit do checkpoint:** `218cb73` ("chore: project checkpoint and AI knowledge preservation"), autor Maicon Talgatti com e-mail noreply do GitHub, 748 arquivos, branch `main`.
- **Envio:** push normal (`main -> main`, sem force).
- **Conferência pela API:**
  - commit remoto igual ao local, 748 arquivos na árvore remota;
  - 37 `.tscn`, 70 `.gd`, 131 `.wav`, 9 agentes, 3 regras, 14 documentos da wiki;
  - local e remoto sincronizados.
- **Clone limpo** (`gh repo clone` numa pasta temporária, usando o Godot portátil desta máquina):
  - **Realizado e aprovado:** suíte 665/665, fluxo 17/17, validação sem erros de dados, auditoria de áudio 0 problemas.
  - Primeiro `--import`: 16 erros "Failed loading resource" (tema carregado antes de fontes e textura estarem importadas); o segundo `--import` deu 0.
  - O Godot acrescentou um `uid` ao cabeçalho de `default_bus_layout.tres` (KI-18).
  - O exe não foi gerado a partir do clone: depende dos templates instalados nesta máquina, os mesmos do build aprovado.
