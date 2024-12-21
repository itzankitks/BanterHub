// ignore_for_file: unnecessary_import, empty_constructor_bodies, no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SnackBarService {
  late BuildContext _buildContext;
  static SnackBarService instance = SnackBarService();

  SnackBarService() {}

  set buildContext(BuildContext _context) {
    _buildContext = _context;
  }

  void showSnackBarError(String _message) {
    ScaffoldMessenger.of(_buildContext).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 2),
        content: Text(
          _message,
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  void showSnackBarSuccess(String _message) {
    ScaffoldMessenger.of(_buildContext).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 2),
        content: Text(
          _message,
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }
}
