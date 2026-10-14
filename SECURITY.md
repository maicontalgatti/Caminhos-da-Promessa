# Política de segurança

## Versões suportadas
Só a versão mais recente da branch `main` recebe correções. O projeto é um protótipo e ainda não tem
releases oficiais.

## Como relatar uma vulnerabilidade
**Não abra issue pública** para falhas de segurança.

Use o relato privado do GitHub: na aba **Security** do repositório, clique em
**Report a vulnerability**
(<https://github.com/maicontalgatti/Caminhos-da-Promessa/security/advisories/new>).

Inclua, se possível:
- descrição do problema e impacto;
- passos para reproduzir;
- versão ou commit afetado;
- sugestão de correção.

**Não inclua** senhas, tokens ou dados pessoais reais no relato. Se você encontrou uma credencial
exposta neste repositório, informe apenas o arquivo e a linha, sem copiar o valor.

## O que esperar
- Confirmação do recebimento assim que possível (projeto mantido por voluntário; sem prazo garantido).
- Avaliação, correção num branch privado quando necessário e crédito a quem relatou, se desejar.

## Escopo
Interessam especialmente:
- segredos ou dados pessoais versionados por engano;
- workflows do GitHub Actions que permitam executar código com permissões indevidas;
- leitura de save ou de dados JSON que possa executar código ou corromper arquivos fora da pasta do jogo;
- scripts de ferramentas (`tools/`) que baixem ou executem conteúdo sem verificação.

## Práticas do repositório
- Nada de segredos no Git; `.gitignore` bloqueia `.env`, chaves e configurações locais de ferramentas.
- O workflow de testes roda com permissão somente de leitura, sem segredos, e não usa
  `pull_request_target`.
- O Godot usado na CI é baixado do release oficial e conferido por SHA-512.
- Não há deploy automático nem publicação automática de executáveis.
