import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

class AppWriteDBService {
  static AppWriteDBService instance = AppWriteDBService();

  late Databases _db;
  late Client _client;

  AppWriteDBService() {
    _client = Client()
        .setEndpoint('https://cloud.appwrite.io/v1')
        .setProject('67d0693f00204f5d1590');

    _db = Databases(_client);
  }

  String _databaseId = '67d082940028aa19474b';
  String _userCollectionId = '67d082bc0029f8042042';

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
          "lastSeen": DateTime.now().toUtc().toString(),
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
