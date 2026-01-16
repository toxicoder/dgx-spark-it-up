# Protocol Buffers Style Guide

This document outlines the coding standards and best practices for Protocol Buffers (`.proto`) files within this project. Adhering to these guidelines ensures API consistency, compatibility, and maintainability across services.

## Table of Contents

1. [General Principles](#general-principles)
2. [File Layout](#code-layout)
3. [Naming Conventions](#naming-conventions)
4. [Versioning](#versioning)
5. [Documentation and Comments](#documentation-and-comments)
6. [Enums](#enums)
7. [Messages](#messages)
8. [Services](#services)
9. [Best Practices](#best-practices)
10. [Breaking Changes](#breaking-changes)
11. [Recommended Tools](#recommended-tools)

## General Principles

- **Consistency**: Follow the conventions of the Google Protocol Buffers style guide and the Buf style guide.
- **Compatibility**: Always design for backward compatibility. Never remove or change the type of a used field.
- **Clarity**: APIs should be intuitive and self-documenting.

## Code Layout

- **Indentation**: Use 2 spaces per indentation level. Do not use tabs.
- **Line Length**: Limit lines to 80 characters.
- **File Structure**:
    1.  License header (if applicable).
    2.  Syntax declaration (`syntax = "proto3";`).
    3.  Package declaration.
    4.  Imports (sorted alphabetically).
    5.  Options (file-level).
    6.  Messages, Enums, and Services.

```protobuf
syntax = "proto3";

package my.package.v1;

import "google/protobuf/timestamp.proto";

option go_package = "github.com/myorg/myrepo/gen/go/my/package/v1;packagev1";

message MyMessage {
  // ...
}
```

## Naming Conventions

- **File Names**: `lower_snake_case.proto` (e.g., `user_profile.proto`).
- **Package Names**: `lower_snake.case.vN` (e.g., `acme.weather.v1`).
    - Must end with a version component (e.g., `v1`, `v1beta1`).
    - Match the directory structure.
- **Message Names**: `PascalCase` (e.g., `UserProfile`).
- **Field Names**: `lower_snake_case` (e.g., `first_name`, `email_address`).
- **Repeated Fields**: Pluralized names (e.g., `users`, `items`).
- **Enums**: `PascalCase` (e.g., `UserStatus`).
- **Enum Values**: `UPPER_CASE_WITH_UNDERSCORES` (e.g., `USER_STATUS_ACTIVE`).
    - Prefix with the upper-cased enum name (e.g., `USER_STATUS_UNSPECIFIED`).
- **Services**: `PascalCase` (e.g., `UserService`).
- **RPCs**: `PascalCase` (e.g., `GetUser`).
- **Request/Response Messages**:
    - Request: `MethodNameRequest` (e.g., `GetUserRequest`).
    - Response: `MethodNameResponse` (e.g., `GetUserResponse`).

## Versioning

- **Semantic Versioning**: Use the package name to denote the API version.
- **Beta/Alpha**: Use `v1beta1`, `v1alpha1` for unstable APIs.
- **Breaking Changes**: Breaking changes require a new major version package (e.g., `v1` -> `v2`).

## Documentation and Comments

- **Style**: Use `//` for comments. Do not use `/* ... */`.
- **Location**: Place comments directly above the definition.
- **Content**:
    - Messages: Describe what the entity represents.
    - Fields: Describe the purpose of the field and any constraints.
    - Services: Describe the high-level purpose of the service.
    - RPCs: Describe the input, output, and side effects.

```protobuf
// User represents a registered user in the system.
message User {
  // The unique identifier for the user.
  string id = 1;

  // The user's display name.
  string display_name = 2;
}
```

## Enums

- **Zero Value**: The first value (0) must be the "unspecified" variant.
    - Format: `ENUM_NAME_UNSPECIFIED = 0;`.
    - This serves as the default value when the field is unset.

```protobuf
enum AccountState {
  ACCOUNT_STATE_UNSPECIFIED = 0;
  ACCOUNT_STATE_ACTIVE = 1;
  ACCOUNT_STATE_SUSPENDED = 2;
  ACCOUNT_STATE_CLOSED = 3;
}
```

## Messages

- **Field Numbers**:
    - Number fields consecutively starting from 1.
    - Reserve deleted field numbers to prevent reuse.
- **Oneof**: Use `oneof` for mutually exclusive fields. The name should be `lower_snake_case`.

## Services

- **Request/Response**: Every RPC *must* take a unique request message and return a unique response message, even if empty.
    - This allows for future extensibility without breaking the API.
    - Avoid reusing messages across different RPCs.

```protobuf
service PaymentService {
  rpc ProcessPayment(ProcessPaymentRequest) returns (ProcessPaymentResponse);
}

message ProcessPaymentRequest {
  string order_id = 1;
  Money amount = 2;
}

message ProcessPaymentResponse {
  string transaction_id = 1;
}
```

## Best Practices

- **Avoid `required`**: `proto3` does not support `required`. Avoid it in `proto2` as well.
- **Use Standard Types**: Use `google.protobuf.Timestamp` for time and `google.protobuf.Duration` for durations.
- **Empty Messages**: Use empty request/response messages instead of `google.protobuf.Empty` if you might add fields later.
- **Maps**: Use `map<key_type, value_type>` for associative arrays. Key types can be any integral or string type.

## Breaking Changes

Avoid the following changes in a stable version:
- Changing a field number.
- Changing a field type.
- Renaming a field (this breaks JSON serialization).
- Deleting a required field (in proto2).
- Adding a required field (in proto2).
- Moving a field into or out of a `oneof`.

Safe changes:
- Adding a new field (optional/repeated).
- Deleting a field (reserve the number and name).
- Renaming a message or enum (updates generated code, but wire format is safe).

## Recommended Tools

- **Linter**: `buf lint` (enforces style and structural rules).
- **Formatter**: `buf format` (standardizes indentation and layout).
- **Breaking Change Detector**: `buf breaking` (detects backward-incompatible changes).
- **Language Server**: `clangd` or protocol buffers extensions for VS Code/IntelliJ.
