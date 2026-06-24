---
name: architecture-ddd-clean-arch
description: Desenvolvimento e edição de software seguindo DDD + Clean Architecture (default quando não há padrão local nem pedido explícito por hexagonal). Use sempre que o agente for desenvolver nova funcionalidade, alterar código existente, corrigir bugs, refatorar, criar testes, criar módulo, extrair bounded context, ou editar projeto que deva preservar separação de camadas, regras de domínio e dependências apontando para dentro. Palavras-gatilho: "implemente", "crie", "refatore", "altere", "estenda", "extraia", "bounded context", "aggregate", "value object", "entity", "domain", "use case", "port", "adapter", "clean architecture". Garante: três camadas mínimas (`domain`/`application`/`interface`); `aggregates/` e `value-objects/` no mesmo nível de `domain/`; Aggregate Root como classe com métodos; VOs branded para identidade; sem composite cross-BC; sem primitive obsession; tipos finitos via literal union/enum. Sem essas fronteiras, código fica anêmico ou acoplado entre BCs — DESVIO.
---

# DDD + Clean Architecture

Use esta skill sempre que for desenvolver algo novo ou editar algo já desenvolvido em estilo Clean Architecture.

## Precedência entre Clean Architecture e Hexagonal

A escolha NÃO é por preferência do agente. Siga esta ordem:

1. **Padrão do projeto existente** — se o repositório já tem layout Clean Arch (`domain/`, `application/`, `interface/`, `infrastructure/`), preserve. Se o repo já é hexagonal (`ports/`, `adapters/in`, `adapters/out`), use a skill `architecture-ddd-hexagonal` em vez desta.
2. **Solicitação do usuário** — quando o usuário pedir "hexagonal", "ports and adapters" ou "hex", aplique `architecture-ddd-hexagonal`. Quando pedir "clean architecture" ou similar, aplique esta skill.
3. **Default** — na ausência de padrão local e de pedido explícito, **use esta skill (Clean Architecture)**.

Nunca misture os dois layouts no mesmo módulo.

## Princípios

- Preserve o domínio como centro da aplicação.
- Mantenha regras de negócio independentes de frameworks, banco de dados, filas, HTTP, UI e serviços externos.
- Faça dependências apontarem para dentro: camadas externas podem conhecer camadas internas, mas camadas internas não devem depender de detalhes externos.
- Modele comportamento de domínio no domínio, não em controllers, handlers, repositories ou componentes de interface.
- Prefira nomes da linguagem ubíqua do projeto aos nomes técnicos genéricos.
- Nomes de modulo, pacote e diretorio refletem o DOMINIO, nao a tecnologia de entrega nem a interface implementada. Sufixos como `_cli`, `_api`, `_web`, `_rest`, `_grpc`, `_gui`, `_service`, `_lib` ou seus equivalentes idiomaticos NAO entram no nome do pacote/modulo; ficam apenas no nome publicado do projeto (ex.: `pyproject.toml [project] name`, `package.json name`, artefato Maven/NuGet) quando precisar distinguir entregas. Exemplos: pacote Python `calculadora` publicado como `calculadora-cli`; modulo Go `payments` exposto via `cmd/payments-api/`; crate Rust `auth` publicado como `auth-cli`. O fato de a entrega atual ser CLI, API ou GUI nao muda o nome do modulo: o dominio e estavel, a interface e substituivel.
- Quando houver dúvida sobre nomenclatura de arquivos, pacotes, módulos, classes ou estrutura inicial, consulte a rule da linguagem em `.agents/rules` e preserve o padrão local se ele existir.
- Identificadores de codigo (variaveis, funcoes, classes, modulos, pacotes, testes, logs) seguem a rule `coding-language-english`: ingles e o idioma exclusivo de codificacao, com excecoes apenas para termos intraduziveis do dominio. Mensagens voltadas ao usuario nao sao literais em outro idioma no codigo: ou estao em ingles como default, ou sao chaves de i18n.

## Camadas e Pastas

Layout obrigatorio de um modulo em `src/<modulo>/`:

```
src/<modulo>/
  domain/              # entidades, domain services, eventos, regras e invariantes
  aggregates/          # aggregate roots (cada um em arquivo proprio)
  value-objects/       # value objects (cada um em arquivo proprio)
  application/         # casos de uso, ports, orquestracao
  infrastructure/      # adapters de saida (repositorios, clients HTTP, brokers)
  interface/           # adapters de entrada (CLI, HTTP, handlers)
```

Responsabilidade de cada pasta:

- **`domain/`**: entities (sem identidade de aggregate root), domain services, eventos de dominio, regras e invariantes que nao se encaixam em um aggregate. **Nao pertencem ao dominio**: parsing textual (CLI args, JSON, XML, query string, formularios), serializacao/desserializacao, IO (arquivos, rede, banco, console), templates de apresentacao, manipulacao de AST. Esses detalhes vivem em `interface` (parsing/apresentacao) ou `application` (orquestracao). Dominio recebe valores ja tipados e validados.
- **`aggregates/`**: cada aggregate root em arquivo proprio (`aggregates/project.ts`, `aggregates/tenant.ts`, `aggregates/charge.ts`). Aggregate root **e classe com metodos**, nao type/record mutavel por fora — veja "Modelagem Tatica".
- **`value-objects/`**: cada VO em arquivo proprio (`value-objects/task-id.ts`, `value-objects/money.ts`, `value-objects/billing-month.ts`). Imutaveis, igualdade por valor, invariantes no construtor.
- **`application/`**: casos de uso (em `application/use-cases/<use-case>.ts` quando 5+), portas em `application/ports/<port>.ts`, orquestracao, autorizacao de fluxo, transacoes.
- **`infrastructure/`**: implementacoes de repositorios, gateways, clients externos, mensageria, persistencia. Adapters de saida.
- **`interface/`**: controllers, rotas, presenters, views, serializers, forms, handlers de entrada. Adapters de entrada.

**VOs de identidade compartilhados entre BCs** (`TenantId`, `UserId`, `TaskId`) ficam em `src/shared-kernel/value-objects/<id>.ts`, NAO dentro de um modulo especifico. Ver "Shared Kernel" em Modelagem Tatica.

## Camadas Detalhadas

- Domínio: entidades, value objects, domain services, eventos de domínio, regras e invariantes. **Não pertencem ao domínio**: parsing de string textual (CLI args, JSON, XML, query string, formulários), serialização/desserialização para formatos externos, IO (arquivos, rede, banco, console), templates de apresentação, manipulação de AST de linguagens externas, validação de formato de entrada. Esses detalhes vivem em `interface` (parsing/apresentação de entrada externa) ou `application` (orquestração e validação de entrada já estruturada). O domínio recebe valores já tipados e validados.
- Aplicação: casos de uso, orquestração, portas/interfaces, transações e autorização de fluxo.
- Infraestrutura: implementações de repositories, gateways, clients externos, mensageria, persistência e adapters.
- Interface: controllers, rotas, presenters, views, serializers, forms e handlers de entrada.

## Fluxo

1. Entenda a intenção do usuário e identifique qual regra de negócio está sendo criada ou alterada.
2. Leia a estrutura existente antes de editar e siga os padrões já usados no projeto.
3. Se estiver criando software do zero ou uma funcionalidade sem estrutura clara, consulte a rule da linguagem para nomenclatura e layout base.
4. Defina o módulo ou bounded context que vai receber a mudança.
5. Localize a camada correta para a mudança.
6. Se a mudança toca regra de negócio, implemente ou ajuste o domínio primeiro.
7. Coloque orquestração de fluxo em casos de uso ou serviços de aplicação.
8. Use portas/interfaces para dependências externas quando a camada interna precisar de algo de fora.
9. Implemente detalhes técnicos apenas nas camadas externas.
10. Adicione ou ajuste testes na camada mais próxima do comportamento alterado.
11. Atualize a documentação do projeto ou módulo quando a mudança alterar estrutura, arquitetura, tecnologia ou comandos.

## Estrutura Inicial

- Mesmo em pedidos pequenos, não coloque regras de negócio em arquivos soltos na raiz do projeto.
- Trate novas CLIs, serviços, bibliotecas e ferramentas como módulos com fronteira própria.
- Quando não houver padrão existente, crie módulos de produção dentro de `src/<modulo>` com as três camadas mínimas obrigatórias: `domain`, `application` e `interface` (mais a estrutura de testes). As três são exigidas mesmo em CLIs e utilitários pequenos: a camada de aplicação não é opcional por "ser simples demais"; comece com um caso de uso fino que orquestra o domínio e ele evolui depois. Ajuste os nomes ao layout idiomático da stack quando a rule aplicável indicar outro padrão (ex.: `cmd/` e `internal/` em Go, `src/main/java` em Java).
- Ajuste `src/<modulo>` ao padrão idiomático da linguagem quando a rule aplicável indicar outro layout de mercado, como `cmd/` e `internal/` em Go ou `src/main/java` em Java.
- Entry points, comandos CLI, rotas e handlers pertencem à interface e devem delegar comportamento para aplicação ou domínio.
- Manifests e arquivos de configuração podem ficar na raiz quando forem convenção da linguagem ou ferramenta.
- Documente a responsabilidade do módulo e das camadas no `README.md` mais próximo, mantendo o texto enxuto.

## Modelagem Tatica: Aggregate, Entity, Value Object

DDD distingue tres formas de modelar conceitos do dominio. Use a forma correta para cada um; misturar gera dominio raso (anemic) ou acoplamento errado.

### Regras estruturais (onde cada coisa mora)

- **Aggregate root** vive em `src/<modulo>/aggregates/<aggregate>.ts` (um arquivo por aggregate root).
- **Value Object** vive em `src/<modulo>/value-objects/<vo>.ts` (um arquivo por VO).
- **Entity nao-root** (filha de um aggregate) vive em `src/<modulo>/aggregates/<aggregate>.ts` JUNTO do root que a controla — entities filhas nao tem arquivo proprio fora do aggregate dono.
- **VOs de identidade compartilhados entre BCs** (`TenantId`, `UserId`, `TaskId`) ficam em `src/shared-kernel/value-objects/<id>.ts` na RAIZ de `src/`. NUNCA dentro de outro modulo (`src/<algum-modulo>/.../shared-kernel/` e DESVIO).
- **Domain services, errors, eventos**: ficam em `src/<modulo>/domain/`.

### Restricoes do shared-kernel

`src/shared-kernel/` e estritamente para tipos compartilhados entre BCs — NAO e um modulo nem um BC. **Conteudo permitido**:

- `value-objects/` — VOs de identidade compartilhados (`TenantId`, `UserId`, `TaskId`).
- `errors.ts` (opcional) — `DomainError` ou base de codigo de erro **apenas como tipo/classe base reutilizavel**, sem catalogo de mensagens nem regra de negocio.
- `event-types.ts` (opcional) — tipos de evento de dominio compartilhados entre BCs (apenas o shape, sem handlers).

**Conteudo PROIBIDO em shared-kernel** (cada um e DESVIO):

- `shared-kernel/application/` — shared-kernel nao tem casos de uso, nao tem portas, nao tem helpers de busca cross-BC.
- `shared-kernel/infrastructure/` — shared-kernel nao tem repositorio, nao tem cliente HTTP, nao persiste nada.
- `shared-kernel/interface/` — shared-kernel nao tem CLI nem catalogo de mensagens.
- `shared-kernel/domain/<state>.ts` definindo state composto (`Tenant & { clients }`, `ProjectManagementState`) — state composto cross-BC e o monolito disfarcado. Cada BC tem seu proprio state.

Sinais de shared-kernel inchado (DESVIO):

- `shared-kernel/` ganhou `application/`, `infrastructure/` ou `interface/`.
- `shared-kernel/domain/` tem mais que VOs + errors.ts + event-types.ts.
- Tipos como `<Nome>State`, `<Nome>Repository`, `<Nome>Messages` aparecem em shared-kernel.
- Funcoes como `findX`, `getX`, `loadX` aparecem em shared-kernel/application.
- Cada BC importa **state composto** (com filhos de outros BCs) do shared-kernel.

Quando shared-kernel cresce alem do permitido, o monolito foi **renomeado**, nao quebrado. Os "BCs" sao fachadas sobre o estado compartilhado.

### Aggregate Root e dono da relacao com filhos

Aggregate root **controla** a colecao de seus filhos. A colecao e propriedade do root, manipulada por seus metodos:

```typescript
// CERTO
export class Project {
  private constructor(
    public readonly id: ProjectId,
    private tasks: Map<TaskId, Task>,    // colecao DENTRO do root
  ) {}

  createTask(taskId: TaskId, title: string, by: UserId): void {
    if (this.tasks.has(taskId)) throw new DomainError("task_already_exists");
    this.tasks.set(taskId, Task.create(taskId, title, by));
  }
}
```

Composite type externo ao aggregate, com filhos colados por fora, e DESVIO:

```typescript
// ERRADO — composite externo
export type Project = ProjectAggregate & { tasks: Record<string, Task> };  // ❌

const project = ProjectAggregate.create(...) as Project;
project.tasks = {};                                                          // ❌ mutacao externa
```

Sintomas:
- `type X = XAggregate & { children: ... }` em shared-kernel ou no modulo de outro BC.
- Cast `as X` apos `XAggregate.create(...)` para "ganhar" o campo de filhos.
- Mutacao da colecao (`x.children = {}`, `x.children[id] = ...`) fora dos metodos do root.

Quando o aggregate root nao e dono da colecao, o conceito "aggregate" foi desfeito — vira data record orquestrado externamente.

### Proibicao absoluta: composite cross-BC

**Nenhum modulo do repositorio**, independentemente do nome (`shared-kernel/`, `project-management/`, `core/`, `common/`, `state/`, etc.), pode definir tipo composto que liga aggregates de mais de um BC:

```typescript
// PROIBIDO em qualquer lugar do projeto
export type Tenant = TenantAggregate & { clients: Record<string, Client> };  // ❌
export type Client = ClientAggregate & { projects: Record<string, Project> }; // ❌
export type ProjectManagementState = { tenants: Record<string, Tenant> };    // ❌ composto cross-BC
```

A regra vale **independentemente do modulo** onde o composto for declarado. Renomear o monolito de `shared-kernel` para `project-management/`, `core/`, ou qualquer outro modulo de "tipos compartilhados" NAO resolve — continua sendo o anti-padrao "BCs cosmeticos sobre estado composto centralizado".

**Padrao correto:**

- Aggregate root e dono da sua propria colecao (via metodo, dentro do root).
- Cross-BC e feito por ID + porta. BC `tenancy` mantem `Tenant` puro (com sua propria colecao se houver, sem clients de outro BC). BC `client-management` mantem `Client` puro (com `tenantId` referenciando, nao `Tenant` composto). Quando BC X precisa de dado de BC Y, declara port em X e adapter ligando Y.
- Persistencia: cada BC tem `<BC>State = Record<<BC>Id, <BC>Aggregate>` proprio. O repositorio do BC carrega/persiste so o seu sub-state.

Sinais de DESVIO mecanico (gatilho objetivo):

- `grep -rn "& { .* Record<" src/` retornando matches que ligam aggregates de modulos diferentes.
- Tipo definido em modulo A importando aggregate de modulo B para compor (`Tenant & { clients: Record<string, ClientFromOtherModule> }`).
- Existencia de qualquer `*State` que contem aggregates de mais de um modulo.

### Modulo legitimo vs modulo monolito disfarcado

Modulo (BC) **legitimo** tem todas as caracteristicas abaixo:

1. `aggregates/<aggregate>.ts` — pelo menos um aggregate root proprio.
2. `application/use-cases/<use-case>.ts` — pelo menos um caso de uso proprio do BC.
3. `application/ports/<port>.ts` — porta(s) de saida proprias quando o BC precisa de IO.
4. `infrastructure/<adapter>.ts` — implementacao das portas, NAO delegacao 100% a outro modulo.
5. `interface/cli.ts` (ou adapter de entrada equivalente) com comandos do proprio BC, OU um README declarando que e BC de leitura/policy sem entrada propria (ex.: `access-control`).
6. `README.md` declarando responsabilidade.
7. Tests proprios (unit dos aggregates + integration + e2e quando expoe operacoes).

Modulo **monolito disfarcado** (DESVIO grave) tem o oposto: state composto cross-BC + helpers de busca cross-BC + porta retornando state composto + repositorio unico. Sintomas:

- Tem `application/<state>.ts` com helpers `findX`/`getX`/`loadX` que percorrem aggregates de outros BCs.
- Tem `application/ports/<state>-repository.ts` retornando state composto cross-BC.
- Tem `infrastructure/<single-repo>.ts` persistindo tudo num arquivo/tabela unico.
- NAO tem `aggregates/` proprios — so define types compostos sobre aggregates de outros BCs.
- NAO tem `application/use-cases/` — so helpers.
- NAO tem `interface/cli.ts` proprio — outros BCs delegam mensagens via ele.

Quando um modulo tem o segundo perfil (sem aggregates proprios, sem use cases proprios, com state composto e repo unico), ele e o **monolito renomeado** que sobrevive a regras anti-shared-kernel-inchado.

### Isolamento de Estado por Bounded Context

Cada BC tem seu proprio **state, repositorio e schema persistido**. Compartilhar state composto via shared-kernel ou via repositorio unico transforma os "BCs" em fachadas cosmeticas sobre um monolito.

**Regras objetivas**:

- A porta de repositorio de um BC retorna o `<BC>State` proprio (ex.: `TenantState`, `ClientState`, `ProjectState`), NUNCA um `ProjectManagementState` ou `WholeState` composto que mistura BCs.
- O schema persistido de cada BC e arquivo/tabela/coleção **proprio**, nao compartilhado. Se a stack obriga arquivo unico (ex.: CLI com um JSON local), o arquivo carrega um envelope versionado com sub-objetos por BC, e cada repositorio le/grava SOMENTE a sua sub-arvore.
- Adapter concreto de repositorio nao extende repositorio de outro BC nem do shared-kernel. `class JsonTenantStateRepository extends JsonProjectManagementStateRepository {}` (classe vazia herdando do shared) = DESVIO grave. Implemente o repositorio diretamente em `<bc>/infrastructure/`.
- Adapter concreto que delega 100% das operacoes para outro repositorio (mesmo via composicao) tambem e DESVIO. Trocar `extends ...{}` por `class JsonXRepository implements XRepository { private readonly other; load() { return this.other.load(); } save(s) { return this.other.save(s); } }` e o mesmo wrapper, agora cosmetico. Adapter concreto precisa implementar `load`/`save` lendo/gravando seu proprio sub-state, nao delegando tudo.

**Sintomas de "BCs cosmeticos sobre estado compartilhado"** (cada um DESVIO grave):

- Repositorios concretos sao classes vazias (`extends ... {}` sem nenhum metodo novo).
- Porta de repositorio do BC retorna state composto cross-BC.
- Cada BC `load()` carrega tudo (incluindo aggregates de outros BCs) e `save()` salva tudo.
- Cross-BC happens via objeto vivo do state compartilhado (`findProject(tenant, projectId)` retornando aggregate de outro BC).
- shared-kernel define `ProjectManagementState`, `TenantWithClients`, ou qualquer composto que liga aggregates de BCs diferentes.

Quando esses sintomas aparecem, o monolito foi **renomeado em fachadas**, nao quebrado em BCs reais.

### Bounded Context = modulo irmao em `src/`

Esta regra e ABSOLUTA e nao tem excecao por reorganizacao interna:

- Bounded context separado vive em `src/<bounded-context>/` como **irmao** de outros BCs, com sua propria estrutura completa (`domain/`, `aggregates/`, `value-objects/`, `application/`, `infrastructure/`, `interface/`).
- Subpastas dentro de `domain/` (ex.: `domain/tenancy/`, `domain/client-management/`) **NAO** sao bounded contexts. Sao no maximo agrupamento estrutural por tema, e em geral DESVIO da regra "aggregates em `aggregates/`".
- Quando uma refatoracao "separa BCs", a expectativa e ter `src/<bc-1>/`, `src/<bc-2>/`, `src/<bc-3>/` irmaos. Nao basta criar subpastas com nomes de BC dentro de um modulo unico.
- BC novo nao e **somente** uma pasta com `aggregates/<aggregate>.ts`. BC novo precisa de estrutura completa: `domain/`+`aggregates/`+`value-objects/`+`application/use-cases/`+`application/ports/`+`infrastructure/`+`interface/`+`README.md`+tests proprios. BC com so o aggregate dentro = **casca vazia**, refatoracao em WIP nao concluida (ver `process-refatoracao-segura` secao 7).

### Value Object (VO)

- **Imutavel**, sem identidade. Igualdade por **valor**, nao por referencia.
- Encapsula um conceito que faz sentido pelo seu conteudo: `Money`, `BillingMonth`, `EmailAddress`, `Cpf`, `Cnpj`, `UserId`, `TenantId`, `TaskId`, `DateRange`, `PercentageRate`.
- Valida invariantes **no construtor/factory**: `Money` nao negativa, `EmailAddress` formato valido, `BillingMonth` padrao `YYYY-MM`, `Cpf` checksum.
- Sem setters. Operacoes retornam novo VO (`amount.add(other)` devolve nova `Money`).

### Entity

- Tem **identidade explicita** (`id`) que persiste atraves de mudancas. Dois `Task` com titulo igual mas `id` diferente sao entidades distintas.
- Igualdade por identidade, nao por valor.
- Mutavel (estado evolui).

### Aggregate

- Cluster de entities + VOs tratado como unidade de consistencia transacional.
- Tem um **Aggregate Root** — a unica entidade acessivel de fora do aggregate.
- Operacoes externas passam **somente** pelo root. Filhos do aggregate sao mutaveis SO via root.
- Exemplo: `Project` e root, `Task` e entity dentro do aggregate. Para completar uma task, chama-se `project.completeTask(taskId, by, at)`, nunca `task.complete()` de fora.
- **Aggregate root e CLASSE com metodos publicos**, NAO type/record mutavel por funcoes externas. `type ProjectAggregate = { ... }` + funcao externa `completeProjectTask(p, ...)` que muta `p.tasks[...]` direto **NAO E** aggregate root — e primitive obsession invertido (estrutura de dados nua orquestrada de fora). Aggregate root encapsula os filhos atras de metodos que validam invariantes.

### Criterios de decisao

| Pergunte | Sim | Nao |
|---|---|---|
| Tem identidade que precisa persistir atraves de mudancas? | Entity | Value Object |
| Faz sentido isoladamente, definido so pelo conteudo? | Value Object | Entity |
| Outros objetos referenciam ele por identidade? | Entity | Value Object |
| Pode ser substituido por outro identico em conteudo? | Value Object | Entity |

### Referencias entre Aggregates e entre Bounded Contexts

- Aggregate **NUNCA** carrega referencia direta a outro Aggregate; carrega o ID (VO de identidade).
- BC **NUNCA** importa entity ou aggregate de outro BC; importa so o ID (VO compartilhado em camada `shared-kernel/`, OU duplicado intencionalmente em cada BC com mesmo formato).
- Carregar a outra aggregate quando precisar e responsabilidade do **caso de uso**, que coordena dois repositorios.

### Anti-padrao 1: Primitive Obsession

**Errado** — `string`/`number` cru para tudo:

```typescript
// domain/model.ts (ERRADO)
export type Task = {
  id: string;                   // qual o formato? misturavel com qualquer string?
  projectId: string;            // aponta pra qual BC?
  completedBy: string;          // UserId? email? nome?
  feeAmount: number;            // moeda? centavos? unidade?
};
```

**Certo** — VOs com semantica e invariantes:

```typescript
// domain/ids.ts
export type TaskId = string & { readonly __brand: "TaskId" };
export const TaskId = {
  of(raw: string): TaskId {
    if (!raw.startsWith("task_")) throw new DomainError("invalid_task_id");
    return raw as TaskId;
  },
};

export type UserId = string & { readonly __brand: "UserId" };
export const UserId = { of: (raw: string): UserId => raw as UserId };

// domain/money.ts
export class Money {
  private constructor(
    public readonly cents: number,
    public readonly currency: "BRL" | "USD",
  ) {
    if (!Number.isInteger(cents) || cents < 0) throw new DomainError("invalid_money");
  }
  static of(cents: number, currency: "BRL" | "USD"): Money {
    return new Money(cents, currency);
  }
  add(other: Money): Money {
    if (other.currency !== this.currency) throw new DomainError("currency_mismatch");
    return Money.of(this.cents + other.cents, this.currency);
  }
}

// domain/model.ts (CERTO)
export type Task = {
  id: TaskId;
  projectId: ProjectId;
  completedBy: UserId | undefined;
  fee: Money;
};
```

### Anti-padrao 2: Aggregate Root ignorado

**Errado** — task mutada por fora do root:

```typescript
// application/use-cases/complete-task.ts (ERRADO)
const project = await repository.load(projectId);
const task = project.tasks.find(...);
task.status = "done";                  // mutacao direta no filho
task.completedBy = currentUserId;      // idem
await repository.save(project);
```

**Certo** — mutacao via root, invariantes garantidas no root:

```typescript
// domain/project.ts (CERTO)
export class Project {
  completeTask(taskId: TaskId, by: UserId, at: Date): void {
    const task = this.tasksById.get(taskId);
    if (!task) throw new DomainError("task_not_found");
    if (this.status !== "active") throw new DomainError("project_not_active");
    task.markDone(by, at);             // metodo do Task, chamado SO pelo root
  }
}

// application/use-cases/complete-task.ts (CERTO)
const project = await repository.load(projectId);
project.completeTask(taskId, by, at);
await repository.save(project);
```

### Anti-padrao 3: Bounded contexts como subpastas em vez de modulos irmaos

**Errado** — refatoracao que "separa BCs" mas mantem tudo dentro do mesmo modulo:

```
src/
  project-management/
    domain/
      tenancy/                     ← ❌ NAO e bounded context, e subpasta
        tenant.ts
      client-management/           ← ❌ idem
        client.ts
      project-planning/            ← ❌ idem
        project.ts
      task-tracking/               ← ❌ idem
        task.ts
      shared-kernel/               ← ❌ shared-kernel DENTRO de modulo: violacao dupla
        ids.ts
      model.ts                     ← legado preservado em paralelo
      lifecycle.ts                 ← legado preservado em paralelo
    application/
      project-management-service.ts  ← service monolitico cresceu
```

Sintomas tipicos: arquivos legados (`model.ts`, `lifecycle.ts`) preservados ao lado das "novas BCs"; aggregates como type/record com mutadores externos; service monolitico continua orquestrando tudo; nenhum `src/<bc>/` foi criado.

**Certo** — bounded contexts genuinos como modulos irmaos:

```
src/
  shared-kernel/                   ← VOs de identidade compartilhados na raiz
    value-objects/
      tenant-id.ts
      user-id.ts
      task-id.ts
  tenancy/                         ← BC irmao
    domain/
    aggregates/tenant.ts           ← classe TenantAggregate com metodos
    value-objects/
    application/
    infrastructure/
    interface/
    README.md
  client-management/               ← BC irmao
    ...
  project-planning/                ← BC irmao (Task como aggregate de Project, nao BC proprio)
    domain/
    aggregates/project.ts          ← classe com .completeTask(...) controlando Task entity
    ...
  billing/                         ← BC irmao (pre-existente)
    ...
  interface/cli.ts                 ← composition root roteando para os BCs
```

Cada BC tem seu README, seu e2e, sua cobertura, suas literal unions, seus aggregates como classes. O codigo "legado" do BC original foi MOVIDO (nao duplicado) para os BCs novos. Service monolitico foi quebrado.

### Anti-padrao 4: Cross-BC por objeto em vez de ID

**Errado** — billing importa entity de outro BC:

```typescript
// src/billing/domain/charge.ts (ERRADO)
import type { Task } from "../../project-management/domain/model.js";   // import cross-BC
export function calculateCharge(task: Task): Money { ... }
```

**Certo** — billing tem seu DTO proprio recebido via porta; identidade via VO compartilhado:

```typescript
// src/shared-kernel/ids.ts (VOs de identidade compartilhados)
export type TaskId = ...;
export type UserId = ...;
export type TenantId = ...;

// src/billing/domain/model.ts
import type { TaskId, UserId, TenantId } from "../../shared-kernel/ids.js";

export type CompletedTaskForBilling = {
  taskId: TaskId;
  userId: UserId;
  tenantId: TenantId;
  completedAt: Date;
};

// src/billing/application/ports/completed-task-query.ts
export interface CompletedTaskQueryPort {
  findCompletedTasksForTenant(tenantId: TenantId): Promise<CompletedTaskForBilling[]>;
}
```

A entity `Task` do project-management NAO atravessa a fronteira. Billing trabalha com `CompletedTaskForBilling` (DTO proprio).

## Tipagem do Dominio

- O dominio recebe valores ja **tipados e validados**. Quando o conjunto de valores aceitos for finito ou enumeravel (operadores, estados, papeis, status, codigos de pais, etc.), expresse essa invariante no TIPO em vez de aceitar `string`/`int` cru.
- Use o recurso mais expressivo da linguagem: `Literal` ou `Enum` em Python, *literal union* ou `enum` em TypeScript, `enum` em Java/C#/Rust, *typed string alias* em Go. Tipo expressivo elimina a necessidade de validar o valor de novo dentro do dominio e remove duplicacao entre interface (que valida texto) e dominio.
- Em vez de validar o mesmo conjunto de operadores em duas camadas (`if op not in {...}`), parseie a string textual na interface (ou application), produza o tipo restrito do dominio, e passe ao dominio. O dominio confia no tipo.

### Exemplos por linguagem

**Python** — use `Literal` (ou `Enum`) e construa o tipo na borda:

```python
# domain/arithmetic.py
from typing import Literal

Operator = Literal["+", "-", "*", "/"]

def calculate(left: float, operator: Operator, right: float) -> float:
    # nao precisa validar "operador desconhecido": o tipo ja garante
    ...

# interface/cli.py
def parse_operator(text: str) -> Operator:
    if text not in ("+", "-", "*", "/"):
        raise InvalidInputError(code="unsupported_operator")
    return text  # type: ignore[return-value]  # narrowed pelo check acima
```

**TypeScript** — *literal union* exportada, usada como parametro:

```typescript
// domain/calculator.ts
export type CalculatorOperator = "+" | "-" | "*" | "/";

export function calculate(
  left: number,
  operator: CalculatorOperator,  // nao aceita string crua
  right: number,
): number { ... }

// interface/cli.ts
function parseOperator(text: string): CalculatorOperator {
  if (text !== "+" && text !== "-" && text !== "*" && text !== "/") {
    throw new InvalidInputError("unsupported_operator");
  }
  return text;  // narrowed
}
```

**Java/C#** — `enum`:

```java
public enum Operator { PLUS, MINUS, TIMES, DIV }

public double calculate(double left, Operator op, double right) { ... }
```

**Rust** — `enum`:

```rust
pub enum Operator { Add, Sub, Mul, Div }

pub fn calculate(left: f64, op: Operator, right: f64) -> f64 { ... }
```

**Go** — *typed string*:

```go
type Operator string

const (
    OpAdd Operator = "+"
    OpSub Operator = "-"
    OpMul Operator = "*"
    OpDiv Operator = "/"
)

func Calculate(left float64, op Operator, right float64) float64 { ... }
```

### Anti-padrao: tipo exportado mas nao usado na assinatura

**Errado** — o tipo restrito existe, mas a funcao ainda aceita `string`, forcando um `default` que duplica a validacao da interface:

```typescript
// domain/calculator.ts
export type Operator = "+" | "-" | "*" | "/";  // tipo definido…

export function calculate(
  left: number,
  operator: string,                              // …mas a assinatura aceita string crua
  right: number,
): number {
  switch (operator) {
    case "+": return left + right;
    // ...
    default:
      throw new CalculationError("unsupported_operator");  // validacao duplicada
  }
}
```

**Certo** — assinatura usa o tipo, `default` desnecessario, validacao acontece uma vez na borda:

```typescript
export type Operator = "+" | "-" | "*" | "/";

export function calculate(
  left: number,
  operator: Operator,                            // tipo restrito na assinatura
  right: number,
): number {
  switch (operator) {
    case "+": return left + right;
    case "-": return left - right;
    case "*": return left * right;
    case "/":
      if (right === 0) throw new CalculationError("division_by_zero");
      return left / right;
  }
  // sem default: o tipo garante exaustividade
}

// interface narrowsa string -> Operator antes de chamar
function parseOperator(text: string): Operator {
  if (text === "+" || text === "-" || text === "*" || text === "/") return text;
  throw new CliInputError("unsupported_operator");
}
```

## Localizacao do Parsing

- Parsing de string textual (argv da CLI, body JSON, query string, formularios, XML, AST de linguagens externas) vive na **interface**, nao em `application` nem em `domain`.
- `application` recebe estrutura ja **tipada e validada** e orquestra dominio + portas. Pode validar invariantes de negocio (regra entre campos, autorizacao), mas nao parseia texto.
- Sinais de que parsing vazou para `application`: funcoes `tokenize`, `parseArgs`, `parseOperand`, `split(/\s+/)`, `Number(text)`, `JSON.parse(body)` dentro de `application/*`. Mova para `interface/*` e faca `application` receber um DTO/Request ja tipado.

### Anti-padrao: parsing textual em application

**Errado** — `application` recebe `string[]` cru e tokeniza:

```typescript
// application/evaluate-expression.ts (ERRADO)
export function evaluateExpression(args: string[]): number {
  const tokens = args.join(" ").trim().split(/\s+/).filter(Boolean);
  if (tokens.length !== 3) throw new CalculationError("invalid_expression");
  const [leftToken, op, rightToken] = tokens;
  const left = Number(leftToken);
  const right = Number(rightToken);
  if (!Number.isFinite(left) || !Number.isFinite(right))
    throw new CalculationError("invalid_number");
  return calculate(left, op, right);
}
```

**Certo** — interface parseia e tipa, application recebe DTO estruturado:

```typescript
// application/evaluate-expression.ts (CERTO)
export type CalculationRequest = {
  left: number;
  operator: Operator;
  right: number;
};

export function evaluateExpression(req: CalculationRequest): number {
  return calculate(req.left, req.operator, req.right);
}

// interface/cli.ts (parseia e monta o DTO)
function parseArgs(args: string[]): CalculationRequest {
  if (args.length !== 3) throw new CliInputError("invalid_argument_count");
  const [leftText, opText, rightText] = args;
  return {
    left: parseNumber(leftText),
    operator: parseOperator(opText),
    right: parseNumber(rightText),
  };
}
```

## Portas (Repositorios/Gateways)

- Portas (interfaces de saida da `application` ou do `domain`) sao declaradas como tipo/interface separado das classes que as consomem.
- Com **1 porta** num modulo pequeno, declara-la junto do caso de uso e aceitavel.
- Com **2 ou mais portas**, mova cada uma para `application/ports/<port-name>.ts` (um arquivo por porta). Isso evita arquivos `use-cases.ts` monoliticos e facilita reuso/teste.

### Anti-padrao: portas espalhadas no `use-cases.ts`

**Evite** — multiplas portas misturadas com casos de uso num arquivo unico:

```typescript
// application/use-cases.ts
export type ProjectRepository = { load(): Promise<...>; save(...): Promise<...>; };
export type UserRepository = { findById(...): Promise<...>; ... };
export type NotificationGateway = { send(...): Promise<void>; };

export async function addUser(repo: UserRepository, ...) { ... }
export async function createProject(repo: ProjectRepository, ...) { ... }
// ...arquivo cresce ate ser impossivel revisar
```

**Prefira** — uma porta por arquivo, casos de uso separados:

```typescript
// application/ports/project-repository.ts
export interface ProjectRepository { load(): Promise<...>; save(...): Promise<...>; }

// application/ports/user-repository.ts
export interface UserRepository { findById(...): Promise<...>; ... }

// application/ports/notification-gateway.ts
export interface NotificationGateway { send(...): Promise<void>; }

// application/use-cases/add-user.ts
import type { UserRepository } from "../ports/user-repository.js";
export async function addUser(repo: UserRepository, ...) { ... }
```

## Casos de Uso

- Com **1-4** casos de uso, e aceitavel mante-los num arquivo unico (`application/use-cases.ts` ou similar).
- Com **5 ou mais** casos de uso, separe em `application/use-cases/<use-case>.ts` (um por arquivo), analogo a regra de portas. Mesmo se eles vivem dentro de uma classe `Service` ou modulo agrupador, o arquivo por caso de uso ainda vale.
- **Forma funcional**: uma funcao exportada por arquivo (`createTenant`, `addClientUser`, `completeTask`). Service desnecessario.
- **Forma OO**: uma classe por arquivo (`CreateTenantUseCase`, `AddClientUserUseCase`); `Service` opcional como composicao/wiring, NUNCA monolito com 5+ metodos.
- Service com 5+ metodos publicos em arquivo unico (`ProjectManagementService.createTenant/createClient/createProject/createTask/...`) e DESVIO: ou esconde casos de uso que deveriam viver em arquivos proprios, ou esta combinando preocupacoes distintas (gerencia de tenant + cliente + projeto + task tudo na mesma classe).

### Anti-padrao: service monolitico

**Evite** — uma classe com todos os casos de uso:

```typescript
// application/project-management-service.ts (195 linhas, 11 metodos)
export class ProjectManagementService {
  constructor(private readonly repository: ProjectManagementRepository) {}

  async createTenant(req: CreateTenantRequest): Promise<void> { ... }
  async setTenantStatus(req: SetTenantStatusRequest): Promise<void> { ... }
  async createClient(req: CreateClientRequest): Promise<void> { ... }
  async addClientUser(req: AddClientUserRequest): Promise<void> { ... }
  async setClientStatus(req: SetClientStatusRequest): Promise<void> { ... }
  async createProject(req: CreateProjectRequest): Promise<void> { ... }
  async addProjectUser(req: AddProjectUserRequest): Promise<void> { ... }
  async setProjectStatus(req: SetProjectStatusRequest): Promise<void> { ... }
  async createTask(req: CreateTaskRequest): Promise<void> { ... }
  async completeTask(req: TaskRequest): Promise<void> { ... }
  async listTasks(req: ProjectRequest): Promise<readonly Task[]> { ... }
}
```

**Prefira** — um caso de uso por arquivo:

```
application/
  ports/
    project-management-repository.ts
  use-cases/
    create-tenant.ts            # export async function createTenant(repo, req) { ... }
    set-tenant-status.ts
    create-client.ts
    add-client-user.ts
    set-client-status.ts
    create-project.ts
    add-project-user.ts
    set-project-status.ts
    create-task.ts
    complete-task.ts
    list-tasks.ts
```

Cada arquivo expoe **uma** funcao (ou classe) com escopo claro. Testes ficam colocalizados por caso de uso. Quando aparece o caso de uso #12, voce sabe exatamente onde adiciona-lo.

## Politicas (Permissoes, Estados, Regras Tabulares)

- Quando o dominio expoe **3 ou mais** funcoes `assertCan*`, `canDo*`, `mayAccess*` ou variantes que so diferem na lista de papeis/estados aceitos, substitua o conjunto de funcoes por uma **policy table**: a politica vira DADO, nao funcao. Mais facil de ler, estender e revisar.
- Funcao `assertCan*` com corpo vazio ou apenas `return;` mantida "por simetria" e sempre DESVIO: ou remova a funcao, ou troque a regra concreta por chamada generica `assertCan(role, "<action>")` resolvida na policy table.

### Anti-padrao: funcoes `assertCan*` espelhadas

**Evite** — funcoes quase identicas, uma vazia "por simetria":

```typescript
// domain/permissions.ts
export function assertCanManageUsers(role: UserRole): void {
  if (role !== "admin") throw new DomainError("permission_denied");
}
export function assertCanManageProjects(role: UserRole): void {
  if (role !== "admin") throw new DomainError("permission_denied");
}
export function assertCanCreateTask(role: UserRole): void {
  if (role === "viewer") throw new DomainError("permission_denied");
}
export function assertCanCompleteTask(role: UserRole): void {
  if (role === "viewer") throw new DomainError("permission_denied");
}
export function assertCanReadProject(): void { return; }  // funcao vazia: DESVIO claro
```

**Prefira** — policy como dado, um unico helper:

```typescript
// domain/permissions.ts
export type Action =
  | "manage_users"
  | "manage_projects"
  | "create_task"
  | "complete_task"
  | "read_project";

const PERMISSIONS: Record<Action, ReadonlyArray<UserRole>> = {
  manage_users:    ["admin"],
  manage_projects: ["admin"],
  create_task:     ["admin", "member"],
  complete_task:   ["admin", "member"],
  read_project:    ["admin", "member", "viewer"],
};

export function assertCan(role: UserRole, action: Action): void {
  if (!PERMISSIONS[action].includes(role)) {
    throw new DomainError("permission_denied");
  }
}
```

Mesmo principio vale para maquinas de estado (`canTransitionTo`), niveis de plano (`canUseFeature`), etc. Politica = dado tabular + helper generico.

## Modulo vs Submodulo de Camada

Modulo (diretorio irmao em `src/`) representa um bounded context — vocabulario proprio, ciclo de vida independente. Adapter de persistencia, cliente HTTP, parser, mapper etc. do proprio modulo sao submodulo de camada (`infrastructure/`), NUNCA modulo irmao. Criterios detalhados em `workflow-iniciar-aplicacao`.

A decisao vale tambem quando o projeto e estendido. Ao adicionar feature nova em projeto existente, NAO assuma por inercia que ela cabe no modulo atual: reaplique os criterios de bounded context (vocabulario, ciclo de vida, modelos homonimos, possibilidade de extracao).

Sinais de DESVIO:

- `src/<entidade>/` + `src/<entidade>-storage/` (ou `<entidade>-repository`, `<entidade>-db`, `<entidade>-client`) — storage do proprio modulo nao e bounded context. Mova para `src/<entidade>/infrastructure/`.
- `src/storage/`, `src/persistence/`, `src/http/` como modulo irmao do nucleo — sao camadas tecnicas, nao dominios.
- Bounded context novo (`billing`, `notifications`, `audit`, `shipping`) enxertado dentro de modulo existente em vez de viver em `src/<novo-modulo>/` irmao — DESVIO. Veja exemplo abaixo.

### Anti-padrao: extensao com bounded context novo enxertado em modulo existente

Cenario: projeto tem `src/project-management/` (users, projects, tasks). Pedido novo: "adicionar emissao de cobrancas mensais por usuario".

**Errado** — billing entra dentro do modulo existente, contaminando tipos e estado:

```typescript
// src/project-management/domain/project.ts (ERRADO)
export type Task = {
  readonly id: string;
  readonly title: string;
  readonly status: TaskStatus;
  readonly completedByUserId?: string;
  readonly completedBillingMonth?: BillingMonth;   // ❌ vocabulario de billing dentro de Task
};

export type ProjectManagementState = {
  readonly users: readonly User[];
  readonly projects: readonly Project[];
  readonly monthlyCharges: readonly MonthlyCharge[];  // ❌ estado de billing misturado
};

export const COMPLETED_TASK_CHARGE_CENTS = 10000;  // ❌ constante de billing no dominio errado

export function issueMonthlyCharges(...) { ... }   // ❌ regra de billing no dominio errado

// src/project-management/domain/permissions.ts (ERRADO)
export type ProjectAction =
  | "add_user" | "create_project" | "complete_task"
  | "issue_monthly_charges";                       // ❌ acao de billing na policy de project
```

Sintomas que aparecem juntos: tipo existente ganha campos `billing*`, `State` ganha colecao de cobrancas, constante de billing no `domain/project.ts`, policy table mistura acoes dos dois dominios, README passa a dizer "gerencia projetos, tasks **e cobrancas**".

**Certo** — billing nasce como modulo irmao, project-management expoe so o necessario:

```
src/
  project-management/                 # modulo existente, foco preservado
    domain/
      project.ts                      # Task tem completedAt: Date e completedBy: UserId (genericos)
    application/
      ports/project-store.ts
    ...
  billing/                            # bounded context novo, irmao
    domain/
      charge.ts                       # MonthlyCharge, BillingMonth, regra de tarifa
      period.ts
    application/
      ports/
        completed-task-query.ts       # porta para CONSULTAR tasks concluidas
        charge-store.ts
      issue-monthly-charges.ts        # caso de uso de billing
    infrastructure/
      project-management-completed-task-query.ts  # adapter que le do project-management
      file-charge-store.ts
    interface/
      cli.ts                          # ou comando dedicado, ou comando da CLI existente delega aqui
    README.md
```

Pontos-chave do "certo":
- `Task` volta a ter `completedAt: Date` e `completedBy: UserId` (genericos). Billing deriva o `BillingMonth` a partir de `completedAt`.
- `ProjectManagementState` NAO conhece `monthlyCharges`. Billing tem seu proprio `BillingState`.
- A policy table de project nao tem acao de billing. Billing tem a propria policy se precisar.
- O adapter `project-management-completed-task-query` em `billing/infrastructure/` e o UNICO ponto que conhece o formato de tasks do project-management. Se billing virar servico, esse adapter vira HTTP client.

## Edição de Código Existente

- Antes de alterar, identifique a responsabilidade atual do arquivo e suas dependências.
- Não mova regra de negócio para camadas externas para ganhar velocidade.
- Não introduza dependência de framework, ORM, HTTP ou ambiente dentro do domínio.
- Preserve contratos públicos quando possível.
- Se encontrar uma violação arquitetural próxima da mudança, corrija apenas quando isso for necessário para atender ao pedido ou reduzir risco direto.

## Testes

- Teste regras de domínio com testes unitários rápidos e sem infraestrutura.
- Teste casos de uso com dependências substituídas por fakes, mocks ou in-memory adapters.
- Teste infraestrutura quando a integração, query, serialização ou adapter for parte do risco.
- Evite depender de testes ponta a ponta para validar regra de negócio que pode ser testada mais perto do domínio.

## Checklist

- O módulo tem as três camadas mínimas (`domain`, `application`, `interface`) ou o equivalente idiomático da stack, mesmo em utilitário pequeno.
- A interface delega para um caso de uso da aplicação; não chama o domínio diretamente.
- Os tipos de entrada do domínio expressam suas invariantes (literal union, enum, typed alias) em vez de aceitar `string`/`int` cru quando o conjunto for finito. A validação do conjunto acontece UMA VEZ, na fronteira (interface ou application), não duplicada no domínio.
- Parsing textual (argv, JSON body, query string, formulários, AST) fica na `interface`. `application` recebe DTO/Request já tipado e validado. Funções como `tokenize`, `parseArgs`, `Number(text)`, `JSON.parse(body)` em `application/*` são desvios.
- Tipo restrito (literal union, enum) está **usado na assinatura**, não apenas exportado. Tipo exportado e não usado é código morto e gera `default`/`else` duplicando validação da interface.
- A regra de negócio ficou no domínio ou na aplicação, não na interface.
- O domínio não depende de framework, banco, HTTP, fila, sistema de arquivos ou variáveis de ambiente.
- Dependências externas foram acessadas por portas/interfaces quando atravessam camadas.
- Nomes refletem o vocabulário do domínio.
- O nome do pacote/módulo não contém sufixo da tecnologia de entrega (`_cli`, `_api`, `_web`, `_service`, etc.); esses sufixos só aparecem no nome publicado do projeto quando necessário.
- O domínio não contém parsing textual, serialização, IO, templates de apresentação nem manipulação de AST de linguagens externas. Entradas textuais são parseadas em `interface` ou `application` e chegam ao domínio já tipadas.
- Código novo foi criado dentro de `src/<modulo>` ou no layout explícito da stack, não espalhado na raiz.
- Rules aplicáveis de nomenclatura e estrutura foram usadas quando não havia convenção local.
- Documentação de raiz ou módulo foi atualizada quando a arquitetura ou estrutura mudou.
- Testes cobrem o comportamento alterado no nível adequado.
