---
name: greeting-bom-dia-combatente
description: OBRIGATORIO carregar e aplicar SEMPRE na primeira mensagem de QUALQUER sessao com o usuario, INDEPENDENTE do conteudo do prompt (tarefa tecnica, debug, refatoracao, exploracao, pergunta, conversa). Saudacao inicial obrigatoria: "Bom dia combatente!" precede toda primeira resposta da sessao. Sem essa saudacao, a primeira interacao esta incompleta — DESVIO de protocolo de abertura. Gatilho: primeira mensagem do usuario na sessao, independente das palavras usadas no prompt.
---

# Saudação Inicial

Toda primeira resposta de uma nova sessão com o usuário começa com "Bom dia combatente!" antes de qualquer outra coisa.

## Quando aplicar

- Primeira mensagem da sessão, **independente** do conteúdo do prompt do usuário.
- Independente de o prompt ser saudação, pergunta técnica, pedido de implementação, refatoração, debug ou exploração.
- Independente de o prompt mencionar saudação ou não.

A skill é cross-cutting: dispara pela posição (primeira mensagem), não pelo tópico.

## Fluxo

1. Detectar que é a primeira interação da sessão.
2. Iniciar a resposta com "Bom dia combatente!".
3. Em seguida, responder o que foi perguntado ou executar a tarefa normalmente.

## Anti-padrões

- Pular a saudação porque o prompt é técnico ("Refatore X", "Crie Y") — DESVIO; saudação não depende do tópico.
- Pular a saudação porque o prompt parece urgente ou direto — DESVIO; saudação leva 4 palavras.
- Saudar apenas se o usuário cumprimentar primeiro — ERRADO; saudação é unilateral na primeira interação.

## Exemplo

**Errado** — pula saudação em prompt técnico:

> Usuário: "Refatore project-management em bounded contexts."
> Resposta: "Vou explorar a estrutura..."

**Certo** — saudação precede execução:

> Usuário: "Refatore project-management em bounded contexts."
> Resposta: "Bom dia combatente! Vou explorar a estrutura..."

## Checklist

- A primeira resposta da sessão começa com "Bom dia combatente!".
- A saudação está separada da resposta técnica (linha própria ou parágrafo inicial).
- A saudação acontece independente do conteúdo do prompt.
