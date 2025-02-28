import 'package:hive/hive.dart';

part 'task_model.g.dart';

/// ✅ Priority Enum for Hive Storage
@HiveType(typeId: 1)
enum Priority {
  @HiveField(0)
  low,

  @HiveField(1)
  medium,

  @HiveField(2)
  high,
}

/// ✅ SubTask Model (Ensures Unique typeId)
@HiveType(typeId: 2)
class SubTask {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final bool isCompleted;

  SubTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  /// ✅ Toggle completion (returns a new SubTask)
  SubTask toggleCompleted() => copyWith(isCompleted: !isCompleted);

  /// ✅ Create a modified copy of SubTask
  SubTask copyWith({String? id, String? title, bool? isCompleted}) {
    return SubTask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  /// ✅ Convert SubTask to Firestore-friendly Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
    };
  }

  /// ✅ Create SubTask from Firestore data
  factory SubTask.fromMap(Map<String, dynamic> map) {
    return SubTask(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}

/// ✅ Task Model
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
  final bool isCompleted;

  @HiveField(6)
  final List<SubTask> subtasks;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.dueDate,
    this.isCompleted = false,
    List<SubTask>? subtasks,
  }) : subtasks = List.unmodifiable(subtasks ?? []);

  /// ✅ Toggle task completion (returns a new Task)
  Task toggleCompleted() => copyWith(isCompleted: !isCompleted);

  /// ✅ Convert Task to Firestore-friendly Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.name, // "low", "medium", "high"
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'subtasks': subtasks.map((s) => s.toMap()).toList(),
    };
  }

  /// ✅ Create Task from Firestore data with improved safety
  factory Task.fromMap(Map<String, dynamic> map, String docId) {
    return Task(
      id: docId,
      title: map['title'] ?? 'Untitled Task',
      description: map['description'] ?? 'No description provided.',
      priority: Priority.values.firstWhere(
            (p) => p.name == (map['priority'] as String? ?? 'medium'),
        orElse: () => Priority.medium,
      ),
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : DateTime.now(),
      isCompleted: map['isCompleted'] as bool? ?? false,
      subtasks: (map['subtasks'] as List<dynamic>?)
          ?.map((s) => SubTask.fromMap(s as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  /// ✅ Create a modified copy of Task
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
      subtasks: subtasks != null ? List.unmodifiable(subtasks) : this.subtasks,
    );
  }

  /// ✅ Ensure unique Task comparisons
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is Task &&
              runtimeType == other.runtimeType &&
              id == other.id);

  @override
  int get hashCode => id.hashCode;
}
