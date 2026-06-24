---
name: naming-structure-go
description: Padrão de nomenclatura, estrutura e ambiente para projetos Go quando não houver convenção local mais específica. Use quando criar/alterar projeto Go, pacotes, serviços, CLIs ou bibliotecas. Palavras-gatilho: "Go", "Golang", "go.mod", "cmd/", "internal/", "go test", "gofmt", "golangci-lint", `.go`. Garante: pacotes em minúsculas curtas sem underscore, `camelCase` não-exportado e `PascalCase` exportado; layout `cmd/<binário>/main.go` + `internal/<pacote>`; tests colocalizados (`foo_test.go`); `golangci-lint` como linter (não só `go vet`); `go.mod` + `go.sum`; nome do pacote reflete domínio (sufixos `cli`/`api`/`grpc` só em `cmd/<nome>-<entrega>/`).
---

# Go Naming And Structure

Use esta rule ao criar ou reorganizar projetos Go, servicos, CLIs ou bibliotecas.

## Precedencia

- Preserve a convencao ja existente no repositorio.
- Siga a convencao da biblioteca ou framework quando ela existir.
- Na ausencia de padrao local, aplique esta rule.

## Nomenclatura

- Use nomes de pacotes curtos, em minusculas, sem underscore, hifen ou plural desnecessario.
- Use `camelCase` para identificadores nao exportados e `PascalCase` para identificadores exportados.
- Use nomes exportados que leiam bem com o nome do pacote.
- O nome do pacote reflete o DOMINIO, nao a tecnologia de entrega. Sufixos como `cli`, `api`, `web`, `rest`, `grpc` NAO entram no nome do pacote em `internal/<pacote>` ou `pkg/<pacote>`; ficam apenas no binario sob `cmd/<nome>-<entrega>/` quando precisar distinguir. Exemplo: pacote `payments` exposto via `cmd/payments-api/main.go`.
- Use arquivos em `snake_case.go` apenas quando precisar separar palavras; prefira nomes curtos e claros.
- Nomeie testes como `<arquivo>_test.go`.
- Evite pacotes genericos como `common`, `utils`, `helpers` e `models` quando houver responsabilidade mais clara.

## Estrutura

- Mantenha `go.mod` na raiz do modulo.
- Para CLIs e servicos executaveis, use `cmd/<nome>/main.go`.
- Use `internal/` para codigo privado ao modulo ou aplicacao.
- Use `pkg/` apenas quando houver API reutilizavel por outros modulos; nao crie `pkg/` por padrao.
- Coloque testes junto ao pacote testado.
- Em projetos com dominio relevante, separe dominio e casos de uso de handlers HTTP, CLI, banco e clients externos.

## Ambiente

- Use `go test ./...` como validacao padrao.
- Formate com `gofmt` ou `go fmt ./...`.
- Linter padrao: `golangci-lint` (agrega `vet`, `staticcheck`, `errcheck`, `ineffassign` e outros). Instale e configure `.golangci.yml` em projeto novo. Mantenha `go vet ./...` como validacao minima quando `golangci-lint` nao puder ser instalado.
- Mantenha dependencias em `go.mod` e `go.sum`.
