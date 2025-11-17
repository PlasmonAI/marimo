# Markdown Fonts in Marimo Frontend Cells

## Summary

For markdown headings in frontend cells (like "## References and definitions"), marimo uses:

**Font**: `var(--heading-font)` which resolves to **"Didot", "Palatino", "Georgia", serif**

(After our recent update from "Lora" serif font)

---

## Detailed Font Configuration

### 1. Markdown Headings (h1-h6)

**File**: [frontend/src/css/md.css:34-42](frontend/src/css/md.css:34-42)

```css
.markdown h1,
.markdown h2,
.markdown h3,
.markdown h4,
.markdown h5,
.markdown h6 {
  font-weight: inherit;
  font-family: var(--heading-font);
}
```

**Resolves to**:
- CSS Variable: `--heading-font`
- Defined in: [frontend/src/css/globals.css:47](frontend/src/css/globals.css:47)
- Value: `var(--marimo-heading-font, "Didot", "Palatino", "Georgia", serif)`

### 2. Markdown Body Text

**File**: [frontend/tailwind.config.cjs:142](frontend/tailwind.config.cjs:142)

```javascript
typography: {
  DEFAULT: {
    css: {
      fontFamily: "var(--text-font)",
      // ...
    }
  }
}
```

**Resolves to**:
- CSS Variable: `--text-font`
- Defined in: [frontend/src/css/globals.css:45](frontend/src/css/globals.css:45)
- Value: `var(--marimo-text-font, "Univers Next W01 Regular", "Helvetica Neue", "Arial", sans-serif)`

### 3. Code in Markdown

**File**: [frontend/src/css/globals.css:43](frontend/src/css/globals.css:43)

```css
--monospace-font: var(
  --marimo-monospace-font,
  "Univers Next Pro",
  "Helvetica Neue",
  "Arial",
  sans-serif
);
```

---

## Font Stack Breakdown

### Heading Font (`--heading-font`)

| Priority | Font Name | Type | Notes |
|----------|-----------|------|-------|
| 1 | **User Override** | Custom | Via `--marimo-heading-font` CSS variable |
| 2 | **Didot** | Serif | Elegant, classic serif (from DESIGN_TOKENS.md) |
| 3 | **Palatino** | Serif | System fallback (macOS/iOS) |
| 4 | **Georgia** | Serif | System fallback (Windows/Linux) |
| 5 | **serif** | Generic | Browser default serif |

**Visual Characteristics**:
- Didot: High contrast, elegant, refined
- Palatino: Classic, readable, slightly wider
- Georgia: Web-optimized, screen-friendly serif

### Body Text Font (`--text-font`)

| Priority | Font Name | Type | Notes |
|----------|-----------|------|-------|
| 1 | **User Override** | Custom | Via `--marimo-text-font` CSS variable |
| 2 | **Univers Next W01 Regular** | Sans-serif | Professional, clean (from DESIGN_TOKENS.md) |
| 3 | **Helvetica Neue** | Sans-serif | System fallback (macOS/iOS) |
| 4 | **Arial** | Sans-serif | System fallback (Windows/Linux) |
| 5 | **sans-serif** | Generic | Browser default sans-serif |

### Code Font (`--monospace-font`)

| Priority | Font Name | Type | Notes |
|----------|-----------|------|-------|
| 1 | **User Override** | Custom | Via `--marimo-monospace-font` CSS variable |
| 2 | **Univers Next Pro** | Monospace replacement | Unified with rest of UI |
| 3 | **monospace** | Generic | Browser default monospace |

---

## Example: "## References and definitions"

When you write this markdown in a cell:

```markdown
## References and definitions
```

The browser will attempt to load fonts in this order:

1. **Check for user override**: `--marimo-heading-font` (if user provided custom CSS)
2. **Try Didot**: If available on system or loaded via web font
3. **Fall back to Palatino**: On macOS/iOS systems
4. **Fall back to Georgia**: On Windows/Linux systems
5. **Use browser default serif**: If none above are available

---

## How to Verify Current Font

### Method 1: Browser DevTools

1. Open marimo in browser
2. Right-click on a markdown heading (e.g., "## References")
3. Select "Inspect Element"
4. In the Computed tab, look for `font-family`
5. You'll see which font is actually being used

### Method 2: JavaScript Console

```javascript
// Get computed style of a markdown h2 element
const h2 = document.querySelector('.markdown h2');
const style = window.getComputedStyle(h2);
console.log('Font family:', style.fontFamily);
console.log('Font size:', style.fontSize);
console.log('Font weight:', style.fontWeight);
```

---

## How Users Can Customize Markdown Fonts

### Option 1: Via Custom CSS File

```python
# In notebook
import marimo as mo
app = mo.App(css_file="custom.css")
```

```css
/* custom.css */
:root {
  /* Override heading font */
  --marimo-heading-font: "Playfair Display", serif;

  /* Override body text font */
  --marimo-text-font: "Roboto", sans-serif;

  /* Override code font */
  --marimo-monospace-font: "JetBrains Mono", monospace;
}
```

### Option 2: Via pyproject.toml

```toml
[tool.marimo.display]
custom_css = ["custom-fonts.css"]
```

### Option 3: Via User Config

```toml
# ~/.config/marimo/marimo.toml
[display]
custom_css = ["~/.config/marimo/custom-fonts.css"]
```

### Option 4: Inline in Markdown Cell

While not recommended, you can use inline styles:

```markdown
<h2 style="font-family: 'Comic Sans MS', cursive;">My Heading</h2>
```

---

## Typography Configuration Files

### Main Configuration Files

1. **[frontend/src/css/globals.css](frontend/src/css/globals.css:43-47)**
   - Defines all font variables
   - Sets defaults and fallbacks

2. **[frontend/src/css/md.css](frontend/src/css/md.css:34-42)**
   - Applies `--heading-font` to markdown headings
   - Controls markdown-specific styling

3. **[frontend/tailwind.config.cjs](frontend/tailwind.config.cjs:90-95)**
   - Maps font variables to Tailwind utilities
   - Configures typography plugin

4. **[frontend/src/css/app/fonts.css](frontend/src/css/app/fonts.css)**
   - Declares `@font-face` for bundled fonts
   - Loads Univers Next Pro, PT Sans (old), Lora (old)

---

## Font Sizes for Markdown Headings

Marimo uses Tailwind Typography plugin which sets these default sizes:

| Heading | Approximate Size | Line Height |
|---------|-----------------|-------------|
| `h1` | 2.25rem (36px) | 2.5rem |
| `h2` | 1.875rem (30px) | 2.25rem |
| `h3` | 1.5rem (24px) | 2rem |
| `h4` | 1.25rem (20px) | 1.75rem |
| `h5` | 1.125rem (18px) | 1.75rem |
| `h6` | 1rem (16px) | 1.5rem |

**Note**: In chat/markdown renderer, h1 and h2 are scaled down:
- `--text-2xl: 1rem` (16px)
- `--text-3xl: 1.2rem` (19.2px)

([frontend/src/components/chat/markdown-renderer.css:5-6](frontend/src/components/chat/markdown-renderer.css:5-6))

---

## Font Weight

Markdown headings use:

```css
font-weight: inherit;
```

This means they inherit the weight from their parent element. Typically this will be:
- **400** (Regular) for body text
- **500-700** for explicitly bolded headings

You can override this globally:

```css
.markdown h1, .markdown h2, .markdown h3 {
  font-weight: 700; /* Bold */
}
```

---

## Complete Font Hierarchy

```
Markdown Cell
│
├── Headings (h1-h6)
│   └── Font: Didot → Palatino → Georgia → serif
│   └── Weight: inherit (usually 400-700)
│   └── Defined in: frontend/src/css/md.css
│
├── Body Text (p, span.paragraph)
│   └── Font: Univers Next W01 Regular → Helvetica Neue → Arial → sans-serif
│   └── Weight: 400 (regular)
│   └── Defined in: tailwind.config.cjs typography
│
├── Code (inline `code`)
│   └── Font: Univers Next Pro → Helvetica Neue → Arial → sans-serif
│   └── Weight: 500
│   └── Defined in: globals.css
│
└── Code Blocks (```code```)
    └── Font: Univers Next Pro → Helvetica Neue → Arial → sans-serif
    └── Weight: 400
    └── Defined in: globals.css + CodeMirror theme

```

---

## Special Markdown Contexts

### 1. Slides Mode

Uses different sizing ([tailwind.config.cjs:165-188](tailwind.config.cjs:165-188)):

```javascript
slides: {
  css: {
    h1: { fontSize: `${70 / 16}rem`, lineHeight: 1.2 },  // 70px
    h2: { fontSize: `${48 / 16}rem`, lineHeight: 1.3 },  // 48px
    h3: { fontSize: `${37 / 16}rem`, lineHeight: 1.4 },  // 37px
  }
}
```

Font family remains: **Didot → Palatino → Georgia → serif**

### 2. Chat/AI Responses

Smaller headings ([markdown-renderer.css:5-6](frontend/src/components/chat/markdown-renderer.css:5-6)):

```css
--text-2xl: 1rem;    /* h2 size reduced */
--text-3xl: 1.2rem;  /* h1 size reduced */
```

Font family remains: **Didot → Palatino → Georgia → serif**

### 3. Documentation Panel

Standard markdown styling with same font family.

---

## Summary Table

| Element | Font Family | Actual Font (after update) | Source File |
|---------|-------------|---------------------------|-------------|
| **Markdown Headings** | `var(--heading-font)` | Didot / Palatino / Georgia | [md.css:41](frontend/src/css/md.css:41) |
| **Markdown Body** | `var(--text-font)` | Univers Next W01 / Helvetica Neue / Arial | [tailwind.config.cjs:142](frontend/tailwind.config.cjs:142) |
| **Markdown Code** | `var(--monospace-font)` | Univers Next Pro | [globals.css:43](frontend/src/css/globals.css:43) |
| **Links** | `var(--text-font)` | Univers Next W01 / Helvetica Neue / Arial | [md.css:44-48](frontend/src/css/md.css:44-48) |

---

## To Use the Actual Didot Font

Since Didot is a commercial font, you have a few options:

### 1. Use System Didot (macOS/iOS)
Didot is pre-installed on Apple systems, so it will work automatically.

### 2. Use Google Fonts Alternative
```css
@import url('https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&display=swap');

:root {
  --marimo-heading-font: "Playfair Display", serif;
}
```

Playfair Display is similar to Didot (high contrast, elegant serif).

### 3. Purchase and Install Didot
If you have a Didot license, add the font files to `frontend/src/fonts/Didot/` and declare them:

```css
/* frontend/src/css/app/fonts.css */
@font-face {
  font-family: "Didot";
  src: url("../../fonts/Didot/Didot-Regular.woff2") format("woff2");
  font-weight: 400;
  font-display: block;
}
```

---

**Last Updated**: 2025-11-17
**Related Files**:
- [frontend/src/css/md.css](frontend/src/css/md.css)
- [frontend/src/css/globals.css](frontend/src/css/globals.css)
- [frontend/tailwind.config.cjs](frontend/tailwind.config.cjs)
