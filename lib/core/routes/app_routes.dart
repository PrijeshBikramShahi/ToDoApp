import 'package:get/get.dart';
import '../../views/pages/home_page.dart';
import '../../views/pages/add_edit_task_page.dart';

/// Centralized route management for the application
/// Defines all routes and their corresponding pages
class AppRoutes {
  static const String home = '/';
  static const String addTask = '/add-task';
  static const String editTask = '/edit-task';

  /// List of all application routes
  static final routes = [
    GetPage(
      name: home,
      page: () => const HomePage(),
    ),
    GetPage(
      name: addTask,
      page: () => const AddEditTaskPage(),
    ),
    GetPage(
      name: editTask,
      page: () => const AddEditTaskPage(),
    ),
  ];
}