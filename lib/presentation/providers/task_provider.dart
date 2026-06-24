// ✨ NEW: Task state management provider
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
/// - Optimistic UI Updates (Instant local changes, background sync)
class TaskProvider with ChangeNotifier {
  final TaskRepository _taskRepository;
  final _uuid = const Uuid();
  StreamSubscription<List<TaskModel>>? _taskSubscription;

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
  
  /// Ensures we only trigger reschedule after initial data sync once
  bool _hasInitialSyncCompleted = false;

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

  @override
  void dispose() {
    _taskSubscription?.cancel();
    super.dispose();
  }

  /// Get all tasks
  List<TaskModel> get tasks => _tasks;

  /// Get pending tasks
  List<TaskModel> get pendingTasks =>
      _tasks.where((t) => t.isCompleted == false).toList();

  /// Get completed tasks
  List<TaskModel> get completedTasks =>
      _tasks.where((t) => t.isCompleted).toList();

  /// Get overdue tasks
  List<TaskModel> get overdueTasks => _tasks
      .where((t) => !t.isCompleted && t.endDate.isBefore(DateTime.now()))
      .toList();

  /// Get tasks due today
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
        break;
      case TaskFilter.pending:
        result = pendingTasks;
        break;
      case TaskFilter.completed:
        result = completedTasks;
        break;
      case TaskFilter.overdue:
        result = overdueTasks;
        break;
      case TaskFilter.dueToday:
        result = tasksDueToday;
        break;
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
  /// Listens to Firestore stream which instantly returns local cache then syncs
  Future<void> initialize() async {
    _userId = FirebaseAuth.instance.currentUser?.uid;
    final prefs = await SharedPreferences.getInstance();
    final savedIndex = prefs.getInt('fallback_tab_index');

    if (savedIndex != null) {
      setDrawerIndex(3);
    }

    if (_userId == null) {
      _isInitialLoading = false;
      _taskSubscription?.cancel();
      notifyListeners();
      return;
    }
    
    _isInitialLoading = true;
    _hasInitialSyncCompleted = false;
    notifyListeners();

    try {
      _taskSubscription?.cancel();
      _taskSubscription = _taskRepository.tasksStream(_userId!).listen(
        (tasks) async {
          _tasks = tasks;
          
          if (!_hasInitialSyncCompleted) {
            _hasInitialSyncCompleted = true;
            // ✨ NEW: Reschedule active reminders upon completing initial sync!
            await NotificationService.rescheduleActiveRemindersForCurrentUser();
          }
          
          await NotificationService.checkAndNotifyOverdueTasks(_tasks);
          
          _isInitialLoading = false;
          notifyListeners();
        },
        onError: (e) {
          _errorMessage = e.toString();
          _isInitialLoading = false;
          debugPrint('Stream error: $_errorMessage');
          notifyListeners();
        },
      );
    } catch (e) {
      _errorMessage = e.toString();
      _isInitialLoading = false;
      debugPrint('Error during initialization: $_errorMessage');
      notifyListeners();
    } finally {
      // Crucial: Clear it immediately so next clean launch defaults back to 0
      await prefs.remove('fallback_tab_index');
    }
  }

  /// Load all tasks for current user
  Future<void> loadTasks() async {
    if (_userId == null) return;
    // With streams, loadTasks is effectively handled automatically.
    // We can just rely on the stream.
  }

  // ============================================================================
  // CREATE OPERATIONS
  // ============================================================================

  /// Create a new task
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

      // APP FLOW: Save to Firestore instantly. Stream updates UI.
      await _taskRepository.createTask(task);
      debugPrint('createTask: Successfully created task: ${task.id}');

      if (task.hasReminder) {
        await NotificationService.scheduleTaskReminder(task);
      }
      return true;
    } catch (e) {
      _setError(e.toString());
      debugPrint('createTask: Error creating task: $e');
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
  /// Returns: true if successful, false otherwise
  Future<bool> updateTask({required TaskModel updatedTask}) async {
    _setLoading(true);
    _clearError();
    notifyListeners();

    try {
      final oldTaskIndex = _tasks.indexWhere((t) => t.id == updatedTask.id);
      final oldTask = oldTaskIndex != -1 ? _tasks[oldTaskIndex] : updatedTask;
      final bool newlyCompleted =
          !oldTask.isCompleted && updatedTask.isCompleted;
      final bool newlyIncomplete =
          oldTask.isCompleted && !updatedTask.isCompleted;

      // APP FLOW: Save locally immediately, syncs to cloud in background
      await _taskRepository.updateTask(updatedTask);
      debugPrint('updateTask: Successfully updated task: ${updatedTask.id}');

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
        if (updatedTask.hasReminder && !updatedTask.isCompleted) {
          await NotificationService.scheduleTaskReminder(updatedTask);
        } else {
          await NotificationService.cancelTaskReminder(updatedTask.id);
        }
      }
      return true;
    } catch (e) {
      _setError(e.toString());
      debugPrint('updateTask: Error updating task: $e');
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
    try {
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
          completedAt: !task.isCompleted ? DateTime.now() : null,
        );

        // APP FLOW: updateTask handles local save & firestore background sync
        await updateTask(updatedTask: toggledTask);
        debugPrint(
          'toggleTaskStatus: Successfully toggled task status for: $taskId',
        );

        if (!toggledTask.isCompleted && task.completedAt != null) {
          final now = DateTime.now();
          if (task.completedAt!.year == now.year &&
              task.completedAt!.month == now.month &&
              task.completedAt!.day == now.day) {
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
    } catch (e) {
      debugPrint('toggleTaskStatus: Error toggling task status: $e');
    } finally {
      notifyListeners();
    }
  }

  // ============================================================================
  // DELETE OPERATIONS
  // ============================================================================

  /// Delete a task
  Future<bool> deleteTask(String taskId) async {
    _setLoading(true);
    _clearError();
    notifyListeners();

    try {
      await NotificationService.cancelTaskReminder(taskId);

      // APP FLOW: Deletes locally instantly, schedules cloud delete in background
      await _taskRepository.deleteTask(taskId);
      debugPrint('deleteTask: Successfully deleted task: $taskId');

      return true;
    } catch (e) {
      _setError(e.toString());
      debugPrint('deleteTask: Error deleting task: $e');
      return false;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> updateNotificationPreference(bool enabled) async {
    try {
      await NotificationService.setNotificationEnabled(enabled);

      if (enabled) {
        await NotificationService.rescheduleActiveRemindersForCurrentUser();
        await NotificationService.checkAndNotifyOverdueTasks(_tasks);
      }
      debugPrint(
        'updateNotificationPreference: Successfully updated to $enabled',
      );
    } catch (e) {
      debugPrint(
        'updateNotificationPreference: Error updating notification preference: $e',
      );
    } finally {
      notifyListeners();
    }
  }

  /// Delete all completed tasks
  Future<int> deleteAllCompletedTasks() async {
    if (_userId == null) return 0;

    _setLoading(true);
    _clearError();
    notifyListeners();

    try {
      // APP FLOW: Deletes locally instantly, schedules cloud delete in background
      final count = await _taskRepository.deleteAllCompletedTasks(_userId!);
      debugPrint(
        'deleteAllCompletedTasks: Successfully deleted $count completed tasks',
      );

      return count;
    } catch (e) {
      _setError(e.toString());
      debugPrint('deleteAllCompletedTasks: Error deleting completed tasks: $e');
      return 0;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Delete all tasks
  Future<int> deleteAllTasks() async {
    if (_userId == null) return 0;

    _setLoading(true);
    _clearError();
    notifyListeners();

    try {
      // APP FLOW: Deletes locally instantly, schedules cloud batch delete in background
      final count = await _taskRepository.deleteAllTasks(_userId!);
      debugPrint('deleteAllTasks: Successfully deleted all $count tasks');

      return count;
    } catch (e) {
      _setError(e.toString());
      debugPrint('deleteAllTasks: Error deleting all tasks: $e');
      return 0;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // ============================================================================
  // FILTER & SEARCH OPERATIONS
  // ============================================================================

  void setFilter(TaskFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  List<TaskModel> searchTasks(String query) {
    if (query.isEmpty) return _tasks;

    final lowerQuery = query.toLowerCase();
    return _tasks.where((task) {
      return task.title.toLowerCase().contains(lowerQuery) ||
          (task.description?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  List<TaskModel> filterByPriority(int priority) {
    return _tasks.where((task) => task.priority.index == priority).toList();
  }

  List<TaskModel> filterByCategory(String category) {
    return _tasks.where((task) => task.category.name == category).toList();
  }

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

  Future<Map<String, int>> getStatistics() async {
    if (_userId == null) {
      return {'total': 0, 'completed': 0, 'pending': 0, 'overdue': 0};
    }

    try {
      final stats = await _taskRepository.getTaskStatistics(_userId!);
      debugPrint('getStatistics: Successfully fetched statistics');
      return stats;
    } catch (e) {
      debugPrint('getStatistics: Error getting statistics: $e');
      return {'total': 0, 'completed': 0, 'pending': 0, 'overdue': 0};
    }
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  void _setLoading(bool value) {
    _isLoading = value;
    // Note: Don't notifyListeners here directly to prevent redundant calls.
    // Callers are expected to call notifyListeners() in finally blocks.
  }

  void _setError(String error) {
    _errorMessage = error;
    // Callers will notifyListeners() in finally block
  }

  void _clearError() {
    _errorMessage = null;
    _titleError = "";
    _descriptionError = "";
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

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

  void reset() {
    try {
      _taskSubscription?.cancel();
      _tasks = [];
      _isLoading = false;
      _isInitialLoading = true;
      _errorMessage = null;
      _userId = null;
      _currentFilter = TaskFilter.all;
      _drawerIndex.value = 0;
      NotificationService.cancelAllReminders();
      debugPrint('reset: Successfully reset task provider state');
    } catch (e) {
      debugPrint('reset: Error resetting state: $e');
    } finally {
      notifyListeners();
    }
  }

  // Inside your Settings Screen (Index 3)
  Future<void> isSystemOpen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('fallback_tab_index', 3);
      debugPrint('isSystemOpen: Successfully set fallback tab index');
    } catch (e) {
      debugPrint('isSystemOpen: Error setting fallback index: $e');
    } finally {
      notifyListeners();
    }
  }
}
