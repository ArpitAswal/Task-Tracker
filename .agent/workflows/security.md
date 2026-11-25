---
description: Run a full security and readiness audit before pushing to GitHub or publishing to the Play Store.
---

1. Load `personas/security-reviewer.md` and `rules/common/security.md`.
2. Load `rules/platforms/flutter-firebase.md` (Firebase security rules are always in scope).
3. Execute all 5 security check categories from `personas/security-reviewer.md`:
   - **Category 1**: Secret & private config exposure (scan for hardcoded passwords/keys/service accounts; confirm untracked status of `firebase_options.dart`, `google-services.json`, `GoogleService-Info.plist`, `secrets.json`, `firebase.json`).
   - **Category 2**: Local storage audit (verify `StorageKeys.savedPassword` and sensitive tokens use `flutter_secure_storage`, never `SharedPreferences` or unencrypted Hive boxes).
   - **Category 3**: Firebase security rules audit (review rules for `TaskTrackerUsers`, `TaskTrackerTasks`, `TaskTrackerNotifications`; reject `allow read, write: if true;`).
   - **Category 4**: Native channels & payloads (`MethodChannel('task_tracker/device_settings')`, deep-link/notification payload validation, cleartext check).
   - **Category 5**: Platform permissions (`AndroidManifest.xml` notification/alarm/battery/camera/media permissions and `Info.plist` usage descriptions).
4. Verify `.gitignore` coverage and `git status` for `.env`, `secrets.json`, `key.properties`, `local.properties`, `*.jks`, `*.keystore`, `*.p12`, and private Firebase files.
5. Output findings grouped by `[CRITICAL]`, `[HIGH]`, `[MEDIUM]`, `[OK]` with file paths and fix snippets.
6. Provide a final **Go / No-Go** verdict for the push or release.
