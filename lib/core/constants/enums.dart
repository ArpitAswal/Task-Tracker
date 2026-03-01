import 'package:hive/hive.dart';

part 'enums.g.dart';

@HiveType(typeId: 2)
/// Task Priority Options
enum TaskPriority {
  /// equivalent to 1
  @HiveField(0)
  low,
  /// equivalent to 2
  @HiveField(1)
  medium,
  /// equivalent to 3
  @HiveField(2)
  high,
}

@HiveType(typeId: 3)
/// Task Category Options
enum TaskCategory {
  /// Personal Tasks/Goals
  @HiveField(0)
  personal,
  /// Work Tasks/Projects
  @HiveField(1)
  work,
  /// Other for Tasks like hobbies, family, etc.
  @HiveField(2)
  other,
}

/// Task filter options
enum TaskFilter {
  /// Show all tasks
  all,

  /// Show only pending tasks
  pending,

  /// Show only completed tasks
  completed,

  /// Show only overdue tasks
  overdue,

  /// Show tasks due today
  dueToday,
}
