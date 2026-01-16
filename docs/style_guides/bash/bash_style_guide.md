# Bash Style Guide

This document outlines the coding standards and best practices for Bash scripting within this project. Adhering to these guidelines ensures code consistency, robustness, portability, and readability.

## Table of Contents

1. [General Principles](#general-principles)
2. [File Header and Extension](#file-header-and-extension)
3. [Formatting and Indentation](#formatting-and-indentation)
4. [Naming Conventions](#naming-conventions)
5. [Variables and Parameters](#variables-and-parameters)
6. [Input and Output](#input-and-output)
7. [Control Flow](#control-flow)
8. [Functions](#functions)
9. [Command Substitution](#command-substitution)
10. [Error Handling and Robustness](#error-handling-and-robustness)
11. [Comments and Documentation](#comments-and-documentation)
12. [Security](#security)
13. [Clean Up and Signals](#clean-up-and-signals)
14. [Recommended Tools](#recommended-tools)

## General Principles

- **ShellCheck Clean**: All scripts must pass `shellcheck` without warnings.
- **Robustness**: Scripts should fail early and loudly. Avoid silent failures.
- **Portability**: Prefer standard Bash features. If a script is meant to be POSIX sh compliant, ensure it is. However, this guide assumes Bash is the target.
- **Readability**: Write code that is easy to understand. Descriptive variable names and comments are crucial.
- **Idempotency**: Whenever possible, scripts should be idempotent (safe to run multiple times).

## File Header and Extension

- **Shebang**: Always start with a shebang. Use `#!/usr/bin/env bash` for portability, rather than `#!/bin/bash`.
- **Extension**: Executable scripts should preferably not have an extension (e.g., `my-script`). Library files (not executable, intended to be sourced) should end in `.sh` or `.bash`.
- **Mode**: Executable scripts must have the executable bit set (`chmod +x`).

```bash
#!/usr/bin/env bash
```

## Formatting and Indentation

- **Indentation**: Use 2 spaces for indentation. Do not use tabs.
- **Line Length**: Aim for 80 characters, but 100 is acceptable if it improves readability.
- **Pipelines**: Break long pipelines into multiple lines with the pipe `|` at the end of the line. Indent the next line.
- **Blocks**: Put `then`, `do` on the same line as the condition/loop.
- **Blank Lines**: Use blank lines to group logical blocks of code.

```bash
# Good
if [[ "$condition" == "true" ]]; then
  do_something
fi

# Good pipeline
command1 \
  | command2 \
  | command3
```

## Naming Conventions

- **Variables**: Use `lower_case` for local variables and loop variables. Use `UPPER_CASE` for environment variables and global constants.
- **Functions**: Use `snake_case` (e.g., `my_function`).
- **Files**: Use `kebab-case` (e.g., `my-script.sh`).
- **Prefix**: Prefix internal/private variables and functions with an underscore `_`.

```bash
readonly MAX_RETRIES=3
some_local_var="value"

function process_data() {
  local _internal_var="temp"
  ...
}
```

## Variables and Parameters

- **Quoting**: Always quote variables (`"$var"`) unless you specifically want word splitting or glob expansion.
- **Local Variables**: Always declare variables inside functions as `local`.
- **Readonly**: Use `readonly` for constants.
- **Curly Braces**: Use `${var}` when necessary for clarity or avoiding ambiguity (e.g., `${var}_suffix`), but `"$var"` is generally sufficient.
- **Unset Variables**: Treat unset variables as an error (see Error Handling).
- **Magic Variables**: Avoid using `$1`, `$2` directly in long functions. Assign them to meaningful variable names at the start of the function.

```bash
# Good
function greet() {
  local name="$1"
  echo "Hello, $name"
}

# Bad
function greet() {
  echo "Hello, $1"
}
```

## Input and Output

- **Redirects**: explicitly redirect input/output.
- **Stderr**: Print error messages to `stderr`.
- **Printf**: Prefer `printf` over `echo` for portability and reliability, especially when printing variable content that might start with `-`.

```bash
# Good
error_msg="Something went wrong"
printf "Error: %s\n" "$error_msg" >&2
```

## Control Flow

- **Test Operator**: Prefer `[[ ... ]]` over `[ ... ]`. `[[` is safer and offers more features (regex, no word splitting).
- **Arithmetic**: Use `(( ... ))` for arithmetic operations.
- **Loops**: Use `for i in "${array[@]}"` to iterate over arrays.
- **Case**: Align `)` with the pattern. End each case with `;;`.

```bash
if [[ -f "$file" && "$count" -gt 0 ]]; then
  ...
fi

if (( count > 10 )); then
  ...
fi
```

## Functions

- **Definition**: Use the `function name() { ... }` or `name() { ... }` syntax. Be consistent. `name() { ... }` is more POSIX compliant, but `function` keyword makes it clear.
- **Return Values**: Functions return exit codes (0-255). Use `echo` or `printf` to return string data (captured via command substitution).
- **Scope**: Variables should be `local` by default.

## Command Substitution

- **Syntax**: Use `$(command)` instead of backticks `` `command` ``. It is nestable and more readable.
- **Exit Codes**: Check the exit code of command substitutions if critical.

```bash
# Good
output=$(do_something)

# Bad
output=`do_something`
```

## Error Handling and Robustness

- **Unofficial Strict Mode**: Start scripts with the following (often called the "Bash strict mode"):
    ```bash
    set -euo pipefail
    ```
    - `-e`: Exit immediately if a command exits with a non-zero status.
    - `-u`: Treat unset variables as an error.
    - `-o pipefail`: The return value of a pipeline is the status of the last command to exit with a non-zero status.
- **IFS**: Be careful with `IFS` (Internal Field Separator). If changing it, save the old value and restore it, or do it in a subshell.
- **Traps**: Use `trap` to clean up resources on exit.

## Comments and Documentation

- **Docstrings**: While not standard, adding a header comment to functions explaining arguments and behavior is recommended.
- **Inline**: Explain *why*, not *what*.
- **TODO**: Use `# TODO(user): description`.

## Security

- **Eval**: Avoid `eval`. It is dangerous and usually unnecessary.
- **Paths**: Use absolute paths or explicitly relative paths (`./script`) when invoking other scripts.
- **Sudo**: Avoid `sudo` inside scripts if possible. Let the user run the script with `sudo` if needed, or check for root privileges at the start.
- **Temporary Files**: Use `mktemp` to create temporary files securely.

```bash
temp_file=$(mktemp)
# Ensure cleanup
trap 'rm -f "$temp_file"' EXIT
```

## Clean Up and Signals

- **Trap**: Use `trap` to catch signals (`INT`, `TERM`) and `EXIT` to perform cleanup (deleting temp files, killing background processes).

```bash
function cleanup() {
  rm -f "$temp_file"
}
trap cleanup EXIT
```

## Recommended Tools

- **Linter**: `shellcheck`. Essential for finding bugs and bad practices.
- **Formatter**: `shfmt`. Enforces consistent formatting (indentation, etc.).
- **Testing**: `bats-core` (Bash Automated Testing System) for unit testing bash scripts.
