import 'package:appwrite/appwrite.dart';

class AppwriteConversations {
  final String id;
  final String conversationId;
  final String lastMessage;
  final String name;
  final String image;
  final int unseenCount;
  final DateTime timeStamp;

  AppwriteConversations({
    required this.id,
    required this.conversationId,
    required this.lastMessage,
    required this.name,
    required this.image,
    required this.unseenCount,
    required this.timeStamp,
  });

  factory AppwriteConversations.fromJson(Map<String, dynamic> json) {
    return AppwriteConversations(
      id: json["userId"],
      conversationId: json["conversationId"],
      lastMessage: json["lastMessage"] ?? "",
      name: json["name"],
      image: json["image"],
      unseenCount: json["unseenCount"] ?? 0,
      timeStamp: DateTime.parse(
          json["timeStamp"]), // ✅ Convert ISO 8601 string to DateTime
    );
  }
}
