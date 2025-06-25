import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../models/task_model.dart';
import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';

/// Main controller for managing tasks and application state
/// Uses GetX for reactive state management
class TaskController extends GetxController {
  final ApiService _apiService;
  final StorageService _storageService;
  
  // Constructor with dependency injection
  TaskController({
    required ApiService apiService,
    required StorageService storageService,
  }) : _apiService = apiService, _storageService = storageService;

  // Reactive state variables
  final RxList<TaskModel> _tasks = <TaskModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isOnline = true.obs;
  final RxString _errorMessage = ''.obs;

  // Getters for accessing reactive state
  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading.value;
  bool get isOnline => _isOnline.value;
  String get errorMessage => _errorMessage.value;

  // Computed properties for task statistics
  int get totalTasks => _tasks.length;
  int get completedTasks => _tasks.where((task) => task.isDone).length;
  int get pendingTasks => _tasks.where((task) => !task.isDone).length;
  double get completionPercentage => 
      totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0.0;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  /// Loads initial data from cache first, then syncs with server
  Future<void> _loadInitialData() async {
    try {
      // Load cached tasks first for immediate UI feedback
      if (_storageService.hasCachedTasks()) {
        final cachedTasks = _storageService.loadTasks();
        _tasks.assignAll(cachedTasks);
        print('📱 Loaded ${cachedTasks.length} tasks from cache');
      }

      // Then try to sync with server
      await fetchTasks();
    } catch (e) {
      print('Error loading initial data: $e');
    }
  }

  /// Fetches all tasks from the API
  /// Handles network errors and offline scenarios
  Future<void> fetchTasks() async {
    try {
      _setLoading(true);
      _clearError();

      final fetchedTasks = await _apiService.getAllTasks();
      _tasks.assignAll(fetchedTasks);
      _isOnline.value = true;

      // Cache the fetched tasks
      await _storageService.saveTasks(fetchedTasks);
      
      print('✅ Fetched ${fetchedTasks.length} tasks from API');
    } on DioException catch (e) {
      _handleNetworkError(e);
    } catch (e) {
      _setError('An unexpected error occurred: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Creates a new task
  /// Optimistic update with rollback on failure
  Future<bool> createTask({
    required String title,
    String? description,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final newTask = TaskModel(
        title: title,
        description: description,
        createdAt: DateTime.now(),
      );

      // Optimistic update - add to local list first
      _tasks.insert(0, newTask);
      
      try {
        // Attempt to create on server
        final createdTask = await _apiService.createTask(newTask);
        
        // Replace the temporary task with the server response
        final index = _tasks.indexOf(newTask);
        if (index != -1) {
          _tasks[index] = createdTask;
        }
        
        // Update cache
        await _storageService.saveTasks(_tasks);
        
        Get.snackbar(
          'Success',
          'Task created successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        
        print('✅ Created task: ${createdTask.title}');
        return true;
        
      } catch (e) {
        // Rollback optimistic update
        _tasks.remove(newTask);
        throw e;
      }
      
    } on DioException catch (e) {
      _handleNetworkError(e);
      return false;
    } catch (e) {
      _setError('Failed to create task: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Updates an existing task
  /// Uses optimistic updates for better UX
  Future<bool> updateTask(TaskModel updatedTask) async {
    try {
      _setLoading(true);
      _clearError();

      // Find the task to update
      final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
      if (index == -1) {
        _setError('Task not found');
        return false;
      }

      final originalTask = _tasks[index];
      
      // Optimistic update
      _tasks[index] = updatedTask;
      
      try {
        // Attempt to update on server
        final serverUpdatedTask = await _apiService.updateTask(updatedTask);
        
        // Update with server response
        _tasks[index] = serverUpdatedTask;
        
        // Update cache
        await _storageService.saveTasks(_tasks);
        
        Get.snackbar(
          'Success',
          'Task updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        
        print('✅ Updated task: ${serverUpdatedTask.title}');
        return true;
        
      } catch (e) {
        // Rollback optimistic update
        _tasks[index] = originalTask;
        throw e;
      }
      
    } on DioException catch (e) {
      _handleNetworkError(e);
      return false;
    } catch (e) {
      _setError('Failed to update task: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Toggles the completion status of a task
  Future<bool> toggleTaskCompletion(TaskModel task) async {
    final updatedTask = task.copyWith(isDone: !task.isDone);
    return await updateTask(updatedTask);
  }

  /// Deletes a task
  /// Uses optimistic updates with rollback
  Future<bool> deleteTask(TaskModel task) async {
    try {
      _setLoading(true);
      _clearError();

      if (task.id == null) {
        _setError('Cannot delete task without ID');
        return false;
      }

      // Optimistic update - remove from local list
      final index = _tasks.indexOf(task);
      _tasks.remove(task);
      
      try {
        // Attempt to delete on server
        final success = await _apiService.deleteTask(task.id!);
        
        if (!success) {
          // Rollback if server deletion failed
          _tasks.insert(index, task);
          _setError('Failed to delete task on server');
          return false;
        }
        
        // Update cache
        await _storageService.saveTasks(_tasks);
        
        Get.snackbar(
          'Success',
          'Task deleted successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        
        print('✅ Deleted task: ${task.title}');
        return true;
        
      } catch (e) {
        // Rollback optimistic update
        _tasks.insert(index, task);
        throw e;
      }
      
    } on DioException catch (e) {
      _handleNetworkError(e);
      return false;
    } catch (e) {
      _setError('Failed to delete task: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Handles network errors and provides appropriate user feedback
  void _handleNetworkError(DioException error) {
    _isOnline.value = false;
    
    String message;
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.connectionError:
        message = 'No internet connection. Using cached data.';
        break;
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        message = 'Server error ($statusCode). Please try again later.';
        break;
      default:
        message = 'Network error occurred. Please try again.';
    }
    
    _setError(message);
    
    Get.snackbar(
      'Network Error',
      message,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  /// Sets loading state
  void _setLoading(bool loading) {
    _isLoading.value = loading;
  }

  /// Sets error message
  void _setError(String message) {
    _errorMessage.value = message;
  }

  /// Clears error message
  void _clearError() {
    _errorMessage.value = '';
  }

  /// Refreshes data from server
  Future<void> refresh() async {
    await fetchTasks();
  }

  /// Clears all local data and cache
  Future<void> clearAllData() async {
    _tasks.clear();
    await _storageService.clearCache();
    _clearError();
  }
}