import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../providers/auth_provider.dart';
import '../services/navigation_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _handleStartup();
  }

  Future<void> _handleStartup() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Schedule navigation after widget is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await authProvider.checkCurrentUserIsAuthenticated();

      if (authProvider.status == AuthStatus.Authenticated) {
        NavigationService.instance.navigateToReplacment("home");
      } else {
        NavigationService.instance.navigateToReplacment("login");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: const Center(
        child: SpinKitFadingCube(
          color: Colors.purpleAccent,
          size: 60.0,
        ),
      ),
    );
  }
}
