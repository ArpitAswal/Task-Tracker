import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:task_tracker/core/localization/app_localizations.dart';
import 'package:task_tracker/core/services/device_settings_service.dart';
import 'package:task_tracker/core/services/notification_service.dart';
import 'package:task_tracker/core/utils/extensions/context_extension.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/utils/extensions/widget_extensions.dart';
import '../../../../core/utils/loading_overlay.dart';
import '../../../../core/utils/message_utils.dart';
import '../../../../data/models/task_model.dart';
import '../../../providers/task_provider.dart';

class AddTaskSheet extends StatefulWidget {
  final String popupTitle;
  final TaskModel? task;

  /// ✨ Optional task for editing
  final TaskProvider provider;

  const AddTaskSheet({
    super.key,
    required this.popupTitle,
    required this.provider,
    this.task,
  });

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  late DateTime _selectedDate;
  late DateTime _reminderAt;
  late TaskPriority _priority;
  late TaskCategory _category;

  AppLocalizations? get l10n => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title);
    _descriptionController = TextEditingController(text: task?.description);

    final now = DateTime.now();
    _selectedDate = task?.endDate ?? now.add(const Duration(days: 1));
    _reminderAt =
        task?.reminderAt ?? _selectedDate.subtract(const Duration(hours: 1));

    _priority = task?.priority ?? TaskPriority.medium;
    _category = task?.category ?? TaskCategory.other;

    context.read<TaskProvider>().clearError();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool _validate() {
    widget.provider.clearError();

    bool valid = true;

    if (_titleController.text.trim().isEmpty) {
      widget.provider.setTitleError(l10n?.titleIsRequired ?? "");
      valid = false;
    } else {
      widget.provider.setTitleError("");
    }

    if (_descriptionController.text.trim().isEmpty) {
      widget.provider.setDescriptionError(l10n?.descriptionIsRequired ?? "");
      valid = false;
    } else {
      widget.provider.setDescriptionError("");
    }

    final now = DateTime.now();
    if (_selectedDate.isBefore(now)) {
      context.showErrorToast(
        l10n?.translate('date_passed') ??
            "Selected date & time are already passed",
      );
      valid = false;
    } else if (_reminderAt.isBefore(now)) {
      context.showErrorToast(
        l10n?.translate('reminder_passed') ?? "Reminder time passed",
      );
      valid = false;
    } else if (_selectedDate.difference(_reminderAt).inMinutes < 10) {
      context.showErrorToast(
        l10n?.translate('reminder_gap') ??
            "Reminder time must be at least 10 minutes before task finish time",
      );
      valid = false;
    }

    return valid;
  }

  Future<void> _submit() async {
    if (!_validate()) return;

    // Before saving a reminder, warn the user about any OS-level blockers that
    // could make the notification look "broken" later.
    await _prepareReminderReliabilityChecks();
    if (!mounted) return;

    final isEditing = widget.task != null;
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    final Future<bool> operation;
    Navigator.of(context).pop();
    if (isEditing) {
      // Create updated task copy
      final updatedTask = widget.task!.copyWith(
        title: title,
        description: description,
        endDate: _selectedDate,
        reminderAt: _reminderAt,
        priority: _priority,
        category: _category,
      );

      operation = widget.provider.updateTask(updatedTask: updatedTask);
    } else {
      operation = widget.provider.createTask(
        title: title,
        description: description,
        endDate: _selectedDate,
        reminderAt: _reminderAt,
        priority: _priority,
        category: _category,
      );
    }

    final success = await context.withLoading(
      message: isEditing
          ? (l10n?.translate('updating_task') ?? 'Updating Task...')
          : (l10n?.translate('creating_task') ?? 'Creating Task...'),
      future: Future.delayed(const Duration(seconds: 1), () => operation),
    );

    if (!mounted) return;

    if (success) {
      context.showSuccessToast(isEditing ? 'task_update' : 'task_create');
    } else {
      debugPrint("# AppError:---> ${widget.provider.errorMessage}");
      context.showErrorToast(widget.provider.errorMessage ?? '');
    }
  }

  Future<void> _prepareReminderReliabilityChecks() async {
    // First verify notification permission, because without it no reminder can
    // be shown on either Android or iOS.
    final notificationsEnabled =
        await NotificationService.requestNotificationPermissionsIfNeeded();
    if (!mounted) return;

    if (!notificationsEnabled) {
      final openSettings = await context.showAlertDialog(
        title:
            l10n?.translate('notification_permission_title') ??
            'Allow Notifications',
        message:
            l10n?.translate('notification_permission_message') ??
            'Task reminders need notification access. You can still save the task, but reminders will not appear until notifications are enabled.',
        confirmText: l10n?.translate('open_settings') ?? 'Open Settings',
        cancelText: l10n?.translate('later') ?? 'Later',
      );

      if (openSettings == true) {
        await DeviceSettingsService.openNotificationSettings();
      }
    }

    // Battery optimization is only meaningful on Android. When active, it may
    // delay reminders even if notification permission is already granted.
    final batteryOptimizationDisabled =
        await DeviceSettingsService.isIgnoringBatteryOptimizations();
    if (!mounted || batteryOptimizationDisabled != false) return;

    final openSettings = await context.showAlertDialog(
      title:
          l10n?.translate('battery_optimization_warning_title') ??
          'Battery Optimization Active',
      message:
          l10n?.translate('battery_optimization_warning_message') ??
          'Battery optimization may delay task reminders on some Android devices. You can still save the task now and whitelist the app for more reliable alerts.',
      confirmText: l10n?.translate('open_settings') ?? 'Open Settings',
      cancelText: l10n?.translate('later') ?? 'Later',
    );

    if (openSettings == true) {
      await DeviceSettingsService.openBatteryOptimizationSettings(
        requestIgnore: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lineColor = theme.colorScheme.primary;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: context.isTablet
            ? 16
            : MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            _Header(title: widget.popupTitle, color: lineColor),
            const SizedBox(height: 12),

            Consumer<TaskProvider>(
              builder: (_, provider, __) {
                return _TaskTextField(
                  controller: _titleController,
                  label: l10n?.taskTitleLabel ?? "Task Label",
                  error: provider.titleError,
                  maxLength: 20,
                );
              },
            ),

            const SizedBox(height: 12),

            Consumer<TaskProvider>(
              builder: (_, provider, __) {
                return _TaskTextField(
                  controller: _descriptionController,
                  label: l10n?.taskDescriptionLabel ?? "Description Label",
                  error: provider.descriptionError,
                  maxLength: 60,
                );
              },
            ),

            const SizedBox(height: 12),
            _PriorityDropdown(
              value: _priority,
              onChanged: (v) => setState(() => _priority = v),
            ),

            const SizedBox(height: 12),
            _CategoryDropdown(
              value: _category,
              onChanged: (v) => setState(() => _category = v),
            ),

            const SizedBox(height: 8),

            _DatePickerTile(
              date: _selectedDate,
              onPick: (d) => setState(() {
                _selectedDate = d;
                _reminderAt = _selectedDate.subtract(const Duration(hours: 1));
              }),
            ),

            if (_selectedDate.year == DateTime.now().year &&
                _selectedDate.month == DateTime.now().month &&
                _selectedDate.day == DateTime.now().day) ...[
              const SizedBox(height: 8),
              _TimePickerTile(
                title: l10n?.translate('finish_time') ?? 'End Of Task Time',
                time: TimeOfDay.fromDateTime(_selectedDate),
                onPick: (t) => setState(() {
                  _selectedDate = DateTime(
                    _selectedDate.year,
                    _selectedDate.month,
                    _selectedDate.day,
                    t.hour,
                    t.minute,
                  );
                }),
              ),
              const SizedBox(height: 8),
              _TimePickerTile(
                title:
                    l10n?.translate('reminder_time') ?? 'RTask Reminder Time',
                time: TimeOfDay.fromDateTime(_reminderAt),
                onPick: (t) => setState(() {
                  _reminderAt = DateTime(
                    _selectedDate.year,
                    _selectedDate.month,
                    _selectedDate.day,
                    t.hour,
                    t.minute,
                  );
                }),
              ),
            ],

            const SizedBox(height: 12),

            _FooterButtons(
              onCancel: () {
                widget.provider.clearError();
                Navigator.pop(context);
              },
              onSubmit: _submit,
              cancelLabel: l10n?.translate('cancel'),
              confirmLabel: (widget.task != null)
                  ? (l10n?.translate('update') ?? 'Update')
                  : (l10n?.translate('create') ?? 'Create'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _TaskTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String error;
  final int maxLength;

  const _TaskTextField({
    required this.controller,
    required this.label,
    required this.error,
    required this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLength: maxLength,
      textCapitalization: TextCapitalization.sentences,
      cursorColor: Theme.of(context).colorScheme.primary,
      style: Theme.of(
        context,
      ).textTheme.labelLarge?.copyWith(color: Theme.of(context).primaryColor),
      decoration: InputDecoration(
        labelText: label,
        errorText: error.isEmpty ? null : error,
        counterStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: context.colorScheme.primary,
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: context.colorScheme.primary,
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: context.colorScheme.primary,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final Color color;

  const _Header({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(
      context,
    ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold, color: color);

    return Row(
      children: [
        Expanded(child: Divider(color: color)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(title, style: style),
        ),
        Expanded(child: Divider(color: color)),
      ],
    );
  }
}

class _PriorityDropdown extends StatelessWidget {
  final TaskPriority value;
  final ValueChanged<TaskPriority> onChanged;

  const _PriorityDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DropdownButtonFormField<TaskPriority>(
      initialValue: value,
      decoration: InputDecoration(labelText: l10n.priority),
      dropdownColor: context.theme.cardTheme.color,
      isDense: true,
      isExpanded: true,
      items: TaskPriority.values.map((p) {
        return DropdownMenuItem(
          value: p,
          child: Row(
            children: [
              Icon(
                Icons.flag,
                size: 18,
                color: p == TaskPriority.high
                    ? Colors.red
                    : p == TaskPriority.medium
                    ? Colors.orange
                    : Colors.green,
              ),
              const SizedBox(width: 8),
              Text(_priorityLabel(p, l10n)),
            ],
          ),
        );
      }).toList(),
      onChanged: (v) => onChanged(v!),
    );
  }

  String _priorityLabel(TaskPriority p, AppLocalizations l10n) {
    switch (p) {
      case TaskPriority.high:
        return l10n.translate('priorityHigh');
      case TaskPriority.medium:
        return l10n.translate('priorityMedium');
      case TaskPriority.low:
        return l10n.translate('priorityLow');
    }
  }
}

class _CategoryDropdown extends StatelessWidget {
  final TaskCategory value;
  final ValueChanged<TaskCategory> onChanged;

  const _CategoryDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DropdownButtonFormField<TaskCategory>(
      initialValue: value,
      decoration: InputDecoration(labelText: l10n.category),
      dropdownColor: context.theme.cardTheme.color,
      isDense: true,
      isExpanded: true,
      items: TaskCategory.values.map((c) {
        return DropdownMenuItem(
          value: c,
          child: Row(
            children: [
              Icon(
                Icons.flag,
                size: 18,
                color: c == TaskCategory.work
                    ? Colors.red
                    : c == TaskCategory.other
                    ? Colors.orange
                    : Colors.green,
              ),
              const SizedBox(width: 8),
              Text(_categoryLabel(c, l10n)),
            ],
          ),
        );
      }).toList(),
      onChanged: (v) => onChanged(v!),
    );
  }

  String _categoryLabel(TaskCategory c, AppLocalizations l10n) {
    switch (c) {
      case TaskCategory.other:
        return l10n.translate('other');
      case TaskCategory.personal:
        return l10n.translate('personal');
      case TaskCategory.work:
        return l10n.translate('work');
    }
  }
}

class _DatePickerTile extends StatelessWidget {
  final DateTime date;
  final ValueChanged<DateTime> onPick;

  const _DatePickerTile({required this.date, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      title: Text(l10n.dueDate),
      titleTextStyle: context.textTheme.bodyLarge?.copyWith(
        color: context.colorScheme.surface,
      ),
      subtitle: Text(DateFormat('MMM dd, yyyy').format(date)),
      trailing: Icon(
        Icons.calendar_today,
        color: context.colorScheme.primary,
        size: context.isTablet ? 36 : 24,
      ),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (context, child) {
            return Theme(
              data: ThemeData().copyWith(
                colorScheme: (context.isDarkMode)
                    ? ColorScheme.dark(
                        primary: context.theme.colorScheme.secondary,
                        onPrimary: context.theme.colorScheme.onPrimary,
                        onSurface: context.theme.colorScheme.secondary,
                      )
                    : ColorScheme.light(
                        primary: context.theme.colorScheme.secondary,
                        onPrimary: context.theme.colorScheme.onSecondary,
                        onSurface: context.theme.colorScheme.onPrimary,
                      ),
                datePickerTheme: DatePickerThemeData(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      24.0,
                    ), // Adjust to match your buttons
                    side: BorderSide(
                      color: context.colorScheme.primary,
                      width: 2.0,
                    ),
                  ),
                  cancelButtonStyle: context.theme.textButtonTheme.style,
                  confirmButtonStyle: context.theme.textButtonTheme.style,
                ),
              ),
              child: Center(
                // Prevents the picker from stretching to fill the screen
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 600.0, // Forces a mobile-like width on tablets
                    maxHeight: 700.0, // Limits the height to reduce the gap
                  ),
                  child: child!,
                ),
              ),
            );
          },
        );
        if (picked != null) {
          DateTime now = DateTime.now();
          onPick(picked.copyWith(hour: now.hour, minute: now.minute));
        }
      },
    );
  }
}

class _TimePickerTile extends StatelessWidget {
  final String title;
  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onPick;

  const _TimePickerTile({
    required this.title,
    required this.time,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      titleTextStyle: context.textTheme.bodyLarge?.copyWith(
        color: context.colorScheme.surface,
      ),
      subtitle: Text(time.format(context)),
      trailing: Icon(
        Icons.access_time_filled,
        color: context.colorScheme.primary,
        size: context.isTablet ? 36 : 24,
      ),
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
          builder: (context, child) {
            return Theme(
              data: ThemeData().copyWith(
                textTheme: context.textTheme,
                colorScheme: (context.isDarkMode)
                    ? ColorScheme.dark(
                        primary: context.theme.colorScheme.secondary,
                        onPrimary: context.theme.colorScheme.onPrimary,
                        onSurface: context.theme.colorScheme.secondary,
                      )
                    : ColorScheme.light(
                        primary: context.theme.colorScheme.secondary,
                        onPrimary: context.theme.colorScheme.onSecondary,
                        onSurface: context.theme.colorScheme.onPrimary,
                      ),
                datePickerTheme: DatePickerThemeData(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      24.0,
                    ), // Adjust to match your buttons
                    side: BorderSide(
                      color: context.colorScheme.primary,
                      width: 2.0,
                    ),
                  ),
                  cancelButtonStyle: context.theme.textButtonTheme.style,
                  confirmButtonStyle: context.theme.textButtonTheme.style,
                ),
              ),
              child: Center(
                child: Transform.scale(
                  // Scale up by 30% if it's a tablet
                  scale: context.isTablet ? 1.5 : 0.9,
                  child: child!,
                ),
              ),
            );
          },
        );
        if (picked != null) {
          onPick(picked);
        }
      },
    );
  }
}

class _FooterButtons extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSubmit;
  final String confirmLabel;
  final String? cancelLabel;

  const _FooterButtons({
    required this.onCancel,
    required this.onSubmit,
    required this.confirmLabel,
    this.cancelLabel = "Cancel",
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: context.themedOutlinedButton(
            label: cancelLabel!,
            onPressed: onCancel,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: context.themedOutlinedButton(
            label: confirmLabel,
            onPressed: onSubmit,
          ),
        ),
      ],
    );
  }
}
