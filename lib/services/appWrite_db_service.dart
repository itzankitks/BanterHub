// ignore_for_file: unused_import, prefer_final_fields, no_leading_underscores_for_local_identifiers, avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:banterhub/app_config.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:banterhub/models/appwrite_message.dart';

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
  String _conversationCollectionId =
      AppConfig.appwriteConversationsCollectionId;

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

  Future<void> updateUserInAppWriteDB(
    String uid,
    String? name,
    String? email,
    String? imageURL,
  ) async {
    try {
      final Map<String, dynamic> data = {
        "lastSeen": DateTime.now().toIso8601String(),
      };

      if (name != null) data["name"] = name;
      if (email != null) data["email"] = email;
      if (imageURL != null) data["image"] = imageURL;

      await _appWriteDB.updateDocument(
        databaseId: _databaseId,
        collectionId: _userCollectionId,
        documentId: uid,
        data: data,
      );
    } catch (e) {
      print("Error updating user in DB: $e");
    }
  }

  Future<void> createOrGetConversationInAppWriteDB(
    String currentUserId,
    String receiverUserId,
    Future<void> Function(String conversationId) onSuccess,
  ) async {
    try {
      // 🔍 Step 1: Check if conversation already exists
      final result = await _appWriteDB.listDocuments(
        databaseId: _databaseId,
        collectionId: _conversationCollectionId,
        queries: [
          Query.contains('members', currentUserId),
          Query.contains('members', receiverUserId),
        ],
      );
      print("currentUserId: $currentUserId");
      print("receiverUserId: $receiverUserId");
      print("result: ${result.documents.asMap()}");

      if (result.documents.isNotEmpty) {
        final existingConversationId = result.documents.first.$id;
        print("existingConversationId: $existingConversationId");
        await onSuccess(existingConversationId);
      } else {
        final newConversation = await _appWriteDB.createDocument(
          databaseId: _databaseId,
          collectionId: _conversationCollectionId,
          documentId: ID.unique(),
          data: {
            'members': [currentUserId, receiverUserId],
            'messages': [],
            'ownerId': currentUserId,
          },
        );

        await onSuccess(newConversation.$id);
      }
    } catch (e) {
      print("Error creating or getting conversation: $e");
    }
  }

  Future<void> sendMessageInAppWriteDB(
    String _conversationId,
    AppwriteMessage _message,
  ) async {
    try {
      final doc = await _appWriteDB.getDocument(
        databaseId: _databaseId,
        collectionId: _conversationCollectionId,
        documentId: _conversationId,
      );

      print("doc: ${doc.data['messages'].runtimeType}");

      final messages = doc.data['messages'] as List<dynamic>? ?? [];
      messages.add(jsonEncode({
        'senderId': _message.senderId,
        'message': _message.content,
        'type': _message.type == AppwriteMessageType.Text ? 'text' : 'image',
        'timeStamp': _message.timeStamp.toIso8601String(),
      }));

      await _appWriteDB.updateDocument(
        databaseId: _databaseId,
        collectionId: _conversationCollectionId,
        documentId: _conversationId,
        data: {'messages': messages},
      );
    } catch (e) {
      print("Error adding message in DB: $e");
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
  Stream<List<AppwriteConversationsSnippet>> getAppWriteUserConversation(
      String _userID) {
    final StreamController<List<AppwriteConversationsSnippet>> _controller =
        StreamController<List<AppwriteConversationsSnippet>>.broadcast();

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

          List<AppwriteConversationsSnippet> conversations = conversationsData
              .map((json) =>
                  AppwriteConversationsSnippet.fromJson(jsonDecode(json)))
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
      if (event.events.any((e) => e.contains("update"))) {
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

  Stream<AppwriteConversation> getConversationInAppWriteDB(
      String conversationId) {
    final StreamController<AppwriteConversation> _controller =
        StreamController<AppwriteConversation>.broadcast();

    final realtime = Realtime(_client);
    final subscription = realtime.subscribe([
      'databases.$_databaseId.collections.${AppConfig.appwriteConversationsCollectionId}.documents.$conversationId'
    ]);

    Future<void> _fetchConversation() async {
      try {
        final response = await _appWriteDB.getDocument(
          databaseId: _databaseId,
          collectionId: AppConfig.appwriteConversationsCollectionId,
          documentId: conversationId,
        );

        AppwriteConversation conversation =
            AppwriteConversation.fromAppwrite(response);
        _controller.sink.add(conversation);
      } catch (e) {
        _controller.sink.addError(e);
      }
    }

    _fetchConversation(); // initial fetch

    subscription.stream.listen((event) async {
      if (event.events.any((e) => e.contains("update"))) {
        await _fetchConversation();
      }
    });

    _controller.onCancel = () {
      subscription.close();
    };

    return _controller.stream;
  }
}
