# Design — ep_006_a_importancia_dos_pocos · "A importância dos poços"

- **Autor:** agente `quest-designer` (IA). **Status:** proposta, `pending_review` — nada aqui está aprovado.
- **Trecho:** `Gen 26:18-22` · **Modo:** `ficcao_contextual` · **Região:** `canaan_village` (aldeia fictícia em Canaã).
- **Missão no jogo:** `canaan_wells` (`data/quests/canaan/canaan_wells.json`). Esta proposta **não recria** a missão:
  melhora textos e acrescenta um objetivo, preservando todos os ids existentes.
- **Entradas usadas:** `research_biblical.md` (seções 6–8), `visual_manifest.json`, `docs/quests.md`,
  `scripts/quests/quest_database.gd`, `scripts/quests/quest_manager.gd`, `data/dialogues/canaan_village.json`,
  `data/bible/presentations.json` (`gen_026_wells`), `data/bible/discoveries.json`, `production/catalog/episodes.json`.
  Pesquisa histórica ainda não chegou: "filisteus" e a localização de Gerar são tratados como **debatidos**.
- **Validação executada:** `QuestDatabase.validate` e `validate_links` sobre `quest.proposal.json` (script temporário
  headless, Godot 4.7.2) → **0 erros** nos dois. Testes do projeto **não executados** (a proposta não está integrada).

---

## 1. Premissa
O viajante fictício chega a uma aldeia de Canaã criada para o jogo e percebe que a vida inteira gira em torno do poço
da praça. Conversando com moradores fictícios e observando o poço, entende por que a água organizava rebanhos, casas e
relações entre famílias — inclusive as disputas em anos de seca. No fim, lê no diário de viagem o relato de
`Gen 26:18-22` (apresentação `gen_026_wells`, com o texto dos versículos), onde Isaque reabre os poços de Abraão, cava
outros e dá nomes a Eseque, Sitna e Reobote.

## 2. Papel do jogador
**Observador e ouvinte.** O jogador não cava, não nomeia nem defende os poços de Isaque, não encontra Isaque nem os
pastores de Gerar, e não participa da aliança de `Gen 26:26-31` (restrições da seção 7 da pesquisa). O relato bíblico é
**estudado** (leitura), nunca testemunhado ou alterado. Toda fala livre é de moradores fictícios.

**Objetivo principal:** entender a importância dos poços na vida da aldeia e conhecer o relato de `Gen 26:18-22`.

## 3. Objetivos (ordem de execução)

| # | id | Texto | Evento (`complete_on`) | Alvo real | Motivo narrativo | Descoberta |
|---|---|---|---|---|---|---|
| 1 | `meet_adina` *(existente)* | Converse com Adina, a pastora. | `custom:wells_adina_water` (nó `water3` de `adina_talk`) | npc `adina` | A água organiza o rebanho e a aldeia; Adina aponta o poço. | `shepherding_water` (pelo diálogo) |
| 2 | `examine_well` *(existente)* | Examine o poço no centro da praça. | `dialogue_finished:well_examine` | dialogue `well_examine` | Observação ambiental: corda gasta, todos dependem do poço. | `wells_antiquity` (pelo diálogo) |
| 3 | `listen_ari` **(novo)** | Pergunte a Ari sobre o poço. | `dialogue_finished:ari_talk` | npc `ari` | Memória da aldeia: quando o poço secou, todos cavaram mais fundo. Eco **fictício e identificado** do tema "reabrir/manter poços" (`Gen 26:18`), sem tocar nos poços de Isaque. | — (nenhuma nova) |
| 4 | `talk_ezer` *(existente)* | Converse com Ezer, o oleiro. | `custom:wells_ezer_disputes` (nó `disputes4` de `ezer_talk`) | npc `ezer` | Guardar água e o risco de disputas entre pastores em anos de seca; nota do narrador remete a `Gen 26:20-21`. | `pottery_jars` (pelo diálogo) |
| 5 | `read_story` *(existente)* | Leia o diário de viagem sobre a pedra, ao lado do poço. | `presentation_finished:gen_026_wells` | dialogue `journal_intro` | Leitura do relato com o texto dos versículos e notas próprias do jogo. | `isaac_wells` (pela apresentação) |

Cada objetivo tem 3 pistas (indireta → contextual → objetiva) no `quest.proposal.json`.
Ritmo: conversa → observação → conversa curta (criança) → conversa → leitura. Não há três conversas com adultos
seguidas nem questionário.

## 4. Diferenças em relação à missão atual (e por quê)

| Mudança | Justificativa |
|---|---|
| **Novo objetivo `listen_ari`** entre `examine_well` e `talk_ezer` | A missão atual não toca o tema central de `Gen 26:18` — poços que precisam ser reabertos/mantidos. O diálogo de Ari **já existe** ("o poço secou e todo mundo teve que cavar mais fundo") e Ari está no mapa a ~45 px do poço (440,372). É a oportunidade 1/6 da pesquisa (poço fictício, contexto) sem o jogador cavar poços bíblicos. Também usa um morador que hoje não tem função na missão. |
| `fictional_characters` ganha `ari` | Ari passa a ser alvo; a ficção fica identificada no diário. |
| `log` de `meet_adina`, `examine_well`, `talk_ezer` reescritos | Registram o que o jogador de fato ouviu/viu nos diálogos atuais (antes eram genéricos). |
| `log` de `read_story` cita reabertura + Eseque/Sitna/Reobote | Distingue os poços reabertos (`26:18`) dos três novos (`26:19-22`) — risco "confundir os poços" da seção 8. |
| `completion.summary` reescrito (continua com 3 pontos) | (1) acrescenta "manter um poço era trabalho de todos" (liga ao objetivo de Ari); (2) separa reabrir × cavar novos e diz que **dois** foram disputados; (3) registra o que o texto diz em `26:22` — Isaque saiu dali e cavou um poço sem contenda — **sem** transformá-lo em herói nem os pastores de Gerar em vilões, e sem a leitura devocional de "mansidão" (que é interpretação). |
| `_comment` do arquivo anota a origem da proposta | Rastreabilidade para o integrador; pode ser removido na integração. |
| **Sem mudança:** id da missão, ids e eventos dos 4 objetivos originais, alvos, pistas originais, `start`, `discoveries`, `references`, `verification` | Saves antigos e testes de vínculo continuam válidos; `verification` fica `pending_review` sem revisor. |

### Compatibilidade com saves
O save guarda o **índice** do objetivo atual (`GameState.quests[id].objective`) e as flags `ev:<tipo>:<id>`. Com a
inserção na posição 3:
- Missão **concluída**: continua `completed` (status não é recalculado).
- Save com objetivo atual `meet_adina` ou `examine_well`: segue normal e passa por `listen_ari`.
- Save com objetivo atual `talk_ezer` (índice 2): o índice 2 passa a ser `examine_well`, já cumprido (flag existe) → avança
  sozinho para `listen_ari` (índice 3) — o jogador precisa falar com Ari (ou avança na hora se já falou com ele).
- Save com objetivo atual `read_story` (índice 3): o índice 3 passa a ser `talk_ezer`, já cumprido → avança sozinho para
  `read_story`. `listen_ari` fica marcado como feito sem ter sido feito; efeito apenas cosmético (sem descoberta perdida).
- Nenhum id foi removido ou renomeado; `start_if` de `adina_talk`, `ezer_talk` e `journal_intro` continuam casando.

### "Objetivo opcional"
O motor **não tem objetivos opcionais**: são sequenciais e obrigatórios (`QuestManager._advance`). `listen_ari` é,
portanto, obrigatório, mas barato (Ari fica junto ao poço; seta dourada aponta para ele) e retroativo (se o jogador já
conversou com Ari, conclui sozinho). Não foi incluído campo `"optional"` porque o motor o ignoraria e a promessa seria
falsa. **Plano B** sem risco: integrar só as melhorias de texto e omitir `listen_ari` (o JSON continua válido removendo
o bloco e `ari` de `fictional_characters`).

## 5. Mapeamento dos objetivos-semente (`production/catalog/episodes.json`, ep_006)

| Semente | Tipo no catálogo | Alvo no catálogo | No motor | Precisa de código? |
|---|---|---|---|---|
| `obj_01` Conversar com Adina sobre a água | `talk_npc` | `adina` | `meet_adina` → `custom:wells_adina_water`, alvo npc `adina` | Não |
| `obj_02` Examinar o poço e a descoberta bíblica | `inspect_object` | `village_well` (**não existe**) | `examine_well` → `dialogue_finished:well_examine`, alvo dialogue `well_examine` (id real). A "descoberta bíblica" vem em duas etapas: `wells_antiquity` (contexto, no poço) e `isaac_wells` (no `read_story`) | Não (corrigir o `target_id` do catálogo para `well_examine`) |
| `obj_03` Conversar com Ezer sobre os conflitos por poços | `talk_npc` | `ezer` | `talk_ezer` → `custom:wells_ezer_disputes`, alvo npc `ezer` | Não |

`talk_npc`/`inspect_object` não são `EVENT_TYPES`; equivalem a `custom` (nó com `event`) ou `dialogue_finished`
(`interact` também serviria para objetos, mas registra antes de o jogador ler o texto). Nenhum `visit_area` é usado; o
equivalente mais próximo no motor seria `region_entered`, que só distingue regiões inteiras. A estimativa do catálogo
(`data_only`, `difficulty: low`) está correta.

## 6. O que exige trabalho do integrador (não código de motor)

| Item | Onde | Esforço |
|---|---|---|
| Substituir o objeto da missão por `quest.proposal.json` (manter `_comment` original se preferir) | `data/quests/canaan/canaan_wells.json` | 5 min |
| **Atualizar testes** que esperam `read_story` logo após Ezer: registrar `dialogue_finished:ari_talk` antes das checagens | `tests/test_runner.gd` (~l. 270-274 e ~l. 613-615); conferir `tools/screenshot/capture.gd` (~l. 111) | 15 min |
| Atualizar a tabela de objetivos (4 → 5) e o roteiro manual | `docs/quests.md` (Fluxo do jogador, item 5; Como testar) | 10 min |
| Atualizar `seed_objectives[1].target_id` para `well_examine` | `production/catalog/episodes.json` | 2 min |
| Rodar `test_runner`, `flow_smoke`, `validate_content` | — | 5 min |

### Melhorias opcionais (dados, sem código)
- **Nó de Ari ligado ao objetivo** (~15 min, só JSON): em `ari_talk`, `start_if` com
  `{"objective": "canaan_wells/listen_ari", "node": "well"}` e um nó que repete a história do avô mesmo para quem já
  conheceu Ari (hoje o nó `again` não repete). Se emitir `event: "wells_ari_deeper"`, trocar o `complete_on` para
  `custom:wells_ari_deeper`. **Não** fiz isso na proposta porque esse evento ainda não existe e o validador recusaria.
- Frase final de Ezer ou Ari mencionando que "cada família quer o seu poço" reforçaria convivência — opcional.

## 7. O que exigiria código novo (fora desta proposta)

| Ideia | Por que precisa de código | Esforço estimado |
|---|---|---|
| Objetivos opcionais (`"optional": true`) | `QuestManager` avança só sequencialmente; seria preciso pular/contabilizar opcionais, HUD e diário mostrarem "opcional", testes e editor | 3–5 h |
| Bebedouro junto ao curral (`water_trough` do manifesto) como ponto de interação | Arte nova no gerador + instância no mapa + diálogo `trough_examine` | 1–2 h arte + 30 min dados/cena |
| Poço entulhado/reaberto fora da aldeia (`well_reopened`) | Arte nova (2 estados) + mapa + diálogo; estado visual por flag exige script | 2–4 h |
| Mediação entre duas famílias fictícias pela água (oportunidade 4 da pesquisa) | Dados bastam para escolhas/flags, mas faltam NPCs e sprites de duas famílias | 4–6 h (arte + diálogo + revisão) |
| Cena/ilustração de Isaque em Gerar | Não recomendada nesta versão (manifesto e pesquisa): risco de falas inventadas | alto; fora do escopo |

## 8. Riscos bíblicos tratados

| Risco (pesquisa, seção 8) | Como a proposta trata |
|---|---|
| Falas de Isaque nos poços | Nenhuma. O relato só aparece na apresentação (texto dos versículos) e em resumos com referência. O resumo final parafraseia `26:22` sem citar falas. |
| Heroísmo / vitimização | Texto neutro: "os pastores de Gerar disputaram dois deles"; "Isaque saiu dali e cavou um poço sem contenda (Gn 26:22)". Sem "mansidão" ou "vilões". |
| Confundir os poços | `read_story.log` e o resumo separam os poços reabertos (`26:18`) dos três novos (`26:19-22`). Berseba (`26:25`, `26:32-33`) não é citada. |
| Confundir Isaque com Abraão | Abraão aparece só como quem cavou os poços originais. `Gen 21` fica restrito à descoberta `wells_antiquity`, que já existe. |
| "Filisteus" | Os textos da missão não usam a palavra; a questão continua tratada como debatida na seção `interpretation` de `isaac_wells`. |
| Localização de Gerar | Nenhum texto da missão situa Gerar ou Reobote. A aldeia é "em Canaã", fictícia, sem relação geográfica afirmada com o relato (pendência 8 da pesquisa continua com o revisor humano). |
| Significado de Sitna | A missão não define os nomes; só a apresentação existente o faz (risco registrado abaixo). |
| Prosperidade como recompensa | Nenhuma recompensa material; descobertas são conhecimento. |
| Rebeca (`26:7-11`) e "água viva" × `Jo 4` | Fora da missão. |
| Ficção do jogador | O jogador só observa/ouve; `listen_ari` é memória **da aldeia fictícia**, não dos poços de Isaque. |

### Pendências para revisão humana (não resolvidas aqui)
1. A apresentação `gen_026_wells` afirma o sentido de Sitna ("inimizade/oposição") e Reobote ("lugares amplos") como
   notas do jogo; a pesquisa pede conferir em léxico (itens 3 e 10.3). Não alterei (fora do meu escopo de entrega).
2. O passo 1 da apresentação diz que Gerar fica "no sul de Canaã" — localização tratada como debatida na pesquisa.
3. `Gen 26:12-14` na apresentação: conferir se a nota "Rebanhos grandes precisam de muita água" não sugere que a
   bênção é mecânica; parece segura, mas cabe ao revisor.
4. `adina_talk/flock2` cita os filhos de Jacó em Siquém — outra geração; não afeta esta missão, mas convém revisar
   coerência temporal da aldeia (Isaque × filhos de Jacó no mesmo "presente").
