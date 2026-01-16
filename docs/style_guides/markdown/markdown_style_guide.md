# Markdown Style Guide

This document outlines the coding standards and best practices for writing Markdown within this project. Adhering to these guidelines ensures documentation consistency, readability, and portability across different renderers (GitHub, GitLab, etc.).

## Table of Contents

1. [General Principles](#general-principles)
2. [File Naming and Location](#file-naming-and-location)
3. [Layout and Formatting](#layout-and-formatting)
4. [Headers](#headers)
5. [Lists](#lists)
6. [Code](#code)
7. [Links and Images](#links-and-images)
8. [Emphasis](#emphasis)
9. [Blockquotes](#blockquotes)
10. [Tables](#tables)
11. [Horizontal Rules](#horizontal-rules)
12. [HTML Usage](#html-usage)
13. [Front Matter](#front-matter)
14. [Accessibility](#accessibility)
15. [Recommended Tools](#recommended-tools)

## General Principles

- **CommonMark/GFM**: Adhere to [GitHub Flavored Markdown (GFM)](https://github.github.com/gfm/) specifications.
- **Readability**: The raw source should be readable as plain text.
- **Consistency**: Use the same formatting conventions throughout the project.
- **Semantic Line Breaks**: Prefer "one sentence per line" for prose. This minimizes diff noise when editing text in version control systems.

## File Naming and Location

- **Extension**: Use `.md` for all Markdown files. Avoid `.markdown` or `.mdown`.
- **Naming**: Use `kebab-case` for filenames (e.g., `user-guide.md`).
- **README**: Every directory should ideally have a `README.md` explaining its purpose and contents.
- **Case Sensitivity**: Always treat filenames as case-sensitive to ensure compatibility across filesystems (Linux, macOS, Windows).

## Layout and Formatting

- **Indentation**: Use 2 spaces for indentation. Do not use tabs.
- **Line Length**:
    - For code blocks and tables, allow long lines to avoid breaking syntax.
    - For prose, use semantic line breaks (new line after each sentence). If wrapping, limit to 80-100 characters.
- **Blank Lines**:
    - Surround headers, lists, code blocks, tables, and blockquotes with a single blank line to ensure proper rendering.
    - End the file with a single newline character.
- **Trailing Whitespace**: Remove all trailing whitespace from lines.

## Headers

- **Style**: Use ATX-style headers (prefixed with `#`).
- **Spacing**: Always put a space after the `#` characters (e.g., `# Header`, not `#Header`).
- **Hierarchy**:
    - Use H1 (`#`) for the document title only.
    - Do not skip heading levels (e.g., do not jump from H2 to H4).
- **No Trailing Punctuation**: Do not use colons or periods at the end of headers.

```markdown
# Document Title

## Section Header

### Subsection Header
```

## Lists

### Unordered Lists
- **Marker**: Use hyphens `-` consistently for unordered lists. Avoid mixing `*` and `+`.
- **Spacing**: Indent nested lists by 2 spaces.

```markdown
- Item 1
- Item 2
  - Sub-item A
  - Sub-item B
```

### Ordered Lists
- **Marker**: Use `1.` for all items. This makes reordering easier and markdown renderers will handle the numbering automatically.

```markdown
1. First step
1. Second step
1. Third step
```

## Code

### Inline Code
- Wrap inline code, commands, file paths, and keyboard shortcuts in backticks `` ` ``.

```markdown
Run the `npm install` command.
```

### Code Blocks
- **Fenced Blocks**: Use triple backticks \`\`\` for code blocks.
- **Language Tag**: Always specify the language identifier for syntax highlighting.
- **Indentation**: Do not indent the code block markers.

````markdown
```python
def hello():
    print("Hello, world!")
```
````

## Links and Images

### Links
- **Format**: Use the `[text](url)` format.
- **Descriptive Text**: Link text should describe the destination. Avoid "click here".
- **Relative Links**: Use relative paths for internal documentation to ensure links work across forks and offline.
- **Reference Links**: Use reference-style links for repeated URLs or to keep the paragraph readable.

```markdown
[Google](https://www.google.com)
[Style Guide](../README.md)
```

### Images
- **Format**: `![Alt Text](url)`.
- **Alt Text**: Always provide descriptive alt text for accessibility.

```markdown
![Architecture Diagram](./images/architecture.png)
```

## Emphasis

- **Bold**: Use double asterisks `**text**`.
- **Italic**: Use underscores `_text_` or single asterisks `*text*`. Be consistent (recommend `_` for clear distinction).
- **Strikethrough**: Use double tildes `~~text~~` (GFM feature).

## Blockquotes

- **Syntax**: Use `>` followed by a space.
- **Nesting**: Use `>>` for nested quotes.

```markdown
> This is a blockquote.
>
> > This is a nested blockquote.
```

## Tables

- **GFM Tables**: Use pipes `|` and hyphens `-` to create tables.
- **Alignment**: Use colons `:` in the delimiter row to specify alignment.
- **Spacing**: Align the pipes vertically in the source for readability (optional but recommended).

```markdown
| Command | Description |
| :------ | :---------- |
| `ls`    | List files  |
| `cd`    | Change dir  |
```

## Horizontal Rules

- **Syntax**: Use three hyphens `---` surrounded by blank lines.

```markdown
Section 1

---

Section 2
```

## HTML Usage

- **Avoidance**: Avoid raw HTML whenever possible to ensure security and portability.
- **Exceptions**: Use HTML only for features not supported by Markdown (e.g., complex tables, specific spacing) and if the target renderer supports it (GitHub supports a subset).

## Front Matter

- **Format**: Use YAML front matter at the very beginning of the file, delimited by `---`.
- **Usage**: Use for metadata like title, date, author, or tags (common in static site generators like Jekyll or Hugo).

```markdown
---
title: Markdown Style Guide
date: 2023-10-27
tags: [documentation, style-guide]
---
```

## Accessibility

- **Alt Text**: All images must have meaningful alt text.
- **Headings**: Use a logical heading structure (H1 -> H2 -> H3).
- **Links**: Use meaningful link text.
    - Bad: `[Click here](doc.md)`
    - Good: `[Read the documentation](doc.md)`

## Recommended Tools

- **Linter**: `markdownlint` (CLI or VS Code extension) to enforce standards.
- **Formatter**: `Prettier` for consistent formatting.
- **Preview**: VS Code Markdown Preview or similar tools.
- **Table Formatter**: Markdown Table Prettifier extensions.
