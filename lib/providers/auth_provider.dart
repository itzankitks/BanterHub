// ignore_for_file: constant_identifier_names, no_leading_underscores_for_local_identifiers, avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/snackbar_service.dart';

enum AuthStatus {
  NotAuthenticated,
  Authenticating,
  Authenticated,
  UserNotFound,
  Error,
}

class AuthProvider extends ChangeNotifier {
  late AuthStatus status;
  late User user;
  late FirebaseAuth _auth;

  static AuthProvider instance = AuthProvider();

  AuthProvider() {
    _auth = FirebaseAuth.instance;
    status = AuthStatus.NotAuthenticated;
  }

  void loginUserWithEmailAndPassword(String _email, String _password) async {
    status = AuthStatus.Authenticating;
    // which where component is listeing to AuthProvider Class
    // The notify listerner will tell them that something changed
    notifyListeners();
    try {
      UserCredential _userCredential = await _auth.signInWithEmailAndPassword(
          email: _email, password: _password);
      user = _userCredential.user!;
      status = AuthStatus.Authenticated;
      SnackBarService.instance
          .showSnackBarSuccess("${user.email} Logged In Successfully");
      SnackBarService.instance.showSnackBarSuccess("Welcome to BanterHub");
      print("logged in successfully");
      // Navigate to the home page
      // Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      status = AuthStatus.Error;
      SnackBarService.instance.showSnackBarError("Error while Authenticating");
      // Fluttertoast.showToast(msg: "Error While Authenticating");
      print("login error");
      print('Failed to sign in: $e');
    }
    notifyListeners();
  }
}
