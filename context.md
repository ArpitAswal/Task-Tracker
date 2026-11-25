# Project Context & Architectural Decisions

> **Rule**: Keep this file strictly under 150 lines. Architecture and *why* decisions only — never code snippets or pixel math.

## Stack & Architecture
| Layer | Technology | Purpose |
|---|---|---|
| **Framework** | Flutter (`Dart >=3.10.0`) | Cross-platform Android & iOS client |
| **State Management** | `Provider` (`ChangeNotifier` + `ValueNotifier`) | App & screen state (`Theme`, `Locale`, `Auth`, `Task`) |
| **Local Persistence** | `Hive` 2 (`hive_generator`) + `SharedPreferences` | Offline user/settings cache & app preferences |
| **Secure Storage** | `flutter_secure_storage` | Encrypted saved login credentials (`rememberMe`) |
| **Cloud Backend** | `Firebase Auth`, `Cloud Firestore`, `Firebase Messaging` | User auth, cloud task sync with offline cache, FCM |
| **Notifications** | `flutter_local_notifications` + `timezone` + `flutter_timezone` | Timezone-aware reminders & daily overdue alerts |
| **Native Bridge** | `MethodChannel` (`task_tracker/device_settings`) | OS notification & Android battery-optimization settings |
| **Localization & Theme** | `AppLocalizations` (`en`, `hi`) + `AppTheme` | Bilingual UI and Light/Dark/System themes |

## Folder Structure
| Path | Responsibility |
|---|---|
| `lib/core/constants/` | `AppConstants`, `StorageKeys`, `FirebaseCollections`, Hive `enums.dart` |
| `lib/core/localization/` | Manual map-based `AppLocalizations` (`en`, `hi`) |
| `lib/core/routes/` | Centralized `AppRoutes.generateRoute` & typed `RouteArguments` |
| `lib/core/services/` | `StorageService`, `NotificationService`, `DeviceSettingsService`, `BatteryOptimizationService` |
| `lib/core/utils/` | `ContextExtensions` breakpoints, `EffectBus` / `GlobalEffectListener`, loading/message helpers |
| `lib/data/models/` | `UserModel` (`typeId: 0`), `TaskModel` (`typeId: 1`), `TaskPriority` (`2`), `TaskCategory` (`3`), `TaskFilterState` |
| `lib/data/repositories/` | Firestore & auth data operations (`TaskRepository`, `AuthRepository`) |
| `lib/presentation/providers/` | `AuthProvider`, `TaskProvider`, `ThemeProvider`, `LocaleProvider` |
| `lib/presentation/screens/` | Feature screens (`auth`, `onboarding`, `home_dashboard`, `task`, `profile`, `setting`, `splash`, `exception`) |

## Key Decisions
| Date | Decision | Rationale |
|---|---|---|
| 2026-11 | `Provider` over Riverpod/BLoC | Matches existing `MultiProvider` tree (`Auth`, `Task`, `Theme`, `Locale`) with low boilerplate |
| 2026-11 | Firestore offline cache for tasks | `TaskRepository` relies on Firestore snapshots + native cache rather than duplicating tasks in Hive (`taskBox` disabled) |
| 2026-11 | Hive for `UserModel` & settings | Fast local startup cache; `typeId`s `0–3` are assigned and immutable |
| 2026-11 | Private Firebase config in `.gitignore` | `firebase_options.dart`, `google-services.json`, `GoogleService-Info.plist`, and `secrets.json` stay untracked for public repo safety |
| 2026-11 | Global `EffectBus` above Navigator | Surfaces async side-effect warnings cleanly via `GlobalEffectListener` in `MaterialApp.builder` |

## Current Focus
- Aligning adaptive screen layouts (`task`, `setting`, `profile`, `auth`) and maintaining filter/localization reliability across English and Hindi.
