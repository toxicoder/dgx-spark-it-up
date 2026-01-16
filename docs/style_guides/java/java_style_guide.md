# Java Style Guide

This document outlines the coding standards and best practices for Java development within this project. Adhering to these guidelines ensures code consistency, readability, and maintainability.

## Table of Contents

1. [General Principles](#general-principles)
2. [Code Layout](#code-layout)
3. [Naming Conventions](#naming-conventions)
4. [Documentation and Comments](#documentation-and-comments)
5. [Declarations](#declarations)
6. [Imports](#imports)
7. [Control Structures](#control-structures)
8. [Object Oriented Programming](#object-oriented-programming)
9. [Exception Handling](#exception-handling)
10. [Generics](#generics)
11. [Lambdas and Streams](#lambdas-and-streams)
12. [Concurrency](#concurrency)
13. [Logging](#logging)
14. [Testing](#testing)
15. [Modern Java Features](#modern-java-features)
16. [Recommended Tools](#recommended-tools)

## General Principles

- **Standard**: Follow the [Google Java Style Guide](https://google.github.io/styleguide/javaguide.html) unless otherwise specified.
- **Readability**: Code is read much more often than it is written. Prioritize clarity over cleverness.
- **Consistency**: Be consistent with the existing codebase. If you edit a file, follow its style.
- **Simplicity**: Keep code simple and focused. Avoid over-engineering.

## Code Layout

- **Indentation**: Use 2 spaces (consistent with Google Style) or 4 spaces. **Choose one and be consistent across the project.** (Default for this guide: **2 spaces**). Do not use tabs.
- **Line Length**: Limit lines to 100 characters.
- **Line Wrapping**:
    - Break before operators.
    - Indent continuation lines by at least 4 spaces (or 2 indentation levels).
- **Blank Lines**:
    - Use blank lines to separate logical groups of code within methods.
    - Use one blank line between methods.
    - Use one blank line between the class declaration and the first member.
- **Whitespace**:
    - Separate keywords (`if`, `for`, `catch`) from the opening parenthesis with a space.
    - Separate closing parenthesis from the opening brace with a space.
    - Do not use space between method name and opening parenthesis.
    - Surround binary operators with spaces.
- **Braces**:
    - Used for `if`, `else`, `for`, `do`, and `while` statements, even when the body is empty or contains only a single statement (K&R style).
    - Opening brace on the same line as the declaration.
    - Closing brace on its own line.

```java
if (condition) {
  doSomething();
} else {
  doSomethingElse();
}
```

## Naming Conventions

- **Classes/Interfaces/Records**: `UpperCamelCase` (PascalCase). Nouns for classes, adjectives or nouns for interfaces.
- **Methods**: `lowerCamelCase`. Verbs or verb phrases.
- **Variables**: `lowerCamelCase`. Meaningful names.
- **Constants**: `UPPER_SNAKE_CASE`. `static final` fields that are immutable.
- **Packages**: `lowercase`. No underscores. `com.example.project`.
- **Type Parameters**: Single capital letter (e.g., `T`, `E`, `K`, `V`).
- **Test Classes**: End with `Test` (e.g., `UserServiceTest`).

## Documentation and Comments

- **Javadoc**: Required for all `public` and `protected` members (classes, methods, fields).
    - Use `@param`, `@return`, `@throws` tags.
    - The first sentence should be a summary fragment.
- **Implementation Comments**: Use `//` for implementation details. Avoid block comments `/* ... */` for code explanations.
- **Self-Documenting Code**: Prefer meaningful variable and method names over comments.
- **TODOs**: Use `TODO(User):` format.

```java
/**
 * Calculates the sum of two integers.
 *
 * @param a the first integer
 * @param b the second integer
 * @return the sum of a and b
 */
public int add(int a, int b) {
  return a + b;
}
```

## Declarations

- **Modifiers**: Order should be: `public/protected/private`, `abstract`, `static`, `final`, `transient`, `volatile`, `synchronized`, `native`, `strictfp`.
- **Annotations**: Place annotations on separate lines before the declaration.
- **Variables**: Declare variables where they are first needed, and initialize them immediately if possible. Avoid C-style array declarations (`String[] args` not `String args[]`).
- **Long Literals**: Use uppercase `L` suffix for long literals (`3000L` not `3000l`).

## Imports

- **No Wildcards**: Avoid wildcard imports (`import java.util.*;`). Import each class explicitly.
- **Order**:
    1. Static imports.
    2. Standard `java.*` and `javax.*` packages.
    3. Third-party packages (e.g., `org.apache.*`, `com.google.*`).
    4. Local application packages.
- **Separation**: Insert a blank line between each group.

## Control Structures

- **Switch**: Use the enhanced `switch` expression (Java 14+) where appropriate. Always include a `default` case unless covering all enum cases.
- **Loops**: Prefer enhanced `for` loops (`for (Type item : items)`) over index-based loops unless the index is needed.
- **Conditionals**: Avoid "yoda conditions" (`if (CONSTANT.equals(variable))`). While safe, standard `variable.equals(CONSTANT)` is preferred if null-safe, or use `Objects.equals()`.
- **Nesting**: Avoid deep nesting. Return early (Guard Clauses).

## Object Oriented Programming

- **Immutability**: Prefer immutable objects. Use `final` fields and constructor injection.
- **Interfaces**: Prefer coding to interfaces rather than implementations (e.g., `List<String> list = new ArrayList<>();`).
- **Constructors**: Chain constructors using `this()` if multiple constructors exist.
- **Overriding**: Always use `@Override` annotation when overriding methods.
- **Utility Classes**: Should be `final` and have a private constructor.
- **Records**: Use `record` (Java 16+) for data carriers (DTOs).

## Exception Handling

- **Checked vs Unchecked**: Prefer unchecked exceptions (`RuntimeException`) for recoverable errors or programming errors. Use checked exceptions sparingly.
- **Catching**: Catch specific exceptions. Never catch `Exception` or `Throwable` unless absolutely necessary (e.g., at the top-level main loop).
- **Ignored Exceptions**: Don't ignore exceptions. At least log them. If ignoring is intentional, comment why and name the variable `ignored`.
- **Try-with-resources**: Use try-with-resources for `AutoCloseable` resources (streams, connections).

```java
try (BufferedReader br = new BufferedReader(new FileReader(path))) {
    return br.readLine();
} catch (IOException e) {
    throw new UncheckedIOException(e);
}
```

## Generics

- **Raw Types**: Never use raw types (e.g., `List` instead of `List<String>`).
- **Inference**: Use the diamond operator `<>` when instantiating generics.
- **Wildcards**: Use `? extends T` for producers (read-only) and `? super T` for consumers (write-only) (PECS: Producer Extends, Consumer Super).

## Lambdas and Streams

- **Lambdas**: Keep lambdas short (one-liners preferred). If complex, extract to a method and use a method reference.
- **Streams**: Use streams for collection processing pipelines.
    - Break long stream chains onto multiple lines, one operation per line.
- **Side Effects**: Avoid side effects in stream operations (e.g., modifying external state within `map` or `filter`).

```java
List<String> names = users.stream()
    .filter(User::isActive)
    .map(User::getName)
    .sorted()
    .collect(Collectors.toList());
```

## Concurrency

- **Threads**: Avoid creating threads manually. Use `ExecutorService` or `CompletableFuture`.
- **Synchronization**: Prefer `java.util.concurrent` classes (`AtomicInteger`, `ConcurrentHashMap`, `Locks`) over `synchronized` blocks/methods.
- **Virtual Threads**: Use virtual threads (Java 21+) for high-throughput I/O-bound tasks.
- **Thread Safety**: Document thread safety of classes (`@ThreadSafe`, `@NotThreadSafe`).

## Logging

- **Framework**: Use SLF4J as the facade (with Logback or Log4j2 as implementation).
- **Levels**: `ERROR` (failures), `WARN` (potential issues), `INFO` (milestones), `DEBUG` (diagnostic), `TRACE` (fine-grained).
- **Format**: Do not use string concatenation. Use placeholders.
    - Good: `log.debug("Processing user: {}", userId);`
    - Bad: `log.debug("Processing user: " + userId);`

## Testing

- **Framework**: JUnit 5 (Jupiter).
- **Assertions**: AssertJ or Truth for fluent and readable assertions.
- **Mocking**: Mockito.
- **Naming**: `MethodName_StateUnderTest_ExpectedBehavior`.
- **Structure**: Tests should follow AAA (Arrange, Act, Assert).

```java
@Test
void calculateTotal_WithValidItems_ReturnsSum() {
    // Arrange
    Order order = new Order(List.of(new Item(10), new Item(20)));

    // Act
    int total = order.calculateTotal();

    // Assert
    assertThat(total).isEqualTo(30);
}
```

## Modern Java Features

- **Records**: Use for immutable data classes.
- **Text Blocks**: Use `"""` for multi-line strings (SQL, JSON, HTML).
- **Pattern Matching**: Use `instanceof` with pattern matching to avoid casting.
- **Switch Expressions**: Use concise switch syntax.
- **Sealed Classes**: Use `sealed` classes to restrict inheritance hierarchies.

```java
// Pattern Matching
if (obj instanceof String s) {
    System.out.println(s.toLowerCase());
}

// Switch Expression
int numLetters = switch (day) {
    case MONDAY, FRIDAY, SUNDAY -> 6;
    case TUESDAY -> 7;
    default -> 8;
};
```

## Recommended Tools

- **Build Systems**: Maven or Gradle.
- **Formatter**: `google-java-format` or Spotless.
- **Linter**: Checkstyle, PMD, SonarLint.
- **Static Analysis**: SpotBugs (successor to FindBugs).
- **Testing**: JUnit 5, Mockito, AssertJ.


## Related Interview Questions

*   **[Practice Questions](../../interview_questions/java.md)**: Test your knowledge of Java concepts.
