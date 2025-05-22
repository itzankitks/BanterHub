// ignore_for_file: unused_import, no_leading_underscores_for_local_identifiers, unused_local_variable

import 'package:banterhub/pages/splash_page.dart';
import 'package:banterhub/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:appwrite/appwrite.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'app_config.dart';

import './pages/login_page.dart';
import './pages/registration_page.dart';
import './pages/home_page.dart';
import './services/navigation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Client client = Client()
      .setEndpoint(AppConfig.appwriteEndpoint)
      .setProject(AppConfig.appwriteProjectId);
  Account account = Account(client);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
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
        primaryColorLight: Color.fromRGBO(182, 114, 199, 1),
        scaffoldBackgroundColor: Color.fromRGBO(28, 27, 27, 1),
      ).copyWith(
        textTheme: GoogleFonts.interTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      initialRoute: "splash",
      routes: {
        "splash": (BuildContext _context) => SplashPage(),
        "login": (BuildContext _context) => LoginPage(),
        "register": (BuildContext _context) => RegistrationPage(),
        "home": (BuildContext _context) => HomePage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
