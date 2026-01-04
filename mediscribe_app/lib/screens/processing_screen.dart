import 'dart:io';
import 'package:flutter/material.dart';

import 'package:mediscribe_app/core/color.dart';
import '../core/text_styles.dart';
import '../services/ocr_service.dart';
import 'package:mediscribe_app/services/gemini_text_services.dart';
import 'result_screen.dart';

class ProcessingScreen extends StatefulWidget {
  final File image;

  const ProcessingScreen({super.key, required this.image});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  @override
  void initState() {
    super.initState();
    _processPrescription();
  }

  Future<void> _processPrescription() async {
    try {
      // 1️⃣ OCR
      final rawText = await OcrService.extractText(widget.image);

      // 2️⃣ Gemini text cleanup
      final cleanedText = rawText.isEmpty
          ? 'No readable text detected.'
          : await GeminiTextService.cleanPrescriptionText(rawText);

      if (!mounted) return;

      // 3️⃣ Navigate to result
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            extractedText: cleanedText,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Processing failed: $e')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              'Analyzing prescription…',
              style: AppTextStyles.subtitle,
            ),
          ],
        ),
      ),
    );
  }
}
