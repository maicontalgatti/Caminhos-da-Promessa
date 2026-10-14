# Novo agente? Comece aqui

Respostas curtas, com link para o documento certo. Não leia o repositório inteiro: siga os links
conforme a tarefa. Ordem de leitura obrigatória: [AGENTS.md](../../AGENTS.md) → [README da wiki](README.md) →
[CURRENT_STATE.md](CURRENT_STATE.md) → [HANDOFF.md](HANDOFF.md).

| Pergunta | Resposta |
|---|---|
| 1. Como instalar o ambiente? | Windows; Godot **4.7.2** Standard 64-bit extraído em `tools/godot/` (fora do Git) e, para gerar o exe, os templates de exportação 4.7.2. Passo a passo no [README](../../README.md#como-jogar) e em [build_windows.md](../build_windows.md). Depois de clonar, rode `--import` uma vez (abaixo). |
| 2. Como abrir o Godot? | `.\tools\godot\Godot_v4.7.2-stable_win64.exe --path . -e` (editor) |
| 3. Como iniciar o jogo? | `.\tools\godot\Godot_v4.7.2-stable_win64.exe --path .` ou F5 no editor |
| 4. Como executar testes? | [TESTING.md](TESTING.md): suíte, fluxo, validação, fábrica, auditoria de áudio, wiki |
| 5. Como gerar o EXE? | `.\criar_exe_atualizado.bat` (roda testes, exporta, autoteste, copia para a raiz); [build_windows.md](../build_windows.md) |
| 6. Como criar missões? | [GAME_SYSTEMS.md](GAME_SYSTEMS.md#como-adicionar-uma-missão) e o formato em [quests.md](../quests.md) |
| 7. Como gerar novos mapas? | Mapas novos só por `tools/art_gen/build_regions.gd`; a aldeia por `tools/art_gen/build_world.gd` (`tools/build_all.ps1 -PropsOnly` depois de editar à mão, ADR-006). Região = JSON em `data/regions/` ([architecture.md](../architecture.md)) |
| 8. Como adicionar itens? | `data/items/items.json` (ADR-023 em [DECISIONS.md](DECISIONS.md)); coleta no mapa por `scripts/items/pickup.gd`; som do item em `data/audio/sfx.json` (bloco `items`) |
| 9. Como gerar efeitos sonoros? | [docs/audio.md](../audio.md): manifesto, `tools/audio/generate_sfx.gd`, `--import`, auditoria |
| 10. Como executar a fábrica de missões? | [mission_factory.md](../mission_factory.md); `--script res://tools/factory.gd -- pending` / `check` |
| 11. Quais agentes existem? | [AI_AGENTS.md](AI_AGENTS.md) (9 subagentes e 3 regras) |
| 12. Como delegar tarefas? | [AI_AGENTS.md](AI_AGENTS.md#como-funcionam) e o pipeline em [mission_factory.md](../mission_factory.md#pipeline-e-agentes) |
| 13. Quais regras bíblicas são obrigatórias? | [BIBLICAL_RULES.md](BIBLICAL_RULES.md) (sempre, para qualquer texto narrativo) |
| 14. Quais sistemas estão prontos? | [CURRENT_STATE.md](CURRENT_STATE.md#funcionalidades-concluídas-e-verificadas) e [GAME_SYSTEMS.md](GAME_SYSTEMS.md) |
| 15. Quais estão pendentes? | [CURRENT_STATE.md](CURRENT_STATE.md#planejado-não-implementado) e [KNOWN_ISSUES.md](KNOWN_ISSUES.md) |
| 16. Qual será a próxima tarefa? | "Próxima ação" e "Pendências" em [HANDOFF.md](HANDOFF.md) |

## Primeiros comandos depois de clonar
```powershell
$g = ".\tools\godot\Godot_v4.7.2-stable_win64_console.exe"
& $g --headless --path . --import                              # cria .godot/ (cache, fora do Git)
& $g --headless --path . res://tests/test_runner.tscn          # deve terminar em "0 falharam"
powershell -ExecutionPolicy Bypass -File tools\check_wiki.ps1   # wiki consistente
```

## Ao terminar qualquer tarefa
Atualize [HANDOFF.md](HANDOFF.md) (sempre) e o que a [política de manutenção](README.md#política-de-manutenção)
pedir, e rode `tools/check_wiki.ps1`. Nunca declare um teste aprovado sem rodá-lo.
