import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_tracker/core/localization/app_localizations.dart';
import 'package:task_tracker/core/services/notification_service.dart';

import '../../../core/routes/app_routes.dart';
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

  @override
  void initState() {
    super.initState();
    _loadNotificationPref();
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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final themeProvider = context.watch<ThemeProvider>();
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
                        await NotificationService.setNotificationEnabled(value);
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
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.error.withValues(alpha: 0.3),
              ),
            ),
            child: ListTile(
              leading: Icon(
                Icons.delete_forever_rounded,
                color: theme.colorScheme.error,
              ),
              title: Text(
                loc?.translate('delete_all_tasks') ?? 'Delete All Tasks',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              onTap: () => _handleDeleteAllTasks(context, loc),
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
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc?.translate('delete_all_tasks') ?? 'Delete All Tasks'),
        content: Text(
          loc?.translate('delete_all_tasks_confirm') ??
              'Are you sure you want to delete all tasks? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(loc?.translate('cancel') ?? 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              loc?.translate('delete') ?? 'Delete',
              style: TextStyle(color: theme.colorScheme.onError),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final taskProvider = context.read<TaskProvider>();
      final authProvider = context.read<AuthProvider>();
      await taskProvider.deleteAllTasks();
      // Add a method to reset streak in authProvider when tasks are cleared
      await authProvider.resetStreak();
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

  Future<void> _handleLogout(BuildContext context) async {
    try {
      final authProvider = context.read<AuthProvider>();
      final taskProvider = context.read<TaskProvider>();
      taskProvider.reset();
      await authProvider.logout();
    } catch (e) {
      debugPrint('Logout error: $e');
    }
    if (context.mounted) {
      AppRoutes.navigateAndRemoveUntil(context, AppRoutes.login);
    }
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
        Icon(icon, size: 20, color: theme.colorScheme.primary),
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
