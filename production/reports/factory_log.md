# Registro da fábrica de missões

Uma entrada por execução. Custos: o Cursor não expõe consumo por subagente; quando não houver medida
real, escreve-se "não mensurado". Nenhum serviço pago foi usado até aqui.

## 2026-10-14 — Primeira execução (piloto ep_006 + preparação do segundo lote)

Coordenador: agente principal da sessão. Subagentes lançados como `generalPurpose` com instrução de
ler e obedecer a `.cursor/agents/<papel>.md` (ver `docs/mission_factory.md`, limitação KI-10).

### Ferramentas
- `tools/factory.gd` + `tools/factory/factory_catalog.gd`: catálogo, gates, referências, alvos, áudio.
- `import-seed`: 78 episódios em `production/catalog/episodes.json`, todos `idea`.
- `check-refs` contra o texto oficial (eBible `porbrbsl`): 77 ok, 1 ok com nota (Atos 8:37 ausente na BPM, variante textual), 0 erros.

### Agentes
| Rodada | Papel | Episódio | Entrega | Situação |
|---|---|---|---|---|
| 1 | biblical-researcher | ep_006 | `research_biblical.md` | entregue |
| 1 | historical-reviewer | ep_006 | `research_historical.md` (salvo pelo coordenador) | entregue; nenhum anacronismo grave; 4 pontos de atenção na arte |
| 1 | visual-asset-producer | ep_006 | `visual_manifest.json` | entregue; missão jogável com a arte atual, 6 lacunas opcionais |
| 2 | quest-designer | ep_006 | `design.md`, `quest.proposal.json` | entregue; ids preservados, objetivo novo `listen_ari` (aceito) |
| 2 | dialogue-writer | ep_006 | `dialogues.proposal.json`, `discoveries.proposal.json`, `quest.patch.md` | entregue; evento novo `wells_ari_well`; 6 notas para `gen_026_wells` |
| 3 | biblical-verifier | ep_006 | veredito + achados (somente leitura) | em andamento |
| 3 | historical-reviewer | ep_006 | veredito + achados (somente leitura) | em andamento |
| lote 2 | biblical-researcher | ep_008 | `research_biblical.md` | entregue; 10 itens para revisão humana; mapa novo `dothan_fields` pequeno |
| lote 2 | biblical-researcher | ep_025 | `research_biblical.md` | entregue; mapa novo de Belém, coleta de espigas exige código |
| lote 2 | biblical-researcher | ep_011 | `research_biblical.md` | entregue; faraó sem nome; mapa egípcio novo; 6 questões abertas |

Plano do segundo lote: [batch2_plan.md](batch2_plan.md).

### Gates
- ep_006: `idea` → `researched` → `designed` (via `set-status`, gates aceitos).
- Segundo lote escolhido: ep_008 (José e seus irmãos), ep_011 (José e o tempo de fartura), ep_025 (Rute). ep_009 (Potifar) adiado: tema adulto pede cuidado editorial maior.

### Custos
- Serviços pagos: nenhum.
- Uso de modelo dos subagentes: não mensurado.
