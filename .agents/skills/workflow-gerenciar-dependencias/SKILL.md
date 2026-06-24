---
name: workflow-gerenciar-dependencias
description: Gerenciar dependências, ambientes e ferramentas de projeto de forma declarada e reproduzível. Use quando o agente precisar instalar, adicionar, atualizar, remover ou executar dependências, ferramentas de teste, cobertura, lint, formatter, build, runtime ou utilitários de stack. Palavras-gatilho: "instale", "adicione", "atualize", "yarn add", "uv add", "npm install", "pip install", "cargo add", "go get", "composer require", "dependência", "biblioteca", "package", "lockfile", "manifesto". Garante uso do gerenciador idiomático da stack (uv em Python, yarn em TS/JS novo), lockfile versionado e sincronizado, dependências declaradas no manifesto (não global), dev-deps separadas de runtime, runtime declarado em arquivo de toolchain quando aplicável. Sem o gerenciador correto e lockfile sincronizado, ambiente não é reproduzível — DESVIO.
---

# Gerenciar Dependências

Use esta skill quando uma tarefa exigir dependência, ferramenta ou ambiente que ainda não esteja configurado no projeto.

## Regras

- Declare dependências no manifesto da stack e mantenha o lockfile quando a ferramenta gerar um.
- Prefira dependências de desenvolvimento para ferramentas de teste, cobertura, lint, formatação, build e automação local.
- Execute comandos pelo ambiente do projeto, não por instalações globais.
- Não trate dependência ausente como bloqueio antes de tentar configurá-la no projeto ou antes de identificar um bloqueio externo real.
- Não misture gerenciadores de dependência na mesma stack sem padrão existente que justifique isso.
- Quando criar ou reorganizar manifests, lockfiles, scripts ou estrutura de ambiente, siga o padrão local ou a rule da linguagem em `.agents/rules`.

## Python

- Use sempre `uv`.
- Crie ou atualize `pyproject.toml` quando o projeto Python ainda não tiver manifesto.
- Em projeto Python novo, declare metadados mínimos, `requires-python`, scripts de CLI quando existirem e configuração das ferramentas no `pyproject.toml`. Use o template mínimo definido na rule `naming-structure-python` em `.agents/rules/naming-structure-python.md` como base; ele já cobre estrutura, entrypoint, `dependency-groups` para dev e configuração de cobertura.
- Adicione dependências de runtime com `uv add <pacote>`.
- Adicione ferramentas de desenvolvimento com `uv add --dev <pacote>`.
- Execute aplicações e validações com `uv run <comando>`.
- Mantenha `uv.lock` quando ele for criado ou alterado.
- Mantenha `.venv/`, `.coverage`, caches e bytecode fora do versionamento por `.gitignore`.
- Não use `pip install`, `python -m venv`, `virtualenv`, `requirements.txt` novo ou instalação global, salvo quando um projeto existente já exigir esse padrão e a razão for registrada.

## Fluxo

1. Identifique a stack e o gerenciador já usado pelo projeto.
2. Consulte a rule da linguagem quando precisar definir estrutura de manifesto, scripts ou lockfile sem padrão local.
3. Se for Python, use `uv` mesmo em projetos pequenos.
4. Adicione a dependência no grupo correto: runtime ou desenvolvimento.
5. Atualize comandos e documentação para usar o ambiente do projeto.
6. Execute a validação que depende da ferramenta instalada.
7. Se a instalação exigir rede, autenticação ou permissão externa, solicite aprovação ou informe o bloqueio concreto.

## Checklist

- Dependências novas foram declaradas no manifesto.
- Ferramentas de desenvolvimento ficaram em dependências de desenvolvimento.
- Lockfile foi mantido quando aplicável.
- Artefatos de ambiente, cache e cobertura ficaram ignorados pelo versionamento.
- Comandos documentados usam o ambiente do projeto.
- Rules aplicáveis foram consultadas quando estrutura de stack precisou ser definida.
- Em Python, os comandos usam `uv add` e `uv run`.
