---
name: workflow-criar-skills
description: Criar, atualizar ou endurecer skills neste projeto a partir do template local e do padrão de nomes com prefixo por tópico. Use quando o usuário pedir para criar, adicionar, atualizar, calibrar ou padronizar uma skill em `.agents/skills`, incluindo a sincronização dos providers Claude, Cursor, GitHub e Gemini. Aplica diretrizes de design baseadas em findings reais do projeto: description forte, anti-padrões detectáveis mecanicamente, output verificável e auto-verificação.
---

# Criar / Atualizar Skills

`.agents/skills/` é a fonte de verdade. Os providers (`.claude/`, `.cursor/`, `.gemini/`, `.github/`) são symlinks sincronizados pelo script.

## Fluxo

1. Normalize o nome da skill em letras minúsculas com hífens, usando apenas letras, números e `-`.
2. Use um prefixo de tópico no nome para manter `skills/` plano e organizado: `architecture-`, `process-`, `workflow-`, `language-`, `greeting-`, `testing-`, `frontend-`, `backend-`, `quality-`, `framework-`, `security-`, `operational-`, `documentation-`, `coding-`, ou outro prefixo claro.
3. Crie a pasta `.agents/skills/<prefixo>-<nome-da-skill>`.
4. Use `templates/skill/SKILL.md` como base para o arquivo `.agents/skills/<prefixo>-<nome-da-skill>/SKILL.md`.
5. Ajuste o frontmatter seguindo as **Diretrizes de description** abaixo.
6. Escreva o corpo da skill seguindo as **Diretrizes de design** abaixo.
7. Quando a skill orientar nomenclatura, estrutura, layout ou convenções de stack, referencie as rules aplicáveis em `.agents/rules`.
8. Rode `scripts/sync-skills.sh` após criar ou alterar skills.

## Diretrizes de description (frontmatter)

A description é o gatilho de triagem do agente. Skills com description fraca não carregam quando deveriam, mesmo com regra clara no corpo. Aplique:

- **Inclua palavras-gatilho concretas**: liste verbos e substantivos que o usuário tipicamente usa para acionar a skill (ex.: "concluído", "completo", "refatore", "extraia", "valide").
- **Seja explícito sobre obrigatoriedade**: quando a skill precisa rodar sempre que certa condição ocorre, use "OBRIGATÓRIO" / "SEMPRE" / "antes de" no início da description. Ex.: "OBRIGATÓRIO carregar antes de qualquer frase de conclusão".
- **Liste frases que disparam a skill**: para skills cross-cutting (revisão, qualidade, greeting), enumere frases-gatilho específicas. Ex.: "Frases-gatilho: 'concluído', 'pronto', 'the refactoring is complete'".
- **Diga o que a skill garante**: "Garante que X não seja violado silenciosamente". Torna o valor da skill explícito para o triage.
- **Diga o que vira DESVIO sem a skill**: "Sem rodar esta checklist, declarar conclusão é DESVIO grave". Reforça por que carregar.
- **Não use description genérica**: "Skill que ajuda em refatoração" é fraco. "Refatorar código legado (módulo monolítico, reorganização estrutural, split de bounded contexts) com rede de testes e passos pequenos" é forte.

## Diretrizes de design (corpo da skill)

Skills que **mudam comportamento real** do agente compartilham padrões:

### 1. Use palavras-gatilho no corpo, não só na description

Em seções como "Quando rodar", liste frases concretas que devem disparar a skill. O agente busca match literal — fica mais fácil de aplicar.

### 2. Prefira anti-padrões detectáveis mecanicamente

Regras conceituais ("mantenha bounded contexts isolados") são contornáveis por interpretação. Anti-padrões detectáveis via grep, lint ou checklist objetiva são robustos.

- **Errado**: "Não misture vocabulário entre módulos."
- **Certo**: "`grep -rn 'XAggregate & {' src/` retornando matches que ligam aggregates de módulos diferentes = DESVIO."

Quando documentar anti-padrão, prefira:
- Comando shell que detecta (`grep`, `find`, `wc -l`).
- Sintoma de código copiável (linha de código exata).
- Bloco "errado vs certo" com TypeScript/Python/Go.

### 3. Output verificável força aplicação

Quando a skill deve ser aplicada **ao final** de uma tarefa (revisão, checklist, validação), exija que o agente apresente o resultado **no resumo final**. Forçar o formato de output mecaniza a aplicação.

- Tabela com status ❌/✅ por item.
- Lista de DESVIOs corrigidos.
- Seção WIP quando há pendências.

Skill que diz "rode a checklist" sem exigir output verificável é frequentemente ignorada.

### 4. Auto-verificação antes de finalizar

Inclua um bloco "Auto-verificação antes de enviar" com 2-3 perguntas literais que o agente faz a si mesmo, com instrução de "VOLTE" se a resposta for não. Ex.:

> 1. A resposta tem a seção X? Se não, VOLTE e adicione.
> 2. Se 2+ itens vermelhos, usei frase de conclusão? Se sim, VOLTE e troque por WIP.

Esse padrão funcionou empiricamente para forçar aplicação de regra antes de submissão.

### 5. Bloco errado/certo com código real

Para skills de arquitetura/qualidade, inclua bloco errado/certo com código TypeScript/Python/etc. mostrando o anti-padrão e a alternativa. Texto abstrato é contornável; código concreto é diretriz.

### 6. Cross-reference entre skills

Skills relacionadas devem se referenciar nominalmente: "Ver `process-tdd` para o ciclo TDD; ver `quality-revisao-aderencia` para o formato de output final". Aumenta a chance de o agente carregar várias skills relacionadas.

### 7. Listar gatilhos de carregamento em skills cross-cutting

Skills que precisam carregar em muitos contextos (revisão, qualidade, greeting) devem ter description com **lista de contextos** onde carregar, não só descrição abstrata.

## Diretrizes de calibração

Skills evoluem por incidentes. A cada falha observada do agente, atualize a skill correspondente:

- Anti-padrão novo detectado → adicione na lista de DESVIOs.
- Caminho de escape do agente identificado → adicione exemplo errado/certo.
- Frase de conclusão prematura → adicione à lista de frases-gatilho proibidas.
- Skill ignorada por triagem → endureça a description com palavras-gatilho.

Registre brevemente no commit ou na resposta final ao usuário qual incidente motivou o ajuste — facilita auditoria.

## Anti-padrões em skills (auto-aplicável)

Ao criar/revisar skills, evite:

- **Description vaga** (`"Skill de qualidade"`) — não dispara triagem.
- **Corpo só com princípios abstratos** sem exemplo concreto.
- **Sem anti-padrão detectável** quando o tema permite (arquitetura, lint, estrutura).
- **Sem cross-reference** quando depende de outras skills.
- **Sem output verificável** quando deve ser aplicada no fim da tarefa.
- **Frases-gatilho ausentes** em skills cross-cutting (greeting, revisão).
- **Description sem indicação de obrigatoriedade** quando a skill deve rodar sempre que X.

## Sincronização

Sempre execute após criar ou alterar:

```bash
./scripts/sync-skills.sh
```

O script:
- Cria/atualiza symlinks em `.claude/skills`, `.cursor/skills`, `.github/skills`, `.gemini/skills` (e o mesmo para `rules/`).
- Remove symlinks órfãos quando skill é excluída de `.agents/skills/`.

Se o script avisar que pulou um caminho existente que não é symlink, informe o conflito ao usuário antes de sobrescrever qualquer coisa.

## Auto-verificação antes de enviar

Antes de declarar a skill criada/atualizada:

1. A description tem palavras-gatilho concretas? Se não, VOLTE e adicione.
2. O corpo tem anti-padrão detectável mecanicamente quando o tema permite? Se não, VOLTE e adicione.
3. Skills relacionadas estão referenciadas nominalmente? Se não, VOLTE e adicione cross-references.
4. Para skill cross-cutting, há lista de frases-gatilho explícita? Se não, VOLTE e adicione.
5. Rodei `./scripts/sync-skills.sh`? Se não, rode agora.

## Checklist

- Nome da pasta = nome do `frontmatter.name`, em kebab-case com prefixo de tópico.
- Description com palavras-gatilho concretas + indicação de obrigatoriedade quando aplicável.
- Corpo com instruções operacionais curtas, não princípios abstratos.
- Anti-padrões com sintoma detectável (grep, lint, código exato) quando o tema permite.
- Cross-references nominais para skills relacionadas.
- Bloco errado/certo com código real quando a skill cobre arquitetura/qualidade.
- Output verificável quando a skill deve ser aplicada no fim da tarefa.
- Auto-verificação antes de submissão quando a skill exige aplicação rigorosa.
- `./scripts/sync-skills.sh` executado.
- Rules aplicáveis em `.agents/rules` referenciadas quando a skill orienta nomenclatura/estrutura/stack.
