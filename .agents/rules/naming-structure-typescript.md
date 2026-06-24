---
name: naming-structure-typescript
description: Padrão de nomenclatura, estrutura, tipagem e ambiente para projetos TypeScript quando não houver convenção local mais específica. Use quando criar/alterar projeto TS, módulos, componentes React/Vue, APIs, CLIs ou bibliotecas. Palavras-gatilho: "TypeScript", "TS", "yarn", "pnpm", "npm", "Node.js", "tsconfig", "eslint", "biome", "vitest", "jest", `.ts`, `.tsx`. Garante: `camelCase` para variáveis/funções, `PascalCase` para classes/tipos/componentes, arquivos `kebab-case.ts`; `yarn` como gerenciador default (não npm em projeto novo); `engines.node` + `.nvmrc` declarados; última versão estável de TS/Node; ESLint+typescript-eslint OU Biome (não só `tsc --noEmit` como lint); `strict: true` + `noUncheckedIndexedAccess` + `exactOptionalPropertyTypes` no tsconfig; tests unitários colocalizados (`foo.test.ts`); `tests/<tipo>/<espelho>` para integration/e2e; **proibição de `any`** (use `unknown` + narrow); nome do pacote reflete domínio (sufixo `-cli`/`-api` só em `package.json name`).
---

# TypeScript Naming And Structure

Use esta rule ao criar ou reorganizar projetos TypeScript em Node.js, frontend, bibliotecas ou CLIs.

## Precedencia

- Preserve a convencao ja existente no repositorio.
- Siga o framework quando ele definir estrutura, como Next.js, NestJS, Angular, Vite ou React.
- Na ausencia de padrao local ou framework, aplique esta rule.

## Nomenclatura

- Use `camelCase` para variaveis, funcoes e metodos.
- Use `PascalCase` para classes, tipos, interfaces, enums e componentes React.
- Use `UPPER_SNAKE_CASE` para constantes globais imutaveis.
- Use arquivos em `kebab-case.ts` para modulos comuns.
- Use `PascalCase.tsx` para componentes React quando o projeto ja diferenciar componentes por nome de arquivo.
- Nomeie testes como `<nome>.test.ts`, `<nome>.spec.ts`, `<nome>.test.tsx` ou `<nome>.spec.tsx`, seguindo o padrao local.
- Evite prefixo `I` em interfaces salvo convencao existente.
- Evite tipos e interfaces genericos como `Data`, `Payload`, `Props` ou `Config` sem contexto de dominio.
- O nome do pacote (`package.json name`) e o nome do diretorio do modulo refletem o DOMINIO, nao a interface implementada. Sufixos como `-cli`, `-api`, `-web`, `-server`, `-client` NAO entram no nome do modulo logico; aparecem apenas no nome publicado quando precisar distinguir entregas (ex.: modulo `payments` publicado como `@org/payments-api`).

## Estrutura

- Prefira codigo de producao em `src/`.
- Separe regras de negocio de handlers, controllers, componentes visuais e adapters externos.
- Coloque tipos compartilhados perto do dominio que os possui; crie `src/types` apenas para contratos transversais reais.
- Para bibliotecas, exponha a API publica por `src/index.ts`.
- Para CLIs, mantenha parsing e IO em uma camada de interface e declare o binario em `package.json`.
- Para testes unitarios, prefira colocalizado (`foo.test.ts` ao lado de `foo.ts`) como default moderno; e o padrao de Vitest, Jest e dos ecossistemas React/Next/Nest atuais. Use `tests/` na raiz ou `__tests__/` quando o projeto ja usar esse padrao ou quando a ferramenta exigir.
- Reserve `tests/` no mesmo nivel de `src/` para testes de integracao, contrato, ponta a ponta e fixtures compartilhadas, mesmo quando os unitarios estiverem colocalizados. Dentro de `tests/`, agrupe por tipo em subpastas (`tests/integration/`, `tests/contract/`, `tests/e2e/`) e espelhe a estrutura de `src/` dentro de cada uma.
- Mantenha `tsconfig.json`, `package.json` e lockfile na raiz do pacote.

## Tipagem

- O proposito do TypeScript e a seguranca de tipos. **Nao use `any`**. Vale para `any` explicito, `any[]`, retorno `any`, parametro `any`, `as any`, `<any>` em generics e `Record<string, any>`.
- Quando o valor for genuinamente desconhecido (input externo, body HTTP, JSON parseado, catch de erro), use `unknown` e narrow com type guard, schema validator (Zod, Valibot, io-ts) ou `instanceof`/checagem estrutural antes de usar.
- Quando precisar marcar exaustividade de `switch`/`if`-chain, use `never` (variavel `_exhaustive: never = value`).
- `tsconfig.json` em projeto novo: `"strict": true` (cobre `noImplicitAny`, `strictNullChecks`, etc.). Considere ativar `noUncheckedIndexedAccess`, `exactOptionalPropertyTypes` quando praticavel.
- ESLint/typescript-eslint em projeto novo: ative as regras `@typescript-eslint/no-explicit-any` (error), `@typescript-eslint/no-unsafe-assignment`, `@typescript-eslint/no-unsafe-call`, `@typescript-eslint/no-unsafe-member-access`, `@typescript-eslint/no-unsafe-return`, `@typescript-eslint/no-unsafe-argument`. Em Biome, ative `noExplicitAny` e `noConfusingVoidType`.
- Excecao permitida: integracao com biblioteca de terceiros sem tipos. Nesses casos: (a) tente `@types/*` primeiro; (b) declare `.d.ts` proprio se faltar; (c) so use `any` se nao houver alternativa, em escopo MINIMO (uma linha), com comentario justificando e isolando o ponto de contato. Nao deixe `any` se espalhar para fora desse ponto.
- Nao silencie a regra com `// eslint-disable` global ou `// @ts-ignore` em massa. Silenciamento pontual exige justificativa registrada inline.

### Anti-padroes (DESVIO claro)

**Evite** — `any` como saida facil:

```typescript
// recebe payload externo
function handle(payload: any): any {            // ❌ any em parametro e retorno
  return payload.user.name.trim();              //    sem narrowing, sem garantia
}

function parseConfig(raw: string): Record<string, any> {  // ❌ Record<string, any>
  return JSON.parse(raw);
}

try { ... } catch (e: any) {                    // ❌ catch tipa erro como any
  console.error(e.message);
}

const items = data as any[];                    // ❌ cast escapatorio
```

**Prefira** — `unknown` + narrowing:

```typescript
type HandlePayload = { user: { name: string } };

function handle(payload: unknown): string {
  if (!isHandlePayload(payload)) throw new ValidationError("invalid_payload");
  return payload.user.name.trim();
}

function isHandlePayload(value: unknown): value is HandlePayload {
  return (
    typeof value === "object" && value !== null && "user" in value &&
    typeof (value as { user: unknown }).user === "object"
    // ...checagem completa, ou use Zod/Valibot
  );
}

function parseConfig(raw: string): unknown {
  return JSON.parse(raw);                       // narrow no consumidor com schema
}

try { ... } catch (error: unknown) {            // catch eh unknown desde TS 4.4
  if (error instanceof Error) console.error(error.message);
}
```

### Exaustividade

```typescript
type Status = "open" | "in_progress" | "done";

function label(status: Status): string {
  switch (status) {
    case "open": return "Open";
    case "in_progress": return "In Progress";
    case "done": return "Done";
    default: {
      const _exhaustive: never = status;        // erro de compilacao se faltar caso
      throw new Error(`unhandled_status:${_exhaustive}`);
    }
  }
}
```

## Ambiente

- Preserve o gerenciador ja presente no projeto (npm, pnpm, bun, yarn). Quando o projeto nao tiver gerenciador definido ou estiver sendo criado do zero, use `yarn` como padrao e versione o `yarn.lock`. Use outro gerenciador apenas quando `yarn` for inviavel: requisito explicito do framework ou plugin (ex.: ferramenta que so suporta `pnpm`/`npm`), restricao de infraestrutura de build, ou diretriz de monorepo ja adotada. Registre o motivo na resposta final quando trocar de `yarn` para outro.
- Use a ultima versao estavel do TypeScript ao iniciar um projeto novo ou atualizar a stack, exceto quando o projeto fixar outra versao em `package.json`, `tsconfig.json` ou em arquivos de toolchain (`.nvmrc`, `.tool-versions`, `engines`, lockfile com `typescript@x.y`). Nesses casos, preserve a versao configurada e nao force atualizacao fora de escopo.
- Use a ultima versao estavel do Node.js suportada pelas ferramentas do projeto ao definir runtime, exceto quando `package.json engines.node`, `.nvmrc` ou `.tool-versions` fixarem outra versao. Preserve a versao declarada.
- Ao criar um projeto novo do zero, DECLARE explicitamente a versao do runtime em pelo menos um arquivo de toolchain: `package.json engines.node` (preferido para travar instalacao via gerenciador) e/ou `.nvmrc`/`.tool-versions`. Nao deixe a versao implicita — projetos novos sem versao declarada sao tratados como entrega incompleta. Exemplo: `"engines": { "node": ">=22.0.0" }` em `package.json` mais `.nvmrc` com `22` na raiz.
- Declare scripts de `typecheck`, `test`, `lint`, `format` e `build` quando essas ferramentas existirem; execute-os via `yarn <script>` quando o gerenciador for `yarn`.
- Linter padrao: `ESLint` com `typescript-eslint` (configuracao recomendada). Alternativa moderna: `Biome` (cobre lint + format em uma ferramenta). Em projeto novo, instale ESLint + typescript-eslint + plugin de prettier OU instale Biome; nao deixe o projeto sem linter. O script `lint` deve invocar a ferramenta real (`eslint` ou `biome check`), nao ser alias de `tsc --noEmit`. `typecheck` (TypeScript) e `lint` (ESLint/Biome) sao validacoes diferentes e ficam em scripts separados.
- Formatter padrao: `Prettier` quando o linter for ESLint, ou `biome format` quando o linter for Biome. Declare script `format` em `package.json`.
- Nao misture ESM e CommonJS sem uma razao explicita do projeto.
