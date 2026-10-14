# Regras bíblicas

Obrigatórias para **qualquer** conteúdo narrativo: diálogos, missões, descobertas, apresentações,
diário, cronologia, lugares, pessoas, textos de UI. Detalhes do método e dos esquemas em
[docs/bible_catalog.md](../bible_catalog.md); dados em `data/bible/`; aplicação no código em
`scripts/bible/content_policy.gd` e `tools/validate_content.gd`.

## As regras
1. **Não inventar versículos.** Toda referência (livro, capítulo, versículo) precisa existir. O livro tem de estar em `data/bible/books.json` e o capítulo, com sua contagem de versículos, em `data/bible/verse_counts.json`; os testes recusam o que não bater.
2. **Não alterar os relatos.** O jogador acompanha e participa ao redor, mas não impede, muda nem causa acontecimentos bíblicos (ex.: não impede a venda de José). Restrições de cada história ficam em `design_constraints`.
3. **Não inventar falas de personagens bíblicos.** Personagens bíblicos só "falam" por resumo ou paráfrase identificada, com referência. Diálogos livres são de moradores fictícios.
4. **Ficção sempre identificável.** O viajante e os moradores são fictícios e aparecem assim (ex.: no diário, "· personagem fictício"). A presença do jogador nunca é apresentada como registrada nas Escrituras.
5. **Classificar todo conteúdo** com uma das seis classificações: `recorded_event`, `historical_context`, `plausible_fiction`, `parable_adaptation`, `symbolic_interpretation`, `devotional_educational`.
6. **Separar tipos de afirmação.** Em textos educativos, distinguir o que o texto diz, contexto histórico, cronologia, interpretações e criação do jogo (`SECTION_KINDS` em `content_policy.gd`).
7. **Datas e locais incertos são marcados.** Use certeza `documented` / `approximate` / `debated` / `unknown`; não existe ano zero; período sem data confiável usa `null`, não um número inventado.
8. **Interpretações não viram fato.** Leituras teológicas ou denominacionais divergentes são apresentadas como interpretações. Textos simbólicos e apocalípticos são sinalizados como simbólicos.
9. **Texto bíblico só de fonte oficial e licença registrada.** Versículos citados vêm de `data/bible/texts/<tradução>.json`, gerado por `tools/import_scripture.gd` a partir do arquivo oficial; **nunca digite versículos de memória** nem copie traduções protegidas sem permissão registrada. Hoje: Bíblia Portuguesa Mundial (domínio público, provisória); NVI só com permissão da Biblica (ADR-016, KI-06). Resumos e notas do jogo continuam sendo texto próprio e ficam separados da citação.
10. **IA não verifica conteúdo.** Conteúdo escrito ou conferido por IA fica no máximo em `pending_review`. `reference_checked` e `approved` exigem `verification.reviewer` humano; nomes de IA são recusados (`ContentPolicy.is_ai_reviewer`).
11. **Canal público só com aprovação.** No canal `public` só aparece conteúdo `approved`. Não mude o canal para `public` nem aprove itens em nome do criador.
12. **Reverência.** Acontecimentos espirituais e milagres não viram recompensa material, poder do jogador nem item colecionável; sem humor que ridicularize o texto.

## Ao criar ou alterar conteúdo
- Preencha `classification`, referências e `verification {status: "pending_review", reviewer: "", notes}`.
- Rode `tools/validate_content.gd` e os testes (ver [TESTING.md](TESTING.md)).
- Na dúvida sobre um fato, **não escreva**: registre a dúvida nas `notes` ou em [KNOWN_ISSUES.md](KNOWN_ISSUES.md) e peça revisão ao criador.

## Documentos narrativos relacionados
- [docs/bible_catalog.md](../bible_catalog.md): tipos de tratamento por livro, esquema de histórias, status, texto bíblico.
- [docs/quests.md](../quests.md): cronologia, descobertas, apresentações, missões.
- [docs/game_design.md](../game_design.md): pilares e estrutura narrativa.
