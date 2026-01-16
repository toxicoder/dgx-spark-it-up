# JavaScript Style Guide

This document outlines the coding standards and best practices for JavaScript development within this project. Adhering to these guidelines ensures code consistency, readability, and maintainability.

## Table of Contents

1. [General Principles](#general-principles)
2. [Code Layout](#code-layout)
3. [Naming Conventions](#naming-conventions)
4. [Documentation and Comments](#documentation-and-comments)
5. [Variables and Declarations](#variables-and-declarations)
6. [Functions](#functions)
7. [Objects and Arrays](#objects-and-arrays)
8. [Classes and Prototypes](#classes-and-prototypes)
9. [Modules](#modules)
10. [Asynchronous Programming](#asynchronous-programming)
11. [Control Flow](#control-flow)
12. [Error Handling](#error-handling)
13. [Testing](#testing)
14. [Security](#security)
15. [Modern Features](#modern-features)
16. [Recommended Tools](#recommended-tools)

## General Principles

- **ECMAScript Standards**: Write modern JavaScript, targeting the latest stable ECMAScript versions. Use transpilers (like [Babel](https://babeljs.io/)) only if legacy browser support is strictly required.
- **Consistency**: Consistency is key. If you edit existing code, follow the existing style.
- **Readability**: Code is read much more often than it is written. Prioritize clarity over cleverness.
- **Functional Style**: Prefer pure functions and immutability where possible. Avoid side effects.

## Code Layout

- **Indentation**: Use 2 spaces per indentation level. Do not use tabs.
- **Line Length**: Limit lines to 80 or 100 characters.
- **Semicolons**: Always use semicolons to avoid [Automatic Semicolon Insertion (ASI)](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Lexical_grammar#automatic_semicolon_insertion) pitfalls.
- **Quotes**: Use single quotes `'` for normal strings. Use backticks `` ` `` for template literals. Avoid double quotes `"` unless necessary (e.g., in JSON or to avoid escaping).
- **Braces**:
    - Use "Egyptian brackets" (opening brace on the same line).
    - Always use braces for control structures (`if`, `else`, `for`, `while`), even for single-line blocks.
- **Spacing**:
    - Put a space before the leading brace.
    - Put a space after control keywords (`if`, `for`, etc.).
    - No space before function invocation parentheses.
    - Space around operators (`=`, `+`, `=>`, etc.).
- **Trailing Commas**: Use trailing commas in multi-line object and array literals, and function arguments. This minimizes diff noise.
- **Empty Lines**:
    - Add an empty line between methods in classes and object literals.
    - Add an empty line before logical blocks of code.
    - End files with a single newline character.

## Naming Conventions

- **Variables/Functions**: `camelCase`.
- **Classes/Components**: `PascalCase`.
- **Constants**: `UPPER_CASE_WITH_UNDERSCORES` for top-level, immutable constants. `camelCase` for constants declared inside functions or that are objects/arrays.
- **Private Properties**: Prefix with `_` (underscore) for internal/private properties (convention only) or use `#` private fields if environment supports it.
- **Booleans**: Prefix with `is`, `has`, `should`, or `can` (e.g., `isVisible`, `hasError`).
- **Filenames**: `kebab-case` (e.g., `my-script.js`, `user-profile.js`).
- **Event Handlers**: Prefix with `handle` (e.g., `handleSubmit`, `handleInputChange`).

## Documentation and Comments

- **JSDoc**: Use [JSDoc](https://jsdoc.app/) for documenting functions, classes, and complex logic.
- **Inline Comments**: Use `//` for single-line comments. Explain *why*, not *what*.
- **Block Comments**: Use `/* ... */` for multi-line comments.
- **TODOs**: Use `TODO(User):` to mark areas for improvement.

```javascript
/**
 * Fetches user data from the API.
 *
 * @param {string} userId - The unique identifier of the user.
 * @param {object} [options] - Optional configuration.
 * @returns {Promise<User>} The user object.
 */
async function fetchUser(userId, options = {}) {
  // ...
}
```

## Variables and Declarations

- **const vs let**: Use `const` by default. Use `let` only if you need to reassign the variable.
- **No var**: Never use `var`. It has function scope and hoisting behavior that can lead to bugs.
- **Declaration**: Declare one variable per statement.
- **Destructuring**: Use destructuring for accessing object properties and array elements when possible.

```javascript
// Good
const { name, age } = user;
const [first, second] = items;

// Bad
const name = user.name;
const age = user.age;
```

## Functions

- **Arrow Functions**: Use arrow functions `() => {}` for callbacks and anonymous functions to preserve lexical `this`.
- **Function Declarations**: Use function declarations for top-level functions or when hoisting is needed.
- **Parameters**: Use default parameter syntax instead of mutating arguments inside the function.
- **Rest Parameters**: Use rest parameters `...args` instead of the `arguments` object.
- **Complexity**: Keep functions small and focused on a single task.

## Objects and Arrays

- **Object Shorthand**: Use property shorthand when the property name matches the variable name.
- **Computed Properties**: Use computed property names `{[key]: value}` when creating objects with dynamic keys.
- **Spreading**: Use the spread operator `...` to copy objects and arrays (shallow copy).
- **Array Methods**: Prefer array methods (`map`, `filter`, `reduce`, `find`, `every`, `some`) over `for` loops.

```javascript
const item = {
  id: 1,
  name: 'Widget',
};

// Shallow copy with override
const updatedItem = { ...item, name: 'New Widget' };
```

## Classes and Prototypes

- **class**: Use `class` syntax instead of manipulating `prototype` directly.
- **Inheritance**: Use `extends` for inheritance.
- **Constructor**: Initialize properties in the constructor.
- **Methods**: Do not use arrow functions as class members unless binding is strictly required (it affects performance and inheritance).

## Modules

- **ES Modules**: Use standard ES modules (`import`/`export`) over CommonJS (`require`/`module.exports`) unless working in a Node.js environment that strictly requires CommonJS.
- **Named Exports**: Prefer named exports over default exports. This improves discoverability and refactoring.
- **Imports**:
    - Put imports at the top of the file.
    - Sort imports: Built-in, Third-party, Internal (absolute), Internal (relative).

```javascript
import fs from 'fs';
import _ from 'lodash';
import { User } from '@/models/User';
import { format } from './utils';
```

## Asynchronous Programming

- **Async/Await**: Prefer `async`/`await` over raw Promises (`.then()`, `.catch()`) for better readability.
- **Try/Catch**: Use `try`/`catch` blocks to handle errors in async functions.
- **Parallelism**: Use `Promise.all()` to run independent promises in parallel.

```javascript
async function loadData() {
  try {
    const [users, posts] = await Promise.all([
      fetchUsers(),
      fetchPosts(),
    ]);
    return { users, posts };
  } catch (error) {
    console.error('Failed to load data', error);
    throw error;
  }
}
```

## Control Flow

- **Comparison**: Use strict equality `===` and inequality `!==`.
- **Ternary**: Use ternary operators `condition ? true : false` for simple assignments. Avoid nested ternaries.
- **Switch**: Use `switch` statements for multiple conditions on the same variable. Always include a `default` case.
- **Conditionals**: Avoid "Yoda conditions" (`if ('red' === color)`). Place the variable on the left.

## Error Handling

- **Throwing**: Throw `Error` objects (or subclasses), not strings.
    - `throw new Error('Something went wrong');`
- **Handling**: Handle errors at the appropriate level. Don't swallow errors silently.
- **Custom Errors**: Create custom error classes for domain-specific errors.

## Testing

- **Framework**: Use a modern testing framework like [Jest](https://jestjs.io/), [Vitest](https://vitest.dev/), or [Mocha](https://mochajs.org/).
- **Unit Tests**: Write unit tests for all utility functions and components.
- **Integration Tests**: Write integration tests for API interactions and flows.
- **Mocks**: Mock external dependencies to keep tests fast and deterministic.
- **Coverage**: Aim for high test coverage, but value meaningful tests over 100% coverage stats.

## Security

- **XSS**: Be wary of Cross-Site Scripting. Sanitize user input before rendering it to the DOM. Avoid `innerHTML` or `dangerouslySetInnerHTML` unless absolutely necessary and input is sanitized (e.g., with [DOMPurify](https://github.com/cure53/DOMPurify)).
- **Dependencies**: Regularly audit dependencies (`npm audit`) for vulnerabilities.
- **Sensitive Data**: Never commit secrets or keys to the repository.

## Modern Features

- **Optional Chaining**: Use `?.` to safely access nested properties.
- **Nullish Coalescing**: Use `??` to provide default values for `null` or `undefined` (but not `0` or `false`).
- **Object.entries/values**: Use `Object.keys`, `Object.values`, and `Object.entries` for iterating over objects.

```javascript
const street = user?.address?.street ?? 'Unknown Street';
```

## Recommended Tools

- **Linter**: [`ESLint`](https://eslint.org/). Use standard configs like [`eslint-config-airbnb-base`](https://www.npmjs.com/package/eslint-config-airbnb-base) or [`eslint-config-standard`](https://www.npmjs.com/package/eslint-config-standard).
- **Formatter**: [`Prettier`](https://prettier.io/). Integrate with ESLint to avoid conflicts.
- **Type Checking**: While this is a JS guide, consider using JSDoc with TypeScript checking (`// @ts-check`) or migrating to TypeScript for larger projects.
- **Bundler**: [`Vite`](https://vitejs.dev/), [`Webpack`](https://webpack.js.org/), or [`Rollup`](https://rollupjs.org/).


## Related Interview Questions

*   **[Practice Questions](../../interview_questions/javascript.md)**: Test your knowledge of Javascript concepts.
