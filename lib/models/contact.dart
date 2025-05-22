// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:cloud_firestore/cloud_firestore.dart';

class Contact {
  final String id;
  final String name;
  final String email;
  final String image;
  final String lastSeen;

  Contact({
    required this.id,
    required this.name,
    required this.email,
    required this.image,
    required this.lastSeen,
  });

  factory Contact.fromFirestore(DocumentSnapshot _snapshot) {
    var _data = _snapshot.data() as Map<String, dynamic>;
    return Contact(
      id: _snapshot.id,
      name: _data["name"],
      email: _data["email"],
      image: _data["image"],
      lastSeen: _data["lastSeen"],
    );
  }
}
