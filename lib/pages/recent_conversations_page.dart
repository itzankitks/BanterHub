import 'dart:convert';

import 'package:banterhub/models/appwrite_conversations_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../providers/auth_provider.dart';
import '../services/appWrite_db_service.dart';

class RecentConversationsPage extends StatefulWidget {
  final double height;
  final double width;

  const RecentConversationsPage(
      {super.key, required this.height, required this.width});

  @override
  State<RecentConversationsPage> createState() =>
      _RecentConversationsPageState();
}

class _RecentConversationsPageState extends State<RecentConversationsPage> {
  late AuthProvider _auth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _conversationListViewWidget(),
      ),
    );
  }

  Widget _conversationListViewWidget() {
    return Builder(
      builder: (BuildContext _context) {
        _auth = Provider.of<AuthProvider>(_context);
        return Container(
          height: widget.height,
          width: widget.width,
          color: Theme.of(context).scaffoldBackgroundColor,
          child: StreamBuilder<List<AppwriteConversations>>(
            stream: AppWriteDBService.instance
                .getAppWriteUserConversation(_auth.user!.uid),
            builder: (_context, _snapshot) {
              var _userConversationData = _snapshot.data;
              return _snapshot.hasData
                  ? ListView.builder(
                      itemCount: _userConversationData!.length,
                      itemBuilder: (_context, _index) {
                        return ListTile(
                          onTap: () {},
                          title: Text(
                            _userConversationData[_index].name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: Text(
                            _userConversationData[_index].lastMessage,
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          leading: _listTileLeadingWidget(
                            _userConversationData[_index].image,
                          ),
                          trailing: _listTileTrailingWidget(
                            _userConversationData[_index].timeStamp,
                          ),
                        );
                      },
                    )
                  : Center(
                      child: SpinKitWanderingCubes(
                        color: Theme.of(_context).primaryColor,
                        size: 50.0,
                      ),
                    );
            },
          ),
        );
      },
    );
  }

  Widget _listTileLeadingWidget(String _image) {
    return Container(
      height: 50,
      width: 50,
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

  Widget _listTileTrailingWidget(DateTime _lastMessageTimeStamp) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          timeago.format(_lastMessageTimeStamp),
          style: TextStyle(
            fontSize: 10,
          ),
        ),
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColorLight,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}
