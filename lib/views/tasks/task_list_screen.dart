import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/task_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../models/task_model.dart';
import 'task_add_edit_screen.dart';
import '/widgets/task_card.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Refresh tasks after the first frame to ensure data is loaded.
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
        title: const Text('Task Manager'),
        actions: [
          IconButton(
            icon: Icon(themeController.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: () => themeController.toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async => await authController.signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_selectedIndex == 0) _buildSearchBar(),
          Expanded(child: _buildTaskList()),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TaskEditScreen()),
          ).then((_) => Provider.of<TaskController>(context, listen: false).refreshTasks());
        },
        child: const Icon(Icons.add),
      )
          : null,
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        onChanged: (query) => Provider.of<TaskController>(context, listen: false).filterTasks(query),
        decoration: InputDecoration(
          labelText: "Search Tasks",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    return Consumer<TaskController>(
      builder: (context, taskController, _) {
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

        if (tasks.isEmpty) {
          return const Center(child: Text("No tasks found"));
        }
        return ListView.separated(
          itemCount: tasks.length,
          separatorBuilder: (context, index) => const SizedBox(height: 4),
          itemBuilder: (context, index) => TaskCard(task: tasks[index]),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() => _selectedIndex = index);
        Provider.of<TaskController>(context, listen: false).refreshTasks();
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.task), label: "All Tasks"),
        BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: "Completed"),
        BottomNavigationBarItem(icon: Icon(Icons.priority_high), label: "Priority"),
      ],
    );
  }
}
