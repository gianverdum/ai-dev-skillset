---
name: naming-structure-php
description: Padrão de nomenclatura, estrutura e ambiente para projetos PHP quando não houver convenção local mais específica. Use quando criar/alterar projeto PHP, APIs Laravel/Symfony, bibliotecas, CLIs ou módulos web. Palavras-gatilho: "PHP", "Laravel", "Symfony", "Composer", "PHPUnit", "Pest", "composer.json", `.php`. Garante: `PascalCase` para classes/interfaces/traits/enums, `camelCase` para métodos/funções/variáveis, `UPPER_SNAKE_CASE` para constantes; namespaces PSR-4; layout `src/`+`tests/<Tipo>/<Namespace>`; testes com sufixo `Test`; PHP_CodeSniffer (PSR-12) + PHP-CS-Fixer (ou Laravel Pint em Laravel); nome de namespace reflete domínio (sufixos `Cli`/`Api`/`Rest` só em pacotes de entrega).
---

# PHP Naming And Structure

Use esta rule ao criar ou reorganizar projetos PHP, APIs, bibliotecas, CLIs ou modulos web.

## Precedencia

- Preserve a convencao ja existente no repositorio.
- Siga o framework quando ele definir estrutura, como Laravel, Symfony ou Laminas.
- Na ausencia de padrao local ou framework, aplique esta rule.

## Nomenclatura

- Use `PascalCase` para classes, interfaces, traits e enums.
- Use `camelCase` para metodos, funcoes e variaveis.
- Use `UPPER_SNAKE_CASE` para constantes.
- Use namespaces PSR-4 coerentes com `composer.json`.
- Nomes de namespace e de pacote refletem o DOMINIO, nao a interface implementada. Sufixos como `Cli`, `Api`, `Web`, `Rest` NAO entram no namespace de dominio; aparecem apenas no nome publicado em `composer.json` ou em pacotes de entrega separados.
- Use nomes de arquivos iguais ao nome da classe quando usar autoload PSR-4.
- Nomeie testes com sufixo `Test`.

## Estrutura

- Use `src/` para codigo de producao quando nao houver framework com layout proprio.
- Use `tests/` para testes automatizados. Dentro de `tests/`, agrupe por tipo em subpastas (`tests/Unit/`, `tests/Integration/`, `tests/Feature/`, `tests/E2E/`) e espelhe a estrutura de `src/` dentro de cada uma: o teste de `src/<Namespace>/<Classe>.php` vai para `tests/<Tipo>/<Namespace>/<Classe>Test.php`.
- Mantenha `composer.json` e `composer.lock` na raiz do pacote.
- Separe dominio e casos de uso de controllers, commands, ORM, filas e clients externos.
- Em Laravel ou Symfony, respeite a estrutura do framework e isole regras de negocio fora de controllers.

## Ambiente

- Use Composer para dependencias.
- Valide com o runner de testes configurado, normalmente PHPUnit ou Pest.
- Nao dependa de pacotes globais quando o projeto puder declarar ferramentas em `composer.json`.
- Linter/formatter padrao: `PHP_CodeSniffer` (`phpcs`) com regra `PSR-12` para lint de estilo, e `PHP-CS-Fixer` para formatacao automatica. Alternativa moderna: `Laravel Pint` (em projetos Laravel) ou `phpcbf` para correcao. Em projeto novo, instale ao menos um pelo Composer (`composer require --dev squizlabs/php_codesniffer friendsofphp/php-cs-fixer`) e declare scripts `lint`/`format` em `composer.json`.
