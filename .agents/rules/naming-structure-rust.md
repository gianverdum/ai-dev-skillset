---
name: naming-structure-rust
description: Padrão de nomenclatura, estrutura e ambiente para projetos Rust quando não houver convenção local mais específica. Use quando criar/alterar projeto Rust, crates, bibliotecas, CLIs ou serviços. Palavras-gatilho: "Rust", "cargo", "Cargo.toml", "clippy", "rustfmt", "crate", "src/lib.rs", "src/main.rs", `.rs`. Garante: `snake_case` para arquivos/módulos/funções, `PascalCase` para structs/enums/traits, `SCREAMING_SNAKE_CASE` para constantes; crates em `kebab-case` no manifesto; layout `src/lib.rs`/`src/main.rs`/`src/bin/<nome>.rs`; tests unitários em módulos `#[cfg(test)]` colocalizados, integration em `tests/`; `cargo clippy -D warnings` como linter; `cargo fmt` antes de fechar; nome do crate reflete domínio (sufixo `-cli`/`-api` só em crates binários em workspace).
---

# Rust Naming And Structure

Use esta rule ao criar ou reorganizar projetos Rust, bibliotecas, CLIs ou servicos.

## Precedencia

- Preserve a convencao ja existente no repositorio.
- Siga a convencao do crate, framework ou workspace quando ela existir.
- Na ausencia de padrao local, aplique esta rule.

## Nomenclatura

- Use `snake_case` para arquivos, modulos, funcoes, metodos e variaveis.
- Use `PascalCase` para structs, enums, traits e type aliases.
- Use `SCREAMING_SNAKE_CASE` para constantes e statics.
- Use nomes de crates em `kebab-case` no `Cargo.toml`; no codigo, importe como `snake_case`.
- O nome do crate reflete o DOMINIO, nao a interface. Sufixos como `-cli`, `-api`, `-web` NAO entram no nome do crate de biblioteca; aparecem apenas em crates binarios em workspace (ex.: crate de biblioteca `auth`, crate binario `auth-cli` no mesmo workspace) ou no nome publicado quando aplicavel.
- Nomeie testes unitarios em modulos `tests` proximos ao codigo e testes de integracao como arquivos em `tests/`.
- Evite modulos genericos como `utils` quando houver nome de dominio ou responsabilidade mais claro.

## Estrutura

- Use `src/lib.rs` para bibliotecas e `src/main.rs` para binarios simples.
- Para multiplos binarios, use `src/bin/<nome>.rs`.
- Use `tests/` para testes de integracao e `benches/` apenas quando houver benchmark configurado. Quando o crate tiver mais de um tipo de teste em `tests/` alem de integracao, agrupe por tipo em subpastas (`tests/integration/`, `tests/contract/`, `tests/e2e/`) e espelhe a estrutura do crate dentro de cada uma. Em crate simples com apenas testes de integracao, manter arquivos direto em `tests/` segue idiomatico.
- Em workspaces, mantenha crates em diretorios claros como `crates/<nome>` ou conforme padrao existente.
- Separe dominio e casos de uso de IO, HTTP, banco e adapters externos quando houver regra de negocio.
- Mantenha `Cargo.toml` e `Cargo.lock` conforme o tipo de projeto; versionar `Cargo.lock` para aplicacoes e CLIs.

## Ambiente

- Formate com `cargo fmt`.
- Valide com `cargo test`.
- Linter padrao: `cargo clippy` (parte do toolchain Rust). Trate avisos do clippy como erros no fluxo do agente; ative `-D warnings` em CI quando aplicavel. Em projeto novo, declare a tarefa `clippy` no manifesto/Makefile/justfile.
- Formatter padrao: `cargo fmt` (rustfmt, parte do toolchain). Rode antes de encerrar a tarefa.
