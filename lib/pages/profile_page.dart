import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/appWrite_db_service.dart';
import '../models/appwrite_contact.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ProfilePage extends StatelessWidget {
  final double height;
  final double width;

  late AuthProvider _auth;

  ProfilePage({super.key, required this.height, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _profilePageUI(),
      ),
    );
  }

  Widget _profilePageUI() {
    return Builder(
      builder: (BuildContext _context) {
        _auth = Provider.of<AuthProvider>(_context);
        return StreamBuilder<AppwriteContact>(
          stream:
              AppWriteDBService.instance.getAppWriteUserData(_auth.user!.uid),
          builder: (_context, _snapshot) {
            var _userData = _snapshot.data;
            return _snapshot.hasData
                ? Align(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      direction: Axis.vertical,
                      alignment: WrapAlignment.center,
                      spacing: 20, // Space between elements
                      runSpacing: 20, // Space between rows
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _userImageWidget(_userData!.image),
                        ),
                        _userNameWidget(_userData.name),
                        _userEmailWidget(_userData.email),
                        _logOutButton()
                      ],
                    ),
                  )
                : Center(
                    child: SpinKitWanderingCubes(
                      color: Theme.of(_context).primaryColor,
                      size: 50.0,
                    ),
                  );
            // if (_snapshot.connectionState == ConnectionState.waiting) {
            //   return Center(child: CircularProgressIndicator());
            // } else if (_snapshot.hasError) {
            //   return Text('Error: ${_snapshot.error}');
            // } else if (_snapshot.hasData) {
            //   final contact = _snapshot.data!;
            //   return Text(contact.name); // Show your contact data
            // } else {
            //   return Center(child: Text('No data available'));
            // }
          },
        );
      },
    );
  }

  Widget _userImageWidget(String _image) {
    return Container(
      height: height > width ? height * 0.35 : width * 0.25,
      width: height > width ? height * 0.35 : width * 0.25,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(_image),
          fit: BoxFit.cover,
        ),
        shape: BoxShape.circle,
        // color: Colors.red,
      ),
    );
  }

  Widget _userNameWidget(String _userName) {
    return Text(
      _userName,
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _userEmailWidget(String _userEmail) {
    return Text(
      _userEmail,
      style: TextStyle(
        fontSize: 15,
        color: Colors.grey,
      ),
    );
  }

  Widget _logOutButton() {
    return ElevatedButton(
      onPressed: () {
        _auth.logoutUser(() {});
      },
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        backgroundColor: Colors.red,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
        child: Text(
          "LOGOUT",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
