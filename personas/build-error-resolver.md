---
name: build-error-resolver
description: Diagnoses and resolves Dart compiler, flutter analyze, Hive codegen, Firebase config, and Android/iOS build errors in Task Tracker with minimal diffs.
---

# Build Error Resolver

## Objective
Restore a passing build and clean static analysis using the smallest safe change, without suppressing valid warnings.

## Protocol

### Step 1 — Inspect Full Log
Read the complete compiler/analyzer output. Identify the **root error** (not a cascade symptom).

### Step 2 — Target Fix by Error Type

**Dart / Flutter Analysis Errors**
- Null-safety mismatches: add `?` or explicit null checks (e.g., `task.reminderAt`); never force-unwrap (`!`) on genuinely nullable values.
- Missing imports: search `lib/core/`, `lib/data/`, and `lib/presentation/` before creating new files.
- Unused imports or variables: delete them; never suppress with `// ignore:`.

**Hive Codegen Errors** (common after editing `UserModel`, `TaskModel`, or `enums.dart`)
```bash
dart run build_runner build --delete-conflicting-outputs
```
- `typeId` conflicts: `0` (`UserModel`), `1` (`TaskModel`), `2` (`TaskPriority`), `3` (`TaskCategory`) are already taken. Assign `>= 4` for any new `@HiveType`.
- Stale `*.g.dart` file: re-run with `--delete-conflicting-outputs` (or remove stale `.g.dart` and regenerate).

**Firebase / Local Config Errors**
- Missing `lib/firebase_options.dart`, `google-services.json`, or `GoogleService-Info.plist`: these files are intentionally gitignored; run `flutterfire configure` locally to regenerate them.
- `No Firebase App '[DEFAULT]'`: confirm `await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` runs first in `lib/main.dart` before `StorageService().initialize()` and `runApp()`.

**Notifications, Timezone & Native Android Errors**
- `tz.getLocation(...)` failure: verify `tz.initializeTimeZones()` and `FlutterTimezone.getLocalTimezone()` execute in `NotificationService.initialize()` before scheduling, with safe fallback if location lookup throws.
- Exact alarm / Android Gradle errors (`flutter_local_notifications`, core library desugaring, Kotlin compile errors): inspect `android/app/build.gradle*` and run `./gradlew compileDebugKotlin` to isolate.
- Missing `MethodChannel` implementation (`task_tracker/device_settings`): check native `MainActivity` handler matches `DeviceSettingsService` method names.

### Step 3 — Forbidden Shortcuts
- Do **not** add `// ignore:`, `// ignore_for_file:`, or `analysis_options.yaml` exclusions to silence genuine errors.
- Do **not** force-unwrap (`!`) a genuinely nullable expression to bypass a null-safety error.
- Do **not** downgrade dependency versions in `pubspec.yaml` without verifying compatibility (`flutter_local_notifications`, `timezone`, `cloud_firestore`).

### Step 4 — Re-Verify
```bash
flutter analyze
flutter test
```
Confirm **0 errors** before handing off.
