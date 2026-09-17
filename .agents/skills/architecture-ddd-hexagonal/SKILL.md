---
name: architecture-ddd-hexagonal
description: 'Desenvolvimento e edição de software seguindo DDD com Arquitetura Hexagonal (Ports & Adapters). Use quando o projeto existente já adotar layout hexagonal (`adapters/in`+`adapters/out`, `ports/`), quando o usuário pedir explicitamente "hexagonal"/"ports and adapters"/"hex arch", ou quando a tarefa exigir múltiplos adapters de entrada/saída sobre o mesmo domínio. Palavras-gatilho: "hexagonal", "ports and adapters", "hex", "hex arch", "adapter in", "adapter out", "driving adapter", "driven adapter". Garante: `domain`/`application` (com `ports/` e `use-cases/`)/`adapters/in`/`adapters/out`/`config` (composition root); aggregate root como classe; VOs branded; cross-BC via porta + DTO próprio. Na ausência de preferência local ou pedido explícito por hex, prefira a skill `architecture-ddd-clean-arch`. Sem essas fronteiras, módulo perde isolamento ports/adapters — DESVIO.'
---

# DDD + Arquitetura Hexagonal (Ports & Adapters)

Use esta skill quando a arquitetura hexagonal for o padrao do projeto ou solicitada pelo usuario.

## Precedencia entre Hexagonal e Clean Architecture

A escolha NAO e por preferencia do agente. Siga esta ordem:

1. **Padrao do projeto existente** — se o repositorio ja tem layout hexagonal (`ports/`, `adapters/in`, `adapters/out`, `adapters/driving`, `adapters/driven`, ou nomenclatura equivalente), preserve. Mesma logica vale para Clean Arch (`interface/`, `application/`, `infrastructure/`): preserve o que esta la.
2. **Solicitacao do usuario** — quando o usuario pedir "hexagonal", "ports and adapters", "hex arch", aplique esta skill. Quando pedir "clean architecture", aplique `architecture-ddd-clean-arch`.
3. **Default** — na ausencia de padrao local e de pedido explicito, use `architecture-ddd-clean-arch`.

Nunca misture os dois layouts no mesmo modulo. Se uma das skills ja esta em uso, a outra nao se aplica naquele modulo.

## Principios

- Preserve o dominio como centro da aplicacao, livre de framework, banco, HTTP, fila, UI ou serviços externos.
- Modele dependencias para o dominio atraves de **portas** (interfaces declaradas pelo dominio/aplicacao); detalhes tecnicos vivem em **adapters** que implementam essas portas.
- Distinga **portas de entrada (driving / inbound)** — invocadas por adapters de fora chamando o dominio — de **portas de saida (driven / outbound)** — chamadas pelo dominio quando ele precisa de algo externo.
- Casos de uso sao exposicoes da port de entrada; repositorios, gateways e clients sao definicoes da port de saida.
- Tipos de entrada do dominio expressam invariantes (literal union, enum, typed alias), nao `string`/`int` cru.

## Camadas e Layout

- `domain/`: entidades, value objects, domain services, eventos, regras e invariantes. Define portas de saida quando o dominio precisar de algo externo (ex.: `ExchangeRateProvider`).
- `application/`: casos de uso (portas de entrada) e orquestracao. Pode declarar portas adicionais para servicos transversais (autorizacao, transacao, clock).
- `adapters/in/` (ou `adapters/driving/`, `inbound/`): tudo que invoca o nucleo de fora — controllers HTTP, handlers CLI, consumers de fila, workers de cron, GraphQL resolvers. Cada adapter de entrada DELEGA para uma porta de entrada da aplicacao.
- `adapters/out/` (ou `adapters/driven/`, `outbound/`): implementacoes concretas das portas de saida — repositorios SQL/NoSQL, HTTP clients, brokers, file system, providers externos.
- `config/` (opcional): composition root, wiring de portas a adapters, leitura de configuracao.

Layout tipico em `src/<modulo>/`:

```
src/payments/
  domain/
    invoice-events.ts                # eventos de dominio
    ports/payment-gateway.ts         # porta de saida
  aggregates/
    invoice.ts                       # aggregate root (classe com metodos)
  value-objects/
    money.ts
    invoice-number.ts
  application/
    use-cases/charge-invoice.ts      # caso de uso
    ports/                            # portas adicionais (clock, ids)
  adapters/
    in/
      http/charge-controller.ts
      cli/charge-command.ts
    out/
      stripe-payment-gateway.ts      # implementa domain/ports/payment-gateway
      postgres-invoice-repository.ts
  config/
    container.ts

src/shared-kernel/                   # raiz, fora de qualquer BC
  value-objects/
    tenant-id.ts
    user-id.ts
```

`aggregates/` e `value-objects/` ficam **no mesmo nivel de `domain/`**, NAO dentro dele. VOs de identidade compartilhados entre BCs vivem em `src/shared-kernel/value-objects/` na raiz, nunca dentro de outro modulo.

Em stacks com layout idiomatico proprio (Java `src/main/java`, Go `cmd/`+`internal/`), use os subdiretorios equivalentes preservando a separacao `domain` / `aggregates` / `value-objects` / `application` / `adapters in/out`.

## Fluxo

1. Identifique o bounded context ou modulo da mudanca.
2. Defina a porta de entrada (caso de uso) que expressa a intencao.
3. Modele as portas de saida que o dominio/aplicacao precisa (repositorio, gateway, clock, id-generator).
4. Implemente o dominio sem citar tecnologia externa.
5. Implemente o caso de uso na aplicacao, recebendo as portas via construtor ou injecao.
6. Crie o adapter de entrada (HTTP, CLI, fila) que parseia entrada e chama o caso de uso.
7. Crie os adapters de saida que implementam as portas declaradas no nucleo.
8. Wire portas a adapters no `config/` (composition root) ou no entrypoint.
9. Adicione testes na camada apropriada (ver secao Testes).

## Direcao das Dependencias

- `domain` nao importa `application`, nem `adapters/*`, nem `config`.
- `application` importa `domain` (incluindo portas de saida do dominio); pode declarar portas proprias.
- `adapters/in/*` importa `application` (caso de uso) e tipos publicos do dominio.
- `adapters/out/*` importa **interfaces de porta** do dominio/aplicacao e implementa-as; **nao** sao importados pelo dominio nem pela aplicacao — o wiring liga via composition root.
- `config/` importa todas as camadas para amarrar o grafo.

## Tipagem do Dominio e Codigos de Erro

- Conjuntos finitos no dominio sao expressos por tipo restrito (`Literal`, *literal union*, `enum`, `typed alias`), nao `string`/`int` cru. A validacao do conjunto acontece UMA VEZ, no adapter de entrada (ao construir o DTO do caso de uso).
- Dominio e aplicacao lancam erros com **codigo estavel em ingles snake_case** (`payment_declined`, `invoice_not_found`). Adapters de entrada resolvem o codigo para texto humano via dicionario/i18n.
- Veja `architecture-ddd-clean-arch` para os exemplos detalhados de tipagem do dominio (`Literal`/literal union/enum/typed alias) e do padrao codigo-de-erro -> mensagem humana; eles valem identicos aqui.

## Localizacao do Parsing

- Parsing de string textual (argv, JSON body, query string, formularios, AST) vive em `adapters/in/*`. Esse adapter monta o DTO/Request tipado e o entrega ao caso de uso.
- `application/use-cases/*` recebe DTO ja tipado. Nao tokeniza, nao faz `Number(text)`, nao `JSON.parse(body)`.
- Sinais de que parsing vazou: `tokenize`, `parseArgs`, `Number(text)`, `JSON.parse(body)` dentro de `application/*` ou `domain/*` -> mover para `adapters/in/*`.

## Testes

- Dominio: testes unitarios rapidos, sem infraestrutura.
- Casos de uso: testes com portas de saida substituidas por in-memory/fakes que implementam a mesma interface.
- Adapters de saida: testes de integracao com o recurso real (banco em container, fake server HTTP) quando o risco for parte da entrega.
- Adapters de entrada: testes de contrato (HTTP/CLI) chamando o adapter com o caso de uso fakeado, mais um teste de integracao de ponta a ponta quando o fluxo for critico.

## Modelagem Tatica: Aggregate, Entity, Value Object

A modelagem tatica (Aggregate Root, Entity, Value Object, primitive obsession, referencia cross-BC por ID e nao por objeto) e identica em Hexagonal e em Clean Arch. Veja a secao **"Modelagem Tatica"** completa em `architecture-ddd-clean-arch`, com os anti-padroes (primitive obsession, aggregate root ignorado, cross-BC por objeto, BCs como subpastas em domain/) e exemplos errado/certo. Em Hexagonal, a unica diferenca de layout e que VOs compartilhados de identidade entre BCs ficam tipicamente em `src/shared-kernel/value-objects/` na raiz, nao espalhados.

Tambem se aplicam identicamente em Hexagonal:

- **Restricoes do shared-kernel**: apenas `value-objects/` + `errors.ts`/`event-types.ts` opcionais. Sem `application/`, `infrastructure/`, `interface/`. Sem state composto cross-BC.
- **Isolamento de estado por BC**: cada BC tem seu proprio state, port de repositorio retornando `<BC>State` proprio, e schema persistido proprio (ou sub-arvore versionada quando arquivo unico). Repositorios concretos NAO podem ser `extends <outro-repo> {}` (classe vazia herdando) NEM `implements ... { delegate 100% }` (composicao vazia delegando tudo).
- **Aggregate Root e dono da colecao**: composite externo `XAggregate & { children }` definido fora do root e DESVIO.
- **Proibicao absoluta de composite cross-BC**: nenhum modulo do repositorio (independente do nome — `shared-kernel/`, `project-management/`, `core/`, `common/`, `state/`, etc.) pode definir tipo composto que liga aggregates de mais de um BC.
- **Modulo legitimo vs monolito disfarcado**: BC legitimo tem aggregates proprios + use cases proprios + adapters reais + tests proprios. "Modulo" sem aggregates, sem use cases, com state composto + helpers + repo unico = monolito renomeado.

Veja exemplos detalhados em `architecture-ddd-clean-arch`.

## Casos de Uso

Em Hexagonal a separacao de casos de uso em `application/use-cases/<use-case>.ts` (um arquivo por caso de uso) ja faz parte do layout idiomatico. O ponto critico continua valido: com **5+** casos de uso, manter um arquivo unico com varios use cases ou uma classe `Service` monolitica com 5+ metodos publicos e DESVIO. Veja o exemplo errado/certo em `architecture-ddd-clean-arch` (a forma OO usando classes de caso de uso ou a forma funcional com uma funcao por arquivo se aplicam identicamente aqui).

## Politicas (Permissoes, Estados, Regras Tabulares)

- Em Hexagonal a separacao de portas em `application/ports/<port>.ts` ja e regra estrutural do layout. O ponto critico aqui e o mesmo de Clean Arch: quando o dominio expoe **3+ funcoes `assertCan*` / `canDo*` / `mayAccess*`** que so diferem na lista de papeis ou estados aceitos, substitua por uma **policy table** — politica como DADO.
- Funcao `assertCan*` com corpo vazio (apenas `return;`) e DESVIO; ou remove ou absorve na policy table.
- Veja a secao "Politicas" em `architecture-ddd-clean-arch` para o bloco errado/certo completo. O exemplo se aplica identicamente aqui.

## Modulo vs Submodulo de Camada

Modulo (diretorio irmao em `src/`) representa um bounded context. Adapter de saida do proprio modulo (repositorio, cliente HTTP, broker, file system) vive em `adapters/out/` DENTRO do modulo dono, NUNCA como modulo irmao. Criterios detalhados em `workflow-iniciar-aplicacao`.

Vale tanto na criacao quanto na extensao do projeto. Em extensao, NAO injete bounded context novo dentro do modulo existente por inercia — reaplique os criterios e crie `src/<novo-modulo>/` quando aplicavel. O novo modulo consome o existente via porta (`adapters/out/<existente>-query.ts`).

Sinais de DESVIO:

- `src/<entidade>/` + `src/<entidade>-storage/` (ou `<entidade>-repository`, `<entidade>-client`) — storage do proprio modulo deveria estar em `src/<entidade>/adapters/out/`.
- `src/adapters/`, `src/storage/`, `src/persistence/` como modulo irmao do nucleo — camadas tecnicas globais nao sao bounded contexts; cada adapter pertence ao modulo cujo nucleo ele serve.
- Bounded context novo enxertado dentro de modulo existente em vez de viver em `src/<novo-modulo>/` irmao. Veja o exemplo completo errado/certo em `architecture-ddd-clean-arch` — o mesmo principio se aplica em Hexagonal (com a diferenca de que o adapter que faz a ponte vive em `adapters/out/` do novo modulo).

## Edicao de Codigo Existente

- Antes de alterar, identifique se o codigo esta em `domain`, `application`, `adapters/in` ou `adapters/out` e respeite as importacoes permitidas.
- Nao adicione import de adapter dentro de `domain`/`application`.
- Se a aplicacao precisa de novo recurso externo, declare uma porta de saida nova; nao chame o cliente HTTP/banco direto.
- Preserve contratos publicos das portas; alteracao quebra todos os adapters.

## Checklist

- O modulo segue layout hexagonal: `domain`, `application` (com casos de uso), `adapters/in`, `adapters/out` (ou equivalentes idiomaticos da stack).
- O dominio nao importa nada de `adapters/*` nem de framework/banco/HTTP/UI.
- Portas de saida estao declaradas no nucleo; implementacoes vivem em `adapters/out`.
- Adapters de entrada delegam para casos de uso; nao chamam o dominio direto.
- Tipos de entrada do dominio expressam invariantes (literal union/enum/typed alias), usados na assinatura, nao apenas exportados.
- Parsing textual fica em `adapters/in/*`; casos de uso recebem DTOs ja tipados.
- Dominio e aplicacao lancam codigos de erro estaveis em ingles; adapters de entrada resolvem para mensagens humanas.
- Composition root liga portas a adapters em um unico lugar.
- Testes cobrem dominio (unit), casos de uso (com fakes), adapters de entrada (contrato) e adapters de saida (integracao) na intensidade adequada.
