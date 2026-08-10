import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository.dart';
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

    // Local notifications must use the device timezone so reminder times match
    // the user's actual local clock after restarts and travel.
    tz.initializeTimeZones();
    _timezone = await FlutterTimezone.getLocalTimezone();
    _availableTimezones = await FlutterTimezone.getAvailableTimezones();
    _availableTimezones.sort((a, b) => a.identifier.compareTo(b.identifier));
    tz.setLocalLocation(tz.getLocation(_timezone?.identifier ?? 'Unknown'));

    // Android init settings
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS / macOS init settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);


    _initialized = true;
    debugPrint('🔔 NotificationService initialized');
  }

  /// Schedule a reminder notification for a task at its `reminderAt` time.
  ///
  /// Skips scheduling if:
  /// - Notifications are globally disabled
  /// - The task has no reminder (`hasReminder == false`)
  /// - The scheduled time is already in the past
  static Future<void> scheduleTaskReminder(TaskModel task) async {
    // Check global toggle
    if (!await isNotificationEnabled()) return;
    // Skip scheduling if the OS itself has notifications blocked.
    if (!await areSystemNotificationsEnabled()) return;

    // Check per-task reminder
    if (!task.hasReminder) return;
    
    final reminderTime = task.reminderAt!;
    final now = DateTime.now();

    if (reminderTime.isBefore(now)) return;

    final loc = await _getLocalizations();

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
      final tzTime = tz.TZDateTime.from(reminderTime, tz.local);
      
      // Build a friendly "due in ..." message from reminder time to task end.
      final difference = task.endDate.difference(reminderTime);
      String timeLeftStr;
      
      if (difference.inDays > 0) {
        timeLeftStr = '${difference.inDays} ${loc.translate('days_streak')}';
      } else if (difference.inHours > 0) {
        final remainingMins = difference.inMinutes % 60;
        if (remainingMins > 0) {
          timeLeftStr = '${difference.inHours}hr ${remainingMins}m';
        } else {
          timeLeftStr = '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'}';
        }
      } else {
        timeLeftStr = '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'}';
      }

      await _notifications.zonedSchedule(
        task.id.hashCode,
        loc.translate('notification_task_reminder'),
        loc.translate('notification_task_due_in_time')
            .replaceAll('{taskTitle}', task.title)
            .replaceAll('{timeLeft}', timeLeftStr),
        tzTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: null,
      );
      debugPrint(
          '🔔 Scheduled reminder for "${task.title}" at $reminderTime');
          
      // Schedule end time notification
      if (task.endDate.isAfter(now)) {
        final tzEndTime = tz.TZDateTime.from(task.endDate, tz.local);
        await _notifications.zonedSchedule(
          task.id.hashCode + 1,
          loc.translate('notification_task_ended'),
          loc.translate('notification_task_ended_msg')
              .replaceAll('{taskTitle}', task.title),
          tzEndTime,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: null,
        );
        debugPrint(
            '🔔 Scheduled end timeframe notification for "${task.title}" at ${task.endDate}');
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
  /// Returns `true` if enabled, `false` if user disabled them
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

  static Future<bool> areSystemNotificationsEnabled() async {
    if (Platform.isAndroid) {
      // Android exposes whether app notifications are allowed at the OS level.
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      return await androidPlugin?.areNotificationsEnabled() ?? false;
    }

    if (Platform.isIOS) {
      // iOS returns a richer permission object; we only need the main enabled
      // flag to decide whether reminders can be shown.
      final iosPlugin = _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      final permissions = await iosPlugin?.checkPermissions();
      return permissions?.isEnabled ?? false;
    }

    return true;
  }

  static Future<bool> requestNotificationPermissionsIfNeeded() async {
    if (await areSystemNotificationsEnabled()) {
      return true;
    }

    if (Platform.isAndroid) {
      // Android can show the runtime notification permission prompt directly.
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final granted = await androidPlugin?.requestNotificationsPermission();
      return granted ?? false;
    }

    if (Platform.isIOS) {
      // iOS needs an explicit alert/sound/badge permission request.
      final iosPlugin = _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      final granted = await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  /// Re-schedule active reminders for the current user after notifications
  /// are enabled again or after app recovery flows.
  static Future<void> rescheduleActiveRemindersForCurrentUser() async {
    final repository = TaskRepository();
    final tasks = await repository.getAllTasksForCurrentUser();

    for (final task in tasks) {
      final shouldSchedule =
          !task.isCompleted &&
          task.hasReminder &&
          task.reminderAt != null &&
          task.reminderAt!.isAfter(DateTime.now());

      if (shouldSchedule) {
        await scheduleTaskReminder(task);
      } else {
        await cancelTaskReminder(task.id);
      }
    }
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
    if (!await areSystemNotificationsEnabled()) return;

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
      int overdue = overdueTasks.length;
      await _notifications.show(
        _overdueNotificationId,
        loc.translate('notification_overdue_title'),
        loc.translate('notification_overdue_msg')
            .replaceAll('{count}', overdue.toString()).replaceAll('{task}', (overdue > 1) ? loc.translate('tasks') : loc.translate('task')),
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
