// ignore_for_file: no_leading_underscores_for_local_identifiers, unnecessary_cast

import 'package:appwrite/models.dart';

class AppwriteContact {
  final String id;
  final String name;
  final String email;
  final String image;
  final DateTime lastSeen;

  AppwriteContact({
    required this.id,
    required this.name,
    required this.email,
    required this.image,
    required this.lastSeen,
  });

  factory AppwriteContact.fromAppwrite(Document _document) {
    var _data = _document.data as Map<String, dynamic>;
    return AppwriteContact(
      id: _document.$id,
      name: _data["name"],
      email: _data["email"],
      image: _data["image"],
      lastSeen: DateTime.parse(_data["lastSeen"]),
    );
  }
}
