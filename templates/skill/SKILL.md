---
name: topic-nome-da-skill
description: |
  [OBRIGATORIO se a skill deve carregar sempre que X — use OBRIGATORIO/SEMPRE/antes de no inicio.]
  Descreva o que a skill faz e quando deve ser usada.
  Inclua palavras-gatilho concretas que o usuario tipicamente usa (verbos, substantivos, frases).
  [Para skills cross-cutting:] Frases-gatilho: "concluido", "feito", "X", "Y".
  [Opcional:] Garante que <regra> nao seja violada silenciosamente.
  Use prefixo de topico no nome: architecture-, process-, workflow-, language-, greeting-, testing-, quality-, framework-, security-, operational-, documentation-, coding-.
---

# Nome da Skill

Explique de forma objetiva o comportamento que o agente deve adotar quando esta skill for acionada. Uma frase de propósito; o resto vai nas seções.

<!--
SEÇÕES OPCIONAIS — INCLUA APENAS AS QUE FAZEM SENTIDO PARA ESTA SKILL.

Estrutura típica por tipo de skill:

- Skills de processo (TDD, refatoração, revisão): Fluxo + Anti-padrões + Auto-verificação + Checklist.
- Skills de arquitetura (DDD, hexagonal): Princípios + Regras estruturais + Exemplos errado/certo + Anti-padrões + Checklist.
- Skills de criação (iniciar app, criar módulo): Decisões iniciais + Estrutura + Checklist.
- Skills de qualidade (revisão, lint): Quando rodar + Pontos a verificar + Anti-padrões + Output verificável + Auto-verificação + Checklist.
- Skills cross-cutting (greeting, idioma): Quando aplicar + Frases-gatilho + Exemplo.

Remova este comentário ao usar o template.
-->

## Quando rodar

<!-- Para skills cross-cutting ou de fim-de-tarefa: liste gatilhos concretos. -->

- Cenário 1 em que a skill deve carregar (palavras/contextos específicos).
- Cenário 2.

<!-- Para skills que devem rodar antes de declarações de fim:

**Regra absoluta de gatilho — antes de qualquer frase de conclusao:**

Antes de escrever no resumo final QUALQUER uma destas frases (ou equivalente):
- "concluido" / "completo" / "feito" / "pronto" / "the X is complete" / ...

Se a checklist tem 2+ itens vermelhos, voce esta PROIBIDO de usar essas frases. Use formato WIP.
-->

## Fluxo

1. Passo concreto e operacional.
2. Próximo passo.
3. Quando a tarefa envolver nomenclatura, estrutura ou convenções de stack, consulte primeiro as rules aplicáveis em `.agents/rules`.
4. Validação ao final, quando houver forma prática de validar.

## Regras / Pontos a verificar

- Regra operacional 1 — descreva comportamento observável.
- Regra operacional 2.
- Mantenha instruções curtas e específicas.

## Anti-padrões

<!-- Prefira anti-padroes DETECTAVEIS MECANICAMENTE (grep, lint, contagem):

- `grep -rn "<padrao>" src/` retornando matches → DESVIO.
- Arquivo `src/<path>` com mais de N linhas → DESVIO.
- Função `*Service` com 5+ métodos públicos → DESVIO.
-->

- Anti-padrão 1 (com sintoma detectável quando possível).
- Anti-padrão 2.

### Exemplo: errado vs certo

<!-- Para skills de arquitetura/qualidade: bloco com codigo real -->

**Errado** — descrição curta do que evitar:

```typescript
// codigo do anti-padrao
```

**Certo** — descrição curta da alternativa:

```typescript
// codigo correto
```

## Output verificável (quando aplicável)

<!--
Para skills aplicadas no fim de tarefa (revisao, qualidade, checklist):
exija formato de saida no resumo final.

Exemplo:

A resposta final OBRIGATORIAMENTE inclui uma seção "Revisão de <skill>" com:

- Tabela com status ❌/✅ por item.
- Lista de DESVIOs corrigidos.
- Seção "Pendente" no formato WIP se houver itens vermelhos.

Frases proibidas se houver itens vermelhos: "concluído", "completo", "feito", "complete", "done".
-->

## Auto-verificação antes de enviar

<!-- Para skills que exigem aplicacao rigorosa: 2-3 perguntas literais. -->

Antes de submeter o resumo final, releia:

1. A resposta tem a seção X? Se não, **VOLTE** e adicione.
2. Aplicou a regra Y a cada item afetado? Se não, **VOLTE** e corrija.
3. Frases de conclusão correspondem ao estado real da checklist? Se não, **VOLTE** e ajuste.

## Referências cruzadas

<!-- Para skills que dependem ou complementam outras: cite nominalmente. -->

- Ver `process-tdd` para o ciclo TDD completo.
- Ver `quality-revisao-aderencia` para o formato de revisão final.
- Ver rules de nomenclatura/estrutura em `.agents/rules/naming-structure-<linguagem>.md`.

## Checklist

- Item operacional verificável 1.
- Item operacional verificável 2.
- Comando ou ferramenta foi executado quando aplicável.
- Output verificável foi incluído no resumo final, se a skill exige.
