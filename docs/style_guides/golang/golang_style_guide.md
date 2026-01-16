# Golang Style Guide

This document outlines the coding standards and best practices for Go (Golang) development within this project. Adhering to these guidelines ensures code consistency, readability, and maintainability.

## Table of Contents

1. [General Principles](#general-principles)
2. [Formatting](#formatting)
3. [Naming Conventions](#naming-conventions)
4. [Project Layout](#project-layout)
5. [Documentation and Comments](#documentation-and-comments)
6. [Error Handling](#error-handling)
7. [Concurrency](#concurrency)
8. [Interfaces](#interfaces)
9. [Testing](#testing)
10. [Dependencies](#dependencies)
11. [Performance and Optimization](#performance-and-optimization)
12. [Linting and Tooling](#linting-and-tooling)
13. [Common Mistakes and Gotchas](#common-mistakes-and-gotchas)

## General Principles

- **Simplicity**: Go is designed to be simple. Avoid over-engineering.
- **Readability**: Clear code is better than clever code.
- **Orthogonality**: Keep concepts independent.
- **Idiomatic Go**: Follow established conventions (e.g., [Effective Go](https://go.dev/doc/effective_go), [Go Code Review Comments](https://github.com/golang/go/wiki/CodeReviewComments)).
- **Explicit Dependencies**: Avoid magic or implicit behavior.

## Formatting

- **gofmt**: All code must be formatted with [`gofmt`](https://pkg.go.dev/cmd/gofmt) (or [`goimports`](https://pkg.go.dev/golang.org/x/tools/cmd/goimports)). This is non-negotiable.
- **Line Length**: Go has no strict line length limit, but avoid excessively long lines. Break long lines logically.
- **Imports**:
    - Group imports into standard library, third-party, and local packages.
    - Use `goimports` to manage imports automatically.

## Naming Conventions

- **Casing**: Use `MixedCaps` or `CamelCase`. Go does not use underscores in names (except in `_test.go` files or build tags).
    - Public (Exported): Starts with an uppercase letter (e.g., `ServeHTTP`).
    - Private (Unexported): Starts with a lowercase letter (e.g., `parseRequest`).
- **Package Names**: Short, concise, and lowercase. Avoid `util`, `common`, or `helpers`.
- **Interfaces**:
    - Single method interfaces should end in `-er` (e.g., `Reader`, `Writer`).
- **Variables**:
    - Short names for local variables with limited scope (e.g., `i` for loop index, `r` for reader).
    - More descriptive names for larger scopes.
- **Getters**: Do not use `Get` prefix.
    - Field: `owner`
    - Getter: `Owner()` (not `GetOwner`)
    - Setter: `SetOwner()`
- **Acronyms**: Keep acronyms consistently uppercased or lowercased.
    - Good: `ServeHTTP`, `IDProcessor`
    - Bad: `ServeHttp`, `IdProcessor`

## Project Layout

- **Standard Layout**: Follow the [Standard Go Project Layout](https://github.com/golang-standards/project-layout) where applicable.
    - `/cmd`: Main applications.
    - `/pkg`: Library code that's ok to use by external applications.
    - `/internal`: Private application and library code.
    - `/api`: OpenAPI/Swagger specs, JSON schema files, protocol definition files.
- **Grouping**: Group code by functionality (domain), not by type (e.g., avoid `models`, `controllers` packages unless warranted by specific framework patterns).

## Documentation and Comments

- **Godoc**: All exported types, variables, constants, and functions must have comments.
    - Comments should start with the name of the thing being described.
    - Example: `// Request represent an incoming HTTP request.`
- **Package Comments**: Every package should have a package comment in one of its files.
    - `// Package json implements encoding and decoding of JSON ...`
- **Notes**: Use `// TODO(User):` or `// FIXME:` to mark areas needing attention.

## Error Handling

- **Check Errors**: Always check errors. Never ignore them using `_`.
- **Handling**: Handle errors once. Wrap them to add context, or return them, or log them (at the top level).
- **Wrapping**: Use `%w` with `fmt.Errorf` to wrap errors for `errors.Is` and `errors.As` support.
    ```go
    if err != nil {
        return fmt.Errorf("failed to open file: %w", err)
    }
    ```
- **Custom Errors**: Define custom error types or sentinel errors for specific conditions.
- **Panic**: Avoid `panic` in library code. Only use it for unrecoverable errors during initialization or logical inconsistencies that should be caught by tests.

## Concurrency

- **Goroutines**: Start goroutines only when you know how they will stop. Avoid leaking goroutines.
- **Channels**: Use channels for orchestration and signaling.
- **Mutexes**: Use `sync.Mutex` or `sync.RWMutex` for protecting shared state.
- **Context**: Use `context.Context` for cancellation, timeouts, and passing request-scoped values.
    - Pass `ctx` as the first argument to functions.
    - Never store contexts in structs (except maybe for testing).
- **WaitGroups**: Use `sync.WaitGroup` to wait for a collection of goroutines to finish.

## Interfaces

- **Consumer Defined**: Interfaces should be defined where they are used (consumer side), not where they are implemented (producer side).
- **Small Interfaces**: Prefer small interfaces (often single method) over large ones.
- **Accept Interfaces, Return Structs**: Functions should generally accept interfaces and return concrete types.

## Testing

- **Package**: Use the standard [`testing`](https://pkg.go.dev/testing) package.
- **Naming**: Test files must end with `_test.go`. Test functions must start with `Test`.
- **Table-Driven Tests**: Use table-driven tests for covering multiple scenarios efficiently.
    ```go
    func TestAdd(t *testing.T) {
        tests := []struct {
            name string
            a, b int
            want int
        }{
            {"positive", 1, 2, 3},
            {"negative", -1, -1, -2},
        }
        for _, tt := range tests {
            t.Run(tt.name, func(t *testing.T) {
                if got := Add(tt.a, tt.b); got != tt.want {
                    t.Errorf("Add() = %v, want %v", got, tt.want)
                }
            })
        }
    }
    ```
- **Subtests**: Use `t.Run` for logical grouping and running specific tests.
- **Benchmarks**: Use `Benchmark` functions to measure performance.
- **Examples**: Use `Example` functions for documentation and verification.
- **Test Main**: Use `TestMain` only for global setup/teardown if absolutely necessary.

## Dependencies

- **Go Modules**: Use Go Modules (`go.mod`, `go.sum`) for dependency management.
- **Tidiness**: Run `go mod tidy` regularly to keep dependencies clean.
- **Vendoring**: Vendor dependencies (`go mod vendor`) if the project requires reproducible builds without relying on external proxies (optional).

## Performance and Optimization

- **Preallocation**: Preallocate slices and maps if the size is known.
    ```go
    // Bad
    var data []int

    // Good
    data := make([]int, 0, expectedSize)
    ```
- **Pointers**: Use pointers for large structs to avoid copying, but be aware of escape analysis and garbage collection pressure.
- **Defer**: `defer` has a small overhead. Avoid it in tight loops if performance is critical.

## Linting and Tooling

- **Linter**: Use [`golangci-lint`](https://golangci-lint.run/) with a robust configuration.
    - Enabled linters: `govet`, `staticcheck`, `errcheck`, `ineffassign`, `gocyclo`, `gocritic`, `revive`.
- **Editor Integration**: Use [`gopls`](https://github.com/golang/tools/blob/master/gopls/README.md) (Go Language Server) for autocomplete, formatting, and refactoring.

## Common Mistakes and Gotchas

- **Loop Variables**: Be careful capturing loop variables in closures (fixed in Go 1.22+).
- **Nil Interfaces**: A nil interface is not the same as an interface containing a nil pointer.
- **Slice Memory Leaks**: Reslicing a large array/slice can keep the underlying array in memory. Copy explicitly if needed.


## Related Interview Questions

*   **[Practice Questions](../../interview_questions/golang.md)**: Test your knowledge of Golang concepts.
