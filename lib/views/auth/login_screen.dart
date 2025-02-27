import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/views/tasks/task_list_screen.dart';
import '../../controllers/auth_controller.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: () async {
                    setState(() => _isLoading = true);
                    String? error = await authController.signIn(
                      _emailController.text.trim(),
                      _passwordController.text.trim(),
                    );
                    setState(() => _isLoading = false);

                    if (error != null) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(error)));
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => TaskListScreen()),
                      ); // ✅ Fix reference
                    }
                  },
                  child: Text('Login'),
                ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () async {
                String? error = await authController.signInWithGoogle();
                if (error != null) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(error)));
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => TaskListScreen()),
                  );
                }
              },
              icon: Icon(Icons.login),
              label: Text('Sign in with Google'),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                  ),
              child: Text('Don’t have an account? Register'),
            ),
          ],
        ),
      ),
    );
  }
}
