# Task Tracker App Flow

## App Startup

1. `main.dart` initializes Flutter bindings.
2. Firebase is initialized with `DefaultFirebaseOptions.currentPlatform`.
3. `StorageService` initializes Hive, SharedPreferences, and secure storage.
4. `NotificationService` initializes timezone-aware local notifications and requests permissions where supported.
5. The app locks orientation to portrait.
6. Providers initialize theme, locale, auth, and task state.
7. `SplashScreen` waits briefly, then routes the user based on onboarding, login, and email verification state.

## Entry Routing

- If logged in and email is verified: go to `HomeDashboardView`.
- If onboarding is complete but the user is signed out or not verified: go to `LoginScreen`.
- Otherwise: go to `OnboardingScreen`.

## Onboarding Flow

- First-time users see a three-page onboarding experience.
- Onboarding completion is stored in SharedPreferences.
- After completion, users continue to authentication.

## Authentication Flow

Available screens:

- Login
- Sign up
- Forgot password
- Email verification

User journey:

1. User signs up with email and password.
2. Firebase creates the account and sends a verification email.
3. User verifies email before entering the home dashboard.
4. User can resend verification email.
5. Existing users can log in.
6. Remember-me can save credentials using secure storage.
7. Forgot password sends a Firebase reset email.
8. Logout clears login state while respecting remember-me credentials.

## Home Navigation

The authenticated home experience is `HomeDashboardView`, using a slider drawer and a two-tab task view.

Drawer destinations:

- Tasks
- Profile
- Leaderboard
- Settings

The floating action button appears on the Tasks section and opens the add-task popup.

## Task Flow

Users can:

- Create tasks.
- Edit tasks.
- Delete tasks.
- Mark tasks complete.
- Mark completed tasks incomplete.
- Search tasks.
- Filter by all, pending, completed, overdue, and due today.
- Sort by due date, creation date, or priority.
- Categorize tasks as personal, work, or other.
- Set priority as high, medium, or low.
- Set a specific end time for the task.
- Add optional reminders at a user-chosen time.

Task creation/editing behavior:

- The due date defaults to today when creating a new task.
- The End Of Task Time and Task Reminder Time pickers are always visible, regardless of which date is selected.
- Changing the date preserves the previously chosen time-of-day for both pickers.
- The only hard validation is that the reminder time cannot be in the past. If the time is invalid, a descriptive error toast guides the user; the form is not silently blocked.
- There is no enforced minimum gap between the reminder time and the task end time. The user controls both independently.

Task card visual states:

- **Pending, future task**: shows due date + time, days remaining, and upcoming reminder time if set.
- **Pending, due today**: shows date + time, a TODAY chip, and a DUE SOON chip if the task ends within 2 hours.
- **Pending, overdue**: shows date + time, an OVERDUE chip with the number of days past due.
- **Pending, reminder fired**: shows a muted "Reminder Sent" chip to indicate the reminder already ran.
- **Completed on time**: shows completion date + time, an ON TIME chip, and a FINISH chip.
- **Completed late**: shows completion date + time, an OVERDUE chip, and a FINISH chip.


## Offline And Sync Flow

1. User task operations write immediately to the local Firestore Native cache.
2. The UI is instantly updated via a Firestore `snapshots()` stream.
3. Firestore automatically synchronizes the local cache with the cloud database in the background when the network is available.
4. If cloud access fails or the device is offline, operations continue to work locally and will sync later.

## Notification Flow

Task reminders:

- A reminder is scheduled at `reminderAt` when the task is incomplete, the time is in the future, notification access is allowed, and the global task reminder toggle is enabled.

Task end notifications:

- A notification is scheduled at the task `endDate` when applicable.

Overdue summaries:

- On task initialization/load, the app checks overdue tasks and shows a daily summary at most once per day.

Cancellation:

- Completing a task cancels its scheduled reminders.
- Deleting a task cancels its scheduled reminders.
- Disabling task reminders cancels all scheduled notifications.
- Re-enabling task reminders reschedules active future reminders for the current user.

## Profile Flow

Users can set up and edit profile information:

- First name
- Last name
- Email
- Photo
- Gender
- Age
- Location

Profile data is stored in the Firestore user document. Photos are represented through the existing `photoUrl` field, which may contain a Base64 string.

## Streak Flow

- Completing the first task of a day updates the current streak.
- Completing tasks on consecutive days increments the streak.
- Missing a day resets the streak to 1 on the next completion.
- Longest streak is updated when the current streak exceeds it.
- Marking the only task completed today as incomplete can decrement the streak.
- Deleting all tasks resets the current streak.

## Leaderboard Flow

- Leaderboard reads users from Firestore.
- Users are ordered by `completedTasksCount` descending.
- The screen initially shows a limited set and can load more.

## Settings Flow

Settings includes:

- Theme: system, light, dark.
- Language: English, Hindi.
- Notification access status with a link to OS notification settings.
- Task reminders global toggle. When enabled, the user receives notifications at the time they configure for each task. The toggle does not enforce any default reminder offset.
- Android battery optimization status and settings shortcut.
- Delete all tasks.

Deleting all tasks also resets the user's streak.


## Permissions And Platform Services

Android permissions include:

- Notifications
- Exact alarms
- Boot completed receiver
- Battery optimization request
- Camera and media/image access
- Internet and network state
- Vibration and wake lock

Platform settings are opened through `DeviceSettingsService` using the `task_tracker/device_settings` method channel on Android.