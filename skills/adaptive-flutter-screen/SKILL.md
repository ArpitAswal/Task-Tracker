---
name: adaptive-flutter-screen
description: Step-by-step execution checklist for auditing, modularizing, coding, and verifying an adaptive Flutter screen across Mobile, Tablet, and Desktop.
---

# Adaptive Flutter Screen Execution Workflow

Follow this exact 4-step pipeline for every screen request:

## Step 1: Non-Destructive Project & Screen Discovery
1. **Verify Target Path & Mode:**
   - **Refactor Mode (File Exists):** Open the target screen Dart file (e.g., `lib/presentation/screens/task/task_screen.dart`) and trace its direct widget hierarchy, controllers, and provider bindings.
   - **Greenfield Mode (New Screen):** Create the target Dart file under `lib/presentation/screens/<feature>/`, wire existing/new providers cleanly, and register the route in `lib/core/routes/app_routes.dart`.
2. **Audit Project Capabilities:**
   - Check `lib/main.dart`, `android/app/src/main/AndroidManifest.xml`, and `ios/Runner/Info.plist` for orientation configuration (`portraitUp/Down` lock in `main.dart` vs. `~ipad` landscape in `Info.plist`) and custom `TextScaler` rules.
   - Reuse `ContextExtensions` (`lib/core/utils/extensions/context_extension.dart`), `AppTheme`, `AppColors`, and `AppLocalizations` (`lib/core/localization/app_localizations.dart`).
   - Identify `Provider` (`TaskProvider`, `AuthProvider`, `ThemeProvider`, `LocaleProvider`) or local `ValueNotifier` bindings used by the screen.
3. **Identify Preservation Targets (Refactor Mode):** List all existing callbacks, `AppRoutes` calls, controllers, and business logic that must remain untouched.

## Step 2: Responsive Layout Planning
Map the screen components against the read-only schema in `skills/adaptive-flutter-screen/templates/adaptive-screen-blueprint-design.md` (never overwrite the template):
1. **Compact (`width < 600 || height <= 550` / `context.isCompact`):** Plan a single scrollable column with `context.horizontalPadding` (`16dp`), compact vertical gaps, and safe keyboard clearance.
2. **Medium (`600 <= width <= 840 && height > 550` / `context.isMedium`):** Plan a centered, width-constrained layout (`maxWidth: 600`) or responsive `Wrap`/`Grid` with `context.horizontalPadding` (`24dp`).
3. **Expanded (`width > 840 && height > 550` / `context.isExpanded`):** Plan a split-screen or multi-pane layout (`Row` + `Expanded` + constrained content panes) with `context.horizontalPadding` (`32dp`).

## Step 3: Modular & Commented Code Implementation
1. **Modularize:** Split bulky UI trees into clean, `const`-friendly sub-widgets or separate files in the screen's `widgets/` folder.
2. **Apply Dynamic Spacing & Scroll Safety:** Use `ContextExtensions` and `LayoutBuilder` constraints to scale paddings/gaps smoothly, and wrap forms/scrollables in `SingleChildScrollView` / `CustomScrollView` to handle short viewports and keyboard popups.
3. **Wire State & Theme:** Connect existing state via narrow selectors (`Selector<T, R>`, `Consumer<T>`, `ValueListenableBuilder`) and apply semantic `Theme.of(context)` colors and `AppLocalizations` keys.
4. **Document in Code:** Add clear inline comments (`// ...`) above responsive branches, dynamic spacing helpers, and state bindings.

## Step 4: Static Verification & Handover
1. Run `dart format <modified_files>` to ensure clean formatting.
2. Run `flutter analyze <modified_files>` to verify zero syntax, typing, or unused-import issues.
3. Run through this final self-check before responding:
   - [ ] Existing business logic, controllers, providers, and `AppRoutes` are 100% preserved.
   - [ ] `templates/adaptive-screen-blueprint-design.md` was NOT overwritten with screen-specific hardcoded data.
   - [ ] `width < 600 || height <= 550` is properly handled without vertical or horizontal overflow.
   - [ ] Existing `AppLocalizations`, `AppTheme`, and `ContextExtensions` helpers are reused.
   - [ ] Code is split into clean sub-widgets with inline explanatory comments.
4. Output a brief summary of changes and stop for user review.
