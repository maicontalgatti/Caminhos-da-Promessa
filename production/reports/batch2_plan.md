# Segundo lote — plano de produção (não implementado)

Preparado na primeira execução da fábrica (2026-10-14). Os três episódios estão em `idea`, com pacote criado
(`factory new`) e pesquisa bíblica de agente (`research_biblical.md`, `pending_review`). Faltam pesquisa
histórica, design, revisões e decisões humanas abaixo. Nada foi implementado.

| Episódio | Referência | Mapa | Mecânicas que faltam | Dificuldade |
|---|---|---|---|---|
| `ep_008_jose_e_seus_irmaos` | Gn 37:12-36 | novo e pequeno (`dothan_fields`, pastos e cisterna seca), reaproveitando a arte de Canaã | gatilho de área dentro do mapa (a chegada ao mapa já gera `region_entered`) | média |
| `ep_011_jose_e_o_tempo_de_fartura` | Gn 41:1-57 | novo (cidade e armazéns no Egito), paleta e arte egípcias; pode servir também ao ep_012 | organizar estoque (aproximável por diálogo) | alta |
| `ep_025_rute_noemi_e_boaz` | Rute 1–4 | novo (Belém: porta da cidade, campos de cevada, eira) | coleta de espigas com contador e entrega (não há inventário) | alta |

Ordem sugerida: ep_008 primeiro (menor mapa, só um gatilho de área novo), depois ep_025 (pede a mecânica de
coleta, útil para outros episódios), depois ep_011 (maior esforço de arte).

## Texto bíblico a importar
`bpm.json` só tem os versículos usados hoje. Antes do design: Gn 37:1 e ecos (Gn 42:21-22; 45:4-8; 50:15-20) se
usados; Gn 41 inteiro; Rute 2–4, Lv 19:9-10, 23:22, 25:25, Dt 24:19, 25:5-10. `verse_counts.json` não tem esses
capítulos (KI-11); `factory check-refs <vpl>` confere contra o arquivo oficial.

## Decisões humanas pendentes (das pesquisas)
**ep_008**
1. A venda de José aparece em quadros ou só é relatada depois? Define o nível de violência.
2. "Túnica de muitas cores" (léxico) e os camelos (possível anacronismo): o jogo comenta?
3. `data/bible/places.json` afirma Tell Dothan e Tell Balata sem grau de confiança.
4. Ecos posteriores (Gn 42, 45, 50) entram aqui ou nos episódios seguintes?
5. Gn 37:10 ("sua mãe") depois da morte de Raquel (Gn 35:19): sugestão é não abordar.

**ep_011**
1. Usar "Nilo" para o "rio" de Gn 41:1 e dizer que Om é Heliópolis?
2. Como mostrar o novo nome de José e o casamento com Asenate?
3. A atividade de organizar um estoque fictício é aceitável?
4. Gn 47:13-26 fica fora do episódio?
5. A elevação de José aparece em quadros ou só contada por moradores?

**ep_025**
1. Rute 4:5 ("de Rute" × "Rute"): conferir possível variação textual.
2. Como resumir os gestos da eira (Rute 3), de sentido debatido.
3. Relação de Rute 4 com Lv 25:25 e Dt 25:5-10 (Boaz não é cunhado: não é levirato literal).
4. Tratar a tensão entre Dt 23:3 e Rute moabita na linhagem de Davi?
5. Genealogia seletiva, grafia Salmom/Salma, Raabe em Mt 1:5, medidas (efa) e se a viúva fictícia lembra Noemi demais.

## Próximos passos por episódio
1. `historical-reviewer` (pesquisa) → salvar `research_historical.md` → `set-status researched`.
2. Decisões humanas acima.
3. `quest-designer` e `dialogue-writer` (só no pacote).
4. Revisão bíblica e histórica em paralelo → `review.json`.
5. Implementação: mapa novo + mecânica (código) pelo integrador único; depois áudio e QA.
