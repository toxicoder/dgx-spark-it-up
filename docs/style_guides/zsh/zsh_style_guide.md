# Zsh Style Guide

This document outlines the coding standards and best practices for Zsh scripting within this project. While Zsh shares many similarities with Bash, it offers distinct features and default behaviors that require specific attention.

## Table of Contents

1. [General Principles](#general-principles)
2. [File Header and Extension](#file-header-and-extension)
3. [Formatting and Indentation](#formatting-and-indentation)
4. [Naming Conventions](#naming-conventions)
5. [Variables and Parameters](#variables-and-parameters)
6. [Arrays and Associative Arrays](#arrays-and-associative-arrays)
7. [Input and Output](#input-and-output)
8. [Control Flow](#control-flow)
9. [Functions and Autoloading](#functions-and-autoloading)
10. [Globbing and Expansion](#globbing-and-expansion)
11. [Error Handling and Robustness](#error-handling-and-robustness)
12. [Comments and Documentation](#comments-and-documentation)
13. [Security](#security)
14. [Recommended Tools](#recommended-tools)

## General Principles

- **Leverage Zsh Features**: Use Zsh's powerful features (glob qualifiers, recursive globbing, associative arrays) where they improve clarity or performance over standard POSIX sh constructs.
- **Robustness**: Scripts should fail early and loudly.
- **Readability**: Code should be self-documenting. Use descriptive names.
- **Consistency**: Follow the style of the existing codebase.

## File Header and Extension

- **Shebang**: Always start with a shebang.
    ```zsh
    #!/usr/bin/env zsh
    ```
- **Extension**: Executable scripts should generally not have an extension. Library files or sourced scripts should end in `.zsh`.
- **Mode**: Executable scripts must have the executable bit set (`chmod +x`).

## Formatting and Indentation

- **Indentation**: Use 2 spaces for indentation. Do not use tabs.
- **Line Length**: Aim for 80 characters, extending to 100 if it improves readability.
- **Pipelines**: Break long pipelines across lines, ending with `|`.
- **Blocks**: `then`, `do` should be on the same line as the condition/loop command.

```zsh
# Good
if [[ -f "$file" ]]; then
  print "File exists"
fi

# Good pipeline
ls -1 \
  | grep "pattern" \
  | sort
```

## Naming Conventions

- **Variables**: `lower_case` for local/loop variables. `UPPER_CASE` for environment/global variables.
- **Functions**: `snake_case` (e.g., `parse_input`).
- **Files**: `kebab-case` (e.g., `install-deps.zsh`).
- **Private Members**: Prefix internal functions/variables with `_` (e.g., `_helper_func`).

## Variables and Parameters

- **Declaration**: Use `local` or `typeset` inside functions to prevent polluting the global scope.
    - Note: In Zsh, `typeset` is equivalent to `local` inside functions.
- **Quoting**: Unlike Bash, Zsh does *not* split words on unquoted variable expansion by default. However, **always quote strings** (`"$var"`) that might contain empty values or if portability habits are desired.
    - Exception: Intentionally unquoted variables for splitting (though explicit splitting flags `${=var}` are preferred).
- **Types**: Use `integer` for math variables and `float` for floating point to enforce typing.
    ```zsh
    integer count=0
    local -a items
    ```

## Arrays and Associative Arrays

- **Indexing**: Zsh arrays are **1-based** by default. Do not assume 0-based indexing unless `setopt KSH_ARRAYS` is widely used (discouraged in pure Zsh scripts).
- **Declaration**:
    ```zsh
    # Array
    local -a my_list=( "item1" "item2" )

    # Associative Array (Map)
    local -A my_map
    my_map[key]="value"
    ```
- **Iteration**:
    ```zsh
    for item in "${my_list[@]}"; do
      ...
    done

    for key value in "${(@kv)my_map}"; do
      print "$key -> $value"
    done
    ```

## Input and Output

- **Print**: Prefer `print` or `printf` over `echo`. `print` is a Zsh builtin with consistent behavior.
    - `print -r` prints raw strings (ignores escapes).
    - `print -l` prints elements separated by newlines.
- **Stderr**:
    ```zsh
    print -u2 "Error message"
    ```

## Control Flow

- **Conditions**: Use `[[ ... ]]` exclusively. It handles regex (`=~`) and globbing safely.
- **Arithmetic**: Use `(( ... ))` for math comparisons and operations.
    ```zsh
    if (( count > 5 )); then ... fi
    (( count++ ))
    ```
- **Loops**:
    - `for x in ...; do ...; done`
    - `while ...; do ...; done`
    - Short form `for` loops (e.g., `for x (...)`) are valid but standard syntax is often more readable for complex blocks.

## Functions and Autoloading

- **Definition**: Prefer `function_name() { ... }`. The `function` keyword is optional but can be used.
- **Autoloading**: For large suites of functions, use `autoload -Uz function_name` and keep functions in separate files in `$fpath`. This improves startup time.
- **Return**: Return status codes (0-255). Output data via stdout.

```zsh
my_function() {
  local input="$1"
  if [[ -z "$input" ]]; then
    return 1
  fi
  print "Processing $input"
}
```

## Globbing and Expansion

- **Recursive Globbing**: Use `**` freely for recursive searches.
- **Qualifiers**: Use glob qualifiers to filter files efficiently without piping to `find`.
    - `*(/)`: directories only
    - `*(.)`: plain files only
    - `*(x)`: executables
    - `*(m-1)`: modified in the last day
    ```zsh
    # List all regular files recursively
    ls **/*(.)
    ```
- **Modifiers**: Use modifiers like `:t` (tail/filename), `:h` (head/dirname), `:r` (remove extension).
    ```zsh
    local file="/path/to/image.png"
    print ${file:t}   # image.png
    print ${file:r}   # /path/to/image
    ```

## Error Handling and Robustness

- **Options**:
    - `setopt ERR_EXIT` (or `set -e`): Exit on error.
    - `setopt NO_UNSET` (or `set -u`): Error on unset variables.
    - `setopt PIPE_FAIL` (or `set -o pipefail`): Check all commands in a pipe.
- **Standard Preamble**:
    ```zsh
    emulate -L zsh # Reset options to standard Zsh defaults inside functions/scripts
    setopt ERR_EXIT NO_UNSET PIPE_FAIL
    ```
- **Traps**: Use `trap` for cleanup.
    ```zsh
    trap 'rm -f $temp_file' EXIT
    ```

## Comments and Documentation

- **Header**: Scripts should explain their purpose at the top.
- **Functions**: Document inputs, outputs, and side effects.
- **Inline**: Explain *why* tricky logic is used.

## Security

- **Eval**: Avoid `eval`.
- **Temporary Files**: Use `mktemp` or Zsh's `=(command)` substitution if appropriate for temporary file handling.
- **Paths**: Use absolute paths for critical commands or ensure `$PATH` is trusted.

## Recommended Tools

- **Syntax Check**: `zsh -n script.zsh` checks for syntax errors without running.
- **Debugging**: `zsh -x script.zsh` traces execution.
