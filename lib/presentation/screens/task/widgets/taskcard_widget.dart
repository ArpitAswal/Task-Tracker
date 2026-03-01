import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:task_tracker/core/localization/app_localizations.dart';

import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:task_tracker/core/utils/loading_overlay.dart';
import 'package:task_tracker/presentation/screens/task/widgets/task_popup_widget.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions/context_extension.dart';
import '../../../../core/utils/message_utils.dart';
import '../../../../data/models/task_model.dart';
import '../../../providers/task_provider.dart';

Widget buildTaskCard(TaskModel task, BuildContext context) {
  final theme = Theme.of(context);
  final isOverdue = task.endDate.day <= DateTime.now().day && !task.isCompleted;
  final hasDescription = (task.description?.trim().isNotEmpty ?? false);
  final priorityColor = task.priorityColor;
  final categoryColor = task.categoryColor;
  final loc = AppLocalizations.of(context)!;

  final cardGradient = LinearGradient(
    colors: task.isCompleted
        ? [
            AppColors.success.withValues(alpha: 0.1),
            AppColors.white.withValues(alpha: 0.3),
          ]
        : (isOverdue)
        ? [
            AppColors.error.withValues(alpha: 0.1),
            AppColors.white.withValues(alpha: 0.3),
          ]
        : (task.isDueToday)
        ? [
            AppColors.warning.withValues(alpha: 0.1),
            AppColors.white.withValues(alpha: 0.3),
          ]
        : [
            AppColors.info.withValues(alpha: 0.1),
            AppColors.white.withValues(alpha: 0.3),
          ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  final Color statusColor = task.isCompleted
      ? AppColors.success
      : isOverdue
      ? AppColors.error
      : task.isDueToday
      ? AppColors.warning
      : AppColors.info;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 24),
    child: Slidable(
      key: ValueKey(task.id),
      startActionPane: (task.isCompleted)
          ? null
          : ActionPane(
              motion: const ScrollMotion(),
              extentRatio: 0.25,
              children: [
                SlidableAction(
                  onPressed: (context) {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      backgroundColor: Theme.of(
                        context,
                      ).scaffoldBackgroundColor,
                      builder: (context) => AddTaskSheet(
                        popupTitle: loc.translate('edit_task'),
                        provider: context.read<TaskProvider>(),
                        task: task,
                      ),
                    );
                  },
                  backgroundColor: AppColors.warning.withValues(alpha: 0.8),
                  foregroundColor: Colors.white,
                  icon: Icons.edit,
                  label: loc.translate('edit'),
                  autoClose: true,
                  alignment: Alignment.center,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(21),
                  ),
                ),
              ],
            ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (context) => _showDeleteConfirmation(context, task),
            backgroundColor: AppColors.error.withValues(alpha: 0.8),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: loc.translate('delete'),
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(21),
            ),
          ),
        ],
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(21),
          boxShadow: [
            BoxShadow(
              color: statusColor.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(-4, 8),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 360;
            return Material(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(21),
              clipBehavior: Clip.antiAlias,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(21),
                  gradient: cardGradient,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: Checkbox(
                            value: task.isCompleted,
                            side: const BorderSide(
                              width: 1.5,
                              color: AppColors.white,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            autofocus: true,
                            onChanged: (bool? value) {
                              if (value != null) {
                                _taskCompleteConfirmation(context, task);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  task.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: priorityColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.flag_outlined,
                                      size: 14,
                                      color: priorityColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      loc.translate(task.priorityString),
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: priorityColor,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: categoryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.category_outlined,
                                      size: 14,
                                      color: categoryColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      loc.translate(task.categoryString),
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: categoryColor,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (hasDescription) ...[
                      const SizedBox(height: 2),
                      Text(
                        task.description!.trim(),
                        maxLines: compact ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: statusColor.withValues(alpha: 1),
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.info.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.event_rounded,
                                size: 14,
                                color: AppColors.info,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                DateFormat('MMM dd, yyyy').format(
                                  (task.isCompleted)
                                      ? (task.completedAt ?? task.endDate)
                                      : task.endDate,
                                ),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppColors.info,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (task.isDueToday && !task.isCompleted)
                          _statusTag(
                            context: context,
                            label: loc.translate('today').toUpperCase(),
                            color: AppColors.warning,
                          ),
                        if (isOverdue)
                          _statusTag(
                            context: context,
                            label: loc.translate('overdue').toUpperCase(),
                            color: AppColors.error,
                          ),
                        if (task.isCompleted && task.wasOverdue)
                          _statusTag(
                            context: context,
                            label: loc.translate('overdue').toUpperCase(),
                            color: AppColors.error,
                          )
                        else if (task.isCompleted && !task.wasOverdue)
                          _statusTag(
                            context: context,
                            label: loc.translate('on_time').toUpperCase(),
                            color: AppColors.status,
                          ),

                        if (task.isCompleted)
                          _statusTag(
                            context: context,
                            label: loc.translate('finish').toUpperCase(),
                            color: AppColors.success,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}

Future<void> _showDeleteConfirmation(
  BuildContext context,
  TaskModel task,
) async {
  /// Capture everything we need from context BEFORE the async gap,
  /// because the Slidable's context will be unmounted after the dialog closes.
  final loc = AppLocalizations.of(context);
  final provider = context.read<TaskProvider>();
  final overlay = Overlay.of(context);
  final successMsg =
      loc?.translate('task_delete') ?? 'Task Deleted Successfully';

  final confirmed = await context.showAlertDialog(
    title: loc?.translate('delete_task') ?? '',
    message: loc?.translate('task_delete_confirm') ?? '',
    confirmText: loc?.translate('delete'),
    cancelText: loc?.translate('cancel'),
  );

  if (confirmed == true) {
    try {
      LoadingOverlay.show(
        overlay,
        message: loc?.translate('deleting_task') ?? '',
      );
      final success = await provider.deleteTask(task.id);
      LoadingOverlay.hide();

      if (success) {
        MessageUtils.showSuccessToastWithOverlay(overlay, successMsg);
      }
    } catch (_) {
      LoadingOverlay.hide();
    }
  }
}

Future<void> _taskCompleteConfirmation(
  BuildContext context,
  TaskModel task,
) async {
  /// Capture everything we need from context BEFORE the async gap,
  /// because the Slidable's context will be unmounted after the dialog closes.
  final loc = AppLocalizations.of(context);
  final provider = context.read<TaskProvider>();
  final overlay = Overlay.of(context);
  final successMsg = (task.isCompleted == false)
      ? loc?.translate('task_complete') ?? 'Task Completed Successfully'
      : loc?.translate('task_incomplete') ?? 'Task was Incomplete';

  final confirmed = await context.showAlertDialog(
    title: (task.isCompleted == false)
        ? loc?.translate('complete_task') ?? ''
        : loc?.translate('incomplete_task') ?? '',
    message: (task.isCompleted == false)
        ? loc?.translate('task_complete_confirm') ?? ''
        : loc?.translate('task_incomplete_confirm') ?? '',
    confirmText: loc?.translate('yes'),
    cancelText: loc?.translate('no'),
  );

  if (confirmed == true) {
    try {
      LoadingOverlay.show(
        overlay,
        message: (task.isCompleted == false)
            ? loc?.translate('completing_task') ?? ''
            : loc?.translate('in_completing_task') ?? '',
      );
      await provider.toggleTaskStatus(task.id);
      LoadingOverlay.hide();
      MessageUtils.showSuccessToastWithOverlay(overlay, successMsg);
    } catch (_) {
      LoadingOverlay.hide();
    }
  }
}

Widget _statusTag({
  required BuildContext context,
  required String label,
  required Color color,
}) {
  final theme = Theme.of(context);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(32),
    ),
    child: Text(
      label,
      style: theme.textTheme.labelSmall?.copyWith(
        color: color,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.3,
      ),
    ),
  );
}
