import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

import '../core/color.dart';
import '../widgets/primary_button.dart';
import 'processing_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _selectedImage;
  bool _loadingImage = false;

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _loadingImage = true);

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source);

      if (picked == null) {
        setState(() => _loadingImage = false);
        return;
      }

      File finalImage = File(picked.path);

      // 🔹 Try compression (optional, safe)
      try {
        final tempDir = await getTemporaryDirectory();
        final targetPath =
            '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

        final compressed = await FlutterImageCompress.compressAndGetFile(
          picked.path,
          targetPath,
          quality: 75,
          format: CompressFormat.jpeg,
        );

        if (compressed != null) {
          finalImage = File(compressed.path);
        }
      } catch (_) {
        // Compression failed → fallback to original image
      }

      setState(() => _selectedImage = finalImage);
    } finally {
      setState(() => _loadingImage = false);
    }
  }

  void _processPrescription() {
    if (_selectedImage == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProcessingScreen(image: _selectedImage!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Upload Prescription'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 📸 Image Preview Card
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
              ),
              child: _loadingImage
                  ? const Center(child: CircularProgressIndicator())
                  : _selectedImage == null
                      ? Center(
                          child: Text(
                            'No image selected',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        ),
            ),

            const SizedBox(height: 24),

            // 📷 Camera / Gallery buttons
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    text: 'Camera',
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    text: 'Gallery',
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                ),
              ],
            ),

            const Spacer(),

            // ▶ Process button (bottom)
            PrimaryButton(
              text: 'Process Prescription',
              onPressed:
                  _selectedImage != null ? _processPrescription : () {},
              isDisabled: _selectedImage == null,
            ),
          ],
        ),
      ),
    );
  }
}
