# AI Engineering Orchestration (`AGENTS.md`)

## 0. Active Project Stack (Load Always)
**Project**: Task Tracker — Flutter/Dart offline-capable task manager with Firebase sync, scheduled notifications, streaks, and English/Hindi localization.
- **Folder Layout**: `lib/core/`, `lib/data/{models,repositories}/`, `lib/presentation/{providers,screens,widgets}/`
- **State Management**: `Provider` (`ChangeNotifier`: `AuthProvider`, `TaskProvider`, `ThemeProvider`, `LocaleProvider`) + `ValueNotifier` for local widget state
- **Local Storage**: `StorageService` (`Hive` 2 typeIds `0–3` via `hive_generator`, `SharedPreferences`, `flutter_secure_storage`)
- **Remote & Notifications**: `Firebase` (`firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_messaging`) + `flutter_local_notifications` (`timezone`, `flutter_timezone`)
- **Code-gen gate**: `dart run build_runner build --delete-conflicting-outputs` after editing any `@HiveType`/`@HiveField` annotated model (`UserModel`, `TaskModel`, `TaskPriority`, `TaskCategory`).
- **Router**: `lib/core/routes/app_routes.dart` — inspect before adding routes.
- **context.md**: Consult `context.md` at the project root for active architectural decisions before every task.

## 1. Core Engineering Principles
1. **Plan Before Code**: For any non-trivial feature, architectural change, or multi-file refactor, produce a concise implementation plan (`personas/planner.md`) covering affected modules, data models, interface contracts, and edge cases before mutating source files.
2. **Immutability by Default**: Prefer immutable data structures, value objects, and unidirectional data flow (`final`/`const` and `copyWith` in Dart, e.g., `TaskModel`, `TaskFilterState`). Mutate state only through `ChangeNotifier.notifyListeners()`.
3. **Separation of Concerns**: Keep data models, pure filtering helpers, and repositories under `lib/data/`. Never scatter Firestore or `NotificationService` calls directly inside widget `build()` methods.
4. **Minimal Diff Discipline**: Modify only the files and lines required for the task. Never perform drive-by formatting, unprompted dependency updates, or speculative abstractions.
5. **Search & Inspect First**: Read `pubspec.yaml`, `lib/core/`, and adjacent modules before introducing any new pattern or library.

## 2. Standard Execution Workflow
1. **Understand & Scope**: Read `context.md` (project root), relevant files in `lib/`, and `pubspec.yaml`.
2. **Plan**: Define step-by-step phases, interface boundaries, and test cases via `personas/planner.md`.
3. **Test-Driven Implementation (`RED → GREEN → REFACTOR`)**:
   - Write or update failing tests first (`skills/tdd-workflow/SKILL.md`).
   - Implement the minimal code required to pass.
   - Run `dart run build_runner build --delete-conflicting-outputs` if Hive models were touched.
   - Refactor for clarity, immutability, and adherence to `rules/common/coding_style.md`.
4. **Verify (`skills/verification-loop/SKILL.md`)**:
   - Run `dart format .` → `flutter analyze` → `flutter test`.
   - Review diffs against `personas/code-reviewer.md` and `rules/common/security.md`.

## 3. Personas (Roles)
- **Orchestrator**: `personas/orchestrator.md` — master entry point, routes all tasks end-to-end.
- **Analyzer**: `personas/analyzer.md` — evaluates requirements, produces architectural trade-offs.
- **Architect**: `personas/architect.md` — enforces layer boundaries and dependency direction.
- **Planner**: `personas/planner.md` — produces phased implementation plan before coding.
- **Code Reviewer**: `personas/code-reviewer.md` — reviews diffs for bugs, leaks, and security flaws.
- **Security Reviewer**: `personas/security-reviewer.md` — audits secrets, `.gitignore`, storage, and manifests.
- **TDD Guide**: `personas/tdd-guide.md` — coaches `RED → GREEN → REFACTOR` cycle.
- **Build Error Resolver**: `personas/build-error-resolver.md` — fixes compiler and analyzer errors.
- **Adaptive Screen**: `personas/flutter-adaptive-screen.md` — responsive UI for Mobile/Tablet/Desktop.
- **Provider State**: `personas/provider-state.md` — enforces correct `Provider`/`ChangeNotifier` patterns.
- **Documentation Writer**: `personas/documentation-writer.md` — enforces bloat-free `context.md`, `README.md`, and `CHANGELOG.md`.

## 4. Baseline Standards (Always Load)
- `rules/common/coding_style.md`
- `rules/common/security.md`
- `rules/common/testing.md`
- `rules/common/development_workflow.md`

## 5. Conditional Platform Extensions
Load ONLY the platform rule matching your active workspace files:
- Flutter/Dart core: `rules/platforms/flutter-dart.md`
- Flutter Adaptive UI: `rules/platforms/flutter-adaptive-ui.md`
- Firebase integration: `rules/platforms/flutter-firebase.md`
- Android/Kotlin (native module / `DeviceSettingsService` bridge): `rules/platforms/android-kotlin.md`
- iOS/Swift (native module): `rules/platforms/ios-swift.md`
