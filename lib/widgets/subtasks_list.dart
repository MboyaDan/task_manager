import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/task_controller.dart';
import '../../models/task_model.dart';
import 'edit_subtask_dialog.dart';

class SubtasksList extends StatefulWidget {
  final Task task;
  const SubtasksList({Key? key, required this.task}) : super(key: key);

  @override
  _SubtasksListState createState() => _SubtasksListState();
}

class _SubtasksListState extends State<SubtasksList> {
  final TextEditingController _newSubtaskController = TextEditingController();

  @override
  void dispose() {
    _newSubtaskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskController = Provider.of<TaskController>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Subtasks", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          widget.task.subtasks.isEmpty
              ? const Text("No subtasks added yet.", style: TextStyle(fontStyle: FontStyle.italic))
              : ListView.builder(
            itemCount: widget.task.subtasks.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final subtask = widget.task.subtasks[index];
              return ListTile(
                key: ValueKey(subtask.id),
                leading: Checkbox(
                  value: subtask.isCompleted,
                  onChanged: (bool? value) {
                    taskController.toggleSubtaskCompletion(widget.task.id, subtask.id);
                  },
                ),
                title: Text(subtask.title),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => EditSubtaskDialog(
                            subtask: subtask,
                            onSave: (updatedTitle) {
                              final updatedSubtask = subtask.copyWith(title: updatedTitle);
                              taskController.updateSubtask(widget.task.id, updatedSubtask);
                            },
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => taskController.deleteSubtask(widget.task.id, subtask.id),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newSubtaskController,
                  decoration: const InputDecoration(hintText: 'Enter new subtask'),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  final newTitle = _newSubtaskController.text.trim();
                  if (newTitle.isNotEmpty) {
                    final newSubtask = SubTask(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: newTitle,
                    );
                    taskController.addSubtask(widget.task.id, newSubtask);
                    _newSubtaskController.clear();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
