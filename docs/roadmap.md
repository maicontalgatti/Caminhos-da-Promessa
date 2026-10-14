# Roadmap

| Fase | Entrega | Situação |
|---|---|---|
| 1. Fundação visual e técnica | Projeto Godot válido, docs, escala, paletas, padrões de sprite, arquitetura mínima | **concluída** |
| 2. Movimento e mundo | Personagem, animações, câmera, colisões, TileMapLayer, primeiro cenário, profundidade | **concluída** |
| 3. Ambientação e interação | NPCs, diálogos, interações, objetos, animações de ambiente, UI básica, salvamento | **concluída (aguarda validação jogando)** |
| 4. Sistemas de gameplay | Inventário, coleta, rotinas de NPC, horário do dia, áudio, transições entre mapas, novas interações | pendente (a v0.2 priorizou as fases 5–6 a pedido do criador) |
| 5. Catálogo bíblico | Livros, referências, classificação, banco narrativo, regiões históricas | em andamento (v0.2: cronologia, lugares, personagens, descobertas, status de verificação; todo conteúdo aguarda revisão humana) |
| 6. Primeiras experiências bíblicas | Primeiro capítulo jogável completo, com diário | iniciada (v0.2: prólogo, 1 missão — os poços de Gênesis 26 —, diário com 5 seções; falta revisão humana e teste jogando) |
| 7. Expansão | Mais regiões, épocas e histórias | pendente |

## Critérios de saída da Fase 3 (validar jogando)

- [ ] Movimento agradável (velocidade, aceleração, corrida).
- [ ] Escala de personagens e objetos legível em 1440×810 e em tela cheia.
- [ ] Profundidade correta ao passar atrás/na frente de casas, árvores e NPCs.
- [ ] Textos legíveis; ritmo da digitação confortável.
- [ ] Salvar, sair e continuar sem perda.

## Próximas atividades recomendadas (Fase 4)

1. Sessão de jogo do criador e ajuste fino (velocidades, câmera, tamanhos de fonte).
2. Transição entre mapas via `Interactable` do tipo DOOR (primeiro interior de casa).
3. Ciclo dia/noite simples + som ambiente da aldeia (licença livre verificada).
4. Inventário mínimo e coleta (ex.: levar água do poço ao oleiro) usando flags.
5. Rotinas de NPC por horário.
6. Esboço do Mapa das Escrituras (tela de navegação, sem conteúdo novo).
