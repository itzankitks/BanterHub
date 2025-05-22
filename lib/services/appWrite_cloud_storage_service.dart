// ignore_for_file: unnecessary_brace_in_string_interps, avoid_print

import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:banterhub/app_config.dart';

class AppWriteStorageService {
  static final AppWriteStorageService instance = AppWriteStorageService();

  final Storage _profileStorage;
  final Storage _messageStorage;
  final String _profileBucketId = AppConfig.appwriteProfileImageBucketId;
  final String _messageBucketId = AppConfig.appwriteMessageImageBucketId;

  AppWriteStorageService()
      : _profileStorage = Storage(Client()
            .setEndpoint(AppConfig.appwriteEndpoint)
            .setProject(AppConfig.appwriteProjectId)
            .setSelfSigned(status: true)),
        _messageStorage = Storage(Client()
            .setEndpoint(AppConfig.appwriteImagesProjectEndpoint)
            .setProject(AppConfig.appwriteImagesProjectId)
            .setSelfSigned(status: true));

  // 📌 Mobile: Upload Image as a File
  Future<String?> uploadUserImageToAppWrite(String uid, File image) async {
    try {
      final inputFile = InputFile.fromPath(
        path: image.path,
        filename: '${uid}.jpg',
      );

      models.File uploadedFile = await _profileStorage.createFile(
        bucketId: _profileBucketId,
        fileId: ID.unique(),
        file: inputFile,
      );

      String imageUrl =
          "https://cloud.appwrite.io/v1/storage/buckets/$_profileBucketId/files/${uploadedFile.$id}/view?project=${AppConfig.appwriteProjectId}";

      print("✅ Image uploaded successfully: $imageUrl");
      return imageUrl;
    } catch (e) {
      print("❌ Error uploading image: $e");
      return null;
    }
  }

  Future<String?> uploadMediaMessageToAppWrite(
      String conversationId, String uid, File mediaFile) async {
    try {
      print("conversationId: $conversationId");
      final timeStamp = DateTime.now();
      final fileName =
          "${conversationId}_${uid}_$timeStamp.${mediaFile.path.split('.').last}";

      final inputFile = InputFile.fromPath(
        path: mediaFile.path,
        filename: fileName,
      );

      models.File uploadedFile = await _messageStorage.createFile(
        bucketId: _messageBucketId,
        fileId: ID.unique(),
        file: inputFile,
      );

      final fileUrl =
          "${AppConfig.appwriteImagesProjectEndpoint}/storage/buckets/$_messageBucketId/files/${uploadedFile.$id}/view?project=${AppConfig.appwriteImagesProjectId}";

      print("✅ Media message uploaded successfully: $fileUrl");
      return fileUrl;
    } catch (e) {
      print("❌ Error uploading media message: $e");
      return null;
    }
  }
}
