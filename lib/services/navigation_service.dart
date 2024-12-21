// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';

class NavigationService {
  late GlobalKey<NavigatorState> navigatorKey;

  static NavigationService instance = NavigationService();

  NavigationService() {
    navigatorKey = GlobalKey<NavigatorState>();
  }

  Future<dynamic> navigateToReplacment(String _routeName) {
    return navigatorKey.currentState!.pushReplacementNamed(_routeName);
  }

  Future<dynamic> navigateTo(String _routeName) {
    return navigatorKey.currentState!.pushNamed(_routeName);
  }

  Future<dynamic> navigateToRoute(MaterialPageRoute _route) {
    return navigatorKey.currentState!.push(_route);
  }

  bool goBack() {
    if (navigatorKey.currentState?.canPop() ?? false) {
      navigatorKey.currentState?.pop();
      return true;
    }
    return false;
  }
}
