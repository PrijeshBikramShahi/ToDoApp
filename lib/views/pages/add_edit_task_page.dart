import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../controllers/task_controller.dart';
import '../../models/task_model.dart';

/// Page for adding new tasks or editing existing ones
/// Determines mode based on whether a task is passed as argument
class AddEditTaskPage extends StatefulWidget {
  const AddEditTaskPage({Key? key}) : super(key: key);

  @override
  State<AddEditTaskPage> createState() => _AddEditTaskPageState();
}

class _AddEditTaskPageState extends State<AddEditTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  late final TaskController _taskController;
  TaskModel? _editingTask;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _taskController = Get.find<TaskController>();
    
    // Check if we're editing an existing task
    final task = Get.arguments as TaskModel?;
    if (task != null) {
      _editingTask = task;
      _isEditing = true;
      _titleController.text = task.title;
      _descriptionController.text = task.description ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Task' : 'Add New Task'),
        actions: [
          // Save button in app bar
          Obx(() => _taskController.isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: SpinKitRing(
                      color: Colors.white,
                      size: 20,
                      lineWidth: 2,
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: _saveTask,
                  tooltip: 'Save',
                )),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Task title input
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  hintText: 'Enter task title',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a task title';
                  }
                  if (value.trim().length < 3) {
                    return 'Title must be at least 3 characters long';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.sentences,
                maxLength: 100,
              ),
              
              const SizedBox(height: 16),
              
              // Task description input
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Enter task description',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                maxLength: 500,
                textCapitalization: TextCapitalization.sentences,
              ),
              
              const SizedBox(height: 24),
              
              // Task status (only show when editing)
              if (_isEditing && _editingTask != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Task Status',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              _editingTask!.isDone 
                                  ? Icons.check_circle 
                                  : Icons.radio_button_unchecked,
                              color: _editingTask!.isDone 
                                  ? Colors.green 
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _editingTask!.isDone ? 'Completed' : 'Pending',
                              style: TextStyle(
                                color: _editingTask!.isDone 
                                    ? Colors.green 
                                    : Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              
              const Spacer(),
              
              // Save button
              Obx(() => ElevatedButton(
                onPressed: _taskController.isLoading ? null : _saveTask,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _taskController.isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SpinKitThreeBounce(
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 16),
                          Text('Saving...'),
                        ],
                      )
                    : Text(
                        _isEditing ? 'Update Task' : 'Create Task',
                        style: const TextStyle(fontSize: 16),
                      ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  /// Saves the task (create or update based on mode)
  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    bool success;
    
    if (_isEditing && _editingTask != null) {
      // Update existing task
      final updatedTask = _editingTask!.copyWith(
        title: title,
        description: description.isEmpty ? null : description,
      );
      success = await _taskController.updateTask(updatedTask);
    } else {
      // Create new task
      success = await _taskController.createTask(
        title: title,
        description: description.isEmpty ? null : description,
      );
    }

    if (success) {
      Get.back();
    }
  }
}