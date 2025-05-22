// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:banterhub/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationSnippet {
  final String id;
  final String conversationId;
  final String lastMessage;
  final String name;
  final String image;
  final int unseenCount;
  final Timestamp timeStamp;

  ConversationSnippet({
    required this.id,
    required this.conversationId,
    required this.lastMessage,
    required this.name,
    required this.image,
    required this.unseenCount,
    required this.timeStamp,
  });

  factory ConversationSnippet.fromFirestore(DocumentSnapshot _snapshot) {
    var _data = _snapshot.data() as Map<String, dynamic>;
    return ConversationSnippet(
      id: _snapshot.id,
      conversationId: _data["conversationId"],
      lastMessage: _data["lastMessage"] ?? "",
      name: _data["name"],
      image: _data["image"],
      unseenCount: _data["unseenCount"],
      timeStamp: _data["timeStamp"],
    );
  }
}

class Conversation {
  final String id;
  final List members;
  final List<Message> messages;
  final String ownerId;

  Conversation({
    required this.id,
    required this.members,
    required this.messages,
    required this.ownerId,
  });

  factory Conversation.fromFirestore(DocumentSnapshot _snapshot) {
    var _data = _snapshot.data() as Map<String, dynamic>;
    var _messages = _data["messages"];
    if (_messages != null) {
      _messages = _messages.map(
        (_m) {
          var _messageType =
              _m["type"] == "text" ? MessageType.text : MessageType.image;
          return Message(
              senderId: _m["senderId"],
              content: _m["message"],
              timeStamp: _m["timeStamp"],
              type: _messageType);
        },
      ).toList();
    } else {
      _messages = null;
    }
    return Conversation(
      id: _snapshot.id,
      members: List<String>.from(_data["members"]),
      messages: _messages,
      ownerId: _data["ownerId"],
    );
  }
}
