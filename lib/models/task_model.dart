class TaskModel {
  final int? id;
  final String title;
  final String? description;
  final DateTime createdAt;
  final bool isDone;

  TaskModel({
    this.id,
    required this.title,
    this.description,
    required this.createdAt,
    this.isDone = false,
  });

  /// Creates a TaskModel from JSON data (from API response)
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as int?,
      title: json['title'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      isDone: json['is_done'] as bool? ?? false,
    );
  }

  /// Converts TaskModel to JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'is_done': isDone,
    };
  }

  /// Creates a copy of the task with updated properties
  TaskModel copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? createdAt,
    bool? isDone,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      isDone: isDone ?? this.isDone,
    );
  }

  @override
  String toString() {
    return 'TaskModel(id: $id, title: $title, description: $description, createdAt: $createdAt, isDone: $isDone)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskModel &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.createdAt == createdAt &&
        other.isDone == isDone;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        createdAt.hashCode ^
        isDone.hashCode;
  }
}