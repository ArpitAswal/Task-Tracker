# Adaptive Flutter UI Engineering Rules

> **Activation**: Apply whenever creating, refactoring, or reviewing responsive/adaptive Flutter screens across Mobile, Tablet, and Desktop viewports.

## 1. Responsive Breakpoints & Constraint Logic

- **Shell vs. Component Constraints:**
  - Use `MediaQuery.sizeOf(context)` and `MediaQuery.orientationOf(context)` (or `context.isCompact`, `context.isMedium`, `context.isExpanded` from `lib/core/utils/extensions/context_extension.dart`) at the top-level screen scaffold to decide macro-composition.
  - Note: `main.dart` currently locks `SystemChrome.setPreferredOrientations` to portrait on phones, while `ios/Runner/Info.plist` enables all 4 orientations for `~ipad`. Never assume portrait-only on tablets, foldables, or split-screen viewports.
  - Use `LayoutBuilder` for inner sections, forms, cards, and grids so widgets adapt to their actual parent constraints rather than global device flags.
- **Standard Viewport Envelopes (Matching `ContextExtensions`):**
  - **Compact (`width < 600` OR `height <= 550`):**
    - Single vertical scrollable column.
    - The `height <= 550` (`context.isShortViewport`) guard protects landscape phones, split-screen windows, and small viewports from vertical crushing. When triggered, reduce vertical gaps, collapse decorative headers, and enforce scrollability.
  - **Landscape / Short Viewport Guard:** If `height <= 550` (or `constraints.maxHeight <= 550`), treat the viewport strictly as **Compact** (single-column scrollable), NEVER as Expanded (2-column).
  - **Medium (`600 <= width <= 840` AND `height > 550`):**
    - Center primary forms or narrow content inside a `ConstrainedBox(constraints: BoxConstraints(maxWidth: 600))` so fields and buttons never stretch unnaturally across tablet portraits.
    - Use `Wrap` or responsive `GridView` (`SliverGridDelegateWithMaxCrossAxisExtent`) for multi-card content.
  - **Expanded (`width > 840` AND `height > 550`):**
    - Multi-pane composition (e.g., `Row` with two `Expanded` panes: an overview/list pane and a `ConstrainedBox(maxWidth: 480)` form/detail pane, or a balanced multi-column grid).
    - Do not leave large empty columns in the center; distribute task cards/metrics cleanly.

## 2. Dynamic Spacing, Padding & Margin

- **No Rigid Pixel Gaps:** Never use large fixed `SizedBox(height: 80)` spacers that overflow on short screens or when the keyboard opens.
- **Consume Project Extensions & Avoid Floating Math:** Always reuse existing helpers in `lib/core/utils/extensions/context_extension.dart`:
  - Breakpoints: `context.isCompact`, `context.isMedium`, `context.isExpanded`, `context.isShortViewport`, `context.isMobile`, `context.isTablet`, `context.isDesktop`
  - Spacing: `context.horizontalPadding` (`16 / 24 / 32`), `context.verticalSpacing` (`12 / 20 / 24`)
  - Helper: `context.responsiveValue(mobile: ..., tablet: ..., desktop: ...)`
  - Never invent non-existent extension getters or raw percentage math on child widths (e.g., `maxWidth * 0.1`).

## 3. Scrolling & Keyboard Safety

- **Content-Driven Scrolling:** Always evaluate whether child widgets can exceed available vertical space — especially when the virtual keyboard opens (`MediaQuery.viewInsetsOf(context).bottom > 0`) or `MediaQuery` text scaling is enlarged (note `main.dart` applies custom `TextScaler` factors: `0.6` for `<=360`, `0.8` default, `1.5` for `>=600`).
- **Overflow Prevention:**
  - Wrap forms and vertical flows in `SingleChildScrollView(physics: const ClampingScrollPhysics())` or `CustomScrollView` with `SliverFillRemaining(hasScrollBody: false)` when bottom-pinned buttons are needed.
  - Never place an unconstrained `Expanded` inside a `SingleChildScrollView` unless wrapped in `LayoutBuilder` + `ConstrainedBox(minHeight: constraints.maxHeight)` + `IntrinsicHeight`.
  - Never introduce nested vertical scrollables along the same axis without explicit physics management.

## 4. Reuse of Project Theme, Localization & Utilities

- **Inspect Before Creating:** Check the codebase for existing:
  - Theme tokens (`Theme.of(context).colorScheme`, `Theme.of(context).textTheme`, `lib/core/theme/app_theme.dart`, `app_colors.dart`).
  - Localization (`AppLocalizations.of(context)?.translate('key')` in `lib/core/localization/app_localizations.dart`). Never hardcode raw UI strings when localization keys exist.
  - Existing helpers in `lib/core/utils/extensions/context_extension.dart` and `widget_extensions.dart`.
- **Light & Dark Mode Parity:** Consume semantic color roles (`surface`, `onSurface`, `primary`, `outlineVariant`).
- **Touch Targets & Feedback:** Keep interactive tap targets at a minimum of `48x48dp`. Prefer `InkWell` or `IconButton` with `constraints: const BoxConstraints(minWidth: 48, minHeight: 48)` instead of bare `GestureDetector`.

## 5. State Management & Rebuild Discipline

- **Follow Task Tracker's Existing Pattern:** Use `Provider` (`AuthProvider`, `TaskProvider`, `ThemeProvider`, `LocaleProvider`) or local `ValueNotifier`s cleanly.
- **Narrow Rebuild Boundaries:**
  - Trigger actions with `context.read<T>()`.
  - Wrap only the specific leaf widget that needs updating in `Selector<T, R>`, `Consumer<T>`, or `ValueListenableBuilder`.
  - Never call `setState` at the top of a large screen if it rebuilds unaffected tabs, task lists, or drawers.

## 6. Clean Code, Modularity & Verification Scope

- **Break Down Large Files:** Keep the main screen widget focused on high-level layout switching. Extract distinct sections into private `_Widget` classes or files in the screen's `widgets/` folder.
- **Comment Every Key Decision:** Add concise inline comments explaining:
  1. Why a specific breakpoint or `height <= 550` branch is triggered.
  2. How keyboard insets and scrolling are handled.
  3. Which state slice a `Selector` or listener is observing.
- **UI-Pass Verification Boundary:** During a dedicated adaptive UI refactor pass, do not create, edit, or run widget/unit tests unless explicitly requested; verify layout changes via `dart format` and `flutter analyze`.
