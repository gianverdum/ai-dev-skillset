---
name: quality-revisao-aderencia
description: 'OBRIGATORIO carregar antes de qualquer frase de conclusao em tarefa de implementacao, refatoracao, fix ou extensao. Frases-gatilho que EXIGEM checklist rodada antes: "concluido", "completo", "feito", "pronto", "terminei", "finalizado", "the refactoring is complete", "tudo certo", "refatoracao concluida", "feature pronta", ou qualquer declaracao de fim de tarefa. Sem essa checklist rodada e reportada no formato exigido, declarar conclusao e DESVIO grave de honestidade. Revisa aderencia as skills e rules ativas, identifica desvios, corrige o que cabe no escopo, e reporta em formato estruturado (DESVIOs corrigidos + debito herdado + status item-a-item da checklist objetiva de 9 itens). Em extensao, aplica checklist separadamente a cada modulo novo. Garante que tipagem do dominio, localizacao do parsing, codigos de erro estaveis, lint real, idioma do codigo, estrutura de testes (e2e por modulo) e fronteiras de bounded context nao sejam violadas silenciosamente.'
---

# Revisao de Aderencia a Skills e Rules

Use esta skill como ultima etapa antes de declarar uma tarefa concluida e, em mudancas grandes, tambem ao terminar cada etapa significativa (modulo novo, camada nova, refator estrutural). O objetivo e fechar o ciclo TDD/quality e impedir desvios silenciosos.

## Quando rodar

**Regra absoluta de gatilho — antes de qualquer frase de conclusao:**

Antes de escrever no resumo final QUALQUER uma destas frases (ou equivalente em outro idioma), VOCE PRECISA ter rodado a checklist objetiva desta skill:

- "concluido" / "completo" / "completa" / "pronto" / "feito" / "terminei" / "finalizado" / "encerrado"
- "the refactoring is complete" / "refactor is done" / "implementation complete" / "all done"
- "refatoracao concluida" / "feature pronta" / "task pronta" / "tudo certo"
- Qualquer declaracao categorica de fim de tarefa (mesmo implicita: "rodei tudo, passou", "all checks pass", etc.)

Se a checklist objetiva (secao "Pontos a verificar") tem **2 ou mais itens vermelhos**, voce esta PROIBIDO de usar qualquer dessas frases. Use o formato WIP transparente em vez (secao "Formato no reporte final QUANDO refatoracao esta em WIP").

Declarar conclusao com itens vermelhos sem WIP = DESVIO grave de honestidade, anula o credito do trabalho feito.

**Outros gatilhos:**

- Ao terminar uma implementacao, fix ou refator, antes do resumo final ao usuario.
- Ao concluir um modulo novo, antes de seguir para o proximo.
- Ao concluir uma camada (domain/application/interface) novamente, antes de seguir.
- **Sempre que uma extensao criar modulo novo**: aplique a checklist completa SEPARADAMENTE ao modulo novo (suite e2e propria, README proprio, cobertura propria, literal unions, etc.), mesmo que o modulo existente ja tenha cobertura completa.
- Quando o usuario pedir explicitamente revisao de aderencia.

**Sintoma da skill nao rodada (auto-deteccao):**

Se voce esta prestes a escrever uma frase de conclusao e NAO consegue listar mentalmente o status (❌/✅) dos 9 itens da checklist objetiva nem dos anti-padroes desta secao, voce nao rodou a skill. Pare, leia esta skill, rode item-a-item, depois decida entre "concluido" ou "WIP transparente".

## Fluxo

1. Liste as skills e rules ATIVAS para a stack e tipo de mudanca (consulte `.agents/skills` e `.agents/rules`).
2. Identifique se a mudanca e **criacao inicial** ou **extensao** (projeto existente). Em extensao, identifique modulos NOVOS criados na mudanca vs modulos EXISTENTES tocados.
3. Enumere os pontos verificaveis: estrutura, camadas, nomes, tipagem do dominio, idioma do codigo, codigos de erro, lint, testes, cobertura, documentacao.
4. **Em extensao, aplique a checklist completa SEPARADAMENTE para cada modulo novo.** Modulo novo herda zero credito do modulo existente: precisa ter sua propria suite e2e completa (4 cenarios minimos quando aplicavel), seu proprio README, sua propria cobertura ≥ 80%, suas proprias literal unions, etc.
5. Para cada ponto, compare com o codigo produzido (working tree e diff). Marque cada item como **OK** ou **DESVIO**.
6. Quando houver desvio, decida:
   - Corrigir agora (default) se o ajuste cabe no escopo da tarefa.
   - Registrar bloqueio concreto se a correcao depende de algo externo.
7. Aplique as correcoes, rode lint/format/tests novamente e reavalie ate ficar limpo.
8. **Em extensao, reporte tambem debito herdado visivel** na area tocada (DESVIOs pre-existentes nao introduzidos por esta mudanca, mas visiveis no modulo/arquivo editado). Veja secao "Debito herdado".
9. Reporte ao usuario o resultado do checklist com OK/DESVIO/corrigido por item, antes do resumo final da tarefa.

## Pontos a verificar

Esta lista cobre os desvios mais comuns observados em iteracoes anteriores. Ela nao substitui as skills/rules; e um checklist operacional.

### Arquitetura

- Identifique a skill de arquitetura ativa antes de avaliar: Clean Arch (`architecture-ddd-clean-arch`) exige `domain`/`application`/`interface`; Hexagonal (`architecture-ddd-hexagonal`) exige `domain`/`application`/`adapters/in`+`adapters/out`. A escolha segue a precedencia: padrao do projeto > pedido do usuario > default Clean Arch. Modulo misturando os dois layouts e DESVIO.
- Modulo tem as camadas minimas exigidas pela arquitetura ativa.
- Camada de entrada (interface ou `adapters/in`) chama application/caso de uso; application chama domain. Sem atalhos da interface direto para o domain.
- Dominio NAO contem: parsing textual, IO, serializacao, framework, mensagens humanas, import de adapter.
- Application NAO faz parsing textual cru (tokenizar string, split, regex em argv, `Number(text)`, `JSON.parse(body)`). Esses passos sao da camada de entrada (interface ou `adapters/in`). Application recebe DTO/Request ja tipado e orquestra dominio.
- Em Hexagonal: portas de saida declaradas no nucleo; implementacoes em `adapters/out`; wiring em `config/` ou entrypoint.

### Tipagem do dominio

- Quando o conjunto de valores aceitos for finito (operador, status, papel, codigo), a assinatura do dominio expressa isso por tipo (`Literal`, *literal union*, `enum`, `typed alias`).
- O tipo expressivo esta USADO na assinatura, nao apenas exportado.
- Nao ha validacao duplicada do conjunto (uma vez na interface, outra dentro do dominio com `default`/`else`).

### Modelagem tatica (Aggregate, Entity, Value Object)

- Conceitos com identidade ou semantica propria (`TaskId`, `UserId`, `TenantId`, `Money`, `BillingMonth`, `EmailAddress`, `Cpf`) estao modelados como **Value Object** com invariantes no construtor, nao como `string`/`number` cru.
- Aggregates expoem um **Aggregate Root** explicito como **classe com metodos**, nao type/record mutavel por funcoes externas. Entities filhas do aggregate sao mutaveis SO via metodos do root (ex.: `project.completeTask(...)`, nunca `task.status = "done"` direto nem `setProjectTaskStatus(project, ...)` externa que muta o campo).
- **Aggregate root e dono da colecao** de seus filhos. Composite externo (`type X = XAggregate & { children: ... }` definido em outro modulo ou no shared-kernel, com mutacao da colecao por fora via cast) e DESVIO; a colecao mora dentro do aggregate root, manipulada por seus metodos.
- Referencias entre aggregates sao por **ID** (VO de identidade), nao por objeto direto.
- Cross-BC: nenhum BC importa entity ou aggregate de outro BC. Comunicacao via porta + DTO proprio do BC consumidor, com VOs de identidade compartilhados em `src/shared-kernel/value-objects/` ou duplicados intencionalmente.

### Shared-kernel restrito

`src/shared-kernel/` so pode conter: `value-objects/` (VOs de identidade compartilhados) + `errors.ts` opcional (classe base de erro) + `event-types.ts` opcional (tipos de evento). Tudo o mais e DESVIO:

- `shared-kernel/application/` = DESVIO.
- `shared-kernel/infrastructure/` = DESVIO.
- `shared-kernel/interface/` = DESVIO.
- `shared-kernel/domain/<state>.ts` com state composto cross-BC (`ProjectManagementState`, `Tenant & { clients }`) = DESVIO.
- Helpers como `findTenant`/`findClient`/`findProject` em `shared-kernel/application/` = DESVIO.

Quando shared-kernel cresce alem disso, o monolito foi renomeado, nao quebrado.

### Isolamento de estado por BC

Cada BC tem state, repositorio e schema persistido proprios:

- Port de repositorio do BC retorna `<BC>State` proprio (ex.: `TenantState`), NAO um composto cross-BC (`ProjectManagementState`).
- Adapter concreto implementa o repositorio diretamente, NAO via classe vazia herdando do shared-kernel.
- Schema persistido por BC. Se a stack obriga arquivo unico, sub-arvore versionada por BC com cada repositorio acessando SOMENTE a sua sub-arvore.

### Layout estrutural

- Cada modulo segue `src/<modulo>/{domain, aggregates, value-objects, application, infrastructure, interface}`.
- `aggregates/` e `value-objects/` ficam **no mesmo nivel de `domain/`**, NUNCA dentro de `domain/`.
- Cada aggregate root em arquivo proprio (`aggregates/<aggregate>.ts`). Cada VO em arquivo proprio (`value-objects/<vo>.ts`).
- `src/shared-kernel/value-objects/` na RAIZ de `src/` para VOs de identidade compartilhados. Nunca dentro de outro modulo.
- Bounded context separado = `src/<bc>/` irmao, com estrutura completa. Subpastas dentro de `domain/` (`domain/tenancy/`, `domain/billing/`) NAO sao BCs.

### Idioma do codigo

- Identificadores em ingles (variaveis, funcoes, classes, modulos, pacotes, testes).
- Mensagens ao usuario nao sao literais traduzidos no dominio/application. Dominio/application lancam codigo estavel snake_case ingles; interface resolve para texto via dicionario/i18n.

### Nomes e estrutura

- Nome do pacote/modulo reflete o DOMINIO, nao a interface. Sufixos `_cli`, `_api`, `_web` so no nome publicado.
- `src/<modulo>` na raiz; sem pasta intermediaria com nome do projeto.
- Testes seguem a rule da linguagem: colocalizados (Go/Rust/TS/JS) ou em `tests/<tipo>/<espelho-de-src>` (Python/PHP/etc).
- README na raiz e README de cada modulo (sem README de submodulo de camada).

### Lint, format, manifesto

- Linter idiomatico instalado e configurado (ruff, biome/eslint, clippy, golangci-lint, etc.).
- Scripts `lint` e `format` no manifesto invocam ferramentas REAIS, nao alias de `typecheck`/`build`/`test`.
- Runtime declarado em projeto novo (`engines.node`+`.nvmrc` em Node, `requires-python` em Python, etc.).
- Lint roda limpo, ou apontamentos foram corrigidos. Nenhum aviso silenciado sem justificativa.

### Testes e cobertura

- Suite roda verde.
- Cobertura >= 80% ou bloqueio explicado.
- Testes cobrem caminho feliz e erros relevantes; nao ha teste vazio ou snapshot sem asseracao.
- Se o modulo persiste estado externo (arquivo, banco, fila, cache, broker, HTTP) ou expoe entrypoint executavel (CLI, HTTP server, daemon), existe ao menos um teste e2e cobrindo o fluxo cross-command/cross-request, alem de unit e integration. Integration sozinho NAO basta.
- Se o modulo tem autorizacao/permissao, validacao cruzada ou multiplos comandos, a suite e2e cobre tambem fluxos criticos de erro (permissao negada, recurso inexistente, validacao de entrada), nao apenas o happy path.
- **Em extensao**: modulo novo criado durante a extensao precisa de suite e2e propria com cobertura completa dos 4 cenarios (happy + permission_denied + not_found + invalid_input), independente do modulo existente ja ter cobertura completa. O fato de o modulo existente ter 6 e2e no padrao nao isenta o modulo novo de cobrir os mesmos cenarios para suas proprias operacoes.

### Portas, casos de uso e politicas

- Quando ha 2+ portas (interfaces de saida) na `application`, cada uma vive em seu proprio arquivo em `application/ports/<port>.ts` (Clean Arch ou Hex). Multiplas portas declaradas dentro de `use-cases.ts` = DESVIO.
- Quando ha 5+ casos de uso na `application`, cada um vive em seu proprio arquivo em `application/use-cases/<use-case>.ts`. Arquivo unico `use-cases.ts` ou `Service` monolitico com 5+ metodos publicos = DESVIO.
- Quando o dominio expoe 3+ funcoes `assertCan*`/`canDo*`/`mayAccess*` que so diferem em listas de papeis/estados aceitos, substitua por uma policy table (`Record<Action, ReadonlyArray<Role>>`) + helper generico `assertCan(role, action)`. Funcoes espelhadas = DESVIO.
- Funcao `assertCan*`/`assert*`/`validate*` com corpo vazio ou apenas `return;` mantida por simetria = DESVIO; remova ou absorva no helper generico.

### Codigos de erro

- O `code`/`kind`/`reason` da classe de erro deve ser **enumeracao explicita** (literal union em TS, `Literal[...]`/`Enum` em Python, `enum` em Rust/Java/C#). `code: string` cru = DESVIO; perde a garantia de exaustividade entre codigos e catalogo de mensagens.
- O dicionario de mensagens da interface deve ser tipado como `Record<EnumDeCodigos, string>` (ou equivalente). `Record<string, string>` = DESVIO; aceita typo silenciosamente e nao alerta sobre codigo novo sem mensagem.

### Fronteira de modulo

- Cada diretorio irmao em `src/` e um bounded context com vocabulario proprio. Adapter de persistencia, cliente HTTP, parser, mapper do PROPRIO modulo nao sao modulos irmaos: ficam como submodulo de camada (`infrastructure/` em Clean Arch ou `adapters/out/` em Hexagonal) dentro do modulo dono.
- A decisao vale tambem em extensoes. Em projeto existente, bounded context novo (vocabulario proprio, ciclo de vida proprio) vira `src/<novo-modulo>/` irmao, NUNCA enxertado no modulo existente. "Preservar padrao local" vale para naming/estilo/layout, nao para misturar bounded contexts no mesmo modulo.
- Sintomas de vazamento (cada um sozinho ja e DESVIO): tipo de entidade existente ganhou campo com vocabulario do novo dominio (`Task.completedBillingMonth`, `User.subscriptionTier`); `State`/agregado existente ganhou colecao do novo dominio (`ProjectManagementState.monthlyCharges`); constante/regra do novo dominio em arquivos do dominio existente (`COMPLETED_TASK_CHARGE_CENTS` em `domain/project.ts`); policy table existente ganhou actions do novo dominio (`issue_monthly_charges`); UX existente passou a exigir campos do novo dominio (`complete-task --billing-month`); README do modulo existente cita novos dominios no titulo/responsabilidade.

### Documentacao

- README da raiz e do modulo refletem a estrutura atual.
- Comandos documentados foram validados.

## Debito herdado (em extensao)

Em extensao de projeto existente, o agente toca arquivos/modulos que podem conter DESVIOs **pre-existentes** — codigo nao introduzido por esta mudanca mas visivel no diff ou na vizinhanca. A regra:

- **Reportar, nao obrigar correcao.** Debito herdado vai em secao separada na resposta final, listada como "Debito herdado visivel" (nao como "DESVIO desta mudanca"). A decisao de corrigir e do usuario.
- **Nao expandir escopo silenciosamente.** Refatorar codigo legado fora do pedido do usuario contraria a precedencia "preservar padrao local + escopo da tarefa". Mencionar o debito permite ao usuario decidir conscientemente.
- **Quando corrigir junto:** apenas se (a) a correcao e trivial e diretamente relacionada ao escopo, OU (b) o debito impede a entrega correta da mudanca, OU (c) o usuario autorizou a refatoracao. Caso contrario, apenas reporte.

Exemplos de debito herdado a reportar:

- `*Service` monolitico com 5+ metodos publicos (regra de "use cases por arquivo" violada antes da mudanca).
- Funcao `assertCan*` vazia ou funcoes espelhadas que sobreviveram a iteracoes anteriores.
- `code: string` cru em classe de erro existente.
- `Record<string, string>` em catalogo de mensagens antigo.
- Tipos sem `readonly` quando o padrao do projeto e imutavel.
- `any` remanescente em codigo legado.
- README desatualizado para a estrutura atual.

### Formato no reporte final

```
## Revisao de aderencia

### DESVIOs desta mudanca (corrigidos)
- ... (lista de itens corrigidos)

### Debito herdado visivel (nao corrigido nesta mudanca)
- src/project-management/application/project-management-service.ts: classe com 11 metodos publicos viola a regra "5+ casos de uso em arquivos proprios". Pre-existente; correcao fora do escopo desta extensao.
- ...
```

### Formato no reporte final QUANDO refatoracao esta em WIP

Quando a checklist objetiva de conclusao (`process-refatoracao-segura` secao 7) tem 2+ itens falhando, NUNCA declare "refatoracao concluida". Use este formato:

```
## Refatoracao em andamento (WIP)

### Feito
- (lista do que foi efetivamente movido/extraido/migrado)

### Pendente (bloqueia "concluido")
- (lista objetiva: o que ainda precisa ser feito para fechar a checklist objetiva)
- (cite os itens da checklist que ainda falham, com caminho dos arquivos envolvidos)

### Itens da checklist objetiva (status atual)
1. Modulo original reduzido para ~30% ou removido: ❌/✅
2. Cada BC novo com estrutura completa: ❌/✅
3. Composition root roteando BCs novos: ❌/✅
4. Suite de testes por BC novo: ❌/✅
5. Migracao de dados decidida e implementada: ❌/✅
6. Isolamento de estado real (cada BC com state/port/repo/schema proprios; sem repositorio vazio herdando): ❌/✅
7. shared-kernel dentro do limite (so value-objects + opcionalmente errors/event-types): ❌/✅
8. Nenhum modulo (independente do nome) define composite cross-BC ou e "monolito disfarcado" (sem aggregates/use-cases proprios): ❌/✅
9. Repositorios concretos implementam load/save lendo seu sub-state, sem delegar 100% a outro repositorio: ❌/✅

### Decisoes pendentes para proxima sessao
- (escolhas que dependem do usuario antes do agente continuar)
```

Refatoracao com 2+ itens vermelhos da checklist objetiva, entregue sem esse formato WIP, e DESVIO grave de honestidade na entrega.

## Anti-padroes recorrentes (gatilho de DESVIO imediato)

- Tipo exportado no dominio mas a assinatura ainda aceita `string`/`int` cru — DESVIO de tipagem.
- `default` em switch do dominio lancando "operador/status invalido" — duplicacao com a validacao da interface. DESVIO.
- Funcoes `tokenize`, `parseArgs`, `parseOperand`, `Number(text)` dentro de `application` — DESVIO de localizacao do parsing.
- Mensagem humana lancada do dominio (`throw new Error("Division by zero is not allowed.")`) — DESVIO de i18n.
- Script `lint` definido como `tsc --noEmit` ou `mypy` — DESVIO; `lint` deve invocar linter real.
- Tipo `string` para operador, status, papel quando a rule diz para usar tipo restrito — DESVIO.
- README de submodulo de camada (`src/<modulo>/domain/README.md`) — DESVIO; submodulos sao descritos no README do modulo.
- Modulo persiste estado externo ou expoe entrypoint executavel mas nao tem teste e2e — DESVIO; integration nao substitui e2e.
- `src/<entidade>-storage/`, `src/<entidade>-repository/`, `src/<entidade>-client/` como modulo irmao do modulo `<entidade>` — DESVIO; deveriam ser submodulo de camada dentro de `src/<entidade>/`.
- `src/storage/`, `src/persistence/`, `src/http/`, `src/adapters/` como modulo irmao do nucleo — DESVIO; camadas tecnicas globais nao sao bounded contexts.
- Funcao `assertCan*`/`assert*Permission`/`canDo*` com corpo vazio ou apenas `return;` mantida por simetria — DESVIO; remova ou troque por chamada generica `assertCan(role, "<action>")` ligada a policy table.
- 3+ funcoes `assertCan*` que diferem somente na lista de papeis/estados aceitos — DESVIO; converta em policy table (`Record<Action, ReadonlyArray<Role>>`) + helper generico.
- 2+ portas declaradas dentro de `application/use-cases.ts` em vez de `application/ports/<port>.ts` — DESVIO; uma porta por arquivo.
- E2E unico cobrindo so o happy path em modulo com autorizacao/multiplos comandos — DESVIO; suite e2e precisa cobrir permissao negada, recurso inexistente e validacao de entrada.
- Uso de `any` em codigo TypeScript (`any`, `any[]`, `Record<string, any>`, `as any`, `<any>`, parametro/retorno `any`, `catch (e: any)`) — DESVIO; troque por `unknown` + narrowing, ou tipo restrito. Excecao isolada a integracao sem tipos, com comentario justificando.
- Bounded context novo (vocabulario proprio, ciclo de vida proprio: `billing`, `notifications`, `audit`, `shipping`, `analytics`...) enxertado dentro de modulo existente em vez de viver em `src/<novo-modulo>/` irmao — DESVIO. Extraia para modulo proprio; o novo modulo consome o existente via porta (`completed-task-query`, `user-lookup` etc.).
- Tipo de entidade do modulo existente passou a carregar atributo com vocabulario de outro dominio (`Task.completedBillingMonth`, `Order.crmContactId`, `User.subscriptionTier`) — DESVIO; troque por atributo generico (`completedAt: Date`, `externalReference: string`) e deixe o outro dominio derivar o conceito proprio dele.
- `State`/agregado do modulo existente ganhou colecao ou campo do novo dominio (`ProjectManagementState.monthlyCharges`, `ShopState.shippingLabels`) — DESVIO; novo dominio tem seu proprio state/store/porta.
- Policy table do modulo existente ganhou action do novo dominio (`assertCan(role, "issue_monthly_charges")` em `project-management/permissions.ts`) — DESVIO; cada dominio tem sua propria policy.
- `code: string` cru em classe de erro (`DomainError`, `ApplicationError`, `CliInputError`) — DESVIO; deve ser literal union/`Literal`/`Enum` explicita para garantir consistencia com o catalogo de mensagens.
- `Record<string, string>` para `ERROR_MESSAGES`/`SUCCESS_MESSAGES` — DESVIO; tipe como `Record<EnumDeCodigos, string>` para o compilador alertar typo e falta de chave.
- Classe `*Service` ou similar com 5+ metodos publicos representando casos de uso distintos — DESVIO; quebre em `application/use-cases/<use-case>.ts` (um arquivo por caso de uso).
- Conceito de dominio com identidade ou invariantes modelado como `string`/`number` cru (`TaskId: string`, `amount: number`, `email: string`, `cpf: string`) — DESVIO de primitive obsession; crie Value Object que encapsula a invariante.
- Mutacao direta em filho de aggregate a partir de fora do root (`task.status = "done"` chamado em arquivo de use-case, em vez de `project.completeTask(...)`) — DESVIO de aggregate root; mutacao vai pelo root.
- Aggregate carrega referencia direta a outra aggregate (`Project.tenant: Tenant` em vez de `Project.tenantId: TenantId`) — DESVIO; aggregates referenciam por ID.
- Domain de um BC importa entity ou aggregate de outro BC (`billing/domain/charge.ts` importa `Task` de `project-management/domain/model.ts`) — DESVIO; cross-BC se comunica via porta + DTO proprio. VOs de identidade ficam em `shared-kernel/`.
- Refatoracao estrutural feita sem characterization tests, em passo grande, ou misturada com feature nova — DESVIO de protocolo de refatoracao segura (veja `process-refatoracao-segura`).
- Mudanca de schema de dados persistidos sem migracao decidida (script standalone, ou migracao na leitura com versao no arquivo) — DESVIO; dados em uso desaparecem silenciosamente.
- Bounded contexts apresentados como subpastas dentro de `domain/` (ex.: `src/project-management/domain/tenancy/`, `domain/client-management/`, `domain/billing/`) em vez de modulos irmaos em `src/` — DESVIO grave; BC = modulo irmao com estrutura completa, nao subpasta tematica.
- Aggregate modelado como `type` ou `interface` com funcoes externas mutando campos (`setProjectStatus(project, status)` que faz `project.status = status`) em vez de classe com metodos — DESVIO; aggregate root e classe que encapsula filhos e valida invariantes nos metodos.
- `aggregates/` ou `value-objects/` ausentes ou dentro de `domain/` — DESVIO; sao pastas no mesmo nivel de `domain/`, cada item em arquivo proprio.
- `shared-kernel/` dentro de um modulo (`src/project-management/domain/shared-kernel/`) em vez de na raiz de `src/` — DESVIO; VOs de identidade compartilhados vivem em `src/shared-kernel/value-objects/`.
- Refatoracao declarada concluida mas com legado preservado em paralelo (`model.ts`, `lifecycle.ts`, `permissions.ts` antigos coexistem com estrutura nova; service monolitico permanece ou cresceu; aggregates novos chamados PELO legado) — DESVIO; ou conclua a refatoracao (remova o legado), ou entregue como WIP explicito com checkpoint registrado.
- **Modulo original ainda tem mais de ~30% das linhas pre-refatoracao OU continua com lifecycle/service/repositorio/CLI principal funcionando** — DESVIO objetivo de refatoracao nao concluida. Soma de linhas em `src/<original>/**/*.ts` (excluindo tests) comparada com o estado anterior.
- **BC novo criado contem apenas `aggregates/<aggregate>.ts`** (ou apenas 1-2 arquivos no total), sem `application/use-cases/`, sem `application/ports/`, sem `infrastructure/`, sem `interface/`, sem tests proprios — DESVIO objetivo: casca vazia. BC novo precisa de estrutura completa de modulo, nao so o aggregate.
- **Composition root** (`src/interface/cli.ts`, `src/index.ts` ou equivalente) **nao roteia para os BCs novos criados** (sem dispatch por prefixo `<bc>:`) — DESVIO; ou rotear os comandos novos, ou declarar WIP.
- **Refatoracao declarada concluida com 2+ itens da checklist objetiva falhando** (modulo original ainda gordo, BCs novos vazios, composition root sem novas rotas, sem suite por BC, sem migracao de dados) e SEM secao WIP/Pendente explicita no resumo — DESVIO grave; nem refatoracao concluida nem WIP transparente.
- **shared-kernel inchado** com `application/`, `infrastructure/`, `interface/`, ou `domain/<state>.ts` definindo composto cross-BC — DESVIO grave; shared-kernel so pode conter `value-objects/` + opcionalmente `errors.ts`/`event-types.ts`.
- **Repositorio concreto de BC e classe vazia herdando do shared-kernel** (`class JsonXRepository extends JsonSharedRepository {}`) — DESVIO grave; cada BC implementa seu repositorio diretamente.
- **Port de repositorio de um BC retorna state composto cross-BC** (ex.: `TenantStateRepository.load(): Promise<ProjectManagementState>`) em vez de `<BC>State` proprio — DESVIO grave; cada BC carrega/persiste so o seu state.
- **Composite type `<X>Aggregate & { children: ... }`** definido fora do aggregate root, com `as <X>` apos `<X>Aggregate.create(...)` para "ganhar" o campo de filhos — DESVIO; a colecao mora dentro do root, manipulada por metodos do root.
- **Use case de um BC importa helper `findX`/`getX`/`loadX` do shared-kernel** que retorna aggregate de outro BC — DESVIO; cross-BC e via porta com DTO proprio, nao via objeto vivo de state compartilhado.
- **Composite type cross-BC declarado em qualquer modulo** (`type Tenant = TenantAggregate & { clients: Record<...> }`, `type State = { tenants: ... }` com aggregates de varios BCs) — DESVIO grave independente do modulo onde foi declarado. Renomear o monolito de `shared-kernel/` para `project-management/`, `core/`, `common/`, `state/` ou qualquer outro NAO resolve. Composite cross-BC e proibido em todo o repositorio.
- **"Modulo" sem aggregates proprios nem use cases proprios** (so tem `domain/<state>.ts` com composite, `application/<helpers>.ts` com `findX`, `application/ports/<state>-repository.ts` retornando composto, `infrastructure/<single-repo>.ts` persistindo tudo, e `interface/<messages>.ts` unificado) — DESVIO grave: e monolito disfarcado, nao bounded context. BC legitimo precisa ter aggregates proprios + use cases proprios + adapters reais + tests proprios.
- **Adapter concreto que delega 100% das operacoes para outro repositorio** (`class JsonXRepository implements XRepository { private readonly other; load() { return this.other.load(); } save(s) { return this.other.save(s); } }`) — DESVIO grave: e o mesmo wrapper de `extends ...{}` agora cosmetico. Adapter implementa load/save lendo/gravando seu proprio sub-state.

## Resposta Final

- **Obrigatorio em TODA resposta de fim de tarefa**: incluir secao **"Revisao de aderencia"** com (a) status item-a-item da checklist objetiva de 9 itens com ❌/✅ explicitos, (b) lista de DESVIOs desta mudanca corrigidos, (c) lista de debito herdado visivel quando em extensao. Esta secao precede qualquer frase de conclusao no resumo.
- **Frases proibidas se a secao "Revisao de aderencia" mostra 2+ itens ❌**: "concluido", "completo", "feito", "pronto", "the refactoring is complete", "all done", "task pronta", e equivalentes. Use **"Refatoracao em andamento (WIP)"** com o formato da secao de WIP. Declarar conclusao com 2+ vermelhos sem WIP = DESVIO grave anulando todo o credito do trabalho feito.
- Se a checklist mostra **0-1 itens vermelhos**, voce pode declarar conclusao com a frase apropriada APOS apresentar a tabela com 8-9 verdes.
- Se sobrou DESVIO nao corrigido (qualquer numero), declare a razao concreta e classifique como (a) impossivel no escopo, (b) decisao explicita do usuario, ou (c) WIP intencional.

### Auto-verificacao antes de enviar a resposta

Antes de submeter o resumo final, releia:

1. A resposta tem a secao "Revisao de aderencia" com status ❌/✅ dos 9 itens? Se nao, **VOLTE** e adicione.
2. Conte os itens ❌. Se 2+, a resposta usa frase de conclusao ("concluido", "complete", etc.)? Se sim, **VOLTE** e troque por WIP transparente.
3. Toda frase de conclusao na resposta corresponde a estado de checklist com 0-1 vermelhos? Se nao, **VOLTE** e corrija.

## Checklist da skill

- Os pontos da secao "Pontos a verificar" foram avaliados contra o codigo produzido.
- Em extensao, a checklist foi aplicada SEPARADAMENTE a cada modulo novo criado (e2e propria, README proprio, cobertura propria, etc.) — sem isencoes herdadas do modulo existente.
- Todo desvio desta mudanca foi corrigido ou justificado.
- Em extensao, debito herdado visivel na area tocada foi reportado em secao separada (nao confundido com DESVIO desta mudanca).
- Lint, format e testes foram re-executados apos as correcoes.
- O usuario recebeu o resultado da revisao antes do resumo final, com secoes claras: DESVIOs corrigidos vs debito herdado.
