# Patch da missão — ep_006 (dialogue-writer)

Depois de integrar `dialogues.proposal.json` (diálogo `ari_talk`), o objetivo `listen_ari` de
`canaan_wells` deve usar:

```json
"complete_on": {"event": "custom", "id": "wells_ari_well"}
```

no lugar de `{"event": "dialogue_finished", "id": "ari_talk"}`. O alvo continua `{"type": "npc", "id": "ari"}`.

Por quê: com `dialogue_finished`, a fala curta `again` (quem já conhecia Ari) também concluiria o objetivo sem
o jogador ouvir a lembrança do avô. Agora `ari_talk` começa no nó `well` enquanto `listen_ari` é o objetivo
atual, e o evento `wells_ari_well` sai nos nós que concluem a lembrança (`well3`, e `n2` no primeiro encontro).
Quem ouviu a história antes de o objetivo ficar ativo conclui retroativamente (flag `ev:custom:wells_ari_well`).

Integração (integrador): aplicar a troca acima em `data/quests/canaan/canaan_wells.json`; nos testes que avançam
a missão, registrar `custom:wells_ari_well` (não `dialogue_finished:ari_talk`) antes de checar `talk_ezer`.
