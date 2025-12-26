import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/task_model.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectionTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors for logging and error handling
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  // Get all tasks with optional filters
  Future<List<Task>> getTasks({
    String? status,
    String? category,
    String? priority,
    String? assignedTo,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;
      if (category != null) queryParams['category'] = category;
      if (priority != null) queryParams['priority'] = priority;
      if (assignedTo != null) queryParams['assigned_to'] = assignedTo;

      final response = await _dio.get(
        '/tasks',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final List<dynamic> tasksJson = response.data['data'] as List<dynamic>;
        return tasksJson.map((json) => Task.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load tasks');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get a single task by ID with history
  Future<Task> getTaskById(String id) async {
    try {
      final response = await _dio.get('/tasks/$id');

      if (response.data['success'] == true) {
        return Task.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load task');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Create a new task
  Future<Task> createTask(CreateTaskRequest request) async {
    try {
      final response = await _dio.post(
        '/tasks',
        data: request.toJson(),
      );

      if (response.data['success'] == true) {
        return Task.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create task');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Update a task
  Future<Task> updateTask(String id, UpdateTaskRequest request) async {
    try {
      final response = await _dio.patch(
        '/tasks/$id',
        data: request.toJson(),
      );

      if (response.data['success'] == true) {
        return Task.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update task');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Delete a task
  Future<void> deleteTask(String id) async {
    try {
      final response = await _dio.delete('/tasks/$id');

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to delete task');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get task statistics
  Future<TaskStats> getTaskStats() async {
    try {
      final response = await _dio.get('/tasks/stats');

      if (response.data['success'] == true) {
        return TaskStats.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load statistics');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Error handler
  String _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        if (error.response?.data != null) {
          final data = error.response!.data;
          if (data is Map && data['message'] != null) {
            return data['message'] as String;
          }
        }
        return 'Server error: ${error.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request was cancelled';
      case DioExceptionType.connectionError:
        return 'No internet connection';
      default:
        return 'An unexpected error occurred';
    }
  }
}
