import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/task_controller.dart';

/// Widget displaying task statistics and progress
/// Shows total, completed, and pending task counts with progress indicator
class TaskStatsCard extends StatelessWidget {
  final TaskController controller;

  const TaskStatsCard({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() => Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: theme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Task Overview',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${controller.completionPercentage.toStringAsFixed(0)}%',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: controller.totalTasks > 0 
                      ? controller.completedTasks / controller.totalTasks 
                      : 0,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Statistics row
            Row(
              children: [
                // Total tasks
                Expanded(
                  child: _StatItem(
                    icon: Icons.list_alt,
                    label: 'Total',
                    value: controller.totalTasks.toString(),
                    color: Colors.blue,
                  ),
                ),
                
                // Completed tasks
                Expanded(
                  child: _StatItem(
                    icon: Icons.check_circle,
                    label: 'Completed',
                    value: controller.completedTasks.toString(),
                    color: Colors.green,
                  ),
                ),
                
                // Pending tasks
                Expanded(
                  child: _StatItem(
                    icon: Icons.pending,
                    label: 'Pending',
                    value: controller.pendingTasks.toString(),
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ));
  }
}

/// Individual statistic item widget
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 28,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}