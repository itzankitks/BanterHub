// ignore_for_file: avoid_unnecessary_containers, no_leading_underscores_for_local_identifiers, sized_box_for_whitespace

import 'dart:io';

import 'package:flutter/material.dart';

import '../services/navigation_service.dart';
import "../services/media_service.dart";

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late GlobalKey<FormState> _formKey;

  late File? _image;

  _RegistrationPageState() {
    _formKey = GlobalKey<FormState>();
    _image = null;
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _registrationPageUI(),
          ),
        ),
      ),
    );
  }

  Widget _registrationPageUI() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 30,
          ),
          // Heading Section
          _headingWidget(),
          // Adding dynamic space between sections
          _spacer(_deviceHeight * 0.03),
          // Input Fields Section
          _inputFields(),
          _spacer(_deviceHeight * 0.03),
          // Register Button Section
          _registerPageButtons(),
          SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }

  Widget _headingWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Let's get going!",
          style: TextStyle(fontSize: 35, fontWeight: FontWeight.w800),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            "Please enter your details",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: GestureDetector(
            onTap: () async {
              File? _imageFile =
                  await MediaService.instance.uploadImage("gallery");
              setState(() {
                _image = _imageFile != null ? File(_imageFile.path) : null;
              });
            },
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                    (_deviceWidth > _deviceHeight)
                        ? _deviceHeight / 5
                        : _deviceWidth / 5),
                child: (_image != null)
                    ? Image.file(
                        _image!,
                        width: (_deviceWidth > _deviceHeight)
                            ? _deviceHeight / 2.5
                            : _deviceWidth / 2.5,
                        height: (_deviceWidth > _deviceHeight)
                            ? _deviceHeight / 2.5
                            : _deviceWidth / 2.5,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        "https://www.pngall.com/wp-content/uploads/2/Upload-PNG-Images.png",
                        width: (_deviceWidth > _deviceHeight)
                            ? _deviceHeight / 2.5
                            : _deviceWidth / 2.5,
                        height: (_deviceWidth > _deviceHeight)
                            ? _deviceHeight / 2.5
                            : _deviceWidth / 2.5,
                        fit: BoxFit.cover,
                        color: Colors.white70,
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _inputFields() {
    return Column(
      children: [
        _nameTextField(),
        _spacer(16.0),
        _emailTextField(),
        _spacer(16.0),
        _passwordTextField(),
      ],
    );
  }

  Widget _nameTextField() {
    return TextFormField(
      autocorrect: false,
      style: TextStyle(color: Colors.white),
      validator: (_input) {
        return _input!.isNotEmpty ? null : "Please Enter Name";
      },
      onSaved: (_input) {},
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: "Enter name",
        hintStyle: const TextStyle(
          fontSize: 15,
          fontStyle: FontStyle.italic,
          color: Colors.grey,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  Widget _emailTextField() {
    return TextFormField(
      autocorrect: false,
      style: TextStyle(color: Colors.white),
      validator: (_input) {
        return _input!.isNotEmpty && _input.contains("@")
            ? null
            : "Please Enter Email";
      },
      onSaved: (_input) {},
      cursorColor: Colors.black,
      decoration: InputDecoration(
        hintText: "Enter email",
        hintStyle: const TextStyle(
          fontSize: 15,
          fontStyle: FontStyle.italic,
          color: Colors.grey,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  Widget _passwordTextField() {
    return TextFormField(
      autocorrect: false,
      obscureText: true,
      style: TextStyle(color: Colors.white),
      validator: (_input) {
        return _input!.isNotEmpty ? null : "Please Enter Password";
      },
      onSaved: (_input) {},
      cursorColor: Colors.black,
      decoration: InputDecoration(
        hintText: "Enter password",
        hintStyle: const TextStyle(
          fontSize: 15,
          fontStyle: FontStyle.italic,
          color: Colors.grey,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  Widget _registerPageButtons() {
    return Center(
      child: Column(
        children: [
          Container(
            height: (_deviceHeight > _deviceWidth)
                ? _deviceHeight * 0.06
                : _deviceWidth * 0.06,
            width: _deviceWidth,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text("Register"),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: GestureDetector(
              onTap: () {
                NavigationService.instance.goBack();
              },
              child: Icon(
                Icons.arrow_back,
                size: 50,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _spacer(double height) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: height / 2),
    );
  }
}
