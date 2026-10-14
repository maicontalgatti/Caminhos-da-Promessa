# Passagem de bastão (handoff)

Descreve só a **última tarefa**. Substitua o conteúdo ao fim de cada tarefa (o histórico fica no
[CHANGELOG.md](CHANGELOG.md) e em [docs/implementation_log.md](../implementation_log.md)).

- **Data:** 2026-10-14 (publicação pública)
- **Responsável:** agente de IA no Cursor, a pedido do criador
- **Versão do projeto:** 0.5.0 (`project.godot`)

Repositório preparado para ser público e receber colaboradores que usam os próprios agentes de IA. O
gameplay, os mapas, as missões, os sons e os agentes não foram alterados.

## Última tarefa
"PUBLICAÇÃO PÚBLICA NO GITHUB E PREPARAÇÃO PARA DESENVOLVIMENTO COLABORATIVO COM IA":
- auditoria de segurança (árvore atual e histórico completo) e de direitos autorais;
- licenças escolhidas pelo criador: **MIT** para o código e **CC BY 4.0** para arte, sons e textos próprios;
- documentação pública, guia para agentes de IA, modelos de issue e PR, CI de testes;
- proteção da `main` e mudança de visibilidade para público.

## Alterações desta tarefa
- **Licenças:** `LICENSE` (MIT), `LICENSE-ASSETS.md` (CC BY 4.0, com as exceções de terceiros), `docs/legal/ASSET_LICENSES.md` (inventário de origem e licença); ADR-027 em [DECISIONS.md](DECISIONS.md).
- **Raiz:** `README.md` reescrito para o público (capturas reais, estado, como rodar, seção "Desenvolva este jogo com sua própria IA", contribuição, conteúdo bíblico, licenças); novos `START_WITH_AI.md`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md`, `CHANGELOG.md`.
- **GitHub:** `.github/ISSUE_TEMPLATE/` (bug, funcionalidade, correção bíblica, `config.yml`), `.github/PULL_REQUEST_TEMPLATE.md`, `.github/workflows/tests.yml`, `.github/dependabot.yml`.
- **Memória:** `AGENTS.md`, índice da wiki, `CURRENT_STATE.md`, `DEVELOPMENT_RULES.md`, `NEW_AGENT_START_HERE.md` (pergunta 17), `AI_AGENTS.md` (outras ferramentas de IA), `TESTING.md` (CI), `CHANGELOG.md`, `docs/implementation_log.md`. Texto antigo que descrevia o repositório como privado foi trocado; a menção a outra conta do `gh` desta máquina saiu do HANDOFF.
- **Build:** `tools/build_windows.ps1` passa a citar as licenças do projeto no `LICENSES.txt` gerado ao lado do exe.

## Resultado
- **Segurança:** sem segredos nem dados pessoais na árvore nem no histórico (detalhes abaixo).
- **Direitos autorais:** nenhum recurso restritivo ou de origem desconhecida; arte e sons gerados por código do projeto; fontes OFL; texto bíblico BPM em domínio público.
- **Testes locais:** todos aprovados (tabela abaixo).
- **Publicação:** ver "Registro da publicação" abaixo.

## Auditoria de segurança
- **Histórico:** 2 commits (`218cb73`, `7243bcd`), 1 branch (`main`), nenhuma tag. Os 753 blobs de todo o histórico foram lidos.
- **Padrões procurados:** tokens do GitHub (clássicos e finos), GitLab, OpenAI, Anthropic, AWS, Google, Slack (tokens e webhooks), JWT, chaves privadas PEM, credenciais em URL, atribuições de senha/token/segredo/chave de API, chaves de provedores de voz.
- **Além de regex:** busca por entropia (cadeias de 32+ caracteres com entropia de Shannon acima de 4,5); cadeias hexadecimais longas conferidas (hashes do Godot nos `.import` e SHA-256 dos áudios no manifesto do ep_006); metadados embutidos nos 88 PNG (blocos tEXt/iTXt/zTXt/eXIf) e nos 131 WAV (LIST/INFO): nenhum.
- **Dados pessoais:** nenhum e-mail, telefone ou documento; nenhum caminho de usuário. O nome do criador aparece só como titular das licenças e dono do repositório.
- **Ferramentas dedicadas** (gitleaks, trufflehog): não instaladas nesta máquina e não instaladas nesta tarefa. Depois da publicação, a varredura de segredos do GitHub cobre o repositório (ver registro).
- **Resultado:** **nenhum achado**.

## Testes
| Teste | Resultado |
|---|---|
| `res://tests/test_runner.tscn` | **Realizado e aprovado**: 665/665 |
| `res://tests/flow_smoke.gd` | **Realizado e aprovado**: 17/17 |
| `res://tools/validate_content.gd` | **Realizado e aprovado**: sem erros de dados |
| `res://tools/factory.gd -- check` | **Realizado e aprovado**: 0 erros em 78 episódios |
| `res://tools/audio/audit_audio.gd` | **Realizado e aprovado**: 131 arquivos, 0 problemas |
| `tools/check_wiki.ps1` | **Realizado e aprovado**: 30 documentos, 0 erros, 0 avisos |
| Links relativos dos novos documentos da raiz | **Realizado e aprovado**: 0 quebrados |
| Workflow do GitHub Actions | ver registro da publicação |
| Build do exe | **Não executado** nesta tarefa: nada que entra no exe mudou (só o texto do `LICENSES.txt` ao lado dele) |
| Sessão de jogo humana, escuta dos sons | **Não executado** (KI-02, KI-16) |

## Problemas conhecidos (principais)
- KI-02: nenhum teste jogando. KI-03 e KI-14: conteúdo bíblico e histórico sem revisão humana. KI-06: tradução provisória.
- KI-16: sons sem escuta humana. KI-17: falha intermitente da suíte, em observação.

## Pendências e próximas prioridades
1. **Criador:** jogar a v0.5.0 pelo roteiro de [docs/quests.md](../quests.md) e ouvir os sons ([docs/audio.md](../audio.md#escuta-humana-necessária)).
2. **Criador:** revisar o conteúdo (KI-03, KI-14), decidir B7/H5 do ep_008 e a tradução (KI-06).
3. Acompanhar as primeiras execuções do workflow em pull requests de forks.
4. Próximo conteúdo pela fábrica: Gn 37:18-36 ou outra experiência planejada.

## Próxima ação
Num chat novo, com qualquer ferramenta de IA: use o prompt de [START_WITH_AI.md](../../START_WITH_AI.md).

## Cuidados
- O repositório é **público**: nada de segredos, dados pessoais ou recursos sem licença; o histórico também é público.
- Mudanças entram por pull request; nada de force push, reescrita de histórico ou mudança de visibilidade.
- Neste clone, o Git usa o `gh` como gerenciador de credenciais (configuração local do repositório).
- Não rode `tools/audio/generate_sfx.gd` sobre sons já trocados por gravação.
- Ferramentas que encerram o jogo chamam `AudioManager.shutdown()` e esperam um instante.
- Em headless, testes com animação, fade ou cooldown medem por tempo; tecla simulada exige `Input.flush_buffered_events()`.
- Autoloads não existem em `--script`. Depois de criar um `class_name`, rode `--import`.
- Rode os comandos do Godot um de cada vez. Para editar, não use `Get-Content`/`Set-Content` do PowerShell.

## Registro da publicação
Preenchido depois do envio (o hash de um commit não pode constar nele mesmo).
- **Repositório:** https://github.com/maicontalgatti/Caminhos-da-Promessa, dono `maicontalgatti`, branch `main`.
- **Commit publicado:** `573bdf3` ("chore: prepare repository for public collaboration"), push normal `7243bcd..573bdf3`, sem force. O `gh` da conta dona recebeu a permissão `workflow` (exigida para enviar `.github/workflows/`) por login no navegador feito pelo criador.
- **CI:** execução 38621957345 do workflow "Testes" no commit `573bdf3`: **Realizado e aprovado** em 55 s no Linux. Godot conferido por SHA-512; suíte 665/665, fluxo 17/17, validação sem erros, fábrica 0 erros em 78 episódios, áudio 131 arquivos e 0 problemas.
- **Clone limpo do commit `573bdf3`** (pasta temporária, Godot portátil): **Realizado e aprovado**. 763 arquivos, segundo `--import` sem erros, suíte 665/665; só `default_bus_layout.tres` aparece modificado (KI-18).
- **Visibilidade:** mudada para **PUBLIC** depois da checagem; conferida pela API autenticada e pela API anônima (`private=false`, licença detectada MIT).
- **Acesso sem login** (HTTP 200): página do repositório, `README.md`, `START_WITH_AI.md`, `AGENTS.md`, `docs/ai-wiki/README.md`, `CURRENT_STATE.md`, `HANDOFF.md`, `LICENSE`, `LICENSE-ASSETS.md`, `CONTRIBUTING.md`.
- **Proteções configuradas:**
  - ruleset "Proteger main" (ativo): bloqueia exclusão e force push; exige pull request com 1 aprovação e o check `godot-tests`; o papel de administrador pode contornar (o criador mantém o projeto sozinho);
  - Actions: permissão padrão do `GITHUB_TOKEN` somente leitura, Actions não aprovam PRs, workflows de colaboradores externos exigem aprovação;
  - varredura de segredos e proteção de push ativas (0 alertas na primeira consulta); relato privado de vulnerabilidades ativo; alertas do Dependabot ativos.
- **Limitações do plano gratuito:** com o repositório privado, rulesets e proteção de branch não estavam disponíveis (HTTP 403); foram aplicados logo depois de torná-lo público.
- **Também feito:** descrição e tópicos do repositório; rótulos `biblical-content` e `dependencies` usados pelos modelos.
- **Este registro** entrou por pull request (fluxo novo), esperou o check de testes e foi integrado pelo agente com o contorno de administrador da conta dona, a pedido do criador (não há segundo revisor no projeto).
