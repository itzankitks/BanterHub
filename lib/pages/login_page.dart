// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:banterhub/services/snackbar_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import "../services/navigation_service.dart";

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late GlobalKey<FormState> _formKey;
  late AuthProvider _auth;

  late String _email;
  late String _password;

  _LoginPageState() {
    _formKey = GlobalKey<FormState>();
    _email = "";
    _password = "";
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: ChangeNotifierProvider<AuthProvider>.value(
          value: AuthProvider.instance,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: _deviceHeight,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: _deviceWidth * 0.1),
                child: IntrinsicHeight(
                  child: _loginPageUI(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _loginPageUI() {
    return Builder(
      builder: (BuildContext _context) {
        SnackBarService.instance.buildContext = _context;
        _auth = Provider.of<AuthProvider>(_context);
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _headingWidget(),
            _inputFields(),
            _logInPageButtons(),
          ],
        );
      },
    );
  }

  Widget _headingWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Welcome Back!",
          style: TextStyle(
            fontSize: _deviceWidth * 0.1,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Please Login to your account",
          style: TextStyle(
            fontSize: _deviceWidth * 0.04,
            fontWeight: FontWeight.w200,
          ),
        ),
      ],
    );
  }

  Widget _inputFields() {
    return Form(
      key: _formKey,
      onChanged: () {
        _formKey.currentState?.save();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _emailTextField(),
          SizedBox(height: 16),
          _passwordTextField(),
        ],
      ),
    );
  }

  Widget _emailTextField() {
    return TextFormField(
      autocorrect: false,
      style: const TextStyle(color: Colors.white),
      validator: (_input) {
        return _input!.isNotEmpty && _input.contains("@")
            ? null
            : "Please Enter a valid Email";
      },
      onSaved: (_input) {
        setState(() {
          _email = _input!;
        });
      },
      cursorColor: Colors.white,
      decoration: _textFieldDecoration(hintText: "Enter Your Email"),
    );
  }

  Widget _passwordTextField() {
    return TextFormField(
      autocorrect: false,
      obscureText: true,
      style: const TextStyle(color: Colors.white),
      validator: (_input) {
        return _input!.isNotEmpty ? null : "Please Enter a Password";
      },
      onSaved: (_input) {
        setState(() {
          _password = _input!;
        });
      },
      cursorColor: Colors.white,
      decoration: _textFieldDecoration(hintText: "Enter Your Password"),
    );
  }

  InputDecoration _textFieldDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        fontSize: 15,
        fontStyle: FontStyle.italic,
        color: Colors.grey,
      ),
      filled: true,
      fillColor: Colors.white10,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.white38, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  Widget _logInPageButtons() {
    return Column(
      children: [
        _logInButton(),
        SizedBox(height: 24),
        _registerButton(),
      ],
    );
  }

  Widget _logInButton() {
    return _auth.status == AuthStatus.Authenticating
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _auth.loginUserWithEmailAndPassword(_email, _password);
                }
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: _deviceHeight * 0.015),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: const Text(
                "LOGIN",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
          );
  }

  Widget _registerButton() {
    return GestureDetector(
      onTap: () {
        NavigationService.instance.navigateTo("register");
      },
      child: Center(
        child: Text(
          "REGISTER",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white60,
          ),
        ),
      ),
    );
  }
}
