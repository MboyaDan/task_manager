import 'package:flutter/material.dart';
import '../../models/task_model.dart';

class EditSubtaskDialog extends StatelessWidget {
  final SubTask subtask;
  final void Function(String updatedTitle) onSave;

  const EditSubtaskDialog({
    Key? key,
    required this.subtask,
    required this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController editController = TextEditingController(text: subtask.title);
    return AlertDialog(
      title: const Text('Edit Subtask'),
      content: TextField(
        controller: editController,
        decoration: const InputDecoration(hintText: 'Subtask title'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final updatedTitle = editController.text.trim();
            if (updatedTitle.isNotEmpty) {
              onSave(updatedTitle);
            }
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
