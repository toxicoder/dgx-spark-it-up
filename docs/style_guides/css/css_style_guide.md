# CSS Style Guide

This document outlines the coding standards and best practices for CSS development. Adhering to these guidelines ensures code consistency, maintainability, scalability, and performance across the codebase.

## Table of Contents

1. [General Principles](#general-principles)
2. [Naming Conventions](#naming-conventions)
3. [Formatting and Syntax](#formatting-and-syntax)
4. [Selectors and Specificity](#selectors-and-specificity)
5. [Architecture](#architecture)
6. [Responsive Design](#responsive-design)
7. [CSS Variables (Custom Properties)](#css-variables-custom-properties)
8. [Values and Units](#values-and-units)
9. [Accessibility](#accessibility)
10. [Performance](#performance)
11. [Comments](#comments)
12. [Recommended Tools](#recommended-tools)

## General Principles

- **Maintainability**: Write code that is easy to read and understand. Favor clarity over clever hacks.
- **Scalability**: Use methodologies like BEM (Block Element Modifier) to ensure styles don't leak or conflict as the project grows.
- **Performance**: Minimize file size and browser reflows/repaints. Avoid expensive selectors and excessive nesting.
- **Consistency**: Follow the established patterns and formatting rules defined in this guide.
- **Browser Support**: Target modern browsers while implementing graceful degradation or progressive enhancement for older ones where necessary.

## Naming Conventions

We strictly follow the **BEM (Block Element Modifier)** naming convention. This helps in creating self-documenting CSS and reduces specificity issues.

### BEM Syntax

- **Block**: The main component (e.g., `.card`, `.btn`).
- **Element**: A child of the block, separated by two underscores (e.g., `.card__title`, `.btn__icon`).
- **Modifier**: A variation of the block or element, separated by two hyphens (e.g., `.card--featured`, `.btn--large`).

```css
/* Good */
.card { }
.card__image { }
.card__title { }
.card--highlighted { }
.card__title--small { }

/* Bad */
.card-image { } /* Ambiguous */
.cardTitle { } /* CamelCase */
.Card { } /* PascalCase */
```

### Class Names

- **Kebab-case**: Always use lowercase letters and hyphens (e.g., `.main-nav`, `.user-profile`).
- **Semantic**: Names should describe *what* the element is, not *where* it looks or *how* it looks (e.g., `.alert-error` instead of `.red-text`).
- **No IDs**: Never use IDs for styling. IDs significantly increase specificity and make reuse impossible.

### State Hooks

Use `is-` or `has-` prefixes for state classes, which are typically toggled by JavaScript.

```css
/* Good */
.nav-item.is-active { }
.modal.is-open { }
.form-group.has-error { }
```

## Formatting and Syntax

- **Indentation**: Use 2 spaces for indentation.
- **Braces**: Put the opening brace on the same line as the selector, preceded by one space. Put the closing brace on a new line.
- **Spacing**: Include one space after the colon for each property.
- **Semicolons**: Always include a semicolon at the end of every property declaration.
- **Empty Lines**: Separate rulesets with a single empty line.
- **Quotes**: Use double quotes for attribute selectors and URL paths.

```css
/* Good */
.selector {
  display: block;
  margin: 0;
  padding: 10px;
  content: "example";
}

/* Bad */
.selector{
    display:block; margin:0
}
```

### Property Ordering

Group properties logically to improve readability. A recommended order is:

1.  **Positioning**: `position`, `top`, `left`, `z-index`.
2.  **Box Model**: `display`, `flex`, `grid`, `width`, `height`, `margin`, `padding`.
3.  **Typography**: `font`, `line-height`, `color`, `text-align`.
4.  **Visual**: `background`, `border`, `border-radius`, `box-shadow`, `opacity`.
5.  **Misc**: `cursor`, `overflow`, `transition`, `animation`.

## Selectors and Specificity

- **Low Specificity**: Keep specificity as low as possible. Stick to class selectors.
- **Avoid Nesting**: Avoid deep nesting. It increases specificity and makes code harder to override. A maximum of 3 levels is recommended, but 1 level (BEM) is ideal.
- **No Tag Selectors**: Avoid styling tags directly (e.g., `div`, `span`) inside components. Use classes instead.
- **Universal Selector**: Avoid using `*` for performance reasons, except for the global box-sizing reset.

```css
/* Good - Specificity: 0-1-0 */
.nav__item { }

/* Bad - Specificity: 0-0-2 (or higher) and coupled to HTML structure */
.nav ul li { }
```

## Architecture

We encourage a component-based architecture (like ITCSS or 7-1 pattern) to organize CSS files.

### Directory Structure Example

```
styles/
|
|– abstracts/      # Variables, mixins, functions
|– base/           # Reset, typography, global styles
|– components/     # Buttons, cards, navbar (BEM blocks)
|– layout/         # Grid, header, footer
|– pages/          # Page-specific styles (avoid if possible)
|– themes/         # Theme-specific variables
|– utilities/      # Helper classes (hidden, text-center)
|– main.css        # Main import file
```

## Responsive Design

- **Mobile-First**: Define styles for mobile devices first, then use `min-width` media queries to override for larger screens.
- **Breakpoints**: Use standard breakpoints or CSS variables for consistency.
- **Fluid Layouts**: Use percentages, `vw`/`vh`, or flexbox/grid for layouts that adapt to any screen size.

```css
/* Mobile styles first */
.container {
  padding: 1rem;
}

/* Tablet and up */
@media (min-width: 768px) {
  .container {
    padding: 2rem;
  }
}
```

## CSS Variables (Custom Properties)

- **Usage**: Use CSS Custom Properties (`--variable-name`) for theme colors, spacing, font sizes, and z-indices.
- **Scope**: Define global variables in the `:root` selector.
- **Naming**: Use kebab-case for variable names (e.g., `--primary-color`, `--spacing-md`).

```css
:root {
  --color-primary: #007bff;
  --font-size-base: 16px;
  --spacing-unit: 8px;
}

.btn {
  background-color: var(--color-primary);
  padding: var(--spacing-unit);
}
```

## Values and Units

- **Rem/Em**: Use `rem` for font sizes and spacing to ensure accessibility and responsiveness. Use `em` only when sizing needs to be relative to the parent's font size (e.g., inside buttons).
- **Pixels**: Avoid `px` for font sizes. `px` is acceptable for borders or very specific layout constraints that shouldn't scale.
- **Colors**: Prefer Hex codes or `rgb()`/`rgba()`. `hsl()` is encouraged for programmatic color manipulation.
- **Zero Values**: Do not specify units for zero values (e.g., `margin: 0;` not `margin: 0px;`).
- **Shorthand**: Use shorthand properties where possible (e.g., `margin`, `padding`, `border`, `background`), but be careful not to unintentionally override other values.

## Accessibility

- **Focus States**: Never remove outline (`outline: none`) on focusable elements without providing an alternative style.
- **Contrast**: Ensure sufficient color contrast between text and background (WCAG AA standard).
- **Hidden Content**: Use a `.visually-hidden` utility class to hide content from screens but keep it available for screen readers, instead of `display: none`.
- **Reduced Motion**: Respect user's motion preferences using the `prefers-reduced-motion` media query.

```css
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
    scroll-behavior: auto !important;
  }
}
```

## Performance

- **Minification**: Always minify CSS for production.
- **Unused CSS**: Periodically audit and remove unused CSS.
- **Critical CSS**: Consider inlining critical CSS for above-the-fold content to improve First Contentful Paint (FCP).
- **Efficient Animations**: Animate only `transform` and `opacity` properties to trigger hardware acceleration and avoid repaints.

## Comments

- **Section Comments**: Use comments to divide large files into logical sections.
- **Explanation**: Comment complex calculations or hacks (e.g., why a specific `z-index` or `negative margin` is used).
- **Format**: use `/* ... */` for standard CSS comments.

```css
/* ==========================================================================
   #HEADER
   ========================================================================== */

.header {
  /* Fix for IE11 z-index bug */
  z-index: 10;
}
```

## Recommended Tools

- **Linting**: Use **Stylelint** with a standard configuration (e.g., `stylelint-config-standard` or `stylelint-config-recommended-scss`).
- **Formatting**: Use **Prettier** to enforce consistent formatting automatically.
- **Post-Processing**: Use **PostCSS** with **Autoprefixer** to automatically add vendor prefixes.
