# Passagem de bastão (handoff)

Descreve só a **última tarefa**. Histórico em [CHANGELOG.md](CHANGELOG.md) e em [docs/implementation_log.md](../implementation_log.md).

- **Data:** 2026-10-16
- **Responsável:** agente de IA (Cursor), a pedido do criador
- **Versão do projeto:** 0.6.0 (sem versão nova)
- **Estado do Git:** branch `feature/fix-new-game-panels` (PR #6).

## Última tarefa
Corrigir painel Configurações do menu (título cortado, conteúdo estourando a janela 480×270).

## Resultado
- Causa: painel de altura fixa (~236 px) com áudio + teclado (min 120) + avisos — conteúdo > viewport; título e Volume geral saíam para cima.
- Título e Voltar fixos; corpo em `BodyScroll`; painel 268×252 centrado.
- Sliders: rótulo de % com 30 px e trilho mínimo 90 (evita botão de Vozes em 100% fora do trilho).
- Pausa → Sons: mesma ideia (scroll + altura limitada).
- Fluxo cobre abertura, bounds e slider de Vozes.

## Testes
- Fluxo **31/31**, suíte **1823/1823**.
- Print do criador mostrava `v0.1.0-protótipo`: precisa do exe/build desta branch para ver a correção.

## Pendências
- Playtest humano (KI-02).

## Próxima ação
Criador: reabrir Configurações no build desta branch; revisar PR #6.

## Cuidados
- Não voltar a empilhar ControlsScroll com `custom_minimum_size.y = 120` fora de um scroll pai.
