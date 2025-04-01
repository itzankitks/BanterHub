// ignore_for_file: unused_import, prefer_final_fields, no_leading_underscores_for_local_identifiers, avoid_print

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:banterhub/app_config.dart';

class AppWriteDBService {
  static AppWriteDBService instance = AppWriteDBService();

  late Databases _db;
  late Client _client;

  AppWriteDBService() {
    _client = Client()
        .setEndpoint(AppConfig.appwriteEndpoint)
        .setProject(AppConfig.appwriteProjectId);

    _db = Databases(_client);
  }

  String _databaseId = AppConfig.appwriteDatabaseId;
  // String _userCollectionId = '67e8d2f90012600185b1';
  String _userCollectionId = AppConfig.appwriteUsersCollectionId;

  Future<bool> createUserInAppWriteDB(
    String _uid,
    String _name,
    String _email,
    String _imageURL,
  ) async {
    try {
      await _db.createDocument(
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
}
