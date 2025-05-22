// ignore_for_file: prefer_final_fields, no_leading_underscores_for_local_identifiers, avoid_print

import 'package:banterhub/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/contact.dart';
import '../models/conversation.dart';

class DBService {
  static DBService instance = DBService();

  late FirebaseFirestore _db;

  DBService() {
    _db = FirebaseFirestore.instance;
  }

  String _userCollection = "Users";
  String _userConversationCollection = "Conversations";

  Future<void> createUserInDB(
    String _uid,
    String _name,
    String _email,
    String _imageURL,
  ) async {
    try {
      return await _db.collection(_userCollection).doc(_uid).set({
        "name": _name,
        "email": _email,
        "image": _imageURL,
        "lastSeen": DateTime.now().toUtc(),
      });
    } catch (e) {
      print("Error creating user in DB $e");
    }
  }

  Future<void> updateUserInDB(
    String _uid,
    String? _name,
    String? _email,
    String? _imageURL,
  ) async {
    try {
      final Map<String, dynamic> data = {
        "lastSeen": DateTime.now().toIso8601String(),
      };

      if (_name != null) data["name"] = _name;
      if (_email != null) data["email"] = _email;
      if (_imageURL != null) data["image"] = _imageURL;

      return await _db.collection(_userCollection).doc(_uid).update(data);
    } catch (e) {
      print("Error updating user in DB $e");
    }
  }

  Future<void> sendMessage(
    String _conversationId,
    Message _message,
  ) {
    var _ref = _db.collection(_userConversationCollection).doc(_conversationId);
    return _ref.update({
      "messages": FieldValue.arrayUnion([
        {
          "senderId": _message.senderId,
          "message": _message.content,
          "type": _message.type == MessageType.text ? "text" : "image",
          "timeStamp": _message.timeStamp,
        }
      ]),
    });
  }

  Future<void> createOrGetConversation(
      String _currentUserId,
      String _receiverUserId,
      Future<void> onSuccess(String _conversationId)) async {
    try {
      var userConversationRef = _db
          .collection(_userCollection)
          .doc(_currentUserId)
          .collection(_userConversationCollection)
          .doc(_receiverUserId);

      var conversationSnapshot = await userConversationRef.get();

      if (conversationSnapshot.exists && conversationSnapshot.data() != null) {
        String conversationId = conversationSnapshot.data()!["conversationId"];
        await onSuccess(conversationId);
      } else {
        // Create a new conversation
        var conversationRef = _db.collection(_userConversationCollection).doc();
        String newConversationId = conversationRef.id;

        // Set data for the new conversation
        await conversationRef.set({
          "members": [_currentUserId, _receiverUserId],
          "messages": [],
          "ownerId": _currentUserId,
        });

        // Update each user's subcollection with this conversation reference
        await _db
            .collection(_userCollection)
            .doc(_currentUserId)
            .collection(_userConversationCollection)
            .doc(_receiverUserId)
            .set({
          "conversationId": newConversationId,
        });

        await _db
            .collection(_userCollection)
            .doc(_receiverUserId)
            .collection(_userConversationCollection)
            .doc(_currentUserId)
            .set({
          "conversationId": newConversationId,
        });

        await onSuccess(newConversationId);
      }
    } catch (e) {
      print("Error creating or getting conversation $e");
    }
  }

  Stream<Contact> getUserData(String _userID) {
    var ref = _db.collection(_userCollection).doc(_userID);
    return ref.get().asStream().map((_snapshot) {
      return Contact.fromFirestore(_snapshot);
    });
  }

  Stream<List<ConversationSnippet>> getUserConversation(String _userID) {
    var ref = _db
        .collection(_userCollection)
        .doc(_userID)
        .collection(_userConversationCollection);
    return ref.snapshots().map(
      (_snapshot) {
        return _snapshot.docs.map((_doc) {
          return ConversationSnippet.fromFirestore(_doc);
        }).toList();
      },
    );
  }

  Stream<List<Contact>> getUserInDB(String _searchName) {
    var ref = _db.collection(_userCollection).where("name",
        isGreaterThanOrEqualTo: _searchName, isLessThan: "$_searchName\uf8ff");
    return ref.get().asStream().map((_snapshot) {
      return _snapshot.docs.map((_doc) {
        return Contact.fromFirestore(_doc);
      }).toList();
    });
  }

  Stream getConversation(String _conversationId) {
    var ref = _db.collection(_userConversationCollection).doc(_conversationId);
    return ref.snapshots().map((_snapshot) {
      return Conversation.fromFirestore(_snapshot);
    });
  }
}
