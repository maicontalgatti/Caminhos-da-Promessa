# CAMINHOS DA PROMESSA — FÁBRICA DE MISSÕES BÍBLICAS COM SUBAGENTES

## Papel e resultado
Atue como coordenador técnico de uma equipe de agentes de IA dentro do Cursor, implementando **uma linha de produção de conteúdo bíblico para o RPG Godot 4**. O objetivo é permitir que eu selecione uma história no catálogo e, com poucas operações, produza um pacote de missão validado: pesquisa, game design, objetivos, falas, descobertas, dados, integração ao jogo, áudio opcional e testes.

**Não confunda uma missão gerada com uma missão jogável.** Só considere uma missão implementada quando seus alvos existirem no mundo, a progressão funcionar, as referências estiverem verificadas, a persistência funcionar e os testes tiverem resultados registrados.

Não reescreva o protótipo nem os sistemas já existentes. Consulte `AGENTS.md`, `docs/ai-wiki/` e os arquivos reais antes de qualquer alteração. Respeite modificações locais e não faça ações destrutivas no Git.

## Material inicial
Vou disponibilizar `Caminhos_da_Promessa_catalogo_missoes.json`, contendo **78 propostas iniciais**. Trate-o como catálogo-semente de IDEIAS, não como base validada e não como lista de mecânicas já implementadas. Copie-o para um diretório de dados de planejamento compatível com o projeto. Se o arquivo não estiver acessível no workspace, reporte precisamente o caminho esperado e continue apenas com os recursos existentes, sem fingir que o leu.

Cada proposta contém ID, livro, referência, modo narrativo, objetivo de aprendizagem, região e três objetivos candidatos. Os IDs de alvo são placeholders e precisam ser vinculados a NPCs, objetos ou eventos reais.

## 1. Auditoria antes de gerar
Inspecione:
- Engine e versão do Godot, cenas, TileMapLayers, regiões e mapas existentes.
- QuestManager, catálogo bíblico, modelo de objetivo/evento, NPCs, diálogo, inventário, interação, diário, HUD, SaveManager e áudio.
- Configurações do Cursor e subagentes já definidos.
- Assets, arquivos JSON, validadores, testes e exportação Windows.
- Documentação e conteúdo bíblico já criado, para evitar duplicação.

Elabore um mapa de capacidades com três colunas: **já funciona**, **existe parcialmente**, **não existe**. Registre quais novos objetivos podem ser instanciados só por dados e quais exigem código.

## 2. Criar agentes especializados reais no Cursor
Use o suporte atual a subagents do Cursor. Crie ou adapte arquivos em `.cursor/agents/*.md` com frontmatter YAML válido (`name`, `description`, `model` quando necessário, `readonly` para auditores). Confirme a documentação compatível com a versão instalada. Não invente sintaxes, comandos de spawn nem recursos inexistentes. A seguir, delegue trabalho real usando os mecanismos do Cursor; não basta criar os arquivos e alegar que os agentes executaram.

### 2.1 `biblical-researcher` — PESQUISADOR
Responsabilidade: localizar referências pertinentes; produzir resumo do texto, personagens, contexto, gênero literário, linha do tempo com incerteza explicitada, fontes e oportunidades de exploração. Não escrever cenas Godot. Distinguir texto bíblico de hipótese histórica e de ficção. Somente leitura do código; propostas em documento próprio.

### 2.2 `biblical-verifier` — AUDITOR BÍBLICO INDEPENDENTE
Responsabilidade: conferir **independentemente** livros, capítulos, versículos e qualquer afirmação bíblica nos roteiros gerados. Detectar versos inexistentes, deslocamentos de acontecimentos, atribuição incorreta de fala, conflito entre épocas, confusão entre parábola e evento histórico, alterações do papel de Jesus, Moisés, José e demais personagens. Classificar cada achado por gravidade. `readonly: true`. Não aceitar a pesquisa do primeiro agente como prova. Se não tiver acesso a fonte verificável, marcar `needs_human_review`, nunca `verified`.

### 2.3 `historical-reviewer` — REVISOR HISTÓRICO
Responsabilidade: revisar anacronismos, arquitetura, roupa, geografia, costumes e cronologias. Usar a.C./d.C. apenas quando houver base suficiente; senão indicar século amplo, período ou data debatida. Registrar fontes e incertezas. `readonly: true`.

### 2.4 `quest-designer` — DESIGNER DE MISSÕES
Responsabilidade: criar premissa jogável, início, objetivos, pistas graduais, condições, eventos, variações de gameplay e término; dar agência ao jogador sem alterar acontecimentos canônicos. Reaproveitar mecânicas e mapas. Categorizar cenas observacionais, parábolas e ensinos ilustrativos. Garantir que uma experiência seja interessante e não apenas sequência de três diálogos ou um questionário.

### 2.5 `dialogue-writer` — ROTEIRISTA
Responsabilidade: criar falas naturais em português brasileiro, opções de resposta não enganosas, contextualização breve, descobertas do diário, dicas discretas e textos de UI. Personagens históricos devem manter atribuições corretas. Fala inventada de personagem bíblico só pode existir se explicitamente classificada como dramatização; jamais ser apresentada como citação textual. Não plagiar traduções bíblicas protegidas.

### 2.6 `godot-implementer` — IMPLEMENTADOR
Responsabilidade: validar o contrato dos dados, associar targets a cenas/NPCs reais, acrescentar recursos mínimos reutilizáveis, integrar QuestManager/diálogos/diário/cena, tratar estados e save, importar assets, testar build. Preferir mudanças pequenas. **Um único integrador escreve em cenas globais e componentes compartilhados por vez**. Outras tarefas podem trabalhar em dados isolados; não permitir escritas paralelas conflitantes.

### 2.7 `visual-asset-producer` — ARTE E ASSETS
Responsabilidade: inventariar sprites, cenários, tiles e animações já existentes; definir demandas de arte de cada missão e gerar recursos apenas se houver gerador de imagens/arte configurado e autorizado. Preservar a pixel art e escala aprovadas na Art Bible. Validar spritesheets, contornos, paleta, dimensão de quadros, animações, pivôs e licenças. Não afirmar ter gerado um arquivo de sprite quando só produziu um prompt. Priorizar reutilização de recursos e placeholders visivelmente marcados quando necessário. Não modificar cenas compartilhadas; entregar assets isolados e especificações ao integrador.

### 2.8 `audio-producer` — PRODUÇÃO DE ÁUDIO
Responsabilidade: criar um manifesto de locução com falas, NPC, emoção, pronúncias e duração-alvo; selecionar perfis de voz consistentes; gerar áudio por provedor TTS configurado **somente se houver integração autorizada e credenciais válidas**. Começar com interface neutra a provedor e suporte futuro a serviços como ElevenLabs, TTS local ou outros. Não inventar que gerou um `.ogg` se não existir. Não expor chaves. Não imitar voz de pessoas reais sem autorização. Produzir legendas para toda fala. Normalizar volume e armazenar áudio longo como Ogg Vorbis quando adequado; validar importação no Godot. Se não houver provedor, produzir manifesto e fallback em texto sem bloquear a missão.

### 2.9 `quest-qa` — QA E TESTES
Responsabilidade: validar JSON/schema, referência, IDs, alvos existentes, objetivos alcançáveis, pré-requisitos, loops, save/load, eventos duplicados, regressões e exportação. Testar início, progresso e conclusão com evidências. `readonly: true` quando estiver apenas auditando; se testes adicionais exigirem escrita, usar uma tarefa de teste isolada e controlada. Não afirmar teste manual quando apenas houve automação.

O **agente principal** funciona como coordenador: aloca missões, coleta pareceres, controla integrações, resolve conflitos, atualiza a AI Wiki e só promove conteúdo após os gates.

## 3. Política de paralelismo, orçamento e contexto
- Pesquisa bíblica e pesquisa histórica independentes podem rodar em paralelo.
- Designer e roteirista dependem de um resumo de pesquisa consistente.
- Verificador bíblico recebe o conteúdo terminado e pesquisa por conta própria; não é o mesmo agente que criou o texto.
- Áudio recebe somente roteiro aprovado.
- Integrador recebe somente contrato aprovado, exceto tarefas pequenas de infraestrutura.
- QA verifica implementação, não só intenção.
- Não criar dezenas de agentes simultâneos. Comece com no máximo 2–3 subagentes paralelos independentes, com limite configurável de tarefas por lote, e registre custos/uso quando as ferramentas expuserem métricas. Nunca inventar dados de custo.
- Não instalar serviços pagos, gastar em API de áudio nem disparar lotes grandes sem me mostrar o custo previsto e pedir autorização.
- Contextos intermediários ficam em arquivos por episódio; o coordenador recebe relatórios compactos, evitando explodir a janela principal.
- Usar Git/branches ou isolamento equivalente se houver implementação paralela, conferindo diff e conflitos antes de mesclar.

## 4. Pipeline com fases e gates
**Gate 0 — seleção:** escolher episódios por impacto educativo, mecânicas reutilizáveis e regiões existentes. Evitar gerar mapas ausentes sem planejamento.
**Gate 1 — pesquisa:** ficha bíblica + referências + gênero + fontes + fatos vs inferências vs ficção. Não validar por confiança subjetiva do modelo.
**Gate 2 — design:** objetivos claros, condição de entrada/saída, eventos observáveis e 3 níveis de dicas. Conferir se o jogador participa sem reescrever o texto bíblico.
**Gate 3 — verificação:** duas revisões independentes, uma bíblica e uma histórica; achados críticos bloqueiam publicação. Incertezas vão para fila humana.
**Gate 4 — assets e implementação:** mapear `target_id` para cena existente ou registrar asset/ambiente pendente. Criar JSON real, integrar ao QuestManager e salvar estados.
**Gate 5 — áudio:** locução opcional, dependente de aprovação textual; manifestos sempre gerados, áudio real quando houver provedor habilitado e orçamento autorizado.
**Gate 6 — QA:** testes de parser, fluxo, persistência, pacote exportado e integração com UI, registrando o que não pôde ser testado.
**Gate 7 — publicação:** habilitar a missão apenas se todos os gates exigidos passaram. Rascunhos podem existir no repositório, mas não aparecem como missões finalizadas para o jogador.

Os estados devem ser distintos: `idea`, `researched`, `designed`, `awaiting_biblical_review`, `awaiting_historical_review`, `approved_for_implementation`, `implemented`, `tested`, `published`, `blocked`. Não usar um único booleano `done`.

## 5. Modelo por episódio
Adapte à arquitetura real, preservando IDs já existentes. Para cada missão, gerar um pacote com:
- `manifest.json`: ID, versão, livro, capítulo/versículos, região, época (pode ser incerta), gênero literário, classificação bíblica, pré-requisitos, estado editorial, links para fontes.
- `quest.json`: objetivos com IDs estáveis, evento e target, contador/ordem, condições, dicas, resultado e gatilhos.
- `dialogues.json`: falas, personagens, retratos quando existentes, variantes e marcação do que é texto bíblico vs dramatização.
- `discoveries.json`: informações educativas, referências, classificação e texto breve/expandido.
- `audio_manifest.json`: IDs de falas, locutor, texto final, perfil de voz, arquivo de saída previsto, idioma pt-BR, estado de geração e direitos.
- `visual_manifest.json`: sprites e cenários existentes a reutilizar, lacunas gráficas, dimensões, animações e origem/licença de cada recurso.
- `review.json`: verificação bíblica, histórica, pendências, fontes, revisores e data.
- `test_report.json`: verificações executadas, falhas e evidências.

Não criar arquivos fantasmas ou referências a cenas que não existem. Gerar somente campos exigidos e suportados pelo loader real; use JSON Schema ou validadores equivalentes.

### Condições mínimas de cada objetivo
- Evento detectável pelo jogo (`talk_npc`, `inspect_object`, `visit_area`, `collect_item`, `deliver_item`, `observe_scene`, etc.).
- Target existente ou pendência explícita.
- Condição clara de conclusão, sem dependência impossível.
- Uma razão narrativa e, quando adequado, uma descoberta educativa.
- Uma dica implícita, outra intermediária e outra direta.
- Progresso idempotente quando o mesmo evento é disparado repetidamente.
- Compatibilidade com save/load e reinicialização via painel de depuração.

Se um novo tipo de evento exigir desenvolvimento de engine, planeje-o e prefira mecânicas genéricas reutilizáveis. Não acrescente dezenas de novos tipos só para uma missão.

## 6. Bíblia, ensino e integridade narrativa
O objetivo é **ensinar a Bíblia por meio de um jogo interessante**, não apenas mostrar referências.
- Sempre citar livro/capítulo/versículo, com validação independente antes de publicar.
- Os 66 livros do cânon protestante são a base inicial do catálogo, com arquitetura preparada para outras tradições canônicas.
- Separar `biblical_account`, `historical_context`, `fictional_interaction`, `parable_adaptation`, `poetry_visualization` e `prophetic_vision`.
- Parábolas devem ser reconhecidas como parábolas; sonhos/visões como tais; cartas e salmos não precisam fingir que são acontecimentos físicos.
- O jogador **não** abre o Mar Vermelho, **não** ressuscita Lázaro, **não** interpreta os sonhos no lugar de José, **não** substitui João Batista ou Jesus e **não** altera eventos centrais.
- Diálogos criados para NPCs fictícios são identificados como contextualização; fala dramatizada de personagem histórico não é citada como fala literal da Escritura.
- Não inventar data histórica exata. Registrar `chronology_confidence` e fontes; usar século/período ou `uncertain` quando adequado.
- Respeitar traduções bíblicas e direitos autorais; se não há licença para texto integral, usar referências e resumos originais conferidos.
- Todas as descobertas terão texto conciso no HUD e contexto expandido no diário; evitar popups constantes.

## 7. Diversidade de gameplay e qualidade
O catálogo-semente inclui várias ideias de observação e estudo. Não reproduzir isso mecanicamente 78 vezes. Cada lote deve ter variedade de pelo menos algumas dessas atividades: exploração, pista ambiental, diálogo contextual, organização, puzzles curtos, ajuda comunitária, coleta com sentido narrativo, rota, comparação de relatos, cena dirigida e reflexão opcional. Não impor quizzes como atividade central. Um episódio pode conter contemplação, mas não deve parecer um slideshow.

Para cada missão, projetar um objetivo principal, 3–6 objetivos jogáveis (ajustáveis) e duração-alvo aproximada conforme teste. As missões pequenas podem ser curtas. Evitar inflar artificialmente a duração. Planejar acessibilidade, controle por teclado, legendas, pular áudio e replay de informação no diário.

## 8. Produção de áudio — requisitos específicos
Implementar `AudioProvider` ou equivalente, configurável e desacoplado do diálogo. Gerar IDs estáveis por fala e cache por hash de texto + idioma + voz + parâmetros, evitando pagar novamente por texto inalterado. Produzir arquivos somente após revisão textual e verificação da licença comercial dos modelos/vozes. Manter `status: pending` caso não haja credenciais. Manifesto de voz precisa identificar NPC, tonalidade e pronúncia de nomes bíblicos. Som ambiente e música devem ser tratados em manifests separados, com origem e licença registradas. Evitar criar centenas de arquivos WAV desnecessariamente grandes. Ao integrar OGG/WAV/MP3, seguir os formatos aceitos pela versão Godot instalada e testar importação e exportação.

## 9. Ferramentas de edição e inspeção
Usando o sistema existente, implementar ou completar uma área de gerenciamento de conteúdo que permita:
- Listar todos os episódios do catálogo e seus estados editoriais/técnicos.
- Filtrar por livro, capítulo, época, região, tipo de experiência, dependências e dificuldade de implementação.
- Ver quais objetivos apontam para elementos ausentes no Godot.
- Abrir missão, diálogo, descoberta, revisão e áudio associados.
- Disparar geração de um pacote selecionado (via comando/script ou ferramenta integrada), validar e colocar na fila de implementação.
- Identificar o que foi **publicado**, o que está **em revisão** e o que é **apenas ideia**.
- Registrar falhas e custo de execução quando mensurável.

Preferir uma interface simples e funcional (EditorPlugin, CLI ou página local, conforme projeto), sem criar infraestrutura web ou servidor desnecessário. Não adicionar dependências pagas.

## 10. Primeira execução REAL
1. Audite o projeto e documente seus recursos reais.
2. Implemente/crie os arquivos dos subagentes em `.cursor/agents/` e configure as instruções do coordenador em `AGENTS.md`/AI Wiki, sem duplicação.
3. Importe o catálogo-semente de 78 propostas para a área de planejamento, **sem publicá-las**.
4. Escolha como piloto **A importância dos poços — Gênesis 26:18–22**, porque a aldeia de Canaã já existe no protótipo descrito; primeiro confirme seus NPCs/objetos reais. Se eles diferirem, adapte os alvos mantendo coerência.
5. Delegue pesquisa bíblica e contexto histórico; mande um verificador independente conferir; registre fontes e incertezas. O agente visual inventaria os assets de Canaã e fornece o manifesto.
6. Gere 1 missão com 3–5 objetivos, dicas, diálogos, descobertas, referências e áudio_manifest.
7. Integre ao Godot e teste de verdade progressão, HUD/diário e save/load. Se houver acesso a provedor TTS autorizado, produza um pequeno teste de voz; caso contrário deixe fallback em texto e um manifesto pronto, sem bloquear a missão.
8. Faça QA independente, corrija erros e deixe o piloto efetivamente jogável ou registre bloqueios objetivos.
9. Prepare um **segundo lote de apenas 3 propostas** para revisão (por exemplo, José em Canaã, José no Egito e Rute), estimando trabalho novo de mapa/asset/mecânica antes de autorizar implementação em massa.
10. Atualize CURRENT_STATE, HANDOFF e documentos específicos da wiki. Entregue relatório claro de arquivos alterados, agentes realmente executados, testes, problemas, custos medidos e próximo passo.

## Critérios de aceite
- Todos os agentes exigidos estão definidos e descobertos pelo Cursor, ou a limitação da instalação está relatada precisamente.
- Existe catálogo navegável com 78 ideias identificadas como não implementadas.
- O piloto possui objetivos realmente alcançáveis com targets existentes e revisão bíblica rastreável.
- Iniciar, progredir, concluir, salvar, carregar e reiniciar o piloto funciona ou bloqueios foram documentados sem simular sucesso.
- Manifestos de áudio e recursos visuais existem; áudio real somente se ferramenta, licença e credenciais estiverem disponíveis.
- Build Godot e validação dos JSON não apresentam novos erros críticos; relatar testes que não puderam ser executados.
- O fluxo pode criar a segunda missão **a partir de dados e delegação de agentes**, sem copiar manualmente grandes trechos de GDScript.

**Não gere as 78 missões como publicadas agora. Construa primeiro a fábrica de conteúdo, valide um piloto e depois escale por lotes pequenos com revisões independentes. Execute alterações reais no workspace, não entregue somente outro plano.**
