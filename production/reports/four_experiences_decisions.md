# Lote "quatro experiências" — decisões e especificação comum

Lote: ep_009 (José no Egito), ep_016 (A travessia do mar), ep_025 (Rute em Belém), ep_048 (Os pastores de
Belém). Branch `content/four-experiences`, um único pull request. Iniciado em 2026-10-14.

## Decisões do criador (2026-10-14)
- As quatro experiências num único pull request, em ordem cronológica.
- Venda de José: cena **jogável de observação** — o viajante vê de longe a caravana, sem interferir.
- Sobrenatural (mar, anjo): **cena visual dirigida no mapa**, que o jogador assiste sem controlar.
- Depois de funcionar: integrar na `main`, gerar o exe e publicar um Release (só com aprovação do criador).

## Decisões provisórias do coordenador (pendentes de revisão do criador)
Tomadas pela opção mais conservadora sugerida nas fichas de pesquisa. Cada uma pode ser revista sem
reescrever sistemas.

### ep_009 — José no Egito
- Escopo bíblico: Gn 37:25-28, 36 (caravana vista de longe) + Gn 39:1-6 (casa de Potifar). **Gn 39:7-23 fica fora** (assédio, falsa acusação, prisão → ep_010).
- Cena da caravana: na região `dothan` (já existe), vista de uma elevação; José aparece como silhueta pequena entre os mercadores, sem correntes, chicote, choro ou close; a venda em si não é mostrada de perto. Camelos na caravana (o texto os cita; datação debatida fica no diário como hipótese).
- Ismaelitas/midianitas: o jogo usa a alternância do texto, sem "resolver".
- Prata: "vinte peças de prata" (pesadas, não moedas); sem comparação com Lv 27 / Êx 21 (H5 continua aberto).
- Sem Sl 105 e At 7 por enquanto.
- Passagem entre os mapas: cartão "OUTRO MOMENTO DA HISTÓRIA" (o viajante não viaja com a caravana).
- Egito: sem pirâmides, sem Faraó nomeado, sem dinastia. Potifar sem falas e sem caráter além do texto; servos fictícios.

### ep_016 — A travessia do mar
- Cena dirigida cobre Êx 14:19-22 (coluna entre os acampamentos, vento oriental a noite toda, águas como muro, povo atravessando). Termina com o povo do outro lado ao amanhecer (14:30-31 citado).
- Morte dos egípcios (14:27-28): só narração curta com referência; sem imagem de afogamento, sem celebração; não afirmar que o faraó morreu.
- Moisés: figura distante com a vara (14:16), mão estendida (14:21); sem falas livres; 14:13-14 só como paráfrase identificada.
- Nome no jogo: "o mar"; o debate *yam suf* fica no diário.
- Êx 15: só eco (tamborins ouvidos ao longe) e referência.
- O viajante não "atravessa jogando": a cena é um corte; depois ele está do outro lado.
- `pilot.json` (escolta/ajudar na travessia) diverge: o jogo segue a decisão do criador; registrar divergência.
- Cena pulável; aviso de conteúdo não é necessário (sem violência mostrada).

### ep_025 — Rute em Belém
- Escopo: Rt 1:19-22 (chegada) e Rt 2:1-23 (respiga nos campos de Boaz). Cap. 3 (eira à noite) e cap. 4 ficam fora; o portão aparece só como cenário.
- Rute, Noemi e Boaz sem falas livres; diálogos de moradores fictícios (ceifeiros, respigadoras).
- Lei da respiga (Lv 19:9-10; 23:22; Dt 24:19) como contexto, com referência.

### ep_048 — Os pastores de Belém
- Anjo: **só luz** (glória do Senhor ao redor dos pastores), sem figura; multidão celestial como luzes/brilho sóbrio, sem asas.
- Pastores do relato: 3 representados (rótulo "representação; o texto não diz quantos").
- Belém e a casa da manjedoura vistas **de fora**; casa de pedra encostada na rocha com área de animais; *katalyma* marcado como debatido; sem cena do parto; sem estrela, magos, neve ou pinheiro.
- Só texto (sem voz).
- Datação: nenhum ano exibido; `chronology.json` (−6 a −4, approximate) diverge da ficha → registrar em KNOWN_ISSUES.

## Encadeamento (ordem cronológica)
`joseph_egypt` requer `joseph_dothan_road`; `exodus_sea` requer a principal de `joseph_egypt`
(`joseph_potiphar_house`); `ruth_bethlehem` requer a principal de `exodus_sea` (`exodus_sea_crossing`);
`shepherds_bethlehem` requer a principal de `ruth_bethlehem` (`ruth_gleaning`).

## Infraestrutura necessária (consolidada dos designs)
1. Cena dirigida (abaixo), evento `scene_finished`, tipo de objetivo `observe_scene`.
2. Experiência com etapas: `stages` em experiences.json (cartão "OUTRO MOMENTO DA HISTÓRIA" ao passar de uma
   região a outra dentro da mesma experiência, ex.: Dotã → Egito) e `passage` opcional em saídas de mapa.
3. Mapa das Escrituras: experiência concluída/disponível tem botão para ir (revisitar); `travel` (região e
   entrada) em cada experiência; `entry_if` para escolher a entrada conforme o progresso.
4. Luz do mapa por estado: `lighting` na região (lista de `{if: condição, tint: "#rrggbb"}`), avaliada ao entrar
   e quando flags mudam; usada para tarde/noite/amanhecer.
5. Extensões da cena pedidas pelos designers: reposicionar o jogador (`player_to`), pose de ator (`pose`), estado
   final aplicado ao pular (`on_end` com `set_flags`), som.

## Especificação comum: cena dirigida (`directed scene`)
Mecânica nova, reutilizável, orientada a dados (ADR a registrar). O jogador assiste; o controle volta no fim.

- **Dados:** `data/scenes/<id>.json`, com `id`, `region`, `title`, `classification`, `references`,
  `verification`, `skippable: true` e `steps` (lista ordenada).
- **Ids de personagens fictícios novos:** prefixo da região para não colidir entre pacotes (`egypt_ipi`,
  `sea_tzvi`, `bf_ilan`, `bn_tamir` etc.).
- **Gatilho:** efeito de diálogo `"action": {"scene": "<id>"}` (mesmo formato de `{"presentation": id}`) ou objetivo/área; ao terminar (ou ao pular)
  emite o evento de missão `scene_finished` com o id da cena (objetivo `observe_scene` passa a ser `data_only`).
- **Passos** (cada um com `wait` opcional para esperar o fim):
  - `camera` — `{"to": [x, y], "time": s}` ou `{"follow": "player"}`; `zoom` opcional.
  - `actor` — cria um figurante temporário: `{"id", "sprite" (personagem de data/characters ou silhueta), "at": [x, y], "facing"}`.
  - `move` — `{"actor", "path": [[x, y], ...], "speed"}`.
  - `remove` — `{"actor"}`.
  - `tint` — cor/luz do mapa (noite, amanhecer): `{"color": "#rrggbb", "time": s}`.
  - `effect` — efeitos do mapa, ligados e desligados: `light_glow` (luz suave num ponto, raio), `pillar` (coluna de nuvem/fogo), `wind` (partículas e balanço), `water_walls` (corredor com paredes de água entre dois pontos; abre ao longo do tempo), `dust` (poeira distante). `{"effect", "on": true/false, "at", "params"}`.
  - `caption` — legenda na base da tela: `{"scripture": "Exod 14:21"}` (texto do arquivo oficial, com referência) ou `{"text": "...", "kind": "narration|context|fiction"}`.
  - `sfx` — som do manifesto.
  - `wait` — `{"time": s}`.
- **Regras:** nunca dá item, ponto ou poder (regra 12); legenda bíblica só por referência ao texto oficial; texto
  próprio identificado; `Esc` pula para o estado final; salvar durante a cena não é possível (UI bloqueada);
  ao carregar, cena concluída não repete.
