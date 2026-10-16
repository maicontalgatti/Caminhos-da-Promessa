# Testes

Todos os comandos rodam na raiz do projeto, em PowerShell. O Godot portátil fica em `tools/godot/`
(fora do Git; ver [README.md](../../README.md) para baixar).

```powershell
$g = ".\tools\godot\Godot_v4.7.2-stable_win64_console.exe"
```

## Como classificar resultados (obrigatório nos relatórios)
- **Realizado e aprovado:** executado agora, saída e código de saída conferidos.
- **Realizado e reprovado:** executado, com falha (cite a mensagem).
- **Não executado:** diga por quê.
- **Resultado não verificável:** não há como conferir daqui (ex.: sensação de jogo, comportamento em outra máquina).

## Testes disponíveis

| Teste | Comando | O que cobre | Último resultado |
|---|---|---|---|
| Suíte principal | `& $g --headless --path . res://tests/test_runner.tscn` | entradas, dados, diálogos, cenas de props, catálogo, cronologia, referências e versículos, texto bíblico importado (tradução, expansão de referências, todas as referências com texto, citações em falas), política de conteúdo, missões (dados, alvos em todas as regiões, fluxo real, pistas), diário (inclui texto bíblico, categorias e Descobertas), modelo do editor, save v1/v2/v3, gameplay na cena real (movimento, prólogo, HUD, seta do objetivo, diário, apresentação com versículos), menu; e, por `tests/world_tests.gd`: regiões e entradas, viagem e volta, bolsa, coleta sem duplicação, troca com Malik (inclusive salvar no meio), 3 desfechos das famílias com save/load, missões entre regiões, missão principal de Dotã, seta para a saída e para registros não encontrados, teclas I/M/Esc, validação da fábrica; e, por `tests/audio_tests.gd`: buses e limitador, todo arquivo do manifesto existe, carrega e não está silencioso nem saturado, materiais de todos os examináveis, som de todos os itens, ambiente das 3 regiões, superfícies (pedra, terra, grama), cooldown, limite de instâncias, prioridade, conjunto fixo de players, marcos coalescidos, silêncio ao carregar e fora do jogo, sinais reais (missão, descoberta, bolsa), recusas sem som, botões automáticos (clique, hover, foco por teclado, desabilitado), diálogo, interação sem som duplo, volumes por bus com persistência e arquivo antigo, passos andando/correndo/parado/contra parede/com diário aberto, telas, pausa e salvar, troca de região com um único ambiente | 665/665 aprovados (2026-10-14, checkpoint v0.5.0; houve falhas intermitentes antes, KI-17) |
| Auditoria de áudio | `& $g --headless --path . --script res://tools/audio/audit_audio.gd` | duração, pico, RMS, saturação e DC de cada WAV em `assets/audio/` | 131 arquivos, 0 problemas (2026-10-14) |
| Fluxo pelos menus | `& $g --headless --path . --script res://tests/flow_smoke.gd` | novo jogo, pular prólogo com Esc, missão ativa, diário pela pausa, salvar, continuar sem repetir o prólogo | 17/17 aprovados (2026-10-14) |
| Validação de conteúdo | `& $g --headless --path . --script res://tools/validate_content.gd` | erros de dados e relatório de status de verificação, inclusive do texto bíblico | sem erros; 72 itens sem aprovação humana + texto BPM (220 versículos) aguardando verificação (2026-10-14, v0.4.0) |
| Fábrica | `& $g --headless --path . --script res://tools/factory.gd -- check` | catálogo, gates, referências, alvos por região, itens, conjuntos e escolhas das missões implementadas | 0 erros em 78 episódios (2026-10-14) |
| Build + autoteste do exe | `.\criar_exe_atualizado.bat` ou `powershell -ExecutionPolicy Bypass -File tools\build_windows.ps1` | importação, testes, fluxo, validação, verificação da wiki (informativa), exportação, `-- --self-test` (inclui regiões, mapas, itens, colecionáveis, missões da v0.4 e os 131 arquivos de som), boot headless e com renderização, cópia para a raiz | 2026-10-14 15:12, checkpoint v0.5.0: todas as etapas aprovadas (o build das 15:11 reprovou, KI-17) |
| Capturas de tela | `& $g --path . res://tools/screenshot/capture.tscn` e `res://tools/screenshot/capture_v04.tscn` | 21 telas da v0.2 e 10 da v0.4 (`docs/images/v04_*.png`; precisa de GPU; janela abre) | v0.4 conferidas visualmente em 2026-10-14 |
| Wiki | `powershell -ExecutionPolicy Bypass -File tools\check_wiki.ps1` | arquivos obrigatórios, links, caminhos citados, campos do estado e da passagem de bastão, versão | OK em 2026-10-14; teste negativo confirmou a detecção de erros |

A saída da suíte termina em `==== N passaram, M falharam ====`; o código de saída é 0 só sem falhas.

### GitHub Actions
`.github/workflows/tests.yml` roda em todo pull request, em push na `main` e manualmente: baixa o Godot
4.7.2 oficial para Linux (conferido por SHA-512), importa o projeto duas vezes e roda suíte, fluxo,
validação, fábrica e auditoria de áudio, com permissão somente de leitura e sem segredos. Não roda o
build do exe nem a verificação da wiki (PowerShell/Windows). Resultado: ver
[Actions](https://github.com/maicontalgatti/Caminhos-da-Promessa/actions) e o [HANDOFF.md](HANDOFF.md).

## Teste manual (jogando)
Roteiro respondível (poços + Dotã): [docs/game-design/PLAYTEST_ROTEIRO.md](../game-design/PLAYTEST_ROTEIRO.md). Roteiro curto antigo: [docs/quests.md](../quests.md#manual-roteiro-sugerido-cerca-de-10-minutos). **Ainda não foi executado por uma pessoa** (KNOWN_ISSUES KI-02).
Para rodar o jogo: `.\tools\godot\Godot_v4.7.2-stable_win64.exe --path .` (ou F5 no editor), ou o `CaminhosDaPromessa.exe` da raiz.

## Que teste rodar para cada mudança
| Mudança | Mínimo a rodar |
|---|---|
| Dados (`data/**`) | suíte principal + validação de conteúdo; referência bíblica nova → rodar `tools/import_scripture.gd` antes |
| Scripts de jogo ou UI | suíte principal + fluxo |
| Layout de UI | o acima + capturas (conferir as imagens) |
| Save | suíte principal (seções de save) + fluxo |
| Exportação ou entrega de versão | build completo |
| Só documentação | `tools/check_wiki.ps1` |

## Cuidados conhecidos
- Rode os comandos do Godot **um de cada vez**: suíte, fluxo e capturas compartilham o diretório de save de teste.
- Erro de parse em script de teste pode deixar o Godot **travado** em vez de sair; se o comando não terminar, encerre o processo e rode com a saída completa para ver o erro.
- Os testes de gameplay passam pelo prólogo e pausam os NPCs durante o teste de movimento (um NPC que passeia pode bloquear o jogador).
- Os testes usam caminhos próprios de save e de configurações; não tocam o save nem os volumes do jogador.
- Tecla simulada em teste: `Input.parse_input_event(...)` seguido de `Input.flush_buffered_events()`; sem o flush a tecla pode chegar depois da verificação (KI-17).
- Em headless os quadros não seguem o tempo real (a animação de passos é por física; cooldowns são em milissegundos reais): testes de passos medem por tempo decorrido, não por número de quadros. O teste de corrida desliga a colisão do jogador para não esbarrar em objetos do mapa.
- Escuta: nenhum teste avalia timbre; ver "Escuta humana necessária" em [docs/audio.md](../audio.md).
- No PowerShell 5.1, `Start-Process` só preenche `ExitCode` se `$p.Handle` for acessado antes de esperar.
