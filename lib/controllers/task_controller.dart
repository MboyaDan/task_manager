import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class TaskController extends ChangeNotifier {
  final String currentUserId; // current logged-in user's ID
  late Box<Task> _taskBox;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];
  bool _isInitialized = false;

  List<Task> get tasks => _tasks;
  List<Task> get filteredTasks => _filteredTasks;

  TaskController({required this.currentUserId}) {
    _initialize();
  }

  /// Initialize Hive & sync with Firestore
  Future<void> _initialize() async {
    if (_isInitialized) return;
    try {
      _taskBox = Hive.isBoxOpen('tasks')
          ? Hive.box<Task>('tasks')
          : await Hive.openBox<Task>('tasks');
      _loadTasks();
      _syncWithFirestore();
      _isInitialized = true;
    } catch (e) {
      debugPrint("Error initializing Hive: $e");
    }
  }

  void refreshTasks() {
    _loadTasks();
    notifyListeners();
  }

  /// Load tasks from Hive storage (only tasks belonging to the current user)
  void _loadTasks() {
    // If currentUserId is empty, clear tasks.
    if (currentUserId.isEmpty) {
      _tasks = [];
      _filteredTasks = [];
      notifyListeners();
      return;
    }
    _tasks = _taskBox.values.where((task) => task.userId == currentUserId).toList();
    _filteredTasks = List.from(_tasks);
    notifyListeners();
  }

  /// Sync tasks with Firestore in real time (filter by current user)
  void _syncWithFirestore() {
    // If no user is logged in, clear tasks and do not sync.
    if (currentUserId.isEmpty) {
      _tasks = [];
      _filteredTasks = [];
      notifyListeners();
      return;
    }
    _firestore
        .collection('tasks')
        .where('userId', isEqualTo: currentUserId)
        .snapshots()
        .listen((snapshot) {
      final newTasks =
      snapshot.docs.map((doc) => Task.fromMap(doc.data(), doc.id)).toList();
      for (var task in newTasks) {
        _taskBox.put(task.id, task);
      }
      _tasks = newTasks;
      _filteredTasks = List.from(_tasks);
      notifyListeners();
    }, onError: (error) {
      debugPrint("Error syncing with Firestore: $error");
    });
  }

  /// Add a new task
  Future<void> addTask(Task task) async {
    try {
      // Ensure the task's userId is set to the current user
      final newTask = task.copyWith(userId: currentUserId);
      await _taskBox.put(newTask.id, newTask);
      await _firestore
          .collection('tasks')
          .doc(newTask.id)
          .set(newTask.toMap(), SetOptions(merge: true));
      // Rely on Firestore snapshots to update _tasks—avoid manual insertion.
    } catch (error) {
      debugPrint("Error adding task: $error");
    }
  }

  /// Edit an existing task
  Future<void> editTask(String id, Task updatedTask) async {
    try {
      // Ensure userId remains set to currentUserId
      final taskToUpdate = updatedTask.copyWith(userId: currentUserId);
      await _taskBox.put(id, taskToUpdate);
      await _firestore.collection('tasks').doc(id).update(taskToUpdate.toMap());
      _tasks = _tasks.map((task) => task.id == id ? taskToUpdate : task).toList();
      _filteredTasks = List.from(_tasks);
      notifyListeners();
    } catch (error) {
      debugPrint("Error editing task: $error");
    }
  }

  /// Delete a task
  Future<void> deleteTask(String taskId) async {
    try {
      await _taskBox.delete(taskId);
      await _firestore.collection('tasks').doc(taskId).delete();
      _tasks.removeWhere((task) => task.id == taskId);
      _filteredTasks = List.from(_tasks);
      notifyListeners();
    } catch (error) {
      debugPrint("Error deleting task: $error");
    }
  }

  /// Toggle task completion
  Future<void> toggleTaskCompletion(String taskId) async {
    try {
      int index = _tasks.indexWhere((t) => t.id == taskId);
      if (index == -1) return;
      Task updatedTask = _tasks[index].toggleCompleted();
      await _taskBox.put(taskId, updatedTask);
      await _firestore
          .collection('tasks')
          .doc(taskId)
          .update({'isCompleted': updatedTask.isCompleted});
      _tasks[index] = updatedTask;
      _filteredTasks = List.from(_tasks);
      notifyListeners();
    } catch (error) {
      debugPrint("Error toggling task completion: $error");
    }
  }

  /// Toggle subtask completion
  Future<void> toggleSubtaskCompletion(String taskId, String subtaskId) async {
    try {
      int taskIndex = _tasks.indexWhere((t) => t.id == taskId);
      if (taskIndex == -1) return;
      Task task = _tasks[taskIndex];
      List<SubTask> updatedSubtasks = task.subtasks.map((subtask) {
        return subtask.id == subtaskId
            ? subtask.copyWith(isCompleted: !subtask.isCompleted)
            : subtask;
      }).toList();
      Task updatedTask = task.copyWith(subtasks: updatedSubtasks);
      await _taskBox.put(taskId, updatedTask);
      await _firestore.collection('tasks').doc(taskId).update({
        'subtasks': updatedSubtasks.map((s) => s.toMap()).toList(),
      });
      _tasks[taskIndex] = updatedTask;
      _filteredTasks = List.from(_tasks);
      notifyListeners();
    } catch (error) {
      debugPrint("Error toggling subtask completion: $error");
    }
  }

  /// Add a subtask to an existing task
  Future<void> addSubtask(String taskId, SubTask newSubtask) async {
    try {
      int taskIndex = _tasks.indexWhere((t) => t.id == taskId);
      if (taskIndex == -1) return;
      Task task = _tasks[taskIndex];
      List<SubTask> updatedSubtasks = List.from(task.subtasks)..add(newSubtask);
      Task updatedTask = task.copyWith(subtasks: updatedSubtasks);
      await _taskBox.put(taskId, updatedTask);
      await _firestore.collection('tasks').doc(taskId).update({
        'subtasks': updatedSubtasks.map((s) => s.toMap()).toList(),
      });
      _tasks[taskIndex] = updatedTask;
      _filteredTasks = List.from(_tasks);
      notifyListeners();
    } catch (error) {
      debugPrint("Error adding subtask: $error");
    }
  }

  /// Update (edit) a subtask of an existing task
  Future<void> updateSubtask(String taskId, SubTask updatedSubtask) async {
    try {
      int taskIndex = _tasks.indexWhere((t) => t.id == taskId);
      if (taskIndex == -1) return;
      Task task = _tasks[taskIndex];
      List<SubTask> updatedSubtasks = task.subtasks.map((subtask) {
        return subtask.id == updatedSubtask.id ? updatedSubtask : subtask;
      }).toList();
      Task updatedTask = task.copyWith(subtasks: updatedSubtasks);
      await _taskBox.put(taskId, updatedTask);
      await _firestore.collection('tasks').doc(taskId).update({
        'subtasks': updatedSubtasks.map((s) => s.toMap()).toList(),
      });
      _tasks[taskIndex] = updatedTask;
      _filteredTasks = List.from(_tasks);
      notifyListeners();
    } catch (error) {
      debugPrint("Error updating subtask: $error");
    }
  }

  /// Delete a subtask from an existing task
  Future<void> deleteSubtask(String taskId, String subtaskId) async {
    try {
      int taskIndex = _tasks.indexWhere((t) => t.id == taskId);
      if (taskIndex == -1) return;
      Task task = _tasks[taskIndex];
      List<SubTask> updatedSubtasks =
      task.subtasks.where((s) => s.id != subtaskId).toList();
      Task updatedTask = task.copyWith(subtasks: updatedSubtasks);
      await _taskBox.put(taskId, updatedTask);
      await _firestore.collection('tasks').doc(taskId).update({
        'subtasks': updatedSubtasks.map((s) => s.toMap()).toList(),
      });
      _tasks[taskIndex] = updatedTask;
      _filteredTasks = List.from(_tasks);
      notifyListeners();
    } catch (error) {
      debugPrint("Error deleting subtask: $error");
    }
  }

  /// Search and filter tasks by query, completion status, or priority.
  void filterTasks(String query, {bool? isCompleted, Priority? priority}) {
    _filteredTasks = _tasks.where((task) {
      bool matchesQuery =
          query.isEmpty || task.title.toLowerCase().contains(query.toLowerCase());
      bool matchesCompletion =
          isCompleted == null || task.isCompleted == isCompleted;
      bool matchesPriority = priority == null || task.priority == priority;
      return matchesQuery && matchesCompletion && matchesPriority;
    }).toList();
    notifyListeners();
  }

  /// Clear all tasks
  Future<void> clearAllTasks() async {
    try {
      await _taskBox.clear();
      _tasks.clear();
      _filteredTasks.clear();
      notifyListeners();
    } catch (error) {
      debugPrint("Error clearing tasks: $error");
    }
  }
}
