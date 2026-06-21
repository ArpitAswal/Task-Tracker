import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_tracker/core/localization/app_localizations.dart';
import 'package:task_tracker/core/services/battery_optimization_service.dart';
import 'package:task_tracker/core/services/device_settings_service.dart';
import 'package:task_tracker/core/services/notification_service.dart';
import 'package:task_tracker/core/services/storage_service.dart';
import 'package:task_tracker/core/constants/app_constants.dart';
import 'package:task_tracker/core/utils/extensions/widget_extensions.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/extensions/context_extension.dart';
import '../../../core/utils/loading_overlay.dart';
import '../../../core/utils/message_utils.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/locale_provider.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen>
    with WidgetsBindingObserver {
  // App-internal task reminder preference (User's choice in the app)
  final ValueNotifier<bool> _notificationsEnabled = ValueNotifier(true);
  final ValueNotifier<bool> _isLoadingNotifPref = ValueNotifier(true);

  // OS-level Notification Access (Whether the device allows notifications for this app)
  final ValueNotifier<bool> _systemNotificationsEnabled = ValueNotifier(false);
  final ValueNotifier<bool> _isLoadingSystemNotifications = ValueNotifier(true);

  // OS-level Battery Optimization (Whether the device restricts background execution for this app)
  final ValueNotifier<bool?> _batteryOptimizationDisabled = ValueNotifier(null);
  final ValueNotifier<bool> _isLoadingBatteryOptimization = ValueNotifier(true);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadNotificationPref();
    _loadSystemNotificationStatus();
    _loadBatteryOptimizationStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _notificationsEnabled.dispose();
    _isLoadingNotifPref.dispose();
    _systemNotificationsEnabled.dispose();
    _isLoadingSystemNotifications.dispose();
    _batteryOptimizationDisabled.dispose();
    _isLoadingBatteryOptimization.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadNotificationPref();
      _loadSystemNotificationStatus();
      _loadBatteryOptimizationStatus();
    }
  }

  // Loads the internal app preference (Task Reminders) - whether the app itself will schedule local notifications.
  Future<void> _loadNotificationPref() async {
    final enabled = await NotificationService.isNotificationEnabled();
    if (mounted) {
      _notificationsEnabled.value = enabled;
      _isLoadingNotifPref.value = false;
    }
  }

  // Loads the actual OS-level notification permission status (Notification Access)
  // This tells us if the user has allowed notifications for this app in Android/iOS Settings.
  Future<void> _loadSystemNotificationStatus() async {
    final enabled = await NotificationService.areSystemNotificationsEnabled();
    final storage = StorageService();
    final wasEnabled = storage.readBool(StorageKeys.systemNotificationsEnabled);
    final isPendingCheck = storage.readBool(StorageKeys.pendingNotificationCheck) ?? false;

    if (mounted) {
      _systemNotificationsEnabled.value = enabled;
      _isLoadingSystemNotifications.value = false;

      if (isPendingCheck && wasEnabled != null && wasEnabled != enabled) {
        final toastKey = enabled
            ? 'notification_access_activated'
            : 'notification_access_deactivated';
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.showSuccessToast(toastKey);
          }
        });
      }
    }

    // Always update the stored value to keep it synced.
    await storage.saveBool(StorageKeys.systemNotificationsEnabled, enabled);
    if (isPendingCheck) {
      await storage.remove(StorageKeys.pendingNotificationCheck);
    }
  }

  // Loads the OS-level battery optimization status for this app.
  // This tells us if Android restricts background execution, which could delay our scheduled task reminders.
  Future<void> _loadBatteryOptimizationStatus() async {
    final status = await BatteryOptimizationService.isIgnoringBatteryOptimizations();
    final storage = StorageService();
    final isPendingCheck = storage.readBool(StorageKeys.pendingBatteryCheck) ?? false;
    final lastStatus = storage.readBool('lastBatteryStatus');

    if (mounted) {
      final oldStatus = _batteryOptimizationDisabled.value ?? lastStatus;
      _batteryOptimizationDisabled.value = status;
      _isLoadingBatteryOptimization.value = false;

      // Show toast if status has changed (e.g. when returning from settings)
      if (isPendingCheck && oldStatus != null && oldStatus != status) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            if (status == true) {
              // Optimization is disabled/whitelisted
              context.showSuccessToast('battery_optimization_deactivated');
            } else {
              // Optimization is active
              context.showSuccessToast('battery_optimization_activated');
            }
          }
        });
      }
    }

    if (isPendingCheck) {
      await storage.remove(StorageKeys.pendingBatteryCheck);
      await storage.remove('lastBatteryStatus');
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final taskProvider = context.read<TaskProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // ============================
          // APPEARANCE SECTION
          // ============================
          _SectionHeader(
            title: loc?.translate('appearance') ?? 'Appearance',
            icon: Icons.palette_outlined,
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.dividerColor.withValues(alpha: 0.3),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: Icon(
                  themeProvider.isDarkMode
                      ? Icons.dark_mode_rounded
                      : themeProvider.isLightMode
                      ? Icons.light_mode_rounded
                      : Icons.brightness_auto_rounded,
                  color: theme.colorScheme.primary,
                ),
                title: Text(
                  loc?.translate('theme') ?? 'Theme',
                  style: theme.textTheme.titleMedium,
                ),
                subtitle: Text(
                  _getThemeLabel(themeProvider.themeMode, loc),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: SegmentedButton<ThemeMode>(
                  segments: [
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: const Icon(Icons.brightness_auto, size: 18),
                      tooltip: loc?.translate('system_theme') ?? 'System',
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: const Icon(Icons.light_mode, size: 18),
                      tooltip: loc?.translate('light_theme') ?? 'Light',
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: const Icon(Icons.dark_mode, size: 18),
                      tooltip: loc?.translate('dark_theme') ?? 'Dark',
                    ),
                  ],
                  selected: {themeProvider.themeMode},
                  onSelectionChanged: (selected) {
                    themeProvider.setThemeMode(selected.first);
                  },
                  showSelectedIcon: false,
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          AnimatedBuilder(
            animation: Listenable.merge([
              _systemNotificationsEnabled,
              _isLoadingSystemNotifications,
            ]),
            builder: (context, _) {
              final sysNotifEnabled = _systemNotificationsEnabled.value;
              final isLoadingSysNotif = _isLoadingSystemNotifications.value;
              
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.3),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        sysNotifEnabled
                            ? Icons.notifications_rounded
                            : Icons.notifications_paused_rounded,
                        color: sysNotifEnabled
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              loc?.translate('notification_access') ??
                                  'Notification Access',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isLoadingSysNotif
                                  ? (loc?.translate('notification_access') ??
                                        'Notification Access')
                                  : sysNotifEnabled
                                  ? (loc?.translate(
                                          'notification_access_enabled',
                                        ) ??
                                        'Notifications are allowed for this device')
                                  : (loc?.translate(
                                          'notification_access_disabled',
                                        ) ??
                                        'Notifications are blocked. Open system settings to enable them'),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () async {
                          final storage = StorageService();
                          await storage.saveBool(StorageKeys.pendingNotificationCheck, true);
                          await DeviceSettingsService.openNotificationSettings();
                          // The change will be picked up by didChangeAppLifecycleState when resuming
                        },
                        child: Icon(
                          Icons.open_in_new_rounded,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.dividerColor.withValues(alpha: 0.3),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Consumer<LocaleProvider>(
                builder: (context, localeProvider, child) {
                  return ListTile(
                    leading: Icon(
                      Icons.language_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(
                      loc?.translate('language') ?? 'Language',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      localeProvider.currentLocaleName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    trailing: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'en', label: Text('EN')),
                        ButtonSegment(value: 'hi', label: Text('HI')),
                      ],
                      selected: {localeProvider.locale.languageCode},
                      onSelectionChanged: (selected) {
                        final code = selected.first;
                        if (code == 'en') {
                          localeProvider.setEnglish();
                        } else {
                          localeProvider.setHindi();
                        }
                      },
                      showSelectedIcon: false,
                      style: const ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ============================
          // NOTIFICATIONS SECTION
          // ============================
          _SectionHeader(
            title: loc?.translate('notifications') ?? 'Notifications',
            icon: Icons.notifications_outlined,
          ),
          const SizedBox(height: 8),
          
          AnimatedBuilder(
            animation: Listenable.merge([
              _notificationsEnabled,
              _isLoadingNotifPref,
            ]),
            builder: (context, _) {
              final notifEnabled = _notificationsEnabled.value;
              final isLoadingNotif = _isLoadingNotifPref.value;
              
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.3),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        notifEnabled
                            ? Icons.notifications_active_rounded
                            : Icons.notifications_off_rounded,
                        color: notifEnabled
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              loc?.translate('task_reminders') ?? 'Task Reminders',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notifEnabled
                                  ? (loc?.translate('reminders_on_desc') ??
                                        'Get reminded 1 hour before tasks are due')
                                  : (loc?.translate('reminders_off_desc') ??
                                        'No task reminder notifications'),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Switch.adaptive(
                        value: isLoadingNotif ? true : notifEnabled,
                        onChanged: isLoadingNotif
                            ? null
                            : (value) async {
                                final newTargetState = value;
                                final titleKey = newTargetState
                                    ? 'task_reminders_dialog_title_enable'
                                    : 'task_reminders_dialog_title_disable';
                                final messageKey = newTargetState
                                    ? 'task_reminders_dialog_message_enable'
                                    : 'task_reminders_dialog_message_disable';

                                final confirmed = await context
                                    .showCustomConfirmDialog(
                                      title:
                                          loc?.translate(titleKey) ??
                                          (newTargetState
                                              ? 'Enable Task Reminders?'
                                              : 'Disable Task Reminders?'),
                                      message: loc?.translate(messageKey) ?? '',
                                      icon: newTargetState
                                          ? Icons.notifications_active_rounded
                                          : Icons.notifications_off_rounded,
                                      iconColor: newTargetState
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.error,
                                    );

                                if (confirmed == true && context.mounted) {
                                  _notificationsEnabled.value = newTargetState;
                                  await taskProvider.updateNotificationPreference(
                                    newTargetState,
                                  );
                                  if (context.mounted) {
                                    final toastKey = newTargetState
                                        ? 'task_reminders_activated'
                                        : 'task_reminders_deactivated';
                                    context.showSuccessToast(toastKey);
                                  }
                                }
                              },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          AnimatedBuilder(
            animation: Listenable.merge([
              _batteryOptimizationDisabled,
              _isLoadingBatteryOptimization,
            ]),
            builder: (context, _) {
              final batteryDisabled = _batteryOptimizationDisabled.value;
              final isLoadingBattery = _isLoadingBatteryOptimization.value;
              
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.3),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        !(batteryDisabled ?? false)
                            ? Icons.battery_alert_outlined
                            : Icons.battery_saver_outlined,
                        color: !(batteryDisabled ?? false)
                            ? theme.colorScheme.onSurfaceVariant
                            : theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              loc?.translate('battery_optimization') ??
                                  'Battery Optimization',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _batteryOptimizationSubtitle(isLoadingBattery, batteryDisabled, loc),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Switch.adaptive(
                        value: !(batteryDisabled ?? false),
                        onChanged:
                            isLoadingBattery ||
                                batteryDisabled == null
                            ? null
                            : (value) async {
                                final newTargetActive = value;

                                final titleKey = newTargetActive
                                    ? 'battery_optimization_dialog_title_enable'
                                    : 'battery_optimization_dialog_title_disable';
                                final messageKey = newTargetActive
                                    ? 'battery_optimization_dialog_message_enable'
                                    : 'battery_optimization_dialog_message_disable';

                                final confirmed = await context
                                    .showCustomConfirmDialog(
                                      title:
                                          loc?.translate(titleKey) ??
                                          (newTargetActive
                                              ? 'Enable Battery Optimization?'
                                              : 'Disable Battery Optimization?'),
                                      message: loc?.translate(messageKey) ?? '',
                                      icon: newTargetActive
                                          ? Icons.battery_alert_outlined
                                          : Icons.battery_saver_outlined,
                                      iconColor: newTargetActive
                                          ? theme.colorScheme.error
                                          : theme.colorScheme.primary,
                                    );

                                if (confirmed == true && context.mounted) {
                                  final storage = StorageService();
                                  await storage.saveBool(StorageKeys.pendingBatteryCheck, true);
                                  await storage.saveBool('lastBatteryStatus', batteryDisabled ?? false);

                                  await BatteryOptimizationService.openSettings(
                                    requestIgnore: !newTargetActive,
                                  );
                                  // The change will be picked up by didChangeAppLifecycleState when resuming
                                }
                              },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // ============================
          // DATA MANAGEMENT SECTION
          // ============================
          _SectionHeader(
            title: loc?.translate('data_management') ?? 'Data Management',
            icon: Icons.storage_rounded,
          ),
          const SizedBox(height: 8),
          Card(
            child: context.themedOutlinedButton(
              label: loc?.translate('delete_all_tasks') ?? 'Delete All Tasks',
              onPressed: () => _handleDeleteAllTasks(context, loc),
              color: AppColors.error,
              icon: Icons.delete_outline_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDeleteAllTasks(
    BuildContext context,
    AppLocalizations? loc,
  ) async {
    final confirmed = await context.showAlertDialog(
      title: loc?.translate('delete_all_tasks') ?? 'Delete All Tasks',
      message:
          loc?.translate('delete_all_tasks_confirm') ??
          'Are you sure you want to delete all tasks? This action cannot be undone.',
      confirmText: loc?.translate('delete') ?? 'Delete',
      cancelText: loc?.translate('cancel') ?? 'Cancel',
    );

    if (confirmed == true && context.mounted) {
      final taskProvider = context.read<TaskProvider>();
      final authProvider = context.read<AuthProvider>();

      await context.withLoading(
        message:
            loc?.translate('deleting_all_tasks') ?? 'Deleting all tasks...',
        future: Future.wait([
          taskProvider.deleteAllTasks(),
          authProvider.resetStreak(),
        ]),
      );

      if (context.mounted) {
        context.showSuccessToast('all_tasks_deleted');
      }
    }
  }

  String _getThemeLabel(ThemeMode mode, AppLocalizations? loc) {
    switch (mode) {
      case ThemeMode.system:
        return loc?.translate('system_theme') ?? 'System default';
      case ThemeMode.light:
        return loc?.translate('light_theme') ?? 'Light';
      case ThemeMode.dark:
        return loc?.translate('dark_theme') ?? 'Dark';
    }
  }

  String _batteryOptimizationSubtitle(bool isLoading, bool? disabled, AppLocalizations? loc) {
    if (isLoading) {
      return loc?.translate('battery_optimization') ?? 'Battery Optimization';
    }

    if (disabled == null) {
      return loc?.translate('battery_optimization_unavailable') ??
          'Battery optimization controls are only available on Android';
    }

    if (disabled == true) {
      return loc?.translate('battery_optimization_disabled') ??
          'Battery optimization is disabled for this app';
    }

    return loc?.translate('battery_optimization_enabled') ??
        'Battery optimization is active and may delay reminders';
  }
}

/// Reusable section header for settings groups
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
