# Changelog

Resumo por versão/entrega. Detalhes, problemas corrigidos e o que não foi verificado estão em
[docs/implementation_log.md](../implementation_log.md).

## 2026-10-14 — Checkpoint no GitHub (documentação e repositório; jogo sem mudanças)
- Primeiro commit e envio para o repositório privado `maicontalgatti/Caminhos-da-Promessa` (branch `main`).
- `AGENTS.md` revisto; novos `AI_AGENTS.md` (inventário dos 9 subagentes e 3 regras) e `NEW_AGENT_START_HERE.md`; `GAME_SYSTEMS.md` e `README.md` da raiz atualizados.
- Auditoria de segurança sem achados; `.gitignore` e `.gitattributes` ampliados.
- Testes: teclas simuladas entregues na hora (KI-17); build 665/665.

## 2026-10-14 — v0.5.0: efeitos sonoros
- `AudioManager` (autoload) com buses Master/Music/SFX/UI/Ambience/Voice, limitador, conjunto fixo de players, prioridade, cooldown, variações e marcos coalescidos; manifesto `data/audio/sfx.json`.
- Passos por superfície (terra, grama, pedra) nos quadros de contato da animação, só com deslocamento real; corrida com som próprio.
- Som automático em todos os botões (clique, hover discreto, foco por teclado); diário, páginas, bolsa, Mapa das Escrituras, pausa, salvar, recusas; interação por material; bolsa (coleta, recebido, entregue, descartado, recompensa); diálogo (som de texto opcional); missões, descobertas, coleção, região nova; ambiente de Canaã, da estrada e de Dotã com troca suave e emissores no poço e na cisterna.
- Volume por bus com silenciar, em tempo real e salvo, no menu e na pausa.
- 131 arquivos procedurais (`tools/audio/`), auditados; **sem escuta humana** (KI-16). Guia em [docs/audio.md](../audio.md).
- Testes: 665/665, fluxo 17/17; autoteste do exe confere todos os sons.

## 2026-10-14 — v0.4.0: expansão para RPG de aventura bíblica
- Três regiões (Aldeia em Canaã, Caminho das Caravanas, Pastos de Dotã) com transição, título da região, salvamento automático e volta sem duplicar itens.
- Mapa das Escrituras (M) por épocas, com experiências planejadas visíveis; bolsa (I) com troca; colecionáveis e aba "Descobertas"; condições compostas e escolhas persistentes; categorias de missão e missão acompanhada; seta e "Siga para" quando o objetivo está em outra região.
- Missões: "O caminho para Dotã" (Gn 37:12-17), "Suprimentos para a viagem", "Duas famílias, uma decisão" (3 desfechos), "Registros da caravana".
- Save v3 com migração; validação da fábrica por região; autoteste do exe ampliado.
- Revisões de agente (bíblica, histórica, QA) aplicadas; nada aprovado por IA.
- Testes: 561/561, fluxo 17/17. Pendentes: `escort_npc`, mapas do Egito e de Belém, Gn 37:18-36 (KI-13).

## 2026-10-14 — v0.2.1: orientação na missão, leitura mais suave e texto bíblico
- Seta dourada sobre o alvo do objetivo (ou na borda da tela); objetivos dizem quem e onde; o diário abre o relato com E a qualquer momento; aviso de fim de conteúdo da versão.
- Fonte Lora nos textos de leitura (Pixelify segue em títulos e botões); espaçamento de linhas corrigido.
- Texto dos versículos no jogo: 196 versículos da Bíblia Portuguesa Mundial (domínio público) importados do arquivo oficial por `tools/import_scripture.gd`; apresentação de Gn 26 em 7 passos com versículos e notas; diário e falas do narrador citam o texto; créditos no menu e no `LICENSES.txt`. NVI pendente de permissão (KI-06).
- Testes: 239/239, fluxo 17/17.

## 2026-10-14 — AI Wiki (documentação; jogo sem mudanças)
- `AGENTS.md`, `docs/ai-wiki/` (12 documentos), regras em `.cursor/rules/`, `tools/check_wiki.ps1`.
- Correções de documentação desatualizada: `docs/roadmap.md`, `docs/game_design.md`, `docs/architecture.md`; link para a wiki no `README.md`.
- Verificação da wiki incluída como etapa informativa no build (`tools/build_windows.ps1`).

## 2026-10-14 — v0.2.0: missões, contexto histórico e aprendizado bíblico
- Prólogo, HUD de contexto, pistas, descobertas, apresentação de Gênesis 26, diário em 5 seções.
- Missão "A importância dos poços"; cronologia sem ano zero; 14 lugares, 8 pessoas, 12 descobertas.
- Status de verificação com revisor humano; canais prototype/public; save v2 com migração.
- Editor de missões (plugin), painel F3 de debug, validador de conteúdo.
- Testes: 208/208, fluxo 17/17, exe com autoteste ampliado.

## 2026-10-14 — Exportação Windows (v0.1.0)
- Exe único com PCK embutido, autoteste, `criar_exe_atualizado.bat`, exe copiado para a raiz.

## 2026-10-14 — v0.1.0: fundação jogável (fases 1–3)
- Projeto Godot 4.7.2, arte provisória procedural, aldeia em Canaã, jogador, 4 moradores e 3 ovelhas.
- Diálogos com escolhas e flags, 20 pontos de interação, menu, pausa, save JSON versionado.
- Catálogo inicial: 66 livros e 7 histórias-piloto.
