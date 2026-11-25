# Platform Extension: Firebase & FlutterFire

> **Activation**: Apply when working with any Firebase-related Dart file, `firebase_options.dart`, Firestore collections (`TaskTrackerUsers`, `TaskTrackerTasks`, `UserTasks`, `TaskTrackerNotifications`), `AuthProvider`, or `firebase_messaging` (FCM).

## 1. Initialization Order (Critical)
- `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` MUST be the first async call in `main()`, right after `WidgetsFlutterBinding.ensureInitialized()`, and before `StorageService().initialize()`, `NotificationService.initialize()`, and `runApp()`.
- Example `main()` order in `lib/main.dart`:
  ```dart
  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await StorageService().initialize();
    await NotificationService.initialize();
    runApp(const MyApp());
  }
  ```

## 2. Firebase Auth
- Always verify `FirebaseAuth.instance.currentUser` before accessing user-scoped Firestore documents.
- Check email verification state cleanly in auth/splash flows (`AuthProvider`, `AppRoutes.emailVerify`) before routing to `AppRoutes.home`.
- Never store Firebase ID tokens manually; the Firebase SDK refreshes them automatically.

## 3. Cloud Firestore
- **Collection Structure**: Use constants in `FirebaseCollections` (`lib/core/constants/app_constants.dart`):
  - Users: `TaskTrackerUsers/{uid}`
  - Tasks: `TaskTrackerTasks/{uid}/UserTasks/{taskId}`
  - Notifications: `TaskTrackerNotifications`
- **Offline Persistence**: Firestore native offline cache is enabled by default on mobile and is the primary offline mechanism for tasks (`TaskRepository`). Do not disable persistence.
- **Avoid N+1 Reads**: Stream or query scoped collections (`tasksStream(userId)`) rather than fetching document IDs and issuing per-document `get()` calls in a loop.
- **Timestamp Serialization**: Convert `DateTime` ↔ `Timestamp` consistently in `TaskModel.toJson()` / `fromJson()` and `UserModel.toJson()` / `fromJson()`. Guard null timestamps safely on reads.
- **Error Handling**: Catch `FirebaseException` / `FirebaseAuthException` cleanly, map to user-friendly localized messages, and emit side-effect failures via `EffectBus` when appropriate.

## 4. Firebase Cloud Messaging (FCM)
- Respect manifest defaults (`firebase_messaging_auto_init_enabled="false"` in `AndroidManifest.xml`) unless explicit opt-in/token registration is initialized intentionally.
- Never log full FCM tokens or user PII to production logs.

## 5. Verification Commands
```bash
flutterfire configure     # regenerate local gitignored firebase_options.dart when switching Firebase projects
flutter analyze
flutter test
```
