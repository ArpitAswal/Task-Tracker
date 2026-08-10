# Task Tracker Summary

## What The Project Does

Task Tracker is a Flutter productivity app for managing personal tasks with authentication, offline storage, cloud sync, reminders, profile stats, streaks, leaderboard ranking, localization, and theme customization.

## Problem Solved

The app helps users keep track of tasks even when connectivity is unreliable. It combines offline-first task access with Firestore synchronization and local notifications so users can create, manage, and complete work without depending on a constant network connection.

## Major Features

- Email/password authentication with email verification.
- First-run onboarding.
- Task CRUD with priority, category, due date, specific end time, and user-configured reminder time.
- Search, filtering, sorting, pending/completed/overdue/due-today views.
- Firestore Native Offline Persistence caching for fast, offline-capable task tracking.
- Local task reminders, end-of-task notifications, and daily overdue summaries.
- Rich task card UI with contextual chips: date+time, reminder time, DUE SOON (< 2 hrs), TODAY, OVERDUE with day count, days remaining, ON TIME, and FINISH. All chips wrap automatically — no overflow on any screen size.
- Theme switching between system, light, and dark.
- English and Hindi localization.
- Profile setup and editing.
- Streak tracking and leaderboard.
- Android notification settings and battery optimization shortcuts.


## Technology Stack

- Flutter and Dart
- Provider for state management
- Firebase Core, Firebase Auth, Cloud Firestore, Firebase Messaging dependency
- Hive and Hive Flutter for User Model local storage
- SharedPreferences for app settings
- Flutter Secure Storage for saved credentials
- flutter_local_notifications for local notifications
- timezone and flutter_timezone for timezone-aware scheduling
- Material 3 theming with Poppins fonts

## Architecture Approach

The project uses a layered Flutter structure:

- `core` for shared infrastructure.
- `data` for models and repositories.
- `presentation` for providers, screens, and widgets.

The app uses manual dependency injection through constructors where needed. Provider owns UI state, repositories own data access, and services own platform integrations.

## Challenges Solved

- Offline task availability leveraging Firestore's Native Offline SQLite caching.
- Timezone-aware local reminders.
- Android exact alarm and battery optimization constraints.
- Localized notification text based on saved language preference.
- Streak and leaderboard updates tied to task completion behavior.
- Fixed a broken overdue detection that compared only the day-of-month instead of the full date, causing false overdue flags across month boundaries.
- Flexible reminder UX: time pickers always visible, no minimum gap enforced between reminder and end time, user guided by toast messages rather than hard blocks.


## Current Business Status

The app appears to be at version `1.0.0+1`, with an APK link referenced from the README. CI/CD and formal release automation are not present in the repository.