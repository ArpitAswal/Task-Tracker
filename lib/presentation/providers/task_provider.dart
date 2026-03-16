// ✨ NEW: Task state management provider
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/enums.dart';
import '../../core/services/notification_service.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/models/task_model.dart';

/// Task state management provider
///
/// Manages task state and operations
/// Uses [TaskRepository] for data operations
/// Notifies listeners on state changes
///
/// Handles:
/// - CRUD operations for tasks
/// - Filtering (pending, completed, overdue)
/// - Loading states
/// - Error handling
class TaskProvider with ChangeNotifier {
  final TaskRepository _taskRepository;
  final _uuid = const Uuid();

  /// Callback invoked when a task is completed (for streak updates)
  VoidCallback? onTaskCompleted;

  /// Callback invoked when a task is marked incomplete (for streak reversal)
  void Function(bool hasOtherCompletedTasksToday)? onTaskIncomplete;

  /// Constructor with dependency injection
  TaskProvider({TaskRepository? taskRepository})
    : _taskRepository = taskRepository ?? TaskRepository();

  // ============================================================================
  // STATE VARIABLES
  // ============================================================================

  /// All tasks for current user
  List<TaskModel> _tasks = [];

  /// Loading state for operations
  bool _isLoading = false;

  /// Loading state for initial fetch
  bool _isInitialLoading = true;

  /// Error message if operation fails
  String? _errorMessage;

  /// Current user ID
  String? _userId;

  /// Selected task filter
  TaskFilter _currentFilter = TaskFilter.all;

  ///Set Default sort Filter of Tasks
  String _sortBy = 'dueDate';

  ///Set Drawer Initial Index
  final ValueNotifier<int> _drawerIndex = ValueNotifier<int>(0);

  ///Set TabView Initial Index
  int _tabviewIndex = 0;

  /// Set Add task popup field error
  String _titleError = "";
  String _descriptionError = "";

  // ============================================================================
  // GETTERS
  // ============================================================================

  /// Get all tasks
  List<TaskModel> get tasks => _tasks;

  /// Get pending tasks
  // List<TaskModel> get pendingTasks => _pendingTasks;
  List<TaskModel> get pendingTasks =>
      _tasks.where((t) => t.isCompleted == false).toList();

  /// Get completed tasks
  // List<TaskModel> get completedTasks => _completedTasks;
  List<TaskModel> get completedTasks =>
      _tasks.where((t) => t.isCompleted).toList();

  /// Get overdue tasks
  // List<TaskModel> get overdueTasks => _overdueTasks;
  List<TaskModel> get overdueTasks => _tasks
      .where((t) => !t.isCompleted && t.endDate.isBefore(DateTime.now()))
      .toList();

  /// Get tasks due today
  // List<TaskModel> get tasksDueToday => _tasksDueToday;
  List<TaskModel> get tasksDueToday {
    final now = DateTime.now();
    return _tasks
        .where(
          (t) =>
              t.endDate.year == now.year &&
              t.endDate.month == now.month &&
              t.endDate.day == now.day,
        )
        .toList();
  }

  /// Get sort filter of Task
  String get sortBy => _sortBy;

  /// Get filtered tasks based on current filter
  List<TaskModel> get filteredTasks {
    List<TaskModel> result;
    switch (_currentFilter) {
      case TaskFilter.all:
        result = List.of(_tasks);
      case TaskFilter.pending:
        result = pendingTasks;
      case TaskFilter.completed:
        result = completedTasks;
      case TaskFilter.overdue:
        result = overdueTasks;
      case TaskFilter.dueToday:
        result = tasksDueToday;
    }
    return _sortTasks(result);
  }

  /// Check if loading
  bool get isLoading => _isLoading;

  /// Check if initial loading
  bool get isInitialLoading => _isInitialLoading;

  /// Get error message
  String? get errorMessage => _errorMessage;

  /// Check if has error
  bool get hasError => _errorMessage != null;

  /// Get current filter
  TaskFilter get currentFilter => _currentFilter;

  /// Get completion percentage
  double get completionPercentage {
    if (_tasks.isEmpty) return 0.0;
    return (completedTasks.length / _tasks.length) * 100;
  }

  /// Get Drawer Index
  ValueNotifier<int> get drawerIndex => _drawerIndex;

  /// Get TabView Index
  int get tabviewIndex => _tabviewIndex;

  /// Get Add Task popup card field error
  String get titleError => _titleError;
  String get descriptionError => _descriptionError;

  // ============================================================================
  // INITIALIZATION
  // ============================================================================

  /// Initialize provider with user ID
  ///
  /// [userId] - Current user ID
  /// [fromLocal] - Whether to load from local storage
  ///
  /// Fetches all tasks for the user
  Future<void> initialize() async {
    _userId = FirebaseAuth.instance.currentUser?.uid;
    if (_userId == null) {
      _isInitialLoading = false;
      notifyListeners();
      return;
    }
    _isInitialLoading = true;
    notifyListeners();

    try {
      // ✨ IMPROVED SYNC LOGIC: Robust ID-Based Two-Way Sync
      _tasks = await _taskRepository.performRobustSync(_userId!);

      // Check for overdue tasks and show daily notification if needed
      await NotificationService.checkAndNotifyOverdueTasks(_tasks);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isInitialLoading = false;
      notifyListeners();
    }
  }

  /// Load all tasks for current user
  ///
  /// [fromLocal] - If true, load from Hive; if false, load from Firestore
  Future<void> loadTasks() async {
    if (_userId == null) return;

    try {
      // Perform robust two-way sync
      _tasks = await _taskRepository.performRobustSync(_userId!);

      // Filter tasks into categories
      // await _filterTasks();
    } catch (e) {
      // Cloud failed → fall back to local
      try {
        _tasks = await _taskRepository.getAllTasks(_userId!, fromLocal: true);
      } catch (localErr) {
        _setError('Failed to load tasks: ${localErr.toString()}');
      }
    } finally {
      notifyListeners();
    }
  }

  /// Filter tasks into categories (pending, completed, overdue, due today)
  // Future<void> _filterTasks() async {
  //   if (_userId == null) return;
  //
  //   try {
  //     _pendingTasks = await _taskRepository.getPendingTasks(_userId!);
  //     _completedTasks = await _taskRepository.getCompletedTasks(_userId!);
  //     _overdueTasks = await _taskRepository.getOverdueTasks(_userId!);
  //     _tasksDueToday = await _taskRepository.getTasksDueToday(_userId!);
  //     notifyListeners();
  //   } catch (e) {
  //     debugPrint('Error filtering tasks: ${e.toString()}');
  //   }
  // }

  // ============================================================================
  // CREATE OPERATIONS
  // ============================================================================

  /// Create a new task
  ///
  /// [title] - Task title
  /// [description] - Task description
  /// [startDate] - Task start date
  /// [endDate] - Task end date
  /// [priority] - Task priority (1-3)
  /// [reminderAt] - Optional precision reminder datetime
  /// [category] - Optional category
  /// [context] - Optional context for localized errors
  ///
  /// Returns: true if successful, false otherwise
  Future<bool> createTask({
    required String title,
    required String? description,
    required DateTime endDate,
    TaskPriority priority = TaskPriority.medium,
    DateTime? startDate,
    DateTime? reminderAt,
    TaskCategory category = TaskCategory.other,
  }) async {
    if (_userId == null) {
      _setError('User not logged in');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      // Create task model
      final task = TaskModel(
        id: _uuid.v4(),
        title: title,
        description: description,
        userId: _userId!,
        startDate: DateTime.now(),
        endDate: endDate,
        priority: priority,
        reminderAt: reminderAt,
        category: category,
        createdAt: DateTime.now(),
        completedAt: null,
        isCompleted: false,
      );

      // Save task
      await _taskRepository.createTask(task);

      // Schedule notification if task has reminder
      if (task.hasReminder) {
        await NotificationService.scheduleTaskReminder(task);
      }

      // Reload tasks
      await loadTasks();

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // ============================================================================
  // UPDATE OPERATIONS
  // ============================================================================

  /// Update an existing task
  ///
  /// [taskId] - Task ID to update
  /// [title] - Updated title (optional)
  /// [description] - Updated description (optional)
  /// [startDate] - Updated start date (optional)
  /// [endDate] - Updated end date (optional)
  /// [priority] - Updated priority (optional)
  /// [reminderAt] - Updated reminder datetime (optional)
  /// [category] - Updated category (optional)
  /// [context] - Optional context for localized errors
  ///
  /// Returns: true if successful, false otherwise
  Future<bool> updateTask({required TaskModel updatedTask}) async {
    _setLoading(true);
    _clearError();
    notifyListeners();

    try {
      // Find old task to check if completion status changed
      final oldTaskIndex = _tasks.indexWhere((t) => t.id == updatedTask.id);
      final oldTask = oldTaskIndex != -1 ? _tasks[oldTaskIndex] : updatedTask;
      final bool newlyCompleted =
          !oldTask.isCompleted && updatedTask.isCompleted;
      final bool newlyIncomplete =
          oldTask.isCompleted && !updatedTask.isCompleted;

      // Save updated task
      await _taskRepository.updateTask(updatedTask);

      // Handle Task Status Toggles
      if (newlyCompleted) {
        await _taskRepository.completedTaskCount(updatedTask.userId, true);
        await NotificationService.cancelTaskReminder(updatedTask.id);
        onTaskCompleted?.call();
      } else if (newlyIncomplete) {
        await _taskRepository.completedTaskCount(updatedTask.userId, false);
        if (updatedTask.hasReminder) {
          await NotificationService.scheduleTaskReminder(updatedTask);
        }
      } else {
        // Status didn't change, just update the reminder if it has one
        if (updatedTask.hasReminder && !updatedTask.isCompleted) {
          await NotificationService.scheduleTaskReminder(updatedTask);
        } else {
          await NotificationService.cancelTaskReminder(updatedTask.id);
        }
      }

      // Reload tasks
      await loadTasks();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // ============================================================================
  // SORT OPERATIONS
  // ============================================================================

  List<TaskModel> _sortTasks(List<TaskModel> tasks) {
    switch (_sortBy) {
      case 'priority':
        tasks.sort((a, b) {
          final priorityOrder = {
            TaskPriority.high: 0,
            TaskPriority.medium: 1,
            TaskPriority.low: 2,
          };
          return (priorityOrder[a.priority] ?? 1).compareTo(
            priorityOrder[b.priority] ?? 1,
          );
        });
        break;
      case 'createdAt':
        tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'dueDate':
      default:
        tasks.sort((a, b) => a.endDate.compareTo(b.endDate));
    }
    return tasks;
  }

  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    notifyListeners();
  }

  // ============================================================================
  // TOGGLE OPERATIONS
  // ============================================================================

  Future<void> toggleTaskStatus(String taskId) async {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      final toggledTask = TaskModel(
        id: task.id,
        title: task.title,
        description: task.description,
        endDate: task.endDate,
        userId: task.userId,
        isCompleted: !task.isCompleted,
        createdAt: task.createdAt,
        priority: task.priority,
        startDate: task.startDate,
        reminderAt: task.reminderAt,
        category: task.category,
        completedAt: task.isCompleted ? null : DateTime.now(),
      );

      await updateTask(updatedTask: toggledTask);

      // If we just marked a task incomplete, check if we need to reverse the streak
      if (!toggledTask.isCompleted && task.completedAt != null) {
        final now = DateTime.now();
        if (task.completedAt!.year == now.year &&
            task.completedAt!.month == now.month &&
            task.completedAt!.day == now.day) {
          // It was completed today, we just marked it incomplete. Are there OTHER tasks completed today?
          final completedToday = completedTasks
              .where(
                (t) =>
                    t.id != taskId &&
                    t.completedAt != null &&
                    t.completedAt!.year == now.year &&
                    t.completedAt!.month == now.month &&
                    t.completedAt!.day == now.day,
              )
              .toList();

          if (completedToday.isEmpty) {
            onTaskIncomplete?.call(false);
          } else {
            onTaskIncomplete?.call(true);
          }
        }
      }
    }
  }

  // ============================================================================
  // DELETE OPERATIONS
  // ============================================================================

  /// Delete a task
  ///
  /// [taskId] - Task ID to delete
  /// [context] - Optional context for localized errors
  ///
  /// Returns: true if successful, false otherwise
  Future<bool> deleteTask(String taskId) async {
    _setLoading(true);
    _clearError();
    notifyListeners();

    try {
      // Cancel any scheduled notification
      await NotificationService.cancelTaskReminder(taskId);

      await _taskRepository.deleteTask(taskId);
      await loadTasks();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Delete all completed tasks
  ///
  /// Returns: Number of tasks deleted
  Future<int> deleteAllCompletedTasks() async {
    if (_userId == null) return 0;

    _setLoading(true);
    _clearError();

    try {
      final count = await _taskRepository.deleteAllCompletedTasks(_userId!);
      await loadTasks();
      _setLoading(false);
      return count;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return 0;
    }
  }

  /// Delete all tasks
  ///
  /// Returns: Number of tasks deleted
  Future<int> deleteAllTasks() async {
    if (_userId == null) return 0;

    _setLoading(true);
    _clearError();

    try {
      final count = await _taskRepository.deleteAllTasks(_userId!);
      await loadTasks();
      _setLoading(false);
      return count;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return 0;
    }
  }

  // ============================================================================
  // FILTER & SEARCH OPERATIONS
  // ============================================================================

  /// Set task filter
  ///
  /// [filter] - Filter to apply
  void setFilter(TaskFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  /// Search tasks by title
  ///
  /// [query] - Search query
  ///
  /// Returns: List of tasks matching query
  List<TaskModel> searchTasks(String query) {
    if (query.isEmpty) return _tasks;

    final lowerQuery = query.toLowerCase();
    return _tasks.where((task) {
      return task.title.toLowerCase().contains(lowerQuery) ||
          (task.description?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  /// Filter tasks by priority
  ///
  /// [priority] - Priority level (1-3)
  ///
  /// Returns: List of tasks with specified priority
  List<TaskModel> filterByPriority(int priority) {
    return _tasks.where((task) => task.priority.index == priority).toList();
  }

  /// Filter tasks by category
  ///
  /// [category] - Category name
  ///
  /// Returns: List of tasks in category
  List<TaskModel> filterByCategory(String category) {
    return _tasks.where((task) => task.category.name == category).toList();
  }

  /// Get tasks by date range
  ///
  /// [startDate] - Start date
  /// [endDate] - End date
  ///
  /// Returns: List of tasks within date range
  List<TaskModel> getTasksByDateRange(DateTime startDate, DateTime endDate) {
    return _tasks.where((task) {
      return task.startDate.isAfter(
            startDate.subtract(const Duration(days: 1)),
          ) &&
          task.endDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  // ============================================================================
  // STATISTICS
  // ============================================================================

  /// Get task statistics
  ///
  /// Returns: Map with task counts
  Future<Map<String, int>> getStatistics() async {
    if (_userId == null) {
      return {'total': 0, 'completed': 0, 'pending': 0, 'overdue': 0};
    }

    try {
      return await _taskRepository.getTaskStatistics(_userId!);
    } catch (e) {
      debugPrint('Error getting statistics: ${e.toString()}');
      return {'total': 0, 'completed': 0, 'pending': 0, 'overdue': 0};
    }
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Set error message
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _errorMessage = null;
    _titleError = "";
    _descriptionError = "";
  }

  /// Clear error manually
  void clearError() {
    _clearError();
    notifyListeners();
  }

  ///Set the Drawer Index
  void setDrawerIndex(int ind) {
    _drawerIndex.value = ind;
  }

  void setTabViewIndex(int ind) {
    _tabviewIndex = ind;
    notifyListeners();
  }

  void setTitleError(String msg) {
    _titleError = msg;
    notifyListeners();
  }

  void setDescriptionError(String msg) {
    _descriptionError = msg;
    notifyListeners();
  }

  /// Reset provider state
  void reset() {
    _tasks = [];
    _isLoading = false;
    _isInitialLoading = true;
    _errorMessage = null;
    _userId = null;
    _currentFilter = TaskFilter.all;
    NotificationService.cancelAllReminders();
    notifyListeners();
  }
}
