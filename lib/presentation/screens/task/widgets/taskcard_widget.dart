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

// ─────────────────────────────────────────────────────────────────────────────
// TASK CARD BUILDER
//
// Design intent:
//  • Pending and Completed cards share the SAME visual skeleton so the list
//    looks cohesive; only the chips inside the Wrap change per status.
//  • All chips live in a [Wrap] so they reflow on narrow screens with zero
//    overflow risk. Future chips can be added without any layout changes.
// ─────────────────────────────────────────────────────────────────────────────
Widget buildTaskCard(TaskModel task, BuildContext context) {
  final theme = Theme.of(context);
  final now = DateTime.now();

  // Full DateTime comparison — not just day-of-month — prevents false
  // positives across month / year boundaries.
  final isOverdue = task.endDate.isBefore(now) && !task.isCompleted;

  // DUE SOON: ends today within the next 2 hours — stronger urgency than TODAY.
  final minutesUntilEnd = task.endDate.difference(now).inMinutes;
  final isDueSoon =
      task.isDueToday &&
      !task.isCompleted &&
      minutesUntilEnd > 0 &&
      minutesUntilEnd <= 120;

  final hasDescription = task.description?.trim().isNotEmpty ?? false;
  final priorityColor = task.priorityColor;
  final categoryColor = task.categoryColor;
  final loc = AppLocalizations.of(context)!;
  final darkMode = context.isDarkMode;
  final isTablet = context.isTablet;

  // Status colour drives gradient + drop-shadow colour
  final Color statusColor = task.isCompleted
      ? AppColors.success
      : isOverdue
      ? AppColors.error
      : isDueSoon
      ? AppColors.error
      : task.isDueToday
      ? AppColors.warning
      : AppColors.info;

  final cardGradient = LinearGradient(
    colors: [
      darkMode
          ? AppColors.black.withValues(alpha: 0.1)
          : statusColor.withValues(alpha: 0.07),
      darkMode
          ? statusColor.withValues(alpha: 0.18)
          : AppColors.white.withValues(alpha: 0.3),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Reminder chip state — three cases:
  //   upcoming (bell, blue)  |  already-fired (muted bell)  |  none
  final bool reminderUpcoming =
      task.hasReminder && task.reminderAt!.isAfter(now);
  final bool reminderFired =
      task.hasReminder && task.reminderAt!.isBefore(now) && !task.isCompleted;

  return Padding(
    padding: EdgeInsets.only(top: isTablet ? 24 : 16),
    child: Slidable(
      key: ValueKey(task.id),
      // Edit action only available on pending tasks
      startActionPane: task.isCompleted
          ? null
          : ActionPane(
              motion: const ScrollMotion(),
              extentRatio: 0.25,
              children: [
                SlidableAction(
                  onPressed: (actionContext) {
                    showModalBottomSheet(
                      context: actionContext,
                      isScrollControlled: true,
                      useSafeArea: true,
                      backgroundColor: Theme.of(
                        context,
                      ).scaffoldBackgroundColor,
                      builder: (actionContext) => AddTaskSheet(
                        popupTitle: loc.translate('edit_task'),
                        provider: context.read<TaskProvider>(),
                        task: task,
                        isBottomSheet: true,
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
            onPressed: (actionContext) =>
                _showDeleteConfirmation(actionContext, task, context),
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

      // ── Card shell ───────────────────────────────────────────────────────
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(21),
          boxShadow: [
            BoxShadow(
              color: statusColor.withValues(alpha: darkMode ? 0.45 : 0.18),
              blurRadius: 4,
              offset: const Offset(-4, 4),
            ),
          ],
        ),
        child: Material(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(21),
          clipBehavior: Clip.antiAlias,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 16 : 10,
              vertical: isTablet ? 12 : 6,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(21),
              gradient: cardGradient,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Row 1: Checkbox · Title · Priority badge · Category badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Compact checkbox — no extra outer padding
                    Transform.scale(
                      scale: isTablet ? 1.4 : 1.0,
                      child: Checkbox(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        value: task.isCompleted,
                        onChanged: (bool? value) {
                          if (value != null) {
                            _taskCompleteConfirmation(context, task);
                          }
                        },
                      ),
                    ),
                    SizedBox(width: isTablet ? 6 : 2),

                    // Title — Expanded fills available space and
                    // ellipsis-truncates cleanly on any screen width
                    Expanded(
                      child: Text(
                        task.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          // Dim + strike-through completed titles for visual
                          // clarity without removing the title text
                          color: task.isCompleted
                              ? (theme.textTheme.titleMedium?.color)
                                    ?.withValues(alpha: 0.55)
                              : null,
                          decorationColor: AppColors.success,
                        ),
                      ),
                    ),

                    SizedBox(width: isTablet ? 8 : 4),

                    // Priority and Category badges flush to right edge
                    _Badge(
                      icon: Icons.flag_outlined,
                      label: loc.translate(task.priorityString),
                      color: priorityColor,
                      isTablet: isTablet,
                      darkMode: darkMode,
                    ),
                    SizedBox(width: isTablet ? 6 : 4),
                    _Badge(
                      icon: Icons.category_outlined,
                      label: loc.translate(task.categoryString),
                      color: categoryColor,
                      isTablet: isTablet,
                      darkMode: darkMode,
                    ),
                  ],
                ),

                // ── Row 2: Description (optional, indented under title) ────
                if (hasDescription) ...[
                  const SizedBox(height: 2),
                  Padding(
                    padding: EdgeInsets.only(left: isTablet ? 44 : 28),
                    child: Text(
                      task.description!.trim(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w400,
                        color: statusColor.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 6),

                // ── Row 3: Chip strip ─────────────────────────────────────
                // Wrap auto-reflows to next line when screen is narrow —
                // zero overflow risk no matter how many chips are added later.
                Padding(
                  padding: EdgeInsets.only(left: isTablet ? 44 : 28),
                  child: Wrap(
                    spacing: 5,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // Date + time chip
                      // Pending → endDate+time  |  Completed → completedAt
                      _Chip(
                        icon: task.isCompleted
                            ? Icons.check_circle_outline_rounded
                            : Icons.event_rounded,
                        label: _formatDateTime(
                          task.isCompleted
                              ? (task.completedAt ?? task.endDate)
                              : task.endDate,
                        ),
                        color: AppColors.info,
                        isTablet: isTablet,
                        darkMode: darkMode,
                      ),

                      // Upcoming reminder chip (shows scheduled time)
                      if (reminderUpcoming)
                        _Chip(
                          icon: Icons.notifications_active_rounded,
                          label: DateFormat('h:mm a').format(task.reminderAt!),
                          color: AppColors.info,
                          isTablet: isTablet,
                          darkMode: darkMode,
                        ),

                      // Reminder-already-fired chip (muted)
                      if (reminderFired)
                        _Chip(
                          icon: Icons.notifications_off_outlined,
                          label: loc.translate('reminder_fired'),
                          color: AppColors.grey,
                          isTablet: isTablet,
                          darkMode: darkMode,
                        ),

                      // DUE SOON overrides TODAY when < 2 hrs remain
                      if (isDueSoon)
                        _Chip(
                          icon: Icons.timer_outlined,
                          label: loc.translate('due_soon').toUpperCase(),
                          color: AppColors.error,
                          isTablet: isTablet,
                          darkMode: darkMode,
                        )
                      else if (task.isDueToday && !task.isCompleted)
                        _Chip(
                          icon: Icons.today_rounded,
                          label: loc.translate('today').toUpperCase(),
                          color: AppColors.warning,
                          isTablet: isTablet,
                          darkMode: darkMode,
                        ),

                      // OVERDUE with day count for pending tasks
                      if (isOverdue)
                        _Chip(
                          icon: Icons.warning_amber_rounded,
                          label: _overdueLabel(task, loc),
                          color: AppColors.error,
                          isTablet: isTablet,
                          darkMode: darkMode,
                        ),

                      // Days remaining — only for future (not today) tasks
                      if (!task.isCompleted &&
                          !isOverdue &&
                          !task.isDueToday &&
                          task.daysRemaining > 0)
                        _Chip(
                          icon: Icons.hourglass_bottom_rounded,
                          label: _daysRemainingLabel(task.daysRemaining, loc),
                          color: AppColors.status,
                          isTablet: isTablet,
                          darkMode: darkMode,
                        ),

                      // Completed: OVERDUE or ON TIME
                      if (task.isCompleted && task.wasOverdue)
                        _Chip(
                          icon: Icons.warning_amber_rounded,
                          label: loc.translate('overdue').toUpperCase(),
                          color: AppColors.error,
                          isTablet: isTablet,
                          darkMode: darkMode,
                        )
                      else if (task.isCompleted)
                        _Chip(
                          icon: Icons.verified_outlined,
                          label: loc.translate('on_time').toUpperCase(),
                          color: AppColors.status,
                          isTablet: isTablet,
                          darkMode: darkMode,
                        ),

                      // FINISH — always shown on completed tasks
                      if (task.isCompleted)
                        _Chip(
                          icon: Icons.task_alt_rounded,
                          label: loc.translate('finish').toUpperCase(),
                          color: AppColors.success,
                          isTablet: isTablet,
                          darkMode: darkMode,
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// FORMATTING HELPERS
// ─────────────────────────────────────────────────────────────────────────────

/// Formats a [DateTime] as "MMM dd, yyyy · h:mm a" so both date and specific
/// end time are visible — important since users now set exact end times.
String _formatDateTime(DateTime dt) =>
    DateFormat("MMM dd, yyyy · h:mm a").format(dt);

/// Builds the overdue label with day count.
///   0 days → "OVERDUE"   |   N days → "2 DAYS OVERDUE"
String _overdueLabel(TaskModel task, AppLocalizations loc) {
  // daysRemaining is negative when overdue; abs() gives the count
  final days = task.daysRemaining.abs();
  if (days == 0) return loc.translate('overdue').toUpperCase();
  final dayWord = days == 1
      ? loc.translate('day_streak')
      : loc.translate('days_streak');
  return '$days $dayWord ${loc.translate('overdue').toUpperCase()}';
}

/// Builds the "X DAY(S) LEFT" label for upcoming tasks.
String _daysRemainingLabel(int days, AppLocalizations loc) {
  final dayWord = days == 1
      ? loc.translate('day_streak')
      : loc.translate('days_streak');
  return '$days $dayWord ${loc.translate('days_left')}';
}

// ─────────────────────────────────────────────────────────────────────────────
// REUSABLE PRIVATE WIDGETS
//
// StatelessWidgets (not functions) so Flutter's element tree can efficiently
// diff only changed chips. Tablet/phone sizing is centralised here.
// ─────────────────────────────────────────────────────────────────────────────

/// Small icon + text pill badge for Priority and Category in the title row.
class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isTablet;
  final bool darkMode;

  const _Badge({
    required this.icon,
    required this.label,
    required this.color,
    required this.isTablet,
    required this.darkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 10 : 6,
        vertical: isTablet ? 5 : 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: darkMode ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isTablet ? 16 : 12, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: isTablet ? 12 : 10,
            ),
          ),
        ],
      ),
    );
  }
}

/// Status chip used in the bottom Wrap strip.
/// Icon + label ensures it is scannable regardless of colour context.
class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isTablet;
  final bool darkMode;

  const _Chip({
    required this.icon,
    required this.label,
    required this.color,
    required this.isTablet,
    required this.darkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 10 : 7,
        vertical: isTablet ? 5 : 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: darkMode ? 0.15 : 0.12),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isTablet ? 15 : 11, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
              fontSize: isTablet ? 12 : 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTION HANDLERS
// ─────────────────────────────────────────────────────────────────────────────

Future<void> _showDeleteConfirmation(
  BuildContext actionContext,
  TaskModel task,
  BuildContext context,
) async {
  /// Capture everything we need from context BEFORE the async gap,
  /// because the Slidable's context will be unmounted after the dialog closes.
  final loc = AppLocalizations.of(context);
  final provider = context.read<TaskProvider>();
  final successMsg =
      loc?.translate('task_delete').replaceAll('{taskTitle}', task.title) ??
      'Task \'${task.title}\' Deleted Successfully';

  final confirmed = await actionContext.showAlertDialog(
    title: loc?.translate('delete_task') ?? '',
    message: loc?.translate('task_delete_confirm') ?? '',
    confirmText: loc?.translate('delete'),
    cancelText: loc?.translate('cancel'),
  );

  if (confirmed == true && context.mounted) {
    bool success = false;
    await context.withLoading(
      message: loc?.translate('deleting_task') ?? '',
      future: Future.delayed(
        const Duration(seconds: 1),
        () async => success = await provider.deleteTask(task.id),
      ),
    );

    if (context.mounted) {
      if (success) {
        MessageUtils.showSuccessToastWithOverlay(
          Overlay.of(context),
          successMsg,
        );
      } else {
        debugPrint("# AppError:---> ${provider.errorMessage}");
        context.showErrorToast(provider.errorMessage ?? '');
      }
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
    context.withLoading(
      message: (task.isCompleted == false)
          ? loc?.translate('completing_task') ?? ''
          : loc?.translate('in_completing_task') ?? '',
      future: Future.delayed(
        const Duration(seconds: 1),
        () => provider.toggleTaskStatus(task.id),
      ),
    );
    MessageUtils.showSuccessToastWithOverlay(Overlay.of(context), successMsg);
  }
}
