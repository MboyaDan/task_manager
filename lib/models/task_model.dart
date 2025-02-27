import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class Task {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final Priority priority;

  @HiveField(4)
  final DateTime dueDate;

  @HiveField(5)
  bool isCompleted;

  @HiveField(6)
  final List<SubTask> subtasks;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.dueDate,
    this.isCompleted = false,
    required this.subtasks,
  });

  ///  Toggle task completion
  void toggleCompleted() {
    isCompleted = !isCompleted;
  }

  /// Convert Task to a Firestore-friendly Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.toString().split('.').last, // "low", "medium", "high"
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'subtasks': subtasks.map((s) => s.toMap()).toList(),
    };
  }

  ///Create Task from Firestore data
  factory Task.fromMap(Map<String, dynamic> map, String docId) {
    return Task(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      priority: _getPriorityFromString(map['priority'] ?? 'medium'),
      dueDate: DateTime.tryParse(map['dueDate'] ?? '') ?? DateTime.now(),
      isCompleted: map['isCompleted'] ?? false,
      subtasks: (map['subtasks'] as List?)?.map((s) => SubTask.fromMap(s)).toList() ?? [],
    );
  }

  ///  Helper method to get Priority from String
  static Priority _getPriorityFromString(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return Priority.low;
      case 'high':
        return Priority.high;
      default:
        return Priority.medium;
    }
  }

  /// Create a modified copy of Task
  Task copyWith({
    String? id,
    String? title,
    String? description,
    Priority? priority,
    DateTime? dueDate,
    bool? isCompleted,
    List<SubTask>? subtasks,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      subtasks: subtasks ?? this.subtasks,
    );
  }
}

///  Annotated Priority Enum for Hive
@HiveType(typeId: 1)
enum Priority {
  @HiveField(0)
  low,

  @HiveField(1)
  medium,

  @HiveField(2)
  high,
}

/// ✅ Fix: Ensure SubTask has a unique typeId
@HiveType(typeId: 2)
class SubTask {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  bool isCompleted;

  SubTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  void toggleCompleted() {
    isCompleted = !isCompleted;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
    };
  }

  factory SubTask.fromMap(Map<String, dynamic> map) {
    return SubTask(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}
