# Rust Style Guide

This document outlines the coding standards and best practices for Rust development within this project. Adhering to these guidelines ensures code consistency, safety, performance, and maintainability.

## Table of Contents

1. [General Principles](#general-principles)
2. [Code Layout](#code-layout)
3. [Naming Conventions](#naming-conventions)
4. [Documentation](#documentation)
5. [Types and Traits](#types-and-traits)
6. [Error Handling](#error-handling)
7. [Ownership and Borrowing](#ownership-and-borrowing)
8. [Concurrency](#concurrency)
9. [Unsafe Code](#unsafe-code)
10. [Modules and Crates](#modules-and-crates)
11. [Macros](#macros)
12. [Testing](#testing)
13. [Dependencies](#dependencies)
14. [Recommended Tools](#recommended-tools)

## General Principles

- **Safety**: Leverage the type system and borrow checker to ensure memory safety and thread safety. Avoid `unsafe` unless absolutely necessary.
- **Performance**: Aim for zero-cost abstractions. Use the most efficient algorithms and data structures suitable for the task.
- **Fearless Concurrency**: Use Rust's ownership model to write concurrent code without data races.
- **Idiomatic Rust**: Write "Rustacean" code. Follow community standards and idioms (e.g., using iterators, pattern matching, RAII).
- **Clarity**: Code should be easy to understand. Explicit is better than implicit.

## Code Layout

- **Formatting**: Use [`rustfmt`](https://github.com/rust-lang/rustfmt) with default settings. Do not manually format code in ways that `rustfmt` would undo.
- **Indentation**: Use 4 spaces for indentation.
- **Line Length**: Limit lines to 100 characters (default `rustfmt` setting).
- **Braces**: Use K&R style braces (1tbs). Opening brace on the same line, closing brace on its own line.
- **Imports**:
    - Group imports by crate.
    - Use `std`, `external_crate`, `crate`, `super`, `self` order.
    - Avoid wildcard imports (`use foo::*;`) except for preludes or tests.
- **Match Arms**: Comma-separate match arms. Use braces for multi-line arms.

```rust
// Good
use std::collections::HashMap;
use std::sync::Arc;

use serde::{Deserialize, Serialize};

use crate::models::User;
```

## Naming Conventions

- **Variables/Functions/Modules**: `snake_case`
- **Types/Traits/Enum Variants**: `UpperCamelCase` (PascalCase)
- **Constants/Statics**: `SCREAMING_SNAKE_CASE`
- **Lifetimes**: `'short_lowercase` (e.g., `'a`, `'ctx`)
- **Macros**: `snake_case!`
- **Getters**: Use `field_name()` not `get_field_name()`.
- **Conversion**: `as_type()` (borrowed), `to_type()` (owned/expensive), `into_type()` (consuming).
- **Constructors**: `new()` for the primary constructor. `with_params()` for others.

```rust
struct UserConfig {
    max_retries: u32,
}

impl UserConfig {
    pub fn new() -> Self { ... }
    pub fn max_retries(&self) -> u32 { self.max_retries }
}
```

## Documentation

- **Doc Comments**: Use `///` for documenting items (functions, structs, enums) and `//!` for documenting the containing module/crate.
- **Format**: Use Markdown. The first line should be a concise summary.
- **Sections**:
    - `# Examples`: Show how to use the item. These are run as doctests.
    - `# Panics`: Document conditions under which the function may panic.
    - `# Errors`: Document the error conditions and types returned.
    - `# Safety`: Mandatory for `unsafe` functions. Explain the invariants the caller must uphold.
- **Completeness**: All public items (`pub`) must be documented.

```rust
/// Divides two numbers.
///
/// # Examples
///
/// ```
/// let result = my_crate::div(10, 2);
/// assert_eq!(result, Some(5));
/// ```
///
/// # Panics
///
/// Panics if `b` is 0.
pub fn div(a: i32, b: i32) -> i32 {
    if b == 0 {
        panic!("division by zero");
    }
    a / b
}
```

## Types and Traits

- **Newtype Pattern**: Use tuple structs (`struct UserId(u64);`) to enforce type safety and avoid primitives obsession.
- **Generics vs Trait Objects**: Prefer generics (static dispatch) for performance. Use trait objects (`Box<dyn Trait>`) when you need dynamic dispatch or heterogeneous collections.
- **Standard Traits**: Implement standard traits like `Debug`, `Clone`, `Default`, `PartialEq` whenever appropriate. Use `#[derive(...)]`.
- **From/Into**: Implement `From<T>` (which gives you `Into<T>` for free) for fallible type conversions. Implement `TryFrom` for fallible conversions.
- **AsRef/Borrow**: Use `AsRef` for argument types to accept different representations (e.g., `path: impl AsRef<Path>`).

## Error Handling

- **Result**: Use `Result<T, E>` for recoverable errors.
- **Option**: Use `Option<T>` for values that may be absent.
- **Unwrap/Expect**: Avoid `unwrap()` in production code. Use `expect("reason")` if you are certain it cannot fail (and explaining why helps). In tests, `unwrap()` is acceptable.
- **Error Types**:
    - For libraries: Define custom error enums using [`thiserror`](https://github.com/dtolnay/thiserror). Expose a public `Error` type.
    - For applications: Use [`anyhow`](https://github.com/dtolnay/anyhow) for easy error handling and context propagation.
- **Question Mark**: Use the `?` operator for error propagation.
- **Panics**: Only panic for unrecoverable errors (bugs, violated invariants).

```rust
use anyhow::{Context, Result};

fn read_config(path: &str) -> Result<String> {
    std::fs::read_to_string(path)
        .with_context(|| format!("Failed to read config from {}", path))
}
```

## Ownership and Borrowing

- **Borrowing**: Prefer borrowing (`&T`) over taking ownership (`T`) if the function doesn't need to consume the value.
- **Cloning**: Avoid explicit `clone()` calls unless necessary. If a type is cheap to copy, implement `Copy`.
- **Lifetimes**: Elide lifetimes where possible. Use descriptive lifetime names if there are multiple or complex relationships.
- **Interior Mutability**: Use `Cell` or `RefCell` for single-threaded interior mutability. Use `Mutex` or `RwLock` for multi-threaded scenarios.

## Concurrency

- **Send/Sync**: Understand `Send` (safe to move to another thread) and `Sync` (safe to share between threads). Most types are automatically both.
- **Async/Await**: Use `async`/`await` for I/O-bound tasks.
- **Runtimes**: We prefer [`tokio`](https://tokio.rs/) as the standard async runtime.
- **Channels**: Use channels (`tokio::sync::mpsc`) for message passing between tasks instead of sharing memory.
- **Blocking**: Never block an async thread. Use `tokio::task::spawn_blocking` for CPU-intensive or blocking synchronous operations.

## Unsafe Code

- **Avoid**: Use `unsafe` only when absolutely necessary (e.g., FFI, low-level optimizations verified by benchmarks).
- **Isolation**: Keep `unsafe` blocks as small as possible.
- **Safety Comments**: Every `unsafe` block MUST be preceded by a `// SAFETY:` comment explaining why the operation is safe and how invariants are maintained.
- **API Safety**: Ensure that `unsafe` blocks inside a safe function do not expose undefined behavior to the caller.

```rust
// SAFETY: We checked that `index` is within bounds.
unsafe {
    *ptr.add(index)
}
```

## Modules and Crates

- **Visibility**: Minimize visibility. Use `pub(crate)` for items shared within the crate but not exposed publicly.
- **Prelude**: If your library has many commonly used items, consider providing a `prelude` module.
- **Structure**:
    - Place unit tests in a `tests` module within the same file (`#[cfg(test)]`).
    - Place integration tests in the `tests/` directory at the crate root.
    - Avoid deep module nesting.

## Macros

- **Usage**: Use macros sparingly. Prefer functions and generics where possible.
- **Declarative**: Use `macro_rules!` for simple pattern matching macros.
- **Procedural**: Use procedural macros (derive, attribute, function-like) for complex code generation, but be mindful of compile times.

## Testing

- **Unit Tests**: Write unit tests for all private and public logic. Keep them in the same file as the code.
- **Integration Tests**: Test the public API in `tests/`.
- **Property-Based Testing**: Consider [`proptest`](https://github.com/proptest-rs/proptest) for testing a wide range of inputs.
- **Mocking**: Use [`mockall`](https://github.com/asomers/mockall) for mocking traits in tests.
- **Doctests**: Ensure examples in documentation compile and pass.

## Dependencies

- **Selection**: Choose well-maintained, popular crates (check downloads, recent updates).
- **Audit**: Use [`cargo audit`](https://github.com/rustsec/rustsec/tree/main/cargo-audit) to check for security vulnerabilities.
- **Features**: Disable unused features to reduce compile times and binary size (`default-features = false`).
- **Heavy Dependencies**: Be cautious with heavy dependencies like `serde`, `tokio`, `syn`. Only include what you need.

## Recommended Tools

- **Format**: [`rustfmt`](https://github.com/rust-lang/rustfmt) (standard formatter).
- **Lint**: [`clippy`](https://github.com/rust-lang/rust-clippy) (catch common mistakes and improve code). Run `cargo clippy` in CI.
- **Check**: `cargo check` (fast compilation check).
- **Test**: `cargo test`.
- **Audit**: `cargo audit` (security).
- **Expand**: [`cargo expand`](https://github.com/dtolnay/cargo-expand) (view macro expansion).
- **IDE**: [`rust-analyzer`](https://rust-analyzer.github.io/) (LSP).
