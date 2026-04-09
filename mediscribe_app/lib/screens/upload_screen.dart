import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
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
      final picked = await picker.pickImage(source: source, imageQuality: 90);

      if (picked == null) return;

      File finalImage = File(picked.path);

      // Compression Logic
      try {
        final tempDir = await getTemporaryDirectory();
        final targetPath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

        final compressed = await FlutterImageCompress.compressAndGetFile(
          picked.path,
          targetPath,
          quality: 70,
        );

        if (compressed != null) {
          finalImage = File(compressed.path);
        }
      } catch (e) {
        debugPrint("Compression error: $e");
      }

      setState(() => _selectedImage = finalImage);
    } finally {
      setState(() => _loadingImage = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Prescription', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  "Please upload a clear photo of your doctor's prescription.",
                  style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 15),
                ),
                const SizedBox(height: 24),

                // 📸 IMAGE PREVIEW / UPLOAD ZONE
                _buildUploadZone(context),

                const SizedBox(height: 32),

                // 📷 ACTION TILES
                const Text("Select Source", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        context,
                        icon: Icons.camera_alt_rounded,
                        label: "Camera",
                        onTap: () => _pickImage(ImageSource.camera),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionCard(
                        context,
                        icon: Icons.photo_library_rounded,
                        label: "Gallery",
                        onTap: () => _pickImage(ImageSource.gallery),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // 💡 GUIDELINES SECTION
                _buildGuidelineSection(context),

                const SizedBox(height: 32), // Added space before button

                // ▶ PROCESS BUTTON
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _selectedImage != null ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProcessingScreen(image: _selectedImage!),
                          ),
                        );
                      } : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7DFF),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: colorScheme.onSurface.withOpacity(0.12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text("Process Prescription", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadZone(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => _pickImage(ImageSource.gallery),
      child: Container(
        height: 240,
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _selectedImage == null ? colorScheme.primary.withOpacity(0.2) : Colors.transparent,
            width: 2,
            // You can use a dotted border package here, or a standard border
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: _loadingImage
                  ? const CircularProgressIndicator()
                  : _selectedImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_upload_outlined, size: 48, color: colorScheme.primary),
                            const SizedBox(height: 12),
                            const Text("No Prescription Selected", style: TextStyle(fontWeight: FontWeight.w600)),
                            Text("Tap to browse files", style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.5))),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.file(_selectedImage!, width: double.infinity, fit: BoxFit.cover),
                        ),
            ),
            if (_selectedImage != null)
              Positioned(
                top: 12,
                right: 12,
                child: IconButton.filled(
                  onPressed: () => setState(() => _selectedImage = null),
                  icon: const Icon(Icons.close, size: 20),
                  style: IconButton.styleFrom(backgroundColor: Colors.black54),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.onSurface.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF2E7DFF), size: 28),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidelineSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, size: 20, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              const Text("Tips for a better scan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          _tipRow("Ensure good lighting and avoid shadows"),
          _tipRow("Place the prescription on a flat surface"),
          _tipRow("Keep the camera steady and focus clearly"),
        ],
      ),
    );
  }

  Widget _tipRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.black87))),
        ],
      ),
    );
  }
}