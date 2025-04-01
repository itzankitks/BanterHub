// ignore_for_file: avoid_unnecessary_containers, no_leading_underscores_for_local_identifiers, sized_box_for_whitespace, unused_import, avoid_print

import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:banterhub/services/appWrite_cloud_storage_service.dart';
import 'package:banterhub/services/appWrite_db_service.dart';
import 'package:banterhub/services/db_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../providers/auth_provider.dart';
import '../services/navigation_service.dart';
import '../services/media_service.dart';
import '../services/cloud_storage_service.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late GlobalKey<FormState> _formKey;
  late AuthProvider _auth;

  late String _name;
  late String _email;
  late String _password;

  late File? _image;
  late Uint8List? _imageBytes; // For Web
  late String uploadedImageUrl;

  _RegistrationPageState() {
    _formKey = GlobalKey<FormState>();
    _image = null;
    _imageBytes = null;
    uploadedImageUrl = "";
    _name = "";
    _email = "";
    _password = "";
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        child: ChangeNotifierProvider<AuthProvider>.value(
          value: AuthProvider.instance,
          child: _registrationPageUI(),
        ),
      ),
    );
  }

  Widget _registrationPageUI() {
    return Builder(
      builder: (BuildContext _context) {
        _auth = Provider.of<AuthProvider>(_context);
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: _deviceHeight,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: _deviceWidth * 0.1,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 30,
                    ),
                    _headingWidget(),
                    _spacer(_deviceHeight * 0.03),
                    _inputFields(),
                    _spacer(_deviceHeight * 0.03),
                    _registerPageButtons(),
                    SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
              var pickedFile =
                  await MediaService.instance.uploadImage("gallery");

              if (pickedFile != null) {
                print("Something is selected: ${pickedFile.runtimeType}");

                if (kIsWeb) {
                  print("Here web");

                  try {
                    Uint8List bytes =
                        await pickedFile.readAsBytes(); // <-- Debug this line
                    print("Web Image Picked: ${bytes.length} bytes");

                    setState(() {
                      _imageBytes = bytes;
                      _image = null; // Ensure mobile image is null
                    });
                  } catch (e, stackTrace) {
                    print("Error while reading bytes: $e");
                    print(stackTrace);
                  }
                } else {
                  print("Here mobile");
                  print("Mobile Image Picked: ${pickedFile.path}");

                  setState(() {
                    _image = File(pickedFile.path);
                    _imageBytes = null; // Ensure web image is null
                  });
                }
              } else {
                print("No image was selected.");
              }
            },
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                    (_deviceWidth > _deviceHeight)
                        ? _deviceHeight / 5
                        : _deviceWidth / 5),
                child: (_image != null && !kIsWeb)
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
                    : (_imageBytes != null && kIsWeb)
                        ? Image.memory(
                            _imageBytes!,
                            width: (_deviceWidth > _deviceHeight)
                                ? _deviceHeight / 2.5
                                : _deviceWidth / 2.5,
                            height: (_deviceWidth > _deviceHeight)
                                ? _deviceHeight / 2.5
                                : _deviceWidth / 2.5,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            "assets/images/Upload-Image.png",
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
    return Form(
      key: _formKey,
      onChanged: () {
        _formKey.currentState?.save();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _nameTextField(),
          _spacer(16.0),
          _emailTextField(),
          _spacer(16.0),
          _passwordTextField(),
        ],
      ),
    );
    // return Column(
    //   children: [
    //     _nameTextField(),
    //     _spacer(16.0),
    //     _emailTextField(),
    //     _spacer(16.0),
    //     _passwordTextField(),
    //   ],
    // );
  }

  Widget _nameTextField() {
    return TextFormField(
      autocorrect: false,
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
      style: TextStyle(color: Colors.white),
      validator: (_input) {
        return _input!.isNotEmpty ? null : "Please Enter Name";
      },
      onSaved: (_input) {
        setState(() {
          _name = _input!;
        });
      },
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
      keyboardType: TextInputType.emailAddress,
      validator: (_input) {
        return _input!.isNotEmpty && _input.contains("@")
            ? null
            : "Please Enter Email";
      },
      onSaved: (_input) {
        setState(() {
          _email = _input!;
        });
      },
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
      onSaved: (_input) {
        setState(() {
          _password = _input!;
        });
      },
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
          _auth.status != AuthStatus.Authenticating
              ? Container(
                  height: (_deviceHeight > _deviceWidth)
                      ? _deviceHeight * 0.06
                      : _deviceWidth * 0.06,
                  width: _deviceWidth,
                  child: ElevatedButton(
                    onPressed: () async {
                      print("i pressed");

                      if (_formKey.currentState?.validate() == true) {
                        print("i am here");

                        if (_image == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please upload an image'),
                            ),
                          );
                          return;
                        }

                        print("photo is uploaded");

                        // ✅ Step 1: Register the user in Firebase
                        _auth.registerUserWithEmailAndPassword(
                          _email,
                          _password,
                          (String _uid) async {
                            // ✅ Step 2: Upload Image to Appwrite Storage
                            var _imageURL = await AppWriteStorageService
                                .instance
                                .uploadUserImageToAppWrite(_uid, _image!);

                            if (_imageURL == null) {
                              Fluttertoast.showToast(
                                  msg: "Image upload failed. Try again.");
                              _imageURL = "";
                            }

                            // ✅ Step 3: Create User in Appwrite Database
                            await AppWriteDBService.instance
                                .createUserInAppWriteDB(
                              _uid,
                              _name,
                              _email,
                              _imageURL.toString(),
                            );

                            Fluttertoast.showToast(
                                msg: "Registration Successful!");
                            print("✅ Registration Completed");
                          },
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text(
                      "Register",
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                    ),
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(),
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
