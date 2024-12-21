// ignore_for_file: unused_import, no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import './pages/login_page.dart';
import './pages/registration_page.dart';
import './services/navigation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BanterHub',
      navigatorKey: NavigationService.instance.navigatorKey,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Color.fromRGBO(162, 65, 187, 1),
        scaffoldBackgroundColor: Color.fromRGBO(28, 27, 27, 1),
      ),
      initialRoute: "login",
      routes: {
        "login": (BuildContext _context) => LoginPage(),
        "register": (BuildContext _context) => RegistrationPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
