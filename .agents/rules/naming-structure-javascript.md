---
name: naming-structure-javascript
description: Padrão de nomenclatura, estrutura e ambiente para projetos JavaScript (Node.js, frontend ou bibliotecas) quando não houver convenção local mais específica. Use quando criar/alterar projeto JS, módulos, componentes React/Vue, APIs ou CLIs. Palavras-gatilho: "JavaScript", "JS", "yarn", "pnpm", "npm", "Node.js", "eslint", "biome", "jest", "vitest", `.js`, `.jsx`. Garante: `camelCase` para variáveis/funções, `PascalCase` para classes/componentes React, arquivos `kebab-case.js`; `yarn` como default em projeto novo; `engines.node` + `.nvmrc` declarados; última versão estável de Node; ESLint OU Biome como linter real; tests unitários colocalizados; `tests/<tipo>/<espelho>` para integration/e2e; nome do pacote reflete domínio (sufixo só em `package.json name`).
---

# JavaScript Naming And Structure

Use esta rule ao criar ou reorganizar projetos JavaScript em Node.js, frontend ou bibliotecas.

## Precedencia

- Preserve a convencao ja existente no repositorio.
- Siga o framework quando ele definir estrutura, como Next.js, Express, NestJS, Vite ou React.
- Na ausencia de padrao local ou framework, aplique esta rule.

## Nomenclatura

- Use `camelCase` para variaveis, funcoes e metodos.
- Use `PascalCase` para classes, construtores e componentes React.
- Use `UPPER_SNAKE_CASE` para constantes globais imutaveis.
- Use arquivos em `kebab-case.js` para modulos comuns.
- Use `PascalCase.jsx` para componentes React quando o projeto ja diferenciar componentes por nome de arquivo.
- Nomeie testes como `<nome>.test.js` ou `<nome>.spec.js`, seguindo o padrao ja usado.
- Evite nomes genericos como `utils`, `helpers` e `common` quando houver um nome de dominio ou responsabilidade mais especifico.
- O nome do pacote (`package.json name`) e o nome do diretorio do modulo refletem o DOMINIO, nao a interface implementada. Sufixos como `-cli`, `-api`, `-web`, `-server`, `-client` NAO entram no nome do modulo logico; aparecem apenas no nome publicado quando precisar distinguir entregas.

## Estrutura

- Prefira codigo de producao em `src/`.
- Separe responsabilidades por dominio ou feature quando o projeto crescer; nao concentre toda logica em `index.js`.
- Para Node.js, mantenha entrada externa em `src/index.js`, `src/server.js` ou `src/cli.js` conforme o tipo de aplicacao.
- Para frontend, siga o roteador/framework adotado e mantenha componentes reutilizaveis fora de paginas/rotas quando aplicavel.
- Para testes unitarios, prefira colocalizado (`foo.test.js` ao lado de `foo.js`) como default moderno; e o padrao de Vitest, Jest e dos ecossistemas Node, React e Next atuais. Use `__tests__/` ou `tests/` na raiz quando o projeto ja usar esse padrao ou quando a ferramenta exigir.
- Reserve `tests/` no mesmo nivel de `src/` para testes de integracao, contrato, ponta a ponta e fixtures compartilhadas, mesmo quando os unitarios estiverem colocalizados. Dentro de `tests/`, agrupe por tipo em subpastas (`tests/integration/`, `tests/contract/`, `tests/e2e/`) e espelhe a estrutura de `src/` dentro de cada uma.
- Mantenha `package.json` e lockfile na raiz do pacote.

## Ambiente

- Preserve o gerenciador ja presente no projeto (npm, pnpm, bun, yarn). Quando o projeto nao tiver gerenciador definido ou estiver sendo criado do zero, use `yarn` como padrao e versione o `yarn.lock`. Use outro gerenciador apenas quando `yarn` for inviavel: requisito explicito do framework ou plugin (ex.: ferramenta que so suporta `pnpm`/`npm`), restricao de infraestrutura de build, ou diretriz de monorepo ja adotada. Registre o motivo na resposta final quando trocar de `yarn` para outro.
- Use a ultima versao estavel do Node.js ao iniciar um projeto novo ou definir runtime, exceto quando o projeto fixar outra versao em `package.json engines.node`, `.nvmrc`, `.tool-versions` ou em configuracao de plataforma (Docker, CI, Vercel, etc.). Preserve a versao declarada e nao force atualizacao fora de escopo.
- Ao criar um projeto novo do zero, DECLARE explicitamente a versao do runtime em pelo menos um arquivo de toolchain: `package.json engines.node` (preferido para travar instalacao via gerenciador) e/ou `.nvmrc`/`.tool-versions`. Nao deixe a versao implicita — projetos novos sem versao declarada sao tratados como entrega incompleta. Exemplo: `"engines": { "node": ">=22.0.0" }` em `package.json` mais `.nvmrc` com `22` na raiz.
- Mantenha um unico lockfile correspondente ao gerenciador escolhido (`yarn.lock` em `yarn`).
- Declare scripts de `lint`, `format`, `test` e `build` em `package.json` quando essas ferramentas existirem; execute-os via `yarn <script>` quando o gerenciador for `yarn`.
- Linter padrao: `ESLint`. Alternativa moderna: `Biome` (cobre lint + format em uma ferramenta). Em projeto novo, instale ESLint OU Biome; nao deixe o projeto sem linter. O script `lint` deve invocar a ferramenta real, nao ser alias de outro comando.
- Formatter padrao: `Prettier` quando o linter for ESLint, ou `biome format` quando o linter for Biome. Declare script `format` em `package.json`.
