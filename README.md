## App Logo
Click on a logo to download the latest version of the app apk file:

<a href="https://github.com/ArpitAswal/Task-Tracker/releases/download/v1.0.0/TaskTracker-app-v1.0.0-release.apk"><img width="96" height="96" alt="todo_image" src="https://github.com/user-attachments/assets/a80658be-b0a7-4e09-a8ea-2005eaacb136" />
</a>

# Task Tracker

Task Tracker is a Flutter productivity app for managing personal tasks with offline support, Firebase sync, localized UI, and scheduled local notifications.

## Current Highlights

- Email/password authentication with verification flow
- Onboarding for first-time users
- Task CRUD with categories, priorities, and reminder times
- Offline-first storage with Hive plus Firestore sync
- Theme switching: System, Light, Dark
- Localization: English and Hindi
- Profile, streaks, and leaderboard
- Local task reminders and overdue notifications
- Android battery optimization shortcut in Settings

## Feature Overview

### Authentication
- Login
- Sign up
- Forgot password
- Email verification
- Remember me support

### Task Management
- Create, edit, complete, incomplete, and delete tasks
- Optional description, priority, category, and reminder time
- Validation for reminder timing
- Sorting and filtering support

### Notifications
- Task reminder notification at `reminderAt`
- End-of-task notification at the task end time
- Daily overdue summary notification
- Global Task Reminders toggle in Settings
- Re-scheduling of active reminders when notifications are turned back on
- Android exact scheduling support for stronger idle-mode delivery

### Settings
- Theme selection
- Language selection
- Task reminders on/off
- Battery optimization shortcut on Android
- Delete all tasks

### Persistence and Sync
- Hive for local task caching
- Firestore for cloud sync
- SharedPreferences for user preferences
- Secure storage for sensitive saved credentials

## App Flow

1. App launches and initializes Firebase, storage, and notifications.
2. Splash screen checks onboarding, login state, and email verification.
3. User is routed to:
   - Onboarding on first launch
   - Login if signed out
   - Email verification if account is not verified
   - Home dashboard if authenticated and verified
4. Home dashboard provides:
   - Tasks
   - Profile
   - Leaderboard
   - Settings

## Notification Behavior

### How task reminders work
- Notifications are initialized during app startup.
- Reminder scheduling is timezone-aware.
- A task reminder is scheduled only if:
  - the global notification toggle is enabled
  - the task has a valid future reminder
  - the task is not completed
- Completing or deleting a task cancels its scheduled notifications.

### Android battery saver / battery optimization
Battery optimization can delay or suppress notifications on some Android devices.

The app now includes a Battery Optimization entry in Settings:
- it reads the current optimization exemption status
- it opens the Android system battery optimization screen
- it helps the user whitelist the app for better notification reliability

Important:
- this setting cannot be silently changed by Flutter alone
- Android requires the user to confirm the change in system UI

## Installation

### Prerequisites
- Flutter SDK
- Firebase project configured for Android/iOS
- `firebase_options.dart`
- `google-services.json` and/or `GoogleService-Info.plist`

### Run locally

```bash
git clone https://github.com/ArpitAswal/TaskTracker.git
cd TaskTracker
flutter pub get
flutter run
```

## Tech Stack

- Flutter
- Provider
- Firebase Auth
- Cloud Firestore
- Hive
- SharedPreferences
- Flutter Secure Storage
- flutter_local_notifications
- timezone

## Important Notes

- Android 13+ requires notification permission.
- Some Android versions/devices also require exact alarm approval for precise scheduling.
- Even with exact scheduling, aggressive OEM battery optimization may still delay alerts.
- The app provides a battery optimization settings shortcut, but the final permission change is system-controlled.
- The repository still contains a default sample widget test that does not reflect the real app bootstrap and will fail without Firebase-aware test setup.

## Documentation Files

Additional project documentation:
- `lib/app_flow_txt`
- `lib/app_implementation.text`

These files have been updated to match the current production flow and feature set.

## Contributing

Contributions are welcome through issues and pull requests.

## Feedback

For feedback or bug reports, please use the repository issues or contact:
- `arpitaswal995@gmail.com`
