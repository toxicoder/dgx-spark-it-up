# Starlark Style Guide

This document outlines the coding standards and best practices for Starlark development (used in Bazel, Buck2, etc.) within this project. Adhering to these guidelines ensures code consistency, readability, and maintainability.

## Table of Contents

1. [General Principles](#general-principles)
2. [Code Layout](#code-layout)
3. [Naming Conventions](#naming-conventions)
4. [Build Files vs. Extensions](#build-files-vs-extensions)
5. [Load Statements](#load-statements)
6. [Macros and Rules](#macros-and-rules)
7. [Functions](#functions)
8. [Data Structures](#data-structures)
9. [Control Flow](#control-flow)
10. [Error Handling](#error-handling)
11. [Documentation](#documentation)
12. [Tooling](#tooling)

## General Principles

- **Hermeticity**: Starlark code should be hermetic. Outputs should depend only on inputs and configuration, not on the external environment (timestamps, network, absolute paths).
- **Determinism**: Execution must be deterministic. Iteration order of dictionaries is fixed in Starlark, but be mindful of sets (which don't exist in Starlark, use `depset` or sorted lists).
- **Readability**: Starlark is optimized for readability. It is often read by developers who are not experts in the build system. Keep logic simple.
- **Pythonic**: Starlark is a dialect of Python. Follow Python best practices (PEP 8) where they apply and don't conflict with Starlark specifics.

## Code Layout

- **Indentation**: Use 4 spaces for indentation. Do not use tabs.
- **Line Length**: Limit lines to 79 characters. This is the standard for `.bzl` and `BUILD` files (enforced by Buildifier).
- **Whitespace**:
    - Use spaces around operators (`=`, `+`, `+=`, etc.).
    - No spaces around keyword argument assignments in calls (`func(arg=value)`), but spaces around default values in definitions (`def func(arg = value):`).
- **Blank Lines**:
    - Use blank lines to separate rules and macro calls in `BUILD` files.
    - Use 2 blank lines between top-level function definitions in `.bzl` files.
- **Trailing Commas**: Always use trailing commas in multi-line lists, dictionaries, and function calls. This reduces merge conflicts and makes reordering easier.

```python
# Good
my_rule(
    name = "my_target",
    srcs = [
        "file1.cc",
        "file2.cc",
    ],
    deps = [
        ":lib",
    ],
)
```

## Naming Conventions

- **Variables/Functions**: `snake_case`.
- **Rules/Macros**: `snake_case`.
- **Providers**: `PascalCase` (e.g., `MyInfo`).
- **Constants**: `UPPER_CASE` (e.g., `DEFAULT_TIMEOUT`).
- **Private Symbols**: Prefix with `_` (underscore). These are not exported from the `.bzl` file.
    - `def _my_private_helper():`
- **Filenames**:
    - Build files: `BUILD` or `BUILD.bazel`.
    - Extension files: `snake_case.bzl`.

## Build Files vs. Extensions

- **BUILD Files**:
    - Should be declarative.
    - Avoid complex logic (loops, `if` statements) in `BUILD` files. Move logic to macros in `.bzl` files.
    - Variable definitions should be minimal.
- **.bzl Files**:
    - Can contain logic, function definitions, rules, and macros.
    - Should be organized logically (loads, constants, providers, implementation functions, rule definitions, macros).

## Load Statements

- **Placement**: All `load()` statements must be at the top of the file, after the license header and docstring.
- **Sorting**: Load statements should be sorted alphabetically by the label (first argument).
- **Symbols**: Symbols loaded from a file should be sorted alphabetically.
- **Format**:

```python
load("@rules_cc//cc:defs.bzl", "cc_binary", "cc_library")
load("//path/to/package:defs.bzl", "my_macro")
```

- **Aliases**: Avoid aliasing unless necessary for disambiguation. If used, follow `original_name = "alias"` (which is not supported directly in load, so `load("...", other_name = "original_name")`). Note: Starlark `load` syntax is `load("file", local_name = "symbol_name")`.

## Macros and Rules

- **Macros**:
    - Should wrap one or more rules.
    - Must have a `name` argument.
    - Should usually pass `**kwargs` to the main underlying rule to forward common attributes like `tags`, `visibility`, `testonly`.
    - Use `native.existing_rule()` to check if a target already exists (be careful with performance).
- **Rules**:
    - Implementation functions should be named `_rule_name_impl`.
    - Attributes should be defined clearly using `attr.*`.
    - Prefer `executable = True` and `test = True` where appropriate.

```python
def my_macro(name, **kwargs):
    """Wraps a cc_binary with default settings.

    Args:
        name: The name of the target.
        **kwargs: Arguments forwarded to cc_binary.
    """
    cc_binary(
        name = name,
        copts = ["-Werror"],
        **kwargs
    )
```

## Functions

- **Arguments**:
    - Use keyword arguments for readability, especially for booleans or when a function has many arguments.
    - Document arguments in docstrings.
- **Return Values**: Keep return values simple. Structs or providers are preferred over complex dictionaries.

## Data Structures

- **Lists vs Tuples**:
    - Lists are mutable (unless frozen). Use them when you need to construct a collection.
    - Tuples are immutable. Use them for fixed collections.
    - Note: In `BUILD` files, lists are often used for `srcs` and `deps`.
- **Dictionaries**:
    - Dictionary concatenation (`+`) matches Python semantics (last write wins).
    - Iteration order is deterministic (insertion order).
- **Depsets**:
    - Use `depset` instead of lists for accumulating transitive data (like headers, object files) to avoid O(N^2) memory consumption.
    - Understand `order` semantics (`"default"`, `"postorder"`, `"preorder"`, `"topological"`).

## Control Flow

- **Loops**: `for` loops are allowed. `while` loops are not supported.
- **Recursion**: Recursion is not allowed in Starlark.
- **Conditionals**: `if`, `elif`, `else` behave as in Python.
- **List Comprehensions**: Encouraged for succinct transformations.

## Error Handling

- **fail()**: Use `fail("Error message")` to stop execution with an error.
    - Use meaningful error messages.
    - Do not use `print()` for errors; it is for debugging only.
    - `fail` is preferable to `assert` style checks if specific error messaging is needed.

## Documentation

- **Docstrings**:
    - All exported rules, macros, and providers must have a docstring.
    - Use the Google docstring format (triple quotes).
    - Document arguments (`Args:`), return values (`Returns:`), and attributes.
- **Stardoc**:
    - Write docstrings compatible with Stardoc to generate documentation automatically.

```python
def my_rule_impl(ctx):
    """Implementation of my_rule."""
    pass

my_rule = rule(
    implementation = my_rule_impl,
    doc = """
    A rule that does something useful.

    Attributes:
        srcs: Source files.
    """,
    attrs = {
        "srcs": attr.label_list(allow_files = True),
    },
)
```

## Tooling

- **Buildifier**:
    - Use `buildifier` to format and lint Starlark code.
    - Run `buildifier -r .` to format all files recursively.
    - Use comments `# buildifier: disable=rule-name` to suppress specific warnings if absolutely necessary, but explain why.
