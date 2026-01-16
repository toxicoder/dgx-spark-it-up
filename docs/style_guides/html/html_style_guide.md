# HTML Style Guide

This document outlines the coding standards and best practices for writing HTML within this project. Adhering to these guidelines ensures code consistency, maintainability, accessibility, and cross-browser compatibility.

## Table of Contents

1. [General Principles](#general-principles)
2. [File Naming and Location](#file-naming-and-location)
3. [Formatting and Layout](#formatting-and-layout)
4. [Document Structure](#document-structure)
5. [Elements and Tags](#elements-and-tags)
6. [Attributes](#attributes)
7. [Semantics and Accessibility](#semantics-and-accessibility)
8. [Links and Resources](#links-and-resources)
9. [Images and Media](#images-and-media)
10. [CSS and JavaScript](#css-and-javascript)
11. [Comments](#comments)
12. [Recommended Tools](#recommended-tools)

## General Principles

- **Standards Mode**: Always use the HTML5 doctype to enable standards mode.
- **Valid HTML**: Ensure that all HTML code validates against the [W3C HTML validator](https://validator.w3.org/).
- **Separation of Concerns**: Keep structure (HTML), presentation (CSS), and behavior (JavaScript) separate.
- **Semantics**: Use HTML elements for their given purpose (e.g., `<button>` for buttons, `<a>` for links, `<header>` for headers) rather than strictly for presentation.
- **Accessibility**: Develop with accessibility in mind (WCAG 2.1 compliance), ensuring content is accessible to users with disabilities.

## File Naming and Location

- **Extension**: Use `.html` for all HTML files. Avoid `.htm`.
- **Naming**: Use `kebab-case` for filenames (e.g., `user-profile.html`).
- **Index Files**: Use `index.html` as the default entry point for directories.
- **Lowercase**: Always use lowercase filenames to ensure compatibility across case-sensitive filesystems.

## Formatting and Layout

- **Indentation**: Use 2 spaces for indentation. Do not use tabs.
- **Line Length**: Soft limit lines to 120 characters to ensure readability, though longer lines are acceptable for long URLs or attributes.
- **Nested Elements**: Indent nested elements.
- **Trailing Whitespace**: Remove trailing whitespace from all lines.
- **Newline at End of File**: Ensure every file ends with a single newline character.

```html
<!-- Good -->
<body>
  <header>
    <nav>
      <ul>
        <li><a href="/">Home</a></li>
      </ul>
    </nav>
  </header>
</body>
```

## Document Structure

- **Doctype**: always use `<!DOCTYPE html>` on the first line.
- **HTML Element**: specify the language of the page content on the `<html>` tag.
- **Character Encoding**: Always declare the character encoding as the first child of `<head>`. Use UTF-8.
- **Viewport**: Include the viewport meta tag for responsive behavior.
- **Title**: Always include a unique `<title>` for every page.

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Page Title</title>
  <meta name="description" content="Description of the page content.">
</head>
<body>
  <!-- Content -->
</body>
</html>
```

## Elements and Tags

- **Lowercase**: All tag names must be lowercase.
- **Closing Tags**: Always close all tags that have a closing tag.
- **Self-Closing Tags**: In HTML5, the trailing slash on void elements (e.g., `<br>`, `<img>`, `<input>`) is optional but adhering to a consistent style is required. This project prefers **no trailing slash** for strict HTML5 compliance, unless using XHTML syntax.
    - *Note*: If using a framework like React/JSX, self-closing tags *must* have the slash.
- **Optional Tags**: Do not omit optional tags (like `</li>` or `</body>`). Explicitly closing tags avoids ambiguity and potential rendering issues.

```html
<!-- Good -->
<img src="image.jpg" alt="A description">
<br>
<input type="text" name="username">

<!-- Bad -->
<IMG SRC="image.jpg">
<br />
```

## Attributes

- **Lowercase**: All attribute names must be lowercase.
- **Quotes**: Always use double quotes `"` around attribute values.
- **Boolean Attributes**: Do not assign values to boolean attributes. The presence of the attribute represents `true`.
- **Ordering**: Order attributes consistently for readability:
    1. `class`
    2. `id`, `name`
    3. `data-*`
    4. `src`, `for`, `type`, `href`, `value`
    5. `title`, `alt`
    6. `role`, `aria-*`
    7. Event handlers (`onClick`, etc. - though avoid inline handlers)

```html
<!-- Good -->
<input type="checkbox" checked>
<div class="container" id="main" data-ref="123"></div>

<!-- Bad -->
<input type='checkbox' checked=true>
<div id=main class=container></div>
```

## Semantics and Accessibility

- **Landmarks**: Use semantic landmark elements (`<main>`, `<nav>`, `<aside>`, `<header>`, `<footer>`, `<section>`, `<article>`) to define the page structure.
- **Headings**: Use headings (`<h1>`–`<h6>`) to create a logical document outline. Do not skip levels (e.g., `<h1>` directly to `<h3>`).
- **Buttons vs. Links**: Use `<button>` for actions and `<a>` for navigation.
    - If a link acts like a button, use `role="button"`.
- **ARIA**: Use WAI-ARIA attributes only when native HTML elements cannot provide the necessary semantics. Adhere to the rule: "No ARIA is better than bad ARIA."
- **Focus**: Never remove focus outlines (`outline: none`) without providing an alternative focus indicator.

```html
<main>
  <article>
    <h1>Article Title</h1>
    <p>Content goes here...</p>
  </article>
</main>
```

## Links and Resources

- **Protocols**: Omit the protocol (`http:`, `https:`) for external resources only if linking to assets (images, scripts) that are available over both, to use the current protocol. However, explicit `https://` is generally preferred for security.
- **Target Blank**: When using `target="_blank"`, always add `rel="noopener noreferrer"` to prevent security vulnerabilities and performance issues.
- **Email Links**: Obfuscate email addresses in public-facing HTML if possible to prevent scraping.

```html
<a href="https://example.com" target="_blank" rel="noopener noreferrer">External Link</a>
```

## Images and Media

- **Alt Text**: All `<img>` tags must have an `alt` attribute.
    - Decorative images should have an empty alt attribute: `alt=""`.
    - Informative images should have descriptive text.
- **Dimensions**: Specify `width` and `height` attributes to prevent layout shifts (CLS) while images load.
- **Lazy Loading**: Use `loading="lazy"` for images below the fold.

```html
<img src="logo.png" alt="Company Name" width="200" height="50">
<img src="decoration.png" alt="" aria-hidden="true">
```

## CSS and JavaScript

- **External Files**: Link CSS and JavaScript in external files. Avoid inline styles (`style="..."`) and embedded scripts (`<script>...</script>`).
- **Placement**:
    - Put `<link>` tags for CSS in the `<head>`.
    - Put `<script>` tags at the end of `<body>` or use `defer` / `async` attributes in the `<head>` to prevent blocking rendering.
- **Type Attribute**: Do not use `type="text/css"` or `type="text/javascript"` as they are default in HTML5.

```html
<!-- Good -->
<head>
  <link rel="stylesheet" href="styles.css">
  <script src="main.js" defer></script>
</head>
```

## Comments

- **Usage**: Use comments to explain complex structural blocks or directives.
- **Format**: `<!-- Comment Text -->`
- **Spacing**: Include a space after the opening `<!--` and before the closing `-->`.
- **Section Dividers**: Use comments to denote start and end of major sections.

```html
<!-- Main Navigation -->
<nav>
  ...
</nav>
<!-- /Main Navigation -->
```

## Recommended Tools

- **Linter**: `HTMLHint` or `djlint` to enforce coding standards.
- **Formatter**: `Prettier` for consistent formatting.
- **Validator**: `Nu Html Checker` (vnu) for validating HTML compliance.
- **Accessibility**: `axe-core` or Lighthouse (in Chrome DevTools) for accessibility auditing.
