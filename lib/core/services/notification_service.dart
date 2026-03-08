import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../data/models/task_model.dart';
import '../constants/app_constants.dart';

/// Notification service for scheduling task reminders
///
/// Uses [FlutterLocalNotificationsPlugin] to schedule local notifications
/// 1 hour before a task's due date. Supports global enable/disable toggle.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// Initialize the notification plugin and timezone data
  ///
  /// Must be called before [scheduleTaskReminder] or [cancelTaskReminder].
  /// Typically called once in `main()` before `runApp`.
  static Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();
    final timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation('America/Detroit'));

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
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
    debugPrint('🔔 NotificationService initialized');
  }

  /// Schedule a reminder notification 1 hour before [task.endDate]
  ///
  /// Skips scheduling if:
  /// - Notifications are globally disabled
  /// - The task has no reminder (`hasReminder == false`)
  /// - The scheduled time (1 hour before due) is already in the past
  static Future<void> scheduleTaskReminder(TaskModel task) async {
    // Check global toggle
    if (!await isNotificationEnabled()) return;

    // Check per-task reminder
    if (!task.hasReminder) return;

    final scheduledDate = task.endDate.subtract(const Duration(hours: 1));

    // Don't schedule if the reminder time is in the past
    if (scheduledDate.isBefore(DateTime.now())) return;

    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    try {
      await _notifications.zonedSchedule(
        task.id.hashCode,
        'Task Reminder',
        'Task "${task.title}" is due in 1 hour!',
        tzScheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            AppConstants.notificationChannelId,
            AppConstants.notificationChannelName,
            channelDescription: AppConstants.notificationChannelDescription,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: null,
      );
      debugPrint('🔔 Scheduled reminder for "${task.title}" at $scheduledDate');
    } catch (e) {
      debugPrint('🔔 Failed to schedule reminder: $e');
    }
  }

  /// Cancel a scheduled reminder for a specific task
  static Future<void> cancelTaskReminder(String taskId) async {
    try {
      await _notifications.cancel(taskId.hashCode);
      debugPrint('🔔 Cancelled reminder for task $taskId');
    } catch (e) {
      debugPrint('🔔 Failed to cancel reminder: $e');
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
    return prefs.getBool(StorageKeys.notificationEnabled) ?? true;
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
}
