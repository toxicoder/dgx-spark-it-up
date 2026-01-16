# Code and Component Documentation

This document provides comprehensive guidelines for managing code components within the NVIDIA DGX Spark Utilities project. Code components are autonomous elements that perform specific tasks.

## Documentation Maintenance

All documentation files in this project should be kept up-to-date with the latest changes and implementation details.

## Style Guide Adherence

All code and documentation should follow the established style guides in the `docs/style_guides/` directory. When making changes, please ensure compliance with:

- **Markdown**: Follow the markdown style guide for all documentation files
- **Go**: Follow the Go style guide for all Go code files
- **Python**: Follow the Python style guide for all Python code files
- **TypeScript**: Follow the TypeScript style guide for all TypeScript files
- **YAML**: Follow the YAML style guide for all configuration files
- **Protobuf**: Follow the Protobuf style guide for all protocol buffer definitions
- **Shell/Bash**: Follow the Bash style guide for all shell scripts
- **JSON**: Follow the JSON style guide for all JSON files
- **SQL**: Follow the SQL style guide for all database schemas and queries
- **CSS**: Follow the CSS style guide for all styling files
- **HTML**: Follow the HTML style guide for all HTML files

When contributing to this project, always check the relevant style guide for formatting, naming conventions, and best practices before submitting changes. This ensures consistency across the entire codebase and documentation.

## Code Quality Requirements

All code should be:

- **Tested**: Implement comprehensive tests for all component functionality
- **Eng Documented**: Document all component capabilities and interfaces with rich and complete docstrings
- **Modularized**: Leverage functions and variables to consolidate related logic and improve readability and reusability
- **Well-documented**: Include rich and fully complete docstrings for all functions, methods, and classes
- **Error-handled**: Implement rich error handling with appropriate error types and messages
- **Logged**: Include proper logging for all significant operations and error conditions

## Model Workflow Guidelines

When working on tasks within the NVIDIA DGX Spark Utilities project, the model should follow a specific workflow that supports both "Plan" and "Act" modes:

### Plan Mode

In Plan Mode, the model should:

1. Analyze the requirements and constraints of the task
2. Break down the problem into smaller, manageable components
3. Identify the necessary files, tools, and resources required to complete the task
4. Create a detailed plan of action before implementing any changes
5. Consider potential edge cases and error conditions
6. Propose a clear, step-by-step approach for completing the task

### Act Mode

In Act Mode, the model should:

1. Execute the task or plan developed in Plan Mode, or directly proceed with implementation if no plan was created
2. Use appropriate tools to read, write, and modify files
3. Implement changes systematically and efficiently
4. Maintain clear documentation of actions taken
5. Follow the established style guides for all code and documentation
6. Ensure all changes comply with the project's code quality requirements
7. Test implementations where appropriate
8. Provide clear feedback on progress and completion status

When switching between Plan and Act modes, the model should clearly communicate its approach and maintain consistency with project standards.
