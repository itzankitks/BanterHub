// import 'dart:io';
// import 'package:appwrite/appwrite.dart';
// import 'package:appwrite/models.dart' as models;

// class AppWriteStorageService {
//   static final AppWriteStorageService instance = AppWriteStorageService();

//   final Storage _storage;
//   final String _bucketId = '67d0848100143fd5c1dc'; // profile_images

//   AppWriteStorageService()
//       : _storage = Storage(Client()
//             .setEndpoint('https://cloud.appwrite.io/v1')
//             .setProject('67d0693f00204f5d1590')
//             .setSelfSigned(status: true));

//   Future<String?> uploadUserImageToAppWrite(String uid, File image) async {
//     try {
//       final inputFile =
//           InputFile.fromPath(path: image.path, filename: '${uid}.jpg');

//       // Upload image to Appwrite Storage
//       models.File uploadedFile = await _storage.createFile(
//         bucketId: _bucketId,
//         fileId: ID.unique(),
//         file: inputFile,
//       );

//       // ✅ Generate a Public URL using getFileView
//       String imageUrl = _storage
//           .getFileView(
//             bucketId: _bucketId,
//             fileId: uploadedFile.$id,
//           )
//           .toString();

//       print("✅ Image uploaded successfully: $imageUrl");
//       return imageUrl;
//     } catch (e) {
//       print("❌ Error uploading user profile image: $e");
//       return null;
//     }
//   }
// }

import 'dart:typed_data';
import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:banterhub/app_config.dart';

class AppWriteStorageService {
  static final AppWriteStorageService instance = AppWriteStorageService();

  final Storage _storage;
  final String _bucketId = '67d0848100143fd5c1dc'; // profile_images

  AppWriteStorageService()
      : _storage = Storage(Client()
            .setEndpoint('https://cloud.appwrite.io/v1')
            .setProject('67d0693f00204f5d1590')
            .setSelfSigned(status: true));

  // 📌 Mobile: Upload Image as a File
  Future<String?> uploadUserImageToAppWrite(String uid, File image) async {
    try {
      final inputFile = InputFile.fromPath(
        path: image.path,
        filename: '${uid}.jpg',
      );

      models.File uploadedFile = await _storage.createFile(
        bucketId: _bucketId,
        fileId: ID.unique(),
        file: inputFile,
      );

      // String imageUrl = _storage.getFileDownload(
      //   bucketId: _bucketId,
      //   fileId: uploadedFile.$id,
      // );
      String imageUrl =
          "https://cloud.appwrite.io/v1/storage/buckets/$_bucketId/files/${uploadedFile.$id}/preview?project=${AppConfig.projectId}";

      print("✅ Image uploaded successfully: $imageUrl");
      return imageUrl;
    } catch (e) {
      print("❌ Error uploading image: $e");
      return null;
    }
  }

  // 📌 Web: Upload Image as Bytes (Uint8List)
  // Future<String?> uploadUserImageBytesToAppWrite(
  //     String uid, Uint8List bytes) async {
  //   try {
  //     final inputFile = InputFile.fromBytes(
  //       bytes: bytes,
  //       filename: '${uid}.jpg',
  //     );

  //     models.File uploadedFile = await _storage.createFile(
  //       bucketId: _bucketId,
  //       fileId: ID.unique(),
  //       file: inputFile,
  //     );

  //     String imageUrl = _storage
  //         .getFileView(
  //           bucketId: _bucketId,
  //           fileId: uploadedFile.$id,
  //         )
  //         .toString();

  //     print("✅ Image uploaded successfully: $imageUrl");
  //     return imageUrl;
  //   } catch (e) {
  //     print("❌ Error uploading image: $e");
  //     return null;
  //   }
  // }
}
