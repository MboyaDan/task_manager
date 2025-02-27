import 'package:hive/hive.dart';

part 'task_model.g.dart'; // Required for Hive type adapter

@HiveType(typeId: 0) // Registering model with Hive
class Task extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  DateTime dueDate;

  @HiveField(3)
  int priority; // 1 = High, 2 = Medium, 3 = Low

  @HiveField(4)
  bool isCompleted;

  Task({
    required this.title,
    required this.description,
    required this.dueDate,
    this.priority = 2,
    this.isCompleted = false,
  });
}
