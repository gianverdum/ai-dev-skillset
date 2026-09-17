---
name: workflow-iniciar-aplicacao
description: 'Iniciar aplicação, CLI, serviço, ferramenta ou módulo novo com organização mínima de pastas, OU estender projeto existente com bounded context novo. Use quando o usuário pedir para criar/iniciar/adicionar app/CLI/utilitário/módulo/biblioteca/serviço/funcionalidade, especialmente sem stack definida. Palavras-gatilho: "crie", "inicie", "adicione", "novo módulo", "novo serviço", "extraia BC", "bounded context novo", "implemente", "construa". Garante: três camadas obrigatórias (`domain`/`application`/`interface` em Clean Arch ou equivalente em Hex); `aggregates/` e `value-objects/` no mesmo nível de `domain/`; `src/shared-kernel/` na raiz quando há VOs cross-BC; BC novo como módulo IRMÃO em `src/` (não submódulo em `domain/`); critérios de "criar módulo separado vs camada" aplicados também em extensão (não só criação inicial). Sem essas fronteiras, módulo novo vira monolito disfarçado — DESVIO.'
---

# Iniciar Aplicação

Use esta skill quando o pedido criar software novo ou uma funcionalidade sem estrutura existente clara.

## Decisões Iniciais

1. Leia a estrutura existente antes de criar arquivos.
2. Se houver padrão claro no projeto, use esse padrão e informe a suposição.
3. Quando criar ou reorganizar estrutura, nomes de arquivos, pacotes, módulos, classes, funções ou testes, consulte a rule da linguagem em `.agents/rules`.
4. Se a linguagem não estiver explícita e o pedido for uma CLI, utilitário local ou ferramenta pequena sem requisito de stack, use Python com `uv` como padrão e informe a suposição.
5. Se a linguagem, runtime ou framework não estiverem explícitos e a escolha afetar arquitetura, deploy, UI, integração externa ou custo relevante, pergunte antes de implementar.
6. Se o pedido for pequeno, ainda trate como módulo evolutivo quando a skill de arquitetura estiver ativa.

## Escopo do Projeto

- Trate a raiz do repositório como a raiz do projeto. Manifesto (`pyproject.toml`, `package.json`, `pom.xml`, `Cargo.toml`, `go.mod`, `.sln`/`.csproj`, etc.), `src/`, `tests/`, `README.md`, `.gitignore` e lockfile ficam na raiz do repositório.
- Não crie uma pasta intermediária com o nome do projeto na raiz do repo para depois colocar `src/` dentro dela. Layout errado: `<repo>/calculadora/src/calculadora/...`. Layout correto: `<repo>/src/calculadora/...`.
- O nome do módulo aparece apenas dentro de `src/` (e em manifestos como `[project] name` ou `package.json` `name`), não como diretório irmão de `src/`.
- Exceção: monorepo explícito com mais de um deliverable independente. Nesse caso, cada projeto fica em `apps/<nome>/`, `packages/<nome>/` ou `services/<nome>/`, mantendo seu próprio manifesto e `src/` interno. Só adote esse layout quando já existir mais de um projeto no repositório ou o usuário pedir explicitamente; não crie monorepo preventivamente para abrigar um único projeto.
- Se o repositório já tiver convenção diferente (ex.: várias pastas-projeto no topo), preserve-a e informe a suposição.

## Quando Criar Modulo Separado vs Submodulo de Camada

Modulo = bounded context (DDD). Camada/adapter dentro de um modulo NAO e modulo separado.

**Vale tanto na criacao inicial quanto em qualquer extensao** (adicionar feature/funcionalidade nova num projeto existente). Ao estender, reaplique os criterios abaixo SEMPRE — nao caia em "preservar o padrao local" por inercia quando a feature nova introduz vocabulario, ciclo de vida ou regra com identidade propria. "Preservar padrao local" vale para conveções de naming/estilo/layout, nao para misturar bounded contexts no mesmo modulo.

Crie modulo SEPARADO quando ao menos um destes for verdade:

- O vocabulario/linguagem ubiqua e diferente (`task` x `project`, `payment` x `notification`, `inventory` x `pricing`).
- O ciclo de vida das regras e independente (mudam por motivos diferentes, em ritmos diferentes).
- Modelos com mesmo nome tem significados distintos (um `User` em `auth` e diferente do `User` em `billing`).
- Existe possibilidade real e prevista de extrair o modulo como servico/biblioteca separada.

NAO crie modulo separado para o que e claramente parte do mesmo bounded context:

- Adapter de persistencia da entidade do proprio modulo (`task-storage`, `task-repository`, `task-db`). Isso e submodulo de infraestrutura/adapter, NAO modulo irmao.
- Cliente HTTP que serve o nucleo do modulo (`payment-api-client` e adapter de saida de `payment`).
- Utilitarios, helpers, value objects, mappers.
- Camadas tecnicas (controllers, handlers, repositories, schemas).

### Sintomas de vazamento de bounded context (DESVIO)

Quando uma extensao precisaria ser modulo novo mas foi enxertada no existente, normalmente aparecem estes sintomas. Cada um sozinho ja sinaliza problema:

- Tipo de uma entidade existente ganhou campos com vocabulario do novo dominio (ex.: `Task.completedBillingMonth`, `User.subscriptionTier`, `Order.crmContactId`).
- O `State`/agregado do modulo existente ganhou novo campo com colecao do novo dominio (ex.: `ProjectManagementState.monthlyCharges`, `ShopState.shippingLabels`).
- Constantes/regras com vocabulario do novo dominio aparecem em arquivos do dominio existente (ex.: `COMPLETED_TASK_CHARGE_CENTS` em `domain/project.ts`).
- A policy table do modulo existente ganhou actions do novo dominio (`issue_monthly_charges`, `print_shipping_label`).
- Parametros de comando da UX existente passam a exigir campos do novo dominio (ex.: `complete-task --billing-month 2026-06`).
- README do modulo existente passa a citar dominios novos no titulo/responsabilidade ("gerencia projetos, tasks **e cobrancas**", "gerencia pedidos **e envios**").

Quando 2+ desses sintomas estao presentes, extraia o novo dominio para `src/<novo-modulo>/` e ligue por porta. Os campos/regras que vazaram para o modulo existente voltam a ser primitivos genericos (`Task.completedAt: Date`, `Task.completedBy: UserId`) e o novo modulo deriva os conceitos proprios a partir dai.

### Exemplos

**Errado** — `storage` como modulo irmao de `task`:

```
src/
  task/
    domain/
    application/
    interface/
  storage/                       # NAO e bounded context, e adapter de saida de task
    file-task-repository.ts
```

**Certo (Clean Arch)** — `storage` vive dentro de `task`:

```
src/
  task/
    domain/
    application/
    interface/
    infrastructure/
      file-task-repository.ts    # adapter de saida do proprio modulo
```

**Certo (Hexagonal)** — adapter de saida em `adapters/out/`:

```
src/
  task/
    domain/
    application/
      ports/task-repository.ts
      use-cases/add-task.ts
    adapters/
      in/cli/
      out/file-task-repository.ts
    config/
```

**Certo (multi-modulo real)** — dois bounded contexts distintos:

```
src/
  task/                          # gestao de tarefas
    domain/ application/ interface/ ...
  project/                       # gestao de projetos (linguagem propria)
    domain/ application/ interface/ ...
  # cada um com seu README; integracao via porta declarada no nucleo
```

Em duvida, comece com um modulo unico. Quebrar dois modulos juntos depois e barato; reverter uma quebra prematura e custoso.

## Organização Mínima

- Não crie arquivos soltos na raiz para código de produção, exceto manifests, configuração, documentação essencial ou entrypoints esperados pela stack.
- Na ausência de padrão local, aplique a rule de nomenclatura e estrutura da linguagem escolhida.
- Crie ou atualize o manifesto da stack quando a aplicação precisar de dependências, ferramentas de teste, comandos ou metadados de pacote.
- Instale e registre dependências no projeto, usando o gerenciador idiomático da stack; não dependa de pacotes globais ou instruções manuais quando o projeto puder declarar a dependência.
- Para Python, use sempre `uv`: inicialize `pyproject.toml` quando necessário, adicione dependências com `uv add` ou `uv add --dev`, execute comandos com `uv run` e mantenha `uv.lock` quando ele for gerado.
- Para Python novo, crie `pyproject.toml` com metadados mínimos, `requires-python`, entrypoint quando houver CLI, build backend simples e configuração das ferramentas usadas.
- Crie ou atualize `.gitignore` antes do primeiro commit. Esta é uma exigência obrigatória, não recomendação. Cubra no mínimo, por stack:
  - Python: `.venv/`, `.coverage`, `coverage.xml`, `htmlcov/`, `__pycache__/`, `*.pyc`, `.pytest_cache/`, `.ruff_cache/`, `.mypy_cache/`, `dist/`, `build/`, `*.egg-info/`.
  - JavaScript/TypeScript: `node_modules/`, `dist/`, `build/`, `.next/`, `.turbo/`, `coverage/`, `.cache/`, `.env*` exceto `.env.example`.
  - Java/Kotlin: `target/`, `build/`, `.gradle/`, `*.class`.
  - C#/.NET: `bin/`, `obj/`, `*.user`, `.vs/`.
  - Go: binários compilados na raiz, `vendor/` quando não versionado.
  - Rust: `target/`, `Cargo.lock` apenas em bibliotecas publicadas.
- Se algum desses artefatos já estiver versionado por engano, remova do índice (`git rm --cached`) ao adicionar a entrada no `.gitignore`.
- Coloque módulos, aplicações, CLIs, serviços e bibliotecas dentro do `src/` da raiz do repositório, criando `<repo>/src/<nome-do-modulo>` quando não houver padrão mais específico.
- Não crie diretórios de aplicação diretamente na raiz do repositório, como `calculator_cli/` ou `calculadora/`, salvo quando a stack exigir esse formato, o repositório for um monorepo explícito ou o padrão existente já use esse layout.
- Crie sempre as camadas minimas obrigatorias no modulo, conforme a skill de arquitetura ativa:
  - **Clean Architecture (default)**: `domain`, `aggregates`, `value-objects`, `application` e `interface`. Carregue `architecture-ddd-clean-arch`.
  - **Hexagonal**: `domain`, `aggregates`, `value-objects`, `application` e `adapters/in` + `adapters/out`. Carregue `architecture-ddd-hexagonal`.
  - Escolha por precedencia: (1) padrao do projeto existente; (2) solicitacao explicita do usuario; (3) default Clean Architecture.
- `aggregates/` e `value-objects/` ficam **no mesmo nivel de `domain/`** (irmaos), nao dentro de `domain/`. Cada aggregate root e cada VO em arquivo proprio.
- VOs de identidade compartilhados entre BCs ficam em `src/shared-kernel/value-objects/` na RAIZ de `src/`, NUNCA dentro de outro modulo.
- Bounded contexts separados sao **modulos irmaos em `src/`** (cada um com sua estrutura completa). Subpastas dentro de `domain/` com nomes de BC nao contam como BCs separados.
- Vale tambem para CLIs e utilitarios pequenos: a camada `application` (ou caso de uso ligado a porta de entrada, em Hexagonal) nao pode ser omitida por simplicidade aparente. A interface (ou `adapters/in`) chama o caso de uso, nunca o dominio direto.
- A colocacao dos testes unitarios e decidida pela rule da linguagem em `.agents/rules`, nao por preferencia global. Resumo das convencoes modernas: Go e Rust colocalizam unitarios junto ao codigo (Rust em modulo `#[cfg(test)]`); TypeScript e JavaScript preferem colocalizado (`foo.test.ts` ao lado de `foo.ts`); Python, Java, C# e PHP usam diretorio espelhado (`tests/` na raiz, `src/test/java`, projeto `*.Tests`, etc.). Siga sempre o padrao da rule da linguagem usada.
- Use `tests/` no mesmo nivel de `src/` para integracao, contrato, ponta a ponta, fixtures compartilhadas e suites que cruzam modulos, independentemente de onde ficam os unitarios.
- Tudo que entrar em `tests/` (unitarios em Python/PHP, integracao/contrato/e2e em qualquer linguagem) deve ser agrupado primeiro pelo TIPO em subpastas como `tests/unit/`, `tests/integration/`, `tests/contract/`, `tests/e2e/`, `tests/acceptance/`. Dentro de cada subpasta de tipo, espelhe a estrutura de `src/`: um teste de `src/<modulo>/<sub>/<arquivo>` vira `tests/<tipo>/<modulo>/<sub>/test_<arquivo>` (com o sufixo do framework). Excecoes: Java/Kotlin (sufixo `*Test`/`*IT` sobre `src/test/java`) e C#/.NET (projetos `*.UnitTests`/`*.IntegrationTests` separados) seguem a convencao da stack.
- Carregue e aplique a skill `documentation-modulos-projeto` sempre que criar ou reorganizar um projeto ou modulo. Crie, na mesma mudanca, o `README.md` da raiz do repositorio e um `README.md` proprio para cada modulo de aplicacao criado (o pacote principal dentro de `src/`, ou cada projeto em `apps/<nome>/`, `packages/<nome>/` ou `services/<nome>/` em monorepo). Submodulos de camada como `domain`, `application`, `interface`, `adapters` ou equivalentes NAO recebem README proprio: sao descritos dentro do README do modulo. README de modulo nao e opcional: a tarefa so termina quando todo modulo novo tem o seu.
- Mantenha artefatos gerados, cache e build fora do versionamento quando aplicável.

## CLI

- Para uma CLI, crie um entrypoint claro e uma camada de interface responsável apenas por parsing, validação de entrada textual e apresentação de saída.
- Mantenha cálculo, decisão e regra de negócio fora do arquivo de CLI.
- Exponha comandos de execução e teste na resposta final.
- Para CLI Python, prefira entrypoint em `pyproject.toml` e documente execução por `uv run <comando>`; use `uv run python -m <modulo>` apenas quando um entrypoint ainda não fizer sentido.
- Em CLI Python, mantenha `__main__.py` apenas como glue fino para `python -m <modulo>` quando isso agregar compatibilidade; não coloque regra de negócio nele.

## Dependências e Ambiente

- Configure as ferramentas necessárias para cumprir os requisitos do pedido, incluindo teste, cobertura, lint ou build quando exigidos por outras skills.
- Carregue e aplique a skill `quality-lint-format`: todo projeto novo deve nascer com linter e formatter idiomaticos instalados, configurados e com scripts `lint` e `format` declarados no manifesto. O script `lint` invoca o linter real (nao alias de `typecheck` ou `build`). A escolha do linter por linguagem esta na rule da linguagem em `.agents/rules`.
- Antes de dizer que uma ferramenta não está instalada, tente adicioná-la ao projeto pelo gerenciador da stack e valide pelo comando do projeto.
- Não instale dependências de forma global, não use `pip install` direto em Python e não crie ambientes virtuais manualmente quando `uv` puder gerenciar o ambiente.
- Se uma instalação precisar de rede, permissão externa ou ferramenta ausente, solicite a aprovação necessária ou registre o bloqueio concreto na resposta final.

## Checklist

- A linguagem ou stack foi confirmada ou inferida por padrão existente.
- Em CLI/utilitário pequeno sem stack explícita, Python com `uv` foi usado como padrão ou outra escolha foi justificada.
- O manifesto da stack foi criado ou atualizado quando havia dependências, comandos ou ferramentas.
- Dependências necessárias foram adicionadas ao projeto pelo gerenciador correto; em Python, por `uv`.
- Linter e formatter idiomaticos foram instalados e configurados; scripts `lint` e `format` no manifesto invocam ferramentas reais, nao aliases.
- `.gitignore` cobre ambiente local, caches e artefatos gerados pela stack, conforme a lista mínima por linguagem.
- Nenhum dos artefatos listados (ex.: `.venv/`, `.coverage`, `node_modules/`, `target/`, `bin/`, `obj/`) está versionado.
- Código de produção não ficou espalhado na raiz.
- `src/`, `tests/` e manifesto estão na raiz do repositório, não dentro de uma pasta com o nome do projeto.
- A funcionalidade nasceu dentro de `<repo>/src/<modulo>` com as camadas minimas exigidas pela skill de arquitetura ativa (Clean Arch: `domain`/`application`/`interface`; Hexagonal: `domain`/`application`/`adapters/in`+`adapters/out`).
- Modulos irmaos em `src/` representam BOUNDED CONTEXTS distintos. Persistencia, cliente HTTP, parser, mapper e demais adapters do proprio modulo NAO sao modulos irmaos — ficam como submodulo de camada dentro do modulo dono.
- A camada de entrada (interface ou `adapters/in`) delega para um caso de uso de `application`; nao chama o `domain` diretamente.
- A precedencia de arquitetura foi respeitada: padrao do projeto > pedido do usuario > default Clean Architecture.
- Testes unitários ficaram próximos do código ou no padrão da stack.
- Testes de integração e outros testes amplos ficaram em `tests/` no mesmo nível de `src/`.
- `README.md` da raiz do repositorio foi criado ou atualizado.
- Cada modulo de aplicacao criado tem o seu proprio `README.md`; submodulos de camada nao recebem README proprio.
- A skill `documentation-modulos-projeto` foi carregada e seu checklist foi cumprido.
- Rules aplicáveis de nomenclatura e estrutura foram consultadas quando não havia padrão local suficiente.
- A resposta final informa como executar e validar.
- A skill `quality-revisao-aderencia` foi rodada antes do resumo final e os desvios encontrados foram corrigidos.
- O resumo final inclui secao "Revisao de aderencia" com status ❌/✅ item-a-item da checklist objetiva. Frases de conclusao ("pronto", "concluido", "feito", "complete", "done") so foram usadas se ≤1 item vermelho.
