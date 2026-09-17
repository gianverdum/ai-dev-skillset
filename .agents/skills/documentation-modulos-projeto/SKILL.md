---
name: documentation-modulos-projeto
description: 'Criar e manter documentação clara e enxuta do projeto e de seus módulos. OBRIGATORIO ao iniciar ou alterar qualquer aplicação, CLI, serviço, módulo, biblioteca, arquitetura, estrutura de pastas, configuração, comandos de uso ou tecnologias do projeto. Palavras-gatilho: "crie", "inicie", "adicione módulo", "extraia BC", "novo projeto", "novo módulo", "novo serviço", "reorganize", "refatore", "altere estrutura". Garante que README da raiz e de cada módulo de aplicação exista e reflita o estado atual; submódulos de camada (domain/application/interface) NÃO recebem README próprio. Sem README atualizado, módulo novo está incompleto — DESVIO.'
---

# Documentação de Projeto e Módulos

Mantenha documentação suficiente para orientar manutenção sem repetir o código.

## Regras

- Atualize documentação na mesma mudança que altera estrutura, arquitetura, tecnologia, configuração, comandos ou comportamento relevante.
- Prefira documentação curta, objetiva e verificável.
- Não documente detalhes óbvios de implementação, histórico de decisões pequenas ou listas completas que envelhecem rápido.
- Se uma informação puder ficar incorreta facilmente, documente o princípio, contrato ou comando canônico.
- Ao documentar estrutura ou nomenclatura, use o padrão local e, quando ele não existir, a rule da linguagem em `.agents/rules`.

## Raiz do Projeto

Crie ou mantenha `README.md` na raiz com:

- o que é o projeto;
- tecnologias principais;
- estrutura de pastas em alto nível;
- convenções de nomenclatura e estrutura adotadas quando elas forem relevantes para manutenção;
- arquitetura usada e responsabilidades das camadas;
- instruções mínimas de configuração;
- comandos de execução, teste e validação.
- o gerenciador de dependências e ambiente usado pelo projeto, quando existir.

## Módulos

Cada módulo de aplicação deve ter um `README.md` próprio. Módulo aqui é o pacote principal entregue dentro de `src/` (em monorepo, cada projeto em `apps/<nome>/`, `packages/<nome>/` ou `services/<nome>/`). Submódulos de camada como `domain`, `application`, `interface`, `adapters` ou equivalentes NÃO recebem `README.md` próprio: a estrutura de camadas é documentada no README do módulo. README de módulo não é opcional: a tarefa só está concluída quando cada módulo novo tem o seu. Cada `README.md` de módulo contém:

- responsabilidade do módulo;
- principais entradas e saídas;
- estrutura interna relevante;
- regras de domínio ou casos de uso centrais;
- comandos específicos do módulo, quando existirem;
- dependências externas ou integrações importantes.
- comandos canônicos pelo ambiente do projeto, como `uv run` em Python.

## Manutenção

- Ao criar módulo novo, crie seu `README.md` na mesma mudança que cria os arquivos de código do módulo, antes de encerrar a tarefa. Vale para o pacote principal do módulo; submódulos de camada são descritos dentro desse README, não em arquivos próprios.
- Ao mover arquivos entre camadas ou pastas, ajuste a documentação afetada.
- Ao definir estrutura nova, alinhe o texto ao padrão descrito na rule da linguagem aplicável.
- Ao adicionar comando, dependência, variável de ambiente ou tecnologia, atualize o `README.md` mais próximo e o da raiz quando impactar o projeto todo.
- Em Python, documente comandos com `uv run` e não com `PYTHONPATH`, `pip install` ou ativação manual de ambiente, salvo padrão existente justificado.
- Ao remover comportamento ou módulo, remova ou corrija documentação obsoleta.

## Checklist

- A raiz tem `README.md` com resumo, estrutura, arquitetura, tecnologia, configuração e uso.
- Cada módulo de aplicação criado ou alterado tem `README.md` enxuto e atualizado; submódulos de camada não recebem README próprio.
- A documentação não duplica código nem descreve detalhes triviais.
- Convenções de estrutura e nomenclatura documentadas seguem o padrão local ou a rule da linguagem.
- Comandos documentados foram validados quando possível.
- Comandos Python documentados usam `uv run` quando aplicável.
