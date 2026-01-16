# TypeScript Style Guide

This document outlines the coding standards and best practices for TypeScript development within this project. Adhering to these guidelines ensures code consistency, type safety, readability, and maintainability.

## Table of Contents

1. [General Principles](#general-principles)
2. [Project Configuration](#project-configuration)
3. [Naming Conventions](#naming-conventions)
4. [Types and Type Safety](#types-and-type-safety)
5. [Variables and Constants](#variables-and-constants)
6. [Functions](#functions)
7. [Control Flow](#control-flow)
8. [Data Structures](#data-structures)
9. [Classes and OOP](#classes-and-oop)
10. [Asynchronous Programming](#asynchronous-programming)
11. [Modules and Imports](#modules-and-imports)
12. [Error Handling](#error-handling)
13. [Comments and Documentation](#comments-and-documentation)
14. [Testing](#testing)
15. [Recommended Tools](#recommended-tools)

## General Principles

- **Consistency**: Consistency with the existing codebase is paramount. If a pattern is established, follow it.
- **Type Safety**: Leverage TypeScript's type system to the fullest. Avoid bypassing type checks.
- **Readability**: Write code for humans first, computers second. Clear naming and structure are more important than clever one-liners.
- **Modern Features**: Use modern ECMAScript and TypeScript features (e.g., optional chaining, nullish coalescing) where appropriate.

## Project Configuration

- **Strict Mode**: Always enable `"strict": true` in [`tsconfig.json`](https://www.typescriptlang.org/tsconfig). This enables a suite of strict type checking options, including `noImplicitAny` and `strictNullChecks`.
- **No Unused Locals/Parameters**: Enable `"noUnusedLocals": true` and `"noUnusedParameters": true` to catch dead code.
- **Consistent Returns**: Enable `"noImplicitReturns": true` to ensure all code paths in a function return a value.

```json
// Recommended tsconfig.json settings
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "esModuleInterop": true,
    "forceConsistentCasingInFileNames": true
  }
}
```

## Naming Conventions

- **Variables & Functions**: Use `camelCase`.
- **Classes & Interfaces**: Use `PascalCase`.
- **Types & Enums**: Use `PascalCase`.
- **Constants**: Use `camelCase` for local constants, and `UPPER_CASE` for global, static constants (e.g., configuration values).
- **Booleans**: Prefix boolean variables/functions with `is`, `has`, `should`, or `can` (e.g., `isEnabled`, `hasAccess`).
- **Private Members**: Do not use the `_` prefix for private properties unless specifically required by a framework or to avoid naming collisions with getters/setters. Use the `private` keyword or `#` private fields.
- **Filenames**: Use `kebab-case` for all files (e.g., `user-profile.ts`, `api-client.ts`). React components may use `PascalCase` (e.g., `UserProfile.tsx`).

```typescript
// Good
const userName = 'Alice';
const MAX_RETRIES = 5;
class UserProfile {}
interface UserData {}
function getUser() {}

// Bad
const User_Name = 'Alice';
const max_retries = 5;
class userProfile {}
interface userData {}
```

## Types and Type Safety

- **No Any**: Avoid `any` at all costs. It disables type checking. Use `unknown` if the type is truly not known yet, and narrow it down later.
- **Interface vs Type**:
    - Use `interface` for defining object shapes and public APIs (extensible).
    - Use `type` for unions, intersections, primitives, and tuples.
- **Explicit Return Types**: Always explicitly type function return values, even if they can be inferred. This prevents accidental API changes.
- **No Non-Null Assertion**: Avoid the non-null assertion operator (`!`). Use optional chaining (`?.`) or proper null checks instead.
- **Readonly**: Mark properties as `readonly` if they shouldn't be mutated. Use `ReadonlyArray<T>` for arrays that shouldn't be modified.
- **Enums**: Prefer union types of string literals over `enum` for simple sets of values, as they are lighter and closer to JS. Use `const enum` if performance is critical and values are internal.

```typescript
// Good
type Status = 'pending' | 'active' | 'inactive';

interface User {
  readonly id: string;
  name: string;
  status: Status;
}

function getStatus(user: User): Status {
  return user.status;
}

// Bad
enum StatusEnum { // Often unnecessary overhead
  Pending,
  Active
}
```

## Variables and Constants

- **Const vs Let**: Use `const` by default. Only use `let` if re-assignment is necessary.
- **No Var**: Never use `var`.
- **Destructuring**: Use object and array destructuring when accessing multiple properties.

```typescript
// Good
const { name, age } = user;
const [first, second] = items;

// Bad
const name = user.name;
const age = user.age;
```

## Functions

- **Arrow Functions**: Use arrow functions for callbacks and simple functions. Use function declarations for top-level exports or when hoisting is needed.
- **Parameters**:
    - Use default parameter syntax (`param = defaultValue`) instead of mutating logic inside the function.
    - Use a config object (destructured) if a function takes more than 3 arguments.
- **Optional Parameters**: Use `?` for optional parameters.

```typescript
// Good
interface SearchConfig {
  query: string;
  limit?: number;
  offset?: number;
}

function search({ query, limit = 10, offset = 0 }: SearchConfig): void {
  // ...
}
```

## Control Flow

- **Equality**: Always use triple equals `===` and `!==`.
- **Loops**: Prefer `map`, `filter`, `reduce`, `find`, `every`, `some` over `for` loops. Use `for...of` if iteration is strictly necessary.
- **Switch**: Use `switch` statements for multiple conditions on the same variable. Ensure all cases are covered (exhaustive check) or a `default` is provided.

```typescript
// Exhaustive check example
type Action = { type: 'start' } | { type: 'stop' };

function handleAction(action: Action) {
  switch (action.type) {
    case 'start':
      // ...
      break;
    case 'stop':
      // ...
      break;
    default:
      const _exhaustiveCheck: never = action; // Error if a case is missed
  }
}
```

## Data Structures

- **Arrays**: Use `[]` shorthand for simple arrays (`string[]`). Use `Array<T>` for complex types (`Array<string | number>`).
- **Maps and Sets**: Use `Map` and `Set` when keys are not strings or when frequent additions/removals occur.
- **Immutability**: Treat data as immutable where possible. Use spread syntax `...` to create copies.

## Classes and OOP

- **Access Modifiers**: Explicitly use `public`, `private`, and `protected`. Public is default, but being explicit documents intent.
- **Readonly Properties**: Mark properties initialized in the constructor that don't change as `readonly`.
- **Parameter Properties**: Use parameter properties in constructors to reduce boilerplate, but maintain readability.

```typescript
class Person {
  constructor(
    public readonly name: string,
    private age: number
  ) {}

  public getAge(): number {
    return this.age;
  }
}
```

## Asynchronous Programming

- **Async/Await**: Prefer `async`/`await` over `.then()` chains.
- **Promise.all**: Use `Promise.all` to run independent promises in parallel.
- **Error Handling**: Use `try/catch` with `await`.
- **Top-level await**: Use top-level await where supported (modern environments).

```typescript
// Good
async function fetchData() {
  try {
    const result = await api.get('/data');
    return result;
  } catch (error) {
    console.error(error);
  }
}
```

## Modules and Imports

- **ES Modules**: Always use ES Module syntax (`import`/`export`).
- **Import Order**:
    1. Built-in Node modules (e.g., `fs`, `path`).
    2. External dependencies (e.g., `react`, `lodash`).
    3. Internal modules (absolute or relative).
- **Named Exports**: Prefer named exports over default exports. This improves refactoring and tree-shaking.
- **Barrels**: Use `index.ts` files (barrel files) sparingly to group exports, but be mindful of circular dependencies.

```typescript
import path from 'path';
import { useState } from 'react';
import { User } from './models';
```

## Error Handling

- **Custom Errors**: Extend the built-in `Error` class for custom application errors.
- **Handling Unknowns**: When catching errors, remember they are of type `unknown`. Type guard them or cast safely.

```typescript
try {
  // ...
} catch (error) {
  if (error instanceof Error) {
    console.error(error.message);
  }
}
```

## Comments and Documentation

- **JSDoc**: Use [JSDoc](https://jsdoc.app/) `/** ... */` for public APIs, interfaces, and complex logic.
- **Self-documenting Code**: Prefer expressive variable names and clear structure over redundant comments.
- **TODOs**: Use `// TODO:` to mark areas for future work.

## Testing

- **Tools**: Use [**Jest**](https://jestjs.io/) or [**Vitest**](https://vitest.dev/) for unit testing.
- **File Naming**: Test files should be named `*.test.ts` or `*.spec.ts` and co-located with the source file or in a `__tests__` directory.
- **Descriptive Names**: Use descriptive strings in `describe` and `it`/`test` blocks.

## Recommended Tools

- **Linter**: [**ESLint**](https://eslint.org/) with [`typescript-eslint`](https://typescript-eslint.io/).
- **Formatter**: [**Prettier**](https://prettier.io/). Configure it to run on save.
- **Compiling**: **tsc** (TypeScript Compiler) or bundlers like [**Vite**](https://vitejs.dev/), [**esbuild**](https://esbuild.github.io/), or [**Webpack**](https://webpack.js.org/).
- **VS Code**: Use the official TypeScript extension and enable strict null checks in the editor.


## Related Interview Questions

*   **[Practice Questions](../../interview_questions/typescript.md)**: Test your knowledge of Typescript concepts.
