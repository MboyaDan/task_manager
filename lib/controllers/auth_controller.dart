import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  UserModel? _user;

  AuthController() {
    //Listen for authentication state changes
    _auth.authStateChanges().listen((User? user) {
      _setUser(user);
    });
  }

  UserModel? get user => _user;

  /// Returns the current user's UID.
  /// This getter assumes the user is logged in.
  String get userId {
    if (_user == null) {
      throw Exception("User not logged in");
    }
    return _user!.uid;
  }

  void _setUser(User? user) {
    _user = user != null ? UserModel(uid: user.uid, email: user.email ?? '') : null;
    notifyListeners();
  }

  String _getFriendlyErrorMessage(String code) {
    switch (code) {
      case "invalid-credential":
        return "Invalid email or password.";
      case "user-not-found":
        return "No account found with this email.";
      case "wrong-password":
        return "Incorrect password.";
      case "email-already-in-use":
        return "This email is already in use. Try logging in.";
      case "weak-password":
        return "Password should be at least 6 characters.";
      case "network-request-failed":
        return "Check your internet connection.";
      default:
        return "An unexpected error occurred. Please try again.";
    }
  }

  // Sign Up with Email & Password
  Future<String?> signUp(String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _setUser(credential.user);
      return null; // No error
    } on FirebaseAuthException catch (e) {
      return _getFriendlyErrorMessage(e.code);
    } catch (e) {
      return "An unexpected error occurred. Please try again.";
    }
  }

  // Sign In with Email & Password
  Future<String?> signIn(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _setUser(credential.user);
      return null; // No error
    } on FirebaseAuthException catch (e) {
      return _getFriendlyErrorMessage(e.code);
    } catch (e) {
      return "An unexpected error occurred. Please try again.";
    }
  }

  // Google Sign-In
  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return "Google Sign-In canceled.";

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      _setUser(userCredential.user);
      return null; // No error
    } on FirebaseAuthException catch (e) {
      return _getFriendlyErrorMessage(e.code);
    } catch (e) {
      return "Google Sign-In failed. Please try again.";
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    _setUser(null);
  }
}
