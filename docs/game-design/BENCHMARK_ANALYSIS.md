# Análise comparativa (benchmark) — Caminhos da Promessa

- **Data:** 2026-10-16
- **Papel:** `game-benchmark-analyst` (coordenador consolidou)
- **Escopo:** princípios de design, não cópia de expressão criativa
- **Fontes:** documentação pública e memória de design dos títulos citados; **não** houve sessão de jogo pessoal nesta análise. Itens marcados **inferência** quando não há fonte citada.

Referências: Stardew Valley, Don't Starve, Graveyard Keeper, Eastward, Roots of Pacha, Spiritfarer.

## Princípio-filtro (CdP)

CdP ensina Bíblia com ficção marcada e sem alterar relatos. Mecânicas de sobrevivência hostil, combate letal ou humor que trivializem o sagrado **não** são alvos de cópia.

## Tabela por critério

| Critério | Referências (síntese) | Em CdP hoje | Diferença é problema? | Aproveitar | Esforço | Como verificar |
|---|---|---|---|---|---|---|
| Ritmo de exploração | Stardew/Roots: dia com várias atividades curtas; Spiritfarer: viagem + cuidado | Exploração livre na aldeia + várias regiões; primeira missão tem loop de 3 viagens | Parcial: outras missões ainda “fale→vá→fale” | Manter loop físico; espaçar payload bíblico | Baixo–médio | Tempo em movimento vs diálogo (estimativa + playtest) |
| Densidade de interações | Eastward/Stardew: muitos hotspots com 1–2 linhas úteis | Muitos examináveis na aldeia; NPCs poucos na praça | Moderado na aldeia piloto; Dotã/Egito variam | Hotspots com reação a flags de missão | Baixo | Contar hotspots que mudam com quest |
| Complexidade de missões | Graveyard/Spiritfarer: arcos com atos | Poços: 6 objetivos + atividade; outras: cadeias talk/travel | Sim para missões só diálogo | Estrutura em atos (doc fábrica) | Médio | Checklist de atos preenchida |
| Variedade de objetivos | Vários tipos no gênero | Motor já tem 15 tipos; uso desigual | Sim se só `talk_to_npc` | Forçar variedade no design gate | Baixo (processo) | Contagem de tipos por missão |
| Rotinas de NPC | Stardew: schedules ricos | `schedule.night` + wander básico | Importante a médio prazo | Expandir rotinas onde enriquecer | Alto | Observação + flags de horário |
| Profundidade de diálogos | Eastward: hubs de pergunta | Algumas árvores (Yaron); Adina/Ezer parcialmente | Sim na trilha crítica linear | Hubs opcionais sem gate | Baixo | Opções não obrigatórias jogáveis |
| Progressão de regiões | Spiritfarer/Eastward: mapa que abre | WorldManager + experiências | Adequado ao escopo | Manter; clareza de “próximo destino” | — | Mapa M compreensível (playtest) |
| Recompensas | Itens, relacionamentos, unlocks | Queijo/escolha, descobertas, conclusão | Moderado: pouca reação duradoura | Flags de decisão → falas futuras | Baixo–médio | Decision ids usados depois |
| Descobertas/segredos | Roots/Stardew: lore opcional | Sistema de descobertas + diário | Bom alicerce | Descobertas no meio da ação, não só no fim | Baixo | Ordem de unlock |
| Sensação de progresso | Barras, estações, barco | Objetivos + seta + diário | Adequado se pistas H forem usadas | — | — | Playtest novato |
| Liberdade | Stardew: ordem flexível | Ordem de objetivos rígida na maioria | Aceitável para ensino; opcionais liberam | Opcionais claros | Baixo | % conteúdo opcional tocado |
| Narrativa ambiental | Eastward: cenário conta história | Examináveis com contexto | Bom na aldeia | Manter padrão | — | — |
| Atividades secundárias | Ofícios, pesca, etc. | Feira, ofício oleiro, trocas | Bom começo | Amarrar ofício à missão quando couber | Médio | — |
| Motivação para continuar | Arcos emocionais (Spiritfarer) | Experiências em cadeia v0.6 | Depende de playtest humano (KI-02) | Gancho emocional fictício sem alterar Escritura | Médio | KI-02 |
| Rejogabilidade | Stardew: temporadas | Baixa (protótipo linear) | Não prioritário agora | Escolhas com desfechos fictícios | Médio | Decisões distintas |

## O que NÃO copiar

- Sobrevivência punitiva estilo Don't Starve (contrário ao tom acolhedor/educativo).
- Relacionamento romântico como eixo (fora do escopo atual).
- Grind de crafting sem narrativa bíblica.

## Oportunidades priorizadas

1. **Hubs de diálogo opcionais** na trilha (baixo esforço, alto valor pedagógico).
2. **Consequências locais** de decisões fictícias (flags → falas).
3. **Checklist de atos** na fábrica (processo).
4. Rotinas ricas de NPC (estrutural, depois).
