import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'controllers/auth_controller.dart';
import 'controllers/theme_controller.dart';
import 'controllers/task_controller.dart';
import 'models/task_model.dart';
import 'views/auth/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  //Initialize Hive
  await Hive.initFlutter();

  // Register Hive Adapters BEFORE opening boxes
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(PriorityAdapter());
  Hive.registerAdapter(SubTaskAdapter());

  // Open Hive Boxes
  await Hive.openBox<Task>('tasks');
  await Hive.openBox<SubTask>('subtasks');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>(create: (_) => AuthController()),
        ChangeNotifierProvider<ThemeController>(create: (_) => ThemeController()),

        /// Provides TaskController with currentUserId from AuthController and rebuilds it when auth state changes.
        ChangeNotifierProxyProvider<AuthController, TaskController>(
          create: (context) => TaskController(
            currentUserId: Provider.of<AuthController>(context, listen: false).user?.uid ?? '',
          ),
          update: (context, authController, previousTaskController) =>
              TaskController(currentUserId: authController.user?.uid ?? ''),
        ),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: themeController.isDarkMode ? ThemeData.dark() : ThemeData.light(),
            home: AuthWrapper(),
          );
        },
      ),
    );
  }
}
