---
name: adaptive-screen-blueprint-design
description: Read-only structural blueprint used to plan responsive layouts per screen. Do not overwrite this file with hardcoded screen data.
---

# Adaptive Screen Blueprint Schema (Read-Only Template)

> **IMPORTANT AGENT RULE:** Do NOT overwrite or edit this file with specific screen paths or hardcoded UI details. Use this template as your internal planning structure before refactoring the target Dart file.

## 1. Screen Context & Preservation Contract
- **Target Dart File:** `<path_to_target_screen.dart>`
- **Visual / Audit Source:** `<Side-Window Audit Notes | Figma/Screenshot | Widget-Tree Extraction>`
- **Preserved Logic & Controllers:** `<List all controllers, callbacks, AppRoutes calls, and Provider bindings that must not be broken>`
- **Project Utilities Reused:** `<AppTheme tokens, AppLocalizations keys, ContextExtensions, shared widgets>`

## 2. Responsive Composition Matrix

| Viewport Tier | Condition | Layout Structure | Dynamic Spacing (Pad / Gap) | Scroll & Keyboard Strategy |
| :--- | :--- | :--- | :--- | :--- |
| **Compact / Short** | `width < 600 \|\| height <= 550` (`context.isCompact`) | Single vertical column; collapse or scrim heavy imagery | Horizontal: `16dp` (`context.horizontalPadding`)<br>Vertical gap: `12dp` (`context.verticalSpacing`) | Full `SingleChildScrollView`; pad bottom by `viewInsets.bottom` |
| **Medium (Tablet Portrait)** | `600 <= width <= 840 && height > 550` (`context.isMedium`) | Centered `ConstrainedBox(maxWidth: 600)` or 2-column `Wrap`/Grid | Horizontal: `24dp`<br>Vertical gap: `20dp` | Contained scrollable card/column |
| **Expanded (Desktop / Tablet Landscape)** | `width > 840 && height > 550` (`context.isExpanded`) | 2-pane `Row` (`Expanded` visual/list pane + constrained content pane) | Horizontal: `32dp`<br>Vertical gap: `24dp` | Independent scrollable content pane |

## 3. Modular Widget Breakdown Plan
- **Primary Screen Shell:** Handles `LayoutBuilder` / `ContextExtensions` breakpoint switching and scaffold background.
- **Extracted Sub-Widgets (Private or Local Files under `widgets/`):**
  - `_HeaderSection` / `_BrandingPane`: Visual anchor and titles.
  - `_MainContentSection` / `_FormSection`: Core interactive fields, filter bars, and cards.
  - `_ActionFooter`: Primary CTAs and secondary actions with `>= 48dp` touch targets.
