# Marimo Design System - Essential Styling Reference

This document extracts the key design tokens from `theme.css` for easy reference when customizing marimo notebooks.

## Color Palette

### Primary Colors

| Color Name | Hex Value | Usage |
|------------|-----------|-------|
| **Primary Dark Teal** | `#00494B` | Primary brand color (dark) |
| **Primary Teal** | `#0A5F61` | Primary interactive elements |
| **Dark Background** | `#082321` | Dark theme background |
| **Accent Rose** | `#B07594` | Accent color |
| **Accent Gold** | `#EBB356` | Secondary accent/highlights |
| **Error Red** | `#CB323B` | Error states, destructive actions |
| **Dark Red** | `#B42818` | Darker error variant |
| **Muted Mauve** | `#8A4F6E` | Subdued accent |

### Neutral/Gray Scale

| Color Name | Hex Value | Palette Reference |
|------------|-----------|-------------------|
| **White** | `#FFFFFF` | Palette / White |
| **Gray 100** | `#F5F5F5` | Palette / Gray / 100 - Lightest gray |
| **Gray 200** | `#E8E8E8` | Palette / Gray / 200 - Light gray, borders |
| **Gray 600** | `#666666` | Palette / Gray / 600 - Medium gray, secondary text |
| **Gray 700** | `#515151` | Palette / Gray / 700 - Dark gray |
| **Gray 800** | `#333333` | Palette / Gray / 800 - Very dark gray |
| **Black** | `#000000` | Pure black |

### Pastel/Subtle Backgrounds

| Color Name | Hex Value | Usage |
|------------|-----------|-------|
| **Soft Teal** | `#B3C8C9` | Subtle background tint |
| **Soft Mint** | `#F2F6F6` | Very light background |
| **Soft Beige** | `#F4EEEB` | Warm background variant |
| **Off White** | `#F4F4F4` | Slightly tinted white |

### Transparency Variations

| Color | RGBA Value | Opacity |
|-------|------------|---------|
| **Black 87%** | `rgba(0, 0, 0, 0.87)` | Primary text (high emphasis) |
| **Black 60%** | `rgba(0, 0, 0, 0.6)` | Secondary text (medium emphasis) |
| **Black 43%** | `rgba(0, 0, 0, 0.43)` | Disabled/hint text (low emphasis) |
| **Teal 30%** | `rgba(0, 73, 75, 0.3)` | Subtle teal overlay |

## Typography

### Font Families

| Font Name | Purpose | Weights Available |
|-----------|---------|-------------------|
| **Univers Next W01 Regular** | Body text, UI elements | 400 (Regular) |
| **Univers Next W01 Medium** | Medium emphasis text | 500 (Medium) |
| **Univers Next W01 Bold** | Headings, emphasis | 700 (Bold) |
| **Didot** | Display text, elegant headings | 400 (Regular) |
| **Font Awesome 5 Pro** | Icons | N/A |

### Font Sizes & Line Heights

Based on patterns found in the CSS:

| Size (px) | Line Height (px) | Usage |
|-----------|------------------|-------|
| 11px | 16px | Small text, tooltips (145% line height) |
| 12px | 16px | Helper text, captions (133% line height) |
| 14px | 18px | Standard body text (129% line height) |
| 16px+ | Varies | Larger text, headings |

## Component Patterns

### Common CSS Patterns Found

#### Tooltip Style
```css
background: #333333;
color: #FFFFFF;
font-family: 'Univers Next W01 Regular';
font-size: 11px;
line-height: 16px;
```

#### Helper Text Style
```css
font-family: 'Univers Next W01 Regular';
font-size: 12px;
line-height: 16px;
color: rgba(0, 0, 0, 0.6); /* Secondary text */
```

#### Primary Interactive Element
```css
background: #0A5F61; /* Primary teal */
color: #FFFFFF;
font-family: 'Univers Next W01 Regular';
```

#### Disabled/Hint Text
```css
color: rgba(0, 0, 0, 0.43);
font-family: 'Univers Next W01 Regular';
```

## Recommended Color Usage

### For Light Theme

| Element Type | Recommended Color | Hex |
|--------------|-------------------|-----|
| **Background** | White | `#FFFFFF` |
| **Primary Text** | Black 87% | `rgba(0, 0, 0, 0.87)` |
| **Secondary Text** | Gray 600 | `#666666` |
| **Borders** | Gray 200 | `#E8E8E8` |
| **Primary Button** | Primary Teal | `#0A5F61` |
| **Accent** | Accent Gold | `#EBB356` |
| **Error** | Error Red | `#CB323B` |
| **Subtle Background** | Gray 100 | `#F5F5F5` |

### For Dark Theme

| Element Type | Recommended Color | Hex |
|--------------|-------------------|-----|
| **Background** | Dark Background | `#082321` |
| **Primary Text** | Off White | `#F4F4F4` |
| **Secondary Text** | Gray 200 | `#E8E8E8` |
| **Borders** | Gray 700 | `#515151` |
| **Primary Button** | Primary Teal | `#0A5F61` |
| **Card Background** | Primary Dark Teal | `#00494B` |

## How to Use These Tokens in Custom CSS

### Example 1: Custom marimo theme with these colors

```css
/* custom-theme.css */
@import url('https://fonts.googleapis.com/css?family=Univers+Next+W01');

:root {
  /* Override marimo fonts */
  --marimo-text-font: "Univers Next W01 Regular", sans-serif;
  --marimo-heading-font: "Didot", serif;
  --marimo-monospace-font: "Fira Mono", monospace;
}

/* Light theme colors */
:root {
  /* Using theme.css palette */
  --primary: #0A5F61;        /* Primary Teal */
  --accent: #EBB356;         /* Accent Gold */
  --error: #CB323B;          /* Error Red */
  --background: #FFFFFF;     /* White */
  --foreground: rgba(0, 0, 0, 0.87); /* Primary text */
  --muted: #F5F5F5;          /* Gray 100 */
  --border: #E8E8E8;         /* Gray 200 */
}

/* Dark theme colors */
.dark {
  --primary: #0A5F61;        /* Primary Teal */
  --accent: #B07594;         /* Accent Rose */
  --background: #082321;     /* Dark Background */
  --foreground: #F4F4F4;     /* Off White */
  --card: #00494B;           /* Primary Dark Teal */
  --border: #515151;         /* Gray 700 */
}

/* Apply to headings */
h1, h2, h3 {
  color: light-dark(#0A5F61, #B3C8C9);
  font-family: var(--marimo-heading-font);
}

/* Style buttons */
button.primary {
  background: #0A5F61;
  color: #FFFFFF;
}

button.accent {
  background: #EBB356;
  color: rgba(0, 0, 0, 0.87);
}

/* Error states */
.error-text {
  color: #CB323B;
}
```

### Example 2: Using the gray scale

```css
/* Borders and dividers */
.divider {
  border-top: 1px solid #E8E8E8; /* Gray 200 */
}

/* Text hierarchy */
.text-primary {
  color: rgba(0, 0, 0, 0.87);
}

.text-secondary {
  color: #666666; /* Gray 600 */
}

.text-disabled {
  color: rgba(0, 0, 0, 0.43);
}
```

### Example 3: Card components

```css
.card {
  background: light-dark(#FFFFFF, #00494B);
  border: 1px solid light-dark(#E8E8E8, #515151);
  border-radius: 8px;
}

.card-subtitle {
  color: light-dark(#666666, #B3C8C9);
  font-size: 12px;
}
```

## Integration with Marimo

To use this design system in your marimo notebook:

1. **Create a CSS file** (e.g., `custom-theme.css`) with your color overrides
2. **Reference it in your notebook**:

```python
import marimo as mo

app = mo.App(css_file="custom-theme.css")
```

Or in `pyproject.toml`:

```toml
[tool.marimo.display]
custom_css = ["custom-theme.css"]
```

## Design Principles (Inferred from theme.css)

1. **Typography Scale**: Uses a clear hierarchy with 11px, 12px, 14px base sizes
2. **Line Height Ratio**: Approximately 130-145% for readability
3. **Opacity Levels**: Three levels of text emphasis (87%, 60%, 43%)
4. **Color Temperature**: Combines cool teals with warm gold/rose accents
5. **Professional Aesthetic**: Univers Next (clean, modern) + Didot (elegant, refined)
6. **Subtle Backgrounds**: Uses very light tints rather than pure white/gray
7. **Consistent Spacing**: Border radius and padding follow consistent patterns

## Notes

- This theme appears to be from a **financial/professional** design system (based on references to "Direct Investments", "Real Estate")
- The color palette is **sophisticated and restrained** - good for data-heavy applications
- **Accessibility**: Text contrast ratios are strong (87% black on white, etc.)
- The design uses **Material Design opacity standards** for text emphasis
- Font Awesome is included for icon support

---

**Generated from**: `/Users/tedlee/workspace/marimo/theme.css` (9693 lines)

**Last Updated**: 2025-11-17
