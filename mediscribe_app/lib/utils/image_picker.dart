import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Pick image from gallery
  static Future<File?> pickFromGallery() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  /// Pick image from camera
  /// (Works on Android, ignored on Windows if unsupported)
  static Future<File?> pickFromCamera() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      return File(image.path);
    }
    return null;
  }
}
