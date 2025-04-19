import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../services/appWrite_db_service.dart';
import '../providers/auth_provider.dart';
import 'package:banterhub/models/appwrite_contact.dart';

class SeacrhPage extends StatefulWidget {
  final double height;
  final double width;
  const SeacrhPage({super.key, required this.height, required this.width});

  @override
  State<SeacrhPage> createState() => _SeacrhPageState();
}

class _SeacrhPageState extends State<SeacrhPage> {
  late String _searchText;
  late AuthProvider _auth;

  _SeacrhPageState() {
    _searchText = '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      child: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _searchPageUI(),
      ),
    );
  }

  Widget _searchPageUI() {
    return Builder(
      builder: (BuildContext _context) {
        _auth = Provider.of<AuthProvider>(_context);
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _userSearchField(),
            Expanded(child: _userListView()),
          ],
        );
      },
    );
  }

  Widget _userSearchField() {
    return Container(
      height: widget.height > widget.width
          ? widget.height * 0.1
          : widget.width * 0.1,
      padding: EdgeInsets.symmetric(
        vertical: widget.width < widget.height
            ? widget.width * 0.03
            : widget.height * 0.02,
        horizontal: widget.width < widget.height
            ? widget.width * 0.04
            : widget.height * 0.08,
      ),
      child: TextField(
        autocorrect: false,
        keyboardType: TextInputType.name,
        textCapitalization: TextCapitalization.words,
        onSubmitted: (_input) {
          setState(() {
            _searchText = _input;
          });
        },
        style: TextStyle(color: Colors.white),
        textAlignVertical: TextAlignVertical.top,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white,
            applyTextScaling: true,
            size: 30,
          ),
          labelText: "Search",
          labelStyle: TextStyle(
            color: Colors.grey,
            fontStyle: FontStyle.italic,
            fontSize: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _userListView() {
    return StreamBuilder<List<AppwriteContact>>(
      stream: AppWriteDBService.instance.getUserInAppWriteDB(_searchText),
      builder: (_context, _snapshot) {
        var _usersData = _snapshot.data;

        return _snapshot.hasData
            ? Container(
                child: ListView.builder(
                  itemCount: _usersData!.length,
                  itemBuilder: (BuildContext _context, int _index) {
                    var _userData = _usersData[_index];
                    var _currentTime = DateTime.now();
                    var _isUserActive = !_userData.lastSeen.isBefore(
                      _currentTime.subtract(
                        Duration(seconds: 30),
                      ),
                    );
                    return ListTile(
                      minTileHeight: widget.height > widget.width
                          ? widget.height * 0.08
                          : widget.width * 0.08,
                      title: Text(
                        _userData.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      leading: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(_userData.image),
                            fit: BoxFit.cover,
                          ),
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        spacing: 2,
                        children: [
                          _isUserActive ? Text("Active Now") : Text("LastSeen"),
                          _isUserActive
                              ? Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              : Text(
                                  timeago.format(_userData.lastSeen),
                                ),
                        ],
                      ),
                    );
                  },
                ),
              )
            : Center(
                child: SpinKitWanderingCubes(
                  color: Theme.of(_context).primaryColor,
                  size: 50.0,
                ),
              );
      },
    );
  }
}
