import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/task_controller.dart';
import '../../models/task_model.dart';
import 'package:task_manager/views/tasks/task_add_edit_screen.dart';
import 'subtasks_list.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  const TaskCard({Key? key, required this.task}) : super(key: key);

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  // You can default to false or true depending on your preference
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final taskController = Provider.of<TaskController>(context, listen: false);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          children: [
            ListTile(
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.task.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  _buildPriorityIndicator(widget.task.priority),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.task.description, style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 5),
                  Text(
                    "Due: ${widget.task.dueDate.toLocal().toString().split(' ')[0]}",
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.task.isCompleted ? "Completed" : "Pending",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: widget.task.isCompleted ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ),
              trailing: _buildTrailingActions(taskController),
            ),
            if (_isExpanded) SubtasksList(task: widget.task),
          ],
        ),
      ),
    );
  }

  Widget _buildTrailingActions(TaskController taskController) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: widget.task.isCompleted,
          onChanged: (bool? value) => taskController.toggleTaskCompletion(widget.task.id),
        ),
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TaskEditScreen(task: widget.task)),
            ).then((_) => taskController.refreshTasks());
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => taskController.deleteTask(widget.task.id),
        ),
        IconButton(
          icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
          onPressed: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPriorityIndicator(Priority priority) {
    switch (priority) {
      case Priority.high:
        return const Icon(Icons.priority_high, color: Colors.red);
      case Priority.medium:
        return const Icon(Icons.warning, color: Colors.orange);
      case Priority.low:
        return const Icon(Icons.low_priority, color: Colors.green);
      default:
        return const SizedBox.shrink();
    }
  }
}
