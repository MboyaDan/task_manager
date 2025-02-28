import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/task_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../models/task_model.dart';
import 'task_add_edit_screen.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskController>(context, listen: false).refreshTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context, listen: false);
    final themeController = Provider.of<ThemeController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Task Manager'),
        actions: [
          IconButton(
            icon: Icon(themeController.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: () => themeController.toggleTheme(),
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await authController.signOut();
            },
          ),
        ],
      ),
      body: _buildTaskScreen(context),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          Provider.of<TaskController>(context, listen: false).refreshTasks();
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.task), label: "All Tasks"),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: "Completed"),
          BottomNavigationBarItem(icon: Icon(Icons.priority_high), label: "Priority"),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TaskEditScreen()),
          ).then((_) => Provider.of<TaskController>(context, listen: false).refreshTasks());
        },
        child: Icon(Icons.add),
      )
          : null,
    );
  }

  Widget _buildTaskScreen(BuildContext context) {
    final taskController = Provider.of<TaskController>(context);
    List<Task> tasks;

    switch (_selectedIndex) {
      case 1:
        tasks = taskController.tasks.where((task) => task.isCompleted).toList();
        break;
      case 2:
        tasks = taskController.tasks.where((task) => task.priority == Priority.high).toList();
        break;
      default:
        tasks = taskController.filteredTasks;
    }

    return CustomScrollView(
      slivers: [
        if (_selectedIndex == 0)
          SliverAppBar(
            floating: true,
            pinned: false,
            flexibleSpace: Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                onChanged: (query) => taskController.filterTasks(query),
                decoration: InputDecoration(
                  labelText: "Search Tasks",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ),
        tasks.isEmpty
            ? SliverFillRemaining(
          child: Center(child: Text("No tasks found")),
        )
            : SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) => TaskCard(task: tasks[index]),
            childCount: tasks.length,
          ),
        ),
      ],
    );
  }
}

class TaskCard extends StatefulWidget {
  final Task task;
  TaskCard({required this.task});

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final taskController = Provider.of<TaskController>(context, listen: false);

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.task.title,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  _buildPriorityIndicator(widget.task.priority),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.task.description, style: TextStyle(fontSize: 14)),
                  SizedBox(height: 5),
                  Text(
                    "Due: ${widget.task.dueDate.toLocal().toString().split(' ')[0]}",
                    style: TextStyle(color: Colors.red),
                  ),
                  SizedBox(height: 5),
                  Text(
                    widget.task.isCompleted ? "Completed" : "Pending",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: widget.task.isCompleted ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: widget.task.isCompleted,
                    onChanged: (bool? value) {
                      taskController.toggleTaskCompletion(widget.task.id);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskEditScreen(task: widget.task),
                        ),
                      ).then((_) => taskController.refreshTasks());
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => taskController.deleteTask(widget.task.id),
                  ),
                ],
              ),
            ),
            if (widget.task.subtasks.isNotEmpty)
              _buildSubtasks(widget.task),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityIndicator(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Icon(Icons.priority_high, color: Colors.red);
      case Priority.medium:
        return Icon(Icons.warning, color: Colors.orange);
      case Priority.low:
        return Icon(Icons.low_priority, color: Colors.green);
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildSubtasks(Task task) {
    return ExpansionTile(
      title: Text("Subtasks (${task.subtasks.length})"),
      initiallyExpanded: _isExpanded,
      onExpansionChanged: (bool expanded) {
        setState(() => _isExpanded = expanded);
      },
      children: task.subtasks.map((subtask) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Checkbox(
                value: subtask.isCompleted,
                onChanged: (bool? value) {
                  // TODO: Handle subtask completion update
                },
              ),
              Expanded(child: Text(subtask.title)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
