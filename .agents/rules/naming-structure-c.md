---
name: naming-structure-c
description: 'Padrão de nomenclatura, estrutura, tratamento de erro e ambiente para projetos em C quando não houver convenção local mais específica. Use quando criar/alterar código C — serviços, daemons, CLIs, bibliotecas e código que fala direto com o kernel (DRM/KMS, V4L2, sockets). Palavras-gatilho: "C", "gcc", "clang", "Makefile", "meson", "CMake", "header", "struct", "ponteiro", "malloc", "ioctl", "dmabuf", "segfault", `.c`, `.h`. Garante: `snake_case` em tudo e `UPPER_SNAKE_CASE` em macro/enum; todo símbolo externo com prefixo de módulo (C não tem namespace) e o resto `static`; par `.c`/`.h` por módulo; domínio separado de `ioctl`/`open`/`socket`; retorno de erro como enum tipada em inglês, nunca `int` cru nem string; todo retorno de `malloc`/`open`/`ioctl` checado; liberação por `goto cleanup`; `-Wall -Wextra -Werror` + sanitizers na suíte; `clang-format` e `clang-tidy` configurados. Sem código de erro tipado, sem checagem de retorno e sem liberação no caminho de erro, o código vaza ou falha em silêncio — DESVIO.'
---

# C Naming And Structure

Use esta rule ao criar ou reorganizar projetos em C: servicos, daemons, CLIs,
bibliotecas e codigo que conversa direto com o kernel.

## Precedencia

- Preserve a convencao ja existente no repositorio.
- Siga a convencao da biblioteca de sistema que o codigo estende ou embrulha.
  POSIX, `libdrm`, V4L2 e o kernel usam `snake_case`; codigo que vive ao lado
  deles nao inventa outro estilo.
- **Prototipo descartavel nao estabelece convencao.** Codigo em `poc/` existe
  para provar um caminho e morrer; nao o cite como padrao do projeto.
- Na ausencia de padrao local, aplique esta rule.

## Nomenclatura

- Use `snake_case` para funcoes, variaveis, parametros, campos de struct e nomes
  de arquivo.
- Use `UPPER_SNAKE_CASE` para macros, constantes de `#define` e membros de `enum`.
- **C nao tem namespace, entao o prefixo faz esse papel.** Todo simbolo com
  ligacao externa carrega o prefixo do modulo: `display_plane_commit`,
  `playlist_next_item`. Simbolo sem prefixo e `static`, sem excecao.
- Tudo que nao faz parte da API do modulo e `static`. Em C, `static` e a unidade
  de encapsulamento: o que nao e `static` e contrato publico.
- Prefira `struct display` explicito. Se usar `typedef`, nomeie
  `<prefixo>_<nome>` e **nao** termine em `_t` — esse sufixo e reservado pelo
  POSIX.
- Nomeie `enum` e seus membros pelo dominio, com o prefixo do modulo nos membros:
  `enum sync_error { SYNC_OK, SYNC_ERR_TIMEOUT }`.
- Um par `.c`/`.h` por modulo, com o nome igual ao prefixo do modulo.
- Todo header tem guarda. Escolha `#pragma once` **ou**
  `#ifndef <PROJETO>_<MODULO>_H` e use a mesma forma no projeto inteiro.
- Nome do modulo, do arquivo e do binario reflete o DOMINIO, nao a interface.
  Sufixos como `cli`, `api`, `web` ou `d` de daemon aparecem apenas no nome do
  executavel (ex.: modulo `playlist`, binario `playlist-cli`).
- Evite abreviacao obscura e nome de uma letra fora de indice de laco.
- Nomeie testes como `test_<modulo>.c` ou `<modulo>_test.c`, conforme o runner.

## Estrutura

- Codigo de producao em `src/`, um `.c` por modulo com o `.h` correspondente.
- Header publico de biblioteca em `include/<projeto>/`; header interno fica ao
  lado do `.c` que o implementa.
- `main.c` e **composition root**: leitura de argumento, wiring e encerramento.
  Sem regra de negocio.
- **Separe dominio de IO.** O codigo que decide — agendamento, playlist,
  orcamento, maquina de estado — nao chama `ioctl`, `open`, `socket` nem
  `mmap`. Quem fala com DRM, V4L2, disco e rede vive em modulos de adapter, e o
  dominio os recebe por ponteiro de struct ou tabela de funcoes.
- `tests/` no mesmo nivel de `src/`, agrupado por tipo (`tests/unit/`,
  `tests/integration/`) e espelhando a estrutura de `src/` dentro de cada um.
- Manifesto de build na raiz do modulo.
- Prototipo descartavel em `poc/<nome>/`, fora de `src/`, com README dizendo
  que e descartavel e o que ele prova.

## Erro, recurso e memoria

Esta secao e o que separa C de linguagem com excecao e coletor de lixo. Cada
item aqui produz defeito real quando ignorado.

- Toda funcao que pode falhar devolve **codigo de erro**. `void` so em funcao
  que nao tem como falhar.
- O codigo de erro e uma **`enum` explicita, em ingles**, nunca `int` cru com
  numero magico nem string de mensagem. Dominio e application devolvem o codigo;
  a camada de interface resolve para texto humano — ver
  `.agents/rules/coding-language-english.md`.
- **Todo retorno de `malloc`, `calloc`, `open`, `ioctl`, `mmap`, `read` e
  `write` e checado.** Ignorar retorno de chamada que pode falhar e DESVIO.
- Libere recurso tambem no caminho de erro, pelo idioma `goto cleanup` — e o
  padrao do kernel e o mais legivel em C.
- **Dono do ponteiro declarado no header.** Quem aloca, quem libera, e o que
  acontece com a posse na chamada. Funcao que transfere posse registra isso na
  declaracao.
- Use `const` em todo parametro que a funcao nao modifica.
- Use tipos de largura fixa de `<stdint.h>` quando o tamanho importa, `size_t`
  para tamanho e `ssize_t` para retorno que pode ser `-1`.
- Proibidos: `strcpy`, `strcat`, `sprintf`, `gets` e `atoi`. Use `snprintf` e
  `strtol` com checagem de `errno`.
- Sem variavel global mutavel: o estado vive em struct passada por ponteiro.
- Sem VLA e sem `alloca`: em stack pequena de servico embarcado, o estouro nao
  avisa.

### Padrao em codigo

**Errado** — codigo de erro cru, retorno ignorado e vazamento no caminho de erro:

```c
int pe_open(const char *path) {
    int fd = open(path, O_RDWR);
    struct buffer *b = malloc(sizeof(*b));   /* retorno nao checado */
    if (ioctl(fd, VIDIOC_QUERYCAP, &cap) < 0) {
        fprintf(stderr, "Falha ao abrir o dispositivo.\n");  /* mensagem no dominio, em pt-BR */
        return -1;                            /* -1 generico: quem chama nao sabe o que houve */
    }
    return fd;                                /* b vaza em todo caminho */
}
```

**Certo** — enum de erro, checagem de tudo e `goto cleanup`:

```c
/* device.h */
enum device_error {
    DEVICE_OK = 0,
    DEVICE_ERR_OPEN,
    DEVICE_ERR_UNSUPPORTED,
    DEVICE_ERR_NO_MEMORY,
};

/* device.c — devolve o codigo; a interface traduz para texto */
enum device_error device_open(const char *path, struct device *out) {
    enum device_error err = DEVICE_OK;
    struct buffer *buf = NULL;

    int fd = open(path, O_RDWR);
    if (fd < 0)
        return DEVICE_ERR_OPEN;

    buf = calloc(1, sizeof(*buf));
    if (buf == NULL) {
        err = DEVICE_ERR_NO_MEMORY;
        goto cleanup;
    }

    struct v4l2_capability cap;
    if (ioctl(fd, VIDIOC_QUERYCAP, &cap) < 0) {
        err = DEVICE_ERR_UNSUPPORTED;
        goto cleanup;
    }

    out->fd = fd;          /* posse do fd passa para `out` */
    out->buf = buf;        /* posse de buf passa para `out` */
    return DEVICE_OK;

cleanup:
    free(buf);
    close(fd);
    return err;
}
```

## Ambiente

- Declare o padrao da linguagem no build: **C11** (`-std=c11`), salvo exigencia
  do toolchain.
- Compile com `-Wall -Wextra -Werror` desde o primeiro commit. Aviso acumulado
  vira ruido e para de ser lido.
- Build: preserve o existente. Em projeto novo, **Meson + Ninja** — e o que
  `libdrm`, `GStreamer` e o ecossistema grafico do Linux usam, e o `pkg-config`
  vem junto. `CMake` e alternativa aceitavel quando a integracao de toolchain
  exigir; registre o motivo na resposta final.
- Declare tarefas de `build`, `test`, `lint` e `format`.
- Linter padrao: `clang-tidy`, configurado em `.clang-tidy` versionado.
  Complemente com `cppcheck`. Em projeto novo, instale pelo menos um.
- Formatter padrao: `clang-format`, com `.clang-format` versionado na raiz.
  Rode antes de encerrar a tarefa.
- Compile o binario de teste com `-fsanitize=address,undefined` e rode a suite
  com os sanitizers ligados. Use `valgrind` quando o sanitizer nao servir —
  cross-compile, ou codigo que mapeia `dmabuf`.
- Declare dependencia de sistema por `pkg-config` no build, nunca por caminho
  absoluto na linha de compilacao.

## Anti-padroes (DESVIO claro)

| Anti-padrao | Por que e DESVIO |
|---|---|
| Funcao com ligacao externa sem prefixo de modulo | Colide no link e some do grep; C nao tem namespace para socorrer |
| Retorno de `malloc`, `open` ou `ioctl` ignorado | A falha aparece depois, em outro lugar, como corrupcao |
| `return -1` como unico codigo de erro | Quem chama nao consegue decidir nada, e a mensagem vira chute |
| `fprintf(stderr, ...)` com texto humano dentro do dominio | Mistura decisao com apresentacao; a mensagem e da interface |
| Header sem guarda | Inclusao dupla quebra o build de um jeito que nao aponta a causa |
| `free` so no caminho feliz | Vazamento que so aparece sob falha, que e quando menos se quer investigar |
| Variavel global mutavel para estado do modulo | Impede teste, impede segunda instancia e esconde dependencia |

## Checklist

- Todo simbolo externo tem prefixo de modulo; o resto e `static`.
- Todo header tem guarda, na mesma forma usada no projeto.
- O dominio nao chama `ioctl`, `open`, `socket` nem `mmap`.
- Toda funcao que pode falhar devolve `enum` de erro em ingles, e nenhuma
  mensagem humana mora no dominio.
- Todo retorno de alocacao e de chamada de sistema e checado.
- Todo caminho de erro libera o que alocou.
- O build compila com `-Wall -Wextra -Werror`, e lint e format rodaram limpos.
