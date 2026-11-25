# Platform Extension: Flutter & Dart

> **Activation**: Apply when working with `pubspec.yaml`, `*.dart` files, or Flutter widgets, services, and providers.

## 1. Architecture & State Management
- **Layered Project Structure**: Organize code under `lib/core/` (`constants`, `localization`, `routes`, `services`, `theme`, `utils`), `lib/data/` (`models`, `repositories`), and `lib/presentation/` (`providers`, `screens`, `widgets`).
- **Provider Pattern (Project Standard)**: This project uses `Provider` with `ChangeNotifier` (`AuthProvider`, `TaskProvider`, `ThemeProvider`, `LocaleProvider`) and `ValueNotifier` for isolated widget state. Do **not** introduce Riverpod, BLoC, or GetX without explicit architectural approval. Access state with `context.watch<T>()` / `Consumer<T>` / `Selector<T, R>` for rebuilding widgets and `context.read<T>()` (or `Provider.of<T>(context, listen: false)`) for event-only calls — never `context.watch` inside callbacks or `initState`.
- **Global Side-Effect Errors**: Surface cross-cutting async warnings/failures through `EffectBus` / `GlobalEffectListener` (`lib/core/utils/exception_handling/`) rather than passing `BuildContext` into data repositories.
- **Immutable Data & Explicit States**: Prefer `final` fields and `copyWith()` updates (`TaskModel`, `UserModel`, `TaskFilterState`). Use Dart 3 `sealed class` or `enum` state representations cleanly where appropriate.

## 2. Rebuild Discipline & Widget Performance
- **Aggressive `const`**: Add `const` to all widget constructors and child subtrees where possible.
- **Scope Listeners Tight**: Wrap only the specific child widgets that depend on state changes in `Consumer<T>`, `Selector<T, R>`, or `ValueListenableBuilder`. Avoid `context.watch` at the top-level screen widget to prevent full-tree rebuilds.
- **ListView Builders**: Always use `ListView.builder` or slivers for dynamic task/leaderboard lists. Never embed an unbounded `ListView` inside a `Column` without `Expanded` or `Flexible`.

## 3. Lifecycle & Asynchronous Safety
- **Dispose Resources**: Every `TextEditingController`, `AnimationController`, `ScrollController`, `TabController` listener, `FocusNode`, `StreamSubscription`, `ValueNotifier`, `WidgetsBindingObserver`, or `ChangeNotifier` created in a widget/provider MUST be cleaned up in `dispose()`.
- **Async `BuildContext` Safety**: After any `await`, always check `if (!context.mounted) return;` (or `if (!mounted) return;` in `State`) before calling `AppRoutes` / `Navigator`, showing `SnackBar`s / dialogs, or accessing `Theme.of(context)`.
- **Safe `notifyListeners()`**: Guard `notifyListeners()` against calls after `dispose()` (following `TaskProvider`'s `_disposed` pattern).

## 4. Hive Local Database & StorageService
- Manage Hive initialization, adapter registration, `SharedPreferences`, and `flutter_secure_storage` through `StorageService` (`lib/core/services/storage_service.dart`).
- Existing `@HiveType` IDs are reserved: `UserModel` (`0`), `TaskModel` (`1`), `TaskPriority` (`2`), `TaskCategory` (`3`). Never reuse or change an existing `typeId` or `@HiveField(N)` index.
- After editing any annotated model, regenerate adapters:
  ```bash
  dart run build_runner build --delete-conflicting-outputs
  ```
- Never store passwords or sensitive tokens in Hive or `SharedPreferences`. Use `StorageService.saveSecure()` (`flutter_secure_storage`) exclusively.

## 5. Verification Commands
```bash
dart format .
flutter analyze
flutter test
flutter test --coverage
```
