enum AppwriteMessageType {
  Text,
  Image,
  Video,
  Audio,
  File,
}

class AppwriteMessage {
  final String senderId;
  final String content;
  final DateTime timeStamp;
  final AppwriteMessageType type;

  AppwriteMessage({
    required this.senderId,
    required this.content,
    required this.timeStamp,
    required this.type,
  });
}
