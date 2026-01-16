# Python Style Guide

This document outlines the coding standards and best practices for Python development within this project. Adhering to these guidelines ensures code consistency, readability, and maintainability.

## Table of Contents

1. [General Principles](#general-principles)
2. [Code Layout](#code-layout)
3. [Naming Conventions](#naming-conventions)
4. [Documentation and Comments](#documentation-and-comments)
5. [Type Hinting](#type-hinting)
6. [Imports](#imports)
7. [Data Structures and Algorithms](#data-structures-and-algorithms)
8. [Control Flow](#control-flow)
9. [Object Oriented Programming](#object-oriented-programming)
10. [Error Handling](#error-handling)
11. [Logging](#logging)
12. [Testing](#testing)
13. [Security](#security)
14. [Modern Python Features](#modern-python-features)
15. [Recommended Tools](#recommended-tools)

## General Principles

- **PEP 8**: Adhere to [PEP 8](https://peps.python.org/pep-0008/) for style guide rules unless otherwise specified.
- **Readability**: Code is read much more often than it is written. Prioritize clarity over cleverness.
- **Explicit is better than implicit**: Avoid magic behavior.
- **Simplicity**: Simple is better than complex.

## Code Layout

- **Indentation**: Use 4 spaces per indentation level. Do not use tabs.
- **Line Length**: Limit all lines to a maximum of 88 characters (consistent with [Black](https://github.com/psf/black) formatter).
- **Blank Lines**:
    - Top-level functions and classes: 2 blank lines.
    - Method definitions inside a class: 1 blank line.
    - Use blank lines sparingly inside functions to separate logical sections.
- **Whitespace**: Avoid extraneous whitespace.
    - Immediately inside parentheses, brackets, or braces.
    - Immediately before a comma, semicolon, or colon.
- **Trailing Commas**: Use trailing commas in multi-line lists, dictionaries, and function calls/definitions. This minimizes diff noise when adding items.
- **String Quotes**: Use double quotes `"` by default, consistent with Black. Use single quotes `'` if the string contains double quotes to avoid escaping.

## Naming Conventions

- **Variables/Functions**: `snake_case`
- **Classes/Exceptions**: `CapWords` (PascalCase)
- **Constants**: `UPPER_CASE_WITH_UNDERSCORES`
- **Protected Members**: `_single_leading_underscore` (internal use only)
- **Private Members**: `__double_leading_underscore` (avoid unless avoiding name clashes in inheritance)
- **Modules/Packages**: `snake_case` (short, all lowercase preferred)
- **Type Variables**: `T`, `U`, `V` or `CapWords` with `_co` (covariant) or `_contra` (contravariant) suffixes if applicable.

## Documentation and Comments

- **Docstrings**: All modules, classes, and public functions must have a docstring.
- **Format**: Use the [Google Style](https://google.github.io/styleguide/pyguide.html#38-comments-and-docstrings) for docstrings.
- **Inline Comments**: Use sparingly. Explain *why* something is done, not *what* is done. Keep them concise.
- **Block Comments**: Indent to the same level as the code. Use `#` followed by a single space.
- **TODOs**: Use `TODO(User):` format to mark incomplete code or areas for improvement.

```python
def fetch_data(url: str, timeout: int = 10) -> dict:
    """Fetches data from a given URL.

    Args:
        url: The URL to fetch data from.
        timeout: The timeout in seconds. Defaults to 10.

    Returns:
        A dictionary containing the JSON response.

    Raises:
        ValueError: If the URL is invalid.
        TimeoutError: If the request times out.
    """
    pass
```

## Type Hinting

- **Strictness**: Aim for strict type checking.
- **Annotations**: Annotate all function arguments and return values.
- **Generics**: Use `list[str]`, `dict[str, int]` (Python 3.9+) or `typing.List`, `typing.Dict` for older versions.
- **Optional**: Use `X | None` (Python 3.10+) or `Optional[X]`.
- **Any**: Avoid `Any`. If used, explain why in a comment.
- **Casting**: Use `typing.cast` sparingly when the type checker cannot infer the type correctly.

```python
from typing import Optional, cast

def process_items(items: list[str]) -> dict[str, int]:
    ...
```

## Imports

- **Order**:
    1. Standard library imports.
    2. Related third-party imports.
    3. Local application/library specific imports.
- **Style**:
    - Absolute imports are recommended over relative imports.
    - Avoid wildcard imports (`from module import *`).
    - Group imports using parentheses if they span multiple lines.

```python
# Good
import os
import sys

import requests

from myproject.models import User
from myproject.utils import (
    helper_one,
    helper_two,
    helper_three,
)
```

## Data Structures and Algorithms

- **List Comprehensions**: Use them for simple transformations. Avoid nested list comprehensions if they impair readability.
- **Generators**: Use generators (`yield`) or generator expressions for large datasets to save memory.
- **Dictionaries**: Use `dict.get()` when you are unsure if a key exists.
- **Sets**: Use sets for membership testing and eliminating duplicates.

## Control Flow

- **Conditionals**: Avoid deep nesting. Return early if possible (Guard Clauses).
- **Loops**: Prefer iterating directly over the collection (`for item in items`) rather than using indices.
- **Enumerate**: Use `enumerate(items)` if you need the index.
- **Zip**: Use `zip(list_a, list_b)` to iterate over multiple lists simultaneously.

## Object Oriented Programming

- **Composition over Inheritance**: Prefer composition to inheritance to reduce complexity.
- **Mixins**: Use mixins for shared functionality that doesn't fit into a strict hierarchy.
- **Properties**: Use `@property` for getters and setters to maintain Pythonic attribute access.
- **Dataclasses**: Use `@dataclass` for data-holding classes.
- **Abstract Base Classes**: Use `abc.ABC` and `@abstractmethod` to define interfaces.

## Error Handling

- **Specificity**: Catch specific exceptions, not broad `Exception`.
- **Try/Except Blocks**: Keep them small. Limit the code inside `try` to the line(s) that might actually raise the exception.
- **Custom Exceptions**: Define custom exception classes for domain-specific errors.
- **Cleanup**: Use `finally` or context managers (`with`) for resource cleanup.

```python
class MyCustomError(Exception):
    pass

try:
    process_data()
except ValueError as e:
    logger.error(f"Invalid data: {e}")
    raise MyCustomError("Data processing failed") from e
```

## Logging

- **Library**: Use the standard [`logging`](https://docs.python.org/3/library/logging.html) library.
- **Levels**: Use appropriate logging levels (`DEBUG`, `INFO`, `WARNING`, `ERROR`, `CRITICAL`).
- **Configuration**: Do not configure logging in libraries; leave it to the application.
- **Messages**: Include context in log messages. Use placeholders `%s` or f-strings (be mindful of performance in high-throughput loops if using f-strings eagerly).

## Testing

- **Framework**: Use [`pytest`](https://docs.pytest.org/).
- **Structure**: Mirror the source code directory structure in the `tests/` directory.
- **Naming**: `test_*.py` for files, `test_*` for functions.
- **Fixtures**: Use `pytest` fixtures for setup and teardown.
- **Coverage**: Aim for high test coverage. Use [`pytest-cov`](https://pytest-cov.readthedocs.io/).
- **Mocking**: Use [`unittest.mock`](https://docs.python.org/3/library/unittest.mock.html) or [`pytest-mock`](https://pytest-mock.readthedocs.io/) to isolate units.

## Security

- **Secrets**: Never hardcode secrets (passwords, API keys) in the code. Use environment variables.
- **Input Validation**: Validate all external inputs.
- **SQL Injection**: Use parameterized queries; never format strings into SQL queries.
- **Dependencies**: regularly update dependencies to patch vulnerabilities.

## Modern Python Features

- **f-strings**: Use f-strings for string interpolation.
- **Walrus Operator**: Use `:=` sparingly and only when it improves readability (e.g., in `while` loops or list comprehensions).
- **Pattern Matching**: Use `match/case` (Python 3.10+) for complex branching logic based on structure.

## Recommended Tools

- **Formatter**: [`black`](https://github.com/psf/black) (uncompromising code formatter).
- **Linter**: [`ruff`](https://github.com/astral-sh/ruff) (extremely fast Python linter) or [`pylint`](https://pylint.readthedocs.io/).
- **Type Checker**: [`mypy`](https://mypy-lang.org/) or [`pyright`](https://github.com/microsoft/pyright).
- **Import Sorter**: [`isort`](https://pycqa.github.io/isort/) (often integrated into ruff).
- **Package Manager**: [`poetry`](https://python-poetry.org/) or [`uv`](https://github.com/astral-sh/uv) for dependency management.
- **Pre-commit**: Use [`pre-commit`](https://pre-commit.com/) hooks to enforce style before committing.


## Related Interview Questions

*   **[Practice Questions](../../interview_questions/python.md)**: Test your knowledge of Python concepts.
