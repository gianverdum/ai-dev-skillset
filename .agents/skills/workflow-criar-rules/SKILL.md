---
name: workflow-criar-rules
description: 'Criar, atualizar ou endurecer rules deste projeto em `.agents/rules`, a partir do template local e do padrão de nomes por tópico. Use quando o usuário pedir para criar, adicionar, atualizar, calibrar, corrigir ou padronizar uma rule — convenção de nomenclatura, estrutura de pastas, idioma do código, ferramental de stack ou contexto do projeto. Palavras-gatilho: "rule", "regra", "convenção", "padrão de nomenclatura", "naming", "estrutura de pastas", "nova linguagem", "adicione a linguagem X", ".agents/rules", "sync-skills". Garante: frontmatter YAML que PARSEIA (description entre aspas simples — `": "` em escalar sem aspas quebra o parser e derruba o gatilho da rule); uma rule por arquivo com prefixo de tópico; rule de linguagem com as quatro seções obrigatórias (Precedencia, Nomenclatura, Estrutura, Ambiente); precedência declarada antes de qualquer regra; linter e formatter nomeados, não genéricos; checklist verificável ao final; `./scripts/sync-skills.sh` executado. Sem frontmatter válido a rule não carrega, e regra que não carrega é regra que não existe — DESVIO.'
---

# Criar / Atualizar Rules

`.agents/rules/` é a fonte de verdade. Os providers (`.claude/`, `.cursor/`, `.gemini/`, `.github/`) são symlinks gerados por `./scripts/sync-skills.sh` — nunca edite dentro deles.

Rule é **convenção**: o que vale sempre, independente da tarefa. Skill é **procedimento**: como executar um tipo de tarefa. Ver `workflow-criar-skills` para o outro lado.

## Quando rodar

Carregue esta skill quando o pedido contiver, em qualquer forma:

- "crie uma rule", "adicione uma regra", "atualize a rule de X", "padronize";
- "convenção de nomenclatura", "estrutura de pastas", "padrão de projeto";
- "adicione a linguagem X" — linguagem nova no projeto pede rule de nomenclatura e estrutura antes de existir código de produção;
- "corrija a rule", "a rule não está carregando", "frontmatter";
- qualquer alteração em arquivo dentro de `.agents/rules/`.

## Rule ou skill?

| O pedido descreve… | Vai para |
|---|---|
| Como nomear, onde colocar, que ferramenta usar | **rule** |
| O que vale sempre, sem depender da tarefa | **rule** |
| Uma sequência de passos para executar um tipo de tarefa | **skill** |
| Um gatilho de comportamento ("antes de concluir, faça X") | **skill** |
| Contexto e fronteiras de um projeto específico | **rule** (`project-<nome>`) |

Na dúvida: se a frase cabe na forma "neste projeto, X é sempre Y", é rule.

## Fluxo

1. Confirme que é rule e não skill, pela tabela acima.
2. Escolha o nome em kebab-case, com prefixo de tópico:
   - `naming-structure-<linguagem>` — nomenclatura, estrutura e ambiente de uma linguagem;
   - `coding-<tema>` — política transversal de código (ex.: `coding-language-english`);
   - `project-<nome>` — contexto, fronteiras e convenções de um projeto;
   - outro prefixo claro quando nenhum servir. Uma rule por arquivo, pasta `rules/` plana.
3. Verifique se o tema já não é coberto por outra rule. **Regra duplicada em dois arquivos é regra que diverge** — estenda a existente em vez de criar irmã.
4. Parta de `templates/rule/RULE.md`.
5. Escreva o frontmatter seguindo **Frontmatter** abaixo, e **valide o YAML** antes de seguir.
6. Escreva o corpo seguindo **Estrutura do corpo** abaixo.
7. Quando a rule fixar ferramenta, versão ou layout que seja caro reverter neste projeto, verifique se a decisão já tem ADR em `docs/decisoes/`. Se não tiver, escreva a rule com o default e **diga na resposta final que é default revisável**, não decisão tomada.
8. Rode `./scripts/sync-skills.sh` e confirme o symlink nos quatro providers.

## Frontmatter

Dois campos: `name` (igual ao nome do arquivo, sem extensão) e `description`.

**A `description` vai entre aspas simples. Sempre.** Ela contém `Palavras-gatilho: ` e `Garante: `, e `": "` dentro de escalar YAML sem aspas é lido como mapa aninhado: o parser aborta, o leitor descarta a description, e **a rule deixa de disparar**. Foi o incidente de 17/09/2026, que atingia 21 dos 22 arquivos de `.agents/`.

Valide antes de encerrar — este comando é a verificação, não a leitura a olho:

```bash
python3 -c "
import pathlib, yaml, sys
ruins = []
for f in sorted(pathlib.Path('.agents').rglob('*.md')):
    t = f.read_text()
    if not t.startswith('---'): continue
    try:
        d = yaml.safe_load(t.split('---', 2)[1])
        assert isinstance(d, dict) and d.get('name') and d.get('description')
    except Exception as e:
        ruins.append((str(f), str(e).splitlines()[0]))
print('frontmatter invalido:', len(ruins))
[print(' ', *x) for x in ruins]
sys.exit(1 if ruins else 0)
"
```

Se a description tiver apóstrofo, dobre-o (`don''t`) ou use bloco `>-`.

### Diretrizes de description

A description é o gatilho de triagem: rule com description fraca não carrega quando deveria.

- **Palavras-gatilho concretas**, incluindo extensões de arquivo e nomes de ferramenta: `"cargo"`, `"pyproject.toml"`, `` `.c` ``.
- **Diga quando aplicar**: "Use quando criar/alterar projeto X, módulos, serviços, CLIs".
- **Diga o que garante**, em itens curtos separados por `;` — é o que o agente compara com a tarefa.
- **Diga o que vira DESVIO sem a rule**, em uma frase, no fim.
- Não escreva description genérica: `"Regras de Python"` não dispara nada.

## Estrutura do corpo

O corpo é escrito **em português sem acentos**, como todas as rules do repositório; a `description` usa acentos normalmente. Preserve esse padrão.

### Rule de linguagem (`naming-structure-<linguagem>`)

Quatro seções obrigatórias, nesta ordem:

| Seção | O que contém |
|---|---|
| `## Precedencia` | Convenção local existente > convenção do framework/biblioteca > esta rule. **Sempre primeiro** |
| `## Nomenclatura` | Caixa por tipo de identificador, nome de arquivo, e a regra de que o nome reflete o DOMINIO e não a interface (`cli`, `api`, `web` só no artefato de entrega) |
| `## Estrutura` | Layout de pastas, onde vive produção e teste, separação de domínio e IO |
| `## Ambiente` | Gerenciador, build, runner de teste, **linter nomeado** e **formatter nomeado**, com o comando |

Seções extras entram quando a linguagem tem um eixo próprio de risco — `## Tipagem` em TypeScript, `## Erro, recurso e memoria` em C. Use isso: a seção extra é onde a rule deixa de ser genérica.

### Rule de política (`coding-<tema>`) ou de projeto (`project-<nome>`)

Use `## Aplicacao`, `## Regra`, `## Excecoes Permitidas` e `## Checklist`. Deixe explícito o que **não** está no escopo — rule sem fronteira vira rule ignorada.

### Sempre

- Termine com `## Checklist` de itens verificáveis, não de intenções.
- Toda rule que mande instalar ferramenta **nomeia a ferramenta**: `ruff`, `clang-tidy`, `golangci-lint`. "Configure um linter" não é regra, é sugestão.
- Referencie rules e skills relacionadas pelo nome.

## Anti-padrões

Detectáveis por comando — rode antes de encerrar:

| Anti-padrão | Como detectar |
|---|---|
| Frontmatter que não parseia | o comando de validação acima |
| Rule de linguagem sem as quatro seções | `for f in .agents/rules/naming-structure-*.md; do for s in Precedencia Nomenclatura Estrutura Ambiente; do grep -q "^## $s" "$f" \|\| echo "$f sem $s"; done; done` |
| Rule sem checklist | `grep -L "^## Checklist" .agents/rules/<arquivo-que-voce-tocou>.md`. Rode no arquivo que voce criou ou alterou: oito rules importadas do skillset ainda nao tem checklist, e isso e debito herdado, nao motivo para reescrever rule alheia fora de escopo |
| `name` do frontmatter diferente do nome do arquivo | `for f in .agents/rules/*.md; do grep -q "^name: $(basename "$f" .md)$" "$f" \|\| echo "$f"; done` |
| Symlink de provider faltando ou órfão | `ls -l .claude/rules .cursor/rules .gemini/rules .github/rules` |
| Linter generico, sem ferramenta nomeada | `grep -n "Configure um linter\|algum linter\|linter adequado\|linter da stack" .agents/rules/*.md`. "Instale pelo menos um linter" **depois** de nomear as ferramentas nao e desvio |

### Exemplo: errado vs certo

**Errado** — description que não parseia e regra sem ferramenta nomeada:

```markdown
---
name: naming-structure-elixir
description: Regras de Elixir. Palavras-gatilho: "Elixir", "mix".
---

## Ambiente

- Configure um linter e um formatter adequados ao projeto.
```

**Certo** — description citada, com garantia e DESVIO, e ferramenta nomeada:

```markdown
---
name: naming-structure-elixir
description: 'Padrão de nomenclatura, estrutura e ambiente para projetos Elixir. Use quando criar/alterar projeto Elixir, aplicações OTP, bibliotecas ou CLIs. Palavras-gatilho: "Elixir", "mix", "mix.exs", "Phoenix", `.ex`, `.exs`. Garante: `snake_case` para funções e arquivos, `PascalCase` para módulos; layout `lib/` + `test/`; `mix format` e `credo` configurados. Sem linter nomeado, o projeto fica sem verificação de estilo — DESVIO.'
---

## Ambiente

- Formatter padrao: `mix format`, com `.formatter.exs` versionado.
- Linter padrao: `credo` (`mix credo --strict`). Em projeto novo, instale-o.
```

## Output verificável

A resposta final que cria ou altera rule inclui, obrigatoriamente:

| Item | Status |
|---|---|
| Frontmatter valida no parser YAML | ✅/❌ |
| Quatro seções presentes (rule de linguagem) | ✅/❌ |
| Linter e formatter nomeados | ✅/❌ |
| Checklist ao final | ✅/❌ |
| `./scripts/sync-skills.sh` executado e symlinks conferidos | ✅/❌ |

Mais a lista de defaults que a rule fixou **sem ADR**, explicitados como revisáveis. Com item vermelho, não use "pronto", "concluído" ou "completo": reporte como WIP.

## Auto-verificação antes de enviar

1. Rodei o comando de validação de frontmatter e ele saiu com zero inválidos? Se não, **VOLTE** e rode.
2. A description tem palavras-gatilho concretas, o que garante e o que vira DESVIO? Se não, **VOLTE** e endureça.
3. A rule nomeia ferramenta em vez de dizer "um linter"? Se não, **VOLTE** e nomeie.
4. Fixei ferramenta, versão ou layout caro de reverter sem ADR? Se sim, **diga isso na resposta**, como default revisável.
5. Rodei `./scripts/sync-skills.sh` e conferi os quatro symlinks? Se não, rode agora.

## Referências cruzadas

- Ver `workflow-criar-skills` para o outro lado do par — skills são procedimento, rules são convenção, e as duas skills compartilham o script de sync.
- Ver `quality-revisao-aderencia` para o formato de revisão final quando a tarefa também tocou código.
- Ver `workflow-gerenciar-dependencias` antes de fixar gerenciador ou lockfile numa rule nova — o padrão da stack já está decidido lá.
- Ver a rule `project-<nome>` do repositório, quando houver, para as convenções locais que a rule nova precisa respeitar — idioma da documentação, quando uma decisão vira ADR, e como registrar dado desconhecido. Neste repositório é `project-neo-midia`.

## Checklist

- Nome do arquivo em kebab-case, com prefixo de tópico, igual ao `name` do frontmatter.
- `description` entre aspas simples e validada por parser YAML.
- Description com palavras-gatilho, garantias e a frase de DESVIO.
- Rule de linguagem com `Precedencia`, `Nomenclatura`, `Estrutura` e `Ambiente`, nessa ordem.
- Precedência declarada antes de qualquer regra concreta.
- Linter e formatter nomeados, com comando.
- Nenhum tema duplicado com rule existente.
- Corpo em português sem acentos, como as rules vizinhas.
- `## Checklist` verificável ao final da rule.
- `./scripts/sync-skills.sh` executado e symlinks conferidos nos quatro providers.
- Output verificável incluído na resposta final.
