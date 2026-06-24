---
name: quality-lint-format
description: OBRIGATORIO antes de encerrar tarefa que tocou código. Garantir boas práticas via linter e formatter da stack. Use sempre que o agente criar, alterar, corrigir, refatorar ou revisar código; antes de encerrar a tarefa, rodar lint e formatter, corrigir apontamentos, não deixar avisos pendentes. Palavras-gatilho: "lint", "format", "estilo de código", "eslint", "biome", "ruff", "prettier", "clippy", "golangci-lint", "fix do lint". Garante que script `lint` invoque o linter REAL (não alias de `typecheck`/`build`), que avisos não sejam silenciados sem justificativa, e que tarefa não seja declarada concluída com lint vermelho. Sem lint passando limpo + format aplicado, tarefa de código está incompleta — DESVIO.
---

# Lint e Formatter

Lint e formatter sao ferramentas obrigatorias em todo projeto de software. Use esta skill em qualquer mudanca de codigo.

## Regras

- Todo projeto deve ter um linter idiomatico instalado, configurado e executavel por comando declarado no manifesto da stack (`pyproject.toml`, `package.json`, `Cargo.toml`, `go.mod`/Makefile, `pom.xml`/`build.gradle`, `.csproj`, `composer.json`). Se nao existir, instale e configure no escopo da tarefa.
- Todo projeto deve ter um formatter idiomatico configurado. Quando o linter ja inclui formatador (ruff, biome, gofmt, rustfmt), o linter cobre os dois papeis.
- O script `lint` declarado no manifesto deve invocar o **linter real**, nao ser alias de `typecheck`, `build` ou outro comando. Linter e type checker validam coisas diferentes; declare scripts separados quando ambas as ferramentas existirem.
- Apos qualquer mudanca de codigo, rode lint e formatter localmente. Corrija o que for apontado antes de considerar a tarefa concluida.
- Trate avisos do linter como erros no fluxo do agente. Nao silencie regras (`// eslint-disable`, `# noqa`, `#[allow(...)]`) para esconder problemas; silencie apenas com justificativa registrada no codigo ou na resposta final.
- O linter padrao por linguagem esta definido na rule de cada linguagem em `.agents/rules`. Quando o projeto ja tiver outro linter configurado, preserve-o.

## Por que rodar lint sempre

- Pega bugs latentes: codigo morto, ramos identicos em `if/else` ou ternario, variavel nao usada, import nao usado, comparacao sempre verdadeira, promise nao aguardada.
- Pega vicios da linguagem: shadowing, mutacao de parametro, exhaustividade de `switch`, equality fraca.
- Fixa estilo: indentacao, ordem de imports, aspas, ponto e virgula. Reduz diff de revisao a sinal real.
- Padroniza saida de erro entre desenvolvedores e agentes.

## Fluxo

1. Identifique o linter ja usado pelo projeto. Se nao existir, escolha o padrao da linguagem (ver rule da linguagem).
2. Instale o linter como dependencia de desenvolvimento pelo gerenciador idiomatico (ex.: `uv add --dev ruff`, `yarn add -D eslint @eslint/js typescript-eslint`).
3. Crie ou atualize a configuracao minima do linter no formato esperado pela ferramenta.
4. Declare scripts no manifesto: pelo menos `lint` (verificar) e `format` (aplicar correcoes), separados de `typecheck` e `test`.
5. Rode lint e formatter ao final da mudanca. Corrija os apontamentos.
6. Documente os comandos no `README.md` mais proximo quando criar ou alterar a configuracao.

## Resposta Final

- Informe o comando de lint executado e o resultado (limpo ou diffs aplicados).
- Se houver avisos silenciados, justifique cada silenciamento.
- Se um linter foi adicionado ao projeto, informe a ferramenta escolhida e o motivo (default da rule, ja usado no ecossistema, decisao do usuario).

## Checklist

- Linter idiomatico esta instalado e configurado no projeto.
- Formatter idiomatico esta configurado (ou coberto pelo linter quando aplicavel).
- O script `lint` invoca o linter real, nao e alias de outro comando.
- Lint foi executado apos a mudanca e ficou limpo, ou os apontamentos foram corrigidos.
- Nenhum aviso foi silenciado sem justificativa registrada.
- Comandos de lint e format estao documentados no `README.md` da raiz ou do modulo quando relevantes.
