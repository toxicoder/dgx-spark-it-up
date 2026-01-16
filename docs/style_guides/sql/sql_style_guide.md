# SQL Style Guide

This document outlines the coding standards and best practices for SQL development within this project. Adhering to these guidelines ensures code consistency, readability, maintainability, and performance across different database systems (PostgreSQL, MySQL, BigQuery, etc.).

## Table of Contents

1. [General Principles](#general-principles)
2. [Code Layout and Formatting](#code-layout-and-formatting)
3. [Naming Conventions](#naming-conventions)
4. [Syntax and Language Features](#syntax-and-language-features)
5. [Data Integrity and Schema Design](#data-integrity-and-schema-design)
6. [Performance and Optimization](#performance-and-optimization)
7. [Security](#security)
8. [Documentation and Comments](#documentation-and-comments)
9. [Transaction Management](#transaction-management)
10. [Recommended Tools](#recommended-tools)

## General Principles

- **Readability First**: Code is read much more often than it is written. Prioritize clarity over cleverness or brevity.
- **Consistency**: Be consistent with the existing codebase. If you edit a file, follow the existing style.
- **Portability**: Where possible, use standard ANSI SQL to ensure portability across different database systems. Avoid vendor-specific extensions unless necessary for performance or specific functionality.
- **Explicit is Better**: Avoid implicit behaviors. Explicitly define column names in `SELECT` and `INSERT` statements.
- **Performance Aware**: Write queries that are performant and scalable. Understand the cost of operations.

## Code Layout and Formatting

- **Indentation**: Use 2 or 4 spaces (consistent with project preferences) for indentation. Do not use tabs.
- **Keywords**: Use `UPPERCASE` for all SQL keywords (e.g., `SELECT`, `FROM`, `WHERE`, `AS`, `CASE`).
- **Identifiers**: Use `snake_case` for all identifiers (tables, columns, aliases).
- **Line Length**: Soft limit of 80-100 characters per line.
- **Clauses**: Place primary clauses (`SELECT`, `FROM`, `WHERE`, `GROUP BY`, etc.) on their own lines.
- **Joins**: Align `JOIN` keywords with the `FROM` keyword. Place `ON` conditions on a new line, indented.
- **Lists**: When selecting multiple columns, place each column on a new line, indented.
- **Commas**: Use trailing commas.
- **Parentheses**: Use parentheses to group conditions and improve readability, even if operator precedence makes them optional.

```sql
-- Good
SELECT
    u.id,
    u.username,
    u.email,
    COUNT(o.id) AS total_orders
FROM
    users AS u
    LEFT JOIN orders AS o
        ON u.id = o.user_id
WHERE
    u.status = 'active'
    AND u.created_at >= '2023-01-01'
GROUP BY
    u.id,
    u.username,
    u.email
ORDER BY
    total_orders DESC;
```

## Naming Conventions

- **Tables**: Use `snake_case`. Use plural names for tables (e.g., `users`, `orders`, `order_items`) to represent a collection of records.
- **Columns**: Use `snake_case`. Names should be descriptive.
    - Booleans: Prefix with `is_`, `has_`, or `can_` (e.g., `is_active`, `has_permission`).
    - Dates/Times: Suffix with `_at` for timestamps (e.g., `created_at`) or `_date` for dates (e.g., `birth_date`).
- **Primary Keys**: Prefer `id` as the primary key name for simplicity, or `table_name_id` if using natural keys or requiring global uniqueness context.
- **Foreign Keys**: Use `referenced_table_singular_id` (e.g., `user_id` in the `orders` table).
- **Aliases**: Use short, meaningful abbreviations.
    - `users` -> `u`
    - `orders` -> `o`
    - Avoid `a`, `b`, `c` unless in a very abstract subquery.
    - Always use `AS` for aliases (e.g., `SELECT col AS alias`).
- **Indexes**: `idx_tablename_columns` (e.g., `idx_users_email`).
- **Constraints**:
    - Primary Key: `pk_tablename`
    - Foreign Key: `fk_tablename_referencedtable`
    - Unique: `uq_tablename_columns`

## Syntax and Language Features

- **Select ***: Avoid `SELECT *`. Always explicitly list columns. This prevents breakage when schema changes and reduces network overhead.
- **Joins**: Always use explicit ANSI join syntax (`JOIN`, `LEFT JOIN`) instead of implicit joins in the `WHERE` clause.
- **CTEs vs Subqueries**: Prefer Common Table Expressions (CTEs) using `WITH` clauses over nested subqueries for readability and logic separation.
- **NULL Handling**:
    - Use `IS NULL` or `IS NOT NULL` checks.
    - Use `COALESCE` to handle potential NULL values in calculations or display.
    - Be aware of how aggregate functions handle NULLs (usually ignored).
- **Data Types**: Choose the appropriate data type for the data.
    - Use `TEXT` or `VARCHAR` for strings.
    - Use `TIMESTAMP WITH TIME ZONE` (or equivalent) for time data to avoid timezone confusion.
    - Use `DECIMAL` or `NUMERIC` for financial data to avoid floating-point errors.
- **Window Functions**: Use window functions (`ROW_NUMBER`, `RANK`, `LEAD`, `LAG`) for analytical queries instead of complex self-joins.
- **Semicolons**: Always terminate statements with a semicolon `;`.

```sql
-- Good: Using CTEs
WITH recent_orders AS (
    SELECT
        user_id,
        MAX(created_at) AS last_order_date
    FROM
        orders
    GROUP BY
        user_id
)
SELECT
    u.username,
    ro.last_order_date
FROM
    users AS u
    JOIN recent_orders AS ro
        ON u.id = ro.user_id;
```

## Data Integrity and Schema Design

- **Normalization**: Aim for 3rd Normal Form (3NF) for transactional databases to reduce redundancy and anomalies. Denormalize only for proven performance needs in analytical workloads.
- **Constraints**: Enforce integrity at the database level.
    - **NOT NULL**: Default to `NOT NULL` unless a value is optional.
    - **Foreign Keys**: Always define FK constraints to ensure referential integrity.
    - **Unique**: Use unique constraints to prevent duplicate data.
    - **Check**: Use check constraints for data validation (e.g., `price >= 0`).
- **Default Values**: Use default values where appropriate (e.g., `created_at DEFAULT CURRENT_TIMESTAMP`).
- **Migrations**: All schema changes must be versioned and reversible (where possible).

## Performance and Optimization

- **Indexing**:
    - Index columns used in `WHERE`, `JOIN`, `ORDER BY`, and `GROUP BY` clauses.
    - Avoid over-indexing; every index adds overhead to writes.
    - Use composite indexes for queries filtering on multiple columns (order matters: equality first, then range).
- **SARGable Queries**: Write Search ARGumentable queries.
    - Avoid functions on indexed columns in the `WHERE` clause (e.g., `WHERE YEAR(date_col) = 2023`). Instead use range checks (`WHERE date_col >= '2023-01-01' AND date_col < '2024-01-01'`).
    - Avoid leading wildcards in `LIKE` (`'%value'`).
- **Set-Based Operations**: Think in sets, not loops. Avoid cursors and procedural loops whenever possible.
- **Explain Plan**: Always check the execution plan (`EXPLAIN` or `EXPLAIN ANALYZE`) for complex or slow-running queries.
- **Limit**: Use `LIMIT` when you only need a sample or top-N results.

## Security

- **SQL Injection**: NEVER concatenate user input directly into SQL strings.
    - Use prepared statements / parameterized queries provided by your client library.
- **Least Privilege**: Application users/roles should only have the permissions necessary (e.g., `CONNECT`, `SELECT`, `INSERT`, `UPDATE`).
    - Do not use the `root` or `postgres` superuser for applications.
    - Restrict access to DDL commands (`CREATE`, `DROP`, `ALTER`).
- **Sensitive Data**: Encrypt sensitive data (PII, passwords) at rest and in transit. Hashing (e.g., bcrypt, argon2) is mandatory for passwords.

## Documentation and Comments

- **Header Comments**: For complex stored procedures or views, include a header comment explaining the purpose, author, and parameters.
- **Inline Comments**: Use `--` for inline comments. Explain *why* complex logic is used.
- **Schema Documentation**: Use the database's comment feature (`COMMENT ON TABLE`, `COMMENT ON COLUMN`) to document the schema itself.

```sql
COMMENT ON TABLE users IS 'Stores registered user accounts';
COMMENT ON COLUMN users.status IS 'Current state of the user account (active, suspended, deleted)';
```

## Transaction Management

- **ACID**: Ensure operations that modify multiple tables are wrapped in a transaction to maintain Atomicity, Consistency, Isolation, and Durability.
- **Explicit Transactions**: Use `BEGIN`, `COMMIT`, and `ROLLBACK` explicitly when logic requires it.
- **Locking**: Be aware of locking behavior. keep transactions short to avoid blocking other operations.
- **Error Handling**: Implement proper error handling in stored procedures or application code to rollback transactions on failure.

## Recommended Tools

- **Linter**: `sqlfluff` - A modular SQL linter and auto-formatter.
- **Formatter**: `sql-formatter` or `pgFormatter`.
- **Migration Tools**: `Flyway`, `Liquibase`, or language-specific tools like `alembic` (Python), `golang-migrate` (Go).
- **GUI Clients**: `DBeaver`, `DataGrip`, or `Postico` for safe database exploration.


## Related Interview Questions

*   **[Practice Questions](../../interview_questions/sql.md)**: Test your knowledge of Sql concepts.
