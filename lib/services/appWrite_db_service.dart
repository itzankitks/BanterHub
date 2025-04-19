// ignore_for_file: unused_import, prefer_final_fields, no_leading_underscores_for_local_identifiers, avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:banterhub/app_config.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

import '../models/appwrite_conversations_model.dart';
import '../models/appwrite_contact.dart';

class AppWriteDBService {
  static AppWriteDBService instance = AppWriteDBService();

  late Databases _appWriteDB;
  late Client _client;

  AppWriteDBService() {
    _client = Client()
        .setEndpoint(AppConfig.appwriteEndpoint)
        .setProject(AppConfig.appwriteProjectId);

    _appWriteDB = Databases(_client);
  }

  String _databaseId = AppConfig.appwriteDatabaseId;
  String _userCollectionId = AppConfig.appwriteUsersCollectionId;

  Future<bool> createUserInAppWriteDB(
    String _uid,
    String _name,
    String _email,
    String _imageURL,
  ) async {
    try {
      await _appWriteDB.createDocument(
        databaseId: _databaseId,
        collectionId: _userCollectionId,
        documentId: _uid,
        data: {
          "name": _name,
          "email": _email,
          "image": _imageURL,
          "lastSeen": DateTime.now().toUtc().toIso8601String(),
        },
      );
      print("✅ User created successfully in Appwrite Database");
      return true;
    } catch (e) {
      print("❌ Error creating user in DB: $e");
      return false;
    }
  }

  /// ✅ **Fetches & streams real-time user data**
  Stream<AppwriteContact> getAppWriteUserData(String _userID) {
    final StreamController<AppwriteContact> _controller =
        StreamController<AppwriteContact>();

    final realtime = Realtime(_client);
    final subscription = realtime.subscribe([
      'databases.$_databaseId.collections.$_userCollectionId.documents.$_userID'
    ]);

    Future<void> _fetchData() async {
      try {
        final response = await _appWriteDB.getDocument(
          databaseId: _databaseId,
          collectionId: _userCollectionId,
          documentId: _userID,
        );
        _controller.sink.add(AppwriteContact.fromAppwrite(response));
      } catch (e) {
        _controller.sink.addError(e);
      }
    }

    _fetchData();

    subscription.stream.listen((event) async {
      if (event.events
          .contains("databases.*.collections.*.documents.*.update")) {
        await _fetchData();
      }
    });

    _controller.onCancel = () {
      subscription.close();
    };

    return _controller.stream;
  }

  /// ✅ **Fetches & streams real-time conversations for a user**
  Stream<List<AppwriteConversations>> getAppWriteUserConversation(
      String _userID) {
    final StreamController<List<AppwriteConversations>> _controller =
        StreamController<List<AppwriteConversations>>();

    final realtime = Realtime(_client);
    final subscription = realtime.subscribe([
      'databases.$_databaseId.collections.$_userCollectionId.documents.$_userID'
    ]);

    Future<void> _fetchConversations() async {
      try {
        final response = await _appWriteDB.getDocument(
          databaseId: _databaseId,
          collectionId: _userCollectionId,
          documentId: _userID,
        );

        if (response.data.containsKey("conversations")) {
          List<dynamic> conversationsData = response.data["conversations"];

          List<AppwriteConversations> conversations = conversationsData
              .map((json) => AppwriteConversations.fromJson(jsonDecode(json)))
              .toList();

          _controller.sink.add(conversations);
        } else {
          _controller.sink.add([]);
        }
      } catch (e) {
        _controller.sink.addError(e);
      }
    }

    _fetchConversations();

    subscription.stream.listen((event) async {
      if (event.events
          .contains("databases.*.collections.*.documents.*.update")) {
        await _fetchConversations();
      }
    });

    _controller.onCancel = () {
      subscription.close();
    };

    return _controller.stream;
  }

  Stream<List<AppwriteContact>> getUserInAppWriteDB(String _searchName) {
    final StreamController<List<AppwriteContact>> _controller =
        StreamController<List<AppwriteContact>>();

    Future<void> _fetchUsers() async {
      try {
        final response = await _appWriteDB.listDocuments(
          databaseId: _databaseId,
          collectionId: _userCollectionId,
          queries: [
            Query.startsWith("name", _searchName), // ✅ Search by name
          ],
        );

        List<AppwriteContact> users = response.documents
            .map((doc) => AppwriteContact.fromAppwrite(doc))
            .toList();

        _controller.sink.add(users);
      } catch (e) {
        _controller.sink.addError(e);
      }
    }

    _fetchUsers(); // Fetch initial data

    return _controller.stream;
  }

  // Stream<AppwriteContact> getAppWriteUserData(String _userID) {
  //   // Creating a StreamController to emit updates to the Stream
  //   final StreamController<AppwriteContact> _controller =
  //       StreamController<AppwriteContact>();

  //   Future<void> _fetchData() async {
  //     try {
  //       final response = await _appWriteDB.getDocument(
  //         databaseId: _databaseId,
  //         collectionId: _userCollectionId,
  //         documentId: _userID,
  //       );
  //       _controller.sink.add(AppwriteContact.fromAppwrite(response));
  //     } catch (e) {
  //       _controller.sink.addError(e);
  //     }
  //   }

  //   // Periodically fetch the data (e.g., every 5 seconds)
  //   // Timer.periodic(Duration(seconds: 5), (_) {
  //   _fetchData();
  //   // });

  //   return _controller.stream;
  // }
}
