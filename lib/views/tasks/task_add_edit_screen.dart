import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../controllers/task_controller.dart';
import '../../models/task_model.dart';

class TaskEditScreen extends StatefulWidget {
  final Task? task;

  TaskEditScreen({this.task});

  @override
  _TaskEditScreenState createState() => _TaskEditScreenState();
}

class _TaskEditScreenState extends State<TaskEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _dueDate;
  Priority _priority = Priority.medium;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');
    _dueDate = widget.task?.dueDate;
    _priority = widget.task?.priority ?? Priority.medium;
    _isCompleted = widget.task?.isCompleted ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final taskController = Provider.of<TaskController>(context, listen: false);
      final newTask = Task(
        id: widget.task?.id ?? UniqueKey().toString(), // Ensure ID is a String
        title: _titleController.text,
        description: _descriptionController.text,
        dueDate: _dueDate ?? DateTime.now(),
        priority: _priority,
        isCompleted: _isCompleted,
        subtasks: widget.task?.subtasks ?? [],
      );

      if (widget.task == null) {
        taskController.addTask(newTask);
      } else {
        taskController.editTask(newTask.id, newTask); // Ensure ID is passed as String
      }
      Navigator.pop(context);
    }
  }

  void _deleteTask() {
    if (widget.task != null) {
      final taskController = Provider.of<TaskController>(context, listen: false);
      taskController.deleteTask(widget.task!.id);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
        actions: [
          if (widget.task != null)
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteTask,
            ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) => value!.isEmpty ? 'Enter a title' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              SizedBox(height: 10),
              ListTile(
                title: Text(_dueDate == null
                    ? 'Pick Due Date'
                    : 'Due Date: ${DateFormat.yMMMd().format(_dueDate!)}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null) {
                    setState(() => _dueDate = picked);
                  }
                },
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<Priority>(
                value: _priority,
                onChanged: (priority) => setState(() => _priority = priority!),
                items: Priority.values.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(priority.toString().split('.').last),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Priority'),
              ),
              SizedBox(height: 10),
              SwitchListTile(
                title: Text('Mark as Completed'),
                value: _isCompleted,
                onChanged: (value) => setState(() => _isCompleted = value),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveTask,
                child: Text(widget.task == null ? 'Add Task' : 'Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
