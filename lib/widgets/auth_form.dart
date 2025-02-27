import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AuthForm extends StatefulWidget {
  final String title;
  final String buttonText;
  final VoidCallback switchScreen;
  final Future<String?> Function(String email, String password) onSubmit;
  final Future<String?> Function()? onGoogleSignIn; // Google Sign-In callback

  const AuthForm({
    required this.title,
    required this.buttonText,
    required this.switchScreen,
    required this.onSubmit,
    this.onGoogleSignIn, // Optional for screens without Google Sign-In
    Key? key,
  }) : super(key: key);

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isGoogleLoading = false; // Track Google sign-in loading
  String? _errorMessage;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
    _controller.forward(from: 0);
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String? error = await widget.onSubmit(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (error != null) {
      _showError(error);
    }
  }

  void _googleSignIn() async {
    if (widget.onGoogleSignIn == null) return;

    setState(() => _isGoogleLoading = true);

    String? error = await widget.onGoogleSignIn!();

    setState(() => _isGoogleLoading = false);

    if (error != null) {
      _showError(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueGrey[900]!, Colors.blueGrey[700]!],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Tasker Title with Animation
              Text(
                "Tasker",
                style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ).animate().fade(duration: 500.ms).slideY(begin: -0.5, end: 0),

              SizedBox(height: 10),

              // Animated Form
              Card(
                elevation: 5,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.blueGrey[700],
                          ),
                        ),
                        SizedBox(height: 15),

                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: "Email",
                            prefixIcon: Icon(Icons.email, color: Colors.blueGrey[600]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Enter your email";
                            if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(value)) {
                              return "Invalid email format";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 12),

                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: Icon(Icons.lock, color: Colors.blueGrey[600]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.length < 6) return "Password must be at least 6 characters";
                            return null;
                          },
                        ),

                        SizedBox(height: 15),

                        // Error Message Animation
                        if (_errorMessage != null)
                          Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red),
                          )
                              .animate(controller: _controller)
                              .shake(duration: 500.ms, hz: 5)
                              .fadeOut(duration: 2.seconds, delay: 2.seconds),

                        SizedBox(height: 10),

                        // Animated Button & Loading Effect
                        _isLoading
                            ? SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.blueGrey[600],
                          ).animate().rotate(duration: 1.seconds).scale(delay: 200.ms),
                        )
                            : ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey[600],
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(widget.buttonText, style: TextStyle(fontSize: 16)),
                        ),

                        SizedBox(height: 10),

                        // Google Sign-In Button
                        if (widget.onGoogleSignIn != null)
                          _isGoogleLoading
                              ? CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.blueGrey[600],
                          ).animate().rotate(duration: 1.seconds).scale(delay: 200.ms)
                              : OutlinedButton.icon(
                            onPressed: _googleSignIn,
                            icon: Icon(Icons.login, color: Colors.blueGrey[600]),
                            label: Text(
                              "Sign in with Google",
                              style: TextStyle(color: Colors.blueGrey[700]),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.blueGrey[600]!),
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                          ),

                        SizedBox(height: 10),

                        TextButton(
                          onPressed: widget.switchScreen,
                          child: Text(
                            widget.buttonText == "Login"
                                ? "Don’t have an account? Register"
                                : "Already have an account? Login",
                            style: TextStyle(color: Colors.blueGrey[700]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fade(duration: 500.ms).slideY(begin: 0.5, end: 0),
            ],
          ),
        ),
      ),
    );
  }
}
