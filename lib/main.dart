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

  // ✅ Initialize Firebase
  await Firebase.initializeApp();

  // ✅ Initialize Hive
  await Hive.initFlutter();

  // ✅ Register Hive Adapters
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(PriorityAdapter());
  Hive.registerAdapter(SubTaskAdapter());

  // ✅ Open Hive Box Before Using It
  await Hive.openBox<Task>('tasks');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthController()), // ✅ Ensures AuthController is initialized
        ChangeNotifierProvider(create: (context) => ThemeController()),
        ChangeNotifierProvider(create: (context) => TaskController()),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: themeController.isDarkMode ? ThemeData.dark() : ThemeData.light(),
            home: AuthWrapper(), // ✅ Loads the correct screen based on user auth state
          );
        },
      ),
    );
  }
}
