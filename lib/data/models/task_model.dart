// ✨ NEW: Task model with Hive support and Firebase integration
import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:task_tracker/core/theme/app_colors.dart';

import '../../core/constants/enums.dart';

part 'task_model.g.dart'; // Generated file for Hive adapter

/// Task data model representing a task in the application
///
/// This model is used for:
/// - Firebase Firestore storage (cloud sync)
/// - Local Hive storage (offline support)
/// - In-app task state management
///
/// Hive TypeId: 1 (UserModel uses 0)
@HiveType(typeId: 1)
class TaskModel extends HiveObject {
  /// Unique task identifier
  @HiveField(0)
  final String id;

  /// Task title/name
  @HiveField(1)
  final String title;

  /// Task description (optional, can be detailed)
  @HiveField(2)
  final String? description;

  /// User ID who owns this task
  @HiveField(3)
  final String userId;

  /// Task start date
  @HiveField(4)
  final DateTime startDate;

  /// Task end/due date
  @HiveField(5)
  final DateTime endDate;

  /// Whether task is completed
  @HiveField(6)
  final bool isCompleted;

  /// Task priority (1 = low, 2 = medium, 3 = high)
  @HiveField(7)
  final TaskPriority priority;

  /// Optional specific hour for reminder (0-23, null = no specific hour)
  @HiveField(8)
  final int? reminderHour;

  /// Timestamp when task was created
  @HiveField(9)
  final DateTime createdAt;

  /// Timestamp when task was last updated
  @HiveField(10)
  final DateTime? updatedAt;

  /// Timestamp when task was completed (null if not completed)
  @HiveField(11)
  final DateTime? completedAt;

  /// Task category/tag (optional)
  @HiveField(12)
  final TaskCategory category;

  /// Constructor with required and optional fields
  TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.userId,
    required this.startDate,
    required this.endDate,
    this.isCompleted = false,
    this.priority = TaskPriority.medium, // Default medium priority
    this.reminderHour,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.category = TaskCategory.other,
  });

  // ============================================================================
  // SERIALIZATION METHODS
  // ============================================================================

  /// Convert model to JSON for Firebase Firestore
  ///
  /// Returns a Map with Firestore-compatible data types (Timestamp)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'userId': userId,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'isCompleted': isCompleted,
      'priority': priority.name,
      'reminderHour': reminderHour,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
      'category': category.name,
    };
  }

  /// Convert model to Map for general use
  ///
  /// Returns a Map with DateTime objects (not Timestamp)
  /// Useful for local storage, API calls, etc.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'userId': userId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isCompleted': isCompleted,
      'priority': priority,
      'reminderHour': reminderHour,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'category': category,
    };
  }

  /// Create model from JSON (Firebase Firestore)
  ///
  /// Converts Firestore Timestamp to DateTime
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      userId: json['userId'] as String,
      startDate: (json['startDate'] as Timestamp).toDate(),
      endDate: (json['endDate'] as Timestamp).toDate(),
      isCompleted: json['isCompleted'] as bool? ?? false,
      priority: json['priority'] is String
          ? TaskPriority.values.firstWhere(
              (e) => e.name == json['priority'],
              orElse: () => TaskPriority.medium,
            )
          : (json['priority'] as TaskPriority? ?? TaskPriority.medium),
      reminderHour: json['reminderHour'] as int?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
      completedAt: json['completedAt'] != null
          ? (json['completedAt'] as Timestamp).toDate()
          : null,
      category: json['category'] is String
          ? TaskCategory.values.firstWhere(
              (e) => e.name == json['category'],
              orElse: () => TaskCategory.other,
            )
          : (json['category'] as TaskCategory? ?? TaskCategory.other),
    );
  }

  /// Create model from Map
  ///
  /// Parses ISO8601 date strings to DateTime
  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      userId: map['userId'] as String,
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
      isCompleted: map['isCompleted'] as bool? ?? false,
      priority: map['priority'] is String
          ? TaskPriority.values.firstWhere(
              (e) => e.name == map['priority'],
              orElse: () => TaskPriority.medium,
            )
          : (map['priority'] as TaskPriority? ?? TaskPriority.medium),
      reminderHour: map['reminderHour'] as int?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'] as String)
          : null,
      category: map['category'] is String
          ? TaskCategory.values.firstWhere(
              (e) => e.name == map['category'],
              orElse: () => TaskCategory.other,
            )
          : (map['category'] as TaskCategory? ?? TaskCategory.other),
    );
  }

  /// Create model from Firestore DocumentSnapshot
  ///
  /// Convenience method for direct Firestore document conversion
  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel.fromJson({...data, 'id': doc.id});
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Create a copy of model with updated fields
  ///
  /// Immutable update pattern - returns new instance
  /// Only specified fields are updated, others remain same
  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCompleted,
    TaskPriority? priority,
    int? reminderHour,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    TaskCategory? category,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      reminderHour: reminderHour ?? this.reminderHour,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      category: category ?? this.category,
    );
  }

  /// Convert model to string for debugging
  @override
  String toString() {
    return 'TaskModel(id: $id, title: $title, isCompleted: $isCompleted)';
  }

  /// Check equality based on id
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskModel && other.id == id;
  }

  /// Generate hash code based on id
  @override
  int get hashCode => id.hashCode;

  // ============================================================================
  // CONVENIENCE GETTERS
  // ============================================================================

  /// Check if task is overdue
  /// Returns true if end date is in the past and task is not completed
  bool get isOverdue {
    if (isCompleted) return false;
    return endDate.isBefore(DateTime.now());
  }

  /// Check if task is due today
  bool get isDueToday {
    final now = DateTime.now();
    return endDate.year == now.year &&
        endDate.month == now.month &&
        endDate.day == now.day;
  }

  /// Check if task is due tomorrow
  bool get isDueTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return endDate.year == tomorrow.year &&
        endDate.month == tomorrow.month &&
        endDate.day == tomorrow.day;
  }

  /// Get priority as string
  String get priorityString {
    switch (priority) {
      case TaskPriority.low:
        return 'priorityLow';
      case TaskPriority.medium:
        return 'priorityMedium';
      case TaskPriority.high:
        return 'priorityHigh';
    }
  }

  /// Get category as String
  String get categoryString {
    switch (category){
      case TaskCategory.personal:
        return 'personal';
      case TaskCategory.work:
        return 'work';
      case TaskCategory.other:
        return 'other';
    }
  }

  /// Get priority color (for UI)
  Color get priorityColor {
    switch (priority) {
      case TaskPriority.low:
        return AppColors.success; // Green for low
      case TaskPriority.medium:
        return AppColors.warning; // Orange for medium
      case TaskPriority.high:
        return AppColors.error; // Red for high
    }
  }


  /// Get priority color (for UI)
  Color get categoryColor {
    switch (category) {
      case TaskCategory.personal:
        return AppColors.success; // Green for personal
      case TaskCategory.other:
        return AppColors.warning; // Orange for others
      case TaskCategory.work:
        return AppColors.error; // Red for work
    }
  }

  /// Get number of days remaining until end date
  /// Returns negative number if overdue
  int get daysRemaining {
    final now = DateTime.now();
    final difference = endDate.difference(
      DateTime(now.year, now.month, now.day),
    );
    return difference.inDays;
  }

  /// Check if task has reminder set
  bool get hasReminder => reminderHour != null;

  /// Get duration of task in days
  int get taskDuration {
    return (completedAt?.difference(startDate).inDays ?? 0) + 1;
  }

  bool get wasOverdue {
    return (isCompleted && (completedAt?.difference(endDate).inDays ?? 0) > 0);
  }
}
