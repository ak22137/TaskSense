import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../services/api_service.dart';

// API Service Provider
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// Task List Provider
final taskListProvider = StateNotifierProvider<TaskListNotifier, AsyncValue<List<Task>>>((ref) {
  return TaskListNotifier(ref.read(apiServiceProvider));
});

class TaskListNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final ApiService _apiService;

  TaskListNotifier(this._apiService) : super(const AsyncValue.loading()) {
    loadTasks();
  }

  Future<void> loadTasks({
    String? status,
    String? category,
    String? priority,
    String? assignedTo,
  }) async {
    state = const AsyncValue.loading();
    try {
      final tasks = await _apiService.getTasks(
        status: status,
        category: category,
        priority: priority,
        assignedTo: assignedTo,
      );
      state = AsyncValue.data(tasks);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createTask(CreateTaskRequest request) async {
    try {
      await _apiService.createTask(request);
      await loadTasks();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTask(String id, UpdateTaskRequest request) async {
    try {
      await _apiService.updateTask(id, request);
      await loadTasks();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _apiService.deleteTask(id);
      await loadTasks();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refresh() async {
    await loadTasks();
  }
}

// Task Statistics Provider
final taskStatsProvider = FutureProvider<TaskStats>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  return await apiService.getTaskStats();
});

// Filter Providers
final statusFilterProvider = StateProvider<String?>((ref) => null);
final categoryFilterProvider = StateProvider<String?>((ref) => null);
final priorityFilterProvider = StateProvider<String?>((ref) => null);

// Filtered Tasks Provider
final filteredTasksProvider = Provider<AsyncValue<List<Task>>>((ref) {
  final tasks = ref.watch(taskListProvider);
  final statusFilter = ref.watch(statusFilterProvider);
  final categoryFilter = ref.watch(categoryFilterProvider);
  final priorityFilter = ref.watch(priorityFilterProvider);

  return tasks.whenData((taskList) {
    var filtered = taskList;

    if (statusFilter != null) {
      filtered = filtered.where((task) => task.status == statusFilter).toList();
    }
    if (categoryFilter != null) {
      filtered = filtered.where((task) => task.category == categoryFilter).toList();
    }
    if (priorityFilter != null) {
      filtered = filtered.where((task) => task.priority == priorityFilter).toList();
    }

    return filtered;
  });
});

// Search Query Provider
final searchQueryProvider = StateProvider<String>((ref) => '');

// Searched Tasks Provider
final searchedTasksProvider = Provider<AsyncValue<List<Task>>>((ref) {
  final filteredTasks = ref.watch(filteredTasksProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  if (searchQuery.isEmpty) {
    return filteredTasks;
  }

  return filteredTasks.whenData((taskList) {
    final query = searchQuery.toLowerCase();
    return taskList.where((task) {
      return task.title.toLowerCase().contains(query) ||
          (task.description?.toLowerCase().contains(query) ?? false) ||
          (task.assignedTo?.toLowerCase().contains(query) ?? false);
    }).toList();
  });
});
