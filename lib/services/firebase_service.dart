import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../models/task_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Box<Task> _taskBox = Hive.box<Task>('tasks');

  // Sync local tasks with Firestore
  Future<void> syncLocalTasksToCloud() async {
    for (var task in _taskBox.values) {
      await _db.collection("tasks").doc(task.id).set(task.toMap());
    }
  }

  // Add a task to both Hive and Firestore
  Future<void> addTask(Task task) async {
    _taskBox.put(task.id, task); // Save locally
    await _db.collection("tasks").doc(task.id).set(task.toMap()); // Save to Firestore
  }

  // Get tasks from Firestore
  Stream<List<Task>> getTasksFromCloud() {
    return _db.collection("tasks").snapshots().map(
          (snapshot) => snapshot.docs
          .map((doc) => Task.fromMap(doc.data(), doc.id))
          .toList(),
    );
  }

  // Update a task in both Hive and Firestore
  Future<void> updateTask(Task task) async {
    _taskBox.put(task.id, task);
    await _db.collection("tasks").doc(task.id).update(task.toMap());
  }

  // Delete a task from both Hive and Firestore
  Future<void> deleteTask(String taskId) async {
    _taskBox.delete(taskId);
    await _db.collection("tasks").doc(taskId).delete();
  }
}
