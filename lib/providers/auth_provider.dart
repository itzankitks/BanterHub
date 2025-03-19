// ignore_for_file: constant_identifier_names, no_leading_underscores_for_local_identifiers, avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../services/snackbar_service.dart';
import '../services/navigation_service.dart';

enum AuthStatus {
  NotAuthenticated,
  Authenticating,
  Authenticated,
  UserNotFound,
  Error,
}

class AuthProvider extends ChangeNotifier {
  late AuthStatus status;
  late User? user;
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
      Fluttertoast.showToast(
        msg: "${user!.email} Logged In Successfully",
      );
      SnackBarService.instance
          .showSnackBarSuccess("${user!.email} Logged In Successfully");
      SnackBarService.instance
          .showSnackBarSuccess("Welcome, ${user!.email} to BanterHub");
      // update lastSeen time
      // Navigate to the home page
      NavigationService.instance.navigateToReplacment("home");
    } catch (e) {
      status = AuthStatus.Error;
      // SnackBarService.instance.showSnackBarError("Error while Authenticating");
      user = null;
      Fluttertoast.showToast(
        msg: "Error While Authenticating",
      );
      print("login error");
      print('Failed to sign in: $e');
    }
    notifyListeners();
  }

  void registerUserWithEmailAndPassword(
    String _email,
    String _password,
    Future<void> onSuccess(String _uid),
  ) async {
    status = AuthStatus.Authenticating;
    notifyListeners();
    try {
      UserCredential _userCredential = await _auth
          .createUserWithEmailAndPassword(email: _email, password: _password);
      user = _userCredential.user!;
      status = AuthStatus.Authenticated;
      await onSuccess(user!.uid);
      SnackBarService.instance.showSnackBarError("Welcome, ${user!.email}");
      // update lastSeen time
      NavigationService.instance.goBack();
      // navigate to home page
      NavigationService.instance.navigateToReplacment("home");
    } catch (e) {
      status = AuthStatus.Error;
      user = null;
      // SnackBarService.instance.showSnackBarError("Error while Authenticating");
      Fluttertoast.showToast(
        msg: "Error Registering User",
      );
    }
    notifyListeners();
  }
}


// Fluttertoast.showToast(
//   msg: "Welcome to BanterHub",
//   toastLength: Toast.LENGTH_SHORT,
//   gravity: ToastGravity.BOTTOM,
//   backgroundColor: Colors.green,
//   textColor: Colors.white,
//   fontSize: 16.0,
// );