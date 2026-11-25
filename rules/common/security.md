# Common Application Security Rules

## 1. Secrets & Repository Hygiene
- **Zero Hardcoded Secrets**: Never commit API keys, OAuth secrets, Firebase service account keys, `secrets.json`, signing keystores (`.jks`, `.keystore`, `.p12`), or passwords into source files or version control.
- **Gitignored Local Configs**: Keep `.env`, `secrets.json`, `key.properties`, `local.properties`, `lib/firebase_options.dart`, `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`, and `firebase.json` untracked per `.gitignore`. Verify `git status` before every push.
- **Public Binary Assumption**: Treat client-side mobile binaries as public. Never embed production admin secrets inside Dart or native source code.

## 2. Secure Local Storage
- **Credentials & Sensitive Tokens**: Store saved login credentials (e.g., `StorageKeys.savedPassword` for Remember Me) and sensitive tokens exclusively via `StorageService.saveSecure()` / `flutter_secure_storage` (Android `encryptedSharedPreferences` / iOS Keychain `first_unlock`).
- **No Plaintext Credentials in Preferences or Hive**: Never write passwords, auth tokens, or sensitive secrets into `SharedPreferences` or unencrypted Hive boxes (`userBox`, `settingsBox`).
- **Session Cleanup**: On account logout or deletion, clear sensitive `flutter_secure_storage` keys and reset user-scoped state cleanly.

## 3. Firebase Security
- **User-Scoped Firestore Access**: Enforce least-privilege Firestore security rules so authenticated users may only read/write their own documents (`request.auth != null && request.auth.uid == userId`) across `TaskTrackerUsers`, `TaskTrackerTasks`, and `TaskTrackerNotifications`.
- **No Open Rules**: Never ship `allow read, write: if true;` in production Firestore rules.
- **FCM Tokens**: Treat FCM device tokens as user-scoped metadata and avoid logging full tokens or user passwords to debug consoles.

## 4. Platform Channels & Permissions
- **Native Channel Boundaries**: Validate method names and arguments passed across `MethodChannel` (`task_tracker/device_settings` in `DeviceSettingsService`) and guard platform checks (`Platform.isAndroid` / `Platform.isIOS`).
- **Minimal Permissions**: Only declare permissions required for Task Tracker features:
  - Notifications & Alarms: `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`, `SCHEDULE_EXACT_ALARM`, `USE_EXACT_ALARM`, `VIBRATE`, `WAKE_LOCK`, `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`.
  - Profile Photo: `CAMERA`, `READ_MEDIA_IMAGES` / `READ_EXTERNAL_STORAGE` (with clear `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription` strings in `Info.plist`).
- **Input Validation**: Sanitize deep links, notification payloads, user-entered task fields, and form inputs before persisting or rendering.
