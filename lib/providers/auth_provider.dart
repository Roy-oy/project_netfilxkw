import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  final _fireAuth = FirebaseAuth.instance;
  final formKey = GlobalKey<FormState>();
  
  bool isLogin = true;
  bool isLoading = false;
  String? errorMessage;
  
  String _email = '';
  String _password = '';
  
  String get email => _email;
  String get password => _password;
  
  void setEmail(String value) {
    _email = value;
    notifyListeners();
  }
  
  void setPassword(String value) {
    _password = value;
    notifyListeners();
  }
  
  void toggleAuthMode() {
    isLogin = !isLogin;
    errorMessage = null;
    notifyListeners();
  }

  Future<bool> submit() async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (isLogin) {
        await _fireAuth.signInWithEmailAndPassword(
          email: _email,
          password: _password,
        );
      } else {
        await _fireAuth.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );
      }
      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage = _getMessageFromErrorCode(e.code);
      return false;
    } catch (e) {
      errorMessage = 'An unexpected error occurred';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _fireAuth.signOut();
    notifyListeners();
  }

  String _getMessageFromErrorCode(String errorCode) {
    switch (errorCode) {
      case 'email-already-in-use':
        return 'Email is already registered';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password is too weak';
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      default:
        return 'Authentication failed';
    }
  }
}