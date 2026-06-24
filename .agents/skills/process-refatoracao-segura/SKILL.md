---
name: process-refatoracao-segura
description: Refatorar codigo legado (modulo monolitico, reorganizacao estrutural, split de bounded contexts, extracao de aggregates) com rede de testes e passos pequenos. Use quando o pedido envolver "refatore", "reorganize", "separe em modulos", "extraia em bounded contexts", "transforme em DDD" ou similar sobre codigo ja escrito e em uso. Garante que comportamento seja preservado, dados persistidos nao sejam perdidos silenciosamente, e a suite de testes permaneca verde durante toda a transformacao.
---

# Refatoracao Segura

Refatoracao estrutural grande quebra comportamento em silencio quando feita sem disciplina. Use esta skill sempre que a tarefa for reorganizar codigo existente sem mudar comportamento externo.

## Definicao

- **Refatoracao** = mudar estrutura mantendo comportamento externo identico. Suite de testes continua passando, comandos externos continuam funcionando.
- **Feature** = mudar comportamento externo. Suite muda, novas operacoes existem.
- **NUNCA misture os dois na mesma tarefa.** Refatoracao primeiro, feature depois (ou vice-versa) — nunca juntos. Se misturar, ninguem consegue dizer onde quebrou.

## Fluxo obrigatorio

### 1. Mapear comportamento atual

Antes de tocar codigo, liste em uma resposta curta:

- Quais comandos/operacoes externas existem hoje? (CLI commands, API endpoints, eventos publicados, exports da biblioteca).
- Quais arquivos/dados persistidos existem? (`.json`, banco, cache, queues).
- O que NAO pode mudar de fora pra dentro nesta refatoracao? (contratos publicos).
- O que **pode** mudar como subproduto aceitavel? (estrutura interna, nomes de arquivo, schema interno de classes).

Sem essa lista, voce nao sabe o que precisa preservar.

### 2. Garantir characterization tests

Para cada comando/operacao externa identificado no passo 1, verifique se existe teste e2e que captura o comportamento atual ponta a ponta. Se nao existir, **ESCREVA antes** de comecar a refatoracao.

Esse teste fixa o que o sistema faz **agora** (caracteriza o comportamento), independente de estar certo ou bonito. E rede de seguranca, nao especificacao ideal. Quando voce mudar a estrutura, ele garante que o comportamento ainda existe.

Sem characterization tests, refatoracao vira reescrita.

### 3. Definir e validar o destino

Documente em 2-3 linhas o estado final pretendido:

> "src/project-management vira src/{tenancy,access,project-management,billing} com bounded contexts separados. CLI mantem todos os comandos atuais com mesma assinatura. Estado persistido migra automaticamente na primeira leitura."

Quando ha 3-4 particoes validas (ex.: quantos BCs?), **critique antes de programar**. Vale revisar com o usuario antes de gastar horas numa direcao errada.

### 4. Refatorar em passos pequenos verdes

Cada passo:

- Faz **uma** transformacao isolada (mover arquivo, extrair tipo, renomear, criar VO).
- Roda `yarn test` (ou equivalente da stack) ao final.
- So vai para commit quando esta verde.
- Se ficar vermelho, **reverte ou conserta antes** do proximo passo.

Passos grandes com teste no final escondem qual passo quebrou. Faca o ciclo ser pequeno.

Ordem tipica de uma extracao de BC:

1. Criar VOs de identidade (`TaskId`, `UserId`, `TenantId`) sem mexer em mais nada.
2. Substituir `string` por VOs onde aparecem identidades. Teste verde.
3. Identificar Aggregate Root em cada candidato a BC. Marcar (ex.: classe `Project` com metodos publicos, `Task` so mutavel via `Project`). Teste verde.
4. Mover arquivos para o novo modulo, ajustar imports. Teste verde.
5. Quebrar dependencias cruzadas: criar port no BC que precisa e implementar como adapter no outro. Teste verde.
6. Adicionar tests proprios do BC novo (unit + integration + e2e). Teste verde.
7. Remover codigo morto do BC antigo. Teste verde.

### 5. Strangler quando aplicavel

Em refatoracao muito grande, mantenha o codigo antigo em paralelo enquanto o novo cresce. O adapter de entrada (CLI/HTTP/etc.) roteia gradualmente para o novo. Quando o novo cobrir tudo, remove o velho.

Vale especialmente quando:

- A refatoracao leva multiplos dias.
- O codigo esta em uso e nao pode quebrar.
- Voce nao tem certeza absoluta da particao certa e quer ver o novo funcionar antes de comprometer.

**Regra do strangler:** entrega final NAO pode ter duplicacao semantica entre estrutura nova e legado preservado. Ou (a) a refatoracao foi concluida e o legado removido, ou (b) a entrega foi explicitamente marcada como WIP com checkpoint registrado na resposta final ("strangler em andamento: BC X migrado, BC Y ainda no legado, proximo passo = ..."). Entregar arquivos novos paralelos ao legado intacto, sem checkpoint, configura refatoracao **nao concluida** — DESVIO.

Sintomas de refatoracao incompleta entregue como completa:
- `model.ts`, `lifecycle.ts`, `permissions.ts` legados continuam com toda a logica original.
- Service monolitico cresceu ou ficou igual (em vez de ser quebrado).
- Aggregates "novos" sao chamados PELOS arquivos legados (legado orquestra o novo).
- "Aggregates" novos sao type/record vazio que so duplicam parte do tipo legado.
- Imports do novo formato co-existem com imports do antigo no mesmo arquivo.

Se um desses sintomas aparecer e a refatoracao foi declarada concluida, o agente nao terminou.

### 6. Migracao de dados persistidos

Se o schema do estado persistido (`.json`, banco, cache) muda, **DECIDA E DOCUMENTE** antes:

- **Quebrar e reinicializar**: schema novo, dados antigos viram lixo. Aceitavel em dev, prototipo, projeto sem usuarios. Inaceitavel em producao.
- **Migrar com script**: script standalone que le formato antigo e grava novo. Roda manualmente uma vez.
- **Migrar na leitura** (preferido em CLIs/apps locais): o `load()` detecta versao antiga e converte automaticamente, persistindo no formato novo no proximo `save()`. Inclua versao no proprio arquivo (`{ "version": 2, ... }`) para suportar futuras migracoes.

Sem decisao explicita registrada, o agente NAO comecou a refatoracao.

### 7. Verificacao objetiva de conclusao

Antes de declarar refatoracao concluida, rode esta checklist OBJETIVA. Se qualquer item falhar, ou a refatoracao continua, ou a entrega vira WIP com checkpoint registrado. **Sem espaco para julgamento.**

#### Quando a refatoracao move logica do modulo original para BCs novos

1. **Modulo original esta substancialmente reduzido ou removido.** Se `src/<modulo-original>/` ainda contem lifecycle, service monolitico, casos de uso de negocio, repositorio principal OU CLI completa, refatoracao **nao concluida**. Regra de polegar: o modulo original deveria ter no maximo ~30% das linhas que tinha antes (idealmente: removido).

2. **Cada BC novo tem estrutura completa de modulo**, nao apenas `aggregates/`. Pasta minima por BC novo populada:
   - `domain/` (entities nao-root, errors, services)
   - `aggregates/<aggregate>.ts` (se ha aggregates)
   - `value-objects/<vo>.ts` (se ha VOs proprios)
   - `application/use-cases/<use-case>.ts` (casos de uso)
   - `application/ports/<port>.ts` (portas declaradas)
   - `infrastructure/<adapter>.ts` (repositorios, clients)
   - `interface/cli.ts` (ou `adapters/in/` em Hex)
   - `README.md` com responsabilidade real
   - Tests proprios (unit + integration + e2e quando aplicavel)

   BC novo com apenas `aggregates/<aggregate>.ts` e o resto vazio = **casca vazia**. WIP, nao concluido.

3. **Composition root roteia para os BCs novos.** Em CLI: dispatcher por prefixo (`tenancy:`, `client-management:`, `billing:`, etc.) chamando o `interface/cli.ts` de cada BC. Em HTTP: rotas dedicadas por BC. Se o root continua chamando so o modulo original, refatoracao **nao concluida**.

4. **Cada BC novo tem suite de testes propria.** Unit dos aggregates/VOs + integration dos adapters + e2e (4 cenarios quando aplicavel: happy + permission_denied + not_found + invalid_input). Testes que ainda exercitam o codigo legado do modulo original NAO contam para o novo BC.

5. **Migracao de dados decidida E implementada.** Se o store antigo do modulo original continua sendo o unico que persiste estado, e os BCs novos nao tem persistencia propria, dados nao foram migrados — refatoracao **nao concluida**.

6. **Isolamento de estado real entre BCs**, nao cosmetico. Cada BC tem:
   - Port de repositorio retornando `<BC>State` proprio (NAO `WholeState` composto cross-BC).
   - Adapter concreto implementando o repositorio diretamente (NAO `class JsonXRepository extends JsonSharedRepository {}` vazia).
   - Schema persistido proprio (arquivo/tabela/colecao) ou sub-arvore versionada quando arquivo unico.
   Se os "BCs novos" sao fachadas sobre o mesmo store compartilhado, com repositorios vazios herdando do shared-kernel, refatoracao **nao concluida** — monolito foi renomeado, nao quebrado.

7. **shared-kernel dentro do limite**: apenas `value-objects/` + opcionalmente `errors.ts`/`event-types.ts`. Se shared-kernel ganhou `application/`, `infrastructure/`, `interface/` ou `domain/<state>.ts` com composto cross-BC, o monolito foi migrado para shared-kernel — refatoracao **nao concluida**.

8. **Nenhum modulo do repositorio (independente do nome) define composite cross-BC** ou contem o padrao "state composto + helpers + repositorio unico" sem aggregates/use cases proprios. Se existe `src/<qualquer>/domain/<state>.ts` definindo `Tenant = TenantAggregate & { clients }` ou `ProjectManagementState` composto, OU `src/<qualquer>/application/<state>.ts` com helpers `findX`/`getX` percorrendo aggregates de varios BCs, OU um "modulo" que tem application/infrastructure/interface mas NAO tem aggregates/ nem use-cases/ — o monolito so foi renomeado. Refatoracao **nao concluida**.

9. **Repositorios concretos implementam load/save lendo/gravando seu proprio sub-state**, nao delegando 100% a outro repositorio. `class JsonXRepository implements XRepository { private readonly other; load() { return this.other.load(); } save(s) { return this.other.save(s); } }` e wrapper cosmetico, equivalente a `extends ...{}`. Refatoracao **nao concluida** enquanto repositorios sao delegadores vazios.

Se **2 ou mais itens falham**, foi extracao parcial, nao refatoracao concluida. Declarar "concluido" nesse estado = DESVIO grave.

#### Saida quando refatoracao nao esta concluida

- **Opcao A — concluir:** continue movendo logica ate todos os itens da checklist passarem.
- **Opcao B — checkpoint WIP explicito:** declare na resposta final exatamente o que foi feito e o que falta. Formato obrigatorio:

```markdown
## Refatoracao em andamento (WIP)

### Feito
- Aggregates extraidos para `src/<bc>/aggregates/`
- VOs de identidade movidos para `src/shared-kernel/value-objects/`
- ...

### Pendente
- Mover casos de uso (`createTenant`, `createClient`, ...) de `src/<original>/application/<service>.ts` para `src/<bc>/application/use-cases/`
- Mover persistencia de `src/<original>/infrastructure/` para `src/<bc>/infrastructure/`
- Quebrar `src/<original>/interface/cli.ts` em CLIs por BC
- Atualizar composition root (`src/interface/cli.ts`) para rotear por prefixo de BC
- Decidir e implementar migracao de dados persistidos
- Remover `src/<original>/` apos migracao completa
- ...

### Decisoes pendentes para proxima sessao
- ...
```

Sem WIP explicito + 2+ itens da checklist objetiva falhando = DESVIO grave.

### 8. Revisar com `quality-revisao-aderencia`

Ao final, aplique a checklist completa. Em refatoracao com extracao de BC, **cada modulo extraido conta como modulo novo**: precisa de README proprio, suite e2e propria (4 cenarios minimos quando aplicavel), cobertura propria, literal unions proprias, etc. Veja a regra de extensao na skill de revisao.

## Anti-padroes

- **Refatorar sem testes verdes na base.** Se a suite ja esta vermelha, a rede nao funciona. Conserte ou registre bloqueio antes de mexer em estrutura.
- **Passo grande com teste no final.** Mover 20 arquivos e rodar testes uma vez impede de saber qual passo quebrou.
- **Apagar testes que "nao se aplicam mais".** Antes de apagar, migre o teste para o novo lugar/forma. Apagar e abrir mao da rede.
- **Refatorar e adicionar feature ao mesmo tempo.** Refatoracao mantem comportamento. Feature muda. Misturar = nao da pra dizer onde quebrou.
- **Mudar schema persistido sem migracao.** Em projeto com dados em uso, schema novo sem migracao = perda silenciosa.
- **Decidir particao no meio da refatoracao.** "Vou ver quantos BCs vai virar" e receita de retrabalho. Defina antes; critique antes de mover arquivos.
- **Importar do BC antigo no novo "so para acelerar".** Cria divida que nunca paga.

## Resposta Final

- Liste os comandos/operacoes externas que continuam funcionando (validados pelos characterization tests).
- Liste o que mudou na estrutura interna.
- Se houve migracao de dados, descreva o protocolo e como ela foi testada (idealmente um test que carrega um JSON antigo e verifica que vira o novo).
- Reporte o resultado de `quality-revisao-aderencia` separado por modulo extraido.

### Proibicao de frases de fechamento sem checklist

NUNCA escreva no resumo final qualquer das frases abaixo sem ter rodado a checklist objetiva de 9 itens E ter resultado de 7+ verdes:

- "Refatoracao concluida" / "The refactoring is complete" / "Refactor done"
- "Concluido" / "Completo" / "Pronto" / "Feito" / "Terminei" / "Finalizado"
- "All checks pass" / "Tudo certo" / "Tudo passou" / "Lint clean, tests pass" (como sinonimo de conclusao da tarefa)
- "Clean. All N tests pass, lint is clear, TypeScript compiles. The refactoring is complete." (frases que misturam validacao de build com declaracao de conclusao da refatoracao)

Build verde + lint verde + tests verdes **nao** implica refatoracao concluida. Refatoracao concluida = checklist objetiva com 7+ itens verdes E ausencia dos anti-padroes listados em `quality-revisao-aderencia` (especialmente: composite cross-BC, monolito disfarcado, delegacao 100% em repositorios, missing tests por BC, isolamento de estado falso).

Se a checklist tem 2+ itens vermelhos, o resumo final usa o formato **"Refatoracao em andamento (WIP)"** com status item-a-item, secao "Feito", secao "Pendente", secao "Decisoes pendentes". Sem excecao.

## Checklist

- Comportamento atual mapeado (lista de operacoes externas e dados persistidos).
- Characterization tests existem e passam antes de comecar.
- Destino documentado em 2-3 linhas; alternativas criticadas quando havia mais de uma.
- Refatoracao feita em passos pequenos, suite verde a cada passo.
- Migracao de dados (se aplicavel) decidida, implementada e testada.
- **Verificacao objetiva de conclusao executada** (9 itens da secao 7); zero ou um item falhando aceitavel, dois ou mais exige WIP explicito com checkpoint.
- Modulo original removido OU reduzido a ~30% do tamanho original OU declarado WIP no resumo.
- Cada BC novo tem `domain/`+`application/use-cases/`+`infrastructure/`+`interface/`+`README.md`+testes proprios — nao basta `aggregates/`.
- Composition root roteia para todos os BCs novos por prefixo de comando.
- `quality-revisao-aderencia` rodado ao final, com checklist por modulo extraido.
- Refatoracao e feature NAO misturadas na mesma tarefa.
