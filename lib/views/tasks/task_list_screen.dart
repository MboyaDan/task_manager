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
    final taskController = Provider.of<TaskController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Your Tasks' : 'Completed Tasks'),
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
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: _selectedIndex == 0
            ? _buildTaskList(taskController, false) // Incomplete tasks
            : _buildTaskList(taskController, true), // Completed tasks
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          Provider.of<TaskController>(context, listen: false).refreshTasks();
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.task), label: "Tasks"),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: "Completed"),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TaskEditScreen()),
          ).then((_) => taskController.refreshTasks());
        },
        child: Icon(Icons.add),
      )
          : null,
    );
  }

  Widget _buildTaskList(TaskController taskController, bool showCompleted) {
    List<Task> tasks = showCompleted
        ? taskController.tasks.where((task) => task.isCompleted).toList()
        : taskController.tasks.where((task) => !task.isCompleted).toList();

    return Column(
      children: [
        Padding(
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
        Expanded(
          child: tasks.isEmpty
              ? Center(child: Text(showCompleted ? "No completed tasks" : "No tasks available"))
              : ListView.builder(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              return TaskCard(task: tasks[index]);
            },
          ),
        ),
      ],
    );
  }
}

class TaskCard extends StatelessWidget {
  final Task task;
  TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final taskController = Provider.of<TaskController>(context, listen: false);
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          contentPadding: EdgeInsets.all(16),
          title: Text(
            task.title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(task.description, style: TextStyle(fontSize: 14)),
              SizedBox(height: 5),
              Text(
                "Due: ${task.dueDate.toLocal().toString().split(' ')[0]}",
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: task.isCompleted,
                onChanged: (bool? value) {
                  taskController.toggleTaskCompletion(task.id);
                },
              ),
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaskEditScreen(task: task),
                    ),
                  ).then((_) => taskController.refreshTasks());
                },
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => taskController.deleteTask(task.id),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
