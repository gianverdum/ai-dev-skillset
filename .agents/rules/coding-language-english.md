---
name: coding-language-english
description: 'OBRIGATORIO em qualquer tarefa que cria ou altera código. Ingles e o idioma exclusivo de codificação em qualquer linguagem do projeto (identificadores, testes, comentários, logs estruturados, mensagens). Use sempre que criar, alterar ou revisar código, testes ou identificadores em qualquer linguagem. Palavras-gatilho: "implemente", "crie", "altere", "refatore", "variável", "função", "classe", "test", "naming", "identificador", "mensagem de erro", "i18n". Garante: código 100% em inglês; mensagens humanas como chaves de i18n com inglês default OU literais em inglês em CLI pequena (NUNCA português sem acentos); codigo de erro tipado como literal union/enum, não `string` cru; `Record<EnumDeCodigos, string>` no catálogo de mensagens. Exceções permitidas: termos intraduzíveis do domínio (CPF, CNPJ, Pix, Boleto) e acrônimos regionais. Sem inglês como default e codes tipados, mistura de idiomas no código é DESVIO.'
---

# Coding Language English

Ingles e o idioma exclusivo de codificacao em qualquer linguagem do projeto.

## Aplicacao

- Aplica-se a TODO codigo de producao e de teste: identificadores (variaveis, parametros, funcoes, metodos, classes, interfaces, tipos, enums, constantes), nomes de arquivos e diretorios de codigo, modulos, pacotes, namespaces, branches semanticas em commits e mensagens de log estruturadas para operacao.
- Aplica-se a comentarios e docstrings dentro do codigo.
- Documentacao orientada a humanos (`README.md`, docs do projeto, mensagens de commit, ADRs) NAO esta no escopo desta rule e pode seguir o idioma adotado pelo projeto.

## Regra

- Use ingles para todo identificador no codigo. Sem excecao por preferencia pessoal ou por o codigo "estar pequeno".
- Em testes, nomeie funcoes, classes e fixtures em ingles. Exemplo: `test_divides_two_numbers` em vez de `test_divide_dois_numeros`.
- Use ingles em mensagens de log estruturadas, codigos de erro internos, identificadores de eventos de dominio e nomes de excecoes.

## Excecoes Permitidas

1. **Termos intraduziveis do dominio**: quando o vocabulario do dominio do projeto nao tem traducao adequada para ingles ou a traducao distorce o significado, mantenha o termo original. Exemplos validos: `CPF`, `CNPJ`, `IPI`, `ICMS`, `Pix`, `Boleto`, `SUS`, `Saci`, `Caipirinha`. Documente esses termos no glossario do projeto quando houver ambiguidade.
2. **Acrônimos e siglas estabelecidas**: mantenha siglas padrao do dominio mesmo quando nao sao inglesas (ex.: nomes de leis, normas, padroes regionais).
3. **Mensagens voltadas ao usuario final**: textos exibidos para humanos (`stdout`, `stderr` em CLI, respostas de API com `message`, conteudo de UI, e-mails, push notifications, etc.) NAO devem ser escritos diretamente em portugues nem em qualquer outro idioma no codigo. Devem ser tratados como **i18n**: o codigo referencia uma CHAVE estavel em ingles (ex.: `errors.division_by_zero`, `cli.usage.expression_required`) e os textos traduzidos vivem em arquivos de catalogo por idioma (`locales/en.json`, `locales/pt-BR.json`, etc.). Ingles e o idioma DEFAULT do catalogo.

## Como Aplicar Mensagens ao Usuario

- Mensagens de erro lancadas para o usuario nao chegam ao codigo como string literal traduzida. Dominio e application lancam um erro carregando um **codigo estavel em ingles** (atributo `code`, `kind`, `reason`, ou tipo da excecao). A camada de apresentacao (interface) resolve esse codigo em texto humano. O catalogo de textos vive isolado e pode ser localizado depois sem tocar dominio/application.
- Em CLIs e ferramentas pequenas onde i18n completo e excessivo, ainda separe **codigo** (no dominio/application) de **mensagem humana** (na interface), mesmo que o catalogo seja um dicionario inline. Strings de mensagem nao moram no dominio. Nunca escreva mensagens em portugues sem acentos como substituto de i18n.
- Em libs/SDKs publicados, excecoes carregam codigo estavel em ingles; mensagens humanas opcionais usam ingles como default.
- O tipo do `code`/`kind`/`reason` da classe de erro deve ser uma **enumeracao explicita** (literal union em TypeScript, `Literal[...]` ou `Enum` em Python, `enum` em Rust/Java/C#, `iota`/typed const em Go), nao `string` cru. Isso permite ao compilador/checador garantir consistencia entre o conjunto de codigos lancados e o catalogo de mensagens. `code: string` cru e DESVIO.

### Padrao em codigo

**Errado** — mensagem humana lancada do dominio:

```python
# domain/arithmetic.py
def calculate(left, op, right):
    if op == "/" and right == 0:
        raise ValueError("Division by zero is not allowed.")  # mistura codigo + apresentacao
```

**Certo** — dominio lanca codigo estavel; interface resolve para texto:

```python
# domain/errors.py
class CalculationError(Exception):
    def __init__(self, code: str) -> None:
        super().__init__(code)
        self.code = code

# domain/arithmetic.py
def calculate(left, op, right):
    if op == "/" and right == 0:
        raise CalculationError("division_by_zero")

# interface/cli.py
ERROR_MESSAGES = {
    "division_by_zero": "Division by zero is not allowed.",
    "unsupported_operator": "Unsupported operator.",
}

try:
    ...
except CalculationError as error:
    print(ERROR_MESSAGES[error.code], file=sys.stderr)
```

**TypeScript equivalente** — classe de erro com `code` tipado como literal union:

```typescript
// domain/errors.ts
export type CalculationErrorCode =
  | "division_by_zero"
  | "unsupported_operator";

export class CalculationError extends Error {
  constructor(public readonly code: CalculationErrorCode) {  // tipo restrito, nao string
    super(code);
    this.name = "CalculationError";
  }
}

// domain/calculator.ts
if (right === 0) throw new CalculationError("division_by_zero");

// interface/cli.ts — Record<EnumDeCodigos, string> forca exaustividade
const ERROR_MESSAGES: Record<CalculationErrorCode, string> = {
  division_by_zero: "Division by zero is not allowed.",
  unsupported_operator: "Unsupported operator.",
};

try { ... }
catch (e) {
  if (e instanceof CalculationError) ports.stderr(ERROR_MESSAGES[e.code]);
}
```

A regra vale para qualquer linguagem: dominio/application carregam **codigo estavel em snake_case ingles**, tipado como **enumeracao explicita**, interface resolve para texto humano.

### Anti-padrao: `code: string` cru

**Evite** — perde a garantia do compilador:

```typescript
// domain/errors.ts (ERRADO)
export class DomainError extends Error {
  constructor(public readonly code: string) { ... }   // ❌ string cru
}

// interface/messages.ts (ERRADO)
const ERROR_MESSAGES: Record<string, string> = {       // ❌ Record<string, ...>
  permission_denied: "...",
  tenant_not_found: "...",
  // typo "tennant_not_found" passa batido; codigo novo nao alerta falta de mensagem
};
```

**Prefira** — `Record<EnumDeCodigos, string>` forca exaustividade:

```typescript
// domain/errors.ts (CERTO)
export type DomainErrorCode =
  | "permission_denied"
  | "tenant_not_found"
  | "client_not_found"
  | "project_not_found";

export class DomainError extends Error {
  constructor(public readonly code: DomainErrorCode) { ... }
}

// interface/messages.ts (CERTO) — compilador alerta:
// (a) toda mensagem ter chave valida em DomainErrorCode (typo nao compila)
// (b) toda chave de DomainErrorCode ter mensagem correspondente (falta de chave nao compila)
const ERROR_MESSAGES: Record<DomainErrorCode, string> = {
  permission_denied: "Permission denied.",
  tenant_not_found: "Tenant not found.",
  client_not_found: "Client not found.",
  project_not_found: "Project not found.",
};
```

## Manutencao

- Ao criar codigo novo, escreva diretamente em ingles. Nao traduza depois.
- Ao editar codigo legado em outro idioma, prefira traduzir os identificadores tocados pela mudanca quando o custo for pequeno; nao force renomeacao em massa fora de escopo.
- Quando o dominio exigir termo nao-ingles, registre o motivo no README do modulo ou em um glossario do projeto.

## Checklist

- Todos os identificadores criados ou alterados estao em ingles, exceto termos intraduziveis do dominio.
- Nenhuma mensagem voltada ao usuario foi escrita como string literal em outro idioma no codigo. Ou esta em ingles como default, ou esta referenciada por chave de i18n.
- Dominio e application nao contem strings de mensagem humana; lancam codigo estavel em ingles (snake_case) e a interface resolve para texto.
- Testes, comentarios, docstrings e logs estruturados estao em ingles.
- Excecoes ao ingles (termos de dominio) tem justificativa registrada no projeto.
