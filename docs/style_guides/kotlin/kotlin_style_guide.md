# Kotlin Style Guide

This document outlines the coding standards and best practices for Kotlin development within this project. Adhering to these guidelines ensures code consistency, readability, and maintainability.

## Table of Contents

1. [General Principles](#general-principles)
2. [Source Files](#source-files)
3. [Formatting](#formatting)
4. [Naming Conventions](#naming-conventions)
5. [Documentation](#documentation)
6. [Classes and Objects](#classes-and-objects)
7. [Functions](#functions)
8. [Properties](#properties)
9. [Control Flow](#control-flow)
10. [Null Safety](#null-safety)
11. [Idiomatic Kotlin](#idiomatic-kotlin)
12. [Concurrency](#concurrency)
13. [Testing](#testing)
14. [Recommended Tools](#recommended-tools)

## General Principles

- **Standard**: Follow the [official Kotlin Coding Conventions](https://kotlinlang.org/docs/coding-conventions.html) and [Google's Kotlin Style Guide](https://developer.android.com/kotlin/style-guide) unless otherwise specified.
- **Readability**: Code is read much more often than it is written. Prioritize clarity over brevity.
- **Consistency**: Be consistent with the existing codebase. If you edit a file, follow its existing style.
- **Immutability**: Prefer immutable data structures (`val` over `var`, read-only collections) to reduce side effects.

## Source Files

- **File Naming**:
    - Use `PascalCase` (UpperCamelCase) for file names (e.g., `ProcessData.kt`).
    - If a file contains a single top-level class, the file name should match the class name.
    - If a file contains multiple top-level declarations, choose a name that describes the contents (e.g., `Extensions.kt`).
- **File Structure**:
    1. File annotations (e.g., `@file:JvmName("...")`).
    2. Package declaration.
    3. Import statements.
    4. Top-level declarations (classes, objects, interfaces, functions, properties).
- **Encoding**: Source files must be encoded in **UTF-8**.

## Formatting

- **Indentation**: Use **4 spaces** for indentation. Do not use tabs.
- **Line Length**: Limit lines to **100 characters**.
    - Exceptions: Package imports, URLs in comments, and shell commands.
- **Braces**:
    - Open braces at the end of the line where the construct begins.
    - Close braces on a separate line, aligned horizontally with the opening construct.
    - Use braces for all control structures (`if`, `when`, `for`, `do`, `while`), even if the body is a single line.

```kotlin
if (elements.isEmpty()) {
    return null
} else {
    elements.forEach { print(it) }
}
```

- **Whitespace**:
    - Put spaces around binary operators (`a + b`).
    - Put spaces after keywords (`if`, `when`, `for`, `catch`).
    - Do not put spaces around the range operator (`0..10`).
    - Put a space before the opening brace `{`.
    - Colon spacing:
        - `fun foo(x: Int): String` (no space before colon when specifying type).
        - `class Foo : Bar` (space before and after colon for inheritance).

## Naming Conventions

- **Packages**: `lowercase` with no underscores (e.g., `com.example.project`).
- **Classes/Interfaces/Objects**: `PascalCase` (UpperCamelCase).
- **Functions**: `camelCase`. Verbs or verb phrases.
    - Test functions in tests can use backticks with spaces (e.g., \`test data is valid\`).
- **Properties**: `camelCase`.
    - Constants (`const val`) should be `UPPER_SNAKE_CASE`.
    - Private properties used as backing fields for public properties should start with an underscore (e.g., `_elementList`).
- **Type Parameters**: Single capital letter (e.g., `T`, `E`, `K`, `V`).
- **Acronyms**: Treat acronyms as words (e.g., `HttpConnection`, not `HTTPConnection`).

## Documentation

- **KDoc**: Use KDoc comments (`/** ... */`) for public APIs.
    - Use `@param`, `@return`, `@throws`, `@receiver`, `@sample` tags.
    - The first line should be a summary description.
- **Comments**:
    - Use `//` for implementation details.
    - Avoid block comments `/* ... */` for code explanation; use them only for temporary commenting out of code.

```kotlin
/**
 * Calculates the total price including tax.
 *
 * @param price The base price of the item.
 * @param taxRate The tax rate as a decimal (e.g., 0.1 for 10%).
 * @return The total price.
 */
fun calculateTotal(price: Double, taxRate: Double): Double {
    return price * (1 + taxRate)
}
```

## Classes and Objects

- **Layout**:
    1. Property declarations and initializer blocks.
    2. Secondary constructors.
    3. Method declarations.
    4. Companion object.
- **Primary Constructors**: Use primary constructors in the class header.
- **Data Classes**: Use `data class` for classes that hold data.
- **Companion Objects**: Place at the bottom of the class. Use explicitly named companion objects only if necessary.
- **Object Declarations**: Use `object` for singletons.

## Functions

- **Single-Expression Functions**: Use expression body syntax when the function body is a single expression.

```kotlin
// Preferred
fun square(x: Int): Int = x * x

// Avoid for simple expressions
fun square(x: Int): Int {
    return x * x
}
```

- **Default Arguments**: Prefer default arguments over function overloading.
- **Named Arguments**: Use named arguments when a function has many parameters or boolean flags, for clarity.
- **Extension Functions**: Use liberally to extend functionality without inheritance, but avoid polluting the global namespace. Keep them relevant to the receiver.
- **Unit Return**: Omit the return type if it is `Unit`.

## Properties

- **Val vs Var**: Prefer `val` (read-only) over `var` (mutable).
- **Custom Accessors**: Use custom get/set only when necessary.
- **Backing Properties**: Use `_propertyName` for private mutable state exposed as public immutable state.

```kotlin
private val _items = mutableListOf<String>()
val items: List<String> get() = _items
```

- **Lateinit**: Use `lateinit` only when dependency injection or setup methods are unavoidable. Prefer nullable types initialized to `null` if possible.

## Control Flow

- **When Expression**: Prefer `when` over `if-else if` chains when checking more than two conditions or checking against types/ranges.
- **Loops**: Prefer functional operations (`map`, `filter`, `forEach`) over imperative loops (`for`, `while`) for collection processing.
- **Trailing Lambdas**: If the last argument of a function is a function, place the lambda outside the parentheses.

```kotlin
items.filter { it.isValid }
     .map { it.name }
```

## Null Safety

- **Nullable Types**: Define types as nullable `Type?` only if `null` is a valid state.
- **Safe Calls**: Use `?.` for accessing properties/methods of nullable types.
- **Elvis Operator**: Use `?:` for default values.
- **Not-Null Assertion**: **Avoid** `!!` operators. If you think you need it, refactor the code or use `requireNotNull()`/`checkNotNull()` with a message.

## Idiomatic Kotlin

- **Scope Functions**: Use scope functions (`let`, `run`, `with`, `apply`, `also`) appropriately:
    - `let`: Execute a block on non-null objects (`obj?.let { ... }`).
    - `apply`: Configure an object (returns the object itself).
    - `run`: Compute a value from an object context.
    - `also`: Perform side effects (returns the object itself).
    - `with`: Call multiple methods on an object instance.
- **String Templates**: Use string templates (`"$variable"`) instead of concatenation.
- **Ranges**: Use ranges (`1..10`, `1 until 10`, `10 downTo 1`) for loops and checks.

## Concurrency

- **Coroutines**: Prefer Kotlin Coroutines over threads and `Future`s.
- **Suspend Functions**: Use `suspend` modifier for functions that perform long-running or blocking operations.
- **Dispatchers**: Use `Dispatchers.IO` for I/O operations and `Dispatchers.Default` for CPU-intensive tasks. Avoid `GlobalScope`.
- **Structured Concurrency**: Ensure all coroutines are launched within a specific `CoroutineScope` tied to a lifecycle.

## Testing

- **Framework**: JUnit 5 or Kotest.
- **Mocking**: MockK (preferred over Mockito for Kotlin).
- **Naming**:
    - Use descriptive names, potentially with backticks: `` `calculating total returns correct sum` ``.
- **Assertions**: Use strict assertions (e.g., Kotest assertions or AssertJ).

## Recommended Tools

- **Build System**: Gradle (Kotlin DSL preferred).
- **Linter/Formatter**:
    - [ktlint](https://github.com/pinterest/ktlint): Anti-bikeshedding Kotlin linter with built-in formatter.
    - [detekt](https://github.com/detekt/detekt): Static code analysis for Kotlin.
- **IDE**: IntelliJ IDEA or Android Studio.


## Related Interview Questions

*   **[Practice Questions](../../interview_questions/kotlin.md)**: Test your knowledge of Kotlin concepts.
