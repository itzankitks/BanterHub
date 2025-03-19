// // ignore_for_file: constant_identifier_names, no_leading_underscores_for_local_identifiers, avoid_print

// import 'package:flutter/material.dart';
// import 'package:appwrite/appwrite.dart';
// import 'package:appwrite/models.dart' as models;
// import 'package:fluttertoast/fluttertoast.dart';

// import '../services/snackbar_service.dart';
// import '../services/navigation_service.dart';

// enum AuthStatus {
//   NotAuthenticated,
//   Authenticating,
//   Authenticated,
//   UserNotFound,
//   Error,
// }

// class AppWriteAuthProvider extends ChangeNotifier {
//   late AuthStatus status;
//   late models.User? user;
//   late Account _account;
//   late Client _client;

//   static AppWriteAuthProvider instance = AppWriteAuthProvider();

//   AppWriteAuthProvider() {
//     _client = Client()
//         .setEndpoint('https://cloud.appwrite.io/v1')
//         .setProject('67d0693f00204f5d1590');

//     _account = Account(_client);
//     status = AuthStatus.NotAuthenticated;

//     // Automatically check if user is already logged in
//     getCurrentUser();
//   }

//   /// ✅ Login with Email and Password
//   Future<void> loginUserWithEmailAndPassword(
//     String _email,
//     String _password,
//   ) async {
//     status = AuthStatus.Authenticating;
//     notifyListeners();

//     try {
//       await _account.createEmailPasswordSession(
//         email: _email,
//         password: _password,
//       );

//       user = await _account.get();
//       status = AuthStatus.Authenticated;

//       // ✅ Show Toast Message
//       Fluttertoast.showToast(
//         msg: "${user!.email} Logged In Successfully",
//       );

//       // ✅ Show Success SnackBar
//       SnackBarService.instance
//           .showSnackBarSuccess("Welcome, ${user!.email} to BanterHub");

//       // ✅ Navigate to home page
//       NavigationService.instance.navigateToReplacment("home");
//     } catch (e) {
//       status = AuthStatus.Error;
//       user = null;

//       // ✅ Show Error Message
//       Fluttertoast.showToast(
//         msg: "Error While Authenticating",
//       );

//       print("Login Error: $e");
//     }
//     notifyListeners();
//   }

//   /// ✅ Register with Email and Password
//   Future<void> registerUserWithEmailAndPassword(
//     String _email,
//     String _password,
//     String _name,
//     Function(String userId) onSuccess,
//   ) async {
//     status = AuthStatus.Authenticating;
//     notifyListeners();

//     try {
//       // ✅ Create User Account
//       models.User userAccount = await _account.create(
//         userId: ID.unique(),
//         email: _email,
//         password: _password,
//         name: _name,
//       );

//       // ✅ Automatically log in the user
//       await _account.createEmailPasswordSession(
//         email: _email,
//         password: _password,
//       );

//       user = await _account.get();
//       status = AuthStatus.Authenticated;

//       // ✅ Call the onSuccess function with userId
//       onSuccess(user!.$id);

//       // ✅ Show Success Message
//       SnackBarService.instance.showSnackBarSuccess("Welcome, ${user!.email}");

//       // ✅ Navigate to Home Page
//       NavigationService.instance.navigateToReplacment("home");
//     } catch (e) {
//       status = AuthStatus.Error;
//       user = null;

//       // ✅ Show Error Message
//       Fluttertoast.showToast(
//         msg: "Error Registering User",
//       );

//       print("Registration Error: $e");
//     }
//     notifyListeners();
//   }

//   /// ✅ Logout User
//   Future<void> logoutUser() async {
//     try {
//       await _account.deleteSession(sessionId: 'current');
//       user = null;
//       status = AuthStatus.NotAuthenticated;

//       // ✅ Navigate to Login Page
//       NavigationService.instance.navigateToReplacment("login");
//     } catch (e) {
//       print("Logout Error: $e");

//       // ✅ Show Error Toast
//       Fluttertoast.showToast(
//         msg: "Failed to logout",
//       );
//     }
//     notifyListeners();
//   }

//   /// ✅ Check if User is Already Logged In
//   Future<void> getCurrentUser() async {
//     try {
//       user = await _account.get();
//       status = AuthStatus.Authenticated;
//     } catch (e) {
//       user = null;
//       status = AuthStatus.NotAuthenticated;
//     }
//     notifyListeners();
//   }
// }
