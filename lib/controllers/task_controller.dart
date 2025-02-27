import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_manager/models/task_model.dart';

class TaskController extends ChangeNotifier {
  late Box<Task> _taskBox;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];

  List<Task> get tasks => _tasks;
  List<Task> get filteredTasks => _filteredTasks;

  TaskController() {
    _initialize();
  }

  /// ✅ Initialize Hive & Sync with Firestore
  Future<void> _initialize() async {
    _taskBox = await Hive.openBox<Task>('tasks');
    _loadTasks();
    _syncWithFirestore();
  }

  /// ✅ Load tasks from Hive
  void _loadTasks() {
    _tasks = _taskBox.values.toList();
    _filteredTasks = List.from(_tasks); // Ensure filtered list is also updated
    notifyListeners();
  }

  void refreshTasks() {
    _loadTasks(); // Reload tasks from Hive
    notifyListeners(); // Notify UI to update
  }

  /// ✅ Sync tasks with Firestore in real-time
  void _syncWithFirestore() {
    _firestore.collection('tasks').snapshots().listen((snapshot) {
      final newTasks = <Task>[];

      for (var doc in snapshot.docs) {
        Task task = Task.fromMap(doc.data(), doc.id);

        // ✅ Avoid redundant updates in Hive
        if (!_taskBox.containsKey(task.id)) {
          _taskBox.put(task.id, task);
        }

        newTasks.add(task);
      }

      _tasks = newTasks;
      _filteredTasks = List.from(_tasks);
      notifyListeners();
    }, onError: (error) {
      debugPrint("Error syncing with Firestore: $error");
    });
  }

  /// ✅ Add a new task
  Future<void> addTask(Task task) async {
    try {
      _tasks.add(task);
      _filteredTasks = List.from(_tasks);
      await _taskBox.put(task.id, task); // ✅ Save to Hive
      await _firestore.collection('tasks').doc(task.id).set(task.toMap(), SetOptions(merge: true)); // ✅ Sync to Firestore
      notifyListeners();
    } catch (error) {
      debugPrint("Error adding task: $error");
    }
  }

  /// ✅ Edit an existing task
  Future<void> editTask(String id, Task updatedTask) async {
    try {
      int index = _tasks.indexWhere((task) => task.id == id);
      if (index != -1) {
        _tasks[index] = updatedTask;
      }

      _filteredTasks = List.from(_tasks);
      await _taskBox.put(id, updatedTask); // ✅ Update in Hive
      await _firestore.collection('tasks').doc(id).update(updatedTask.toMap()); // ✅ Sync to Firestore
      notifyListeners();
    } catch (error) {
      debugPrint("Error editing task: $error");
    }
  }

  /// ✅ Delete a task
  Future<void> deleteTask(String taskId) async {
    try {
      _tasks.removeWhere((task) => task.id == taskId);
      _filteredTasks = List.from(_tasks);
      await _taskBox.delete(taskId); // ✅ Remove from Hive
      await _firestore.collection('tasks').doc(taskId).delete(); // ✅ Remove from Firestore
      notifyListeners();
    } catch (error) {
      debugPrint("Error deleting task: $error");
    }
  }

  /// ✅ Toggle task completion
  Future<void> toggleTaskCompletion(String taskId) async {
    try {
      int index = _tasks.indexWhere((task) => task.id == taskId);
      if (index != -1) {
        _tasks[index] = _tasks[index].copyWith(isCompleted: !_tasks[index].isCompleted);
        await _taskBox.put(taskId, _tasks[index]); // ✅ Save to Hive
        await _firestore.collection('tasks').doc(taskId).update({'isCompleted': _tasks[index].isCompleted}); // ✅ Sync to Firestore
        notifyListeners();
      }
    } catch (error) {
      debugPrint("Error toggling task completion: $error");
    }
  }

  /// ✅ Implement `filterTasks`
  void filterTasks(String query) {
    if (query.isEmpty) {
      _filteredTasks = List.from(_tasks);
    } else {
      _filteredTasks = _tasks.where((task) => task.title.toLowerCase().contains(query.toLowerCase())).toList();
    }
    notifyListeners();
  }

  /// ✅ Clear all tasks (for debugging purposes)
  Future<void> clearAllTasks() async {
    try {
      _tasks.clear();
      _filteredTasks.clear();
      await _taskBox.clear(); // ✅ Clear Hive storage
      notifyListeners();
    } catch (error) {
      debugPrint("Error clearing tasks: $error");
    }
  }
}
