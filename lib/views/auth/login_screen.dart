import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/auth_form.dart';
import 'register_screen.dart';
import '../tasks/task_list_screen.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);

    return Scaffold(
      body: AuthForm(
        title: "Login",
        buttonText: "Login",
        onSubmit: (email, password) => authController.signIn(email, password),
        onGoogleSignIn: () => authController.signInWithGoogle(),
        switchScreen: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => RegisterScreen()),
        ),
      ),
    );
  }
}
