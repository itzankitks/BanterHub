// ignore_for_file: unnecessary_cast, no_leading_underscores_for_local_identifiers

import 'dart:convert';

import 'package:appwrite/models.dart';
import 'package:banterhub/models/appwrite_message.dart';

class AppwriteConversationsSnippet {
  final String id;
  final String conversationId;
  final String lastMessage;
  final String name;
  final String image;
  final AppwriteMessageType? type;
  final int unseenCount;
  final DateTime timeStamp;

  AppwriteConversationsSnippet({
    required this.id,
    required this.conversationId,
    required this.lastMessage,
    required this.name,
    required this.image,
    this.type,
    required this.unseenCount,
    required this.timeStamp,
  });

  factory AppwriteConversationsSnippet.fromJson(Map<String, dynamic> json) {
    var _messageType = AppwriteMessageType.Text;
    if (json["type"] != null) {
      switch (json["type"]) {
        case 'text':
          // _messageType = AppwriteMessageType.Text;
          break;
        case 'image':
          _messageType = AppwriteMessageType.Image;
          break;
        default:
      }
    }
    return AppwriteConversationsSnippet(
      id: json["userId"] ?? '',
      conversationId: json["conversationId"] ?? '',
      lastMessage: json["lastMessage"] ?? '',
      name: json["name"] ?? 'Unknown',
      image: json["image"] ?? '',
      type: _messageType,
      unseenCount: json["unseenCount"] ?? 0,
      timeStamp: json["timeStamp"] != null
          ? DateTime.tryParse(json["timeStamp"]) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class AppwriteConversation {
  final String id;
  final List members;
  final List<AppwriteMessage> messages;
  final String ownerId;

  AppwriteConversation({
    required this.id,
    required this.members,
    required this.messages,
    required this.ownerId,
  });

  factory AppwriteConversation.fromAppwrite(Document _document) {
    var data = _document.data as Map<String, dynamic>;

    List<AppwriteMessage> _messages = [];
    if (data["messages"] != null) {
      _messages = (data["messages"] as List).map((msgStr) {
        final Map<String, dynamic> msg = jsonDecode(msgStr);
        final _messageType = msg["type"] == "text"
            ? AppwriteMessageType.Text
            : AppwriteMessageType.Image;
        return AppwriteMessage(
          senderId: msg["senderId"],
          content: msg["message"],
          timeStamp: DateTime.parse(msg["timeStamp"]),
          type: _messageType,
        );
      }).toList();
    }

    return AppwriteConversation(
      id: _document.$id,
      members: List<String>.from(data["members"]),
      messages: _messages,
      ownerId: data["ownerId"],
    );
  }
}
