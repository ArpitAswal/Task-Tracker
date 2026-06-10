import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_tracker/core/localization/app_localizations.dart';
import 'package:task_tracker/core/services/battery_optimization_service.dart';
import 'package:task_tracker/core/services/device_settings_service.dart';
import 'package:task_tracker/core/services/notification_service.dart';
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

class _SettingScreenState extends State<SettingScreen> {
  bool _notificationsEnabled = true;
  bool _isLoadingNotifPref = true;
  bool _systemNotificationsEnabled = false;
  bool _isLoadingSystemNotifications = true;
  bool? _batteryOptimizationDisabled;
  bool _isLoadingBatteryOptimization = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationPref();
    _loadSystemNotificationStatus();
    _loadBatteryOptimizationStatus();
  }

  Future<void> _loadNotificationPref() async {
    final enabled = await NotificationService.isNotificationEnabled();
    if (mounted) {
      setState(() {
        _notificationsEnabled = enabled;
        _isLoadingNotifPref = false;
      });
    }
  }

  Future<void> _loadSystemNotificationStatus() async {
    // Keep the Settings UI aligned with the real OS permission state.
    final enabled = await NotificationService.areSystemNotificationsEnabled();
    if (mounted) {
      setState(() {
        _systemNotificationsEnabled = enabled;
        _isLoadingSystemNotifications = false;
      });
    }
  }

  Future<void> _loadBatteryOptimizationStatus() async {
    final status =
        await BatteryOptimizationService.isIgnoringBatteryOptimizations();
    if (mounted) {
      setState(() {
        _batteryOptimizationDisabled = status;
        _isLoadingBatteryOptimization = false;
      });
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

          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.dividerColor.withValues(alpha: 0.3),
              ),
            ),
            child: ListTile(
              leading: Icon(
                _systemNotificationsEnabled
                    ? Icons.notifications_rounded
                    : Icons.notifications_paused_rounded,
                color: _systemNotificationsEnabled
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              title: Text(
                loc?.translate('notification_access') ??
                    'Notification Access',
                style: theme.textTheme.titleMedium,
              ),
              subtitle: Text(
                _isLoadingSystemNotifications
                    ? (loc?.translate('notification_access') ??
                        'Notification Access')
                    : _systemNotificationsEnabled
                    ? (loc?.translate('notification_access_enabled') ??
                        'Notifications are allowed for this device')
                    : (loc?.translate('notification_access_disabled') ??
                        'Notifications are blocked. Open system settings to enable them'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: Icon(
                Icons.open_in_new_rounded,
                color: theme.colorScheme.primary,
              ),
              onTap: () async {
                // The app cannot toggle OS notification permission itself, so
                // this opens the platform settings page and then refreshes.
                await DeviceSettingsService.openNotificationSettings();
                await _loadSystemNotificationStatus();
              },
            ),
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
                      style: theme.textTheme.titleMedium,
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
              child: SwitchListTile.adaptive(
                secondary: Icon(
                  _notificationsEnabled
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_off_rounded,
                  color: _notificationsEnabled
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                title: Text(
                  loc?.translate('task_reminders') ?? 'Task Reminders',
                  style: theme.textTheme.titleMedium,
                ),
                subtitle: Text(
                  _notificationsEnabled
                      ? (loc?.translate('reminders_on_desc') ??
                            'Get reminded 1 hour before tasks are due')
                      : (loc?.translate('reminders_off_desc') ??
                            'No task reminder notifications'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                value: _isLoadingNotifPref ? true : _notificationsEnabled,
                onChanged: _isLoadingNotifPref
                    ? null
                    : (value) async {
                        setState(() => _notificationsEnabled = value);
                        await taskProvider.updateNotificationPreference(value);
                      },
              ),
            ),
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
              child: SwitchListTile.adaptive(
                secondary: Icon(
                  (_batteryOptimizationDisabled ?? false)
                      ? Icons.battery_saver_outlined
                      : Icons.battery_alert_outlined,
                  color: (_batteryOptimizationDisabled ?? false)
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                title: Text(
                  loc?.translate('battery_optimization') ??
                      'Battery Optimization',
                  style: theme.textTheme.titleMedium,
                ),
                subtitle: Text(
                  _batteryOptimizationSubtitle(loc),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                value: _batteryOptimizationDisabled ?? false,
                onChanged: _isLoadingBatteryOptimization ||
                        _batteryOptimizationDisabled == null
                    ? null
                    : (_) async {
                        // Android owns this setting, so we deep-link to system
                        // settings and refresh the visible status afterward.
                        await BatteryOptimizationService.openSettings(
                          requestIgnore:
                              !(_batteryOptimizationDisabled ?? false),
                        );
                        await _loadBatteryOptimizationStatus();
                      },
              ),
            ),
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
              icon: Icons.delete_outline_outlined
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
        message: loc?.translate('deleting_all_tasks') ?? 'Deleting all tasks...',
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

  String _batteryOptimizationSubtitle(AppLocalizations? loc) {
    if (_isLoadingBatteryOptimization) {
      return loc?.translate('battery_optimization') ?? 'Battery Optimization';
    }

    if (_batteryOptimizationDisabled == null) {
      return loc?.translate('battery_optimization_unavailable') ??
          'Battery optimization controls are only available on Android';
    }

    if (_batteryOptimizationDisabled == true) {
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
