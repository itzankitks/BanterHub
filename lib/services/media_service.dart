import 'dart:io';
import 'package:image_picker/image_picker.dart';

class MediaService {
  static MediaService instance = MediaService();

  Future<File?> uploadImage(String inputSource) async {
    final picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(
        source:
            inputSource == 'camera' ? ImageSource.camera : ImageSource.gallery);

    // Check if the image was picked, then convert XFile to File
    return pickedImage != null ? File(pickedImage.path) : null;
  }
}
