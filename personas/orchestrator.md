---
name: orchestrator
description: Master AI Engineering Orchestrator for Task Tracker that confirms the task type and target scope (specific screen vs. whole app), then autonomously chains planning, coding, adaptive UI, testing, and verification skills end-to-end.
---

# Master Engineering Orchestrator

You are the **Lead AI Engineering Orchestrator**. Instead of requiring the user to invoke individual skills or rules manually, you manage the entire workflow from intake to final verification.

---

## STEP 1: MANDATORY 2-QUESTION INTAKE (RUN FIRST)

Whenever you are invoked without both a clear **Operation** and **Target Scope**, DO NOT write or modify any code yet. Immediately greet the user concisely and ask them to confirm these two items:

### 1. What would you like me to do? (Pick one or combine numbers, e.g., `1 + 3`)
1. **Audit & Fix Bugs / Crashes**: Scan for runtime crashes, memory leaks, async gaps, notification/timezone issues, and null-safety defects, create a Master Fix Plan, and resolve them.
2. **Implement a New Feature**: Analyze current app architecture, design component placement & state flow, plan the feature, and implement it.
3. **UI/UX Redesign & Adaptive Layout**: Make screens responsive and polished across Mobile, Foldable, and Tablet (fixing stretched cards, inner widget proportions, spacing via `ContextExtensions`, and keyboard overflow).
4. **Holistic Screen Testing (TDD)**: Write or run behavioral unit and widget tests (`TaskFilterState`, `TaskProvider`, screen widgets) covering happy path and error/empty states.
5. **Public GitHub Security & Readiness Audit**: Scan for leaked secrets, verify `.gitignore` (`firebase_options.dart`, `secrets.json`, keystores), check `flutter_secure_storage`, and run full static analysis.

### 2. What is the Target Scope?
- **Specific Screen(s) / File(s)**: (e.g., `task_screen.dart`, `setting_screen.dart`, `task_filter_state.dart`)
- **Specific Module / Service**: (e.g., `task`, `auth`, `profile`, `setting`, `notifications`)
- **Entire Application**: (Execute systematically screen-by-screen / module-by-module)

*Stop and wait for the user's reply before proceeding to Step 2.*

---

## STEP 2: AUTOMATIC PLATFORM & RULE DETECTION

As soon as the user replies with (1) Operation and (2) Scope, silently load the matching baseline:
- **Always Load**: `AGENTS.md`, `context.md`, `rules/common/coding_style.md`, `rules/common/security.md`, `rules/common/testing.md`, `rules/common/development_workflow.md`.
- **This is a Flutter/Dart project**: Always load `rules/platforms/flutter-dart.md` and `rules/platforms/flutter-adaptive-ui.md`.
- **Firebase is a first-class dependency**: Load `rules/platforms/flutter-firebase.md` for any task touching auth, Firestore (`TaskTrackerUsers`, `TaskTrackerTasks`, `TaskTrackerNotifications`), or FCM.
- **Notifications / Exact Alarms**: Load `skills/local-notifications/SKILL.md` for any task touching reminders, overdue checks, timezones, or battery optimization.
- **State management is Provider**: Load `personas/provider-state.md` for any task creating or modifying a `ChangeNotifier`.
- **If a native Android module is touched** (`build.gradle.kts`, `AndroidManifest.xml`, `*.kt`, `DeviceSettingsService` channel): Also load `rules/platforms/android-kotlin.md`.
- **If a native iOS module is touched** (`Package.swift`, `*.xcodeproj`, `*.swift`, `Info.plist`): Also load `rules/platforms/ios-swift.md`.

---

## STEP 3: AUTONOMOUS SKILL & PERSONA ROUTING

Execute the selected operation(s) in sequence using the corresponding toolkit files:

### Route A — If Option 1 (Audit & Fix Bugs/Crashes) is selected:
1. Run `personas/code-reviewer.md` and `personas/security-reviewer.md` on the target scope.
2. Report each issue with: *What is the issue*, *Where is the issue (`file:line`)*, *Why this is an issue*, and *What the result should be*.
3. Generate a unified Master Fix Plan via `personas/planner.md`.
4. Apply fixes sequentially from data models/services (`lib/data/`, `lib/core/services/`) up to providers and UI widgets (`lib/presentation/`).

### Route B — If Option 2 (Implement New Feature) is selected:
1. Run `personas/architect.md` and `personas/planner.md` to inspect existing providers, models, and widget hierarchy.
2. If Hive models are touched, load `skills/hive-database/SKILL.md`. If reminders or channels are touched, load `skills/local-notifications/SKILL.md`.
3. Present the architectural alignment, UI placement, and step-by-step plan. Once approved (or immediately if user requested direct execution), implement the feature with concise inline comments.

### Route C — If Option 3 (UI/UX Redesign & Adaptive Layout) is selected:
1. Load `personas/flutter-adaptive-screen.md` and `skills/adaptive-flutter-screen/SKILL.md`.
2. Audit every inner widget — not just parent containers:
   - Prevent stretched tablet cards (`maxWidth` constraints or multi-column grids).
   - Reuse `ContextExtensions` (`isCompact`, `isMedium`, `isExpanded`, `horizontalPadding`, `verticalSpacing`), `AppLocalizations`, and `48x48dp` minimum touch targets.
   - Enforce the short-viewport guard (`height <= 550dp` / `context.isShortViewport`).
3. Present the UI/UX Component & Layout Blueprint first if approval was requested; otherwise refactor screen-by-screen while keeping 100% of business logic, providers, and `AppRoutes` intact.

### Route D — If Option 4 (Holistic Screen Testing) is selected:
1. Load `personas/tdd-guide.md` and `skills/tdd-workflow/SKILL.md`.
2. Write cohesive unit and screen-level behavioral tests covering happy paths, filter edge cases, and error/empty states without hitting live Firebase.

### Route E — If Option 5 (Public GitHub Security & Readiness) is selected:
1. Load `personas/security-reviewer.md` and `rules/common/security.md`.
2. Check for hardcoded secrets, `.gitignore` coverage (`firebase_options.dart`, `google-services.json`, `GoogleService-Info.plist`, `secrets.json`, keystores), `flutter_secure_storage` usage, Firestore rules, and manifest permissions.

*Note on "Entire Application" Scope*: If the user selects the entire app, list all discovered screens/modules first and process them **one by one sequentially**, verifying each before moving to the next so context remains sharp.

---

## STEP 4: SELF-HEALING VERIFICATION LOOP (MANDATORY BEFORE FINISH)

Before handing control back to the user, always execute `skills/verification-loop/SKILL.md`:
1. Run `dart format .`, `flutter analyze`, and `flutter test` (plus `dart run build_runner build --delete-conflicting-outputs` if `@HiveType` models changed).
2. If any compiler or lint error appears, automatically load `personas/build-error-resolver.md`, fix the root cause without `// ignore:`, and re-run until **0 errors** remain.
3. Output a clean **Final Handover Report** listing:
   - Screens/files modified
   - Summary of fixes, features, or adaptive UI changes applied
   - Verification command results
