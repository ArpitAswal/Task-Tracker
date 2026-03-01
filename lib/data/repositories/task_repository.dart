// ✨ NEW: Task repository handling all task data operations
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/storage_service.dart';
import '../../core/utils/exception_handling/effect_bus.dart';
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
  final StorageService _storageService;
  final EffectBus _effect;
  final FirebaseAuth _authUser;

  /// Constructor with dependency injection
  ///
  /// Allows testing with mock instances
  TaskRepository({
    FirebaseFirestore? firestore,
    StorageService? storageService,
    EffectBus? effect,
    FirebaseAuth? authUser,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storageService = storageService ?? StorageService(),
       _effect = effect ?? EffectBus.instance,
       _authUser = authUser ?? FirebaseAuth.instance;

  // ============================================================================
  // CREATE OPERATIONS
  // ============================================================================

  /// Create a new task
  ///
  /// [task] - Task model to create
  /// [context] - Optional context for localized errors
  ///
  /// Returns: Created task with updated timestamps
  /// Throws: Exception with error message
  ///
  /// Process:
  /// 1. Save to local Hive database (offline support)
  /// 2. Sync to Firebase Firestore (cloud backup)
  Future<TaskModel> createTask(TaskModel task) async {
    // Update timestamps
    final newTask = task.copyWith(updatedAt: DateTime.now());

    // Await local write (primary) — must succeed or be caught gracefully
    try {
      final box = await Hive.openBox<TaskModel>(
        "${AppConstants.taskBox}_${task.userId}",
      );
      await box.put(newTask.id, newTask);
    } catch (localErr) {
      debugPrint('Local save failed (createTask): $localErr');
    }

    // Fire-and-forget cloud write (secondary)
    unawaited(
      _effect.safeEffect(
        () => _firestore
            .collection(FirebaseCollections.tasks)
            .doc(newTask.userId)
            .collection(FirebaseCollections.userTasks)
            .doc(newTask.id)
            .set(newTask.toJson()),
      ),
    );

    return newTask;
  }

  // ============================================================================
  // READ OPERATIONS
  // ============================================================================

  /// Get all tasks for a specific user
  ///
  /// [userId] - User ID to fetch tasks for
  /// [fromLocal] - If true, fetch from Hive; if false, fetch from Firestore
  ///
  /// Returns: List of tasks
  Future<List<TaskModel>> getAllTasks(
    String userId, {
    bool fromLocal = true,
  }) async {
    try {
      if (fromLocal) {
        // Fetch from Hive (offline)
        final box = _storageService.getTypedBox<TaskModel>(
          "${AppConstants.taskBox}_$userId",
        );
        final tasks = box.values
            .whereType<TaskModel>()
            .where((task) => task.userId == userId)
            .toList();

        // Sort by end date (newest first)
        tasks.sort((a, b) => b.endDate.compareTo(a.endDate));
        return tasks;
      } else {
        // Fetch from Firestore (online)
        final snapshot = await _firestore
            .collection(FirebaseCollections.tasks)
            .doc(userId)
            .collection(FirebaseCollections.userTasks)
            .orderBy('priority', descending: true) // Sort by priority
            .orderBy('endDate', descending: true) // Sort by end Date of task
            .get();

        return snapshot.docs
            .map((doc) => TaskModel.fromFirestore(doc))
            .toList();
      }
    } catch (e) {
      throw Exception('Failed to fetch tasks: ${e.toString()}');
    }
  }

  /// Get pending tasks (not completed and not overdue)
  ///
  /// [userId] - User ID to fetch tasks for
  /// [fromLocal] - If true, fetch from Hive; if false, fetch from Firestore
  ///
  /// Returns: List of pending tasks
  Future<List<TaskModel>> getPendingTasks(
    String userId, {
    bool fromLocal = true,
  }) async {
    final allTasks = await getAllTasks(userId, fromLocal: fromLocal);
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
  ///
  /// [userId] - User ID to fetch tasks for
  /// [fromLocal] - If true, fetch from Hive; if false, fetch from Firestore
  ///
  /// Returns: List of completed tasks
  Future<List<TaskModel>> getCompletedTasks(
    String userId, {
    bool fromLocal = true,
  }) async {
    final allTasks = await getAllTasks(userId, fromLocal: fromLocal);
    return allTasks.where((task) => task.isCompleted).toList();
  }

  /// Get overdue tasks (not completed and past due date)
  ///
  /// [userId] - User ID to fetch tasks for
  /// [fromLocal] - If true, fetch from Hive; if false, fetch from Firestore
  ///
  /// Returns: List of overdue tasks
  Future<List<TaskModel>> getOverdueTasks(
    String userId, {
    bool fromLocal = true,
  }) async {
    final allTasks = await getAllTasks(userId, fromLocal: fromLocal);
    return allTasks.where((task) => task.isOverdue).toList();
  }

  /// Get tasks due today
  ///
  /// [userId] - User ID to fetch tasks for
  /// [fromLocal] - If true, fetch from Hive; if false, fetch from Firestore
  ///
  /// Returns: List of tasks due today
  Future<List<TaskModel>> getTasksDueToday(
    String userId, {
    bool fromLocal = true,
  }) async {
    final allTasks = await getAllTasks(userId, fromLocal: fromLocal);
    return allTasks
        .where((task) => !task.isCompleted && task.isDueToday)
        .toList();
  }

  /// Get a single task by ID
  ///
  /// [taskId] - Task ID to fetch
  /// [fromLocal] - If true, fetch from Hive; if false, fetch from Firestore
  ///
  /// Returns: Task model or null if not found
  Future<TaskModel?> getTaskById(String taskId, {bool fromLocal = true}) async {
    final uid = _authUser.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');

    try {
      if (fromLocal) {
        // Fetch from Hive
        final box = _storageService.getTypedBox<TaskModel>(
          "${AppConstants.taskBox}_$uid",
        );
        return box.get(taskId);
      } else {
        // Fetch from Firestore
        final doc = await _firestore
            .collection(FirebaseCollections.tasks)
            .doc(uid)
            .collection(FirebaseCollections.userTasks)
            .doc(taskId)
            .get();

        if (!doc.exists) return null;
        return TaskModel.fromFirestore(doc);
      }
    } catch (e) {
      throw Exception('Failed to fetch task: ${e.toString()}');
    }
  }

  // ============================================================================
  // UPDATE OPERATIONS
  // ============================================================================

  /// Update an existing task
  ///
  /// [task] - Updated task model
  /// [context] - Optional context for localized errors
  ///
  /// Returns: Updated task
  /// Throws: Exception with error message
  Future<TaskModel> updateTask(TaskModel task) async {
    final uid = _authUser.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');

    // Update timestamp
    final updatedTask = task.copyWith(updatedAt: DateTime.now());

    // Await local write (primary)
    try {
      final box = _storageService.getTypedBox<TaskModel>(
        "${AppConstants.taskBox}_$uid",
      );
      await box.put(updatedTask.id, updatedTask);
    } catch (localErr) {
      debugPrint('Local save failed (updateTask): $localErr');
    }

    // Fire-and-forget cloud write (secondary)
    unawaited(
      _effect.safeEffect(
        () => _firestore
            .collection(FirebaseCollections.tasks)
            .doc(uid)
            .collection(FirebaseCollections.userTasks)
            .doc(updatedTask.id)
            .update(updatedTask.toJson()),
      ),
    );

    return updatedTask;
  }

  /// Mark task as completed
  ///
  /// [taskId] - Task ID to mark as completed
  /// [context] - Optional context for localized errors
  ///
  /// Returns: Updated task
  Future<TaskModel> markTaskAsCompleted(String taskId) async {
    final task = await getTaskById(taskId);
    if (task == null) {
      throw Exception('Task not found');
    }

    final completedTask = task.copyWith(
      isCompleted: true,
      completedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await updateTask(completedTask);
  }

  /// Mark task as incomplete
  ///
  /// [taskId] - Task ID to mark as incomplete
  /// [context] - Optional context for localized errors
  ///
  /// Returns: Updated task
  Future<TaskModel> markTaskAsIncomplete(String taskId) async {
    final task = await getTaskById(taskId);
    if (task == null) {
      throw Exception('Task not found');
    }

    final incompleteTask = task.copyWith(
      isCompleted: false,
      completedAt: null,
      updatedAt: DateTime.now(),
    );

    return await updateTask(incompleteTask);
  }

  // ============================================================================
  // DELETE OPERATIONS
  // ============================================================================

  /// Delete a task
  ///
  /// [taskId] - Task ID to delete
  /// [context] - Optional context for localized errors
  ///
  /// Throws: Exception with error message
  Future<void> deleteTask(String taskId) async {
    final uid = _authUser.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');

    // Await local delete (primary)
    try {
      final box = _storageService.getTypedBox<TaskModel>(
        "${AppConstants.taskBox}_$uid",
      );
      await box.delete(taskId);
    } catch (localErr) {
      debugPrint('Local delete failed (deleteTask): $localErr');
    }

    // Fire-and-forget cloud delete (secondary)
    unawaited(
      _effect.safeEffect(
        () => _firestore
            .collection(FirebaseCollections.tasks)
            .doc(uid)
            .collection(FirebaseCollections.userTasks)
            .doc(taskId)
            .delete(),
      ),
    );
  }

  /// Delete all completed tasks for a user
  ///
  /// [userId] - User ID to delete tasks for
  ///
  /// Returns: Number of tasks deleted
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

  /// Delete all tasks for a user
  ///
  /// [userId] - User ID to delete tasks for
  ///
  /// Returns: Number of tasks deleted
  Future<int> deleteAllTasks(String userId) async {
    try {
      final allTasks = await getAllTasks(userId);

      for (final task in allTasks) {
        await deleteTask(task.id);
      }

      return allTasks.length;
    } catch (e) {
      throw Exception('Failed to delete all tasks: ${e.toString()}');
    }
  }

  // ============================================================================
  // SYNC OPERATIONS
  // ============================================================================

  /// Sync local tasks to Firestore
  ///
  /// [userId] - User ID to sync tasks for
  ///
  /// Uploads all local tasks to Firestore (for backup)
  Future<void> syncLocalToCloud(String userId) async {
    try {
      final localTasks = await getAllTasks(userId, fromLocal: true);

      for (final task in localTasks) {
        await _firestore
            .collection(FirebaseCollections.tasks)
            .doc(userId)
            .collection(FirebaseCollections.userTasks)
            .doc(task.id)
            .set(task.toJson(), SetOptions(merge: true));
      }
    } catch (e) {
      throw Exception('Failed to sync to cloud: ${e.toString()}');
    }
  }

  /// Sync cloud tasks to local storage
  ///
  /// [userId] - User ID to sync tasks for
  ///
  /// Downloads all tasks from Firestore to Hive
  Future<List<TaskModel>> syncCloudToLocal(String userId) async {
    try {
      final cloudTasks = await getAllTasks(userId, fromLocal: false);
      final box = _storageService.getTypedBox<TaskModel>(
        "${AppConstants.taskBox}_$userId",
      );

      for (final task in cloudTasks) {
        await box.put(task.id, task);
      }
      return cloudTasks;
    } catch (e) {
      throw Exception('Failed to sync from cloud: ${e.toString()}');
    }
  }

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
}
