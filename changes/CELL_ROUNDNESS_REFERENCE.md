# Marimo Cell Roundness (Border Radius) Reference

## Summary

Marimo cells use **rounded corners** with different border-radius values depending on the element and context. The main cell container has a **10px border radius**.

---

## Border Radius Values

### Main Cell Container

**File**: [frontend/src/css/app/Cell.css:12](frontend/src/css/app/Cell.css:12)

```css
.marimo-cell {
  border-radius: 10px;
  /* ... */
}
```

**Value**: `10px`
**Applied to**: The entire cell wrapper (outer container)

---

### Child Elements (First/Last)

When a cell is in **interactive mode**, the first and last child elements get slightly smaller rounded corners to fit within the parent:

**File**: [frontend/src/css/app/Cell.css:100-107](frontend/src/css/app/Cell.css:100-107)

```css
.marimo-cell.interactive {
  /* First child (usually the code editor) */
  & > :first-child {
    border-top-left-radius: 9px;
    border-top-right-radius: 9px;
  }

  /* Last child (usually the output area) */
  & > :last-child {
    border-bottom-left-radius: 9px;
    border-bottom-right-radius: 9px;
  }
}
```

**Value**: `9px`
**Why smaller?**: Creates a 1px gap between parent and child borders for clean visual nesting

---

### CodeMirror Editor

**File**: [frontend/src/css/app/Cell.css:133](frontend/src/css/app/Cell.css:133)

```css
.marimo-cell.interactive .cm {
  border-radius: 8px;
}
```

**Value**: `8px`
**Applied to**: The code editor component (CodeMirror)

---

### Active Line Highlight

**File**: [frontend/src/css/app/Cell.css:439](frontend/src/css/app/Cell.css:439)

```css
.marimo-cell .cm-editor .cm-activeLine:not(.cm-error-line) {
  border-radius: 2px;
}
```

**Value**: `2px`
**Applied to**: The currently active line in the code editor
**Why small?**: Subtle highlight, doesn't compete with cell boundaries

---

### AI-Generated/Deleted Cell Overlays

**File**: [frontend/src/css/app/Cell.css:30](frontend/src/css/app/Cell.css:30) and [Cell.css:53](frontend/src/css/app/Cell.css:53)

```css
.marimo-cell:has(.mo-ai-generated-cell)::before {
  border-radius: 10px;
  /* Cyan glow overlay */
}

.marimo-cell:has(.mo-ai-deleted-cell)::before {
  border-radius: 10px;
  /* Red glow overlay */
}
```

**Value**: `10px`
**Why same as parent?**: Overlays match the cell container exactly

---

### Tray (Code Editor Container)

**File**: [frontend/src/css/app/Cell.css:363-370](frontend/src/css/app/Cell.css:363-370)

```css
.tray {
  &:first-child .cm-editor {
    border-top-left-radius: 9px;
    border-top-right-radius: 9px;
  }

  &:last-child .cm-editor {
    border-bottom-left-radius: 9px;
    border-bottom-right-radius: 9px;
  }
}
```

**Value**: `9px`
**Applied to**: CodeMirror editor when it's the first/last child in the tray

---

## Complete Border Radius Hierarchy

```
Cell Container (outer)
├── border-radius: 10px
│
├── AI Overlay (::before pseudo-element)
│   └── border-radius: 10px (matches parent)
│
├── First Child
│   └── border-top-*-radius: 9px (1px smaller)
│
├── CodeMirror Editor (.cm)
│   ├── border-radius: 8px (2px smaller)
│   └── Active Line
│       └── border-radius: 2px (subtle)
│
└── Last Child
    └── border-bottom-*-radius: 9px (1px smaller)
```

---

## Global Radius Variable

**File**: [frontend/src/css/globals.css:48](frontend/src/css/globals.css:48)

```css
:root,
.marimo {
  --radius: 8px;
  /* ... */
}
```

**Default**: `8px`
**Usage**: Used throughout the app for buttons, inputs, cards, etc.
**Note**: The cell itself uses `10px` (hardcoded), not the `--radius` variable

---

## Visual Comparison

| Element | Border Radius | Visual Effect |
|---------|---------------|---------------|
| **Cell Container** | `10px` | Most rounded (outer boundary) |
| **First/Last Child** | `9px` | Slightly less rounded (nested) |
| **CodeMirror Editor** | `8px` | Moderately rounded (matches `--radius`) |
| **Active Line** | `2px` | Barely rounded (subtle) |

---

## Why Different Values?

### 1. Visual Nesting
```
┌────────────────────────┐  10px (outer cell)
│ ┌────────────────────┐ │  9px (first child)
│ │ Code Editor        │ │
│ │                    │ │
│ └────────────────────┘ │
│ ┌────────────────────┐ │  9px (last child)
│ │ Output Area        │ │
│ └────────────────────┘ │
└────────────────────────┘
```

The 1px difference creates a clean visual hierarchy.

### 2. Consistency with Global --radius
The CodeMirror editor uses `8px`, which matches the global `--radius` variable used for other UI elements (buttons, cards, inputs).

### 3. Subtle Highlights
The active line uses `2px` to provide a gentle rounded effect without being distracting.

---

## How Border Radius Affects States

### Normal State
```css
.marimo-cell {
  border-radius: 10px;
  border: 1px solid var(--gray-4);
  box-shadow: /* small shadow */;
}
```

### Hover State
```css
.marimo-cell.interactive:hover {
  /* border-radius stays 10px */
  box-shadow: /* medium shadow */;
}
```

### Focus State
```css
.marimo-cell.interactive:focus-within {
  /* border-radius stays 10px */
  border: 1px solid var(--gray-5);
  box-shadow: /* large shadow */;
  left: -1px;
  top: -1px;
}
```

**Important**: Border radius remains constant across all states (normal, hover, focus, error, disabled).

---

## Special Cases

### 1. Published Mode (No Cell Outline)

**File**: [frontend/src/css/app/Cell.css:238-269](frontend/src/css/app/Cell.css:238-269)

```css
.marimo-cell.published {
  border: none;
  box-shadow: none;
  /* border-radius is still 10px but not visible */
}
```

Border radius is still applied but not visible since there's no border or shadow.

### 2. Borderless Mode

**File**: [frontend/src/css/app/Cell.css:273-287](frontend/src/css/app/Cell.css:273-287)

```css
.marimo-cell.borderless {
  border-color: transparent;
  box-shadow: none;
  /* border-radius is still 10px */
}
```

On hover, border and shadow appear:
```css
.marimo-cell.borderless:hover {
  border: 1px solid var(--gray-4);
  box-shadow: /* small shadow */;
  /* border-radius is now visible */
}
```

### 3. Error State

**File**: [frontend/src/css/app/Cell.css:179-192](frontend/src/css/app/Cell.css:179-192)

```css
.marimo-cell.has-error {
  /* border-radius stays 10px */
  outline: 1px solid var(--red-4);
  box-shadow: /* red shadow */;
}
```

Border radius doesn't change; only outline and shadow change color.

---

## Customization

### How to Change Cell Roundness

Since the cell border-radius is hardcoded (not using the `--radius` variable), you need to override it with custom CSS:

#### Option 1: Custom CSS File

```python
# In notebook
import marimo as mo
app = mo.App(css_file="custom.css")
```

```css
/* custom.css */

/* Change main cell roundness */
.marimo-cell {
  border-radius: 16px !important; /* More rounded */
}

/* Adjust child elements to match */
.marimo-cell.interactive > :first-child {
  border-top-left-radius: 15px !important;
  border-top-right-radius: 15px !important;
}

.marimo-cell.interactive > :last-child {
  border-bottom-left-radius: 15px !important;
  border-bottom-right-radius: 15px !important;
}

/* Adjust AI overlays */
.marimo-cell:has(.mo-ai-generated-cell)::before,
.marimo-cell:has(.mo-ai-deleted-cell)::before {
  border-radius: 16px !important;
}
```

#### Option 2: Square Cells (No Roundness)

```css
/* custom.css */
.marimo-cell,
.marimo-cell.interactive > :first-child,
.marimo-cell.interactive > :last-child,
.marimo-cell .cm {
  border-radius: 0 !important;
}
```

#### Option 3: Very Rounded (Pill-shaped)

```css
/* custom.css */
.marimo-cell {
  border-radius: 24px !important;
}

.marimo-cell.interactive > :first-child {
  border-top-left-radius: 23px !important;
  border-top-right-radius: 23px !important;
}

.marimo-cell.interactive > :last-child {
  border-bottom-left-radius: 23px !important;
  border-bottom-right-radius: 23px !important;
}
```

---

## Design Philosophy

### Why 10px?

1. **Modern Standard**: 8-12px is common for card-like UI elements
2. **Not Too Round**: Avoids looking "bubbly" or toy-like
3. **Not Too Sharp**: Softer than 4-6px corners
4. **Scales Well**: Works at different screen sizes and zoom levels
5. **Matches Design Trends**: Consistent with modern design systems (Material, Fluent, etc.)

### Comparison with Other Design Systems

| Design System | Card Border Radius |
|---------------|-------------------|
| **Material Design 3** | 12px (default) |
| **Fluent 2** | 8px (default) |
| **Tailwind CSS** | 8px (`rounded-lg`) |
| **Bootstrap 5** | 8px (`.card`) |
| **Marimo Cells** | 10px ✅ |

Marimo's 10px sits comfortably in the middle of modern design systems.

---

## Related CSS Variables

While cells don't use the global `--radius` variable, other UI elements do:

**File**: [frontend/src/css/globals.css:48](frontend/src/css/globals.css:48)

```css
:root {
  --radius: 8px;
}
```

**Used by**:
- Buttons
- Input fields
- Dropdowns
- Tooltips
- Cards (non-cell)
- Modals
- Popovers

To create a consistent design, you could override both:

```css
:root {
  --radius: 12px; /* Global UI elements */
}

.marimo-cell {
  border-radius: 12px !important; /* Cells */
}
```

---

## Summary Table

| Element | Location in CSS | Border Radius | Why |
|---------|----------------|---------------|-----|
| Cell Container | `Cell.css:12` | `10px` | Main outer boundary |
| AI Overlay | `Cell.css:30, 53` | `10px` | Matches container |
| First Child | `Cell.css:100-101` | `9px` | Nested inside container |
| Last Child | `Cell.css:105-106` | `9px` | Nested inside container |
| CodeMirror | `Cell.css:133` | `8px` | Matches global `--radius` |
| Tray First | `Cell.css:363-364` | `9px` | Nested inside tray |
| Tray Last | `Cell.css:368-369` | `9px` | Nested inside tray |
| Active Line | `Cell.css:439` | `2px` | Subtle highlight |
| Global Default | `globals.css:48` | `8px` | Used for buttons, inputs, etc. |

---

**Key Takeaway**: Marimo cells use **10px border radius** for a modern, professional appearance with visual hierarchy through nested 9px and 8px radii for child elements.

---

**Last Updated**: 2025-11-17
**Main Reference**: [frontend/src/css/app/Cell.css](frontend/src/css/app/Cell.css)
