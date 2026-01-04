import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ImagePreprocessor {
  /// Converts camera/gallery image to safe JPEG
  /// Fixes MIUI / MediaTek decompression crash
  static Future<File> process(File file) async {
    final tempDir = await getTemporaryDirectory();
    final targetPath = p.join(
      tempDir.path,
      '${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      minWidth: 1280,
      minHeight: 1280,
      quality: 80,
      format: CompressFormat.jpeg,
    );

    if (result == null) {
      throw Exception('Image preprocessing failed');
    }

    return File(result.path);
  }
}
