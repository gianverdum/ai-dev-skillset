---
name: topic-nome-da-rule
description: 'Descreva a regra e diga quando ela deve orientar o agente. Inclua palavras-gatilho concretas. Diga o que a rule garante e o que vira DESVIO sem ela. MANTENHA AS ASPAS SIMPLES: a description contem `": "` em "Palavras-gatilho:" e "Garante:", e escalar YAML sem aspas quebra o parser — a rule para de carregar.'
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

- Use nomes em letras minusculas com hifens, com prefixo de topico (`naming-structure-`, `coding-`, `project-`).
- Mantenha uma rule por arquivo em `.agents/rules`.
- Rule de linguagem tem quatro secoes obrigatorias: `Precedencia`, `Nomenclatura`, `Estrutura` e `Ambiente`.
- Valide o frontmatter com parser YAML antes de encerrar.
- Rode `./scripts/sync-skills.sh` depois de criar ou alterar rules.
- Ver a skill `workflow-criar-rules` para o fluxo completo e os anti-padroes detectaveis.
