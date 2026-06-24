---
name: topic-nome-da-rule
description: Descreva a regra de forma curta e diga quando ela deve orientar o agente.
---

# Nome da Rule

Defina uma regra objetiva que o agente deve seguir durante a execucao das tarefas.

## Aplicacao

- Use esta rule quando o pedido do usuario envolver o contexto descrito no frontmatter.
- Mantenha a regra focada em comportamento observavel do agente.
- Prefira orientacoes verificaveis, com criterios claros de cumprimento.

## Regra

- Descreva o que o agente deve fazer.
- Descreva restricoes importantes, se existirem.
- Indique validacoes esperadas quando a regra impactar arquivos, comandos ou entregaveis.

## Manutencao

- Use nomes em letras minusculas com hifens.
- Mantenha uma rule por arquivo em `.agents/rules`.
- Rode `./scripts/sync-skills.sh` depois de criar ou alterar rules.
