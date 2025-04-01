// ignore_for_file: unused_import, prefer_final_fields, no_leading_underscores_for_local_identifiers, avoid_print

import 'dart:async';

import 'package:banterhub/app_config.dart';
import 'package:appwrite/appwrite.dart';
// import 'package:appwrite/models.dart' as models;
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
          // "lastSeen": DateTime.now().toUtc().toString(),
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

  Stream<AppwriteContact> getAppWriteUserData(String _userID) {
    // Creating a StreamController to emit updates to the Stream
    final StreamController<AppwriteContact> _controller =
        StreamController<AppwriteContact>();

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

    // Periodically fetch the data (e.g., every 5 seconds)
    // Timer.periodic(Duration(seconds: 5), (_) {
    _fetchData();
    // });

    return _controller.stream;
  }
}
