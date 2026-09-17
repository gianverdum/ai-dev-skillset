---
name: testing-coverage-quality
description: 'OBRIGATORIO em qualquer tarefa que altera comportamento de software. Garantir qualidade mínima de testes (unit + integration + e2e quando aplicável) e cobertura ≥ 80%. Use sempre que o agente criar, alterar, corrigir, refatorar ou estender software. Palavras-gatilho: "cobertura", "coverage", "test", "vitest", "jest", "pytest", "unit", "integration", "e2e", "test:cov", "limiar de cobertura", "gap de teste". Garante: limiar 80% configurado, e2e obrigatório quando há persistência externa ou entrypoint executável (CLI/HTTP/daemon), e2e cobre não só happy path mas também `permission_denied`/`not_found`/`invalid_input`, layout `tests/<tipo>/<espelho-de-src>/`. Sem cobertura mínima e tipos de teste apropriados, tarefa está incompleta — DESVIO.'
---

# Qualidade e Cobertura de Testes

Use esta skill junto da skill de TDD em qualquer mudança de software.

## Regras

- Garanta ao menos 80% de cobertura automatizada para o módulo alterado ou para o projeto quando a ferramenta medir apenas cobertura global.
- Configure o comando de cobertura para falhar abaixo de 80% quando a stack oferecer suporte prático a limiar mínimo.
- Se a ferramenta de cobertura não existir, adicione-a como dependência de desenvolvimento do projeto pelo gerenciador da stack antes de considerar a medição indisponível.
- Para Python, use sempre `uv`: adicione `coverage`, `pytest-cov` ou ferramenta equivalente com `uv add --dev`, execute com `uv run` e registre a configuração em `pyproject.toml` quando aplicável.
- Configure a cobertura para medir o pacote ou módulo de produção inteiro, não apenas os arquivos importados acidentalmente pelos testes.
- Não aumente cobertura com testes vazios, snapshots sem asserção relevante ou testes que só exercitam código sem validar comportamento.
- Priorize cobertura de regras de domínio, casos de uso, validações, cálculos, parsing, serialização e fluxos de erro.
- **Teste e2e e obrigatorio** quando o modulo (a) persiste estado externo — arquivo, banco, fila, cache, message broker, request HTTP de saida — OU (b) expoe entrypoint executavel — CLI, HTTP server, daemon, worker, cron job. Nesses casos, alem de unit e integration, inclua pelo menos um teste e2e do fluxo completo a partir do entrypoint real. Integration sozinho NAO substitui e2e: integration valida o adapter contra o recurso; e2e valida o fluxo cross-command/cross-request inteiro, incluindo parsing, wiring e estado final observavel.
- E2E em CLI: invoque a CLI compilada (ou `main()`/`runCli()` chamada como subprocesso ou in-process) com `argv`, capture `exit code`, `stdout` e `stderr`, e VERIFIQUE o estado do recurso externo (arquivo, banco) depois de uma sequencia de comandos representativa. Exemplo: `add "X"` -> `list` -> `done <id>` -> `list --done`, verificando que o arquivo persistido contem a tarefa com `status: "done"`.
- E2E em HTTP server: suba o servidor (ou use `supertest`), chame os endpoints na ordem do fluxo real (criar -> ler -> atualizar -> ler), verifique status e payload de resposta E o estado final do recurso externo.
- E2E nao substitui unit/integration. Os tres niveis convivem: unit cobre regras puras com a maior densidade; integration cobre adapters contra recursos reais; e2e cobre o fluxo completo do ponto de entrada ate o estado final.
- **E2E nao e so caminho feliz.** Um unico e2e do happy path satisfaz o minimo absoluto, mas modulo com autorizacao, validacao cruzada ou multiplos comandos precisa de e2e tambem para os fluxos de erro criticos. No minimo: (1) sequencia feliz cross-command; (2) acesso negado por permissao (`permission_denied`); (3) recurso inexistente (`not_found`); (4) validacao de entrada falhando no entrypoint. Cada e2e verifica exit code, stderr, e estado do recurso externo (nao mutado em caminhos de falha).

### Exemplo: e2e suficiente para CLI com permissionamento

Para uma CLI com roles e persistencia, a suite e2e minima cobre quatro cenarios distintos:

```typescript
// tests/e2e/<modulo>/cli.test.ts

it("admin bootstraps users, creates project, member adds and completes task", async () => {
  // happy path cross-command: add admin -> add member -> create project ->
  //   member cria task -> member completa task -> admin lista
  // verifica stdout e estado final do arquivo persistido
});

it("viewer cannot create task", async () => {
  // permissao negada: exit 1, stderr "Permission denied.", arquivo NAO mutado
});

it("create task fails when project does not exist", async () => {
  // recurso inexistente: exit 1, stderr com codigo project_not_found, arquivo NAO mutado
});

it("rejects invalid role on add-user", async () => {
  // validacao de entrada no parser: exit 1, stderr "Invalid role."
});
```

E2E unico cobrindo so o happy path passa o minimo, mas deixa fluxos de seguranca/erro sem rede. Para modulo com autorizacao, considere a suite acima o piso.
- Cubra caminhos felizes e erros relevantes; não persiga 100% quando isso gerar teste frágil ou acoplado a implementação.
- Exclua artefatos gerados, caches, migrações mecânicas, arquivos de build e glue code trivial quando a ferramenta permitir.
- Mantenha artefatos de cobertura fora do versionamento via `.gitignore`. No mínimo: `.coverage`, `.coverage.*`, `coverage.xml`, `htmlcov/`, `coverage/`, `lcov.info`. Se já estiverem versionados, remova do índice com `git rm --cached`.
- Não escreva percentuais de cobertura fixos em `README.md` nem em outra documentação versionada. Eles envelhecem sem aviso e passam a mentir sobre o estado atual. Documente apenas o comando que produz o relatório e o limiar mínimo configurado.

## Fluxo

1. Identifique a ferramenta de teste e cobertura usada pela stack.
2. Se não houver ferramenta, configure a opção mais simples e idiomática para a linguagem do módulo e adicione as dependências de desenvolvimento necessárias ao manifesto do projeto.
3. Escreva ou ajuste testes antes da implementação conforme TDD.
4. Execute testes com cobertura ao final da mudança.
5. Se a cobertura ficar abaixo de 80%, adicione testes úteis ou explique o bloqueio técnico.
6. Documente o comando de teste/cobertura no `README.md` mais próximo quando criar ou alterar a configuração.

## Python

- Use `uv` como único gerenciador de ambiente e dependências.
- Crie ou mantenha `pyproject.toml` para declarar projeto, dependências, scripts e configuração de ferramentas.
- Para testes com `unittest`, use `uv add --dev coverage` e valide com `uv run coverage run -m unittest discover -s tests` seguido de `uv run coverage report --fail-under=80`.
- Para testes com `pytest`, use `uv add --dev pytest pytest-cov` e valide com `uv run pytest --cov --cov-fail-under=80`.
- Configure `[tool.coverage.run] source = ["src/<modulo>"]` para incluir o pacote de produção completo no relatório.
- Exclua de cobertura apenas glue trivial, arquivos gerados ou entrypoints sem decisão própria; não exclua CLI, parsers, casos de uso ou regras de domínio.
- Testes de CLI em subprocesso podem validar empacotamento, mas adicione também teste direto da função de entrada para que a cobertura do adaptador conte no processo medido.
- Mantenha `uv.lock` quando ele for gerado pela instalação.
- Para outras linguagens, preserve o padrão local e consulte a rule da linguagem em `.agents/rules` para nomes e localização de testes antes de criar uma estrutura nova.

## Layout

- Mantenha testes unitários próximos dos arquivos ou pacotes testados quando esse for um padrão aceito pela linguagem.
- Mantenha testes de integração, contrato, ponta a ponta e fixtures compartilhadas em `tests/` no mesmo nível de `src/`.
- Preserve o padrão existente quando o projeto já tiver uma convenção consistente.

## Revisao final

- Apos rodar testes e medir cobertura, execute a skill `quality-revisao-aderencia` antes de encerrar a tarefa. Ela checa arquitetura, tipagem do dominio, localizacao do parsing, codigos de erro estaveis, lint real, idioma do codigo e estrutura de testes; corrige desvios na hora.

## Resposta Final

- Informe o comando de testes executado.
- Informe o percentual de cobertura obtido quando a ferramenta reportar esse número, apenas na resposta da conversa. Não persista esse número em arquivos versionados.
- Se não for possível medir cobertura, informe a razão concreta, incluindo a tentativa de configurar a ferramenta ou o bloqueio externo encontrado.

## Checklist

- A suíte relevante foi executada.
- Se o modulo persiste estado externo ou expoe entrypoint executavel, existe ao menos um teste e2e do fluxo completo, e ele passa.
- Se o modulo tem autorizacao, validacao cruzada ou multiplos comandos, a suite e2e cobre tambem fluxos criticos de erro (permissao negada, recurso inexistente, validacao de entrada), nao apenas o caminho feliz.
- A cobertura medida ficou em pelo menos 80% ou o bloqueio foi explicado.
- O limiar de 80% foi configurado quando prático.
- A cobertura mede o pacote de produção inteiro, com exclusões justificadas.
- Dependências de cobertura foram adicionadas ao projeto quando estavam ausentes.
- Os testes adicionados validam comportamento observável.
- Artefatos de cobertura (`.coverage`, `coverage.xml`, `htmlcov/`, `lcov.info`) estão no `.gitignore` e não versionados.
- Nenhum percentual de cobertura fixo foi escrito em `README.md` ou outro arquivo versionado.
- O layout dos testes respeita unitários próximos do código e testes amplos em `tests/`.
