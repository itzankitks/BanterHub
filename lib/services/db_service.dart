// ignore_for_file: prefer_final_fields, no_leading_underscores_for_local_identifiers, avoid_print

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
    var ref = _db.collection(_userCollection);
    return ref.get().asStream().map((_snapshot) {
      return _snapshot.docs.map((_doc) {
        return Contact.fromFirestore(_doc);
      }).toList();
    });
  }
}
