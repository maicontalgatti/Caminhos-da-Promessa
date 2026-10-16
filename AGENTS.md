# AGENTS.md — Caminhos da Promessa

Ponto de entrada para qualquer agente de IA (ou pessoa) que vá trabalhar neste repositório.
É curto de propósito: a memória do projeto está na **AI Wiki** em [`docs/ai-wiki/`](docs/ai-wiki/README.md).
Primeiro contato? Leia [`NEW_AGENT_START_HERE.md`](docs/ai-wiki/NEW_AGENT_START_HERE.md). Prompt de inicialização para
qualquer ferramenta de IA: [`START_WITH_AI.md`](START_WITH_AI.md).

> Antes de realizar alterações no projeto, consulte o índice da AI Wiki e o estado atual do
> desenvolvimento. Leia a documentação específica dos sistemas envolvidos na tarefa. Não presuma
> que o contexto da conversa contém todas as decisões anteriores.

## O projeto em uma frase
RPG 2D em pixel art (vista 3/4, estilo Stardew) para **ensinar e contextualizar a Bíblia**, com o
jogador como um viajante fictício que explora, conversa e aprende **sem alterar os relatos bíblicos**.
Godot **4.7.2** · GDScript · renderer Compatibility · dados em JSON · Windows (exe único).
Versão e estado atuais: [`CURRENT_STATE.md`](docs/ai-wiki/CURRENT_STATE.md).

## Leitura progressiva (não leia tudo)
1. **Sempre:** este arquivo → [`docs/ai-wiki/README.md`](docs/ai-wiki/README.md) → [`CURRENT_STATE.md`](docs/ai-wiki/CURRENT_STATE.md) → [`HANDOFF.md`](docs/ai-wiki/HANDOFF.md).
2. **Conforme a tarefa:** o documento indicado na tabela "Qual documento ler" do índice da wiki.
3. **Só então o código:** busca direcionada nos arquivos apontados por [`ARCHITECTURE_MAP.md`](docs/ai-wiki/ARCHITECTURE_MAP.md).

**Documentação orienta; código e testes verificam.** Se a doc divergir do código, registre a divergência em
[`KNOWN_ISSUES.md`](docs/ai-wiki/KNOWN_ISSUES.md) e investigue antes de decidir.
Chat novo, troca de modelo ou contexto resumido: siga "RECUPERAÇÃO DE CONTEXTO" no [índice da wiki](docs/ai-wiki/README.md#recuperação-de-contexto).

## Regras que nunca podem ser quebradas
- Conteúdo bíblico: siga [`BIBLICAL_RULES.md`](docs/ai-wiki/BIBLICAL_RULES.md). Não invente versículos, datas ou falas de personagens bíblicos; ficção é sempre identificada; IA nunca marca conteúdo como verificado.
- Código e repositório: siga [`DEVELOPMENT_RULES.md`](docs/ai-wiki/DEVELOPMENT_RULES.md). Não reescreva sistemas que funcionam, não apague nada importante, nada de comandos Git destrutivos (reset forçado, clean, force push), nada de segredos na doc ou no Git.
- Testes: nunca declare um teste como aprovado sem tê-lo executado. Diga "não executado" quando for o caso.
- Decisões registradas em [`DECISIONS.md`](docs/ai-wiki/DECISIONS.md) só mudam com justificativa e análise de impacto.
- Repositório **público** (`maicontalgatti/Caminhos-da-Promessa`): mudanças entram por branch/fork e pull request revisado ([`CONTRIBUTING.md`](CONTRIBUTING.md)); nada direto na `main`. Commits e push só quando a pessoa que você atende pedir. Nunca grave segredos ou dados pessoais: tudo aqui é visível para qualquer um.
- Recursos de terceiros só com licença compatível registrada em [`docs/legal/ASSET_LICENSES.md`](docs/legal/ASSET_LICENSES.md). Licenças do projeto: código MIT ([`LICENSE`](LICENSE)); arte, sons e textos próprios CC BY 4.0 ([`LICENSE-ASSETS.md`](LICENSE-ASSETS.md)).

## Convenções
- Dados de jogo em JSON (`data/`), carregados automaticamente; sons por id no manifesto `data/audio/sfx.json`.
- Arte, mapas e sons provisórios são **gerados por ferramentas** em `tools/` (arte, mundo, áudio); edite o gerador, não o arquivo gerado, salvo indicação em contrário.
- Textos do jogo e documentação em português do Brasil. Para editar arquivos, não use `Get-Content`/`Set-Content` do PowerShell (quebram o UTF-8).
- Agentes especializados: [`AI_AGENTS.md`](docs/ai-wiki/AI_AGENTS.md); produção de episódios: [`docs/mission_factory.md`](docs/mission_factory.md).

## Ao iniciar uma tarefa
1. Faça a leitura do nível 1 acima e rode `git status` (alterações locais de outra sessão podem estar em andamento).
2. Leia os documentos do nível 2 ligados à tarefa.
3. Confirme no código o que a doc afirma antes de depender disso.

## Ao encerrar uma tarefa (ou antes de o contexto acabar)
1. Rode os testes pertinentes ([`TESTING.md`](docs/ai-wiki/TESTING.md)) e anote os resultados reais.
2. Atualize [`HANDOFF.md`](docs/ai-wiki/HANDOFF.md) (sempre) e [`CURRENT_STATE.md`](docs/ai-wiki/CURRENT_STATE.md) (se o estado geral mudou).
3. Registre decisões novas em `DECISIONS.md`, problemas em `KNOWN_ISSUES.md` e a entrega em [`CHANGELOG.md`](docs/ai-wiki/CHANGELOG.md) e `docs/implementation_log.md`.
4. Rode a verificação da wiki: `powershell -ExecutionPolicy Bypass -File tools\check_wiki.ps1`.

## Comandos essenciais
```powershell
.\tools\godot\Godot_v4.7.2-stable_win64.exe --path . # rodar o jogo (ou F5 no editor)
$g = ".\tools\godot\Godot_v4.7.2-stable_win64_console.exe"
& $g --headless --path . --import # depois de clonar ou criar class_name
& $g --headless --path . res://tests/test_runner.tscn # testes do projeto
& $g --headless --path . --script res://tests/flow_smoke.gd # fluxo pelos menus
.\criar_exe_atualizado.bat # testes + validação + builds Windows e Linux na raiz
powershell -ExecutionPolicy Bypass -File tools\check_wiki.ps1 # links e estrutura da wiki
& $g --headless --path . --script res://tools/factory.gd -- pending # fábrica de missões
& $g --headless --path . --script res://tools/audio/audit_audio.gd # conferir os arquivos de som
```
Godot portátil fica em `tools/godot/` (fora do Git; ver [`README.md`](README.md) para baixar).
