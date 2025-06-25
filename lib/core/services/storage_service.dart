import 'package:get_storage/get_storage.dart';
import '../../models/task_model.dart';

/// Service class for local storage operations
/// Uses GetStorage to cache tasks locally for offline functionality
class StorageService {
  late final GetStorage _storage;
  
  // Storage keys
  static const String _tasksKey = 'cached_tasks';
  static const String _lastSyncKey = 'last_sync_time';

  StorageService() {
    _storage = GetStorage();
  }

  /// Saves tasks to local storage
  /// Converts TaskModel objects to JSON for storage
  Future<void> saveTasks(List<TaskModel> tasks) async {
    try {
      final tasksJson = tasks.map((task) => task.toJson()).toList();
      await _storage.write(_tasksKey, tasksJson);
      await _storage.write(_lastSyncKey, DateTime.now().toIso8601String());
      print('📱 Saved ${tasks.length} tasks to local storage');
    } catch (e) {
      print('Error saving tasks to storage: $e');
    }
  }

  /// Loads tasks from local storage
  /// Returns cached tasks or empty list if none exist
  List<TaskModel> loadTasks() {
    try {
      final tasksJson = _storage.read(_tasksKey) as List<dynamic>?;
      if (tasksJson != null) {
        final tasks = tasksJson
            .map((json) => TaskModel.fromJson(json as Map<String, dynamic>))
            .toList();
        print('📱 Loaded ${tasks.length} tasks from local storage');
        return tasks;
      }
    } catch (e) {
      print('Error loading tasks from storage: $e');
    }
    return [];
  }

  /// Gets the last sync time
  DateTime? getLastSyncTime() {
    try {
      final syncTimeString = _storage.read(_lastSyncKey) as String?;
      if (syncTimeString != null) {
        return DateTime.parse(syncTimeString);
      }
    } catch (e) {
      print('Error getting last sync time: $e');
    }
    return null;
  }

  /// Clears all cached data
  Future<void> clearCache() async {
    try {
      await _storage.remove(_tasksKey);
      await _storage.remove(_lastSyncKey);
      print('📱 Cleared local storage cache');
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  /// Checks if there are cached tasks available
  bool hasCachedTasks() {
    return _storage.hasData(_tasksKey);
  }
}