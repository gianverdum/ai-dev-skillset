---
name: naming-structure-python
description: Padrão de nomenclatura, estrutura e ambiente para projetos Python quando não houver convenção local mais específica. Use quando criar/alterar projeto Python, módulos, pacotes, testes ou CLIs. Palavras-gatilho: "Python", "uv", "pyproject.toml", "pytest", "ruff", "pacote", "módulo Python", "venv", `.py`. Garante: `snake_case` para módulos/funções/variáveis, `PascalCase` para classes/exceções, `UPPER_SNAKE_CASE` para constantes; layout `src/<pacote>` com `tests/<tipo>/<espelho>` agrupados por tipo (`unit/integration/e2e/contract/`); `uv` como gerenciador (não pip global), `pyproject.toml` com `[dependency-groups] dev`; `ruff` como linter+formatter padrão (não flake8+black em projeto novo); `requires-python` declarado; nome do pacote reflete domínio (sem sufixo `_cli`/`_api`/`_service` — só no nome publicado).
---

# Python Naming And Structure

Use esta rule ao criar ou reorganizar projetos, pacotes, modulos, testes ou CLIs Python.

## Precedencia

- Preserve a convencao ja existente no repositorio.
- Siga a convencao do framework quando ele exigir layout proprio.
- Na ausencia de padrao local ou framework, aplique esta rule.

## Nomenclatura

- Use `snake_case` para modulos, pacotes, funcoes, metodos e variaveis.
- Use `PascalCase` para classes e excecoes.
- Use `UPPER_SNAKE_CASE` para constantes.
- Use nomes de pacote curtos, descritivos e sem hifens; hifens ficam apenas no nome publicado do projeto, quando necessario.
- O nome do pacote Python reflete o DOMINIO, nao a interface implementada nem a tecnologia. Sufixos como `_cli`, `_api`, `_web`, `_rest`, `_service`, `_lib` NAO entram no nome do pacote em `src/<pacote>`; ficam apenas no nome publicado em `[project] name` quando precisar distinguir entregas. Exemplo: pacote `calculadora` publicado como `calculadora-cli`; pacote `payments` publicado como `payments-api`.
- Use verbos para funcoes e casos de uso que executam acao; use substantivos do dominio para entidades e value objects.
- Evite abreviacoes obscuras e nomes genericos como `utils`, `helpers`, `manager` ou `service` quando houver termo de dominio mais claro.

## Estrutura

- A raiz do repositorio e a raiz do projeto. `pyproject.toml`, `uv.lock`, `README.md`, `.gitignore`, `src/` e `tests/` ficam na raiz do repo.
- Nao crie uma pasta com o nome do projeto na raiz do repo para depois colocar `src/` dentro. Errado: `<repo>/calculadora/src/calculadora/`. Certo: `<repo>/src/calculadora/`. O nome do projeto aparece em `[project] name` do `pyproject.toml` e como pacote em `src/<pacote_python>`.
- So use layout de monorepo (`apps/<nome>/`, `packages/<nome>/` ou similar) quando o repositorio ja hospedar mais de um projeto independente ou quando isso for pedido explicitamente.
- Prefira layout `src/` para codigo de producao: `src/<pacote_python>`.
- Para aplicacoes com regra de negocio, separe pelo menos `domain`, `application` e `interface` ou adapters equivalentes.
- Coloque entrypoints CLI em camada de interface e declare scripts em `pyproject.toml`.
- Use `tests/` na raiz para testes de integracao, contrato e CLI; testes unitarios podem ficar em `tests/` ou proximos ao pacote se o projeto ja usar esse padrao.
- Dentro de `tests/`, agrupe por tipo em subpastas (`tests/unit/`, `tests/integration/`, `tests/contract/`, `tests/e2e/`) e espelhe a estrutura de `src/<pacote>` dentro de cada uma: o teste de `src/<pacote>/<sub>/<arquivo>.py` vai para `tests/<tipo>/<pacote>/<sub>/test_<arquivo>.py`.
- Mantenha configuracoes, manifesto e lockfile na raiz: `pyproject.toml`, `uv.lock`, `README.md` e arquivos de ferramenta.
- Nao coloque codigo de producao solto na raiz.

## Ambiente

- Use `uv` como gerenciador padrao quando nao houver padrao existente.
- Declare dependencias em `pyproject.toml` e mantenha `uv.lock`.
- Execute comandos com `uv run`.
- Linter e formatter padrao: `ruff` (cobre lint e formatacao em uma so ferramenta). Adicione com `uv add --dev ruff`, configure em `[tool.ruff]` no `pyproject.toml` e declare scripts equivalentes a `ruff check` (lint) e `ruff format` (format). Em projetos legados que ja usem `flake8`+`black`+`isort`, preserve a stack existente.

## Template Minimo de `pyproject.toml`

Use este template quando criar um projeto Python novo com `uv`. Ajuste nome, versao de Python e entrypoint conforme o caso. Mantenha dependencias de runtime em `[project] dependencies` e ferramentas de desenvolvimento em `[dependency-groups] dev` (padrao do `uv`).

```toml
[project]
name = "<nome-publicado>"
version = "0.1.0"
description = "<descricao curta>"
requires-python = ">=3.11"
dependencies = []

[project.scripts]
<comando> = "<pacote_python>.interface.cli:main"

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[tool.hatch.build.targets.wheel]
packages = ["src/<pacote_python>"]

[dependency-groups]
dev = [
    "pytest",
    "pytest-cov",
]

[tool.pytest.ini_options]
addopts = "--cov=<pacote_python> --cov-fail-under=80"
testpaths = ["tests"]

[tool.coverage.run]
source = ["src/<pacote_python>"]
```

Notas:
- Remova a secao `[project.scripts]` quando o projeto nao expoe CLI.
- Remova `[tool.pytest.ini_options]` e `[tool.coverage.run]` quando a stack de testes nao for `pytest` ou quando a skill de cobertura nao se aplicar.
- Use `uv add <pacote>` para runtime e `uv add --dev <pacote>` para ferramentas; isso mantem `[project] dependencies` e `[dependency-groups] dev` sincronizados com `uv.lock`.
