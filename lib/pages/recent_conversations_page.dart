import 'dart:convert';

import 'package:banterhub/models/appwrite_conversations_model.dart';
import 'package:banterhub/models/appwrite_message.dart';
import 'package:banterhub/pages/conversation_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../providers/auth_provider.dart';
import '../services/appWrite_db_service.dart';
import '../services/navigation_service.dart';

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
          child: StreamBuilder<List<AppwriteConversationsSnippet>>(
            stream: AppWriteDBService.instance
                .getAppWriteUserConversation(_auth.user!.uid),
            builder: (_context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: SpinKitWanderingCubes(
                    color: Theme.of(context).primaryColor,
                    size: 50.0,
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No conversations found.'));
              }

              final conversations = snapshot.data!;
              return ListView.builder(
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  final convo = conversations[index];
                  // print("conversations: ${convo.lastMessage}");
                  return ListTile(
                    onTap: () {
                      NavigationService.instance.navigateToRoute(
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return ConversationPage(
                              conversationId: convo.conversationId,
                              receiverUserId: convo.id,
                              receiverImageUrl: convo.image,
                              receiverUserName: convo.name,
                            );
                          },
                        ),
                      );
                    },
                    title: Text(
                      convo.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      convo.type == AppwriteMessageType.Text
                          ? convo.lastMessage
                          : "Attachment: Image",
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    leading: _listTileLeadingWidget(convo.image),
                    trailing: _listTileTrailingWidget(convo.timeStamp),
                  );
                },
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
          "Last Message",
          style: TextStyle(
            fontSize: 10,
          ),
        ),
        Text(
          timeago.format(_lastMessageTimeStamp),
          style: TextStyle(
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
