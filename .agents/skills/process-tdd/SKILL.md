---
name: process-tdd
description: OBRIGATORIO em qualquer tarefa que altera comportamento de software. Desenvolvimento guiado por testes (TDD) — teste primeiro, implementação depois. Use sempre que o agente for desenvolver, alterar, corrigir, refatorar ou estender software. Palavras-gatilho: "implemente", "crie", "adicione", "corrija", "refatore", "altere", "estenda", "feature", "bug", "fix", "regra", "validação", "cálculo", "use case". Garante: teste falhando antes da implementação, implementação mínima para passar, refator com suite verde, e2e obrigatório quando há persistência externa ou entrypoint executável. Sem ciclo Red-Green-Refactor seguido, mudança de comportamento foi feita sem rede de segurança — DESVIO.
---

# TDD

Todo desenvolvimento deve ser guiado por TDD.

## Regra Principal

- Antes de implementar ou alterar comportamento, escreva ou ajuste um teste que falhe pelo motivo esperado.
- Só escreva código de produção suficiente para fazer o teste passar.
- Depois que os testes passarem, refatore mantendo a suíte verde.

## Ciclo

1. Entenda o comportamento esperado.
2. Identifique o menor teste que demonstra esse comportamento.
3. Escreva o teste primeiro e execute para confirmar a falha.
4. Implemente a menor mudança suficiente para passar.
5. Execute os testes relevantes.
6. Refatore se necessário, mantendo os testes passando.
7. Repita o ciclo para o próximo comportamento.
8. Antes de encerrar a tarefa, rode lint e formatter conforme a skill `quality-lint-format` e corrija o que for apontado.
9. Como ultima etapa, rode a skill `quality-revisao-aderencia` para verificar que estrutura, tipagem do dominio, localizacao do parsing, codigos de erro e demais regras das skills/rules ativas estao respeitadas. Corrija desvios antes do resumo final.
10. **Antes de declarar a tarefa concluida** ("pronto", "completo", "feito", "concluded", "done", etc.), inclua no resumo final a secao "Revisao de aderencia" com status ❌/✅ item-a-item da checklist objetiva. Se 2+ itens vermelhos, NAO use frase de conclusao — use formato WIP transparente. Build verde + tests verdes + lint verde NAO implica conclusao da tarefa quando ha refatoracao estrutural pendente.

## Escopo dos Testes

- Prefira testes unitários para regras de negócio, validações, cálculos e decisões.
- Use testes de aplicação ou integração quando o risco estiver na orquestração, persistência, adapters, serialização ou contrato entre camadas.
- Use testes ponta a ponta apenas quando o comportamento depender do fluxo completo.
- Testes ponta a ponta sao OBRIGATORIOS quando o modulo persiste estado externo (arquivo, banco, fila, cache, broker, HTTP de saida) ou expoe entrypoint executavel (CLI, HTTP server, daemon, worker). Integration cobre o adapter contra o recurso; e2e cobre o fluxo completo cross-command/cross-request. Detalhes em `testing-coverage-quality`.
- Não substitua um teste simples e próximo do comportamento por um teste amplo e lento sem necessidade.
- Para CLI, teste parsing, saída, código de retorno e erros no adaptador de interface; testes em subprocesso são úteis, mas não devem ser a única cobertura da CLI quando a função de entrada pode ser chamada diretamente.
- Ao iniciar um módulo novo, crie a estrutura mínima de testes junto da estrutura de produção.
- A colocacao dos testes unitarios e definida pela rule da linguagem em `.agents/rules`: Go e Rust colocalizam; TypeScript e JavaScript preferem colocalizado; Python, Java, C# e PHP usam diretorio espelhado (`tests/`, `src/test/java`, projeto `*.Tests`). Siga a rule da linguagem em uso, nao um default unico.
- Use `tests/` no mesmo nivel de `src/` para testes de integracao, contrato, ponta a ponta, fixtures compartilhadas e suites que cruzam modulos, mesmo quando os unitarios ficam colocalizados.
- Quando testes ficarem dentro de `tests/` (unitarios em linguagens como Python/PHP, ou integracao/contrato/e2e em qualquer linguagem), agrupe-os primeiro pelo TIPO de teste em subpastas como `tests/unit/`, `tests/integration/`, `tests/contract/`, `tests/e2e/`, `tests/acceptance/`. Dentro de cada subpasta de tipo, espelhe a estrutura de pastas do codigo alvo: um teste de `src/<modulo>/<sub>/<arquivo>` vira `tests/<tipo>/<modulo>/<sub>/test_<arquivo>` (ajustando o sufixo ao idioma do framework). Vale para qualquer tipo de teste, nao so unitario.
- Excecoes por convencao da stack: em Java/Kotlin Maven/Gradle, a separacao de tipo e feita pelo sufixo do nome (`*Test` unitario, `*IT` integracao) sobre `src/test/java` espelhando `src/main/java`; em C#/.NET, a separacao e feita por projetos de teste distintos (`MyApp.UnitTests`, `MyApp.IntegrationTests`). Nesses casos, siga a convencao da stack em vez do agrupamento por subpasta de tipo.
- Quando houver duvida sobre nomes e localizacao de testes, preserve o padrao local ja existente; na ausencia dele, siga a rule da linguagem.
- Se a stack exigir outro layout, siga a convenção da stack e registre a razão na resposta final.

## Código Existente

- Ao corrigir bug, escreva primeiro um teste que reproduza o bug.
- Ao refatorar, garanta testes cobrindo o comportamento antes de mover ou simplificar código.
- Para refatoracao estrutural grande (reorganizar modulos, separar bounded contexts, extrair aggregates), carregue tambem a skill `process-refatoracao-segura`. Ela define o protocolo: characterization tests primeiro, passos pequenos verdes, migracao de dados decidida, refatoracao e feature nunca misturadas.
- Ao editar uma funcionalidade existente, ajuste ou adicione testes antes de mudar a implementação.
- Se não houver estrutura de testes, crie a menor estrutura compatível com o projeto.
- Se a ferramenta de teste necessária não existir no projeto, adicione-a como dependência de desenvolvimento pelo gerenciador da stack antes de tratar isso como bloqueio.
- Para Python, use `uv add --dev` para ferramentas de teste externas e execute a suíte com `uv run`; não use instalação global nem `pip install` direto.

## Exceções

Só prossiga sem escrever teste primeiro quando:

- a mudança for exclusivamente documental;
- a alteração for apenas formatação sem mudança de comportamento;
- não houver ambiente ou ferramenta de teste disponível, não for possível adicioná-la ao projeto no escopo do pedido e o bloqueio concreto tiver sido verificado;
- o usuário pedir explicitamente para não criar testes.

Quando houver exceção, registre a razão na resposta final.

## Checklist

- Existe um teste novo ou alterado para o comportamento desenvolvido.
- O teste falhou antes da implementação quando isso foi viável.
- A implementação contém apenas o necessário para passar o teste.
- Ferramentas de teste ausentes foram adicionadas ao projeto quando isso era necessário e viável.
- A estrutura de testes separa unitários próximos do código e testes amplos em `tests/`, salvo convenção explícita da stack.
- Os testes relevantes foram executados.
- A refatoração, se feita, manteve a suíte verde.
