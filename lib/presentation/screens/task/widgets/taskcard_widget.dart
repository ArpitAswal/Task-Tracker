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
  final isOverdue = task.endDate.day < DateTime.now().day && !task.isCompleted;
  final hasDescription = (task.description?.trim().isNotEmpty ?? false);
  final priorityColor = task.priorityColor;
  final categoryColor = task.categoryColor;
  final loc = AppLocalizations.of(context)!;
  final darkMode = context.isDarkMode;

  final cardGradient = LinearGradient(
    colors: task.isCompleted
        ? (darkMode)
              ? [
                  AppColors.black.withValues(alpha: 0.1),
                  AppColors.success.withValues(alpha: 0.2),
                ]
              : [
                  AppColors.success.withValues(alpha: 0.1),
                  AppColors.white.withValues(alpha: 0.3),
                ]
        : (isOverdue)
        ? (darkMode)
              ? [
                  AppColors.black.withValues(alpha: 0.1),
                  AppColors.error.withValues(alpha: 0.2),
                ]
              : [
                  AppColors.error.withValues(alpha: 0.1),
                  AppColors.white.withValues(alpha: 0.3),
                ]
        : (task.isDueToday)
        ? (darkMode)
              ? [
                  AppColors.black.withValues(alpha: 0.1),
                  AppColors.warning.withValues(alpha: 0.2),
                ]
              : [
                  AppColors.warning.withValues(alpha: 0.1),
                  AppColors.white.withValues(alpha: 0.3),
                ]
        : (darkMode)
        ? [
            AppColors.black.withValues(alpha: 0.1),
            AppColors.info.withValues(alpha: 0.2),
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
    padding: EdgeInsets.only(top: (context.isTablet ? 24 : 8)),
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
              color: statusColor.withValues(alpha: darkMode ? 0.5 : 0.2),
              blurRadius: 4,
              offset: const Offset(-4, 4),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Material(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(21),
              clipBehavior: Clip.antiAlias,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: (context.isTablet) ? 8 : 2,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(21),
                  gradient: cardGradient,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Transform.scale(
                          scale: (context.isTablet) ? 1.5 : 1,
                          child: Checkbox(
                            // This shrinks the hit area to the size of the box itself
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            // This removes extra padding around the checkbox
                            visualDensity: VisualDensity.compact,
                            value: task.isCompleted,
                            onChanged: (bool? value) {
                              if (value != null) {
                                _taskCompleteConfirmation(context, task);
                              }
                            },
                          ),
                        ),
                        SizedBox(width: (context.isTablet) ? 8 : 0),
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  task.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(width: (context.isTablet) ? 12 : 8),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: (context.isTablet) ? 12 : 8,
                                  vertical: (context.isTablet) ? 8 : 5,
                                ),
                                decoration: BoxDecoration(
                                  color: priorityColor.withValues(
                                    alpha: darkMode ? 0.2 : 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.flag_outlined,
                                      size: context.isTablet ? 21 : 14,
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
                              SizedBox(width: (context.isTablet) ? 8 : 4),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: (context.isTablet) ? 12 : 8,
                                  vertical: (context.isTablet) ? 8 : 5,
                                ),
                                decoration: BoxDecoration(
                                  color: categoryColor.withValues(
                                    alpha: darkMode ? 0.2 : 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.category_outlined,
                                      size: context.isTablet ? 21 : 14,
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
                      Text(
                        task.description!.trim(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: statusColor,
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
                          padding: EdgeInsets.symmetric(
                            horizontal: (context.isTablet) ? 12 : 8,
                            vertical: (context.isTablet) ? 8 : 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.info.withValues(
                              alpha: darkMode ? 0.1 : 0.15,
                            ),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.event_rounded,
                                size: context.isTablet ? 21 : 14,
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
                    const SizedBox(height: 6),
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
  final successMsg =
      loc?.translate('task_delete') ?? 'Task Deleted Successfully';

  final confirmed = await context.showAlertDialog(
    title: loc?.translate('delete_task') ?? '',
    message: loc?.translate('task_delete_confirm') ?? '',
    confirmText: loc?.translate('delete'),
    cancelText: loc?.translate('cancel'),
  );

  if (confirmed == true && context.mounted) {
    try {
      LoadingOverlay.show(
        context,
        message: loc?.translate('deleting_task') ?? '',
      );
      final success = await provider.deleteTask(task.id);
      LoadingOverlay.hide();

      if (success && context.mounted) {
        MessageUtils.showSuccessToastWithOverlay(
          Overlay.of(context),
          successMsg,
        );
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

  if (confirmed == true && context.mounted) {
    try {
      LoadingOverlay.show(
        context,
        message: (task.isCompleted == false)
            ? loc?.translate('completing_task') ?? ''
            : loc?.translate('in_completing_task') ?? '',
      );
      await provider.toggleTaskStatus(task.id);
      LoadingOverlay.hide();
      MessageUtils.showSuccessToastWithOverlay(Overlay.of(context), successMsg);
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
    padding: EdgeInsets.symmetric(
      horizontal: (context.isTablet) ? 12 : 8,
      vertical: (context.isTablet) ? 8 : 5,
    ),
    decoration: BoxDecoration(
      color: color.withValues(alpha: (context.isDarkMode) ? 0.1 : 0.15),
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
