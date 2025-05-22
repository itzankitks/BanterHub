import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  text,
  image,
  video,
  audio,
  file,
}

class Message {
  final String senderId;
  final String content;
  final Timestamp timeStamp;
  final MessageType type;

  Message({
    required this.senderId,
    required this.content,
    required this.timeStamp,
    required this.type,
  });
}
