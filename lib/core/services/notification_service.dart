import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../data/models/task_model.dart';
import '../constants/app_constants.dart';
import '../localization/app_localizations.dart';

/// Notification service for scheduling task reminders
///
/// Uses [FlutterLocalNotificationsPlugin] to schedule local notifications
/// [reminderHour] hours after task creation. Supports global enable/disable toggle.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;
  static TimezoneInfo? _timezone;
  static List<TimezoneInfo> _availableTimezones = [];

  /// Initialize the notification plugin and timezone data
  ///
  /// Must be called before [scheduleTaskReminder] or [cancelTaskReminder].
  /// Typically called once in `main()` before `runApp`.
  static Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();
    _timezone = await FlutterTimezone.getLocalTimezone();
    _availableTimezones = await FlutterTimezone.getAvailableTimezones();
    _availableTimezones.sort((a, b) => a.identifier.compareTo(b.identifier));
    print("availableTimeZones:  -> ${_availableTimezones.toList()}");
    tz.setLocalLocation(tz.getLocation(_timezone?.identifier ?? 'Unknown'));

    // Android init settings
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS / macOS init settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);

    // Request permissions on Android 13+
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final granted = await androidPlugin?.requestNotificationsPermission();

    // Persist permission state in SharedPreferences
    if (granted == true) {
      await setNotificationEnabled(true);
    }

    _initialized = true;
    debugPrint('🔔 NotificationService initialized');
  }

  /// Schedule two reminder notifications for a task:
  ///   1. One hour before the reminder time (early heads-up)
  ///   2. At the exact reminder time
  ///
  /// The reminder time is calculated as [task.createdAt] + [task.reminderHour].
  ///
  /// Skips scheduling if:
  /// - Notifications are globally disabled
  /// - The task has no reminder (`hasReminder == false`)
  /// - The scheduled time is already in the past
  static Future<void> scheduleTaskReminder(TaskModel task) async {
    // Check global toggle
    if (!await isNotificationEnabled()) return;

    // Check per-task reminder
    if (!task.hasReminder) return;

    final now = DateTime.now();
    final loc = await _getLocalizations();

    // Reminder time = task end date (the due date selected by the user)
    final exactReminderTime = task.endDate;

    // 1 hour before the exact reminder time
    final earlyReminderTime =
        exactReminderTime.subtract(const Duration(hours: 1));

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        AppConstants.notificationChannelId,
        AppConstants.notificationChannelName,
        channelDescription: AppConstants.notificationChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    try {
      // Notification 1: 1 hour before the reminder time
      if (earlyReminderTime.isAfter(now)) {
        final tzEarlyTime = tz.TZDateTime.from(earlyReminderTime, tz.local);
        await _notifications.zonedSchedule(
          task.id.hashCode,
          loc.translate('notification_task_reminder'),
          loc.translate('notification_task_due_in_1hr')
              .replaceAll('{taskTitle}', task.title),
          tzEarlyTime,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: null,
        );
        debugPrint(
            '🔔 Scheduled early reminder for "${task.title}" at $earlyReminderTime');
      }

      // Notification 2: At the exact reminder time
      if (exactReminderTime.isAfter(now)) {
        final tzExactTime = tz.TZDateTime.from(exactReminderTime, tz.local);
        await _notifications.zonedSchedule(
          task.id.hashCode + 1,
          loc.translate('notification_task_due_now'),
          loc.translate('notification_task_due_now_msg')
              .replaceAll('{taskTitle}', task.title),
          tzExactTime,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: null,
        );
        debugPrint(
            '🔔 Scheduled exact reminder for "${task.title}" at $exactReminderTime');
      }
    } catch (e) {
      debugPrint('🔔 Failed to schedule reminder: $e');
    }
  }

  /// Cancel both scheduled reminders for a specific task
  static Future<void> cancelTaskReminder(String taskId) async {
    try {
      await _notifications.cancel(taskId.hashCode);
      await _notifications.cancel(taskId.hashCode + 1);
      debugPrint('🔔 Cancelled reminders for task $taskId');
    } catch (e) {
      debugPrint('🔔 Failed to cancel reminders: $e');
    }
  }

  /// Cancel all pending notification reminders
  static Future<void> cancelAllReminders() async {
    try {
      await _notifications.cancelAll();
      debugPrint('🔔 Cancelled all reminders');
    } catch (e) {
      debugPrint('🔔 Failed to cancel all reminders: $e');
    }
  }

  // ===========================================================================
  // GLOBAL TOGGLE
  // ===========================================================================

  /// Check if notifications are globally enabled
  ///
  /// Returns `true` if enabled (default), `false` if user disabled them
  static Future<bool> isNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(StorageKeys.notificationEnabled) ?? false;
  }

  /// Set the global notification enabled/disabled flag
  ///
  /// When set to `false`, [scheduleTaskReminder] becomes a no-op.
  /// Existing scheduled notifications are cancelled immediately.
  static Future<void> setNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageKeys.notificationEnabled, enabled);

    if (!enabled) {
      await cancelAllReminders();
    }
    debugPrint('🔔 Notifications ${enabled ? "enabled" : "disabled"}');
  }

  // ===========================================================================
  // DAILY OVERDUE CHECK
  // ===========================================================================

  /// Fixed notification ID for the general overdue reminder
  static const int _overdueNotificationId = 999999;

  /// Check for overdue tasks and show a one-time daily notification
  ///
  /// Call this on app launch. It will:
  /// 1. Skip if notifications are disabled
  /// 2. Skip if the notification was already shown today
  /// 3. Find tasks that are incomplete AND overdue by more than 1 day
  /// 4. Show a single general notification with the overdue count
  /// 5. Save today's date so it won't fire again until tomorrow
  static Future<void> checkAndNotifyOverdueTasks(List<TaskModel> tasks) async {
    if (!await isNotificationEnabled()) return;

    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    // Check if we already showed this notification today
    final lastDate =
        prefs.getString(StorageKeys.lastOverdueNotificationDate) ?? '';
    if (lastDate == todayStr) {
      debugPrint('🔔 Overdue notification already shown today');
      return;
    }

    // Find incomplete tasks overdue by more than 1 day
    final oneDayAgo = today.subtract(const Duration(days: 1));
    final overdueTasks = tasks
        .where((t) => !t.isCompleted && t.endDate.isBefore(oneDayAgo))
        .toList();

    if (overdueTasks.isEmpty) {
      debugPrint('🔔 No overdue tasks found');
      return;
    }

    final loc = await _getLocalizations();

    // Show the general overdue notification
    try {
      await _notifications.show(
        _overdueNotificationId,
        loc.translate('notification_overdue_title'),
        loc.translate('notification_overdue_msg')
            .replaceAll('{count}', overdueTasks.length.toString()),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            AppConstants.notificationChannelId,
            AppConstants.notificationChannelName,
            channelDescription: AppConstants.notificationChannelDescription,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );

      // Mark today as done
      await prefs.setString(
          StorageKeys.lastOverdueNotificationDate, todayStr);
      debugPrint(
          '🔔 Showed overdue notification for ${overdueTasks.length} task(s)');
    } catch (e) {
      debugPrint('🔔 Failed to show overdue notification: $e');
    }
  }

  // ===========================================================================
  // LOCALE HELPER
  // ===========================================================================

  /// Get localized strings for notifications by reading the stored locale
  static Future<AppLocalizations> _getLocalizations() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(StorageKeys.locale) ?? 'en';
    return AppLocalizations(Locale(localeCode));
  }
}
