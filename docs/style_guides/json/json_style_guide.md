# JSON Style Guide

This document outlines the coding standards and best practices for JSON (JavaScript Object Notation) files within this project. Adhering to these guidelines ensures consistency, interoperability, and prevents common parsing errors.

## Table of Contents

1. [General Principles](#general-principles)
2. [File Extension and Formatting](#file-extension-and-formatting)
3. [Syntax and Structure](#syntax-and-structure)
4. [Naming Conventions](#naming-conventions)
5. [Data Types](#data-types)
6. [Comments](#comments)
7. [Date and Time](#date-and-time)
8. [JSON Variants](#json-variants)
9. [Security](#security)
10. [Validation and Schemas](#validation-and-schemas)
11. [Recommended Tools](#recommended-tools)

## General Principles

- **Strictness**: JSON is less forgiving than other formats (like YAML or JavaScript). Strict adherence to the spec is required.
- **Interoperability**: JSON is the lingua franca of data exchange. Prioritize structures that are easy to consume by various languages (JavaScript, Python, Go, etc.).
- **Readability**: While often machine-generated, configuration files and static data should be formatted for human readability.
- **Consistency**: Stick to a single style for indentation and naming conventions throughout a project.

## File Extension and Formatting

- **Extension**: Use `.json` for standard JSON files.
    - Use `.jsonc` or `.json5` if you explicitly require comments or extended syntax (and your tools support it).
- **Indentation**:
    - Use **2 spaces** per indentation level.
    - **Never** use tabs.
- **Line Length**: While JSON doesn't enforce line limits, try to wrap long strings or deeply nested objects if it aids readability, but prioritize syntactic correctness.
- **Encoding**: Must be **UTF-8**.
- **End of File**: Ensure files end with a single newline character.

## Syntax and Structure

- **Root Element**: A JSON payload should ideally be a single object `{}` or array `[]`. Avoid top-level primitives (like a raw string or number) for API responses as they can be security risks (JSON hijacking) or harder to extend.
- **Quotes**:
    - **Double quotes** `"` are mandatory for all keys and string values.
    - Single quotes `'` are **invalid** in standard JSON.
- **Trailing Commas**:
    - **Do not** use trailing commas. They are invalid in standard JSON and will cause parsing errors in many environments (e.g., Python's `json` library, stricter browsers).
- **Spacing**:
    - No space before the colon.
    - One space after the colon.
    - Good: `"key": "value"`
    - Bad: `"key" :"value"`, `"key":"value"`

## Naming Conventions

- **Keys**:
    - Use **camelCase** (`myKeyName`) as the primary standard, aligning with JavaScript conventions.
    - **snake_case** (`my_key_name`) is acceptable if the backend system or language strictly prefers it (e.g., Python-heavy environments), but consistency is key.
    - **kebab-case** (`my-key-name`) is discouraged for JSON keys as it is harder to access with dot notation in JavaScript (`obj.my-key-name` is invalid).
    - Keys must be unique within an object.
- **Meaningful Names**: Use descriptive keys. Avoid abbreviations unless standard (e.g., `id`, `url`).

## Data Types

### Strings
- Escape special characters: `"` (`\"`), `\` (`\\`), backspace (`\b`), form feed (`\f`), newline (`\n`), carriage return (`\r`), tab (`\t`).
- Avoid constructing JSON strings manually; use a serialization library to handle escaping correctly.

### Numbers
- Do not use quotes for numbers.
- **Integers**: `123`, `-10`.
- **Floats**: `123.45`.
- **Exponents**: `1.23e4` is valid.
- **Leading Zeros**: **Forbidden**. `01` is invalid; use `1`.
- **Infinity/NaN**: Not supported in standard JSON. Use `null` or a string representation if strictly necessary (and documented).

### Booleans
- Use `true` and `false` (all lowercase).
- Do not quote them.

### Null
- Use `null` (all lowercase) to represent an empty or missing value.
- Do not quote it (`"null"` is a string).

### Arrays
- Use `[]` for lists.
- Elements can be of mixed types, but homogeneous lists (all elements of the same type) are preferred for schema consistency.

### Objects
- Use `{}` for key-value pairs.

## Comments

- **Standard JSON**: Comments are **forbidden**. Do not include `//` or `/* */` in `.json` files.
- **Configuration**: If comments are absolutely necessary for configuration files:
    - Use a pre-processor (like `strip-json-comments`).
    - Use a derived format like **JSONC** (JSON with Comments) or **JSON5**.
    - Store documentation in a separate field (e.g., `"_comment": "This explains the setting"`) if strict JSON compliance is required.

## Date and Time

- JSON has no native date type.
- **Format**: Always use **ISO 8601** strings.
    - UTC is preferred: `YYYY-MM-DDThh:mm:ss.sssZ`
    - Example: `"2023-10-27T10:00:00Z"`

## JSON Variants

If standard JSON is too limiting (e.g., for config files needing comments):

- **JSONC**: Standard JSON syntax but allows comments. Visual Studio Code uses this for settings.
- **JSON5**: Extension of JSON that allows comments, unquoted keys (ES5 style), trailing commas, and single quotes.
- **Usage**: Ensure your parser supports these variants before using them. Do not use them for data exchange between disparate systems unless agreed upon.

## Security

- **Top-Level Arrays**: Avoid returning top-level arrays in API responses to mitigate JSON hijacking (though modern browsers have largely mitigated this). Return an object wrapping the array: `{"data": [...]}`.
- **Depth Limit**: When parsing JSON, enforce a maximum depth to prevent stack overflow attacks.
- **XSS**: Be wary of embedding JSON directly into HTML (e.g., in `<script>` tags). Characters like `<` and `>` should be properly escaped or sanitized to prevent Cross-Site Scripting.

## Validation and Schemas

- **JSON Schema**: Strongly recommended for defining and validating the structure of JSON data.
    - Enables automated testing and documentation.
    - Use the latest draft (currently 2020-12) or draft-07.
- **Contract Testing**: Use JSON Schemas to ensure API contracts between services are honored.

## Recommended Tools

- **Formatter**: [`prettier`](https://prettier.io/)
    - excellent support for JSON, enforcing standard formatting.
- **Linter**: [`eslint-plugin-json`](https://www.npmjs.com/package/eslint-plugin-json) or [`jsonlint`](https://jsonlint.com/)
- **Command Line**: [`jq`](https://stedolan.github.io/jq/)
    - Essential for slicing, filtering, and mapping JSON data in the terminal.
- **Schema Validator**: [`ajv`](https://ajv.js.org/) (JavaScript), [`jsonschema`](https://python-jsonschema.readthedocs.io/) (Python).
