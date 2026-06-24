# ai-dev-skillset

Skill system multi-provider para coding agents: DDD, Clean Architecture, TDD, naming e estrutura por linguagem. Fonte única em `.agents/`, espelhada via symlinks para Claude Code, Cursor, Gemini e GitHub Copilot.

> **Aviso de instalação:** este `README.md` e o `LICENSE` são metadata do distribuidor — **não devem ir para o projeto-alvo**. Já `scripts/` faz parte do skillset (mantém os symlinks dos providers sincronizados quando você cria/remove skills) e **deve ser copiado**. Use uma das opções da seção [Como usar](#como-usar) — todas filtram corretamente.

---

## Por que existe

Agentes de IA escrevem código rápido, mas tendem a divergir em:

- **Arquitetura** — caem em layout `domain/application/interface` raso, ignoram bounded contexts, criam módulos genéricos `utils/helpers`.
- **Testes** — geram `expect(true).toBe(true)`, esquecem cobertura de branches, misturam unit/integration/e2e na mesma pasta.
- **Naming e estrutura** — usam o package manager errado, criam pastas com nome do projeto duplicando `src/`, deixam `any` espalhado em TypeScript.
- **Honestidade de conclusão** — declaram "completo" com débitos abertos, sem reportar o que ficou para trás.

Este repositório é um **conjunto curado e calibrado empiricamente** de skills (procedimentos) e rules (convenções) que faz o agente entregar código de produção consistente, independente do provider. Foi validado em ciclos iterativos contra Claude Code e Codex em cenários reais: criação one-shot, refatoração estrutural DDD e resolução de débitos técnicos.

## O que tem dentro

### Skills (`.agents/skills/`)

Procedimentos acionáveis carregados sob demanda pelo agente, baseados em palavras-gatilho:

| Skill | Quando dispara |
|---|---|
| `architecture-ddd-clean-arch` | Modelagem de domínio, casos de uso, aggregates, bounded contexts |
| `architecture-ddd-hexagonal` | Ports & adapters, composition root, isolamento de IO |
| `process-tdd` | Ciclo red-green-refactor, testes antes da implementação |
| `process-refatoracao-segura` | Refatoração com characterization tests, strangler pattern, migração de schema |
| `testing-coverage-quality` | Branches reais, target ≥80%, sem testes vazios |
| `quality-lint-format` | Linter/formatter da stack rodando limpos antes de fechar |
| `quality-revisao-aderencia` | Checklist objetiva de conclusão com formato `❌/✅`, frases proibidas se há débito |
| `workflow-iniciar-aplicacao` | Bootstrap de projeto novo (toolchain, runtime, manifest) |
| `workflow-gerenciar-dependencias` | Add/upgrade/remove via gerenciador padrão de cada stack |
| `workflow-criar-skills` | Meta-skill: como escrever/manter skills (description forte, triggers, anti-padrões detectáveis) |
| `documentation-modulos-projeto` | Quando documentar módulos e o que NÃO documentar |
| `greeting-bom-dia-combatente` | Saudação inicial obrigatória (verifica que o triage de skills está funcionando) |

### Rules (`.agents/rules/`)

Convenções estáticas carregadas conforme a linguagem detectada:

- `coding-language-english.md` — inglês como idioma exclusivo no código; mensagens ao usuário via i18n com `code` estável (snake_case en) + `Record<EnumDeCodigos, string>`.
- `naming-structure-typescript.md` — proibição de `any`, `strict: true`, layout `src/` + `tests/<tipo>/`, yarn como default.
- `naming-structure-javascript.md` — equivalente sem tipagem; ESLint ou Biome obrigatório.
- `naming-structure-python.md` — `uv` como default, `ruff` para lint+format, layout `src/<pacote>` na raiz (sem pasta intermediária).
- `naming-structure-go.md` — `cmd/<binário>/main.go` + `internal/<pacote>`, `golangci-lint`, package reflete domínio.
- `naming-structure-rust.md` — `cargo clippy -D warnings`, `cargo fmt`, crate name em `kebab-case`.
- `naming-structure-java.md` — layout Maven/Gradle padrão, Checkstyle + Spotless.
- `naming-structure-csharp.md` — analyzers do SDK com `TreatWarningsAsErrors`, `dotnet format`.
- `naming-structure-php.md` — PSR-4 + PSR-12, PHP_CodeSniffer + PHP-CS-Fixer (ou Laravel Pint).

### Templates (`templates/`)

Esqueletos para criar suas próprias skills/rules seguindo o mesmo padrão (frontmatter, seções opcionais comentadas, auto-verificação).

### Sincronização (`scripts/sync-skills.sh`)

Após adicionar/remover skill ou rule em `.agents/`, rode `./scripts/sync-skills.sh` para atualizar os symlinks dos providers. O script é idempotente e remove symlinks órfãos automaticamente.

## Como usar

### Opção A — Template do GitHub (recomendado para projeto novo)

1. Clique em **"Use this template"** no topo do repo.
2. Crie seu novo repo.
3. **Antes do primeiro commit**, apague `README.md` e (opcionalmente) `LICENSE` se quiser substituir pelo seu — são metadata do skillset, não do seu projeto. Mantenha `scripts/sync-skills.sh`, é ele que reconstrói os symlinks quando você cria novas skills.
4. Comece a desenvolver. O agente já vai detectar `.claude/`, `.cursor/`, etc.

### Opção B — Instalar em projeto existente via `degit`

```bash
# instala apenas as pastas que importam
npx degit gianverdum/ai-dev-skillset/.agents .agents
npx degit gianverdum/ai-dev-skillset/.claude .claude
npx degit gianverdum/ai-dev-skillset/.cursor .cursor
npx degit gianverdum/ai-dev-skillset/.gemini .gemini
npx degit gianverdum/ai-dev-skillset/.github .github
npx degit gianverdum/ai-dev-skillset/scripts scripts
npx degit gianverdum/ai-dev-skillset/templates templates
```

`degit` baixa só o conteúdo das pastas, sem `.git`, sem README. Nada para apagar depois.

### Opção C — Clone + cópia seletiva

```bash
git clone git@github.com:gianverdum/ai-dev-skillset.git /tmp/skillset
cd /caminho/do/seu/projeto
cp -r /tmp/skillset/.agents .
cp -r /tmp/skillset/.claude .
cp -r /tmp/skillset/.cursor .
cp -r /tmp/skillset/.gemini .
cp -r /tmp/skillset/.github .
cp -r /tmp/skillset/scripts .
cp -r /tmp/skillset/templates .
```

## Estrutura

```
.agents/                  ← single source of truth
  skills/<skill>/SKILL.md
  rules/<rule>.md
.claude/                  ← symlinks → .agents/
.cursor/                  ← symlinks → .agents/
.gemini/                  ← symlinks → .agents/
.github/                  ← symlinks → .agents/  (Copilot)
templates/
  skill/SKILL.md          ← esqueleto para nova skill
  rule/RULE.md            ← esqueleto para nova rule
scripts/
  sync-skills.sh          ← re-cria symlinks dos providers
```

**Edite sempre em `.agents/`.** Os outros diretórios são gerados.

## Compatibilidade

| Provider | Como consome |
|---|---|
| **Claude Code** | `.claude/skills/` e `.claude/rules/` (symlinks) |
| **Cursor** | `.cursor/skills/` e `.cursor/rules/` (symlinks) |
| **Gemini** | `.gemini/skills/` e `.gemini/rules/` (symlinks) |
| **GitHub Copilot** | `.github/skills/` e `.github/rules/` (symlinks) |

Para adicionar um provider novo, edite o array `providers=(…)` em `scripts/sync-skills.sh` e rode o script.

## Criando suas próprias skills

1. Copie `templates/skill/SKILL.md` para `.agents/skills/<categoria>-<nome>/SKILL.md`.
2. Preencha o `frontmatter` com **description forte**: comece com "OBRIGATÓRIO/SEMPRE" quando a skill deve disparar incondicionalmente, liste palavras-gatilho específicas, declare o que a skill **garante**.
3. No corpo, prefira **anti-padrões mecanicamente detectáveis** (regex, AST, comando shell) sobre conselhos conceituais — agente pula conceito, agente respeita regra com exemplo de código.
4. Adicione seção **"Output verificável"** quando aplicável: o que deve aparecer na resposta final do agente para provar que a skill foi seguida.
5. Rode `./scripts/sync-skills.sh` para propagar para os providers.

Veja `.agents/skills/workflow-criar-skills/SKILL.md` — é a meta-skill que documenta o processo, validada empiricamente.

## Princípio de design

As skills nascem da observação de **falhas reais** em sessões de coding agent. Cada regra existe porque algum agente, em algum momento, errou daquela forma específica. O ciclo é:

1. Agente entrega → humano avalia aderência → identifica gap.
2. Skill/rule é endurecida com o anti-padrão observado + exemplo mecânico.
3. Próxima iteração com prompt mais curto valida que a calibração pegou o caso.
4. Repete até a skill resistir a prompts mínimos.

Isso significa que o skillset é **opinativo por design** — não tenta cobrir todas as filosofias possíveis, e sim convergir em um conjunto coerente: DDD + Clean Arch + Hexagonal + TDD + linters obrigatórios + i18n + idioma único.

Se a sua opinião sobre alguma área for diferente, **forkar e ajustar é o caminho** — para isso este repo é template.

## Licença

MIT. Use, modifique, redistribua.
