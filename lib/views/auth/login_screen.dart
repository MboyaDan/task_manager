import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/auth_form.dart';
import 'register_screen.dart';
import '../tasks/task_list_screen.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthController>(
        builder: (context, authController, child) {
          if (authController.user != null) {
            Future.microtask(() {
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => TaskListScreen()),
                );
              }
            });
          }

          return AuthForm(
            title: "Login",
            buttonText: "Login",
            onSubmit: (email, password) => authController.signIn(email, password),
            onGoogleSignIn: () => authController.signInWithGoogle(),
            switchScreen: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => RegisterScreen()),
            ),
          );
        },
      ),
    );
  }
}
