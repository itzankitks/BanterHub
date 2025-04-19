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
