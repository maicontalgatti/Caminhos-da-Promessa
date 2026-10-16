# AI Project Wiki — Caminhos da Promessa

Memória persistente do projeto para agentes de IA e pessoas. Independe de fornecedor: é Markdown
comum, versionado junto com o código. Ponto de entrada: [`AGENTS.md`](../../AGENTS.md).

**Documentação orienta. Código e testes verificam.**

## Documentos da wiki

| Documento | Para que serve | Quando ler |
|---|---|---|
| [NEW_AGENT_START_HERE.md](NEW_AGENT_START_HERE.md) | 17 perguntas frequentes com o link certo; primeiros comandos após clonar | Primeiro contato com o repositório |
| [PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md) | O que é o jogo, público, pilares, escopo | Primeira vez no projeto |
| [CURRENT_STATE.md](CURRENT_STATE.md) | Versão, o que funciona (verificado), em andamento, planejado | **Sempre** |
| [HANDOFF.md](HANDOFF.md) | Última tarefa, resultado, pendências, próxima ação | **Sempre** |
| [ARCHITECTURE_MAP.md](ARCHITECTURE_MAP.md) | Sistemas → arquivos, dependências, sinais, dados | Antes de mexer em código |
| [GAME_SYSTEMS.md](GAME_SYSTEMS.md) | Comportamento de cada sistema de jogo e seu grau de verificação | Tarefas de gameplay/UI |
| [BIBLICAL_RULES.md](BIBLICAL_RULES.md) | Regras de fidelidade bíblica e de classificação | **Qualquer** conteúdo narrativo |
| [DEVELOPMENT_RULES.md](DEVELOPMENT_RULES.md) | Regras de código, Git, segurança, testes | Antes de alterar arquivos |
| [AI_AGENTS.md](AI_AGENTS.md) | Inventário dos subagentes e regras do Cursor, status de cada um | Antes de delegar |
| [DECISIONS.md](DECISIONS.md) | Decisões arquiteturais (ADRs) | Antes de mudar algo estrutural |
| [KNOWN_ISSUES.md](KNOWN_ISSUES.md) | Problemas, riscos, divergências doc × código | Antes de planejar |
| [TESTING.md](TESTING.md) | Como testar, o que cada teste cobre, resultados | Antes de entregar |
| [CHANGELOG.md](CHANGELOG.md) | Resumo das versões | Para entender a evolução |

## Documentos de referência (fora da wiki — fonte detalhada, não duplicar)

| Documento | Conteúdo |
|---|---|
| [docs/game_design.md](../game_design.md) | Design completo: pilares, controles, diálogos, missões |
| [docs/game-design/CRITICAL_REVIEW.md](../game-design/CRITICAL_REVIEW.md) | Conselho crítico: achados e prioridades |
| [docs/game-design/BENCHMARK_ANALYSIS.md](../game-design/BENCHMARK_ANALYSIS.md) | Comparação com RPGs 2D de referência |
| [docs/game-design/QUEST_QUALITY_CHECKLIST.md](../game-design/QUEST_QUALITY_CHECKLIST.md) | Checklist editorial (≠ testes) |
| [docs/game-design/PLAYTEST_ROTEIRO.md](../game-design/PLAYTEST_ROTEIRO.md) | Perguntas respondíveis para playtest humano (KI-02) |
| [docs/architecture.md](../architecture.md) | Arquitetura técnica detalhada e formatos de dados |
| [docs/quests.md](../quests.md) | Sistema de missões, eventos, editor, roteiro de teste manual |
| [docs/mission_factory.md](../mission_factory.md) | Fábrica de missões: catálogo de 78 episódios, gates, agentes, áudio |
| [docs/bible_catalog.md](../bible_catalog.md) | Catálogo bíblico, status de verificação, fluxo de revisão |
| [docs/art_bible.md](../art_bible.md) | Direção de arte, resoluções, paletas, sprites |
| [docs/roadmap.md](../roadmap.md) | Fases do projeto |
| [docs/implementation_log.md](../implementation_log.md) | Registro detalhado de cada entrega (histórico) |
| [docs/build_windows.md](../build_windows.md) | Exportação Windows e Linux |
| [docs/audio.md](../audio.md) | Efeitos sonoros: AudioManager, manifesto, como adicionar sons, inventário, escuta pendente |
| [README.md](../../README.md) | Instalação, como rodar, controles |
| [START_WITH_AI.md](../../START_WITH_AI.md) | Prompt de inicialização para qualquer agente de IA |
| [CONTRIBUTING.md](../../CONTRIBUTING.md) | Fluxo de contribuição, testes, conteúdo bíblico, recursos externos |
| [docs/legal/ASSET_LICENSES.md](../legal/ASSET_LICENSES.md) | Origem e licença de cada grupo de recursos |

## Qual documento ler para cada tarefa

| Tarefa | Nível 2 (ler) | Código provável |
|---|---|---|
| Produzir episódio do catálogo / coordenar agentes | [mission_factory.md](../mission_factory.md), [AI_AGENTS.md](AI_AGENTS.md), BIBLICAL_RULES | `production/`, `tools/factory.gd`, `.cursor/agents/` |
| Nova missão / alterar missão | passo a passo em [GAME_SYSTEMS](GAME_SYSTEMS.md#como-adicionar-uma-missão); formato em quests.md; BIBLICAL_RULES; checklist em game-design/ | `data/quests/`, `scripts/quests/` |
| Avaliar ritmo/qualidade de missão | CRITICAL_REVIEW, QUEST_QUALITY_CHECKLIST, AI_AGENTS (conselho) | `data/quests/`, `data/dialogues/` |
| Diálogo ou NPC | BIBLICAL_RULES, game_design.md (diálogos) | `data/dialogues/`, `data/characters/` |
| Conteúdo bíblico (refs, cronologia, lugares) | BIBLICAL_RULES, bible_catalog.md | `data/bible/`, `scripts/bible/` |
| UI / HUD / diário / cinemática | GAME_SYSTEMS, ARCHITECTURE_MAP | `scripts/ui/` |
| Mapa, arte, sprites | art_bible.md, DECISIONS (ADR-005/006) | `tools/art_gen/`, `scenes/` |
| Save | ARCHITECTURE_MAP (save), DECISIONS (ADR-008) | `scripts/save/`, `scripts/core/game_state.gd` |
| Build / exe | build_windows.md, TESTING | `tools/build_export.ps1` |
| Sons, ambiente, volumes | [audio.md](../audio.md), DECISIONS (ADR-026) | `scripts/core/audio_manager.gd`, `data/audio/sfx.json`, `tools/audio/` |
| Testes | TESTING | `tests/` |

## Leitura progressiva
- **Nível 1 (sempre):** `AGENTS.md`, este índice, `CURRENT_STATE.md`, `HANDOFF.md`.
- **Nível 2 (pela tarefa):** os documentos da tabela acima.
- **Nível 3 (código):** busca direcionada nos arquivos do `ARCHITECTURE_MAP.md`. Não leia o repositório inteiro.

## RECUPERAÇÃO DE CONTEXTO
Use ao trocar de modelo, abrir um chat novo, retomar depois de pausa ou quando o contexto foi resumido.
1. Leia `AGENTS.md`.
2. Leia este índice.
3. Leia `CURRENT_STATE.md`.
4. Leia `HANDOFF.md`.
5. Identifique os sistemas envolvidos na nova tarefa.
6. Leia somente os documentos desses sistemas (tabela "Qual documento ler").
7. Verifique o estado do Git (`git status`, `git log --oneline -5`; o remoto `origin` é o repositório público no GitHub; contribuições entram por pull request, ver [CONTRIBUTING.md](../../CONTRIBUTING.md)).
8. Compare a documentação com os arquivos atuais (abra os arquivos citados; confirme nomes e assinaturas).
9. Registre divergências em `KNOWN_ISSUES.md` antes de alterar algo.
10. Só então proponha ou execute alterações.

## Política de manutenção
Atualize a wiki **na mesma tarefa** que mudar o projeto:

| Quando | Atualizar |
|---|---|
| Ao fim de toda tarefa | `HANDOFF.md` |
| Funcionalidade concluída/verificada ou estado geral mudou | `CURRENT_STATE.md` |
| Nova decisão estrutural | `DECISIONS.md` (novo ADR; não reescreva os antigos — marque como substituídos) |
| Bug, risco ou divergência encontrada | `KNOWN_ISSUES.md` |
| Arquivo/sistema criado, movido ou renomeado | `ARCHITECTURE_MAP.md` |
| Nova versão entregue | `CHANGELOG.md` + `docs/implementation_log.md` |
| Regra bíblica ou de desenvolvimento nova | `BIBLICAL_RULES.md` / `DEVELOPMENT_RULES.md` |

Regras de compactação: `AGENTS.md` continua curto; este índice só indexa; `CURRENT_STATE.md` é um
resumo do presente (histórico vai para `CHANGELOG`/`implementation_log`); `HANDOFF.md` descreve só a última tarefa.
Prefira links a cópias. Não registre raciocínio interno de modelos, segredos ou dados pessoais.

### Verificação automatizada
`tools/check_wiki.ps1` (PowerShell, sem dependências) verifica:
- arquivos obrigatórios da wiki;
- links Markdown relativos quebrados em `AGENTS.md`, `README.md` e `docs/**/*.md`;
- caminhos do repositório citados entre crases que não existem;
- campos obrigatórios em `CURRENT_STATE.md` e `HANDOFF.md`, e a versão do `CURRENT_STATE.md` contra `project.godot`;
- se há uma regra sempre ativa em `.cursor/rules/` apontando para `AGENTS.md` (os links dos `.mdc` também são verificados);
- aviso de desatualização quando há arquivos de código/dados mais novos que a data de `CURRENT_STATE.md`.

Ele **não** verifica se o conteúdo descreve corretamente o código; isso continua sendo revisão humana/do agente.
Também roda como etapa informativa (não bloqueante) do build do exe.
