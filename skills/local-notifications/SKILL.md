---
name: local-notifications
description: Step-by-step execution checklist for scheduling, cancelling, and troubleshooting timezone-aware local notifications, exact alarms, and battery optimization flows in Task Tracker.
---

# Local Notifications & Device Settings Workflow

Execute this skill whenever modifying `lib/core/services/notification_service.dart`, `device_settings_service.dart`, `battery_optimization_service.dart`, reminder scheduling in `TaskProvider`/`TaskRepository`, or notification permissions in `AndroidManifest.xml` / `Info.plist`.

---

## Step 1: Verify Initialization Order
1. Confirm `NotificationService.initialize()` runs in `lib/main.dart` **after** `WidgetsFlutterBinding.ensureInitialized()`, `Firebase.initializeApp()`, and `StorageService().initialize()`, and **before** `runApp()`.
2. Confirm timezone initialization runs before any `tz.TZDateTime` conversion:
   - `tz.initializeTimeZones()`
   - `FlutterTimezone.getLocalTimezone()` → `tz.setLocalLocation(...)`

## Step 2: Enforce Scheduling Preconditions
Before calling `_notifications.zonedSchedule(...)` in `NotificationService`:
1. Check app toggle: `await isNotificationEnabled()`.
2. Check OS-level access: `await areSystemNotificationsEnabled()`.
3. Check task state: `!task.isCompleted`, `task.hasReminder`, and `task.reminderAt != null`.
4. Guard past timestamps: skip if `reminderTime.isBefore(DateTime.now())` (and never force-unwrap `task.reminderAt!` without verifying non-null).
5. Use deterministic notification IDs (`task.id.hashCode` for reminder, `task.id.hashCode + 1` for end-of-task, `_overdueNotificationId` for daily overdue summary).

## Step 3: Lifecycle Cancellation & Rescheduling
- **Task Completed or Deleted**: Always call `NotificationService.cancelTaskReminder(task.id)`.
- **Task Edited**: Cancel stale schedules or overwrite deterministically, then reschedule if still incomplete and in the future.
- **Global Toggle Turned Off**: Immediately call `NotificationService.cancelAllReminders()`.
- **Global Toggle Turned On / Recovery**: Re-schedule active reminders via `NotificationService.rescheduleActiveRemindersForCurrentUser()`.

## Step 4: Native Device Settings & Battery Optimization Bridge
- Keep all OS settings redirects routed through `DeviceSettingsService` (`MethodChannel('task_tracker/device_settings')`) and `BatteryOptimizationService`.
- Always guard platform checks (`if (!Platform.isAndroid)` / `if (!(Platform.isAndroid || Platform.isIOS))`).
- Never silently mutate system permissions; present clear UI guidance via `SettingScreen` and re-check status in `didChangeAppLifecycleState(AppLifecycleState.resumed)`.

## Step 5: Verification
1. Check localization keys (`notification_task_reminder`, `notification_task_due_in_time`, `notification_task_ended`, `notification_overdue_title`, `notification_overdue_msg`) exist in both `'en'` and `'hi'` inside `AppLocalizations`.
2. Run `dart format .` → `flutter analyze` → `flutter test`.
