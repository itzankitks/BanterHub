// import 'dart:io';
// import 'package:firebase_storage/firebase_storage.dart';

// class CloudStorageService {
//   static final CloudStorageService instance = CloudStorageService();

//   late FirebaseStorage _storage;
//   late Reference _baseRef;

//   String _profileImages = "profile_images";

//   CloudStorageService() {
//     _storage = FirebaseStorage.instance;
//     _baseRef = _storage.ref();
//   }

//   Future<String?> uploadUserImage(String _uid, File _image) async {
//     try {
//       final userImageRef = _baseRef.child("$_profileImages/$_uid");

//       UploadTask uploadTask = userImageRef.putFile(_image);

//       TaskSnapshot snapshot = await uploadTask;

//       String downloadURL = await snapshot.ref.getDownloadURL();

//       print("Image uploaded successfully: $downloadURL");
//       return downloadURL;
//     } catch (e) {
//       print("Error uploading user profile image: $e");
//       return null;
//     }
//   }
// }
