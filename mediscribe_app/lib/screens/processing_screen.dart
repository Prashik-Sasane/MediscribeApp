import 'dart:io';
import 'package:flutter/material.dart';

import '../core/color.dart';
import '../services/ocr_service.dart';
import '../services/gemini_text_services.dart';
import 'result_screen.dart';

class ProcessingScreen extends StatefulWidget {
  final File image;

  const ProcessingScreen({super.key, required this.image});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  double _progress = 0.0;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _startPipeline();
  }

  Future<void> _startPipeline() async {
    // STEP 1 — OCR (ML Kit)
    setState(() => _progress = 0.25);
    final ocrText = await OcrService.extractText(widget.image);

    // STEP 2 — Gemini (TEXT UNDERSTANDING ONLY)
    setState(() => _progress = 0.65);
    final geminiText =
        await GeminiService.understandPrescription(ocrText);

    // STEP 3 — Finish
    setState(() {
      _progress = 1.0;
      _done = true;
    });

    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          text: geminiText ?? ocrText, // ✅ FIXED
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: _done
                  ? const Icon(
                      Icons.check_circle_rounded,
                      key: ValueKey('done'),
                      size: 72,
                      color: Colors.green,
                    )
                  : Icon(
                      Icons.health_and_safety_rounded,
                      key: const ValueKey('loading'),
                      size: 72,
                      color: Theme.of(context).colorScheme.primary,
                    ),
            ),

            const SizedBox(height: 24),

            Text(
              _done
                  ? 'Prescription processed successfully'
                  : 'Processing prescription…',
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: 220,
              child: LinearProgressIndicator(
                value: _progress,
                minHeight: 6,
                borderRadius: BorderRadius.circular(6),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              '${(_progress * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
