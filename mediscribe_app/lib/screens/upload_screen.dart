import 'dart:io';
import 'package:flutter/material.dart';

import 'package:mediscribe_app/core/color.dart';
import '../core/text_styles.dart';
import '../widgets/primary_button.dart';
import '../utils/image_picker.dart';
import 'processing_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _selectedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
        title: const Text(
          'Upload Prescription',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upload a prescription image',
              style: AppTextStyles.sectionTitle,
            ),
            const SizedBox(height: 8),
            const Text(
              'Make sure the image is clear and readable for accurate results.',
              style: AppTextStyles.subtitle,
            ),
            const SizedBox(height: 24),

            // IMAGE PREVIEW
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade50,
              ),
              child: _selectedImage == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.image_outlined,
                          size: 60,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No image selected',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
            ),

            const SizedBox(height: 24),

            // PICK IMAGE BUTTONS
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Gallery'),
                    onPressed: () async {
                      final image =
                          await ImagePickerHelper.pickFromGallery();
                      if (image != null) {
                        setState(() => _selectedImage = image);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Camera'),
                    onPressed: () async {
                      final image =
                          await ImagePickerHelper.pickFromCamera();
                      if (image != null) {
                        setState(() => _selectedImage = image);
                      }
                    },
                  ),
                ),
              ],
            ),

            const Spacer(),

            // PROCESS BUTTON
            PrimaryButton(
              text: 'Process Prescription',
              isDisabled: _selectedImage == null,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProcessingScreen(
                      image: _selectedImage!,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
