import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

class CloudStorageService {
  static final CloudStorageService instance = CloudStorageService();

  late FirebaseStorage _storage;
  late Reference _baseRef;

  String _profileImages = "profile_images";
  String _messages = "messages";
  String _images = "images";

  CloudStorageService() {
    _storage = FirebaseStorage.instance;
    _baseRef = _storage.ref();
  }

  Future<String?> uploadUserImage(String _uid, File _image) async {
    try {
      final userImageRef = _baseRef.child("$_profileImages/$_uid");

      UploadTask uploadTask = userImageRef.putFile(_image);

      TaskSnapshot snapshot = await uploadTask;

      String downloadURL = await snapshot.ref.getDownloadURL();

      print("Image uploaded successfully: $downloadURL");
      return downloadURL;
    } catch (e) {
      print("Error uploading user profile image: $e");
      return null;
    }
  }

  Future<TaskSnapshot> uploadMediaMessage(String uid, File file) async {
    final timeStamp = DateTime.now(); //.millisecondsSinceEpoch;
    final fileName = "${basename(file.path)}_${timeStamp.toString()}";

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child("messages")
          .child(uid)
          .child("images")
          .child(fileName);

      final uploadTask = ref.putFile(file);
      return await uploadTask;
    } catch (e) {
      print("Error uploading media message: $e");
      rethrow; // Forward the error if needed
    }
  }
}
