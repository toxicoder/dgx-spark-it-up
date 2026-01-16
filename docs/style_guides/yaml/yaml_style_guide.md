# YAML Style Guide

This document outlines the coding standards and best practices for YAML (YAML Ain't Markup Language) files within this project. Adhering to these guidelines ensures consistency, readability, and prevents common pitfalls in configuration files.

## Table of Contents

1. [General Principles](#general-principles)
2. [File Extension and Formatting](#file-extension-and-formatting)
3. [Syntax and Structure](#syntax-and-structure)
4. [Naming Conventions](#naming-conventions)
5. [Data Types](#data-types)
6. [Comments](#comments)
7. [Keys and Values](#keys-and-values)
8. [Lists and Dictionaries](#lists-and-dictionaries)
9. [Multi-line Strings](#multi-line-strings)
10. [Anchors and Aliases](#anchors-and-aliases)
11. [Security](#security)
12. [Validation and Schemas](#validation-and-schemas)
13. [Recommended Tools](#recommended-tools)

## General Principles

- **Human Readability**: YAML is designed to be human-readable. Prioritize layout and structure that aids human understanding.
- **Consistency**: Stick to a single style for quoting, indentation, and key naming throughout a project.
- **Data vs. Code**: Remember that YAML is a data serialization language, not a programming language. Avoid complex logic (like excessive anchors/aliases) that mimics code inheritance unless absolutely necessary.
- **DRY (Don't Repeat Yourself)**: Use anchors and aliases judiciously to reduce repetition, but not at the expense of readability.

## File Extension and Formatting

- **Extension**: Use `.yaml` for all YAML files. Do not use `.yml`.
- **Indentation**:
    - Use **2 spaces** per indentation level.
    - **Never** use tabs.
- **Line Length**: Limit lines to **80 characters** where possible, or **100 characters** max. This matches common editor settings and improves side-by-side diffing.
- **Encoding**: Always use **UTF-8**.
- **End of File**: Ensure files end with a single newline character.

## Syntax and Structure

- **Document Separators**:
    - Start files with `---` (document start marker) if the file might be concatenated or if it helps clarity.
    - Omit `---` for simple configuration files where it adds noise.
    - Avoid `...` (document end marker) unless strictly necessary for stream processing.
- **Directives**: Place directives (like `%YAML 1.2`) at the very top if used, but they are generally optional for configuration files.

## Naming Conventions

- **Keys**:
    - Use **snake_case** (`key_name`) as the primary standard for general configuration.
    - Use **kebab-case** (`key-name`) if mandated by the specific ecosystem (e.g., Kubernetes, Ansible).
    - Be consistent within a single file and project.
    - Avoid spaces and special characters in keys to prevent the need for quoting.
- **Consistency**: Match the naming convention of the application consuming the YAML.

## Data Types

### Booleans
- Use `true` and `false` (all lowercase).
- **Avoid**: `yes`, `no`, `on`, `off`, `True`, `False`. The YAML 1.2 spec is stricter, but many parsers still accept 1.1 types. Sticking to `true`/`false` is safest and most standard.

```yaml
# Good
feature_enabled: true
debug_mode: false

# Bad
feature_enabled: yes
debug_mode: OFF
```

### Strings
- **Unquoted**: Use unquoted strings for simple alphanumeric values without special characters.
- **Quoted**:
    - Use **double quotes** `"` if the string contains special characters, escape sequences (like `\n`), or starts with a character that could confuse the parser (e.g., `[`, `{`, `*`, `#`, `!`, `%`, `@`, `&`, `|`, `>`, `?`, `-`, `:`, `,`).
    - Use **single quotes** `'` if the string contains double quotes and no escape sequences are needed.
- **Numbers as Strings**: Always quote numbers that should be treated as strings (e.g., versions, account numbers) to prevent them from being parsed as integers or floats.

```yaml
version: "1.10"  # Good (keeps it a string)
version: 1.10    # Bad (parsed as float 1.1)
country_code: "045" # Good (preserves leading zero)
```

### Null
- Use `null` or omit the value.
- Avoid `~`.

### Numbers
- Be explicit.
- Avoid octal notation (starting with `0`) unless intentional and standard-compliant (YAML 1.2 uses `0o`).

## Comments

- **Style**: Use `#` followed by a space.
- **Placement**:
    - **Inline**: Allowed for short explanations.
    - **Block**: Preferred for detailed descriptions. Indent block comments to align with the code they describe.
- **Content**: Explain *why* a configuration is set, especially for non-obvious values or workarounds.

```yaml
# Timeout set to 30s to accommodate slow legacy backend
timeout: 30

retry_count: 5 # Retry 5 times before failing
```

## Keys and Values

- **Colons**: Put a single space after the colon `: `.
    - Good: `key: value`
    - Bad: `key:value`
- **Duplicate Keys**: Never use duplicate keys in the same mapping. Most parsers will either error out or silently overwrite the first value.

## Lists and Dictionaries

- **Block Style**: Prefer block style (indented) for readability.

```yaml
# Good
items:
  - item1
  - item2

# Acceptable for short lists
items: [item1, item2]
```

- **Flow Style**: Use flow style (`{...}`, `[...]`) only for very short, simple structures that fit on one line.
- **List Items**: Indent the hyphen `-` at the same level as the key or indented by 2 spaces. Pick one style and stick to it.
    - **Recommended**: Indent list items by 2 spaces relative to the parent key.

```yaml
# Recommended
users:
  - name: alice
    uid: 1001
  - name: bob
    uid: 1002

# Also common (no indentation for hyphen)
users:
- name: alice
  uid: 1001
```

## Multi-line Strings

- **Literal Style (`|`)**: Preserves newlines. Use for code blocks or embedded scripts.
- **Folded Style (`>`)**: Replaces single newlines with spaces. Use for long prose or descriptions.
- **Chomping Indicators**:
    - `|-` or `>-`: Strip the final newline.
    - `|+` or `>+`: Keep all trailing newlines.
    - Default (no indicator): Keep a single trailing newline.

```yaml
description: >
  This is a long description that spans multiple
  lines in the YAML file but will be rendered
  as a single line string.

script: |
  echo "Hello World"
  ls -la
```

## Anchors and Aliases

- **Usage**: Use anchors (`&name`) and aliases (`*name`) to avoid repetition of large data structures.
- **Merge Keys (`<<`)**: Use merge keys to inherit from a base dictionary. Note that merge keys are optional in YAML 1.2, but widely supported.
- **Clarity**: Do not overuse. If the hierarchy becomes too deep or complex, it becomes hard to read.

```yaml
default_settings: &defaults
  timeout: 10
  retries: 3

production:
  <<: *defaults
  timeout: 30
```

## Security

- **Safe Loading**: When writing code that parses YAML, always use "safe load" functions (e.g., `yaml.safe_load()` in Python) to prevent code execution vulnerabilities from unsafe tags like `!!python/object`.
- **Secrets**: Do not commit secrets (passwords, API keys) to version control in YAML files. Use templating, environment variables, or secret management tools (e.g., Sealed Secrets, Vault).

## Validation and Schemas

- **JSON Schema**: Use JSON Schema to validate YAML configuration files where structure is critical.
- **Linting**: Enforce style and syntax checks using CI/CD pipelines.

## Recommended Tools

- **Linter**: [`yamllint`](https://github.com/adrienverge/yamllint)
    - Can verify indentation, line length, trailing spaces, and more.
- **Formatter**: [`prettier`](https://prettier.io/)
    - Supports YAML and enforces consistent formatting.
- **Processor**: [`yq`](https://github.com/mikefarah/yq)
    - Lightweight and portable command-line YAML processor (like `jq` for YAML).
- **Validation**: [`kubeval`](https://www.kubeval.com/) (for Kubernetes), [`check-jsonschema`](https://github.com/python-jsonschema/check-jsonschema).
