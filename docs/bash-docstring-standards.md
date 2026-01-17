# Bash Script Documentation Standards

This document outlines the required documentation standards for all Bash scripts in the repository.

## Requirements

Every Bash script must contain robust, well-structured docstrings for all functions, sub-shells, and global variables. The documentation should be clear enough that a developer can understand each construct's purpose, inputs, outputs, and failure modes without reading the implementation.

### One-line Summary

- Starts with an uppercase verb or noun
- Ends with a period (`.`)
- Provides the core intent of the function/variable

### Blank Line Separator

- Insert one blank line between the one-line summary and the extended description

### Extended Description (optional but encouraged for complex constructs)

- Short paragraph(s) describing behavior, side effects, or important details
- End every sentence with a period

### Parameters (`@param`)

- List each parameter in the order they appear in the signature
- Include name, type (e.g., `Integer`, `String`), and a concise purpose
- End each line with a period

### Return Values (`@return` or `@returns`)

- Describe the type of the returned value(s)
- Mention any conditions that affect the output
- End with a period

### Error Handling (`@error`/`@throws`)

- Enumerate each error condition (e.g., invalid argument, missing file)
- State the exit code or message that will be produced when the error occurs
- End each line with a period

### Global Variables/Constants

- Document any exported/global symbols in the same format as functions (`@variable`, `@const`)

### Formatting Style

- Each docstring must use `#` comment markers on consecutive lines
- All sentences terminate with a period—no trailing whitespace or missing punctuation

## Example Layout

```bash
# my_function – Run preprocessing on an input directory.
#
# Preprocesses all files matching *pattern* in the given SOURCE_DIR,
# validates their JSON structure, and writes cleaned outputs to DEST_DIR.
#
# Parameters:
#   source_dir (String) – Path to the directory containing raw data. .
#   pattern        (String) – Glob pattern for files to process. .
#   dest_dir       (String) – Destination directory for processed files. .
#
# Returns:
#   0 on success, non-zero exit code on failure. .
#
# Errors:
#   1 – Missing SOURCE_DIR or not a directory. .
#   2 – Invalid JSON encountered in any source file. .
def my_function() {
    # implementation …
}
```

## Enforcement

- **Pre-commit hook** (`scripts/lint_docstrings.sh`) will automatically scan new or modified Bash files for missing or malformed docstrings
- The `shellcheck` warning `SC2034` (unused variable) and `SC1091` (non-existent SCM metadata) are treated as failures when docstrings are absent

## Usage

To validate docstrings in your scripts:

```bash
./scripts/lint_docstrings.sh
```

To validate specific files:

```bash
./scripts/lint_docstrings.sh script1.sh script2.sh
```

## Implementation Notes

All functions must have complete docstrings following the format above. Functions without proper documentation will be flagged by the linting script and will cause pre-commit hooks to fail.
