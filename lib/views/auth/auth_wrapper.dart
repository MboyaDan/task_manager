import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../tasks/task_list_screen.dart';
import 'login_screen.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);

    return authController.user == null ? LoginScreen() : TaskListScreen();
  }
}
