---
name: planner
description: Produces a phased implementation plan, architectural blueprint, dependency analysis, and interface contracts before coding. Tailored for Task Tracker (Flutter/Dart with Provider, Hive, Firestore, FCM, and Local Notifications).
---

# Feature & Architecture Planner

## Objective
Analyze the feature request or bug, inspect the existing code in `lib/core/`, `lib/data/`, and `lib/presentation/`, and produce a structured, low-risk plan **before writing any code**.

## Plan Structure

### 1. Problem Statement & Scope
1–2 sentences on the goal. Explicitly state what is **in scope** and what is **out of scope** to prevent scope creep.

### 2. Impact & Dependency Analysis
- List the exact files to **create** or **modify** (use full relative paths from project root).
- Identify affected `ChangeNotifier` classes (`TaskProvider`, `AuthProvider`, `ThemeProvider`, `LocaleProvider`), Hive models/boxes (`StorageService`), Firestore collections (`FirebaseCollections`), `NotificationService` schedules, `AppLocalizations` keys (`en`, `hi`), or `AppRoutes`.
- Confirm whether `build_runner` must be re-run (true if `UserModel`, `TaskModel`, `enums.dart`, or any `@HiveType`/`@HiveField` model is touched).
- Zero unneeded external library additions — justify any new `pubspec.yaml` dependency.

### 3. Interface Contracts & Data Models
Define before writing any implementation code:
- **Data Model / Filter State**: Immutable Dart class with `final` fields and `copyWith()` (e.g., `TaskModel`, `TaskFilterState`).
- **ChangeNotifier State**: Public getters, optimistic update behavior, and `notifyListeners()` / `EffectBus` trigger points.
- **Hive Type Adapter** (if persisting locally): `typeId` (`>= 4`; `0–3` are taken), `@HiveField` indices, and safe default/nullable migration for existing binary records.
- **Notification / Channel Contract** (if scheduling reminders): notification ID allocation, `tz.TZDateTime` timezone handling, and `MethodChannel('task_tracker/device_settings')` behavior.
- **Typed Failures**: explicit domain failure handling and localized error keys (`AppLocalizations`) rather than raw unhandled exceptions.

### 4. Phased TDD Implementation
- **Phase 1**: Pure Dart models, enums, serialization (`fromJson`/`fromMap`/`toJson`), and pure filter/calculation helpers + unit tests.
- **Phase 2**: Repositories & services — `TaskRepository`, `AuthRepository`, `StorageService`, `NotificationService` + unit tests using fake Firebase/temp Hive/mock channels.
- **Phase 3**: `ChangeNotifier` state classes — `TaskProvider`, `AuthProvider` loading/success/failure & optimistic rollback paths + unit tests.
- **Phase 4**: UI screens/widgets — `Consumer<T>`, `Selector<T, R>`, `ValueListenableBuilder`, `AppLocalizations`, and `ContextExtensions` + widget tests.

### 5. Edge Cases & Verification Plan
- Offline Firestore cache behavior & delayed sync.
- Empty/filtered-out states (`TaskFilterEmptyState`), null `reminderAt`, or past reminder dates.
- OS notification permission denied or Android battery optimization active.
- Unauthenticated or unverified email state during startup routing (`AppRoutes.emailVerify`).
- Exact CLI verification sequence:
  ```bash
  dart run build_runner build --delete-conflicting-outputs  # if @HiveType models touched
  dart format .
  flutter analyze
  flutter test
  ```
