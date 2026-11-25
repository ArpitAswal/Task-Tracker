---
name: hive-database
description: Step-by-step execution checklist for creating, modifying, and migrating Hive local database models with hive_generator in Task Tracker. Load this skill whenever adding a new Hive type, adding fields to UserModel/TaskModel/enums, or troubleshooting codegen errors.
---

# Hive Database Workflow

Follow this exact pipeline for every Hive model create/update task in Task Tracker.

## Existing Registered TypeIds (Reserved — Never Reuse)
| `typeId` | Model / Enum | File |
|---|---|---|
| `0` | `UserModel` | `lib/data/models/user_model.dart` |
| `1` | `TaskModel` | `lib/data/models/task_model.dart` |
| `2` | `TaskPriority` | `lib/core/constants/enums.dart` |
| `3` | `TaskCategory` | `lib/core/constants/enums.dart` |

> Assign `typeId >= 4` for any new `@HiveType`.

## Step 1: Design the Model
1. Search `lib/data/models/` and `lib/core/constants/` for `@HiveType(typeId:` to verify the next unused integer.
2. Assign `@HiveField(N)` indices starting from `0`. Once shipped, indices are **permanent** — never change or reuse a field index.
3. Keep models immutable with `final` fields and a `copyWith()` method.

```dart
import 'package:hive/hive.dart';

part 'task_note_model.g.dart'; // generated file

@HiveType(typeId: 4) // next unused ID (0..3 are reserved)
class TaskNoteModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String body;

  TaskNoteModel({required this.id, required this.body});
}
```

## Step 2: Run Code Generation
```bash
dart run build_runner build --delete-conflicting-outputs
```
Verify that `*.g.dart` is generated with the matching `*Adapter` class.

## Step 3: Register & Open via `StorageService`
Register the adapter inside `StorageService.initialize()` (`lib/core/services/storage_service.dart`) **before** opening its box:
```dart
if (!Hive.isAdapterRegistered(4)) {
  Hive.registerAdapter(TaskNoteModelAdapter());
}
```
Note: Task Tracker currently uses Firestore native offline cache for tasks (`AppConstants.taskBox` opening is commented out in `StorageService.initialize()`), while `AppConstants.userBox` and `AppConstants.settingsBox` are opened at startup. Do not open duplicate task boxes unless intentionally introducing local-only Hive task storage.

## Step 4: Security Rule
- Never store passwords, auth tokens, or sensitive credentials in Hive boxes.
- Use `StorageService.saveSecure()` / `readSecure()` (`flutter_secure_storage`) for sensitive data such as `StorageKeys.savedPassword`.

## Step 5: Field Migration (Adding Fields to `UserModel` / `TaskModel`)
- Add the new `@HiveField` with the **next unused index** (never fill gaps).
- Make the new field nullable or provide a safe default value so existing binary records deserialize without throwing.
- Re-run `dart run build_runner build --delete-conflicting-outputs` and test deserialization with existing fixtures.

## Step 6: Verification
```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```
