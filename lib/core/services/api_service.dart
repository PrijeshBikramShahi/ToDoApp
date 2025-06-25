import 'package:dio/dio.dart';
import '../../models/task_model.dart';

/// Service class for handling all API operations
/// Uses Dio for HTTP requests with interceptors for logging and error handling
class ApiService {
  late final Dio _dio;
  
  // Base URL for the REST API
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  // Note: Using JSONPlaceholder as a mock API since the example API isn't real
  // In production, replace with your actual API endpoint
  
  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
    ));
    
    _setupInterceptors();
  }

  /// Sets up Dio interceptors for logging, headers, and error handling
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add authorization header if needed
          // options.headers['Authorization'] = 'Bearer your_token_here';
          options.headers['Content-Type'] = 'application/json';
          options.headers['Accept'] = 'application/json';
          
          print('🚀 REQUEST: ${options.method} ${options.path}');
          print('📋 Headers: ${options.headers}');
          if (options.data != null) {
            print('📦 Data: ${options.data}');
          }
          
          handler.next(options);
        },
        onResponse: (response, handler) {
          print('✅ RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
          print('📄 Data: ${response.data}');
          handler.next(response);
        },
        onError: (error, handler) {
          print('❌ ERROR: ${error.type} ${error.message}');
          print('🔍 Response: ${error.response?.data}');
          handler.next(error);
        },
      ),
    );
  }

  /// Fetches all tasks from the API
  /// Returns a list of TaskModel objects
  Future<List<TaskModel>> getAllTasks() async {
    try {
      // Using JSONPlaceholder todos endpoint as mock data
      final response = await _dio.get('/todos');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => _mapJsonPlaceholderToTask(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch tasks',
        );
      }
    } catch (e) {
      print('Error fetching tasks: $e');
      rethrow;
    }
  }

  /// Creates a new task via API
  /// Returns the created TaskModel with server-assigned ID
  Future<TaskModel> createTask(TaskModel task) async {
    try {
      final response = await _dio.post(
        '/todos',
        data: _mapTaskToJsonPlaceholder(task),
      );
      
      if (response.statusCode == 201) {
        return _mapJsonPlaceholderToTask(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to create task',
        );
      }
    } catch (e) {
      print('Error creating task: $e');
      rethrow;
    }
  }

  /// Updates an existing task via API
  /// Returns the updated TaskModel
  Future<TaskModel> updateTask(TaskModel task) async {
    try {
      final response = await _dio.put(
        '/todos/${task.id}',
        data: _mapTaskToJsonPlaceholder(task),
      );
      
      if (response.statusCode == 200) {
        return _mapJsonPlaceholderToTask(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to update task',
        );
      }
    } catch (e) {
      print('Error updating task: $e');
      rethrow;
    }
  }

  /// Deletes a task via API
  /// Returns true if successful
  Future<bool> deleteTask(int taskId) async {
    try {
      final response = await _dio.delete('/todos/$taskId');
      
      if (response.statusCode == 200) {
        return true;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to delete task',
        );
      }
    } catch (e) {
      print('Error deleting task: $e');
      rethrow;
    }
  }

  /// Maps JSONPlaceholder response to TaskModel
  /// This is needed because JSONPlaceholder has different field names
  TaskModel _mapJsonPlaceholderToTask(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as int?,
      title: json['title'] as String,
      description: json['title'] as String, // JSONPlaceholder doesn't have description
      createdAt: DateTime.now(), // JSONPlaceholder doesn't have created_at
      isDone: json['completed'] as bool? ?? false,
    );
  }

  /// Maps TaskModel to JSONPlaceholder format
  Map<String, dynamic> _mapTaskToJsonPlaceholder(TaskModel task) {
    return {
      if (task.id != null) 'id': task.id,
      'title': task.title,
      'completed': task.isDone,
      'userId': 1, // Required by JSONPlaceholder
    };
  }
}