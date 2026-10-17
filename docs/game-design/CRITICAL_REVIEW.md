# Conselho de avaliação crítica — consolidado

- **Data:** 2026-10-16
- **Coordenador:** agente principal (Cursor), a pedido do criador
- **Agentes do conselho:** `game-benchmark-analyst`, `quest-pacing-auditor`, `narrative-depth-reviewer`, `world-npc-critic`, `biblical-learning-reviewer`, `player-experience-critic`
- **Estado inicial registrado:** ver seção 0; código e dados conferidos (não só docs)

## 0. Estado inicial (antes das melhorias desta entrega)

| Item | Evidência |
|---|---|
| Missão piloto jogável | `data/quests/canaan/canaan_wells.json` — 6 objetivos |
| Atividade física já existe | Objetivos `take_jar` + `water_trough` (3 viagens poço↔bebedouro) em diálogos `well_examine` / `canaan_trough` |
| Escolha já existe | `wells_reward` accept/decline do queijo em `adina_talk` |
| Ari opcional | `ari_talk` não é alvo obrigatório |
| Motor de diálogo | `start_if`, `choices`, `decision`, `scripture`, condições — já suportam hubs |
| Fábrica | 9 agentes de produção; **nenhum** crítico de ritmo/benchmark até esta entrega |
| Playtest humano | KI-02 aberto — nenhuma métrica de tempo real de jogador |
| Outras missões jogáveis | Dotã, Egito, mar, Belém/Rute/pastores em `data/quests/` (v0.4–v0.6) |

**Correção à premissa “só conversar–examinar–ler”:** na missão dos poços isso **não** descreve o fluxo completo. Há coleta, transporte repetido e escolha de recompensa. A fragilidade real é outra (abaixo).

## 1. Achados (formato padrão)

### CR-01 — Payload bíblico concentrado no fim
- **Sistema:** `canaan_wells` / conclusão + `read_story`
- **Descrição:** O trabalho corporal acontece cedo; Eseque/Sitna/Reobote e o grosso do ensino de Gn 26 chegam no bloco final (Ezer + apresentação).
- **Evidência:** objetivos 1–5 vs `read_story` + `completion.summary`; falas `disputes2–4` só em `return_jar`
- **Gravidade:** Importante
- **Comparação:** Spiritfarer/Eastward espalham lore ao longo da ação (**inferência**)
- **Recomendação:** Perguntas opcionais e notas curtas *durante* o transporte; manter apresentação completa no diário
- **Impacto:** Aprendizado sentido como descoberta, não epílogo
- **Custo:** Baixo (diálogos)
- **Dependências:** Nenhuma nova mecânica
- **Validação:** Unlock de contexto antes de `read_story`; playtest
- **Status:** Tratado no piloto — hubs Adina/Ezer/Ari + notas Gn 26:18 / 26:20 nas 1ª e 2ª viagens ao bebedouro; Gn 24:20 na 3ª; Ezer/apresentação fecham Eseque–Sitna–Reobote

### CR-02 — Poucas consequências duradouras
- **Sistema:** decisões / NPCs
- **Descrição:** `wells_reward` existe, mas pouco eco em falas posteriores; Ari não reage ao jogador carregando água.
- **Evidência:** grep `wells_reward` / `decision` nos diálogos da aldeia
- **Gravidade:** Moderado
- **Recomendação:** Flags de pergunta/decisão alterando `again` de NPCs
- **Custo:** Baixo
- **Status:** Tratado — eco de `wells_reward` em Adina/Ezer/Ari pós-missão; microconflito do “acordo das famílias” (ficção) com falas cruzadas Adina↔Ari

### CR-03 — Densidade social limitada na praça
- **Sistema:** mundo / NPCs
- **Descrição:** Quatro pessoas + ovelhas; suficiente para piloto, fraco vs aldeia “viva”. Design de 11 etapas (AUD-07) nunca virou jogo.
- **Evidência:** `data/characters/canaan_village.json`; AUD-07 em `docs/auditoria-tecnica.md`
- **Gravidade:** Moderado (não crítico para ensinar Gn 26)
- **Recomendação:** **Não** adicionar 5 NPCs de uma vez. No máximo 1–2 com função (ancião / pastor vizinho) num episódio futuro
- **Custo:** Médio (sprite, spawn, diálogos, testes)
- **Status:** Adiado — rejeitado como “melhoria rápida”

### CR-04 — Outras missões ainda mais “corredor de falas”
- **Sistema:** missões Dotã/Egito/mar/Belém
- **Descrição:** Muitas cadeias talk/travel/presentation; menos atividade corporal que os poços.
- **Evidência:** estrutura de `data/quests/dothan/`, `egypt/`, etc. (inspeção)
- **Gravidade:** Importante (padrão de fábrica)
- **Recomendação:** Poços como **padrão de qualidade**; próximas melhorias missão a missão
- **Custo:** Alto se feito em lote — **proibido** nesta entrega
- **Status:** Piloto em `joseph_dothan_road` (checklist + hubs opcionais); demais missões intactas

### CR-05 — Sem telemetria de ritmo
- **Sistema:** ferramentas / testes
- **Descrição:** Não há medição de minutos reais; só contagens estruturais e testes de fluxo.
- **Evidência:** KI-02; ausência de profiler de missão
- **Gravidade:** Moderado (para gestão de design)
- **Recomendação:** Estimativas explícitas + questionário humano (já rascunhado na conversa do criador)
- **Status:** Processo; sem código novo obrigatório

### CR-06 — Risco pedagógico se ficção crescer sem marcação
- **Sistema:** aprendizado bíblico
- **Descrição:** Conflitos fictícios de água são úteis **se** o jogo repetir que são ficção; senão confundem com Gn 26.
- **Evidência:** BIBLICAL_RULES; `classification_note` da missão
- **Gravidade:** Importante (ao ampliar)
- **Recomendação:** Narrador marca ficção; referências só via `scripture` / apresentação
- **Status:** Observado nas novas falas

## 2. Respostas obrigatórias — A importância dos poços

| # | Pergunta | Resposta (com evidência) |
|---|---|---|
| 1 | Quanto tempo leva? | **Estimativa estrutural:** ~8–20 min conforme leitura e se o jogador fala com Ari/Yaron. **Não medido** com humano. Contagem: 6 objetivos, ≥3 idas ao poço, 1 apresentação. |
| 2 | Atividade além de falar/examinar/ler? | **Sim:** pegar cântaro, 3 ciclos encher/despejar, escolha de queijo, devolver item. |
| 3 | Personalidades distintas? | Adina (prática, rebanho), Ezer (ofício, memória de seca), Ari (criança, memória do avô), Yaron (feira). Funciona; pouco eco mútuo. |
| 4 | Problema a resolver? | Sim: bebedouro seco antes do sol esquentar. |
| 5 | Descobertas naturais? | Parcial: várias no examine; `isaac_wells` amarrado ao arco final. |
| 6 | Conversas opcionais? | Ari e Yaron; Adina tem alguns ramos; trilha crítica ainda empurra para frente. |
| 7 | Escolha? | Sim (`wells_reward`); impacto social baixo. |
| 8 | Exploração significativa? | Aldeia aberta; interiores/feira existem; missão não obriga explorar tudo. |
| 9 | Desfecho satisfatório? | Completo tecnicamente; emocionalmente “entrega + aula”. |
| 10 | Ensina Gn 26? | Sim via apresentação + falas com `scripture`; risco de parecer apêndice. Status `pending_review` (IA não aprova). |

## 3. Plano priorizado

### Rápido (feito)
- Hubs opcionais Adina/Ezer/Ari + reação ao cântaro cheio
- Checklist de qualidade na fábrica
- Agentes do conselho + estes docs
- Eco de `wells_reward` + acordo das famílias (Adina/Ari), sem NPC novo
- Notas Gn 26:18/20 durante as viagens de água (CR-01)

### Médio esforço
- Aplicar checklist a **uma** missão Dotã — **feito:** [checklists/joseph_dothan_road.md](checklists/joseph_dothan_road.md); hubs opcionais Adina/Malik com Gn 37:15-17
- 1 NPC novo com função (ex.: ancião) só se playtest pedir

### Estrutural (depois)
- Roteiro de playtest respondível — **feito:** [PLAYTEST_ROTEIRO.md](PLAYTEST_ROTEIRO.md); telemetria em código ainda não
- Rotinas NPC ricas
- Revisão humana do conteúdo (KI-03)

## 4. Divergências do conselho

- **Alongar para 15–30 min:** pacing-auditor e PX-critic alertam contra padding. Meta é **densidade**, não relógio.
- **Muitos NPCs novos:** world-npc-critic e PX-critic contra; biblical-learning exige marcação de ficção.

## 5. Formato de achado (template)

```
### CR-XX — título
- Sistema/missão:
- Descrição:
- Evidência:
- Gravidade:
- Comparação (opcional):
- Recomendação:
- Impacto / Custo / Dependências / Validação / Status:
```
