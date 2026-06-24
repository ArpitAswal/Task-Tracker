// ✨ NEW: Task repository handling all task data operations
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/storage_service.dart';
import '../models/task_model.dart';

/// Repository for task data operations
///
/// Handles:
/// - CRUD operations for tasks
/// - Local storage with Hive (offline support)
/// - Cloud storage with Firestore (sync)
/// - Data synchronization between local and cloud
class TaskRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _authUser;

  /// Constructor with dependency injection
  ///
  /// Allows testing with mock instances
  TaskRepository({
    FirebaseFirestore? firestore,
    StorageService? storageService,
    FirebaseAuth? authUser,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _authUser = authUser ?? FirebaseAuth.instance;

  // ============================================================================
  // CREATE OPERATIONS
  // ============================================================================

  /// Create a new task
  ///
  /// [task] - Task model to create
  ///
  /// Returns: Created task with updated timestamps
  Future<TaskModel> createTask(TaskModel task) async {
    // Update timestamps
    final newTask = task.copyWith(updatedAt: DateTime.now());

    // Fire-and-forget cloud write (Firestore handles offline caching automatically)
    _firestore
        .collection(FirebaseCollections.tasks)
        .doc(newTask.userId)
        .collection(FirebaseCollections.userTasks)
        .doc(newTask.id)
        .set(newTask.toJson());

    return newTask;
  }

  // ============================================================================
  // READ OPERATIONS
  // ============================================================================

  /// Get a stream of all tasks for a specific user
  Stream<List<TaskModel>> tasksStream(String userId) {
    return _firestore
        .collection(FirebaseCollections.tasks)
        .doc(userId)
        .collection(FirebaseCollections.userTasks)
        .orderBy('priority', descending: true)
        .orderBy('endDate', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList(),
        );
  }

  /// Get all tasks for a specific user
  ///
  /// [userId] - User ID to fetch tasks for
  ///
  /// Returns: List of tasks
  Future<List<TaskModel>> getAllTasks(String userId) async {
    try {
      // Fetch from Firestore (online/offline handled automatically by SDK cache)
      final snapshot = await _firestore
          .collection(FirebaseCollections.tasks)
          .doc(userId)
          .collection(FirebaseCollections.userTasks)
          .orderBy('priority', descending: true)
          .orderBy('endDate', descending: true)
          .get();

      return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch tasks: ${e.toString()}');
    }
  }

  Future<List<TaskModel>> getAllTasksForCurrentUser() async {
    final uid = _authUser.currentUser?.uid;
    if (uid == null) return [];
    return getAllTasks(uid);
  }

  /// Get pending tasks (not completed and not overdue)
  Future<List<TaskModel>> getPendingTasks(String userId) async {
    final allTasks = await getAllTasks(userId);
    final now = DateTime.now();

    return allTasks
        .where(
          (task) =>
              !task.isCompleted &&
              task.endDate.isAfter(now.subtract(const Duration(days: 1))),
        )
        .toList();
  }

  /// Get completed tasks
  Future<List<TaskModel>> getCompletedTasks(String userId) async {
    final allTasks = await getAllTasks(userId);
    return allTasks.where((task) => task.isCompleted).toList();
  }

  /// Get overdue tasks (not completed and past due date)
  Future<List<TaskModel>> getOverdueTasks(String userId) async {
    final allTasks = await getAllTasks(userId);
    return allTasks.where((task) => task.isOverdue).toList();
  }

  /// Get tasks due today
  Future<List<TaskModel>> getTasksDueToday(String userId) async {
    final allTasks = await getAllTasks(userId);
    return allTasks
        .where((task) => !task.isCompleted && task.isDueToday)
        .toList();
  }

  /// Get a single task by ID
  Future<TaskModel?> getTaskById(String taskId) async {
    final uid = _authUser.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');

    try {
      final doc = await _firestore
          .collection(FirebaseCollections.tasks)
          .doc(uid)
          .collection(FirebaseCollections.userTasks)
          .doc(taskId)
          .get();

      if (!doc.exists) return null;
      return TaskModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to fetch task: ${e.toString()}');
    }
  }

  // ============================================================================
  // UPDATE OPERATIONS
  // ============================================================================

  /// Update an existing task
  Future<TaskModel> updateTask(TaskModel task) async {
    final uid = _authUser.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');

    // Update timestamp
    final updatedTask = task.copyWith(updatedAt: DateTime.now());

    // Fire-and-forget cloud write (Firestore handles offline caching automatically)
    _firestore
        .collection(FirebaseCollections.tasks)
        .doc(uid)
        .collection(FirebaseCollections.userTasks)
        .doc(updatedTask.id)
        .update(updatedTask.toJson());

    return updatedTask;
  }

  // ============================================================================
  // DELETE OPERATIONS
  // ============================================================================

  /// Delete a task
  Future<void> deleteTask(String taskId) async {
    final uid = _authUser.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');

    // Fire-and-forget cloud delete (Firestore handles offline caching automatically)
    _firestore
        .collection(FirebaseCollections.tasks)
        .doc(uid)
        .collection(FirebaseCollections.userTasks)
        .doc(taskId)
        .delete();
  }

  /// Delete all completed tasks for a user
  Future<int> deleteAllCompletedTasks(String userId) async {
    try {
      final completedTasks = await getCompletedTasks(userId);

      for (final task in completedTasks) {
        await deleteTask(task.id);
      }

      return completedTasks.length;
    } catch (e) {
      throw Exception('Failed to delete completed tasks: ${e.toString()}');
    }
  }

  Future<int> deleteAllTasks(String userId) async {
    try {
      final allTasks = await getAllTasks(userId);

      // Cancel notifications for each task
      for (final task in allTasks) {
        await NotificationService.cancelTaskReminder(task.id);
      }

      // Delete from Firestore in batches of 500 (Fire-and-forget)
      if (allTasks.isNotEmpty) {
        final List<List<TaskModel>> chunks = [];
        for (var i = 0; i < allTasks.length; i += 500) {
          chunks.add(
            allTasks.sublist(
              i,
              i + 500 > allTasks.length ? allTasks.length : i + 500,
            ),
          );
        }

        for (final chunk in chunks) {
          final batch = _firestore.batch();
          for (final task in chunk) {
            final docRef = _firestore
                .collection(FirebaseCollections.tasks)
                .doc(userId)
                .collection(FirebaseCollections.userTasks)
                .doc(task.id);
            batch.delete(docRef);
          }
          await batch.commit();
        }
      }

      return allTasks.length;
    } catch (e) {
      throw Exception('Failed to delete all tasks: ${e.toString()}');
    }
  }

  // ============================================================================
  // SYNC OPERATIONS
  // ============================================================================

  // ============================================================================
  // STATISTICS
  // ============================================================================

  /// Get task statistics for a user
  ///
  /// [userId] - User ID to get stats for
  ///
  /// Returns: Map with task statistics
  Future<Map<String, int>> getTaskStatistics(String userId) async {
    final allTasks = await getAllTasks(userId);
    final completed = allTasks.where((t) => t.isCompleted).length;
    final pending = allTasks
        .where((t) => !t.isCompleted && !t.isOverdue)
        .length;
    final overdue = allTasks.where((t) => t.isOverdue).length;

    return {
      'total': allTasks.length,
      'completed': completed,
      'pending': pending,
      'overdue': overdue,
    };
  }

  // ============================================================================
  // LEADERBOARD METHODS
  // ============================================================================

  /// Increment the completed tasks count for a specific user
  Future<void> completedTaskCount(String uid, bool isInc) async {
    // Fire-and-forget cloud write
    _firestore.collection(FirebaseCollections.users).doc(uid).update({
      'completedTasksCount': (isInc)
          ? FieldValue.increment(1)
          : FieldValue.increment(-1),
    });
  }
}
