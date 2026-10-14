# Como contribuir

Obrigado pelo interesse em Caminhos da Promessa! Este guia vale para pessoas e para agentes de IA.
Antes de tudo, leia o [README.md](README.md), o [AGENTS.md](AGENTS.md) e o
[Código de Conduta](CODE_OF_CONDUCT.md).

## Fluxo de trabalho

```
Fork ou branch → Desenvolvimento → Testes → Documentação → Pull Request → Revisão → Merge
```

- **Ninguém altera a `main` diretamente.** Toda mudança entra por pull request revisado.
- Quem não tem acesso de escrita trabalha num **fork**. Colaboradores com acesso usam uma branch.
- Nomes de branch: `feat/…`, `fix/…`, `docs/…`, `content/…` (missões e textos), `art/…`, `audio/…`,
  `test/…`, `chore/…`. Exemplo: `content/gn37-poco-de-dota`.
- Um pull request = um assunto. Prefira PRs pequenos.
- Commits: mensagem curta no imperativo, em inglês ou português (ex.: `fix: corrige seta do objetivo em Dotã`).
- Nada de force push em branches compartilhadas nem reescrita do histórico da `main`.

## Abrir issues
Use os modelos em [issues → New issue](https://github.com/maicontalgatti/Caminhos-da-Promessa/issues/new/choose):
- **Bug:** versão, passos, resultado esperado e obtido, logs **sem dados pessoais nem segredos**.
- **Funcionalidade:** problema, proposta, impacto no gameplay, sistemas envolvidos.
- **Correção bíblica:** livro e passagem, conteúdo incorreto, correção, fonte e classificação.

Vulnerabilidades de segurança **não** vão em issue pública: veja [SECURITY.md](SECURITY.md).

## Preparar o ambiente
Siga "Como executar localmente" no [README.md](README.md). Resumo: Godot 4.7.2 em `tools/godot/`,
`--import` duas vezes num clone novo e a suíte de testes deve terminar em "0 falharam".

## Tipos de contribuição

### Funcionalidades e correções de código
- Leia o documento da área na tabela "Qual documento ler" da [AI Wiki](docs/ai-wiki/README.md) e o
  [ARCHITECTURE_MAP.md](docs/ai-wiki/ARCHITECTURE_MAP.md).
- Siga as [regras de desenvolvimento](docs/ai-wiki/DEVELOPMENT_RULES.md): não reescreva sistemas que
  funcionam; sistemas novos entram ao lado dos existentes; decisões estruturais viram ADR em
  [DECISIONS.md](docs/ai-wiki/DECISIONS.md).
- Novos sistemas precisam de testes em `tests/`.

### Missões bíblicas
1. Abra uma issue de funcionalidade descrevendo o episódio (livro, capítulos, ideia jogável).
2. Siga a [fábrica de missões](docs/mission_factory.md): pesquisa bíblica e histórica → design →
   roteiro → verificação → implementação → QA. O catálogo de episódios fica em `production/catalog/`.
3. O pacote do episódio fica em `production/episodes/<id>/`; dados do jogo em `data/`.
4. Toda contribuição bíblica deve identificar, separadamente:
   - **referências** exatas (livro, capítulo, versículos);
   - **fatos do texto** (o que a passagem diz);
   - **contexto histórico** (com o grau de certeza: consenso ou hipótese);
   - **interpretações**;
   - **elementos fictícios** do jogo (moradores, tarefas, diálogos inventados).
5. Siga as [regras bíblicas](docs/ai-wiki/BIBLICAL_RULES.md): não invente versículos, datas ou falas
   de personagens bíblicos; ficção é sempre identificada.
6. Conteúdo novo entra com status `pending_review`. **Só uma pessoa revisora pode marcar conteúdo como
   verificado.**

### Mapas
- Mapas são gerados por ferramentas (`tools/art_gen/build_regions.gd`; a aldeia por
  `tools/art_gen/build_world.gd`). Edite o gerador, não o `.tscn` gerado (ADR-006).
- Cada região é um JSON em `data/regions/`. Veja [architecture.md](docs/architecture.md).

### Arte e sons
- Arte e sons atuais são gerados por código (`tools/art_gen/`, `tools/audio/`). Siga a
  [Art Bible](docs/art_bible.md) e o [guia de áudio](docs/audio.md).

## Recursos externos
Arte, sons, fontes, músicas, textos ou traduções que **não** foram criados por você:
- precisam de licença compatível com redistribuição pública (ex.: CC0, CC BY, OFL, MIT);
- **não** são aceitos sem origem conhecida ("achei na internet" não basta);
- devem ganhar uma linha em [docs/legal/ASSET_LICENSES.md](docs/legal/ASSET_LICENSES.md) com caminho,
  autor, link da fonte, licença e status de verificação;
- traduções bíblicas modernas (NVI, ARA, NAA, NTLH, NVT etc.) **não podem** ser usadas sem licença
  escrita do detentor. Use referências ou o texto de domínio público já incluso.

Ao enviar material criado por você, você concorda em licenciá-lo nos termos do projeto: código sob MIT
([LICENSE](LICENSE)); arte, sons e textos sob CC BY 4.0 ([LICENSE-ASSETS.md](LICENSE-ASSETS.md)).

## Conteúdo produzido com IA
Agentes de IA são bem-vindos. Ao usá-los:
- informe no pull request o que foi produzido ou alterado com IA (código, textos, arte, sons);
- confira o resultado: rode os testes e revise o que o agente escreveu;
- **validação feita só por agente não substitui revisão humana independente**, principalmente de
  conteúdo bíblico e histórico;
- comece pelo prompt de [START_WITH_AI.md](START_WITH_AI.md); o agente deve seguir o `AGENTS.md`.

## Revisar referências
Ao revisar conteúdo bíblico:
- abra a passagem citada numa tradução confiável e confira se o texto do jogo corresponde a ela;
- verifique se fatos, contexto, interpretação e ficção estão separados e corretamente rotulados;
- registre o resultado na revisão do PR (ou em `production/episodes/<id>/review.json` na fábrica);
- só marque `verified` se você for a pessoa revisora responsável e tiver conferido de fato.

## Testes
Rode, um de cada vez, e informe os resultados reais no PR (detalhes em
[TESTING.md](docs/ai-wiki/TESTING.md)):

```powershell
$g = ".\tools\godot\Godot_v4.7.2-stable_win64_console.exe"
& $g --headless --path . res://tests/test_runner.tscn             # suíte principal
& $g --headless --path . --script res://tests/flow_smoke.gd       # fluxo pelos menus
& $g --headless --path . --script res://tools/validate_content.gd # dados e referências
& $g --headless --path . --script res://tools/factory.gd -- check # fábrica de missões
powershell -ExecutionPolicy Bypass -File tools\check_wiki.ps1      # AI Wiki
```

O GitHub Actions roda a suíte, o fluxo, a validação e a fábrica em todo pull request. Nunca declare um
teste como aprovado sem executá-lo; escreva "não executado" quando for o caso.

## Atualizar a AI Wiki
A wiki em [docs/ai-wiki/](docs/ai-wiki/README.md) é a memória do projeto. No mesmo PR que mudar o
projeto, atualize o que a [política de manutenção](docs/ai-wiki/README.md#política-de-manutenção) pede:
- `HANDOFF.md` sempre (última tarefa, resultado, pendências);
- `CURRENT_STATE.md` se o estado geral mudou;
- `DECISIONS.md`, `KNOWN_ISSUES.md`, `ARCHITECTURE_MAP.md`, `CHANGELOG.md` conforme o caso.

Em PRs paralelos, conflitos em `HANDOFF.md` são esperados: mantenha o registro mais recente e mova o
anterior para `docs/implementation_log.md`.

## Pull requests
- Preencha o modelo: o que mudou, por quê, testes, documentação, recursos externos e implicações bíblicas.
- Mantenha o gameplay existente funcionando; mudanças de comportamento devem estar descritas.
- Não inclua builds (`.exe`, `.pck`, `dist/`), a pasta `.godot/`, o Godot portátil, saves, logs ou
  arquivos `.env`.
- O PR só é integrado depois da revisão e com os testes do GitHub Actions passando.
