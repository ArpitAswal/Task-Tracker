---
name: provider-state
description: Enforces correct Provider/ChangeNotifier and ValueNotifier patterns for the Task Tracker Flutter project. Load this persona whenever creating or modifying a provider class or reviewing state management code.
---

# Provider & ChangeNotifier State Persona

## Objective
Ensure every state class (`AuthProvider`, `TaskProvider`, `ThemeProvider`, `LocaleProvider`) and widget integration follows Task Tracker's `Provider` architecture cleanly — no mixed paradigms, no lifecycle leaks, no unnecessary tree rebuilds.

## Rules

### 1. ChangeNotifier Design
- Keep each `ChangeNotifier` **single-responsibility**: one class per concern (`TaskProvider`, `AuthProvider`, `ThemeProvider`, `LocaleProvider`).
- Expose read-only or immutable views of state to the UI (`List.unmodifiable(...)` where practical) and mutate state only inside provider methods before calling `notifyListeners()`.
- Model filter and selection state cleanly via immutable value objects (e.g., `TaskFilterState` with `copyWith()`), rather than scattered mutable booleans.
- Guard `notifyListeners()` against calls after `dispose()` (following `TaskProvider`'s `_disposed` flag pattern) when async snapshots or timers may settle late.

### 2. Provider Registration (`lib/main.dart` / `MultiProvider`)
- Register app-wide notifiers (`ThemeProvider`, `LocaleProvider`, `AuthProvider`, `TaskProvider`) inside `MultiProvider` at the root in `lib/main.dart`.
- Initialize async startup loads safely without blocking `build()`, logging errors cleanly.
- Never instantiate a `ChangeNotifier` directly inside a widget's `build()` method.

### 3. Widget Consumption Rules
| Use Case | Correct API |
|---|---|
| Rebuild widget on state change | `context.watch<T>()` or `Consumer<T>` |
| Narrow rebuild to one field | `Selector<T, R>(selector: (_, p) => p.field, builder: ...)` |
| Local toggle / loading state inside a screen | `ValueNotifier<T>` + `ValueListenableBuilder<T>` (disposed in `dispose()`) |
| Call a method / trigger event | `context.read<T>().method()` or `Provider.of<T>(context, listen: false)` |
| One-time read in `initState` | `context.read<T>()` inside `WidgetsBinding.instance.addPostFrameCallback` |

- **Never** use `context.watch<T>()` inside `initState`, `dispose`, or button `onPressed` callbacks.
- **Never** wrap an entire `Scaffold` in `Consumer<TaskProvider>` if only a tab header or task list depends on it.

### 4. Async Operations & Side-Effect Errors
- Set loading state before async repository work and clear it in a `finally` block.
- For global non-blocking warnings or background side-effect failures (such as Firestore sync warnings in `TaskProvider` / `AuthProvider`), emit events to `EffectBus` (`GlobalEffectListener`) instead of passing `BuildContext` into providers or repositories.
- Roll back optimistic UI mutations cleanly if the underlying repository call fails.

### 5. Disposal
- If a `ChangeNotifier` or screen state holds `StreamSubscription`s, `ValueNotifier`s, `TabController` listeners, or `WidgetsBindingObserver` registrations, always cancel/remove/dispose them in `dispose()` (e.g., `TaskProvider._taskSubscription?.cancel()`, `TaskProvider._drawerIndex.dispose()`).
