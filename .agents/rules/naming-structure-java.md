---
name: naming-structure-java
description: Padrão de nomenclatura, estrutura e ambiente para projetos Java quando não houver convenção local mais específica. Use quando criar/alterar projeto Java, módulos Maven/Gradle, serviços Spring Boot, bibliotecas ou CLIs. Palavras-gatilho: "Java", "Maven", "Gradle", "Spring", "Spring Boot", "JUnit", "pom.xml", "build.gradle", `.java`. Garante: `PascalCase` para classes/records/enums/interfaces, `camelCase` para métodos/parâmetros, `UPPER_SNAKE_CASE` para `static final`; layout Maven/Gradle padrão (`src/main/java`, `src/test/java`); testes com sufixo `Test`/`IT`; Checkstyle + Spotless como linter/formatter; nome de pacote reflete domínio (sufixos `cli`/`api`/`rest` só em módulos de entrega como `payments-api`).
---

# Java Naming And Structure

Use esta rule ao criar ou reorganizar projetos Java, servicos, bibliotecas ou CLIs.

## Precedencia

- Preserve a convencao ja existente no repositorio.
- Siga o framework e a ferramenta de build quando definirem estrutura, como Spring Boot, Maven ou Gradle.
- Na ausencia de padrao local ou framework, aplique esta rule.

## Nomenclatura

- Use `PascalCase` para classes, records, enums e interfaces.
- Use `camelCase` para metodos, parametros, variaveis e campos.
- Use `UPPER_SNAKE_CASE` para constantes `static final`.
- Use pacotes em letras minusculas, sem hifens, normalmente em dominio reverso quando houver dominio organizacional.
- Use nomes de classes orientados a responsabilidade ou dominio, evitando sufixos genericos como `Manager`, `Helper` e `Util` salvo utilitarios realmente estaticos e transversais.
- Nomes de pacote e de modulo Maven/Gradle refletem o DOMINIO, nao a interface. Sufixos como `cli`, `api`, `web`, `rest` NAO entram no nome do pacote de dominio; aparecem apenas em modulos de entrega separados (ex.: modulo `payments-domain` e modulo `payments-api` no mesmo build) ou no artefato publicado.
- Nomeie testes com sufixo `Test` ou `IT`, conforme a suite.

## Estrutura

- Use layout Maven/Gradle padrao: `src/main/java`, `src/main/resources`, `src/test/java` e `src/test/resources`.
- Organize pacotes por dominio, feature ou bounded context antes de organizar apenas por tipo tecnico.
- Em Clean Architecture, mantenha dominio sem dependencias de framework e adapters em pacotes externos.
- Para Spring, mantenha controllers, configuration e persistence fora do pacote de dominio.
- Mantenha `pom.xml`, `build.gradle` ou `settings.gradle` na raiz do modulo.

## Ambiente

- Use Maven ou Gradle conforme o projeto existente.
- Se nao houver padrao, escolha uma ferramenta de build e declare comandos de teste e build.
- Linter/formatter padrao: `Checkstyle` (lint de estilo + convencoes) e `Spotless` com `google-java-format` (formatador automatico). Configure ambos via plugin Maven/Gradle e declare tasks de `lint`/`format` (`mvn checkstyle:check` + `mvn spotless:check`/`spotless:apply` ou equivalentes Gradle). Para analise estatica adicional, considere `SpotBugs` ou `Error Prone`. Em projeto novo, instale pelo menos um linter.
