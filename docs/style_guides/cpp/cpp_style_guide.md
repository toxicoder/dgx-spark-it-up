# C++ Style Guide

This document outlines the coding standards and best practices for C++ development within this project. Adhering to these guidelines ensures code consistency, readability, maintainability, and safety.

## Table of Contents

1. [General Principles](#general-principles)
2. [Code Layout](#code-layout)
3. [Naming Conventions](#naming-conventions)
4. [Files and Structure](#files-and-structure)
5. [Documentation and Comments](#documentation-and-comments)
6. [Classes and Structs](#classes-and-structs)
7. [Functions](#functions)
8. [Modern C++ Features](#modern-c-features)
9. [Error Handling](#error-handling)
10. [Concurrency](#concurrency)
11. [Templates and Generic Programming](#templates-and-generic-programming)
12. [Casts and Types](#casts-and-types)
13. [Memory Management](#memory-management)
14. [Performance and Optimization](#performance-and-optimization)
15. [Testing](#testing)
16. [Recommended Tools](#recommended-tools)

## General Principles

- **Standard**: Target C++17 or C++20 (project dependent). Avoid non-standard extensions.
- **C++ Core Guidelines**: Follow the [C++ Core Guidelines](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines) unless otherwise specified.
- **Readability**: Code is read much more often than it is written. Prioritize clarity over brevity.
- **Consistency**: Be consistent with the existing codebase.
- **Safety**: Prefer safe constructs (smart pointers, `std::array`, `std::vector`) over unsafe ones (raw pointers, C-style arrays).

## Code Layout

- **Indentation**: Use 4 spaces per indentation level. Do not use tabs.
- **Line Length**: Limit lines to 100 characters (or 80 if strict adherence is preferred).
- **Braces**:
    - Use "K&R" or "1TBS" style (opening brace on the same line) for control structures and functions.
    - Putting the opening brace on a new line (Allman style) is acceptable if consistent within a module.
- **Whitespace**:
    - Spaces around binary operators (`+`, `-`, `=`, `==`, etc.).
    - Space after comma in argument lists.
    - No space between function name and opening parenthesis.
- **Pointer/Reference Alignment**: Align `*` and `&` with the type, not the variable name (e.g., `int* ptr` not `int *ptr`).
    - *Reasoning*: The type is `int*` (pointer to int).
- **Class Access Modifiers**: Indent `public:`, `protected:`, and `private:` labels.

```cpp
class MyClass {
  public:
    void do_something();

  private:
    int m_value;
};

void do_something(int a, int b) {
    if (a > b) {
        return;
    }
}
```

## Naming Conventions

- **Variables**: `snake_case` (e.g., `item_count`, `user_name`).
- **Functions**: `snake_case` (e.g., `calculate_total`, `get_id`).
- **Classes/Structs**: `PascalCase` (e.g., `UserManager`, `HttpRequest`).
- **Constants**: `kPascalCase` or `UPPER_CASE_WITH_UNDERSCORES` (e.g., `kMaxRetry`, `MAX_BUFFER_SIZE`).
- **Private Members**: `m_` prefix + `snake_case` or trailing underscore (e.g., `m_count` or `count_`). Be consistent.
- **Namespaces**: `snake_case`.
- **Template Types**: `PascalCase` or single uppercase letter `T` (e.g., `T`, `InputIterator`, `ValueType`).
- **Macros**: `UPPER_CASE_WITH_UNDERSCORES` (Avoid macros if possible).

## Files and Structure

- **Extensions**: `.cpp` for source files, `.hpp` or `.h` for headers.
- **Include Guards**: Use `#pragma once` for header files. It is widely supported and less error-prone than `#ifndef` guards.
- **Include Order**:
    1. Related header (e.g., `my_class.cpp` includes `my_class.hpp`).
    2. C standard library headers (e.g., `<cmath>`).
    3. C++ standard library headers (e.g., `<vector>`, `<algorithm>`).
    4. Third-party libraries.
    5. Project headers.
    - Separate groups with a blank line. Alphabetize within groups.
- **Forward Declarations**: Use forward declarations where possible to reduce compile times and dependencies.
- **Inline Functions**: Define small functions (1-3 lines) inline in the header or class definition.

## Documentation and Comments

- **Style**: Use [Doxygen](https://doxygen.nl/)-compatible comments (`///` or `/** ... */`).
- **Files**: Top of file comment explaining the file's purpose.
- **Classes/Functions**: Document public APIs, including parameters, return values, exceptions, and thread safety.
- **Implementation**: Comment complex logic explaining *why*, not *what*.

```cpp
/// @brief Calculates the Fibonacci sequence.
/// @param n The position in the sequence to calculate.
/// @return The nth Fibonacci number.
/// @throws std::invalid_argument if n is negative.
int fibonacci(int n);
```

## Classes and Structs

- **Structs**: Use `struct` only for passive data objects (PODs) with public data members.
- **Initialization**: Use member initializer lists in constructors. Prefer in-class member initialization (C++11).
- **Explicit**: Mark single-argument constructors as `explicit` to avoid implicit conversions.
- **Rule of 5**: If you define a destructor, copy/move constructor, or copy/move assignment operator, define all 5 (or delete them).
- **Zero Rule**: Prefer classes that require no custom destructor/copy/move logic (rely on `std::string`, `std::vector`, etc.).
- **Virtual**: Use `override` explicitly for overridden virtual functions. Use `final` if further overriding is disallowed.
- **Destructors**: Virtual destructors are required for base classes with virtual functions.

```cpp
class Widget {
  public:
    explicit Widget(int id) : m_id(id) {} // Initializer list
    virtual ~Widget() = default;          // Virtual destructor

    virtual void draw() const = 0;

  private:
    int m_id = 0; // In-class initialization
};
```

## Functions

- **Parameters**:
    - Primitive types: Pass by value (`int`, `bool`, `double`).
    - Objects: Pass by `const` reference (`const std::string&`) to avoid copies.
    - Mutable output: Prefer returning values or structs. If necessary, pass by pointer (`int* out_val`). Avoid non-const references for output parameters as they are less obvious at the call site.
- **Return Values**: Rely on Return Value Optimization (RVO). Do not `std::move` return values explicitly unless necessary.
- **Const Correctness**: Mark member functions `const` if they do not modify the object. Mark variables `const` wherever possible.
- **Noexcept**: Mark functions `noexcept` if they are guaranteed not to throw, especially move constructors and destructors.

## Modern C++ Features

- **Auto**: Use `auto` when the type is obvious (e.g., `auto it = map.begin()`, `auto widget = std::make_unique<Widget>()`) or redundant. Avoid `auto` when it obscures the type.
- **Smart Pointers**:
    - `std::unique_ptr`: Default choice for exclusive ownership.
    - `std::shared_ptr`: Shared ownership. Use `std::make_shared`.
    - `std::weak_ptr`: Break cycles or temporary observation.
    - Avoid `new` and `delete` directly.
- **Lambdas**: Use lambdas for short, local callbacks. Capture explicitly (`[this]`, `[&]`, `[=]`) rather than implicitly if scope is complex.
- **Range-based for**: Use `for (const auto& item : items)` for iteration.
- **Structured Binding**: Use `auto [key, value] = *it;` (C++17) for unpacking pairs/tuples.

## Error Handling

- **Exceptions**: Use exceptions for error handling, not control flow.
- **Standard Exceptions**: Throw standard exceptions (`std::runtime_error`, `std::invalid_argument`) or derive from them.
- **Noexcept**: Ensure destructors, swap functions, and move operations do not throw.
- **Alternatives**: For expected failures (e.g., "file not found"), consider `std::optional` or [`std::expected`](https://en.cppreference.com/w/cpp/utility/expected) (C++23) over exceptions to indicate "no value".

## Concurrency

- **Standard Library**: Use `std::thread`, `std::mutex`, `std::condition_variable`.
- **Locks**: Use `std::lock_guard` or `std::unique_lock` for RAII-style locking. Never manually `lock()` and `unlock()`.
- **Atomics**: Use `std::atomic` for simple shared flags or counters.
- **Data Races**: Ensure all shared data is protected. Use tools like [ThreadSanitizer](https://github.com/google/sanitizers/wiki/ThreadSanitizerCppManual).
- **Async**: Prefer `std::async` for simple tasks returning a value (`std::future`).

## Templates and Generic Programming

- **Constraints**: Use C++20 Concepts (`requires`) to constrain templates for better error messages.
- **Type Traits**: Use `<type_traits>` (`std::is_same_v`, `std::enable_if_t`) for compile-time logic if Concepts are unavailable.
- **Implementation**: Put template implementation in headers.

```cpp
template <typename T>
requires std::integral<T> // C++20 Concept
T add(T a, T b) {
    return a + b;
}
```

## Casts and Types

- **C++ Casts**: Use `static_cast`, `dynamic_cast`, `reinterpret_cast`, `const_cast`.
- **Avoid C-Style Casts**: Never use `(int)x`. They are dangerous and hard to grep.
- **Signed/Unsigned**: Be careful comparing signed and unsigned integers. Prefer `int` for arithmetic unless bitwise operations or specific overflow behavior is needed.
- **Size**: Use `std::size_t` for sizes and indices.

## Memory Management

- **RAII**: Resource Acquisition Is Initialization. Wrap resources (memory, file handles, sockets) in classes that release them in the destructor.
- **Containers**: Prefer `std::vector`, `std::string`, `std::array` over raw arrays.
- **String Views**: Use `std::string_view` (C++17) for read-only string arguments to avoid allocations.

## Performance and Optimization

- **Premature Optimization**: Do not optimize without profiling. Readable code is often fast enough.
- **Pass by Reference**: Avoid copying large objects.
- **Move Semantics**: Implement move constructor/assignment for heavy objects.
- **Constexpr**: Use `constexpr` for values and functions computed at compile time.

## Testing

- **Framework**: Use [Google Test (GTest)](https://github.com/google/googletest) or [Catch2](https://github.com/catchorg/Catch2).
- **Unit Tests**: Write unit tests for all public interfaces.
- **Coverage**: Aim for high test coverage.
- **Structure**: Keep tests in a separate directory (e.g., `tests/`) or alongside source (e.g., `_test.cpp`).

## Recommended Tools

- **Formatter**: [`clang-format`](https://clang.llvm.org/docs/ClangFormat.html). Check in a `.clang-format` file.
- **Linter**: [`clang-tidy`](https://clang.llvm.org/extra/clang-tidy/) for static analysis and modernizing code.
- **Build System**: [CMake](https://cmake.org/) is the industry standard.
- **Compiler**: Enable warnings: `-Wall -Wextra -Werror -pedantic`.
- **Sanitizers**: Use [AddressSanitizer (ASan)](https://github.com/google/sanitizers/wiki/AddressSanitizer) and [UndefinedBehaviorSanitizer (UBSan)](https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html) during development/CI.
