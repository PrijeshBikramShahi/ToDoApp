import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
// ignore: unused_import
import 'package:intl/intl.dart';
import '../../controllers/task_controller.dart';
import '../../core/routes/app_routes.dart';
import '../../models/task_model.dart';
import '../widgets/task_card.dart';
import '../widgets/task_stats_card.dart';
import '../widgets/empty_state_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TaskController taskController = Get.find<TaskController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => taskController.refresh(),
            tooltip: 'Refresh',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuSelection,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_cache',
                child: Row(
                  children: [
                    Icon(Icons.clear_all),
                    SizedBox(width: 8),
                    Text('Clear Cache'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (taskController.isLoading && taskController.tasks.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SpinKitWave(
                  color: Colors.blue,
                  size: 50.0,
                ),
                SizedBox(height: 16),
                Text(
                  'Loading tasks...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: taskController.refresh,
          child: CustomScrollView(
            slivers: [
              if (!taskController.isOnline)
                SliverToBoxAdapter(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: Colors.orange,
                    child: const Row(
                      children: [
                        Icon(Icons.cloud_off, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Offline - Using cached data',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),

              if (taskController.tasks.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TaskStatsCard(controller: taskController),
                  ),
                ),

              taskController.tasks.isEmpty
                  ? const SliverFillRemaining(
                      child: EmptyStateWidget(),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final task = taskController.tasks[index];
                          return Padding(
                            padding: EdgeInsets.only(
                              left: 16,
                              right: 16,
                              top: index == 0 ? 8 : 4,
                              bottom: index == taskController.tasks.length - 1 ? 100 : 4,
                            ),
                            child: TaskCard(
                              task: task,
                              onTap: () => _editTask(task),
                              onToggle: () => taskController.toggleTaskCompletion(task),
                              onDelete: () => _showDeleteConfirmation(context, task),
                            ),
                          );
                        },
                        childCount: taskController.tasks.length,
                      ),
                    ),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _handleMenuSelection(String value) {
    // ignore: unused_local_variable
    final TaskController taskController = Get.find<TaskController>();
    
    switch (value) {
      case 'clear_cache':
        _showClearCacheConfirmation();
        break;
    }
  }

  void _showClearCacheConfirmation() {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will remove all cached data. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.find<TaskController>().clearAllData();
              Get.snackbar(
                'Success',
                'Cache cleared successfully',
                backgroundColor: Colors.green,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, TaskModel task) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.find<TaskController>().deleteTask(task);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _addTask() {
    Get.toNamed(AppRoutes.addTask);
  }

  void _editTask(TaskModel task) {
    Get.toNamed(AppRoutes.editTask, arguments: task);
  }
}