---
name: naming-structure-csharp
description: 'Padrão de nomenclatura, estrutura e ambiente para projetos C#/.NET quando não houver convenção local mais específica. Use quando criar/alterar projeto C#, APIs ASP.NET, workers, CLIs ou bibliotecas. Palavras-gatilho: "C#", ".NET", "dotnet", "ASP.NET", "EF Core", "Entity Framework", `.csproj`, `.sln`, `.cs`. Garante: `PascalCase` para classes/records/structs/interfaces/enums/propriedades/métodos, `camelCase` para variáveis locais; prefixo `I` em interfaces; sufixo `Async` em métodos assíncronos; layout `src/`+`tests/`; testes com sufixo `Tests`; analyzers do SDK habilitados com `TreatWarningsAsErrors`; `dotnet format` antes de fechar; nome de projeto reflete domínio (sufixos `.Cli`/`.Api`/`.Web` só em projetos de entrega).'
---

# C# Naming And Structure

Use esta rule ao criar ou reorganizar projetos C#/.NET, APIs, bibliotecas, workers ou CLIs.

## Precedencia

- Preserve a convencao ja existente no repositorio.
- Siga a convencao do framework e do SDK .NET quando eles definirem estrutura.
- Na ausencia de padrao local, aplique esta rule.

## Nomenclatura

- Use `PascalCase` para classes, records, structs, interfaces, enums, propriedades, metodos e eventos.
- Use `camelCase` para variaveis locais e parametros.
- Use prefixo `I` para interfaces. E a convencao do .NET e da BCL, nao preferencia local; so abra excecao quando o projeto existente ja tiver adotado outro padrao.
- Use `Async` como sufixo de metodos assincronos.
- Use namespaces coerentes com o nome do projeto e da pasta.
- Nomes de projeto `.csproj` e de namespace refletem o DOMINIO, nao a interface. Sufixos como `.Cli`, `.Api`, `.Web`, `.Rest` aparecem apenas em projetos de entrega separados (ex.: `Payments.Domain`, `Payments.Api`); o nucleo de dominio mantem o nome de dominio puro.
- Nomeie testes com sufixo `Tests` e metodos de teste com comportamento esperado claro.

## Estrutura

- Use arquivos `.csproj` por projeto e `.sln` quando houver mais de um projeto.
- Organize solucoes em `src/` para producao e `tests/` para testes quando nao houver padrao local.
- Separe dominio e casos de uso de controllers, EF Core, HTTP clients, filas e outros adapters.
- Para APIs ASP.NET, mantenha controllers/endpoints e configuracao fora do dominio.
- Use `Program.cs` apenas para composition root, configuracao de host e wiring.

## Ambiente

- Valide com `dotnet test`.
- Formate com `dotnet format` quando configurado.
- Linter padrao: analyzers do .NET SDK habilitados via `<EnableNETAnalyzers>true</EnableNETAnalyzers>` e `<TreatWarningsAsErrors>true</TreatWarningsAsErrors>` no `.csproj`. Configure regras via `.editorconfig`. Em projeto novo, habilite analyzers e configure pelo menos `dotnet format --verify-no-changes` como verificacao de lint. Considere `StyleCop.Analyzers` para regras de estilo adicionais.
- Declare pacotes no `.csproj` correspondente.

## Checklist

- `PascalCase` em tipos, propriedades, metodos e eventos; `camelCase` em variaveis locais e parametros.
- Interfaces com prefixo `I` e metodos assincronos com sufixo `Async`.
- Namespaces coerentes com o nome do projeto e da pasta.
- Nome de projeto e de namespace reflete o dominio; `.Cli`, `.Api` e `.Web` so em projeto de entrega separado.
- `src/` e `tests/` quando nao houver padrao local, com `.sln` a partir de dois projetos.
- Dominio e casos de uso separados de controllers, EF Core, HTTP clients e filas; `Program.cs` so como composition root.
- Testes com sufixo `Tests` e nome de metodo descrevendo o comportamento esperado.
- `<EnableNETAnalyzers>` e `<TreatWarningsAsErrors>` habilitados, com regras no `.editorconfig`.
- `dotnet format --verify-no-changes` e `dotnet test` executados; pacotes declarados no `.csproj` correspondente.
- Identificadores, testes, comentarios e logs estruturados estao em ingles, conforme `.agents/rules/coding-language-english.md`.
