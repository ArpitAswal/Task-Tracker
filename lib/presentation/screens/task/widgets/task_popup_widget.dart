import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:task_tracker/core/localization/app_localizations.dart';
import '../../../../core/constants/enums.dart';
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
  late TaskPriority _priority;
  late TaskCategory _category;

  AppLocalizations? get l10n => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title);
    _descriptionController = TextEditingController(text: task?.description);
    _selectedDate = task?.endDate ?? DateTime.now();
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

    return valid;
  }

  Future<void> _submit() async {
    if (!_validate()) return;

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
        priority: _priority,
        category: _category,
      );

      operation = widget.provider.updateTask(updatedTask: updatedTask);
    } else {
      operation = widget.provider.createTask(
        title: title,
        description: description,
        endDate: _selectedDate,
        priority: _priority,
        category: _category,
      );
    }

    final success = await context.withLoading(
      message: isEditing
          ? (l10n?.translate('updating_task') ?? 'Updating Task...')
          : (l10n?.translate('creating_task') ?? 'Creating Task...'),
      future: operation,
    );

    if (!mounted) return;

    if (success) {
      context.showSuccessToast(isEditing ? 'task_update' : 'task_create');
      Navigator.of(context).pop();
    } else {
      debugPrint("# AppError:---> ${widget.provider.errorMessage}");
      context.showErrorToast(widget.provider.errorMessage ?? '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lineColor = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ).copyWith(bottom: MediaQuery.of(context).viewInsets.bottom),
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
              onPick: (d) => setState(() => _selectedDate = d),
            ),

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
            color: Theme.of(context).primaryColor,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
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
      subtitle: Text(DateFormat('MMM dd, yyyy').format(date)),
      trailing: Icon(
        Icons.calendar_today,
        color: Theme.of(context).primaryColor,
      ),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) onPick(picked);
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
          child: OutlinedButton(onPressed: onCancel, child: Text(cancelLabel!)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(onPressed: onSubmit, child: Text(confirmLabel)),
        ),
      ],
    );
  }
}
