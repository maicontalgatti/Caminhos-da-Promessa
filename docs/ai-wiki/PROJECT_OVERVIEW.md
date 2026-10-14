# Visão geral do projeto

Detalhes completos em [docs/game_design.md](../game_design.md). Este arquivo é o resumo estável.

## Identidade
- **Nome:** Caminhos da Promessa.
- **Gênero:** RPG 2D de exploração em pixel art, vista 3/4 de cima (referência visual: Stardew Valley), sem combate como núcleo.
- **Objetivo:** ensinar e contextualizar a Bíblia de forma correta. O jogador é um **viajante fictício**
  que acompanha os acontecimentos, conversa com moradores e descobre o contexto histórico, cultural e
  geográfico, **sem alterar os relatos bíblicos**.
- **Público:** adolescentes, jovens e adultos, inclusive sem conhecimento bíblico prévio.
- **Plataforma atual:** Windows (exe único). Idioma: português do Brasil.
- **Responsável:** o criador do projeto (revisor humano do conteúdo bíblico). O código foi escrito com agentes de IA.

## Pilares (de game_design.md)
1. **Estar lá:** ambientes vivos e plausíveis.
2. **Fidelidade:** o jogador participa mas não substitui personagens bíblicos nem reescreve fatos; ficção sempre identificável.
3. **Descoberta tranquila:** sem pressão, sem questionários; aprender pelo contexto.
4. **Reverência:** acontecimentos espirituais nunca viram recompensa material.
5. **Crescimento por dados:** novas histórias, personagens e regiões entram por arquivos JSON.

## Tecnologia (resumo; justificativas em [DECISIONS.md](DECISIONS.md))
- Godot **4.7.2** (portátil em `tools/godot/`, fora do Git), GDScript, renderer **GL Compatibility**.
- Resolução base **480×270**, janela 1440×810, escala inteira; tiles 16 px; personagens 24×32.
- Fontes Pixelify Sans (títulos e botões) e Lora (textos de leitura), ambas OFL. Texto bíblico importado de tradução livre (ADR-016). Arte provisória gerada por código (`tools/art_gen/`).
- Conteúdo em JSON em `data/`; save em JSON versionado em `user://savegame.json`.

## Escopo atual
Uma aldeia fictícia em Canaã na época dos patriarcas, com prólogo, uma missão de contexto
(os poços de Abraão e Isaque, Gênesis 26), diário e descobertas. Estado exato em [CURRENT_STATE.md](CURRENT_STATE.md).

## Direção futura (planejada, não implementada)
Mapa das Escrituras como hub de experiências por época (patriarcas, José no Egito, Êxodo, reinos e
profetas, Galileia, igreja primitiva); inventário, dia/noite, áudio, interiores, personalização do
viajante. Ver [docs/roadmap.md](../roadmap.md).
